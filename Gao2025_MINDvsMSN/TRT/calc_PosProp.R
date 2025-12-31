## Calculate the positive proportion of edge-wise difference between methods
setwd('/home/huyang/Projects/HuYang/HY_20251111')
## Loop each statistic
for (curr_stat in c('ICC', 'Discr')){
  ## Loop each dataset
  for (curr_set in c('BNU1', 'HNU1')){
    ## Loop each atlas
    for (curr_atlas in c('DK308', 'Schaefer300')){
      ## Load raw data
      in_fname <- paste('./PROCDATA/STATS/TRT/', curr_set, '/', curr_atlas, '_edge_ICC_Discr.rds', sep = '')
      raw_dat <- readRDS(in_fname)
      ## Loop each measure pair
      meas_names <- c('MIND_5F', 'MIND_CT', 'MIND_CV', 'MSN_5F1S', 'MSN_9F1S', 'MSN_5F4S')
      pair_names <- combn(meas_names,2)
      pair_names <- pair_names[, c(1,2,13,14,3)]
      NP <- ncol(pair_names)
      output <- NULL
      for (pair_idx in c(1:NP)){
        curr_x_name <- pair_names[1, pair_idx]
        curr_y_name <- pair_names[2, pair_idx]
        curr_x_dat <- raw_dat[[curr_x_name]][[curr_stat]]
        curr_y_dat <- raw_dat[[curr_y_name]][[curr_stat]]
        curr_posprop <- mean((curr_x_dat - curr_y_dat)>0)
        curr_comp_name <- paste(curr_x_name, curr_y_name, sep = '-')
        curr_output <- data.frame(Comparison=curr_comp_name, PosProp=curr_posprop)
        output <- rbind(output, curr_output)
      }
      ## Save
      out_fname <- paste('./PROCDATA/STATS/TRT/', curr_set, '/', curr_atlas, '_', curr_stat, '_PosProp.csv', sep = '')
      write.csv(output, out_fname, row.names = FALSE, quote = FALSE)
    }
  }
}

