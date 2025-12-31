library(e1071)
library(caret)
library(foreach)
library(doParallel)
library(doRNG)
## Predict age using SVR model
setwd('/home/huyang/Projects/HuYang/HY_20251111')
## Load custom functions
source('./SCRIPTS/AGE/SVR_func.R')
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
  in_fname <- paste('./PROCDATA/STATS/RAW/', curr_set, '/t1_subinfo_postqc.csv', sep = '')
  subinfo <- read.csv(in_fname)
  ## Loop each atlas
  for (curr_atlas in c('DK308', 'Schaefer300')){
    ## Loop each type of measures
    output <- list()
    for (curr_meas in c('MIND_5F', 'MIND_CT', 'MIND_CV', 'MSN_5F1S', 'MSN_9F1S', 'MSN_5F4S')){
      ## Load raw data
      in_fname <- paste('./PROCDATA/STATS/RAW/', curr_set, '/', curr_meas, '_', curr_atlas, '_raw.rds', sep = '')
      raw_dat <- readRDS(in_fname)
      ## Check subject order
      print(sum(subinfo$FID == raw_dat$FID))
      ## Run SVR
      curr_x_dat <- raw_dat[, -1]
      curr_y_dat <- subinfo$Age
      cov_dat <- subinfo[, c('Sex', 'TIV', 'EulerNum')]
      cov_dat$TIV <- scale(cov_dat$TIV, center = TRUE, scale = FALSE)
      cov_dat$EulerNum <- scale(cov_dat$EulerNum, center = TRUE, scale = FALSE)
      acc_dat <- SVR_CV(curr_x_dat, curr_y_dat, cov_dat)
      output[[curr_meas]] <- acc_dat
    }
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_SVR.rds', sep = '')
    saveRDS(output, out_fname)
  }
}
end_time <- Sys.time()
print(end_time - start_time)
## Close parallel cluster
parallel::stopCluster(cl = my.cluster)

