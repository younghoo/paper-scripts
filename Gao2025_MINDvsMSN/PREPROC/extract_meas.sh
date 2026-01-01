#! /bin/bash
step=2
## Extract default ROI-based measures
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/STATS/T1/ROIDATA
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    mkdir -p ${targ_dir}
    for sub in $(cat $sublist)
    do
      echo $sub
      export SUBJECTS_DIR=${sour_dir}/${sub}/t1_proc
      SUBJECT=freesurfer
      for curr_meas in thickness area volume meancurv gauscurv foldind curvind
      do
        for curr_parc in Schaefer.300Parcels.7Networks 500.aparc
        do
          for hemi in lh rh
          do
            aparcstats2table --subjects ${SUBJECT} --hemi ${hemi} --parc ${curr_parc} --meas ${curr_meas} --tablefile ${targ_dir}/${sub}_${curr_parc}_${curr_meas}_${hemi}.txt
          done
        done
      done
    done
fi
## Extract extra ROI-based measures
if [[ $step -eq 2 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/STATS/T1/ROIDATA
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    for sub in $(cat $sublist)
    do
      echo $sub
      export SUBJECTS_DIR=${sour_dir}/${sub}/t1_proc
      SUBJECT=freesurfer
      for curr_meas in lgi sulc
      do
        for curr_parc in Schaefer.300Parcels.7Networks 500.aparc
        do
          for hemi in lh rh
          do
            aparcstats2table --subjects ${SUBJECT} --hemi ${hemi} --parc ${curr_parc}_${curr_meas} --meas thickness --tablefile ${targ_dir}/${sub}_${curr_parc}_${curr_meas}_${hemi}.txt
          done
        done
      done
    done     
fi


