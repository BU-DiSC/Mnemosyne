#!/bin/bash
I="21000000"
Q="31000000"
U="10000000"
E="512"
L="0.25"
Z_LIST=("0.0" "0.5" "1.0")
ZD_LIST=("0" "1")
ZD_NDEV="5.0"
../K-V-Workload-Generator/load_gen -I${I} -E${E} -L ${L}
for Z in ${Z_LIST[@]}
do
	for ZD in ${ZD_LIST[@]}
	do
		../K-V-Workload-Generator/load_gen -L${L} -U ${U} -E${E} -Q${Q} -Z ${Z} --ZD ${ZD} --ED ${ZD} --ZD_NDEV ${ZD_NDEV} --ED_NDEV ${ZD_NDEV} --PL --OP Z${Z}_ZD${ZD}_mixed_update_query_workload.txt 
	done
done
mv workload.txt ingestion_workload.txt
