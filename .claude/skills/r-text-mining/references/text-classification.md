# Text Classification Guide

Complete reference for supervised text classification using tidymodels and textrecipes.

## Overview

Text classification assigns predefined categories to documents based on their content. This guide covers the complete tidymodels workflow for text classification tasks.

**Common Applications**:
- Spam detection (spam/ham)
- Sentiment classification (positive/negative/neutral)
- Topic categorization (politics, sports, tech, etc.)
- Intent detection (question, complaint, praise)
- Language detection
- Author identification

## Complete Classification Workflow

### 1. Data Preparation

```r
library(tidymodels)
library(textrecipes)
library(tidyverse)

# Example: Product reviews
data <- tibble(
  review_id = 1:1000,
  text = c("This product is amazing!", "Terrible quality...", ...),
  category = factor(c("positive", "negative", ...))
)

# Check class balance
data |> count(category)

# Train/test split (stratified by outcome)
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = category)
train_data <- training(data_split)
test_data <- testing(data_split)

# Verify stratification
train_data |> count(category) |> mutate(prop = n / sum(n))
test_data |> count(category) |> mutate(prop = n / sum(n))
```

### 2. Text Preprocessing Recipe

```r
# Basic text recipe
text_recipe <- recipe(category ~ text, data = train_data) |>
  # Tokenization
  step_tokenize(text) |>

  # Cleaning
  step_stopwords(text, stopword_source = "snowball") |>
  step_tokenfilter(text, max_tokens = 1000, min_times = 5) |>

  # Feature generation
  step_tfidf(text) |>

  # Normalization
  step_normalize(all_predictors())

# Prep and check
text_prep <- prep(text_recipe)
bake(text_prep, new_data = NULL) |> glimpse()
```

### 3. Model Specification

```r
# Logistic regression
logistic_spec <- logistic_reg() |>
  set_engine("glmnet") |>
  set_mode("classification")

# Naive Bayes
nb_spec <- naive_Bayes() |>
  set_engine("naivebayes") |>
  set_mode("classification")

# SVM
svm_spec <- svm_linear() |>
  set_engine("LiblineaR") |>
  set_mode("classification")

# Random Forest
rf_spec <- rand_forest(trees = 500) |>
  set_engine("ranger", importance = "impurity") |>
  set_mode("classification")

# XGBoost
xgb_spec <- boost_tree(trees = 500) |>
  set_engine("xgboost") |>
  set_mode("classification")
```

### 4. Workflow Creation

```r
# Create workflows for each model
logistic_wf <- workflow() |>
  add_recipe(text_recipe) |>
  add_model(logistic_spec)

nb_wf <- workflow() |>
  add_recipe(text_recipe) |>
  add_model(nb_spec)

svm_wf <- workflow() |>
  add_recipe(text_recipe) |>
  add_model(svm_spec)

rf_wf <- workflow() |>
  add_recipe(text_recipe) |>
  add_model(rf_spec)

xgb_wf <- workflow() |>
  add_recipe(text_recipe) |>
  add_model(xgb_spec)
```

### 5. Cross-Validation

```r
# Create CV folds
set.seed(123)
cv_folds <- vfold_cv(train_data, v = 10, strata = category)

# Fit all models
logistic_fit <- fit_resamples(
  logistic_wf,
  resamples = cv_folds,
  metrics = metric_set(accuracy, roc_auc, precision, recall, f_meas),
  control = control_resamples(save_pred = TRUE)
)

nb_fit <- fit_resamples(nb_wf, resamples = cv_folds)
svm_fit <- fit_resamples(svm_wf, resamples = cv_folds)
rf_fit <- fit_resamples(rf_wf, resamples = cv_folds)
xgb_fit <- fit_resamples(xgb_wf, resamples = cv_folds)
```

### 6. Model Comparison

```r
# Collect and compare metrics
model_comparison <- bind_rows(
  collect_metrics(logistic_fit) |> mutate(model = "Logistic"),
  collect_metrics(nb_fit) |> mutate(model = "Naive Bayes"),
  collect_metrics(svm_fit) |> mutate(model = "SVM"),
  collect_metrics(rf_fit) |> mutate(model = "Random Forest"),
  collect_metrics(xgb_fit) |> mutate(model = "XGBoost")
)

# Best performers
model_comparison |>
  filter(.metric == "accuracy") |>
  arrange(desc(mean))

# Visualize comparison
model_comparison |>
  filter(.metric %in% c("accuracy", "roc_auc")) |>
  ggplot(aes(mean, reorder(model, mean), fill = model)) +
  geom_col(show.legend = FALSE) +
  geom_errorbar(aes(xmin = mean - std_err, xmax = mean + std_err), width = 0.2) +
  facet_wrap(~.metric, scales = "free_x") +
  labs(title = "Model Performance Comparison", x = "Mean Score", y = NULL)
```

### 7. Final Model Training

```r
# Select best model
best_wf <- svm_wf  # Based on comparison

# Fit on full training data and evaluate on test
final_fit <- last_fit(best_wf, data_split)

# Test set metrics
collect_metrics(final_fit)

# Confusion matrix
collect_predictions(final_fit) |>
  conf_mat(truth = category, estimate = .pred_class)

# ROC curve
collect_predictions(final_fit) |>
  roc_curve(truth = category, .pred_positive) |>
  autoplot()
```

### 8. Model Deployment

```r
# Train final model on all data
final_model <- fit(best_wf, data)

# Save model
saveRDS(final_model, "text_classifier_model.rds")

# Prediction function
predict_category <- function(text, model) {
  new_data <- tibble(text = text)
  predict(model, new_data, type = "prob") |>
    bind_cols(predict(model, new_data)) |>
    bind_cols(new_data)
}

# Use
predict_category("This is an amazing product!", final_model)
```

## Text Preprocessing Options

### Tokenization Strategies

```r
# Words (default)
recipe(category ~ text, data = train) |>
  step_tokenize(text)

# N-grams (unigrams + bigrams)
recipe(category ~ text, data = train) |>
  step_tokenize(text, token = "ngrams", options = list(n = 2, n_min = 1))

# Character n-grams (good for short text, typos)
recipe(category ~ text, data = train) |>
  step_tokenize(text, token = "character_shingles", options = list(n = 3))

# Skip-grams (capture long-distance dependencies)
recipe(category ~ text, data = train) |>
  step_tokenize(text, token = "skip_ngrams", options = list(n = 2, k = 1))
```

### Token Filtering

```r
recipe(category ~ text, data = train) |>
  step_tokenize(text) |>

  # Remove stop words
  step_stopwords(text, stopword_source = "snowball") |>

  # Token frequency filtering
  step_tokenfilter(
    text,
    max_tokens = 1000,   # Keep top 1000 tokens
    min_times = 5,       # Must appear >= 5 times
    max_times = Inf,     # No upper limit
    percentage = FALSE   # Use counts not percentages
  ) |>

  # Stemming
  step_stem(text)
```

### Feature Generation

```r
# TF-IDF (most common)
recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_tfidf(text)

# Term frequency only
recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_tf(text)

# Feature hashing (memory efficient)
recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_texthash(text, num_terms = 512)

# Word embeddings (pre-trained)
glove_embeddings <- read_rds("glove_embeddings.rds")

recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_word_embeddings(text, embeddings = glove_embeddings)
```

## Advanced Recipe Patterns

### Handling Class Imbalance

```r
# Downsampling (reduce majority class)
recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_tfidf(text) |>
  step_downsample(category)

# Upsampling (duplicate minority class)
recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_tfidf(text) |>
  step_upsample(category, over_ratio = 1)

# SMOTE (synthetic minority oversampling)
library(themis)
recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_tfidf(text) |>
  step_smote(category)
```

### Custom Stop Words

```r
# Domain-specific stop words
custom_stops <- c("product", "item", "company", "service")

recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_stopwords(text, custom_stopword_source = custom_stops)
```

### Multiple Text Columns

```r
# Combine features from multiple text sources
recipe(category ~ title + body + tags, data = train) |>
  step_tokenize(title, body, tags) |>
  step_stopwords(title, body, tags) |>
  step_tfidf(title, body, tags) |>
  step_normalize(all_predictors())
```

### Adding Non-Text Features

```r
# Combine text and numeric/categorical features
recipe(category ~ text + price + rating + brand, data = train) |>
  # Text preprocessing
  step_tokenize(text) |>
  step_tfidf(text) |>

  # Categorical preprocessing
  step_dummy(brand) |>

  # Numeric preprocessing
  step_normalize(price, rating) |>

  # Final normalization
  step_normalize(all_predictors())
```

## Model Selection Guidelines

### Binary Classification

| Model | Pros | Cons | Best For |
|-------|------|------|----------|
| **Logistic Regression** | Fast, interpretable, regularizable | Linear boundary | Baseline, interpretability |
| **Naive Bayes** | Very fast, probabilistic | Independence assumption | High-dimensional, quick baseline |
| **SVM** | Handles high-dim well, strong performance | Slow on large data | Accuracy priority, moderate size |
| **Random Forest** | Robust, handles interactions | Slow, memory-intensive | Complex patterns, feature importance |
| **XGBoost** | State-of-art accuracy, fast | Many hyperparameters | Production, competition |

### Multi-Class Classification

All binary classifiers extend to multi-class (one-vs-rest or multinomial).

**Special considerations**:
- Naive Bayes: Native multi-class support
- SVM: Use `svm_poly()` or `svm_rbf()` for complex boundaries
- Neural networks: Good for > 10 classes

### Model Tuning

```r
# Define tuning grid
svm_spec_tune <- svm_linear(cost = tune()) |>
  set_engine("LiblineaR") |>
  set_mode("classification")

svm_wf_tune <- workflow() |>
  add_recipe(text_recipe) |>
  add_model(svm_spec_tune)

# Grid search
svm_grid <- grid_regular(cost(), levels = 10)

svm_tuned <- tune_grid(
  svm_wf_tune,
  resamples = cv_folds,
  grid = svm_grid,
  metrics = metric_set(accuracy, roc_auc)
)

# Best hyperparameters
best_cost <- select_best(svm_tuned, metric = "accuracy")

# Finalize workflow
final_wf <- finalize_workflow(svm_wf_tune, best_cost)
```

## Evaluation Metrics

### Choosing Metrics

```r
# Custom metric set
text_metrics <- metric_set(
  accuracy,     # Overall correctness
  precision,    # True positives / (TP + FP)
  recall,       # True positives / (TP + FN)
  f_meas,       # Harmonic mean of precision/recall
  roc_auc,      # Area under ROC curve
  pr_auc        # Area under precision-recall curve
)

# Use in cross-validation
fit_resamples(
  workflow,
  resamples = cv_folds,
  metrics = text_metrics
)
```

### Metric Guidelines

| Scenario | Primary Metric |
|----------|---------------|
| Balanced classes | Accuracy, AUC |
| Imbalanced classes | F1, PR-AUC |
| Cost of FP high (spam) | Precision |
| Cost of FN high (disease) | Recall |
| Ranking important | ROC-AUC |

### Per-Class Metrics

```r
# Multi-class confusion matrix
predictions <- collect_predictions(final_fit)

# Overall
predictions |>
  conf_mat(truth = category, estimate = .pred_class)

# Per-class metrics
predictions |>
  group_by(category) |>
  metrics(truth = category, estimate = .pred_class)

# Macro-averaged (unweighted average across classes)
predictions |>
  f_meas(truth = category, estimate = .pred_class, estimator = "macro")

# Weighted average (by class frequency)
predictions |>
  f_meas(truth = category, estimate = .pred_class, estimator = "macro_weighted")
```

## Feature Importance

### TF-IDF Feature Importance

```r
# Extract feature weights from logistic regression
logistic_final <- fit(logistic_wf, train_data)

# Get coefficients
tidy(logistic_final) |>
  filter(term != "(Intercept)") |>
  slice_max(abs(estimate), n = 20) |>
  ggplot(aes(estimate, reorder(term, estimate))) +
  geom_col() +
  labs(title = "Top 20 Predictive Features", x = "Coefficient", y = "Term")
```

### Random Forest Importance

```r
# Fit random forest with importance
rf_final <- fit(rf_wf, train_data)

# Extract variable importance
library(vip)
rf_final |>
  extract_fit_engine() |>
  vip(num_features = 20) +
  labs(title = "Top 20 Important Features")
```

### LIME (Local Interpretable Model-Agnostic Explanations)

```r
library(lime)

# Create explainer
explainer <- lime(train_data$text, final_model)

# Explain specific predictions
explanation <- explain(
  test_data$text[1:5],
  explainer,
  n_labels = 1,
  n_features = 10
)

# Visualize
plot_features(explanation)
```

## Production Deployment

### Model Serving

```r
# Save complete workflow
saveRDS(final_model, "model.rds")

# Load and predict
production_model <- readRDS("model.rds")

# Batch prediction
new_texts <- tibble(text = c("Great product!", "Disappointing quality"))
predictions <- predict(production_model, new_texts, type = "prob") |>
  bind_cols(predict(production_model, new_texts))

# Single prediction API
predict_text <- function(text, model_path = "model.rds") {
  model <- readRDS(model_path)
  new_data <- tibble(text = text)

  probs <- predict(model, new_data, type = "prob")
  class <- predict(model, new_data)

  list(
    prediction = class$.pred_class,
    confidence = max(as.numeric(probs)),
    probabilities = as.list(probs)
  )
}
```

### Model Monitoring

```r
# Track predictions over time
prediction_log <- tibble(
  timestamp = Sys.time(),
  text = "...",
  prediction = "positive",
  confidence = 0.87,
  true_label = NA  # Fill in later if available
)

# Monitor prediction distribution
prediction_log |>
  count(prediction) |>
  mutate(prop = n / sum(n))

# Monitor confidence distribution
ggplot(prediction_log, aes(confidence)) +
  geom_histogram(bins = 30) +
  facet_wrap(~prediction) +
  labs(title = "Prediction Confidence Distribution")

# Accuracy over time (when labels available)
prediction_log |>
  filter(!is.na(true_label)) |>
  mutate(correct = prediction == true_label) |>
  group_by(date = as.Date(timestamp)) |>
  summarise(accuracy = mean(correct)) |>
  ggplot(aes(date, accuracy)) +
  geom_line() +
  geom_smooth(se = FALSE) +
  labs(title = "Model Accuracy Over Time")
```

### Model Retraining

```r
# Decide when to retrain
retrain_needed <- function(current_accuracy, baseline_accuracy, threshold = 0.05) {
  current_accuracy < (baseline_accuracy - threshold)
}

# Incremental training data
new_labeled_data <- collect_new_labels()

# Combine with existing data
updated_train <- bind_rows(train_data, new_labeled_data)

# Retrain
updated_model <- fit(best_wf, updated_train)

# Evaluate on held-out test
updated_metrics <- augment(updated_model, test_data) |>
  metrics(truth = category, estimate = .pred_class)

# Deploy if improved
if (updated_metrics$accuracy > current_accuracy) {
  saveRDS(updated_model, "model.rds")
}
```

## Common Issues and Solutions

### Issue: Low Accuracy

**Causes**:
- Insufficient training data
- Noisy labels
- Class imbalance
- Feature representation mismatch

**Solutions**:
```r
# 1. Check data quality
train_data |> count(category)  # Imbalance?
train_data |> sample_n(50) |> View()  # Label errors?

# 2. Try different feature representations
# TF-IDF vs embeddings vs hashing

# 3. Handle imbalance
recipe(...) |> step_smote(category)

# 4. Try more complex models
# Logistic → SVM → Random Forest → XGBoost
```

### Issue: Overfitting

**Symptoms**: High train accuracy, low test accuracy

**Solutions**:
```r
# 1. Regularization
logistic_reg(penalty = 0.1, mixture = 1)  # Lasso

# 2. Reduce feature space
step_tokenfilter(text, max_tokens = 500)

# 3. More training data
# Collect more or augment existing

# 4. Simpler model
# Use Naive Bayes or logistic instead of XGBoost
```

### Issue: Slow Training

**Solutions**:
```r
# 1. Feature hashing instead of TF-IDF
step_texthash(text, num_terms = 1024)

# 2. Reduce token count
step_tokenfilter(text, max_tokens = 500)

# 3. Parallel processing
fit_resamples(..., control = control_resamples(parallel_over = "everything"))

# 4. Simpler model
# Naive Bayes is very fast
```

## Best Practices

✅ **Always** use stratified splits for imbalanced data
✅ **Always** check class balance and handle if needed
✅ **Always** use cross-validation for model selection
✅ **Always** evaluate on held-out test set
✅ **Always** try multiple models (start simple, add complexity)
✅ **Consider** feature engineering (n-grams, embeddings)
✅ **Consider** hyperparameter tuning for final model
✅ **Report** precision, recall, F1, not just accuracy
✅ **Monitor** model performance in production
✅ **Retrain** periodically with new data

## Quick Reference

| Task | Code Pattern |
|------|--------------|
| Train/test split | `initial_split(data, strata = outcome)` |
| Text recipe | `recipe() |> step_tokenize() |> step_tfidf()` |
| Cross-validation | `vfold_cv(train, v = 10, strata = outcome)` |
| Fit models | `fit_resamples(workflow, resamples)` |
| Compare models | `collect_metrics() |> arrange(desc(mean))` |
| Final evaluation | `last_fit(workflow, split)` |
| Confusion matrix | `conf_mat(truth, estimate)` |
| Save model | `saveRDS(model, "model.rds")` |
| Predict new | `predict(model, new_data)` |

---

**Remember**: Text classification is supervised learning. Quality and quantity of labeled training data is crucial for good performance.
