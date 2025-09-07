#!/bin/bash

# Exit immediately if any command fails.
set -e
ulimit -n 65535

echo "🚀 Starting script for Figure 11..."

echo "[Fig 11] ⏳ Preparing workloads..."

cd ../workload_generator_scripts/
./workload_type_I.sh
cd -
 
cd ../skew-aware-bpk-benchmark
echo "[Fig 11] ⏳ Compiling the executable runtime_tput_exp"
make runtime_tput_exp
echo "[Fig 11] ⏳ Executing workloads and measuring the throughput with different bits-per-key..."
./tput_exp.sh
echo "[Fig 11] ✅ Experiments complete"

cd ../plot_scripts/
echo "[Fig 11] ⏳ Plotting runtime throughput and average bits-per-key..."
python3 static-monkey-vs-rocksdb-throughput-exp.py --name="../exp-figures/Fig11-c.pdf"
python3 static-monkey-vs-rocksdb-throughput-exp.py --tput_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-4.0_throughputs.txt" --bpk_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-4.0_tracked_avg_bpk.txt" --name="../exp-figures/Fig11-b.pdf" 
python3 static-monkey-vs-rocksdb-throughput-exp.py --tput_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-6.0_throughputs.txt" --bpk_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-6.0_tracked_avg_bpk.txt" --name="../exp-figures/Fig11-a.pdf" 
cd -

echo "[Fig 11] ✅ Plotting complete."

echo "🎉 All tasks for Figure 11 are finished!"
