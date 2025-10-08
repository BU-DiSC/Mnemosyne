

# The codebase for "Mnemosyne: Dynamic Workload-Aware BF Tuning via Accurate Statistics in LSM trees" 

The repository is structured as follows:

* **`skew-aware-rocksdb-8.9.1/`**: A modified version of RocksDB (v8.9.1) that incorporates Mnemosyne and Mnemosyne+.
* **`skew-aware-bpk-benchmark/`**: Contains the main benchmark scripts for our experiments.
* **`K-V-Workload-Generator/`**: Tools for generating custom key-value workloads (see [KVBench](https://dl.acm.org/doi/abs/10.1145/3662165.3662765)).
* **`workload_generator_scripts/`**: Scripts for automating workload generation.
* **`plot_scripts/`**: Scripts to generate plots from the benchmark results.
* **`YCSB-cpp/`**: Contains the YCSB benchmark scripts.
* **`distribute_lsm_bfsize/`**: a standalone microbenchmark when solving the optimal bits-per-key assignment given access statistics.
* **`exp-figures/`**: Directory where the generated figures will be saved.


## Hardware and Software Environment

All benchmarks were executed on the hardware environment specified below. Please note that absolute performance metrics (e.g., latency, throughput) will vary depending on the system configuration. However, other results, such as read bytes and relative performance between methods, should be consistent with the findings presented in our paper.

* **CPU**: 2x Intel Xeon Gold 6230 2.1GHz (each with 20 cores and virtualization enabled)
* **Memory**: 375GB DDR4 RAM
* **Storage**:
    * **Fast SSD**: 350GB Optane P4800X SSD 
    * **Slow SSD**: 932GB NVM SSD (Intel P4510 SFF) 
    * **HDD**: 1.9TB Hard Disk Drive
    * **RAM Disk**: An 80GB partition created in main memory using `tmpfs`.
* **Operating System**: Rocky Linux 8.10 (Green Obsidian)
* **Kernel**: 4.18.0-553.56.1.el8\_10.x86\_64
* **Compiler**: GCC 12.3.1
* **Key Dependencies**:
    *  [RocksDB Dependencies](https://github.com/facebook/rocksdb/blob/main/INSTALL.md) (e.g., zlib, bzip2, lz4, zstd)
    * `python3` (3.6.8) and `matplotlib` (3.0.3) for plotting



## Prerequisites

Before running any experiments, please ensure your environment is set up correctly:

1.  **Install Dependencies**: Install the necessary libraries and tools listed above using your system's package manager (e.g., `apt-get` or `yum`).

2.  **Increase File Limit**: It's crucial to increase the file descriptor limit. This setting is not permanent and must be run in the same shell session as the experiments. Otherwise, experiments can be interrupted due to insufficient maximum open files.
    ```bash
    ulimit -n 65536
    ```
3.  **Storage Setup**: You will need to specify paths for your storage devices in the experiment scripts.
    * **Fast SSD**: The primary database path is assumed to use a fast SSD with at least **100GB** of free space.
    * **Slower SSD**: For some experiments (e.g., Figure 13), a slower SSD is required. This drive should have at least **40GB** of free space.
    * **HDD**: For codebase, logging, and workloads. To accommodate all workloads, the HDD should have at least **300GB** free space. If not, you may have to run experimental sripts separately and manually remove unused workloads to release space, but this still requires at least **80GB** free space. 
    * **RAM Disk (Optional but Recommended)**: To significantly accelerate experiments for Figure 4 and Figure 10, create and use a RAM disk of at least **80GB**.
        ```bash
        # Example for creating an 80GB RAM disk
        sudo mkdir /mnt/ramdisk
        sudo mount -t tmpfs -o size=80G tmpfs /mnt/ramdisk
        ```

## SSD Performance Expectations

Our in-house SSDs have a higher write throughput than standard AWS NVMe SSDs. As a result, you may observe a **2.5-5x longer execution time** when running these experiments on commodity cloud hardware. Below is a general comparison of SSD read/write speeds to help you gauge performance expectations. Performance metrics such as latency and throughput are highly dependent on the underlying hardware. For optimal visualization, you may need to adjust the `ymax` parameter in our plotting scripts. To benchmark your storage device's random read/write throughput, we provide a fio configuration file `fio-rand-RW.fio`. After installing fio (e.g., `apt-get install fio` or `yum install fio`), run `fio fio-rand-RW.fio` with your storage device. 

| SSD Type             | Typical Read Speed (MB/s) | Typical Write Speed (MB/s) |
| :------------------- | :-----------------------: | :------------------------: |
| **Our Fast SSD** |         1231         |         821         |
| **Our Slow SSD** |       694       |       463        |
| **AWS NVMe Storage (Nitro SSDs)** |       260      |       173      |

*Note: These are approximate values and can vary based on the specific model, manufacturer, and system configuration.*


## Quick Start: Running a Single Workload

This section provides a detailed walkthrough for users who want to understand the individual components of the system (workload generation, compilation, etc.) by running a single experiment. For automated, full-scale reproduction of the paper's findings, please proceed directly to the `Reproducing Paper Results` section.

1.  **Workload Generation**: To generate a key-value workload, you need to go into directory `K-V-Workload-Generator` and simply give 

    ```
    make
    ./load_gen -I10000 -E512 -L0.25
    ```

     with the desired parameters. These include: Number of inserts, updates, deletes, point & range lookups, distribution styles, etc. 
     In the above example, it will generate a workload file (e.g., `workload.txt`) with 10000 inserts (for pre-populating a database) with 128-byte key size and 384-byte value size (`E` specifies the overall entry size and `L` specifies the proportion between the key size and the key-value size).

     We can further use preloading feature to generate another workload to benchmark. For example, we can run

    ```
    ./load_gen -E512 -L0.25 --PL -Q3000 --OP query_workload.txt
    ```
    This will generate a text file `query_workload.txt` that contains 3000 point queries on existing keys by preloading `workload.txt` generated earlier.

    To vary the distribution of point queries, you can specify `--ED [ED] --ZD [ZD]`, where `[ED]` and `[ZD]` represent the distribution number for existing and non-existing point queries, respectively (distribution number: 0->uniform, 1->normal, 2->beta, 3->zipf)

    More details can be found by running `./load_gen --help`.

2.  **RocksDB Library Compilation**: Go to the `skew-aware-rocksdb-8.9.1` directory and run
    ```
    make static_lib
    ```
    You can speed up this process by using the `-j` flag. For example, to use all available CPU cores, run make static_lib `-j$(nproc)`. 


3.  **Benchmarking Compilation and Execution**: We provide a rich set of benchmark codes under `skew-aware-bpk-benchmark`. You can compile all of them by `make` after you go into that directory. Here is the list of benchmark codes:

    * `bpk_benchmark`: Measure the number of unnecessarily accessed data blocks by replaying the query workload against different bits-per-key allocation strategy.

    * `query_lat_exp`: Pre-populate the database using an ingestion workload and measure the query performance using a mixed update and query workload (see workload type II in our paper).

    * `query_statistics_est_benchmark`: Measure the estimation accuracy of the runtime access statistics.

    * `runtime_tput_exp`: Measure the throughput along with the actual used bits-per-key by running a workload mixed with inserts, updates, and queries (see workoad type I in our paper)

    These executables have a large set of common parameters and presume that workloads are already generated using our workload generator. Take `query_lat_exp` as an example:

    ```
    ./query_lat_exp -E [E] --dd --iwp [path/to/ingestion_workload] --qwp [path/to/benchmark_workload] --dw --dr
    ```

    where `[E]` is the entry size generated from our workload generator, `[path/to/ingestion_workload]` means the path of the ingestion workload to pre-populate a database and `[path/to/benchmark_workload]` means the path of benchmark. If you generate the workload using our commands in the first step, we will have an insert-only workload `workload.txt` and a query workload `query_workload.txt` under `K-V-Workload-Generator` directory. We can then replace the path as follows:

    ```
    ./query_lat_exp -E 512 --dd --iwp ../K-V-Workload-Generator/workload.txt --qwp ../K-V-Workload-Generator/query_workload.txt --dw --dr
    ```

    In the above example, `dr`, `dw` represent *direct read* and *direct write* respectively, and `dd` specifies *destroying the database* if there already exists one before running the experiment. By default, it builds `db_working_home` under the current directory and uses it as the database path. We also provide more parameters that users can explore in these benchmark executables. More details can be found by `./query_lat_exp --help`.

---

## Reproducing Paper Results

We integrate all experimental scripts into one `one-for-all.sh` for easier reproducing. But you need to specify `FAST_DB_HOME`, `SLOW_DB_HOME`, and `RAM_DB_HOME` in your environment variable before you run them (ensure that there is no `/` at the end of any `DB_HOME` path). See example as follows:

```
mkdir -p /scratchFastSSD/${USER}/db_working_home
export FAST_DB_HOME=/scratchFastSSD/${USER}/db_working_home
mkdir -p /scratchSlowSSD/${USER}/db_working_home
export SLOW_DB_HOME=/scratchSlowSSD/${USER}/db_working_home
mkdir -p /mnt/ramdisk/${USER}/db_working_home
export RAM_DB_HOME=/mnt/ramdisk/${USER}/db_working_home
./one-for-all.sh
```

We also provide a Dockerfile for you to run the experiments. 
```
docker build . -t mnemosyne
docker run --ulimit nofile=65536:65536 \
	-v ${FAST_DB_HOME}:/fast_db_home \
	-v ${SLOW_DB_HOME}:/slow_db_home \
	-v ${RAM_DB_HOME}:/ram_db_home \
	-e FAST_DB_HOME=/fast_db_home \
	-e SLOW_DB_HOME=/slow_db_home \
	-e RAM_DB_HOME=/ram_db_home mnemosyne
```

You are also allowed to run specific experiments that run FAST_DB_HOME, SLOW_DB_HOME, or RAM_DB_HOME through `./one-for-all.sh fast`, `./one-for-all.sh slow`, or `./one-for-all.sh ram`.

The figures will be plotted under `exp-figures` directory.
Running all the experiments with 3 runs would take around 10 days using our device. If you are using slower SSDs, the total execution
time could be even longer.
Alternatively, you can run the scripts for each figure individually. This is useful for targeted reproduction, or debugging.
The scripts for all the experiment are designed to be be executed under `exp-scripts` directory.
Make sure that you are in `exp-scripts/` directory before you run them. 
You can also specify the number of repeated runs for each experiment separately to reduce the overall experiment execution time.
For example, as YCSB scalability experiment takes the longest time, you may adjust the number of runs
of YCSB experiments to 1 and keep 3 runs for other experiments.

Below are the details for each script.

1. `fig3.sh`: Generates workload distributions and CDF of accessed files. You can use the configured RAM disk to execute this experiment:
    ```
    RAM_DB_HOME=/mnt/ramdisk/${USER}/db_working_home ./fig3.sh
    ```
    This experiment does not repeat for three times but the pattern for workload distribution would remain roughly the same.

2. `fig4.sh`: Measures unnecessarily accessed data blocks under different workloads. This can be also executed using RAM disk as we only measure the unnecessarily data blocks. You ca
    ```
    RAM_DB_HOME=/mnt/ramdisk/${USER}/db_working_home ./fig4.sh
    ```
    In `fig4.sh`, you can specify the number of runs through `RUNS=x` where `x` is the number of runs you want to repeat.

3. `fig5.sh`: Compare the efficiency of different solvers to obtain the best bits-per-key allocation. This experiment needs to collect the number of queries (including both empty and non-empty point queries) per file, and thus you can also use RAM disk.
    ```
    RAM_DB_HOME=/mnt/ramdisk/${USER}/db_working_home ./fig5.sh
    ```
    To repeat experiments in `fig5.sh`, you need to change the variable `runs` in file `skew-aware-bpk-benchmark/main-collect-query-stats-for-optimization-exp.sh` (line 10).

4. `fig10.sh`: Measures the accuracy of statistics estimation methods. This experiment periodically copies the whole database to obtain the ground-truth access statistics for a certain interval. To ensure the persistency of copied database, it is recommended using fast SSD device.
    ```
    FAST_DB_HOME=/scratchFastSSD/${USER}/db_working_home ./fig10.sh
    ```
    You can specify the number of runs by changing variable `R` in file `skew-aware-bpk-benchmark/exp_query_statistics_est_benchmark.sh` (line 8).

5. `fig11.sh`: Meausres the runtime throughput and actual bits-per-key for workload type I (40M inserts, mixed with 40M empty queries and 20M updates). To eliminate the impact from system cache, we turn on *direct read* flag when running the database, which means RAM\_DB\_HOME would not be supported in this experiment.

    ```
    FAST_DB_HOME=/scratchFastSSD/${USER}/db_working_home ./fig11.sh
    ```
    You can specify the number of runs by changing variable `R` in file `skew-aware-bpk-benchmark/tput_exp.sh` (line 7).

6. `fig12.sh`: Meausres the query latency for workload type II (21M inserts followed by 31M mixed queries and 10M updates) on the fast SSD. We turn on *direct read* so RAM\_DB\_HOME is not supported in this experiment.
    ```
    FAST_DB_HOME=/scratchFastSSD/${USER}/db_working_home ./fig12.sh
    ```
    You can directly set the number of runs in `fig12.sh` by specifying the variable `RUNS`, just like `fig4.sh`.

7. `fig13-14.sh`: Measures the query latency and the number of read bytes for workload type II using a slower SSD.
    ```
    SLOW_DB_HOME=/scratchSlowSSD/${USER}/db_working_home ./fig13-14.sh
    ```
    Similar to `fig12.sh` and `fig4.sh`, you can customize the number of runs to repeat by changing variable `RUNS` in `fig13-14.sh`.

8. `fig15-16.sh`: Measures the throughput in YCSB with different workloads and different scales.
    ```
    FAST_DB_HOME=/scratchFastSSD/${USER}/db_working_home ./fig15-16.sh
    ```
    For YCSB experiments, you need to change the number of runs separately for Figures 15 and 16 if you want to customize the number of runs.
    For Figure 15, you need to change the variable `runs` in `YCSB-cpp/run_ycsb_basic.sh` (line 92), while for the scalability experiment, you need to the variable `runs` in `YCSB-cpp/run_ycsb_basic.sh` (line 76).
