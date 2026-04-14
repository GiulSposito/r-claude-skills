# Feature Engineering Guide

Complete reference for preprocessing and feature engineering using recipes from tidymodels.

## Overview

Feature engineering transforms raw predictors into features that better represent the underlying problem for predictive models. This guide covers the recipes package approach.

## Recipe Workflow

```r
library(recipes)
library(tidymodels)

# 1. Create recipe
rec <- recipe(outcome ~ ., data = train) |>
  # Add preprocessing steps
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

# 2. Prep recipe (estimate parameters from training data)
rec_prepped <- prep(rec, training = train)

# 3. Bake (apply to data)
train_processed <- bake(rec_prepped, new_data = NULL)  # NULL = training data
test_processed <- bake(rec_prepped, new_data = test)

# Or use in workflow (recommended)
wf <- workflow() |>
  add_recipe(rec) |>
  add_model(model_spec)
```

## Missing Values

### Imputation Methods

```r
# Simple imputation
recipe(outcome ~ ., data = train) |>
  step_impute_mean(all_numeric_predictors()) |>
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors())

# Model-based imputation
recipe(outcome ~ ., data = train) |>
  step_impute_knn(all_numeric_predictors(), neighbors = 5) |>
  step_impute_bag(all_numeric_predictors(), trees = 25) |>
  step_impute_linear(income ~ age + education)

# Add indicator for missingness
recipe(outcome ~ ., data = train) |>
  step_indicate_na(all_predictors(), prefix = "missing_")

# Unknown category for factors
recipe(outcome ~ ., data = train) |>
  step_unknown(all_nominal_predictors(), new_level = "unknown")
```

## Encoding Categorical Variables

### Dummy Variables

```r
# One-hot encoding (reference level dropped)
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors())

# Full one-hot (keep all levels)
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE)

# Manual reference level
recipe(outcome ~ ., data = train) |>
  step_relevel(factor_var, ref_level = "baseline") |>
  step_dummy(factor_var)

# Handle new levels in test set
recipe(outcome ~ ., data = train) |>
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors())
```

### Other Encoding Methods

```r
# Ordinal encoding
recipe(outcome ~ ., data = train) |>
  step_ordinalscore(education, convert = ordered_levels)

# Target encoding (encode by outcome mean)
recipe(outcome ~ ., data = train) |>
  step_lencode_mixed(category, outcome = vars(outcome))

# Binary to factor
recipe(outcome ~ ., data = train) |>
  step_bin2factor(binary_var, levels = c("no", "yes"))
```

## Numeric Transformations

### Scaling and Centering

```r
# Standardize (mean=0, sd=1)
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors())

# Center only
recipe(outcome ~ ., data = train) |>
  step_center(all_numeric_predictors())

# Scale only
recipe(outcome ~ ., data = train) |>
  step_scale(all_numeric_predictors())

# Range scaling [0, 1]
recipe(outcome ~ ., data = train) |>
  step_range(all_numeric_predictors(), min = 0, max = 1)
```

### Power Transformations

```r
# Log transformation
recipe(outcome ~ ., data = train) |>
  step_log(income, base = 10, offset = 1)

# Square root
recipe(outcome ~ ., data = train) |>
  step_sqrt(count_var)

# Box-Cox transformation
recipe(outcome ~ ., data = train) |>
  step_BoxCox(all_numeric_predictors())

# Yeo-Johnson (handles negative values)
recipe(outcome ~ ., data = train) |>
  step_YeoJohnson(all_numeric_predictors())

# Inverse transformation
recipe(outcome ~ ., data = train) |>
  step_inverse(rate)
```

### Discretization

```r
# Cut into bins
recipe(outcome ~ ., data = train) |>
  step_cut(age, breaks = c(0, 18, 30, 50, 100))

# Equal frequency bins
recipe(outcome ~ ., data = train) |>
  step_discretize(income, num_breaks = 4)
```

## Feature Creation

### Interactions

```r
# All 2-way interactions
recipe(outcome ~ ., data = train) |>
  step_interact(~ all_predictors():all_predictors())

# Specific interactions
recipe(outcome ~ ., data = train) |>
  step_interact(~ age:income + education:income)

# Interaction with outcome (for non-linear models)
recipe(outcome ~ ., data = train) |>
  step_interact(~ starts_with("pred_"):outcome)
```

### Polynomial Features

```r
# Polynomial terms
recipe(outcome ~ ., data = train) |>
  step_poly(age, degree = 3)  # age, age^2, age^3

# Orthogonal polynomials
recipe(outcome ~ ., data = train) |>
  step_poly(age, degree = 3, options = list(raw = FALSE))
```

### Splines

```r
# Natural splines
recipe(outcome ~ ., data = train) |>
  step_ns(age, deg_free = 4)

# B-splines
recipe(outcome ~ ., data = train) |>
  step_bs(age, deg_free = 4, degree = 3)
```

### Date/Time Features

```r
# Extract components
recipe(outcome ~ ., data = train) |>
  step_date(date_var, features = c("dow", "month", "year", "doy"))

# Time features
recipe(outcome ~ ., data = train) |>
  step_time(datetime_var, features = c("hour", "minute"))

# Holiday indicator
recipe(outcome ~ ., data = train) |>
  step_holiday(date_var, holidays = timeDate::listHolidays("US"))

# Relative to reference date
recipe(outcome ~ ., data = train) |>
  step_mutate(days_since = as.numeric(date - as.Date("2020-01-01")))
```

## Dimensionality Reduction

### Principal Components

```r
# PCA
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>  # Always normalize first
  step_pca(all_numeric_predictors(), threshold = 0.95)  # Keep 95% variance

# Keep specific number of components
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>
  step_pca(all_numeric_predictors(), num_comp = 5)
```

### Other Methods

```r
# Independent Component Analysis
recipe(outcome ~ ., data = train) |>
  step_ica(all_numeric_predictors(), num_comp = 5)

# Kernel PCA
recipe(outcome ~ ., data = train) |>
  step_kpca(all_numeric_predictors(), num_comp = 5)

# UMAP
recipe(outcome ~ ., data = train) |>
  step_umap(all_numeric_predictors(), num_comp = 2)
```

## Feature Selection

### Filter Methods

```r
# Remove zero-variance predictors
recipe(outcome ~ ., data = train) |>
  step_zv(all_predictors())

# Remove near-zero variance
recipe(outcome ~ ., data = train) |>
  step_nzv(all_predictors(), freq_cut = 95/5, unique_cut = 10)

# Remove highly correlated features
recipe(outcome ~ ., data = train) |>
  step_corr(all_numeric_predictors(), threshold = 0.9)

# Remove linear combinations
recipe(outcome ~ ., data = train) |>
  step_lincomb(all_numeric_predictors())
```

### Wrapper Methods

```r
# Feature selection via importance
library(colino)

recipe(outcome ~ ., data = train) |>
  step_select_forests(all_predictors(), outcome = "outcome", top_p = 10)

# Boruta feature selection
recipe(outcome ~ ., data = train) |>
  step_select_boruta(all_predictors(), outcome = "outcome")
```

## Handling Class Imbalance

### Resampling Methods

```r
library(themis)

# Downsample majority class
recipe(outcome ~ ., data = train) |>
  step_downsample(outcome, under_ratio = 1)

# Upsample minority class
recipe(outcome ~ ., data = train) |>
  step_upsample(outcome, over_ratio = 1)

# SMOTE (Synthetic Minority Oversampling)
recipe(outcome ~ ., data = train) |>
  step_smote(outcome, over_ratio = 1, neighbors = 5)

# ROSE (Random Oversampling Examples)
recipe(outcome ~ ., data = train) |>
  step_rose(outcome)

# ADASYN (Adaptive Synthetic Sampling)
recipe(outcome ~ ., data = train) |>
  step_adasyn(outcome)
```

## Complete Recipe Examples

### Regression Recipe

```r
reg_recipe <- recipe(price ~ ., data = train) |>
  # 1. Handle missing
  step_impute_knn(all_numeric_predictors()) |>
  step_unknown(all_nominal_predictors()) |>

  # 2. Create features
  step_date(date, features = c("month", "dow", "year")) |>
  step_rm(date) |>
  step_mutate(age_squared = age^2) |>

  # 3. Encode categoricals
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>

  # 4. Transform numerics
  step_YeoJohnson(all_numeric_predictors()) |>
  step_normalize(all_numeric_predictors()) |>

  # 5. Feature selection
  step_zv(all_predictors()) |>
  step_corr(all_numeric_predictors(), threshold = 0.9)
```

### Classification Recipe

```r
class_recipe <- recipe(outcome ~ ., data = train) |>
  # 1. Handle missing
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>

  # 2. Create features
  step_interact(~ age:income) |>
  step_poly(age, degree = 2) |>

  # 3. Encode
  step_dummy(all_nominal_predictors(), one_hot = FALSE) |>

  # 4. Transform
  step_normalize(all_numeric_predictors()) |>

  # 5. Handle imbalance
  step_smote(outcome, over_ratio = 0.8) |>

  # 6. Feature selection
  step_zv(all_predictors()) |>
  step_nzv(all_predictors())
```

### High-Dimensional Recipe

```r
highdim_recipe <- recipe(outcome ~ ., data = train) |>
  # 1. Handle missing
  step_impute_knn(all_numeric_predictors()) |>

  # 2. Reduce dimensions
  step_normalize(all_numeric_predictors()) |>
  step_pca(all_numeric_predictors(), threshold = 0.95) |>

  # 3. Encode remaining
  step_dummy(all_nominal_predictors())
```

## Best Practices

✅ **Order matters**: Follow this sequence:
  1. Imputation
  2. Feature engineering
  3. Encoding
  4. Transformations/normalization
  5. Feature selection
  6. Resampling (if needed)

✅ **Always normalize** before PCA, ICA, or distance-based methods
✅ **Handle missingness early** in the pipeline
✅ **Use `prep()` and `bake()`** to check intermediate results
✅ **Test recipes** on small sample before full pipeline
✅ **Consider domain knowledge** when engineering features
✅ **Use workflows** instead of manual prep/bake in production

❌ **Don't normalize** after dummy encoding (sparse → dense)
❌ **Don't fit recipe on test data** (use `prep()` on train only)
❌ **Don't remove predictors** manually before recipe
❌ **Don't apply transformations** before checking distributions

## Debugging Recipes

```r
# Check intermediate steps
rec <- recipe(outcome ~ ., data = train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_normalize(all_numeric_predictors())

rec_prepped <- prep(rec)

# See parameter estimates
tidy(rec_prepped, number = 1)  # First step
tidy(rec_prepped, number = 2)  # Second step

# Bake and inspect
baked_data <- bake(rec_prepped, new_data = NULL)
glimpse(baked_data)
summary(baked_data)

# Visualize transformations
original <- train |> select(numeric_var)
transformed <- baked_data |> select(numeric_var)

bind_rows(
  original |> mutate(type = "original"),
  transformed |> mutate(type = "transformed")
) |>
  ggplot(aes(numeric_var, fill = type)) +
  geom_density(alpha = 0.5)
```

## Quick Reference

| Category | Step | Purpose |
|----------|------|---------|
| **Missing** | `step_impute_median()` | Fill with median |
| | `step_impute_knn()` | KNN imputation |
| | `step_unknown()` | Factor "unknown" level |
| **Encoding** | `step_dummy()` | One-hot encoding |
| | `step_ordinalscore()` | Ordinal encoding |
| **Transform** | `step_normalize()` | Standardize (z-score) |
| | `step_range()` | Min-max scaling |
| | `step_YeoJohnson()` | Power transform |
| | `step_log()` | Log transform |
| **Features** | `step_interact()` | Interaction terms |
| | `step_poly()` | Polynomial features |
| | `step_date()` | Date components |
| **Reduce** | `step_pca()` | Principal components |
| | `step_corr()` | Remove correlated |
| **Select** | `step_zv()` | Remove zero-variance |
| | `step_nzv()` | Remove near-zero |
| **Imbalance** | `step_smote()` | Synthetic oversampling |
| | `step_downsample()` | Undersample majority |

---

**Remember**: Good feature engineering often matters more than model choice. Invest time understanding your data and domain.
