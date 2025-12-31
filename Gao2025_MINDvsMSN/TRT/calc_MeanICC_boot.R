library(irr)
library(foreach)
library(doParallel)
## Calculate the mean of real, jackknife, and bootstrap ICC
setwd('/home/huyang/Projects/HuYang/HY_20251111')
## Set parallel cluster to speed up
n.cores <- 20
my.cluster <- parallel::makeCluster(n.cores, type = "FORK")
doParallel::registerDoParallel(cl = my.cluster)
start_time <- Sys.time()
## Loop each dataset 
for (curr_set in c('BNU1', 'HNU1')){
  ## Create the output folder
  out_dir <- paste('./PROCDATA/STATS/TRT/', curr_set, sep = '')
  dir.create(out_dir, recursive = TRUE)
  if (curr_set == 'BNU1'){
    NSUB <- 47
    NVIS <- 2
  }else{
    NSUB <- 24
    NVIS <- 10
  }
  NBOOT <- 2000
  set.seed(100)
  boot_samples <- replicate(NBOOT, sample(1:NSUB, NSUB, replace=TRUE))
  ## Loop each atlas 
  for (curr_atlas in c('DK308', 'Schaefer300')){
    ## Loop each measure
    output <- list()
    for (curr_meas in c('MIND_5F', 'MIND_CT', 'MIND_CV', 'MSN_5F1S', 'MSN_9F1S', 'MSN_5F4S')){
      ## Load raw data
      in_fname <- paste('./PROCDATA/STATS/RAW/', curr_set, '/', curr_meas, '_', curr_atlas, '_raw.rds', sep = '')
      raw_dat <- readRDS(in_fname)
      var_names <- names(raw_dat)[-1]
      ## Calculate the real ICC statistic
      NVAR <- length(var_names)
      ICC_real <- foreach(var_idx = 1:NVAR, .combine='c') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        ## Convert the data into a subject by visit matrix
        curr_var_dat <- matrix(curr_var_dat, ncol=NVIS, byrow = TRUE)
        ## Calculate ICC
        ICC_result <- icc(curr_var_dat, model = "twoway", type = "agreement", unit = "single")
        curr_ICC_dat <- ifelse(ICC_result$value < 0, 0, ICC_result$value)
        return(curr_ICC_dat)
      }
      ICC_real_stat <- mean(ICC_real)
      output[[curr_meas]][['Real']] <- ICC_real_stat
      ## Calculate the jackknife ICC statistic
      ICC_jack <- foreach(var_idx = 1:NVAR, .combine='cbind') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        ## Convert the data into a subject by visit matrix
        curr_var_dat <- matrix(curr_var_dat, ncol=NVIS, byrow = TRUE)
        ## Jackknife resampling
        curr_ICC_dat <- matrix(0, nrow=NSUB, ncol=1)
        for (sub_idx in c(1:NSUB)){
          curr_jack_dat <- curr_var_dat[-sub_idx, ]
          ## Calculate ICC
          ICC_result <- icc(curr_jack_dat, model = "twoway", type = "agreement", unit = "single")
          curr_ICC_dat[sub_idx, ] <- ifelse(ICC_result$value < 0, 0, ICC_result$value)
        }
        return(curr_ICC_dat)
      }
      ICC_jack_stat <- apply(ICC_jack, 1, mean)
      output[[curr_meas]][['Jack']] <- ICC_jack_stat
      ## Calculate the bootstrap ICC statistic
      ICC_boot <- foreach(var_idx = 1:NVAR, .combine='cbind') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        ## Convert the data into a subject by visit matrix
        curr_var_dat <- matrix(curr_var_dat, ncol=NVIS, byrow = TRUE)
        ## Bootstrap procedure
        curr_ICC_dat <- matrix(0, nrow=NBOOT, ncol=1)
        for (boot_idx in c(1:NBOOT)){
          ## Bootstrap the data
          curr_boot_dat <- curr_var_dat[boot_samples[,boot_idx], ]
          ## Calculate ICC
          ICC_result <- icc(curr_boot_dat, model = "twoway", type = "agreement", unit = "single")
          curr_ICC_dat[boot_idx,] <- ifelse(ICC_result$value < 0, 0, ICC_result$value)
        }
        return(curr_ICC_dat)
      }
      ICC_boot_stat <- apply(ICC_boot, 1, mean)
      output[[curr_meas]][['Boot']] <- ICC_boot_stat
    }
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_MeanICC.rds', sep = '')
    saveRDS(output, out_fname)
  }
}
end_time <- Sys.time()
run_time <- end_time - start_time
print(run_time)
## Close parallel cluster
parallel::stopCluster(cl = my.cluster)

