# NLP Patterns with Keras3

This guide demonstrates natural language processing patterns using Keras3 preprocessing layers and text models in R.

## Text Vectorization

Convert raw text strings to integer sequences using `layer_text_vectorization()`.

```r
library(keras3)

# Sample text data
texts <- c(
  "The quick brown fox jumps over the lazy dog",
  "Machine learning is fascinating",
  "Deep learning with Keras3",
  "Natural language processing in R"
)

# Create text vectorization layer
text_vectorizer <- layer_text_vectorization(
  max_tokens = 1000,              # Vocabulary size
  output_mode = "int",             # Output as integers
  output_sequence_length = 20      # Pad/truncate to fixed length
)

# Adapt to training data (build vocabulary)
text_vectorizer |> adapt(texts)

# Transform text to sequences
sequences <- text_vectorizer(as_tensor(texts, dtype = "string"))
print(sequences)

# Get vocabulary
vocab <- text_vectorizer$get_vocabulary()
cat("Vocabulary size:", length(vocab), "\n")
cat("First 10 words:", paste(vocab[1:10], collapse = ", "), "\n")
```

### Text Vectorization Modes

Different output modes for different tasks.

```r
# Mode 1: Integer sequences (for embeddings)
vectorizer_int <- layer_text_vectorization(
  max_tokens = 1000,
  output_mode = "int",
  output_sequence_length = 50
)

# Mode 2: Multi-hot encoding (for bag-of-words)
vectorizer_multihot <- layer_text_vectorization(
  max_tokens = 1000,
  output_mode = "multi_hot"
)

# Mode 3: TF-IDF (for traditional ML)
vectorizer_tfidf <- layer_text_vectorization(
  max_tokens = 1000,
  output_mode = "tf_idf"
)

# Mode 4: Count (term frequency)
vectorizer_count <- layer_text_vectorization(
  max_tokens = 1000,
  output_mode = "count"
)

# Example usage
texts <- c("hello world", "hello keras", "world of deep learning")

# Adapt all
vectorizer_int |> adapt(texts)
vectorizer_multihot |> adapt(texts)
vectorizer_tfidf |> adapt(texts)
vectorizer_count |> adapt(texts)

# Compare outputs
cat("Int mode:\n")
print(vectorizer_int(as_tensor(texts[1], dtype = "string")))

cat("\nMulti-hot mode:\n")
print(vectorizer_multihot(as_tensor(texts[1], dtype = "string")))

cat("\nTF-IDF mode:\n")
print(vectorizer_tfidf(as_tensor(texts[1], dtype = "string")))

cat("\nCount mode:\n")
print(vectorizer_count(as_tensor(texts[1], dtype = "string")))
```

## Embedding Layer

Learn dense vector representations for words.

```r
# Simple embedding model
vocabulary_size <- 10000
embedding_dim <- 128
sequence_length <- 100

input <- keras_input(shape = c(sequence_length), dtype = "int32")

# Embedding layer
embedded <- input |>
  layer_embedding(
    input_dim = vocabulary_size,
    output_dim = embedding_dim,
    mask_zero = TRUE  # Enable masking for variable-length sequences
  )

# embedded shape: (batch, sequence_length, embedding_dim)

# Use in model
output <- embedded |>
  layer_global_average_pooling_1d() |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dense(units = 1, activation = "sigmoid")

model <- keras_model(inputs = input, outputs = output)
```

### Embedding with Trainable Flag

Control whether embeddings are updated during training.

```r
# Frozen embeddings (e.g., for pre-trained embeddings)
frozen_embedding <- layer_embedding(
  input_dim = vocabulary_size,
  output_dim = embedding_dim,
  trainable = FALSE  # Don't update during training
)

# Fine-tunable embeddings (start frozen, unfreeze later)
finetunable_embedding <- layer_embedding(
  input_dim = vocabulary_size,
  output_dim = embedding_dim,
  trainable = TRUE
)
```

## Text Classification

Complete text classification pipeline.

```r
library(keras3)

# Build text classifier
build_text_classifier <- function(max_tokens = 10000,
                                   sequence_length = 200,
                                   embedding_dim = 128,
                                   num_classes = 2) {
  # Input: raw text strings
  input <- keras_input(shape = 1, dtype = "string", name = "text")

  # Text vectorization
  vectorized <- input |>
    layer_text_vectorization(
      max_tokens = max_tokens,
      output_sequence_length = sequence_length,
      output_mode = "int"
    )

  # Embedding
  embedded <- vectorized |>
    layer_embedding(
      input_dim = max_tokens,
      output_dim = embedding_dim,
      mask_zero = TRUE
    )

  # Feature extraction
  features <- embedded |>
    layer_global_average_pooling_1d()

  # Classification
  output <- features |>
    layer_dense(units = 64, activation = "relu") |>
    layer_dropout(rate = 0.5) |>
    layer_dense(
      units = if (num_classes == 2) 1 else num_classes,
      activation = if (num_classes == 2) "sigmoid" else "softmax"
    )

  # Build model
  model <- keras_model(inputs = input, outputs = output)

  return(model)
}

# Example: Binary sentiment classification
texts <- c(
  "This movie was absolutely fantastic! I loved it.",
  "Terrible film, waste of time.",
  "An amazing experience, highly recommend.",
  "Boring and predictable plot."
)
labels <- c(1, 0, 1, 0)  # 1 = positive, 0 = negative

# Create and adapt model
model <- build_text_classifier(num_classes = 2)

# Get vectorization layer and adapt
text_layer <- model$layers[[2]]  # Second layer is text_vectorization
text_layer |> adapt(texts)

# Compile
model |> compile(
  optimizer = optimizer_adam(),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

# Train
history <- model |> fit(
  x = array(texts, dim = c(length(texts), 1)),
  y = labels,
  epochs = 10,
  batch_size = 2
)
```

## Sequence Models (LSTM/GRU)

Use recurrent layers for sequence processing.

```r
# LSTM-based text classifier
build_lstm_classifier <- function(max_tokens = 10000,
                                   sequence_length = 200,
                                   embedding_dim = 128,
                                   lstm_units = 64,
                                   num_classes = 2) {
  input <- keras_input(shape = 1, dtype = "string")

  output <- input |>
    layer_text_vectorization(
      max_tokens = max_tokens,
      output_sequence_length = sequence_length
    ) |>
    layer_embedding(
      input_dim = max_tokens,
      output_dim = embedding_dim,
      mask_zero = TRUE
    ) |>
    # Bidirectional LSTM for better context
    layer_bidirectional(
      layer_lstm(units = lstm_units, return_sequences = FALSE, dropout = 0.2)
    ) |>
    layer_dense(units = 64, activation = "relu") |>
    layer_dropout(rate = 0.5) |>
    layer_dense(
      units = if (num_classes == 2) 1 else num_classes,
      activation = if (num_classes == 2) "sigmoid" else "softmax"
    )

  model <- keras_model(inputs = input, outputs = output)
  return(model)
}

# GRU alternative (faster than LSTM)
build_gru_classifier <- function(max_tokens = 10000,
                                  sequence_length = 200,
                                  embedding_dim = 128,
                                  gru_units = 64,
                                  num_classes = 2) {
  input <- keras_input(shape = 1, dtype = "string")

  output <- input |>
    layer_text_vectorization(
      max_tokens = max_tokens,
      output_sequence_length = sequence_length
    ) |>
    layer_embedding(
      input_dim = max_tokens,
      output_dim = embedding_dim,
      mask_zero = TRUE
    ) |>
    layer_bidirectional(
      layer_gru(units = gru_units, return_sequences = FALSE, dropout = 0.2)
    ) |>
    layer_dense(units = 64, activation = "relu") |>
    layer_dropout(rate = 0.5) |>
    layer_dense(
      units = if (num_classes == 2) 1 else num_classes,
      activation = if (num_classes == 2) "sigmoid" else "softmax"
    )

  model <- keras_model(inputs = input, outputs = output)
  return(model)
}

# Stacked LSTM for complex patterns
build_stacked_lstm <- function(max_tokens = 10000,
                                sequence_length = 200,
                                embedding_dim = 128,
                                num_classes = 2) {
  input <- keras_input(shape = 1, dtype = "string")

  output <- input |>
    layer_text_vectorization(
      max_tokens = max_tokens,
      output_sequence_length = sequence_length
    ) |>
    layer_embedding(
      input_dim = max_tokens,
      output_dim = embedding_dim,
      mask_zero = TRUE
    ) |>
    # First LSTM returns sequences
    layer_lstm(units = 128, return_sequences = TRUE, dropout = 0.2) |>
    # Second LSTM returns final state
    layer_lstm(units = 64, return_sequences = FALSE, dropout = 0.2) |>
    layer_dense(units = 64, activation = "relu") |>
    layer_dropout(rate = 0.5) |>
    layer_dense(
      units = if (num_classes == 2) 1 else num_classes,
      activation = if (num_classes == 2) "sigmoid" else "softmax"
    )

  model <- keras_model(inputs = input, outputs = output)
  return(model)
}
```

## Attention Mechanisms

Multi-head attention for capturing long-range dependencies.

```r
# Transformer-style text classifier with attention
build_attention_classifier <- function(max_tokens = 10000,
                                        sequence_length = 200,
                                        embedding_dim = 128,
                                        num_heads = 4,
                                        num_classes = 2) {
  input <- keras_input(shape = 1, dtype = "string")

  # Vectorize and embed
  embedded <- input |>
    layer_text_vectorization(
      max_tokens = max_tokens,
      output_sequence_length = sequence_length
    ) |>
    layer_embedding(
      input_dim = max_tokens,
      output_dim = embedding_dim
    )

  # Multi-head attention
  attention_output <- embedded |>
    layer_multi_head_attention(
      num_heads = num_heads,
      key_dim = embedding_dim %/% num_heads,
      dropout = 0.1
    )(embedded, embedded)

  # Add & norm
  normalized <- layer_add(list(embedded, attention_output)) |>
    layer_layer_normalization()

  # Feed-forward
  ff_output <- normalized |>
    layer_dense(units = embedding_dim * 2, activation = "relu") |>
    layer_dropout(rate = 0.1) |>
    layer_dense(units = embedding_dim)

  # Add & norm
  normalized2 <- layer_add(list(normalized, ff_output)) |>
    layer_layer_normalization()

  # Classification
  output <- normalized2 |>
    layer_global_average_pooling_1d() |>
    layer_dropout(rate = 0.5) |>
    layer_dense(
      units = if (num_classes == 2) 1 else num_classes,
      activation = if (num_classes == 2) "sigmoid" else "softmax"
    )

  model <- keras_model(inputs = input, outputs = output)
  return(model)
}
```

## Pre-trained Embeddings

Load and use external word embeddings (e.g., GloVe, Word2Vec).

```r
# Load pre-trained embeddings
load_glove_embeddings <- function(file_path, embedding_dim = 100) {
  # Read GloVe file
  lines <- readLines(file_path)

  # Parse embeddings
  embeddings <- list()
  for (line in lines) {
    parts <- strsplit(line, " ")[[1]]
    word <- parts[1]
    vector <- as.numeric(parts[-1])
    embeddings[[word]] <- vector
  }

  return(embeddings)
}

# Create embedding matrix from pre-trained
create_embedding_matrix <- function(word_index, embeddings, embedding_dim) {
  vocab_size <- length(word_index)
  embedding_matrix <- matrix(0, nrow = vocab_size + 1, ncol = embedding_dim)

  for (word in names(word_index)) {
    idx <- word_index[[word]]
    if (!is.null(embeddings[[word]])) {
      embedding_matrix[idx + 1, ] <- embeddings[[word]]
    }
  }

  return(embedding_matrix)
}

# Example usage
# glove_embeddings <- load_glove_embeddings("glove.6B.100d.txt", embedding_dim = 100)

# Create model with pre-trained embeddings
build_model_with_pretrained <- function(word_index,
                                         embedding_matrix,
                                         sequence_length = 200,
                                         num_classes = 2) {
  vocab_size <- nrow(embedding_matrix) - 1
  embedding_dim <- ncol(embedding_matrix)

  input <- keras_input(shape = sequence_length, dtype = "int32")

  # Initialize embedding layer with pre-trained weights
  embedded <- input |>
    layer_embedding(
      input_dim = vocab_size + 1,
      output_dim = embedding_dim,
      weights = list(embedding_matrix),
      trainable = FALSE,  # Freeze embeddings
      mask_zero = TRUE
    )

  output <- embedded |>
    layer_global_average_pooling_1d() |>
    layer_dense(units = 64, activation = "relu") |>
    layer_dropout(rate = 0.5) |>
    layer_dense(
      units = if (num_classes == 2) 1 else num_classes,
      activation = if (num_classes == 2) "sigmoid" else "softmax"
    )

  model <- keras_model(inputs = input, outputs = output)
  return(model)
}
```

## String Lookup Layer

Map categorical text to integers (for labels or categories).

```r
# String lookup for categorical data
categories <- c("sports", "politics", "technology", "entertainment", "sports", "politics")

# Create lookup layer
string_lookup <- layer_string_lookup(
  max_tokens = NULL,  # No limit on vocabulary
  num_oov_indices = 1  # One index for out-of-vocabulary
)

# Adapt to data
string_lookup |> adapt(categories)

# Transform categories to integers
category_ids <- string_lookup(as_tensor(categories, dtype = "string"))
print(category_ids)

# Get vocabulary
vocab <- string_lookup$get_vocabulary()
print(vocab)

# Use in model for multi-input
text_input <- keras_input(shape = 1, dtype = "string", name = "text")
category_input <- keras_input(shape = 1, dtype = "string", name = "category")

# Process text
text_features <- text_input |>
  layer_text_vectorization(max_tokens = 10000, output_sequence_length = 100) |>
  layer_embedding(input_dim = 10000, output_dim = 64) |>
  layer_global_average_pooling_1d()

# Process category
category_features <- category_input |>
  layer_string_lookup(max_tokens = 100) |>
  layer_embedding(input_dim = 100, output_dim = 16) |>
  layer_flatten()

# Combine
merged <- layer_concatenate(list(text_features, category_features))

output <- merged |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dense(units = 1, activation = "sigmoid")

model <- keras_model(
  inputs = list(text_input, category_input),
  outputs = output
)
```

## Complete NLP Training Example

End-to-end workflow with real data.

```r
library(keras3)

# Sample dataset (in practice, load from file)
texts <- c(
  "Great product, highly recommend!",
  "Terrible quality, very disappointed.",
  "Amazing! Exceeded my expectations.",
  "Not worth the money, poor quality.",
  "Absolutely love it, fantastic!",
  "Waste of money, broken on arrival."
)
labels <- c(1, 0, 1, 0, 1, 0)

# Split into train/test
set.seed(42)
train_idx <- sample(length(texts), size = floor(0.7 * length(texts)))
test_idx <- setdiff(seq_along(texts), train_idx)

train_texts <- texts[train_idx]
train_labels <- labels[train_idx]
test_texts <- texts[test_idx]
test_labels <- labels[test_idx]

# Build model
model <- build_text_classifier(
  max_tokens = 1000,
  sequence_length = 50,
  embedding_dim = 64,
  num_classes = 2
)

# Adapt text vectorization layer
text_layer <- model$layers[[2]]
text_layer |> adapt(train_texts)

# Compile
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

# Train
history <- model |> fit(
  x = array(train_texts, dim = c(length(train_texts), 1)),
  y = train_labels,
  validation_data = list(
    array(test_texts, dim = c(length(test_texts), 1)),
    test_labels
  ),
  epochs = 20,
  batch_size = 2,
  verbose = 1
)

# Evaluate
test_results <- model |> evaluate(
  array(test_texts, dim = c(length(test_texts), 1)),
  test_labels
)

cat(sprintf("Test accuracy: %.2f%%\n", test_results["accuracy"] * 100))

# Predict new text
new_texts <- c("This is excellent!", "Very bad experience.")
predictions <- model |> predict(array(new_texts, dim = c(length(new_texts), 1)))
cat("\nPredictions:\n")
for (i in seq_along(new_texts)) {
  sentiment <- if (predictions[i, 1] > 0.5) "Positive" else "Negative"
  cat(sprintf("'%s' -> %s (%.2f%%)\n",
              new_texts[i], sentiment, predictions[i, 1] * 100))
}
```

## Best Practices

1. **Adapt Layers**: Always adapt text_vectorization and string_lookup layers to training data
2. **Mask Zero**: Use `mask_zero = TRUE` in embeddings for variable-length sequences
3. **Sequence Length**: Choose based on typical text length in dataset
4. **Vocabulary Size**: Balance between coverage and memory (10k-50k typical)
5. **Embedding Dim**: Start with 128-256 for most tasks
6. **Dropout**: Add dropout (0.3-0.5) to prevent overfitting
7. **Bidirectional RNN**: Use for better context understanding
8. **Pre-trained Embeddings**: Consider for small datasets

## Related Resources

- See main SKILL.md for Keras3 basics
- Reference functional-api-advanced.md for multi-input text models
- Check custom-layers-models.md for building custom text layers
- See r-text-mining skill for traditional text analysis in R
