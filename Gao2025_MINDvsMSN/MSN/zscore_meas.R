## Calculate the Z-score for each measure
setwd('/home/huyang/Projects/HuYang/HY_20250708')
atlas_names <- c('Schaefer300', 'DK308')
for (curr_atlas in atlas_names){
  meas_names <- c('Morph_5F4S', 'Morph_5F1S', 'Morph_9F1S')
  for (curr_meas in meas_names){
    ## Load raw data
    in_fname <- paste('./PROCDATA/STATS/T1/MSN/', curr_meas, '_', curr_atlas, '_raw.rds', sep = '')
    raw_dat <- readRDS(in_fname)
    ## Loop each subject
    sublist <- names(raw_dat)
    output <- list()
    for (curr_sub in sublist){
      curr_dat <- raw_dat[[curr_sub]]
      ## Z-score
      zscore_dat <- scale(t(as.matrix(curr_dat)), center = TRUE, scale = TRUE)
      output[[curr_sub]] <- t(zscore_dat)
    }
    ## Save
    out_fname <- paste('./PROCDATA/STATS/T1/MSN/', curr_meas, '_', curr_atlas, '_Zscore_raw.rds', sep = '')
    saveRDS(output, out_fname)
  }
}

