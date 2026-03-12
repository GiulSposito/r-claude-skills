# Audio Dataset and Dataloader Template
# Customizable torch dataset for audio classification

library(torch)
library(torchaudio)
library(tuneR)

# =============================================================================
# Complete Audio Classification Dataset
# =============================================================================

audio_classification_dataset <- dataset(
  name = "AudioClassificationDataset",

  # -------------------------------------------------------------------------
  # Initialization
  # -------------------------------------------------------------------------
  initialize = function(metadata_df,
                       audio_dir,
                       target_sr = 22050,
                       duration_sec = 5,
                       n_mels = 128,
                       n_fft = 2048,
                       hop_length = 512,
                       f_min = 500,
                       f_max = 12000,
                       augment = FALSE,
                       augment_prob = 0.5,
                       cache_spectrograms = FALSE) {

    # Store parameters
    self$metadata <- metadata_df  # Should have: filename, label_id
    self$audio_dir <- audio_dir
    self$target_sr <- target_sr
    self$duration_sec <- duration_sec
    self$target_length <- target_sr * duration_sec
    self$n_mels <- n_mels
    self$augment <- augment
    self$augment_prob <- augment_prob
    self$cache_spectrograms <- cache_spectrograms

    # Cache for spectrograms (if enabled)
    if (cache_spectrograms) {
      self$cache <- list()
    }

    # Create mel-spectrogram transform
    self$mel_transform <- transform_mel_spectrogram(
      sample_rate = target_sr,
      n_fft = n_fft,
      hop_length = hop_length,
      n_mels = n_mels,
      f_min = f_min,
      f_max = f_max
    )

    cat(sprintf(
      "Dataset initialized: %d samples, SR=%d, duration=%ds, n_mels=%d, augment=%s\n",
      nrow(metadata_df), target_sr, duration_sec, n_mels, augment
    ))
  },

  # -------------------------------------------------------------------------
  # Get Item (core method)
  # -------------------------------------------------------------------------
  .getitem = function(index) {
    # Get metadata
    row <- self$metadata[index, ]
    audio_path <- file.path(self$audio_dir, row$filename)

    # Check cache
    if (self$cache_spectrograms && !is.null(self$cache[[as.character(index)]])) {
      log_mel <- self$cache[[as.character(index)]]
    } else {
      # Load and preprocess audio
      log_mel <- self$load_and_preprocess(audio_path)

      # Cache if enabled
      if (self$cache_spectrograms) {
        self$cache[[as.character(index)]] <- log_mel
      }
    }

    # Apply augmentation
    if (self$augment && runif(1) < self$augment_prob) {
      log_mel <- self$augment_spectrogram(log_mel)
    }

    # Add channel dimension for CNN
    log_mel <- log_mel$unsqueeze(1)  # (1, n_mels, n_frames)

    # Get label
    label <- torch_tensor(row$label_id, dtype = torch_long())

    return(list(x = log_mel, y = label))
  },

  # -------------------------------------------------------------------------
  # Length
  # -------------------------------------------------------------------------
  .length = function() {
    nrow(self$metadata)
  },

  # -------------------------------------------------------------------------
  # Load and Preprocess Audio
  # -------------------------------------------------------------------------
  load_and_preprocess = function(audio_path) {
    # 1. Load audio
    audio <- readWave(audio_path)

    # 2. Convert to mono
    if (audio@stereo) {
      audio <- mono(audio, which = "both")
    }

    # 3. Resample to target sample rate
    if (audio@samp.rate != self$target_sr) {
      audio <- resample(audio, self$target_sr, orig.freq = audio@samp.rate)
    }

    # 4. Normalize (peak normalization)
    audio <- normalize(audio, unit = "1")

    # 5. Handle duration (pad or crop)
    signal <- audio@left

    if (length(signal) < self$target_length) {
      # Pad with zeros
      padding <- rep(0, self$target_length - length(signal))
      signal <- c(signal, padding)
    } else if (length(signal) > self$target_length) {
      if (self$augment) {
        # Random crop (augmentation)
        start_idx <- sample(1:(length(signal) - self$target_length + 1), 1)
      } else {
        # Center crop (evaluation)
        start_idx <- (length(signal) - self$target_length) %/% 2 + 1
      }
      signal <- signal[start_idx:(start_idx + self$target_length - 1)]
    }

    # 6. Convert to tensor
    waveform <- torch_tensor(signal)$unsqueeze(1)  # Add channel dim

    # 7. Compute mel-spectrogram
    mel_spec <- self$mel_transform(waveform)

    # 8. Log scaling
    log_mel <- torch_log1p(mel_spec)  # log(x + 1)

    # 9. Per-example normalization
    mean_val <- torch_mean(log_mel)
    std_val <- torch_std(log_mel)
    log_mel <- (log_mel - mean_val) / (std_val + 1e-8)

    return(log_mel)  # (n_mels, n_frames)
  },

  # -------------------------------------------------------------------------
  # Augmentation: SpecAugment
  # -------------------------------------------------------------------------
  augment_spectrogram = function(spec, freq_mask_param = 15, time_mask_param = 20) {
    n_mels <- spec$shape[1]
    n_frames <- spec$shape[2]

    # Frequency masking
    if (n_mels > freq_mask_param) {
      f <- sample(0:freq_mask_param, 1)
      if (f > 0) {
        f0 <- sample(0:(n_mels - f), 1)
        spec[(f0 + 1):(f0 + f), ] <- 0
      }
    }

    # Time masking
    if (n_frames > time_mask_param) {
      t <- sample(0:time_mask_param, 1)
      if (t > 0) {
        t0 <- sample(0:(n_frames - t), 1)
        spec[, (t0 + 1):(t0 + t)] <- 0
      }
    }

    return(spec)
  }
)


# =============================================================================
# Usage Example
# =============================================================================

# Prepare metadata
metadata <- data.frame(
  filename = c("audio1.wav", "audio2.wav", "audio3.wav"),
  label_id = c(0L, 1L, 0L)
)

# Create dataset
train_ds <- audio_classification_dataset(
  metadata_df = metadata,
  audio_dir = "data/audio/",
  target_sr = 22050,
  duration_sec = 5,
  n_mels = 128,
  augment = TRUE,
  cache_spectrograms = FALSE  # Set TRUE if dataset fits in memory
)

# Create dataloader
train_dl <- dataloader(
  train_ds,
  batch_size = 16,
  shuffle = TRUE,
  num_workers = 4,  # Parallel data loading
  pin_memory = TRUE  # Speed up GPU transfer
)

# Test
batch <- train_dl$.iter()$.next()
cat("Batch shape:", batch$x$shape, "\n")    # [16, 1, 128, 216]
cat("Labels shape:", batch$y$shape, "\n")   # [16]


# =============================================================================
# Multi-Label Audio Dataset
# =============================================================================

multilabel_audio_dataset <- dataset(
  name = "MultiLabelAudioDataset",

  initialize = function(metadata_df,
                       audio_dir,
                       label_columns,  # Vector of column names containing labels
                       target_sr = 22050,
                       duration_sec = 5,
                       n_mels = 128,
                       n_fft = 2048,
                       hop_length = 512,
                       f_min = 500,
                       f_max = 12000,
                       augment = FALSE) {

    self$metadata <- metadata_df
    self$audio_dir <- audio_dir
    self$label_columns <- label_columns
    self$n_classes <- length(label_columns)
    self$target_sr <- target_sr
    self$duration_sec <- duration_sec
    self$target_length <- target_sr * duration_sec
    self$n_mels <- n_mels
    self$augment <- augment

    # Mel transform
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
    row <- self$metadata[index, ]
    audio_path <- file.path(self$audio_dir, row$filename)

    # Preprocess (same as single-label)
    log_mel <- self$load_and_preprocess(audio_path)

    # Augmentation
    if (self$augment && runif(1) > 0.5) {
      log_mel <- self$augment_spectrogram(log_mel)
    }

    # Add channel
    log_mel <- log_mel$unsqueeze(1)

    # Multi-label target (binary vector)
    labels <- as.numeric(row[self$label_columns])
    label_tensor <- torch_tensor(labels, dtype = torch_float())

    return(list(x = log_mel, y = label_tensor))
  },

  .length = function() {
    nrow(self$metadata)
  },

  # Reuse methods from single-label dataset
  load_and_preprocess = audio_classification_dataset$public_methods$load_and_preprocess,
  augment_spectrogram = audio_classification_dataset$public_methods$augment_spectrogram
)


# =============================================================================
# Raw Waveform Dataset (for 1D CNN)
# =============================================================================

waveform_dataset <- dataset(
  name = "WaveformDataset",

  initialize = function(metadata_df,
                       audio_dir,
                       target_sr = 22050,
                       duration_sec = 5,
                       augment = FALSE) {

    self$metadata <- metadata_df
    self$audio_dir <- audio_dir
    self$target_sr <- target_sr
    self$duration_sec <- duration_sec
    self$target_length <- target_sr * duration_sec
    self$augment <- augment
  },

  .getitem = function(index) {
    row <- self$metadata[index, ]
    audio_path <- file.path(self$audio_dir, row$filename)

    # Load audio
    audio <- readWave(audio_path)

    # Convert to mono
    if (audio@stereo) {
      audio <- mono(audio)
    }

    # Resample
    if (audio@samp.rate != self$target_sr) {
      audio <- resample(audio, self$target_sr, orig.freq = audio@samp.rate)
    }

    # Normalize
    audio <- normalize(audio, unit = "1")

    # Pad or crop
    signal <- audio@left

    if (length(signal) < self$target_length) {
      signal <- c(signal, rep(0, self$target_length - length(signal)))
    } else if (length(signal) > self$target_length) {
      if (self$augment) {
        start_idx <- sample(1:(length(signal) - self$target_length + 1), 1)
      } else {
        start_idx <- (length(signal) - self$target_length) %/% 2 + 1
      }
      signal <- signal[start_idx:(start_idx + self$target_length - 1)]
    }

    # Convert to tensor: (1, length) for 1D CNN
    waveform <- torch_tensor(signal)$unsqueeze(1)

    # Normalize
    waveform <- (waveform - waveform$mean()) / (waveform$std() + 1e-8)

    # Label
    label <- torch_tensor(row$label_id, dtype = torch_long())

    return(list(x = waveform, y = label))
  },

  .length = function() {
    nrow(self$metadata)
  }
)


# =============================================================================
# Advanced Augmentation Functions
# =============================================================================

# Mixup augmentation (apply at batch level)
mixup_batch <- function(batch_x, batch_y, alpha = 0.4) {
  batch_size <- batch_x$shape[1]

  # Sample lambda from Beta distribution
  lambda <- rbeta(1, alpha, alpha)

  # Random permutation of batch
  indices <- torch_randperm(batch_size) + 1L

  # Mix inputs and labels
  mixed_x <- lambda * batch_x + (1 - lambda) * batch_x[indices]
  mixed_y <- lambda * batch_y + (1 - lambda) * batch_y[indices]

  return(list(x = mixed_x, y = mixed_y))
}

# Time stretching (requires torchaudio)
time_stretch_augment <- function(spec, rate_range = c(0.8, 1.2)) {
  rate <- runif(1, rate_range[1], rate_range[2])

  time_stretch_fn <- transform_time_stretch(
    hop_length = 512,
    n_freq = spec$shape[1]
  )

  stretched <- time_stretch_fn(spec, rate)
  return(stretched)
}

# Pitch shifting
pitch_shift_augment <- function(spec, max_shift = 5) {
  n_mels <- spec$shape[1]
  n_frames <- spec$shape[2]

  shift_bins <- sample(-max_shift:max_shift, 1)

  if (shift_bins > 0) {
    # Shift up
    shifted <- torch_cat(
      list(spec[(shift_bins + 1):n_mels, ], torch_zeros(shift_bins, n_frames)),
      dim = 1
    )
  } else if (shift_bins < 0) {
    # Shift down
    shifted <- torch_cat(
      list(torch_zeros(-shift_bins, n_frames), spec[1:(n_mels + shift_bins), ]),
      dim = 1
    )
  } else {
    shifted <- spec
  }

  return(shifted)
}

# Background noise addition
add_background_noise <- function(waveform, noise_waveform, snr_db = 10) {
  # Ensure same length
  target_length <- waveform$shape[2]

  if (noise_waveform$shape[2] > target_length) {
    # Crop noise
    start_idx <- sample(1:(noise_waveform$shape[2] - target_length + 1), 1)
    noise_waveform <- noise_waveform[, start_idx:(start_idx + target_length - 1)]
  } else if (noise_waveform$shape[2] < target_length) {
    # Repeat noise
    repeats <- ceiling(target_length / noise_waveform$shape[2])
    noise_waveform <- torch_cat(rep(list(noise_waveform), repeats), dim = 2)
    noise_waveform <- noise_waveform[, 1:target_length]
  }

  # Calculate signal and noise power
  signal_power <- torch_mean(waveform^2)
  noise_power <- torch_mean(noise_waveform^2)

  # Scale noise to achieve desired SNR
  snr_linear <- 10^(snr_db / 10)
  noise_scaled <- noise_waveform * torch_sqrt(signal_power / (snr_linear * noise_power + 1e-8))

  # Mix signal and noise
  augmented <- waveform + noise_scaled

  return(augmented)
}


# =============================================================================
# Custom Collate Function (for variable-length sequences)
# =============================================================================

# Pad sequences to same length in batch
collate_pad_sequences <- function(batch) {
  # Extract inputs and labels
  inputs <- lapply(batch, function(x) x$x)
  labels <- lapply(batch, function(x) x$y)

  # Find max length
  max_len <- max(sapply(inputs, function(x) x$shape[2]))

  # Pad sequences
  padded_inputs <- lapply(inputs, function(x) {
    pad_size <- max_len - x$shape[2]
    if (pad_size > 0) {
      padding <- torch_zeros(x$shape[1], pad_size)
      x <- torch_cat(list(x, padding), dim = 2)
    }
    return(x)
  })

  # Stack into batch
  batch_x <- torch_stack(padded_inputs)
  batch_y <- torch_stack(labels)

  return(list(x = batch_x, y = batch_y))
}

# Usage with dataloader
# train_dl <- dataloader(train_ds, batch_size = 16, collate_fn = collate_pad_sequences)


# =============================================================================
# Efficient Data Loading Tips
# =============================================================================

# 1. Use multiple workers for parallel loading
#    train_dl <- dataloader(train_ds, num_workers = 4)

# 2. Pin memory for faster GPU transfer
#    train_dl <- dataloader(train_ds, pin_memory = TRUE)

# 3. Cache preprocessed spectrograms if dataset fits in memory
#    train_ds <- audio_classification_dataset(..., cache_spectrograms = TRUE)

# 4. Prefetch next batch while training current batch (automatic with num_workers > 0)

# 5. Use persistent workers (requires torch >= 0.10)
#    train_dl <- dataloader(train_ds, num_workers = 4, persistent_workers = TRUE)

# 6. For very large datasets, consider:
#    - Preprocessing to save spectrograms to disk
#    - Loading preprocessed spectrograms instead of raw audio
#    - Using memory-mapped files for large arrays


# =============================================================================
# Validation and Testing
# =============================================================================

# Test dataset
test_dataset <- function(dataset, n_samples = 3) {
  cat("Testing dataset...\n")

  for (i in 1:n_samples) {
    tryCatch({
      item <- dataset$.getitem(i)

      cat(sprintf(
        "Sample %d: x shape = %s, y = %s\n",
        i,
        paste(item$x$shape, collapse = "x"),
        as.numeric(item$y)
      ))

      # Check for NaN/Inf
      if (torch_any(torch_isnan(item$x))$item()) {
        cat("  WARNING: NaN detected in input\n")
      }
      if (torch_any(torch_isinf(item$x))$item()) {
        cat("  WARNING: Inf detected in input\n")
      }

    }, error = function(e) {
      cat(sprintf("ERROR in sample %d: %s\n", i, e$message))
    })
  }

  cat("Dataset test complete\n")
}

# Test dataloader
test_dataloader <- function(dataloader) {
  cat("Testing dataloader...\n")

  batch <- dataloader$.iter()$.next()

  cat(sprintf(
    "Batch: x shape = %s, y shape = %s\n",
    paste(batch$x$shape, collapse = "x"),
    paste(batch$y$shape, collapse = "x")
  ))

  cat("Dataloader test complete\n")
}

# Usage
# test_dataset(train_ds, n_samples = 5)
# test_dataloader(train_dl)
