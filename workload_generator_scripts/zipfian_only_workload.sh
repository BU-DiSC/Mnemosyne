#!/bin/bash
scale_base=5000000
scale_factor=$1
I=`echo "${scale_base}*${scale_factor}" | bc | awk '{printf("%d",$1)}'`
U=`echo "${scale_base}*${scale_factor}/2" | bc | awk '{printf("%d",$1)}'`
Q=`echo "${scale_base}*3*${scale_factor}/2" | bc | awk '{printf("%d",$1)}'`
#I="2000000"
#U="1000000"
#Q="2000000"
Z="0.5"
E="512"
L="0.25"
Z_LIST=("0.0" "1.0")
ZD_LIST=("3")
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
