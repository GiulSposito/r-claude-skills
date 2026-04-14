# Ecoacoustic Indices Guide

Comprehensive guide to ecoacoustic indices for soundscape ecology and biodiversity assessment in R.

## Overview

Ecoacoustic indices are acoustic metrics designed to capture soundscape-level patterns related to biodiversity, ecosystem health, and acoustic complexity. They are calculated from recordings spanning minutes to hours and are used primarily for:

- **Biodiversity assessment**: Correlating acoustic complexity with species richness
- **Soundscape monitoring**: Tracking changes in acoustic environments over time
- **Ecosystem health**: Using acoustic activity as proxy for ecological integrity
- **Anthropogenic impact**: Detecting human noise intrusion

**Critical distinction**: These indices are designed for **soundscape ecology**, not **species classification**. While they can be supplementary features in machine learning models, they have limited discriminative power for distinguishing individual species.

## Index Catalog

| Index | Package | Purpose | Typical Range | Interpretation |
|-------|---------|---------|---------------|----------------|
| **ACI** | soundecology, seewave | Temporal complexity | 0-2000+ | Higher = more complex |
| **ADI** | soundecology | Frequency diversity | 0-5 | Higher = more diverse |
| **AEI** | soundecology | Frequency evenness | 0-1 | Higher = more even |
| **BI** | soundecology | Biophony area | 0-100+ | Higher = more biophony |
| **NDSI** | soundecology | Anthrophony vs biophony | -1 to 1 | Positive = more biophony |
| **H (temporal)** | seewave | Temporal entropy | 0-1 | Higher = more variable |
| **H (spectral)** | seewave | Spectral entropy | 0-1 | Higher = more uniform |

## 1. Acoustic Complexity Index (ACI)

### Theory

**Purpose**: Measures temporal variability in acoustic intensity within frequency bands

**Rationale**:
- Biological sounds (birds, insects) tend to have variable intensity over short time scales
- Anthropogenic sounds (traffic, machinery) tend to have constant intensity
- Higher ACI indicates more biological activity

**Formula**: Sum of absolute intensity differences within each frequency band, normalized by total intensity

### Implementation

```r
library(soundecology)
library(tuneR)

# Load audio (5-10 minutes typical)
audio <- readWave("soundscape.wav")

# Calculate ACI
aci_result <- acoustic_complexity(
  soundfile = audio,

  # Frequency range (Hz)
  min_freq = 0,              # Lower limit
  max_freq = 10000,          # Upper limit (species-dependent)

  # Temporal resolution
  j = 5,                     # Cluster size (seconds)
                             # Smaller = finer temporal resolution
                             # Typical: 5-10 seconds

  # FFT parameters
  fft_w = 512                # FFT window size
)

# Extract values
aci_left <- aci_result$AciTotAll_left    # Left channel
aci_right <- aci_result$AciTotAll_right  # Right channel (if stereo)

# Per-frequency band values
aci_by_freq <- aci_result$AciTotAll_left_bymin  # Time series by frequency
```

### Parameters

**Critical parameters**:

- **min_freq/max_freq**: Should match your target taxa. For birds: 2000-10000 Hz. For insects: 1000-8000 Hz.

- **j (cluster size)**: Time window for calculating intensity differences. Smaller j = more sensitive to rapid changes (songbirds). Larger j = captures slower changes (frogs, mammals).

### Interpretation

| ACI Value | Interpretation | Example |
|-----------|----------------|---------|
| < 500 | Low complexity | Urban park, low bird activity |
| 500-1000 | Moderate complexity | Mixed habitat, moderate activity |
| 1000-1500 | High complexity | Dawn chorus, high bird diversity |
| > 1500 | Very high complexity | Peak activity, complex soundscape |

**Important caveats**:
- Sensitive to recording equipment and settings
- Can be inflated by wind noise or rain
- Not directly comparable across different recording setups
- Use **relative comparisons** within same dataset

### When to Use

✅ Comparing acoustic activity across sites (same equipment)
✅ Tracking temporal patterns (diurnal, seasonal)
✅ Detecting changes after disturbance
✅ Screening for high-biodiversity sites

❌ Species classification (low discriminative power)
❌ Absolute biodiversity estimation
❌ Cross-study comparisons (different equipment)

### Example: Diurnal Pattern Analysis

```r
library(tidyverse)
library(soundecology)

# Calculate ACI for 24-hour recording (5-min segments)
files <- list.files("24h_recording", pattern = "\\.wav$", full.names = TRUE)

aci_diurnal <- tibble(file = files) |>
  mutate(
    hour = as.numeric(str_extract(file, "\\d{2}(?=h)")),
    aci = map_dbl(file, ~{
      audio <- readWave(.x)
      acoustic_complexity(audio, min_freq = 2000, max_freq = 10000)$AciTotAll_left
    })
  )

# Plot diurnal pattern
ggplot(aci_diurnal, aes(hour, aci)) +
  geom_line() +
  geom_point() +
  labs(title = "Acoustic Complexity Over 24 Hours",
       x = "Hour of Day", y = "ACI") +
  scale_x_continuous(breaks = seq(0, 23, 3))
```

## 2. Acoustic Diversity Index (ADI)

### Theory

**Purpose**: Measures diversity of acoustic signals across frequency bands

**Rationale**:
- Shannon entropy applied to amplitude distribution across frequency bins
- More diverse soundscape (more species occupying different frequencies) = higher entropy
- Based on information theory: more "surprise" in frequency distribution = more diversity

**Formula**: Shannon entropy of proportion of total amplitude in each frequency band

### Implementation

```r
library(soundecology)

audio <- readWave("soundscape.wav")

adi_result <- acoustic_diversity(
  soundfile = audio,

  # Frequency parameters
  max_freq = 10000,          # Maximum frequency (Hz)
  db_threshold = -50,        # Amplitude threshold (dB)
                             # Bins below this are considered noise
  freq_step = 1000           # Frequency band width (Hz)
                             # Creates bins: 0-1k, 1-2k, ..., 9-10k
)

# Extract ADI
adi <- adi_result$adi_left
adi_max_possible <- adi_result$adi_max  # Maximum possible given bin structure
adi_normalized <- adi / adi_max_possible  # Normalize to 0-1
```

### Parameters

**Critical parameters**:

- **max_freq**: Should match your recording sample rate and target taxa

- **db_threshold**: Filters out background noise. More negative = more permissive. Typical: -40 to -60 dB.

- **freq_step**: Frequency band width. Smaller = finer resolution but more bins. Typical: 500-1000 Hz.

### Interpretation

| ADI (normalized) | Interpretation | Example |
|------------------|----------------|---------|
| < 0.4 | Low diversity | Single species dominates |
| 0.4-0.7 | Moderate diversity | Several species present |
| 0.7-0.9 | High diversity | Many species across frequencies |
| > 0.9 | Very high diversity | Uniform acoustic activity |

**Important**: ADI values depend on number of frequency bins. Always normalize by maximum possible ADI for comparison.

### When to Use

✅ Comparing frequency diversity across habitats
✅ Detecting shift in community composition
✅ Supplementary feature for soundscape classification

❌ Not reliable if single species dominates (even if diverse community present)
❌ Sensitive to noise floor and threshold choice

### Example: Habitat Comparison

```r
# Compare ADI across three habitats
habitats <- c("forest", "grassland", "wetland")

adi_comparison <- habitats |>
  map_dfr(function(habitat) {
    files <- list.files(habitat, pattern = "\\.wav$", full.names = TRUE)

    files |>
      map_dfr(~{
        audio <- readWave(.x)
        result <- acoustic_diversity(audio, max_freq = 10000, db_threshold = -50)
        tibble(
          habitat = habitat,
          file = basename(.x),
          adi = result$adi_left,
          adi_normalized = result$adi_left / result$adi_max
        )
      })
  })

# Statistical comparison
ggplot(adi_comparison, aes(habitat, adi_normalized)) +
  geom_boxplot() +
  labs(title = "Acoustic Diversity Across Habitats",
       y = "Normalized ADI")
```

## 3. Acoustic Evenness Index (AEI)

### Theory

**Purpose**: Measures evenness of acoustic signals across frequency bands

**Rationale**:
- Based on Gini coefficient (inequality measure from economics)
- Perfectly even distribution (all frequency bands have equal amplitude) = 1
- Uneven distribution (energy concentrated in few bands) = closer to 0
- Complements ADI: ADI measures diversity, AEI measures evenness

**Formula**: 1 - Gini coefficient of amplitude distribution across frequency bands

### Implementation

```r
library(soundecology)

audio <- readWave("soundscape.wav")

aei_result <- acoustic_evenness(
  soundfile = audio,

  # Same parameters as ADI
  max_freq = 10000,
  db_threshold = -50,
  freq_step = 1000
)

# Extract AEI
aei <- aei_result$aei_left
```

### Parameters

Same as ADI: `max_freq`, `db_threshold`, `freq_step`

### Interpretation

| AEI | Interpretation | Example |
|-----|----------------|---------|
| < 0.4 | Low evenness | Energy concentrated in few bands |
| 0.4-0.6 | Moderate evenness | Some bands dominate |
| 0.6-0.8 | High evenness | Relatively uniform distribution |
| > 0.8 | Very high evenness | Nearly uniform across frequencies |

**Relationship with ADI**:
- High ADI + High AEI = Diverse and even soundscape (ideal)
- High ADI + Low AEI = Diverse but uneven (some species/bands dominate)
- Low ADI + High AEI = Low diversity but even (not many species, but uniformly distributed)
- Low ADI + Low AEI = Low diversity and uneven (few species in narrow range)

### When to Use

✅ Paired with ADI for comprehensive frequency diversity assessment
✅ Detecting dominance by particular frequency bands
✅ Quality control (very low AEI might indicate equipment issues)

❌ Redundant with ADI if only one metric needed

### Example: ADI vs AEI Scatterplot

```r
# Calculate both ADI and AEI for multiple recordings
soundscape_metrics <- files |>
  map_dfr(function(file) {
    audio <- readWave(file)

    adi <- acoustic_diversity(audio, max_freq = 10000)
    aei <- acoustic_evenness(audio, max_freq = 10000)

    tibble(
      file = basename(file),
      adi = adi$adi_left / adi$adi_max,
      aei = aei$aei_left
    )
  })

# Visualize relationship
ggplot(soundscape_metrics, aes(adi, aei)) +
  geom_point() +
  labs(title = "Acoustic Diversity vs Evenness",
       x = "Normalized ADI", y = "AEI") +
  geom_vline(xintercept = 0.6, linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = 0.6, linetype = "dashed", alpha = 0.5)
```

## 4. Bioacoustic Index (BI)

### Theory

**Purpose**: Measures area under the spectrogram within a frequency band of interest

**Rationale**:
- Simple metric: total acoustic energy in biological frequency range
- Originally designed for bird vocalizations (2-8 kHz)
- Assumes more biological activity = more acoustic energy

**Formula**: Sum of squared amplitudes in target frequency range

### Implementation

```r
library(soundecology)

audio <- readWave("soundscape.wav")

bi_result <- bioacoustic_index(
  soundfile = audio,

  # Frequency band of interest
  min_freq = 2000,           # Lower limit (Hz)
  max_freq = 8000,           # Upper limit (Hz)
                             # Should match target taxa

  # FFT parameters
  fft_w = 512                # FFT window size
)

# Extract BI
bi <- bi_result$left_area
```

### Parameters

**Critical parameters**:

- **min_freq/max_freq**: Define "biophony band". For birds: 2000-8000 Hz. For insects: 1000-10000 Hz. For bats: 20000-100000 Hz.

### Interpretation

| BI Value | Interpretation | Example |
|----------|----------------|---------|
| < 10 | Low activity | Quiet period, few vocalizations |
| 10-30 | Moderate activity | Some vocalizations present |
| 30-60 | High activity | Active period (e.g., dawn chorus) |
| > 60 | Very high activity | Peak activity |

**Important caveats**:
- Very sensitive to recording gain and equipment
- Not comparable across different recording setups
- Can be inflated by wind, rain, or loud individual vocalizers
- Use **only for within-dataset comparisons**

### When to Use

✅ Quick screening for acoustic activity
✅ Detecting peak activity periods
✅ Simple metric when computational resources limited

❌ Not robust to noise
❌ Not directly related to species richness (one loud species can inflate BI)
❌ Cross-study comparisons

### Example: Temporal Activity Pattern

```r
# Calculate BI across 24 hours
bi_temporal <- files |>
  map_dfr(function(file) {
    audio <- readWave(file)
    bi <- bioacoustic_index(audio, min_freq = 2000, max_freq = 8000)

    tibble(
      datetime = parse_datetime(basename(file)),
      bi = bi$left_area
    )
  })

# Plot
ggplot(bi_temporal, aes(datetime, bi)) +
  geom_line() +
  labs(title = "Bioacoustic Activity Over Time",
       x = "Time", y = "Bioacoustic Index")
```

## 5. Normalized Difference Soundscape Index (NDSI)

### Theory

**Purpose**: Ratio of biological sounds (biophony) to human-generated sounds (anthrophony)

**Rationale**:
- Based on NDVI (vegetation index from remote sensing)
- Partitions soundscape into anthrophony (1-2 kHz: traffic, machinery) and biophony (2-11 kHz: birds, insects)
- Ranges from -1 (all anthrophony) to +1 (all biophony)
- Useful for detecting anthropogenic impact

**Formula**: (biophony - anthrophony) / (biophony + anthrophony)

### Implementation

```r
library(soundecology)

audio <- readWave("soundscape.wav")

ndsi_result <- ndsi(
  soundfile = audio,

  # FFT parameters
  fft_w = 1024,              # FFT window size

  # Anthrophony band (human-generated noise)
  anthro_min = 1000,         # Lower limit (Hz)
  anthro_max = 2000,         # Upper limit (Hz)

  # Biophony band (biological sounds)
  bio_min = 2000,            # Lower limit (Hz)
  bio_max = 11000            # Upper limit (Hz)
)

# Extract NDSI
ndsi_val <- ndsi_result$ndsi_left
```

### Parameters

**Critical parameters**:

- **anthro_min/anthro_max**: Frequency band dominated by human noise. Typical: 1000-2000 Hz (low-frequency rumble of traffic).

- **bio_min/bio_max**: Frequency band dominated by biological sounds. Typical: 2000-11000 Hz for birds.

**Note**: These boundaries are **approximate** and context-dependent. In urban areas, anthrophony may extend into higher frequencies (construction, sirens).

### Interpretation

| NDSI Range | Interpretation | Example |
|------------|----------------|---------|
| -1.0 to -0.5 | Heavy anthrophony | Urban center, highway |
| -0.5 to 0.0 | Moderate anthrophony | Suburban park, light traffic |
| 0.0 to 0.5 | Moderate biophony | Rural area, some biological activity |
| 0.5 to 1.0 | Strong biophony | Natural area, high bird activity |

### When to Use

✅ Quantifying human impact on soundscapes
✅ Comparing natural vs disturbed sites
✅ Monitoring restoration success (NDSI should increase)
✅ Temporal analysis (NDSI typically higher at dawn/dusk)

❌ Not suitable for fully natural areas (no anthrophony to contrast)
❌ Band definitions are arbitrary and context-dependent

### Example: Disturbance Gradient

```r
# Compare NDSI across disturbance gradient
sites <- c("natural", "moderate", "disturbed")

ndsi_gradient <- sites |>
  map_dfr(function(site) {
    files <- list.files(site, pattern = "\\.wav$", full.names = TRUE)

    files |>
      map_dfr(~{
        audio <- readWave(.x)
        result <- ndsi(audio, anthro_min = 1000, anthro_max = 2000,
                       bio_min = 2000, bio_max = 11000)
        tibble(
          site = site,
          file = basename(.x),
          ndsi = result$ndsi_left
        )
      })
  })

# Order by disturbance level
ndsi_gradient$site <- factor(ndsi_gradient$site,
                              levels = c("natural", "moderate", "disturbed"))

# Visualize
ggplot(ndsi_gradient, aes(site, ndsi, fill = site)) +
  geom_boxplot() +
  labs(title = "NDSI Across Disturbance Gradient",
       x = "Site Type", y = "NDSI") +
  geom_hline(yintercept = 0, linetype = "dashed")
```

## 6. Entropy Indices (seewave)

### 6.1 Temporal Entropy (H)

**Purpose**: Complexity of amplitude distribution over time

```r
library(seewave)

audio <- readWave("soundscape.wav")

# Temporal entropy
temp_entropy <- H(audio)  # 0-1 scale

# Interpretation:
# 0 = constant amplitude (pure tone)
# 1 = maximum variability (white noise)
```

**Use case**: Distinguishing simple (single species calling) from complex (chorus) soundscapes

### 6.2 Spectral Entropy

**Purpose**: Complexity of frequency distribution

```r
library(seewave)

audio <- readWave("soundscape.wav")

# Spectral entropy
mean_spec <- meanspec(audio, plot = FALSE)
spec_entropy <- sh(mean_spec)  # 0-1 scale

# Alternative: from specprop
props <- specprop(mean_spec)
spec_entropy <- props$sh
```

**Use case**: Distinguishing tonal (low entropy) from noisy/broadband (high entropy) soundscapes

## Combining Multiple Indices

### Comprehensive Soundscape Profile

```r
library(soundecology)
library(seewave)
library(tidyverse)

calculate_soundscape_profile <- function(audio_file) {
  audio <- readWave(audio_file)

  # Ecoacoustic indices
  aci <- acoustic_complexity(audio, min_freq = 2000, max_freq = 10000)
  adi <- acoustic_diversity(audio, max_freq = 10000, db_threshold = -50)
  aei <- acoustic_evenness(audio, max_freq = 10000, db_threshold = -50)
  bi <- bioacoustic_index(audio, min_freq = 2000, max_freq = 8000)
  ndsi_val <- ndsi(audio, anthro_min = 1000, anthro_max = 2000,
                   bio_min = 2000, bio_max = 11000)

  # Entropy indices
  temp_entropy <- H(audio)
  spec_entropy <- sh(meanspec(audio, plot = FALSE))

  # Compile
  tibble(
    file = basename(audio_file),
    aci = aci$AciTotAll_left,
    adi = adi$adi_left / adi$adi_max,  # Normalized
    aei = aei$aei_left,
    bi = bi$left_area,
    ndsi = ndsi_val$ndsi_left,
    temporal_entropy = temp_entropy,
    spectral_entropy = spec_entropy
  )
}

# Apply to all files
soundscape_profiles <- files |>
  map_dfr(calculate_soundscape_profile)

# PCA for dimensionality reduction
pca <- prcomp(soundscape_profiles |> select(-file), scale. = TRUE)

# Biplot
library(ggfortify)
autoplot(pca, data = soundscape_profiles, loadings = TRUE,
         loadings.label = TRUE, loadings.label.size = 3)
```

### Batch Processing with soundecology

```r
library(soundecology)

# Process entire directory
results <- multiple_sounds(
  directory = "soundscape_recordings",
  resultfile = "soundscape_indices.csv",
  soundindex = c(
    "acoustic_complexity",
    "acoustic_diversity",
    "acoustic_evenness",
    "bioacoustic_index",
    "ndsi"
  ),
  no_cores = 4  # Parallel processing
)

# Read results
indices <- read_csv("soundscape_indices.csv")
```

## Best Practices

### 1. Recording Duration

**Minimum**: 1 minute per index calculation (though 5-10 minutes more robust)

**Rationale**: Indices require sufficient temporal coverage to capture variability. Very short recordings (< 30s) produce unreliable estimates.

### 2. Standardization

Always use:
- **Same recording equipment** within study
- **Same gain settings**
- **Same sample rate** (or resample to common rate)
- **Same audio format** (uncompressed WAV preferred)

**Why**: Indices are sensitive to recording parameters. Comparisons across different equipment are unreliable.

### 3. Time of Day

Control for temporal variation:
- Calculate indices for **same time windows** across sites
- Or include time-of-day as covariate
- Dawn chorus (peak bird activity) will have higher ACI/ADI than midday

### 4. Frequency Band Selection

Match frequency bands to your study system:

| Taxa | Recommended Bands |
|------|-------------------|
| Birds | 2000-10000 Hz |
| Frogs | 500-5000 Hz |
| Insects | 1000-8000 Hz |
| Bats | 20000-100000 Hz |
| Marine | 100-20000 Hz |

### 5. Validation

Always validate indices against:
- Manual species counts or richness estimates
- Visual/aural inspection of recordings
- Known disturbance gradients

**Don't assume indices directly correlate with biodiversity** - relationships are context-dependent.

## Limitations and Caveats

❌ **Not species-specific**: Indices capture soundscape-level patterns, not individual species presence/absence

❌ **Confounded by noise**: Wind, rain, human voices, aircraft all affect indices

❌ **Equipment-dependent**: Values not comparable across different recording setups

❌ **No universal threshold**: "High" vs "low" values are relative within dataset

❌ **Limited validation**: Correlations with biodiversity vary across ecosystems

❌ **Dominated by loud species**: Single loud individual can inflate indices

❌ **Frequency band assumptions**: Anthrophony/biophony bands are approximate and context-dependent

## When to Use vs Species Classification Features

| Analysis Goal | Use Ecoacoustic Indices | Use Species-Specific Features |
|---------------|-------------------------|-------------------------------|
| Biodiversity monitoring | ✅ Yes - primary approach | Supplementary |
| Soundscape characterization | ✅ Yes - primary approach | Not applicable |
| Species classification | ❌ No - low discrimination | ✅ Yes - primary approach |
| Habitat comparison | ✅ Yes | Aggregate species detections |
| Temporal patterns | ✅ Yes | Count detections over time |
| Anthropogenic impact | ✅ Yes (especially NDSI) | Species turnover |

**Rule of thumb**:
- Ecoacoustic indices for **community/ecosystem questions**
- Species-specific features (MFCC, spectral) for **individual classification**

## References

- Pieretti et al. (2011): ACI original paper
- Villanueva-Rivera et al. (2011): soundecology package
- Sueur et al. (2008): seewave and acoustic indices
- Refining ecoacoustic indices in ecosystems (2024)
- Systematic review of ML in ecoacoustics (2023)

## Further Reading

- soundecology vignette: `vignette("soundecology")`
- seewave acoustic ecology tutorial: `?seewave::ACI`
- Buxton et al. (2018): "Noise pollution is pervasive in US protected areas" - NDSI application
