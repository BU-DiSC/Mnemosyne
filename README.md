

<H1> The codebase for "Mnemosyne: Dynamic Workload-Aware BF Tuning via Accurate Statistics in LSM trees" </H1>

This repository contains four submodules: skew-aware-RocksDB (modified based on v8.9.1), benchmark code, our workload generator, YCSB-cpp, and a standalone efficiency benchmark code when solving the optimal false positive rate given the access statistics.

<H1> Workload Generation </H1>

To generate a key-value workload, you need to go into directory `K-V-Workload-Generator` and simply give 

```
make
./load_gen -I10000
```

with the desired parameters. These include: Number of inserts, updates, deletes, point & range lookups, distribution styles, etc. 
In the above example, it will generate a workload file (e.g., `workload.txt`) with 10000 inserts (for pre-populating a database).

We can further use preloading feature to generate another workload to benchmark. For example, we can run

```
./load_gen --PL -Q3000 --OP query_workload.txt
```
This will generate a text file `query_workload.txt` that contains 3000 point queries on existing keys by preloading `workload.txt` generated earlier.

To vary the distribution of point queries, you can specify `--ED [ED] --ZD [ZD]`, where `[ED]` and `[ZD]` represent the distribution number for existing and non-existing point queries, respectively (distribution number: 0->uniform, 1->normal, 2->beta, 3->zipf)

More details can be found by running `./load_gen --help`.

<H1> Compiling RocksDB </H1>

After that, make sure that you are able to skew-aware-rocksdb-8.9.1. To do that under `skew-aware-rocksdb-8.9.1` directory and run:
```
make static_lib
```
You can speedup this process using more threads `-j[X]` where `[X]` can be replaced by the number of threads you may use. If you cannot compile the static library successfully due to lack of package, please check [here](https://github.com/facebook/rocksdb/blob/main/INSTALL.md) for more info. 

<H1> Running Experiments </H1>

To run the workload, you need to go to `skew-aware-bpk-benchmark` directory and compile the executables:

```
make
```
which produces a set of executables including `bpk_benchmark`,`plain_benchmark`,`query_statistics_est_benchmark`,`simple_benchmark`, and `simple_benchmark_2`. Among these executables, `bpk_benchmark` is used to run experiments Figure 4 in our paper, `query_statistics_est_benchmark` is used to run experiments in Figure 10, `simple_benchmark_2` is for throughput experiment in Figure 11, and all other experiments (except Figures 4 and 5) are executed using `plain_benchmark`. Before run any experiments, remember to run `ulimit -n 65536` to ensure that maximum open files are set, otherwise experiments can be interrupted and stop due to insufficient maximum open files. To produce Figure 5, you can execute `exp-collect-query-stats.sh` under the `skew-aware-bpk-benchmark` which still uses `plain_benchmark` but only collects the access statistics, and copy the statistics results to `distributs_lsm_bfsize` folder to run the efficiency experiment.

These executables have a large set of common parameters and presume that workloads are already generated using our workload generator. Take `plain_benchmark` as an example:

```
./plain_benchmark -E [E] --dd --iwp [path/to/ingestion_workload] --qwp [path/to/benchmark_workload] --dw --dr
```
where `[E]` is the entry size generated from our workload generator, `[path/to/ingestion_workload]` means the path of the ingestion workload to pre-populate a database and `[path/to/benchmark_workload]` means the path of benchmark.

If you generate the workload without specifying the entry size (by default, the entry size is 8 in the workload generator), we can replace the path as follows:

```
./plain_benchmark -E 8 --dd --iwp ../K-V-Workload-Generator/workload.txt --qwp ../K-V-Workload-Generator/query_workload.txt --dw --dr
```
This will create a database in the current directory using path `./db_working_home`, populate the database using the ingestion workload, and then benchmark RocksDB using the query workload (`dw` and `dr` respectively represent direct write and direct read). The experiment results (e.g., latency or throughput) are printed when the benchmark finishes. You can also specify `--path=[/path/to/database]` to change the database path, you mostly need to change this path to the specific SSD device if you have a dedicated one.  More options are available. Type:

```
./plain_benchmark --help 
```

for more details.

We summarize our experiment terminal commands into several scripts file. For example, to run experiment Figure 4, you can run `.\exp_bpk.sh` if you have `bpk_benchmark` executable available (remember to modify the `DB_HOME` path in the script to utilize your dedicated storage device). To run this experiment multiple times and obtain the average, you can run `.\main_bpk.sh [runs]` where [runs] is the number of times you want to run `exp_bpk.sh` and the averaged result will be stored under directory `agg_output_by_bpk/` (thie folder will be created if not existing). Similarly, you can use `.\main_plain.sh` to run `exp_plain.sh` multiple times and obtain the average.


To produce Figure 4, you can run `main.sh` to collect the access statistics. To save your time, we summarize the access statistics in a zipped file `file-access-exp-data.zip` under `distribute_lsm_bfsize`. You can then go into this directory and run the experiments (uncompress the zipped file and run `.\test.sh`)

For Figure 10, you can run `.\exp_query_statistics_est_benchmark.sh` (since we are only comparing the statistics, you can create a RAM disk and specify `DB_HOME` as the mounted path for your RAM disk). We do not offer extra script to run this experiment multiple times and get the average since you can achieve this by specifying `-R [X]` when executing `query_statistics_est_benchmark` (you can change `R` in the file `exp_query_statistics_est_benchmark.sh`).

For Figure 12, run `main_plain.sh [X]` where `[X]` is the number of times you want to run `exp_plain.sh`, and the experimental result (average one) will be summarzied under a folder `agg_output/` in the current directory. Figure 13 is plotted by re-using the experimental results from Figure 12. Similarly, for Figure 13, you just need to change the `DB_HOME` in `exp_plain.sh` to a slower storage device.

<!--Experiments for Figure 14 and 15 are executed by `exp_throughput_simple.sh` and `scalability.sh`, respectively. You can specify `R` in `exp_throughput_simple.sh` to run it multiple times and get the average result for the throughput experiment. For the scalability experiment, you can use `.\main_scalability.sh` to run the scalability experiment multiple times and obtain the average under directory `agg_scalability`.

The experimental results in Figure 16 are obtained using YCSB-cpp repository. go into this directory and follow the instruction to compile an executable `ycsb` (which requires you already compile `skew-aware-rocksdb-8.9.1`) and run `.\test.sh`. You can also change many parameters in `test.sh`. For example, you can specify the number of times you run the experiment by changing `runs` and you can also specify the database path using a dedicated storage device (by changing `DB_HOME`)-->

