#!/bin/bash
I="4000000"
Q="15000000"
L="0.25"
E="512"
Z_LIST=("1.0" "0.75" "0.5" "0.25" "0.1" "0.05" "0.01" "0.0")
ZD_LIST=("0" "1")
NDEV="5.0"
../K-V-Workload-Generator/load_gen -I${I} -E${E} -L${L}
for Z in ${Z_LIST[@]}
do
	for ZD in ${ZD_LIST[@]}
	do
		../K-V-Workload-Generator/load_gen -L${L} -E${E} -Q${Q} -Z ${Z} --ZD ${ZD} --ED ${ZD} --ZD_NDEV ${NDEV} --ED_NDEV ${NDEV} --PL --OP Z${Z}_ZD${ZD}_query_workload.txt 
	done
done
mv workload.txt ingestion_workload.txt
