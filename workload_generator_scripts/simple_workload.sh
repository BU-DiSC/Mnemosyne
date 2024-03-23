#!/bin/bash
I="21000000"
U="10000000"
Q="31000000"
#I="2000000"
#U="1000000"
#Q="2000000"
Z="0.5"
E="512"
L="0.25"
Z_LIST=("0.0" "0.5" "1.0")
ZD_LIST=("0" "3")
#ZALPHA_LIST=("0.7" "1.0" "1.3")
ZALPHA_LIST=()
../K-V-Workload-Generator/load_gen -I ${I} -E${E} -L ${L}
for Z in ${Z_LIST[@]}
do
	for ZD in ${ZD_LIST[@]}
	do
		../K-V-Workload-Generator/load_gen -L ${L} -U ${U} -E${E} -Q${Q} -Z ${Z} --ZD ${ZD} --ED ${ZD} --PL --OP Z${Z}_ZD${ZD}_simple_mixed_query_workload.txt 
		cp workload.txt Z${Z}_ZD${ZD}_simple_mixed_query_workload-temp.txt
		cat Z${Z}_ZD${ZD}_simple_mixed_query_workload.txt >> Z${Z}_ZD${ZD}_simple_mixed_query_workload-temp.txt
		mv Z${Z}_ZD${ZD}_simple_mixed_query_workload-temp.txt  Z${Z}_ZD${ZD}_simple_mixed_query_workload.txt
	done
<<COMMENT
	for ALPHA in ${ZALPHA_LIST[@]}
	do
		../K-V-Workload-Generator/load_gen -E${E} -Q${Q} -Z ${Z} --ZD 3 --ED 3 --ED_ZALPHA ${ALPHA} --ZD_ZALPHA ${ALPHA} --PL --OP Z${Z}_ZD3_ZALPHA${ALPHA}_query_workload.txt 
	done
COMMENT
done
#head -${I} workload.txt > ingestion_workload.txt
#tail -${Q} workload.txt > query_workload.txt
