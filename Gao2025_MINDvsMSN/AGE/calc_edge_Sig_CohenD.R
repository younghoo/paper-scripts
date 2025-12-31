library(foreach)
library(doParallel)
library(emmeans)
## Calculate edge-wise significance and Cohen's D for visualization
setwd('/home/huyang/Projects/HuYang/HY_20251111')
## Set parallel cluster to speed up
n.cores <- 20
my.cluster <- parallel::makeCluster(n.cores, type = "FORK")
doParallel::registerDoParallel(cl = my.cluster)
start_time <- Sys.time()
## Loop each dataset 
for (curr_set in c('eNKI', 'Cam-CAN')){
  ## Create the output folder
  out_dir <- paste('./PROCDATA/STATS/AGE/', curr_set, sep = '')
  dir.create(out_dir, recursive = TRUE)
  ## Load subject info
  in_fname <- paste('./PROCDATA/STATS/RAW/', curr_set, '/t1_subinfo_age_group.csv', sep = '')
  subinfo <- read.csv(in_fname)
  ## Loop each atlas 
  for (curr_atlas in c('DK308', 'Schaefer300')){
    ## Loop each measure
    output <- list()
    for (curr_meas in c('MIND_5F', 'MIND_CT', 'MIND_CV', 'MSN_5F1S', 'MSN_9F1S', 'MSN_5F4S')){
      ## Load raw data
      in_fname <- paste('./PROCDATA/STATS/RAW/', curr_set, '/', curr_meas, '_', curr_atlas, '_raw.rds', sep = '')
      raw_dat <- readRDS(in_fname)
      ## Merge data
      all_dat <- merge(subinfo, raw_dat, by = 'FID')
      ## Check the subject order
      print(sum(subinfo$FID == all_dat$FID))
      ## Loop each variable & calculate the statistic
      NVAR <- ncol(all_dat)
      var_names <- names(all_dat)[7:NVAR]
      NVAR <- length(var_names)
      stat_dat <- foreach(var_idx = 1:NVAR, .combine='rbind') %dopar% {
        curr_var_dat <- all_dat[, c(1:6, var_idx+6)]
        names(curr_var_dat)[7] <- 'Var'
        curr_lm_mod <- lm(curr_var_dat$Var ~ curr_var_dat$Group + curr_var_dat$Sex + curr_var_dat$TIV + curr_var_dat$EulerNum)
        curr_result <- summary(curr_lm_mod)
        curr_Pval <- curr_result$coefficients[2,4]
        curr_Tval <- curr_result$coefficients[2,3]
        EMM <- emmeans(curr_lm_mod, "Group")
        curr_result <- summary(eff_size(EMM, sigma = sigma(curr_lm_mod), edf = df.residual(curr_lm_mod)))
        curr_CohenD <- abs(curr_result$effect.size)
        curr_stat_dat <- data.frame(VAR=var_names[var_idx], Tval=curr_Tval, Pval=curr_Pval, CohenD=curr_CohenD)
        return(curr_stat_dat)
      }
      stat_dat$PvalFDR <- p.adjust(stat_dat$Pval, method = 'fdr')
      output[[curr_meas]] <- stat_dat
    }
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_edge_Sig_CohenD.rds', sep = '')
    saveRDS(output, out_fname)
  }
}
end_time <- Sys.time()
run_time <- end_time - start_time
print(run_time)
## Close parallel cluster
parallel::stopCluster(cl = my.cluster)

