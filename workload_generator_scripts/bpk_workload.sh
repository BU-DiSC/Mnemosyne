#!/bin/bash
I="2000000"
Q="4000000"
Z="0.5"
E="512"
Z_LIST=("0.0" "0.5" "1.0")
ZD_LIST=("0" "3")
#ZALPHA_LIST=("0.7" "1.0" "1.3")
ZALPHA_LIST=()
../K-V-Workload-Generator/load_gen -I${I} -E${E}
for Z in ${Z_LIST[@]}
do
	for ZD in ${ZD_LIST[@]}
	do
		../K-V-Workload-Generator/load_gen -E${E} -Q${Q} -Z ${Z} --ZD ${ZD} --ED ${ZD} --PL --OP Z${Z}_ZD${ZD}_query_workload.txt 
	done
	for ALPHA in ${ZALPHA_LIST[@]}
	do
		../K-V-Workload-Generator/load_gen -E${E} -Q${Q} -Z ${Z} --ZD 3 --ED 3 --ED_ZALPHA ${ALPHA} --ZD_ZALPHA ${ALPHA} --PL --OP Z${Z}_ZD3_ZALPHA${ALPHA}_query_workload.txt 
	done
done
mv workload.txt ingestion_workload.txt
#head -${I} workload.txt > ingestion_workload.txt
#tail -${Q} workload.txt > query_workload.txt
