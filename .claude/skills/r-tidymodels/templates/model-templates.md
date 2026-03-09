# Tidymodels Code Templates

Ready-to-use templates for common machine learning tasks with tidymodels.

## Table of Contents

1. [Binary Classification Workflow](#binary-classification-workflow)
2. [Regression Workflow](#regression-workflow)
3. [Multiclass Classification](#multiclass-classification)
4. [Time Series Forecasting](#time-series-forecasting)
5. [Model Comparison Framework](#model-comparison-framework)
6. [Deployment Pipeline](#deployment-pipeline)

---

## Binary Classification Workflow

Complete workflow for binary classification with cross-validation and tuning.

```r
library(tidymodels)
library(tidyverse)

# Load data (example: credit default prediction)
# Assume: data with outcome 'default' (yes/no) and predictors

# 1. SPLIT DATA
set.seed(123)
data_split <- initial_split(credit_data, prop = 0.75, strata = default)
train_data <- training(data_split)
test_data <- testing(data_split)

# 2. CREATE RECIPE
credit_rec <- recipe(default ~ ., data = train_data) |>
  # Remove ID variables
  update_role(customer_id, new_role = "ID") |>

  # Handle missing data
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>

  # Feature engineering
  step_mutate(
    credit_utilization = balance / credit_limit,
    payment_ratio = total_payments / income
  ) |>

  # Handle categorical variables
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.05) |>
  step_dummy(all_nominal_predictors()) |>

  # Handle class imbalance (if needed)
  themis::step_smote(default, over_ratio = 0.8) |>

  # Remove problematic predictors
  step_zv(all_predictors()) |>
  step_corr(all_numeric_predictors(), threshold = 0.9) |>

  # Normalize
  step_normalize(all_numeric_predictors())

# 3. SPECIFY MODELS

# Logistic Regression with regularization
log_spec <- logistic_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet") |>
  set_mode("classification")

# Random Forest
rf_spec <- rand_forest(
  mtry = tune(),
  trees = 1000,
  min_n = tune()
) |>
  set_engine("ranger", importance = "impurity") |>
  set_mode("classification")

# XGBoost
xgb_spec <- boost_tree(
  trees = tune(),
  tree_depth = tune(),
  min_n = tune(),
  learn_rate = tune(),
  loss_reduction = tune()
) |>
  set_engine("xgboost") |>
  set_mode("classification")

# 4. CREATE WORKFLOWS
log_wflow <- workflow() |>
  add_recipe(credit_rec) |>
  add_model(log_spec)

rf_wflow <- workflow() |>
  add_recipe(credit_rec) |>
  add_model(rf_spec)

xgb_wflow <- workflow() |>
  add_recipe(credit_rec) |>
  add_model(xgb_spec)

# 5. SETUP RESAMPLING
set.seed(234)
cv_folds <- vfold_cv(train_data, v = 10, strata = default)

# 6. DEFINE METRICS
class_metrics <- metric_set(
  roc_auc,
  pr_auc,
  accuracy,
  f_meas,
  sensitivity,
  specificity
)

# 7. TUNE MODELS

# Logistic Regression (grid search)
log_grid <- grid_latin_hypercube(
  penalty(range = c(-5, 1)),
  mixture(range = c(0, 1)),
  size = 20
)

log_res <- log_wflow |>
  tune_grid(
    resamples = cv_folds,
    grid = log_grid,
    metrics = class_metrics,
    control = control_grid(save_pred = TRUE)
  )

# Random Forest (grid search)
rf_grid <- grid_latin_hypercube(
  mtry(range = c(5, 15)),
  min_n(range = c(2, 20)),
  size = 20
)

rf_res <- rf_wflow |>
  tune_grid(
    resamples = cv_folds,
    grid = rf_grid,
    metrics = class_metrics,
    control = control_grid(save_pred = TRUE)
  )

# XGBoost (Bayesian optimization)
xgb_params <- extract_parameter_set_dials(xgb_wflow) |>
  update(
    trees = trees(range = c(100, 2000)),
    tree_depth = tree_depth(range = c(3, 10)),
    learn_rate = learn_rate(range = c(-3, -0.5))
  )

xgb_res <- xgb_wflow |>
  tune_bayes(
    resamples = cv_folds,
    param_info = xgb_params,
    initial = 10,
    iter = 30,
    metrics = class_metrics,
    control = control_bayes(no_improve = 10, verbose = TRUE)
  )

# 8. EVALUATE AND COMPARE
show_best(log_res, metric = "roc_auc")
show_best(rf_res, metric = "roc_auc")
show_best(xgb_res, metric = "roc_auc")

# Visualize tuning results
autoplot(rf_res, metric = "roc_auc")
autoplot(xgb_res, type = "performance")

# Compare ROC curves
best_log <- select_best(log_res, metric = "roc_auc")
best_rf <- select_best(rf_res, metric = "roc_auc")
best_xgb <- select_best(xgb_res, metric = "roc_auc")

log_roc <- log_res |>
  collect_predictions(parameters = best_log) |>
  roc_curve(truth = default, .pred_yes) |>
  mutate(model = "Logistic Regression")

rf_roc <- rf_res |>
  collect_predictions(parameters = best_rf) |>
  roc_curve(truth = default, .pred_yes) |>
  mutate(model = "Random Forest")

xgb_roc <- xgb_res |>
  collect_predictions(parameters = best_xgb) |>
  roc_curve(truth = default, .pred_yes) |>
  mutate(model = "XGBoost")

bind_rows(log_roc, rf_roc, xgb_roc) |>
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
  geom_path(size = 1.2) +
  geom_abline(lty = 2, color = "gray50") +
  coord_equal() +
  theme_minimal() +
  labs(title = "ROC Curves Comparison")

# 9. FINALIZE BEST MODEL (assume RF wins)
final_wflow <- rf_wflow |>
  finalize_workflow(best_rf)

# 10. FINAL EVALUATION ON TEST SET
final_fit <- final_wflow |>
  last_fit(data_split, metrics = class_metrics)

# Test set metrics
collect_metrics(final_fit)

# Confusion matrix
final_fit |>
  collect_predictions() |>
  conf_mat(truth = default, estimate = .pred_class)

# Variable importance
final_fit |>
  extract_fit_parsnip() |>
  vip::vip(num_features = 20)

# 11. SAVE MODEL
final_model <- extract_workflow(final_fit)
saveRDS(final_model, "models/credit_default_model.rds")
```

---

## Regression Workflow

Complete workflow for regression with advanced preprocessing.

```r
library(tidymodels)
library(tidyverse)

# Load data (example: house price prediction)
data(ames, package = "modeldata")

# 1. SPLIT DATA
set.seed(123)
ames_split <- initial_split(ames, prop = 0.80, strata = Sale_Price)
ames_train <- training(ames_split)
ames_test <- testing(ames_split)

# 2. EXPLORATORY RECIPE (check distributions)
ames_rec <- recipe(Sale_Price ~ ., data = ames_train) |>
  # Update roles
  update_role(Id, new_role = "ID") |>

  # Handle missing data
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>

  # Feature engineering
  step_mutate(
    House_Age = Year_Sold - Year_Built,
    Remod_Age = Year_Sold - Year_Remod_Add,
    Has_Garage = if_else(Garage_Area > 0, "yes", "no"),
    Total_Bathrooms = Full_Bath + 0.5 * Half_Bath,
    Total_SF = Gr_Liv_Area + Total_Bsmt_SF
  ) |>

  # Log transform outcome (right-skewed)
  step_log(Sale_Price, base = 10) |>

  # Log transform skewed predictors
  step_log(Lot_Area, Gr_Liv_Area, Total_Bsmt_SF, base = 10, offset = 1) |>

  # Create interactions
  step_interact(terms = ~ Gr_Liv_Area:Overall_Qual) |>
  step_interact(terms = ~ Total_SF:Neighborhood) |>

  # Handle categorical variables
  step_novel(all_nominal_predictors()) |>
  step_unknown(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.01) |>
  step_dummy(all_nominal_predictors()) |>

  # Remove problematic predictors
  step_zv(all_predictors()) |>
  step_nzv(all_predictors(), freq_cut = 95/5) |>

  # Normalize
  step_normalize(all_numeric_predictors()) |>

  # Remove highly correlated predictors
  step_corr(all_numeric_predictors(), threshold = 0.9)

# 3. SPECIFY MODELS

# Linear regression with elastic net
glmnet_spec <- linear_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet")

# Random Forest
rf_spec <- rand_forest(
  mtry = tune(),
  trees = 1000,
  min_n = tune()
) |>
  set_engine("ranger", importance = "impurity") |>
  set_mode("regression")

# XGBoost
xgb_spec <- boost_tree(
  trees = tune(),
  tree_depth = tune(),
  min_n = tune(),
  learn_rate = tune()
) |>
  set_engine("xgboost") |>
  set_mode("regression")

# Support Vector Machine
svm_spec <- svm_rbf(cost = tune(), rbf_sigma = tune()) |>
  set_engine("kernlab") |>
  set_mode("regression")

# 4. CREATE WORKFLOW SET (compare all at once)
wf_set <- workflow_set(
  preproc = list(full = ames_rec),
  models = list(
    glmnet = glmnet_spec,
    rf = rf_spec,
    xgb = xgb_spec,
    svm = svm_spec
  )
)

# 5. SETUP RESAMPLING
set.seed(234)
ames_folds <- vfold_cv(ames_train, v = 10, strata = Sale_Price)

# 6. DEFINE METRICS
reg_metrics <- metric_set(rmse, rsq, mae, mape)

# 7. TUNE ALL MODELS
wf_results <- wf_set |>
  workflow_map(
    fn = "tune_grid",
    resamples = ames_folds,
    grid = 20,
    metrics = reg_metrics,
    verbose = TRUE,
    control = control_grid(save_pred = TRUE)
  )

# 8. EVALUATE AND COMPARE
rank_results(wf_results, rank_metric = "rmse", select_best = TRUE)

# Visualize all models
autoplot(wf_results, metric = "rmse")

# Best from each model
wf_results |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  group_by(wflow_id) |>
  slice_min(mean, n = 1)

# 9. EXTRACT BEST OVERALL MODEL
best_model_id <- wf_results |>
  rank_results(rank_metric = "rmse", select_best = TRUE) |>
  slice(1) |>
  pull(wflow_id)

best_result <- wf_results |>
  extract_workflow_set_result(best_model_id)

best_params <- select_best(best_result, metric = "rmse")

# 10. FINALIZE AND TEST
final_wflow <- wf_results |>
  extract_workflow(best_model_id) |>
  finalize_workflow(best_params)

final_fit <- final_wflow |>
  last_fit(ames_split, metrics = reg_metrics)

# Test metrics
collect_metrics(final_fit)

# Residual plots
augment(extract_workflow(final_fit), new_data = ames_test) |>
  mutate(residuals = Sale_Price - .pred) |>
  ggplot(aes(x = .pred, y = residuals)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, color = "red", linetype = 2) +
  theme_minimal() +
  labs(title = "Residual Plot", x = "Predicted", y = "Residuals")

# 11. SAVE MODEL
final_model <- extract_workflow(final_fit)
saveRDS(final_model, "models/ames_price_model.rds")
```

---

## Multiclass Classification

Template for multiclass classification problems.

```r
library(tidymodels)
library(tidyverse)

# Load data (example: iris species classification)
data(iris)

# 1. SPLIT DATA
set.seed(123)
iris_split <- initial_split(iris, prop = 0.75, strata = Species)
iris_train <- training(iris_split)
iris_test <- testing(iris_split)

# 2. CREATE RECIPE
iris_rec <- recipe(Species ~ ., data = iris_train) |>
  # Feature engineering
  step_mutate(
    Petal_Ratio = Petal.Length / Petal.Width,
    Sepal_Ratio = Sepal.Length / Sepal.Width
  ) |>

  # Normalize
  step_normalize(all_numeric_predictors())

# 3. SPECIFY MODELS

# Multinomial logistic regression
multinom_spec <- multinom_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet") |>
  set_mode("classification")

# Random Forest
rf_spec <- rand_forest(mtry = tune(), min_n = tune()) |>
  set_engine("ranger") |>
  set_mode("classification")

# Neural Network
nn_spec <- mlp(hidden_units = tune(), penalty = tune(), epochs = 100) |>
  set_engine("nnet") |>
  set_mode("classification")

# 4. CREATE WORKFLOWS
multinom_wflow <- workflow() |>
  add_recipe(iris_rec) |>
  add_model(multinom_spec)

rf_wflow <- workflow() |>
  add_recipe(iris_rec) |>
  add_model(rf_spec)

nn_wflow <- workflow() |>
  add_recipe(iris_rec) |>
  add_model(nn_spec)

# 5. SETUP RESAMPLING
set.seed(234)
iris_folds <- vfold_cv(iris_train, v = 10, strata = Species)

# 6. DEFINE METRICS (multiclass-specific)
multi_metrics <- metric_set(
  accuracy,
  roc_auc,        # Uses Hand-Till method for multiclass
  mn_log_loss,
  bal_accuracy
)

# 7. TUNE MODELS
multinom_res <- multinom_wflow |>
  tune_grid(
    resamples = iris_folds,
    grid = 15,
    metrics = multi_metrics
  )

rf_res <- rf_wflow |>
  tune_grid(
    resamples = iris_folds,
    grid = 15,
    metrics = multi_metrics
  )

nn_res <- nn_wflow |>
  tune_grid(
    resamples = iris_folds,
    grid = 15,
    metrics = multi_metrics
  )

# 8. COMPARE MODELS
show_best(multinom_res, metric = "roc_auc")
show_best(rf_res, metric = "roc_auc")
show_best(nn_res, metric = "roc_auc")

# 9. SELECT BEST
best_rf <- select_best(rf_res, metric = "roc_auc")

final_wflow <- rf_wflow |>
  finalize_workflow(best_rf)

# 10. FINAL EVALUATION
final_fit <- final_wflow |>
  last_fit(iris_split, metrics = multi_metrics)

collect_metrics(final_fit)

# Multiclass confusion matrix
final_fit |>
  collect_predictions() |>
  conf_mat(truth = Species, estimate = .pred_class)

# Per-class ROC curves
final_fit |>
  collect_predictions() |>
  roc_curve(truth = Species, .pred_setosa:.pred_virginica) |>
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = .level)) +
  geom_path(size = 1.2) +
  geom_abline(lty = 2, color = "gray50") +
  coord_equal() +
  theme_minimal() +
  labs(title = "Per-Class ROC Curves", color = "Class")

# 11. SAVE MODEL
final_model <- extract_workflow(final_fit)
saveRDS(final_model, "models/iris_classifier.rds")
```

---

## Time Series Forecasting

Template for time series with rolling origin resampling.

```r
library(tidymodels)
library(tidyverse)
library(timetk)

# Load time series data
# Assume: time_data with columns `date`, `value`, and predictors

# 1. CREATE TIME-BASED FEATURES
time_data <- time_data |>
  tk_augment_timeseries_signature(date) |>
  select(-contains("iso"), -contains("xts"), -contains("hour"),
         -contains("minute"), -contains("second"), -contains("am.pm"))

# 2. TIME-BASED SPLIT (no shuffling!)
time_split <- initial_time_split(time_data, prop = 0.8)
time_train <- training(time_split)
time_test <- testing(time_split)

# 3. ROLLING ORIGIN RESAMPLING
time_folds <- rolling_origin(
  time_train,
  initial = 365,       # Use 1 year for training
  assess = 30,         # Predict 30 days ahead
  skip = 29,           # Advance by 1 day
  cumulative = TRUE    # Use all previous data
)

# 4. CREATE RECIPE
time_rec <- recipe(value ~ ., data = time_train) |>
  # Update role for date
  update_role(date, new_role = "ID") |>

  # Lag features
  step_lag(value, lag = 1:7) |>
  step_lag(value, lag = c(30, 60, 90, 365)) |>

  # Rolling statistics
  step_slidify(value, period = 7, .f = mean, prefix = "ma_7_") |>
  step_slidify(value, period = 30, .f = mean, prefix = "ma_30_") |>
  step_slidify(value, period = 7, .f = sd, prefix = "sd_7_") |>

  # Handle missing from lags
  step_naomit(all_predictors()) |>

  # Encode cyclical features
  step_mutate(
    month_sin = sin(2 * pi * date_month / 12),
    month_cos = cos(2 * pi * date_month / 12),
    week_sin = sin(2 * pi * date_week / 52),
    week_cos = cos(2 * pi * date_week / 52)
  ) |>

  # Handle categorical
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors()) |>

  # Normalize
  step_normalize(all_numeric_predictors())

# 5. SPECIFY MODELS

# Prophet-style linear model
prophet_spec <- linear_reg() |>
  set_engine("lm")

# Random Forest for time series
rf_spec <- rand_forest(mtry = tune(), trees = 1000, min_n = tune()) |>
  set_engine("ranger") |>
  set_mode("regression")

# XGBoost
xgb_spec <- boost_tree(
  trees = tune(),
  tree_depth = tune(),
  learn_rate = tune()
) |>
  set_engine("xgboost") |>
  set_mode("regression")

# 6. CREATE WORKFLOWS
prophet_wflow <- workflow() |>
  add_recipe(time_rec) |>
  add_model(prophet_spec)

rf_wflow <- workflow() |>
  add_recipe(time_rec) |>
  add_model(rf_spec)

xgb_wflow <- workflow() |>
  add_recipe(time_rec) |>
  add_model(xgb_spec)

# 7. TUNE ON TIME FOLDS
ts_metrics <- metric_set(rmse, mae, mape, rsq)

# Prophet (no tuning)
prophet_res <- prophet_wflow |>
  fit_resamples(
    resamples = time_folds,
    metrics = ts_metrics
  )

# Random Forest
rf_res <- rf_wflow |>
  tune_grid(
    resamples = time_folds,
    grid = 15,
    metrics = ts_metrics
  )

# XGBoost
xgb_res <- xgb_wflow |>
  tune_grid(
    resamples = time_folds,
    grid = 15,
    metrics = ts_metrics
  )

# 8. COMPARE MODELS
collect_metrics(prophet_res)
show_best(rf_res, metric = "rmse")
show_best(xgb_res, metric = "rmse")

# 9. SELECT BEST
best_model <- select_best(xgb_res, metric = "rmse")

final_wflow <- xgb_wflow |>
  finalize_workflow(best_model)

# 10. FINAL FIT AND FORECAST
final_fit <- final_wflow |>
  last_fit(time_split, metrics = ts_metrics)

# Visualize forecast
forecast_plot <- final_fit |>
  collect_predictions() |>
  bind_cols(select(time_test, date)) |>
  ggplot(aes(x = date)) +
  geom_line(aes(y = value), color = "black") +
  geom_line(aes(y = .pred), color = "blue", linetype = 2) +
  theme_minimal() +
  labs(title = "Actual vs Forecast", y = "Value")

# 11. SAVE MODEL
final_model <- extract_workflow(final_fit)
saveRDS(final_model, "models/timeseries_model.rds")
```

---

## Model Comparison Framework

Systematic framework for comparing multiple models.

```r
library(tidymodels)
library(tidyverse)

# 1. SETUP DATA
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train_data <- training(data_split)
test_data <- testing(data_split)

# 2. CREATE MULTIPLE RECIPES

# Basic recipe
basic_rec <- recipe(outcome ~ ., data = train_data) |>
  step_impute_median(all_numeric_predictors()) |>
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# Advanced recipe with interactions
advanced_rec <- recipe(outcome ~ ., data = train_data) |>
  step_impute_knn(all_numeric_predictors(), neighbors = 5) |>
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_interact(terms = ~ all_predictors():all_predictors()) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# PCA recipe
pca_rec <- recipe(outcome ~ ., data = train_data) |>
  step_impute_median(all_numeric_predictors()) |>
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  step_pca(all_numeric_predictors(), num_comp = tune())

# 3. SPECIFY MODELS
log_spec <- logistic_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet")

rf_spec <- rand_forest(mtry = tune(), min_n = tune()) |>
  set_engine("ranger") |>
  set_mode("classification")

xgb_spec <- boost_tree(trees = tune(), learn_rate = tune()) |>
  set_engine("xgboost") |>
  set_mode("classification")

svm_spec <- svm_rbf(cost = tune(), rbf_sigma = tune()) |>
  set_engine("kernlab") |>
  set_mode("classification")

# 4. CREATE WORKFLOW SET (all combinations)
all_workflows <- workflow_set(
  preproc = list(
    basic = basic_rec,
    advanced = advanced_rec,
    pca = pca_rec
  ),
  models = list(
    logistic = log_spec,
    rf = rf_spec,
    xgb = xgb_spec,
    svm = svm_spec
  ),
  cross = TRUE  # All combinations: 3 recipes × 4 models = 12 workflows
)

# 5. SETUP RESAMPLING
set.seed(234)
cv_folds <- vfold_cv(train_data, v = 5, strata = outcome)  # Use v=5 for speed

# 6. TUNE ALL WORKFLOWS
all_results <- all_workflows |>
  workflow_map(
    fn = "tune_grid",
    resamples = cv_folds,
    grid = 10,  # Small grid for speed
    metrics = metric_set(roc_auc, accuracy),
    verbose = TRUE,
    seed = 345,
    control = control_grid(save_pred = TRUE, parallel_over = "everything")
  )

# 7. COMPARE ALL MODELS

# Ranking
rank_results(all_results, rank_metric = "roc_auc", select_best = TRUE) |>
  filter(.metric == "roc_auc")

# Visualization
autoplot(all_results, metric = "roc_auc") +
  theme_minimal() +
  labs(title = "Model Comparison: ROC-AUC Across All Workflows")

# Best configuration from each workflow
all_results |>
  collect_metrics() |>
  filter(.metric == "roc_auc") |>
  group_by(wflow_id) |>
  slice_max(mean, n = 1) |>
  arrange(desc(mean))

# 8. STATISTICAL COMPARISON (Bayesian approach)
library(tidyposterior)
library(rstanarm)

# Extract best results for each workflow
best_results <- all_results |>
  collect_metrics() |>
  filter(.metric == "roc_auc") |>
  group_by(wflow_id) |>
  slice_max(mean, n = 1)

# Fit Bayesian model for comparison
roc_model <- perf_mod(
  all_results,
  metric = "roc_auc",
  iter = 5000,
  chains = 4,
  seed = 456
)

# Posterior distributions
autoplot(roc_model, type = "intervals")

# Pairwise comparisons
contrast_models(roc_model) |>
  summary(size = 0.02)  # Practical difference threshold

# 9. SELECT FINAL MODEL
best_workflow_id <- rank_results(all_results, rank_metric = "roc_auc") |>
  slice(1) |>
  pull(wflow_id)

best_result <- all_results |>
  extract_workflow_set_result(best_workflow_id)

best_params <- select_best(best_result, metric = "roc_auc")

# 10. FINALIZE AND TEST
final_wflow <- all_results |>
  extract_workflow(best_workflow_id) |>
  finalize_workflow(best_params)

final_fit <- final_wflow |>
  last_fit(data_split)

collect_metrics(final_fit)

# 11. SAVE MODEL
final_model <- extract_workflow(final_fit)
saveRDS(final_model, "models/best_comparison_model.rds")
```

---

## Deployment Pipeline

Complete pipeline from training to production deployment.

```r
library(tidymodels)
library(tidyverse)
library(pins)
library(vetiver)
library(plumber)

# === STEP 1: TRAIN AND SAVE MODEL ===

# (Assume we've already trained a model and have final_fit)

# Extract workflow
trained_workflow <- extract_workflow(final_fit)

# Save with metadata
model_metadata <- list(
  model_type = "Random Forest Classifier",
  trained_date = Sys.Date(),
  metrics = collect_metrics(final_fit),
  feature_names = names(training(data_split)),
  target_name = "outcome",
  preprocessing_steps = c("imputation", "normalization", "dummy_encoding")
)

saveRDS(
  list(workflow = trained_workflow, metadata = model_metadata),
  "models/production_model.rds"
)

# === STEP 2: CREATE VETIVER MODEL FOR DEPLOYMENT ===

# Create vetiver model object
v_model <- vetiver_model(
  trained_workflow,
  model_name = "credit_risk_model",
  versioned = TRUE,
  metadata = model_metadata
)

# Create model board (storage backend)
model_board <- board_folder("models/vetiver", versioned = TRUE)

# Pin model to board (version control)
vetiver_pin_write(model_board, v_model)

# === STEP 3: CREATE PREDICTION API ===

# Generate API
pr <- plumber::pr() |>
  vetiver_api(v_model)

# Add custom health check endpoint
pr <- pr |>
  pr_get("/health", function() {
    list(status = "healthy", timestamp = Sys.time())
  })

# Add custom info endpoint
pr <- pr |>
  pr_get("/model-info", function() {
    list(
      model_name = v_model$model_name,
      version = v_model$versioned,
      metadata = v_model$metadata
    )
  })

# Run API locally for testing
# pr |> pr_run(port = 8000)

# === STEP 4: CREATE DOCKER DEPLOYMENT ===

# Write Dockerfile
vetiver_write_docker(v_model, path = "deployment", port = 8000)

# Write plumber.R for Docker
vetiver_write_plumber(model_board, "credit_risk_model", file = "deployment/plumber.R")

# === STEP 5: BATCH PREDICTION FUNCTION ===

# Load model from pin
loaded_model <- vetiver_pin_read(model_board, "credit_risk_model")

# Batch prediction function
batch_predict <- function(new_data, model_path = "models/production_model.rds") {

  # Load model
  model_obj <- readRDS(model_path)
  model <- model_obj$workflow

  # Validate input
  required_cols <- model_obj$metadata$feature_names
  missing_cols <- setdiff(required_cols, names(new_data))

  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # Generate predictions
  preds <- predict(model, new_data = new_data, type = "prob") |>
    bind_cols(predict(model, new_data = new_data, type = "class")) |>
    bind_cols(select(new_data, any_of("id"))) |>
    mutate(
      prediction_date = Sys.Date(),
      model_version = model_obj$metadata$trained_date
    )

  return(preds)
}

# === STEP 6: MODEL MONITORING FUNCTION ===

monitor_model <- function(predictions, actuals, model_metadata) {

  # Calculate metrics on new data
  current_metrics <- predictions |>
    bind_cols(actuals = actuals) |>
    metrics(truth = actuals, estimate = .pred_class, .pred_yes)

  # Compare to training metrics
  training_metrics <- model_metadata$metrics

  # Detect drift
  metric_comparison <- current_metrics |>
    left_join(
      training_metrics |> select(.metric, training_estimate = .estimate),
      by = ".metric"
    ) |>
    mutate(
      pct_change = 100 * (.estimate - training_estimate) / training_estimate,
      alert = abs(pct_change) > 10  # Alert if >10% change
    )

  # Feature drift detection (simple statistical test)
  feature_drift <- map(names(predictions), function(col) {
    if (is.numeric(predictions[[col]])) {
      # KS test for distribution shift
      ks_result <- ks.test(predictions[[col]], model_metadata$training_data[[col]])

      tibble(
        feature = col,
        ks_statistic = ks_result$statistic,
        p_value = ks_result$p.value,
        drift_detected = ks_result$p.value < 0.05
      )
    }
  }) |> list_rbind()

  list(
    metric_comparison = metric_comparison,
    feature_drift = feature_drift,
    timestamp = Sys.time()
  )
}

# === STEP 7: EXAMPLE API CLIENT ===

# Call API endpoint
call_prediction_api <- function(new_data, url = "http://localhost:8000/predict") {

  library(httr)
  library(jsonlite)

  # Prepare data
  json_data <- toJSON(new_data, auto_unbox = TRUE)

  # Make request
  response <- POST(
    url,
    body = json_data,
    encode = "json",
    content_type_json()
  )

  # Parse response
  if (status_code(response) == 200) {
    predictions <- content(response, as = "parsed")
    return(predictions)
  } else {
    stop("API request failed: ", content(response, as = "text"))
  }
}

# === STEP 8: RETRAINING PIPELINE ===

retrain_model <- function(new_data, old_model_path) {

  # Load previous model configuration
  old_model <- readRDS(old_model_path)

  # Use same workflow structure
  # (In practice, extract recipe and model spec from old_model)

  # Retrain
  new_split <- initial_split(new_data, prop = 0.8, strata = outcome)
  new_fit <- old_model$workflow |>
    fit(training(new_split))

  # Evaluate
  new_metrics <- new_fit |>
    augment(testing(new_split)) |>
    metrics(truth = outcome, estimate = .pred_class, .pred_yes)

  # Compare performance
  old_metrics <- old_model$metadata$metrics

  # Decide whether to deploy new model
  improvement <- new_metrics |>
    filter(.metric == "roc_auc") |>
    pull(.estimate) - old_metrics |>
    filter(.metric == "roc_auc") |>
    pull(.estimate)

  if (improvement > 0.01) {  # Deploy if >1% improvement
    message("New model is better. Deploying...")

    new_metadata <- list(
      model_type = old_model$metadata$model_type,
      trained_date = Sys.Date(),
      metrics = new_metrics,
      improvement_over_previous = improvement
    )

    saveRDS(
      list(workflow = new_fit, metadata = new_metadata),
      old_model_path
    )

    return(TRUE)
  } else {
    message("Old model is still better. Keeping current model.")
    return(FALSE)
  }
}
```

---

## Usage Examples

### Binary Classification
```r
# Load template code
source("templates/binary_classification.R")

# Customize for your data
credit_data <- read_csv("data/credit.csv")
# ... run workflow ...
```

### Regression
```r
# Load template
source("templates/regression.R")

# Use your data
ames <- read_csv("data/houses.csv")
# ... run workflow ...
```

### Deployment
```r
# Load deployment template
source("templates/deployment.R")

# Deploy your model
vetiver_deploy_rsconnect(
  board = model_board,
  name = "credit_risk_model",
  version = "latest"
)
```
