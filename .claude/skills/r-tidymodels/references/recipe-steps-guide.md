# Complete Recipe Steps Guide

Comprehensive catalog of all recipe preprocessing steps organized by category.

## Table of Contents

1. [Missing Data Handling](#missing-data-handling)
2. [Feature Creation](#feature-creation)
3. [Categorical Variable Encoding](#categorical-variable-encoding)
4. [Numeric Transformations](#numeric-transformations)
5. [Normalization and Scaling](#normalization-and-scaling)
6. [Feature Selection and Filtering](#feature-selection-and-filtering)
7. [Dimensionality Reduction](#dimensionality-reduction)
8. [Class Imbalance](#class-imbalance)
9. [Text Processing](#text-processing)
10. [Date and Time Features](#date-and-time-features)
11. [Advanced Steps](#advanced-steps)
12. [Step Order Guidelines](#step-order-guidelines)

---

## Missing Data Handling

### `step_impute_mean()`
Replace missing values with the mean.

```r
recipe(outcome ~ ., data = train) |>
  step_impute_mean(all_numeric_predictors())
```

**When to use:** Quick imputation for normally distributed numeric variables
**Pros:** Simple, fast
**Cons:** Can distort distributions, doesn't capture relationships

### `step_impute_median()`
Replace missing values with the median.

```r
recipe(outcome ~ ., data = train) |>
  step_impute_median(age, income, credit_score)
```

**When to use:** Numeric variables with skewed distributions or outliers
**Pros:** Robust to outliers
**Cons:** Doesn't capture relationships

### `step_impute_mode()`
Replace missing categorical values with the most frequent category.

```r
recipe(outcome ~ ., data = train) |>
  step_impute_mode(all_nominal_predictors())
```

**When to use:** Categorical variables
**Pros:** Simple, preserves most common pattern
**Cons:** May over-represent majority class

### `step_impute_knn()`
K-nearest neighbors imputation.

```r
recipe(outcome ~ ., data = train) |>
  step_impute_knn(all_predictors(), neighbors = 5)
```

**When to use:** When missing values have relationships with other features
**Pros:** Captures feature relationships
**Cons:** Computationally expensive, requires scaling first

### `step_impute_bag()`
Bagged tree imputation.

```r
recipe(outcome ~ ., data = train) |>
  step_impute_bag(age, income, trees = 25)
```

**When to use:** Complex relationships, mixed variable types
**Pros:** Handles non-linear relationships
**Cons:** Slow, can overfit

### `step_impute_linear()`
Linear regression imputation.

```r
recipe(outcome ~ ., data = train) |>
  step_impute_linear(blood_pressure, impute_with = imp_vars(age, weight, gender))
```

**When to use:** Linear relationships between variables
**Pros:** Captures linear relationships
**Cons:** Assumes linearity

### `step_unknown()`
Convert missing categories to "unknown" level.

```r
recipe(outcome ~ ., data = train) |>
  step_unknown(all_nominal_predictors(), new_level = "missing")
```

**When to use:** When missingness itself is informative
**Pros:** Preserves missingness information
**Cons:** Creates extra category

**Order:** Apply imputation steps EARLY in recipe, before transformations.

---

## Feature Creation

### `step_mutate()`
Create or modify variables using dplyr syntax.

```r
recipe(sale_price ~ ., data = train) |>
  step_mutate(
    house_age = year_sold - year_built,
    price_per_sqft = sale_price / total_sqft,
    has_garage = if_else(garage_sqft > 0, 1, 0)
  )
```

**When to use:** Custom feature engineering
**Pros:** Flexible, familiar dplyr syntax
**Cons:** None

### `step_interact()`
Create interaction terms.

```r
recipe(outcome ~ ., data = train) |>
  step_interact(terms = ~ age:gender + income:education)

# All pairwise interactions
recipe(outcome ~ ., data = train) |>
  step_interact(terms = ~ all_numeric_predictors():all_numeric_predictors())
```

**When to use:** When effects depend on combinations of features
**Pros:** Captures non-additive effects
**Cons:** Can create many features, may overfit

### `step_poly()`
Create polynomial features.

```r
recipe(outcome ~ ., data = train) |>
  step_poly(age, degree = 3)
```

**When to use:** Non-linear relationships
**Pros:** Captures curves
**Cons:** Can overfit, creates correlated features

### `step_ns()` / `step_bs()`
Natural splines / B-splines for smooth curves.

```r
library(splines)
recipe(outcome ~ ., data = train) |>
  step_ns(age, deg_free = 4)
```

**When to use:** Smooth non-linear relationships
**Pros:** Flexible, less prone to overfitting than polynomials
**Cons:** Requires choosing degrees of freedom

### `step_ratio()`
Create ratios between numeric variables.

```r
recipe(outcome ~ ., data = train) |>
  step_ratio(denom = dplyr::vars(total_income),
             naming = function(x) paste0(x, "_ratio"))
```

**When to use:** Relative relationships matter more than absolutes
**Pros:** Often more interpretable
**Cons:** Division by zero issues

### `step_lag()` (from timetk or  step_slidify)
Create lagged features for time series.

```r
recipe(value ~ ., data = time_train) |>
  step_lag(value, lag = 1:7)  # Previous 7 time points
```

**When to use:** Time series forecasting
**Pros:** Captures temporal patterns
**Cons:** Creates missing values at start

---

## Categorical Variable Encoding

### `step_dummy()`
One-hot encoding (create binary indicators).

```r
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors(), one_hot = FALSE)  # Drop first level
```

**When to use:** Most models (linear, tree-based)
**Pros:** Standard approach
**Cons:** Creates many features, loses ordinal information

**Options:**
- `one_hot = TRUE`: Keep all levels
- `one_hot = FALSE`: Drop first level (avoid multicollinearity)

### `step_novel()`
Handle novel factor levels in new data.

```r
recipe(outcome ~ ., data = train) |>
  step_novel(all_nominal_predictors(), new_level = "new")
```

**When to use:** ALWAYS, before `step_dummy()`
**Pros:** Prevents errors on new data
**Cons:** None

**Critical:** Must come BEFORE `step_dummy()`

### `step_other()`
Pool infrequent categories.

```r
recipe(outcome ~ ., data = train) |>
  step_other(neighborhood, threshold = 0.05, other = "rare")
```

**When to use:** Many categorical levels, some rare
**Pros:** Reduces dimensionality, improves generalization
**Cons:** Loses information about rare categories

### `step_ordinalscore()`
Convert ordered factors to numeric scores.

```r
recipe(outcome ~ ., data = train) |>
  step_ordinalscore(education_level)  # e.g., HS=1, College=2, PhD=3
```

**When to use:** Ordinal categories
**Pros:** Preserves ordering, reduces dimensionality
**Cons:** Assumes equal spacing

### `step_integer()`
Convert factors to integers (non-ordinal).

```r
recipe(outcome ~ ., data = train) |>
  step_integer(color, zero_based = TRUE)
```

**When to use:** Tree-based models
**Pros:** Compact representation
**Cons:** Implies ordering where none exists

### `step_lencode_glm()` / `step_lencode_bayes()` / `step_lencode_mixed()`
Target/likelihood encoding.

```r
library(embed)
recipe(outcome ~ ., data = train) |>
  embed::step_lencode_mixed(neighborhood, outcome = vars(sale_price))
```

**When to use:** High-cardinality categorical variables
**Pros:** Captures category-outcome relationship
**Cons:** Risk of overfitting, requires careful cross-validation

**Package:** `embed`

---

## Numeric Transformations

### `step_log()`
Log transformation.

```r
recipe(outcome ~ ., data = train) |>
  step_log(sale_price, lot_area, base = 10, offset = 1)
```

**When to use:** Right-skewed distributions, multiplicative relationships
**Pros:** Reduces skewness, stabilizes variance
**Cons:** Cannot handle zero or negative values (use offset)

### `step_sqrt()`
Square root transformation.

```r
recipe(outcome ~ ., data = train) |>
  step_sqrt(count_variable)
```

**When to use:** Count data, moderate skewness
**Pros:** Milder than log
**Cons:** Still cannot handle negative values

### `step_inverse()`
Inverse transformation (1/x).

```r
recipe(outcome ~ ., data = train) |>
  step_inverse(rate)
```

**When to use:** Rate data, specific distributional requirements
**Pros:** Can normalize certain distributions
**Cons:** Creates issues with zeros

### `step_logit()`
Logit transformation for proportions.

```r
recipe(outcome ~ ., data = train) |>
  step_logit(proportion, offset = 0.001)
```

**When to use:** Proportion/percentage data (0-1)
**Pros:** Unbounds proportions
**Cons:** Requires values strictly between 0 and 1

### `step_BoxCox()`
Box-Cox power transformation.

```r
recipe(outcome ~ ., data = train) |>
  step_BoxCox(all_numeric_predictors())
```

**When to use:** Automatically find best transformation
**Pros:** Data-driven, flexible
**Cons:** Only for positive values, can be unstable

### `step_YeoJohnson()`
Yeo-Johnson transformation (works with negative values).

```r
recipe(outcome ~ ., data = train) |>
  step_YeoJohnson(all_numeric_predictors())
```

**When to use:** Like Box-Cox but allows zero/negative values
**Pros:** More flexible than Box-Cox
**Cons:** Can be computationally expensive

---

## Normalization and Scaling

### `step_normalize()`
Z-score standardization (mean=0, sd=1).

```r
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors())
```

**When to use:** Most models (SVM, neural nets, regularized regression)
**Pros:** Standard approach, preserves distribution shape
**Cons:** Sensitive to outliers

**When NOT to use:** Tree-based models (RF, XGBoost) - they don't need scaling

### `step_range()`
Min-max scaling to [0, 1] or custom range.

```r
recipe(outcome ~ ., data = train) |>
  step_range(all_numeric_predictors(), min = 0, max = 1)
```

**When to use:** Neural networks, bounded algorithms
**Pros:** Bounded output
**Cons:** Very sensitive to outliers

### `step_center()`
Center to mean=0 without scaling.

```r
recipe(outcome ~ ., data = train) |>
  step_center(all_numeric_predictors())
```

**When to use:** Interpretation, PCA preparation
**Pros:** Interpretable
**Cons:** Doesn't handle scale differences

### `step_scale()`
Scale to sd=1 without centering.

```r
recipe(outcome ~ ., data = train) |>
  step_scale(all_numeric_predictors())
```

**When to use:** Rarely on its own (usually with `step_center()`)
**Pros:** Handles scale differences
**Cons:** Incomplete without centering

**Note:** `step_normalize() = step_center() |> step_scale()`

---

## Feature Selection and Filtering

### `step_zv()`
Remove zero-variance predictors.

```r
recipe(outcome ~ ., data = train) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors())
```

**When to use:** ALWAYS, after dummy encoding
**Pros:** Removes useless features
**Cons:** None

**Critical:** Run AFTER `step_dummy()` (dummy encoding can create zero-variance)

### `step_nzv()`
Remove near-zero-variance predictors.

```r
recipe(outcome ~ ., data = train) |>
  step_nzv(all_predictors(), freq_cut = 95/5, unique_cut = 10)
```

**When to use:** Remove nearly constant features
**Pros:** Reduces noise
**Cons:** May remove useful rare events

### `step_corr()`
Remove highly correlated predictors.

```r
recipe(outcome ~ ., data = train) |>
  step_corr(all_numeric_predictors(), threshold = 0.9)
```

**When to use:** Reduce multicollinearity
**Pros:** Improves model stability
**Cons:** May remove useful features, arbitrary threshold

**Note:** Run AFTER normalization

### `step_lincomb()`
Remove linear combinations.

```r
recipe(outcome ~ ., data = train) |>
  step_lincomb(all_numeric_predictors())
```

**When to use:** Perfect multicollinearity
**Pros:** Prevents matrix singularity
**Cons:** Rare in practice

### `step_rm()`
Manually remove specific variables.

```r
recipe(outcome ~ ., data = train) |>
  step_rm(id, timestamp, internal_id)
```

**When to use:** Known non-predictive variables
**Pros:** Explicit control
**Cons:** Manual specification

**Alternative:** Use `update_role()` instead to preserve for later use

---

## Dimensionality Reduction

### `step_pca()`
Principal Component Analysis.

```r
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>  # Required first!
  step_pca(all_numeric_predictors(), num_comp = 10)
```

**When to use:** Many correlated features, visualization
**Pros:** Reduces dimensionality, removes correlation
**Cons:** Loses interpretability, requires scaling first

**Options:**
- `num_comp`: Number of components
- `threshold`: Variance threshold (e.g., 0.95)

### `step_ica()`
Independent Component Analysis.

```r
library(embed)
recipe(outcome ~ ., data = train) |>
  embed::step_ica(all_numeric_predictors(), num_comp = 5)
```

**When to use:** Non-Gaussian data, blind source separation
**Pros:** Finds independent sources
**Cons:** Computationally expensive

**Package:** `embed`

### `step_umap()`
UMAP (Uniform Manifold Approximation and Projection).

```r
library(embed)
recipe(outcome ~ ., data = train) |>
  embed::step_umap(all_numeric_predictors(), num_comp = 2, neighbors = 15)
```

**When to use:** Non-linear dimensionality reduction, visualization
**Pros:** Preserves local + global structure
**Cons:** Non-deterministic, requires tuning

**Package:** `embed`

### `step_kpca()`
Kernel PCA.

```r
library(embed)
recipe(outcome ~ ., data = train) |>
  embed::step_kpca(all_numeric_predictors(), num_comp = 5, kernel = "rbfdot")
```

**When to use:** Non-linear relationships
**Pros:** Captures non-linearity
**Cons:** Computationally expensive

**Package:** `embed`

---

## Class Imbalance

**Package:** `themis`

### `step_upsample()`
Upsample minority class(es) by random duplication.

```r
library(themis)
recipe(class ~ ., data = train) |>
  themis::step_upsample(class, over_ratio = 0.8)
```

**When to use:** Imbalanced classification
**Pros:** Simple, fast
**Cons:** Duplicates exact observations (overfitting risk)

**Options:**
- `over_ratio = 0.8`: Minority class will be 80% of majority class size
- `over_ratio = 1.0`: Perfect balance

### `step_downsample()`
Downsample majority class(es).

```r
library(themis)
recipe(class ~ ., data = train) |>
  themis::step_downsample(class, under_ratio = 1.2)
```

**When to use:** Imbalanced classification with large dataset
**Pros:** Fast, no data duplication
**Cons:** Throws away data

### `step_smote()`
Synthetic Minority Over-sampling Technique.

```r
library(themis)
recipe(class ~ ., data = train) |>
  themis::step_smote(class, over_ratio = 0.8, neighbors = 5)
```

**When to use:** Imbalanced classification
**Pros:** Creates synthetic examples (less overfitting)
**Cons:** Can create unrealistic examples

**Most popular approach**

### `step_rose()`
Random Over-Sampling Examples.

```r
library(themis)
recipe(class ~ ., data = train) |>
  themis::step_rose(class)
```

**When to use:** Imbalanced classification
**Pros:** Smooth synthetic generation
**Cons:** Can blur class boundaries

### `step_adasyn()`
Adaptive Synthetic Sampling.

```r
library(themis)
recipe(class ~ ., data = train) |>
  themis::step_adasyn(class, over_ratio = 0.8, neighbors = 5)
```

**When to use:** Imbalanced classification with focus on hard examples
**Pros:** Focuses on difficult cases
**Cons:** More complex

**Critical:** Apply balancing steps BEFORE dummy encoding!

---

## Text Processing

**Package:** `textrecipes`

### `step_tokenize()`
Split text into tokens.

```r
library(textrecipes)
recipe(sentiment ~ review, data = train) |>
  textrecipes::step_tokenize(review)
```

**When to use:** All text preprocessing
**Pros:** Foundation for text features
**Cons:** Requires choosing tokenization method

### `step_stopwords()`
Remove stop words.

```r
library(textrecipes)
recipe(sentiment ~ review, data = train) |>
  textrecipes::step_tokenize(review) |>
  textrecipes::step_stopwords(review, language = "en")
```

**When to use:** Remove common uninformative words
**Pros:** Reduces noise
**Cons:** May remove useful context

### `step_stem()`
Stem words to root form.

```r
library(textrecipes)
recipe(sentiment ~ review, data = train) |>
  textrecipes::step_tokenize(review) |>
  textrecipes::step_stem(review)
```

**When to use:** Reduce vocabulary size
**Pros:** Normalizes variations
**Cons:** Loses some meaning (running → run)

### `step_tf()` / `step_tfidf()`
Term frequency or TF-IDF features.

```r
library(textrecipes)
recipe(sentiment ~ review, data = train) |>
  textrecipes::step_tokenize(review) |>
  textrecipes::step_tf(review, max_tokens = 100)

# Or with TF-IDF weighting
recipe(sentiment ~ review, data = train) |>
  textrecipes::step_tokenize(review) |>
  textrecipes::step_tfidf(review, max_tokens = 100)
```

**When to use:** Text classification
**Pros:** Standard text features
**Cons:** High dimensionality

### `step_word_embeddings()`
Pretrained word embeddings.

```r
library(textrecipes)
recipe(sentiment ~ review, data = train) |>
  textrecipes::step_tokenize(review) |>
  textrecipes::step_word_embeddings(review, embeddings = glove_embeddings)
```

**When to use:** Semantic text features
**Pros:** Captures meaning
**Cons:** Requires pretrained embeddings

### `step_texthash()`
Feature hashing for text.

```r
library(textrecipes)
recipe(sentiment ~ review, data = train) |>
  textrecipes::step_tokenize(review) |>
  textrecipes::step_texthash(review, signed = FALSE, num_terms = 1024)
```

**When to use:** Large vocabulary, fast processing
**Pros:** Fixed dimensionality, fast
**Cons:** Hash collisions, no interpretability

---

## Date and Time Features

### `step_date()`
Extract date features.

```r
recipe(outcome ~ ., data = train) |>
  step_date(transaction_date, features = c("dow", "month", "year", "doy"))
```

**When to use:** Date variables
**Pros:** Captures temporal patterns
**Cons:** None

**Features:**
- `dow`: Day of week (1-7)
- `month`: Month (1-12)
- `year`: Year
- `doy`: Day of year (1-365)
- `week`: Week of year
- `quarter`: Quarter (1-4)

### `step_holiday()`
Create holiday indicators.

```r
library(timeDate)
recipe(outcome ~ ., data = train) |>
  step_holiday(transaction_date, holidays = timeDate::listHolidays("US"))
```

**When to use:** Holidays affect outcome
**Pros:** Captures special events
**Cons:** Requires holiday calendar

### `step_time()`
Extract time-of-day features.

```r
recipe(outcome ~ ., data = train) |>
  step_time(timestamp, features = c("hour", "minute"))
```

**When to use:** Timestamp variables
**Pros:** Intraday patterns
**Cons:** Limited features

---

## Advanced Steps

### `step_spatialsign()`
Project predictors onto unit sphere.

```r
recipe(outcome ~ ., data = train) |>
  step_normalize(all_numeric_predictors()) |>
  step_spatialsign(all_numeric_predictors())
```

**When to use:** Remove outlier influence
**Pros:** Robust normalization
**Cons:** Loses magnitude information

### `step_depth()`
Data depth metrics.

```r
library(embed)
recipe(outcome ~ ., data = train) |>
  embed::step_depth(all_predictors(), class = "outcome", metric = "spatial")
```

**When to use:** Outlier-robust features
**Pros:** Robust
**Cons:** Computationally expensive

**Package:** `embed`

### `step_ns()` (natural splines)
Smooth curves for continuous predictors.

```r
recipe(outcome ~ ., data = train) |>
  step_ns(age, deg_free = 4)
```

**When to use:** Non-linear smooth relationships
**Pros:** Flexible, smooth
**Cons:** Requires choosing degrees of freedom

### `step_discretize()`
Bin continuous variables.

```r
recipe(outcome ~ ., data = train) |>
  step_discretize(age, num_breaks = 5, min_unique = 10)
```

**When to use:** Convert continuous to categorical
**Pros:** Captures non-linear effects simply
**Cons:** Loses information, arbitrary bins

---

## Step Order Guidelines

**Critical ordering rules:**

```r
recipe(outcome ~ ., data = train) |>

  # 1. UPDATE ROLES
  update_role(id, new_role = "ID") |>

  # 2. HANDLE MISSING DATA
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>

  # 3. FEATURE CREATION (before transformations)
  step_mutate(...) |>
  step_interact(...) |>

  # 4. TRANSFORMATIONS
  step_log(...) |>
  step_BoxCox(...) |>

  # 5. CLASS IMBALANCE (before encoding)
  themis::step_smote(outcome) |>

  # 6. HANDLE NOVEL LEVELS (before dummy)
  step_novel(all_nominal_predictors()) |>
  step_unknown(all_nominal_predictors()) |>

  # 7. POOL RARE CATEGORIES (before dummy)
  step_other(all_nominal_predictors(), threshold = 0.05) |>

  # 8. ENCODE CATEGORICAL
  step_dummy(all_nominal_predictors()) |>

  # 9. REMOVE PROBLEMATIC PREDICTORS (after dummy)
  step_zv(all_predictors()) |>
  step_nzv(all_predictors()) |>

  # 10. NORMALIZE (after dummy, before PCA)
  step_normalize(all_numeric_predictors()) |>

  # 11. REMOVE CORRELATIONS (after normalize)
  step_corr(all_numeric_predictors(), threshold = 0.9) |>

  # 12. DIMENSIONALITY REDUCTION (last)
  step_pca(all_numeric_predictors(), threshold = 0.95)
```

**Why order matters:**

1. **Imputation first** - Many steps can't handle NAs
2. **Transform before normalize** - Normalization assumes distribution shape
3. **Class balance before encoding** - Sampling works better on original data
4. **Novel levels before dummy** - Prevents errors
5. **Dummy before zero-variance** - Dummy encoding creates zero-variance predictors
6. **Normalize before PCA/correlations** - These require same scale
7. **Feature selection last** - After all feature creation is done

**Common mistakes:**
- ❌ Normalizing before creating dummies
- ❌ Creating interactions after removing zero-variance
- ❌ Applying class balancing after dummy encoding
- ❌ PCA before normalization
- ❌ Forgetting `step_novel()` before `step_dummy()`
- ❌ Not removing zero-variance after dummy encoding

**When in doubt:** Follow the order in the example above.
