## Calculate the Cohen's D difference between methods
setwd('/home/huyang/Projects/HuYang/HY_20251111')
## Loop each dataset
for (curr_set in c('eNKI')){
  out_dir <- paste('./PROCDATA/STATS/AGE/', curr_set, sep = '')
  ## Loop each atlas 
  for (curr_atlas in c('DK308', 'Schaefer300')){
    ## Load CohenD data
    in_fname <- paste(out_dir, '/', curr_atlas, '_CohenD.rds', sep = '')
    CohenD_dat <- readRDS(in_fname)
    ## Create comparison pairs
    meas_names <- c('MIND_5F', 'MIND_CT', 'MIND_CV', 'MSN_5F1S', 'MSN_9F1S', 'MSN_5F4S')
    pair_names <- combn(meas_names,2)
    pair_names <- pair_names[, c(1,2,13,14,3)]
    NP <- ncol(pair_names)
    output <- NULL
    for (pair_idx in c(1:NP)){
      curr_x_name <- pair_names[1, pair_idx]
      curr_y_name <- pair_names[2, pair_idx]
      curr_x_real <- CohenD_dat[[curr_x_name]][['Real']]
      curr_y_real <- CohenD_dat[[curr_y_name]][['Real']]
      curr_x_jack <- CohenD_dat[[curr_x_name]][['Jack']]
      curr_y_jack <- CohenD_dat[[curr_y_name]][['Jack']]
      curr_x_boot <- CohenD_dat[[curr_x_name]][['Boot']]
      curr_y_boot <- CohenD_dat[[curr_y_name]][['Boot']]
      ## Calculate the difference
      curr_diff_real <- curr_x_real - curr_y_real
      curr_diff_jack <- curr_x_jack - curr_y_jack
      curr_diff_boot <- curr_x_boot - curr_y_boot
      ## Calculate 95% CI using BCa method
      alpha <- 0.05
      z0 <- qnorm(mean(curr_diff_boot < curr_diff_real))
      U <- (curr_diff_real - curr_diff_jack)
      a <- sum(U^3)/(6*sum(U^2)^(3/2))
      lb <- pnorm(z0+(z0+qnorm(alpha/2))/(1-a*(z0+qnorm(alpha/2))))
      ub <- pnorm(z0+(z0+qnorm(1-alpha/2))/(1-a*(z0+qnorm(1-alpha/2))))
      curr_ci <- quantile(curr_diff_boot, c(lb, ub))
      curr_sig <- ifelse(curr_ci[1] > 0 | curr_ci[2] < 0, 1, 0)
      ## Merge data
      curr_comp_name <- paste(curr_x_name, curr_y_name, sep = '-')
      curr_output <- data.frame(Comparison=curr_comp_name, Diff=curr_diff_real, LB=curr_ci[1], UB=curr_ci[2], Sig=curr_sig)
      output <- rbind(output, curr_output)
    }
    ## Check failure
    output$Fail <- ifelse(output$Diff < output$LB | output$Diff > output$UB, 1, 0)
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_CohenD_Diff.csv', sep = '')
    write.csv(output, out_fname, row.names = FALSE, quote = FALSE)
  }
}

