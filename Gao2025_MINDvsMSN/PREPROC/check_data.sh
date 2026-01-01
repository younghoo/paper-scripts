#! /bin/bash
step=2
## Check whether recon-all is finished
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist.txt
    for curr_sub in $(cat $sublist)
    do
      INDIR=${sour_dir}/${curr_sub}/t1_proc
      if [[ ! -f ${INDIR}/stats/t1_Aseg_volume.sum ]] && [[ -d ${INDIR} ]]
      then
          echo $curr_sub
      else
          echo ${curr_sub} >> ${targ_dir}/sublist_init.txt
      fi
    done
fi
## Check the failed subjects in calculating LGI
## The reason of failure is unknown
if [[ $step -eq 2 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    for curr_sub in $(cat $sublist)
    do
      INDIR=${sour_dir}/${curr_sub}/t1_proc/freesurfer/surf
      if [[ ! -f ${INDIR}/lh.pial_lgi ]] || [[ ! -f ${INDIR}/rh.pial_lgi ]]
      then
          echo $curr_sub >> ${targ_dir}/failed_lgi_sublist.txt
          cat ${sour_dir}/${curr_sub}/t1_proc/freesurfer/scripts/recon-all.log | grep "ERROR: compute_lgi did not create output file"
      fi
    done
fi


