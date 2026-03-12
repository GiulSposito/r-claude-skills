# Deep Learning Patterns for Audio Classification and Analysis

Comprehensive guide to deep learning approaches for audio tasks, with focus on R implementations using {torch}, {torchaudio}, and {keras3}.

---

## Audio Preprocessing for Deep Learning

### Standard Preprocessing Pipeline

**1. Audio Loading and Resampling**
```r
# Using tuneR
library(tuneR)
audio <- readWave("audio.wav")

# Resample to standard rate (e.g., 22050 Hz or 16000 Hz)
target_sr <- 22050
if (audio@samp.rate != target_sr) {
  audio <- resample(audio, target_sr, orig.freq = audio@samp.rate)
}
```

**2. Mono Conversion**
```r
# Convert stereo to mono
if (audio@stereo) {
  audio <- mono(audio, which = "both")  # Average both channels
}
```

**3. Normalization**
```r
# Peak normalization
audio <- normalize(audio, unit = "1")

# RMS normalization (preferred for ML)
rms <- sqrt(mean(audio@left^2))
audio@left <- audio@left / (rms * sqrt(2))

# Z-score normalization per file
audio@left <- scale(audio@left)
```

**4. Duration Handling**
```r
# Pad or truncate to fixed length
target_length <- target_sr * duration_seconds

pad_or_truncate <- function(audio, target_length) {
  current_length <- length(audio@left)

  if (current_length < target_length) {
    # Pad with zeros
    padding <- rep(0, target_length - current_length)
    audio@left <- c(audio@left, padding)
  } else if (current_length > target_length) {
    # Truncate
    audio@left <- audio@left[1:target_length]
  }

  return(audio)
}
```

**5. Windowing for Continuous Audio**
```r
# Create overlapping windows
create_windows <- function(audio, window_sec = 5, hop_sec = 2.5) {
  sr <- audio@samp.rate
  window_samples <- sr * window_sec
  hop_samples <- sr * hop_sec

  signal <- audio@left
  n_windows <- floor((length(signal) - window_samples) / hop_samples) + 1

  windows <- list()
  for (i in 0:(n_windows - 1)) {
    start_idx <- i * hop_samples + 1
    end_idx <- start_idx + window_samples - 1
    windows[[i + 1]] <- signal[start_idx:end_idx]
  }

  return(windows)
}
```

**Key Parameters:**
- **Sample Rate**: 22050 Hz (music), 16000 Hz (speech), 44100 Hz (high quality)
- **Window Length**: 2-5 seconds for bioacoustics, 3-10 seconds for soundscapes
- **Hop Length**: 50% overlap (window_length / 2) is standard
- **Bit Depth**: 16-bit is sufficient for most ML tasks

---

## Spectrogram Representations

### 1. Short-Time Fourier Transform (STFT)

**Concept**: Transforms audio from time domain to time-frequency representation.

```r
# Using torch/torchaudio
library(torch)
library(torchaudio)

# Create STFT spectrogram
compute_stft <- function(waveform, n_fft = 2048, hop_length = 512,
                         win_length = 2048) {

  spectrogram <- transform_spectrogram(
    n_fft = n_fft,
    hop_length = hop_length,
    win_length = win_length,
    power = 2  # Power spectrogram
  )

  spec <- spectrogram(waveform)
  return(spec)
}
```

**Parameters:**
- **n_fft**: FFT size (1024, 2048, 4096) - higher = better frequency resolution
- **hop_length**: Step size (512 typical) - smaller = better time resolution
- **win_length**: Window size (usually = n_fft)
- **window**: Hann window is standard

**Trade-offs:**
- Large n_fft: good frequency resolution, poor time resolution
- Small n_fft: good time resolution, poor frequency resolution
- For birds: n_fft=2048, hop=512 works well

### 2. Mel-Spectrogram

**Concept**: Applies mel-scale filter banks to STFT, mimicking human auditory perception.

```r
# Using torchaudio
compute_melspec <- function(waveform, sample_rate = 22050,
                           n_mels = 128, n_fft = 2048,
                           hop_length = 512) {

  mel_spec <- transform_mel_spectrogram(
    sample_rate = sample_rate,
    n_fft = n_fft,
    hop_length = hop_length,
    n_mels = n_mels,
    f_min = 0,
    f_max = sample_rate / 2
  )

  mel <- mel_spec(waveform)
  return(mel)
}
```

**Parameters:**
- **n_mels**: Number of mel bands (64, 128, 256) - 128 is most common
- **f_min**: Minimum frequency (0 Hz or higher to exclude low freq noise)
- **f_max**: Maximum frequency (Nyquist = sr/2, or lower if species-specific)

**For Bioacoustics:**
```r
# Bird vocalizations: 1-12 kHz typically
bird_melspec <- transform_mel_spectrogram(
  sample_rate = 22050,
  n_fft = 2048,
  hop_length = 512,
  n_mels = 128,
  f_min = 500,    # Exclude very low frequencies
  f_max = 12000   # Birds rarely above 12 kHz
)

# Anurans: 100-5000 Hz typically
frog_melspec <- transform_mel_spectrogram(
  sample_rate = 22050,
  n_fft = 2048,
  hop_length = 512,
  n_mels = 128,
  f_min = 50,
  f_max = 5000
)
```

### 3. Log-Mel Spectrogram

**Most common for deep learning**: Applies log compression to mel-spectrogram.

```r
# Log scaling
log_mel <- function(mel_spec, top_db = 80) {
  # Convert to decibels
  db_spec <- transform_amplitude_to_db(
    stype = "power",
    top_db = top_db
  )

  log_mel <- db_spec(mel_spec)
  return(log_mel)
}

# Alternative: log(1 + mel_spec)
log_mel_alt <- torch_log1p(mel_spec)
```

**Why log-scale?**
- Human hearing is logarithmic
- Compresses dynamic range
- Makes quiet sounds more visible
- Stabilizes training

### 4. MFCC (Mel-Frequency Cepstral Coefficients)

**Concept**: Further compression of mel-spectrogram via DCT, captures spectral envelope.

```r
# Using torchaudio
compute_mfcc <- function(waveform, sample_rate = 22050, n_mfcc = 40) {
  mfcc_transform <- transform_mfcc(
    sample_rate = sample_rate,
    n_mfcc = n_mfcc,
    log_mels = TRUE,
    melkwargs = list(
      n_fft = 2048,
      hop_length = 512,
      n_mels = 128
    )
  )

  mfcc <- mfcc_transform(waveform)
  return(mfcc)
}

# Include deltas (velocity)
compute_mfcc_deltas <- function(mfcc) {
  delta <- transform_compute_deltas()(mfcc)
  delta_delta <- transform_compute_deltas()(delta)

  # Concatenate
  features <- torch_cat(list(mfcc, delta, delta_delta), dim = 1)
  return(features)
}
```

**When to use:**
- MFCC: Good for speech, less common for environmental sounds
- Log-Mel: Standard for most audio classification tasks
- Raw STFT: Rarely used directly in DL

### Spectrogram Size Calculation

```r
# Time axis length
n_frames <- floor((signal_length - n_fft) / hop_length) + 1

# Frequency axis length
n_freq_bins <- n_fft / 2 + 1  # For STFT
n_freq_bins <- n_mels           # For mel-spectrogram

# Example: 5-second audio at 22050 Hz
# signal_length = 110250 samples
# n_fft = 2048, hop = 512
# n_frames = floor((110250 - 2048) / 512) + 1 = 212
# Shape: (n_mels=128, n_frames=212) for mel-spec
```

---

## CNN/CRNN Architectures for Audio

### 1. Basic 2D CNN on Spectrograms

**Treat spectrogram as image**: (n_mels, n_frames) with 1 channel.

```r
library(torch)
library(luz)

# Simple CNN
audio_cnn <- nn_module(
  "AudioCNN",

  initialize = function(n_classes, n_mels = 128) {
    self$conv1 <- nn_conv2d(1, 32, kernel_size = c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(32)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    self$conv2 <- nn_conv2d(32, 64, kernel_size = c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(64)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    self$conv3 <- nn_conv2d(64, 128, kernel_size = c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(128)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    self$conv4 <- nn_conv2d(128, 256, kernel_size = c(3, 3), padding = "same")
    self$bn4 <- nn_batch_norm2d(256)
    self$pool4 <- nn_max_pool2d(c(2, 2))

    self$dropout <- nn_dropout(0.5)

    # Global average pooling
    self$gap <- nn_adaptive_avg_pool2d(c(1, 1))

    self$fc <- nn_linear(256, n_classes)
  },

  forward = function(x) {
    # x shape: (batch, 1, n_mels, n_frames)

    x <- self$conv1(x) %>%
      self$bn1() %>%
      nnf_relu() %>%
      self$pool1()

    x <- self$conv2(x) %>%
      self$bn2() %>%
      nnf_relu() %>%
      self$pool2()

    x <- self$conv3(x) %>%
      self$bn3() %>%
      nnf_relu() %>%
      self$pool3()

    x <- self$conv4(x) %>%
      self$bn4() %>%
      nnf_relu() %>%
      self$pool4()

    # Global pooling
    x <- self$gap(x)
    x <- torch_flatten(x, start_dim = 2)

    x <- self$dropout(x)
    x <- self$fc(x)

    return(x)
  }
)
```

**Architecture Principles:**
- **Start with small filters**: (3,3) captures local patterns
- **Batch normalization**: After each conv, before activation
- **Pooling**: Reduces spatial dimensions, increases receptive field
- **Dropout**: Prevents overfitting (0.3-0.5 typical)
- **Global pooling**: Better than flatten, handles variable input sizes

### 2. Deeper CNN with Residual Connections

```r
# Residual block
residual_block <- nn_module(
  "ResidualBlock",

  initialize = function(in_channels, out_channels, stride = 1) {
    self$conv1 <- nn_conv2d(in_channels, out_channels,
                            kernel_size = c(3, 3),
                            stride = stride,
                            padding = "same")
    self$bn1 <- nn_batch_norm2d(out_channels)

    self$conv2 <- nn_conv2d(out_channels, out_channels,
                            kernel_size = c(3, 3),
                            padding = "same")
    self$bn2 <- nn_batch_norm2d(out_channels)

    # Shortcut connection
    if (in_channels != out_channels || stride != 1) {
      self$shortcut <- nn_sequential(
        nn_conv2d(in_channels, out_channels,
                  kernel_size = c(1, 1), stride = stride),
        nn_batch_norm2d(out_channels)
      )
    } else {
      self$shortcut <- nn_identity()
    }
  },

  forward = function(x) {
    residual <- x

    out <- self$conv1(x) %>%
      self$bn1() %>%
      nnf_relu()

    out <- self$conv2(out) %>%
      self$bn2()

    # Add residual
    out <- out + self$shortcut(residual)
    out <- nnf_relu(out)

    return(out)
  }
)

# ResNet-style architecture
audio_resnet <- nn_module(
  "AudioResNet",

  initialize = function(n_classes, n_mels = 128) {
    self$conv1 <- nn_conv2d(1, 64, kernel_size = c(7, 7),
                            stride = 2, padding = "same")
    self$bn1 <- nn_batch_norm2d(64)
    self$pool1 <- nn_max_pool2d(c(3, 3), stride = 2, padding = 1)

    self$layer1 <- nn_sequential(
      residual_block(64, 64),
      residual_block(64, 64)
    )

    self$layer2 <- nn_sequential(
      residual_block(64, 128, stride = 2),
      residual_block(128, 128)
    )

    self$layer3 <- nn_sequential(
      residual_block(128, 256, stride = 2),
      residual_block(256, 256)
    )

    self$layer4 <- nn_sequential(
      residual_block(256, 512, stride = 2),
      residual_block(512, 512)
    )

    self$gap <- nn_adaptive_avg_pool2d(c(1, 1))
    self$fc <- nn_linear(512, n_classes)
  },

  forward = function(x) {
    x <- self$conv1(x) %>%
      self$bn1() %>%
      nnf_relu() %>%
      self$pool1()

    x <- self$layer1(x)
    x <- self$layer2(x)
    x <- self$layer3(x)
    x <- self$layer4(x)

    x <- self$gap(x)
    x <- torch_flatten(x, start_dim = 2)
    x <- self$fc(x)

    return(x)
  }
)
```

### 3. CRNN (CNN + RNN) for Temporal Context

**Motivation**: Captures long-range temporal dependencies in audio.

```r
audio_crnn <- nn_module(
  "AudioCRNN",

  initialize = function(n_classes, n_mels = 128, rnn_hidden = 128) {
    # CNN frontend
    self$conv1 <- nn_conv2d(1, 64, kernel_size = c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(64)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    self$conv2 <- nn_conv2d(64, 128, kernel_size = c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(128)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    self$conv3 <- nn_conv2d(128, 256, kernel_size = c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(256)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # Recurrent layer
    # Input to LSTM: (batch, seq_len, features)
    self$lstm <- nn_lstm(
      input_size = 256,  # Will be 256 * (n_mels / 8) after pooling
      hidden_size = rnn_hidden,
      num_layers = 2,
      batch_first = TRUE,
      bidirectional = TRUE,
      dropout = 0.3
    )

    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(rnn_hidden * 2, n_classes)  # *2 for bidirectional
  },

  forward = function(x) {
    # x: (batch, 1, n_mels, n_frames)
    batch_size <- x$shape[1]

    # CNN feature extraction
    x <- self$conv1(x) %>%
      self$bn1() %>%
      nnf_relu() %>%
      self$pool1()

    x <- self$conv2(x) %>%
      self$bn2() %>%
      nnf_relu() %>%
      self$pool2()

    x <- self$conv3(x) %>%
      self$bn3() %>%
      nnf_relu() %>%
      self$pool3()

    # x: (batch, 256, n_mels/8, n_frames/8)

    # Reshape for RNN: collapse frequency axis
    # (batch, channels, freq, time) -> (batch, time, channels*freq)
    x <- x$permute(c(1, 4, 2, 3))  # (batch, time, channels, freq)
    x <- torch_flatten(x, start_dim = 3)  # (batch, time, channels*freq)

    # RNN
    x <- self$lstm(x)[[1]]  # Get output, ignore hidden states

    # Use last timestep for classification
    x <- x[, -1, ]  # (batch, hidden*2)

    x <- self$dropout(x)
    x <- self$fc(x)

    return(x)
  }
)
```

**CRNN Variants:**
- **GRU instead of LSTM**: Faster, similar performance
- **Attention over time**: Better than last timestep
- **Temporal convolutions**: Alternative to RNN, faster

### 4. 1D CNN on Raw Waveform

**Less common but powerful**: Learns features directly from audio.

```r
waveform_cnn <- nn_module(
  "WaveformCNN",

  initialize = function(n_classes) {
    # 1D convolutions with increasing dilation
    self$conv1 <- nn_conv1d(1, 64, kernel_size = 80, stride = 4)
    self$bn1 <- nn_batch_norm1d(64)
    self$pool1 <- nn_max_pool1d(4)

    self$conv2 <- nn_conv1d(64, 128, kernel_size = 3, padding = "same")
    self$bn2 <- nn_batch_norm1d(128)
    self$pool2 <- nn_max_pool1d(4)

    self$conv3 <- nn_conv1d(128, 256, kernel_size = 3, padding = "same")
    self$bn3 <- nn_batch_norm1d(256)
    self$pool3 <- nn_max_pool1d(4)

    self$conv4 <- nn_conv1d(256, 512, kernel_size = 3, padding = "same")
    self$bn4 <- nn_batch_norm1d(512)
    self$pool4 <- nn_max_pool1d(4)

    self$gap <- nn_adaptive_avg_pool1d(1)
    self$fc <- nn_linear(512, n_classes)
  },

  forward = function(x) {
    # x: (batch, 1, signal_length)

    x <- self$conv1(x) %>%
      self$bn1() %>%
      nnf_relu() %>%
      self$pool1()

    x <- self$conv2(x) %>%
      self$bn2() %>%
      nnf_relu() %>%
      self$pool2()

    x <- self$conv3(x) %>%
      self$bn3() %>%
      nnf_relu() %>%
      self$pool3()

    x <- self$conv4(x) %>%
      self$bn4() %>%
      nnf_relu() %>%
      self$pool4()

    x <- self$gap(x)
    x <- torch_flatten(x, start_dim = 2)
    x <- self$fc(x)

    return(x)
  }
)
```

**Trade-offs:**
- **Pros**: No manual feature engineering, end-to-end learning
- **Cons**: Requires more data, slower training, harder to interpret

---

## Attention Mechanisms for Audio

### 1. Self-Attention on Time Axis

```r
attention_layer <- nn_module(
  "AttentionLayer",

  initialize = function(feature_dim, attention_dim = 128) {
    self$attention <- nn_sequential(
      nn_linear(feature_dim, attention_dim),
      nn_tanh(),
      nn_linear(attention_dim, 1)
    )
  },

  forward = function(x) {
    # x: (batch, time, features)

    # Compute attention weights
    attn_weights <- self$attention(x)  # (batch, time, 1)
    attn_weights <- torch_softmax(attn_weights, dim = 2)

    # Apply attention
    attended <- (x * attn_weights)$sum(dim = 2)  # (batch, features)

    return(list(attended, attn_weights))
  }
)

# CRNN with attention pooling
audio_crnn_attention <- nn_module(
  "AudioCRNNAttention",

  initialize = function(n_classes, n_mels = 128, rnn_hidden = 128) {
    # CNN frontend (same as before)
    self$conv_blocks <- nn_sequential(
      nn_conv2d(1, 64, c(3, 3), padding = "same"),
      nn_batch_norm2d(64),
      nn_relu(),
      nn_max_pool2d(c(2, 2)),

      nn_conv2d(64, 128, c(3, 3), padding = "same"),
      nn_batch_norm2d(128),
      nn_relu(),
      nn_max_pool2d(c(2, 2)),

      nn_conv2d(128, 256, c(3, 3), padding = "same"),
      nn_batch_norm2d(256),
      nn_relu(),
      nn_max_pool2d(c(2, 2))
    )

    # Bidirectional LSTM
    self$lstm <- nn_lstm(
      input_size = 256,
      hidden_size = rnn_hidden,
      num_layers = 2,
      batch_first = TRUE,
      bidirectional = TRUE,
      dropout = 0.3
    )

    # Attention pooling
    self$attention <- attention_layer(rnn_hidden * 2)

    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(rnn_hidden * 2, n_classes)
  },

  forward = function(x) {
    # CNN
    x <- self$conv_blocks(x)

    # Reshape for RNN
    x <- x$permute(c(1, 4, 2, 3))
    x <- torch_flatten(x, start_dim = 3)

    # RNN
    x <- self$lstm(x)[[1]]

    # Attention pooling
    result <- self$attention(x)
    x <- result[[1]]
    attn_weights <- result[[2]]

    x <- self$dropout(x)
    x <- self$fc(x)

    return(x)
  }
)
```

### 2. Multi-Head Attention (Transformer-style)

```r
multi_head_attention <- nn_module(
  "MultiHeadAttention",

  initialize = function(embed_dim, num_heads = 8) {
    self$multihead_attn <- nn_multihead_attention(
      embed_dim = embed_dim,
      num_heads = num_heads,
      batch_first = TRUE
    )
    self$norm <- nn_layer_norm(embed_dim)
  },

  forward = function(x) {
    # x: (batch, seq_len, embed_dim)

    attn_output <- self$multihead_attn(
      query = x,
      key = x,
      value = x
    )[[1]]

    # Residual connection + layer norm
    x <- self$norm(x + attn_output)

    return(x)
  }
)
```

**Benefits of Attention:**
- **Interpretability**: Visualize which time frames are important
- **Variable length**: Handle different audio durations naturally
- **Performance**: Often better than simple pooling or last timestep

---

## Training Strategies

### 1. Loss Functions

**Single-label classification:**
```r
# Cross-entropy loss
loss_fn <- nn_cross_entropy_loss()

# With class weights for imbalanced data
class_weights <- torch_tensor(c(0.5, 2.0, 1.0, 3.0))  # Example weights
loss_fn <- nn_cross_entropy_loss(weight = class_weights)
```

**Multi-label classification (soundscapes):**
```r
# Binary cross-entropy with logits
loss_fn <- nn_bce_with_logits_loss()

# Focal loss for extreme imbalance
focal_loss <- function(inputs, targets, alpha = 0.25, gamma = 2.0) {
  bce_loss <- nnf_binary_cross_entropy_with_logits(
    inputs, targets, reduction = "none"
  )

  pt <- torch_exp(-bce_loss)
  focal_loss <- alpha * (1 - pt)^gamma * bce_loss

  return(focal_loss$mean())
}
```

### 2. Optimization

**Standard setup:**
```r
# Adam optimizer
optimizer <- optim_adam(model$parameters, lr = 0.001)

# With weight decay
optimizer <- optim_adam(
  model$parameters,
  lr = 0.001,
  weight_decay = 1e-4
)

# Learning rate scheduler
scheduler <- lr_one_cycle(
  optimizer,
  max_lr = 0.01,
  epochs = 50,
  steps_per_epoch = length(train_dataloader)
)
```

**Learning rate strategies:**
```r
# Reduce on plateau
scheduler <- lr_reduce_on_plateau(
  optimizer,
  mode = "min",
  factor = 0.5,
  patience = 5,
  threshold = 0.001
)

# Cosine annealing
scheduler <- lr_cosine_annealing(
  optimizer,
  t_max = 50,
  eta_min = 1e-6
)
```

### 3. Data Augmentation

**SpecAugment (frequency + time masking):**
```r
spec_augment <- function(spec, freq_mask_param = 30, time_mask_param = 40,
                        n_freq_masks = 2, n_time_masks = 2) {

  # Frequency masking
  for (i in 1:n_freq_masks) {
    freq_mask_size <- sample(1:freq_mask_param, 1)
    freq_mask_start <- sample(1:(spec$shape[2] - freq_mask_size), 1)
    spec[, freq_mask_start:(freq_mask_start + freq_mask_size - 1), ] <- 0
  }

  # Time masking
  for (i in 1:n_time_masks) {
    time_mask_size <- sample(1:time_mask_param, 1)
    time_mask_start <- sample(1:(spec$shape[3] - time_mask_size), 1)
    spec[, , time_mask_start:(time_mask_start + time_mask_size - 1)] <- 0
  }

  return(spec)
}
```

**Mixup augmentation:**
```r
mixup <- function(x1, x2, y1, y2, alpha = 0.4) {
  # Sample mixing coefficient
  lambda <- rbeta(1, alpha, alpha)

  # Mix inputs and targets
  x_mixed <- lambda * x1 + (1 - lambda) * x2
  y_mixed <- lambda * y1 + (1 - lambda) * y2

  return(list(x = x_mixed, y = y_mixed))
}

# In training loop
indices <- sample(1:batch_size, batch_size)
x_mixed <- mixup(batch$x, batch$x[indices, , , ],
                 batch$y, batch$y[indices, ])
```

**Time stretching:**
```r
# Using torchaudio
time_stretch <- transform_time_stretch(
  hop_length = 512,
  n_freq = n_fft / 2 + 1
)

# Apply with random rate
rate <- runif(1, 0.8, 1.2)
stretched_spec <- time_stretch(spec, rate)
```

**Pitch shifting:**
```r
pitch_shift <- transform_pitch_shift(
  sample_rate = 22050,
  n_steps = sample(-2:2, 1)  # Random shift -2 to +2 semitones
)

shifted_audio <- pitch_shift(waveform)
```

**Background noise addition:**
```r
add_noise <- function(audio, noise_audio, snr_db = 10) {
  # Signal-to-noise ratio in dB
  signal_power <- mean(audio^2)
  noise_power <- mean(noise_audio^2)

  # Scale noise to achieve desired SNR
  snr_linear <- 10^(snr_db / 10)
  noise_scaled <- noise_audio * sqrt(signal_power / (snr_linear * noise_power))

  # Mix
  augmented <- audio + noise_scaled

  return(augmented)
}
```

### 4. Handling Class Imbalance

**Sampling strategies:**
```r
# Weighted random sampling
compute_sample_weights <- function(labels) {
  class_counts <- table(labels)
  class_weights <- 1 / class_counts
  sample_weights <- class_weights[as.character(labels)]
  return(as.numeric(sample_weights))
}

# Create weighted sampler
weights <- compute_sample_weights(train_labels)
sampler <- sampler_weighted(weights, num_samples = length(weights))
```

**Oversampling minority classes:**
```r
# SMOTE-like for audio (in feature space)
oversample_minority <- function(features, labels, target_ratio = 1.0) {
  class_counts <- table(labels)
  majority_count <- max(class_counts)

  augmented_features <- list()
  augmented_labels <- c()

  for (class in names(class_counts)) {
    class_mask <- labels == class
    class_features <- features[class_mask, ]
    n_samples <- nrow(class_features)

    # Add original samples
    augmented_features[[length(augmented_features) + 1]] <- class_features
    augmented_labels <- c(augmented_labels, rep(class, n_samples))

    # Oversample if minority
    n_to_generate <- floor(majority_count * target_ratio) - n_samples
    if (n_to_generate > 0) {
      # Generate synthetic samples (simple: random pairs interpolation)
      for (i in 1:n_to_generate) {
        idx1 <- sample(1:n_samples, 1)
        idx2 <- sample(1:n_samples, 1)
        alpha <- runif(1)
        synthetic <- alpha * class_features[idx1, ] + (1 - alpha) * class_features[idx2, ]

        augmented_features[[length(augmented_features) + 1]] <- matrix(synthetic, nrow = 1)
        augmented_labels <- c(augmented_labels, class)
      }
    }
  }

  return(list(
    features = do.call(rbind, augmented_features),
    labels = augmented_labels
  ))
}
```

### 5. Validation Strategy

**Critical: Prevent leakage in audio data**

```r
# Split by recording location/date, not by random windows
create_audio_splits <- function(metadata, test_size = 0.2, val_size = 0.1) {
  # Group by recording_id to avoid leakage
  unique_recordings <- unique(metadata$recording_id)
  n_recordings <- length(unique_recordings)

  # Shuffle recordings
  set.seed(42)
  recordings_shuffled <- sample(unique_recordings)

  # Split
  n_test <- floor(n_recordings * test_size)
  n_val <- floor(n_recordings * val_size)
  n_train <- n_recordings - n_test - n_val

  test_recordings <- recordings_shuffled[1:n_test]
  val_recordings <- recordings_shuffled[(n_test + 1):(n_test + n_val)]
  train_recordings <- recordings_shuffled[(n_test + n_val + 1):n_recordings]

  return(list(
    train = metadata[metadata$recording_id %in% train_recordings, ],
    val = metadata[metadata$recording_id %in% val_recordings, ],
    test = metadata[metadata$recording_id %in% test_recordings, ]
  ))
}
```

**Cross-validation for small datasets:**
```r
# K-fold CV at recording level
library(mlr3)

# Group by recording_id
task$set_col_roles("recording_id", roles = "group")

# Create grouped CV resampling
resampling <- rsmp("cv", folds = 5)
resampling$instantiate(task)
```

---

## Advanced Techniques

### 1. Weak Supervision and Multiple Instance Learning

**Problem**: Only clip-level labels, not frame-level labels.

**Solution**: Multiple Instance Learning with attention pooling.

```r
mil_model <- nn_module(
  "MILAudioModel",

  initialize = function(n_classes, n_mels = 128) {
    # Feature extractor (CNN)
    self$feature_extractor <- nn_sequential(
      nn_conv2d(1, 64, c(3, 3), padding = "same"),
      nn_batch_norm2d(64),
      nn_relu(),
      nn_max_pool2d(c(2, 2)),

      nn_conv2d(64, 128, c(3, 3), padding = "same"),
      nn_batch_norm2d(128),
      nn_relu(),
      nn_max_pool2d(c(2, 2)),

      nn_conv2d(128, 256, c(3, 3), padding = "same"),
      nn_batch_norm2d(256),
      nn_relu(),
      nn_max_pool2d(c(2, 2))
    )

    # Attention-based pooling
    self$attention <- nn_sequential(
      nn_linear(256, 128),
      nn_tanh(),
      nn_linear(128, n_classes)
    )

    self$classifier <- nn_sequential(
      nn_linear(256, 128),
      nn_relu(),
      nn_dropout(0.5),
      nn_linear(128, n_classes)
    )
  },

  forward = function(x) {
    # x: (batch, n_windows, 1, n_mels, n_frames)
    # Each sample is a bag of windows from same recording

    batch_size <- x$shape[1]
    n_windows <- x$shape[2]

    # Reshape to process all windows
    x <- x$view(c(batch_size * n_windows, 1, -1, -1))

    # Extract features
    features <- self$feature_extractor(x)
    features <- torch_mean(features, dim = c(3, 4))  # (batch*n_windows, 256)

    # Reshape back
    features <- features$view(c(batch_size, n_windows, -1))

    # Attention weights per class
    attn_weights <- self$attention(features)  # (batch, n_windows, n_classes)
    attn_weights <- torch_softmax(attn_weights, dim = 2)

    # Weighted sum of features
    attended_features <- torch_sum(
      features$unsqueeze(3) * attn_weights$unsqueeze(2),
      dim = 2
    )  # (batch, 256, n_classes)

    # Classify
    logits <- torch_stack(
      lapply(1:n_classes, function(c) {
        self$classifier(attended_features[, , c])
      }),
      dim = 2
    )

    return(logits)
  }
)
```

**Training with weak labels:**
```r
# Only clip-level label, not which window contains the sound
# Loss: max over windows (assumes at least one window has the species)
weak_supervision_loss <- function(window_predictions, clip_label) {
  # window_predictions: (n_windows, n_classes)
  # clip_label: (n_classes) binary

  # Max pooling over windows
  clip_prediction <- torch_max(torch_sigmoid(window_predictions), dim = 1)$values

  # BCE loss
  loss <- nnf_binary_cross_entropy(clip_prediction, clip_label)

  return(loss)
}
```

### 2. Self-Supervised Learning

**Pretext task**: Predict temporal order of audio chunks.

```r
ssl_temporal_order <- nn_module(
  "SSLTemporalOrder",

  initialize = function(n_mels = 128) {
    # Shared feature extractor
    self$encoder <- nn_sequential(
      nn_conv2d(1, 64, c(3, 3), padding = "same"),
      nn_batch_norm2d(64),
      nn_relu(),
      nn_max_pool2d(c(2, 2)),

      nn_conv2d(64, 128, c(3, 3), padding = "same"),
      nn_batch_norm2d(128),
      nn_relu(),
      nn_max_pool2d(c(2, 2)),

      nn_adaptive_avg_pool2d(c(1, 1))
    )

    # Classifier for order prediction
    self$classifier <- nn_sequential(
      nn_linear(128 * 2, 64),  # Concatenate 2 chunks
      nn_relu(),
      nn_dropout(0.5),
      nn_linear(64, 1)  # Binary: in order or not
    )
  },

  forward = function(chunk1, chunk2) {
    # Extract features
    feat1 <- self$encoder(chunk1)$flatten(start_dim = 2)
    feat2 <- self$encoder(chunk2)$flatten(start_dim = 2)

    # Concatenate and predict
    combined <- torch_cat(list(feat1, feat2), dim = 2)
    logits <- self$classifier(combined)

    return(logits)
  }
)

# Data preparation for SSL
create_ssl_pairs <- function(spectrogram) {
  # Split spectrogram into chunks
  n_frames <- spectrogram$shape[3]
  chunk_size <- n_frames %/% 4

  chunks <- list(
    spectrogram[, , 1:chunk_size],
    spectrogram[, , (chunk_size + 1):(2 * chunk_size)],
    spectrogram[, , (2 * chunk_size + 1):(3 * chunk_size)],
    spectrogram[, , (3 * chunk_size + 1):(4 * chunk_size)]
  )

  # Create positive pair (in order)
  idx1 <- sample(1:3, 1)
  idx2 <- idx1 + 1
  pos_pair <- list(chunks[[idx1]], chunks[[idx2]], label = 1)

  # Create negative pair (out of order)
  neg_indices <- sample(1:4, 2)
  if (neg_indices[1] > neg_indices[2]) {
    neg_pair <- list(chunks[[neg_indices[1]]], chunks[[neg_indices[2]]], label = 0)
  } else {
    neg_pair <- pos_pair
  }

  return(list(positive = pos_pair, negative = neg_pair))
}
```

**Contrastive learning (SimCLR-style):**
```r
contrastive_loss <- function(features1, features2, temperature = 0.5) {
  # features1, features2: (batch, feature_dim)
  # Augmented versions of same samples

  # Normalize features
  features1 <- nnf_normalize(features1, dim = 2)
  features2 <- nnf_normalize(features2, dim = 2)

  # Compute similarity matrix
  logits <- torch_matmul(features1, features2$t()) / temperature

  # Labels: diagonal elements are positive pairs
  batch_size <- features1$shape[1]
  labels <- torch_arange(0, batch_size - 1, dtype = torch_long())

  # Cross-entropy loss
  loss <- nnf_cross_entropy(logits, labels)

  return(loss)
}
```

### 3. Transfer Learning with Pre-trained Models

**Using embeddings from pre-trained models:**
```r
# Example: Use PANNs (Pretrained Audio Neural Networks) embeddings
# Or BirdNET, VGGish, etc.

transfer_learning_model <- nn_module(
  "TransferLearningAudio",

  initialize = function(pretrained_encoder, n_classes, freeze_encoder = TRUE) {
    self$encoder <- pretrained_encoder

    # Freeze encoder weights
    if (freeze_encoder) {
      for (param in self$encoder$parameters) {
        param$requires_grad_(FALSE)
      }
    }

    # Add custom classifier head
    self$classifier <- nn_sequential(
      nn_linear(2048, 512),  # Assuming encoder outputs 2048-dim
      nn_relu(),
      nn_dropout(0.5),
      nn_linear(512, 128),
      nn_relu(),
      nn_dropout(0.3),
      nn_linear(128, n_classes)
    )
  },

  forward = function(x) {
    # Extract features (no gradient)
    with_no_grad({
      features <- self$encoder(x)
    })

    # Classify
    logits <- self$classifier(features)

    return(logits)
  }
)

# Fine-tuning strategy
train_transfer_learning <- function(model, train_loader, val_loader,
                                   epochs = 50) {
  # Phase 1: Train only classifier (encoder frozen)
  optimizer <- optim_adam(model$classifier$parameters, lr = 0.001)

  for (epoch in 1:20) {
    # Training loop...
  }

  # Phase 2: Unfreeze encoder and fine-tune with lower LR
  for (param in model$encoder$parameters) {
    param$requires_grad_(TRUE)
  }

  optimizer <- optim_adam(
    model$parameters,
    lr = 0.0001  # Much lower LR
  )

  for (epoch in 21:epochs) {
    # Training loop...
  }
}
```

---

## Evaluation and Inference

### 1. Evaluation Metrics

**Single-label classification:**
```r
# Accuracy, F1, precision, recall per class
library(yardstick)

evaluate_model <- function(predictions, labels) {
  results <- tibble(
    truth = factor(labels),
    estimate = factor(predictions)
  )

  metrics <- metric_set(accuracy, precision, recall, f_meas)
  overall <- metrics(results, truth = truth, estimate = estimate)

  # Per-class metrics
  class_metrics <- results %>%
    group_by(truth) %>%
    summarise(
      precision = precision_vec(truth, estimate),
      recall = recall_vec(truth, estimate),
      f1 = f_meas_vec(truth, estimate)
    )

  return(list(overall = overall, per_class = class_metrics))
}
```

**Multi-label classification:**
```r
# Average precision, ROC-AUC per class
evaluate_multilabel <- function(predictions, labels) {
  # predictions: (n_samples, n_classes) probabilities
  # labels: (n_samples, n_classes) binary

  n_classes <- ncol(labels)

  # Per-class metrics
  class_metrics <- tibble(
    class_id = 1:n_classes,
    auc = numeric(n_classes),
    avg_precision = numeric(n_classes)
  )

  for (i in 1:n_classes) {
    # ROC-AUC
    class_metrics$auc[i] <- yardstick::roc_auc_vec(
      truth = factor(labels[, i]),
      estimate = predictions[, i]
    )

    # Average precision
    class_metrics$avg_precision[i] <- yardstick::pr_auc_vec(
      truth = factor(labels[, i]),
      estimate = predictions[, i]
    )
  }

  # Mean average precision (mAP)
  map_score <- mean(class_metrics$avg_precision)

  return(list(
    class_metrics = class_metrics,
    map = map_score
  ))
}
```

### 2. Inference on Continuous Audio

**Sliding window prediction:**
```r
predict_continuous_audio <- function(model, audio_path,
                                    window_sec = 5, hop_sec = 2.5,
                                    sample_rate = 22050) {
  # Load audio
  audio <- readWave(audio_path)

  # Resample if needed
  if (audio@samp.rate != sample_rate) {
    audio <- resample(audio, sample_rate, orig.freq = audio@samp.rate)
  }

  # Create windows
  signal <- audio@left
  window_samples <- sample_rate * window_sec
  hop_samples <- sample_rate * hop_sec

  n_windows <- floor((length(signal) - window_samples) / hop_samples) + 1

  # Predictions storage
  predictions <- list()
  timestamps <- numeric(n_windows)

  for (i in 1:n_windows) {
    start_idx <- (i - 1) * hop_samples + 1
    end_idx <- start_idx + window_samples - 1
    window <- signal[start_idx:end_idx]

    # Convert to spectrogram
    spec <- compute_melspec(torch_tensor(window)$unsqueeze(1), sample_rate)
    spec <- log_mel(spec)
    spec <- spec$unsqueeze(1)$unsqueeze(1)  # (1, 1, n_mels, n_frames)

    # Predict
    with_no_grad({
      logits <- model(spec)
      probs <- torch_softmax(logits, dim = 2)
    })

    predictions[[i]] <- as.numeric(probs$cpu())
    timestamps[i] <- start_idx / sample_rate
  }

  # Post-processing: smooth predictions over time
  predictions_matrix <- do.call(rbind, predictions)
  smoothed_predictions <- apply(predictions_matrix, 2, function(x) {
    zoo::rollmean(x, k = 3, fill = NA, align = "center")
  })

  return(tibble(
    timestamp = timestamps,
    predictions = as.data.frame(smoothed_predictions)
  ))
}
```

**Post-processing strategies:**
```r
# 1. Median filtering
median_filter <- function(predictions, window_size = 5) {
  apply(predictions, 2, function(x) {
    zoo::rollmedian(x, k = window_size, fill = NA, align = "center")
  })
}

# 2. Apply species-specific thresholds
apply_thresholds <- function(predictions, thresholds) {
  # thresholds: named vector per species
  detections <- predictions

  for (species in names(thresholds)) {
    detections[[species]] <- predictions[[species]] > thresholds[species]
  }

  return(detections)
}

# 3. Merge adjacent detections
merge_detections <- function(detections, timestamps, min_gap_sec = 1.0) {
  # Merge detections within min_gap_sec
  events <- list()

  for (species in colnames(detections)) {
    species_detections <- which(detections[[species]])

    if (length(species_detections) == 0) next

    # Group adjacent detections
    gaps <- diff(timestamps[species_detections])
    split_points <- which(gaps > min_gap_sec)

    event_groups <- split(
      species_detections,
      cumsum(c(1, gaps > min_gap_sec))
    )

    # Create events
    for (group in event_groups) {
      events[[length(events) + 1]] <- list(
        species = species,
        start_time = timestamps[group[1]],
        end_time = timestamps[group[length(group)]],
        confidence = mean(detections[[species]][group])
      )
    }
  }

  return(bind_rows(events))
}
```

### 3. Confidence Calibration

**Temperature scaling:**
```r
temperature_scaling <- function(logits, temperature) {
  scaled_logits <- logits / temperature
  probs <- torch_softmax(scaled_logits, dim = 2)
  return(probs)
}

# Find optimal temperature on validation set
calibrate_temperature <- function(model, val_loader) {
  # Collect all logits and labels
  all_logits <- list()
  all_labels <- list()

  model$eval()
  with_no_grad({
    for (batch in val_loader) {
      logits <- model(batch$x)
      all_logits[[length(all_logits) + 1]] <- logits
      all_labels[[length(all_labels) + 1]] <- batch$y
    }
  })

  all_logits <- torch_cat(all_logits, dim = 1)
  all_labels <- torch_cat(all_labels, dim = 1)

  # Optimize temperature
  temperature <- torch_tensor(1.5, requires_grad = TRUE)
  optimizer <- optim_lbfgs(list(temperature), lr = 0.01, max_iter = 50)

  optimizer$step(function() {
    optimizer$zero_grad()
    loss <- nnf_cross_entropy(
      all_logits / temperature,
      all_labels
    )
    loss$backward()
    return(loss)
  })

  return(as.numeric(temperature))
}
```

---

## Practical Code Patterns

### Complete Training Pipeline

```r
library(torch)
library(luz)
library(tuneR)
library(torchaudio)

# 1. Data preparation
prepare_audio_dataset <- function(metadata_df, audio_dir) {
  dataset(
    name = "AudioDataset",

    initialize = function(metadata, audio_dir, augment = FALSE) {
      self$metadata <- metadata
      self$audio_dir <- audio_dir
      self$augment <- augment
    },

    .getitem = function(index) {
      row <- self$metadata[index, ]

      # Load audio
      audio_path <- file.path(self$audio_dir, row$filename)
      audio <- readWave(audio_path)

      # Preprocess
      audio <- mono(audio)
      audio <- resample(audio, 22050, orig.freq = audio@samp.rate)
      waveform <- torch_tensor(audio@left)$unsqueeze(1)

      # Compute mel-spectrogram
      mel_spec <- transform_mel_spectrogram(
        sample_rate = 22050,
        n_fft = 2048,
        hop_length = 512,
        n_mels = 128
      )(waveform)

      # Log scaling
      log_mel <- torch_log1p(mel_spec)

      # Normalize
      log_mel <- (log_mel - log_mel$mean()) / log_mel$std()

      # Augment
      if (self$augment) {
        if (runif(1) > 0.5) {
          log_mel <- spec_augment(log_mel)
        }
      }

      # Add channel dimension
      log_mel <- log_mel$unsqueeze(1)

      # Label
      label <- torch_tensor(row$label_id, dtype = torch_long())

      return(list(x = log_mel, y = label))
    },

    .length = function() {
      nrow(self$metadata)
    }
  )(metadata_df, audio_dir)
}

# 2. Create data loaders
train_ds <- prepare_audio_dataset(train_metadata, audio_dir, augment = TRUE)
val_ds <- prepare_audio_dataset(val_metadata, audio_dir, augment = FALSE)

train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE, num_workers = 4)
val_dl <- dataloader(val_ds, batch_size = 32, shuffle = FALSE, num_workers = 4)

# 3. Define model (using one of the architectures above)
model <- audio_resnet(n_classes = length(unique(train_metadata$label_id)))

# 4. Training with luz
fitted <- model %>%
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_accuracy()
    )
  ) %>%
  set_hparams(n_classes = n_classes, n_mels = 128) %>%
  set_opt_hparams(lr = 0.001, weight_decay = 1e-4) %>%
  fit(
    train_dl,
    epochs = 50,
    valid_data = val_dl,
    callbacks = list(
      luz_callback_early_stopping(patience = 10),
      luz_callback_lr_scheduler(
        lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 5
      ),
      luz_callback_model_checkpoint(path = "models/")
    )
  )

# 5. Evaluation
model$eval()
predictions <- list()
labels <- list()

with_no_grad({
  for (batch in val_dl) {
    logits <- model(batch$x)
    preds <- torch_argmax(logits, dim = 2)

    predictions[[length(predictions) + 1]] <- as.numeric(preds$cpu())
    labels[[length(labels) + 1]] <- as.numeric(batch$y$cpu())
  }
})

predictions <- unlist(predictions)
labels <- unlist(labels)

# Compute metrics
results <- evaluate_model(predictions, labels)
print(results)

# 6. Save model
torch_save(model, "final_model.pt")
```

### Inference Pipeline

```r
# Load trained model
model <- torch_load("final_model.pt")
model$eval()

# Predict on new audio file
predictions <- predict_continuous_audio(
  model = model,
  audio_path = "new_recording.wav",
  window_sec = 5,
  hop_sec = 2.5,
  sample_rate = 22050
)

# Apply thresholds
species_thresholds <- c(
  species1 = 0.7,
  species2 = 0.6,
  species3 = 0.8
)

detections <- apply_thresholds(predictions$predictions, species_thresholds)

# Merge adjacent detections
events <- merge_detections(detections, predictions$timestamp, min_gap_sec = 1.0)

# Export results
write_csv(events, "detections.csv")
```

### Model Comparison Framework

```r
compare_models <- function(models_list, val_loader) {
  results <- list()

  for (model_name in names(models_list)) {
    model <- models_list[[model_name]]
    model$eval()

    predictions <- list()
    labels <- list()

    with_no_grad({
      for (batch in val_loader) {
        logits <- model(batch$x)
        preds <- torch_argmax(logits, dim = 2)

        predictions[[length(predictions) + 1]] <- as.numeric(preds$cpu())
        labels[[length(labels) + 1]] <- as.numeric(batch$y$cpu())
      }
    })

    predictions <- unlist(predictions)
    labels <- unlist(labels)

    metrics <- evaluate_model(predictions, labels)

    results[[model_name]] <- metrics
  }

  # Compare results
  comparison <- bind_rows(
    lapply(names(results), function(name) {
      results[[name]]$overall %>%
        mutate(model = name)
    })
  )

  return(comparison)
}

# Usage
models <- list(
  cnn = audio_cnn(n_classes = n_classes),
  resnet = audio_resnet(n_classes = n_classes),
  crnn = audio_crnn(n_classes = n_classes)
)

# Load trained weights for each...

comparison <- compare_models(models, val_dl)
print(comparison)
```

---

## Summary of Best Practices

### Preprocessing
1. **Standardize**: Mono, fixed sample rate (16-22 kHz), normalization
2. **Window appropriately**: 2-5 sec for birds, 50% overlap
3. **Use log-mel spectrograms**: n_mels=128, species-appropriate freq range
4. **Handle variable length**: Pad/truncate or use attention pooling

### Architecture Selection
1. **Start simple**: Basic CNN on log-mel
2. **Add temporal modeling**: CRNN if temporal context matters
3. **Use attention**: For interpretability and variable-length audio
4. **Consider end-to-end**: 1D CNN on waveform if data is abundant

### Training
1. **Augment heavily**: SpecAugment, mixup, noise addition
2. **Handle imbalance**: Class weights, focal loss, sampling strategies
3. **Validate carefully**: Split by recording/location, not random
4. **Use transfer learning**: Pre-trained audio models when possible

### Inference
1. **Sliding windows**: Overlap windows for continuous audio
2. **Post-process**: Median filter, species-specific thresholds
3. **Calibrate confidence**: Temperature scaling on validation set
4. **Merge detections**: Group adjacent predictions into events

### For Bioacoustics Specifically
1. **Use domain knowledge**: Set frequency ranges based on species
2. **Weak supervision**: MIL for clip-level labels
3. **Few-shot learning**: SSL or transfer learning for rare species
4. **Soundscape ecology**: Multi-label classification, attention pooling

---

## References and Resources

### Key Papers
- SpecAugment: Park et al. (2019) - A Simple Data Augmentation Method for ASR
- PANNs: Kong et al. (2020) - Pretrained Audio Neural Networks
- BirdNET: Kahl et al. (2021) - BirdNET: A deep learning solution for avian diversity monitoring
- Weak Supervision: Kumar et al. (2021) - Weakly-Supervised Classification and Detection of Bird Sounds
- Self-Supervised: Ghosh et al. (2022) - Self-Supervised Learning for Few-Shot Bird Sound Classification

### R Packages
- **{torch}**: Deep learning framework
- **{torchaudio}**: Audio transformations
- **{luz}**: High-level training interface
- **{tuneR}**: Audio I/O and preprocessing
- **{seewave}**: Acoustic analysis

### Online Resources
- torch.mlverse.org - Official torch for R documentation
- BirdCLEF competitions - Real-world audio classification challenges
- PANNs GitHub - Pre-trained audio models
- AudioSet - Large-scale audio dataset
