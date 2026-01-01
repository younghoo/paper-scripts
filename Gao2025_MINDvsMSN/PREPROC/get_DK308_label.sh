#! /bin/bash
step=1
## Project DK308 Atlas from fsaverage space to individual surface
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    atlas_dir=/Data/sharehome/huyang/MyAtlases/DK308
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist.txt
    fsaverage=${FREESURFER_HOME}/subjects/fsaverage
    for sub in $(cat $sublist)
    do
      export SUBJECTS_DIR=${sour_dir}/${sub}/t1_proc
      SUBJECT=freesurfer
      ln -s $fsaverage $SUBJECTS_DIR/
      for hemi in lh rh
      do
        mri_surf2surf --srcsubject fsaverage --trgsubject $SUBJECT --hemi $hemi --sval-annot ${atlas_dir}/${hemi}.500.aparc.annot --tval ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.500.aparc.annot
        mris_anatomical_stats -mgz -cortex ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.cortex.label -f ${SUBJECTS_DIR}/${SUBJECT}/stats/${hemi}.500.aparc.stats -b -a ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.500.aparc.annot ${SUBJECT} ${hemi} white
      done
      rm $SUBJECTS_DIR/fsaverage
    done
fi


