#! /bin/bash
step=1
## Parcellate individual surface using Schaefer300 Atlas
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    atlas_dir=/Data/sharehome/huyang/MyAtlases/Schaefer
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    for sub in $(cat $sublist)
    do
      export SUBJECTS_DIR=${sour_dir}/${sub}/t1_proc
      SUBJECT=freesurfer
      ## Project Schaefer cortical parcellation into individual surface space
      for hemi in lh rh
      do    
        mris_ca_label -l ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.cortex.label ${SUBJECT} ${hemi} ${SUBJECTS_DIR}/${SUBJECT}/surf/${hemi}.sphere.reg ${atlas_dir}/${hemi}.Schaefer2018_300Parcels_7Networks.gcs ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.Schaefer.300Parcels.7Networks.annot
        mris_anatomical_stats -mgz -cortex ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.cortex.label -f ${SUBJECTS_DIR}/${SUBJECT}/stats/${hemi}.Schaefer.300Parcels.7Networks.stats -b -a ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.Schaefer.300Parcels.7Networks.annot ${SUBJECT} ${hemi} white
      done
    done 
fi


