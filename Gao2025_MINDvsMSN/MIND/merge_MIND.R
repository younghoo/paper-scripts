library(dplyr)
## Merge MIND matrix into one file
setwd('/home/huyang/Projects/HuYang/HY_20250708')
## Load sublist
sublist <- scan('./PROCDATA/LIST/t1_sublist_postqc.txt', what = '')
## Merge MIND
atlas_names <- c('Schaefer.300Parcels.7Networks', '500.aparc')
meas_names <- c('FF', 'CT', 'CV')
for (curr_atlas in atlas_names){
  for (curr_meas in meas_names){
    mind_dat <- NULL
    for (curr_sub in sublist){
      in_fname <- paste('./PROCDATA/STATS/T1/MIND/',curr_sub, '_', curr_atlas, '_', curr_meas, '.txt', sep = '')
      curr_mind <- as.matrix(read.table(in_fname, header = TRUE))
      ## Extract unique values
      mind_vec <- curr_mind[lower.tri(curr_mind)]
      mind_dat <- rbind(mind_dat, mind_vec)
    }
    NE <- ncol(mind_dat)
    mind_dat <- data.frame(FID=sublist, mind_dat)
    names(mind_dat)[-1] <- paste('E', c(1:NE), sep = '')
    ## save
    curr_meas_goodname <- ifelse(curr_meas == 'FF', '5F', curr_meas)
    curr_atlas_goodname <- case_when(
      curr_atlas == 'Schaefer.300Parcels.7Networks' ~ 'Schaefer300',
      curr_atlas == '500.aparc' ~ 'DK308'
    )
    out_fname <- paste('./PROCDATA/STATS/T1/SUMMARY/RAW/MIND_', curr_meas_goodname, '_', curr_atlas_goodname, '_raw.rds', sep = '')
    saveRDS(mind_dat, out_fname)
  }
}

