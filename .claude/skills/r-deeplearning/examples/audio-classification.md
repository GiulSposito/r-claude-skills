# Audio Classification Example

Complete end-to-end audio classification workflow using torch in R.

## Overview

This example demonstrates building a deep learning model for audio classification, commonly used in bioacoustics, speech recognition, and environmental sound monitoring.

**Use Case**: Classify bird species from audio recordings

**Key Components**:
- Audio preprocessing and normalization
- Mel-spectrogram feature extraction
- CNN architecture for spectrogram classification
- Data augmentation (SpecAugment)
- Handling class imbalance
- Training with luz
- Inference on continuous audio streams
- Temporal smoothing for robust predictions

---

## 1. Setup and Data Preparation

```r
library(torch)
library(luz)
library(torchaudio)
library(tuneR)
library(dplyr)

# Prepare metadata
metadata <- data.frame(
  filename = c("bird1.wav", "bird2.wav", "bird3.wav", ...),
  species = c("robin", "sparrow", "robin", ...),
  duration = c(5.2, 4.8, 6.1, ...)
)

# Encode labels to integers
metadata <- metadata |>
  mutate(label_id = as.integer(factor(species)) - 1L)

# Split data (temporal split for audio)
set.seed(42)
train_idx <- sample(nrow(metadata), nrow(metadata) * 0.7)
val_idx <- sample(setdiff(seq_len(nrow(metadata)), train_idx),
                  nrow(metadata) * 0.15)
test_idx <- setdiff(seq_len(nrow(metadata)), c(train_idx, val_idx))

train_meta <- metadata[train_idx, ]
val_meta <- metadata[val_idx, ]
test_meta <- metadata[test_idx, ]

n_classes <- length(unique(metadata$species))
```

---

## 2. Audio Dataset with Preprocessing

```r
# Custom dataset for audio classification
audio_classification_dataset <- dataset(
  name = "AudioClassificationDataset",

  initialize = function(metadata_df, audio_dir,
                       target_sr = 22050, duration_sec = 5,
                       n_mels = 128, n_fft = 2048, hop_length = 512,
                       f_min = 500, f_max = 12000,
                       augment = FALSE) {

    self$metadata <- metadata_df
    self$audio_dir <- audio_dir
    self$target_sr <- target_sr
    self$duration_sec <- duration_sec
    self$n_mels <- n_mels
    self$augment <- augment

    # Create mel-spectrogram transform
    self$mel_transform <- transform_mel_spectrogram(
      sample_rate = target_sr,
      n_fft = n_fft,
      hop_length = hop_length,
      n_mels = n_mels,
      f_min = f_min,
      f_max = f_max
    )
  },

  .getitem = function(index) {
    # Get metadata
    row <- self$metadata[index, ]
    audio_path <- file.path(self$audio_dir, row$filename)

    # 1. Load audio
    audio <- readWave(audio_path)

    # 2. Convert to mono
    if (audio@stereo) {
      audio <- mono(audio, which = "both")
    }

    # 3. Resample to target sample rate
    if (audio@samp.rate != self$target_sr) {
      audio <- resample(audio, self$target_sr,
                       orig.freq = audio@samp.rate)
    }

    # 4. Normalize (peak normalization)
    audio <- normalize(audio, unit = "1")

    # 5. Handle duration (pad or crop)
    signal <- audio@left
    target_length <- self$target_sr * self$duration_sec

    if (length(signal) < target_length) {
      # Pad with zeros
      signal <- c(signal, rep(0, target_length - length(signal)))
    } else if (length(signal) > target_length) {
      if (self$augment) {
        # Random crop (augmentation)
        start_idx <- sample(1:(length(signal) - target_length + 1), 1)
      } else {
        # Center crop
        start_idx <- (length(signal) - target_length) %/% 2 + 1
      }
      signal <- signal[start_idx:(start_idx + target_length - 1)]
    }

    # 6. Convert to tensor
    waveform <- torch_tensor(signal)$unsqueeze(1)  # Add channel dim

    # 7. Compute mel-spectrogram
    mel_spec <- self$mel_transform(waveform)

    # 8. Log scaling (log1p is log(x + 1))
    log_mel <- torch_log1p(mel_spec)

    # 9. Per-example normalization
    mean_val <- torch_mean(log_mel)
    std_val <- torch_std(log_mel)
    log_mel <- (log_mel - mean_val) / (std_val + 1e-8)

    # 10. Apply augmentation
    if (self$augment && runif(1) > 0.5) {
      log_mel <- self$spec_augment(log_mel)
    }

    # 11. Add channel dimension for CNN
    log_mel <- log_mel$unsqueeze(1)  # (1, n_mels, n_frames)

    # Get label
    label <- torch_tensor(row$label_id, dtype = torch_long())

    return(list(x = log_mel, y = label))
  },

  .length = function() {
    nrow(self$metadata)
  },

  # SpecAugment: mask random frequency and time bands
  spec_augment = function(spec, freq_mask_param = 15, time_mask_param = 20) {
    n_mels <- spec$shape[1]
    n_frames <- spec$shape[2]

    # Frequency masking
    if (n_mels > freq_mask_param) {
      f <- sample(0:freq_mask_param, 1)
      f0 <- sample(0:(n_mels - f), 1)
      spec[(f0 + 1):(f0 + f), ] <- 0
    }

    # Time masking
    if (n_frames > time_mask_param) {
      t <- sample(0:time_mask_param, 1)
      t0 <- sample(0:(n_frames - t), 1)
      spec[, (t0 + 1):(t0 + t)] <- 0
    }

    return(spec)
  }
)

# Create datasets
train_ds <- audio_classification_dataset(
  train_meta,
  audio_dir = "data/audio/",
  augment = TRUE  # Enable augmentation for training
)

val_ds <- audio_classification_dataset(
  val_meta,
  audio_dir = "data/audio/",
  augment = FALSE
)

test_ds <- audio_classification_dataset(
  test_meta,
  audio_dir = "data/audio/",
  augment = FALSE
)

# Create dataloaders
train_dl <- dataloader(train_ds, batch_size = 16, shuffle = TRUE,
                       num_workers = 4)
val_dl <- dataloader(val_ds, batch_size = 16, shuffle = FALSE)
test_dl <- dataloader(test_ds, batch_size = 16, shuffle = FALSE)

# Verify shapes
batch <- train_dl$.iter()$.next()
cat("Input shape:", batch$x$shape, "\n")    # [16, 1, 128, 216]
cat("Label shape:", batch$y$shape, "\n")    # [16]
```

---

## 3. CNN Architecture

```r
# CNN for audio classification
audio_cnn <- nn_module(
  "AudioCNN",

  initialize = function(n_classes, n_mels = 128, dropout = 0.5) {

    # Convolutional blocks with batch normalization
    # Each block: Conv2D -> BatchNorm -> ReLU -> MaxPool

    # Block 1: (1, 128, 216) -> (32, 64, 108)
    self$conv1 <- nn_conv2d(1, 32, kernel_size = c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(32)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    # Block 2: (32, 64, 108) -> (64, 32, 54)
    self$conv2 <- nn_conv2d(32, 64, kernel_size = c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(64)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    # Block 3: (64, 32, 54) -> (128, 16, 27)
    self$conv3 <- nn_conv2d(64, 128, kernel_size = c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(128)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # Block 4: (128, 16, 27) -> (256, 8, 13)
    self$conv4 <- nn_conv2d(128, 256, kernel_size = c(3, 3), padding = "same")
    self$bn4 <- nn_batch_norm2d(256)
    self$pool4 <- nn_max_pool2d(c(2, 2))

    # Global average pooling instead of flatten (reduces parameters)
    self$gap <- nn_adaptive_avg_pool2d(c(1, 1))

    # Classifier head
    self$dropout <- nn_dropout(dropout)
    self$fc <- nn_linear(256, n_classes)
  },

  forward = function(x) {
    # Input: (batch, 1, n_mels, n_frames)

    x <- x |>
      self$conv1() |>
      self$bn1() |>
      nnf_relu() |>
      self$pool1()

    x <- x |>
      self$conv2() |>
      self$bn2() |>
      nnf_relu() |>
      self$pool2()

    x <- x |>
      self$conv3() |>
      self$bn3() |>
      nnf_relu() |>
      self$pool3()

    x <- x |>
      self$conv4() |>
      self$bn4() |>
      nnf_relu() |>
      self$pool4()

    # Global average pooling: (batch, 256, h, w) -> (batch, 256, 1, 1)
    x <- self$gap(x)

    # Flatten: (batch, 256, 1, 1) -> (batch, 256)
    x <- torch_flatten(x, start_dim = 2)

    # Classify
    x <- self$dropout(x)
    x <- self$fc(x)  # (batch, n_classes)

    return(x)
  }
)

# Test model
model <- audio_cnn(n_classes = n_classes)
dummy_input <- torch_randn(4, 1, 128, 216)
output <- model(dummy_input)
cat("Output shape:", output$shape, "\n")  # [4, n_classes]
```

---

## 4. Handle Class Imbalance

```r
# Compute class weights for imbalanced dataset
compute_class_weights <- function(labels) {
  class_counts <- table(labels)
  total <- sum(class_counts)
  n_classes <- length(class_counts)

  # Inverse frequency weighting
  weights <- total / (n_classes * class_counts)

  # Normalize to sum to n_classes
  weights <- weights / sum(weights) * n_classes

  return(torch_tensor(as.numeric(weights)))
}

# Calculate weights
class_weights <- compute_class_weights(train_meta$label_id)
cat("Class weights:\n")
print(class_weights)

# Alternative: Focal Loss for extreme imbalance
focal_loss <- function(alpha = 0.25, gamma = 2.0) {
  function(input, target) {
    # input: raw logits (batch, n_classes)
    # target: class indices (batch)

    ce_loss <- nnf_cross_entropy(input, target, reduction = "none")
    pt <- torch_exp(-ce_loss)  # Probability of true class
    focal <- alpha * (1 - pt)^gamma * ce_loss

    return(focal$mean())
  }
}
```

---

## 5. Training with Luz

```r
# Train model
fitted <- model |>
  setup(
    # Use weighted cross-entropy for class imbalance
    loss = nn_cross_entropy_loss(weight = class_weights),
    # Or use focal loss: loss = focal_loss(alpha = 0.25, gamma = 2.0),

    optimizer = optim_adam,

    metrics = list(
      luz_metric_accuracy(),
      luz_metric_recall(),
      luz_metric_precision()
    )
  ) |>

  set_hparams(
    n_classes = n_classes,
    dropout = 0.5
  ) |>

  set_opt_hparams(
    lr = 0.001,
    weight_decay = 1e-4  # L2 regularization
  ) |>

  fit(
    train_dl,
    epochs = 50,
    valid_data = val_dl,

    callbacks = list(
      # Early stopping: stop if validation loss doesn't improve
      luz_callback_early_stopping(
        monitor = "valid_loss",
        patience = 10,
        mode = "min"
      ),

      # Learning rate reduction on plateau
      luz_callback_lr_scheduler(
        lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 5,
        threshold = 0.001
      ),

      # Save best model
      luz_callback_model_checkpoint(
        path = "models/",
        monitor = "valid_loss",
        save_best_only = TRUE,
        mode = "min"
      ),

      # Log training history
      luz_callback_csv_logger("training_log.csv")
    ),

    verbose = TRUE
  )

# Save final model
luz_save(fitted, "audio_classifier_final.pt")
```

---

## 6. Evaluation

```r
library(yardstick)

# Evaluate on test set
evaluate_model <- function(model, test_dl) {
  model$eval()

  all_preds <- list()
  all_labels <- list()
  all_probs <- list()

  with_no_grad({
    coro::loop(for (batch in test_dl) {
      logits <- model(batch$x)
      probs <- nnf_softmax(logits, dim = 2)
      preds <- torch_argmax(logits, dim = 2)

      all_preds[[length(all_preds) + 1]] <- as.integer(preds$cpu())
      all_labels[[length(all_labels) + 1]] <- as.integer(batch$y$cpu())
      all_probs[[length(all_probs) + 1]] <- as.matrix(probs$cpu())
    })
  })

  predictions <- unlist(all_preds)
  labels <- unlist(all_labels)
  probs <- do.call(rbind, all_probs)

  # Create results dataframe
  results <- tibble(
    truth = factor(labels),
    estimate = factor(predictions)
  )

  # Overall metrics
  overall_metrics <- results |>
    metrics(truth, estimate)

  # Confusion matrix
  conf_mat <- results |>
    conf_mat(truth, estimate)

  # Per-class metrics
  class_metrics <- results |>
    group_by(truth) |>
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
    per_class = class_metrics,
    predictions = predictions,
    labels = labels,
    probabilities = probs
  ))
}

# Run evaluation
eval_results <- evaluate_model(fitted$model, test_dl)

print("Overall Metrics:")
print(eval_results$overall)

print("\nPer-Class Metrics:")
print(eval_results$per_class)

print("\nConfusion Matrix:")
print(eval_results$confusion_matrix)

# Plot confusion matrix
library(ggplot2)
autoplot(eval_results$confusion_matrix, type = "heatmap") +
  scale_fill_gradient(low = "white", high = "steelblue") +
  theme_minimal() +
  labs(title = "Confusion Matrix - Audio Classification")
```

---

## 7. Inference on Continuous Audio

For real-world deployment, process long audio files with sliding windows.

```r
# Predict on continuous audio stream
predict_continuous_audio <- function(model, audio_path,
                                    window_sec = 5,
                                    hop_sec = 2.5,
                                    sample_rate = 22050,
                                    n_mels = 128,
                                    threshold = 0.5) {

  # Load audio
  audio <- readWave(audio_path)

  if (audio@stereo) {
    audio <- mono(audio)
  }

  if (audio@samp.rate != sample_rate) {
    audio <- resample(audio, sample_rate, orig.freq = audio@samp.rate)
  }

  signal <- normalize(audio, unit = "1")@left

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

  # Process each window
  model$eval()
  predictions <- list()
  timestamps <- numeric(n_windows)

  with_no_grad({
    for (i in 1:n_windows) {
      start_idx <- (i - 1) * hop_samples + 1
      end_idx <- start_idx + window_samples - 1
      window <- signal[start_idx:end_idx]

      # Preprocess
      waveform <- torch_tensor(window)$unsqueeze(1)
      mel_spec <- mel_transform(waveform)
      log_mel <- torch_log1p(mel_spec)
      log_mel <- (log_mel - log_mel$mean()) / (log_mel$std() + 1e-8)
      log_mel <- log_mel$unsqueeze(1)$unsqueeze(1)  # Add batch and channel

      # Predict
      logits <- model(log_mel)
      probs <- nnf_softmax(logits, dim = 2)

      predictions[[i]] <- as.numeric(probs$cpu())
      timestamps[i] <- start_idx / sample_rate
    }
  })

  # Create results dataframe
  pred_matrix <- do.call(rbind, predictions)
  colnames(pred_matrix) <- paste0("prob_", 0:(ncol(pred_matrix) - 1))

  results <- data.frame(
    timestamp = timestamps,
    pred_matrix
  ) |>
    mutate(
      max_prob = apply(select(., starts_with("prob_")), 1, max),
      predicted_class = apply(select(., starts_with("prob_")), 1, which.max) - 1
    )

  return(results)
}

# Usage
predictions <- predict_continuous_audio(
  model = fitted$model,
  audio_path = "long_recording.wav",
  window_sec = 5,
  hop_sec = 2.5  # 50% overlap
)

# Filter high-confidence detections
detections <- predictions |>
  filter(max_prob > 0.7)

print(head(detections))
```

---

## 8. Temporal Smoothing

Apply post-processing to reduce false positives in continuous predictions.

```r
# Moving average smoothing
smooth_predictions <- function(predictions, window_size = 3) {
  prob_cols <- grep("^prob_", names(predictions), value = TRUE)

  smoothed <- predictions
  for (col in prob_cols) {
    smoothed[[col]] <- zoo::rollmean(
      predictions[[col]],
      k = window_size,
      fill = "extend",
      align = "center"
    )
  }

  # Recalculate predicted class
  smoothed <- smoothed |>
    mutate(
      max_prob = apply(select(., starts_with("prob_")), 1, max),
      predicted_class = apply(select(., starts_with("prob_")), 1, which.max) - 1
    )

  return(smoothed)
}

# Apply smoothing
smoothed_preds <- smooth_predictions(predictions, window_size = 5)

# Visualize predictions over time
library(ggplot2)
library(tidyr)

plot_data <- smoothed_preds |>
  select(timestamp, starts_with("prob_")) |>
  pivot_longer(cols = starts_with("prob_"),
               names_to = "class",
               values_to = "probability") |>
  mutate(class = gsub("prob_", "", class))

ggplot(plot_data, aes(x = timestamp, y = probability, color = class)) +
  geom_line() +
  theme_minimal() +
  labs(
    title = "Audio Classification Over Time",
    x = "Time (seconds)",
    y = "Probability",
    color = "Species"
  )
```

---

## Best Practices

### Preprocessing
- **Sample rate**: 22050 Hz for birds/music, 16000 Hz for speech
- **Duration**: 5 seconds typical for short clips
- **Normalization**: Per-example normalization after log-scaling
- **Frequency range**: Set `f_min` and `f_max` based on target species

### Model Architecture
- Start with 4 convolutional blocks
- Use batch normalization after each conv layer
- Global average pooling reduces overfitting vs. flatten
- Dropout 0.3-0.5 before classifier

### Training
- Use class weights or focal loss for imbalance
- Learning rate 0.001 with ReduceLROnPlateau
- Early stopping with patience 10
- Data augmentation: SpecAugment essential

### Inference
- Use sliding windows with 50% overlap for continuous audio
- Apply temporal smoothing (moving average) to reduce noise
- Set species-specific confidence thresholds

---

## Common Issues

**Issue**: Model overfits quickly
**Solution**: Increase dropout, add more augmentation, reduce model size

**Issue**: Low recall on rare species
**Solution**: Use focal loss with high gamma (2.0-3.0), or oversample rare classes

**Issue**: Many false positives in continuous audio
**Solution**: Increase confidence threshold, apply temporal smoothing, use longer smoothing windows

**Issue**: GPU out of memory
**Solution**: Reduce batch size, use gradient accumulation, or use mixed precision training

---

## References

See also:
- [references/architectures.md](../references/architectures.md) - CNN and CRNN architectures
- [references/audio-dl-best-practices.md](../references/audio-dl-best-practices.md) - Audio deep learning guidelines
- [templates/audio-dataset.R](../templates/audio-dataset.R) - Dataset template
- [templates/training-recipes.R](../templates/training-recipes.R) - Training patterns
