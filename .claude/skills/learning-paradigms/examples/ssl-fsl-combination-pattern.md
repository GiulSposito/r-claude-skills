# SSL + FSL Combination Pattern

How to effectively combine Self-Supervised Learning (SSL) pretraining with Few-Shot Learning (FSL) for maximum sample efficiency.

## Why Combine SSL and FSL?

**Problem:** You have abundant unlabeled data but very few labeled examples per class.

**Solution:** SSL learns rich representations from unlabeled data, then FSL leverages these representations for classification with minimal labels.

**Synergy:**
- SSL addresses "representation poverty" (no pretrained model)
- FSL addresses "label scarcity" (< 10 examples per class)
- Together: Better than either paradigm alone

## When This Combination Works Best

### ✅ Ideal Scenarios

1. **Bioacoustics / Acoustic Monitoring**
   - Unlabeled: 1000s hours of continuous audio
   - Labeled: 5-20 clips per species
   - Challenge: Species-specific sounds + environmental noise

2. **Medical Imaging (Rare Diseases)**
   - Unlabeled: 100k+ normal scans
   - Labeled: 10-50 positive cases per rare condition
   - Challenge: High inter-patient variability

3. **Industrial Defect Detection**
   - Unlabeled: Millions of images from production line
   - Labeled: 5-10 examples per defect type
   - Challenge: Defects are rare, diverse, and evolving

4. **Ecological Monitoring**
   - Unlabeled: Camera trap images (99% empty or common species)
   - Labeled: 1-5 images per rare/endangered species
   - Challenge: Long-tailed distribution, environmental variability

### ❌ When NOT to Use This Combination

- You have 50+ labeled examples per class → Use transfer learning or supervised
- Unlabeled data is scarce (< 1000 samples) → SSL won't learn useful representations
- Pretrained models work well → Transfer learning is simpler
- Classes are very similar → Even SSL+FSL may struggle without more labels

## Implementation Pattern

### Phase 1: Self-Supervised Pretraining

**Goal:** Learn general-purpose representations from unlabeled data.

#### Step 1.1: Choose SSL Method

| Method | Best For | Complexity |
|--------|----------|------------|
| **SimCLR** | Images, audio spectrograms | Medium |
| **MoCo** | Large datasets, memory efficiency | Medium-High |
| **Barlow Twins** | Avoiding collapse without negatives | Medium |
| **MAE (Masked Autoencoder)** | Images, sequential data | Medium-High |
| **BYOL** | Avoiding negative pairs | High |

**Recommendation for beginners:** Start with **SimCLR** or **Barlow Twins** (well-documented, stable).

#### Step 1.2: Define Augmentations

**Critical:** Augmentations must preserve class-relevant information.

**Audio (spectrograms):**
```r
# Good augmentations
- Time masking (mask random time slices)
- Frequency masking (mask random frequency bands)
- Time stretching (speed up/down by 10-20%)
- Gaussian noise (low SNR)
- Mixup between samples

# Bad augmentations
- Vertical flip (changes frequency structure)
- Extreme time warping (destroys temporal patterns)
```

**Images:**
```r
# Good augmentations
- Random crop + resize
- Color jitter (brightness, contrast, saturation)
- Horizontal flip (if semantics preserved)
- Gaussian blur
- Random rotation (±15°)

# Bad augmentations
- Vertical flip (for most objects)
- Extreme distortions
- Cutout (for SSL - removes too much information)
```

#### Step 1.3: Train SSL Model

**R/torch implementation sketch:**
```r
library(torch)
library(luz)

# Define SSL model (example: SimCLR)
ssl_model <- nn_module(
  initialize = function(encoder, projection_dim = 128) {
    self$encoder <- encoder  # e.g., ResNet backbone
    self$projector <- nn_sequential(
      nn_linear(encoder$output_dim, 512),
      nn_relu(),
      nn_linear(512, projection_dim)
    )
  },

  forward = function(x) {
    features <- self$encoder(x)
    projections <- self$projector(features)
    projections
  }
)

# Contrastive loss (temperature-scaled)
contrastive_loss <- function(z1, z2, temperature = 0.5) {
  # z1, z2: projections of augmented views
  # Compute cosine similarity, apply temperature scaling
  # Return NT-Xent loss
}

# Training loop
for (epoch in 1:num_epochs) {
  for (batch in unlabeled_dataloader) {
    # Generate two augmented views
    view1 <- augment(batch)
    view2 <- augment(batch)

    # Forward pass
    z1 <- ssl_model(view1)
    z2 <- ssl_model(view2)

    # Compute loss
    loss <- contrastive_loss(z1, z2)

    # Backward + optimize
    loss$backward()
    optimizer$step()
  }
}

# Save encoder (discard projector)
torch_save(ssl_model$encoder, "ssl_encoder.pt")
```

**Training tips:**
- **Batch size:** Large (256-1024) for contrastive learning (more negatives)
- **Epochs:** 200-1000 (SSL needs long training)
- **Learning rate:** 0.001-0.01 with cosine annealing
- **Temperature:** 0.1-0.5 (tune on validation task)

---

### Phase 2: Few-Shot Learning on SSL Embeddings

**Goal:** Adapt SSL encoder to classify with few labels.

#### Step 2.1: Choose FSL Method

| Method | How It Works | When to Use |
|--------|--------------|-------------|
| **Prototypical Networks** | Compute class prototypes (mean embeddings), classify by nearest prototype | Simple, effective, recommended |
| **Matching Networks** | Attention over support set, weighted by similarity | Small support sets (< 5 shots) |
| **Relation Networks** | Learn a relation module to compare query and support | Complex relationships between classes |
| **MAML** | Meta-learn initialization for fast adaptation | Have multiple related FSL tasks |

**Recommendation:** Start with **Prototypical Networks** (simple, robust, works well with SSL).

#### Step 2.2: Episodic Training

**Key idea:** Train in "episodes" that mimic few-shot testing.

**Episode structure:**
- Sample N classes (e.g., 5 classes)
- Sample K support examples per class (e.g., 5 shots)
- Sample Q query examples per class (e.g., 15 queries)
- Classify queries using only support examples

**R/torch implementation:**
```r
# Load SSL encoder
ssl_encoder <- torch_load("ssl_encoder.pt")
ssl_encoder$eval()  # Freeze encoder (optional: fine-tune later)

# Prototypical network classifier
proto_classifier <- nn_module(
  initialize = function(encoder) {
    self$encoder <- encoder
  },

  forward = function(support_x, support_y, query_x) {
    # Encode support and query
    support_emb <- self$encoder(support_x)  # [N*K, D]
    query_emb <- self$encoder(query_x)      # [N*Q, D]

    # Compute class prototypes (mean of support embeddings)
    prototypes <- compute_prototypes(support_emb, support_y)  # [N, D]

    # Classify queries by nearest prototype (Euclidean distance)
    distances <- torch_cdist(query_emb, prototypes)  # [N*Q, N]
    logits <- -distances  # Negative distance = higher similarity
    logits
  }
)

# Episodic training loop
for (episode in 1:num_episodes) {
  # Sample episode
  episode_data <- sample_episode(
    dataset,
    n_way = 5,
    k_shot = 5,
    q_query = 15
  )

  # Forward pass
  logits <- proto_classifier(
    episode_data$support_x,
    episode_data$support_y,
    episode_data$query_x
  )

  # Compute loss
  loss <- nnf_cross_entropy(logits, episode_data$query_y)

  # Backward + optimize
  loss$backward()
  optimizer$step()
}
```

**Training tips:**
- **Episodes:** 10k-100k episodes (more episodes = better generalization)
- **N-way:** 5-20 classes per episode (match test distribution)
- **K-shot:** Match your target scenario (1-shot, 5-shot, etc.)
- **Fine-tuning encoder:** Start frozen, unfreeze after 5k episodes if needed

---

### Phase 3: Evaluation

**Episodic evaluation (FSL standard):**
```r
# Evaluate on 1000 episodes
accuracies <- c()

for (i in 1:1000) {
  # Sample test episode
  test_episode <- sample_episode(test_dataset, n_way = 5, k_shot = 5)

  # Predict
  with_no_grad({
    logits <- proto_classifier(
      test_episode$support_x,
      test_episode$support_y,
      test_episode$query_x
    )
    preds <- torch_argmax(logits, dim = 2)
    accuracy <- mean(preds == test_episode$query_y)
  })

  accuracies <- c(accuracies, accuracy)
}

# Report mean ± 95% confidence interval
cat(sprintf(
  "5-way 5-shot accuracy: %.2f%% ± %.2f%%\n",
  mean(accuracies) * 100,
  1.96 * sd(accuracies) / sqrt(length(accuracies)) * 100
))
```

---

## Complete Bioacoustics Example

### Scenario
- **Domain:** Neotropical frog classification
- **Unlabeled data:** 10,000 hours continuous audio (environmental recordings)
- **Labeled data:** 10 clips per species (50 species = 500 clips total)
- **Goal:** Classify species from 5-second clips

### Implementation

#### 1. Preprocessing
```r
library(tuneR)
library(torch)

# Convert audio to mel-spectrogram
audio_to_melspec <- function(audio_path, sr = 22050, n_mels = 128) {
  # Load audio
  audio <- readWave(audio_path)

  # Resample if needed
  if (audio@samp.rate != sr) {
    audio <- resample(audio, sr)
  }

  # Convert to tensor
  waveform <- torch_tensor(audio@left)$unsqueeze(1)

  # Mel-spectrogram transform
  mel_transform <- torchaudio::transform_melspectrogram(
    sample_rate = sr,
    n_mels = n_mels,
    n_fft = 2048,
    hop_length = 512
  )

  melspec <- mel_transform(waveform)

  # Convert to dB scale
  melspec_db <- torchaudio::transform_amplitude_to_db(melspec)

  melspec_db
}

# Augmentation function
augment_melspec <- function(melspec) {
  # Time masking
  if (runif(1) > 0.5) {
    t_mask_size <- sample(5:15, 1)
    t_start <- sample(1:(melspec$size(3) - t_mask_size), 1)
    melspec[, , t_start:(t_start + t_mask_size)] <- 0
  }

  # Frequency masking
  if (runif(1) > 0.5) {
    f_mask_size <- sample(5:15, 1)
    f_start <- sample(1:(melspec$size(2) - f_mask_size), 1)
    melspec[, f_start:(f_start + f_mask_size), ] <- 0
  }

  melspec
}
```

#### 2. SSL Pretraining (10k hours unlabeled)
```r
# Dataset of unlabeled audio clips
unlabeled_dataset <- dataset(
  initialize = function(audio_files) {
    self$files <- audio_files
  },

  .getitem = function(i) {
    melspec <- audio_to_melspec(self$files[i])
    melspec
  },

  .length = function() {
    length(self$files)
  }
)

# Create dataset (split 10k hours into 5-sec clips = ~7M clips)
unlabeled_files <- list.files("unlabeled_audio/", full.names = TRUE)
unlabeled_ds <- unlabeled_dataset(unlabeled_files)

# SSL model (SimCLR with ResNet18 backbone)
encoder <- torchvision::model_resnet18(pretrained = FALSE)
encoder$fc <- nn_identity()  # Remove classification head

ssl_model <- ssl_simclr_module(encoder, projection_dim = 128)

# Train SSL for 500 epochs (may take days on CPU, hours on GPU)
# ... (training code as shown earlier)

# Save encoder
torch_save(encoder, "frog_ssl_encoder.pt")
```

#### 3. FSL Fine-Tuning (10 clips per species × 50 species)
```r
# Labeled dataset
labeled_dataset <- dataset(
  initialize = function(audio_files, labels) {
    self$files <- audio_files
    self$labels <- labels
  },

  .getitem = function(i) {
    melspec <- audio_to_melspec(self$files[i])
    list(x = melspec, y = self$labels[i])
  },

  .length = function() {
    length(self$files)
  }
)

# Create dataset (500 labeled clips)
labeled_files <- list.files("labeled_audio/", full.names = TRUE)
labels <- read.csv("labels.csv")$species_id
labeled_ds <- labeled_dataset(labeled_files, labels)

# Load SSL encoder
ssl_encoder <- torch_load("frog_ssl_encoder.pt")

# Prototypical network
proto_model <- prototypical_network(ssl_encoder)

# Episodic training (5-way 5-shot)
train_fsl(
  model = proto_model,
  dataset = labeled_ds,
  n_way = 5,
  k_shot = 5,
  q_query = 15,
  num_episodes = 10000
)

# Save FSL model
torch_save(proto_model, "frog_fsl_model.pt")
```

#### 4. Evaluation
```r
# Test on held-out species (10 new species, 5-shot per species)
test_accuracy <- evaluate_fsl(
  model = proto_model,
  test_dataset = test_ds,
  n_way = 5,
  k_shot = 5,
  num_episodes = 1000
)

cat(sprintf("5-way 5-shot accuracy: %.2f%%\n", test_accuracy * 100))
# Expected: 60-80% (domain-dependent)
```

---

## Expected Performance Gains

### Baseline vs SSL → FSL

| Scenario | Baseline (FSL only) | SSL → FSL | Gain |
|----------|---------------------|-----------|------|
| **Bioacoustics (50 species, 5-shot)** | 40-50% | 60-75% | +20-25% |
| **Medical imaging (10 classes, 10-shot)** | 55-65% | 70-85% | +15-20% |
| **Fine-grained classification (100 classes, 1-shot)** | 25-35% | 40-55% | +15-20% |

**Key insight:** SSL pretraining typically provides **15-25% absolute accuracy improvement** in few-shot scenarios.

---

## Ablation Study: What Matters Most?

From research on SSL + FSL combinations:

1. **SSL data volume**: More unlabeled data → better (diminishing returns after 100k samples)
2. **Augmentation quality**: Good augmentations critical for SSL success
3. **Encoder architecture**: Larger encoders (ResNet50 vs ResNet18) help, but diminishing returns
4. **FSL method**: Prototypical Networks work well; MAML slightly better but much more expensive
5. **Fine-tuning encoder**: Freezing encoder often sufficient; fine-tuning adds 2-5% if done carefully

**Priority ranking:**
1. ✅ **Good augmentations** (most important)
2. ✅ **Sufficient SSL data** (10k+ samples)
3. ✅ **Prototypical Networks** (simple, effective)
4. 🔶 **Fine-tuning encoder** (optional, helps slightly)
5. 🔶 **Larger encoder** (optional, diminishing returns)

---

## Common Pitfalls

### ❌ Pitfall 1: Poor Augmentations
**Problem:** Augmentations destroy class-relevant information.
**Example:** Vertically flipping audio spectrograms (changes frequency structure).
**Fix:** Use domain-appropriate augmentations that preserve semantics.

### ❌ Pitfall 2: Insufficient SSL Training
**Problem:** Stopping SSL pretraining too early (< 100 epochs).
**Fix:** Train SSL for 200-1000 epochs (convergence is slow).

### ❌ Pitfall 3: Not Evaluating SSL Embeddings
**Problem:** Assuming SSL worked without validation.
**Fix:** Test SSL embeddings on downstream task before FSL training.

### ❌ Pitfall 4: Overfitting to Support Set
**Problem:** FSL model memorizes support set, fails to generalize.
**Fix:** Use episodic training with diverse episodes.

### ❌ Pitfall 5: Ignoring Class Imbalance
**Problem:** Some classes much more common in SSL data.
**Fix:** Balanced episode sampling during FSL training.

---

## Summary

**SSL + FSL Combination:**
1. **Pretrain** encoder on abundant unlabeled data (SSL)
2. **Freeze** or **fine-tune** encoder for FSL task
3. **Train** prototypical network in episodes (FSL)
4. **Evaluate** on unseen classes with few-shot episodes

**Expected gains:** 15-25% absolute accuracy improvement over FSL alone.

**R implementation:** Feasible with `{torch}` + `{torchaudio}`, but requires custom implementations.

**When to use:** Abundant unlabeled data + very few labels (< 10 per class).

**Alternative:** If pretrained models exist, try **transfer learning + FSL** first (simpler).
