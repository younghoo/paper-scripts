library(stringr)
library(dplyr)
## Merge all measures into one file
setwd('/home/huyang/Projects/HuYang/HY_20250708')
sublist <- scan('./PROCDATA/LIST/t1_sublist_postqc.txt', what = '')
meas_names <- c('thickness', 'area', 'volume', 'sulc', 'meancurv', 'gauscurv', 'curvind', 'foldind', 'lgi')
atlas_names <- c('Schaefer.300Parcels.7Networks', '500.aparc')
for (curr_atlas in atlas_names){
  output <- list()
  output2 <- list()
  for (curr_sub in sublist){
    meas_dat <- NULL
    for (curr_meas in meas_names){
      cort_dat <- NULL
      for (curr_hemi in c('lh', 'rh')){
        in_fname <- paste('./PROCDATA/STATS/T1/ROIDATA/', curr_sub, '_', curr_atlas, '_', curr_meas, '_', curr_hemi, '.txt', sep = '')
        morph_dat <- read.table(in_fname, header = TRUE, check.names = FALSE)
        ## Remove the first column
        morph_dat <- morph_dat[,-1]
        ## Remove uninteresting data
        rm_idx <- names(morph_dat) %in% c("lh_MeanThickness_thickness", "rh_MeanThickness_thickness",
                                          "lh_WhiteSurfArea_area", "rh_WhiteSurfArea_area",
                                          "BrainSegVolNotVent", "eTIV")
        morph_dat <- morph_dat[, !rm_idx]
        ## Combine the left and right data
        if (is.null(cort_dat)){
          cort_dat <- morph_dat
        }else{
          cort_dat <- cbind(cort_dat, morph_dat)
        }
      }
      names(cort_dat) <- str_remove(names(cort_dat), '_(thickness|area|volume|meancurv|gauscurv|curvind|foldind)')
      ## Remove uninteresting columns for DK308
      rm_idx <- names(cort_dat) %in% c('lh_unknown_part1', 'rh_unknown_part1')
      cort_dat <- cort_dat[, !rm_idx]
      ## Refine label names for Schaefer300
      names(cort_dat) <- str_remove(names(cort_dat), '(lh|rh)_7Networks_')
      names(cort_dat) <- str_replace_all(names(cort_dat), pattern = "(LH|RH)", replacement = tolower)
      ## Refine label names for aparc.a2009s
      names(cort_dat) <- str_replace_all(names(cort_dat), fixed('&'), '_and_')
      names(cort_dat) <- str_replace_all(names(cort_dat), fixed('-'), '_')
      meas_dat <- rbind(meas_dat, cort_dat)
    }
    output[[curr_sub]] <- meas_dat
    output2[[curr_sub]] <- meas_dat[1:5,]
  }
  ## Save
  curr_atlas_goodname <- case_when(
    curr_atlas == 'aparc' ~ 'DK',
    curr_atlas == 'aparc.a2009s' ~ 'Destrieux',
    curr_atlas == '500.aparc' ~ 'DK308',
    curr_atlas == 'Schaefer.300Parcels.7Networks' ~ 'Schaefer300',
    .default = as.character(curr_atlas)
  )
  out_fname <- paste('./PROCDATA/STATS/T1/MSN/Morph_9F1S_', curr_atlas_goodname, '_raw.rds', sep = '')
  saveRDS(output, out_fname)
  out_fname <- paste('./PROCDATA/STATS/T1/MSN/Morph_5F1S_', curr_atlas_goodname, '_raw.rds', sep = '')
  saveRDS(output2, out_fname)
}

