# R Data Science Skill

Expert R data science using tidyverse for data wrangling and tidymodels for machine learning.

## Overview

This skill provides comprehensive guidance for data science tasks in R, covering:
- Data wrangling and transformation (dplyr, tidyr)
- Machine learning workflows (tidymodels)
- Statistical modeling and inference
- Feature engineering and preprocessing
- Model evaluation and selection
- Best practices for reproducible analysis

## When to Use

Use this skill when you need to:
- Wrangle, clean, or transform data
- Build predictive models or classifiers
- Perform statistical analysis or hypothesis testing
- Engineer features for machine learning
- Evaluate and compare models
- Create reproducible data science workflows

## Invocation

**Manual**: `/r-datascience`
**Automatic**: Mention "tidyverse", "dplyr", "tidymodels", "data wrangling", "machine learning", "statistical modeling", etc.

## Quick Start

### Data Wrangling
```r
library(tidyverse)

clean_data <- raw_data |>
  filter(!is.na(key_var)) |>
  mutate(new_var = if_else(condition, value1, value2)) |>
  group_by(category) |>
  summarize(
    mean_val = mean(value),
    sd_val = sd(value),
    n = n()
  ) |>
  arrange(desc(mean_val))
```

### Machine Learning
```r
library(tidymodels)

# Split
set.seed(123)
split <- initial_split(data, prop = 0.75, strata = outcome)
train <- training(split)
test <- testing(split)

# Recipe
rec <- recipe(outcome ~ ., data = train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

# Model
rf_spec <- rand_forest(trees = 1000) |>
  set_engine("ranger") |>
  set_mode("classification")

# Workflow
wf <- workflow() |>
  add_recipe(rec) |>
  add_model(rf_spec)

# Fit and evaluate
final_fit <- last_fit(wf, split)
collect_metrics(final_fit)
```

### Statistical Modeling
```r
# Linear regression
model <- lm(y ~ x1 + x2 + x1:x2, data = data)

# Diagnostics
plot(model)

# Tidy output
library(broom)
tidy(model, conf.int = TRUE)
glance(model)
```

## Key Features

### Data Manipulation (dplyr)
- **Five core verbs**: filter, select, arrange, mutate, summarize
- **Grouped operations**: group_by for split-apply-combine
- **Joins**: left_join, inner_join, anti_join, etc.
- **Window functions**: lag, lead, cumsum, ranking

### Data Reshaping (tidyr)
- **Pivoting**: pivot_longer (wide→long), pivot_wider (long→wide)
- **Separation**: separate (split columns), unite (combine columns)
- **Completion**: complete (fill missing combinations), fill (propagate values)

### Machine Learning (tidymodels)
- **Preprocessing**: recipes with step_* functions
- **Model specification**: parsnip unified interface
- **Workflows**: combine recipe + model
- **Tuning**: grid search, Bayesian optimization
- **Evaluation**: cross-validation, metrics, confusion matrices

### Statistical Inference
- **Linear models**: lm, glm for regression/classification
- **ANOVA**: aov for group comparisons
- **Hypothesis tests**: t-tests, chi-square, non-parametric
- **Mixed models**: lmer for hierarchical/repeated measures
- **Regularization**: Ridge, Lasso, Elastic Net

### Feature Engineering
- **Missing values**: Imputation (mean, median, KNN, bagging)
- **Encoding**: Dummy variables, ordinal, target encoding
- **Transformations**: Normalize, log, Box-Cox, Yeo-Johnson
- **Feature creation**: Interactions, polynomials, splines, date features
- **Dimensionality reduction**: PCA, ICA, UMAP
- **Class imbalance**: SMOTE, downsampling, upsampling

## Contents

### Main Skill File
- **SKILL.md**: Complete data science guide with workflows and task dispatch

### References
- **data-wrangling.md**: dplyr and tidyr reference (select, filter, mutate, pivot, etc.)
- **feature-engineering.md**: recipes and preprocessing steps
- **statistical-modeling.md**: Linear models, GLMs, hypothesis tests, mixed models

## Common Workflows

### Exploratory Data Analysis
1. Import data (`read_csv()`)
2. Inspect structure (`glimpse()`, `summary()`, `skimr::skim()`)
3. Visualize distributions (histograms, boxplots)
4. Check missing values (`naniar::vis_miss()`)
5. Explore relationships (scatterplots, correlations)

### Predictive Modeling
1. Split data (stratified train/test)
2. Create preprocessing recipe
3. Specify multiple models
4. Cross-validate to compare
5. Tune hyperparameters for best model
6. Evaluate on test set
7. Deploy production model

### Statistical Analysis
1. Visualize data
2. State hypotheses
3. Check assumptions
4. Fit appropriate model/test
5. Diagnose residuals
6. Interpret results with effect sizes and CIs
7. Report findings

## Model Selection Guide

| Task | Simple Baseline | Production Model |
|------|-----------------|------------------|
| **Classification** | Logistic Regression, Naive Bayes | Random Forest, XGBoost |
| **Regression** | Linear Regression | Random Forest, XGBoost |
| **Imbalanced** | SMOTE + Logistic | Weighted XGBoost |
| **High-dimensional** | Ridge/Lasso | Elastic Net, XGBoost |
| **Interpretability** | Linear/Logistic + Lasso | GAM, Decision Tree |

## Best Practices

### Data Wrangling
✅ Use native pipe (`|>`) for readability
✅ Handle missing values explicitly
✅ Verify joins don't create unexpected rows
✅ Use `count()` instead of `group_by() + summarise(n())`
✅ Always `ungroup()` after grouped operations

### Machine Learning
✅ Set seed for reproducibility
✅ Use stratified splits for classification
✅ Preprocess within CV folds (no data leakage)
✅ Start with simple baseline model
✅ Try multiple models, compare rigorously
✅ Tune hyperparameters on CV, evaluate on test
✅ Check for class imbalance
✅ Monitor for overfitting

### Statistical Modeling
✅ Visualize before modeling
✅ Check model assumptions (residual plots)
✅ Report effect sizes and confidence intervals
✅ Consider domain knowledge in interpretation
✅ Use robust methods when assumptions violated
✅ Check for influential observations and multicollinearity

## Integration with Other Skills

- **ggplot2**: For data visualization
- **r-tidymodels**: For advanced ML workflows
- **r-timeseries**: For temporal data analysis
- **r-text-mining**: For text data analysis
- **r-style-guide**: For code formatting
- **tidyverse-patterns**: For advanced tidyverse patterns
- **tdd-workflow**: For testing data pipelines

## Common Issues

**Low model accuracy**:
- Check data quality (missing, outliers)
- Try different feature representations
- Handle class imbalance
- Use more complex model
- Get more training data

**Overfitting**:
- Use regularization
- Simpler model
- More training data
- Better cross-validation

**Violated assumptions**:
- Transform variables
- Use robust methods
- Use non-parametric tests
- Consider GLM instead of linear model

## Resources

### External Documentation
- [R for Data Science](https://r4ds.had.co.nz/)
- [Tidymodels](https://www.tidymodels.org/)
- [Modern Data Science with R](https://mdsr-book.github.io/)
- [ISLR](https://www.statlearning.com/)

### Internal References
See `references/` directory for detailed guides on wrangling, feature engineering, and statistical modeling.

## Tips

### For Data Wrangling
- Use `glimpse()` and `summary()` to understand data structure
- Use `count()` to explore categorical variables
- Use `across()` for operations on multiple columns
- Check join keys before merging datasets

### For Machine Learning
- Always validate on held-out test set
- Use cross-validation for model selection, not test set
- Preprocess consistently with recipes
- Start simple, add complexity as needed
- Feature engineering often beats complex models

### For Statistical Modeling
- Check assumptions before interpreting
- Use diagnostic plots to identify issues
- Consider effect sizes, not just p-values
- Standardize predictors for comparing effects
- Cross-validate for predictive performance

## Version

1.0.0 - Initial release

## Feedback

For issues or suggestions, consult the main skill documentation or CLAUDE.md in the project root.
