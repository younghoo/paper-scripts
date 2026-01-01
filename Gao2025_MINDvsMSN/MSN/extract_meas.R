library(fsbrain)
library(tidyr)
library(stringr)
library(e1071)
library(dplyr)
## Extract parcel-wise measures based on vertex data
setwd('/home/huyang/Projects/HuYang/HY_20250708')
fs_dir <- './PROCDATA/STATS/T1/FSDATA'
sublist <- scan('./PROCDATA/LIST/t1_sublist_postqc.txt', what = '')
atlas_names <- c('Schaefer.300Parcels.7Networks', '500.aparc')
meas_names <- c('thickness', 'area', 'volume', 'sulc', 'curv')
func_names <- c('mean', 'sd', 'skewness', 'kurtosis')
for (curr_atlas in atlas_names){
  output <- list()
  for (curr_sub in sublist){
    func_dat <- NULL
    for (curr_func in func_names){
      for (curr_meas in meas_names){
        cort_dat <- NULL
        for (curr_hemi in c('lh', 'rh')){
          morph_dat <- subject.morph.native(fs_dir, curr_sub, curr_meas, curr_hemi)
          annot_dat <- subject.annot(fs_dir, curr_sub, curr_hemi, curr_atlas)
          curr_dat <- data.frame(morph = morph_dat, label = annot_dat$label_names)
          stat_dat <- aggregate(curr_dat$morph, list(curr_dat$label), curr_func)
          ## Remove uninteresting data
          rm_idx <- stat_dat$Group.1 %in% c('', 'Unknown')
          stat_dat <- stat_dat[!rm_idx,]
          ## Add hemi info into the region label
          stat_dat$Group.1 <- paste(curr_hemi, '_', stat_dat$Group.1, sep = '')
          ## Refine label names for Schaefer300
          stat_dat$Group.1 <- str_remove(stat_dat$Group.1, '7Networks_(RH|LH)_')
          ## Refine label names for aparc.a2009s
          stat_dat$Group.1 <- str_replace_all(stat_dat$Group.1, fixed('&'), '_and_')
          stat_dat$Group.1 <- str_replace_all(stat_dat$Group.1, fixed('-'), '_')
          cort_dat <- rbind(cort_dat, stat_dat)
        }
        names(cort_dat) <- c('Label', 'Stat')
        cort_dat <- spread(cort_dat, Label, Stat)
        func_dat <- rbind(func_dat, cort_dat)
      }
    }
    ## Load node label to reorder the columns
    if (curr_atlas %in% c('aparc')){
      node_info <- read.table('/home/huyang/Atlases/FreeSurfer/PROCDATA/DK/LABEL/DK_node_labels.txt', header = TRUE)
    }else if (curr_atlas %in% c('aparc.a2009s')){
      node_info <- read.table('/home/huyang/Atlases/FreeSurfer/PROCDATA/Destrieux/LABEL/Destrieux_node_labels.txt', header = TRUE)
    }else if (curr_atlas %in% c('500.aparc')){
      node_info <- read.table('/home/huyang/Atlases/DK308/PROCDATA/LABEL/DK308_node_labels.txt', header = TRUE)
    }else{
      node_info <- read.table('/home/huyang/Atlases/Schaefer2018/PROCDATA/Schaefer300/LABEL/Schaefer300_Yeo7_node_labels.txt', header = TRUE)
    }
    func_dat <- func_dat[, node_info$LABEL]
    output[[curr_sub]] <- func_dat
  }
  ## Save
  curr_atlas_goodname <- case_when(
    curr_atlas == 'aparc' ~ 'DK',
    curr_atlas == 'aparc.a2009s' ~ 'Destrieux',
    curr_atlas == 'Schaefer.300Parcels.7Networks' ~ 'Schaefer300',
    curr_atlas == '500.aparc' ~ 'DK308'
  )
  out_fname <- paste('./PROCDATA/STATS/T1/MSN/Morph_5F4S_', curr_atlas_goodname, '_raw.rds', sep = '')
  saveRDS(output, out_fname)
}

