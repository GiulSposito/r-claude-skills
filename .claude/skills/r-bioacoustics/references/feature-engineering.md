# Comprehensive Feature Engineering for Bioacoustics

This guide covers the complete feature extraction toolkit for bioacoustic classification and analysis in R.

## Feature Categories Overview

| Category | Primary Use | Packages | Typical Count |
|----------|-------------|----------|---------------|
| MFCCs | Species classification | tuneR | 13-20 coefficients |
| Spectral | General discrimination | seewave | 10-15 features |
| Temporal | Rhythm and structure | seewave | 5-10 features |
| Structural | Call-specific | warbleR, custom | 5-10 features |
| Ecoacoustic | Soundscape context | seewave, soundecology | 5-8 indices |

**Recommended baseline**: MFCC (13) + spectral centroid/bandwidth/rolloff + duration + frequency range = ~20 features

## 1. Time-Frequency Features

### 1.1 Mel-Frequency Cepstral Coefficients (MFCCs)

**Purpose**: Compact representation of spectral envelope, inspired by human auditory perception

**Why it works**:
- Mel scale approximates human frequency perception (logarithmic above 1000 Hz)
- Cepstral transformation decorrelates features
- Captures vocal tract characteristics
- Standard in speech recognition, highly effective for bird/frog/mammal vocalizations

**Extraction with tuneR**:
```r
library(tuneR)

# Extract MFCCs from audio segment
mfcc_features <- melfcc(
  audio,
  numcep = 13,        # Number of coefficients (12-20 typical)
  wintime = 0.025,    # Window size (25ms standard)
  hoptime = 0.010,    # Hop size (10ms standard)
  nbands = 40,        # Number of mel bands
  minfreq = 0,        # Minimum frequency
  maxfreq = NULL      # Maximum frequency (Nyquist by default)
)

# Returns: matrix with numcep rows, one column per frame
# Typically summarize across time:
mfcc_mean <- colMeans(mfcc_features)
mfcc_sd <- apply(mfcc_features, 1, sd)

# Delta and delta-delta features (velocity and acceleration)
mfcc_delta <- apply(mfcc_features, 1, function(x) diff(x))
mfcc_delta_mean <- rowMeans(mfcc_delta)
```

**Parameter guidance**:
- **numcep**: 13 is standard (includes energy), 12 without energy. More (20-30) can help but increases dimensionality.
- **wintime**: 25ms standard for speech, 20-50ms for animal sounds depending on call structure
- **hoptime**: 50% overlap of wintime is standard
- **nbands**: 40 is typical, more for wider frequency ranges

**Statistical summaries to compute**:
1. Mean of each coefficient across time (13 features)
2. Standard deviation (13 features)
3. Min/max (26 features, if relevant)
4. Delta (first derivative) mean and sd (26 features)
5. Delta-delta (acceleration) mean and sd (26 features)

**Total feature count**: 13 (mean) + 13 (sd) + 13 (delta mean) = 39 features typical

### 1.2 Spectral Centroid

**Purpose**: "Center of mass" of the spectrum - where most energy is concentrated

**Interpretation**:
- Higher centroid = higher-pitched, brighter sound
- Lower centroid = deeper, darker sound
- Useful for distinguishing high-frequency vs low-frequency vocalizers

**Extraction with seewave**:
```r
library(seewave)

# Method 1: From mean spectrum
mean_spec <- meanspec(audio, plot = FALSE)
props <- specprop(mean_spec)
centroid <- props$cent  # In kHz

# Method 2: Time-varying centroid
spec_matrix <- spectro(audio, plot = FALSE)
centroids <- apply(spec_matrix$amp, 2, function(col) {
  freqs <- spec_matrix$freq
  weighted.mean(freqs, col)
})

# Summarize
centroid_mean <- mean(centroids)
centroid_sd <- sd(centroids)
centroid_range <- max(centroids) - min(centroids)
```

**When to use**: Effective for species with distinct frequency ranges (e.g., soprano vs bass frogs)

### 1.3 Spectral Bandwidth

**Purpose**: Spread of frequencies around the centroid (similar to standard deviation)

**Interpretation**:
- Narrow bandwidth = pure tones, whistles
- Wide bandwidth = noisy, broadband calls

**Extraction**:
```r
# Using seewave specprop()
mean_spec <- meanspec(audio, plot = FALSE)
props <- specprop(mean_spec)
bandwidth_sd <- props$sd  # Standard deviation around centroid

# Alternative: Interquartile range
bandwidth_iqr <- props$IQR
```

**When to use**: Distinguishes tonal vs noisy vocalizations (e.g., songbirds vs woodpeckers)

### 1.4 Spectral Rolloff

**Purpose**: Frequency below which X% (typically 85%) of spectral energy is concentrated

**Interpretation**:
- Lower rolloff = energy in low frequencies
- Higher rolloff = energy in high frequencies
- Complements centroid with different weighting

**Extraction**:
```r
# Custom function (not built-in to seewave)
spectral_rolloff <- function(spec, threshold = 0.85) {
  cumsum_energy <- cumsum(spec$amp)
  total_energy <- sum(spec$amp)
  rolloff_idx <- which(cumsum_energy >= threshold * total_energy)[1]
  spec$freq[rolloff_idx]
}

mean_spec <- meanspec(audio, plot = FALSE)
rolloff_85 <- spectral_rolloff(mean_spec, threshold = 0.85)
rolloff_95 <- spectral_rolloff(mean_spec, threshold = 0.95)
```

**When to use**: Often used in music information retrieval, useful for bioacoustics with distinct spectral shapes

### 1.5 Zero-Crossing Rate (ZCR)

**Purpose**: Number of times signal crosses zero amplitude per second

**Interpretation**:
- High ZCR = high-frequency content, noisy
- Low ZCR = low-frequency content, tonal
- Simple but effective discriminator

**Extraction with seewave**:
```r
zcr_val <- zcr(audio)  # Returns single value for entire segment

# Time-varying ZCR
zcr_seq <- zcr(audio, plot = FALSE)  # Vector over time

# Summarize
zcr_mean <- mean(zcr_seq)
zcr_sd <- sd(zcr_seq)
```

**When to use**: Fast to compute, useful as baseline feature. Effective for distinguishing harsh vs smooth calls.

### 1.6 Spectral Flatness (SFM)

**Purpose**: Measure of how tone-like vs noise-like the spectrum is

**Interpretation**:
- High flatness (→1) = white noise, flat spectrum
- Low flatness (→0) = pure tone, peaked spectrum
- Ratio of geometric mean to arithmetic mean of spectrum

**Extraction**:
```r
mean_spec <- meanspec(audio, plot = FALSE)
props <- specprop(mean_spec)
flatness <- props$sfm  # Spectral flatness measure

# Alternative: sfm() function directly
flatness_val <- sfm(meanspec(audio, plot = FALSE))
```

**When to use**: Distinguishes tonal singers (warblers) from noisy calls (owls, frogs with harsh croaks)

### 1.7 Spectral Entropy

**Purpose**: Complexity/disorder of frequency distribution

**Interpretation**:
- High entropy = complex, many frequencies with similar energy
- Low entropy = simple, few dominant frequencies
- Shannon entropy applied to spectrum

**Extraction**:
```r
mean_spec <- meanspec(audio, plot = FALSE)
props <- specprop(mean_spec)
spec_entropy <- props$sh  # Spectral entropy
```

**When to use**: Differentiates simple vs complex calls, complements flatness

## 2. Temporal Features

### 2.1 Duration

**Purpose**: Total length of vocalization

**Extraction**:
```r
# From detection table
duration <- end_time - start_time

# From Wave object
duration_sec <- duration(audio)  # seewave function

# warbleR specan includes this automatically
```

**When to use**: One of the most discriminative features for many species. Essential baseline feature.

### 2.2 Temporal Entropy

**Purpose**: Complexity of amplitude distribution over time

**Interpretation**:
- High entropy = variable amplitude, complex temporal structure
- Low entropy = steady amplitude, simple structure

**Extraction**:
```r
library(seewave)

temporal_entropy <- H(audio)  # Shannon entropy of amplitude envelope

# Alternative: entropy from specprop (frequency entropy)
spec_entropy <- specprop(meanspec(audio, plot = FALSE))$sh
```

**When to use**: Distinguishes pulsed vs continuous calls

### 2.3 RMS Energy

**Purpose**: Root mean square of amplitude - overall loudness/energy

**Extraction**:
```r
rms_val <- rms(audio)

# Time-varying RMS
env <- env(audio, plot = FALSE)  # Amplitude envelope
rms_seq <- sqrt(colMeans(env^2))

# Summarize
rms_mean <- mean(rms_seq)
rms_sd <- sd(rms_seq)
```

**When to use**: Can help distinguish loud vs soft calls, but be careful - often confounded by recording distance/equipment

### 2.4 Crest Factor and Shape Statistics

**Purpose**: Ratio of peak amplitude to RMS - how "spiky" the signal is

**Extraction**:
```r
shape_stats <- csh(audio)
# Returns: M (mean amplitude), dB (sound pressure level), crest factor, etc.

crest_factor <- shape_stats$crest
```

**When to use**: Distinguishes pulsed/click sounds from continuous tones

## 3. Structural Features

### 3.1 Frequency Modulation (FM)

**Purpose**: Rate and extent of frequency change over time

**Extraction**:
```r
library(seewave)

# Dominant frequency tracking
dom_freq <- dfreq(audio, wl = 512, ovlp = 90, plot = FALSE)

# Calculate modulation metrics
fm_range <- max(dom_freq[, 2], na.rm = TRUE) - min(dom_freq[, 2], na.rm = TRUE)
fm_rate <- mean(abs(diff(dom_freq[, 2])), na.rm = TRUE)  # Average change per frame
fm_sd <- sd(dom_freq[, 2], na.rm = TRUE)

# Modulation index from warbleR specan
# modindx = (max(freq) - min(freq)) / bandwidth
```

**When to use**: Critical for species with frequency-modulated calls (many songbirds, bats)

### 3.2 Peak Frequency

**Purpose**: Frequency with maximum energy

**Extraction**:
```r
# Using seewave
peak_freq <- fpeaks(meanspec(audio, plot = FALSE), nmax = 1)

# warbleR specan includes:
# - maxdom: maximum dominant frequency
# - meandom: mean dominant frequency
# - mindom: minimum dominant frequency
```

**When to use**: Complements centroid, often more robust to noise

### 3.3 Fundamental Frequency (F0)

**Purpose**: Lowest frequency component (pitch for harmonic sounds)

**Extraction**:
```r
# Using seewave
f0 <- fund(audio, fmax = 5000, plot = FALSE)

# Time-varying F0
f0_track <- fund(audio, fmax = 5000, plot = FALSE, at = NULL)
f0_mean <- mean(f0_track[, 2], na.rm = TRUE)
f0_sd <- sd(f0_track[, 2], na.rm = TRUE)
```

**When to use**: Essential for harmonic vocalizations (many birds, mammals). Not applicable to broadband/noisy sounds.

### 3.4 Frequency Range and Bandwidth

**Purpose**: Minimum and maximum frequencies, total bandwidth

**Extraction**:
```r
# From detection (bioacoustics blob_detection includes these)
freq_min <- min_frequency
freq_max <- max_frequency
bandwidth <- freq_max - freq_min

# From spectrum
mean_spec <- meanspec(audio, plot = FALSE)
freq_range <- range(mean_spec$freq[mean_spec$amp > threshold])
```

**When to use**: Fundamental discriminator - species occupy different frequency niches

### 3.5 Temporal Centroid

**Purpose**: "Center of mass" of energy distribution over time

**Interpretation**:
- Early centroid = front-loaded energy
- Late centroid = back-loaded energy
- Middle centroid = symmetric distribution

**Extraction**:
```r
# Using bioacoustics output (if using blob_detection)
temp_centroid <- detection$temp_centroid

# Custom calculation
amplitude <- abs(audio@left)
time <- seq(0, length(amplitude) - 1) / audio@samp.rate
temp_centroid <- sum(time * amplitude) / sum(amplitude)
```

**When to use**: Distinguishes attack/decay patterns in calls

## 4. Ecoacoustic Indices

**Important**: These are primarily for soundscape ecology and biodiversity assessment. They provide context but are typically **not recommended as primary features for species classification** due to limited discrimination between species.

### 4.1 Acoustic Complexity Index (ACI)

**Purpose**: Measures temporal variability of acoustic intensity within frequency bands

**Interpretation**:
- Higher ACI = more complex soundscape, more heterogeneity
- Correlates with species richness in some studies
- Sensitive to biophony, less sensitive to constant anthropophony

**Extraction**:
```r
library(soundecology)

aci_result <- acoustic_complexity(audio,
                                   min_freq = 2000,
                                   max_freq = 10000,
                                   j = 5)  # Cluster size (seconds)
aci <- aci_result$AciTotAll_left
```

**Use as feature**: Can be supplementary feature for multi-level models (soundscape + species)

### 4.2 Spectral Entropy (H)

**Purpose**: Disorder of spectral distribution

**Extraction**:
```r
library(seewave)

# Spectral entropy
spec_h <- sh(meanspec(audio, plot = FALSE))

# Or from specprop
spec_h <- specprop(meanspec(audio, plot = FALSE))$sh
```

**Use as feature**: Moderate discriminative power, useful as baseline

### 4.3 Temporal Entropy

**Purpose**: Disorder of temporal amplitude distribution

**Extraction**:
```r
temp_h <- H(audio)
```

**Use as feature**: Useful for distinguishing call structure (pulsed vs continuous)

### 4.4 Other Indices (Soundscape-Level)

These are calculated at soundscape level (minutes), not suitable for individual call classification:

```r
# Acoustic Diversity Index (ADI)
adi_result <- acoustic_diversity(audio, max_freq = 10000)

# Acoustic Evenness Index (AEI)
aei_result <- acoustic_evenness(audio, max_freq = 10000)

# Bioacoustic Index (BI)
bi_result <- bioacoustic_index(audio, min_freq = 2000, max_freq = 8000)

# Normalized Difference Soundscape Index (NDSI)
ndsi_result <- ndsi(audio, anthro_min = 1000, anthro_max = 2000,
                    bio_min = 2000, bio_max = 11000)
```

See [ecoacoustic-indices.md](ecoacoustic-indices.md) for detailed interpretation.

## 5. Statistical Summaries for Time-Varying Features

Many features (MFCC, spectral centroid, dominant frequency, etc.) vary over time. Compute these summaries:

### Standard Summaries
```r
# For any time-varying feature vector x:
feature_mean <- mean(x)
feature_sd <- sd(x)
feature_median <- median(x)
feature_min <- min(x)
feature_max <- max(x)
feature_range <- max(x) - min(x)
feature_q25 <- quantile(x, 0.25)
feature_q75 <- quantile(x, 0.75)
feature_iqr <- IQR(x)
```

### Advanced Summaries
```r
# Skewness and kurtosis
library(moments)
feature_skew <- skewness(x)
feature_kurt <- kurtosis(x)

# Delta statistics (rate of change)
feature_delta <- diff(x)
feature_delta_mean <- mean(feature_delta)
feature_delta_sd <- sd(feature_delta)

# Delta-delta (acceleration)
feature_deltadelta <- diff(feature_delta)
feature_deltadelta_mean <- mean(feature_deltadelta)
```

## 6. Feature Selection Strategy

### Phase 1: Baseline Features (Always Include)

**Essential baseline (~20 features)**:
```r
baseline_features <- c(
  # Temporal
  "duration",

  # Spectral
  "spectral_centroid_mean", "spectral_centroid_sd",
  "spectral_bandwidth",
  "freq_min", "freq_max", "freq_range",

  # MFCCs
  paste0("mfcc_", 1:13, "_mean")
)
```

### Phase 2: Domain-Specific Features

Add based on your specific context:

**For harmonic vocalizations (songbirds, primates)**:
```r
harmonic_features <- c(
  "fundamental_freq_mean", "fundamental_freq_sd",
  "modulation_index",
  "spectral_flatness"  # Lower for harmonic
)
```

**For noisy/broadband calls (owls, amphibians with harsh calls)**:
```r
broadband_features <- c(
  "zero_crossing_rate",
  "spectral_flatness",  # Higher for broadband
  "spectral_rolloff",
  "crest_factor"
)
```

**For frequency-modulated calls (bats, some songbirds)**:
```r
fm_features <- c(
  "fm_range", "fm_rate", "fm_sd",
  "dominant_freq_mean", "dominant_freq_sd"
)
```

**For pulsed/rhythmic calls (insects, some frogs)**:
```r
rhythmic_features <- c(
  "temporal_entropy",
  "pulse_rate",  # Custom: count peaks per second
  "inter_pulse_interval_mean", "inter_pulse_interval_sd"
)
```

### Phase 3: Feature Selection

**After extraction, reduce dimensionality**:

```r
library(tidymodels)

# Correlation-based filtering
recipe <- recipe(species ~ ., data = feature_data) |>
  step_corr(all_numeric_predictors(), threshold = 0.9)  # Remove highly correlated

# Variance-based filtering
recipe <- recipe |>
  step_nzv(all_numeric_predictors())  # Remove near-zero variance

# Boruta or recursive feature elimination
library(Boruta)
boruta_result <- Boruta(species ~ ., data = feature_data)
selected_features <- names(boruta_result$finalDecision[boruta_result$finalDecision == "Confirmed"])
```

## 7. Complete Feature Extraction Template

```r
library(tuneR)
library(seewave)
library(tidyverse)

extract_comprehensive_features <- function(audio) {

  # Ensure mono
  if (audio@stereo) audio <- mono(audio, which = "both")

  # 1. TEMPORAL FEATURES
  duration <- duration(audio)
  rms_val <- rms(audio)
  zcr_val <- zcr(audio)
  temp_entropy <- H(audio)
  shape_stats <- csh(audio)

  # 2. SPECTRAL FEATURES
  mean_spec <- meanspec(audio, plot = FALSE)
  spec_props <- specprop(mean_spec)

  # Peak frequency
  peaks <- fpeaks(mean_spec, nmax = 3, plot = FALSE)

  # Dominant frequency tracking
  dom_freq <- dfreq(audio, wl = 512, ovlp = 90, plot = FALSE, threshold = 5)

  # 3. MFCC FEATURES
  mfcc <- melfcc(audio, numcep = 13)
  mfcc_mean <- colMeans(mfcc)
  mfcc_sd <- apply(mfcc, 1, sd)

  # 4. STRUCTURAL FEATURES
  # Frequency modulation
  fm_range <- max(dom_freq[, 2], na.rm = TRUE) - min(dom_freq[, 2], na.rm = TRUE)
  fm_rate <- mean(abs(diff(dom_freq[, 2])), na.rm = TRUE)

  # 5. COMBINE INTO DATAFRAME
  tibble(
    # Temporal
    duration = duration,
    rms = rms_val,
    zcr = zcr_val,
    temporal_entropy = temp_entropy,
    crest_factor = shape_stats$crest,

    # Spectral
    spectral_centroid = spec_props$cent,
    spectral_bandwidth = spec_props$sd,
    spectral_flatness = spec_props$sfm,
    spectral_entropy = spec_props$sh,
    spectral_skewness = spec_props$skewness,
    spectral_kurtosis = spec_props$kurtosis,

    # Peak frequencies
    peak_freq_1 = peaks$freq[1],
    peak_freq_2 = peaks$freq[2],
    peak_freq_3 = peaks$freq[3],

    # Frequency modulation
    fm_range = fm_range,
    fm_rate = fm_rate,

    # MFCCs
    !!!setNames(as.list(mfcc_mean), paste0("mfcc_", 1:13, "_mean")),
    !!!setNames(as.list(mfcc_sd), paste0("mfcc_", 1:13, "_sd"))
  )
}

# Apply to detection table
features <- detections |>
  rowwise() |>
  mutate(
    audio = list(readWave(sound.files)),
    segment = list(cutw(audio[[1]], from = start, to = end, output = "Wave")),
    features = list(extract_comprehensive_features(segment[[1]]))
  ) |>
  unnest_wider(features)
```

## 8. When to Use Each Feature Type

| Task | Primary Features | Supplementary Features | Avoid |
|------|------------------|------------------------|-------|
| **Bird species classification** | MFCC, spectral centroid, duration, freq range | FM features, temporal entropy | Soundscape indices |
| **Frog call classification** | MFCC, dominant frequency, duration, pulse rate | Spectral features | High-frequency features |
| **Bat call classification** | MFCC, spectral rolloff, bandwidth, duration | ZCR, FM features | Low-frequency features |
| **Soundscape ecology** | ACI, ADI, AEI, NDSI, BI | Spectral entropy, richness metrics | Individual call features |
| **Environmental monitoring** | Detection counts, ACI, spectral features | Species-level features aggregated | Raw MFCCs |
| **Audio quality assessment** | RMS, SNR, spectral flatness, crest factor | - | Species-specific features |

## 9. Performance Considerations

**Fast features** (< 10ms per call):
- Duration, basic statistics
- ZCR, RMS
- Spectral centroid/bandwidth from mean spectrum

**Moderate features** (10-100ms per call):
- MFCCs
- Spectral features from full spectrum
- Dominant frequency tracking

**Slow features** (> 100ms per call):
- Fine-grained fundamental frequency tracking
- Complex acoustic indices (ACI with many bands)
- High-overlap spectrograms

**Optimization tips**:
- Batch process with vectorization
- Cache mean spectrum if extracting multiple spectral features
- Parallelize feature extraction across files with `furrr::future_map()`
- Consider downsampling if sample rate is excessive for target species

## 10. Common Pitfalls

❌ **Too many correlated features**: MFCCs 1-13 + deltas + delta-deltas = 39 highly correlated features. Use PCA or feature selection.

❌ **Confounding by recording equipment**: RMS and absolute frequency measurements can vary by microphone. Normalize or use relative features.

❌ **Ignoring temporal structure**: Summarizing time-varying features loses information. Consider sequence models (LSTM, HMM) or structural features.

❌ **Using soundscape indices for species classification**: ACI, ADI designed for community-level metrics, not discriminative for species.

❌ **Over-extraction**: Extracting 100+ features for 50 samples leads to overfitting. Start with baseline ~20-30 features.

## References

- warbleR `specan()` documentation: 22 spectro-temporal parameters
- tuneR `melfcc()`: MFCC extraction guide
- seewave vignette: Comprehensive acoustic analysis
- Boruta package: Feature selection with random forests
- Systematic review of ML in ecoacoustics (2023)
