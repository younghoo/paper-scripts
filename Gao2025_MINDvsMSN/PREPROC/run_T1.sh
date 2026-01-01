#! /bin/bash
step=1
## Run T1
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist.txt
    for sub in $(cat $sublist)
    do
      T1IMAGE=${sour_dir}/${sub}/t1.nii.gz
      if [[ -f ${T1IMAGE} ]]
      then
          qsub -cwd -V -q all.q -S /bin/bash ${PhiPipe}/t1_process.sh -a ${T1IMAGE} -b ${sour_dir}/${sub}/t1_proc -c t1 -f 1
      fi
    done
fi


