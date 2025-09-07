#!/bin/bash

# Exit immediately if any command fails.
set -e
ulimit -n 65535

RUNS=1

echo "🚀 Starting script for Figure 4..."
echo "💡 INFO: For faster execution, this experiment is suggested to perform with DB_HOME set to a RAM disk."

# --- (1/2) Run the Benchmark ---
echo ""
echo "--- (1/2) Measuring unnecessarily accessed data blocks... ---"

cd ../skew-aware-bpk-benchmark
echo "[Fig 4] ⏳ Measuring unnecessarily accessed data blocks with varying the empty point query proportion (Z)..."
./main_Z.sh ${RUNS}
echo "[Fig 4] ✅ Experiments complete."


# --- (2/2) Plot the Results ---
echo ""
echo "--- (2/2) Plotting results... ---"

echo "[Fig 4] Plotting unnecessarily accessed data blocks with different bpk allocation..."
cd ../plot_scripts
python3 opt-vs-monkey-vs-rocksdb-overall-microbenchmark_by_more_Z.py --name="../exp-figures/Fig4.png"

echo "[Fig 4] ✅ Plotting completes."

echo "🎉 All tasks for Figure 4 are finished!"
