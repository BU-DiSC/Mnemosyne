#!/bin/bash

# Exit immediately if any command fails.
set -e
ulimit -n 65535

echo "🚀 Starting script for Figures 15 and 16..."

cd ../YCSB-cpp
./run_ycsb_main.sh
cd -

cd ../plot_scripts/
echo "[Fig 15] ⏳ Plotting throughput for different YCSB workloads..."
python3 ycsb-plot.py --path=../YCSB-cpp/exp-th1_dynamic_cmpact/ycsb_agg_exp.txt --name=../exp-figures/Fig15-a.pdf
python3 ycsb-plot.py --path=../YCSB-cpp/exp-th4_dynamic_cmpact/ycsb_agg_exp.txt --name=../exp-figures/Fig15-b.pdf --showLegend
echo "[Fig 15] ✅ Plotting complete."
echo "[Fig 16] ⏳ Plotting throughput for different scales with YCSB workload type B..."
python3 scalability-ycsb-plot.py --path=../YCSB-cpp/exp-th16_dynamic_cmpact/ycsb_scalability_workloadb_dynamic_exp.txt --name=../exp-figures/Fig16-a.pdf
python3 scalability-ycsb-plot.py --path=../YCSB-cpp/exp-th16_no_dynamic_cmpact/ycsb_scalability_workloadb_no_dynamic_exp.txt --name=../exp-figures/Fig16-b.pdf
echo "[Fig 16] ✅ Plotting complete."
cd -


echo "🎉 All tasks for Figures 15 and 16 are finished!"
