library(irr)
library(mgc)
library(foreach)
library(doParallel)
## Calculate edge-wise ICC and Discr for visualization
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
  ## Loop each atlas 
  for (curr_atlas in c('DK308', 'Schaefer300')){
    ## Loop each measure
    output <- list()
    for (curr_meas in c('MIND_5F', 'MIND_CT', 'MIND_CV', 'MSN_5F1S', 'MSN_9F1S', 'MSN_5F4S')){
      ## Load raw data
      in_fname <- paste('./PROCDATA/STATS/RAW/', curr_set, '/', curr_meas, '_', curr_atlas, '_raw.rds', sep = '')
      raw_dat <- readRDS(in_fname)
      var_names <- names(raw_dat)[-1]
      ## Calculate ICC
      NVAR <- length(var_names)
      ICC_dat <- foreach(var_idx = 1:NVAR, .combine='c') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        ## Convert the data into a subject by visit matrix
        curr_var_dat <- matrix(curr_var_dat, ncol=NVIS, byrow = TRUE)
        ## Calculate ICC
        ICC_result <- icc(curr_var_dat, model = "twoway", type = "agreement", unit = "single")
        curr_ICC_dat <- ifelse(ICC_result$value < 0, 0, ICC_result$value)
        return(curr_ICC_dat)
      }
      output[[curr_meas]][['ICC']] <- ICC_dat
      ## Calculate Discr
      NVAR <- length(var_names)
      sublist <- str_remove(raw_dat$FID, "_[^_]+$")
      Discr_dat <- foreach(var_idx = 1:NVAR, .combine='c') %dopar% {
        curr_var_dat <- raw_dat[, (var_idx+1)]
        curr_Discr_dat <- discr.stat(curr_var_dat, sublist)$discr
        return(curr_Discr_dat)
      }
      output[[curr_meas]][['Discr']] <- Discr_dat
    }
    ## Save
    out_fname <- paste(out_dir, '/', curr_atlas, '_edge_ICC_Discr.rds', sep = '')
    saveRDS(output, out_fname)
  }
}
end_time <- Sys.time()
run_time <- end_time - start_time
print(run_time)
## Close parallel cluster
parallel::stopCluster(cl = my.cluster)

