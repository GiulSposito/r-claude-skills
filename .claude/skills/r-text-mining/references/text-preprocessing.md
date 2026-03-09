# Text Preprocessing Guide

Complete reference for cleaning and preparing text data for analysis.

## Tokenization

### Basic Tokenization with tidytext

```r
library(tidytext)

# Words (default)
data |> unnest_tokens(word, text_column)

# N-grams
data |> unnest_tokens(bigram, text_column, token = "ngrams", n = 2)
data |> unnest_tokens(trigram, text_column, token = "ngrams", n = 3)

# Sentences
data |> unnest_tokens(sentence, text_column, token = "sentences")

# Characters
data |> unnest_tokens(character, text_column, token = "characters")

# Lines
data |> unnest_tokens(line, text_column, token = "lines")

# Custom regex pattern
data |> unnest_tokens(
  word,
  text_column,
  token = "regex",
  pattern = "[[:alpha:]]+"
)
```

### Advanced Tokenization Options

```r
# Keep punctuation
data |> unnest_tokens(word, text_column, strip_punct = FALSE)

# Keep numbers
data |> unnest_tokens(word, text_column, strip_numeric = FALSE)

# Custom token pattern (hashtags)
data |> unnest_tokens(
  hashtag,
  text_column,
  token = "regex",
  pattern = "#\\w+"
)

# Email addresses
data |> unnest_tokens(
  email,
  text_column,
  token = "regex",
  pattern = "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"
)
```

## Stop Word Removal

### Using Built-in Stop Words

```r
library(tidytext)

# Default English stop words
data("stop_words")

tidy_text |>
  anti_join(stop_words, by = "word")

# Specific lexicon
stop_words |> filter(lexicon == "snowball")  # 175 words
stop_words |> filter(lexicon == "SMART")     # 571 words
stop_words |> filter(lexicon == "onix")      # 404 words
```

### Custom Stop Words

```r
# Add domain-specific stop words
custom_stops <- tibble(
  word = c("company", "product", "customer", "service")
)

tidy_text |>
  anti_join(stop_words, by = "word") |>
  anti_join(custom_stops, by = "word")

# Combine with built-in
all_stops <- bind_rows(stop_words, custom_stops)
tidy_text |> anti_join(all_stops, by = "word")
```

### Selective Stop Word Removal

```r
# Keep negation words
negation_words <- c("not", "no", "never", "none", "nobody", "nothing")

custom_stops <- stop_words |>
  filter(!word %in% negation_words)

tidy_text |> anti_join(custom_stops, by = "word")
```

## Text Cleaning

### Removing Unwanted Characters

```r
# Remove numbers
tidy_text |>
  filter(!str_detect(word, "\\d+"))

# Remove punctuation-only tokens
tidy_text |>
  filter(str_detect(word, "[a-zA-Z]"))

# Remove URLs
text <- str_remove_all(text, "http\\S+|www\\S+")

# Remove email addresses
text <- str_remove_all(text, "\\S+@\\S+")

# Remove mentions (@username)
text <- str_remove_all(text, "@\\w+")

# Remove hashtags
text <- str_remove_all(text, "#\\w+")

# Remove extra whitespace
text <- str_squish(text)
```

### Case Normalization

```r
# Lowercase (done automatically by unnest_tokens)
# But if needed manually:
text <- str_to_lower(text)

# Title case
text <- str_to_title(text)

# Uppercase
text <- str_to_upper(text)
```

### Special Character Handling

```r
library(stringr)

# Remove all punctuation
text <- str_remove_all(text, "[[:punct:]]")

# Keep specific punctuation (e.g., hyphens, apostrophes)
text <- str_remove_all(text, "[^[:alnum:][:space:]'-]")

# Replace multiple spaces with single space
text <- str_replace_all(text, "\\s+", " ")

# Remove leading/trailing whitespace
text <- str_trim(text)
```

## Stemming and Lemmatization

### Stemming (Porter Algorithm)

```r
library(SnowballC)

# Stem individual words
wordStem("running")  # → "run"
wordStem("better")   # → "better"

# Stem tidy text
tidy_text |>
  mutate(stem = wordStem(word, language = "english"))

# Group by stems
tidy_text |>
  mutate(stem = wordStem(word)) |>
  count(document_id, stem)
```

### Lemmatization

```r
# Via textrecipes (requires spaCy installation)
library(textrecipes)

recipe(~ text, data = data) |>
  step_tokenize(text, engine = "spacyr") |>
  step_lemma(text)

# Note: spaCy must be installed:
# reticulate::py_install("spacy")
# system("python -m spacy download en_core_web_sm")
```

### Stemming vs Lemmatization

| Method | Speed | Accuracy | Example |
|--------|-------|----------|---------|
| **Stemming** | Fast | Approximate | "running" → "run", "better" → "better" |
| **Lemmatization** | Slow | Accurate | "running" → "run", "better" → "good" |

**Use stemming for**: Speed, English text, exploratory analysis
**Use lemmatization for**: Accuracy, morphologically rich languages

## N-gram Processing

### Extracting N-grams

```r
# Bigrams
bigrams <- data |>
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

# Separate bigrams
bigrams |>
  separate_wider_delim(bigram, delim = " ", names = c("word1", "word2"))

# Filter bigrams with stop words
bigrams_separated <- bigrams |>
  separate_wider_delim(bigram, delim = " ", names = c("word1", "word2")) |>
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word)

# Recombine
bigrams_filtered <- bigrams_separated |>
  unite(bigram, word1, word2, sep = " ")
```

### N-gram Frequency Analysis

```r
# Most common bigrams
bigrams |>
  count(bigram, sort = TRUE)

# Bigrams starting with specific word
bigrams_separated |>
  filter(word1 == "data") |>
  count(word2, sort = TRUE)

# Network of word connections
library(igraph)
library(ggraph)

bigram_graph <- bigrams_separated |>
  filter(n > 20) |>
  graph_from_data_frame()

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1)
```

## Token Filtering

### By Frequency

```r
# Remove rare words (appear < 5 times)
word_counts <- tidy_text |>
  count(word) |>
  filter(n >= 5)

tidy_text_filtered <- tidy_text |>
  semi_join(word_counts, by = "word")

# Remove very common words (appear in > 90% of documents)
doc_freq <- tidy_text |>
  distinct(document_id, word) |>
  count(word) |>
  mutate(doc_prop = n / n_distinct(tidy_text$document_id)) |>
  filter(doc_prop < 0.9)

tidy_text |>
  semi_join(doc_freq, by = "word")
```

### By Document Frequency

```r
# Keep words appearing in 2-50% of documents
idf <- tidy_text |>
  distinct(document_id, word) |>
  count(word) |>
  mutate(
    n_docs = n_distinct(tidy_text$document_id),
    doc_freq = n / n_docs
  ) |>
  filter(doc_freq >= 0.02, doc_freq <= 0.50)

tidy_text |>
  semi_join(idf, by = "word")
```

### By Length

```r
# Remove very short/long words
tidy_text |>
  filter(nchar(word) >= 3, nchar(word) <= 15)
```

## textrecipes Preprocessing

### Complete textrecipes Pipeline

```r
library(textrecipes)
library(tidymodels)

text_recipe <- recipe(outcome ~ text, data = train) |>
  # 1. Tokenization
  step_tokenize(text) |>

  # 2. Filtering
  step_stopwords(text, stopword_source = "snowball") |>
  step_stem(text) |>
  step_tokenfilter(
    text,
    max_tokens = 1000,  # Keep top 1000 tokens
    min_times = 5       # Must appear >= 5 times
  ) |>

  # 3. Feature generation
  step_tfidf(text) |>

  # 4. Normalization
  step_normalize(all_predictors())
```

### textrecipes Step Options

```r
# Tokenization engines
step_tokenize(text, engine = "tokenizers")  # Default, fast
step_tokenize(text, engine = "spacyr")      # spaCy, accurate

# N-grams
step_tokenize(text, token = "ngrams", options = list(n = 2, n_min = 1))

# Stop words sources
step_stopwords(text, stopword_source = "snowball")  # 175 words
step_stopwords(text, stopword_source = "smart")     # 571 words
step_stopwords(text, stopword_source = "stopwords-iso")  # 1,298 words

# Custom stop words
step_stopwords(text, custom_stopword_source = c("word1", "word2"))

# Token filtering
step_tokenfilter(
  text,
  max_tokens = 1000,    # Maximum features
  min_times = 5,        # Minimum frequency
  max_times = Inf,      # Maximum frequency
  percentage = FALSE    # Use counts not percentages
)

# Feature generation
step_tfidf(text)                           # TF-IDF
step_tf(text)                              # Term frequency only
step_texthash(text, num_terms = 512)      # Feature hashing
step_word_embeddings(text, embeddings)    # Pre-trained embeddings

# Lemmatization/Stemming
step_lemma(text)  # Requires spacyr
step_stem(text)   # Porter stemmer
```

## Special Text Types

### Social Media Text

```r
# Extract hashtags
hashtags <- str_extract_all(text, "#\\w+")

# Extract mentions
mentions <- str_extract_all(text, "@\\w+")

# Remove emojis
text <- iconv(text, "UTF-8", "ASCII", sub = "")

# Or keep emojis (requires specific handling)
library(textclean)
text_with_emoji_descriptions <- replace_emoji(text)
```

### HTML/XML Text

```r
library(rvest)
library(xml2)

# Extract text from HTML
html <- read_html("<html>...</html>")
text <- html_text(html)

# Remove HTML tags
text <- str_remove_all(text, "<[^>]+>")

# Decode HTML entities
library(textclean)
text <- replace_html(text)
```

### PDF Text

```r
library(pdftools)

# Extract text from PDF
text <- pdf_text("document.pdf")

# Clean up spacing issues common in PDFs
text <- str_replace_all(text, "-\\n", "")  # Hyphenation
text <- str_replace_all(text, "\\n", " ")  # Newlines
text <- str_squish(text)  # Multiple spaces
```

## Best Practices

### Preprocessing Order

1. **Case normalization** (if needed manually)
2. **Special character removal** (URLs, emails, etc.)
3. **Tokenization**
4. **Stop word removal**
5. **Stemming/Lemmatization** (if needed)
6. **Token filtering** (by frequency, length)
7. **Feature generation** (TF-IDF, embeddings)

### Guidelines

✅ **Keep preprocessing reproducible** - save recipe or document steps
✅ **Test on sample** - verify cleaning doesn't remove important info
✅ **Domain-specific** - customize stop words and patterns
✅ **Balance** - don't over-clean (may lose signal)
✅ **Validate** - inspect results after each major step

❌ **Don't remove everything** - some "noise" contains signal
❌ **Don't stem without reason** - may harm interpretability
❌ **Don't use one-size-fits-all** - different tasks need different preprocessing

## Quick Reference

| Task | Function/Pattern |
|------|------------------|
| Tokenize words | `unnest_tokens(word, text)` |
| Tokenize bigrams | `unnest_tokens(bigram, text, token = "ngrams", n = 2)` |
| Remove stop words | `anti_join(stop_words)` |
| Stem | `mutate(stem = SnowballC::wordStem(word))` |
| Remove numbers | `filter(!str_detect(word, "\\d+"))` |
| Remove short words | `filter(nchar(word) >= 3)` |
| Remove URLs | `str_remove_all(text, "http\\S+")` |
| Clean whitespace | `str_squish(text)` |
| TF-IDF | `bind_tf_idf(word, document, n)` |
