#!/bin/bash

I="4000000" 
E="512"
L="0.25"
Q="15000000"

../K-V-Workload-Generator/load_gen -I${I} -E${E} -L ${L} 

NDEV_LIST=("3.0" "4.0" "5.0")
for NDEV in ${NDEV_LIST[@]}
do
	../K-V-Workload-Generator/load_gen -Q${Q} -E${E} -L${L} -Z 1.0 --ZD 1 --ZD_NDEV ${NDEV} --OP Normal_Dis_NDEV${NDEV}_empty_query_workload.txt --PL
done


../K-V-Workload-Generator/load_gen -L${L} -Q${Q} -E${E} -Z 1.0 --ZD 0 --OP Uniform_Dis_empty_query_workload.txt --PL

mv workload.txt ingestion_workload.txt
