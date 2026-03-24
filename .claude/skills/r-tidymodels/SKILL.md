---
name: r-tidymodels
description: Expert R data science using tidymodels for machine learning. Use when working with tidymodels, recipes, parsnip, tune, workflows, user mentions "machine learning in R", "ML em R", "predictive modeling", "modelagem preditiva", "modelo de classificação", "classification model", "modelo de regressão", "regression model", "feature engineering", "engenharia de features", "model tuning", "tunear modelo", "tuning", "tunar", "tune boosting", "tune gradient boosting", "xgboost tuning", "random forest tuning", "hyperparameters", "hiperparâmetros", "cross-validation", "validação cruzada", "cv", "recipe steps", "data preprocessing", discusses ML workflows, or model development in R.
version: 1.4.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R *), WebFetch
---

# R Tidymodels - Expert Machine Learning in R

Expert-level tidymodels framework knowledge for building, tuning, and deploying production-ready machine learning models in R.

## Overview

This skill provides comprehensive expertise in the tidymodels ecosystem, following the principled three-phase workflow from "Tidy Modeling with R":

**Phase 1: Foundation** - Data splitting, model specification, preprocessing, basic evaluation
**Phase 2: Optimization** - Resampling, hyperparameter tuning, model comparison
**Phase 3: Production-Ready** - Ensembles, explainability, deployment, trustworthiness assessment

## Core Principles

1. **Data Budgeting First** - Split data before any analysis to prevent leakage
2. **Honest Estimation** - All preprocessing must be included in validation
3. **Composable Workflows** - Bundle recipes + models for consistency
4. **Prevention Over Correction** - Framework prevents common pitfalls by design
5. **Tidy Philosophy** - All outputs work seamlessly with dplyr and ggplot2
6. **Parallel by Default** - Use parallel processing for tuning and resampling to maximize efficiency

## Proactive Parallelization Guidance

When building ML pipelines, **ALWAYS suggest setting up parallel processing** for operations involving:
- `tune_grid()` with 10+ grid points
- `tune_bayes()` with iterative optimization
- `fit_resamples()` with 5+ folds
- `workflow_map()` comparing multiple models
- Any workflow expected to take >30 seconds

**Default recommendation**: Use `doFuture` backend (modern, cross-platform, clean API)

## Essential Package Ecosystem

```r
library(tidymodels)  # Loads core packages
library(tidyverse)   # Data manipulation and visualization (uses native pipe |>)
```

**Core Packages (loaded by tidymodels):**
- `rsample` - Data splitting and resampling infrastructure
- `recipes` - Feature engineering and preprocessing
- `parsnip` - Unified model interface
- `workflows` - Bundle preprocessing + modeling
- `tune` - Hyperparameter optimization
- `yardstick` - Performance metrics
- `broom` - Tidy model outputs
- `dials` - Tuning parameter management

**Specialized Extensions:**
- `themis` - Class imbalance (SMOTE, upsampling)
- `embed` - Advanced encoding (target encoding, embeddings)
- `textrecipes` - Text preprocessing
- `stacks` - Model ensembling
- `finetune` - Advanced tuning strategies
- `probably` - Probability calibration
- `applicable` - Applicability domain assessment
- `vip` - Variable importance plots

## Dynamic Reference Lookup

This skill combines curated local knowledge (~100 recipe steps, ~50 models) with the ability to search the complete tidymodels reference (300+ steps, 160+ models) when needed.

### When to Use Dynamic Lookup

**Use WebFetch to search online when:**
- User asks about a specific recipe step not in local knowledge
- User needs to find models with specific capabilities
- User asks about prediction type support for model/engine combinations
- User needs sparse data compatibility information
- Searching for recently added tidymodels functionality

**Use local knowledge when:**
- Providing general guidance on workflow and best practices
- Explaining common patterns and step ordering
- Teaching concepts and principles
- Most common recipe steps and models (covered comprehensively)

### Available Search Tools

**1. Recipe Steps Search** (300+ steps)
- URL: https://www.tidymodels.org/find/recipes/
- Columns: Title (description), Topic (function name), Package
- Use for: Finding specific preprocessing steps, exploring packages like themis, textrecipes, embed

**Example queries:**
```
WebFetch: "Search for recipe steps related to 'holiday' or 'date features'"
WebFetch: "Find all SMOTE-related recipe steps from themis package"
```

**2. Parsnip Models Search** (160+ models)
- URL: https://www.tidymodels.org/find/parsnip/
- Columns: Title, Model (function), Engine, Mode, Package
- Use for: Finding specific model types, discovering available engines, checking package sources

**Example queries:**
```
WebFetch: "Find all gradient boosting models available in parsnip"
WebFetch: "What engines are available for neural networks?"
```

**3. Prediction Types Matrix**
- URL: https://www.tidymodels.org/find/parsnip_pred_types/
- Shows which prediction types (numeric, class, prob, conf_int, pred_int, quantile, raw) each model/engine supports
- Use for: Verifying if a model/engine combination supports needed prediction type

**Example queries:**
```
WebFetch: "Does svm_rbf with liquidSVM engine support confidence intervals?"
WebFetch: "Which random forest engines support prediction intervals?"
```

**4. Sparse Data Compatibility**
- URL: https://www.tidymodels.org/find/sparse/
- Lists methods compatible with sparse matrices
- Use for: Building models with high-dimensional sparse data

**Example queries:**
```
WebFetch: "Which recipe steps work with sparse matrices?"
WebFetch: "Can I use step_pca with sparse data?"
```

**5. Complete Tidymodels Search**
- URL: https://www.tidymodels.org/find/all/
- Searches across all tidymodels packages
- Use for: Broad searches when you're not sure which category

### Search Pattern

When user asks about specific functionality:

1. **Check local knowledge first** - Most common steps/models are documented
2. **If not found or user asks for comprehensive list** - Use WebFetch to search appropriate tool
3. **Extract relevant information** - Function names, descriptions, packages
4. **Provide context** - How it fits in workflow, when to use, example code

**Example workflow:**
```
User: "Is there a recipe step for handling holidays in date data?"

1. Check local knowledge → step_holiday() is documented ✓
2. Provide answer with example from local knowledge

User: "What are ALL the date-related recipe steps available?"

1. Local knowledge has main ones (step_date, step_holiday, step_time)
2. Use WebFetch to search https://www.tidymodels.org/find/recipes/ for "date"
3. Return comprehensive list with descriptions
```

## Phase 1: Foundation Workflow

### Step 1: Data Splitting Strategy

```r
library(tidymodels)
library(tidyverse)

# Load data
data(ames, package = "modeldata")

# Initial split with stratification
set.seed(123)
ames_split <- initial_split(ames, prop = 0.80, strata = Sale_Price)
ames_train <- training(ames_split)
ames_test <- testing(ames_split)

# Create validation split for iterative tuning
set.seed(234)
ames_val <- initial_validation_split(ames, prop = c(0.6, 0.2), strata = Sale_Price)
```

**Splitting Functions:**
- `initial_split()` - Simple train/test split
- `initial_validation_split()` - Train/validation/test split
- `initial_time_split()` - Time series split
- `group_initial_split()` - Split by groups
- Always use `strata` for classification and skewed outcomes

### Step 2: Feature Engineering with Recipes

```r
# Comprehensive preprocessing recipe
ames_rec <- recipe(Sale_Price ~ ., data = ames_train) |>

  # 1. Update roles for non-predictors
  update_role(Id, new_role = "ID") |>

  # 2. Handle missing data (before transformations)
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>

  # 3. Feature creation
  step_mutate(
    House_Age = Year_Sold - Year_Built,
    Remod_Age = Year_Sold - Year_Remod_Add,
    Total_SF = Gr_Liv_Area + Total_Bsmt_SF
  ) |>

  # 4. Transform outcome (if needed)
  step_log(Sale_Price, base = 10) |>

  # 5. Handle novel factor levels (BEFORE dummy encoding)
  step_novel(all_nominal_predictors()) |>
  step_unknown(all_nominal_predictors()) |>

  # 6. Other preprocessing for categorical
  step_other(all_nominal_predictors(), threshold = 0.01) |>

  # 7. Encode categorical variables
  step_dummy(all_nominal_predictors(), one_hot = FALSE) |>

  # 8. Remove problematic predictors
  step_zv(all_predictors()) |>
  step_nzv(all_predictors()) |>

  # 9. Normalize numeric features (AFTER dummies)
  step_normalize(all_numeric_predictors()) |>

  # 10. Remove highly correlated predictors
  step_corr(all_numeric_predictors(), threshold = 0.9)
```

**Recipe Step Order (Critical):**
1. Update roles (ID variables, case weights)
2. Handle missing data
3. Create new features
4. Transform outcomes
5. Handle novel/unknown factor levels
6. Pool infrequent categories
7. Create dummy variables
8. Remove zero/near-zero variance
9. Normalize/scale numeric predictors
10. Remove correlations or apply dimensionality reduction

**Role Selectors:**
- `all_predictors()` / `all_outcomes()` - By role
- `all_numeric_predictors()` / `all_nominal_predictors()` - By type
- `has_role("ID")` / `has_type("date")` - Specific criteria
- Never hard-code column names if avoidable

See [references/recipe-steps-guide.md](references/recipe-steps-guide.md) for complete step catalog.

### Step 3: Model Specification with Parsnip

```r
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

# Penalized Regression
glmnet_spec <- linear_reg(
  penalty = tune(),
  mixture = tune()
) |>
  set_engine("glmnet")
```

**Key Model Functions:**

| Model Type | Function | Modes | Common Engines |
|------------|----------|-------|----------------|
| Linear/Logistic Reg | `linear_reg()` / `logistic_reg()` | regression / classification | glm, glmnet, stan |
| Decision Trees | `decision_tree()` | both | rpart, C5.0 |
| Random Forest | `rand_forest()` | both | ranger, randomForest |
| Boosted Trees | `boost_tree()` | both | xgboost, lightgbm |
| SVM | `svm_rbf()`, `svm_poly()` | both | kernlab |
| Neural Networks | `mlp()` | both | nnet, keras, brulee |
| Nearest Neighbors | `nearest_neighbor()` | both | kknn |
| Naive Bayes | `naive_Bayes()` | classification | klaR, naivebayes |

**Tuning Parameters:**
- Mark with `tune()` for hyperparameter optimization
- Use `set_engine()` for implementation-specific options
- Always set `mode` explicitly

### Step 4: Create Workflow

```r
# Bundle recipe + model
rf_wflow <- workflow() |>
  add_recipe(ames_rec) |>
  add_model(rf_spec)

# Alternative: formula interface (skips recipe)
rf_wflow_formula <- workflow() |>
  add_formula(Sale_Price ~ Lot_Area + Neighborhood) |>
  add_model(rf_spec)

# Add case weights if needed
rf_wflow_weighted <- workflow() |>
  add_recipe(ames_rec) |>
  add_model(rf_spec) |>
  add_case_weights(weight_column)
```

**Why Workflows:**
- Ensures preprocessing consistency across train/test/predict
- Simplifies tuning (tunes both recipe and model parameters)
- Bundles everything for deployment
- Prevents preprocessing from being excluded from validation

### Step 5: Basic Evaluation

```r
# Fit and evaluate on test set
ames_fit <- rf_wflow |>
  fit(data = ames_train)

# Predict on test set
ames_pred <- augment(ames_fit, new_data = ames_test)

# Calculate metrics
ames_pred |>
  metrics(truth = Sale_Price, estimate = .pred)
```

## Phase 2: Optimization Workflow

### Step 1: Create Resampling Strategy

```r
# V-fold cross-validation (most common)
set.seed(345)
ames_folds <- vfold_cv(ames_train, v = 10, strata = Sale_Price)

# Repeated CV for more robust estimates
ames_folds_rep <- vfold_cv(ames_train, v = 10, repeats = 3, strata = Sale_Price)

# Bootstrap resampling
ames_boots <- bootstraps(ames_train, times = 25, strata = Sale_Price)

# Monte Carlo CV
ames_mc <- mc_cv(ames_train, prop = 0.9, times = 20, strata = Sale_Price)

# Time series rolling origin
time_folds <- rolling_origin(
  time_data,
  initial = 365,    # Initial training window
  assess = 30,      # Assessment window
  skip = 29,        # Days to skip
  cumulative = TRUE # Use all previous data
)
```

**Resampling Strategy Guide:**
- **10-fold CV**: Default choice, good balance
- **Repeated CV**: When you need more robust estimates
- **Bootstrap**: For small datasets or confidence intervals
- **Monte Carlo**: For very large datasets
- **Rolling origin**: For time series only

### Step 2: Evaluate Without Tuning

```r
# Fit across resamples without tuning
rf_res <- rf_wflow |>
  fit_resamples(
    resamples = ames_folds,
    metrics = metric_set(rmse, rsq, mae),
    control = control_resamples(save_pred = TRUE)
  )

# View metrics
collect_metrics(rf_res)

# Plot predictions vs truth
collect_predictions(rf_res) |>
  ggplot(aes(x = Sale_Price, y = .pred)) +
  geom_abline(lty = 2) +
  geom_point(alpha = 0.3) +
  coord_obs_pred()
```

### Step 3: Hyperparameter Tuning - Grid Search

```r
# Setup parallel processing (recommended for grid search)
library(doFuture)
registerDoFuture()
plan(multisession, workers = parallel::detectCores() - 1)

# Define tuning grid (space-filling design recommended)
rf_grid <- grid_latin_hypercube(
  mtry(range = c(10, 30)),
  min_n(range = c(2, 10)),
  size = 20
)

# Tune with grid search (automatically uses parallel processing)
rf_tuned <- rf_wflow |>
  tune_grid(
    resamples = ames_folds,
    grid = rf_grid,
    metrics = metric_set(rmse, rsq, mae),
    control = control_grid(
      save_pred = TRUE,
      verbose = TRUE,
      parallel_over = "everything"
    )
  )

# Examine results
show_best(rf_tuned, metric = "rmse", n = 5)
autoplot(rf_tuned, metric = "rmse")

# Select best configuration
best_rmse <- select_best(rf_tuned, metric = "rmse")
```

**Grid Strategies:**
- `grid_regular()` - Full factorial grid (can be huge)
- `grid_random()` - Random search
- `grid_latin_hypercube()` - **Recommended**: space-filling design
- Start with 20-30 points for initial exploration

### Step 4: Iterative Tuning (Bayesian Optimization)

```r
# Parallel processing already set up from previous step
# (If not, run: registerDoFuture(); plan(multisession, workers = detectCores() - 1))

# Setup Bayesian optimization with parallelization
ctrl_bayes <- control_bayes(
  no_improve = 10,        # Stop after 10 iterations without improvement
  verbose = TRUE,
  save_pred = TRUE,
  parallel_over = "everything"  # Critical for speed
)

# Define parameter ranges
xgb_params <- extract_parameter_set_dials(xgb_wflow) |>
  update(
    trees = trees(range = c(100, 2000)),
    learn_rate = learn_rate(range = c(-3, -0.5))
  )

# Bayesian tuning (uses parallel processing automatically)
set.seed(456)
xgb_bayes <- xgb_wflow |>
  tune_bayes(
    resamples = ames_folds,
    param_info = xgb_params,
    initial = 10,         # Initial random grid points
    iter = 50,            # Additional iterations
    metrics = metric_set(rmse, rsq),
    control = ctrl_bayes
  )

# Visualize optimization path
autoplot(xgb_bayes, type = "performance")
autoplot(xgb_bayes, type = "parameters")
```

**Iterative Strategies:**
- `tune_bayes()` - Bayesian optimization (best for expensive models)
- `tune_sim_anneal()` - Simulated annealing
- `tune_race_anova()` - Racing with ANOVA (from finetune package)

### Step 5: Compare Multiple Models

```r
# Create workflow set with multiple models
wf_set <- workflow_set(
  preproc = list(basic = ames_rec),
  models = list(
    rf = rf_spec,
    xgb = xgb_spec,
    glmnet = glmnet_spec
  )
)

# Tune all workflows
wf_results <- wf_set |>
  workflow_map(
    fn = "tune_grid",
    resamples = ames_folds,
    grid = 20,
    metrics = metric_set(rmse, rsq),
    verbose = TRUE
  )

# Rank models
rank_results(wf_results, rank_metric = "rmse", select_best = TRUE)

# Visualize comparison
autoplot(wf_results, metric = "rmse")
```

### Step 6: Finalize and Test

```r
# Finalize workflow with best parameters
final_wflow <- rf_wflow |>
  finalize_workflow(best_rmse)

# Fit on training data and evaluate on test set
final_fit <- final_wflow |>
  last_fit(ames_split, metrics = metric_set(rmse, rsq, mae))

# Test set metrics
collect_metrics(final_fit)

# Test set predictions
collect_predictions(final_fit) |>
  ggplot(aes(x = Sale_Price, y = .pred)) +
  geom_abline(lty = 2) +
  geom_point(alpha = 0.5) +
  coord_obs_pred()

# Extract final fitted workflow
final_model <- extract_workflow(final_fit)
```

## Phase 3: Production-Ready Models

### Variable Importance & Interpretability

```r
library(vip)

# Extract fitted model and visualize importance
final_fit |>
  extract_fit_parsnip() |>
  vip(num_features = 20, geom = "point")

# For linear models, examine coefficients
glmnet_fit |>
  extract_fit_parsnip() |>
  tidy() |>
  filter(term != "(Intercept)") |>
  ggplot(aes(x = estimate, y = reorder(term, estimate))) +
  geom_col()
```

### Model Stacking (Ensembles)

```r
library(stacks)

# Collect candidate models from tuning results
model_st <- stacks() |>
  add_candidates(rf_tuned) |>
  add_candidates(xgb_tuned) |>
  add_candidates(glmnet_tuned)

# Fit meta-learner (blend predictions)
ensemble_fit <- model_st |>
  blend_predictions(
    penalty = 10^(-6:-1),
    mixture = c(0, 0.5, 1)
  ) |>
  fit_members()

# Examine member weights
autoplot(ensemble_fit, type = "weights")

# Predict with ensemble
predict(ensemble_fit, new_data = ames_test)
```

### Class Imbalance Handling

```r
library(themis)

# Add imbalance correction to recipe
balanced_rec <- recipe(class ~ ., data = train_data) |>
  # Upsample minority class
  step_upsample(class, over_ratio = 0.8) |>
  # OR downsample majority class
  # step_downsample(class, under_ratio = 1.2) |>
  # OR SMOTE (synthetic examples)
  # step_smote(class, over_ratio = 0.8) |>
  # OR ROSE
  # step_rose(class) |>
  step_normalize(all_numeric_predictors())

# Themis steps must come BEFORE dummy variables
```

### Probability Calibration

```r
library(probably)

# Estimate calibration from resamples
cal_obj <- rf_res |>
  collect_predictions() |>
  cal_estimate_beta(truth = class, estimate = dplyr::starts_with(".pred_"))

# Apply calibration to new predictions
calibrated_preds <- augment(rf_fit, new_data = test_data) |>
  cal_apply(cal_obj)

# Visualize calibration
cal_plot_breaks(cal_obj)
```

### Model Deployment

```r
# Save final fitted workflow
saveRDS(final_model, "models/ames_rf_model.rds")

# Load for prediction
model <- readRDS("models/ames_rf_model.rds")
predictions <- predict(model, new_data = new_houses)

# Production prediction function
predict_sale_price <- function(new_data) {
  model <- readRDS("models/ames_rf_model.rds")

  pred <- predict(model, new_data = new_data) |>
    bind_cols(
      predict(model, new_data = new_data, type = "conf_int")
    )

  return(pred)
}
```

## Best Practices & Common Pitfalls

### ✅ DO:

1. **Split data first** - Before any exploration or analysis
2. **Stratify splits** - Use `strata` for classification and skewed outcomes
3. **Use workflows** - Bundle recipe + model for consistency
4. **Set seeds** - For reproducibility: `set.seed(123)`
5. **Setup parallel processing** - Use `doFuture` or `doParallel` for tuning/resampling
6. **Include preprocessing in validation** - Always use recipes within workflows
7. **Use role selectors** - `all_numeric_predictors()` instead of hard-coded names
8. **Handle novel levels** - `step_novel()` before `step_dummy()`
9. **Normalize after dummies** - Create indicators first, then scale
10. **Multiple metrics** - Use `metric_set(rmse, rsq, mae)` for comprehensive view
11. **Visualize tuning** - Use `autoplot()` to understand parameter effects

### ❌ DON'T:

1. **Preprocess before splitting** - Causes data leakage
2. **Tune on test set** - Only use for final evaluation
3. **Skip validation** - Always use resampling, never just training metrics
4. **Forget `step_zv()`** - Dummy coding can create zero-variance predictors
5. **Normalize before dummies** - Order matters!
6. **Ignore novel factor levels** - Will error in production
7. **Use `step_dummy(all_predictors())`** - Excludes numeric predictors, use `all_nominal_predictors()`
8. **Evaluate only accuracy** - Consider business costs and trade-offs
9. **Skip test set evaluation** - Training/CV metrics can be optimistic
10. **Trust all predictions equally** - Assess applicability domain

## Performance Metrics Guide

### Regression Metrics

```r
metric_set(rmse, rsq, mae, mape, huber_loss)
```

- `rmse` - Root mean squared error (penalizes large errors)
- `rsq` - R-squared (proportion of variance explained)
- `mae` - Mean absolute error (robust to outliers)
- `mape` - Mean absolute percentage error
- `huber_loss` - Combination of MSE and MAE

### Classification Metrics

```r
# Binary classification
metric_set(accuracy, roc_auc, pr_auc, f_meas, sensitivity, specificity)

# Multiclass classification
metric_set(accuracy, roc_auc, mn_log_loss, bal_accuracy)
```

- `accuracy` - Overall correct predictions
- `roc_auc` - Area under ROC curve
- `pr_auc` - Area under precision-recall curve
- `f_meas` - F1 score (harmonic mean of precision and recall)
- `sensitivity` - True positive rate (recall)
- `specificity` - True negative rate
- `bal_accuracy` - Balanced accuracy for imbalanced data
- `mn_log_loss` - Multinomial log loss

## Parallel Processing (Always Recommend for Tuning)

### When to Use Parallelization

**ALWAYS suggest parallel processing when the user is:**
- Running `tune_grid()` with 10+ grid configurations
- Running `tune_bayes()` with iterative optimization
- Running `fit_resamples()` with 5+ CV folds
- Using `workflow_map()` to compare multiple models
- Building any ML pipeline expected to take >30 seconds

**Ask proactively**: "Would you like me to set up parallel processing? This can speed up tuning by 3-7x depending on available cores."

### Recommended Setup (doFuture - Modern & Cross-Platform)

```r
library(doFuture)

# Setup parallel processing (works on Windows, Mac, Linux)
registerDoFuture()
plan(multisession, workers = parallel::detectCores() - 1)

# All tuning functions automatically use parallel processing
tuned_results <- tune_grid(
  workflow,
  resamples = folds,
  grid = param_grid,
  control = control_grid(parallel_over = "everything")
)

# Clean up (optional - doFuture auto-cleans on session end)
plan(sequential)
```

### Alternative Setup (doParallel - Traditional)

```r
library(doParallel)

# Setup parallel backend
cl <- makePSOCKcluster(parallel::detectCores() - 1)
registerDoParallel(cl)

# Tuning automatically uses parallel processing
tuned_results <- tune_grid(
  workflow,
  resamples = folds,
  grid = param_grid,
  control = control_grid(parallel_over = "everything")
)

# IMPORTANT: Stop cluster when done
stopCluster(cl)
registerDoSEQ()  # Return to sequential
```

### Backend Comparison

| Backend | Pros | Cons | Best For |
|---------|------|------|----------|
| **doFuture** | Modern, cross-platform, auto-cleanup, flexible | Slightly more setup | **Recommended default** |
| **doParallel (PSOCK)** | Stable, well-tested, cross-platform | Manual cleanup needed | Production stability |
| **doParallel (fork)** | Lowest overhead, fast | Unix/Mac only | Mac/Linux power users |

### Control Options

```r
# Parallelize everything (default recommendation)
control_grid(parallel_over = "everything")

# Parallelize only resamples (if models are very fast)
control_grid(parallel_over = "resamples")

# Disable parallelization
control_grid(parallel_over = NULL)
```

### Expected Performance Gains

- **10-fold CV with 4 cores** → ~3.5x speedup
- **Grid search (50 points) with 8 cores** → ~7x speedup
- **Bayesian tuning (50 iterations) with 8 cores** → ~6x speedup
- **workflow_map (5 models) with 4 cores** → ~3.8x speedup

## Quick Reference

### Essential Workflow Pattern (With Parallel Processing)

```r
library(tidymodels)
library(tidyverse)
library(doFuture)

# 0. Setup parallel processing (recommended for steps 6-7)
registerDoFuture()
plan(multisession, workers = parallel::detectCores() - 1)

# 1. Split
split <- initial_split(data, prop = 0.8, strata = outcome)
train <- training(split)
test <- testing(split)

# 2. Recipe
rec <- recipe(outcome ~ ., data = train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# 3. Model
spec <- rand_forest(mtry = tune(), min_n = tune()) |>
  set_engine("ranger") |>
  set_mode("classification")

# 4. Workflow
wflow <- workflow() |>
  add_recipe(rec) |>
  add_model(spec)

# 5. Resample
folds <- vfold_cv(train, v = 10, strata = outcome)

# 6. Tune (uses parallel processing automatically)
results <- wflow |>
  tune_grid(
    resamples = folds,
    grid = grid_latin_hypercube(mtry(), min_n(), size = 20),
    control = control_grid(parallel_over = "everything")
  )

# 7. Select best
best <- select_best(results, metric = "roc_auc")

# 8. Finalize
final_wflow <- finalize_workflow(wflow, best)

# 9. Last fit
final_fit <- last_fit(final_wflow, split)

# 10. Evaluate
collect_metrics(final_fit)

# 11. Clean up (optional)
plan(sequential)
```

## Supporting Resources

- **Complete workflows**: [examples/tidymodels-workflows.md](examples/tidymodels-workflows.md)
- **Recipe catalog**: [references/recipe-steps-guide.md](references/recipe-steps-guide.md)
- **Model templates**: [templates/model-templates.md](templates/model-templates.md)

## External Resources

- [tidymodels.org](https://www.tidymodels.org/) - Official documentation
- [Tidy Modeling with R](https://www.tmwr.org/) - Comprehensive book
- [tidymodels GitHub](https://github.com/tidymodels) - Source code and issues
