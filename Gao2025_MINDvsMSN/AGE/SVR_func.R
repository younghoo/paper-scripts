## Custom functions to perform Repeated K-fold Cross-Validated Support Vector Regression
## Version 1.0.10 / 2025-11-22
## This version ensures the reproducibility of parallel processing using doRNG package
## ---------------------------------------------------------------------
## Function to calculate accuracy metrics
calc_ACC <- function(y_real, y_predict, cov_dat){
  ## y_real is the real value of target variable
  ## y_predict is the predicted value of target variable
  ## cov_dat is the data.frame of covariate variables
  ## Partial Pearson correlation
  y_real_resid <- resid(lm(y_real ~ ., data = cov_dat))
  y_predict_resid <- resid(lm(y_predict ~ ., data = cov_dat))
  PPC_dat <- cor(y_real_resid, y_predict_resid)
  ## Partial Spearman correlation
  cov_dat_rank <- as.data.frame(apply(cov_dat, 2, rank))
  y_real_resid <- resid(lm(rank(y_real) ~ ., data = cov_dat_rank))
  y_predict_resid <- resid(lm(rank(y_predict) ~ ., data = cov_dat_rank))
  PSC_dat <- cor(y_real_resid, y_predict_resid)
  ## Mean absolute error
  curr_lm_mod <- lm(y_real ~ ., data = cov_dat)
  y_real_adjust <- resid(curr_lm_mod) + coef(curr_lm_mod)[1]
  curr_lm_mod <- lm(y_predict ~ ., data = cov_dat)
  y_predict_adjust <- resid(curr_lm_mod) + coef(curr_lm_mod)[1]
  MAE_dat <- mean(abs(y_real_adjust - y_predict_adjust))
  ## Combine all metrics
  ACC_dat <- c(PPC_dat, PSC_dat, MAE_dat)
  return(ACC_dat)
}
## Evaluate prediction accuracy using all samples or female/male samples
SVR_ACC <- function(y_real, y_predict, cov_dat){
  ## Using all samples
  all_ACC <- calc_ACC(y_real, y_predict, cov_dat)
  ## Using female samples
  female_idx <- cov_dat$Sex == 'F'
  female_ACC <- calc_ACC(y_real[female_idx], y_predict[female_idx], cov_dat[female_idx, -1])
  ## Using male samples
  male_idx <- cov_dat$Sex == 'M'
  male_ACC <- calc_ACC(y_real[male_idx], y_predict[male_idx], cov_dat[male_idx, -1])
  ## Combine all metrics
  ACC_dat <- c(all_ACC, female_ACC, male_ACC)
  return(ACC_dat)
} 
## ---------------------------------------------------------------------
## Repeated K-fold CV
SVR_CV <- function(x, y, z, K=5, N=4, myseed=1){
  ## x is a matrix or dataframe of predictors, in which row means observation and column means variable
  ## y is a vector of target variable
  ## z is a dataframe of covariates, in which row means observation and column means variable
  ## K means K-fold CV
  ## N means the N repetitions of K-fold CV
  ## myseed means the random seed
  ## Set random seed to ensure reproducibility
  set.seed(myseed)
  ## Randomly split the data into K folds and repeat N times
  all_folds <- matrix(0, nrow=length(y), ncol=N)
  for (col_idx in c(1:N)){
    all_folds[,col_idx] <- createFolds(y, k=K, list = FALSE)
  }
  ## Loop each run of train-test procedure
  M <- N * K
  output <- foreach(curr_run = 1:M, .combine='rbind') %dorng% {
    curr_rep <- (curr_run - 1) %/% K + 1
    curr_fold <- (curr_run - 1) %% K + 1
    ## sub_idx means the subject position index of the current fold
    sub_idx <- which(all_folds[, curr_rep] == curr_fold)
    x_train <- x[-sub_idx,]
    y_train <- y[-sub_idx]
    x_test <- x[sub_idx,,drop=FALSE]
    y_test <- y[sub_idx]
    z_test <- z[sub_idx,,drop=FALSE]
    ## Fit SVR model with hyper-parameter tuning
    model_tune <- tune(svm, x_train, y_train, kernel='linear',
                       ranges = list(epsilon = c(0.01, 0.1, 0.5, 1), cost = c(0.1, 1, 10, 100, 1000)),               
                       tunecontrol = tune.control(nrepeat = 1, sampling = "cross",  cross=K))
    model_train <- model_tune$best.model
    ## Predict
    y_predict <- predict(model_train, x_test)
    ## Evaluate performance
    SVR_ACC(y_test, y_predict, z_test)
  }
  return(output)
}

