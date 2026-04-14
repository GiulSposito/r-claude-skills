---
name: r-audio-multiclass
description: Multi-label audio classification in R using torch for bioacoustics and ecological monitoring. Use when mentions "multi-label audio", "multilabel audio", "multi-label classification", "classificação multi-rótulo", "mel-spectrogram", "mel spectrogram", "audio augmentation", "time-frequency masking", "BCEWithLogitsLoss", "audio preprocessing", "bioacoustics", "bioacústica", "acoustic monitoring", "monitoramento acústico", "sound classification", "classificação de sons", "overlapping species", "espécies sobrepostas", "soundscape analysis", "análise de paisagem sonora", "PAM", "passive acoustic monitoring", "audio multi-label", "torch audio", "torchaudio in R", or building sound classification models with overlapping classes in ecological contexts.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# R Audio Multi-Label Classification - Bioacoustics Focus

Multi-label audio classification in R using `{torch}` and `{torchaudio}` for ecological monitoring, with focus on bioacoustic scenarios where multiple species vocalize simultaneously.

## Overview

Multi-label classification differs fundamentally from multi-class:
- **Multi-class:** One label per sample (mutually exclusive classes)
- **Multi-label:** Multiple labels per sample (overlapping classes)

**Bioacoustic context:** Soundscapes contain multiple species vocalizing simultaneously. A 5-second clip might contain frog species A, B, and D but not C or E. This is multi-label classification.

This skill covers:
1. Audio preprocessing (mel-spectrograms, augmentation)
2. Multi-label loss functions and training
3. Evaluation metrics for multi-label scenarios
4. R/torch implementation patterns
5. Bioacoustic-specific considerations

**Key packages:**
- `{torch}`: Deep learning framework
- `{torchaudio}`: Audio transforms (mel-spectrogram)
- `{tuneR}`: Audio I/O
- `{luz}`: High-level torch training (optional)
- `{tidymodels}`: Preprocessing and validation splits

## When This Skill Activates

Use this skill when:
- Building multi-label audio classifiers (overlapping classes)
- Working with bioacoustic data (birds, frogs, insects, marine mammals)
- Dealing with soundscapes (environmental recordings)
- Need audio preprocessing pipelines in R
- Implementing attention pooling or temporal models
- Evaluating multi-label performance (per-class F1, mAP)

Related but different:
- For single-label audio → Use `r-tidymodels` with tabular features
- For bioacoustic feature extraction → Use `r-bioacoustics` skill
- For learning paradigms (SSL, FSL) → Use `learning-paradigms` skill

## Multi-Label vs Multi-Class

| Aspect | Multi-Class | Multi-Label |
|--------|-------------|-------------|
| **Labels per sample** | Exactly 1 | 0 to N |
| **Classes** | Mutually exclusive | Can overlap |
| **Output** | Softmax (sums to 1) | Sigmoid (independent) |
| **Loss** | Cross-entropy | BCE with logits |
| **Example** | "This is species A" | "Species A, C, F present" |
| **Bioacoustic case** | Single species calling | Chorus of multiple species |

---

## Phase 1: Audio Preprocessing

### 1.1 Loading Audio

```r
library(torch)
library(tuneR)

# Load audio file
load_audio <- function(file_path, target_sr = 22050) {
  # Read with tuneR
  audio <- readWave(file_path)

  # Resample if needed
  if (audio@samp.rate != target_sr) {
    audio <- resample(audio, target_sr)
  }

  # Convert to mono if stereo
  if (audio@stereo) {
    waveform <- (audio@left + audio@right) / 2
  } else {
    waveform <- audio@left
  }

  # Convert to torch tensor
  waveform_tensor <- torch_tensor(waveform)$unsqueeze(1)  # [1, samples]

  list(waveform = waveform_tensor, sample_rate = target_sr)
}
```

### 1.2 Mel-Spectrogram Transformation

```r
# Create mel-spectrogram transform
create_melspec_transform <- function(sample_rate = 22050,
                                     n_fft = 2048,
                                     hop_length = 512,
                                     n_mels = 128) {
  torchaudio::transform_melspectrogram(
    sample_rate = sample_rate,
    n_fft = n_fft,
    hop_length = hop_length,
    n_mels = n_mels,
    f_min = 0,
    f_max = sample_rate / 2
  )
}

# Convert to dB scale
amplitude_to_db <- function(melspec, ref_value = 1.0, amin = 1e-10) {
  melspec_db <- 10 * torch_log10(torch_clamp(melspec, min = amin) / ref_value)
  melspec_db
}

# Complete pipeline
audio_to_melspec <- function(audio_path, transform) {
  # Load audio
  audio <- load_audio(audio_path)

  # Apply mel-spectrogram
  melspec <- transform(audio$waveform)

  # Convert to dB
  melspec_db <- amplitude_to_db(melspec)

  melspec_db
}
```

### 1.3 Augmentation (Time-Frequency Masking)

**Critical for audio:** Augmentation improves generalization and prevents overfitting.

```r
# Time masking (SpecAugment)
time_mask <- function(spec, time_mask_param = 20) {
  if (runif(1) > 0.5) {
    t <- spec$size(3)  # Time dimension
    t_mask_size <- sample(1:time_mask_param, 1)
    t_start <- sample(1:(t - t_mask_size + 1), 1)
    spec[, , t_start:(t_start + t_mask_size - 1)] <- 0
  }
  spec
}

# Frequency masking
freq_mask <- function(spec, freq_mask_param = 15) {
  if (runif(1) > 0.5) {
    f <- spec$size(2)  # Frequency dimension
    f_mask_size <- sample(1:freq_mask_param, 1)
    f_start <- sample(1:(f - f_mask_size + 1), 1)
    spec[, f_start:(f_start + f_mask_size - 1), ] <- 0
  }
  spec
}

# Combined augmentation
augment_spectrogram <- function(spec) {
  spec |>
    time_mask(time_mask_param = 30) |>
    freq_mask(freq_mask_param = 20)
}
```

**Augmentation guidelines for bioacoustics:**
- ✅ Time masking (10-15% of duration)
- ✅ Frequency masking (5-10% of frequency bins)
- ✅ Gaussian noise (low SNR)
- ✅ Time stretching (±10-15%)
- ❌ Frequency inversion (destroys pitch information)
- ❌ Extreme warping (breaks temporal structure)

---

## Phase 2: Dataset and DataLoader

### 2.1 Multi-Label Dataset

```r
library(torch)

multilabel_audio_dataset <- dataset(
  name = "multilabel_audio_dataset",

  initialize = function(audio_files, labels_matrix, transform, augment = FALSE) {
    # audio_files: character vector of file paths
    # labels_matrix: [N, C] binary matrix (N samples, C classes)
    # transform: mel-spectrogram function
    # augment: apply augmentation?

    self$audio_files <- audio_files
    self$labels <- torch_tensor(labels_matrix, dtype = torch_float())
    self$transform <- transform
    self$augment <- augment
  },

  .getitem = function(i) {
    # Load and transform audio
    melspec <- audio_to_melspec(self$audio_files[i], self$transform)

    # Augment if training
    if (self$augment) {
      melspec <- augment_spectrogram(melspec)
    }

    # Get labels (all classes for this sample)
    labels <- self$labels[i, ]

    list(x = melspec, y = labels)
  },

  .length = function() {
    length(self$audio_files)
  }
)

# Example usage
train_ds <- multilabel_audio_dataset(
  audio_files = train_files,
  labels_matrix = train_labels,  # [N, C] binary matrix
  transform = melspec_transform,
  augment = TRUE
)

train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE)
```

### 2.2 Label Matrix Format

**Example:** 3 samples, 5 species

| Sample | Species_A | Species_B | Species_C | Species_D | Species_E |
|--------|-----------|-----------|-----------|-----------|-----------|
| clip_001.wav | 1 | 0 | 1 | 0 | 0 |
| clip_002.wav | 0 | 1 | 1 | 1 | 0 |
| clip_003.wav | 0 | 0 | 0 | 0 | 0 |

- `1` = species present in clip
- `0` = species absent
- Sample can have 0, 1, or multiple labels

```r
# Create label matrix from annotations
create_label_matrix <- function(annotations_df, species_list) {
  # annotations_df: columns = file_path, species_present (comma-separated)
  # species_list: character vector of all possible species

  n_samples <- nrow(annotations_df)
  n_species <- length(species_list)

  label_matrix <- matrix(0, nrow = n_samples, ncol = n_species)
  colnames(label_matrix) <- species_list

  for (i in 1:n_samples) {
    present_species <- strsplit(annotations_df$species_present[i], ",")[[1]]
    present_species <- trimws(present_species)  # Remove whitespace

    for (species in present_species) {
      if (species %in% species_list && species != "") {
        col_idx <- which(species_list == species)
        label_matrix[i, col_idx] <- 1
      }
    }
  }

  label_matrix
}
```

---

## Phase 3: Model Architecture

### 3.1 CNN for Mel-Spectrograms

```r
# Simple CNN for multi-label classification
multilabel_cnn <- nn_module(
  "multilabel_cnn",

  initialize = function(n_mels = 128, n_classes = 50) {
    # Convolutional layers
    self$conv1 <- nn_conv2d(1, 32, kernel_size = 3, padding = 1)
    self$conv2 <- nn_conv2d(32, 64, kernel_size = 3, padding = 1)
    self$conv3 <- nn_conv2d(64, 128, kernel_size = 3, padding = 1)

    # Pooling
    self$pool <- nn_max_pool2d(kernel_size = 2, stride = 2)

    # Dropout for regularization
    self$dropout <- nn_dropout(0.3)

    # Fully connected layers
    # After 3 pooling layers: n_mels // 8 frequency bins
    self$fc1 <- nn_linear(128 * (n_mels %/% 8) * (n_mels %/% 8), 256)
    self$fc2 <- nn_linear(256, n_classes)
  },

  forward = function(x) {
    # x: [batch, 1, n_mels, time]

    # Convolutional blocks
    x <- self$conv1(x) |> nnf_relu() |> self$pool()
    x <- self$conv2(x) |> nnf_relu() |> self$pool()
    x <- self$conv3(x) |> nnf_relu() |> self$pool()

    # Flatten
    x <- x$view(c(x$size(1), -1))

    # Fully connected
    x <- self$fc1(x) |> nnf_relu() |> self$dropout()
    logits <- self$fc2(x)  # Raw logits (no activation)

    logits
  }
)
```

**Why no sigmoid in forward():** We use `BCEWithLogitsLoss` which applies sigmoid internally for numerical stability.

### 3.2 Attention Pooling (Temporal Models)

For variable-length audio or weak supervision (clip-level labels, need frame-level):

```r
# Attention-based pooling for multi-label
attention_pooling_model <- nn_module(
  "attention_pooling_model",

  initialize = function(feature_dim = 128, n_classes = 50) {
    # Frame-level feature extractor
    self$feature_extractor <- nn_sequential(
      nn_conv2d(1, 32, kernel_size = 3, padding = 1),
      nn_relu(),
      nn_max_pool2d(2),
      nn_conv2d(32, 64, kernel_size = 3, padding = 1),
      nn_relu(),
      nn_max_pool2d(2)
    )

    # Attention mechanism
    self$attention <- nn_linear(feature_dim, n_classes)

    # Classifier
    self$classifier <- nn_linear(feature_dim, n_classes)
  },

  forward = function(x) {
    # x: [batch, 1, n_mels, time]

    # Extract features per frame
    features <- self$feature_extractor(x)  # [batch, 64, H, W]
    features <- features$mean(dim = 3)     # Avg across frequency → [batch, 64, time]
    features <- features$permute(c(1, 3, 2))  # [batch, time, feature_dim]

    # Attention weights
    attention_logits <- self$attention(features)  # [batch, time, n_classes]
    attention_weights <- nnf_softmax(attention_logits, dim = 2)  # Normalize over time

    # Weighted pooling
    weighted_features <- features$unsqueeze(3) * attention_weights$unsqueeze(2)
    pooled_features <- weighted_features$sum(dim = 2)  # [batch, feature_dim, n_classes]

    # Classification
    logits <- self$classifier(pooled_features$mean(dim = 2))  # [batch, n_classes]

    logits
  }
)
```

---

## Phase 4: Loss Function and Training

### 4.1 Binary Cross-Entropy with Logits

**Why BCEWithLogitsLoss:** Combines sigmoid + BCE for numerical stability.

```r
# Loss function
loss_fn <- nn_bce_with_logits_loss()

# Training loop
train_one_epoch <- function(model, dataloader, optimizer, device) {
  model$train()
  total_loss <- 0

  coro::loop(for (batch in dataloader) {
    # Move to device
    inputs <- batch$x$to(device = device)
    targets <- batch$y$to(device = device)

    # Forward pass
    optimizer$zero_grad()
    logits <- model(inputs)
    loss <- loss_fn(logits, targets)

    # Backward pass
    loss$backward()
    optimizer$step()

    total_loss <- total_loss + loss$item()
  })

  avg_loss <- total_loss / length(dataloader)
  avg_loss
}
```

### 4.2 Class Imbalance Handling

**Problem:** Some species are rare (< 1% of samples), others common (> 50%).

**Solution 1: Weighted BCE Loss**
```r
# Compute positive class weights (inverse frequency)
compute_pos_weights <- function(labels_matrix) {
  # labels_matrix: [N, C] binary matrix

  n_samples <- nrow(labels_matrix)
  pos_counts <- colSums(labels_matrix)
  neg_counts <- n_samples - pos_counts

  pos_weights <- neg_counts / (pos_counts + 1e-8)  # Avoid division by zero
  torch_tensor(pos_weights)
}

# Use in loss
pos_weights <- compute_pos_weights(train_labels)$to(device = device)
loss_fn <- nn_bce_with_logits_loss(pos_weight = pos_weights)
```

**Solution 2: Focal Loss** (for extreme imbalance)
```r
# Focal loss for multi-label
focal_loss_multilabel <- function(logits, targets, alpha = 0.25, gamma = 2.0) {
  bce_loss <- nnf_binary_cross_entropy_with_logits(
    logits, targets, reduction = "none"
  )

  probs <- torch_sigmoid(logits)
  pt <- torch_where(targets == 1, probs, 1 - probs)
  focal_weight <- (1 - pt)$pow(gamma)

  loss <- alpha * focal_weight * bce_loss
  loss$mean()
}
```

---

## Phase 5: Evaluation Metrics

### 5.1 Multi-Label Metrics

**Key metrics:**
- **Per-class precision/recall/F1:** How well each species is detected
- **Mean Average Precision (mAP):** Ranking quality
- **Hamming Loss:** Fraction of incorrect labels
- **Exact Match Ratio:** Fraction of perfectly predicted samples

```r
library(yardstick)

# Compute multi-label metrics
evaluate_multilabel <- function(model, dataloader, device, threshold = 0.5) {
  model$eval()

  all_preds <- list()
  all_targets <- list()

  with_no_grad({
    coro::loop(for (batch in dataloader) {
      inputs <- batch$x$to(device = device)
      targets <- batch$y$to(device = device)

      logits <- model(inputs)
      probs <- torch_sigmoid(logits)

      all_preds <- c(all_preds, list(probs$cpu()))
      all_targets <- c(all_targets, list(targets$cpu()))
    })
  })

  # Concatenate all batches
  preds_tensor <- torch_cat(all_preds, dim = 1)
  targets_tensor <- torch_cat(all_targets, dim = 1)

  # Convert to binary predictions
  binary_preds <- (preds_tensor > threshold)$to(dtype = torch_float())

  # Compute metrics
  metrics <- list(
    # Hamming loss (fraction of wrong labels)
    hamming_loss = (binary_preds != targets_tensor)$float()$mean()$item(),

    # Exact match ratio (all labels correct)
    exact_match = ((binary_preds == targets_tensor)$all(dim = 2))$float()$mean()$item(),

    # Per-class F1
    per_class_f1 = compute_per_class_f1(binary_preds, targets_tensor)
  )

  metrics
}

# Per-class F1 score
compute_per_class_f1 <- function(preds, targets) {
  n_classes <- preds$size(2)
  f1_scores <- numeric(n_classes)

  for (i in 1:n_classes) {
    tp <- (preds[, i] * targets[, i])$sum()$item()
    fp <- (preds[, i] * (1 - targets[, i]))$sum()$item()
    fn <- ((1 - preds[, i]) * targets[, i])$sum()$item()

    precision <- tp / (tp + fp + 1e-8)
    recall <- tp / (tp + fn + 1e-8)
    f1 <- 2 * (precision * recall) / (precision + recall + 1e-8)

    f1_scores[i] <- f1
  }

  f1_scores
}

# Mean Average Precision (mAP)
compute_map <- function(probs, targets) {
  # probs: [N, C] probabilities
  # targets: [N, C] binary labels

  n_classes <- probs$size(2)
  ap_scores <- numeric(n_classes)

  for (i in 1:n_classes) {
    class_probs <- as.numeric(probs[, i]$cpu())
    class_targets <- as.numeric(targets[, i]$cpu())

    # Skip if no positive examples
    if (sum(class_targets) == 0) {
      ap_scores[i] <- NA
      next
    }

    # Sort by probability (descending)
    ord <- order(class_probs, decreasing = TRUE)
    sorted_targets <- class_targets[ord]

    # Compute AP
    tp_cumsum <- cumsum(sorted_targets)
    precisions <- tp_cumsum / seq_along(sorted_targets)
    recalls <- tp_cumsum / sum(sorted_targets)

    # Average precision (area under PR curve)
    ap <- sum(precisions * sorted_targets) / sum(sorted_targets)
    ap_scores[i] <- ap
  }

  mean(ap_scores, na.rm = TRUE)  # mAP
}
```

### 5.2 Threshold Tuning

**Default threshold = 0.5 may not be optimal for imbalanced classes.**

```r
# Find optimal threshold per class
tune_thresholds <- function(probs, targets, metric = "f1") {
  n_classes <- probs$size(2)
  optimal_thresholds <- numeric(n_classes)

  for (i in 1:n_classes) {
    class_probs <- as.numeric(probs[, i]$cpu())
    class_targets <- as.numeric(targets[, i]$cpu())

    # Try thresholds from 0.1 to 0.9
    thresholds <- seq(0.1, 0.9, by = 0.05)
    scores <- numeric(length(thresholds))

    for (j in seq_along(thresholds)) {
      preds <- as.numeric(class_probs > thresholds[j])

      tp <- sum(preds * class_targets)
      fp <- sum(preds * (1 - class_targets))
      fn <- sum((1 - preds) * class_targets)

      precision <- tp / (tp + fp + 1e-8)
      recall <- tp / (tp + fn + 1e-8)
      f1 <- 2 * (precision * recall) / (precision + recall + 1e-8)

      scores[j] <- f1
    }

    optimal_thresholds[i] <- thresholds[which.max(scores)]
  }

  optimal_thresholds
}
```

---

## Complete Training Pipeline

See [templates/multilabel-training-loop.R](templates/multilabel-training-loop.R) for full training script.

**Key steps:**
1. Prepare label matrix (binary [N, C] format)
2. Create datasets with augmentation for training
3. Initialize model + optimizer
4. Train with BCEWithLogitsLoss (optionally weighted)
5. Evaluate with per-class F1, mAP, hamming loss
6. Tune thresholds per class on validation set
7. Save model and optimal thresholds

---

## Bioacoustic-Specific Considerations

### Issue 1: Temporal Localization

**Problem:** Clip-level labels (species present somewhere), need frame-level predictions.

**Solution:** Attention pooling or Multiple Instance Learning (MIL).
- See `attention_pooling_model` above
- For MIL guidance, see `learning-paradigms` skill (weak supervision section)

### Issue 2: Long-Tailed Distribution

**Problem:** 10% of species account for 90% of vocalizations.

**Solutions:**
- Weighted BCE loss (see section 4.2)
- Focal loss (emphasizes hard examples)
- Oversample rare species (carefully, avoid overfitting)
- Use few-shot learning for very rare species (see `learning-paradigms`)

### Issue 3: Environmental Noise

**Problem:** Wind, rain, vehicles mask vocalizations.

**Solutions:**
- Data augmentation with Gaussian noise
- Denois preprocessing (spectral subtraction, Wiener filtering)
- Robust loss functions (e.g., symmetric cross-entropy)

### Issue 4: Dataset Size

**Typical sizes:**
- Small: 100-500 clips (use transfer learning or SSL pretraining)
- Medium: 500-5k clips (train from scratch feasible)
- Large: 5k+ clips (full deep learning pipeline)

**If dataset is small:** Consider self-supervised pretraining (see `learning-paradigms` skill, SSL section).

---

## Real-World Examples

### Example 1: Neotropical Frog Chorus (AnuraSet-inspired)

See [examples/bioacoustics-use-cases.md](examples/bioacoustics-use-cases.md) for complete example.

**Scenario:**
- 50 frog species in Brazilian Atlantic Forest
- 3-second clips from continuous recordings
- Multiple species calling simultaneously (multi-label)
- Long-tailed distribution (5 common species, 20 medium, 25 rare)

**Approach:**
1. Mel-spectrogram preprocessing (128 mels, 22kHz)
2. Time/frequency masking augmentation
3. ResNet18 backbone (adapt from torchvision)
4. Weighted BCE loss (pos_weight for rare species)
5. Per-class F1 evaluation
6. Threshold tuning per species

**Expected performance:** 60-75% mean F1 (species-dependent).

### Example 2: Bird Soundscape Monitoring

**Scenario:**
- Identifying bird species by their calls in soundscapes (Springer paper ref)
- Multiple overlapping bird calls in natural environments
- Need real-time processing for monitoring

**Approach:**
1. CNN with temporal pooling
2. Attention mechanism for variable-length audio
3. Multi-label classification (multiple species per clip)
4. Deployment considerations (model size, inference speed)

**Reference:** "Identifying bird species by their calls in Soundscapes" (Springer, 2023) - demonstrates multi-label approach for bird calls in natural soundscapes with overlapping vocalizations.

---

## Templates and Examples

- **Training pipeline:** [templates/multilabel-training-loop.R](templates/multilabel-training-loop.R)
- **Audio preprocessing:** [templates/audio-preprocessing-pipeline.R](templates/audio-preprocessing-pipeline.R)
- **Use cases:** [examples/bioacoustics-use-cases.md](examples/bioacoustics-use-cases.md)

---

## Integration with Other Skills

**Preprocessing audio features:**
→ Use `r-bioacoustics` for MFCC, spectral features, ecoacoustic indices

**Learning paradigms:**
→ Use `learning-paradigms` for SSL pretraining, few-shot learning, weak supervision

**Model tuning:**
→ Use `r-tidymodels` for hyperparameter tuning, cross-validation setup

**Feature engineering:**
→ Use `r-feature-engineering` for systematic feature selection if using tabular features

---

## Common Pitfalls

❌ **Using softmax instead of sigmoid** → Forces single label, loses multi-label capability
❌ **Ignoring class imbalance** → Model predicts only common species
❌ **Not tuning thresholds** → Default 0.5 suboptimal for imbalanced classes
❌ **Excessive augmentation** → Destroys species-specific acoustic patterns
❌ **Wrong evaluation metrics** → Accuracy is meaningless for multi-label
❌ **Training on full spectrograms** → Memory issues; use cropping or downsample

✅ **Do this instead:**
- Use sigmoid + BCEWithLogitsLoss
- Weight loss by inverse class frequency
- Tune thresholds on validation set
- Use domain-appropriate augmentation
- Evaluate with per-class F1 and mAP
- Downsample or crop spectrograms to fixed size

---

## Performance Expectations

| Dataset Size | Architecture | Expected mAP | Expected Mean F1 |
|--------------|--------------|--------------|------------------|
| 100-500 clips | Simple CNN | 40-55% | 35-50% |
| 500-2k clips | ResNet18 | 55-70% | 50-65% |
| 2k-10k clips | ResNet50 + Attention | 65-80% | 60-75% |
| 10k+ clips | EfficientNet + SSL | 75-90% | 70-85% |

**Factors affecting performance:**
- Species acoustic similarity (high similarity → lower F1)
- Clip duration (longer clips → easier detection)
- Background noise level (higher noise → lower performance)
- Class imbalance (long-tailed → lower mean F1)

---

## Quick Reference

**I want to...**

- **Build multi-label classifier** → Use BCEWithLogitsLoss + sigmoid output
- **Handle imbalanced classes** → Use weighted BCE or focal loss
- **Evaluate model** → Per-class F1, mAP, hamming loss
- **Optimize thresholds** → Tune per-class thresholds on validation set
- **Preprocess audio** → Mel-spectrogram + time/frequency masking
- **Handle weak labels** → Attention pooling or MIL (see `learning-paradigms`)
- **Work with small dataset** → Transfer learning or SSL pretraining

**R packages:**
- `{torch}` - Core deep learning
- `{torchaudio}` - Audio transforms
- `{tuneR}` - Audio I/O
- `{luz}` - High-level training (optional)
- `{yardstick}` - Evaluation metrics
