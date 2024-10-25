#!/bin/bash
I="4000000"
Q="6000000"
U="4000000"
E="512"

../K-V-Workload-Generator/load_gen -I${I} -E${E} -L 0.25
../K-V-Workload-Generator/load_gen -E${E} -L 0.25 -U${U} -Q${Q} -Z 0 --PL --OP query_workload0.txt
../K-V-Workload-Generator/load_gen -E${E} -L 0.25 -U${U} -Q${Q} -Z 0.5 --PL --OP query_workload1.txt
../K-V-Workload-Generator/load_gen -E${E} -L 0.25 -U${U} -Q${Q} -Z 1.0 --PL --OP query_workload2.txt
cat query_workload0.txt query_workload1.txt query_workload2.txt > context_switch_queries_Z.txt
mv workload.txt ingestion_workload_for_shifting_Z.txt
rm query_workload0.txt
rm query_workload1.txt
rm query_workload2.txt
