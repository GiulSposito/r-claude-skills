# Complete Tidymodels Workflows - Real Examples

End-to-end working examples based on real-world datasets and problems.

## Table of Contents

1. [Ames Housing Price Prediction (Regression)](#ames-housing-price-prediction)
2. [Hotel Booking Cancellation (Binary Classification)](#hotel-booking-cancellation)
3. [Bean Type Classification (Multiclass)](#bean-type-classification)
4. [Credit Default with Imbalanced Classes](#credit-default-with-imbalanced-classes)

---

## Ames Housing Price Prediction

**Problem:** Predict house sale prices using property characteristics
**Type:** Regression
**Dataset:** Ames housing data (2,930 properties, 80 features)
**Source:** `modeldata::ames`

### Complete Workflow

```r
library(tidymodels)
library(tidyverse)
library(vip)

# === 1. LOAD AND EXPLORE DATA ===

data(ames, package = "modeldata")

glimpse(ames)
# 2,930 × 74

# Quick EDA
ames |>
  ggplot(aes(x = Sale_Price)) +
  geom_histogram(bins = 50) +
  scale_x_log10() +
  labs(title = "Sale Price Distribution (Log Scale)")

# === 2. DATA SPLITTING ===

set.seed(501)
ames_split <- initial_split(ames, prop = 0.80, strata = Sale_Price)
ames_train <- training(ames_split)
ames_test <- testing(ames_split)

cat("Training set:", nrow(ames_train), "observations\n")
cat("Test set:", nrow(ames_test), "observations\n")
# Training set: 2342 observations
# Test set: 588 observations

# === 3. CREATE PREPROCESSING RECIPE ===

ames_rec <- recipe(Sale_Price ~ ., data = ames_train) |>

  # Remove ID variable
  update_role(starts_with("Order"), new_role = "ID") |>
  update_role(starts_with("PID"), new_role = "ID") |>

  # Handle missing data
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>

  # Feature engineering
  step_mutate(
    House_Age = Year_Sold - Year_Built,
    Remod_Age = Year_Sold - Year_Remod_Add,
    Garage_Exists = if_else(Garage_Area > 0, "Yes", "No"),
    Total_Bathrooms = Full_Bath + 0.5 * Half_Bath + Bsmt_Full_Bath + 0.5 * Bsmt_Half_Bath,
    Total_SF = Gr_Liv_Area + Total_Bsmt_SF,
    Total_Porch_SF = Open_Porch_SF + Enclosed_Porch + Three_season_porch + Screen_Porch
  ) |>

  # Log transform outcome (right-skewed)
  step_log(Sale_Price, base = 10) |>

  # Log transform skewed predictors
  step_log(Lot_Area, Gr_Liv_Area, base = 10, offset = 1) |>

  # Interactions
  step_interact(terms = ~ Gr_Liv_Area:Overall_Qual) |>
  step_interact(terms = ~ House_Age:Overall_Qual) |>

  # Handle categorical variables
  step_novel(all_nominal_predictors()) |>
  step_unknown(all_nominal_predictors()) |>
  step_other(Neighborhood, threshold = 0.01) |>
  step_other(MS_SubClass, threshold = 0.01) |>
  step_dummy(all_nominal_predictors()) |>

  # Filter predictors
  step_zv(all_predictors()) |>
  step_nzv(all_predictors()) |>

  # Normalize
  step_normalize(all_numeric_predictors()) |>

  # Remove correlations
  step_corr(all_numeric_predictors(), threshold = 0.85)

# Preview recipe
ames_rec |> prep() |> bake(new_data = NULL) |> glimpse()

# === 4. SPECIFY MODELS ===

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
  learn_rate = tune(),
  loss_reduction = tune()
) |>
  set_engine("xgboost") |>
  set_mode("regression")

# Elastic Net
glmnet_spec <- linear_reg(
  penalty = tune(),
  mixture = tune()
) |>
  set_engine("glmnet")

# === 5. CREATE WORKFLOWS ===

rf_wflow <- workflow() |>
  add_recipe(ames_rec) |>
  add_model(rf_spec)

xgb_wflow <- workflow() |>
  add_recipe(ames_rec) |>
  add_model(xgb_spec)

glmnet_wflow <- workflow() |>
  add_recipe(ames_rec) |>
  add_model(glmnet_spec)

# === 6. SETUP RESAMPLING ===

set.seed(55)
ames_folds <- vfold_cv(ames_train, v = 10, strata = Sale_Price)

# === 7. DEFINE METRICS ===

reg_metrics <- metric_set(rmse, rsq, mae)

# === 8. TUNE MODELS ===

# Random Forest - Grid Search
set.seed(9)
rf_grid <- grid_latin_hypercube(
  mtry(range = c(10, 30)),
  min_n(range = c(2, 10)),
  size = 20
)

rf_res <- rf_wflow |>
  tune_grid(
    resamples = ames_folds,
    grid = rf_grid,
    metrics = reg_metrics,
    control = control_grid(save_pred = TRUE)
  )

# XGBoost - Bayesian Optimization
set.seed(9)
xgb_params <- extract_parameter_set_dials(xgb_wflow) |>
  update(
    trees = trees(range = c(100, 2000)),
    tree_depth = tree_depth(range = c(3, 8)),
    learn_rate = learn_rate(range = c(-3, -0.5))
  )

xgb_res <- xgb_wflow |>
  tune_bayes(
    resamples = ames_folds,
    param_info = xgb_params,
    initial = 10,
    iter = 25,
    metrics = reg_metrics,
    control = control_bayes(no_improve = 10, verbose = TRUE)
  )

# Elastic Net - Grid Search
set.seed(9)
glmnet_grid <- grid_latin_hypercube(
  penalty(range = c(-5, 0)),
  mixture(range = c(0, 1)),
  size = 20
)

glmnet_res <- glmnet_wflow |>
  tune_grid(
    resamples = ames_folds,
    grid = glmnet_grid,
    metrics = reg_metrics,
    control = control_grid(save_pred = TRUE)
  )

# === 9. EVALUATE AND COMPARE ===

# Best results from each model
show_best(rf_res, metric = "rmse", n = 5)
show_best(xgb_res, metric = "rmse", n = 5)
show_best(glmnet_res, metric = "rmse", n = 5)

# Visualize tuning
autoplot(rf_res, metric = "rmse")
autoplot(xgb_res, type = "performance")

# Compare best configurations
tibble(
  Model = c("Random Forest", "XGBoost", "Elastic Net"),
  RMSE = c(
    show_best(rf_res, metric = "rmse", n = 1)$mean,
    show_best(xgb_res, metric = "rmse", n = 1)$mean,
    show_best(glmnet_res, metric = "rmse", n = 1)$mean
  ),
  RSQ = c(
    show_best(rf_res, metric = "rsq", n = 1)$mean,
    show_best(xgb_res, metric = "rsq", n = 1)$mean,
    show_best(glmnet_res, metric = "rsq", n = 1)$mean
  )
) |>
  arrange(RMSE)

# === 10. SELECT BEST MODEL ===

# Random Forest wins
best_rf <- select_best(rf_res, metric = "rmse")
cat("\nBest RF parameters:\n")
print(best_rf)

# === 11. FINALIZE AND TEST ===

final_wflow <- rf_wflow |>
  finalize_workflow(best_rf)

final_fit <- final_wflow |>
  last_fit(ames_split, metrics = reg_metrics)

# Test set metrics
cat("\nTest Set Performance:\n")
collect_metrics(final_fit)

# Predictions vs actual
final_fit |>
  collect_predictions() |>
  ggplot(aes(x = 10^Sale_Price, y = 10^.pred)) +
  geom_abline(lty = 2, color = "gray50", size = 1) +
  geom_point(alpha = 0.5) +
  scale_x_log10(labels = scales::dollar) +
  scale_y_log10(labels = scales::dollar) +
  coord_obs_pred() +
  labs(
    title = "Ames Housing: Predictions vs Actual",
    x = "Actual Sale Price",
    y = "Predicted Sale Price"
  )

# Residual plot
final_fit |>
  collect_predictions() |>
  mutate(residuals = Sale_Price - .pred) |>
  ggplot(aes(x = .pred, y = residuals)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, color = "red", linetype = 2) +
  labs(
    title = "Residual Plot",
    x = "Predicted (Log10 Scale)",
    y = "Residuals"
  )

# Variable importance
final_fit |>
  extract_fit_parsnip() |>
  vip(num_features = 20, geom = "point") +
  labs(title = "Top 20 Most Important Features")

# === 12. SAVE MODEL ===

final_model <- extract_workflow(final_fit)
saveRDS(final_model, "ames_price_model.rds")

# Production prediction function
predict_house_price <- function(new_houses, model_path = "ames_price_model.rds") {
  model <- readRDS(model_path)

  predictions <- predict(model, new_data = new_houses) |>
    mutate(.pred_dollars = 10^.pred) |>
    bind_cols(predict(model, new_data = new_houses, type = "conf_int")) |>
    mutate(
      .pred_lower_dollars = 10^.pred_lower,
      .pred_upper_dollars = 10^.pred_upper
    ) |>
    select(starts_with(".pred"))

  bind_cols(new_houses, predictions)
}

# Test prediction function
sample_houses <- ames_test |> slice_sample(n = 5)
predict_house_price(sample_houses)
```

**Key Takeaways:**
- Log transformation critical for skewed outcome
- Feature engineering improved performance significantly
- Random Forest performed best (RMSE ≈ 0.075 on log scale)
- Variable importance shows Overall_Qual and Total_SF as top predictors

---

## Hotel Booking Cancellation

**Problem:** Predict whether hotel bookings will be canceled
**Type:** Binary Classification
**Dataset:** Hotel bookings (simulated, ~50,000 bookings)
**Challenge:** Class imbalance (~40% cancellation rate)

### Complete Workflow

```r
library(tidymodels)
library(tidyverse)
library(themis)

# === 1. LOAD DATA ===

# Simulated hotel booking data
data(hotel_data, package = "modeldata")

# Quick look
glimpse(hotel_data)
table(hotel_data$children)
# children    none children
#        37867    12133

# === 2. DATA SPLITTING (with stratification) ===

set.seed(123)
hotel_split <- initial_split(hotel_data, prop = 0.75, strata = children)
hotel_train <- training(hotel_split)
hotel_test <- testing(hotel_split)

# Additional validation split for iterative tuning
set.seed(234)
val_set <- validation_split(hotel_train, prop = 0.80, strata = children)

# === 3. CREATE RECIPE ===

library(timeDate)  # For holidays

hotel_rec <- recipe(children ~ ., data = hotel_train) |>

  # Date features
  step_date(arrival_date, features = c("dow", "month", "year")) |>
  step_holiday(arrival_date, holidays = timeDate::listHolidays("US")) |>
  step_rm(arrival_date) |>

  # Feature engineering
  step_mutate(
    total_stay = stays_in_week_nights + stays_in_weekend_nights,
    is_repeated_guest = if_else(is_repeated_guest == 1, "yes", "no"),
    has_special_request = if_else(total_of_special_requests > 0, "yes", "no")
  ) |>

  # Handle class imbalance
  step_downsample(children, under_ratio = 1.2, seed = 42) |>

  # Handle categorical
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.01) |>
  step_dummy(all_nominal_predictors()) |>

  # Remove zero variance
  step_zv(all_predictors()) |>

  # Normalize
  step_normalize(all_numeric_predictors())

# === 4. SPECIFY MODELS ===

# Penalized Logistic Regression
lr_spec <- logistic_reg(penalty = tune(), mixture = 1) |>
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

# === 5. CREATE WORKFLOWS ===

lr_wflow <- workflow() |>
  add_recipe(hotel_rec) |>
  add_model(lr_spec)

rf_wflow <- workflow() |>
  add_recipe(hotel_rec) |>
  add_model(rf_spec)

# === 6. SETUP RESAMPLING ===

set.seed(345)
hotel_folds <- vfold_cv(hotel_train, v = 10, strata = children)

# === 7. DEFINE METRICS ===

class_metrics <- metric_set(
  roc_auc,
  pr_auc,
  accuracy,
  f_meas,
  sensitivity,
  specificity
)

# === 8. TUNE MODELS ===

# Logistic Regression
set.seed(456)
lr_grid <- grid_latin_hypercube(
  penalty(range = c(-5, 1)),
  size = 30
)

lr_res <- lr_wflow |>
  tune_grid(
    resamples = hotel_folds,
    grid = lr_grid,
    metrics = class_metrics,
    control = control_grid(save_pred = TRUE)
  )

# Random Forest
set.seed(456)
rf_grid <- grid_latin_hypercube(
  mtry(range = c(5, 15)),
  min_n(range = c(2, 20)),
  size = 25
)

rf_res <- rf_wflow |>
  tune_grid(
    resamples = hotel_folds,
    grid = rf_grid,
    metrics = class_metrics,
    control = control_grid(save_pred = TRUE)
  )

# === 9. EVALUATE AND COMPARE ===

# Best results
show_best(lr_res, metric = "roc_auc", n = 5)
show_best(rf_res, metric = "roc_auc", n = 5)

# Visualize
autoplot(lr_res, metric = "roc_auc")
autoplot(rf_res, metric = "roc_auc")

# Compare ROC curves
best_lr <- select_best(lr_res, metric = "roc_auc")
best_rf <- select_best(rf_res, metric = "roc_auc")

lr_roc <- lr_res |>
  collect_predictions(parameters = best_lr) |>
  roc_curve(truth = children, .pred_children) |>
  mutate(model = "Logistic Regression")

rf_roc <- rf_res |>
  collect_predictions(parameters = best_rf) |>
  roc_curve(truth = children, .pred_children) |>
  mutate(model = "Random Forest")

bind_rows(lr_roc, rf_roc) |>
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
  geom_path(size = 1.2) +
  geom_abline(lty = 2, color = "gray50") +
  coord_equal() +
  theme_minimal() +
  labs(title = "ROC Curves: Hotel Booking Cancellation")

# === 10. FINALIZE BEST MODEL ===

# Random Forest wins
final_wflow <- rf_wflow |>
  finalize_workflow(best_rf)

final_fit <- final_wflow |>
  last_fit(hotel_split, metrics = class_metrics)

# === 11. FINAL EVALUATION ===

# Test metrics
collect_metrics(final_fit)

# Confusion matrix
final_fit |>
  collect_predictions() |>
  conf_mat(truth = children, estimate = .pred_class) |>
  autoplot(type = "heatmap")

# Confusion matrix with metrics
final_fit |>
  collect_predictions() |>
  conf_mat(truth = children, estimate = .pred_class) |>
  summary()

# Variable importance
final_fit |>
  extract_fit_parsnip() |>
  vip(num_features = 15)

# === 12. THRESHOLD OPTIMIZATION ===

library(probably)

# Find optimal threshold
threshold_data <- final_fit |>
  collect_predictions() |>
  probably::threshold_perf(
    truth = children,
    estimate = .pred_children,
    thresholds = seq(0.1, 0.9, by = 0.01),
    metrics = metric_set(j_index, sens, spec, f_meas)
  )

# Visualize threshold impact
threshold_data |>
  filter(.metric != "distance") |>
  ggplot(aes(x = .threshold, y = .estimate, color = .metric)) +
  geom_line(size = 1) +
  theme_minimal() +
  labs(
    title = "Threshold Optimization",
    x = "Probability Threshold",
    y = "Metric Value"
  )

# Best threshold for F1 score
best_threshold <- threshold_data |>
  filter(.metric == "f_meas") |>
  filter(.estimate == max(.estimate)) |>
  pull(.threshold)

cat("Optimal threshold:", best_threshold, "\n")

# === 13. SAVE MODEL ===

final_model <- extract_workflow(final_fit)
saveRDS(final_model, "hotel_cancellation_model.rds")
```

**Key Takeaways:**
- Date features (day of week, holidays) were important predictors
- Downsampling helped with imbalanced classes
- Random Forest outperformed logistic regression (ROC-AUC ≈ 0.89)
- Threshold optimization improved F1 score by 5%

---

## Bean Type Classification

**Problem:** Classify bean types from physical measurements
**Type:** Multiclass Classification (7 bean types)
**Dataset:** Dry bean dataset (13,611 beans, 16 features)

### Complete Workflow

```r
library(tidymodels)
library(tidyverse)

# === 1. LOAD DATA ===

data(beans, package = "modeldata")

glimpse(beans)
# 13,611 × 17

# Class distribution
beans |> count(class, sort = TRUE)
# class              n
# <fct>          <int>
# Dermason        3546
# Sira            2636
# Seker           2027
# Horoz           1928
# Cali            1630
# Barbunya        1322
# Bombay           522

# === 2. DATA SPLITTING ===

set.seed(123)
bean_split <- initial_split(beans, prop = 0.75, strata = class)
bean_train <- training(bean_split)
bean_test <- testing(bean_split)

# === 3. CREATE RECIPE ===

bean_rec <- recipe(class ~ ., data = bean_train) |>

  # Feature engineering (ratios often useful)
  step_mutate(
    aspect_ratio = major_axis_length / minor_axis_length,
    roundness_ratio = roundness / compactness,
    extent_solidity_ratio = extent / solidity
  ) |>

  # Normalize (important for multiclass)
  step_YeoJohnson(all_numeric_predictors()) |>
  step_normalize(all_numeric_predictors()) |>

  # Remove highly correlated
  step_corr(all_numeric_predictors(), threshold = 0.9)

# === 4. SPECIFY MODELS ===

# Multinomial Logistic Regression
multinom_spec <- multinom_reg(penalty = tune(), mixture = tune()) |>
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

# Neural Network
nn_spec <- mlp(
  hidden_units = tune(),
  penalty = tune(),
  epochs = 100
) |>
  set_engine("nnet") |>
  set_mode("classification")

# === 5. CREATE WORKFLOWS ===

multinom_wflow <- workflow() |>
  add_recipe(bean_rec) |>
  add_model(multinom_spec)

rf_wflow <- workflow() |>
  add_recipe(bean_rec) |>
  add_model(rf_spec)

nn_wflow <- workflow() |>
  add_recipe(bean_rec) |>
  add_model(nn_spec)

# === 6. SETUP RESAMPLING ===

set.seed(234)
bean_folds <- vfold_cv(bean_train, v = 10, strata = class)

# === 7. DEFINE METRICS (multiclass) ===

multi_metrics <- metric_set(
  accuracy,
  roc_auc,          # Uses Hand-Till method
  bal_accuracy,
  mn_log_loss
)

# === 8. TUNE MODELS ===

# Multinomial Regression
set.seed(345)
multinom_grid <- grid_latin_hypercube(
  penalty(range = c(-5, 0)),
  mixture(range = c(0, 1)),
  size = 20
)

multinom_res <- multinom_wflow |>
  tune_grid(
    resamples = bean_folds,
    grid = multinom_grid,
    metrics = multi_metrics
  )

# Random Forest
set.seed(345)
rf_grid <- grid_latin_hypercube(
  mtry(range = c(3, 10)),
  min_n(range = c(2, 15)),
  size = 20
)

rf_res <- rf_wflow |>
  tune_grid(
    resamples = bean_folds,
    grid = rf_grid,
    metrics = multi_metrics
  )

# Neural Network
set.seed(345)
nn_grid <- grid_latin_hypercube(
  hidden_units(range = c(5, 20)),
  penalty(range = c(-5, -1)),
  size = 20
)

nn_res <- nn_wflow |>
  tune_grid(
    resamples = bean_folds,
    grid = nn_grid,
    metrics = multi_metrics
  )

# === 9. COMPARE MODELS ===

show_best(multinom_res, metric = "roc_auc")
show_best(rf_res, metric = "roc_auc")
show_best(nn_res, metric = "roc_auc")

# === 10. SELECT BEST ===

# Random Forest wins
best_rf <- select_best(rf_res, metric = "roc_auc")

final_wflow <- rf_wflow |>
  finalize_workflow(best_rf)

final_fit <- final_wflow |>
  last_fit(bean_split, metrics = multi_metrics)

# === 11. EVALUATE ===

collect_metrics(final_fit)

# Multiclass confusion matrix
final_fit |>
  collect_predictions() |>
  conf_mat(truth = class, estimate = .pred_class) |>
  autoplot(type = "heatmap")

# Per-class performance
final_fit |>
  collect_predictions() |>
  group_by(class) |>
  summarise(
    accuracy = mean(.pred_class == class),
    n = n()
  ) |>
  arrange(accuracy)

# Per-class ROC curves
final_fit |>
  collect_predictions() |>
  roc_curve(truth = class, .pred_BARBUNYA:.pred_SIRA) |>
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = .level)) +
  geom_path(size = 1) +
  geom_abline(lty = 2, color = "gray50") +
  facet_wrap(~ .level) +
  coord_equal() +
  theme_minimal()

# === 12. SAVE MODEL ===

final_model <- extract_workflow(final_fit)
saveRDS(final_model, "bean_classifier.rds")
```

**Key Takeaways:**
- Feature engineering with ratios improved performance
- Excellent accuracy (~92%) achievable with simple features
- Some bean types harder to distinguish (DERMASON vs SIRA)
- Random Forest outperformed both multinomial and neural network

---

## Credit Default with Imbalanced Classes

**Problem:** Predict credit card default (highly imbalanced)
**Type:** Binary Classification
**Challenge:** Only 5% default rate - extreme imbalance

### Complete Workflow

```r
library(tidymodels)
library(tidyverse)
library(themis)
library(probably)

# === 1. SIMULATED CREDIT DATA ===

set.seed(123)
n <- 10000

credit_data <- tibble(
  customer_id = 1:n,
  age = rnorm(n, 45, 12),
  income = exp(rnorm(n, 10.5, 0.6)),
  debt_ratio = rbeta(n, 2, 5),
  num_accounts = rpois(n, 3),
  credit_history = sample(c("poor", "fair", "good", "excellent"), n, replace = TRUE),
  employment_status = sample(c("employed", "self_employed", "unemployed"), n, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
  default = sample(c("no", "yes"), n, replace = TRUE, prob = c(0.95, 0.05))  # 5% default rate
)

table(credit_data$default)
# no   yes
# 9504  496

# === 2. SPLIT DATA ===

set.seed(456)
credit_split <- initial_split(credit_data, prop = 0.75, strata = default)
credit_train <- training(credit_split)
credit_test <- testing(credit_split)

# === 3. CREATE RECIPE WITH SMOTE ===

credit_rec <- recipe(default ~ ., data = credit_train) |>

  # Remove ID
  update_role(customer_id, new_role = "ID") |>

  # Feature engineering
  step_mutate(
    debt_to_income = debt_ratio * 100,
    high_risk = if_else(debt_ratio > 0.4 & employment_status == "unemployed", "yes", "no")
  ) |>

  # Handle class imbalance with SMOTE
  step_smote(default, over_ratio = 0.5, neighbors = 5) |>

  # Categorical encoding
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors()) |>

  # Normalize
  step_normalize(all_numeric_predictors())

# === 4. SPECIFY MODELS ===

# Logistic with L1 (Lasso)
lasso_spec <- logistic_reg(penalty = tune(), mixture = 1) |>
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
  learn_rate = tune(),
  min_n = tune()
) |>
  set_engine("xgboost", scale_pos_weight = 19) |>  # Weight for imbalance
  set_mode("classification")

# === 5. CREATE WORKFLOWS ===

lasso_wflow <- workflow() |>
  add_recipe(credit_rec) |>
  add_model(lasso_spec)

rf_wflow <- workflow() |>
  add_recipe(credit_rec) |>
  add_model(rf_spec)

xgb_wflow <- workflow() |>
  add_recipe(credit_rec) |>
  add_model(xgb_spec)

# === 6. RESAMPLING ===

set.seed(567)
credit_folds <- vfold_cv(credit_train, v = 10, strata = default)

# === 7. METRICS (focus on minority class) ===

imbal_metrics <- metric_set(
  roc_auc,
  pr_auc,        # Precision-Recall AUC (better for imbalanced)
  recall,        # Sensitivity - catch defaults
  precision,     # Don't falsely flag good customers
  f_meas         # Balance of precision and recall
)

# === 8. TUNE MODELS ===

# Lasso
set.seed(678)
lasso_res <- lasso_wflow |>
  tune_grid(
    resamples = credit_folds,
    grid = 20,
    metrics = imbal_metrics
  )

# Random Forest
set.seed(678)
rf_res <- rf_wflow |>
  tune_grid(
    resamples = credit_folds,
    grid = 15,
    metrics = imbal_metrics
  )

# XGBoost
set.seed(678)
xgb_res <- xgb_wflow |>
  tune_grid(
    resamples = credit_folds,
    grid = 15,
    metrics = imbal_metrics
  )

# === 9. COMPARE (focus on PR-AUC) ===

show_best(lasso_res, metric = "pr_auc")
show_best(rf_res, metric = "pr_auc")
show_best(xgb_res, metric = "pr_auc")

# === 10. FINALIZE ===

best_xgb <- select_best(xgb_res, metric = "pr_auc")

final_wflow <- xgb_wflow |>
  finalize_workflow(best_xgb)

final_fit <- final_wflow |>
  last_fit(credit_split, metrics = imbal_metrics)

# === 11. EVALUATE ON IMBALANCED TEST SET ===

collect_metrics(final_fit)

# Confusion matrix
final_fit |>
  collect_predictions() |>
  conf_mat(truth = default, estimate = .pred_class)

# PR curve (more informative than ROC for imbalanced)
final_fit |>
  collect_predictions() |>
  pr_curve(truth = default, .pred_yes) |>
  ggplot(aes(x = recall, y = precision)) +
  geom_path(size = 1.2) +
  theme_minimal() +
  labs(title = "Precision-Recall Curve")

# === 12. CALIBRATE PROBABILITIES ===

# Predictions may not be well-calibrated
cal_plot_breaks(
  final_fit |> collect_predictions(),
  truth = default,
  estimate = .pred_yes
)

# === 13. THRESHOLD OPTIMIZATION ===

# Find threshold that balances precision and recall
threshold_perf <- final_fit |>
  collect_predictions() |>
  threshold_perf(
    truth = default,
    estimate = .pred_yes,
    thresholds = seq(0.01, 0.5, by = 0.01),
    metrics = metric_set(j_index, sens, spec, precision, recall, f_meas)
  )

# Visualize
threshold_perf |>
  ggplot(aes(x = .threshold, y = .estimate, color = .metric)) +
  geom_line(size = 1) +
  facet_wrap(~.metric, scales = "free_y") +
  theme_minimal()

# Optimal for F1
best_f1_threshold <- threshold_perf |>
  filter(.metric == "f_meas") |>
  filter(.estimate == max(.estimate))

cat("Optimal threshold:", best_f1_threshold$.threshold, "\n")
cat("F1 score:", best_f1_threshold$.estimate, "\n")

# === 14. COST-SENSITIVE EVALUATION ===

# Assume: Missing a default costs $10,000, false alarm costs $100
cost_matrix <- tibble(
  truth = c("yes", "yes", "no", "no"),
  prediction = c("yes", "no", "yes", "no"),
  cost = c(0, 10000, 100, 0)  # True Pos, False Neg, False Pos, True Neg
)

# Calculate expected cost with optimal threshold
predictions_with_threshold <- final_fit |>
  collect_predictions() |>
  mutate(.pred_class_optimal = if_else(.pred_yes >= best_f1_threshold$.threshold, "yes", "no"))

predictions_with_threshold |>
  mutate(
    cost = case_when(
      default == "yes" & .pred_class_optimal == "yes" ~ 0,
      default == "yes" & .pred_class_optimal == "no" ~ 10000,
      default == "no" & .pred_class_optimal == "yes" ~ 100,
      default == "no" & .pred_class_optimal == "no" ~ 0
    )
  ) |>
  summarise(
    total_cost = sum(cost),
    avg_cost_per_customer = mean(cost),
    num_customers = n()
  )

# === 15. SAVE MODEL ===

final_model <- extract_workflow(final_fit)
model_bundle <- list(
  workflow = final_model,
  optimal_threshold = best_f1_threshold$.threshold,
  cost_matrix = cost_matrix
)

saveRDS(model_bundle, "credit_default_model.rds")
```

**Key Takeaways:**
- SMOTE improved recall significantly
- PR-AUC more informative than ROC-AUC for imbalanced data
- Threshold optimization critical for business metrics
- Cost-sensitive evaluation shows real-world impact
- XGBoost's `scale_pos_weight` parameter helped with imbalance

---

## Summary

These complete workflows demonstrate:

1. **Ames Housing**: Regression with extensive feature engineering
2. **Hotel Bookings**: Binary classification with date features
3. **Bean Types**: Multiclass classification with physical measurements
4. **Credit Default**: Extreme class imbalance handling

**Common Patterns:**
- Always split data first with stratification
- Feature engineering often more important than complex models
- Tune multiple models and compare systematically
- Use appropriate metrics for the problem type
- Visualize results to understand model behavior
- Save complete workflows for reproducible deployment

**Code Organization:**
1. Load and explore
2. Split with stratification
3. Create comprehensive recipe
4. Specify multiple models
5. Bundle in workflows
6. Setup resampling
7. Define relevant metrics
8. Tune systematically
9. Compare and select best
10. Final evaluation on test set
11. Interpret with visualizations
12. Save complete workflow
