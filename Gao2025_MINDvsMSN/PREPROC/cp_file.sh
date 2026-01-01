#! /bin/bash
step=1
## Copy files for MIND calculation
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/STATS/T1/FSDATA
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist_init.txt
    for sub in $(cat $sublist)
    do
      echo $sub
      INDIR=${sour_dir}/${sub}/t1_proc/freesurfer
      OUTDIR=${targ_dir}/${sub}
      ## Copy surf files
      mkdir -p ${OUTDIR}/surf
      cp ${INDIR}/surf/?h.thickness ${OUTDIR}/surf
      cp ${INDIR}/surf/?h.curv ${OUTDIR}/surf
      cp ${INDIR}/surf/?h.volume ${OUTDIR}/surf
      cp ${INDIR}/surf/?h.sulc ${OUTDIR}/surf
      cp ${INDIR}/surf/?h.area ${OUTDIR}/surf
      ## Copy annot files
      mkdir -p ${OUTDIR}/label
      cp ${INDIR}/label/*Schaefer.300*.annot ${OUTDIR}/label
      cp ${INDIR}/label/*.500.aparc.annot ${OUTDIR}/label
    done
fi


