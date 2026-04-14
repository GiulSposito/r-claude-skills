# Audio Deep Learning Best Practices

Comprehensive guidelines for audio deep learning in R, based on research and production experience.

---

## Preprocessing Guidelines

### Sample Rate Selection

**Target sample rates by application**:

| Application | Recommended Sample Rate | Rationale |
|-------------|------------------------|-----------|
| Speech recognition | 16000 Hz | Captures speech frequencies (< 8 kHz) |
| Bird calls | 22050 Hz | Captures most bird vocalizations (< 11 kHz) |
| Music analysis | 44100 Hz | CD quality, full frequency range |
| Ultrasonic detection | 48000-192000 Hz | For bats, insects (> 20 kHz) |
| General purpose | 22050 Hz | Good balance of quality and efficiency |

**Resampling**:
```r
# Always resample to consistent rate
if (audio@samp.rate != target_sr) {
  audio <- resample(audio, target_sr, orig.freq = audio@samp.rate)
}
```

### Normalization Strategies

**1. Peak normalization** (scale to [-1, 1]):
```r
audio <- normalize(audio, unit = "1")
```
- Simple, preserves relative dynamics
- Use for inference, when consistency matters

**2. RMS normalization** (energy-based):
```r
rms <- sqrt(mean(audio@left^2))
target_rms <- 0.1  # Adjust based on dataset
audio@left <- audio@left * (target_rms / rms)
```
- Better for models (consistent energy)
- Preferred for training

**3. Z-score normalization** (per-file):
```r
audio@left <- scale(audio@left)
```
- Removes DC bias, standardizes variance
- Use after mel-spectrogram computation

### Duration Handling

**Fixed-length clips**:
```r
pad_or_truncate <- function(signal, target_length, mode = "random") {
  current_length <- length(signal)

  if (current_length < target_length) {
    # Pad with zeros
    padding <- rep(0, target_length - current_length)
    signal <- c(signal, padding)
  } else if (current_length > target_length) {
    if (mode == "random") {
      # Random crop (augmentation)
      start_idx <- sample(1:(current_length - target_length + 1), 1)
    } else if (mode == "center") {
      # Center crop (evaluation)
      start_idx <- (current_length - target_length) %/% 2 + 1
    }
    signal <- signal[start_idx:(start_idx + target_length - 1)]
  }

  return(signal)
}
```

**Sliding windows** (for continuous audio):
```r
window_samples <- sample_rate * window_sec
hop_samples <- sample_rate * hop_sec  # 50% overlap typical
```

---

## Spectrogram Parameter Selection

### Mel-Spectrogram Basics

Key parameters:
- `n_fft`: FFT window size (frequency resolution)
- `hop_length`: Stride between windows (time resolution)
- `n_mels`: Number of mel bins (frequency dimensionality)
- `f_min`, `f_max`: Frequency range

### Parameter Guidelines

**n_fft (FFT size)**:

| Sample Rate | Short window | Medium window | Long window |
|-------------|--------------|---------------|-------------|
| 16000 Hz | 512 (32ms) | 1024 (64ms) | 2048 (128ms) |
| 22050 Hz | 1024 (46ms) | 2048 (93ms) | 4096 (186ms) |
| 44100 Hz | 2048 (46ms) | 4096 (93ms) | 8192 (186ms) |

- **Short (512-1024)**: For transients, percussion, speech
- **Medium (2048)**: General purpose, most common
- **Long (4096+)**: For pitch detection, harmonic analysis

**hop_length (stride)**:
- Rule of thumb: `hop_length = n_fft / 4`
- Typical: 512 with n_fft=2048
- Smaller = better time resolution, more computation
- Larger = coarser time resolution, faster

**n_mels (mel bins)**:
- Speech: 40-80
- Music: 128-256
- Birds/environmental: 64-128
- **Standard: 128** (good default)

**Frequency range (f_min, f_max)**:

| Application | f_min | f_max | Rationale |
|-------------|-------|-------|-----------|
| Speech | 80 Hz | 8000 Hz | Human voice range |
| Bird calls | 500 Hz | 12000 Hz | Most bird species |
| Music | 20 Hz | 20000 Hz | Full audible range |
| Bats | 15000 Hz | 100000 Hz | Ultrasonic |

### Example Configuration

```r
# General purpose (birds, environmental)
mel_transform <- transform_mel_spectrogram(
  sample_rate = 22050,
  n_fft = 2048,        # 93ms window
  hop_length = 512,    # 23ms stride
  n_mels = 128,        # Standard dimensionality
  f_min = 500,         # Remove low-frequency noise
  f_max = 12000        # Nyquist or species-specific
)

# Log scaling (essential!)
log_mel <- torch_log1p(mel_spec)  # log(x + 1)

# Normalization (per-example)
log_mel <- (log_mel - log_mel$mean()) / (log_mel$std() + 1e-8)
```

---

## Architecture Recommendations

### By Use Case

**Short clips (< 5 sec) - Classification**:
- Simple CNN (4-5 layers)
- ResNet-style if complex patterns
- Global average pooling

**Long clips (> 10 sec) - Event detection**:
- CRNN (CNN + GRU)
- Attention mechanism
- Sliding window inference

**Continuous audio - Monitoring**:
- CRNN with attention
- Temporal smoothing
- Post-processing filters

**Raw waveforms**:
- 1D CNN
- Deeper architecture needed
- Consider preprocessing instead

### Architecture Design

**Convolutional frontend**:
```r
# Standard pattern: 4 blocks
# Each block: Conv -> BN -> ReLU -> MaxPool (2x2)
# Filters: 32 -> 64 -> 128 -> 256
# Results in 16x downsampling
```

**Pooling strategy**:
- MaxPool for feature extraction
- Global Average Pool for final aggregation
- Avoid flatten (too many parameters)

**Classifier head**:
```r
# Best practice
self$gap <- nn_adaptive_avg_pool2d(c(1, 1))
self$dropout <- nn_dropout(0.5)
self$fc <- nn_linear(n_features, n_classes)

# Avoid multiple FC layers unless necessary
```

---

## Data Augmentation Strategies

### Essential Augmentations

**1. SpecAugment** (frequency and time masking):
```r
spec_augment <- function(spec, freq_mask = 15, time_mask = 20) {
  n_mels <- spec$shape[1]
  n_frames <- spec$shape[2]

  # Frequency masking
  if (n_mels > freq_mask) {
    f <- sample(0:freq_mask, 1)
    f0 <- sample(0:(n_mels - f), 1)
    spec[(f0 + 1):(f0 + f), ] <- 0
  }

  # Time masking
  if (n_frames > time_mask) {
    t <- sample(0:time_mask, 1)
    t0 <- sample(0:(n_frames - t), 1)
    spec[, (t0 + 1):(t0 + t)] <- 0
  }

  return(spec)
}
```

**When to use**: Always for audio classification, especially speech and environmental sounds

**2. Random cropping**:
```r
# In dataset .getitem():
if (self$augment && length(signal) > target_length) {
  start_idx <- sample(1:(length(signal) - target_length + 1), 1)
  signal <- signal[start_idx:(start_idx + target_length - 1)]
}
```

**3. Mixup** (mixing two examples):
```r
mixup_batch <- function(batch_x, batch_y, alpha = 0.4) {
  lambda <- rbeta(1, alpha, alpha)
  indices <- torch_randperm(batch_x$shape[1]) + 1L

  mixed_x <- lambda * batch_x + (1 - lambda) * batch_x[indices]
  mixed_y <- lambda * batch_y + (1 - lambda) * batch_y[indices]

  return(list(x = mixed_x, y = mixed_y))
}
```

**When to use**: Improves generalization, especially with limited data

### Advanced Augmentations

**Time shifting**:
```r
# Shift waveform in time
shift_samples <- sample(-sample_rate:sample_rate, 1)
signal <- c(rep(0, abs(shift_samples)), signal)[1:length(signal)]
```

**Time stretching**:
```r
# Requires torchaudio
time_stretch_fn <- transform_time_stretch(hop_length = 512, n_freq = n_mels)
stretched <- time_stretch_fn(spec, rate = runif(1, 0.8, 1.2))
```

**Pitch shifting**:
```r
# Shift in mel-spectrogram domain
shift_bins <- sample(-5:5, 1)
if (shift_bins > 0) {
  spec <- torch_cat(list(spec[(shift_bins + 1):n_mels, ], torch_zeros(shift_bins, n_frames)))
} else if (shift_bins < 0) {
  spec <- torch_cat(list(torch_zeros(-shift_bins, n_frames), spec[1:(n_mels + shift_bins), ]))
}
```

**Background noise addition**:
```r
add_noise <- function(waveform, noise_waveform, snr_db = 10) {
  # Scale noise to achieve SNR
  signal_power <- torch_mean(waveform^2)
  noise_power <- torch_mean(noise_waveform^2)

  snr_linear <- 10^(snr_db / 10)
  noise_scaled <- noise_waveform * torch_sqrt(signal_power / (snr_linear * noise_power + 1e-8))

  return(waveform + noise_scaled)
}
```

### Augmentation Guidelines

**Training set**: Apply all augmentations with probability 0.5
**Validation set**: No augmentation (or only center crop)
**Test set**: No augmentation

**Recommended combination**:
1. Random crop (waveform)
2. SpecAugment (spectrogram) - prob 0.5
3. Mixup (batch-level) - prob 0.3

---

## Training Strategies

### Learning Rate

**Initial LR**:
- New model from scratch: 1e-3
- Fine-tuning pretrained: 1e-5 to 1e-4
- Large batch (> 64): scale LR proportionally

**LR scheduling**:
```r
# Recommended: ReduceLROnPlateau
luz_callback_lr_scheduler(
  lr_reduce_on_plateau,
  mode = "min",
  factor = 0.5,      # Halve LR
  patience = 5,      # After 5 epochs without improvement
  threshold = 0.001  # Minimum improvement
)
```

**Warm-up** (for large models):
```r
# Start with low LR, gradually increase
# Helps stabilize training
warmup_scheduler <- function(optimizer, warmup_epochs = 5, base_lr = 1e-3) {
  current_epoch <- 0

  function() {
    current_epoch <<- current_epoch + 1
    if (current_epoch <= warmup_epochs) {
      lr <- base_lr * (current_epoch / warmup_epochs)
      for (param_group in optimizer$param_groups) {
        param_group$lr <- lr
      }
    }
  }
}
```

### Regularization

**Dropout**:
- Standard: 0.5 before final classifier
- Heavy regularization: 0.5-0.7
- Light regularization: 0.3

**Weight decay** (L2):
```r
set_opt_hparams(
  lr = 0.001,
  weight_decay = 1e-4  # Standard value
)
```

**Batch normalization**:
- Use after every conv layer
- Before activation function
- Helps with training stability

### Class Imbalance

**1. Class weights**:
```r
compute_class_weights <- function(labels) {
  class_counts <- table(labels)
  total <- sum(class_counts)
  n_classes <- length(class_counts)

  # Inverse frequency
  weights <- total / (n_classes * class_counts)

  # Normalize
  weights <- weights / sum(weights) * n_classes

  return(torch_tensor(as.numeric(weights)))
}

# Use in loss
loss = nn_cross_entropy_loss(weight = class_weights)
```

**2. Focal loss** (for extreme imbalance):
```r
focal_loss <- function(alpha = 0.25, gamma = 2.0) {
  function(input, target) {
    ce_loss <- nnf_cross_entropy(input, target, reduction = "none")
    pt <- torch_exp(-ce_loss)
    focal <- alpha * (1 - pt)^gamma * ce_loss
    return(focal$mean())
  }
}
```

**3. Oversampling** (rare classes):
```r
# In dataset: sample rare classes more frequently
# Or use weighted random sampler
```

### Checkpointing

```r
luz_callback_model_checkpoint(
  path = "models/",
  monitor = "valid_loss",
  save_best_only = TRUE,  # Keep only best model
  mode = "min"
)
```

---

## Validation Strategies

### Temporal Splits

**Critical for audio**: Never shuffle time series!

```r
# Correct: temporal split
train_idx <- 1:floor(nrow(metadata) * 0.7)
val_idx <- (max(train_idx) + 1):floor(nrow(metadata) * 0.85)
test_idx <- (max(val_idx) + 1):nrow(metadata)

# Wrong: random split (leaks future info)
# Don't do this for time series audio!
```

### Metrics

**Classification**:
- Accuracy: Overall performance
- Precision: Avoid false positives
- Recall: Avoid false negatives
- F1-score: Balanced metric
- Confusion matrix: Per-class analysis

**Multi-label**:
- Binary accuracy: Per-label accuracy
- AUROC: Area under ROC curve
- mAP: Mean average precision
- Subset accuracy: All labels correct

**Regression** (continuous predictions):
- MAE: Mean absolute error
- RMSE: Root mean squared error
- R²: Coefficient of determination

### Cross-Validation

**K-fold CV** (for small datasets):
```r
# Ensure temporal ordering within folds
# Use stratified splits for imbalanced data
```

**Walk-forward validation** (time series):
```r
# Train on past, validate on future
# Mimics real-world deployment
```

---

## Inference Patterns

### Sliding Window

For continuous audio streams:

```r
predict_continuous <- function(model, audio_path,
                              window_sec = 5,
                              hop_sec = 2.5) {  # 50% overlap

  # Load audio
  audio <- readWave(audio_path)
  signal <- normalize(audio)@left

  # Window parameters
  window_samples <- sample_rate * window_sec
  hop_samples <- sample_rate * hop_sec
  n_windows <- floor((length(signal) - window_samples) / hop_samples) + 1

  # Process each window
  predictions <- list()
  for (i in 1:n_windows) {
    start_idx <- (i - 1) * hop_samples + 1
    end_idx <- start_idx + window_samples - 1
    window <- signal[start_idx:end_idx]

    # Preprocess and predict
    spec <- preprocess(window)
    pred <- model(spec)

    predictions[[i]] <- list(
      timestamp = start_idx / sample_rate,
      probabilities = as.numeric(pred$cpu())
    )
  }

  return(predictions)
}
```

**Overlap guidelines**:
- 50% (hop = window/2): Standard
- 75% (hop = window/4): More robust, slower
- 25% (hop = 3*window/4): Faster, less robust

### Post-Processing

**1. Temporal smoothing** (reduce noise):
```r
# Moving average over predictions
smoothed_probs <- zoo::rollmean(
  probabilities,
  k = 5,  # 5-window average
  fill = "extend",
  align = "center"
)
```

**2. Confidence thresholding**:
```r
# Only keep high-confidence predictions
detections <- predictions |>
  filter(max_prob > 0.7)  # Tune threshold per species/class
```

**3. Minimum duration filter**:
```r
# Remove very short detections (likely false positives)
min_duration_sec <- 1.0
detections <- detections |>
  group_by(class) |>
  filter(duration >= min_duration_sec)
```

**4. Non-maximum suppression**:
```r
# Remove overlapping detections (keep highest confidence)
nms <- function(detections, iou_threshold = 0.5) {
  # Sort by confidence
  detections <- detections |> arrange(desc(confidence))

  keep <- c()
  for (i in 1:nrow(detections)) {
    # Check overlap with kept detections
    overlaps <- compute_iou(detections[i, ], detections[keep, ])
    if (all(overlaps < iou_threshold)) {
      keep <- c(keep, i)
    }
  }

  return(detections[keep, ])
}
```

---

## Weak Supervision and Few-Shot Learning

### Weak Supervision Strategies

**1. Sound event detection with weak labels**:
```r
# Label: "bird present in 10-second clip"
# Model: Predict frame-level probabilities
# Aggregate: Max pooling over frames

# Loss: Binary cross-entropy on aggregated prediction
weak_label_loss <- function(frame_probs, clip_label) {
  # frame_probs: (batch, n_frames, n_classes)
  # clip_label: (batch, n_classes)

  # Max pooling over time
  clip_probs <- torch_max(frame_probs, dim = 2)[[1]]

  # BCE loss
  loss <- nnf_binary_cross_entropy(clip_probs, clip_label)
  return(loss)
}
```

**2. Mix weak and strong labels**:
```r
# Combine clip-level and event-level labels
total_loss <- 0.7 * strong_loss + 0.3 * weak_loss
```

### Few-Shot Learning

**Prototypical networks**:
```r
# Learn a feature extractor
# Classify based on distance to class prototypes

# Support set: Few examples of each class
# Query set: Examples to classify

# Compute prototypes (mean of support embeddings)
prototypes <- support_embeddings |>
  group_by(class) |>
  summarise(prototype = mean(embedding))

# Classify query based on nearest prototype
distances <- compute_distances(query_embeddings, prototypes)
predictions <- argmin(distances, dim = 2)
```

**Data augmentation crucial**:
- Mixup with alpha=0.4
- SpecAugment aggressive (freq_mask=30, time_mask=40)
- Multiple augmented views per example

---

## Common Issues and Solutions

### Issue: Model overfits quickly

**Symptoms**: Training accuracy high, validation accuracy low

**Solutions**:
1. Increase dropout (0.5 → 0.7)
2. Add more data augmentation
3. Reduce model size (fewer layers/filters)
4. Increase weight decay (1e-4 → 1e-3)
5. Early stopping with patience 5-10

### Issue: Low recall on rare classes

**Symptoms**: Common classes predicted well, rare classes missed

**Solutions**:
1. Use focal loss (gamma=2-3)
2. Increase class weights for rare classes
3. Oversample rare classes
4. Lower confidence threshold for rare classes

### Issue: Many false positives in continuous audio

**Symptoms**: Too many detections, low precision

**Solutions**:
1. Increase confidence threshold (0.5 → 0.7)
2. Apply temporal smoothing (5-window average)
3. Add minimum duration filter
4. Use non-maximum suppression
5. Train with more negative examples

### Issue: Model doesn't learn (loss plateaus)

**Symptoms**: Loss stuck, accuracy at baseline

**Solutions**:
1. Check data preprocessing (normalization, scaling)
2. Verify labels are correct
3. Increase learning rate (1e-3 → 1e-2)
4. Simplify model (overparameterized?)
5. Check for NaN/Inf in data
6. Try different architecture

### Issue: GPU out of memory

**Symptoms**: CUDA OOM error during training

**Solutions**:
1. Reduce batch size (32 → 16 → 8)
2. Reduce sequence length / image size
3. Use gradient accumulation
4. Use mixed precision training (fp16)
5. Reduce model size

---

## Performance Optimization

### Speed Improvements

**1. Efficient data loading**:
```r
# Use multiple workers
train_dl <- dataloader(train_ds, batch_size = 32,
                       shuffle = TRUE, num_workers = 4)

# Pin memory for GPU transfer
train_dl <- dataloader(train_ds, batch_size = 32,
                       pin_memory = TRUE)
```

**2. Mixed precision training**:
```r
# Requires torch >= 0.8
# Use autocast for forward pass
# GradScaler for backward pass
```

**3. Efficient architectures**:
- Use depthwise separable convolutions
- Replace LSTM with GRU (faster, similar performance)
- Use 1D CNN instead of 2D when possible

### Memory Optimization

**1. Gradient checkpointing**:
- Trade computation for memory
- Useful for very deep models

**2. In-place operations**:
```r
# Use inplace=TRUE when possible
nnf_relu(x, inplace = TRUE)
```

**3. Clear cache**:
```r
if (cuda_is_available()) {
  cuda_empty_cache()
}
```

---

## Production Deployment

### Model Export

**Save for inference**:
```r
# Save only model weights
model_only <- fitted$model
torch_save(model_only, "model_weights.pt")

# Load for inference
model <- audio_cnn(n_classes = 10)
model$load_state_dict(torch_load("model_weights.pt"))
model$eval()
```

**ONNX export** (for deployment):
```r
dummy_input <- torch_randn(1, 1, 128, 216)
torch_onnx_export(
  model,
  dummy_input,
  "model.onnx",
  input_names = c("spectrogram"),
  output_names = c("logits"),
  opset_version = 11
)
```

### Inference Optimization

**Batch inference**:
```r
# Process multiple files together
batch_size <- 16
for (i in seq(1, n_files, by = batch_size)) {
  batch_files <- files[i:min(i + batch_size - 1, n_files)]
  # Process batch
}
```

**Caching**:
```r
# Cache preprocessed spectrograms
# Avoids recomputing during inference
```

---

## References

### Key Papers

1. **SpecAugment**: Park et al. (2019) - "SpecAugment: A Simple Data Augmentation Method for ASR"
2. **Mixup**: Zhang et al. (2017) - "mixup: Beyond Empirical Risk Minimization"
3. **Focal Loss**: Lin et al. (2017) - "Focal Loss for Dense Object Detection"
4. **PANNs**: Kong et al. (2020) - "PANNs: Large-Scale Pretrained Audio Neural Networks"

### See Also

- [architectures.md](architectures.md) - Neural network architectures
- [examples/audio-classification.md](../examples/audio-classification.md) - Complete implementation
- [templates/audio-dataset.R](../templates/audio-dataset.R) - Dataset template
