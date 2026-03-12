# Audio Deep Learning - Code Recipes for R

Ready-to-use code snippets for audio classification tasks using {torch} and {torchaudio} in R.

---

## Recipe 1: Complete Preprocessing Pipeline

```r
# Install packages
# install.packages(c("torch", "torchaudio", "tuneR", "seewave"))

library(torch)
library(torchaudio)
library(tuneR)

# Function to preprocess a single audio file
preprocess_audio <- function(audio_path, target_sr = 22050, duration_sec = 5,
                             n_mels = 128, n_fft = 2048, hop_length = 512,
                             f_min = 500, f_max = 12000) {

  # 1. Load audio
  audio <- readWave(audio_path)

  # 2. Convert to mono
  if (audio@stereo) {
    audio <- mono(audio, which = "both")
  }

  # 3. Resample
  if (audio@samp.rate != target_sr) {
    audio <- resample(audio, target_sr, orig.freq = audio@samp.rate)
  }

  # 4. Normalize
  audio <- normalize(audio, unit = "1")

  # 5. Pad or truncate to fixed duration
  target_length <- target_sr * duration_sec
  signal <- audio@left

  if (length(signal) < target_length) {
    # Pad with zeros
    signal <- c(signal, rep(0, target_length - length(signal)))
  } else if (length(signal) > target_length) {
    # Random crop (augmentation) or center crop
    if (length(signal) > target_length) {
      start_idx <- sample(1:(length(signal) - target_length + 1), 1)
      signal <- signal[start_idx:(start_idx + target_length - 1)]
    }
  }

  # 6. Convert to tensor
  waveform <- torch_tensor(signal)$unsqueeze(1)  # Add channel dim

  # 7. Compute mel-spectrogram
  mel_transform <- transform_mel_spectrogram(
    sample_rate = target_sr,
    n_fft = n_fft,
    hop_length = hop_length,
    n_mels = n_mels,
    f_min = f_min,
    f_max = f_max
  )

  mel_spec <- mel_transform(waveform)

  # 8. Log scaling
  log_mel <- torch_log1p(mel_spec)

  # 9. Normalize
  mean_val <- torch_mean(log_mel)
  std_val <- torch_std(log_mel)
  log_mel <- (log_mel - mean_val) / (std_val + 1e-8)

  # 10. Add batch and channel dimensions
  log_mel <- log_mel$unsqueeze(1)  # (1, 1, n_mels, n_frames)

  return(log_mel)
}

# Usage
spec <- preprocess_audio("bird_call.wav")
print(spec$shape)  # torch_Size([1, 1, 128, 216])
```

---

## Recipe 2: Custom Dataset Class

```r
library(torch)
library(tuneR)

# Audio dataset for classification
audio_dataset <- dataset(
  name = "AudioClassificationDataset",

  initialize = function(metadata_df, audio_dir, target_sr = 22050,
                       duration_sec = 5, n_mels = 128, augment = FALSE) {

    self$metadata <- metadata_df  # Should have: filename, label_id
    self$audio_dir <- audio_dir
    self$target_sr <- target_sr
    self$duration_sec <- duration_sec
    self$n_mels <- n_mels
    self$augment <- augment

    # Create mel-spectrogram transform
    self$mel_transform <- transform_mel_spectrogram(
      sample_rate = target_sr,
      n_fft = 2048,
      hop_length = 512,
      n_mels = n_mels,
      f_min = 500,
      f_max = 12000
    )
  },

  .getitem = function(index) {
    # Get metadata
    row <- self$metadata[index, ]
    audio_path <- file.path(self$audio_dir, row$filename)

    # Load and preprocess
    audio <- readWave(audio_path)
    audio <- mono(audio)

    if (audio@samp.rate != self$target_sr) {
      audio <- resample(audio, self$target_sr, orig.freq = audio@samp.rate)
    }

    audio <- normalize(audio, unit = "1")

    # Pad/crop
    signal <- audio@left
    target_length <- self$target_sr * self$duration_sec

    if (length(signal) < target_length) {
      signal <- c(signal, rep(0, target_length - length(signal)))
    } else if (length(signal) > target_length) {
      if (self$augment) {
        # Random crop
        start_idx <- sample(1:(length(signal) - target_length + 1), 1)
      } else {
        # Center crop
        start_idx <- (length(signal) - target_length) %/% 2 + 1
      }
      signal <- signal[start_idx:(start_idx + target_length - 1)]
    }

    # Convert to tensor
    waveform <- torch_tensor(signal)$unsqueeze(1)

    # Compute mel-spectrogram
    mel_spec <- self$mel_transform(waveform)

    # Log scale
    log_mel <- torch_log1p(mel_spec)

    # Normalize
    log_mel <- (log_mel - log_mel$mean()) / (log_mel$std() + 1e-8)

    # Augment
    if (self$augment && runif(1) > 0.5) {
      log_mel <- self$spec_augment(log_mel)
    }

    # Add channel dimension
    log_mel <- log_mel$unsqueeze(1)

    # Get label
    label <- torch_tensor(row$label_id, dtype = torch_long())

    return(list(x = log_mel, y = label))
  },

  .length = function() {
    nrow(self$metadata)
  },

  spec_augment = function(spec, freq_mask = 15, time_mask = 20) {
    # Frequency masking
    n_freq <- spec$shape[1]
    if (n_freq > freq_mask) {
      f <- sample(0:freq_mask, 1)
      f0 <- sample(0:(n_freq - f), 1)
      spec[(f0 + 1):(f0 + f), ] <- 0
    }

    # Time masking
    n_time <- spec$shape[2]
    if (n_time > time_mask) {
      t <- sample(0:time_mask, 1)
      t0 <- sample(0:(n_time - t), 1)
      spec[, (t0 + 1):(t0 + t)] <- 0
    }

    return(spec)
  }
)

# Usage
metadata <- data.frame(
  filename = c("bird1.wav", "bird2.wav"),
  label_id = c(0L, 1L)
)

train_ds <- audio_dataset(metadata, audio_dir = "data/audio/", augment = TRUE)
train_dl <- dataloader(train_ds, batch_size = 16, shuffle = TRUE)

# Test
batch <- train_dl$.iter()$.next()
print(batch$x$shape)  # [16, 1, 128, 216]
print(batch$y$shape)  # [16]
```

---

## Recipe 3: Simple CNN Model

```r
library(torch)
library(luz)

# Define a simple CNN for audio classification
audio_cnn <- nn_module(
  "AudioCNN",

  initialize = function(n_classes, n_mels = 128, dropout = 0.5) {

    # Block 1
    self$conv1 <- nn_conv2d(1, 32, kernel_size = c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(32)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    # Block 2
    self$conv2 <- nn_conv2d(32, 64, kernel_size = c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(64)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    # Block 3
    self$conv3 <- nn_conv2d(64, 128, kernel_size = c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(128)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # Block 4
    self$conv4 <- nn_conv2d(128, 256, kernel_size = c(3, 3), padding = "same")
    self$bn4 <- nn_batch_norm2d(256)
    self$pool4 <- nn_max_pool2d(c(2, 2))

    # Classifier
    self$dropout <- nn_dropout(dropout)
    self$gap <- nn_adaptive_avg_pool2d(c(1, 1))
    self$fc <- nn_linear(256, n_classes)
  },

  forward = function(x) {
    # x: (batch, 1, n_mels, n_frames)

    x <- x %>%
      self$conv1() %>%
      self$bn1() %>%
      nnf_relu() %>%
      self$pool1()

    x <- x %>%
      self$conv2() %>%
      self$bn2() %>%
      nnf_relu() %>%
      self$pool2()

    x <- x %>%
      self$conv3() %>%
      self$bn3() %>%
      nnf_relu() %>%
      self$pool3()

    x <- x %>%
      self$conv4() %>%
      self$bn4() %>%
      nnf_relu() %>%
      self$pool4()

    # Global average pooling
    x <- self$gap(x)
    x <- torch_flatten(x, start_dim = 2)

    # Dropout and classification
    x <- self$dropout(x)
    x <- self$fc(x)

    return(x)
  }
)

# Instantiate model
model <- audio_cnn(n_classes = 10)

# Test forward pass
dummy_input <- torch_randn(4, 1, 128, 216)  # batch=4
output <- model(dummy_input)
print(output$shape)  # [4, 10]
```

---

## Recipe 4: Training Loop with Luz

```r
library(torch)
library(luz)

# Prepare data (assuming you have train_dl and val_dl)

# Define model
model <- audio_cnn(n_classes = length(unique(train_metadata$label_id)))

# Train with luz
fitted <- model %>%
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_accuracy()
    )
  ) %>%
  set_hparams(
    n_classes = n_classes,
    dropout = 0.5
  ) %>%
  set_opt_hparams(
    lr = 0.001,
    weight_decay = 1e-4
  ) %>%
  fit(
    train_dl,
    epochs = 50,
    valid_data = val_dl,
    callbacks = list(
      # Early stopping
      luz_callback_early_stopping(
        monitor = "valid_loss",
        patience = 10,
        mode = "min"
      ),

      # Learning rate scheduler
      luz_callback_lr_scheduler(
        lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 5,
        threshold = 0.001
      ),

      # Model checkpoint
      luz_callback_model_checkpoint(
        path = "models/",
        monitor = "valid_loss",
        save_best_only = TRUE
      ),

      # CSV logger
      luz_callback_csv_logger("training_log.csv")
    ),
    verbose = TRUE
  )

# Save final model
luz_save(fitted, "final_model.pt")
```

---

## Recipe 5: Training with Class Weights

```r
# Compute class weights from imbalanced data
compute_class_weights <- function(labels) {
  class_counts <- table(labels)
  total <- sum(class_counts)

  # Inverse frequency weighting
  weights <- total / (length(class_counts) * class_counts)

  # Normalize
  weights <- weights / sum(weights) * length(weights)

  return(torch_tensor(as.numeric(weights)))
}

# Get class weights
class_weights <- compute_class_weights(train_metadata$label_id)
print(class_weights)

# Train with weighted loss
fitted <- model %>%
  setup(
    loss = nn_cross_entropy_loss(weight = class_weights),
    optimizer = optim_adam,
    metrics = list(luz_metric_accuracy())
  ) %>%
  set_hparams(n_classes = n_classes) %>%
  set_opt_hparams(lr = 0.001) %>%
  fit(train_dl, epochs = 50, valid_data = val_dl)
```

---

## Recipe 6: Focal Loss for Extreme Imbalance

```r
# Focal loss implementation
focal_loss <- function(alpha = 0.25, gamma = 2.0) {
  function(input, target) {
    # input: logits (batch, n_classes)
    # target: class indices (batch)

    ce_loss <- nnf_cross_entropy(input, target, reduction = "none")
    pt <- torch_exp(-ce_loss)
    focal <- alpha * (1 - pt)^gamma * ce_loss

    return(focal$mean())
  }
}

# Use in training
fitted <- model %>%
  setup(
    loss = focal_loss(alpha = 0.25, gamma = 2.0),
    optimizer = optim_adam,
    metrics = list(luz_metric_accuracy())
  ) %>%
  set_hparams(n_classes = n_classes) %>%
  fit(train_dl, epochs = 50, valid_data = val_dl)
```

---

## Recipe 7: CRNN with Attention

```r
# CRNN model with attention pooling
audio_crnn_attention <- nn_module(
  "AudioCRNNAttention",

  initialize = function(n_classes, n_mels = 128, rnn_hidden = 128) {

    # CNN frontend
    self$conv1 <- nn_conv2d(1, 64, c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(64)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    self$conv2 <- nn_conv2d(64, 128, c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(128)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    self$conv3 <- nn_conv2d(128, 256, c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(256)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # Bidirectional LSTM
    freq_dim <- n_mels / 8  # After 3 pooling layers
    self$lstm <- nn_lstm(
      input_size = 256 * freq_dim,
      hidden_size = rnn_hidden,
      num_layers = 2,
      batch_first = TRUE,
      bidirectional = TRUE,
      dropout = 0.3
    )

    # Attention
    self$attention_fc <- nn_linear(rnn_hidden * 2, 1)

    # Classifier
    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(rnn_hidden * 2, n_classes)
  },

  forward = function(x) {
    batch_size <- x$shape[1]

    # CNN
    x <- x %>%
      self$conv1() %>%
      self$bn1() %>%
      nnf_relu() %>%
      self$pool1()

    x <- x %>%
      self$conv2() %>%
      self$bn2() %>%
      nnf_relu() %>%
      self$pool2()

    x <- x %>%
      self$conv3() %>%
      self$bn3() %>%
      nnf_relu() %>%
      self$pool3()

    # x: (batch, 256, n_mels/8, n_frames/8)

    # Reshape for RNN: (batch, time, features)
    x <- x$permute(c(1, 4, 2, 3))  # (batch, time, channels, freq)
    x <- torch_flatten(x, start_dim = 3)  # (batch, time, channels*freq)

    # RNN
    lstm_out <- self$lstm(x)[[1]]  # (batch, time, hidden*2)

    # Attention weights
    attn_weights <- self$attention_fc(lstm_out)  # (batch, time, 1)
    attn_weights <- torch_softmax(attn_weights, dim = 2)

    # Attended output
    attended <- (lstm_out * attn_weights)$sum(dim = 2)  # (batch, hidden*2)

    # Classify
    out <- self$dropout(attended)
    out <- self$fc(out)

    return(out)
  }
)

# Usage
model <- audio_crnn_attention(n_classes = 10)
dummy_input <- torch_randn(4, 1, 128, 216)
output <- model(dummy_input)
print(output$shape)  # [4, 10]
```

---

## Recipe 8: Inference on Continuous Audio

```r
# Function to predict on long audio file
predict_continuous_audio <- function(model, audio_path,
                                    window_sec = 5, hop_sec = 2.5,
                                    sample_rate = 22050, n_mels = 128,
                                    threshold = 0.5) {

  # Load audio
  audio <- readWave(audio_path)

  if (audio@stereo) {
    audio <- mono(audio)
  }

  if (audio@samp.rate != sample_rate) {
    audio <- resample(audio, sample_rate, orig.freq = audio@samp.rate)
  }

  signal <- audio@left

  # Window parameters
  window_samples <- sample_rate * window_sec
  hop_samples <- sample_rate * hop_sec
  n_windows <- floor((length(signal) - window_samples) / hop_samples) + 1

  # Mel transform
  mel_transform <- transform_mel_spectrogram(
    sample_rate = sample_rate,
    n_fft = 2048,
    hop_length = 512,
    n_mels = n_mels,
    f_min = 500,
    f_max = 12000
  )

  # Predict each window
  model$eval()
  predictions <- list()
  timestamps <- numeric(n_windows)

  for (i in 1:n_windows) {
    start_idx <- (i - 1) * hop_samples + 1
    end_idx <- start_idx + window_samples - 1
    window <- signal[start_idx:end_idx]

    # Preprocess
    waveform <- torch_tensor(window)$unsqueeze(1)
    mel_spec <- mel_transform(waveform)
    log_mel <- torch_log1p(mel_spec)
    log_mel <- (log_mel - log_mel$mean()) / (log_mel$std() + 1e-8)
    log_mel <- log_mel$unsqueeze(1)$unsqueeze(1)

    # Predict
    with_no_grad({
      logits <- model(log_mel)
      probs <- nnf_softmax(logits, dim = 2)
    })

    predictions[[i]] <- as.numeric(probs$cpu())
    timestamps[i] <- start_idx / sample_rate
  }

  # Convert to data frame
  pred_matrix <- do.call(rbind, predictions)
  colnames(pred_matrix) <- paste0("class_", 0:(ncol(pred_matrix) - 1))

  results <- data.frame(
    timestamp = timestamps,
    pred_matrix
  )

  return(results)
}

# Usage
predictions <- predict_continuous_audio(
  model = fitted$model,
  audio_path = "long_recording.wav",
  window_sec = 5,
  hop_sec = 2.5
)

# Apply threshold and find detections
detections <- predictions %>%
  mutate(
    detected_class = apply(select(., starts_with("class_")), 1,
                          function(x) {
                            max_prob <- max(x)
                            if (max_prob > 0.7) which.max(x) - 1 else NA
                          })
  ) %>%
  filter(!is.na(detected_class))

print(detections)
```

---

## Recipe 9: Model Evaluation

```r
library(yardstick)
library(dplyr)

# Evaluate model on test set
evaluate_audio_model <- function(model, test_dl) {

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

  # Overall metrics
  results <- tibble(
    truth = factor(labels),
    estimate = factor(predictions)
  )

  overall_metrics <- results %>%
    metrics(truth, estimate)

  # Confusion matrix
  conf_mat <- results %>%
    conf_mat(truth, estimate)

  # Per-class metrics
  class_metrics <- results %>%
    group_by(truth) %>%
    summarise(
      n = n(),
      precision = precision_vec(truth, estimate),
      recall = recall_vec(truth, estimate),
      f1 = f_meas_vec(truth, estimate),
      .groups = "drop"
    )

  return(list(
    overall = overall_metrics,
    confusion_matrix = conf_mat,
    per_class = class_metrics
  ))
}

# Usage
eval_results <- evaluate_audio_model(fitted$model, test_dl)
print(eval_results$overall)
print(eval_results$per_class)

# Plot confusion matrix
library(ggplot2)
autoplot(eval_results$confusion_matrix, type = "heatmap")
```

---

## Recipe 10: Multi-Label Classification

```r
# Multi-label dataset (for soundscapes with multiple species)
multilabel_audio_dataset <- dataset(
  name = "MultiLabelAudioDataset",

  initialize = function(metadata_df, audio_dir, n_classes, ...) {
    # metadata_df should have binary columns for each class
    self$metadata <- metadata_df
    self$audio_dir <- audio_dir
    self$n_classes <- n_classes
    # ... (same preprocessing as before)
  },

  .getitem = function(index) {
    row <- self$metadata[index, ]

    # ... (preprocess audio to get log_mel)

    # Multi-label target
    label_cols <- grep("^label_", names(row), value = TRUE)
    labels <- as.numeric(row[, label_cols])
    label_tensor <- torch_tensor(labels, dtype = torch_float())

    return(list(x = log_mel, y = label_tensor))
  },

  .length = function() {
    nrow(self$metadata)
  }
)

# Model with sigmoid output
multilabel_audio_model <- nn_module(
  "MultiLabelAudioCNN",

  initialize = function(n_classes) {
    # Same CNN as before
    self$features <- audio_cnn(n_classes = n_classes)
  },

  forward = function(x) {
    logits <- self$features(x)
    # No softmax - use sigmoid for multi-label
    return(logits)
  }
)

# Training with BCE loss
fitted <- multilabel_audio_model(n_classes = 20) %>%
  setup(
    loss = nn_bce_with_logits_loss(),  # For multi-label
    optimizer = optim_adam,
    metrics = list(
      luz_metric_binary_accuracy_with_logits(),
      luz_metric_binary_auroc()
    )
  ) %>%
  set_hparams(n_classes = 20) %>%
  set_opt_hparams(lr = 0.001) %>%
  fit(train_dl, epochs = 50, valid_data = val_dl)

# Prediction (apply threshold per class)
with_no_grad({
  logits <- model(batch$x)
  probs <- torch_sigmoid(logits)
})

# Species-specific thresholds
thresholds <- c(0.5, 0.6, 0.7, ...)  # Tune per species
predictions <- (probs > torch_tensor(thresholds))$cpu()
```

---

## Recipe 11: Data Augmentation Functions

```r
# SpecAugment
spec_augment <- function(spec, freq_mask_param = 15, time_mask_param = 20,
                        n_freq_masks = 2, n_time_masks = 2) {

  # spec: (n_mels, n_frames)
  n_mels <- spec$shape[1]
  n_frames <- spec$shape[2]

  # Frequency masking
  for (i in 1:n_freq_masks) {
    f <- sample(0:freq_mask_param, 1)
    if (f > 0 && f < n_mels) {
      f0 <- sample(0:(n_mels - f), 1)
      spec[(f0 + 1):(f0 + f), ] <- 0
    }
  }

  # Time masking
  for (i in 1:n_time_masks) {
    t <- sample(0:time_mask_param, 1)
    if (t > 0 && t < n_frames) {
      t0 <- sample(0:(n_frames - t), 1)
      spec[, (t0 + 1):(t0 + t)] <- 0
    }
  }

  return(spec)
}

# Mixup (use in training loop)
mixup_batch <- function(batch_x, batch_y, alpha = 0.4) {
  batch_size <- batch_x$shape[1]

  # Sample lambda
  lambda <- rbeta(1, alpha, alpha)

  # Random permutation
  indices <- torch_randperm(batch_size) + 1L

  # Mix
  mixed_x <- lambda * batch_x + (1 - lambda) * batch_x[indices]
  mixed_y <- lambda * batch_y + (1 - lambda) * batch_y[indices]

  return(list(x = mixed_x, y = mixed_y))
}

# Time stretching
time_stretch <- function(spec, rate = NULL) {
  if (is.null(rate)) {
    rate <- runif(1, 0.8, 1.2)
  }

  time_stretch_fn <- transform_time_stretch(
    hop_length = 512,
    n_freq = spec$shape[1]
  )

  stretched <- time_stretch_fn(spec, rate)
  return(stretched)
}

# Background noise addition
add_background_noise <- function(waveform, noise_waveform, snr_db = 10) {
  # Ensure same length
  if (noise_waveform$shape[2] > waveform$shape[2]) {
    start_idx <- sample(1:(noise_waveform$shape[2] - waveform$shape[2] + 1), 1)
    noise_waveform <- noise_waveform[, start_idx:(start_idx + waveform$shape[2] - 1)]
  } else {
    # Repeat noise if too short
    repeats <- ceiling(waveform$shape[2] / noise_waveform$shape[2])
    noise_waveform <- torch_cat(rep(list(noise_waveform), repeats), dim = 2)
    noise_waveform <- noise_waveform[, 1:waveform$shape[2]]
  }

  # Calculate signal and noise power
  signal_power <- torch_mean(waveform^2)
  noise_power <- torch_mean(noise_waveform^2)

  # Scale noise to achieve desired SNR
  snr_linear <- 10^(snr_db / 10)
  noise_scaled <- noise_waveform * torch_sqrt(signal_power / (snr_linear * noise_power + 1e-8))

  # Mix
  augmented <- waveform + noise_scaled

  return(augmented)
}
```

---

## Recipe 12: Saving and Loading Models

```r
# Save model
luz_save(fitted, "audio_classifier.pt")

# Load model
loaded_model <- luz_load("audio_classifier.pt")

# Extract just the trained model (without optimizer state, etc.)
model_only <- fitted$model
torch_save(model_only, "model_weights.pt")

# Load weights into a new model instance
new_model <- audio_cnn(n_classes = 10)
new_model$load_state_dict(torch_load("model_weights.pt"))
new_model$eval()

# Export to ONNX (for deployment)
dummy_input <- torch_randn(1, 1, 128, 216)
torch_onnx_export(
  new_model,
  dummy_input,
  "audio_classifier.onnx",
  input_names = c("spectrogram"),
  output_names = c("logits"),
  opset_version = 11
)
```

---

## Recipe 13: Complete End-to-End Example

```r
library(torch)
library(luz)
library(tuneR)
library(torchaudio)
library(dplyr)

# 1. Prepare metadata
metadata <- data.frame(
  filename = list.files("data/audio", pattern = "\\.wav$"),
  label = c("species_A", "species_B", "species_A", ...)
)

# Encode labels
metadata <- metadata %>%
  mutate(label_id = as.integer(factor(label)) - 1L)

# Split data
set.seed(42)
train_ids <- sample(nrow(metadata), nrow(metadata) * 0.8)
train_meta <- metadata[train_ids, ]
test_meta <- metadata[-train_ids, ]

# 2. Create datasets
train_ds <- audio_dataset(train_meta, audio_dir = "data/audio", augment = TRUE)
test_ds <- audio_dataset(test_meta, audio_dir = "data/audio", augment = FALSE)

train_dl <- dataloader(train_ds, batch_size = 16, shuffle = TRUE)
test_dl <- dataloader(test_ds, batch_size = 16, shuffle = FALSE)

# 3. Define model
n_classes <- length(unique(metadata$label))
model <- audio_cnn(n_classes = n_classes)

# 4. Compute class weights
class_weights <- compute_class_weights(train_meta$label_id)

# 5. Train
fitted <- model %>%
  setup(
    loss = nn_cross_entropy_loss(weight = class_weights),
    optimizer = optim_adam,
    metrics = list(luz_metric_accuracy())
  ) %>%
  set_hparams(n_classes = n_classes) %>%
  set_opt_hparams(lr = 0.001, weight_decay = 1e-4) %>%
  fit(
    train_dl,
    epochs = 50,
    valid_data = test_dl,
    callbacks = list(
      luz_callback_early_stopping(patience = 10),
      luz_callback_lr_scheduler(lr_reduce_on_plateau, patience = 5),
      luz_callback_model_checkpoint(path = "models/"),
      luz_callback_csv_logger("training.csv")
    )
  )

# 6. Evaluate
eval_results <- evaluate_audio_model(fitted$model, test_dl)
print(eval_results$overall)
print(eval_results$per_class)

# 7. Predict on new file
predictions <- predict_continuous_audio(
  fitted$model,
  "new_recording.wav"
)

# 8. Save model
luz_save(fitted, "final_audio_model.pt")
```

---

## Common Hyperparameters

```r
# Preprocessing
config_preprocess <- list(
  sample_rate = 22050,      # 16000 for speech, 22050 for music/birds
  duration_sec = 5,          # 2-5 for short clips, 10+ for soundscapes
  n_mels = 128,              # 64-256, 128 is standard
  n_fft = 2048,              # 1024-4096, affects freq resolution
  hop_length = 512,          # Usually n_fft / 4
  f_min = 500,               # Species-specific
  f_max = 12000              # Nyquist or species-specific
)

# Model
config_model <- list(
  dropout = 0.5,             # 0.3-0.5 for regularization
  n_conv_layers = 4,         # 3-5 typical
  base_filters = 32,         # 32 or 64
  rnn_hidden = 128           # For CRNN: 64-256
)

# Training
config_training <- list(
  batch_size = 16,           # 16-32 typical (depends on GPU memory)
  lr = 0.001,                # 0.0001-0.01, use 0.001 as start
  weight_decay = 1e-4,       # L2 regularization
  epochs = 50,               # With early stopping
  patience = 10,             # Early stopping patience
  lr_patience = 5            # LR reduction patience
)

# Augmentation
config_augment <- list(
  use_spec_augment = TRUE,
  freq_mask = 15,            # 10-30
  time_mask = 20,            # 10-40
  use_mixup = TRUE,
  mixup_alpha = 0.4,         # 0.2-0.8
  use_time_stretch = FALSE,  # Slower, use if needed
  use_noise = FALSE          # Need noise dataset
)
```

---

## Debugging Tips

```r
# Check input shapes
batch <- train_dl$.iter()$.next()
print(batch$x$shape)  # Should be [batch_size, 1, n_mels, n_frames]
print(batch$y$shape)  # Should be [batch_size]

# Verify model forward pass
model <- audio_cnn(n_classes = 10)
output <- model(batch$x)
print(output$shape)  # Should be [batch_size, n_classes]

# Check for NaN/Inf
torch_any(torch_isnan(batch$x))
torch_any(torch_isinf(batch$x))

# Visualize spectrogram
library(ggplot2)
spec_matrix <- as.matrix(batch$x[1, 1, , ]$cpu())
image(t(spec_matrix), col = hcl.colors(100, "YlOrRd", rev = TRUE))

# Check class distribution
table(train_meta$label)

# Monitor GPU memory
if (cuda_is_available()) {
  cuda_empty_cache()
  print(cuda_memory_allocated() / 1e9)  # GB
}

# Overfit on single batch (sanity check)
single_batch <- train_dl$.iter()$.next()
model$train()
optimizer <- optim_adam(model$parameters, lr = 0.01)

for (i in 1:100) {
  optimizer$zero_grad()
  output <- model(single_batch$x)
  loss <- nnf_cross_entropy(output, single_batch$y)
  loss$backward()
  optimizer$step()

  if (i %% 10 == 0) {
    cat(sprintf("Step %d: Loss = %.4f\n", i, loss$item()))
  }
}
# Loss should go to ~0 if model can overfit
```

---

These recipes provide ready-to-use code for the most common audio deep learning tasks in R!
