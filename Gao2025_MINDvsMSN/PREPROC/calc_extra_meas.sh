#! /bin/bash
step=2
## Calculate the ROI-based sulc measure
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    for sub in $(cat $sublist)
    do
      export SUBJECTS_DIR=${sour_dir}/${sub}/t1_proc
      SUBJECT=freesurfer
      for curr_parc in Schaefer.300Parcels.7Networks 500.aparc
      do
        for hemi in lh rh
        do
          mris_anatomical_stats -mgz -cortex ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.cortex.label -f ${SUBJECTS_DIR}/${SUBJECT}/stats/${hemi}.${curr_parc}_sulc.stats -b -a ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.${curr_parc}.annot -t sulc ${SUBJECT} ${hemi} white
        done
      done
    done
fi
## Calculate the ROI-based LGI measure
if [[ $step -eq 2 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    script_dir=/Data/sharehome/huyang/HuYang/HY_20250709/SCRIPTS
    for sub in $(cat $sublist)
    do
      qsub -cwd -V -q all.q -S /bin/bash ${script_dir}/calc_LGI.sh ${sour_dir}/${sub}/t1_proc
    done
fi


