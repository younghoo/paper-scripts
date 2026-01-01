#! /bin/bash
export SUBJECTS_DIR=$1
SUBJECT=freesurfer
## Calculate LGI
recon-all -s ${SUBJECT} -localGI
## Calculate ROI measure
for curr_parc in Schaefer.300Parcels.7Networks 500.aparc
do
  for hemi in lh rh
  do
    mris_anatomical_stats -mgz -cortex ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.cortex.label -f ${SUBJECTS_DIR}/${SUBJECT}/stats/${hemi}.${curr_parc}_lgi.stats -b -a ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.${curr_parc}.annot -t pial_lgi ${SUBJECT} ${hemi} white
  done
done


