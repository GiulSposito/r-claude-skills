# Sentiment Analysis Guide

Complete reference for sentiment analysis using tidytext lexicons and scoring methods.

## Overview

Sentiment analysis assigns emotional tone to text using predefined word-sentiment mappings (lexicons). This guide covers lexicon-based sentiment analysis in R.

## Available Sentiment Lexicons

### AFINN

**Type**: Numeric scores (-5 to +5)
**Words**: 2,477
**Best for**: Fine-grained sentiment intensity

```r
library(tidytext)

# Load AFINN lexicon
afinn <- get_sentiments("afinn")

# Structure
head(afinn)
#   word      value
#   abandon    -2
#   abandoned  -2
#   abandons   -2
#   abducted   -2
#   abduction  -2
#   abilities   2

# Score distribution
afinn |> count(value)
```

**Pros**:
- Numeric scores capture intensity (very positive vs slightly positive)
- Good for detecting strong sentiment
- Works well for social media text

**Cons**:
- Smaller vocabulary than SMART stop words
- Scores are subjective
- Doesn't handle context (sarcasm, negation)

### Bing

**Type**: Binary (positive/negative)
**Words**: 6,786
**Best for**: Simple positive/negative classification

```r
# Load Bing lexicon
bing <- get_sentiments("bing")

# Structure
head(bing)
#   word       sentiment
#   2-faces    negative
#   abnormal   negative
#   abolish    negative
#   abominable negative
#   abominably negative
#   abominate  negative

# Distribution
bing |> count(sentiment)
#   sentiment     n
#   negative   4781
#   positive   2005
```

**Pros**:
- Large vocabulary (6,786 words)
- Simple binary classification
- Good general-purpose lexicon

**Cons**:
- Imbalanced (more negative words)
- No intensity information
- Binary may oversimplify

### NRC

**Type**: Multiple emotions + positive/negative
**Words**: 13,901
**Emotions**: anger, anticipation, disgust, fear, joy, sadness, surprise, trust

```r
# Load NRC lexicon
nrc <- get_sentiments("nrc")

# Structure
head(nrc)
#   word      sentiment
#   abacus    trust
#   abandon   fear
#   abandon   negative
#   abandon   sadness
#   abandoned anger
#   abandoned fear

# Available sentiments
nrc |> distinct(sentiment)
#   anger, anticipation, disgust, fear, joy,
#   negative, positive, sadness, surprise, trust

# Words per emotion
nrc |> count(sentiment, sort = TRUE)
```

**Pros**:
- Rich emotional categories
- Large vocabulary
- Good for emotion detection beyond pos/neg

**Cons**:
- Words can have multiple emotions
- Emotion categories subjective
- Noisy for simple sentiment

### Loughran

**Type**: Financial sentiment categories
**Words**: 4,150
**Categories**: constraining, litigious, negative, positive, superfluous, uncertainty

```r
# Load Loughran lexicon
loughran <- get_sentiments("loughran")

# Structure
head(loughran)
#   word        sentiment
#   abandon     negative
#   abandoned   negative
#   abandoning  negative
#   abandonment negative
#   abandonments negative
#   abandons    negative

# Categories
loughran |> count(sentiment, sort = TRUE)
```

**Pros**:
- Specialized for financial/business text
- Captures domain-specific sentiment (uncertainty, litigious)
- More accurate for business documents

**Cons**:
- Only useful for financial domain
- Limited to business vocabulary
- Not appropriate for general text

## Lexicon Comparison

| Lexicon | Words | Type | Best For |
|---------|-------|------|----------|
| **AFINN** | 2,477 | Numeric (-5 to +5) | Social media, intensity |
| **Bing** | 6,786 | Binary (pos/neg) | General purpose |
| **NRC** | 13,901 | Emotions + pos/neg | Emotion detection |
| **Loughran** | 4,150 | Financial categories | Business/financial text |

## Basic Sentiment Scoring

### Binary Sentiment (Bing)

```r
library(tidytext)
library(tidyverse)

# Tokenize text
tidy_text <- data |>
  unnest_tokens(word, text_column)

# Join with Bing sentiment
sentiment_words <- tidy_text |>
  inner_join(get_sentiments("bing"), by = "word")

# Count by sentiment
sentiment_counts <- sentiment_words |>
  count(document_id, sentiment)

# Calculate sentiment score
sentiment_scores <- sentiment_counts |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(
    sentiment_score = positive - negative,
    total_sentiment_words = positive + negative,
    sentiment_ratio = positive / (positive + negative)
  )

# Classify documents
sentiment_scores |>
  mutate(
    sentiment_class = case_when(
      sentiment_score > 0 ~ "positive",
      sentiment_score < 0 ~ "negative",
      TRUE ~ "neutral"
    )
  )
```

### Numeric Sentiment (AFINN)

```r
# AFINN scoring
afinn_scores <- tidy_text |>
  inner_join(get_sentiments("afinn"), by = "word") |>
  group_by(document_id) |>
  summarise(
    sentiment = sum(value),
    sentiment_mean = mean(value),
    n_sentiment_words = n()
  )

# Normalize by document length
tidy_text |>
  inner_join(get_sentiments("afinn"), by = "word") |>
  group_by(document_id) |>
  summarise(
    sentiment_sum = sum(value),
    sentiment_words = n()
  ) |>
  left_join(
    tidy_text |> count(document_id, name = "total_words"),
    by = "document_id"
  ) |>
  mutate(
    sentiment_per_word = sentiment_sum / total_words,
    sentiment_coverage = sentiment_words / total_words
  )
```

### Emotion Analysis (NRC)

```r
# Extract emotions
nrc_emotions <- tidy_text |>
  inner_join(get_sentiments("nrc"), by = "word") |>
  filter(!sentiment %in% c("positive", "negative"))  # Focus on emotions

# Count emotions per document
emotion_counts <- nrc_emotions |>
  count(document_id, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0)

# Dominant emotion per document
dominant_emotion <- nrc_emotions |>
  count(document_id, sentiment) |>
  group_by(document_id) |>
  slice_max(n, n = 1) |>
  select(document_id, dominant_emotion = sentiment, emotion_count = n)

# Emotion profile
emotion_profile <- nrc_emotions |>
  count(document_id, sentiment) |>
  group_by(document_id) |>
  mutate(
    total_emotion_words = sum(n),
    emotion_prop = n / total_emotion_words
  )
```

## Advanced Sentiment Techniques

### Time Series Sentiment

```r
# Sentiment over time
time_sentiment <- tidy_text |>
  inner_join(get_sentiments("bing"), by = "word") |>
  count(date, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(sentiment = positive - negative)

# Plot
ggplot(time_sentiment, aes(date, sentiment)) +
  geom_line() +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Sentiment Over Time", y = "Sentiment Score")

# Rolling average
library(zoo)
time_sentiment |>
  mutate(sentiment_ma = rollmean(sentiment, k = 7, fill = NA)) |>
  ggplot(aes(date, sentiment_ma)) +
  geom_line()
```

### Sentiment by Category/Group

```r
# Compare sentiment across groups
group_sentiment <- tidy_text |>
  inner_join(get_sentiments("bing"), by = "word") |>
  count(group_var, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(
    sentiment_score = positive - negative,
    sentiment_ratio = positive / (positive + negative)
  )

# Visualize
group_sentiment |>
  ggplot(aes(reorder(group_var, sentiment_score), sentiment_score, fill = sentiment_score > 0)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("red", "green")) +
  labs(title = "Sentiment by Group", x = "Group", y = "Sentiment Score")
```

### Word Contribution to Sentiment

```r
# Most positive/negative words
word_sentiment_contribution <- tidy_text |>
  inner_join(get_sentiments("afinn"), by = "word") |>
  count(word, value, sort = TRUE) |>
  mutate(contribution = n * value)

# Top positive contributors
word_sentiment_contribution |>
  filter(contribution > 0) |>
  slice_max(contribution, n = 15) |>
  ggplot(aes(contribution, reorder(word, contribution))) +
  geom_col(fill = "darkgreen") +
  labs(title = "Top Positive Words", x = "Contribution", y = NULL)

# Top negative contributors
word_sentiment_contribution |>
  filter(contribution < 0) |>
  slice_min(contribution, n = 15) |>
  ggplot(aes(contribution, reorder(word, contribution))) +
  geom_col(fill = "darkred") +
  labs(title = "Top Negative Words", x = "Contribution", y = NULL)
```

### Sentiment with Context (Bigrams)

```r
# Bigrams with negation
library(tidyr)

bigrams <- data |>
  unnest_tokens(bigram, text_column, token = "ngrams", n = 2) |>
  separate_wider_delim(bigram, delim = " ", names = c("word1", "word2"))

# Negation words
negation_words <- c("not", "no", "never", "without", "nobody", "nowhere",
                   "nothing", "neither", "hardly", "scarcely", "barely")

# Words preceded by negation
negated_sentiment <- bigrams |>
  filter(word1 %in% negation_words) |>
  inner_join(get_sentiments("afinn"), by = c("word2" = "word")) |>
  mutate(
    value = -value,  # Flip sentiment
    word = paste(word1, word2)
  ) |>
  count(word, value, sort = TRUE)

# Most common negated words
negated_sentiment |>
  slice_max(n, n = 20) |>
  ggplot(aes(n, reorder(word, n), fill = value > 0)) +
  geom_col() +
  labs(title = "Most Common Negated Sentiment Words")
```

## Visualization Patterns

### Sentiment Distribution

```r
# Distribution of sentiment scores
ggplot(sentiment_scores, aes(sentiment_score)) +
  geom_histogram(binwidth = 1, fill = "steelblue") +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Distribution of Sentiment Scores", x = "Sentiment Score", y = "Count")

# Density by group
ggplot(sentiment_scores, aes(sentiment_score, fill = group)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment Distribution by Group")
```

### Word Clouds

```r
library(wordcloud)
library(RColorBrewer)

# Sentiment word cloud
tidy_text |>
  inner_join(get_sentiments("bing"), by = "word") |>
  count(word, sentiment, sort = TRUE) |>
  acast(word ~ sentiment, value.var = "n", fill = 0) |>
  comparison.cloud(colors = c("red", "green"), max.words = 100)

# Single sentiment word cloud
tidy_text |>
  inner_join(get_sentiments("bing"), by = "word") |>
  filter(sentiment == "positive") |>
  count(word) |>
  with(wordcloud(word, n, max.words = 100))
```

### Sentiment Heatmap

```r
# Sentiment by document and time
sentiment_matrix <- tidy_text |>
  inner_join(get_sentiments("bing"), by = "word") |>
  count(document_id, time_period, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(sentiment = positive - negative)

ggplot(sentiment_matrix, aes(time_period, document_id, fill = sentiment)) +
  geom_tile() +
  scale_fill_gradient2(low = "red", mid = "white", high = "green", midpoint = 0) +
  labs(title = "Sentiment Heatmap")
```

## Handling Limitations

### Negation Handling

```r
# Simple negation detection
negation_words <- c("not", "no", "never", "neither", "nobody", "nowhere",
                   "nothing", "none", "hardly", "scarcely", "barely")

# Mark negated words (within 3-word window)
tidy_text_with_negation <- tidy_text |>
  mutate(
    word_id = row_number(),
    negated = word %in% negation_words
  ) |>
  mutate(
    in_negation_window = lag(negated, 1) | lag(negated, 2) | lag(negated, 3)
  )

# Flip sentiment for negated words
sentiment_with_negation <- tidy_text_with_negation |>
  inner_join(get_sentiments("afinn"), by = "word") |>
  mutate(value = if_else(in_negation_window, -value, value)) |>
  group_by(document_id) |>
  summarise(sentiment = sum(value))
```

### Domain-Specific Lexicons

```r
# Create custom lexicon
custom_lexicon <- tibble(
  word = c("excellent", "outstanding", "terrible", "awful", "decent"),
  value = c(5, 5, -5, -4, 2)
)

# Combine with existing lexicon
combined_lexicon <- bind_rows(
  get_sentiments("afinn"),
  custom_lexicon |> anti_join(get_sentiments("afinn"), by = "word")
)

# Use combined lexicon
tidy_text |>
  inner_join(combined_lexicon, by = "word") |>
  group_by(document_id) |>
  summarise(sentiment = sum(value))
```

### Handling Intensifiers

```r
# Intensifiers boost sentiment
intensifiers <- c("very", "extremely", "absolutely", "completely", "totally",
                 "really", "highly", "quite", "especially", "particularly")

# Boost sentiment for words following intensifiers
sentiment_with_boost <- bigrams |>
  filter(word1 %in% intensifiers) |>
  inner_join(get_sentiments("afinn"), by = c("word2" = "word")) |>
  mutate(
    value = value * 1.5,  # Boost by 50%
    word = paste(word1, word2)
  )
```

## Evaluation and Validation

### Sentiment Coverage

```r
# What proportion of words have sentiment?
sentiment_coverage <- tidy_text |>
  left_join(get_sentiments("bing"), by = "word") |>
  group_by(document_id) |>
  summarise(
    total_words = n(),
    sentiment_words = sum(!is.na(sentiment)),
    coverage = sentiment_words / total_words
  )

# Low coverage warning
sentiment_coverage |>
  filter(coverage < 0.05) |>
  arrange(coverage)
```

### Manual Validation

```r
# Extract sample for manual review
sample_sentiment <- tidy_text |>
  inner_join(get_sentiments("bing"), by = "word") |>
  group_by(document_id) |>
  summarise(
    sentiment_score = sum(if_else(sentiment == "positive", 1, -1)),
    text_preview = paste(word[1:50], collapse = " ")
  )

# Review extreme cases
sample_sentiment |>
  filter(abs(sentiment_score) > 10) |>
  select(document_id, sentiment_score, text_preview)
```

### Confusion Matrix (if labeled data available)

```r
# If you have true sentiment labels
sentiment_predictions <- sentiment_scores |>
  mutate(
    predicted = case_when(
      sentiment_score > 1 ~ "positive",
      sentiment_score < -1 ~ "negative",
      TRUE ~ "neutral"
    )
  )

# Confusion matrix
library(yardstick)
sentiment_predictions |>
  conf_mat(truth = true_sentiment, estimate = predicted)

# Metrics
sentiment_predictions |>
  metrics(truth = true_sentiment, estimate = predicted)
```

## Best Practices

### Choosing a Lexicon

✅ **AFINN** for:
- Social media text (Twitter, reviews)
- Need for sentiment intensity
- Short texts

✅ **Bing** for:
- General-purpose sentiment
- Large corpus analysis
- Simple positive/negative classification

✅ **NRC** for:
- Emotion detection beyond sentiment
- Marketing/brand analysis
- Psychological studies

✅ **Loughran** for:
- Financial reports/earnings calls
- Business documents
- Legal/corporate text

### General Guidelines

✅ **Always** check sentiment coverage (% of words with sentiment)
✅ **Always** handle negation for better accuracy
✅ **Always** validate on sample (manual review)
✅ **Always** normalize by document length
✅ **Consider** domain-specific lexicons or augmentations
✅ **Consider** context window for negation/intensifiers
✅ **Report** both score and confidence/coverage

### Common Pitfalls

❌ **Ignoring negation** → "not good" scored as positive
✅ Use bigrams to detect negation patterns

❌ **Not normalizing** → Long documents score higher
✅ Divide by document length or use proportions

❌ **Low coverage** → Sentiment based on few words
✅ Report coverage, warn if < 5%

❌ **Wrong lexicon** → Using Bing for financial text
✅ Choose domain-appropriate lexicon

❌ **Treating as ground truth** → Lexicons are imperfect
✅ Validate with manual review, treat as baseline

## Quick Reference

| Task | Code Pattern |
|------|--------------|
| Basic Bing sentiment | `inner_join(get_sentiments("bing"))` |
| AFINN score | `inner_join(get_sentiments("afinn")) |> summarise(sum(value))` |
| NRC emotions | `inner_join(get_sentiments("nrc")) |> filter(!sentiment %in% c("pos", "neg"))` |
| Time series | `count(date, sentiment) |> pivot_wider(...)` |
| Word contribution | `count(word, value) |> mutate(contribution = n * value)` |
| Negation handling | Use bigrams with negation word list |
| Custom lexicon | `bind_rows(get_sentiments(...), custom_tibble)` |
| Coverage check | `summarise(coverage = sum(!is.na(sentiment)) / n())` |

## Integration with Modeling

Sentiment scores can be used as features in text classification:

```r
library(textrecipes)

# Add sentiment features to recipe
recipe(outcome ~ text, data = train) |>
  step_tokenize(text) |>
  step_word_embeddings(text, embeddings = glove) |>
  # Custom step for sentiment
  step_mutate(
    sentiment = map_dbl(text, ~{
      tibble(word = .x) |>
        inner_join(get_sentiments("afinn"), by = "word") |>
        summarise(sent = sum(value)) |>
        pull(sent)
    })
  )
```

---

**Remember**: Lexicon-based sentiment is a baseline. For production systems, consider supervised learning with labeled data for better accuracy.
