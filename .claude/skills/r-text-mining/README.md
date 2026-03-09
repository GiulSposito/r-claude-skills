# R Text Mining and NLP Skill

Expert text mining and natural language processing using R's tidytext and textrecipes ecosystems.

## Overview

This skill provides comprehensive guidance for text analysis and NLP tasks in R, covering:
- Sentiment analysis (opinion mining, emotional tone)
- Topic modeling (discovering themes with LDA)
- Text classification (supervised categorization)
- Text preprocessing (tokenization, cleaning, feature extraction)
- Best practices for text data workflows

## When to Use

Use this skill when you need to:
- Analyze customer reviews, social media, or survey responses
- Classify text documents into categories
- Extract sentiment or emotion from text
- Discover topics or themes in large text corpora
- Build text-based machine learning models
- Process and clean text data for analysis

## Invocation

**Manual**: `/r-text-mining`
**Automatic**: Mention "text analysis", "NLP", "sentiment analysis", "topic modeling", "tidytext", "textrecipes", "tokenization", etc.

## Quick Start

### Sentiment Analysis
```r
library(tidytext)
library(tidyverse)

# Tokenize and get sentiment
tidy_text <- data |>
  unnest_tokens(word, text_column) |>
  inner_join(get_sentiments("bing"), by = "word")

# Calculate scores
sentiment_scores <- tidy_text |>
  count(document_id, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(score = positive - negative)
```

### Topic Modeling
```r
library(topicmodels)

# Create document-term matrix
dtm <- tidy_text |>
  count(document_id, word) |>
  cast_dtm(document_id, word, n)

# Fit LDA
lda_model <- LDA(dtm, k = 5, control = list(seed = 123))

# Extract topics
topics <- tidy(lda_model, matrix = "beta")
top_terms <- topics |>
  group_by(topic) |>
  slice_max(beta, n = 10)
```

### Text Classification
```r
library(tidymodels)
library(textrecipes)

# Split data
data_split <- initial_split(data, strata = category)
train <- training(data_split)
test <- testing(data_split)

# Create recipe
text_recipe <- recipe(category ~ text, data = train) |>
  step_tokenize(text) |>
  step_stopwords(text) |>
  step_tokenfilter(text, max_tokens = 1000) |>
  step_tfidf(text)

# Model and workflow
svm_spec <- svm_linear() |> set_mode("classification")
text_wf <- workflow() |>
  add_recipe(text_recipe) |>
  add_model(svm_spec)

# Fit and evaluate
final_fit <- last_fit(text_wf, data_split)
collect_metrics(final_fit)
```

## Key Features

### Text Preprocessing
- **Tokenization**: Words, n-grams, sentences, characters
- **Cleaning**: Stop word removal, punctuation, numbers
- **Normalization**: Stemming, lemmatization, case folding
- **Feature Extraction**: TF-IDF, embeddings, feature hashing

### Sentiment Analysis
- **Lexicons**: AFINN, Bing, NRC, Loughran (financial)
- **Methods**: Binary classification, numeric scoring, emotion detection
- **Advanced**: Negation handling, time series sentiment, word contribution

### Topic Modeling
- **LDA**: Latent Dirichlet Allocation for topic discovery
- **Selection**: Perplexity, coherence, manual inspection
- **Interpretation**: Topic labeling, representative documents, visualization

### Text Classification
- **Models**: Naive Bayes, Logistic Regression, SVM, Random Forest, XGBoost
- **Workflows**: Complete tidymodels integration
- **Evaluation**: Cross-validation, confusion matrices, ROC curves
- **Production**: Model deployment, monitoring, retraining

## Contents

### Main Skill File
- **SKILL.md**: Complete text mining guide with workflows and best practices

### References
- **text-preprocessing.md**: Comprehensive tokenization and cleaning reference
- **sentiment-analysis.md**: Sentiment lexicons and scoring methods
- **topic-modeling.md**: LDA topic modeling and interpretation
- **text-classification.md**: Supervised classification workflows with tidymodels

### Examples
- **customer-reviews-analysis.md**: End-to-end analysis with sentiment, topics, and classification

## Task Types

### 1. Sentiment Analysis
**Use when**: Analyzing opinions, reviews, social media
**Output**: Sentiment scores, positive/negative classification, emotional tone
**Lexicons**: AFINN (numeric), Bing (binary), NRC (emotions), Loughran (financial)

### 2. Topic Modeling
**Use when**: Discovering themes in large text corpora
**Output**: Topic-word distributions, document-topic assignments, topic labels
**Method**: Latent Dirichlet Allocation (LDA)

### 3. Text Classification
**Use when**: Categorizing documents automatically
**Output**: Predicted categories, probabilities, model performance metrics
**Models**: Naive Bayes, SVM, Random Forest, XGBoost

### 4. Text Preprocessing
**Use when**: Preparing text for any analysis
**Output**: Clean, tokenized text ready for modeling
**Steps**: Tokenization → Cleaning → Normalization → Feature extraction

## Common Workflows

### Quick Sentiment Analysis
1. Tokenize text with `unnest_tokens()`
2. Join with sentiment lexicon (e.g., `get_sentiments("bing")`)
3. Calculate sentiment scores per document
4. Visualize sentiment distribution
5. Identify top positive/negative words

### Topic Discovery
1. Preprocess text (remove stops, filter rare/common words)
2. Create document-term matrix
3. Fit LDA models with different k (number of topics)
4. Select k based on perplexity and interpretability
5. Extract and label topics
6. Assign documents to topics

### Text Classification Pipeline
1. Split data (train/test, stratified)
2. Create textrecipes preprocessing recipe
3. Specify multiple model types
4. Cross-validate to compare models
5. Select best model
6. Evaluate on test set
7. Deploy and monitor

## Integration with Other Skills

- **tidyverse-patterns**: For data manipulation and visualization
- **r-tidymodels**: For machine learning workflows
- **ggplot2**: For visualizing text analysis results
- **r-style-guide**: For code formatting standards
- **tdd-workflow**: For testing text processing pipelines

## Best Practices

✅ **Always** start with exploratory visualization (word frequencies, length distribution)
✅ **Always** remove stop words for most analyses
✅ **Always** validate sentiment against sample of documents
✅ **Always** use cross-validation for classification
✅ **Always** report prediction intervals/confidence, not just point estimates
✅ **Consider** domain-specific lexicons (e.g., Loughran for financial)
✅ **Consider** n-grams to capture phrases
✅ **Consider** negation handling for sentiment

❌ **Never** skip text preprocessing
❌ **Never** use train/test split without stratification (for classification)
❌ **Never** ignore class imbalance
❌ **Never** rely solely on automated topic labels
❌ **Never** treat lexicon-based sentiment as ground truth

## Resources

### External Documentation
- [Text Mining with R](https://www.tidytextmining.com/)
- [tidytext package](https://juliasilge.github.io/tidytext/)
- [textrecipes package](https://textrecipes.tidymodels.org/)
- [tidymodels](https://www.tidymodels.org/)

### Internal References
See `references/` directory for detailed guides on preprocessing, sentiment, topics, and classification.

## Tips

### For Sentiment Analysis
- Choose lexicon based on domain (Bing general, Loughran financial, NRC emotions)
- Always check sentiment coverage (% of words with sentiment)
- Handle negation for better accuracy
- Validate on sample documents

### For Topic Modeling
- Start with small k (3-5), increase gradually
- Remove very rare (< 2-3 docs) and very common (> 50% docs) words
- Manually inspect and label topics
- Try multiple k values, choose most interpretable

### For Text Classification
- Start with simple model (Naive Bayes), add complexity if needed
- Use TF-IDF or embeddings for features
- Tune max_tokens parameter (500-2000 typical)
- Check for class imbalance, handle with resampling if needed

## Troubleshooting

**Low sentiment coverage**: Add domain-specific words to lexicon
**Meaningless topics**: Try different k, better preprocessing, more data
**Low classification accuracy**: More data, better features (n-grams, embeddings), handle imbalance
**Slow processing**: Use feature hashing, reduce token count, parallel processing

## Version

1.0.0 - Initial release

## Feedback

For issues or suggestions, consult the main skill documentation or CLAUDE.md in the project root.
