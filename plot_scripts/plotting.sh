#!/bin/bash

echo "Plotting the distribution of queries takes substantial time building the histogram (45mins) for 15M queries"
python3 point-query-prefix-distribution.py --name="../exp-figures/Fig3-a.pdf"
echo "Plotting CDF"
python3 access-distribution.py --showLegend --name="../exp-figures/Fig3-b.pdf"

echo "Plotting unnecessarily accessed data blocks with different empty lookup ratio"
python3 opt-vs-monkey-vs-rocksdb-overall-microbenchmark_by_more_Z.py --name="../exp-figures/Fig4.png"


echo "Plotting euclidean distance and cosine similarity for different statistics estimation methods"
python3 query-stats-est-benchmark.py  --showLegend --name="../exp-figures/Fig10-a.pdf"
python3 query-stats-est-benchmark.py --path="../skew-aware-bpk-benchmark/query_statistics_est_benchmark_result/bottom_up_Z0.5_ZD1_num_empty_point_reads_stats_diff.txt" --name="../exp-figures/Fig10-b.pdf"
# see more plotting not shown in paper
#python3 query-stats-est-benchmark.py --path="../skew-aware-bpk-benchmark/query_statistics_est_benchmark_result/bottom_up_Z0.0_ZD1_num_empty_point_reads_stats_diff.txt" --name="../exp-figures/bottom_up_Z0.0_ZD1_stats_diff.pdf"
#python3 query-stats-est-benchmark.py --path="../skew-aware-bpk-benchmark/query_statistics_est_benchmark_result/bottom_up_Z1.0_ZD1_num_empty_point_reads_stats_diff.txt" --name="../exp-figures/bottom_up_Z1.0_ZD1_stats_diff.pdf"
#python3 query-stats-est-benchmark.py --path="../skew-aware-bpk-benchmark/query_statistics_est_benchmark_result/bottom_up_Z0.0_ZD0_num_empty_point_reads_stats_diff.txt" --name="../exp-figures/bottom_up_Z0.0_ZD0_stats_diff.pdf"
#python3 query-stats-est-benchmark.py --path="../skew-aware-bpk-benchmark/query_statistics_est_benchmark_result/bottom_up_Z1.0_ZD0_num_empty_point_reads_stats_diff.txt" --name="../exp-figures/bottom_up_Z1.0_ZD0_stats_diff.pdf"

echo "Plotting throughputs-and-average-bpk for different bpk allocation methods"
python3 static-monkey-vs-rocksdb-throughput-exp.py --name="../exp-figures/Fig11-c.pdf"
python3 static-monkey-vs-rocksdb-throughput-exp.py --tput_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-4.0_throughputs.txt" --bpk_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-4.0_tracked_avg_bpk.txt" --name="../exp-figures/Fig11-b.pdf" 
python3 static-monkey-vs-rocksdb-throughput-exp.py --tput_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-6.0_throughputs.txt" --bpk_path="../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-6.0_tracked_avg_bpk.txt" --name="../exp-figures/Fig11-a.pdf" 

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

echo "Plotting the query latency for Normal and Uniform distribution with slow SSDs"
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_slower_device/query_latency_Z1.0_ZD0.txt --name=../exp-figures/Fig13-a.pdf --metric=read_latency --ymax=180 --showLegend --width=8
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_slower_device/query_latence_Z1.0_ZD1.txt --name=../exp-figures/Fig13-b.pdf --metric=read_latency --ymax=180 --width=8

echo "Plotting the query latency and read bytes for ribbon filter with slow SSDs"
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_ribbon_filter/query_latency_Z1.0_ZD0.txt --name=../exp-figures/Fig14-a.pdf --metric=read_latency --width=8
python3 mnemosyneplus-main-exp-plot.py --path=../skew-aware-bpk-benchmark/agg_output_ribbon_filter/read_bytes_Z1.0_ZD0.txt --name=../exp-figures/Fig14-b.pdf --metric=read_bytes --width=8


echo "Plotting YCSB"
python3 ycsb-plot.py --path=../YCSB-cpp/exp-th1_dynamic_cmpact/ycsb_agg_exp.txt --name=../exp-figures/Fig15-a.pdf
python3 ycsb-plot.py --path=../YCSB-cpp/exp-th4_dynamic_cmpact/ycsb_agg_exp.txt --name=../exp-figures/Fig15-b.pdf --showLegend

python3 scalability-ycsb-plot.py --path=../YCSB-cpp/exp-th16_dynamic_cmpact/ycsb_scalability_workloadb_dynamic_exp.txt --name=../exp-figures/Fig16-a.pdf
python3 scalability-ycsb-plot.py --path=../YCSB-cpp/exp-th16_no_dynamic_cmpact/ycsb_scalability_workloadb_no_dynamic_exp.txt --name=../exp-figures/Fig16-b.pdf

