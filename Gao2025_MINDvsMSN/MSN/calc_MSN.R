library(stringr)
## Calculate MSN
setwd('/home/huyang/Projects/HuYang/HY_20250708')
atlas_names <- c('Schaefer300', 'DK308')
meas_names <- c('Morph_5F4S', 'Morph_5F1S', 'Morph_9F1S')
for (curr_atlas in atlas_names){
  for (curr_meas in meas_names){
    ## Load raw data (Z-score)
    in_fname <- paste('./PROCDATA/STATS/T1/MSN/', curr_meas, '_', curr_atlas, '_Zscore_raw.rds', sep = '')
    raw_dat <- readRDS(in_fname)
    sublist <- names(raw_dat)
    ## Calculate MSN
    msn_dat <- NULL
    for (curr_sub in sublist){
      curr_dat <-  raw_dat[[curr_sub]]
      curr_msn <- cor(curr_dat, method = 'pearson')
      msn_vec <- curr_msn[lower.tri(curr_msn)]
      msn_dat <- rbind(msn_dat, msn_vec)
    }
    NE <- ncol(msn_dat)
    msn_dat <- data.frame(FID=sublist, msn_dat)
    names(msn_dat)[-1] <- paste('E', c(1:NE), sep = '')
    ## save
    curr_meas_goodname <- str_replace(curr_meas, 'Morph', 'MSN')
    out_fname <- paste('./PROCDATA/STATS/T1/SUMMARY/RAW/', curr_meas_goodname, '_', curr_atlas, '_raw.rds', sep = '')
    saveRDS(msn_dat, out_fname)
  }
}

