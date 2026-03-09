# Comprehensive Tidymodels Machine Learning Knowledge Base

> Extracted from four official tidymodels books: Feature Engineering & Selection, ModernDive, Supervised ML for Text Analysis, and Text Mining with R

## Table of Contents

1. [Tidymodels Workflow Structure](#tidymodels-workflow-structure)
2. [Data Preparation & Preprocessing](#data-preparation--preprocessing)
3. [Feature Engineering Catalog](#feature-engineering-catalog)
4. [Model Specifications](#model-specifications)
5. [Resampling & Validation Strategies](#resampling--validation-strategies)
6. [Hyperparameter Tuning](#hyperparameter-tuning)
7. [Performance Metrics](#performance-metrics)
8. [Text & NLP Methods](#text--nlp-methods)
9. [Deep Learning Patterns](#deep-learning-patterns)
10. [Statistical Inference](#statistical-inference)
11. [Complete Workflow Patterns](#complete-workflow-patterns)

---

## Tidymodels Workflow Structure

### Core Three-Component Pattern

Every tidymodels workflow combines three elements:

```r
# 1. Recipe - Data preprocessing specification
# 2. Model Specification - Algorithm and engine definition
# 3. Workflow - Container bundling preprocessor and model

workflow() %>%
  add_recipe(preprocessing_recipe) %>%
  add_model(model_specification)
```

### Data Splitting Foundation

```r
# Basic train-test split
data_split <- initial_split(data, prop = 0.75)
training_data <- training(data_split)
testing_data <- testing(data_split)

# Stratified split (classification)
data_split <- initial_split(data, prop = 0.75, strata = outcome_var)

# Convert to numeric for regression
data <- data %>% mutate(outcome = as.numeric(outcome))
```

### Cross-Validation Setup

```r
# V-fold cross-validation
data_folds <- vfold_cv(training_data, v = 10)

# Stratified v-fold (classification)
data_folds <- vfold_cv(training_data, v = 10, strata = outcome)

# Validation split (for neural networks)
validation_split <- validation_split(training_data, prop = 0.8, strata = outcome)
```

---

## Data Preparation & Preprocessing

### Tidy Data Principles

**Core Requirements:**
- Each variable forms a column
- Each observation forms a row
- Each type of observational unit forms a table

### Data Importing Methods

```r
# CSV from URL or local file
data <- read_csv("path/to/file.csv")
data <- read_csv("https://example.com/data.csv")

# Excel files
library(readxl)
data <- read_excel("file.xlsx")

# Google Sheets
library(googlesheets4)
data <- read_sheet("sheet_url")
```

### Data Transformation

```r
# Wide to long format
data_long <- data_wide %>%
  pivot_longer(
    cols = c(col1, col2, col3),
    names_to = "variable",
    values_to = "value"
  )

# Long to wide format
data_wide <- data_long %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  )
```

### Joining Datasets

```r
# Standard joins for combining related tables
combined <- left_join(table1, table2, by = "key_column")
combined <- inner_join(table1, table2, by = c("key1", "key2"))
```

---

## Feature Engineering Catalog

### Recipe Basics

```r
# Basic recipe structure
basic_recipe <- recipe(outcome ~ ., data = training_data) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors())
```

### Numeric Transformations

```r
# Centering and scaling
recipe(outcome ~ ., data = train) %>%
  step_center(all_numeric_predictors()) %>%
  step_scale(all_numeric_predictors()) %>%
  # Or combined:
  step_normalize(all_numeric_predictors())

# Log transformations for skewness
recipe(outcome ~ ., data = train) %>%
  step_log(skewed_var, offset = 1)

# Box-Cox transformation
recipe(outcome ~ ., data = train) %>%
  step_BoxCox(all_numeric_predictors())

# Yeo-Johnson (handles zeros and negatives)
recipe(outcome ~ ., data = train) %>%
  step_YeoJohnson(all_numeric_predictors())
```

### Categorical Encoding

```r
# Dummy variables (one-hot encoding)
recipe(outcome ~ ., data = train) %>%
  step_dummy(all_nominal_predictors(), one_hot = TRUE)

# Remove near-zero variance predictors
recipe(outcome ~ ., data = train) %>%
  step_nzv(all_predictors())

# Handle unknown factor levels
recipe(outcome ~ ., data = train) %>%
  step_unknown(all_nominal_predictors())

# Novel level handling
recipe(outcome ~ ., data = train) %>%
  step_novel(all_nominal_predictors())
```

### Date/Time Features

```r
# Extract date components
recipe(outcome ~ ., data = train) %>%
  step_date(date_column, features = c("dow", "month", "year"))

# Time-based features
recipe(outcome ~ ., data = train) %>%
  step_time(timestamp, features = c("hour", "minute"))
```

### Dimensionality Reduction

```r
# Principal Component Analysis
recipe(outcome ~ ., data = train) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_pca(all_numeric_predictors(), num_comp = 5)

# Spatial sign transformation
recipe(outcome ~ ., data = train) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_spatialsign(all_numeric_predictors())
```

### Interaction Terms

```r
# Create interaction features
recipe(outcome ~ ., data = train) %>%
  step_interact(~ predictor1:predictor2)

# Polynomial features
recipe(outcome ~ ., data = train) %>%
  step_poly(numeric_var, degree = 2)
```

### Missing Data Handling

```r
# Imputation strategies
recipe(outcome ~ ., data = train) %>%
  step_impute_mean(all_numeric_predictors()) %>%
  step_impute_mode(all_nominal_predictors())

# K-nearest neighbors imputation
recipe(outcome ~ ., data = train) %>%
  step_impute_knn(all_predictors(), neighbors = 5)

# Bag tree imputation
recipe(outcome ~ ., data = train) %>%
  step_impute_bag(all_predictors())
```

---

## Model Specifications

### Regression Models

```r
# Linear Regression
lm_spec <- linear_reg() %>%
  set_engine("lm") %>%
  set_mode("regression")

# Regularized Regression (Lasso/Ridge/Elastic Net)
glmnet_spec <- linear_reg(penalty = tune(), mixture = tune()) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

# Random Forest
rf_spec <- rand_forest(
  trees = 1000,
  mtry = tune(),
  min_n = tune()
) %>%
  set_engine("ranger") %>%
  set_mode("regression")

# Support Vector Machine
svm_spec <- svm_linear() %>%
  set_engine("LiblineaR") %>%
  set_mode("regression")

# Null Model (baseline)
null_spec <- null_model() %>%
  set_engine("parsnip") %>%
  set_mode("regression")
```

### Classification Models

```r
# Logistic Regression
logistic_spec <- logistic_reg() %>%
  set_engine("glm") %>%
  set_mode("classification")

# Lasso Classification
lasso_spec <- logistic_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet") %>%
  set_mode("classification")

# Multinomial Regression (multiclass)
multinom_spec <- multinom_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet") %>%
  set_mode("classification")

# Naive Bayes
nb_spec <- naive_Bayes() %>%
  set_engine("naivebayes") %>%
  set_mode("classification")

# Random Forest
rf_class_spec <- rand_forest(trees = 1000) %>%
  set_engine("ranger") %>%
  set_mode("classification")

# Support Vector Machine
svm_class_spec <- svm_linear() %>%
  set_engine("LiblineaR") %>%
  set_mode("classification")
```

### Model Formulas

```r
# Basic linear model
lm(outcome ~ predictor, data = data)

# Multiple predictors
lm(outcome ~ pred1 + pred2 + pred3, data = data)

# Interaction model (different slopes per group)
lm(outcome ~ pred1 * pred2, data = data)

# Parallel slopes model (different intercepts, same slope)
lm(outcome ~ pred1 + pred2, data = data)

# All predictors
lm(outcome ~ ., data = data)
```

---

## Resampling & Validation Strategies

### Cross-Validation

```r
# V-fold cross-validation
folds <- vfold_cv(training_data, v = 10)

# Repeated cross-validation
folds <- vfold_cv(training_data, v = 10, repeats = 5)

# Stratified (preserves outcome distribution)
folds <- vfold_cv(training_data, v = 10, strata = outcome)

# Monte Carlo cross-validation
folds <- mc_cv(training_data, prop = 0.75, times = 25)

# Validation split (single holdout)
val_split <- validation_split(training_data, prop = 0.8)
```

### Bootstrap Resampling

```r
# Bootstrap samples (with replacement)
bootstraps <- bootstraps(training_data, times = 1000)

# For confidence intervals
bootstraps <- bootstraps(training_data, times = 1000, strata = outcome)
```

### Fitting Resampled Models

```r
# Basic resampling
resampled_fit <- fit_resamples(
  workflow,
  resamples = folds,
  control = control_resamples(save_pred = TRUE)
)

# With custom metrics
resampled_fit <- fit_resamples(
  workflow,
  resamples = folds,
  metrics = metric_set(rmse, mae, rsq),
  control = control_resamples(save_pred = TRUE)
)

# Extract results
collect_metrics(resampled_fit)
collect_predictions(resampled_fit)
```

---

## Hyperparameter Tuning

### Marking Parameters for Tuning

```r
# In recipe
recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = tune()) %>%
  step_tfidf(text)

# In model specification
rf_spec <- rand_forest(
  trees = 1000,
  mtry = tune(),
  min_n = tune()
) %>%
  set_engine("ranger") %>%
  set_mode("regression")

# In regularization
glmnet_spec <- linear_reg(
  penalty = tune(),
  mixture = tune()
) %>%
  set_engine("glmnet")
```

### Tuning Grids

```r
# Regular grid
regular_grid <- grid_regular(
  penalty(range = c(-5, 0)),
  mixture(range = c(0, 1)),
  levels = 5
)

# Latin hypercube sampling
lhs_grid <- grid_latin_hypercube(
  penalty(),
  mixture(),
  size = 30
)

# Random grid
random_grid <- grid_random(
  penalty(),
  mixture(),
  size = 50
)

# Custom grid for specific parameter
token_grid <- grid_regular(
  max_tokens(range = c(1e3, 6e3)),
  levels = 6
)
```

### Running Tuning

```r
# Grid search
tune_results <- tune_grid(
  workflow,
  resamples = folds,
  grid = parameter_grid,
  metrics = metric_set(rmse, rsq),
  control = control_grid(save_pred = TRUE)
)

# View results
show_best(tune_results, metric = "rmse", n = 10)
autoplot(tune_results)

# Select best parameters
best_params <- select_best(tune_results, metric = "rmse")

# Select by one standard error rule (parsimony)
best_params <- select_by_one_std_err(
  tune_results,
  metric = "roc_auc",
  desc(penalty)  # prefer higher penalty for simpler model
)

# Finalize workflow
final_workflow <- finalize_workflow(workflow, best_params)
```

### Bayesian Optimization

```r
# More efficient for expensive models
library(finetune)

tune_results <- tune_bayes(
  workflow,
  resamples = folds,
  initial = 5,  # initial random grid
  iter = 50,    # additional iterations
  metrics = metric_set(roc_auc),
  control = control_bayes(verbose = TRUE)
)
```

---

## Performance Metrics

### Regression Metrics

```r
# Default metrics
# - RMSE (root mean squared error)
# - R² (coefficient of determination)

# Custom regression metrics
regression_metrics <- metric_set(
  rmse,      # root mean squared error
  mae,       # mean absolute error
  mape,      # mean absolute percentage error
  rsq,       # R-squared
  huber_loss # Huber loss (robust to outliers)
)

# Apply to predictions
predictions %>%
  metrics(truth = actual, estimate = .pred)

# Individual calculations
predictions %>%
  rmse(truth = actual, estimate = .pred)
```

### Classification Metrics

```r
# Binary classification defaults
# - Accuracy
# - ROC AUC (area under ROC curve)

# Comprehensive classification metrics
classification_metrics <- metric_set(
  accuracy,      # overall accuracy
  bal_accuracy,  # balanced accuracy (handles imbalanced data)
  sensitivity,   # true positive rate (recall)
  specificity,   # true negative rate
  precision,     # positive predictive value
  recall,        # same as sensitivity
  f_meas,        # F1 score (harmonic mean of precision and recall)
  roc_auc,       # area under ROC curve
  pr_auc,        # area under precision-recall curve
  kap            # Cohen's kappa
)

# For multiclass
multiclass_metrics <- metric_set(
  accuracy,
  roc_auc,
  mn_log_loss    # multinomial log loss
)

# Confusion matrix
conf_mat_resampled(resampled_fit, tidy = FALSE)
```

### Model Comparison

```r
# Compare multiple models
model_results <- list(
  model1 = fit_resamples(workflow1, folds),
  model2 = fit_resamples(workflow2, folds),
  model3 = fit_resamples(workflow3, folds)
)

# Compare metrics
comparison <- model_results %>%
  map_dfr(collect_metrics, .id = "model_name") %>%
  filter(.metric == "rmse") %>%
  arrange(mean)

# Statistical comparison
library(tidyposterior)
model_comparison <- perf_mod(
  workflow_set,
  metric = "roc_auc",
  prior_intercept = rstanarm::student_t(df = 1),
  chains = 4,
  iter = 5000
)
```

---

## Text & NLP Methods

### Text Preprocessing Recipes

#### Basic Text Recipe

```r
# TF-IDF with normalization
text_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text) %>%
  step_normalize(all_predictors())
```

#### Stop Word Removal

```r
# Using pre-built stop word lists
text_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_stopwords(text, stopword_source = "snowball") %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

# Available stop word sources:
# - "snowball" (175 words - Porter's English list)
# - "smart" (571 words - Cornell IR system)
# - "stopwords-iso" (1,298 words - largest)

# Custom stop words
custom_stops <- c("word1", "word2", "word3")
text_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_stopwords(text, custom_stopword_source = custom_stops) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)
```

#### N-gram Features

```r
# Bigrams and unigrams
ngram_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text, token = "ngrams",
                options = list(n = 2, n_min = 1)) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

# Pure bigrams
bigram_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text, token = "ngrams",
                options = list(n = 2, n_min = 2)) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

# Trigrams
trigram_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text, token = "ngrams",
                options = list(n = 3, n_min = 3)) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)
```

#### Stemming and Lemmatization

```r
# Stemming (Porter algorithm)
stemmed_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_stem(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

# Lemmatization (requires spaCy)
lemma_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text, engine = "spacyr") %>%
  step_lemma(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)
```

#### Feature Hashing

```r
# Efficient for high-dimensional text
hashed_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_texthash(text, signed = TRUE, num_terms = 512)

# Advantages:
# - Fixed dimensionality (num_terms)
# - Fast computation
# - No vocabulary storage needed
# - Handles unknown tokens automatically

# Note: Requires text normalization first
train <- train %>%
  mutate(text = stringi::stri_trans_nfc(text))
```

#### Handling Imbalanced Text Data

```r
# Downsample after text preprocessing
balanced_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text) %>%
  step_downsample(outcome)  # applies to outcome, not predictors

# Upsample minority class
upsampled_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text) %>%
  step_upsample(outcome)

# SMOTE (synthetic minority oversampling)
smote_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text) %>%
  step_smote(outcome)
```

#### Combining Text and Non-Text Features

```r
# Mixed feature recipe
mixed_recipe <- recipe(outcome ~ text + date + category + amount, data = train) %>%
  # Text features
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text) %>%
  # Date features
  step_date(date, features = c("dow", "month", "year")) %>%
  step_rm(date) %>%
  # Categorical features
  step_unknown(category) %>%
  step_dummy(category, all_nominal_predictors()) %>%
  # Numeric features
  step_normalize(amount) %>%
  # Final normalization
  step_normalize(all_numeric_predictors())
```

### Tokenization Methods

#### Core Tokenizers

```r
library(tokenizers)

# Word tokenization
tokenize_words(text)

# Character tokenization
tokenize_characters(text, strip_non_alphanum = FALSE)

# Sentence tokenization
tokenize_sentences(text)

# N-gram tokenization
tokenize_ngrams(text, n = 2)
tokenize_ngrams(text, n = 3, n_min = 1)  # unigrams through trigrams

# Line and paragraph
tokenize_lines(text)
tokenize_paragraphs(text)
```

#### Tidy Text Tokenization

```r
library(tidytext)

# Basic word tokenization
tidy_text <- data %>%
  unnest_tokens(word, text_column)

# N-grams
tidy_bigrams <- data %>%
  unnest_tokens(bigram, text_column, token = "ngrams", n = 2)

# Characters
tidy_chars <- data %>%
  unnest_tokens(character, text_column, token = "characters")

# Sentences
tidy_sentences <- data %>%
  unnest_tokens(sentence, text_column, token = "sentences")

# Custom pattern
tidy_custom <- data %>%
  unnest_tokens(
    word,
    text_column,
    token = "regex",
    pattern = "[[:alpha:]']+-?[[:alpha:]+]"  # keeps hyphenated words
  )
```

#### Multilingual Tokenization

```r
# Chinese word segmentation
library(jiebaR)
segmenter <- worker()
chinese_tokens <- segment(chinese_text, segmenter)

# General Unicode word boundaries
tokenize_words(text)  # uses Unicode specifications by default
```

### Sentiment Analysis

#### Using Sentiment Lexicons

```r
library(tidytext)

# Get sentiment lexicons
afinn <- get_sentiments("afinn")      # -5 to +5 scores
bing <- get_sentiments("bing")        # positive/negative binary
nrc <- get_sentiments("nrc")          # emotions (joy, anger, etc.)
loughran <- get_sentiments("loughran") # financial sentiment

# Apply sentiment scoring
sentiment_scores <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(document_id, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(sentiment_score = positive - negative)

# Numeric sentiment (AFINN)
afinn_scores <- tidy_text %>%
  inner_join(get_sentiments("afinn"), by = "word") %>%
  group_by(document_id) %>%
  summarize(sentiment = sum(value))

# Emotion classification (NRC)
emotions <- tidy_text %>%
  inner_join(get_sentiments("nrc"), by = "word") %>%
  count(document_id, sentiment)
```

#### Sentiment Trajectories

```r
# Track sentiment across narrative
sentiment_trajectory <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(index = row_number() %/% 80, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(sentiment = positive - negative)

# Visualize
ggplot(sentiment_trajectory, aes(index, sentiment)) +
  geom_col() +
  labs(title = "Sentiment Trajectory")
```

#### Word Contribution to Sentiment

```r
# Most important words for sentiment
sentiment_contributions <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(word, sentiment, sort = TRUE) %>%
  group_by(sentiment) %>%
  slice_max(n, n = 10) %>%
  ungroup()

# Visualize
sentiment_contributions %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word, fill = sentiment)) +
  geom_col() +
  facet_wrap(~sentiment, scales = "free")
```

### TF-IDF (Term Frequency-Inverse Document Frequency)

```r
# Calculate TF-IDF
library(tidytext)

tf_idf_scores <- tidy_text %>%
  count(document, word) %>%
  bind_tf_idf(word, document, n) %>%
  arrange(desc(tf_idf))

# Formula: tf_idf = tf * idf
# where idf = ln(n_documents / n_documents_containing_term)

# Identify distinctive words per document
distinctive_words <- tf_idf_scores %>%
  group_by(document) %>%
  slice_max(tf_idf, n = 10) %>%
  ungroup()

# Visualize
distinctive_words %>%
  ggplot(aes(tf_idf, reorder(word, tf_idf), fill = document)) +
  geom_col() +
  facet_wrap(~document, scales = "free") +
  labs(x = "TF-IDF", y = NULL)
```

### Word Embeddings

#### Creating Embeddings from Corpus

```r
library(widyr)

# Create skipgram windows
tidy_skipgrams <- tidy_text %>%
  unnest_tokens(ngram, text, token = "ngrams", n = 8) %>%
  mutate(ngramID = row_number()) %>%
  unite(skipgramID, document, ngramID) %>%
  unnest_tokens(word, ngram)

# Calculate PMI (pointwise mutual information)
skipgram_probs <- tidy_skipgrams %>%
  pairwise_count(word, skipgramID, diag = TRUE, sort = TRUE) %>%
  mutate(p = n / sum(n))

pmi_matrix <- skipgram_probs %>%
  pairwise_pmi(word, feature, n)

# Apply SVD for dimensionality reduction
library(irlba)

pmi_svd <- pmi_matrix %>%
  widely_svd(word, feature, value, nv = 100, maxit = 1000)

# Extract word vectors
word_vectors <- pmi_svd %>%
  filter(dimension <= 100) %>%
  pivot_wider(names_from = dimension,
              names_prefix = "dim_",
              values_from = value)
```

#### Using Pre-trained Embeddings

```r
library(textdata)

# GloVe embeddings (6B tokens from Wikipedia + news)
glove_vectors <- embedding_glove6b(dimensions = 100)

# Match to your vocabulary
embeddings_matched <- tidy_text %>%
  distinct(word) %>%
  inner_join(glove_vectors, by = "word")

# Document embeddings from word embeddings
# Create sparse word matrix
word_matrix <- tidy_text %>%
  count(document, word) %>%
  cast_sparse(document, word, n)

# Matrix multiplication to get document embeddings
doc_embeddings <- word_matrix %*% as.matrix(embeddings_matched[, -1])
```

#### Exploring Embeddings

```r
# Find nearest neighbors (semantic similarity)
nearest_neighbors <- function(word_vectors, target_word, n = 10) {
  target_vector <- word_vectors %>%
    filter(word == target_word) %>%
    select(-word) %>%
    as.numeric()

  word_vectors %>%
    mutate(
      similarity = map_dbl(1:n(), ~{
        other_vector <- select(., -word) %>% slice(.x) %>% as.numeric()
        sum(target_vector * other_vector) /
          (sqrt(sum(target_vector^2)) * sqrt(sum(other_vector^2)))
      })
    ) %>%
    arrange(desc(similarity)) %>%
    slice(2:(n+1))  # exclude the word itself
}

# PCA visualization
library(ggplot2)
pca_result <- prcomp(word_vectors %>% select(-word))

pca_plot <- word_vectors %>%
  bind_cols(as_tibble(pca_result$x[, 1:2])) %>%
  ggplot(aes(PC1, PC2, label = word)) +
  geom_text(check_overlap = TRUE)
```

### Topic Modeling

#### LDA (Latent Dirichlet Allocation)

```r
library(topicmodels)
library(tidytext)

# Create document-term matrix
dtm <- tidy_text %>%
  count(document, word) %>%
  cast_dtm(document, word, n)

# Fit LDA model
lda_model <- LDA(dtm, k = 5, control = list(seed = 42))

# Extract topic-word probabilities (beta)
topics <- tidy(lda_model, matrix = "beta")

# Top words per topic
top_terms <- topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Visualize topics
top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales = "free") +
  scale_y_reordered()

# Extract document-topic probabilities (gamma)
doc_topics <- tidy(lda_model, matrix = "gamma")

# Assign documents to topics
doc_classification <- doc_topics %>%
  group_by(document) %>%
  slice_max(gamma, n = 1)

# Per-word topic assignment
word_assignments <- augment(lda_model, data = dtm)
```

#### Alternative: Mallet

```r
library(mallet)

# Mallet provides Java-based LDA
# Can still be tidied with tidytext
mallet_model <- mallet.lda.topics(...)
tidy(mallet_model)
```

### Word Relationships

#### Pairwise Correlations

```r
library(widyr)

# Calculate word correlations within sections
word_cors <- tidy_text %>%
  group_by(word) %>%
  filter(n() >= 20) %>%  # minimum frequency
  pairwise_cor(word, section, sort = TRUE)

# Find correlated words
word_cors %>%
  filter(item1 == "target_word") %>%
  slice_max(correlation, n = 10)
```

#### Bigram Networks

```r
library(igraph)
library(ggraph)

# Create bigram counts
bigram_counts <- data %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word) %>%
  count(word1, word2, sort = TRUE)

# Create network graph
bigram_graph <- bigram_counts %>%
  filter(n > 5) %>%
  graph_from_data_frame()

# Visualize
set.seed(42)
ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
  theme_void()
```

#### Negation in Sentiment

```r
# Identify negated words
negation_words <- c("not", "no", "never", "without")

negated_sentiment <- data %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(word1 %in% negation_words) %>%
  inner_join(get_sentiments("bing"), by = c("word2" = "word")) %>%
  count(word1, word2, sentiment, sort = TRUE)

# Most common negated words
negated_sentiment %>%
  group_by(word1) %>%
  slice_max(n, n = 10)
```

---

## Deep Learning Patterns

### Dense Neural Networks with Tidymodels

#### Basic DNN Architecture

```r
library(keras)

# Define model
dnn_model <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_flatten() %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 1, activation = "sigmoid")

# Compile
dnn_model %>% compile(
  optimizer = "adam",
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)
```

#### Preprocessing for Deep Learning

```r
# Sequence preprocessing recipe
dl_recipe <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_sequence_onehot(text, sequence_length = 100)

# Prepare data
prepped_recipe <- prep(dl_recipe)
train_dl <- bake(prepped_recipe, new_data = train, composition = "matrix")
test_dl <- bake(prepped_recipe, new_data = test, composition = "matrix")
```

#### Training with Validation

```r
# Create validation split
val_split <- validation_split(train, prop = 0.8, strata = outcome)

# Fit model
history <- dnn_model %>%
  fit(
    x = train_dl,
    y = train$outcome,
    epochs = 20,
    batch_size = 512,
    validation_split = 0.2,
    callbacks = list(
      callback_early_stopping(patience = 3)
    )
  )

# Plot training history
plot(history)
```

### LSTM Networks

#### Basic LSTM

```r
lstm_model <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_lstm(units = 32) %>%
  layer_dense(units = 1, activation = "sigmoid")

lstm_model %>% compile(
  optimizer = "adam",
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)
```

#### LSTM with Dropout

```r
# Reduce overfitting with dropout
lstm_dropout <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_lstm(
    units = 32,
    dropout = 0.4,              # input dropout
    recurrent_dropout = 0.4     # recurrent state dropout
  ) %>%
  layer_dense(units = 1, activation = "sigmoid")
```

#### Bidirectional LSTM

```r
# Process sequences in both directions
bilstm_model <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  bidirectional(layer_lstm(units = 32)) %>%
  layer_dense(units = 1, activation = "sigmoid")
```

#### Stacked LSTM

```r
# Multiple LSTM layers
stacked_lstm <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_lstm(units = 32, return_sequences = TRUE) %>%  # must return sequences
  layer_lstm(units = 32, return_sequences = TRUE) %>%
  layer_lstm(units = 32) %>%
  layer_dense(units = 1, activation = "sigmoid")
```

#### Padding Strategy

```r
# CRITICAL: padding position matters!
# Pre-padding (default) performs better
sequences <- pad_sequences(
  tokenized_text,
  maxlen = sequence_length,
  padding = "pre"    # zeros at beginning (RECOMMENDED)
)

# Post-padding flushes hidden states with zeros
sequences <- pad_sequences(
  tokenized_text,
  maxlen = sequence_length,
  padding = "post"   # zeros at end (worse performance)
)
```

#### LSTM for Regression

```r
# Change output layer for regression
lstm_regression <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_lstm(units = 32) %>%
  layer_dense(units = 1)  # no activation for regression

lstm_regression %>% compile(
  optimizer = "adam",
  loss = "mse",
  metrics = c("mae")
)
```

### Convolutional Neural Networks

#### Basic CNN for Text

```r
cnn_model <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_conv_1d(filters = 32, kernel_size = 5, activation = "relu") %>%
  layer_global_max_pooling_1d() %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")
```

#### Multi-layer CNN

```r
# Increase filters in deeper layers
deep_cnn <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_conv_1d(filters = 32, kernel_size = 5, activation = "relu") %>%
  layer_max_pooling_1d(pool_size = 2) %>%
  layer_conv_1d(filters = 64, kernel_size = 5, activation = "relu") %>%
  layer_global_max_pooling_1d() %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")
```

#### Kernel Size Selection

```r
# Smaller kernels for fine-grained patterns (character-level)
char_cnn <- keras_model_sequential() %>%
  layer_embedding(input_dim = n_chars + 1, output_dim = 16) %>%
  layer_conv_1d(filters = 32, kernel_size = 3, activation = "relu")

# Larger kernels for broader patterns (word-level)
word_cnn <- keras_model_sequential() %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32) %>%
  layer_conv_1d(filters = 32, kernel_size = 5, activation = "relu")
```

#### Multiple Kernel Sizes (Parallel CNNs)

```r
# Different kernel sizes capture different pattern scales
input_layer <- layer_input(shape = c(sequence_length))
embedding <- input_layer %>%
  layer_embedding(input_dim = max_words + 1, output_dim = 32)

# Parallel convolutions
conv3 <- embedding %>%
  layer_conv_1d(filters = 32, kernel_size = 3, activation = "relu") %>%
  layer_global_max_pooling_1d()

conv4 <- embedding %>%
  layer_conv_1d(filters = 32, kernel_size = 4, activation = "relu") %>%
  layer_global_max_pooling_1d()

conv5 <- embedding %>%
  layer_conv_1d(filters = 32, kernel_size = 5, activation = "relu") %>%
  layer_global_max_pooling_1d()

# Concatenate and classify
output <- layer_concatenate(c(conv3, conv4, conv5)) %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")

multi_cnn <- keras_model(input_layer, output)
```

### Model Interpretability with LIME

```r
library(lime)

# Create explanation model
explainer <- lime(
  x = train_text,
  model = fitted_model,
  preprocess = function(x) {
    # Ensure text matches training format
    preprocess_text(x)
  }
)

# Explain predictions
explanations <- explain(
  x = test_samples,
  explainer = explainer,
  n_labels = 1,
  n_features = 10
)

# Visualize
plot_features(explanations)
```

### Byte Pair Encoding

```r
# For handling rare words and subword units
library(tokenizers.bpe)

# Learn BPE vocabulary
bpe_model <- bpe_learn(
  corpus,
  vocab_size = 5000,
  coverage = 0.9999
)

# Encode text
encoded_text <- bpe_encode(text, bpe_model)
```

---

## Statistical Inference

### Bootstrap Confidence Intervals

#### Using infer Package

```r
library(infer)

# Bootstrap workflow
bootstrap_dist <- data %>%
  specify(response = outcome_var) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  calculate(stat = "mean")

# Percentile method
percentile_ci <- bootstrap_dist %>%
  get_confidence_interval(level = 0.95, type = "percentile")

# Standard error method (for normal distributions)
se_ci <- bootstrap_dist %>%
  get_confidence_interval(level = 0.95, type = "se", point_estimate = mean(data$outcome_var))

# Visualize
bootstrap_dist %>%
  visualize() +
  shade_confidence_interval(endpoints = percentile_ci)
```

#### Bootstrap for Regression Slopes

```r
# Bootstrap distribution of slope
slope_bootstrap <- data %>%
  specify(outcome ~ predictor) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  calculate(stat = "slope")

# Confidence interval for slope
slope_ci <- get_confidence_interval(slope_bootstrap, level = 0.95)
```

#### Bootstrap for Difference in Means

```r
# Two-group comparison
diff_bootstrap <- data %>%
  specify(outcome ~ group) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  calculate(stat = "diff in means", order = c("treatment", "control"))

diff_ci <- get_confidence_interval(diff_bootstrap)
```

### Hypothesis Testing

#### Permutation Tests

```r
# Null hypothesis: no relationship between variables

# Generate null distribution
null_dist <- data %>%
  specify(outcome ~ group) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in means", order = c("group1", "group2"))

# Calculate observed statistic
obs_stat <- data %>%
  specify(outcome ~ group) %>%
  calculate(stat = "diff in means", order = c("group1", "group2"))

# Calculate p-value
p_value <- null_dist %>%
  get_p_value(obs_stat = obs_stat, direction = "both")

# Visualize
null_dist %>%
  visualize() +
  shade_p_value(obs_stat = obs_stat, direction = "both")
```

#### Test for Single Mean

```r
# H0: population mean = hypothesized value
null_dist <- data %>%
  specify(response = outcome) %>%
  hypothesize(null = "point", mu = 100) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  calculate(stat = "mean")

obs_mean <- data %>%
  specify(response = outcome) %>%
  calculate(stat = "mean")

p_value <- get_p_value(null_dist, obs_stat = obs_mean, direction = "two-sided")
```

#### Test for Correlation

```r
# H0: no correlation
null_cor_dist <- data %>%
  specify(var1 ~ var2) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "correlation")

obs_cor <- data %>%
  specify(var1 ~ var2) %>%
  calculate(stat = "correlation")

p_value <- get_p_value(null_cor_dist, obs_stat = obs_cor, direction = "both")
```

### Inference for Regression

#### Coefficient Significance

```r
# Bootstrap confidence interval for regression coefficient
coef_bootstrap <- data %>%
  specify(outcome ~ predictor) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  calculate(stat = "slope")

# Check if CI includes zero
coef_ci <- get_confidence_interval(coef_bootstrap, level = 0.95)

# Hypothesis test for coefficient
null_slope_dist <- data %>%
  specify(outcome ~ predictor) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "slope")

obs_slope <- data %>%
  specify(outcome ~ predictor) %>%
  calculate(stat = "slope")

p_value <- get_p_value(null_slope_dist, obs_stat = obs_slope, direction = "both")
```

#### Model Assumptions (LINE)

```r
# Check regression assumptions
library(moderndive)

# 1. Linearity: scatterplot of y vs x
ggplot(data, aes(x = predictor, y = outcome)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# 2. Independence: Consider study design

# 3. Normality of residuals
regression_points <- get_regression_points(model)
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(binwidth = 0.25)

# 4. Equal variance (homoscedasticity)
ggplot(regression_points, aes(x = .fitted, y = residual)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed")
```

#### Theory-Based Inference

```r
# Get regression table with confidence intervals
library(moderndive)

model <- lm(outcome ~ predictor, data = data)
regression_table <- get_regression_table(model)

# Contains: estimate, std_error, statistic, p_value, lower_ci, upper_ci
```

### Sampling Concepts

#### Sampling Distribution Simulation

```r
# Simulate repeated sampling
sampling_distribution <- data %>%
  rep_sample_n(size = 50, reps = 1000) %>%
  group_by(replicate) %>%
  summarize(sample_mean = mean(variable))

# Standard error (SD of sampling distribution)
se <- sd(sampling_distribution$sample_mean)

# Visualize
ggplot(sampling_distribution, aes(x = sample_mean)) +
  geom_histogram(binwidth = 0.5) +
  labs(title = "Sampling Distribution of Sample Mean")
```

#### Representative Sampling

```r
# Random sampling ensures representativeness
sample_data <- data %>%
  slice_sample(n = 100)  # simple random sample

# Stratified sampling
stratified_sample <- data %>%
  group_by(strata_var) %>%
  slice_sample(prop = 0.1) %>%
  ungroup()
```

---

## Complete Workflow Patterns

### Standard Regression Workflow

```r
library(tidymodels)

# 1. Data splitting
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train <- training(data_split)
test <- testing(data_split)

# 2. Recipe
recipe_spec <- recipe(outcome ~ ., data = train) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors())

# 3. Model specification
model_spec <- linear_reg() %>%
  set_engine("lm") %>%
  set_mode("regression")

# 4. Workflow
workflow_spec <- workflow() %>%
  add_recipe(recipe_spec) %>%
  add_model(model_spec)

# 5. Cross-validation
folds <- vfold_cv(train, v = 10)

# 6. Fit resamples
cv_results <- fit_resamples(
  workflow_spec,
  resamples = folds,
  metrics = metric_set(rmse, rsq, mae),
  control = control_resamples(save_pred = TRUE)
)

# 7. Evaluate
collect_metrics(cv_results)

# 8. Final fit on training, evaluate on test
final_fit <- last_fit(workflow_spec, data_split)
collect_metrics(final_fit)

# 9. Extract final model
final_model <- extract_workflow(final_fit)

# 10. Make predictions
predictions <- predict(final_model, new_data = test)
```

### Classification with Tuning

```r
library(tidymodels)

# 1. Data prep
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = class)
train <- training(data_split)
test <- testing(data_split)

# 2. Recipe with tuning placeholder
recipe_spec <- recipe(class ~ ., data = train) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_nzv(all_predictors())

# 3. Model with tuning parameters
model_spec <- rand_forest(
  trees = 1000,
  mtry = tune(),
  min_n = tune()
) %>%
  set_engine("ranger") %>%
  set_mode("classification")

# 4. Workflow
workflow_spec <- workflow() %>%
  add_recipe(recipe_spec) %>%
  add_model(model_spec)

# 5. Cross-validation
folds <- vfold_cv(train, v = 10, strata = class)

# 6. Tuning grid
param_grid <- grid_regular(
  mtry(range = c(1, 10)),
  min_n(range = c(2, 20)),
  levels = 5
)

# 7. Tune
tune_results <- tune_grid(
  workflow_spec,
  resamples = folds,
  grid = param_grid,
  metrics = metric_set(roc_auc, accuracy),
  control = control_grid(save_pred = TRUE)
)

# 8. Select best
best_params <- select_best(tune_results, metric = "roc_auc")

# 9. Finalize workflow
final_workflow <- finalize_workflow(workflow_spec, best_params)

# 10. Final fit
final_fit <- last_fit(final_workflow, data_split)

# 11. Evaluate
collect_metrics(final_fit)
conf_mat_resampled(tune_results)

# 12. Extract and use
final_model <- extract_workflow(final_fit)
predictions <- predict(final_model, test, type = "prob")
```

### Text Classification Workflow

```r
library(tidymodels)
library(textrecipes)

# 1. Data prep
set.seed(123)
data_split <- initial_split(complaints, prop = 0.75, strata = product)
train <- training(data_split)
test <- testing(data_split)

# 2. Text recipe
text_recipe <- recipe(product ~ complaint_text, data = train) %>%
  step_tokenize(complaint_text) %>%
  step_stopwords(complaint_text, stopword_source = "snowball") %>%
  step_tokenfilter(complaint_text, max_tokens = 1000) %>%
  step_tfidf(complaint_text) %>%
  step_normalize(all_predictors())

# 3. Lasso model with tuning
lasso_spec <- logistic_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet") %>%
  set_mode("classification")

# 4. Workflow
text_workflow <- workflow() %>%
  add_recipe(text_recipe) %>%
  add_model(lasso_spec)

# 5. Cross-validation
folds <- vfold_cv(train, v = 10, strata = product)

# 6. Tune penalty
lambda_grid <- grid_regular(penalty(range = c(-5, 0)), levels = 30)

tune_results <- tune_grid(
  text_workflow,
  resamples = folds,
  grid = lambda_grid,
  metrics = metric_set(roc_auc, accuracy)
)

# 7. Select with parsimony
best_penalty <- select_by_one_std_err(
  tune_results,
  metric = "roc_auc",
  desc(penalty)
)

# 8. Finalize and fit
final_workflow <- finalize_workflow(text_workflow, best_penalty)
final_fit <- last_fit(final_workflow, data_split)

# 9. Evaluate
collect_metrics(final_fit)

# 10. Examine coefficients
final_fit %>%
  extract_fit_parsnip() %>%
  tidy() %>%
  arrange(desc(abs(estimate))) %>%
  slice_head(n = 20)

# 11. Make predictions
predictions <- predict(final_fit, test, type = "prob")
```

### Mixed Features Text Workflow

```r
library(tidymodels)
library(textrecipes)
library(themis)

# 1. Data prep with imbalanced classes
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train <- training(data_split)
test <- testing(data_split)

# 2. Complex recipe with text + other features
mixed_recipe <- recipe(outcome ~ text + date + category + amount, data = train) %>%
  # Text processing
  step_tokenize(text) %>%
  step_stopwords(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text) %>%
  # Date features
  step_date(date, features = c("dow", "month", "year")) %>%
  step_rm(date) %>%
  # Categorical features
  step_unknown(category) %>%
  step_dummy(all_nominal_predictors()) %>%
  # Numeric features
  step_normalize(amount) %>%
  # Handle imbalance (after all feature creation)
  step_downsample(outcome) %>%
  # Final normalization
  step_normalize(all_numeric_predictors())

# 3. Model with sparse encoding for efficiency
lasso_spec <- logistic_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet") %>%
  set_mode("classification")

# 4. Workflow with sparse matrix blueprint
sparse_workflow <- workflow() %>%
  add_recipe(
    mixed_recipe,
    blueprint = hardhat::default_recipe_blueprint(composition = "dgCMatrix")
  ) %>%
  add_model(lasso_spec)

# 5. Rest follows standard pattern
folds <- vfold_cv(train, v = 10, strata = outcome)

tune_results <- tune_grid(
  sparse_workflow,
  resamples = folds,
  grid = grid_regular(penalty(), levels = 30),
  metrics = metric_set(roc_auc, accuracy, sensitivity, specificity)
)

best_params <- select_best(tune_results, metric = "roc_auc")
final_workflow <- finalize_workflow(sparse_workflow, best_params)
final_fit <- last_fit(final_workflow, data_split)

collect_metrics(final_fit)
```

### Model Comparison Workflow

```r
library(tidymodels)

# 1. Data prep
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = outcome)
train <- training(data_split)
test <- testing(data_split)
folds <- vfold_cv(train, v = 10, strata = outcome)

# 2. Define multiple recipes
recipe1 <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

recipe2 <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_stopwords(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

recipe3 <- recipe(outcome ~ text, data = train) %>%
  step_tokenize(text, token = "ngrams", options = list(n = 2, n_min = 1)) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

# 3. Define model
svm_spec <- svm_linear() %>%
  set_engine("LiblineaR") %>%
  set_mode("regression")

# 4. Create workflows
workflow1 <- workflow() %>% add_recipe(recipe1) %>% add_model(svm_spec)
workflow2 <- workflow() %>% add_recipe(recipe2) %>% add_model(svm_spec)
workflow3 <- workflow() %>% add_recipe(recipe3) %>% add_model(svm_spec)

# 5. Fit all models
results <- list(
  baseline = fit_resamples(workflow1, folds, metrics = metric_set(rmse, rsq)),
  stopwords = fit_resamples(workflow2, folds, metrics = metric_set(rmse, rsq)),
  bigrams = fit_resamples(workflow3, folds, metrics = metric_set(rmse, rsq))
)

# 6. Compare
comparison <- results %>%
  map_dfr(collect_metrics, .id = "model") %>%
  filter(.metric == "rmse") %>%
  arrange(mean)

print(comparison)

# 7. Select best model
best_model_name <- comparison %>% slice(1) %>% pull(model)
best_workflow <- switch(
  best_model_name,
  baseline = workflow1,
  stopwords = workflow2,
  bigrams = workflow3
)

# 8. Final evaluation
final_fit <- last_fit(best_workflow, data_split)
collect_metrics(final_fit)
```

### Regression with Inference

```r
library(tidymodels)
library(moderndive)
library(infer)

# 1. Fit model
model <- lm(outcome ~ predictor1 + predictor2, data = data)

# 2. Get coefficients with inference
regression_table <- get_regression_table(model)
# Contains: estimate, std_error, statistic, p_value, lower_ci, upper_ci

# 3. Get fitted values and residuals
regression_points <- get_regression_points(model)

# 4. Check assumptions
# Linearity
ggplot(data, aes(x = predictor1, y = outcome)) +
  geom_point() +
  geom_smooth(method = "lm")

# Normality of residuals
ggplot(regression_points, aes(x = residual)) +
  geom_histogram()

# Equal variance
ggplot(regression_points, aes(x = .fitted, y = residual)) +
  geom_point() +
  geom_hline(yintercept = 0)

# 5. Bootstrap confidence intervals
boot_slopes <- data %>%
  specify(outcome ~ predictor1) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  calculate(stat = "slope")

boot_ci <- get_confidence_interval(boot_slopes)

# 6. Hypothesis test for slope
null_dist <- data %>%
  specify(outcome ~ predictor1) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "slope")

obs_slope <- data %>%
  specify(outcome ~ predictor1) %>%
  calculate(stat = "slope")

p_value <- get_p_value(null_dist, obs_stat = obs_slope, direction = "both")

# 7. Visualize
null_dist %>%
  visualize() +
  shade_p_value(obs_stat = obs_slope, direction = "both")
```

---

## Best Practices Summary

### Recipe Design Principles

1. **Order matters**: Apply steps in logical sequence
   - Imputation before normalization
   - Stop word removal before tokenization filtering
   - Feature creation before feature selection
   - Class balancing (downsample/upsample) last

2. **Use selectors**: `all_numeric_predictors()`, `all_nominal_predictors()`, `all_predictors()`

3. **Preserve outcome**: Recipe steps only modify predictors by default

4. **Test on training data only**: Recipes learn parameters from training data

### Model Selection

1. **Start simple**: Baseline/null models establish minimum performance

2. **Regularization helps**: Lasso (mixture=1) performs feature selection

3. **Ensemble methods**: Random forests often perform well with minimal tuning

4. **Text models**: SVM and regularized regression excel with high-dimensional text

### Cross-Validation Strategy

1. **Stratify on outcome**: Preserves class balance or outcome distribution

2. **10-fold standard**: Good balance of bias and variance

3. **Save predictions**: `control_resamples(save_pred = TRUE)` enables detailed analysis

4. **Appropriate metrics**: Match metrics to problem (ROC AUC for imbalanced classification)

### Hyperparameter Tuning

1. **Grid search**: Systematic exploration, visualize results

2. **One standard error rule**: `select_by_one_std_err()` favors simpler models

3. **Computational efficiency**: Use `grid_regular()` with modest `levels` first

4. **Bayesian optimization**: `tune_bayes()` for expensive models (neural networks)

### Text Preprocessing

1. **Normalize first**: Fix encoding issues with `stringi::stri_trans_nfc()`

2. **Stop words contextual**: Not always helpful, test with and without

3. **Token limits**: Balance vocabulary size with computational cost (1000-2000 common)

4. **N-grams add information**: But increase dimensionality substantially

5. **Stemming trade-offs**: Reduces features but loses semantic distinctions

### Evaluation Best Practices

1. **Never touch test set**: Until final evaluation with `last_fit()`

2. **Multiple metrics**: No single metric tells complete story

3. **Confusion matrices**: Essential for classification understanding

4. **Coefficient inspection**: Identify important features and check sanity

5. **Residual plots**: Verify regression assumptions

### Reproducibility

1. **Set seed**: `set.seed()` before any randomization

2. **Document versions**: Package versions affect results

3. **Save workflows**: Entire workflow objects for consistent predictions

### Computational Efficiency

1. **Sparse matrices**: Use `composition = "dgCMatrix"` for text data

2. **Parallel processing**: Enable with `parallel_over = "everything"` in controls

3. **Feature hashing**: Alternative to vocabulary storage for very large corpora

4. **Early stopping**: For neural networks, prevents unnecessary epochs

---

## Common Patterns Cheat Sheet

### Quick Start: Regression

```r
library(tidymodels)
set.seed(123)

# Split, recipe, model, workflow
split <- initial_split(data, prop = 0.75)
rec <- recipe(y ~ ., training(split)) %>% step_normalize(all_predictors())
mod <- linear_reg() %>% set_engine("lm")
wf <- workflow() %>% add_recipe(rec) %>% add_model(mod)

# Fit and evaluate
fit <- last_fit(wf, split)
collect_metrics(fit)
```

### Quick Start: Classification

```r
library(tidymodels)
set.seed(123)

# Split, recipe, model, workflow
split <- initial_split(data, prop = 0.75, strata = class)
rec <- recipe(class ~ ., training(split)) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors())
mod <- logistic_reg() %>% set_engine("glm")
wf <- workflow() %>% add_recipe(rec) %>% add_model(mod)

# Fit and evaluate
fit <- last_fit(wf, split)
collect_metrics(fit)
```

### Quick Start: Text Classification

```r
library(tidymodels)
library(textrecipes)
set.seed(123)

# Split, recipe, model, workflow
split <- initial_split(data, prop = 0.75, strata = class)
rec <- recipe(class ~ text, training(split)) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)
mod <- svm_linear() %>% set_engine("LiblineaR") %>% set_mode("classification")
wf <- workflow() %>% add_recipe(rec) %>% add_model(mod)

# Fit and evaluate
fit <- last_fit(wf, split)
collect_metrics(fit)
```

### Quick Start: With Tuning

```r
library(tidymodels)
set.seed(123)

# Setup
split <- initial_split(data, prop = 0.75, strata = class)
rec <- recipe(class ~ ., training(split)) %>% step_normalize(all_predictors())
mod <- rand_forest(mtry = tune(), min_n = tune()) %>%
  set_engine("ranger") %>%
  set_mode("classification")
wf <- workflow() %>% add_recipe(rec) %>% add_model(mod)

# Tune
folds <- vfold_cv(training(split), v = 10)
tune_res <- tune_grid(wf, folds, grid = 10)
best <- select_best(tune_res, "roc_auc")

# Finalize and evaluate
final_wf <- finalize_workflow(wf, best)
final_fit <- last_fit(final_wf, split)
collect_metrics(final_fit)
```

---

## Key Resources

### Book Chapters Referenced

- **Feature Engineering & Selection**: 12 chapters on creating and selecting predictive features
- **ModernDive**: 11 chapters on statistical inference and modeling with tidyverse
- **Supervised ML for Text Analysis**: 10 chapters on NLP with tidymodels
- **Text Mining with R**: 9 chapters on tidy text principles and applications

### Essential Packages

**Core Tidymodels:**
- `rsample` - data splitting and resampling
- `recipes` - preprocessing and feature engineering
- `parsnip` - unified model interface
- `workflows` - bundling preprocessors and models
- `tune` - hyperparameter optimization
- `yardstick` - performance metrics
- `dials` - parameter definitions

**Text Processing:**
- `textrecipes` - text preprocessing steps
- `tidytext` - tidy text mining
- `tokenizers` - fast tokenization
- `stopwords` - stop word lists

**Specialized:**
- `themis` - handling class imbalance
- `embed` - advanced embeddings
- `infer` - statistical inference
- `moderndive` - teaching-focused helpers

**Deep Learning:**
- `keras` - neural network interface
- `tensorflow` - backend

### Formula Reference

**TF-IDF:**
```
tf-idf(term, doc) = tf(term, doc) × idf(term)
idf(term) = ln(n_documents / n_documents_containing_term)
```

**Cosine Similarity:**
```
cos(v1, v2) = (v1 · v2) / (||v1|| × ||v2||)
```

**Standard Error:**
```
SE = SD / √n
```

**Confidence Interval (95%):**
```
point_estimate ± 1.96 × SE
```

---

*This knowledge base synthesizes content from four comprehensive tidymodels books covering machine learning, statistical inference, text analysis, and feature engineering in R. Use it as a reference for building production ML workflows with the tidymodels ecosystem.*
