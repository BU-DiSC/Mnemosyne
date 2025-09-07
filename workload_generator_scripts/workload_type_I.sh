#!/bin/bash
I="20000000"
U="20000000"
Q="40000000"

Z="1.0"
E="128"
L="0.25"
../K-V-Workload-Generator/load_gen -I ${I} -E${E} -L ${L}
../K-V-Workload-Generator/load_gen -L ${L} -U ${U} -E${E} -I${I} -Q${Q} -Z ${Z}  --PL --OP mixed_query_workload.txt 

cat mixed_query_workload.txt >> workload_type_I.txt
rm mixed_query_workload.txt

