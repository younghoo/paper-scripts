## Calculate the SVR ACC difference between methods
setwd('/home/huyang/Projects/HuYang/HY_20251111')
## Loop each dataset
for (curr_set in c('eNKI', 'Cam-CAN')){
  out_dir <- paste('./PROCDATA/STATS/AGE/', curr_set, sep = '')
  ## Loop each atlas
  for (curr_atlas in c('Schaefer300', 'DK308')){
    ## Load SVR data
    in_fname <- paste(out_dir, '/', curr_atlas, '_SVR.rds', sep = '')
    SVR_dat <- readRDS(in_fname)
    ## Create comparison pairs
    meas_names <- c('MIND_5F', 'MIND_CT', 'MIND_CV', 'MSN_5F1S', 'MSN_9F1S', 'MSN_5F4S')
    pair_names <- combn(meas_names,2)
    pair_names <- pair_names[, c(1,2,13,14,3)]
    NP <- ncol(pair_names)
    ## Loop each comparison
    output <- NULL
    for (pair_idx in c(1:NP)){
      curr_x_name <- pair_names[1, pair_idx]
      curr_y_name <- pair_names[2, pair_idx]
      ## Loop each type of accuracy metrics
      ACC_types <- c('PPC', 'PSC', 'MAE', 'PPC.F', 'PSC.F', 'MAE.F', 'PPC.M', 'PSC.M', 'MAE.M')
      for (type_idx in c(1:length(ACC_types))){
        curr_x_dat <- SVR_dat[[curr_x_name]][, type_idx]
        curr_y_dat <- SVR_dat[[curr_y_name]][, type_idx]
        curr_diff_dat <- curr_x_dat - curr_y_dat
        stat_dat <- t.test(curr_diff_dat)
        ## Merge data
        curr_comp_name <- paste(curr_x_name, curr_y_name, sep = '-')
        curr_output <- data.frame(Comparison=curr_comp_name, ACCMetric=ACC_types[type_idx], DiffMean=mean(curr_diff_dat), DiffSD=sd(curr_diff_dat),
                                  Tval=stat_dat$statistic, Pval=stat_dat$p.value, Sig=ifelse(stat_dat$p.value < 0.05, 1, 0))
        output <- rbind(output, curr_output)
      }
    }
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_SVR_Diff.csv', sep = '')
    write.csv(output, out_fname, row.names = FALSE, quote = FALSE)
  }
}

