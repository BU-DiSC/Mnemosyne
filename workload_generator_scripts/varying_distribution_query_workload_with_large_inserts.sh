#!/bin/bash

I=$1
E="128"
L="0.5"
Q="8000000"

TMP_FILE=$(mktemp temp-file.XXXXXX)
if [ -f "workload.txt" ]; then
	mv workload.txt ${TMP_FILE}
fi

../K-V-Workload-Generator/load_gen -I${I} -E${E} -L ${L} 

../K-V-Workload-Generator/load_gen -Q${Q} -E${E} -L${L} -Z 0.0 --ZD 1 --ZD_NDEV 5.0 --ED_NDEV 5.0 --OP ZD1_Z0.0_for_opt_bpk_solver_query_workload.txt --PL

../K-V-Workload-Generator/load_gen -L${L} -Q${Q} -E${E} -Z 0.0 --ZD 0 --OP ZD0_Z0.0_for_opt_bpk_solver_query_workload.txt --PL

mv workload.txt ingestion_for_opt_bpk_solver_workload.txt

if [ -f ${TMP_FILE} ]; then
	mv ${TMP_FILE} workload.txt
fi
