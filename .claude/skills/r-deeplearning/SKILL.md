---
name: r-deeplearning
description: Deep learning in R using torch and keras3 for neural networks across domains. Use when mentions "deep learning em R", "deep learning in R", "torch", "torch em R", "torch for R", "keras3", "keras3 em R", "neural network", "rede neural", "redes neurais", "CNN", "convolutional neural network", "rede convolucional", "RNN", "LSTM", "GRU", "recurrent neural network", "transformer", "GPU em R", "GPU in R", "train neural network", "treinar rede neural", "image classification", "classificação de imagens", "text classification", "classificação de texto", "sound classification", "audio classification", "classificação de sons", "audio deep learning", "deep learning com áudio", "spectrogram CNN", "CRNN", "mel-spectrogram", "torchaudio", "luz package", "build neural network", "construir rede neural", "transfer learning", "fine-tuning", "pretrained model", "modelo pré-treinado", or building/training neural network models in R for vision, NLP, audio, time series, or tabular data.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Deep Learning in R - torch & keras3

Expert guidance for deep learning in R using torch and keras3 frameworks across multiple domains: computer vision, NLP, audio processing, time series, and tabular data.

## Overview

This skill provides comprehensive knowledge for building, training, and deploying neural networks in R using:

- **torch**: Low-level, flexible deep learning framework (PyTorch port to R)
- **keras3**: High-level API with multiple backends (TensorFlow, JAX, torch)
- **torchaudio**: Audio-specific transformations and datasets
- **luz**: High-level training interface for torch

Covers complete workflows from data preparation through training, evaluation, and deployment with special emphasis on audio deep learning for bioacoustics.

## Core Concepts

### torch vs keras3

| Aspect | torch | keras3 |
|--------|-------|--------|
| **Level** | Low-level, explicit control | High-level, concise API |
| **Flexibility** | Maximum (custom everything) | Moderate (configurable) |
| **Learning curve** | Steeper | Gentler |
| **Training** | Manual loops or luz | Built-in `fit()` |
| **Backend** | Pure torch | TensorFlow/JAX/torch |
| **Best for** | Research, custom architectures | Production, standard models |

**When to use torch**:
- Custom loss functions or training procedures
- Research and experimentation
- Need full control over training loop
- Implementing novel architectures

**When to use keras3**:
- Standard architectures (ResNet, LSTM, etc.)
- Rapid prototyping
- Prefer high-level API
- Deploying to TensorFlow Serving

## Framework Fundamentals

### torch Basics

```r
library(torch)

# Tensors - fundamental data structure
x <- torch_tensor(c(1, 2, 3, 4, 5, 6))
x <- x$view(c(2, 3))  # Reshape to 2x3

# Device management (CPU/GPU)
device <- if (cuda_is_available()) "cuda" else "cpu"
x <- x$to(device = device)

# Autograd - automatic differentiation
x <- torch_tensor(c(1.0, 2.0, 3.0), requires_grad = TRUE)
y <- x$pow(2)$sum()
y$backward()  # Compute gradients
print(x$grad)  # Access gradients

# Neural network modules
model <- nn_module(
  "SimpleNet",
  initialize = function(input_dim, hidden_dim, output_dim) {
    self$fc1 <- nn_linear(input_dim, hidden_dim)
    self$fc2 <- nn_linear(hidden_dim, output_dim)
    self$relu <- nn_relu()
  },
  forward = function(x) {
    x |>
      self$fc1() |>
      self$relu() |>
      self$fc2()
  }
)

net <- model(input_dim = 784, hidden_dim = 128, output_dim = 10)
net <- net$to(device = device)

# Optimizer
optimizer <- optim_adam(net$parameters, lr = 0.001)

# Loss function
criterion <- nn_cross_entropy_loss()

# Training loop (manual)
net$train()  # Training mode
optimizer$zero_grad()  # Reset gradients
output <- net(input)
loss <- criterion(output, target)
loss$backward()  # Backpropagation
optimizer$step()  # Update weights

# Inference
net$eval()  # Evaluation mode
with_no_grad({  # Disable gradient computation
  predictions <- net(test_input)
})
```

### keras3 Basics

```r
library(keras3)

# Sequential API - simple stacking
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(units = 128, activation = "relu") |>
  layer_dropout(rate = 0.2) |>
  layer_dense(units = 10, activation = "softmax")

# Functional API - complex topologies
inputs <- layer_input(shape = c(784))
outputs <- inputs |>
  layer_dense(units = 128, activation = "relu") |>
  layer_dropout(rate = 0.2) |>
  layer_dense(units = 10, activation = "softmax")

model <- keras_model(inputs, outputs)

# Compile - configure learning process
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_categorical_crossentropy(),
  metrics = list(metric_categorical_accuracy())
)

# Training - high-level fit()
history <- model |> fit(
  x_train, y_train,
  epochs = 20,
  batch_size = 32,
  validation_split = 0.2,
  callbacks = list(
    callback_early_stopping(patience = 3, restore_best_weights = TRUE),
    callback_reduce_lr_on_plateau(factor = 0.5, patience = 2)
  )
)

# Evaluation
model |> evaluate(x_test, y_test)

# Inference
predictions <- model |> predict(x_new)
```

### luz (torch High-Level Training)

```r
library(luz)

# luz provides keras-like API for torch models
fitted <- net |>
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_accuracy()
    )
  ) |>
  set_hparams(input_dim = 784, hidden_dim = 128, output_dim = 10) |>
  set_opt_hparams(lr = 0.001) |>
  fit(
    train_dataloader,
    epochs = 20,
    valid_data = valid_dataloader,
    callbacks = list(
      luz_callback_early_stopping(patience = 3),
      luz_callback_lr_scheduler(torch::lr_step, step_size = 5, gamma = 0.5)
    )
  )
```

## Domain-Specific Patterns

### Computer Vision (CNNs)

```r
library(torch)

# CNN for image classification (torch)
cnn_model <- nn_module(
  "CNN",
  initialize = function(num_classes = 10) {
    # Convolutional layers
    self$conv1 <- nn_conv2d(in_channels = 3, out_channels = 32, kernel_size = 3, padding = 1)
    self$conv2 <- nn_conv2d(32, 64, 3, padding = 1)
    self$conv3 <- nn_conv2d(64, 128, 3, padding = 1)

    # Pooling and regularization
    self$pool <- nn_max_pool2d(kernel_size = 2, stride = 2)
    self$dropout <- nn_dropout(0.3)

    # Fully connected layers
    self$fc1 <- nn_linear(128 * 4 * 4, 512)  # Assuming 32x32 input
    self$fc2 <- nn_linear(512, num_classes)

    # Activation
    self$relu <- nn_relu()
  },
  forward = function(x) {
    # Conv block 1
    x <- self$conv1(x) |> self$relu() |> self$pool()

    # Conv block 2
    x <- self$conv2(x) |> self$relu() |> self$pool()

    # Conv block 3
    x <- self$conv3(x) |> self$relu() |> self$pool()

    # Flatten
    x <- x$view(c(x$size(1), -1))

    # Fully connected
    x <- self$fc1(x) |> self$relu() |> self$dropout()
    x <- self$fc2(x)

    return(x)
  }
)

# Data augmentation
augmentation_transform <- function(x) {
  x |>
    transform_random_horizontal_flip(p = 0.5) |>
    transform_random_rotation(degrees = 15) |>
    transform_color_jitter(brightness = 0.2, contrast = 0.2)
}

# Transfer learning with pretrained models (keras3)
library(keras3)

base_model <- application_resnet50(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(224, 224, 3)
)

# Freeze base
base_model$trainable <- FALSE

# Add custom head
inputs <- layer_input(shape = c(224, 224, 3))
outputs <- inputs |>
  base_model() |>
  layer_global_average_pooling_2d() |>
  layer_dense(256, activation = "relu") |>
  layer_dropout(0.3) |>
  layer_dense(num_classes, activation = "softmax")

model <- keras_model(inputs, outputs)

# Two-phase training
# Phase 1: Train head with frozen base
model |> compile(
  optimizer = optimizer_adam(1e-3),
  loss = loss_categorical_crossentropy(),
  metrics = "accuracy"
)
model |> fit(train_data, epochs = 10)

# Phase 2: Fine-tune entire network
base_model$trainable <- TRUE
model |> compile(
  optimizer = optimizer_adam(1e-5),  # Lower learning rate
  loss = loss_categorical_crossentropy(),
  metrics = "accuracy"
)
model |> fit(train_data, epochs = 10)
```

### Natural Language Processing (RNNs/LSTMs)

```r
library(torch)

# LSTM for text classification
lstm_model <- nn_module(
  "TextLSTM",
  initialize = function(vocab_size, embedding_dim = 128, hidden_dim = 256, num_classes = 2) {
    self$embedding <- nn_embedding(vocab_size, embedding_dim)
    self$lstm <- nn_lstm(embedding_dim, hidden_dim, num_layers = 2,
                          dropout = 0.3, batch_first = TRUE)
    self$fc <- nn_linear(hidden_dim, num_classes)
    self$dropout <- nn_dropout(0.3)
  },
  forward = function(x) {
    # x: (batch, sequence_length)
    embedded <- self$embedding(x)  # (batch, seq, embedding_dim)

    # LSTM
    lstm_out <- self$lstm(embedded)  # Returns list(output, (h_n, c_n))
    last_hidden <- lstm_out[[2]][[1]][2, , ]  # Last layer's hidden state

    # Classification head
    out <- last_hidden |> self$dropout() |> self$fc()

    return(out)
  }
)

# Bidirectional LSTM (keras3)
library(keras3)

model <- keras_model_sequential() |>
  layer_embedding(input_dim = vocab_size, output_dim = 128, input_length = max_len) |>
  layer_lstm(units = 64, return_sequences = TRUE) |>
  bidirectional(layer_lstm(units = 64)) |>
  layer_dense(64, activation = "relu") |>
  layer_dropout(0.3) |>
  layer_dense(num_classes, activation = "softmax")

# Text preprocessing with keras
tokenizer <- text_tokenizer(num_words = 10000)
tokenizer |> fit_text_tokenizer(texts)
sequences <- texts_to_sequences(tokenizer, texts)
x_train <- pad_sequences(sequences, maxlen = max_len)
```

### Time Series (RNNs/ConvLSTM)

```r
library(torch)

# GRU for time series forecasting
gru_model <- nn_module(
  "TimeSeriesGRU",
  initialize = function(input_dim, hidden_dim = 64, num_layers = 2, output_steps = 1) {
    self$gru <- nn_gru(input_dim, hidden_dim, num_layers = num_layers,
                        dropout = 0.2, batch_first = TRUE)
    self$fc <- nn_linear(hidden_dim, output_steps)
  },
  forward = function(x) {
    # x: (batch, seq_len, input_dim)
    gru_out <- self$gru(x)
    last_output <- gru_out[[1]][, -1, ]  # Last time step

    predictions <- self$fc(last_output)
    return(predictions)
  }
)

# 1D CNN for time series (often competitive with RNNs)
cnn_ts_model <- nn_module(
  "TimeSeriesCNN",
  initialize = function(input_dim, num_filters = c(32, 64, 128), output_steps = 1) {
    self$conv1 <- nn_conv1d(input_dim, num_filters[1], kernel_size = 3, padding = 1)
    self$conv2 <- nn_conv1d(num_filters[1], num_filters[2], 3, padding = 1)
    self$conv3 <- nn_conv1d(num_filters[2], num_filters[3], 3, padding = 1)
    self$pool <- nn_adaptive_avg_pool1d(1)
    self$fc <- nn_linear(num_filters[3], output_steps)
    self$relu <- nn_relu()
  },
  forward = function(x) {
    # x: (batch, input_dim, seq_len)
    x <- self$conv1(x) |> self$relu()
    x <- self$conv2(x) |> self$relu()
    x <- self$conv3(x) |> self$relu()
    x <- self$pool(x)$squeeze(-1)  # Global pooling
    x <- self$fc(x)
    return(x)
  }
)
```

### Tabular Data (Dense Networks)

```r
library(torch)

# Deep network for tabular data with entity embeddings
tabular_model <- nn_module(
  "TabularNN",
  initialize = function(num_numeric, cat_dims, embedding_dims, hidden_dims = c(256, 128, 64)) {
    # Categorical embeddings
    self$embeddings <- nn_module_list(lapply(1:length(cat_dims), function(i) {
      nn_embedding(cat_dims[i], embedding_dims[i])
    }))

    # Calculate total input dimension
    total_dim <- num_numeric + sum(embedding_dims)

    # Dense layers
    self$fc1 <- nn_linear(total_dim, hidden_dims[1])
    self$fc2 <- nn_linear(hidden_dims[1], hidden_dims[2])
    self$fc3 <- nn_linear(hidden_dims[2], hidden_dims[3])
    self$output <- nn_linear(hidden_dims[3], 1)

    # Regularization
    self$batch_norm1 <- nn_batch_norm1d(hidden_dims[1])
    self$batch_norm2 <- nn_batch_norm1d(hidden_dims[2])
    self$dropout <- nn_dropout(0.3)
    self$relu <- nn_relu()
  },
  forward = function(x_numeric, x_categorical) {
    # Embed categorical features
    embedded <- lapply(1:length(x_categorical), function(i) {
      self$embeddings[[i]](x_categorical[[i]])
    })
    embedded_cat <- torch_cat(embedded, dim = 2)

    # Concatenate numeric and categorical
    x <- torch_cat(list(x_numeric, embedded_cat), dim = 2)

    # Dense network
    x <- self$fc1(x) |> self$batch_norm1() |> self$relu() |> self$dropout()
    x <- self$fc2(x) |> self$batch_norm2() |> self$relu() |> self$dropout()
    x <- self$fc3(x) |> self$relu()
    x <- self$output(x)

    return(x)
  }
)
```

## Audio Deep Learning (Detailed)

### Audio Preprocessing Pipeline

```r
library(torch)
library(torchaudio)
library(tuneR)

# Standard audio preprocessing for classification
preprocess_audio <- function(audio_path, target_sr = 22050, duration = 5.0) {
  # Load audio
  audio <- readWave(audio_path)

  # Convert to mono
  if (audio@stereo) {
    audio <- mono(audio, which = "both")
  }

  # Resample
  if (audio@samp.rate != target_sr) {
    audio <- downsample(audio, samp.rate = target_sr)
  }

  # Normalize
  audio <- normalize(audio, unit = "16")

  # Pad or truncate to fixed duration
  target_length <- as.integer(target_sr * duration)
  current_length <- length(audio@left)

  if (current_length < target_length) {
    # Pad with zeros
    padding <- rep(0, target_length - current_length)
    waveform <- c(audio@left, padding)
  } else {
    # Truncate or random crop
    waveform <- audio@left[1:target_length]
  }

  # Convert to torch tensor
  waveform_tensor <- torch_tensor(waveform)$unsqueeze(1)  # Add channel dim

  return(waveform_tensor)
}

# Mel-spectrogram transformation (torchaudio)
mel_spectrogram_transform <- function(sample_rate = 22050,
                                       n_fft = 2048,
                                       hop_length = 512,
                                       n_mels = 128) {
  transform_mel_spectrogram(
    sample_rate = sample_rate,
    n_fft = n_fft,
    hop_length = hop_length,
    n_mels = n_mels,
    normalized = TRUE
  )
}

# Apply log-mel transformation
audio_to_log_mel <- function(waveform, mel_transform) {
  mel_spec <- mel_transform(waveform)  # (channel, n_mels, time)
  log_mel_spec <- torch_log(mel_spec + 1e-9)  # Add small constant for stability

  return(log_mel_spec)
}

# MFCC transformation
mfcc_transform <- function(sample_rate = 22050, n_mfcc = 13) {
  transform_mfcc(
    sample_rate = sample_rate,
    n_mfcc = n_mfcc,
    melkwargs = list(
      n_fft = 2048,
      hop_length = 512,
      n_mels = 128
    )
  )
}
```

### CNN for Audio Classification

```r
# 2D CNN on log-mel spectrograms
audio_cnn <- nn_module(
  "AudioCNN",
  initialize = function(num_classes, n_mels = 128) {
    # Convolutional blocks
    self$conv1 <- nn_conv2d(1, 32, kernel_size = c(3, 3), padding = c(1, 1))
    self$conv2 <- nn_conv2d(32, 64, c(3, 3), padding = c(1, 1))
    self$conv3 <- nn_conv2d(64, 128, c(3, 3), padding = c(1, 1))
    self$conv4 <- nn_conv2d(128, 256, c(3, 3), padding = c(1, 1))

    # Pooling and regularization
    self$pool <- nn_max_pool2d(kernel_size = c(2, 2))
    self$dropout <- nn_dropout(0.3)
    self$batch_norm1 <- nn_batch_norm2d(32)
    self$batch_norm2 <- nn_batch_norm2d(64)
    self$batch_norm3 <- nn_batch_norm2d(128)
    self$batch_norm4 <- nn_batch_norm2d(256)

    # Global pooling instead of fixed FC input size
    self$global_pool <- nn_adaptive_avg_pool2d(c(1, 1))

    # Classification head
    self$fc1 <- nn_linear(256, 256)
    self$fc2 <- nn_linear(256, num_classes)

    # Activation
    self$relu <- nn_relu()
  },
  forward = function(x) {
    # Input: (batch, 1, n_mels, time)

    # Conv block 1
    x <- self$conv1(x) |> self$batch_norm1() |> self$relu() |> self$pool()

    # Conv block 2
    x <- self$conv2(x) |> self$batch_norm2() |> self$relu() |> self$pool()

    # Conv block 3
    x <- self$conv3(x) |> self$batch_norm3() |> self$relu() |> self$pool()

    # Conv block 4
    x <- self$conv4(x) |> self$batch_norm4() |> self$relu()

    # Global pooling
    x <- self$global_pool(x)$squeeze(c(3, 4))  # (batch, 256)

    # Classification head
    x <- self$fc1(x) |> self$relu() |> self$dropout()
    x <- self$fc2(x)

    return(x)
  }
)
```

### CRNN for Audio (CNN + RNN)

```r
# CRNN: Captures both spectral patterns (CNN) and temporal context (RNN)
audio_crnn <- nn_module(
  "AudioCRNN",
  initialize = function(num_classes, n_mels = 128, rnn_hidden = 128) {
    # CNN for feature extraction
    self$conv1 <- nn_conv2d(1, 64, kernel_size = c(3, 3), padding = c(1, 1))
    self$conv2 <- nn_conv2d(64, 128, c(3, 3), padding = c(1, 1))
    self$conv3 <- nn_conv2d(128, 256, c(3, 3), padding = c(1, 1))

    self$pool <- nn_max_pool2d(c(2, 2))
    self$batch_norm1 <- nn_batch_norm2d(64)
    self$batch_norm2 <- nn_batch_norm2d(128)
    self$batch_norm3 <- nn_batch_norm2d(256)

    # RNN for temporal modeling
    # After 3 pooling layers, frequency dim is n_mels / 8
    self$gru <- nn_gru(
      input_size = 256 * (n_mels %/% 8),
      hidden_size = rnn_hidden,
      num_layers = 2,
      dropout = 0.3,
      batch_first = TRUE,
      bidirectional = TRUE
    )

    # Attention mechanism (optional)
    self$attention <- nn_linear(rnn_hidden * 2, 1)

    # Classification head
    self$fc <- nn_linear(rnn_hidden * 2, num_classes)

    self$dropout <- nn_dropout(0.3)
    self$relu <- nn_relu()
  },
  forward = function(x) {
    # Input: (batch, 1, n_mels, time)
    batch_size <- x$size(1)

    # CNN feature extraction
    x <- self$conv1(x) |> self$batch_norm1() |> self$relu() |> self$pool()
    x <- self$conv2(x) |> self$batch_norm2() |> self$relu() |> self$pool()
    x <- self$conv3(x) |> self$batch_norm3() |> self$relu() |> self$pool()
    # Shape: (batch, 256, n_mels/8, time/8)

    # Reshape for RNN: (batch, time, features)
    freq_dim <- x$size(3)
    time_dim <- x$size(4)
    x <- x$permute(c(1, 4, 2, 3))  # (batch, time, channels, freq)
    x <- x$reshape(c(batch_size, time_dim, -1))

    # RNN
    rnn_out <- self$gru(x)[[1]]  # (batch, time, rnn_hidden*2)

    # Attention pooling (weight different time steps)
    attention_weights <- self$attention(rnn_out)  # (batch, time, 1)
    attention_weights <- nnf_softmax(attention_weights, dim = 2)
    weighted <- (rnn_out * attention_weights)$sum(dim = 2)  # (batch, rnn_hidden*2)

    # Classification
    out <- weighted |> self$dropout() |> self$fc()

    return(out)
  }
)
```

### Audio Data Augmentation

```r
# Time-domain augmentation
time_augmentation <- function(waveform, sample_rate) {
  # Random time shift
  shift <- sample(-sample_rate:sample_rate, 1)
  if (shift > 0) {
    waveform <- torch_cat(list(torch_zeros(shift), waveform[1:(length(waveform) - shift)]))
  } else if (shift < 0) {
    shift <- abs(shift)
    waveform <- torch_cat(list(waveform[(shift + 1):length(waveform)], torch_zeros(shift)))
  }

  # Add background noise (if noise samples available)
  if (runif(1) > 0.5) {
    noise_level <- runif(1, 0.001, 0.01)
    noise <- torch_randn_like(waveform) * noise_level
    waveform <- waveform + noise
  }

  return(waveform)
}

# Spectrogram augmentation (SpecAugment)
spec_augment <- function(spec, freq_mask_param = 15, time_mask_param = 35, n_freq_masks = 2, n_time_masks = 2) {
  # Frequency masking
  for (i in 1:n_freq_masks) {
    freq_start <- sample(1:(spec$size(2) - freq_mask_param), 1)
    spec[, freq_start:(freq_start + freq_mask_param - 1), ] <- 0
  }

  # Time masking
  for (i in 1:n_time_masks) {
    time_start <- sample(1:(spec$size(3) - time_mask_param), 1)
    spec[, , time_start:(time_start + time_mask_param - 1)] <- 0
  }

  return(spec)
}

# Mixup augmentation (at batch level)
mixup_batch <- function(x, y, alpha = 0.2) {
  batch_size <- x$size(1)
  lambda <- torch_tensor(rbeta(batch_size, alpha, alpha))$to(device = x$device)

  # Shuffle indices
  indices <- torch_randperm(batch_size)

  # Mix inputs and labels
  x_mixed <- lambda$view(c(-1, 1, 1, 1)) * x + (1 - lambda$view(c(-1, 1, 1, 1))) * x[indices]
  y_mixed <- lambda * y + (1 - lambda) * y[indices]

  list(x = x_mixed, y = y_mixed)
}
```

### Audio Dataset and DataLoader

```r
library(torch)

# Custom dataset for audio classification
audio_dataset <- dataset(
  name = "audio_dataset",

  initialize = function(file_paths, labels, transform = NULL, augment = FALSE) {
    self$file_paths <- file_paths
    self$labels <- labels
    self$transform <- transform
    self$augment <- augment
  },

  .getitem = function(index) {
    # Load audio
    waveform <- preprocess_audio(self$file_paths[index])

    # Time-domain augmentation
    if (self$augment) {
      waveform <- time_augmentation(waveform, sample_rate = 22050)
    }

    # Transform to spectrogram
    if (!is.null(self$transform)) {
      spectrogram <- self$transform(waveform)

      # Spectrogram augmentation
      if (self$augment) {
        spectrogram <- spec_augment(spectrogram)
      }
    } else {
      spectrogram <- waveform
    }

    # Label
    label <- torch_tensor(self$labels[index], dtype = torch_long())

    list(x = spectrogram, y = label)
  },

  .length = function() {
    length(self$file_paths)
  }
)

# Create datasets
mel_transform <- mel_spectrogram_transform()

train_ds <- audio_dataset(
  train_files, train_labels,
  transform = mel_transform,
  augment = TRUE
)

valid_ds <- audio_dataset(
  valid_files, valid_labels,
  transform = mel_transform,
  augment = FALSE
)

# DataLoaders
train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE, num_workers = 4)
valid_dl <- dataloader(valid_ds, batch_size = 32, shuffle = FALSE, num_workers = 4)
```

### Training Audio Models with luz

```r
library(luz)

# Setup model
fitted <- audio_cnn |>
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_accuracy(),
      luz_metric_binary_auroc()  # If binary classification
    )
  ) |>
  set_hparams(num_classes = length(unique(train_labels)), n_mels = 128) |>
  set_opt_hparams(lr = 0.001, weight_decay = 1e-4) |>
  fit(
    train_dl,
    epochs = 50,
    valid_data = valid_dl,
    callbacks = list(
      luz_callback_early_stopping(patience = 10, monitor = "valid_loss"),
      luz_callback_lr_scheduler(
        torch::lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 5
      ),
      luz_callback_model_checkpoint(path = "models/", monitor = "valid_loss"),
      luz_callback_csv_logger("training_log.csv")
    ),
    verbose = TRUE
  )

# Evaluate
evaluate(fitted, valid_dl)

# Predict on new data
predictions <- predict(fitted, test_dl)
```

### Handling Class Imbalance in Audio

```r
# Class weights (inverse frequency)
class_counts <- table(train_labels)
class_weights <- 1.0 / as.numeric(class_counts)
class_weights <- class_weights / sum(class_weights) * length(class_weights)
class_weights_tensor <- torch_tensor(class_weights)

# Weighted loss
criterion <- nn_cross_entropy_loss(weight = class_weights_tensor$to(device = device))

# Focal loss for extreme imbalance
focal_loss <- nn_module(
  "FocalLoss",
  initialize = function(alpha = 1, gamma = 2) {
    self$alpha <- alpha
    self$gamma <- gamma
    self$ce_loss <- nn_cross_entropy_loss(reduction = "none")
  },
  forward = function(inputs, targets) {
    ce_loss <- self$ce_loss(inputs, targets)
    pt <- torch_exp(-ce_loss)
    focal_loss <- self$alpha * (1 - pt)^self$gamma * ce_loss
    return(focal_loss$mean())
  }
)

# Per-species threshold tuning (post-training)
optimize_thresholds <- function(probabilities, true_labels, metric = "f1") {
  num_classes <- ncol(probabilities)
  optimal_thresholds <- numeric(num_classes)

  for (i in 1:num_classes) {
    thresholds <- seq(0.1, 0.9, by = 0.05)
    scores <- sapply(thresholds, function(t) {
      preds <- probabilities[, i] > t
      if (metric == "f1") {
        # Calculate F1
        tp <- sum(preds & true_labels[, i])
        fp <- sum(preds & !true_labels[, i])
        fn <- sum(!preds & true_labels[, i])
        precision <- tp / (tp + fp + 1e-9)
        recall <- tp / (tp + fn + 1e-9)
        2 * (precision * recall) / (precision + recall + 1e-9)
      }
    })
    optimal_thresholds[i] <- thresholds[which.max(scores)]
  }

  return(optimal_thresholds)
}
```

### Inference on Continuous Audio

```r
# Sliding window inference for long recordings
infer_continuous_audio <- function(model, audio_path, window_sec = 5, overlap = 0.5,
                                    mel_transform, device = "cpu") {
  # Load audio
  audio <- readWave(audio_path)
  sr <- audio@samp.rate
  duration_sec <- length(audio@left) / sr

  # Parameters
  window_samples <- as.integer(window_sec * sr)
  hop_samples <- as.integer(window_samples * (1 - overlap))

  # Initialize results
  timestamps <- c()
  predictions <- list()

  model$eval()
  with_no_grad({
    start_sample <- 1
    while (start_sample + window_samples <= length(audio@left)) {
      # Extract window
      window_audio <- audio@left[start_sample:(start_sample + window_samples - 1)]
      waveform <- torch_tensor(window_audio)$unsqueeze(1)$to(device = device)

      # Transform to spectrogram
      spectrogram <- mel_transform(waveform)$unsqueeze(1)  # Add batch dim

      # Predict
      logits <- model(spectrogram)
      probs <- nnf_softmax(logits, dim = 2)

      # Store
      timestamps <- c(timestamps, start_sample / sr)
      predictions[[length(predictions) + 1]] <- as.array(probs$cpu())

      # Next window
      start_sample <- start_sample + hop_samples
    }
  })

  # Combine results
  results <- tibble(
    start_time = timestamps,
    end_time = timestamps + window_sec,
    predictions = predictions
  )

  return(results)
}

# Post-processing: Temporal smoothing
smooth_predictions <- function(predictions, window_size = 5) {
  # Moving average over time
  smoothed <- apply(predictions, 2, function(x) {
    zoo::rollmean(x, k = window_size, fill = "extend")
  })
  return(smoothed)
}

# Aggregate overlapping windows
aggregate_windows <- function(inference_results, method = "mean") {
  # Group overlapping predictions and aggregate
  if (method == "mean") {
    # Average probabilities across overlapping windows
    aggregated <- inference_results |>
      group_by(start_time = floor(start_time)) |>
      summarize(
        predictions = list(Reduce(`+`, predictions) / length(predictions))
      )
  } else if (method == "max") {
    # Max probability across overlapping windows
    aggregated <- inference_results |>
      group_by(start_time = floor(start_time)) |>
      summarize(
        predictions = list(do.call(pmax, predictions))
      )
  }

  return(aggregated)
}
```

## Training Best Practices

### Data Preparation
1. **Standardization**:
   - Fixed sample rate across all audio
   - Consistent duration (pad/crop)
   - Normalization to [-1, 1] or [0, 1]

2. **Train/validation/test splits**:
   - For audio: group by `recording_id` or `site_id` (prevent leakage)
   - Use `group_vfold_cv()` from tidymodels or grouped resampling
   - Never split randomly for time series or spatial data

3. **Data augmentation**:
   - Time-domain: time shift, noise addition, speed/pitch changes
   - Spectrogram: SpecAugment (frequency/time masking)
   - Batch-level: mixup, cutmix

### Model Training
1. **Learning rate scheduling**:
   - Start with 1e-3 for Adam
   - Use `lr_reduce_on_plateau` (factor=0.5, patience=3-5)
   - Or `lr_one_cycle` for faster convergence

2. **Regularization**:
   - Dropout: 0.2-0.5 after dense layers
   - Batch normalization after conv layers
   - Weight decay: 1e-4 to 1e-5
   - Early stopping: patience=5-10 epochs

3. **Gradient management**:
   - Gradient clipping if loss spikes (max_norm=1.0)
   - Mixed precision training for GPU memory (torch_cuda_amp)

4. **Checkpointing**:
   - Save best model based on validation metric
   - Save optimizer state for resuming training
   - Track hyperparameters with each checkpoint

### Evaluation
1. **Metrics**:
   - Classification: accuracy, macro/micro F1, per-class precision/recall
   - Imbalanced: weighted F1, PR-AUC (not ROC-AUC)
   - Multi-label: Hamming loss, subset accuracy

2. **Validation strategy**:
   - Cross-validation with grouped folds
   - Hold-out test set (never touched during development)
   - Monitor training/validation curves for overfitting

3. **Error analysis**:
   - Confusion matrix for classification
   - Per-class performance breakdown
   - Visualize misclassified examples

## Integration with R Ecosystem

### With tidyverse

```r
library(tidyverse)

# Prepare data with tidyverse
audio_df <- tibble(
  file_path = list.files("audio", pattern = "\\.wav$", full.names = TRUE),
  file_name = basename(file_path)
) |>
  mutate(
    # Extract labels from filename
    species = str_extract(file_name, "^[A-Za-z]+"),
    # Create numeric labels
    label = as.integer(factor(species)) - 1
  )

# Split by recording_id to prevent leakage
train_test_split <- audio_df |>
  mutate(recording_id = str_extract(file_name, "rec[0-9]+")) |>
  group_by(recording_id) |>
  slice_sample(n = 1) |>  # One file per recording for split decision
  ungroup() |>
  mutate(split = sample(c("train", "test"), n(), replace = TRUE, prob = c(0.8, 0.2))) |>
  select(recording_id, split)

audio_df <- audio_df |>
  mutate(recording_id = str_extract(file_name, "rec[0-9]+")) |>
  left_join(train_test_split, by = "recording_id")

train_df <- audio_df |> filter(split == "train")
test_df <- audio_df |> filter(split == "test")
```

### With tidymodels

```r
library(tidymodels)

# If using extracted features (not raw spectrograms)
# Integrate DL embeddings as features for tidymodels

# Extract embeddings from pretrained CNN
extract_embeddings <- function(model, dataloader, device = "cpu") {
  model$eval()
  embeddings <- list()

  with_no_grad({
    coro::loop(for (batch in dataloader) {
      x <- batch$x$to(device = device)
      # Forward pass through CNN (stop before final layer)
      features <- model$conv1(x) |>
        model$conv2() |>
        model$conv3() |>
        model$global_pool()
      embeddings[[length(embeddings) + 1]] <- as.array(features$cpu())
    })
  })

  do.call(rbind, embeddings)
}

# Create tidymodels recipe with DL embeddings
recipe_with_embeddings <- recipe(species ~ ., data = feature_df) |>
  step_normalize(all_numeric_predictors()) |>
  step_pca(starts_with("embedding_"), num_comp = 50)

# Standard tidymodels workflow
rf_spec <- rand_forest(trees = 500) |>
  set_engine("ranger") |>
  set_mode("classification")

wf <- workflow() |>
  add_recipe(recipe_with_embeddings) |>
  add_model(rf_spec)

fit_resamples(wf, resamples = vfold_cv(feature_df, v = 5))
```

## Common Patterns

### Pattern: Save and Load Models

```r
# torch
# Save
torch_save(model, "model.pt")
torch_save(optimizer, "optimizer.pt")

# Load
model <- torch_load("model.pt")
optimizer <- torch_load("optimizer.pt")

# Save just state dict (recommended)
torch_save(model$state_dict(), "model_state.pt")
model$load_state_dict(torch_load("model_state.pt"))

# keras3
# Save
model |> save_model("model.keras")

# Load
model <- load_model("model.keras")

# luz
# Automatically saved by callback
luz_callback_model_checkpoint(path = "models/", monitor = "valid_loss")

# Load
model <- luz_load("models/best_model.pt")
```

### Pattern: Reproducibility

```r
# Set seeds for reproducibility
set.seed(42)
torch_manual_seed(42)
if (cuda_is_available()) {
  cuda_manual_seed(42)
  cuda_manual_seed_all(42)
}

# For cuDNN determinism (slower but reproducible)
torch_backends_cudnn_deterministic(TRUE)
torch_backends_cudnn_benchmark(FALSE)

# Track configuration with config package
library(config)

config <- list(
  model = "AudioCNN",
  n_mels = 128,
  batch_size = 32,
  learning_rate = 0.001,
  epochs = 50,
  seed = 42
)

yaml::write_yaml(config, "config.yaml")
```

### Pattern: Multi-GPU Training

```r
# torch (single script, multiple GPUs)
if (cuda_device_count() > 1) {
  model <- nn_data_parallel(model)  # Wrap model
}

model <- model$to(device = "cuda")

# Rest of training loop remains the same
# Data will be automatically split across GPUs
```

## Troubleshooting

**Issue**: CUDA out of memory
- Reduce batch size
- Use gradient accumulation (effective batch size)
- Enable mixed precision training
- Use smaller model or spectrograms
- Clear cache with `cuda_empty_cache()`

**Issue**: Model not learning (loss not decreasing)
- Check learning rate (try 1e-4, 1e-3, 1e-2)
- Verify data preprocessing (normalization, labels)
- Check for NaN/Inf in gradients (`torch_any(torch_isnan(model$fc1$weight$grad))`)
- Simplify model architecture first
- Visualize input data (ensure spectrograms look correct)

**Issue**: Overfitting (validation loss increasing)
- Add more dropout
- Increase weight decay
- Use data augmentation
- Reduce model capacity
- Early stopping with patience

**Issue**: Spectrograms look wrong
- Check sample rate matches expectation
- Verify mono conversion
- Check n_fft, hop_length, n_mels parameters
- Apply log scaling to mel-spectrogram
- Visualize before training

**Issue**: Slow training
- Use GPU (check `cuda_is_available()`)
- Increase batch size
- Use more num_workers in dataloader
- Profile with `profvis` to find bottlenecks
- Consider mixed precision training

## Additional Resources

- **torch documentation**: [torch.mlverse.org](https://torch.mlverse.org)
- **keras3 documentation**: [keras3.posit.co](https://keras3.posit.co)
- **luz documentation**: [mlverse.github.io/luz](https://mlverse.github.io/luz)
- **Domain-specific examples**: [examples/](examples/)
  - [Computer vision](examples/computer-vision.md)
  - [NLP](examples/nlp.md)
  - [Audio classification](examples/audio-classification.md)
  - [Time series](examples/time-series.md)
- **Architecture references**: [references/architectures.md](references/architectures.md)
- **Training recipes**: [templates/training-recipes.R](templates/training-recipes.R)

## Integration with Other Skills

- **r-bioacoustics**: For audio preprocessing and feature extraction before DL
- **r-tidymodels**: For integrating DL embeddings as features in ML pipelines
- **learning-paradigms**: For weak supervision, few-shot, and self-supervised learning
- **r-performance**: For profiling and optimizing training pipelines
- **ggplot2**: For visualizing training curves and spectrograms

---

This skill provides comprehensive deep learning guidance across all domains with special emphasis on audio for bioacoustic applications. For audio-specific workflows, consider integrating with the r-bioacoustics skill for preprocessing and feature engineering.
