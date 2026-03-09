---
name: r-text-mining
description: Expert text mining and NLP in R using tidytext and textrecipes. Use when analyzing text data, mentions "text analysis", "NLP", "sentiment analysis", "topic modeling", "tidytext", "textrecipes", "tokenization", "TF-IDF", "text classification", "word embeddings", "natural language processing", or any text/NLP task in R.
version: 1.0.0
user-invocable: true
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---

# R Text Mining and NLP Expert

You are an expert in text mining and natural language processing using R's tidytext and textrecipes ecosystems.

## Core Philosophy

1. **Tidy Text Principles**: One-token-per-row format for analysis
2. **Preprocessing First**: Clean and prepare text before modeling
3. **Multiple Methods**: Try different approaches (TF-IDF, embeddings, etc.)
4. **Context Matters**: Consider domain-specific patterns and vocabulary
5. **Validate Results**: Use both quantitative metrics and qualitative review

## When This Skill Activates

Use this skill when:
- Analyzing textual data (reviews, documents, tweets, etc.)
- Performing sentiment analysis
- Building topic models
- Classifying text documents
- Extracting features from text for machine learning
- Working with tidytext or textrecipes packages
- Processing natural language

## Task Classification & Dispatch

### 1. Sentiment Analysis
**Triggers**: "sentiment", "opinion mining", "positive/negative", "emotional tone"

**Workflow**:
1. Tokenize text to tidy format
2. Join with sentiment lexicons (AFINN, bing, nrc)
3. Calculate sentiment scores
4. Visualize sentiment distribution
5. Identify key sentiment-driving words

**See**: [references/sentiment-analysis.md](references/sentiment-analysis.md)

### 2. Topic Modeling
**Triggers**: "topics", "LDA", "themes", "discover patterns"

**Workflow**:
1. Create document-term matrix
2. Fit LDA model (choose k topics)
3. Extract top terms per topic
4. Assign documents to topics
5. Interpret and label topics

**See**: [references/topic-modeling.md](references/topic-modeling.md)

### 3. Text Classification
**Triggers**: "classify text", "predict category", "text machine learning"

**Workflow**:
1. Prepare data (train/test split)
2. Create textrecipes recipe
3. Choose model (logistic, naive Bayes, SVM)
4. Tune hyperparameters
5. Evaluate performance
6. Deploy model

**See**: [references/text-classification.md](references/text-classification.md)

### 4. Text Preprocessing
**Triggers**: "clean text", "tokenize", "remove stop words", "normalize"

**Workflow**:
1. Tokenization (words, n-grams, sentences)
2. Cleaning (stop words, punctuation, numbers)
3. Normalization (stemming, lemmatization, lowercasing)
4. Feature extraction (TF-IDF, embeddings)

**See**: [references/text-preprocessing.md](references/text-preprocessing.md)

## Quick Start Workflows

### Sentiment Analysis
```r
library(tidytext)
library(tidyverse)

# Tokenize
tidy_text <- data %>%
  unnest_tokens(word, text_column)

# Get sentiment
sentiment <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(document_id, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(score = positive - negative)
```

### Topic Modeling
```r
library(tidytext)
library(topicmodels)

# Create DTM
dtm <- tidy_text %>%
  count(document_id, word) %>%
  cast_dtm(document_id, word, n)

# Fit LDA
lda_model <- LDA(dtm, k = 5, control = list(seed = 123))

# Extract topics
topics <- tidy(lda_model, matrix = "beta")
```

### Text Classification (tidymodels)
```r
library(tidymodels)
library(textrecipes)

# Split data
data_split <- initial_split(data, strata = category)
train <- training(data_split)
test <- testing(data_split)

# Recipe
text_recipe <- recipe(category ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_stopwords(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text)

# Model
svm_spec <- svm_linear() %>%
  set_mode("classification")

# Workflow
text_wf <- workflow() %>%
  add_recipe(text_recipe) %>%
  add_model(svm_spec)

# Fit and evaluate
fit <- last_fit(text_wf, data_split)
collect_metrics(fit)
```

## Text Preprocessing Methods

### Tokenization
```r
library(tidytext)

# Words (unigrams)
data %>% unnest_tokens(word, text)

# Bigrams
data %>% unnest_tokens(bigram, text, token = "ngrams", n = 2)

# Trigrams
data %>% unnest_tokens(trigram, text, token = "ngrams", n = 3)

# Sentences
data %>% unnest_tokens(sentence, text, token = "sentences")

# Characters
data %>% unnest_tokens(character, text, token = "characters")
```

### Cleaning
```r
# Remove stop words
tidy_text %>%
  anti_join(stop_words, by = "word")

# Custom stop words
custom_stops <- tibble(word = c("word1", "word2"))
tidy_text %>% anti_join(custom_stops, by = "word")

# Remove numbers
tidy_text %>%
  filter(!str_detect(word, "\\d+"))

# Remove rare/common words
word_counts <- tidy_text %>% count(word)
tidy_text %>%
  filter(word %in% (word_counts %>% filter(n > 5, n < 1000) %>% pull(word)))
```

### Normalization
```r
# Lowercasing (done automatically by unnest_tokens)

# Stemming
library(SnowballC)
tidy_text %>%
  mutate(stem = wordStem(word))

# Lemmatization (requires spaCy or similar)
# Via textrecipes:
recipe(~ text, data) %>%
  step_tokenize(text, engine = "spacyr") %>%
  step_lemma(text)
```

## Sentiment Analysis

### Available Lexicons
```r
library(tidytext)

# AFINN: numeric score -5 to +5
get_sentiments("afinn")

# Bing: binary positive/negative
get_sentiments("bing")

# NRC: emotions (joy, fear, anger, etc.)
get_sentiments("nrc")

# Loughran: financial sentiment
get_sentiments("loughran")
```

### Sentiment Scoring
```r
# Binary sentiment (bing)
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
```

## Topic Modeling (LDA)

### Basic LDA Workflow
```r
library(topicmodels)
library(tidytext)

# 1. Create document-term matrix
dtm <- tidy_text %>%
  count(document, word) %>%
  cast_dtm(document, word, n)

# 2. Fit LDA
lda_model <- LDA(dtm, k = 5, control = list(seed = 123))

# 3. Extract topic-term probabilities (beta)
topics <- tidy(lda_model, matrix = "beta")

# Top terms per topic
top_terms <- topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10)

# 4. Extract document-topic probabilities (gamma)
doc_topics <- tidy(lda_model, matrix = "gamma")

# Assign documents to most likely topic
doc_classification <- doc_topics %>%
  group_by(document) %>%
  slice_max(gamma, n = 1)
```

### Choosing Number of Topics (k)
```r
# Fit multiple models
library(purrr)

models <- tibble(k = 2:10) %>%
  mutate(
    lda_model = map(k, ~LDA(dtm, k = .x, control = list(seed = 123))),
    perplexity = map_dbl(lda_model, perplexity, newdata = dtm)
  )

# Plot perplexity (lower is better, look for elbow)
ggplot(models, aes(k, perplexity)) +
  geom_line() +
  geom_point() +
  labs(title = "Model Perplexity by Number of Topics")
```

## Text Classification with Tidymodels

### textrecipes Steps

Common preprocessing steps for text:
```r
recipe(outcome ~ text, data = train) %>%

  # 1. Tokenization
  step_tokenize(text) %>%
  step_tokenize(text, token = "ngrams", options = list(n = 2, n_min = 1)) %>%

  # 2. Filtering
  step_stopwords(text, stopword_source = "snowball") %>%
  step_stem(text) %>%  # Stemming
  step_tokenfilter(text, max_tokens = 1000, min_times = 5) %>%

  # 3. Feature generation
  step_tfidf(text) %>%  # TF-IDF weighting
  step_texthash(text, num_terms = 512) %>%  # Feature hashing (alternative)

  # 4. Normalization
  step_normalize(all_predictors())
```

### Model Selection for Text

| Model | Pros | Cons | Use When |
|-------|------|------|----------|
| **Naive Bayes** | Fast, interpretable, good baseline | Assumes independence | Quick baseline |
| **Logistic Regression** | Interpretable, regularizable | Linear decision boundary | Interpretability needed |
| **SVM** | Good with high-dimensional text | Slower, less interpretable | Accuracy priority |
| **Random Forest** | Handles interactions, robust | Slow, memory-intensive | Complex patterns |
| **XGBoost** | State-of-art accuracy | Slow, many hyperparameters | Competition/production |
| **Neural Networks** | Can learn complex patterns | Needs large data, slow | Large datasets |

### Complete Classification Workflow
```r
library(tidymodels)
library(textrecipes)

# 1. Split
set.seed(123)
data_split <- initial_split(data, prop = 0.75, strata = category)
train <- training(data_split)
test <- testing(data_split)

# 2. Recipe
text_recipe <- recipe(category ~ text, data = train) %>%
  step_tokenize(text) %>%
  step_stopwords(text) %>%
  step_tokenfilter(text, max_tokens = 1000) %>%
  step_tfidf(text) %>%
  step_normalize(all_predictors())

# 3. Model specs
nb_spec <- naive_Bayes() %>% set_engine("naivebayes") %>% set_mode("classification")
svm_spec <- svm_linear() %>% set_engine("LiblineaR") %>% set_mode("classification")
rf_spec <- rand_forest(trees = 500) %>% set_engine("ranger") %>% set_mode("classification")

# 4. Workflows
nb_wf <- workflow() %>% add_recipe(text_recipe) %>% add_model(nb_spec)
svm_wf <- workflow() %>% add_recipe(text_recipe) %>% add_model(svm_spec)
rf_wf <- workflow() %>% add_recipe(text_recipe) %>% add_model(rf_spec)

# 5. Cross-validation
folds <- vfold_cv(train, v = 10, strata = category)

# 6. Fit resamples
nb_fit <- fit_resamples(nb_wf, folds)
svm_fit <- fit_resamples(svm_wf, folds)
rf_fit <- fit_resamples(rf_wf, folds)

# 7. Compare
bind_rows(
  collect_metrics(nb_fit) %>% mutate(model = "Naive Bayes"),
  collect_metrics(svm_fit) %>% mutate(model = "SVM"),
  collect_metrics(rf_fit) %>% mutate(model = "Random Forest")
) %>%
  filter(.metric == "accuracy") %>%
  arrange(desc(mean))

# 8. Final fit
final_wf <- svm_wf  # Or best performer
final_fit <- last_fit(final_wf, data_split)
collect_metrics(final_fit)

# 9. Confusion matrix
collect_predictions(final_fit) %>%
  conf_mat(truth = category, estimate = .pred_class)
```

## TF-IDF (Term Frequency-Inverse Document Frequency)

### Concept
Measures how important a word is to a document in a collection:
- **TF**: How often word appears in document
- **IDF**: Downweights common words across documents
- **TF-IDF**: TF × IDF

### Using TF-IDF
```r
library(tidytext)

# Calculate TF-IDF
tf_idf <- tidy_text %>%
  count(document, word) %>%
  bind_tf_idf(word, document, n)

# Find distinctive words per document
distinctive <- tf_idf %>%
  group_by(document) %>%
  slice_max(tf_idf, n = 10)

# Visualize
tf_idf %>%
  group_by(document) %>%
  slice_max(tf_idf, n = 10) %>%
  ggplot(aes(tf_idf, reorder_within(word, tf_idf, document))) +
  geom_col() +
  facet_wrap(~document, scales = "free") +
  scale_y_reordered()
```

## Best Practices

### Preprocessing
✅ **Always** convert to tidy format first
✅ **Always** remove stop words (unless needed for context)
✅ **Always** check token distribution (too rare/common)
✅ **Always** handle lowercase/capitalization consistently
✅ **Consider** stemming for English (improves recall)
✅ **Consider** n-grams for capturing phrases

### Sentiment Analysis
✅ **Choose** lexicon appropriate to domain (e.g., loughran for finance)
✅ **Consider** negation handling ("not good" vs "good")
✅ **Validate** against known examples
✅ **Report** confidence/coverage (% of words with sentiment)

### Topic Modeling
✅ **Try** multiple values of k (number of topics)
✅ **Remove** very common and very rare terms first
✅ **Validate** topics make intuitive sense
✅ **Label** topics after inspection (don't rely on automatic labels)

### Text Classification
✅ **Start** with simple baseline (naive Bayes, logistic)
✅ **Use** cross-validation for robust evaluation
✅ **Try** different feature representations (TF-IDF, hashing, embeddings)
✅ **Tune** max_tokens parameter (balance accuracy vs speed)
✅ **Check** for class imbalance (use stratified splits, resampling)

## Common Pitfalls

❌ **Not removing stop words** → Noise in features
✅ Use `step_stopwords()` or `anti_join(stop_words)`

❌ **Too many/few features** → Overfitting or underfitting
✅ Tune `max_tokens` parameter (500-2000 typically)

❌ **Ignoring class imbalance** → Model biased to majority class
✅ Use stratified splits, `step_downsample()`, `step_upsample()`, or `step_smote()`

❌ **Not handling negation** → "not good" treated as "good"
✅ Use bigrams or custom preprocessing to capture negation

❌ **Overfitting on small data** → Poor generalization
✅ Use regularization (ridge/lasso), cross-validation, simpler models

❌ **Not validating topic quality** → Meaningless topics
✅ Inspect top terms, document assignments, coherence metrics

## Supporting Resources

### Comprehensive References
- **text-preprocessing.md**: Complete tokenization and cleaning guide
- **sentiment-analysis.md**: Lexicon-based sentiment with examples
- **topic-modeling.md**: LDA and topic interpretation
- **text-classification.md**: Full tidymodels text classification

### Workflow Templates
- **sentiment-workflow.md**: Step-by-step sentiment analysis
- **topic-modeling-workflow.md**: Complete LDA workflow
- **text-classification-workflow.md**: End-to-end classification

### Complete Examples
- **customer-reviews-analysis.md**: Full sentiment + classification example

## Quick Reference

### Package Loading
```r
library(tidytext)      # Tidy text analysis
library(textrecipes)   # Text preprocessing for tidymodels
library(topicmodels)   # LDA topic modeling
library(tidymodels)    # ML workflows
```

### Essential Functions

| Task | Function |
|------|----------|
| Tokenize | `unnest_tokens()` |
| Remove stop words | `anti_join(stop_words)` |
| Sentiment | `get_sentiments()` + `inner_join()` |
| TF-IDF | `bind_tf_idf()` |
| DTM | `cast_dtm()` |
| LDA | `LDA()` from topicmodels |
| Text recipe | `recipe() %>% step_tokenize() %>% step_tfidf()` |

## Integration with Other Skills

- **r-datascience**: For data preparation and EDA
- **r-tidymodels**: For ML workflows with text
- **ggplot2**: For visualizing text analysis results
- **r-style-guide**: For code formatting
- **tdd-workflow**: For testing text pipelines

---

**Remember**: Text analysis is both art and science. Always validate computational results with qualitative review and domain expertise.
