#! /bin/bash
step=1
if [[ $step -eq 1 ]]
then
    script_dir=/home/huyang/Projects/HuYang/HY_20250708/SCRIPTS/T1/MIND
    sublist=/home/huyang/Projects/HuYang/HY_20250708/PROCDATA/LIST/t1_sublist.txt
    parallel --jobs 8 --joblog ${script_dir}/zlog_parallel.txt python ${script_dir}/calc_MIND.py {1} ::: $(cat $sublist)
fi


