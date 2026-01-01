#! /bin/bash
step=2
## Copy QC figures
if [[ $step -eq 1 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/QCDATA/T1
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist.txt
    ## Loop subjects
    for sub in $(cat $sublist)
    do
      echo $sub
      INDIR=${sour_dir}/${sub}/t1_proc
      if [[ -f ${INDIR}/stats/t1_Aseg_volume.sum ]]
      then
          OUTDIR=${targ_dir}/BET
          mkdir -p ${OUTDIR}
          cp ${INDIR}/masks/t1_brainmask.png ${OUTDIR}/${sub}.png
          OUTDIR=${targ_dir}/SEG/WM
          mkdir -p ${OUTDIR}
          cp ${INDIR}/masks/t1_wmmask.png ${OUTDIR}/${sub}.png
          OUTDIR=${targ_dir}/SEG/CSF
          mkdir -p ${OUTDIR}
          cp ${INDIR}/masks/t1_csfmask.png ${OUTDIR}/${sub}.png
      fi
    done
fi
## Extract Euler number for each subject
if [[ $step -eq 2 ]]
then
    sour_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/NIIDATA/T1
    targ_dir=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/QCDATA/T1/SurfHoles
    sublist=/Data/sharehome/huyang/HuYang/HY_20250709/PROCDATA/LIST/sublist.txt
    mkdir -p ${targ_dir}
    if [[ -f ${targ_dir}/total_holes.txt ]]
    then
        rm ${targ_dir}/total_holes.txt
    fi
    for sub in $(cat $sublist)
    do
      echo $sub
      if [[ -f ${sour_dir}/${sub}/t1_proc/freesurfer/stats/aseg.stats ]]
      then
          total_holes=$(cat ${sour_dir}/${sub}/t1_proc/freesurfer/stats/aseg.stats | grep "Measure SurfaceHoles" | cut -d ',' -f 4)      
          printf "%s\t%s\n" ${sub} ${total_holes} >> ${targ_dir}/total_holes.txt
      fi
    done
fi


