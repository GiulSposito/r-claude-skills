# Complete PAM Pipeline Example

End-to-end reproducible Passive Acoustic Monitoring (PAM) workflow for species classification, from raw audio to predictions.

## Overview

This example demonstrates a production-ready PAM pipeline for multi-species bird classification using tidymodels. The workflow covers:

1. Project structure setup
2. Audio standardization
3. Event detection
4. Feature extraction
5. Model training with cross-validation
6. Inference on continuous audio
7. Post-processing and validation

**Dataset context**: Bird vocalizations from temperate forest, 10 species, 100 hours of recordings across 20 sites.

## 1. Project Structure

```
pam_project/
├── data/
│   ├── raw_audio/           # Original WAV files
│   ├── processed_audio/     # Standardized WAV files
│   ├── annotations/         # Manual annotations (reference set)
│   └── metadata.csv         # Recording metadata (site, date, time, etc.)
├── features/
│   ├── detections.csv       # Detection table
│   └── features.csv         # Extracted features
├── models/
│   ├── trained_model.rds    # Trained model object
│   └── model_metrics.csv    # Performance metrics
├── predictions/
│   └── species_detections.csv  # Final predictions
├── scripts/
│   ├── 01_standardize.R
│   ├── 02_detect.R
│   ├── 03_extract_features.R
│   ├── 04_train_model.R
│   ├── 05_inference.R
│   └── utils.R              # Helper functions
└── reports/
    └── analysis.qmd          # Quarto report

```

## 2. Setup and Dependencies

```r
# Install packages (run once)
install.packages(c(
  "tuneR", "seewave", "warbleR", "bioacoustics", "ohun", "soundecology",
  "tidyverse", "tidymodels", "ranger", "xgboost",
  "here", "fs", "glue", "tictoc"
))

# Load libraries
library(tidyverse)
library(tuneR)
library(seewave)
library(bioacoustics)
library(warbleR)
library(tidymodels)
library(here)
library(fs)

# Set random seed for reproducibility
set.seed(42)
```

## 3. Audio Standardization (01_standardize.R)

**Goal**: Convert all raw audio to consistent format (mono, 22050 Hz, normalized)

```r
library(tidyverse)
library(tuneR)
library(fs)
library(here)

# Function: Standardize single audio file
standardize_audio <- function(input_path, output_dir) {

  # Read audio
  audio <- readWave(input_path)

  # Convert to mono (average both channels if stereo)
  if (audio@stereo) {
    audio <- mono(audio, which = "both")
  }

  # Resample to 22050 Hz (bird vocalizations up to 11 kHz)
  if (audio@samp.rate != 22050) {
    audio <- downsample(audio, samp.rate = 22050)
  }

  # Normalize to 16-bit scale
  audio <- normalize(audio, unit = "16")

  # High-pass filter to remove DC offset and low-frequency noise
  audio <- ffilter(audio, from = 1000, output = "Wave")

  # Construct output path (preserve filename)
  output_path <- path(output_dir, path_file(input_path))

  # Ensure output directory exists
  dir_create(output_dir)

  # Write standardized audio
  writeWave(audio, output_path)

  # Return info
  tibble(
    input = input_path,
    output = output_path,
    duration_sec = duration(audio),
    sample_rate = audio@samp.rate
  )
}

# Process all raw audio files
raw_dir <- here("data", "raw_audio")
processed_dir <- here("data", "processed_audio")

raw_files <- dir_ls(raw_dir, glob = "*.wav")

# Process with progress
standardization_log <- raw_files |>
  map_dfr(
    ~standardize_audio(.x, processed_dir),
    .progress = TRUE
  )

# Save log
write_csv(standardization_log, here("data", "standardization_log.csv"))

# Summary
cat(glue("
Standardization Complete
------------------------
Files processed: {nrow(standardization_log)}
Total duration: {round(sum(standardization_log$duration_sec) / 3600, 1)} hours
"))
```

**Output**: Standardized WAV files in `data/processed_audio/`

## 4. Event Detection (02_detect.R)

**Goal**: Detect vocalization events in all recordings

```r
library(tidyverse)
library(tuneR)
library(bioacoustics)
library(fs)
library(here)
library(tictoc)

# Function: Detect events in single file using blob_detection
detect_events <- function(audio_path, file_id) {

  # Read audio
  audio <- readWave(audio_path)

  # Detect events with bioacoustics (robust to noise)
  tic()
  detections <- blob_detection(
    audio,
    time_exp = 1,
    min_dur = 50,        # 50 ms minimum
    max_dur = 3000,      # 3 seconds maximum
    min_area = 40,       # Filter small noise blobs
    min_TBE = 50,        # 50 ms min time between events
    max_TBE = 10000,     # 10 seconds max gap
    LPF = 11000,         # Low-pass filter (11 kHz)
    HPF = 2000,          # High-pass filter (2 kHz) - bird range
    bg_substract = 10    # Background noise subtraction
  )
  elapsed <- toc(quiet = TRUE)

  # Return empty tibble if no detections
  if (is.null(detections) || nrow(detections) == 0) {
    return(tibble())
  }

  # Convert to tidy format
  detections |>
    as_tibble() |>
    mutate(
      sound_file = basename(audio_path),
      file_id = file_id,
      detection_id = row_number(),
      .before = 1
    ) |>
    select(
      sound_file, file_id, detection_id,
      start = starting_time,
      duration,  # in ms
      freq_min, freq_max, freq_bandwidth, freq_centroid,
      temp_centroid, area, smoothness
    ) |>
    mutate(
      end = start + duration / 1000,  # Convert ms to seconds
      duration_sec = duration / 1000
    )
}

# Process all files
processed_dir <- here("data", "processed_audio")
processed_files <- dir_ls(processed_dir, glob = "*.wav")

# Detect with progress
all_detections <- processed_files |>
  imap_dfr(
    ~detect_events(.x, .y),
    .progress = TRUE
  )

# Save detections
write_csv(all_detections, here("features", "detections.csv"))

# Summary statistics
summary_stats <- all_detections |>
  summarize(
    n_files = n_distinct(sound_file),
    n_detections = n(),
    mean_duration = mean(duration_sec),
    median_duration = median(duration_sec),
    mean_freq_centroid = mean(freq_centroid),
    detections_per_file = n() / n_distinct(sound_file)
  )

print(summary_stats)

# Visualize detection distribution
ggplot(all_detections, aes(duration_sec)) +
  geom_histogram(bins = 50) +
  labs(title = "Detection Duration Distribution",
       x = "Duration (s)", y = "Count")

ggplot(all_detections, aes(freq_centroid)) +
  geom_histogram(bins = 50) +
  labs(title = "Frequency Centroid Distribution",
       x = "Frequency (kHz)", y = "Count")
```

**Output**: Detection table with ~50,000 events in `features/detections.csv`

## 5. Feature Extraction (03_extract_features.R)

**Goal**: Extract comprehensive acoustic features for each detection

```r
library(tidyverse)
library(tuneR)
library(seewave)
library(here)
library(furrr)

# Load detections
detections <- read_csv(here("features", "detections.csv"))

# Function: Extract features for single detection
extract_features <- function(audio_path, start, end) {

  # Read audio and extract segment
  audio <- readWave(audio_path)
  segment <- cutw(audio, from = start, to = end, output = "Wave")

  # Ensure mono
  if (segment@stereo) segment <- mono(segment, which = "both")

  # 1. MFCC FEATURES
  mfcc <- melfcc(segment, numcep = 13, wintime = 0.025, hoptime = 0.010)
  mfcc_mean <- colMeans(mfcc)
  mfcc_sd <- apply(mfcc, 1, sd)

  # 2. SPECTRAL FEATURES
  mean_spec <- meanspec(segment, plot = FALSE)
  spec_props <- specprop(mean_spec)

  # Dominant frequency tracking
  dom_freq <- tryCatch(
    dfreq(segment, wl = 512, ovlp = 90, plot = FALSE, threshold = 5),
    error = function(e) matrix(NA, nrow = 2, ncol = 2)
  )

  # 3. TEMPORAL FEATURES
  rms_val <- rms(segment)
  zcr_val <- zcr(segment)
  temp_entropy <- H(segment)

  # 4. FREQUENCY MODULATION
  fm_range <- if (!all(is.na(dom_freq[, 2]))) {
    max(dom_freq[, 2], na.rm = TRUE) - min(dom_freq[, 2], na.rm = TRUE)
  } else {
    NA_real_
  }

  fm_sd <- if (!all(is.na(dom_freq[, 2]))) {
    sd(dom_freq[, 2], na.rm = TRUE)
  } else {
    NA_real_
  }

  # Compile features
  tibble(
    # Temporal
    duration = end - start,
    rms = rms_val,
    zcr = zcr_val,
    temporal_entropy = temp_entropy,

    # Spectral
    spectral_centroid = spec_props$cent,
    spectral_bandwidth = spec_props$sd,
    spectral_flatness = spec_props$sfm,
    spectral_entropy = spec_props$sh,
    spectral_skewness = spec_props$skewness,
    spectral_kurtosis = spec_props$kurtosis,

    # Frequency modulation
    fm_range = fm_range,
    fm_sd = fm_sd,

    # MFCCs (13 mean + 13 sd = 26 features)
    !!!setNames(as.list(mfcc_mean), paste0("mfcc_", 1:13, "_mean")),
    !!!setNames(as.list(mfcc_sd), paste0("mfcc_", 1:13, "_sd"))
  )
}

# Setup parallel processing
plan(multisession, workers = 4)

# Extract features for all detections (with progress)
processed_dir <- here("data", "processed_audio")

features <- detections |>
  mutate(audio_path = file.path(processed_dir, sound_file)) |>
  # Sample for testing (remove for full run)
  # slice_sample(n = 1000) |>
  # Extract features
  future_pmap_dfr(
    list(audio_path, start, end),
    extract_features,
    .progress = TRUE,
    .options = furrr_options(seed = TRUE)
  )

# Combine with detection metadata
features_complete <- bind_cols(
  detections |> select(sound_file, file_id, detection_id, start, end),
  features
)

# Save
write_csv(features_complete, here("features", "features.csv"))

# Summary
cat(glue("
Feature Extraction Complete
---------------------------
Total features extracted: {nrow(features_complete)}
Feature dimensions: {ncol(features_complete)}
"))
```

**Output**: Feature table with 52 features per detection in `features/features.csv`

## 6. Add Labels and Prepare Training Data

**Goal**: Match detections to manual annotations and prepare training dataset

```r
library(tidyverse)
library(here)

# Load features
features <- read_csv(here("features", "features.csv"))

# Load manual annotations (assumed format)
annotations <- read_csv(here("data", "annotations", "manual_labels.csv"))
# Expected columns: sound_file, start, end, species

# Function: Find best matching annotation for each detection
match_annotations <- function(detections, annotations) {
  detections |>
    left_join(
      annotations,
      by = "sound_file",
      suffix = c("_det", "_ann")
    ) |>
    # Calculate overlap
    mutate(
      overlap_start = pmax(start_det, start_ann),
      overlap_end = pmin(end_det, end_ann),
      overlap_duration = pmax(0, overlap_end - overlap_start),
      overlap_prop = overlap_duration / (end_det - start_det)
    ) |>
    # Keep best match (highest overlap)
    group_by(sound_file, detection_id) |>
    slice_max(overlap_prop, n = 1, with_ties = FALSE) |>
    ungroup() |>
    # Filter: keep only detections with >50% overlap
    filter(overlap_prop > 0.5) |>
    select(
      sound_file, file_id, detection_id,
      species,
      starts_with("duration"), starts_with("rms"), starts_with("zcr"),
      starts_with("temporal"), starts_with("spectral"),
      starts_with("fm"), starts_with("mfcc")
    )
}

# Match and create labeled dataset
labeled_data <- match_annotations(features, annotations)

# Check class distribution
class_counts <- labeled_data |>
  count(species, sort = TRUE)

print(class_counts)

# Handle class imbalance (optional: downsample majority class)
# balanced_data <- labeled_data |>
#   group_by(species) |>
#   slice_sample(n = min(class_counts$n)) |>
#   ungroup()

# Save labeled data
write_csv(labeled_data, here("features", "labeled_features.csv"))

cat(glue("
Labeled Data Summary
--------------------
Total labeled examples: {nrow(labeled_data)}
Number of species: {n_distinct(labeled_data$species)}
Mean examples per species: {round(mean(class_counts$n))}
"))
```

## 7. Model Training with Tidymodels (04_train_model.R)

**Goal**: Train random forest classifier with grouped cross-validation

```r
library(tidyverse)
library(tidymodels)
library(ranger)
library(here)

# Load labeled data
data <- read_csv(here("features", "labeled_features.csv"))

# 1. DATA SPLITTING (grouped by file_id to prevent leakage)
set.seed(42)

# Extract file_id for grouping
data <- data |>
  mutate(species = as.factor(species))

# Grouped split (by file_id)
split <- group_initial_split(data, group = file_id, prop = 0.8, strata = species)
train_data <- training(split)
test_data <- testing(split)

# Grouped CV folds (5-fold)
cv_folds <- group_vfold_cv(train_data, group = file_id, v = 5, strata = species)

# 2. FEATURE ENGINEERING RECIPE
recipe <- recipe(species ~ ., data = train_data) |>
  # Remove identifiers
  step_rm(sound_file, file_id, detection_id) |>
  # Remove near-zero variance
  step_nzv(all_numeric_predictors()) |>
  # Remove highly correlated (>0.95)
  step_corr(all_numeric_predictors(), threshold = 0.95) |>
  # Impute missing (if any)
  step_impute_median(all_numeric_predictors()) |>
  # Normalize
  step_normalize(all_numeric_predictors())

# 3. MODEL SPECIFICATION
rf_spec <- rand_forest(
  mtry = tune(),
  trees = 1000,
  min_n = tune()
) |>
  set_engine("ranger", importance = "impurity") |>
  set_mode("classification")

# 4. WORKFLOW
workflow <- workflow() |>
  add_recipe(recipe) |>
  add_model(rf_spec)

# 5. HYPERPARAMETER TUNING
tune_grid <- grid_regular(
  mtry(range = c(5, 20)),
  min_n(range = c(5, 30)),
  levels = 5
)

# Tune with grouped CV
tune_results <- workflow |>
  tune_grid(
    resamples = cv_folds,
    grid = tune_grid,
    metrics = metric_set(accuracy, roc_auc, precision, recall),
    control = control_grid(save_pred = TRUE, verbose = TRUE)
  )

# Best parameters
best_params <- tune_results |>
  select_best(metric = "accuracy")

print(best_params)

# 6. FINALIZE AND FIT
final_workflow <- workflow |>
  finalize_workflow(best_params)

final_fit <- final_workflow |>
  fit(train_data)

# 7. EVALUATE ON TEST SET
test_predictions <- final_fit |>
  predict(test_data) |>
  bind_cols(test_data |> select(species))

# Confusion matrix
conf_mat <- test_predictions |>
  conf_mat(truth = species, estimate = .pred_class)

print(conf_mat)

# Per-class metrics
per_class_metrics <- test_predictions |>
  metrics(truth = species, estimate = .pred_class, .metric = "precision") |>
  bind_rows(
    test_predictions |>
      metrics(truth = species, estimate = .pred_class, .metric = "recall")
  )

print(per_class_metrics)

# Overall accuracy
overall_accuracy <- test_predictions |>
  accuracy(truth = species, estimate = .pred_class)

print(overall_accuracy)

# 8. SAVE MODEL
saveRDS(final_fit, here("models", "trained_model.rds"))
write_csv(
  tibble(
    metric = c("accuracy", "best_mtry", "best_min_n"),
    value = c(overall_accuracy$.estimate, best_params$mtry, best_params$min_n)
  ),
  here("models", "model_metrics.csv")
)

cat(glue("
Model Training Complete
-----------------------
Overall Accuracy: {round(overall_accuracy$.estimate * 100, 1)}%
Best mtry: {best_params$mtry}
Best min_n: {best_params$min_n}
Model saved: models/trained_model.rds
"))
```

**Output**: Trained model with ~85-90% accuracy (depends on dataset)

## 8. Inference on Continuous Audio (05_inference.R)

**Goal**: Apply trained model to new recordings, generate species predictions

```r
library(tidyverse)
library(tidymodels)
library(tuneR)
library(seewave)
library(bioacoustics)
library(here)

# Load trained model
model <- readRDS(here("models", "trained_model.rds"))

# Function: Process single file (detect + extract + predict)
process_file <- function(audio_path) {

  filename <- basename(audio_path)
  cat(glue("Processing: {filename}\n"))

  # 1. Detect events
  audio <- readWave(audio_path)
  detections <- blob_detection(
    audio, time_exp = 1, min_dur = 50, max_dur = 3000,
    min_area = 40, LPF = 11000, HPF = 2000
  )

  if (is.null(detections) || nrow(detections) == 0) {
    return(tibble())
  }

  # 2. Extract features
  features <- detections |>
    as_tibble() |>
    rowwise() |>
    mutate(
      segment = list(cutw(audio, from = starting_time,
                          to = starting_time + duration/1000, output = "Wave")),
      features = list(extract_features_simple(segment[[1]]))
    ) |>
    unnest_wider(features) |>
    select(-segment)

  # 3. Predict species
  predictions <- model |>
    predict(features, type = "prob") |>
    bind_cols(
      model |> predict(features)
    ) |>
    bind_cols(
      features |> select(starting_time, duration)
    ) |>
    mutate(
      sound_file = filename,
      end_time = starting_time + duration / 1000,
      .before = 1
    )

  return(predictions)
}

# Simplified feature extraction (use same as training)
extract_features_simple <- function(segment) {
  # ... same as extract_features() but without file I/O
  # (copy relevant code from 03_extract_features.R)
}

# Process new recordings
new_recordings_dir <- here("data", "new_recordings")
new_files <- dir_ls(new_recordings_dir, glob = "*.wav")

all_predictions <- new_files |>
  map_dfr(process_file, .progress = TRUE)

# Save raw predictions
write_csv(all_predictions, here("predictions", "raw_predictions.csv"))

# 9. POST-PROCESSING
# Filter by confidence threshold
confident_predictions <- all_predictions |>
  # Get max probability for each detection
  rowwise() |>
  mutate(max_prob = max(c_across(starts_with(".pred_")))) |>
  ungroup() |>
  # Filter: keep only confident predictions (>0.7)
  filter(max_prob > 0.7)

# Temporal smoothing (aggregate overlapping predictions)
smoothed_predictions <- confident_predictions |>
  arrange(sound_file, starting_time) |>
  group_by(sound_file, .pred_class) |>
  mutate(
    time_diff = starting_time - lag(end_time, default = -Inf),
    new_bout = time_diff > 5  # New bout if >5s gap
  ) |>
  mutate(bout_id = cumsum(new_bout)) |>
  group_by(sound_file, .pred_class, bout_id) |>
  summarize(
    start = min(starting_time),
    end = max(end_time),
    n_detections = n(),
    mean_confidence = mean(max_prob),
    .groups = "drop"
  ) |>
  rename(species = .pred_class)

# Save final predictions
write_csv(smoothed_predictions, here("predictions", "species_detections.csv"))

# Summary
species_summary <- smoothed_predictions |>
  count(species, name = "n_bouts") |>
  arrange(desc(n_bouts))

print(species_summary)

cat(glue("
Inference Complete
------------------
Files processed: {n_distinct(all_predictions$sound_file)}
Raw detections: {nrow(all_predictions)}
Confident detections: {nrow(confident_predictions)}
Final species bouts: {nrow(smoothed_predictions)}
"))
```

**Output**: Species detections with temporal smoothing in `predictions/species_detections.csv`

## 10. Validation and Reporting

**Goal**: Compare predictions to ground truth, generate performance report

```r
library(tidyverse)
library(here)
library(yardstick)

# Load predictions and ground truth
predictions <- read_csv(here("predictions", "species_detections.csv"))
ground_truth <- read_csv(here("data", "annotations", "validation_labels.csv"))

# Match predictions to ground truth (similar to step 6)
matched <- predictions |>
  left_join(ground_truth, by = "sound_file", suffix = c("_pred", "_truth")) |>
  mutate(
    overlap_start = pmax(start_pred, start_truth),
    overlap_end = pmin(end_pred, end_truth),
    overlap = pmax(0, overlap_end - overlap_start),
    overlap_prop = overlap / (end_pred - start_pred)
  ) |>
  filter(overlap_prop > 0.5) |>
  group_by(sound_file, species_pred) |>
  slice_max(overlap_prop, n = 1) |>
  ungroup()

# Confusion matrix
conf_mat <- matched |>
  conf_mat(truth = species_truth, estimate = species_pred)

# Metrics
metrics <- matched |>
  metrics(truth = species_truth, estimate = species_pred)

print(metrics)

# Per-species precision and recall
per_species <- matched |>
  group_by(species_truth) |>
  summarize(
    n_true = n(),
    n_correct = sum(species_pred == species_truth),
    precision = n_correct / n(),
    recall = n_correct / n_true
  )

print(per_species)

# Save report
write_csv(metrics, here("reports", "validation_metrics.csv"))
write_csv(per_species, here("reports", "per_species_metrics.csv"))
```

## Key Takeaways

1. **Standardization is critical**: Always normalize, resample, and filter before analysis
2. **Grouped cross-validation**: Use `group_vfold_cv()` to prevent temporal/spatial leakage
3. **Class imbalance**: Handle with class weights, downsampling, or per-class thresholds
4. **Feature engineering**: MFCCs + spectral + temporal features provide strong baseline
5. **Post-processing**: Temporal smoothing and confidence filtering reduce false positives
6. **Validation**: Always validate on held-out sites/dates, not random splits

## Extensions

- **Deep learning**: Replace feature extraction with CNN on spectrograms (see r-audio-multiclass skill)
- **Weak supervision**: Use pre-trained models (BirdNET) to generate pseudo-labels
- **Active learning**: Iteratively label most uncertain predictions
- **Real-time inference**: Optimize for streaming audio with windowing
- **Multi-label**: Extend to overlapping species with multi-label classification

## Resources

- Full code: [GitHub repository](https://github.com/example/pam-pipeline)
- tidymodels: https://www.tidymodels.org
- bioacoustics: https://cran.r-project.org/package=bioacoustics
- warbleR: https://marce10.github.io/warbleR/
