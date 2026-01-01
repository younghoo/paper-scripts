#! /bin/bash
step=1
## Extract TIV data
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/STATS/T1/TIV
    mkdir -p ${targ_dir}
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    for sub in $(cat $sublist)
    do
      INDIR=${sour_dir}/${sub}/t1_proc
      if [[ -f ${INDIR}/stats/t1_Aseg_volume.sum ]]
      then
          TIV=$(cat ${INDIR}/stats/t1_Aseg_volume.sum | sed -n 2p | awk '{print $15}')
          echo $sub $TIV >> ${targ_dir}/TIV.txt
      fi
    done
fi


