---
name: r-bioacoustics
description: Expert bioacoustic analysis in R using tuneR, seewave, warbleR, bioacoustics, ohun, and soundecology. Use when mentions "análise de áudio em R", "audio analysis in R", "bioacoustics", "bioacústica", "acoustic analysis", "análise acústica", "espectrograma", "spectrogram", "MFCC", "mel-spectrogram", "detecção de eventos sonoros", "event detection", "sound detection", "passive acoustic monitoring", "PAM", "monitoramento acústico passivo", "índices ecoacústicos", "ecoacoustic indices", "acoustic indices", "tuneR", "seewave", "warbleR", "bioacoustics package", "ohun", "soundecology", "feature extraction from audio", "extração de features de áudio", "classificação de sons", "sound classification", "bird sound", "som de aves", "animal sound", "análise de vocalizações", "vocalization analysis", "acoustic ecology", "ecologia acústica", or working with environmental audio, animal vocalizations, or soundscape analysis.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# R Bioacoustics Expert

Expert guidance for bioacoustic analysis in R using the comprehensive ecosystem of tuneR, seewave, warbleR, bioacoustics, ohun, and soundecology packages.

## Overview

This skill provides expert knowledge for analyzing environmental audio, animal vocalizations, and soundscapes in R. It covers:

- **Audio I/O and preprocessing** (tuneR)
- **Spectral and temporal analysis** (seewave)
- **Bioacoustic signal processing** (warbleR)
- **Automated detection and feature extraction** (bioacoustics)
- **Event detection optimization** (ohun)
- **Ecoacoustic indices** (soundecology)

The skill integrates these packages into coherent workflows for Passive Acoustic Monitoring (PAM), species classification, soundscape ecology, and bioacoustic research.

## Core Packages

### tuneR - Audio Foundation
**Purpose**: Audio I/O, basic manipulation, MFCC extraction
**Key Functions**: `readWave()`, `writeWave()`, `melfcc()`, `normalize()`, `downsample()`, `mono()`
**Role**: Foundation for all bioacoustic workflows - handles audio files and basic transformations

### seewave - Comprehensive Analysis
**Purpose**: Advanced spectral/temporal analysis, acoustic indices (200+ functions)
**Key Functions**: `spectro()`, `meanspec()`, `specprop()`, `ACI()`, `H()`, `ffilter()`, `zcr()`
**Role**: Core analysis engine - spectrograms, features, filtering, visualization

### warbleR - Bioacoustic Pipeline
**Purpose**: Streamlined workflow for animal vocalization analysis
**Key Functions**: `auto_detec()`, `specan()` (22 parameters), `cross_correlation()`, `dfDTW()`
**Role**: High-level bioacoustic workflows - detection, measurement, comparison

### bioacoustics - Automated Detection
**Purpose**: Robust automated detection and feature extraction
**Key Functions**: `blob_detection()`, `threshold_detection()`, `acoustic_complexity()`
**Role**: Production-grade detection with Kalman filtering for noisy recordings

### ohun - Detection Optimization
**Purpose**: Optimize detection parameters for your specific recordings
**Key Functions**: `optimize_energy_detector()`, `optimize_template_detector()`
**Role**: Tune detection thresholds to maximize precision/recall trade-offs

### soundecology - Soundscape Indices
**Purpose**: Ecoacoustic indices for biodiversity and soundscape assessment
**Key Functions**: `acoustic_complexity()`, `acoustic_diversity()`, `acoustic_evenness()`
**Role**: Soundscape-level metrics (ACI, ADI, AEI, BI, NDSI)

## Core Workflows

### Workflow 1: Basic Audio Exploration

**Goal**: Load, inspect, and clean audio files

```r
library(tuneR)
library(seewave)

# Load audio
audio <- readWave("recording.wav")

# Inspect
print(audio)  # Sample rate, duration, channels, bit depth
duration(audio)  # Duration in seconds

# Normalize and standardize
audio_norm <- normalize(audio, unit = "16")  # 16-bit normalization

# Convert to mono if stereo
if (audio@stereo) {
  audio_mono <- mono(audio, which = "both")  # Average both channels
}

# Resample to standard rate (e.g., 22050 Hz for birds)
audio_resamp <- downsample(audio_mono, samp.rate = 22050)

# Basic visualization
oscillo(audio_resamp, from = 0, to = 5)  # First 5 seconds
spectro(audio_resamp, flim = c(0, 11))   # Spectrogram up to 11 kHz
```

**Best Practices**:
- Always check sample rate, duration, channels before analysis
- Normalize to consistent amplitude scale
- Mono conversion: `which = "left"`, `"right"`, or `"both"` (average)
- Resample based on target frequencies (e.g., 22050 Hz for birds, 44100 Hz for full range)

### Workflow 2: Spectrogram Analysis

**Goal**: Generate and analyze spectrograms with appropriate parameters

```r
library(seewave)

# High-resolution spectrogram for visualization
spectro(audio,
        wl = 512,           # Window length (FFT size)
        ovlp = 90,          # Overlap percentage (higher = smoother)
        flim = c(2, 10),    # Frequency limits in kHz
        collevels = seq(-40, 0, 1))  # Dynamic range

# Extract frequency spectrum at specific time
spec_t <- spec(audio, at = 2.5, plot = TRUE)  # At 2.5 seconds

# Mean spectrum across entire recording
mean_spec <- meanspec(audio, flim = c(0, 10), plot = TRUE)

# Spectral properties
props <- specprop(mean_spec)
# Returns: mean, sd, median, mode, Q25, Q75, IQR, cent (centroid),
#          skewness, kurtosis, sfm (flatness), sh (entropy)

# Dominant frequency tracking
dom_freq <- dfreq(audio,
                  wl = 512,
                  ovlp = 90,
                  plot = TRUE,
                  threshold = 5)  # In % of amplitude

# Find frequency peaks
peaks <- fpeaks(mean_spec,
                nmax = 5,      # Top 5 peaks
                plot = TRUE)
```

**Parameter Selection**:
- **Window length (`wl`)**:
  - Smaller (256-512): Better temporal resolution, worse frequency resolution
  - Larger (1024-2048): Better frequency resolution, worse temporal resolution
  - Rule: `wl` should be > 2 / min_frequency_of_interest
- **Overlap (`ovlp`)**: 70-90% for smooth spectrograms
- **Frequency limits (`flim`)**: Match your species' vocalization range

### Workflow 3: Automated Signal Detection

**Goal**: Detect vocalization events in continuous recordings

```r
library(warbleR)
library(bioacoustics)
library(ohun)

# Method 1: warbleR auto_detec (amplitude + frequency thresholds)
detections_wr <- auto_detec(
  ssmooth = 300,        # Smoothing for amplitude envelope (ms)
  threshold = 10,       # Amplitude threshold (% of max)
  mindur = 0.05,        # Minimum duration (s)
  maxdur = 2,           # Maximum duration (s)
  bp = c(2, 10),        # Bandpass filter (kHz)
  path = "audio_folder"
)

# Method 2: bioacoustics blob_detection (connected components)
# More robust to noise, uses Kalman filtering
detections_ba <- blob_detection(
  audio,
  time_exp = 5,         # Time expansion factor
  min_dur = 20,         # Min duration (ms)
  max_dur = 2000,       # Max duration (ms)
  min_area = 40,        # Min blob area
  min_TBE = 20,         # Min time between events (ms)
  max_TBE = 5000,       # Max time between events (ms)
  LPF = 10000,          # Low-pass filter (Hz)
  HPF = 2000            # High-pass filter (Hz)
)

# Method 3: ohun energy-based with optimization
# First, create reference detections (manual or from warbleR)
reference <- data.frame(
  sound.files = "recording.wav",
  start = c(1.2, 3.5, 5.8),
  end = c(1.5, 3.9, 6.1)
)

# Optimize detection parameters
opt_params <- optimize_energy_detector(
  reference = reference,
  path = "audio_folder",
  bp = c(2, 10),
  hop.size = 11.6,      # Time resolution (ms)
  wl = 512
)

# Apply optimized detection
detections_oh <- energy_detector(
  files = "recording.wav",
  bp = c(2, 10),
  threshold = opt_params$threshold,  # Optimized
  smooth = opt_params$smooth,        # Optimized
  path = "audio_folder"
)

# Method 4: Template-based detection (for stereotyped calls)
template <- selection_table(
  sound.files = "template.wav",
  start = 0.1,
  end = 0.3
)

template_detections <- template_detector(
  templates = template,
  files = "recording.wav",
  path = "audio_folder",
  cor.method = "pearson"
)
```

**When to Use Each Method**:
- **warbleR `auto_detec()`**: Fast, good for high SNR, simple vocalizations
- **bioacoustics `blob_detection()`**: Best for noisy recordings, complex soundscapes
- **ohun energy**: When you can optimize with reference annotations
- **ohun template**: For stereotyped calls with consistent structure

### Workflow 4: Feature Extraction for Classification

**Goal**: Extract comprehensive acoustic features for machine learning

```r
library(tuneR)
library(seewave)
library(warbleR)
library(bioacoustics)

# Assumes you have detection table from Workflow 3
# Format: sound.files, start, end columns

# Method 1: warbleR specan - 22 spectro-temporal parameters
features_specan <- specan(
  X = detections_wr,
  bp = c(2, 10),
  wl = 512,
  path = "audio_folder"
)
# Returns: duration, meanfreq, sd, freq.median, freq.Q25, freq.Q75,
#          freq.IQR, time.median, time.Q25, time.Q75, time.IQR,
#          skew, kurt, sp.ent, time.ent, entropy, sfm,
#          meandom, mindom, maxdom, dfrange, modindx

# Method 2: Custom feature extraction with seewave
extract_features <- function(audio, start, end) {
  # Extract segment
  seg <- cutw(audio, from = start, to = end, output = "Wave")

  # Time-domain features
  zcr_val <- zcr(seg)
  rms_val <- rms(seg)

  # Frequency-domain features
  spec <- meanspec(seg, plot = FALSE)
  props <- specprop(spec)

  # MFCCs
  mfcc <- melfcc(seg,
                 numcep = 13,          # 13 coefficients
                 wintime = 0.025,      # 25ms window
                 hoptime = 0.010)      # 10ms hop
  mfcc_summary <- colMeans(mfcc)       # Average across time

  # Acoustic indices
  aci_val <- ACI(seg)
  h_val <- H(seg)  # Temporal entropy

  # Combine
  c(
    duration = end - start,
    zcr = zcr_val,
    rms = rms_val,
    spectral_centroid = props$cent,
    spectral_flatness = props$sfm,
    spectral_entropy = props$sh,
    aci = aci_val,
    temporal_entropy = h_val,
    setNames(mfcc_summary, paste0("mfcc_", 1:13))
  )
}

# Apply to all detections
features_custom <- detections_wr |>
  rowwise() |>
  mutate(
    audio = list(readWave(file.path("audio_folder", sound.files))),
    features = list(extract_features(audio[[1]], start, end))
  ) |>
  unnest_wider(features)

# Method 3: bioacoustics features (if using blob_detection)
# Already extracted during detection:
# - duration, freq_max, freq_min, freq_bandwidth, freq_centroid,
# - temp_centroid, area, smoothness, etc.
```

**Feature Engineering Strategy**:
1. **Time-frequency basics**: MFCC, spectral centroid/bandwidth/rolloff, ZCR
2. **Structural**: duration, frequency range, modulation, temporal envelope
3. **Acoustic indices**: ACI, entropy (complement, not primary for classification)
4. **Statistical summaries**: mean, sd, quartiles for time-varying features

See [references/feature-engineering.md](references/feature-engineering.md) for comprehensive feature catalog.

### Workflow 5: Ecoacoustic Indices

**Goal**: Calculate soundscape-level metrics for biodiversity assessment

```r
library(soundecology)
library(seewave)

# Load long recording
audio <- readWave("soundscape_5min.wav")

# Acoustic Complexity Index (ACI)
# Measures heterogeneity - higher = more complex soundscape
aci_result <- acoustic_complexity(audio,
                                   min_freq = 2000,   # Hz
                                   max_freq = 10000,  # Hz
                                   j = 5)             # Cluster size
print(aci_result$AciTotAll_left)

# Acoustic Diversity Index (ADI)
# Based on Shannon entropy of amplitude across frequency bands
adi_result <- acoustic_diversity(audio,
                                  max_freq = 10000,
                                  db_threshold = -50,
                                  freq_step = 1000)
print(adi_result$adi_left)

# Acoustic Evenness Index (AEI)
# Evenness of signal across frequency bands (Gini coefficient)
aei_result <- acoustic_evenness(audio,
                                 max_freq = 10000,
                                 db_threshold = -50,
                                 freq_step = 1000)
print(aei_result$aei_left)

# Bioacoustic Index (BI)
# Area under spectrogram between frequency limits
bi_result <- bioacoustic_index(audio,
                                min_freq = 2000,
                                max_freq = 8000)
print(bi_result$left_area)

# Normalized Difference Soundscape Index (NDSI)
# Ratio of anthrophony to biophony
ndsi_result <- ndsi(audio,
                    fft_w = 1024,
                    anthro_min = 1000,
                    anthro_max = 2000,  # Anthrophony band
                    bio_min = 2000,
                    bio_max = 11000)    # Biophony band
print(ndsi_result$ndsi_left)

# Multiple indices at once
all_indices <- multiple_sounds(
  directory = "soundscape_folder",
  resultfile = "indices_results.csv",
  soundindex = c("acoustic_complexity",
                 "acoustic_diversity",
                 "acoustic_evenness",
                 "bioacoustic_index",
                 "ndsi")
)
```

**When to Use Ecoacoustic Indices**:
- ✅ Soundscape characterization and biodiversity monitoring
- ✅ Comparing acoustic activity across sites or time periods
- ✅ As supplementary features for soundscape classification
- ❌ **Not recommended** as primary features for species classification (limited discrimination)

See [references/ecoacoustic-indices.md](references/ecoacoustic-indices.md) for detailed interpretation guide.

### Workflow 6: Complete PAM Pipeline

**Goal**: End-to-end Passive Acoustic Monitoring workflow

```r
library(tidyverse)
library(tuneR)
library(seewave)
library(warbleR)
library(bioacoustics)
library(ohun)

# 1. PROJECT SETUP
project_dir <- "pam_project"
dir.create(file.path(project_dir, c("raw", "processed", "features", "models", "results")), recursive = TRUE)

# 2. AUDIO STANDARDIZATION
standardize_audio <- function(file_path, output_dir) {
  audio <- readWave(file_path)

  # Mono conversion
  if (audio@stereo) audio <- mono(audio, which = "both")

  # Resample to 22050 Hz
  if (audio@samp.rate != 22050) {
    audio <- downsample(audio, samp.rate = 22050)
  }

  # Normalize
  audio <- normalize(audio, unit = "16")

  # Save
  output_path <- file.path(output_dir, basename(file_path))
  writeWave(audio, output_path)

  return(output_path)
}

# Process all files
raw_files <- list.files("pam_project/raw", pattern = "\\.wav$", full.names = TRUE)
processed_files <- map_chr(raw_files, ~standardize_audio(.x, "pam_project/processed"))

# 3. EVENT DETECTION
# Use optimized parameters from previous runs or optimize
detections <- blob_detection(
  readWave(processed_files[1]),
  time_exp = 1,
  min_dur = 50,
  max_dur = 2000,
  min_area = 40,
  LPF = 11000,
  HPF = 2000
)

# Convert to selection table format
selection_table <- detections |>
  mutate(
    sound.files = basename(processed_files[1]),
    start = starting_time,
    end = starting_time + duration,
    selec = row_number()
  ) |>
  select(sound.files, selec, start, end, duration, freq_min, freq_max)

# 4. FEATURE EXTRACTION
features <- specan(
  X = selection_table,
  bp = c(2, 10),
  wl = 512,
  path = "pam_project/processed"
)

# Add MFCCs
add_mfcc <- function(row, audio_dir) {
  audio <- readWave(file.path(audio_dir, row$sound.files))
  segment <- cutw(audio, from = row$start, to = row$end, output = "Wave")

  mfcc <- melfcc(segment, numcep = 13)
  mfcc_mean <- colMeans(mfcc)

  as_tibble(t(mfcc_mean)) |>
    set_names(paste0("mfcc_", 1:13))
}

mfcc_features <- selection_table |>
  rowwise() |>
  mutate(mfcc = list(add_mfcc(cur_data(), "pam_project/processed"))) |>
  unnest(mfcc)

features_complete <- bind_cols(features, mfcc_features |> select(starts_with("mfcc_")))

# Save features
write_csv(features_complete, "pam_project/features/features.csv")

# 5. MODELING (integrate with tidymodels or mlr3)
# See r-tidymodels or r-datascience skills for ML workflows

# 6. INFERENCE ON CONTINUOUS AUDIO
# Window long recordings and apply model
inference_windowed <- function(audio_path, window_sec = 5, overlap = 0.5) {
  audio <- readWave(audio_path)
  sr <- audio@samp.rate
  duration <- duration(audio)

  hop <- window_sec * (1 - overlap)
  windows <- seq(0, duration - window_sec, by = hop)

  map_dfr(windows, function(start) {
    segment <- cutw(audio, from = start, to = start + window_sec, output = "Wave")

    # Extract features for this window
    # Apply trained model
    # Return predictions

    tibble(
      start_time = start,
      end_time = start + window_sec,
      # ... predictions ...
    )
  })
}
```

**PAM Best Practices**:
1. **Standardization first**: Always resample, normalize, convert to mono
2. **Temporal/spatial splits**: Group by recording_id or site for cross-validation (prevent leakage)
3. **Detection before classification**: Reduce data volume by detecting events first
4. **Class imbalance**: Use class weights, focal loss, or per-species thresholds
5. **Post-processing**: Smooth predictions over time, aggregate overlapping windows
6. **Reproducibility**: Use `{renv}` for dependencies, set seeds, track metadata

See [examples/pam-pipeline.md](examples/pam-pipeline.md) for complete reproducible example.

## Integration Patterns

### Pattern 1: tuneR → seewave Pipeline
```r
# tuneR for I/O and basic manipulation
audio <- readWave("recording.wav") |>
  normalize(unit = "16") |>
  mono(which = "both")

# seewave for analysis
spectro(audio, flim = c(0, 10))
features <- specprop(meanspec(audio, plot = FALSE))
aci <- ACI(audio)
```

### Pattern 2: warbleR Batch Processing
```r
# warbleR excels at batch operations on selection tables
detections <- auto_detec(path = "audio_folder", bp = c(2, 10))
features <- specan(X = detections, path = "audio_folder")
correlations <- cross_correlation(X = detections, path = "audio_folder")
```

### Pattern 3: bioacoustics Detection → seewave Features
```r
# Robust detection with bioacoustics
detections <- blob_detection(audio, min_dur = 50, max_dur = 2000)

# Convert to selection format for seewave
for (i in 1:nrow(detections)) {
  segment <- cutw(audio,
                  from = detections$starting_time[i],
                  to = detections$starting_time[i] + detections$duration[i],
                  output = "Wave")

  # Extract features with seewave
  spec <- meanspec(segment, plot = FALSE)
  features[i, ] <- specprop(spec)
}
```

### Pattern 4: ohun Optimization → Production Detection
```r
# Development: Optimize parameters with reference set
opt <- optimize_energy_detector(
  reference = reference_annotations,
  bp = c(2, 10),
  path = "train_folder"
)

# Production: Apply optimized parameters to new recordings
production_detections <- energy_detector(
  files = list.files("new_recordings"),
  bp = c(2, 10),
  threshold = opt$threshold,
  smooth = opt$smooth,
  path = "new_recordings"
)
```

### Pattern 5: soundecology for Soundscape + warbleR for Species
```r
# Calculate soundscape indices for each 5-min segment
soundscape_summary <- tibble(
  file = list.files("recordings", pattern = "\\.wav$"),
  aci = map_dbl(file, ~acoustic_complexity(readWave(.x))$AciTotAll_left),
  adi = map_dbl(file, ~acoustic_diversity(readWave(.x))$adi_left),
  aei = map_dbl(file, ~acoustic_evenness(readWave(.x))$aei_left)
)

# Detect and classify individual species in same segments
species_detections <- auto_detec(path = "recordings", bp = c(2, 10))
species_features <- specan(X = species_detections, path = "recordings")

# Combine for multi-level analysis
combined <- species_features |>
  left_join(soundscape_summary, by = c("sound.files" = "file"))
```

## Best Practices

### Audio Preprocessing
1. **Always standardize before analysis**:
   - Mono conversion (average both channels if stereo)
   - Fixed sample rate (22050 Hz for birds, 44100 Hz for full range)
   - Normalization to consistent scale
   - High-pass filter to remove DC offset and low-frequency noise

2. **Choose sample rate based on target species**:
   - Birds: 22050-44100 Hz (covers up to 11-22 kHz)
   - Bats: 192000-384000 Hz (ultrasonic)
   - Frogs/amphibians: 22050 Hz
   - Marine mammals: varies widely

3. **Segmentation strategy**:
   - Fixed windows: 2-5 seconds with 50% overlap
   - Event-based: detect events first, extract variable-length segments
   - Hybrid: detect events within fixed windows

### Detection Strategy
1. **Start simple, add complexity**:
   - Baseline: warbleR `auto_detec()` with visual validation
   - If too many false positives: bioacoustics `blob_detection()`
   - If you have reference: ohun optimization
   - For stereotyped calls: ohun template matching

2. **Validation is critical**:
   - Manually annotate 50-100 events as reference
   - Calculate precision, recall, F1 at different thresholds
   - Optimize for your use case (high precision vs high recall)

3. **Handling continuous audio**:
   - Don't analyze entire long recordings at once (memory issues)
   - Use fixed windows (5-10 min) or overlapping chunks
   - Aggregate predictions with temporal smoothing

### Feature Engineering
1. **Feature selection priorities**:
   - **Primary**: MFCC, spectral centroid, bandwidth, duration, frequency range
   - **Structural**: Modulation, temporal envelope, inter-note intervals (if applicable)
   - **Supplementary**: Acoustic indices (ACI, entropy), zero-crossing rate

2. **Avoid redundant features**:
   - Many seewave functions return correlated features
   - Use correlation analysis or PCA to reduce dimensionality
   - Prioritize interpretable features over exhaustive extraction

3. **Time-series summarization**:
   - For time-varying features (e.g., MFCC per frame), compute:
     - Mean, standard deviation, min, max, median
     - Percentiles (Q25, Q75)
     - Delta (first difference) and delta-delta statistics

### Cross-Validation
1. **Prevent temporal/spatial leakage**:
   - Group by `recording_id`, `site_id`, or `date`
   - Use `group_vfold_cv()` in tidymodels or grouped resampling in mlr3
   - **Never** split randomly - adjacent segments are highly correlated

2. **Nested resampling for tuning**:
   - Outer loop: performance estimation (grouped by recording)
   - Inner loop: hyperparameter tuning
   - See `{mlr3}` nested resampling documentation

3. **Class imbalance handling**:
   - Class weights proportional to inverse frequency
   - Focal loss for extreme imbalance
   - Per-species threshold tuning for multi-label scenarios

### Performance Optimization
1. **Batch processing with warbleR**:
   - Use `parallel` argument in warbleR functions
   - Process multiple files simultaneously
   - Example: `specan(X, parallel = 4)`

2. **Memory management for long recordings**:
   - Process in chunks, don't load entire file
   - Use `readWave()` with `from` and `to` parameters
   - Clear objects with `rm()` and `gc()` in loops

3. **Caching intermediate results**:
   - Save detection tables as CSV
   - Save feature tables as RDS or parquet
   - Use `{targets}` or `{drake}` for pipeline management

## Common Code Patterns

### Pattern: Batch Feature Extraction
```r
# Template for extracting features from multiple files
library(tidyverse)
library(tuneR)
library(seewave)

extract_all_features <- function(audio_dir, detection_table) {
  detection_table |>
    rowwise() |>
    mutate(
      # Load audio
      audio = list(readWave(file.path(audio_dir, sound.files))),

      # Extract segment
      segment = list(cutw(audio[[1]], from = start, to = end, output = "Wave")),

      # Extract features
      mfcc = list(colMeans(melfcc(segment[[1]], numcep = 13))),
      spec = list(specprop(meanspec(segment[[1]], plot = FALSE))),
      aci_val = ACI(segment[[1]]),

      # Clean up
      audio = list(NULL),
      segment = list(NULL)
    ) |>
    unnest_wider(spec) |>
    unnest_wider(mfcc, names_sep = "_")
}

features <- extract_all_features("audio_folder", detections)
```

### Pattern: Quality Control Filtering
```r
# Filter detections by quality metrics
filter_detections <- function(detections, min_dur = 0.05, max_dur = 2,
                               min_freq = 1000, max_freq = 12000) {
  detections |>
    filter(
      duration >= min_dur,
      duration <= max_dur,
      freq_min >= min_freq,
      freq_max <= max_freq,
      freq_max - freq_min >= 500  # Minimum bandwidth
    )
}

clean_detections <- filter_detections(raw_detections)
```

### Pattern: Spectrogram Visualization Grid
```r
# Visualize multiple detections in a grid
library(ggplot2)

plot_detection_grid <- function(audio_dir, detections, n = 16) {
  sampled <- slice_sample(detections, n = n)

  plots <- sampled |>
    rowwise() |>
    mutate(
      plot = list({
        audio <- readWave(file.path(audio_dir, sound.files))
        seg <- cutw(audio, from = start, to = end, output = "Wave")

        # Create spectrogram data
        spec_data <- spectro(seg, plot = FALSE)

        # ggplot visualization
        ggspectro(seg, flim = c(2, 10)) +
          labs(title = paste("Det", selec))
      })
    )

  cowplot::plot_grid(plotlist = plots$plot, ncol = 4)
}

plot_detection_grid("audio_folder", detections, n = 16)
```

### Pattern: Export for Raven/Audacity
```r
# Export detection table to Raven selection table format
export_raven <- function(detections, output_file) {
  raven_format <- detections |>
    mutate(
      Selection = selec,
      View = "Spectrogram 1",
      Channel = 1,
      `Begin Time (s)` = start,
      `End Time (s)` = end,
      `Low Freq (Hz)` = freq_min,
      `High Freq (Hz)` = freq_max
    ) |>
    select(Selection, View, Channel, `Begin Time (s)`, `End Time (s)`,
           `Low Freq (Hz)`, `High Freq (Hz)`)

  write_tsv(raven_format, output_file)
}

export_raven(detections, "detections_raven.txt")
```

### Pattern: Reproducible Pipeline with {targets}
```r
# _targets.R
library(targets)
library(tarchetypes)

list(
  tar_target(raw_files, list.files("raw", pattern = "\\.wav$", full.names = TRUE)),
  tar_target(processed_files, standardize_audio(raw_files), pattern = map(raw_files)),
  tar_target(detections, detect_events(processed_files)),
  tar_target(features, extract_features(detections, processed_files)),
  tar_target(model, train_model(features)),
  tar_target(predictions, predict_species(model, features))
)
```

## Integration with Other Skills

- **r-tidymodels**: For training classifiers on extracted features
- **r-deeplearning**: For CNN/CRNN models on spectrograms (see audio section)
- **r-feature-engineering**: For advanced feature selection and encoding
- **r-timeseries**: For temporal pattern analysis in acoustic activity
- **ggplot2**: For custom acoustic visualizations
- **r-performance**: For optimizing large-scale PAM pipelines

## Troubleshooting

**Issue**: `readWave()` fails with "unable to open connection"
- Check file path is correct (use `file.exists()`)
- Verify file format (WAV, not MP4/M4A)
- Try `readMP3()` if file is MP3

**Issue**: Spectrograms look noisy/unclear
- Adjust `wl` (window length) - try 512, 1024, 2048
- Increase `ovlp` (overlap) to 85-95%
- Apply bandpass filter with `ffilter()` before visualization
- Adjust `collevels` to change dynamic range

**Issue**: Too many false positives in detection
- Increase threshold in `auto_detec()` or `energy_detector()`
- Tighten duration constraints (`mindur`, `maxdur`)
- Use narrower bandpass filter (`bp`)
- Switch to `blob_detection()` for better noise handling

**Issue**: Memory issues with long recordings
- Don't load entire file - use `from` and `to` in `readWave()`
- Process in chunks (e.g., 5-minute segments)
- Clear objects regularly with `rm()` and `gc()`
- Consider downsampling if very high sample rate

**Issue**: MFCC extraction fails
- Ensure audio is mono (use `mono()`)
- Check sample rate is reasonable (16000-48000 Hz)
- Reduce `numcep` if too many coefficients requested
- Verify segment duration is sufficient (>0.025s)

## Additional Resources

- **Comprehensive package reference**: [references/package-functions.md](references/package-functions.md)
- **Feature engineering guide**: [references/feature-engineering.md](references/feature-engineering.md)
- **Detection methods comparison**: [references/detection-methods.md](references/detection-methods.md)
- **Complete PAM example**: [examples/pam-pipeline.md](examples/pam-pipeline.md)
- **Preprocessing templates**: [templates/preprocessing.R](templates/preprocessing.R)
- **Detection templates**: [templates/detection.R](templates/detection.R)
- **Feature extraction templates**: [templates/feature-extraction.R](templates/feature-extraction.R)

## Academic References

- **Comprehensive reviews**:
  - Systematic review of ML in ecoacoustics (2023)
  - Advancements in preprocessing, detection and classification for PAM (2024)

- **Methodology papers**:
  - Weakly-supervised bird sound classification (2021)
  - Self-supervised learning for few-shot bird sounds (2023)
  - Refining ecoacoustic indices in ecosystems (2024)

- **Datasets**:
  - AnuraSet: Neotropical anuran dataset
  - BirdCLEF challenges (annual)

See [references/academic-sources.md](references/academic-sources.md) for full citations and links.
