# NLP Example

Text classification using LSTM/GRU networks in torch.

## Overview

**Use Case**: Classify text documents (sentiment analysis, topic classification)

**Key Components**:
- Text preprocessing and tokenization
- Word embeddings (learned or pretrained)
- LSTM/GRU architecture
- Sequence padding and packing
- Attention mechanism (optional)

---

## 1. Setup and Data

```r
library(torch)
library(luz)
library(dplyr)
library(stringr)

# Example: Sentiment classification
text_data <- data.frame(
  text = c(
    "I love this product, it's amazing!",
    "Terrible quality, very disappointed",
    "Good value for money",
    ...
  ),
  sentiment = c("positive", "negative", "positive", ...)
)

# Encode labels
text_data <- text_data |>
  mutate(label_id = as.integer(factor(sentiment)) - 1L)

# Split data
set.seed(42)
train_idx <- sample(nrow(text_data), nrow(text_data) * 0.8)
val_idx <- setdiff(seq_len(nrow(text_data)), train_idx)[1:(nrow(text_data) * 0.1)]
test_idx <- setdiff(seq_len(nrow(text_data)), c(train_idx, val_idx))

train_df <- text_data[train_idx, ]
val_df <- text_data[val_idx, ]
test_df <- text_data[test_idx, ]

n_classes <- length(unique(text_data$sentiment))
```

---

## 2. Text Preprocessing and Vocabulary

```r
# Build vocabulary from training data
build_vocabulary <- function(texts, min_freq = 2, max_vocab = 10000) {
  # Tokenize
  tokens <- texts |>
    str_to_lower() |>
    str_replace_all("[^a-z0-9\\s]", "") |>
    str_split("\\s+")

  # Count word frequencies
  word_freq <- table(unlist(tokens))
  word_freq <- sort(word_freq, decreasing = TRUE)

  # Filter by frequency
  word_freq <- word_freq[word_freq >= min_freq]

  # Limit vocabulary size
  if (length(word_freq) > max_vocab) {
    word_freq <- word_freq[1:max_vocab]
  }

  # Create word-to-index mapping
  # Reserve special tokens: 0=<PAD>, 1=<UNK>
  vocab <- list(
    word2idx = c(
      "<PAD>" = 0,
      "<UNK>" = 1,
      setNames(seq(2, length(word_freq) + 1), names(word_freq))
    ),
    idx2word = c("<PAD>", "<UNK>", names(word_freq))
  )

  return(vocab)
}

# Text encoding function
encode_text <- function(text, vocab, max_length = 100) {
  tokens <- text |>
    str_to_lower() |>
    str_replace_all("[^a-z0-9\\s]", "") |>
    str_split("\\s+") |>
    .[[1]]

  # Convert to indices
  indices <- sapply(tokens, function(token) {
    idx <- vocab$word2idx[[token]]
    if (is.null(idx)) {
      return(vocab$word2idx[["<UNK>"]])
    }
    return(idx)
  })

  # Pad or truncate
  if (length(indices) < max_length) {
    indices <- c(indices, rep(0, max_length - length(indices)))
  } else if (length(indices) > max_length) {
    indices <- indices[1:max_length]
  }

  return(indices)
}

# Build vocabulary
vocab <- build_vocabulary(train_df$text, min_freq = 2, max_vocab = 10000)
vocab_size <- length(vocab$word2idx)

cat("Vocabulary size:", vocab_size, "\n")
```

---

## 3. Text Dataset

```r
text_dataset <- dataset(
  name = "TextDataset",

  initialize = function(dataframe, vocab, max_length = 100) {
    self$data <- dataframe
    self$vocab <- vocab
    self$max_length <- max_length
  },

  .getitem = function(index) {
    row <- self$data[index, ]

    # Encode text to indices
    encoded <- encode_text(row$text, self$vocab, self$max_length)

    # Convert to tensor
    text_tensor <- torch_tensor(encoded, dtype = torch_long())

    # Label
    label <- torch_tensor(row$label_id, dtype = torch_long())

    return(list(x = text_tensor, y = label))
  },

  .length = function() {
    nrow(self$data)
  }
)

# Create datasets
train_ds <- text_dataset(train_df, vocab, max_length = 100)
val_ds <- text_dataset(val_df, vocab, max_length = 100)
test_ds <- text_dataset(test_df, vocab, max_length = 100)

# Create dataloaders
train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE)
val_dl <- dataloader(val_ds, batch_size = 32, shuffle = FALSE)
test_dl <- dataloader(test_ds, batch_size = 32, shuffle = FALSE)

# Verify
batch <- train_dl$.iter()$.next()
cat("Text shape:", batch$x$shape, "\n")   # [32, 100]
cat("Label shape:", batch$y$shape, "\n")  # [32]
```

---

## 4. LSTM Classifier

```r
# LSTM text classifier
lstm_classifier <- nn_module(
  "LSTMClassifier",

  initialize = function(vocab_size, embedding_dim = 128,
                       hidden_dim = 256, n_layers = 2,
                       n_classes, dropout = 0.5,
                       bidirectional = TRUE) {

    # Embedding layer
    self$embedding <- nn_embedding(
      num_embeddings = vocab_size,
      embedding_dim = embedding_dim,
      padding_idx = 0  # <PAD> token
    )

    # LSTM
    self$lstm <- nn_lstm(
      input_size = embedding_dim,
      hidden_size = hidden_dim,
      num_layers = n_layers,
      batch_first = TRUE,
      dropout = dropout,
      bidirectional = bidirectional
    )

    # Direction multiplier
    self$dir_mult <- if (bidirectional) 2 else 1

    # Classifier
    self$dropout <- nn_dropout(dropout)
    self$fc <- nn_linear(hidden_dim * self$dir_mult, n_classes)
  },

  forward = function(x) {
    # x: (batch, seq_len)

    # Embed: (batch, seq_len, embedding_dim)
    embedded <- self$embedding(x)

    # LSTM: output (batch, seq_len, hidden_dim * num_directions)
    lstm_out <- self$lstm(embedded)[[1]]

    # Take last hidden state
    # For bidirectional, concatenate forward and backward last states
    last_hidden <- lstm_out[, -1, ]  # (batch, hidden_dim * num_directions)

    # Classify
    out <- self$dropout(last_hidden)
    out <- self$fc(out)  # (batch, n_classes)

    return(out)
  }
)

# Create model
model <- lstm_classifier(
  vocab_size = vocab_size,
  embedding_dim = 128,
  hidden_dim = 256,
  n_layers = 2,
  n_classes = n_classes,
  dropout = 0.5,
  bidirectional = TRUE
)

# Test
dummy_input <- torch_randint(0, vocab_size, c(4, 100), dtype = torch_long())
output <- model(dummy_input)
cat("Output shape:", output$shape, "\n")  # [4, n_classes]
```

---

## 5. Alternative: GRU with Attention

```r
# GRU with attention mechanism
gru_attention_classifier <- nn_module(
  "GRUAttentionClassifier",

  initialize = function(vocab_size, embedding_dim = 128,
                       hidden_dim = 256, n_layers = 2,
                       n_classes, dropout = 0.5) {

    self$embedding <- nn_embedding(
      num_embeddings = vocab_size,
      embedding_dim = embedding_dim,
      padding_idx = 0
    )

    self$gru <- nn_gru(
      input_size = embedding_dim,
      hidden_size = hidden_dim,
      num_layers = n_layers,
      batch_first = TRUE,
      dropout = dropout,
      bidirectional = TRUE
    )

    # Attention
    self$attention_fc <- nn_linear(hidden_dim * 2, 1)

    # Classifier
    self$dropout <- nn_dropout(dropout)
    self$fc <- nn_linear(hidden_dim * 2, n_classes)
  },

  forward = function(x) {
    # Embed
    embedded <- self$embedding(x)  # (batch, seq_len, emb_dim)

    # GRU
    gru_out <- self$gru(embedded)[[1]]  # (batch, seq_len, hidden*2)

    # Attention weights
    attn_weights <- self$attention_fc(gru_out)  # (batch, seq_len, 1)
    attn_weights <- torch_softmax(attn_weights, dim = 2)

    # Weighted sum
    attended <- (gru_out * attn_weights)$sum(dim = 2)  # (batch, hidden*2)

    # Classify
    out <- self$dropout(attended)
    out <- self$fc(out)

    return(out)
  }
)
```

---

## 6. Training

```r
# Train model
fitted <- model |>
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_accuracy(),
      luz_metric_precision(),
      luz_metric_recall()
    )
  ) |>

  set_hparams(
    vocab_size = vocab_size,
    embedding_dim = 128,
    hidden_dim = 256,
    n_layers = 2,
    n_classes = n_classes,
    dropout = 0.5,
    bidirectional = TRUE
  ) |>

  set_opt_hparams(
    lr = 0.001,
    weight_decay = 1e-5
  ) |>

  fit(
    train_dl,
    epochs = 20,
    valid_data = val_dl,

    callbacks = list(
      luz_callback_early_stopping(
        monitor = "valid_loss",
        patience = 5
      ),

      luz_callback_lr_scheduler(
        lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 3
      ),

      luz_callback_model_checkpoint(
        path = "models/",
        monitor = "valid_loss",
        save_best_only = TRUE
      ),

      luz_callback_csv_logger("training_log.csv")
    ),

    verbose = TRUE
  )

# Save
luz_save(fitted, "text_classifier.pt")
```

---

## 7. Using Pretrained Embeddings (GloVe)

```r
# Load pretrained GloVe embeddings
load_glove <- function(glove_path, vocab, embedding_dim = 100) {
  # Read GloVe file
  glove_lines <- readLines(glove_path)

  # Parse embeddings
  glove_dict <- list()
  for (line in glove_lines) {
    parts <- str_split(line, " ")[[1]]
    word <- parts[1]
    embedding <- as.numeric(parts[-1])
    glove_dict[[word]] <- embedding
  }

  # Create embedding matrix
  vocab_size <- length(vocab$word2idx)
  embedding_matrix <- matrix(0, nrow = vocab_size, ncol = embedding_dim)

  # Fill with pretrained embeddings
  for (word in names(vocab$word2idx)) {
    idx <- vocab$word2idx[[word]]
    if (!is.null(glove_dict[[word]])) {
      embedding_matrix[idx, ] <- glove_dict[[word]]
    } else {
      # Random initialization for OOV words
      embedding_matrix[idx, ] <- rnorm(embedding_dim, sd = 0.01)
    }
  }

  return(torch_tensor(embedding_matrix))
}

# Load and set pretrained embeddings
pretrained_embeddings <- load_glove(
  "glove.6B.100d.txt",
  vocab,
  embedding_dim = 100
)

# Set embeddings in model
model$embedding$weight <- nn_parameter(pretrained_embeddings)

# Optionally freeze embeddings
model$embedding$weight$requires_grad_(FALSE)
```

---

## 8. Evaluation and Inference

```r
# Evaluate
evaluate_text_model <- function(model, test_dl) {
  model$eval()

  all_preds <- list()
  all_labels <- list()

  with_no_grad({
    coro::loop(for (batch in test_dl) {
      logits <- model(batch$x)
      preds <- torch_argmax(logits, dim = 2)

      all_preds[[length(all_preds) + 1]] <- as.integer(preds$cpu())
      all_labels[[length(all_labels) + 1]] <- as.integer(batch$y$cpu())
    })
  })

  predictions <- unlist(all_preds)
  labels <- unlist(all_labels)

  results <- tibble(
    truth = factor(labels),
    estimate = factor(predictions)
  )

  overall <- results |> metrics(truth, estimate)
  conf_mat <- results |> conf_mat(truth, estimate)

  return(list(overall = overall, confusion_matrix = conf_mat))
}

eval_results <- evaluate_text_model(fitted$model, test_dl)
print(eval_results$overall)

# Predict new text
predict_text <- function(model, text, vocab, class_names, max_length = 100) {
  model$eval()

  # Encode
  encoded <- encode_text(text, vocab, max_length)
  text_tensor <- torch_tensor(encoded, dtype = torch_long())$unsqueeze(1)

  # Predict
  with_no_grad({
    logits <- model(text_tensor)
    probs <- nnf_softmax(logits, dim = 2)
  })

  probs_vec <- as.numeric(probs$cpu())
  names(probs_vec) <- class_names

  predicted_class <- class_names[which.max(probs_vec)]
  confidence <- max(probs_vec)

  return(list(
    predicted_class = predicted_class,
    confidence = confidence,
    all_probabilities = probs_vec
  ))
}

# Usage
class_names <- sort(unique(text_data$sentiment))
result <- predict_text(
  model = fitted$model,
  text = "This is an excellent product!",
  vocab = vocab,
  class_names = class_names
)

cat("Predicted:", result$predicted_class, "\n")
cat("Confidence:", sprintf("%.2f%%", result$confidence * 100), "\n")
```

---

## Best Practices

### Preprocessing
- Remove punctuation, lowercase, handle special characters
- Build vocabulary on training set only
- Set min_freq (2-5) to filter rare words
- Limit vocab size (10k-50k) to manage memory

### Model Architecture
- Embedding dim: 128-300 for learned, match pretrained if using GloVe/Word2Vec
- Hidden dim: 128-512 depending on dataset size
- Use bidirectional LSTM/GRU for better context
- Dropout 0.3-0.5 to prevent overfitting

### Training
- Batch size 32-128 for text
- Learning rate 0.001-0.003
- Use gradient clipping (clip_grad_norm) for RNNs
- Try attention mechanism for longer texts

### Advanced
- Use pretrained embeddings (GloVe, FastText) for small datasets
- Consider transformer models (need external implementation)
- Pack padded sequences for variable-length efficiency

---

## References

See also:
- [references/architectures.md](../references/architectures.md) - RNN/LSTM/GRU patterns
- [templates/training-recipes.R](../templates/training-recipes.R) - Training patterns
