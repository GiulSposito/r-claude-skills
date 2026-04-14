# Keras3-Native Audio Classification

This guide demonstrates Keras3-native audio preprocessing and classification using built-in audio layers. This approach differs from the torch-based r-audio-multiclass skill by using Keras3 preprocessing layers natively.

## Key Difference from r-audio-multiclass

**r-audio-multiclass**: Uses torch for audio processing with torchaudio transforms
**keras3 audio** (this guide): Uses keras3 built-in audio preprocessing layers

Both are valid approaches - choose based on your deep learning backend preference.

## Keras3 Audio Preprocessing Layers

Keras3 provides native audio preprocessing layers that work with all backends (JAX, TensorFlow, PyTorch).

```r
library(keras3)

# Available audio layers:
# - layer_mel_spectrogram(): Convert audio to mel-scale spectrogram
# - layer_stft_spectrogram(): Short-Time Fourier Transform spectrogram
# - layer_random_crop_1d(): Audio augmentation
# - layer_random_frequency_masking(): Frequency masking augmentation
# - layer_random_time_masking(): Time masking augmentation
```

## Audio Loading and Preprocessing Pipeline

Complete pipeline from audio files to features.

```r
library(keras3)
library(tuneR)  # For loading audio files

# Load audio file
load_audio <- function(file_path, target_sr = 16000) {
  # Read audio file
  audio <- readWave(file_path)

  # Resample if necessary
  if (audio@samp.rate != target_sr) {
    audio <- resample(audio, target_sr, audio@samp.rate)
  }

  # Convert to mono if stereo
  if (audio@stereo) {
    audio <- mono(audio, which = "both")
  }

  # Normalize to [-1, 1]
  waveform <- audio@left / 2^(audio@bit - 1)

  # Return as array
  return(array(waveform, dim = c(1, length(waveform))))
}

# Example: Load multiple audio files
audio_files <- list.files("audio_dataset/", pattern = "\\.wav$", full.names = TRUE)
labels <- c("bird", "frog", "bird", "frog")  # Example labels

# Load all audio
audio_data <- lapply(audio_files, load_audio)
audio_data <- do.call(rbind, audio_data)
```

## Mel-Spectrogram Configuration

Convert raw audio to mel-spectrograms using keras3 layers.

```r
# Create mel-spectrogram preprocessing layer
create_mel_layer <- function(
  sample_rate = 16000,
  fft_length = 512,
  frame_step = 256,
  n_mels = 128,
  fmin = 0,
  fmax = 8000
) {
  layer_mel_spectrogram(
    fft_length = fft_length,
    sequence_stride = frame_step,
    num_mel_bins = n_mels,
    sampling_rate = sample_rate,
    lower_edge_hertz = fmin,
    upper_edge_hertz = fmax,
    log_scale = TRUE  # Apply log scaling for better representation
  )
}

# Example usage in model
input <- keras_input(shape = c(NULL), dtype = "float32", name = "audio")

# Convert to mel-spectrogram
mel_spec <- input |>
  create_mel_layer(
    sample_rate = 16000,
    fft_length = 1024,
    frame_step = 512,
    n_mels = 128
  )

# mel_spec shape: (batch, time_steps, n_mels)
```

## STFT Spectrogram Alternative

Use Short-Time Fourier Transform for frequency analysis.

```r
# STFT spectrogram layer
input <- keras_input(shape = c(NULL), dtype = "float32", name = "audio")

stft_spec <- input |>
  layer_stft_spectrogram(
    fft_length = 512,
    sequence_stride = 256,
    output_magnitude = TRUE  # Return magnitude instead of complex values
  )

# Apply log scaling manually
log_spec <- stft_spec |>
  layer_lambda(function(x) keras3::k_log(x + 1e-6))

# log_spec shape: (batch, time_steps, fft_length/2 + 1)
```

## Audio Augmentation with Keras3

Time and frequency masking for robust audio models.

```r
# Create augmentation pipeline
create_audio_augmentation <- function() {
  # Sequential augmentation layers
  keras_model_sequential() |>
    # Randomly mask time segments
    layer_random_time_masking(
      max_size = 10,      # Maximum number of time steps to mask
      num_masks = 2       # Number of masks to apply
    ) |>
    # Randomly mask frequency bands
    layer_random_frequency_masking(
      max_size = 10,      # Maximum number of frequency bins to mask
      num_masks = 2       # Number of masks to apply
    )
}

# Use in training pipeline
input <- keras_input(shape = c(NULL), dtype = "float32")

# Preprocessing
mel_spec <- input |>
  create_mel_layer()

# Apply augmentation only during training
augmented <- mel_spec |>
  create_audio_augmentation()

# Note: Augmentation layers automatically disable during inference
```

## Complete Audio Classification Model

End-to-end model for audio classification.

```r
library(keras3)

# Model parameters
sample_rate <- 16000
audio_length <- 3  # seconds
n_classes <- 10

# Build model
build_audio_classifier <- function(n_classes, sample_rate = 16000) {
  # Input: raw audio waveform
  input <- keras_input(
    shape = c(sample_rate * 3),  # 3 seconds at 16kHz
    dtype = "float32",
    name = "audio_input"
  )

  # Convert to mel-spectrogram
  mel_spec <- input |>
    layer_mel_spectrogram(
      fft_length = 1024,
      sequence_stride = 512,
      num_mel_bins = 128,
      sampling_rate = sample_rate,
      log_scale = TRUE
    )

  # Data augmentation (training only)
  augmented <- mel_spec |>
    layer_random_time_masking(max_size = 10, num_masks = 2) |>
    layer_random_frequency_masking(max_size = 10, num_masks = 2)

  # Add channel dimension for CNN
  # Shape: (batch, time, freq) -> (batch, time, freq, 1)
  expanded <- augmented |>
    layer_reshape(target_shape = c(-1, 128, 1))

  # CNN architecture
  output <- expanded |>
    # Block 1
    layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = "relu", padding = "same") |>
    layer_batch_normalization() |>
    layer_max_pooling_2d(pool_size = c(2, 2)) |>
    layer_dropout(rate = 0.25) |>

    # Block 2
    layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = "relu", padding = "same") |>
    layer_batch_normalization() |>
    layer_max_pooling_2d(pool_size = c(2, 2)) |>
    layer_dropout(rate = 0.25) |>

    # Block 3
    layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu", padding = "same") |>
    layer_batch_normalization() |>
    layer_global_average_pooling_2d() |>
    layer_dropout(rate = 0.5) |>

    # Classification head
    layer_dense(units = 256, activation = "relu") |>
    layer_dropout(rate = 0.3) |>
    layer_dense(units = n_classes, activation = "softmax")

  # Build model
  model <- keras_model(inputs = input, outputs = output)

  return(model)
}

# Create and compile model
model <- build_audio_classifier(n_classes = 10)

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "sparse_categorical_crossentropy",
  metrics = c("accuracy")
)

model
```

## RNN-based Audio Classification

Alternative architecture using recurrent layers.

```r
# RNN model for temporal audio patterns
build_rnn_audio_classifier <- function(n_classes, sample_rate = 16000) {
  input <- keras_input(
    shape = c(sample_rate * 3),
    dtype = "float32",
    name = "audio_input"
  )

  # Mel-spectrogram
  mel_spec <- input |>
    layer_mel_spectrogram(
      fft_length = 1024,
      sequence_stride = 512,
      num_mel_bins = 64,
      sampling_rate = sample_rate,
      log_scale = TRUE
    )

  # RNN for temporal modeling
  output <- mel_spec |>
    layer_lstm(units = 128, return_sequences = TRUE, dropout = 0.3) |>
    layer_lstm(units = 64, return_sequences = FALSE, dropout = 0.3) |>
    layer_dense(units = 128, activation = "relu") |>
    layer_dropout(rate = 0.4) |>
    layer_dense(units = n_classes, activation = "softmax")

  model <- keras_model(inputs = input, outputs = output)

  return(model)
}

# Compile
rnn_model <- build_rnn_audio_classifier(n_classes = 10)

rnn_model |> compile(
  optimizer = optimizer_adam(),
  loss = "sparse_categorical_crossentropy",
  metrics = c("accuracy")
)
```

## Complete Training Pipeline

From audio files to trained model.

```r
library(keras3)
library(tuneR)

# Data preparation function
prepare_audio_dataset <- function(audio_dir, target_sr = 16000, max_duration = 3) {
  # Get file list with labels
  files <- list.files(audio_dir, pattern = "\\.wav$", full.names = TRUE, recursive = TRUE)

  # Extract labels from directory structure (e.g., audio_dir/class_name/file.wav)
  labels <- basename(dirname(files))
  unique_labels <- unique(labels)
  label_map <- setNames(seq_along(unique_labels) - 1, unique_labels)

  # Load and preprocess audio
  audio_list <- list()
  label_list <- list()

  for (i in seq_along(files)) {
    tryCatch({
      # Load audio
      audio <- readWave(files[i])

      # Resample
      if (audio@samp.rate != target_sr) {
        audio <- resample(audio, target_sr, audio@samp.rate)
      }

      # Convert to mono
      if (audio@stereo) {
        audio <- mono(audio, which = "both")
      }

      # Normalize
      waveform <- audio@left / 2^(audio@bit - 1)

      # Pad or truncate to fixed length
      target_length <- target_sr * max_duration
      if (length(waveform) > target_length) {
        waveform <- waveform[1:target_length]
      } else {
        waveform <- c(waveform, rep(0, target_length - length(waveform)))
      }

      audio_list[[i]] <- waveform
      label_list[[i]] <- label_map[labels[i]]
    }, error = function(e) {
      warning(sprintf("Failed to load %s: %s", files[i], e$message))
    })
  }

  # Convert to arrays
  audio_array <- do.call(rbind, audio_list)
  labels_array <- unlist(label_list)

  return(list(
    audio = audio_array,
    labels = labels_array,
    label_names = unique_labels
  ))
}

# Prepare data
dataset <- prepare_audio_dataset("path/to/audio_dataset/", target_sr = 16000, max_duration = 3)

# Split into train/validation
set.seed(42)
n_samples <- nrow(dataset$audio)
train_idx <- sample(n_samples, size = floor(0.8 * n_samples))
val_idx <- setdiff(1:n_samples, train_idx)

train_audio <- dataset$audio[train_idx, ]
train_labels <- dataset$labels[train_idx]
val_audio <- dataset$audio[val_idx, ]
val_labels <- dataset$labels[val_idx]

# Build model
model <- build_audio_classifier(
  n_classes = length(dataset$label_names),
  sample_rate = 16000
)

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "sparse_categorical_crossentropy",
  metrics = c("accuracy")
)

# Callbacks
callbacks <- list(
  callback_early_stopping(
    monitor = "val_loss",
    patience = 10,
    restore_best_weights = TRUE
  ),
  callback_reduce_lr_on_plateau(
    monitor = "val_loss",
    factor = 0.5,
    patience = 5,
    min_lr = 1e-7
  )
)

# Train
history <- model |> fit(
  x = train_audio,
  y = train_labels,
  validation_data = list(val_audio, val_labels),
  epochs = 50,
  batch_size = 32,
  callbacks = callbacks,
  verbose = 1
)

# Evaluate
results <- model |> evaluate(val_audio, val_labels)
cat(sprintf("Validation accuracy: %.2f%%\n", results["accuracy"] * 100))
```

## Predictions on New Audio

Inference workflow for new audio files.

```r
# Predict on new audio
predict_audio <- function(model, audio_file, sample_rate = 16000, label_names) {
  # Load and preprocess
  audio <- readWave(audio_file)

  if (audio@samp.rate != sample_rate) {
    audio <- resample(audio, sample_rate, audio@samp.rate)
  }

  if (audio@stereo) {
    audio <- mono(audio, which = "both")
  }

  waveform <- audio@left / 2^(audio@bit - 1)

  # Pad/truncate to 3 seconds
  target_length <- sample_rate * 3
  if (length(waveform) > target_length) {
    waveform <- waveform[1:target_length]
  } else {
    waveform <- c(waveform, rep(0, target_length - length(waveform)))
  }

  # Add batch dimension
  waveform <- array(waveform, dim = c(1, length(waveform)))

  # Predict
  predictions <- model |> predict(waveform)

  # Get top prediction
  pred_class <- which.max(predictions[1, ]) - 1
  confidence <- max(predictions[1, ])

  return(list(
    class = label_names[pred_class + 1],
    confidence = confidence,
    all_probs = predictions[1, ]
  ))
}

# Example
result <- predict_audio(model, "test_audio.wav", label_names = dataset$label_names)
cat(sprintf("Prediction: %s (%.2f%% confidence)\n",
            result$class, result$confidence * 100))
```

## Best Practices

1. **Sample Rate**: Use consistent sample rate (16kHz is common)
2. **Audio Length**: Pad/truncate to fixed length for batching
3. **Normalization**: Normalize waveforms to [-1, 1]
4. **Augmentation**: Use time/frequency masking for robustness
5. **Log Scaling**: Apply log to spectrograms for better range
6. **Callbacks**: Use early stopping and learning rate scheduling
7. **Validation**: Monitor validation metrics to prevent overfitting

## Comparison with r-audio-multiclass

| Feature | keras3 (this guide) | r-audio-multiclass |
|---------|---------------------|---------------------|
| Backend | Keras3 (JAX/TF/PyTorch) | PyTorch (torch) |
| Audio Layers | layer_mel_spectrogram() | torchaudio transforms |
| Multi-label | Manual implementation | Built-in BCEWithLogitsLoss |
| Preprocessing | Keras preprocessing | torch preprocessing |
| Best for | Keras ecosystem | PyTorch ecosystem |

**Use keras3** when:
- Working with Keras models
- Want backend flexibility (JAX, TensorFlow, PyTorch)
- Prefer Keras API

**Use r-audio-multiclass** when:
- Need multi-label classification
- Working with PyTorch models
- Want torch ecosystem integration

## Related Resources

- See main SKILL.md for Keras3 basics
- Reference functional-api-advanced.md for complex model architectures
- Check r-audio-multiclass skill for torch-based audio classification
- See r-bioacoustics skill for traditional acoustic analysis
