# R Tidymodels Skill

Transform Claude Code into an expert R data scientist specializing in machine learning with the tidymodels ecosystem.

## Overview

This skill provides comprehensive expertise in building, tuning, and deploying machine learning models in R using the tidymodels framework. It covers the complete ML workflow from data preparation through model deployment, following best practices from the official tidymodels documentation and the "Tidy Modeling with R" book.

## When This Skill Activates

Claude will automatically use this skill when you:

- Work with tidymodels packages (recipes, parsnip, tune, workflows)
- Mention **machine learning in R**, predictive modeling, or model development
- Discuss **feature engineering**, preprocessing, or data transformation
- Talk about **model tuning**, hyperparameters, or cross-validation
- Ask about model evaluation, comparison, or deployment
- Use tidymodels-related keywords: SMOTE, recipe steps, parsnip models, etc.

## What This Skill Provides

### 1. Complete ML Workflows

Three-phase approach based on "Tidy Modeling with R":

- **Phase 1: Foundation** - Data splitting, recipes, model specification, basic evaluation
- **Phase 2: Optimization** - Resampling, hyperparameter tuning, model comparison
- **Phase 3: Production** - Ensembles, interpretability, deployment, monitoring

### 2. Dynamic Knowledge Base 🆕

**Hybrid approach combining curated expertise with live reference lookup:**

- **Local knowledge**: ~100 most common recipe steps and ~50 popular models with detailed guidance
- **Dynamic search**: Access to complete tidymodels reference (300+ recipe steps, 160+ models)
- **Smart lookup**: Automatically searches online when you ask about specific functionality not in local knowledge
- **Always current**: Accesses latest tidymodels documentation for new features

**Example:** Ask "What recipe steps are available for handling holidays?" → Gets instant answer from local knowledge. Ask "Show me ALL date-related recipe steps" → Searches complete online catalog and returns comprehensive list.

### 3. Expert Recipe Knowledge

Comprehensive preprocessing with 100+ recipe steps:
- Missing data handling (imputation strategies)
- Feature engineering (interactions, polynomials, splines)
- Categorical encoding (dummy variables, target encoding)
- Transformations (log, Box-Cox, Yeo-Johnson)
- Normalization and scaling
- Feature selection and filtering
- Dimensionality reduction (PCA, UMAP, ICA)
- Class imbalance (SMOTE, upsampling, downsampling)
- Text processing (tokenization, TF-IDF)
- Date/time features

See [Recipe Steps Guide](references/recipe-steps-guide.md) for the complete catalog.

### 3. Model Specification

Unified interface to 50+ model types through parsnip:
- Linear/logistic regression (with regularization)
- Decision trees and random forests
- Gradient boosting (XGBoost, LightGBM)
- Support vector machines
- Neural networks
- Naive Bayes, K-NN, and more

### 4. Tuning Strategies

Multiple hyperparameter optimization approaches:
- **Grid search**: Regular grids, random search, space-filling designs
- **Bayesian optimization**: Efficient for expensive models
- **Simulated annealing**: Global optimization
- **Racing methods**: Early stopping for efficiency

### 5. Production-Ready Patterns

- Model ensembling and stacking
- Variable importance and interpretability
- Probability calibration
- Threshold optimization
- Deployment pipelines with vetiver
- Model monitoring and retraining

## Quick Start

### Example 1: Simple Classification

```r
library(tidymodels)

# Split data
set.seed(123)
split <- initial_split(iris, prop = 0.75, strata = Species)

# Create recipe
rec <- recipe(Species ~ ., data = training(split)) |>
  step_normalize(all_numeric_predictors())

# Specify model
rf_spec <- rand_forest(mtry = tune(), min_n = tune()) |>
  set_engine("ranger") |>
  set_mode("classification")

# Bundle in workflow
wflow <- workflow() |>
  add_recipe(rec) |>
  add_model(rf_spec)

# Tune
folds <- vfold_cv(training(split), v = 10)
results <- wflow |> tune_grid(resamples = folds, grid = 15)

# Finalize and evaluate
best <- select_best(results, metric = "roc_auc")
final_wflow <- finalize_workflow(wflow, best)
final_fit <- last_fit(final_wflow, split)

collect_metrics(final_fit)
```

### Example 2: Regression with Feature Engineering

```r
library(tidymodels)

# Create advanced recipe
rec <- recipe(Sale_Price ~ ., data = ames_train) |>
  step_mutate(House_Age = Year_Sold - Year_Built) |>
  step_log(Sale_Price, Lot_Area, base = 10) |>
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# Compare multiple models
wf_set <- workflow_set(
  preproc = list(full = rec),
  models = list(
    rf = rand_forest_spec,
    xgb = xgboost_spec,
    glmnet = elastic_net_spec
  )
)

# Tune all at once
results <- wf_set |>
  workflow_map(fn = "tune_grid", resamples = folds, grid = 20)

# Rank by performance
rank_results(results, rank_metric = "rmse")
```

## Supporting Files

### Templates
**[templates/model-templates.md](templates/model-templates.md)**

Ready-to-use code templates for:
- Binary classification workflow
- Regression workflow
- Multiclass classification
- Time series forecasting
- Model comparison framework
- Deployment pipeline

### Examples
**[examples/tidymodels-workflows.md](examples/tidymodels-workflows.md)**

Complete end-to-end examples:
- **Ames Housing**: Regression with extensive feature engineering
- **Hotel Bookings**: Binary classification with date features
- **Bean Classification**: Multiclass with physical measurements
- **Credit Default**: Extreme class imbalance handling

### References
**[references/recipe-steps-guide.md](references/recipe-steps-guide.md)**

Comprehensive catalog of all recipe steps organized by category with:
- When to use each step
- Pros and cons
- Example code
- Critical ordering rules

## Dynamic Search Capabilities 🆕

The skill can search the complete tidymodels online reference when needed:

**Available searches:**
- **Recipe Steps** (300+): https://www.tidymodels.org/find/recipes/
- **Parsnip Models** (160+): https://www.tidymodels.org/find/parsnip/
- **Prediction Types Matrix**: Which prediction types each model/engine supports
- **Sparse Compatibility**: Methods that work with sparse matrices

**When it searches automatically:**
- You ask about a specific step/model not in local knowledge
- You request comprehensive lists ("show me ALL...")
- You need prediction type compatibility information
- You ask about sparse data support

**Example queries that trigger search:**
- "What recipe steps are available for text processing?"
- "Show me all gradient boosting models in tidymodels"
- "Does svm_rbf with liquidSVM support confidence intervals?"
- "Which recipe steps work with sparse matrices?"

The skill intelligently decides when to use curated local knowledge vs. searching the complete online catalog.

## Key Principles

### 1. Data Budgeting First
Split data BEFORE any analysis to prevent leakage:
```r
set.seed(123)
split <- initial_split(data, prop = 0.80, strata = outcome)
train <- training(split)
test <- testing(split)
```

### 2. Honest Estimation
Include ALL preprocessing in validation:
```r
# ✅ Correct - preprocessing in recipe
recipe(outcome ~ .) |>
  step_normalize(all_numeric_predictors())

# ❌ Wrong - preprocessing outside validation
data_normalized <- data |> mutate(across(where(is.numeric), scale))
```

### 3. Composable Workflows
Bundle recipe + model for consistency:
```r
workflow() |>
  add_recipe(my_recipe) |>
  add_model(my_model)
```

### 4. Systematic Comparison
Compare models on same resampling:
```r
workflow_set(
  preproc = list(basic = recipe1, advanced = recipe2),
  models = list(rf = rf_spec, xgb = xgb_spec)
) |>
  workflow_map(fn = "tune_grid", resamples = folds)
```

### 5. Appropriate Metrics
Choose metrics matching your problem:
- **Regression**: RMSE, R-squared, MAE
- **Balanced classification**: Accuracy, ROC-AUC
- **Imbalanced classification**: PR-AUC, F1, Sensitivity

## Common Workflows

### Regression
1. Split with stratification
2. Recipe: impute → engineer features → log transform → dummy → normalize
3. Models: elastic net, random forest, XGBoost
4. Tune with grid search or Bayesian optimization
5. Evaluate with RMSE, R-squared, MAE
6. Interpret with variable importance
7. Deploy with confidence intervals

### Classification
1. Split with stratification
2. Recipe: impute → engineer features → balance classes → dummy → normalize
3. Models: logistic, random forest, XGBoost
4. Tune optimizing ROC-AUC or PR-AUC
5. Evaluate with confusion matrix, ROC curves
6. Optimize probability threshold
7. Deploy with calibrated probabilities

### Time Series
1. Time-based split (no shuffling!)
2. Recipe: create lags → rolling stats → cyclical features
3. Rolling origin resampling
4. Models: prophet, random forest, XGBoost
5. Walk-forward validation
6. Deploy with monitoring

## Best Practices

✅ **DO:**
- Split data first, always with `strata` for classification
- Use workflows to bundle recipe + model
- Apply `step_novel()` before `step_dummy()`
- Remove zero-variance predictors with `step_zv()` after dummies
- Normalize after creating dummy variables
- Use multiple metrics for comprehensive evaluation
- Visualize tuning results with `autoplot()`
- Evaluate on held-out test set with `last_fit()`

❌ **DON'T:**
- Preprocess data before splitting (data leakage!)
- Tune on test set
- Forget to set seed before splitting
- Normalize before creating dummy variables
- Skip `step_novel()` when using `step_dummy()`
- Evaluate only on training data
- Trust all predictions equally (check applicability)

## Resources

### Official Documentation
- [tidymodels.org](https://www.tidymodels.org/) - Official documentation and tutorials
- [tmwr.org](https://www.tmwr.org/) - "Tidy Modeling with R" book
- [tidymodels GitHub](https://github.com/tidymodels) - Source code and issues

### Core Packages
- [recipes](https://recipes.tidymodels.org/) - Feature engineering
- [parsnip](https://parsnip.tidymodels.org/) - Unified model interface
- [workflows](https://workflows.tidymodels.org/) - Bundle preprocessing + modeling
- [tune](https://tune.tidymodels.org/) - Hyperparameter optimization
- [yardstick](https://yardstick.tidymodels.org/) - Performance metrics
- [rsample](https://rsample.tidymodels.org/) - Resampling methods

### Extension Packages
- [themis](https://themis.tidymodels.org/) - Class imbalance
- [textrecipes](https://textrecipes.tidymodels.org/) - Text preprocessing
- [embed](https://embed.tidymodels.org/) - Categorical encoding, dimensionality reduction
- [stacks](https://stacks.tidymodels.org/) - Model ensembling
- [vetiver](https://vetiver.rstudio.com/) - Model deployment
- [probably](https://probably.tidymodels.org/) - Probability tools

## Installation

This skill is automatically available when using Claude Code in this project.

To make it available system-wide:
```bash
cp -r .claude/skills/r-tidymodels ~/.claude/skills/
```

## Usage Tips

### Get Help
Ask Claude:
- "How do I handle missing data in recipes?"
- "Show me how to tune an XGBoost model"
- "What's the best way to handle class imbalance?"
- "Help me deploy my tidymodels workflow"

### Request Examples
- "Show me a complete classification workflow"
- "How do I create interaction terms in a recipe?"
- "What recipe steps should I use for text data?"
- "Help me compare multiple models systematically"

### Search Queries 🆕
- "Find all recipe steps for handling dates and times"
- "What models are available for survival analysis?"
- "Does random forest with randomForest engine support prediction intervals?"
- "Show me all SMOTE variants in tidymodels"

### Debugging
- "Why is my recipe failing?"
- "How do I fix this novel factor level error?"
- "My model is overfitting, what should I check?"
- "The tuning is taking too long, how can I speed it up?"

## Skill Structure

```
.claude/skills/r-tidymodels/
├── SKILL.md                      # Main skill definition (expert knowledge)
├── README.md                     # This file (user guide)
├── templates/
│   └── model-templates.md        # Ready-to-use code templates
├── examples/
│   └── tidymodels-workflows.md   # Complete working examples
└── references/
    └── recipe-steps-guide.md     # Comprehensive recipe catalog
```

## Contributing

Found an issue or have a suggestion? This skill is based on:
- [tidymodels.org](https://www.tidymodels.org/) - Official documentation
- [Tidy Modeling with R](https://www.tmwr.org/) - Comprehensive book by Max Kuhn and Julia Silge

For questions about tidymodels itself, visit [forum.posit.co](https://forum.posit.co).

## Version

**Version:** 1.1.0 🆕
**Last Updated:** 2026-03-08
**Based on:** tidymodels 1.2.0, Tidy Modeling with R (2024 edition)

**What's New in 1.1.0:**
- ✨ Dynamic search capability with WebFetch
- 🔍 Access to complete tidymodels online reference (300+ steps, 160+ models)
- 🎯 Smart hybrid approach: curated local knowledge + comprehensive online catalog
- 📊 Prediction types matrix, sparse compatibility, and more search tools

---

Built with ❤️ for the R community
