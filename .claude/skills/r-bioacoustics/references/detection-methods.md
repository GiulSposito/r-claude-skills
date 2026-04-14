# Detection Methods Comparison

Comprehensive comparison of acoustic event detection methods in R, covering warbleR, bioacoustics, and ohun packages.

## Overview

Detection is the critical first step in passive acoustic monitoring - identifying temporal and frequency boundaries of vocalizations in continuous recordings. The choice of detection method significantly impacts downstream classification performance.

## Detection Methods Summary

| Method | Package | Approach | Speed | Robustness to Noise | Use Case |
|--------|---------|----------|-------|---------------------|----------|
| **auto_detec** | warbleR | Amplitude + frequency thresholds | Fast | Moderate | High SNR, simple calls |
| **blob_detection** | bioacoustics | Connected components + Kalman | Moderate | High | Noisy recordings, complex soundscapes |
| **energy_detector** | ohun | Optimizable energy thresholds | Fast | Moderate-High | When reference annotations available |
| **template_detector** | ohun | Cross-correlation matching | Slow | High | Stereotyped calls, known templates |

## 1. warbleR auto_detec()

### Algorithm

**Approach**: Amplitude envelope detection with bandpass filtering

1. Apply bandpass filter to focus on target frequency range
2. Calculate amplitude envelope with smoothing
3. Identify segments exceeding amplitude threshold
4. Filter by duration constraints

### Code Example

```r
library(warbleR)

detections <- auto_detec(
  # Input
  path = "audio_folder",           # Directory with WAV files

  # Bandpass filter
  bp = c(2, 10),                   # Frequency range (kHz)

  # Amplitude detection
  threshold = 10,                  # Threshold (% of max amplitude)
  ssmooth = 300,                   # Envelope smoothing (ms)

  # Duration constraints
  mindur = 0.05,                   # Minimum duration (s)
  maxdur = 2,                      # Maximum duration (s)

  # Output
  output = "data.frame",           # Return format
  img = FALSE                      # Don't save detection images
)

# Returns: data.frame with columns
# - sound.files: filename
# - selec: detection number
# - start: start time (s)
# - end: end time (s)
# - bottom.freq: low frequency (kHz)
# - top.freq: high frequency (kHz)
```

### Parameters

**Critical parameters**:

- **bp (bandpass)**: Most important. Should match your target species' frequency range. Too narrow = miss calls, too wide = more noise.

- **threshold**: Balance between precision (high threshold = fewer false positives) and recall (low threshold = catch more calls). Typical range: 5-20%.

- **ssmooth**: Smoothing window for amplitude envelope. Longer calls need more smoothing. Typical: 200-500ms.

- **mindur/maxdur**: Hard constraints. Use domain knowledge (e.g., bird chips are 0.05-0.2s, frog calls 0.5-2s).

### Strengths

✅ Very fast - can process hours of audio quickly
✅ Simple, intuitive parameters
✅ Works well for high SNR recordings
✅ Good for well-isolated, amplitude-distinct calls
✅ Integrated with warbleR pipeline (specan, cross_correlation)

### Weaknesses

❌ Sensitive to background noise
❌ Struggles with overlapping calls
❌ Fixed thresholds don't adapt to varying SNR
❌ No spectral shape information (only amplitude + frequency range)
❌ Tends to split long modulated calls into multiple detections

### When to Use

- Initial exploration of new datasets
- High-quality recordings with clear calls
- When speed is priority
- Simple, stereotyped vocalizations
- As baseline before trying more complex methods

### Parameter Tuning Strategy

```r
# 1. Start with wide bandpass
detections_wide <- auto_detec(bp = c(0.5, 12), threshold = 15)

# 2. Visualize frequency distribution
hist(detections_wide$top.freq - detections_wide$bottom.freq)

# 3. Narrow bandpass based on actual call frequencies
detections_narrow <- auto_detec(bp = c(3, 8), threshold = 12)

# 4. Tune threshold by visual validation
# Higher threshold = fewer detections, higher precision
# Lower threshold = more detections, lower precision

# 5. Iterate on duration constraints
table(cut(detections_narrow$end - detections_narrow$start,
          breaks = seq(0, 5, 0.5)))
```

## 2. bioacoustics blob_detection()

### Algorithm

**Approach**: Connected components analysis with Kalman filtering

1. Generate spectrogram
2. Apply threshold to create binary image
3. Identify connected components (blobs) in time-frequency space
4. Apply Kalman filter to smooth blob boundaries
5. Extract blob features (duration, frequency range, area, etc.)
6. Filter by constraints (duration, area, time between events)

**Key innovation**: Kalman filtering makes it robust to noise by predicting blob trajectories

### Code Example

```r
library(bioacoustics)
library(tuneR)

# Load audio
audio <- readWave("recording.wav")

# Detect events
detections <- blob_detection(
  audio,

  # Time expansion (for bat recordings, 1 for real-time)
  time_exp = 1,

  # Duration constraints (ms)
  min_dur = 50,                    # Minimum duration
  max_dur = 2000,                  # Maximum duration

  # Blob constraints
  min_area = 40,                   # Minimum blob area

  # Time between events (ms)
  min_TBE = 20,                    # Minimum time between events
  max_TBE = 5000,                  # Maximum time between events

  # Frequency filtering (Hz)
  LPF = 10000,                     # Low-pass filter
  HPF = 2000,                      # High-pass filter

  # Sensitivity
  blur = 2,                        # Gaussian blur radius
  bg_substract = 10,               # Background noise subtraction

  # FFT parameters
  FFT_size = 512,
  FFT_overlap = 0.875
)

# Returns: data.frame with rich features per detection
# - starting_time: start time (s)
# - duration: duration (ms)
# - freq_max, freq_min: frequency range (kHz)
# - freq_bandwidth: bandwidth (kHz)
# - freq_centroid: spectral centroid (kHz)
# - temp_centroid: temporal centroid
# - area: blob area
# - smoothness: blob smoothness metric
# - ... and more
```

### Parameters

**Critical parameters**:

- **min_dur/max_dur**: Duration constraints. More flexible than warbleR because of spectral information.

- **min_area**: Blob area in time-frequency space. Filters out small noise blobs. Larger = more conservative.

- **HPF/LPF**: Frequency filtering. Similar to warbleR bp but separate high/low pass.

- **blur**: Smoothing before blob detection. Higher = merge nearby components. Typical: 1-3.

- **bg_substract**: Background noise level (dB). Higher = more aggressive noise reduction. Typical: 5-15.

### Strengths

✅ Excellent noise robustness (Kalman filtering)
✅ Handles overlapping calls better
✅ Rich feature set extracted automatically (17 features per detection)
✅ Spectral shape information (not just amplitude)
✅ Originally designed for bats, works well for all taxa
✅ Doesn't split long calls as much as auto_detec

### Weaknesses

❌ Slower than auto_detec (spectral processing + Kalman filter)
❌ More parameters to tune
❌ Less intuitive than simple threshold
❌ Can merge closely-spaced calls into single detection
❌ Memory intensive for very long recordings

### When to Use

- Noisy recordings (field conditions, wind, rain)
- Overlapping vocalizations (choruses, multi-species)
- When you need extracted features immediately
- Production systems where robustness > speed
- Complex soundscapes
- When warbleR produces too many false positives

### Parameter Tuning Strategy

```r
# 1. Start with permissive parameters
detections_permissive <- blob_detection(
  audio,
  min_dur = 20,
  max_dur = 5000,
  min_area = 20,
  LPF = 20000,
  HPF = 1000,
  bg_substract = 5
)

# 2. Examine feature distributions
hist(detections_permissive$duration)
hist(detections_permissive$freq_bandwidth)
hist(detections_permissive$area)

# 3. Tighten constraints based on target species
detections_filtered <- blob_detection(
  audio,
  min_dur = 50,      # Based on histogram
  max_dur = 2000,
  min_area = 40,     # Filter small noise blobs
  LPF = 10000,       # Match species range
  HPF = 2000,
  bg_substract = 10  # Increase if noisy
)

# 4. Validate visually
# Listen to detections, adjust parameters iteratively
```

## 3. ohun energy_detector()

### Algorithm

**Approach**: Optimizable energy-based detection

1. Calculate energy envelope with smoothing
2. Apply threshold to identify events
3. Filter by duration
4. **Key feature**: Parameters can be optimized against reference annotations

### Code Example

```r
library(ohun)

# Step 1: Create reference annotations (manual or from warbleR)
reference <- data.frame(
  sound.files = c("rec1.wav", "rec1.wav", "rec2.wav"),
  start = c(1.2, 3.5, 0.8),
  end = c(1.5, 3.9, 1.1)
)

# Step 2: Optimize parameters
optimization <- optimize_energy_detector(
  reference = reference,
  path = "audio_folder",

  # Fixed parameters
  bp = c(2, 10),                   # Bandpass filter
  hop.size = 11.6,                 # Time resolution (ms)
  wl = 512,                        # Window length

  # Parameters to optimize
  threshold = c(5, 10, 15, 20),    # Try multiple thresholds
  smooth = c(5, 10, 15),           # Try multiple smoothing values

  # Optimization metric
  max.overlap = 0.5                # Maximum allowed overlap with reference
)

# Returns: data.frame with performance metrics
# - threshold, smooth: parameter combination
# - recall: proportion of reference detections found
# - precision: proportion of detections that are correct
# - f1_score: harmonic mean of precision and recall

# Step 3: Select best parameters
best_params <- optimization |>
  filter(f1_score == max(f1_score))

# Step 4: Apply to new recordings
detections <- energy_detector(
  files = list.files("new_recordings", pattern = "\\.wav$"),
  path = "new_recordings",
  bp = c(2, 10),
  threshold = best_params$threshold,
  smooth = best_params$smooth,
  hop.size = 11.6,
  wl = 512
)
```

### Parameters

**Fixed parameters**:
- **bp**: Bandpass filter (same as warbleR)
- **hop.size**: Time resolution in ms (smaller = finer temporal precision, slower)
- **wl**: FFT window length (power of 2)

**Optimized parameters**:
- **threshold**: Energy threshold (0-100, arbitrary units)
- **smooth**: Smoothing window (number of frames)

### Strengths

✅ Optimization removes guesswork - finds best parameters automatically
✅ Transparent performance metrics (precision, recall, F1)
✅ Fast once optimized
✅ Can target specific precision/recall trade-offs
✅ Works well with limited reference annotations (50-100 examples)
✅ Reproducible - same parameters across datasets with similar characteristics

### Weaknesses

❌ Requires reference annotations (manual effort upfront)
❌ Optimization can be slow for large parameter grids
❌ Performance depends on quality of reference set
❌ Still threshold-based (similar limitations to auto_detec for noise)
❌ Doesn't extract features automatically

### When to Use

- You have (or can create) reference annotations for a subset
- You need optimized, reproducible parameters
- Deploying to production - want to maximize precision or recall
- Comparing performance across different methods
- When you have time to invest in optimization upfront

### Optimization Strategy

```r
# 1. Create diverse reference set
# - Include calls from different SNR conditions
# - Include different call types if multi-species
# - Aim for 50-100 examples minimum

# 2. Define parameter grid
# Start broad, then narrow
threshold_grid <- seq(5, 30, by = 5)
smooth_grid <- seq(5, 20, by = 5)

# 3. Optimize
opt <- optimize_energy_detector(
  reference = reference,
  path = "audio_folder",
  bp = c(2, 10),
  threshold = threshold_grid,
  smooth = smooth_grid
)

# 4. Examine trade-offs
library(ggplot2)
ggplot(opt, aes(recall, precision, color = threshold, size = smooth)) +
  geom_point() +
  labs(title = "Precision-Recall Trade-off")

# 5. Choose based on your priority
# High precision (fewer false positives): choose high threshold
# High recall (catch all calls): choose low threshold
# Balanced: choose max F1 score

best_f1 <- opt |> slice_max(f1_score, n = 1)
best_precision <- opt |> filter(precision > 0.9) |> slice_max(recall, n = 1)
best_recall <- opt |> filter(recall > 0.9) |> slice_max(precision, n = 1)
```

## 4. ohun template_detector()

### Algorithm

**Approach**: Cross-correlation template matching

1. User provides template(s) - examples of target call
2. Compute cross-correlation between template and recording
3. Identify peaks in correlation above threshold
4. Filter by duration and peak properties

**Key feature**: Highly specific - only detects calls similar to template

### Code Example

```r
library(ohun)

# Step 1: Create template (can be selection table from warbleR)
template <- selection_table(
  X = data.frame(
    sound.files = "template.wav",
    start = 0.1,
    end = 0.3
  ),
  path = "templates"
)

# Or create from existing detection
template <- detections |>
  filter(species == "target_species") |>
  slice_sample(n = 5)  # Use multiple templates

# Step 2: Detect using templates
detections <- template_detector(
  templates = template,
  files = list.files("recordings", pattern = "\\.wav$"),
  path = "recordings",

  # Correlation parameters
  cor.method = "pearson",          # Correlation method
  threshold = 0.4,                 # Correlation threshold (0-1)

  # Duration constraints
  mindur = 0.05,
  maxdur = 0.5,

  # Performance
  cores = 4                        # Parallel processing
)

# Step 3: Optimize threshold (optional)
opt_template <- optimize_template_detector(
  templates = template,
  reference = reference,
  path = "recordings",
  threshold = seq(0.3, 0.7, 0.05)
)
```

### Parameters

**Critical parameters**:

- **templates**: Selection table with example calls. More templates = better generalization.

- **threshold**: Correlation threshold (0-1). Higher = more specific, lower = more sensitive. Typical: 0.3-0.6.

- **cor.method**: "pearson" (standard), "spearman" (rank-based, more robust), "kendall" (non-parametric)

### Strengths

✅ Highest specificity - excellent for stereotyped calls
✅ Very low false positive rate
✅ Robust to noise if template is clean
✅ No parameter tuning needed (just threshold)
✅ Works when calls are rare (finds needles in haystack)
✅ Can use multiple templates for within-species variation

### Weaknesses

❌ Very slow (correlation is computationally expensive)
❌ Requires high-quality template(s)
❌ Poor generalization if calls are variable
❌ Misses calls that differ from template (low recall)
❌ Sensitive to recording differences (equipment, sample rate)
❌ Not suitable for highly variable species

### When to Use

- Stereotyped, consistent calls (e.g., specific frog species, bat echolocation clicks)
- Rare species detection (high specificity needed)
- When you have clean examples of target call
- Multi-species recording but only interested in one species
- When false positives are more costly than false negatives
- Validating other detection methods (template as ground truth)

### Template Selection Strategy

```r
# 1. Create diverse template set
# - Include calls from different individuals
# - Include different SNR conditions
# - Include slight variations in call structure

# 2. Test individual templates
template_performance <- templates |>
  rowwise() |>
  mutate(
    detections = list(template_detector(
      templates = cur_data(),
      files = "test_file.wav",
      threshold = 0.4
    )),
    n_detections = nrow(detections[[1]])
  )

# 3. Select best templates (not too specific, not too general)
# Too specific = very few detections (high precision, low recall)
# Too general = many detections (low precision, high recall)

# 4. Combine multiple templates
best_templates <- template_performance |>
  filter(n_detections > 5 & n_detections < 50) |>
  select(-detections, -n_detections)

# 5. Optimize threshold with combined templates
opt <- optimize_template_detector(
  templates = best_templates,
  reference = reference,
  threshold = seq(0.2, 0.6, 0.05)
)
```

## Comparison Table (Detailed)

| Feature | auto_detec | blob_detection | energy_detector | template_detector |
|---------|------------|----------------|-----------------|-------------------|
| **Speed** | ~10x real-time | ~5x real-time | ~10x real-time | ~0.5x real-time |
| **Noise robustness** | Moderate | High | Moderate-High | Moderate |
| **Overlapping calls** | Poor | Good | Poor | Moderate |
| **Parameter tuning** | Manual | Manual | Automated | Automated |
| **Feature extraction** | No | Yes (17 features) | No | No |
| **Memory usage** | Low | Moderate-High | Low | High |
| **False positive rate** | Moderate-High | Low-Moderate | Optimizable | Very Low |
| **False negative rate** | Low-Moderate | Moderate | Optimizable | Moderate-High |
| **Call type suitability** | Simple, isolated | Complex, variable | Medium complexity | Stereotyped only |
| **Reference needed** | No | No | Yes (optional) | Yes |
| **Multi-species** | Yes | Yes | Yes | No (one species per template) |

## Workflow Recommendations

### Scenario 1: Initial Exploration (No Reference Annotations)

```r
# Step 1: Fast exploration with warbleR
detections_initial <- auto_detec(bp = c(2, 10), threshold = 15)

# Step 2: Validate 50-100 detections manually
# Create reference set

# Step 3: If noise is problem, switch to blob_detection
detections_robust <- blob_detection(audio, min_dur = 50, HPF = 2000, LPF = 10000)

# Step 4: Compare and choose
```

### Scenario 2: Production System (Optimized Performance)

```r
# Step 1: Create reference annotations (manual or validated)
reference <- create_reference_set()

# Step 2: Optimize ohun energy_detector
opt <- optimize_energy_detector(
  reference = reference,
  threshold = seq(5, 25, 2),
  smooth = seq(5, 20, 5)
)

# Step 3: Apply optimized parameters to all data
detections <- energy_detector(
  files = all_recordings,
  threshold = best_params$threshold,
  smooth = best_params$smooth
)
```

### Scenario 3: Rare Species in Multi-Species Recordings

```r
# Step 1: Broad detection with blob_detection (high recall)
detections_all <- blob_detection(audio, min_area = 20)

# Step 2: Template matching for target species (high precision)
target_templates <- create_templates_for_target_species()

detections_target <- template_detector(
  templates = target_templates,
  files = recordings,
  threshold = 0.4
)

# Step 3: Combine strategies
# - Use template detections as high-confidence subset
# - Train classifier on blob_detection features using template detections as labels
```

### Scenario 4: Multi-Method Ensemble

```r
# Combine multiple methods for robustness
detections_wr <- auto_detec(bp = c(2, 10), threshold = 12)
detections_ba <- blob_detection(audio, min_dur = 50)
detections_oh <- energy_detector(threshold = 15, smooth = 10)

# Keep detections found by 2+ methods (consensus)
consensus_detections <- find_overlapping_detections(
  list(detections_wr, detections_ba, detections_oh),
  min_overlap = 0.5,
  min_consensus = 2
)
```

## Validation and Performance Metrics

```r
# Given reference annotations and detections
evaluate_detections <- function(detections, reference,
                                max_overlap = 0.5) {

  # True positives: detections overlapping with reference
  tp <- sum(detections overlap with reference > max_overlap)

  # False positives: detections not overlapping with reference
  fp <- nrow(detections) - tp

  # False negatives: reference not detected
  fn <- sum(reference not overlapped by detections)

  # Metrics
  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  f1_score <- 2 * (precision * recall) / (precision + recall)

  tibble(
    precision = precision,
    recall = recall,
    f1_score = f1_score,
    true_positives = tp,
    false_positives = fp,
    false_negatives = fn
  )
}

# Compare methods
comparison <- tibble(
  method = c("auto_detec", "blob_detection", "energy_detector"),
  detections = list(det_wr, det_ba, det_oh)
) |>
  rowwise() |>
  mutate(
    metrics = list(evaluate_detections(detections[[1]], reference))
  ) |>
  unnest(metrics)

print(comparison)
```

## Summary Recommendations

**Choose auto_detec() if**:
- High-quality recordings
- Speed is priority
- Simple, isolated calls
- Initial exploration phase

**Choose blob_detection() if**:
- Noisy field recordings
- Overlapping calls/choruses
- Need features extracted automatically
- Complex soundscapes
- Production robustness over speed

**Choose energy_detector() if**:
- Have reference annotations
- Need optimized performance
- Deploying to production
- Want reproducible parameters
- Can invest time in optimization

**Choose template_detector() if**:
- Stereotyped calls
- Rare species (high specificity needed)
- Have clean templates
- False positives more costly than false negatives
- Single-species focus

**Use ensemble approach if**:
- Critical application (conservation, research)
- Have computational resources
- Want maximum robustness
- Can combine methods (e.g., blob for detection + template for validation)

## References

- warbleR: Araya-Salas & Smith-Vidaurre (2017)
- bioacoustics: Kalman-based bat call detection
- ohun: Optimizable detection for PAM (2023)
- Advancements in preprocessing, detection and classification for PAM (2024)
