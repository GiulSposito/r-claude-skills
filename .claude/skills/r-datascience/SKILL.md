---
name: r-datascience
description: Expert R data science using tidyverse and tidymodels. Use when working with data in R, mentions "tidyverse", "dplyr", "data wrangling", "machine learning", "statistical modeling", "ggplot2", "data visualization", "predictive modeling", "feature engineering", "model training", "cross-validation", or any data science task in R.
version: 1.0.0
user-invocable: true
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---

# R Data Science Expert

You are an expert in data science using R's tidyverse and tidymodels ecosystems, with deep knowledge of statistical learning, machine learning, and data analysis.

## Core Philosophy

1. **Tidy Data Principles**: Organize data for analysis (one observation per row, one variable per column)
2. **Functional Programming**: Use pipes, map functions, and composition for clarity
3. **Visualization First**: Explore data visually before modeling
4. **Model Pluralism**: Fit multiple models, compare rigorously
5. **Reproducibility**: Document workflow, set seeds, version data

## When This Skill Activates

Use this skill when:
- Performing data analysis, exploration, or wrangling
- Building predictive models or statistical learning
- Creating data visualizations with ggplot2
- Working with tidyverse or tidymodels packages
- Developing machine learning workflows
- Statistical modeling (regression, classification, clustering)
- Feature engineering and data preprocessing
- Model evaluation and selection

## Task Classification & Dispatch

### 1. Data Wrangling & Transformation
**Triggers**: "clean data", "reshape", "pivot", "join", "filter", "mutate", "dplyr", "tidyr"

**Workflow**:
1. Import data with readr
2. Explore structure and quality
3. Transform with dplyr (filter, mutate, summarize, group_by)
4. Reshape with tidyr (pivot_longer, pivot_wider)
5. Join/combine datasets

**See**: [references/data-wrangling.md](references/data-wrangling.md)

### 2. Data Visualization
**Triggers**: "plot", "visualize", "chart", "graph", "ggplot2", "geom_"

**Workflow**:
1. Choose appropriate plot type for data
2. Map aesthetics (x, y, color, size, etc.)
3. Add geometric layers (geom_point, geom_line, etc.)
4. Customize scales, themes, labels
5. Create multi-panel plots with facets

**See**: ggplot2 skill for comprehensive guidance

### 3. Machine Learning & Predictive Modeling
**Triggers**: "predict", "classify", "machine learning", "model training", "cross-validation", "tidymodels"

**Workflow**:
1. Split data (training/testing, cross-validation)
2. Create preprocessing recipe (feature engineering)
3. Specify model(s) with parsnip
4. Create workflow
5. Tune hyperparameters if needed
6. Evaluate and select best model
7. Final fit and prediction

**See**: r-tidymodels skill for ML-specific guidance

### 4. Statistical Modeling
**Triggers**: "linear regression", "logistic regression", "hypothesis test", "ANOVA", "GLM"

**Workflow**:
1. Exploratory data analysis
2. Check assumptions (normality, homoscedasticity, independence)
3. Fit model
4. Diagnose residuals
5. Interpret coefficients and p-values
6. Assess model fit (R², AIC, etc.)

**See**: [references/statistical-modeling.md](references/statistical-modeling.md)

### 5. Feature Engineering
**Triggers**: "feature", "preprocess", "encode", "normalize", "recipe", "step_"

**Workflow**:
1. Handle missing values
2. Encode categorical variables (dummy, one-hot)
3. Transform numeric features (normalize, log, box-cox)
4. Create interactions
5. Reduce dimensionality (PCA)
6. Handle class imbalance

**See**: [references/feature-engineering.md](references/feature-engineering.md)

## Quick Start Workflows

### Data Analysis Pipeline

```r
library(tidyverse)

# 1. Import
data <- read_csv("data.csv")

# 2. Explore
glimpse(data)
summary(data)
skimr::skim(data)

# 3. Wrangle
clean_data <- data %>%
  filter(!is.na(key_var)) %>%
  mutate(
    new_var = case_when(
      condition1 ~ value1,
      condition2 ~ value2,
      TRUE ~ default
    )
  ) %>%
  group_by(group_var) %>%
  summarize(
    mean_val = mean(numeric_var),
    n = n()
  )

# 4. Visualize
ggplot(clean_data, aes(x, y, color = group)) +
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~category) +
  theme_minimal()
```

### Machine Learning Pipeline

```r
library(tidymodels)

# 1. Split
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train <- training(data_split)
test <- testing(data_split)

# 2. Recipe
rec <- recipe(outcome ~ ., data = train) %>%
  step_impute_median(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_zv(all_predictors())

# 3. Model specification
rf_spec <- rand_forest(trees = 1000, mtry = tune(), min_n = tune()) %>%
  set_engine("ranger") %>%
  set_mode("classification")

# 4. Workflow
rf_wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(rf_spec)

# 5. Tuning
cv_folds <- vfold_cv(train, v = 10, strata = outcome)
rf_grid <- grid_regular(mtry(range = c(1, 10)), min_n(), levels = 5)

rf_tuned <- tune_grid(
  rf_wf,
  resamples = cv_folds,
  grid = rf_grid,
  metrics = metric_set(accuracy, roc_auc)
)

# 6. Finalize
best_params <- select_best(rf_tuned, metric = "roc_auc")
final_wf <- finalize_workflow(rf_wf, best_params)
final_fit <- last_fit(final_wf, data_split)

# 7. Evaluate
collect_metrics(final_fit)
collect_predictions(final_fit) %>%
  conf_mat(truth = outcome, estimate = .pred_class)
```

### Statistical Modeling

```r
library(tidyverse)
library(broom)

# 1. Fit model
model <- lm(y ~ x1 + x2 + x1:x2, data = data)

# 2. Tidy output
tidy(model, conf.int = TRUE)
glance(model)
augment(model)

# 3. Diagnostics
par(mfrow = c(2, 2))
plot(model)

# 4. Predictions
new_data <- tibble(x1 = c(1, 2, 3), x2 = c(10, 20, 30))
predict(model, newdata = new_data, interval = "prediction")
```

## Core Tidyverse Patterns

### dplyr: Data Manipulation

```r
# Select columns
data %>% select(var1, var2, starts_with("prefix"))

# Filter rows
data %>% filter(var1 > 10, var2 %in% c("A", "B"))

# Create/modify columns
data %>% mutate(
  new_var = var1 + var2,
  var1_scaled = scale(var1)
)

# Grouped operations
data %>%
  group_by(group) %>%
  summarize(
    mean_val = mean(value),
    sd_val = sd(value),
    n = n()
  )

# Arrange rows
data %>% arrange(desc(var1))

# Count occurrences
data %>% count(category, sort = TRUE)
```

### tidyr: Reshaping

```r
# Pivot longer (wide to long)
data %>%
  pivot_longer(
    cols = starts_with("year_"),
    names_to = "year",
    values_to = "value"
  )

# Pivot wider (long to wide)
data %>%
  pivot_wider(
    names_from = category,
    values_from = value
  )

# Separate columns
data %>% separate(col, into = c("part1", "part2"), sep = "_")

# Unite columns
data %>% unite(new_col, col1, col2, sep = "_")

# Nesting
data %>%
  nest(data = c(col1, col2))
```

### purrr: Functional Programming

```r
# Map over vectors
map(1:3, ~rnorm(10, mean = .x))
map_dbl(list(a = 1:5, b = 6:10), mean)
map_df(files, read_csv)

# Map over multiple inputs
map2(list1, list2, ~.x + .y)
pmap(list(x = 1:3, y = 4:6), ~.x + .y)

# Conditional mapping
map_if(data_list, is.numeric, log)

# Reduce
reduce(list(df1, df2, df3), left_join)

# Safely handle errors
safe_log <- safely(log)
map(list(1, "a", -1), safe_log)
```

## Tidymodels Workflow

### Complete ML Pipeline

```r
library(tidymodels)

# 1. Data budget
set.seed(123)
split <- initial_split(data, prop = 0.8, strata = outcome)
train <- training(split)
test <- testing(split)

# 2. Preprocessing recipe
rec <- recipe(outcome ~ ., data = train) %>%
  # Missing values
  step_impute_knn(all_numeric_predictors()) %>%
  step_unknown(all_nominal_predictors()) %>%

  # Encoding
  step_dummy(all_nominal_predictors(), one_hot = FALSE) %>%

  # Transformations
  step_normalize(all_numeric_predictors()) %>%
  step_YeoJohnson(all_numeric_predictors()) %>%

  # Feature selection
  step_zv(all_predictors()) %>%
  step_corr(all_numeric_predictors(), threshold = 0.9)

# 3. Model specifications
models <- list(
  logistic = logistic_reg() %>% set_engine("glm"),
  ridge = logistic_reg(penalty = tune(), mixture = 0) %>% set_engine("glmnet"),
  lasso = logistic_reg(penalty = tune(), mixture = 1) %>% set_engine("glmnet"),
  rf = rand_forest(trees = 1000, mtry = tune()) %>% set_engine("ranger"),
  xgb = boost_tree(trees = tune(), tree_depth = tune()) %>% set_engine("xgboost")
)

# 4. Workflows
workflows <- map(models, ~workflow() %>% add_recipe(rec) %>% add_model(.x))

# 5. Cross-validation
cv_folds <- vfold_cv(train, v = 10, strata = outcome)

# 6. Tune (for models with tune())
tune_results <- map(workflows[2:5], ~{
  tune_grid(
    .x,
    resamples = cv_folds,
    grid = 10,
    metrics = metric_set(roc_auc, accuracy)
  )
})

# 7. Compare
compare_models <- map_df(tune_results, show_best, n = 1, .id = "model")

# 8. Finalize best
best_model_name <- compare_models %>% slice_max(mean) %>% pull(model)
best_params <- tune_results[[best_model_name]] %>% select_best(metric = "roc_auc")
final_wf <- finalize_workflow(workflows[[best_model_name]], best_params)

# 9. Final fit
final_fit <- last_fit(final_wf, split)
collect_metrics(final_fit)

# 10. Deploy
prod_model <- fit(final_wf, data)
saveRDS(prod_model, "model.rds")
```

### Recipe Step Categories

**Missing Values**:
- `step_impute_mean()`, `step_impute_median()`, `step_impute_mode()`
- `step_impute_knn()`, `step_impute_bag()`
- `step_unknown()` - Create "unknown" level for factors

**Encoding**:
- `step_dummy()` - One-hot encoding
- `step_ordinalscore()` - Ordinal encoding
- `step_bin2factor()` - Binary to factor

**Transformations**:
- `step_log()`, `step_sqrt()`, `step_inverse()`
- `step_BoxCox()`, `step_YeoJohnson()`
- `step_normalize()` - Center and scale
- `step_range()` - Scale to [0, 1]

**Feature Engineering**:
- `step_interact()` - Interaction terms
- `step_poly()` - Polynomial features
- `step_ns()`, `step_bs()` - Splines
- `step_date()` - Extract date components
- `step_holiday()` - Holiday indicators

**Dimensionality Reduction**:
- `step_pca()` - Principal components
- `step_ica()` - Independent components
- `step_umap()` - UMAP projection

**Feature Selection**:
- `step_zv()` - Remove zero-variance
- `step_nzv()` - Remove near-zero variance
- `step_corr()` - Remove correlated features
- `step_lincomb()` - Remove linear combinations

**Class Imbalance**:
- `step_downsample()` - Reduce majority class
- `step_upsample()` - Duplicate minority class
- `step_smote()` - Synthetic minority oversampling
- `step_rose()` - Random oversampling

## Model Selection Guide

### Classification Models

| Model | Pros | Cons | Use When |
|-------|------|------|----------|
| **Logistic Regression** | Interpretable, fast, probabilistic | Linear boundary | Baseline, interpretability |
| **Ridge/Lasso** | Regularized, handles multicollinearity | Still linear | Many features, some redundant |
| **Naive Bayes** | Fast, probabilistic | Independence assumption | High-dimensional, baseline |
| **Decision Trees** | Interpretable, non-linear | Unstable, overfits | Interpretability needed |
| **Random Forest** | Robust, accurate, feature importance | Slow, black box | General purpose, high accuracy |
| **XGBoost** | State-of-art, fast | Many hyperparameters | Competition, production |
| **SVM** | Handles high-dim | Slow on large data | Text, image data |
| **Neural Networks** | Very flexible | Needs lots of data | Large datasets, complex patterns |

### Regression Models

| Model | Pros | Cons | Use When |
|-------|------|------|----------|
| **Linear Regression** | Interpretable, simple | Assumes linearity | Baseline, simple relationships |
| **Ridge/Lasso/Elastic Net** | Regularized | Still linear | Many features |
| **Decision Trees** | Non-linear, interpretable | Unstable | Non-linear patterns |
| **Random Forest** | Accurate, robust | Black box | General purpose |
| **XGBoost** | State-of-art | Complex tuning | Competition |
| **GAM** | Smooth non-linearity, interpretable | Slower | Non-linear but need interpretability |
| **Neural Networks** | Very flexible | Complex, needs data | Large data, complex patterns |

### Clustering

| Algorithm | Best For |
|-----------|----------|
| **K-means** | Spherical clusters, large data |
| **Hierarchical** | Unknown k, dendrogram visualization |
| **DBSCAN** | Arbitrary shapes, noise handling |
| **Gaussian Mixture** | Probabilistic clusters |

## Statistical Inference

### Hypothesis Testing

```r
# T-tests
t.test(x, y)  # Two-sample
t.test(x, mu = 0)  # One-sample

# ANOVA
aov(y ~ group, data = data)
summary(aov_model)
TukeyHSD(aov_model)  # Post-hoc

# Chi-square test
chisq.test(table(data$var1, data$var2))

# Correlation
cor.test(x, y, method = "pearson")
cor.test(x, y, method = "spearman")

# Non-parametric tests
wilcox.test(x, y)  # Mann-Whitney
kruskal.test(y ~ group, data = data)  # Kruskal-Wallis
```

### Linear Models

```r
# Simple linear regression
lm(y ~ x, data = data)

# Multiple regression
lm(y ~ x1 + x2 + x3, data = data)

# Interactions
lm(y ~ x1 * x2, data = data)  # Expands to x1 + x2 + x1:x2

# Polynomials
lm(y ~ poly(x, 2), data = data)

# Logistic regression
glm(y ~ x1 + x2, data = data, family = binomial)

# Poisson regression
glm(count ~ x1 + x2, data = data, family = poisson)

# Model comparison
anova(model1, model2)
AIC(model1, model2)
BIC(model1, model2)
```

## Best Practices

### Data Wrangling

✅ **Always** check data types after import (`glimpse()`, `summary()`)
✅ **Always** handle missing values explicitly
✅ **Always** use `group_by()` + `summarize()` for grouped summaries
✅ **Always** verify joins don't create unexpected rows
✅ **Consider** using `count()` instead of `group_by() + summarize(n = n())`
✅ **Consider** using `across()` for operations on multiple columns

### Visualization

✅ **Always** start with simple plots before complex ones
✅ **Always** use appropriate geom for data type
✅ **Always** label axes clearly with units
✅ **Consider** faceting instead of overplotting
✅ **Consider** color for categorical, size for continuous
✅ **Consider** theme_minimal() or theme_bw() for cleaner look

### Machine Learning

✅ **Always** use stratified splits for classification
✅ **Always** use cross-validation for model selection
✅ **Always** preprocess consistently (use recipe)
✅ **Always** tune hyperparameters for final model
✅ **Always** evaluate on held-out test set
✅ **Always** check for data leakage
✅ **Consider** starting with simple baseline model
✅ **Consider** trying multiple models
✅ **Consider** feature engineering before complex models

### Statistical Modeling

✅ **Always** visualize data before modeling
✅ **Always** check model assumptions (residual plots)
✅ **Always** interpret coefficients in context
✅ **Always** report confidence intervals, not just p-values
✅ **Consider** standardizing predictors for interpretation
✅ **Consider** interaction terms for related variables

## Common Pitfalls

❌ **Not setting seed** → Non-reproducible results
✅ Use `set.seed()` before random operations

❌ **Data leakage** → Overoptimistic performance
✅ Preprocess within CV folds, not on full data

❌ **Using test set for model selection** → Invalid inference
✅ Use CV on training data only

❌ **Ignoring class imbalance** → Biased model
✅ Use stratified splits, resampling, or class weights

❌ **Not checking assumptions** → Invalid inference
✅ Check residual plots, normality, homoscedasticity

❌ **Overfitting** → Poor generalization
✅ Use regularization, simpler models, more data

❌ **Multiple comparisons without correction** → Inflated Type I error
✅ Use Bonferroni, FDR, or family-wise error rate control

## Supporting Resources

### Comprehensive References
- **data-wrangling.md**: Complete dplyr/tidyr guide
- **feature-engineering.md**: Recipes and preprocessing
- **statistical-modeling.md**: Linear models, GLMs, inference
- **model-evaluation.md**: Metrics, validation, diagnostics

### Workflow Templates
- **ml-workflow.md**: End-to-end tidymodels template
- **eda-workflow.md**: Exploratory data analysis template

### Complete Examples
- **customer-churn.md**: Classification example
- **house-prices.md**: Regression example

## Quick Reference

### Package Loading
```r
library(tidyverse)      # Data wrangling + viz
library(tidymodels)     # ML workflows
library(broom)          # Tidy model outputs
library(skimr)          # Data summaries
```

### Essential Functions

| Task | Function |
|------|----------|
| Import CSV | `read_csv()` |
| Filter rows | `filter()` |
| Select columns | `select()` |
| Create columns | `mutate()` |
| Summarize | `summarize()` |
| Group | `group_by()` |
| Join | `left_join()`, `inner_join()` |
| Reshape | `pivot_longer()`, `pivot_wider()` |
| Plot | `ggplot() + geom_*()` |
| Model | `lm()`, `glm()` |
| ML workflow | `recipe() + workflow()` |
| Tune | `tune_grid()` |
| Evaluate | `collect_metrics()` |

## Integration with Other Skills

- **ggplot2**: For data visualization
- **r-tidymodels**: For advanced ML workflows
- **r-timeseries**: For temporal data analysis
- **r-text-mining**: For text data analysis
- **r-style-guide**: For code formatting
- **tdd-workflow**: For testing data pipelines

---

**Remember**: Data science is iterative. Explore, model, evaluate, refine. Visualization and domain knowledge are as important as sophisticated algorithms.
