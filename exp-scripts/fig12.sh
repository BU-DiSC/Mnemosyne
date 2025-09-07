#!/bin/bash

# Exit immediately if any command fails.
set -e
ulimit -n 65535

RUNS=1

echo "🚀 Starting script for Figure 12..."
 
cd ../skew-aware-bpk-benchmark
echo "[Fig 12] ⏳ Compiling the executable query_lat_exp"
make query_lat_exp
echo "[Fig 12] ⏳ Executing workloads and measuring the query latency with different bits-per-key..."
./main_query_lat.sh ${RUNS}
echo "[Fig 12] ✅ Experiments complete"

cd ../plot_scripts/
echo "[Fig 12] ⏳ Plotting query latency.."

echo "Plotting the query latency and read bytes with fast SSDs"
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/query_latency_Z0.0_ZD0.txt --name=../exp-figures/Fig12-g.pdf --metric=read_latency --showLegend --ymax=60
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/query_latency_Z0.5_ZD0.txt --name=../exp-figures/Fig12-h.pdf --metric=read_latency --ymax=60
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/query_latency_Z1.0_ZD0.txt --name=../exp-figures/Fig12-i.pdf --metric=read_latency --ymax=60

python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/query_latency_Z0.0_ZD1.txt --name=../exp-figures/Fig12-j.pdf --metric=read_latency
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/query_latency_Z0.5_ZD1.txt --name=../exp-figures/Fig12-k.pdf --metric=read_latency
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/query_latency_Z1.0_ZD1.txt --name=../exp-figures/Fig12-l.pdf --metric=read_latency

python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/read_bytes_Z0.0_ZD0.txt --name=../exp-figures/Fig12-a.pdf --metric=read_bytes --showLegend
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/read_bytes_Z0.5_ZD0.txt --name=../exp-figures/Fig12-b.pdf --metric=read_bytes
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/read_bytes_Z1.0_ZD0.txt --name=../exp-figures/Fig12-c.pdf --metric=read_bytes

python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/read_bytes_Z0.0_ZD1.txt --name=../exp-figures/Fig12-d.pdf --metric=read_bytes
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/read_bytes_Z0.5_ZD1.txt --name=../exp-figures/Fig12-e.pdf --metric=read_bytes
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output/read_bytes_Z1.0_ZD1.txt --name=../exp-figures/Fig12-f.pdf --metric=read_bytes

echo "[Fig 12] ✅ Plotting completes."
cd -

echo "🎉 All tasks for Figure 12 are finished!"
