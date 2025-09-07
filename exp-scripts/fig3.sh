#!/bin/bash

# Exit immediately if any command fails.
set -e

echo "🚀 Starting script for Figure 3..."

echo "[Fig 3] ⏳ Preparing workloads ..."
# Go into workload_generator_scripts to run the script in its correct directory
cd ../workload_generator_scripts/
./varying_distribution_query_workload.sh
cd -
	

# --- Figure 3(a): Plot Workload Distribution ---
{
    cd ../plot_scripts
    echo "[Fig 3a] ⏳ Plotting the query distribution (this may take over an hour)..."
    python3 point-query-prefix-distribution.py --name="../exp-figures/Fig3-a.pdf" 
    cd -
    echo "[Fig 3a] ✅ Plotting completes."
} 

# --- Figure 3(b): Collect and Plot Access Statistics ---
{
    cd ../skew-aware-bpk-benchmark
    echo "[Fig 3b] ⏳ Executing query workloads to collect access statistics..."
    ./exp-collect-query-stats.sh
    echo "[Fig 3b] ✅ Experiments complete."

    echo "[Fig 3b] Plotting access distribution CDF..."
    cd ../plot_scripts
    python3 access-distribution.py --showLegend --name="../exp-figures/Fig3-b.pdf"

    echo "[Fig 3b] ✅ Plotting completes."
    cd ../exp-scripts
} & # Run in background

echo "🎉 All tasks for Figure 3 are finished!"
