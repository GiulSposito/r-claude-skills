# Bioacoustics Use Cases - Multi-Label Audio Classification

Real-world examples of multi-label audio classification for ecological monitoring and conservation.

## Use Case 1: Neotropical Frog Monitoring (AnuraSet-inspired)

### Context

- **Location:** Brazilian Atlantic Forest
- **Target:** 50 anuran species (frogs and toads)
- **Data:** 3-second audio clips from continuous environmental recordings
- **Challenge:** Multiple species calling simultaneously in chorus behavior
- **Class distribution:** Long-tailed (5 common species account for 60% of calls, 25 rare species < 1% each)

### Dataset Characteristics

| Metric | Value |
|--------|-------|
| **Total clips** | 93,000 |
| **Duration** | 27 hours |
| **Sample rate** | 44.1 kHz |
| **Species** | 42 labeled species |
| **Labels per clip** | 0-7 species (mean: 2.3) |
| **Empty clips** | ~15% (no species present) |

### Acoustic Characteristics

**Frequency ranges:**
- Tree frogs: 2-6 kHz (high-pitched calls)
- Ground frogs: 0.5-2 kHz (low-pitched calls)
- Toads: 0.3-1 kHz (deep calls)

**Temporal patterns:**
- Pulse trains: 5-20 pulses/second
- Trills: Continuous for 1-5 seconds
- Single notes: 50-200 ms duration

**Environmental challenges:**
- Rain noise: Broadband 2-8 kHz
- Wind: Low-frequency rumble < 500 Hz
- Insect background: 4-12 kHz (cicadas, crickets)

### Implementation Strategy

#### 1. Preprocessing
```r
# Downsample to 22.05 kHz (sufficient for frog calls < 10 kHz)
# Mel-spectrogram: 128 mels, 2048 FFT, 512 hop length
# Fixed-length: Crop/pad to 3 seconds (66 frames @ 22.05kHz)
# Augmentation: Time masking (20%), frequency masking (15%)
```

#### 2. Model Architecture
```r
# ResNet18 backbone (adapted from torchvision)
# - Input: [batch, 1, 128, 66] (mel-spectrogram)
# - Backbone: ResNet18 (pretrained on ImageNet, fine-tuned)
# - Classifier: FC(512 → 256 → 42)
# - Output: Sigmoid probabilities for 42 species
```

#### 3. Loss and Training
```r
# Weighted BCE loss (pos_weight per species)
# - Common species (weight ~1.0)
# - Rare species (weight ~10-50)
# Optimizer: Adam, lr=1e-3, weight decay=1e-4
# Scheduler: ReduceLROnPlateau (patience=5, factor=0.5)
# Epochs: 50 (early stopping on validation loss)
```

#### 4. Evaluation
**Metrics:**
- Per-class F1 score (most important for conservation)
- Mean Average Precision (mAP)
- Hamming loss
- Exact match ratio

**Results (expected):**
- **Common species (5):** F1 = 75-85%
- **Medium species (17):** F1 = 55-70%
- **Rare species (20):** F1 = 25-45%
- **Overall mean F1:** 60-65%
- **mAP:** 68-72%

### Conservation Applications

1. **Population monitoring:** Track species presence over time
2. **Habitat quality assessment:** Species richness as indicator
3. **Rare species detection:** Alert system for endangered species
4. **Reproductive phenology:** Identify breeding seasons from call patterns

### Springer Paper Reference

This multi-label approach aligns with "Identifying bird species by their calls in Soundscapes" (Springer, 2023), which demonstrates similar techniques for bird call classification in natural soundscapes with overlapping vocalizations.

---

## Use Case 2: Bird Dawn Chorus Monitoring

### Context

- **Location:** Tropical rainforest edge
- **Target:** 80 bird species
- **Data:** 10-second clips from dawn chorus (5:30-7:00 AM)
- **Challenge:** Extreme overlap (10-15 species calling simultaneously at peak)

### Dataset Characteristics

| Metric | Value |
|--------|-------|
| **Total clips** | 15,000 |
| **Duration** | 42 hours |
| **Sample rate** | 48 kHz (high-frequency bird calls) |
| **Species** | 80 species |
| **Labels per clip** | 1-18 species (mean: 6.8) |

### Acoustic Characteristics

**Frequency ranges:**
- Low-frequency (< 1 kHz): Owls, doves, ground-dwelling birds
- Mid-frequency (1-4 kHz): Most passerines
- High-frequency (4-12 kHz): Warblers, flycatchers, hummingbirds

**Temporal patterns:**
- Songs: 1-5 seconds, structured patterns
- Calls: 50-300 ms, simple notes
- Flight calls: Brief (< 100 ms)

**Environmental challenges:**
- Very high overlap (peak density: 15 species/10 sec)
- Distance variation (near vs far birds)
- Weather-dependent (rain suppresses calling)

### Implementation Strategy

#### 1. Preprocessing
```r
# Keep 48 kHz for high-frequency calls
# Mel-spectrogram: 256 mels, 4096 FFT, 512 hop length
# Fixed-length: 10 seconds (938 frames @ 48kHz)
# Augmentation: Time masking (10%), frequency masking (10%), mixup
```

#### 2. Model Architecture
```r
# EfficientNet-B2 backbone
# - Input: [batch, 1, 256, 938]
# - Backbone: EfficientNet-B2 (ImageNet pretrained)
# - Attention pooling: Learn to weight time frames
# - Classifier: FC(1408 → 512 → 80)
# - Output: Sigmoid probabilities for 80 species
```

#### 3. Handling Extreme Overlap

**Problem:** 15 species calling → dense label vector, high confusion

**Solutions:**
- **Focal loss:** Emphasize hard-to-classify examples
- **Attention mechanism:** Let model focus on discriminative time frames
- **Mixup augmentation:** Mix two spectrograms to simulate overlap
- **Threshold tuning:** Lower thresholds for rare species, higher for common

#### 4. Evaluation

**Expected performance:**
- **Mean F1:** 50-60% (lower due to extreme overlap)
- **mAP:** 62-70%
- **Per-species variation:** 20-80% F1 depending on acoustic similarity

**Error analysis:**
- **Confusion clusters:** Similar-sounding species (e.g., flycatchers)
- **Distance effect:** Far birds harder to detect (lower recall)
- **Peak chorus:** Performance drops when > 12 species present

### Applications

1. **Biodiversity assessment:** Species richness in fragmented habitats
2. **Migration monitoring:** Detect passage migrants from calls
3. **Territory mapping:** Spatial patterns from call density
4. **Climate response:** Shifts in phenology (earlier/later dawn chorus)

---

## Use Case 3: Marine Mammal Acoustic Monitoring

### Context

- **Location:** Coastal waters, hydrophone array
- **Target:** 12 marine mammal species
- **Data:** 60-second clips from continuous underwater recordings
- **Challenge:** Variable call rates, long silent periods, distant calls

### Dataset Characteristics

| Metric | Value |
|--------|-------|
| **Total clips** | 50,000 |
| **Duration** | 833 hours |
| **Sample rate** | 96 kHz (ultrasonic dolphin clicks) |
| **Species** | 12 cetacean species |
| **Labels per clip** | 0-4 species (mean: 0.8, many empty) |

### Acoustic Characteristics

**Call types:**
- **Baleen whales:** Low-frequency (< 500 Hz), long duration (5-60 sec)
- **Dolphins:** High-frequency clicks (20-120 kHz), echolocation
- **Seals:** Mid-frequency (1-4 kHz), pulsed calls

**Environmental challenges:**
- Boat noise: Broadband 50-5000 Hz
- Snapping shrimp: Impulsive clicks, 2-5 kHz
- Weather noise: Waves, rain

### Implementation Strategy

#### 1. Preprocessing
```r
# Downsample to 48 kHz (capture most calls, reduce size)
# Mel-spectrogram: 256 mels, 4096 FFT, 1024 hop length
# Fixed-length: 60 seconds (2813 frames)
# Denoise: Spectral subtraction (remove background)
```

#### 2. Temporal Modeling

**Problem:** Calls may occur anywhere in 60-second clip, not uniformly distributed

**Solution: Attention-based pooling**
```r
# Frame-level features: CNN extracts features per time frame
# Attention weights: Learn which frames contain calls
# Weighted pooling: Aggregate features with attention weights
# Classifier: Predict species from pooled features
```

#### 3. Handling Class Imbalance

**Distribution:**
- Common species (dolphins): 40% of clips
- Rare species (blue whale): < 0.5% of clips

**Solutions:**
- Extreme pos_weight for rare species (50-100x)
- Oversampling rare species clips
- Focal loss with high gamma (2.5-3.0)

#### 4. Evaluation

**Metrics:**
- **Recall for rare species:** Critical for conservation
- **Precision:** Avoid false alarms in monitoring systems
- **Per-species ROC-AUC:** Account for imbalance

**Expected performance:**
- **Common species:** F1 = 70-85%
- **Rare species:** Recall = 40-60%, Precision = 50-70%
- **Overall mAP:** 65-75%

### Applications

1. **Ship strike prevention:** Real-time whale detection for vessel routing
2. **Population monitoring:** Presence/absence over seasons
3. **Behavior analysis:** Feeding vs traveling calls
4. **Noise impact assessment:** Changes in call patterns near construction

---

## Use Case 4: Urban Soundscape Monitoring

### Context

- **Location:** Urban park
- **Target:** 30 bird species + noise sources (traffic, voices, construction)
- **Data:** 5-second clips from continuous recording
- **Challenge:** High noise levels, mask bird calls

### Dataset Characteristics

| Metric | Value |
|--------|-------|
| **Total clips** | 20,000 |
| **Duration** | 28 hours |
| **Sample rate** | 44.1 kHz |
| **Species** | 30 bird species |
| **Noise labels** | Traffic, voices, construction, wind |

### Acoustic Characteristics

**Urban noise:**
- Traffic: Broadband 50-2000 Hz
- Voices: 100-4000 Hz
- Construction: Impulsive, broadband

**Bird calls:** Typically 1-8 kHz, must be extracted from noise

### Implementation Strategy

#### 1. Preprocessing
```r
# Mel-spectrogram: 128 mels, 2048 FFT, 512 hop length
# Noise-robust augmentation:
#   - Add urban noise samples (mixup with noise library)
#   - Time/frequency masking
#   - Gaussian noise
```

#### 2. Multi-Task Learning

**Predict both:**
- 30 bird species (primary task)
- 4 noise sources (auxiliary task)

**Rationale:** Noise classification helps model learn noise-invariant bird features

#### 3. Evaluation

**Expected performance:**
- **Clean conditions (SNR > 10 dB):** F1 = 65-75%
- **Noisy conditions (SNR < 5 dB):** F1 = 35-50%
- **Overall:** F1 = 50-60%

### Applications

1. **Urban biodiversity:** Track species richness in cities
2. **Park management:** Identify high-quality acoustic habitats
3. **Noise pollution:** Quantify masking effect on bird communication
4. **Soundscape quality:** Assess "quietness" of urban green spaces

---

## Common Patterns Across Use Cases

### Pattern 1: Hierarchical Evaluation

**Don't just report overall metrics:**
```r
# Stratify by:
- Species rarity (common / medium / rare)
- Acoustic similarity (clustered species)
- Environmental context (noisy / clean)
- Temporal period (peak / off-peak calling)
```

### Pattern 2: Per-Species Threshold Tuning

**Default 0.5 is rarely optimal:**
```r
# Tune per species on validation set:
- High precision species (avoid false alarms): threshold = 0.7
- High recall species (catch all instances): threshold = 0.3
- Balanced: threshold = 0.4-0.6
```

### Pattern 3: Temporal Context Post-Processing

**Smooth predictions over time:**
```r
# If species detected in clip t and t+2 but not t+1:
# → Likely false negative at t+1, fill in prediction
# → Temporal consistency improves recall
```

### Pattern 4: Active Learning

**Prioritize manual labeling:**
```r
# Label clips where model is uncertain:
- High prediction variance across classes
- Species at decision boundary (prob ≈ 0.5)
- Rare species with low confidence
```

---

## Performance Expectations by Scenario

| Scenario | Mean F1 | mAP | Key Challenge |
|----------|---------|-----|---------------|
| **Frog chorus (low overlap)** | 60-70% | 68-75% | Long-tailed distribution |
| **Bird dawn chorus (high overlap)** | 50-60% | 62-70% | Extreme acoustic overlap |
| **Marine mammals (sparse)** | 60-70% | 65-75% | Rare species, class imbalance |
| **Urban birds (noisy)** | 50-60% | 55-65% | High noise levels |

**General rule:** Each 10 dB decrease in SNR costs ~10-15% F1 score.

---

## Key Takeaways for Bioacoustics

1. **Multi-label is the norm:** Natural soundscapes almost always contain multiple species
2. **Class imbalance is severe:** Conservation focus = rare species = low data
3. **Acoustic overlap hurts:** More overlap → lower performance
4. **Noise matters:** SNR is the biggest predictor of performance
5. **Threshold tuning is critical:** Don't use default 0.5
6. **Temporal smoothing helps:** Leverage time-series structure
7. **Per-species evaluation:** Report stratified metrics, not just overall

---

## References

- **AnuraSet:** Oliveira et al. (2023) "AnuraSet: A dataset for classification of anuran sounds"
- **Bird soundscapes:** "Identifying bird species by their calls in Soundscapes" (Springer, 2023)
- **Marine acoustics:** Erbe et al. (2016) "Underwater Passive Acoustic Monitoring"
- **Urban soundscapes:** Buxton et al. (2017) "Noise pollution is pervasive in U.S. protected areas"
