library(foreach)
library(doParallel)
## Calculate the significance proportion of real, bootstrap and jackknife group difference
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
  ## Generate bootstrap samples
  NSUB <- 200
  NBOOT <- 2000
  set.seed(100)
  G1_sub_idx <- which(subinfo$Group == 'G1_YA')
  G1_samples <- replicate(NBOOT, sample(G1_sub_idx, length(G1_sub_idx), replace=TRUE))
  G2_sub_idx <- which(subinfo$Group == 'G2_OA')
  G2_samples <- replicate(NBOOT, sample(G2_sub_idx, length(G2_sub_idx), replace=TRUE))
  boot_samples <- rbind(G1_samples, G2_samples)
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
      ## Loop each variable & calculate the real statistic
      NVAR <- ncol(all_dat)
      var_names <- names(all_dat)[7:NVAR]
      NVAR <- length(var_names)
      pval_real <- foreach(var_idx = 1:NVAR, .combine='c') %dopar% {
        curr_var_dat <- all_dat[, c(1:6, var_idx+6)]
        names(curr_var_dat)[7] <- 'Var'
        curr_lm_mod <- lm(curr_var_dat$Var ~ curr_var_dat$Group + curr_var_dat$Sex + curr_var_dat$TIV + curr_var_dat$EulerNum)
        curr_stat <- summary(curr_lm_mod)
        curr_stat <- curr_stat$coefficients[2,4]
        return(curr_stat)
      }
      pval_real_fdr <- p.adjust(pval_real, method = 'fdr')
      pval_real_stat <- mean(pval_real_fdr < 0.05)
      output[[curr_meas]][['Real']] <- pval_real_stat
      ## Calculate the jackknife statistic
      pval_jack <- foreach(var_idx = 1:NVAR, .combine='cbind') %dopar% {
        curr_var_dat <- all_dat[, c(1:6, var_idx+6)]
        names(curr_var_dat)[7] <- 'Var'
        ## Jackknife resampling
        curr_pval_dat <- matrix(0, nrow=NSUB, ncol=1)
        for (sub_idx in c(1:NSUB)){
          curr_jack_dat <- curr_var_dat[-sub_idx, ]
          curr_lm_mod <- lm(curr_jack_dat$Var ~ curr_jack_dat$Group + curr_jack_dat$Sex + curr_jack_dat$TIV + curr_jack_dat$EulerNum)
          curr_stat <- summary(curr_lm_mod)
          curr_stat <- curr_stat$coefficients[2,4]
          curr_pval_dat[sub_idx, ] <- curr_stat
        }
        return(curr_pval_dat)
      }
      pval_jack_fdr <- t(apply(pval_jack, 1, p.adjust, method = 'fdr'))
      pval_jack_stat <- apply(pval_jack_fdr, 1, function(x){mean(x < 0.05)})
      output[[curr_meas]][['Jack']] <- pval_jack_stat
      ## Calculate the bootstrap statistic
      pval_boot <- foreach(var_idx = 1:NVAR, .combine='cbind') %dopar% {
        curr_var_dat <- all_dat[, c(1:6, var_idx+6)]
        names(curr_var_dat)[7] <- 'Var'
        ## Bootstrap procedure
        curr_pval_dat <- matrix(0, nrow=NBOOT, ncol=1)
        for (boot_idx in c(1:NBOOT)){
          curr_boot_dat <- curr_var_dat[boot_samples[,boot_idx], ]
          curr_lm_mod <- lm(curr_boot_dat$Var ~ curr_boot_dat$Group + curr_boot_dat$Sex + curr_boot_dat$TIV + curr_boot_dat$EulerNum)
          curr_stat <- summary(curr_lm_mod)
          curr_stat <- curr_stat$coefficients[2,4]
          curr_pval_dat[boot_idx, ] <- curr_stat
        }
        return(curr_pval_dat)
      }
      pval_boot_fdr <- t(apply(pval_boot, 1, p.adjust, method = 'fdr'))
      pval_boot_stat <- apply(pval_boot_fdr, 1, function(x){mean(x < 0.05)})
      output[[curr_meas]][['Boot']] <- pval_boot_stat
    }
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_SigProp.rds', sep = '')
    saveRDS(output, out_fname)
  }
}
end_time <- Sys.time()
run_time <- end_time - start_time
print(run_time)
## Close parallel cluster
parallel::stopCluster(cl = my.cluster)

