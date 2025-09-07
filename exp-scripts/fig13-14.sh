#!/bin/bash

# Exit immediately if any command fails.
set -e
ulimit -n 65535

RUNS=1

echo "🚀 Starting script for Figures 13 and 14..."

echo "[Fig 13&14] ⏳ Preparing workloads..."

cd ../workload_generator_scripts/
./workload_type_II.sh
cd -
 
cd ../skew-aware-bpk-benchmark
echo "[Fig 13&14] ⏳ Compiling the executable query_lat_exp"
make query_lat_exp
echo "[Fig 13] ⏳ Measuring query latency in mixed workloads using a slower SSD..."
./main_query_lat_slower_device.sh ${RUNS}
echo "[Fig 13] ✅ Experiments complete"
echo "[Fig 14] ⏳ Measuring query latency with Ribbon Filter in mixed workloads using a slower SSD..."
./main_query_lat_ribbon_filter_slower_device.sh ${RUNS}
echo "[Fig 14] ✅ Experiments complete"
cd -

cd ../plot_scripts/
echo "[Fig 13] ⏳ Plotting query latency for workloads with different distribution..."
python3 query-stats-est-benchmark.py  --showLegend --name="../exp-figures/Fig10-a.pdf"
echo "[Fig 13] ✅ Plotting complete."
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_slower_device/query_latency_Z1.0_ZD0.txt --name=../exp-figures/Fig13-a.pdf --metric=read_latency --ymax=180 --showLegend --width=8
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_slower_device/query_latency_Z1.0_ZD1.txt --name=../exp-figures/Fig13-b.pdf --metric=read_latency --ymax=180 --width=8
echo "[Fig 14] ⏳ Plotting query latency and read bytes for uniform queries"
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_ribbon_filter/query_latency_Z1.0_ZD0.txt --name=../exp-figures/Fig14-a.pdf --metric=read_latency --width=8
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_ribbon_filter/read_bytes_Z1.0_ZD0.txt --name=../exp-figures/Fig14-b.pdf --metric=read_bytes --width=8
echo "[Fig 14] ✅ Plotting complete."
cd -

echo "🎉 All tasks for Figures 13 and 14 are finished!"
