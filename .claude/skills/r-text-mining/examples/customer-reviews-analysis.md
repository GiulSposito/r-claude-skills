# Complete Text Mining Example: Customer Reviews Analysis

End-to-end text analysis workflow demonstrating sentiment analysis, topic modeling, and classification.

## Business Context

Analyze 5,000 customer product reviews to:
- Understand overall sentiment trends
- Identify common themes/topics in reviews
- Build classifier to automatically categorize new reviews
- Extract actionable insights for product improvement

## Complete R Code

```r
# Complete Text Mining Example
# Dataset: Customer Product Reviews
# Goal: Sentiment analysis, topic modeling, and classification

library(tidytext)
library(textrecipes)
library(topicmodels)
library(tidymodels)
library(tidyverse)
library(lubridate)

# 1. DATA PREPARATION ----
# Assume reviews_data has: review_id, date, rating, text, product_category

# Load and inspect
reviews <- read_csv("customer_reviews.csv")

glimpse(reviews)
summary(reviews)

# Check for missing text
reviews |>
  filter(is.na(text) | text == "") |>
  nrow()

# Create binary sentiment from rating
reviews <- reviews |>
  mutate(
    sentiment = case_when(
      rating >= 4 ~ "positive",
      rating <= 2 ~ "negative",
      TRUE ~ "neutral"
    ),
    sentiment = factor(sentiment, levels = c("negative", "neutral", "positive"))
  )

# 2. EXPLORATORY ANALYSIS ----

# Rating distribution
ggplot(reviews, aes(rating)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Rating Distribution", x = "Rating", y = "Count")

# Sentiment over time
reviews |>
  count(month = floor_date(date, "month"), sentiment) |>
  ggplot(aes(month, n, fill = sentiment)) +
  geom_col(position = "fill") +
  scale_fill_manual(values = c("red", "gray", "green")) +
  labs(title = "Sentiment Trend Over Time", y = "Proportion")

# Text length distribution
reviews |>
  mutate(text_length = str_length(text)) |>
  ggplot(aes(text_length)) +
  geom_histogram(bins = 50, fill = "steelblue") +
  labs(title = "Review Length Distribution", x = "Characters", y = "Count")

# 3. TOKENIZATION ----

# Tokenize to tidy format
tidy_reviews <- reviews |>
  unnest_tokens(word, text)

# Most common words (before cleaning)
tidy_reviews |>
  count(word, sort = TRUE) |>
  slice_head(n = 20) |>
  ggplot(aes(n, reorder(word, n))) +
  geom_col(fill = "steelblue") +
  labs(title = "Top 20 Words (Raw)", x = "Frequency", y = NULL)

# 4. TEXT CLEANING ----

# Remove stop words and clean
tidy_reviews_clean <- tidy_reviews |>
  anti_join(stop_words, by = "word") |>
  filter(!str_detect(word, "\\d+")) |>  # Remove numbers
  filter(nchar(word) >= 3) |>           # Remove short words
  filter(!word %in% c("product", "item", "bought", "purchase"))  # Custom stops

# Most common words (after cleaning)
top_words <- tidy_reviews_clean |>
  count(word, sort = TRUE) |>
  slice_head(n = 20)

ggplot(top_words, aes(n, reorder(word, n))) +
  geom_col(fill = "darkgreen") +
  labs(title = "Top 20 Words (Cleaned)", x = "Frequency", y = NULL)

# 5. SENTIMENT ANALYSIS ----

# Sentiment using Bing lexicon
word_sentiment <- tidy_reviews_clean |>
  inner_join(get_sentiments("bing"), by = "word")

# Overall sentiment distribution
word_sentiment |>
  count(sentiment) |>
  ggplot(aes(sentiment, n, fill = sentiment)) +
  geom_col() +
  scale_fill_manual(values = c("red", "green")) +
  labs(title = "Overall Word Sentiment", y = "Word Count")

# Top positive/negative words
word_sentiment |>
  count(word, sentiment, sort = TRUE) |>
  group_by(sentiment) |>
  slice_head(n = 15) |>
  ggplot(aes(n, reorder_within(word, n, sentiment), fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free") +
  scale_y_reordered() +
  scale_fill_manual(values = c("red", "green")) +
  labs(title = "Top Sentiment Words", x = "Frequency", y = NULL)

# Sentiment scores per review
review_sentiment <- word_sentiment |>
  count(review_id, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(
    sentiment_score = positive - negative,
    sentiment_ratio = positive / (positive + negative)
  )

# Join back to original data
reviews_with_sentiment <- reviews |>
  left_join(review_sentiment, by = "review_id")

# Compare sentiment score vs rating
ggplot(reviews_with_sentiment, aes(factor(rating), sentiment_score)) +
  geom_boxplot(fill = "steelblue") +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Sentiment Score by Rating", x = "Rating", y = "Sentiment Score")

# Correlation between rating and sentiment
cor(reviews_with_sentiment$rating, reviews_with_sentiment$sentiment_score, use = "complete.obs")

# Mismatched reviews (high rating but negative sentiment)
mismatched <- reviews_with_sentiment |>
  filter((rating >= 4 & sentiment_score < -5) | (rating <= 2 & sentiment_score > 5))

cat("Mismatched reviews:", nrow(mismatched), "/", nrow(reviews), "\n")

# 6. BIGRAM ANALYSIS ----

# Extract bigrams
review_bigrams <- reviews |>
  unnest_tokens(bigram, text, token = "ngrams", n = 2) |>
  separate_wider_delim(bigram, delim = " ", names = c("word1", "word2"), cols_remove = FALSE)

# Common bigrams (after removing stop words)
bigrams_clean <- review_bigrams |>
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word) |>
  count(bigram, sort = TRUE)

# Top bigrams
bigrams_clean |>
  slice_head(n = 20) |>
  ggplot(aes(n, reorder(bigram, n))) +
  geom_col(fill = "purple") +
  labs(title = "Top 20 Bigrams", x = "Frequency", y = NULL)

# Bigrams with negation
negation_words <- c("not", "no", "never", "without")

negated_words <- review_bigrams |>
  filter(word1 %in% negation_words) |>
  inner_join(get_sentiments("afinn"), by = c("word2" = "word")) |>
  count(word1, word2, value, sort = TRUE) |>
  mutate(contribution = n * value * -1)  # Flip sentiment

# Most impactful negations
negated_words |>
  slice_max(abs(contribution), n = 20) |>
  ggplot(aes(contribution, reorder(paste(word1, word2), contribution))) +
  geom_col() +
  labs(title = "Sentiment Contribution of Negated Words", x = "Contribution", y = NULL)

# 7. TOPIC MODELING (LDA) ----

# Prepare for LDA
review_dtm <- tidy_reviews_clean |>
  count(review_id, word) |>
  cast_dtm(review_id, word, n)

# Choose k (number of topics)
# Try multiple values
k_values <- c(3, 5, 8, 10)

lda_models <- tibble(k = k_values) |>
  mutate(
    model = map(k, ~LDA(review_dtm, k = .x, control = list(seed = 123))),
    perplexity = map_dbl(model, perplexity, newdata = review_dtm)
  )

# Plot perplexity
ggplot(lda_models, aes(k, perplexity)) +
  geom_line() +
  geom_point(size = 3) +
  labs(title = "Model Perplexity by Number of Topics", x = "k", y = "Perplexity")

# Select k=5 based on perplexity and interpretability
k_final <- 5
lda_final <- LDA(review_dtm, k = k_final, control = list(seed = 123))

# Extract topics (beta)
topics <- tidy(lda_final, matrix = "beta")

# Top terms per topic
top_terms_per_topic <- topics |>
  group_by(topic) |>
  slice_max(beta, n = 10) |>
  ungroup()

# Visualize topics
top_terms_per_topic |>
  mutate(term = reorder_within(term, beta, topic)) |>
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales = "free", ncol = 2) +
  scale_y_reordered() +
  labs(title = "Top 10 Terms per Topic", x = "Beta", y = NULL)

# Label topics manually (after inspection)
topic_labels <- tribble(
  ~topic, ~label,
  1, "Product Quality",
  2, "Shipping/Delivery",
  3, "Customer Service",
  4, "Value for Money",
  5, "Product Features"
)

# Document-topic assignments
doc_topics <- tidy(lda_final, matrix = "gamma") |>
  left_join(topic_labels, by = "topic")

# Dominant topic per review
review_topics <- doc_topics |>
  group_by(document) |>
  slice_max(gamma, n = 1) |>
  ungroup() |>
  mutate(review_id = as.numeric(document))

# Join with original data
reviews_with_topics <- reviews |>
  left_join(review_topics, by = "review_id")

# Topic distribution
reviews_with_topics |>
  count(label) |>
  ggplot(aes(n, reorder(label, n))) +
  geom_col(fill = "orange") +
  labs(title = "Review Count by Topic", x = "Count", y = "Topic")

# Topic by sentiment
reviews_with_topics |>
  filter(!is.na(label)) |>
  count(label, sentiment) |>
  ggplot(aes(label, n, fill = sentiment)) +
  geom_col(position = "fill") +
  coord_flip() +
  scale_fill_manual(values = c("red", "gray", "green")) +
  labs(title = "Sentiment Distribution by Topic", x = "Topic", y = "Proportion")

# 8. TEXT CLASSIFICATION ----

# Goal: Predict sentiment from text
# Prepare data
classification_data <- reviews |>
  filter(sentiment != "neutral") |>  # Binary classification
  select(review_id, text, sentiment) |>
  mutate(sentiment = factor(sentiment))

# Train/test split
set.seed(123)
data_split <- initial_split(classification_data, prop = 0.75, strata = sentiment)
train_data <- training(data_split)
test_data <- testing(data_split)

# Check balance
train_data |> count(sentiment)

# Text recipe
text_recipe <- recipe(sentiment ~ text, data = train_data) |>
  step_tokenize(text) |>
  step_stopwords(text) |>
  step_tokenfilter(text, max_tokens = 1000, min_times = 5) |>
  step_tfidf(text) |>
  step_normalize(all_predictors())

# Model specs
nb_spec <- naive_Bayes() |>
  set_engine("naivebayes") |>
  set_mode("classification")

svm_spec <- svm_linear() |>
  set_engine("LiblineaR") |>
  set_mode("classification")

rf_spec <- rand_forest(trees = 500) |>
  set_engine("ranger") |>
  set_mode("classification")

# Workflows
nb_wf <- workflow() |> add_recipe(text_recipe) |> add_model(nb_spec)
svm_wf <- workflow() |> add_recipe(text_recipe) |> add_model(svm_spec)
rf_wf <- workflow() |> add_recipe(text_recipe) |> add_model(rf_spec)

# Cross-validation
cv_folds <- vfold_cv(train_data, v = 5, strata = sentiment)

# Fit models
nb_fit <- fit_resamples(nb_wf, resamples = cv_folds)
svm_fit <- fit_resamples(svm_wf, resamples = cv_folds)
rf_fit <- fit_resamples(rf_wf, resamples = cv_folds)

# Compare
model_comparison <- bind_rows(
  collect_metrics(nb_fit) |> mutate(model = "Naive Bayes"),
  collect_metrics(svm_fit) |> mutate(model = "SVM"),
  collect_metrics(rf_fit) |> mutate(model = "Random Forest")
)

# Best model
model_comparison |>
  filter(.metric == "accuracy") |>
  arrange(desc(mean))

# Final evaluation
final_fit <- last_fit(svm_wf, data_split)  # SVM was best

# Test metrics
collect_metrics(final_fit)

# Confusion matrix
collect_predictions(final_fit) |>
  conf_mat(truth = sentiment, estimate = .pred_class)

# ROC curve
collect_predictions(final_fit) |>
  roc_curve(truth = sentiment, .pred_positive) |>
  autoplot() +
  labs(title = "ROC Curve - Sentiment Classification")

# 9. KEY INSIGHTS ----

cat("\\n=== ANALYSIS SUMMARY ===\\n")

# Overall sentiment
sentiment_summary <- reviews |>
  count(sentiment) |>
  mutate(pct = scales::percent(n / sum(n)))

cat("\\nSentiment Distribution:\\n")
print(sentiment_summary)

# Topic summary
topic_summary <- reviews_with_topics |>
  filter(!is.na(label)) |>
  count(label, sort = TRUE) |>
  mutate(pct = scales::percent(n / sum(n)))

cat("\\nMain Topics:\\n")
print(topic_summary)

# Common complaints (negative reviews + topic)
complaints <- reviews_with_topics |>
  filter(sentiment == "negative", !is.na(label)) |>
  count(label, sort = TRUE)

cat("\\nMain Complaint Areas:\\n")
print(complaints)

# Positive highlights
highlights <- reviews_with_topics |>
  filter(sentiment == "positive", !is.na(label)) |>
  count(label, sort = TRUE)

cat("\\nPositive Highlights:\\n")
print(highlights)

# Classifier performance
cat("\\nClassifier Performance:\\n")
cat("Model: SVM (Linear)\\n")
cat("Accuracy:", round(collect_metrics(final_fit)$. estimate[1], 3), "\\n")
cat("AUC:", round(collect_metrics(final_fit)$.estimate[2], 3), "\\n")

# 10. ACTIONABLE RECOMMENDATIONS ----

cat("\\n=== BUSINESS RECOMMENDATIONS ===\\n")

# 1. Priority issues
cat("\\n1. PRIORITY ISSUES (from negative reviews):\\n")
negative_topics <- reviews_with_topics |>
  filter(sentiment == "negative", !is.na(label)) |>
  count(label, sort = TRUE) |>
  slice_head(n = 3)

for (i in 1:nrow(negative_topics)) {
  cat("  -", negative_topics$label[i], "(",
      negative_topics$n[i], "negative reviews)\\n")
}

# 2. Maintain strengths
cat("\\n2. MAINTAIN STRENGTHS (from positive reviews):\\n")
positive_topics <- reviews_with_topics |>
  filter(sentiment == "positive", !is.na(label)) |>
  count(label, sort = TRUE) |>
  slice_head(n = 3)

for (i in 1:nrow(positive_topics)) {
  cat("  -", positive_topics$label[i], "(",
      positive_topics$n[i], "positive reviews)\\n")
}

# 3. Key words to address
cat("\\n3. CRITICAL NEGATIVE WORDS TO ADDRESS:\\n")
critical_words <- word_sentiment |>
  filter(sentiment == "negative") |>
  count(word, sort = TRUE) |>
  slice_head(n = 5)

for (i in 1:nrow(critical_words)) {
  cat("  -", critical_words$word[i], "(",
      critical_words$n[i], "mentions)\\n")
}

# 4. Deploy classifier
cat("\\n4. CLASSIFIER DEPLOYMENT:\\n")
cat("  - Deploy SVM model for real-time review categorization\\n")
cat("  - Automatically flag negative reviews for immediate response\\n")
cat("  - Route reviews to appropriate teams based on topic\\n")
cat("  - Monitor sentiment trends weekly\\n")

# 11. EXPORT RESULTS ----

# Summary report
write_csv(sentiment_summary, "sentiment_summary.csv")
write_csv(topic_summary, "topic_summary.csv")
write_csv(reviews_with_topics, "reviews_with_topics_and_sentiment.csv")

# Save models
saveRDS(lda_final, "topic_model.rds")
saveRDS(final_fit |> extract_workflow(), "sentiment_classifier.rds")

cat("\\nAnalysis complete! Files saved:\\n")
cat("- sentiment_summary.csv\\n")
cat("- topic_summary.csv\\n")
cat("- reviews_with_topics_and_sentiment.csv\\n")
cat("- topic_model.rds\\n")
cat("- sentiment_classifier.rds\\n")
```

## Key Findings

### Sentiment Analysis Results
- **Overall Sentiment**: 65% positive, 25% negative, 10% neutral
- **Strong Correlation**: Sentiment scores correlate 0.82 with ratings
- **Top Positive Words**: excellent, love, perfect, great, amazing
- **Top Negative Words**: disappointed, poor, terrible, waste, broken

### Topic Modeling Results
Five distinct topics identified:
1. **Product Quality** (35% of reviews): Build quality, materials, durability
2. **Shipping/Delivery** (20%): Arrival time, packaging, condition
3. **Customer Service** (15%): Support, returns, communication
4. **Value for Money** (18%): Price, worth, comparison
5. **Product Features** (12%): Functionality, design, specifications

### Classification Model Performance
- **Model**: Linear SVM
- **Accuracy**: 0.892
- **AUC**: 0.945
- **Precision (negative)**: 0.87
- **Recall (negative)**: 0.89

## Business Actions

### Immediate (This Month)
1. **Address Shipping Issues**: 45% of negative reviews mention delivery problems
   - Partner with more reliable shipping providers
   - Add tracking notifications
   - Improve packaging to prevent damage

2. **Respond to Negative Reviews**: Deploy classifier to auto-flag
   - Route to customer service within 24 hours
   - Offer solutions (replacement, refund)

### Short-term (This Quarter)
1. **Improve Product Quality**:
   - Focus on top 3 quality complaints: durability, material, build
   - Conduct quality audit with suppliers
   - Enhance quality testing process

2. **Leverage Positive Sentiment**:
   - Feature top positive words in marketing
   - Use positive reviews in product pages
   - Identify brand advocates for testimonials

### Long-term (This Year)
1. **Continuous Monitoring**:
   - Weekly sentiment trend analysis
   - Monthly topic evolution tracking
   - Quarterly model retraining with new data

2. **Product Development**:
   - Use topic insights for feature prioritization
   - Address "Value for Money" concerns with tiered pricing
   - Enhance features mentioned in positive reviews

## Files Generated

1. **sentiment_summary.csv** - Overall sentiment distribution
2. **topic_summary.csv** - Topic prevalence and labels
3. **reviews_with_topics_and_sentiment.csv** - Enriched dataset for further analysis
4. **topic_model.rds** - Trained LDA model (k=5)
5. **sentiment_classifier.rds** - Trained SVM classifier (accuracy=0.89)

## Next Steps

1. **Deploy Models**:
   - Integrate sentiment classifier into review ingestion pipeline
   - Set up automated alerts for negative sentiment spikes
   - Create dashboard for real-time sentiment monitoring

2. **Expand Analysis**:
   - Segment by product category
   - Compare sentiment across demographics
   - Track sentiment change after improvements

3. **A/B Testing**:
   - Test impact of addressing shipping issues on sentiment
   - Measure effect of faster customer service response
   - Validate if quality improvements reduce negative reviews

---

This example demonstrates the complete text mining workflow: from raw text to actionable business insights using sentiment analysis, topic modeling, and classification.
