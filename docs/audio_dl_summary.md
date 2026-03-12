# Deep Learning Audio Patterns - Executive Summary

Quick reference guide for implementing deep learning audio classification in R.

---

## Core Pipeline

```
Raw Audio → Preprocessing → Spectrogram → CNN/CRNN → Classification
```

### Standard Preprocessing Stack

```r
audio (WAV) → mono → resample(22050 Hz) → normalize → window(5s, 50% overlap)
→ mel-spectrogram(n_mels=128, n_fft=2048) → log scaling → normalization
```

**Key Parameters:**
- Sample rate: 22050 Hz (standard), 16000 Hz (speech)
- Window: 2-5 seconds for bioacoustics
- Hop: 50% overlap (window/2)
- n_mels: 128 (standard)
- n_fft: 2048 (good balance)
- Freq range: Species-specific (e.g., 500-12000 Hz for birds)

---

## Architecture Recommendations

### 1. Baseline: Simple CNN on Log-Mel Spectrograms
**When:** First model, limited data, need interpretability
**Structure:** 3-4 conv blocks (conv → BN → ReLU → pool) → GAP → FC
**Training time:** Fast (~1-2 hours for small dataset)
**Expected performance:** Good baseline, 70-85% accuracy

### 2. Intermediate: CRNN (CNN + LSTM + Attention)
**When:** Temporal context matters, variable-length audio
**Structure:** CNN feature extractor → BiLSTM → Attention pooling → FC
**Training time:** Medium (~3-5 hours)
**Expected performance:** Better temporal modeling, 80-90% accuracy

### 3. Advanced: ResNet-style with Transfer Learning
**When:** More data available, need state-of-art performance
**Structure:** ResNet backbone → Fine-tune → Custom head
**Training time:** Longer (~5-10 hours)
**Expected performance:** Best results, 85-95% accuracy

### 4. For Weak Supervision: MIL with Attention
**When:** Only clip-level labels, not frame-level
**Structure:** CNN → Attention pooling over windows → Classifier
**Use case:** Continuous recordings with presence/absence labels

---

## Data Augmentation Arsenal

**Must-have:**
1. **SpecAugment**: Frequency + time masking (standard in audio)
2. **Mixup**: Mix samples and labels (alpha=0.4 typical)

**Nice-to-have:**
3. **Time stretching**: Speed variation (0.8-1.2x)
4. **Pitch shifting**: ±2 semitones
5. **Noise addition**: Background noise at various SNR levels

**Implementation priority:**
1. Start with SpecAugment only
2. Add mixup if overfitting
3. Add others if still need more data

---

## Handling Class Imbalance

**Strategy ladder (try in order):**

1. **Class weights in loss function** (easiest, start here)
   ```r
   loss_fn <- nn_cross_entropy_loss(weight = class_weights)
   ```

2. **Focal loss** (for extreme imbalance)
   - Downweights easy examples
   - Focuses on hard examples

3. **Weighted sampling** (changes training distribution)
   - Sample minority classes more often
   - Can hurt majority class performance

4. **SMOTE-like oversampling** (in feature space)
   - Generate synthetic samples
   - Use carefully to avoid overfitting

5. **Ensemble methods** (combine multiple approaches)
   - Train separate models per class group
   - Combine predictions

**For bioacoustics:** Usually class weights + focal loss is sufficient.

---

## Critical Validation Strategy

**NEVER split randomly - Audio has severe leakage issues!**

### Correct Approach:
```r
# Split by recording_id, location, or date
# Ensure all windows from same recording in same split

splits <- metadata %>%
  distinct(recording_id, location, date) %>%
  # Split these unique recordings
  initial_split(prop = 0.8)

train_recordings <- training(splits)$recording_id
test_recordings <- testing(splits)$recording_id

train_data <- metadata %>% filter(recording_id %in% train_recordings)
test_data <- metadata %>% filter(recording_id %in% test_recordings)
```

### Why This Matters:
- Adjacent windows are highly correlated
- Same recording in train and test = inflated metrics
- Model won't generalize to new recordings
- Common mistake in audio competitions

---

## Weak Supervision Pattern

**Problem:** Long recordings with only clip-level labels ("species X present somewhere in this 10-minute file")

**Solution:** Multiple Instance Learning (MIL)

**Concept:**
- Treat recording as "bag" of windows
- At least one window should have high score if species present
- Use attention to find which windows matter

**Loss function:**
```r
# Max pooling assumption
clip_prediction = max(window_predictions)
loss = BCE(clip_prediction, clip_label)

# Or attention-weighted pooling (better)
attention_weights = softmax(attention_scores)
clip_prediction = sum(attention_weights * window_predictions)
loss = BCE(clip_prediction, clip_label)
```

**Benefits:**
- Works with weak labels
- Attention weights show which parts have the sound
- Can handle variable-length recordings

---

## Transfer Learning Strategy

**2-Phase Fine-tuning:**

**Phase 1: Frozen Backbone (5-10 epochs)**
```r
# Freeze encoder
for (param in model$encoder$parameters) {
  param$requires_grad_(FALSE)
}

# Train only classifier head
optimizer <- optim_adam(model$classifier$parameters, lr = 0.001)
```

**Phase 2: Full Fine-tuning (20-40 epochs)**
```r
# Unfreeze encoder
for (param in model$encoder$parameters) {
  param$requires_grad_(TRUE)
}

# Train all with lower LR
optimizer <- optim_adam(model$parameters, lr = 0.0001)
```

**Pre-trained Models for Audio:**
- **BirdNET**: Specialized for bird sounds
- **PANNs**: General audio (AudioSet)
- **VGGish**: Google's audio embeddings
- **YAMNet**: Another AudioSet model

**When to use:**
- Limited labeled data (< 1000 samples)
- Similar domain exists
- Need quick results

---

## Inference on Continuous Audio

**Pipeline:**
```
Long audio file → Sliding windows (50% overlap) → Batch predict
→ Smooth predictions (median filter) → Apply thresholds
→ Merge adjacent detections → Export events
```

**Post-processing essentials:**

1. **Smooth predictions** (median filter, k=3-5)
   - Reduces jitter in predictions
   - More stable detections

2. **Species-specific thresholds** (tune on validation set)
   - Different species have different optimal thresholds
   - Common: 0.5-0.8 depending on precision/recall needs

3. **Merge adjacent detections** (gap < 1 second)
   - Group predictions into events
   - Start time, end time, confidence

4. **Confidence calibration** (temperature scaling)
   - Model confidences are often miscalibrated
   - Simple post-hoc fix

---

## Common Pitfalls

### 1. Data Leakage
**Problem:** Random split of windows
**Fix:** Split by recording_id

### 2. Overfitting on Silent Periods
**Problem:** Model learns to predict based on silence/noise
**Fix:** Event detection (ohun) before classification

### 3. Frequency Range Too Broad
**Problem:** Including irrelevant frequencies
**Fix:** Set f_min and f_max based on species biology

### 4. Class Imbalance Ignored
**Problem:** Model only predicts majority class
**Fix:** Class weights or focal loss

### 5. No Augmentation
**Problem:** Model overfits to training examples
**Fix:** At minimum, use SpecAugment

### 6. Wrong Evaluation Metrics
**Problem:** Using accuracy when classes imbalanced
**Fix:** Use F1, precision/recall, or mAP for multi-label

---

## Model Complexity vs. Data Size

**< 500 samples per class:**
- Use transfer learning (frozen backbone)
- Heavy augmentation
- Simple classifier head
- Or classical ML on hand-crafted features

**500-2000 samples per class:**
- Simple CNN (3-4 layers)
- Moderate augmentation
- Consider fine-tuning pre-trained model

**2000-5000 samples per class:**
- CRNN or deeper CNN
- Standard augmentation
- Can train from scratch

**> 5000 samples per class:**
- ResNet-style architectures
- Attention mechanisms
- Advanced techniques (MIL, SSL)

---

## Computational Requirements

### Training:
- **GPU**: Highly recommended (10-50x speedup)
- **RAM**: 16GB minimum, 32GB comfortable
- **Storage**: ~10-50GB for spectrograms (cache if possible)

### Inference:
- **CPU**: Usually sufficient for real-time on short clips
- **GPU**: Needed for batch processing of many files

### R-Specific:
- **torch**: Supports CUDA GPUs on Linux/Windows
- **Apple Silicon**: MPS backend for M1/M2 Macs
- **CPU fallback**: Works but much slower

---

## Quick Start Template

```r
# 1. Preprocessing
audio → mono → resample(22050) → window(5s, 50% overlap)
     → mel_spec(n_mels=128, n_fft=2048, f_min=500, f_max=12000)
     → log() → normalize()

# 2. Model selection
# Start with: Simple CNN
# If temporal matters: Add CRNN
# If weak labels: Use MIL

# 3. Training
# Loss: Cross-entropy with class weights
# Optimizer: Adam (lr=0.001)
# Augmentation: SpecAugment
# Validation: Split by recording_id
# Callbacks: Early stopping (patience=10), LR reduction

# 4. Evaluation
# Metrics: F1 per class, confusion matrix
# Tune thresholds on validation set

# 5. Inference
# Sliding windows → Predictions → Smooth → Threshold → Merge events
```

---

## Key R Packages

**Essential:**
- `{torch}`: Deep learning framework
- `{luz}`: High-level training interface
- `{torchaudio}`: Audio transformations
- `{tuneR}`: Audio I/O

**Supporting:**
- `{tidymodels}`: ML workflow
- `{yardstick}`: Metrics
- `{seewave}`: Acoustic analysis
- `{ohun}`: Event detection

---

## Performance Benchmarks

**Typical results on bioacoustics tasks:**

| Approach | Accuracy | Training Time | Data Requirement |
|----------|----------|---------------|------------------|
| Hand-crafted features + RF | 60-75% | Minutes | Low |
| Simple CNN on log-mel | 70-85% | 1-2 hours | Medium |
| CRNN with attention | 80-90% | 3-5 hours | Medium-High |
| Transfer learning (fine-tuned) | 85-95% | 2-4 hours | Low-Medium |
| ResNet-style from scratch | 85-95% | 5-10 hours | High |

**Factors affecting performance:**
- Data quality and quantity
- Class overlap/similarity
- Background noise levels
- Label accuracy
- Species-specific characteristics

---

## Decision Trees

### When to use CNN vs CRNN?
- **CNN**: If each window is independent, classification based on presence
- **CRNN**: If temporal patterns matter (e.g., song structure, call sequences)

### When to use transfer learning?
- **Yes**: < 2000 samples per class, similar domain exists
- **No**: > 5000 samples per class, very different domain

### When to use weak supervision?
- **Yes**: Only clip-level labels, continuous recordings
- **No**: Frame-level labels available, short clips

### When to use self-supervised learning?
- **Yes**: Lots of unlabeled data, few labeled samples, rare species
- **No**: Plenty of labeled data

---

## Next Steps for Implementation

1. **Week 1: Baseline**
   - Implement preprocessing pipeline
   - Train simple CNN on log-mel spectrograms
   - Establish evaluation protocol

2. **Week 2: Improvements**
   - Add data augmentation (SpecAugment, mixup)
   - Handle class imbalance (weights, focal loss)
   - Try CRNN architecture

3. **Week 3: Advanced**
   - Implement transfer learning
   - Add attention mechanisms
   - Optimize inference pipeline

4. **Week 4: Production**
   - Calibrate thresholds
   - Test on continuous audio
   - Document and deploy

---

## Resources

**Learning:**
- torch.mlverse.org - Official R torch docs
- BirdCLEF competitions - Real-world audio challenges
- "Deep Learning for Audio" papers on arXiv

**Pre-trained Models:**
- BirdNET (GitHub)
- PANNs (GitHub)
- VGGish (TensorFlow Hub)

**Datasets:**
- BirdCLEF (Kaggle)
- AudioSet (Google)
- ESC-50 (environmental sounds)
- AnuraSet (neotropical anurans)

**Key Papers:**
- SpecAugment (Park et al., 2019)
- PANNs (Kong et al., 2020)
- BirdNET (Kahl et al., 2021)
- Weak supervision for birds (Kumar et al., 2021)
