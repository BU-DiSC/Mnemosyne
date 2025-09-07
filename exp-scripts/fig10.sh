#!/bin/bash

# Exit immediately if any command fails.
set -e
ulimit -n 65535

echo "🚀 Starting script for Figure 10..."

echo "[Fig 10] ⏳ Preparing workloads..."

cd ../workload_generator_scripts/
./workload_type_II.sh
cd -
 
cd ../skew-aware-bpk-benchmark
echo "[Fig 10] ⏳ Compiling the executable query_statistic_est_benchmark"
make query_statistics_est_benchmark
echo "[Fig 10] ⏳ Populating databases with queries to measure the accuracy of different access estimation methods..."
./exp_query_statistics_est_benchmark.sh
echo "[Fig 10] ✅ Experiments complete"

cd ../plot_scripts/
echo "[Fig 10] ⏳ Plotting euclidean distance and cosine similarity for different statistics estimation methods..."
python3 query-stats-est-benchmark.py  --showLegend --name="../exp-figures/Fig10-a.pdf"
python3 query-stats-est-benchmark.py --path="../skew-aware-bpk-benchmark/query_statistics_est_benchmark_result/bottom_up_Z0.5_ZD1_num_empty_point_reads_stats_diff.txt" --name="../exp-figures/Fig10-b.pdf"
cd -
echo "[Fig 10] ✅ Plotting complete."

echo "🎉 All tasks for Figure 10 are finished!"
