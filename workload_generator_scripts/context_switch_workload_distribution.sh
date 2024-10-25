#!/bin/bash
I="6000000"
Q="6000000"
U="4000000"
Z="0.5"
E="512"
L="0.25"

mv workload.txt old_workload.txt
../K-V-Workload-Generator/load_gen -I${I} -E${E} -L ${L}
../K-V-Workload-Generator/load_gen -L ${L} -E${E} -U${U} -Q${Q} -Z ${Z} --PL --ED=0 --ZD=0 --OP query_workload0.txt
../K-V-Workload-Generator/load_gen -L ${L} -E${E} -U${U} -Q${Q} -Z ${Z} --PL --ED=1 --ZD=1 --ZD_NDEV 5.0 --ED_NDEV 5.0 --OP query_workload1.txt
../K-V-Workload-Generator/load_gen -L ${L} -E${E} -U${U} -Q${Q} -Z ${Z} --PL --ED=1 --ZD=1 --ZD_NDEV 3.0 --ED_NDEV 3.0 --OP query_workload2.txt
../K-V-Workload-Generator/load_gen -L ${L} -E${E} -U${U} -Q${Q} -Z ${Z} --PL --ED=0 --ZD=0 --OP query_workload3.txt
cat query_workload0.txt query_workload1.txt query_workload2.txt query_workload3.txt > context_switch_queries_distribution.txt
	

mv workload.txt ingestion_workload_for_shifting_distribution.txt
rm query_workload0.txt
rm query_workload1.txt
rm query_workload2.txt
rm query_workload3.txt
mv old_workload.txt workload.txt
