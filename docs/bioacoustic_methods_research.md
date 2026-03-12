# Bioacoustic Analysis Methods Research
*Research compilation for r-bioacoustics Claude Code skill development*

Date: 2026-03-11

## Executive Summary

This document synthesizes academic and practical methods for bioacoustic analysis, specifically targeting Passive Acoustic Monitoring (PAM) challenges: continuous audio streams, weak labels, class imbalance, and limited annotated data for understudied species. The research draws from systematic reviews, competition approaches (BirdCLEF), practical datasets (AnuraSet), and R ecosystem capabilities.

**Key Finding**: Modern bioacoustic workflows combine classical feature engineering (spectral indices, MFCCs) with deep learning (CNNs on spectrograms) and increasingly leverage weakly-supervised, semi-supervised, and self-supervised methods to handle real-world PAM constraints.

---

## 1. Bioacoustic Workflows

### Standard Pipeline Architecture

The consensus workflow for bioacoustic analysis follows this structure:

```
Raw Audio → Preprocessing → Segmentation → Feature Extraction → Modeling → Post-processing → Evaluation
```

### 1.1 Preprocessing Phase

**Standardization steps:**
- **Resampling**: Standardize to fixed sample rate (commonly 22.05 kHz or 44.1 kHz)
- **Channel reduction**: Convert stereo to mono
- **Normalization**: Amplitude normalization or loudness standardization
- **Format conversion**: WAV preferred for lossless processing

**Noise reduction (optional):**
- High-pass/low-pass filtering to target frequency range
- Band-pass filtering for known species frequency ranges
- Background noise subtraction

### 1.2 Segmentation Phase

**Continuous audio challenges:**
- Long recordings (hours to days) require chunking
- Need to balance context vs. computational efficiency
- Typical window sizes: 2-5 seconds with 0-50% overlap

**Detection-based segmentation:**
- **Energy-based detection**: Identify periods above amplitude/SNR threshold
- **Template-based detection**: Match known call templates
- **Spectrogram blob detection**: Identify regions of interest in time-frequency space
- Tools: `{ohun}` in R for automatic event detection

**Fixed windowing:**
- Uniform segmentation when continuous monitoring is required
- Ensures consistent processing for soundscape analysis
- Used in BirdCLEF challenges for standardized evaluation

### 1.3 Feature Extraction Approaches

Two parallel paradigms:

**Classical feature engineering** (→ Tabular models)
- Acoustic descriptors computed per segment
- Interpretable, computationally efficient
- Good for baseline models and species with distinct calls

**Representation learning** (→ Neural models)
- Spectrograms as 2D image-like inputs
- Embeddings from pre-trained or self-supervised models
- Better for complex patterns and transfer learning

### 1.4 Modeling Phase

**Three-tier strategy emerging from literature:**

1. **Tabular baselines**: RF, XGBoost, SVM on engineered features
2. **Spectrogram models**: CNNs, CRNNs for time-frequency patterns
3. **Advanced approaches**: Weakly-supervised, few-shot, self-supervised learning

### 1.5 Post-processing Phase

**Temporal smoothing:**
- Adjacent predictions often correlated
- Apply moving average or median filtering
- Aggregate predictions across overlapping windows

**Threshold tuning:**
- Per-species confidence thresholds
- Addresses class imbalance
- Optimized using validation set F1 or precision-recall curves

**Spatial aggregation:**
- When multiple recordings from same location/time
- Vote aggregation or max pooling across recordings

---

## 2. Feature Engineering Strategies

### 2.1 Time-Frequency Features (Classical)

**Fundamental spectral descriptors:**
- **MFCCs** (Mel-Frequency Cepstral Coefficients): Capture timbral characteristics, commonly 13-40 coefficients
- **Delta-MFCCs**: First and second derivatives for temporal dynamics
- **Spectral centroid**: Center of mass of spectrum
- **Spectral bandwidth**: Spread around centroid
- **Spectral rolloff**: Frequency below which X% of energy is contained (e.g., 85%)
- **Zero-crossing rate**: Number of sign changes in time domain
- **Spectral entropy**: Measure of spectral randomness
- **Energy per frequency band**: Power distribution across octaves or mel bands

**R implementation:**
- `{tuneR}`: MFCC extraction, basic spectral features
- `{seewave}`: Comprehensive spectral analysis, entropy, autocorrelation, dominant frequency

**Usage patterns:**
- Good for species with distinct frequency signatures
- Baseline features for interpretable models
- Often combined with boosting (XGBoost) or ensemble methods

### 2.2 Bioacoustic Structural Features

**Event-level measurements:**
- **Duration**: Length of vocal event
- **Frequency range**: Min/max frequency of call
- **Peak frequency**: Dominant frequency component
- **Frequency modulation**: Rate of frequency change
- **Temporal envelope**: Call amplitude contour
- **Inter-note intervals**: Timing between repeated elements
- **Frequency contour**: Time-varying frequency trajectory

**R implementation:**
- `{warbleR}`: Structural quantification of animal signals
- `{bioacoustics}`: Automated detection and measurement (threshold_detection, blob_detection)

**Usage patterns:**
- Species identification based on call structure
- Most effective after signal detection/segmentation
- Often combined with clustering or classification

### 2.3 Ecoacoustic Indices

**Soundscape-level metrics:**
- **ACI** (Acoustic Complexity Index): Variability in amplitude across time
- **ADI** (Acoustic Diversity Index): Shannon diversity of spectrum
- **AEI** (Acoustic Evenness Index): Evenness across frequency bands
- **Bioacoustic Index**: Area under frequency spectrum curve
- **Spectral entropy**: Uncertainty in frequency distribution
- **Temporal entropy**: Uncertainty in amplitude distribution

**R implementation:**
- `{soundecology}`: Suite of ecoacoustic indices

**Usage considerations:**
- Originally designed for biodiversity assessment, not species classification
- Best as supplementary features for "acoustic state" context
- Recent literature suggests limited utility as sole representation for multi-species classification
- Can help with habitat characterization or anomaly detection

### 2.4 Learned Embeddings

**Deep feature representations:**
- **CNN embeddings**: Activations from intermediate layers of trained networks
- **Pre-trained audio models**: AudioSet, PANNs, or domain-specific models
- **Self-supervised embeddings**: Contrastive learning or masked prediction on unlabeled audio

**Advantages:**
- Capture complex patterns beyond hand-crafted features
- Transfer learning from larger datasets
- Particularly valuable for rare species with few examples
- Support few-shot learning scenarios

**R implementation:**
- `{torch}` + `{torchaudio}`: CNN training, spectrogram transformations
- `{keras3}`: Multi-input/multi-output models, transfer learning
- External embeddings can be imported and used with traditional R ML frameworks

---

## 3. Modeling Approaches

### 3.1 Tabular Models (Classical ML)

**Recommended baselines:**
- **Elastic Net / Regularized Logistic**: Simple, interpretable, handles multicollinearity
- **Random Forest**: Robust, handles interactions, provides feature importance
- **XGBoost / LightGBM**: State-of-art for tabular data, handles imbalance well
- **SVM with RBF kernel**: Good for moderate-dimensional feature spaces

**R ecosystem support:**
- `{tidymodels}`: Unified interface, resampling, tuning (see "Tidy Modeling with R")
- `{mlr3}`: Advanced pipelines, benchmarking, nested resampling (see "Applied ML Using mlr3")

**When to use:**
- Quick baselines to assess feature signal
- Interpretability required
- Small to moderate datasets
- Species with clearly distinct acoustic features

### 3.2 Spectrogram-Based Models

**Architecture patterns:**

**2D CNNs:**
- Treat log-mel spectrogram as image (time × frequency)
- Standard architectures: ResNet, EfficientNet, VGG
- Common input: 128-256 mel bins × variable time frames
- Works well for species with distinct visual patterns in spectrogram

**CRNNs (CNN + RNN):**
- CNN layers extract local time-frequency patterns
- RNN layers (LSTM/GRU) capture temporal context
- Better for calls with temporal structure (sequences, phrases)

**Temporal pooling strategies:**
- **Global average/max pooling**: Single prediction per clip
- **Attention pooling**: Weighted aggregation (useful for weak labels)
- **Frame-level predictions**: Dense predictions with post-aggregation

**R implementation:**
- `{torch}`: Full PyTorch ecosystem, custom architectures
- `{torchaudio}`: Spectrogram, mel-spectrogram, PCEN transformations
- `{keras3}`: Higher-level API, pre-built layers, transfer learning support

**Best practices from literature:**
- Log-mel spectrograms most common (vs. linear or MFCC images)
- Data augmentation: SpecAugment, time/frequency masking, mixup
- Multi-scale inputs or multi-branch architectures for diverse call types

### 3.3 Weakly-Supervised Models

**Motivation:** PAM datasets often have clip-level labels (e.g., "species X present in 5-second clip") but lack precise temporal boundaries.

**Multiple Instance Learning (MIL) paradigm:**
- Clip = "bag" of instances (frames or sub-clips)
- Positive bag: at least one positive instance
- Negative bag: all instances negative
- Model learns to identify positive instances without frame-level labels

**Attention-based pooling:**
- Each frame generates embedding
- Attention mechanism weights frames by relevance
- Aggregated embedding fed to classifier
- Attention weights provide interpretability (where in clip species vocalized)

**Implementation pattern:**
```
Spectrogram → CNN backbone → Frame embeddings → Attention pooling → Classifier
```

**Key papers (from roadmap):**
- "Weakly-Supervised Classification and Detection of Bird Sounds in the Wild" (Conde et al., 2021)
- "Recognizing bird species in diverse soundscapes under weak supervision" (Henkel et al., 2021)

**When to use:**
- Clip-level annotations only
- Overlapping vocalizations
- Soundscape recordings (multiple species, noise)
- BirdCLEF-style challenges

### 3.4 Self-Supervised and Few-Shot Learning

**Self-supervised pre-training:**
- Learn representations from unlabeled audio
- Contrastive learning: Similar clips closer in embedding space
- Masked prediction: Predict masked time-frequency patches
- Temporal ordering: Predict correct sequence of audio chunks

**Few-shot learning:**
- Meta-learning or metric learning approaches
- Prototypical networks: Learn class prototypes from few examples
- Siamese/triplet networks: Learn similarity metrics

**Key insight from literature:**
- "Self-supervised learning can acquire meaningful representations of bird sounds from audio recordings without the need for annotations"
- "SSL-derived representations successfully generalize to previously unseen bird species in limited-sample scenarios"

**Data selection strategy:**
- Use pretrained audio neural network to filter windows with high target activation
- Selectively train SSL on relevant audio (not silence/noise)
- Significantly enhances learned representation quality

**When to use:**
- Large unlabeled audio corpus available
- Many rare/understudied species with few labels
- Transfer learning scenarios
- New species identification with minimal training data

**R considerations:**
- Less mature ecosystem than Python for SSL/few-shot
- Can train embeddings in Python, import to R for downstream tasks
- Or use pre-trained embeddings as features for R models

---

## 4. Validation Best Practices

### 4.1 Temporal and Spatial Splitting

**Critical principle:** Avoid data leakage from temporal/spatial autocorrelation.

**Temporal splitting:**
- **DON'T**: Random split of audio segments
- **DO**: Split by recording session, date, or time block
- Rationale: Adjacent segments highly correlated; random split inflates performance
- Implementation: Group by recording ID before splitting

**Spatial splitting:**
- **DON'T**: Mix locations in train/test
- **DO**: Hold out entire locations/sites for testing
- Rationale: Tests generalization to new habitats/acoustic conditions
- Particularly important for PAM deployment

**BirdCLEF approach:**
- Evaluation on soundscapes from different time period or location than training data
- Simulates real-world deployment scenario

### 4.2 Resampling Strategies

**Nested resampling for tuning:**
- Outer loop: Cross-validation or holdout for final performance estimate
- Inner loop: Cross-validation for hyperparameter tuning
- Prevents overfitting tuning process
- Well-documented in `{mlr3}` ecosystem

**Group-based resampling:**
- Groups defined by recording, location, or species
- Ensures groups not split across folds
- `tidymodels::group_vfold_cv()`, `mlr3::ResamplingGroupCV`

**Stratification:**
- Stratify by species (or rarity) to ensure representation
- Important given class imbalance

### 4.3 Handling Class Imbalance

**Common in PAM:** Long-tailed distribution (few common species, many rare species)

**Strategies:**

**Data-level:**
- **Oversampling**: SMOTE or simple duplication of minority classes
- **Undersampling**: Reduce majority classes (risks information loss)
- **Balanced batching**: Ensure each batch has diverse species representation

**Algorithm-level:**
- **Class weights**: Weight loss by inverse class frequency
- **Focal loss**: Down-weight easy examples, focus on hard ones
- Effective for deep learning models

**Post-processing:**
- **Per-class thresholds**: Tune decision threshold per species to optimize F1/recall
- **Calibration**: Calibrate probabilities using validation set

**Evaluation metrics:**
- Avoid accuracy (misleading with imbalance)
- Use: **macro-averaged F1**, **per-class F1**, **PR-AUC**, **mAP** (mean average precision)

### 4.4 Evaluation Protocols

**BirdCLEF/Competition style:**
- Hold-out test set from different temporal or spatial context
- Metrics: macro-averaged F1, mean average precision (mAP)
- Often multiple test sets (e.g., different ecosystems)

**Scientific validation:**
- Report per-species performance (especially for rare species)
- Confusion matrices to identify systematic errors
- Confidence calibration curves
- Qualitative error analysis (misclassifications vs. ambiguous cases)

---

## 5. Domain-Specific Challenges

### 5.1 Class Imbalance and Long-Tailed Distributions

**Reality:** Few abundant species dominate; many rare/endangered species underrepresented.

**Impact:**
- Models biased toward common species
- Poor recall for rare species (the conservation priority)

**Mitigation:**
- Class weighting, focal loss (see §4.3)
- Per-species threshold tuning
- Few-shot learning for rare species
- Transfer learning from related species

### 5.2 Weak and Noisy Labels

**Common annotation types:**
- **Clip-level**: "Species X present somewhere in 5-second clip"
- **Event-level**: Timestamp + species, but imprecise boundaries
- **Crowd-sourced**: Potentially noisy, variable quality

**Challenges:**
- Can't train frame-level models directly
- Presence label doesn't indicate call quality (might be faint, partial)

**Solutions:**
- Weakly-supervised methods (MIL, attention pooling) (see §3.3)
- Noise-robust loss functions
- Active learning to prioritize high-quality annotations
- Multi-annotator consensus

### 5.3 Continuous Audio and Soundscapes

**Characteristics:**
- Hours of recording, sparse species events
- Multiple species overlapping
- Background noise (wind, rain, insects, anthropogenic)
- Varying acoustic conditions

**Challenges:**
- Computational cost of processing entire stream
- High false positive rate if applying per-frame classification
- Overlapping calls difficult to separate

**Solutions:**
- Energy-based pre-filtering to detect candidate events
- Template matching for known species
- Multi-label classification (predict multiple species per clip)
- Temporal smoothing and aggregation of predictions
- Source separation or masking (advanced)

### 5.4 Background Noise and Interference

**Sources:**
- Wind, rain, rustling vegetation
- Anthropogenic noise (traffic, machinery, aircraft)
- Other animals (insects, non-target species)

**Mitigation:**
- Preprocessing: band-pass filtering, noise gating
- Data augmentation: Add noise during training to improve robustness
- Multi-condition training: Include noisy examples
- PCEN (Per-Channel Energy Normalization): Robust front-end for spectrogram
- Denoising as preprocessing (with caution—can remove target signal)

### 5.5 Species with Similar Calls

**Challenge:** Sympatric species may have convergent or overlapping acoustic features.

**Mitigation:**
- Focus on fine-grained structural features (modulation, harmonics)
- Ensemble diverse model types (tabular + CNN)
- Incorporate contextual features (time of day, season, location)
- Use hierarchical classification (genus → species)
- Human-in-the-loop verification for ambiguous cases

---

## 6. Practical Patterns for R-Based Workflows

### 6.1 Project Organization

**Recommended structure:**
```
project/
├── data/
│   ├── raw/              # Original audio files
│   ├── processed/        # Resampled, normalized
│   └── features/         # Extracted feature tables
├── metadata/
│   ├── annotations.csv   # Labels
│   └── recordings.csv    # Recording metadata
├── scripts/
│   ├── 01_preprocess.R
│   ├── 02_detect.R       # Event detection
│   ├── 03_extract_features.R
│   ├── 04_model_tabular.R
│   └── 05_model_spectrogram.R
├── models/               # Saved model objects
├── results/              # Predictions, metrics
└── reports/              # Rmd/Quarto documents
```

### 6.2 Reproducibility Best Practices

**Environment management:**
- `{renv}` for package version control
- Document R version, system info
- Docker for full reproducibility

**Random seeds:**
- Set seeds for train/test split, resampling, model training
- Document seeds in code

**Metadata tracking:**
- Record preprocessing parameters (sample rate, window size, overlap)
- Feature extraction settings
- Model hyperparameters
- Software versions

**Version control:**
- Git for scripts, configs, documentation
- LFS or external storage for large audio/model files

### 6.3 Iterative Development Strategy

**Phase 1: Establish baseline**
- Simple features (MFCCs, spectral descriptors)
- Random Forest or XGBoost
- Proper validation setup
- Document baseline performance

**Phase 2: Feature engineering**
- Add structural features (warbleR, bioacoustics)
- Experiment with ecoacoustic indices
- Feature selection/importance analysis

**Phase 3: Spectrogram models**
- Log-mel spectrogram + CNN (ResNet18 baseline)
- Data augmentation
- Compare with tabular baseline

**Phase 4: Advanced methods**
- Weakly-supervised (if clip-level labels)
- Transfer learning or self-supervised embeddings
- Ensembling

**Phase 5: Deployment preparation**
- Threshold tuning per species
- Temporal post-processing
- Efficiency optimization
- Documentation for non-technical users

### 6.4 Common Pitfalls and How to Avoid

**Pitfall 1: Data leakage**
- Symptom: Unrealistically high validation performance
- Solution: Temporal/spatial splits, group-based CV

**Pitfall 2: Ignoring class imbalance**
- Symptom: High accuracy, poor per-species F1
- Solution: Class weighting, per-class metrics, threshold tuning

**Pitfall 3: Overfitting to training soundscape**
- Symptom: Poor generalization to new locations/recorders
- Solution: Diverse training data, noise augmentation, spatial test split

**Pitfall 4: Over-preprocessing**
- Symptom: Removes target signal (e.g., aggressive noise reduction)
- Solution: Validate preprocessing visually (spectrograms), compare with/without

**Pitfall 5: Inappropriate metrics**
- Symptom: Metrics don't reflect conservation goals (e.g., accuracy when rare species matter)
- Solution: Use macro F1, per-species recall, prioritize rare species performance

---

## 7. R Ecosystem Summary

### 7.1 Audio and Acoustic Analysis

| Package | Primary Use | Key Functions |
|---------|-------------|---------------|
| `tuneR` | Audio I/O, MFCC | `readWave`, `melfcc` |
| `seewave` | Spectral analysis | `spectro`, `dfreq`, `meanspec`, entropy functions |
| `warbleR` | Bioacoustic workflows | `autodetec`, `specan`, `dfDTW` |
| `bioacoustics` | Detection & classification | `threshold_detection`, `blob_detection`, `read_audio` |
| `ohun` | Event detection | Energy-based and template-based detection |
| `soundecology` | Ecoacoustic indices | `acoustic_complexity`, `acoustic_diversity` |

### 7.2 Machine Learning

| Package | Framework | Strengths |
|---------|-----------|-----------|
| `tidymodels` | Unified ML | Tidy API, resampling, recipes (preprocessing pipelines) |
| `mlr3` | Advanced ML | Pipelines, benchmarking, nested resampling, extensive learners |
| `caret` | Legacy (still used) | Wide learner support, older but stable |
| `xgboost` | Gradient boosting | High performance for tabular data |
| `ranger` | Random Forest | Fast RF implementation |

### 7.3 Deep Learning

| Package | Backend | Capabilities |
|---------|---------|--------------|
| `torch` | PyTorch | Full flexibility, custom architectures, GPU |
| `torchaudio` | PyTorch | Audio transforms (spectrogram, mel, PCEN) |
| `keras3` | Keras 3.0 (multi-backend) | High-level API, transfer learning, easier for beginners |

### 7.4 Key References

**Books (free online):**
- *R for Data Science (2e)*: Data wrangling foundation
- *Tidy Modeling with R*: `tidymodels` ecosystem guide
- *Applied Machine Learning Using mlr3 in R*: Advanced ML patterns
- *Feature Engineering and Selection*: Feature creation strategies

**Tutorials:**
- `{ohun}` vignette: Automated sound event detection
- `{warbleR}` vignettes: End-to-end bioacoustic workflows
- `{torch}` documentation: Audio classification examples

---

## 8. Research Paper Insights

### 8.1 Accessible Papers (from roadmap)

**Systematic review of ML in ecoacoustics:**
- URL: https://www.sciencedirect.com/science/article/pii/S2405844023074832
- Key topics: Trends in supervised/unsupervised/semi-supervised methods, species classification, soundscape monitoring
- Note: Full text not accessible via web scraping (paywall), but abstract confirms focus on ML method review

**Weakly-supervised bird sound classification:**
- Papers by Conde et al. (2021) and Henkel et al. (2021)
- URLs: https://arxiv.org/pdf/2107.04878v1, https://arxiv.org/pdf/2107.07728
- Key topics: BirdCLEF competition approaches, MIL, attention pooling, handling clip-level labels
- Note: PDFs contain primarily metadata in accessible format; full technical details require PDF reader

**Self-supervised learning for few-shot bird sounds:**
- URL: https://arxiv.org/abs/2312.15824
- Key insight (from abstract): SSL acquires meaningful representations without annotations; generalizes to unseen species; selective sampling (high activation windows) improves quality
- Recommendation: Highly relevant for rare species scenario

### 8.2 Practical Resources

**AnuraSet dataset (GitHub):**
- URL: https://github.com/soundclim/anuraset
- 93,000 samples, 3-second segments, 42 neotropical anuran species
- Multi-label annotations (overlapping calls)
- Baseline: ResNet18 with PyTorch
- Provides real-world example of long-tailed distribution handling
- Code organization pattern: modular (baseline/, datasets/, config-driven)

**BirdCLEF challenges:**
- URL: https://www.imageclef.org/BirdCLEF2025
- Annual competition on bird sound classification in continuous monitoring
- 2025 focus: Colombia Middle Magdalena Valley, limited training data for rare species
- Key challenge: Leveraging unlabeled data
- Solution approaches: Check Kaggle competition forums and working notes papers for participant methods

**BirdNET-Analyzer:**
- URL: https://github.com/kahst/BirdNET-Analyzer
- State-of-art bird sound classifier (6512 species)
- Python-based, Docker deployment
- Designed for non-CS scientists
- Note: Useful as reference or complementary tool; not directly R-integrated

---

## 9. Recommendations for r-bioacoustics Skill

### 9.1 Skill Scope

The skill should guide users through:

1. **Project setup**: Folder structure, metadata organization, reproducibility
2. **Preprocessing**: Resampling, format conversion, filtering
3. **Feature engineering**: When to use MFCCs, structural features, indices, embeddings
4. **Model selection**: Decision tree for tabular vs. spectrogram vs. advanced methods
5. **Validation**: Temporal/spatial splits, nested resampling, imbalance handling
6. **Evaluation**: Appropriate metrics, per-species analysis
7. **Post-processing**: Temporal smoothing, threshold tuning
8. **Documentation**: Reproducibility, reporting results

### 9.2 Decision Trees to Include

**Feature engineering decision:**
```
Are calls structurally distinct?
  → YES: Structural features (warbleR, bioacoustics)
  → NO: MFCCs, spectrograms

Is interpretability critical?
  → YES: Hand-crafted features + tabular models
  → NO: Deep features + CNNs

Do you have large unlabeled corpus?
  → YES: Consider self-supervised embeddings
  → NO: Stick to supervised features
```

**Model selection decision:**
```
Data size:
  → Small (<1000 samples): Tabular models, transfer learning, few-shot
  → Medium: Tabular + CNN comparison
  → Large (>10k): Deep learning primary focus

Label type:
  → Frame-level: Direct CNN/CRNN
  → Clip-level (weak): MIL, attention pooling
  → No labels: Self-supervised, clustering

Species count:
  → Few (<10): Simpler models, focus on feature quality
  → Many (>50): Deep learning, hierarchical classification
```

### 9.3 Code Templates to Provide

**Preprocessing pipeline:**
```r
library(tuneR)
library(dplyr)

# Standardize audio
preprocess_audio <- function(file_path, target_sr = 22050) {
  wave <- readWave(file_path)
  wave <- normalize(wave)  # Amplitude normalization
  if (wave@samp.rate != target_sr) {
    wave <- resample(wave, target_sr)
  }
  wave
}
```

**Feature extraction (tabular):**
```r
library(tuneR)
library(seewave)

extract_features <- function(wave, window_sec = 3) {
  # MFCCs
  mfccs <- melfcc(wave, numcep = 20)

  # Spectral features
  spec <- meanspec(wave, plot = FALSE)
  spectral_centroid <- mean(spec[,1] * spec[,2]) / sum(spec[,2])
  spectral_entropy <- sh(spec)

  # Temporal features
  zcr <- zcr(wave)

  tibble(
    mfcc_mean = list(colMeans(mfccs)),
    spec_centroid = spectral_centroid,
    spec_entropy = spectral_entropy,
    zcr_mean = mean(zcr)
  )
}
```

**Validation split (temporal):**
```r
library(tidymodels)
library(dplyr)

# Group by recording to prevent leakage
data_splits <- data %>%
  group_initial_split(group = recording_id, prop = 0.8, strata = species)

train_data <- training(data_splits)
test_data <- testing(data_splits)
```

**Class imbalance handling:**
```r
library(recipes)

recipe_obj <- recipe(species ~ ., data = train_data) %>%
  step_smote(species, over_ratio = 0.8) %>%  # SMOTE oversampling
  prep()

# Or with model-level weights
class_weights <- train_data %>%
  count(species) %>%
  mutate(weight = 1 / n) %>%
  mutate(weight = weight / sum(weight))
```

### 9.4 Common Workflows to Document

**Workflow 1: Rapid baseline (tabular)**
1. Segment audio to 3s windows
2. Extract MFCCs + spectral features (tuneR, seewave)
3. Train Random Forest with tidymodels
4. Temporal validation split
5. Evaluate with macro F1

**Workflow 2: Spectrogram CNN**
1. Generate log-mel spectrograms (torchaudio)
2. Data augmentation (time mask, frequency mask)
3. Train ResNet18 with torch
4. Attention pooling for clip-level prediction
5. Threshold tuning per species

**Workflow 3: Event detection + classification**
1. Energy-based detection (ohun) to find candidate events
2. Extract structural features (warbleR) for each event
3. Train classifier on detected events
4. Apply to continuous audio
5. Post-processing: temporal smoothing

**Workflow 4: Weakly-supervised (clip-level labels)**
1. Generate frame embeddings (CNN)
2. Attention-based pooling
3. Clip-level loss
4. Visualize attention weights to interpret predictions

### 9.5 Validation Patterns

**Pattern 1: Temporal split with nested resampling**
```r
library(mlr3)

# Outer: temporal holdout
outer_split <- split_by_time(data, cutoff_date = "2025-06-01")

# Inner: cross-validation for tuning (grouped by recording)
inner_resampling <- rsmp("cv", folds = 5)$instantiate(
  task, groups = task$data()$recording_id
)
```

**Pattern 2: Spatial cross-validation**
```r
library(tidymodels)

# Hold out entire locations
spatial_folds <- group_vfold_cv(data, group = location_id, v = 5)

# Tune hyperparameters respecting spatial structure
tune_results <- tune_grid(
  model_spec,
  preprocessor,
  resamples = spatial_folds,
  grid = param_grid
)
```

---

## 10. References and Sources

### Academic Papers (from roadmap)
1. Systematic review of ML in ecoacoustics: https://www.sciencedirect.com/science/article/pii/S2405844023074832
2. Weakly-supervised bird sound classification (Conde et al., 2021): https://arxiv.org/pdf/2107.04878v1
3. Recognizing bird species under weak supervision (Henkel et al., 2021): https://arxiv.org/pdf/2107.07728
4. Self-supervised learning for few-shot bird sounds: https://arxiv.org/abs/2312.15824

### Practical Resources
5. BirdCLEF challenges: https://www.imageclef.org/BirdCLEF2025
6. AnuraSet dataset: https://github.com/soundclim/anuraset
7. BirdNET-Analyzer: https://github.com/kahst/BirdNET-Analyzer

### R Package Documentation
8. tuneR: https://cran.r-project.org/package=tuneR
9. seewave: https://cran.r-project.org/package=seewave
10. warbleR: https://cran.r-project.org/package=warbleR
11. bioacoustics: https://cran.r-project.org/web/packages/bioacoustics/
12. ohun: https://cran.r-project.org/web/packages/ohun/
13. soundecology: https://cran.r-project.org/web/packages/soundecology/
14. torch: https://torch.mlverse.org/
15. tidymodels: https://www.tidymodels.org/
16. mlr3: https://mlr3book.mlr-org.com/

### Books (free online)
17. R for Data Science (2e): https://r4ds.hadley.nz/
18. Tidy Modeling with R: https://www.tidymodels.org/books/tmwr/
19. Applied Machine Learning Using mlr3 in R: https://mlr3book.mlr-org.com/
20. Feature Engineering and Selection: https://feat.engineering/

---

## Document Status

**Version**: 1.0
**Last Updated**: 2026-03-11
**Purpose**: Inform r-bioacoustics Claude Code skill development
**Next Steps**: Integrate methodological guidance into skill SKILL.md and supporting files
