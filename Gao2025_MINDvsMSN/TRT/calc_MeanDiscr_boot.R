library(mgc)
library(foreach)
library(doParallel)
library(stringr)
## Calculate the mean of real, bootstrap and jackknife Discr
setwd('/home/huyang/Projects/HuYang/HY_20251111')
## Set parallel cluster to speed up
n.cores <- 20
my.cluster <- parallel::makeCluster(n.cores, type = "FORK")
doParallel::registerDoParallel(cl = my.cluster)
start_time <- Sys.time()
## Loop each dataset 
for (curr_set in c('BNU1')){
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
  NBOOT <- 1000
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
      ## Calculate the real Discr statistic
      NVAR <- length(var_names)
      sublist <- str_remove(raw_dat$FID, "_[^_]+$")
      Discr_real <- foreach(var_idx = 1:NVAR, .combine='c') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        curr_Discr_dat <- discr.stat(curr_var_dat, sublist)$discr
        return(curr_Discr_dat)
      }
      Discr_real_stat <- mean(Discr_real)
      output[[curr_meas]][['Real']] <- Discr_real_stat
      ## Calculate the jackknife Discr statistic
      Discr_jack <- foreach(var_idx = 1:NVAR, .combine='cbind') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        ## Jackknife resampling
        curr_Discr_dat <- matrix(0, nrow=NSUB, ncol=1)
        for (sub_idx in c(1:NSUB)){
          rm_idx <- sublist %in% unique(sublist)[sub_idx]
          curr_jack_dat <- curr_var_dat[!rm_idx]
          curr_jack_list <- sublist[!rm_idx]
          curr_Discr_dat[sub_idx, ] <- discr.stat(curr_jack_dat, curr_jack_list)$discr
        }
        return(curr_Discr_dat)
      }
      Discr_jack_stat <- apply(Discr_jack, 1, mean)
      output[[curr_meas]][['Jack']] <- Discr_jack_stat
      ## Calculate the bootstrap Discr statistic
      Discr_boot <- foreach(var_idx = 1:NVAR, .combine='cbind') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        ## Convert the data into a subject by visit matrix for easier bootstrap
        curr_var_dat <- matrix(curr_var_dat, ncol=NVIS, byrow = TRUE)
        ## Bootstrap procedure
        curr_Discr_dat <- matrix(0, nrow=NBOOT, ncol=1)
        for (boot_idx in c(1:NBOOT)){
          ## Bootstrap the data
          curr_boot_dat <- curr_var_dat[boot_samples[,boot_idx], ]
          ## Reshape back to 1D form
          curr_boot_dat <- c(t(curr_boot_dat))
          curr_Discr_dat[boot_idx, ] <- discr.stat(curr_boot_dat, sublist)$discr
        }
        return(curr_Discr_dat)
      }
      Discr_boot_stat <- apply(Discr_boot, 1, mean)
      output[[curr_meas]][['Boot']] <- Discr_boot_stat
    }
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_MeanDiscr.rds', sep = '')
    saveRDS(output, out_fname)
  }
}
end_time <- Sys.time()
run_time <- end_time - start_time
print(run_time)
## Close parallel cluster
parallel::stopCluster(cl = my.cluster)

