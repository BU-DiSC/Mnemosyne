#!/bin/bash

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---
# This function checks if all required executables exist before starting.
verify_executables() {
	echo "🔎 Verifying required executables..."
	# --- List all required executables here ---
	local required_files=(
	        "K-V-Workload-Generator/load_gen"
		"skew-aware-bpk-benchmark/bpk_benchmark"
		"skew-aware-bpk-benchmark/query_lat_exp"
		"skew-aware-bpk-benchmark/runtime_tput_exp"
		"skew-aware-bpk-benchmark/query_statistics_est_benchmark"
	)

	local all_found=true
	for file in "${required_files[@]}"; do
		if [ ! -x "$file" ]; then
			echo "❌ Error: Required executable not found or not executable at: $file"
			all_found=false
		fi
	done
	if [ "$all_found" = false ]; then
		echo "👉 Please ensure all projects are compiled successfully. Exiting."
		exit 1
	else
		echo "✅ All executables found. Proceeding with experiments."
	fi
}


# This function runs a list of scripts for a given storage type.
# It checks if the corresponding environment variable is set and uses a
# local default if it is not.
run_exp_group() {
    local storage_type=$1
    local env_var_name=$2
    # 'shift 2' removes the first two arguments, so $@ now contains the script list
    shift 2
    local scripts_to_run=("$@")
    local db_home_path

    # Check if the environment variable is set using indirect reference
    if [ -z "${!env_var_name}" ]; then
        db_home_path="./db_working_home_${storage_type}"
        echo "${env_var_name} is not set. Using local default: ${db_home_path}"
    else
        db_home_path="${!env_var_name}"
        echo "Using ${env_var_name} for database path: ${db_home_path}"
    fi

    # Create the target directory
    mkdir -p "${db_home_path}"

    # Run each script in the list
    for script in "${scripts_to_run[@]}"; do
        echo "--- Running ${script} for ${storage_type} storage ---"
        # Temporarily set the correct DB_HOME for the script execution
        DB_HOME="${db_home_path}" ./"${script}"
    done
}

# --- Main Script Logic ---
echo "Starting Mnemosyne experiment runner..."

# Define the lists of scripts for each storage category
FAST_SSD_SCRIPTS=("fig10.sh" "fig11.sh" "fig12.sh" "fig15-16.sh")
SLOW_SSD_SCRIPTS=("fig13-14.sh")
RAM_DISK_SCRIPTS=("fig3.sh" "fig4.sh" "fig5.sh")

echo "Preparing executables..."
cd K-V-Workload-Generator/
make load_gen
cd -

cd skew-aware-bpk-benchmark/
make
cd -

verify_executables

# Move into the scripts directory
cd exp-scripts/

# Check for an optional command-line argument to run a specific group
if [ -n "$1" ]; then
    case "$1" in
        ram)
            run_exp_group "ram" "RAM_DB_HOME" "${RAM_DISK_SCRIPTS[@]}"
            ;;
        fast)
            run_exp_group "fast" "FAST_DB_HOME" "${FAST_SSD_SCRIPTS[@]}"
            ;;
        slow)
            run_exp_group "slow" "SLOW_DB_HOME" "${SLOW_SSD_SCRIPTS[@]}"
            ;;
        *)
            echo "Error: Invalid argument. Use 'fast', 'slow', or 'ram'."
            exit 1
            ;;
    esac
else
    # If no argument is given, run all experiment groups
    echo "Running all experiment groups..."
    run_exp_group "fast" "FAST_DB_HOME" "${FAST_SSD_SCRIPTS[@]}"
    run_exp_group "slow" "SLOW_DB_HOME" "${SLOW_SSD_SCRIPTS[@]}"
    run_exp_group "ram" "RAM_DB_HOME" "${RAM_DISK_SCRIPTS[@]}"
fi

echo "All experiments completed successfully."
cd -
