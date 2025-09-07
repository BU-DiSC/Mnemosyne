#!/bin/bash
I="20000000"
U="20000000"
Q="40000000"

Z_List=("0.0" "0.5" "1.0")
ZD_List=("0" "1")
E="128"
L="0.25"
../K-V-Workload-Generator/load_gen -I ${I} -E${E} -L ${L}
for Z in ${Z_List[@]}
do
	for ZD in ${ZD_List[@]}
	do
		../K-V-Workload-Generator/load_gen --ZD ${ZD} -L ${L} -U ${U} -E${E} -I${I} -Q${Q} -Z ${Z} --ED ${ZD}  --PL --OP mixed_query_workload.txt 
		cat mixed_query_workload.txt >> Z${Z}_ZD${ZD}_ED${ZD}_workload_type_I.txt
		rm mixed_query_workload.txt
	done
done


