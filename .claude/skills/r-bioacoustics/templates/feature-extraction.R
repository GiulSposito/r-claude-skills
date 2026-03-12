# Feature Extraction Template for Bioacoustic Analysis
#
# This script extracts comprehensive acoustic features from detected events.
# Features are used for downstream classification or analysis.
#
# Author: [Your Name]
# Date: [Date]
# Project: [Project Name]

# Load required packages ---------------------------------------------------
library(tuneR)
library(seewave)
library(tidyverse)
library(fs)
library(here)
library(furrr)  # Parallel processing
library(glue)

# Configuration ------------------------------------------------------------

# Input directories
audio_dir <- here("data", "processed")
detections_file <- here("features", "detections.csv")  # From detection script

# Output directory
output_dir <- here("features")

# Feature extraction options
EXTRACT_MFCC <- TRUE          # Mel-frequency cepstral coefficients
N_MFCC <- 13                  # Number of MFCC coefficients
EXTRACT_SPECTRAL <- TRUE      # Spectral features (centroid, bandwidth, etc.)
EXTRACT_TEMPORAL <- TRUE      # Temporal features (ZCR, RMS, entropy)
EXTRACT_FM <- TRUE            # Frequency modulation features

# Parallel processing
N_CORES <- 4  # Number of cores to use

# Functions ----------------------------------------------------------------

#' Extract MFCC features
extract_mfcc_features <- function(segment, n_cep = 13) {

  # Ensure mono
  if (segment@stereo) segment <- mono(segment, which = "both")

  # Extract MFCCs
  mfcc <- melfcc(
    segment,
    numcep = n_cep,
    wintime = 0.025,  # 25ms window
    hoptime = 0.010   # 10ms hop
  )

  # Summarize across time
  mfcc_mean <- colMeans(mfcc)
  mfcc_sd <- apply(mfcc, 1, sd)

  # Delta features (velocity)
  mfcc_delta <- apply(mfcc, 1, function(x) {
    if (length(x) > 1) mean(diff(x), na.rm = TRUE) else NA_real_
  })

  # Return as named list
  c(
    setNames(as.list(mfcc_mean), paste0("mfcc_", 1:n_cep, "_mean")),
    setNames(as.list(mfcc_sd), paste0("mfcc_", 1:n_cep, "_sd")),
    setNames(as.list(mfcc_delta), paste0("mfcc_", 1:n_cep, "_delta"))
  )
}

#' Extract spectral features
extract_spectral_features <- function(segment) {

  # Ensure mono
  if (segment@stereo) segment <- mono(segment, which = "both")

  # Mean spectrum
  mean_spec <- meanspec(segment, plot = FALSE)

  # Spectral properties
  props <- specprop(mean_spec)

  # Peak frequencies
  peaks <- tryCatch(
    fpeaks(mean_spec, nmax = 3, plot = FALSE),
    error = function(e) data.frame(freq = rep(NA, 3), amp = rep(NA, 3))
  )

  list(
    spectral_centroid = props$cent,
    spectral_bandwidth = props$sd,
    spectral_flatness = props$sfm,
    spectral_entropy = props$sh,
    spectral_skewness = props$skewness,
    spectral_kurtosis = props$kurtosis,
    spectral_median = props$median,
    spectral_q25 = props$Q25,
    spectral_q75 = props$Q75,
    spectral_iqr = props$IQR,
    peak_freq_1 = peaks$freq[1],
    peak_freq_2 = peaks$freq[2],
    peak_freq_3 = peaks$freq[3],
    peak_amp_1 = peaks$amp[1],
    peak_amp_2 = peaks$amp[2],
    peak_amp_3 = peaks$amp[3]
  )
}

#' Extract temporal features
extract_temporal_features <- function(segment) {

  # Ensure mono
  if (segment@stereo) segment <- mono(segment, which = "both")

  # RMS energy
  rms_val <- rms(segment)

  # Zero-crossing rate
  zcr_val <- zcr(segment)

  # Temporal entropy
  temp_entropy <- H(segment)

  # Crest factor and shape
  shape_stats <- csh(segment)

  # Amplitude envelope
  env_vals <- env(segment, plot = FALSE)

  list(
    duration = duration(segment),
    rms = rms_val,
    zcr = zcr_val,
    temporal_entropy = temp_entropy,
    crest_factor = shape_stats$crest,
    mean_amplitude = shape_stats$M,
    envelope_mean = mean(env_vals),
    envelope_sd = sd(env_vals),
    envelope_max = max(env_vals),
    envelope_min = min(env_vals)
  )
}

#' Extract frequency modulation features
extract_fm_features <- function(segment) {

  # Ensure mono
  if (segment@stereo) segment <- mono(segment, which = "both")

  # Dominant frequency tracking
  dom_freq <- tryCatch(
    dfreq(segment, wl = 512, ovlp = 90, plot = FALSE, threshold = 5),
    error = function(e) matrix(NA, nrow = 2, ncol = 2)
  )

  if (!all(is.na(dom_freq[, 2]))) {
    freq_values <- dom_freq[, 2]
    freq_values <- freq_values[!is.na(freq_values)]

    if (length(freq_values) > 1) {
      fm_range <- max(freq_values) - min(freq_values)
      fm_mean <- mean(freq_values)
      fm_sd <- sd(freq_values)
      fm_rate <- mean(abs(diff(freq_values)))
      fm_max_rate <- max(abs(diff(freq_values)))
    } else {
      fm_range <- fm_mean <- fm_sd <- fm_rate <- fm_max_rate <- NA_real_
    }
  } else {
    fm_range <- fm_mean <- fm_sd <- fm_rate <- fm_max_rate <- NA_real_
  }

  list(
    fm_range = fm_range,
    fm_mean = fm_mean,
    fm_sd = fm_sd,
    fm_rate = fm_rate,
    fm_max_rate = fm_max_rate
  )
}

#' Extract all features for single detection
extract_all_features <- function(audio_path, start, end,
                                  extract_mfcc = TRUE,
                                  extract_spectral = TRUE,
                                  extract_temporal = TRUE,
                                  extract_fm = TRUE,
                                  n_mfcc = 13) {

  tryCatch({
    # Read audio and extract segment
    audio <- readWave(audio_path)
    segment <- cutw(audio, from = start, to = end, output = "Wave")

    # Extract features based on configuration
    features <- list()

    if (extract_temporal) {
      features <- c(features, extract_temporal_features(segment))
    }

    if (extract_spectral) {
      features <- c(features, extract_spectral_features(segment))
    }

    if (extract_fm) {
      features <- c(features, extract_fm_features(segment))
    }

    if (extract_mfcc) {
      features <- c(features, extract_mfcc_features(segment, n_cep = n_mfcc))
    }

    # Convert to tibble
    as_tibble(features)

  }, error = function(e) {
    tibble(error = as.character(e))
  })
}

# Main processing ----------------------------------------------------------

cat("Feature Extraction\n")
cat("==================\n\n")

# Load detections
detections <- read_csv(detections_file, show_col_types = FALSE)
cat(glue("Loaded {nrow(detections)} detections\n"))

# Add full audio path
detections <- detections %>%
  mutate(audio_path = path(audio_dir, sound_file))

# Check all files exist
missing_files <- detections %>%
  filter(!file_exists(audio_path)) %>%
  pull(sound_file) %>%
  unique()

if (length(missing_files) > 0) {
  cat("\nWarning: Missing audio files:\n")
  print(missing_files)
  detections <- detections %>%
    filter(file_exists(audio_path))
}

cat(glue("\nExtracting features from {nrow(detections)} detections\n"))
cat(glue("Using {N_CORES} cores for parallel processing\n\n"))

# Setup parallel processing
plan(multisession, workers = N_CORES)

# Extract features with progress bar
features <- detections %>%
  future_pmap_dfr(
    list(audio_path, start, end),
    function(path, s, e) {
      extract_all_features(
        path, s, e,
        extract_mfcc = EXTRACT_MFCC,
        extract_spectral = EXTRACT_SPECTRAL,
        extract_temporal = EXTRACT_TEMPORAL,
        extract_fm = EXTRACT_FM,
        n_mfcc = N_MFCC
      )
    },
    .progress = list(
      type = "iterator",
      format = "Extracting {cli::pb_bar} {cli::pb_current}/{cli::pb_total} | ETA: {cli::pb_eta}"
    ),
    .options = furrr_options(seed = TRUE)
  )

# Stop parallel processing
plan(sequential)

# Handle errors
if ("error" %in% names(features)) {
  errors <- features %>% filter(!is.na(error))
  if (nrow(errors) > 0) {
    cat("\nWarning: Errors in feature extraction:\n")
    print(table(errors$error))
  }
  features <- features %>% filter(is.na(error)) %>% select(-error)
}

# Combine with detection metadata ------------------------------------------

features_complete <- bind_cols(
  detections %>% select(sound_file, detection_id, start, end),
  features
)

# Summary statistics -------------------------------------------------------

cat("\n\nFeature Extraction Summary\n")
cat("--------------------------\n")
cat(glue("Total features extracted: {nrow(features_complete)}\n"))
cat(glue("Feature dimensions: {ncol(features_complete)}\n"))
cat(glue("Success rate: {round(nrow(features_complete)/nrow(detections)*100, 1)}%\n\n"))

# Check for missing values
missing_summary <- features_complete %>%
  summarize(across(where(is.numeric), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "feature", values_to = "n_missing") %>%
  filter(n_missing > 0) %>%
  arrange(desc(n_missing))

if (nrow(missing_summary) > 0) {
  cat("Features with missing values:\n")
  print(missing_summary, n = 20)
  cat("\n")
}

# Feature statistics
numeric_features <- features_complete %>%
  select(where(is.numeric), -starts_with(c("start", "end", "detection")))

cat("Feature statistics:\n")
cat(glue("  Numeric features: {ncol(numeric_features)}\n"))
cat(glue("  Mean values range: [{round(min(colMeans(numeric_features, na.rm = TRUE)), 3)}, "))
cat(glue("{round(max(colMeans(numeric_features, na.rm = TRUE)), 3)}]\n\n"))

# Save features ------------------------------------------------------------

output_path <- path(output_dir, "features.csv")
write_csv(features_complete, output_path)
cat(glue("Features saved: {output_path}\n"))

# Also save as RDS for faster loading
output_rds <- path(output_dir, "features.rds")
saveRDS(features_complete, output_rds)
cat(glue("Features saved (RDS): {output_rds}\n"))

# Visualizations -----------------------------------------------------------

cat("\nGenerating feature visualizations...\n")

# Correlation heatmap (sample features)
sample_features <- numeric_features %>%
  select(1:min(30, ncol(numeric_features))) %>%
  na.omit()

if (ncol(sample_features) > 1 && nrow(sample_features) > 10) {
  library(corrplot)

  cor_matrix <- cor(sample_features, use = "complete.obs")

  png(
    here("reports", "feature_correlation.png"),
    width = 10,
    height = 10,
    units = "in",
    res = 300
  )
  corrplot(
    cor_matrix,
    method = "color",
    type = "upper",
    tl.cex = 0.6,
    tl.col = "black"
  )
  dev.off()
}

# Feature distribution (selected features)
key_features <- features_complete %>%
  select(
    any_of(c(
      "duration", "spectral_centroid", "spectral_bandwidth",
      "mfcc_1_mean", "mfcc_2_mean", "rms", "zcr"
    ))
  )

if (ncol(key_features) > 0) {
  p <- key_features %>%
    pivot_longer(everything(), names_to = "feature", values_to = "value") %>%
    ggplot(aes(value)) +
    geom_histogram(bins = 50, fill = "steelblue", alpha = 0.7) +
    facet_wrap(~feature, scales = "free") +
    labs(title = "Key Feature Distributions") +
    theme_minimal()

  ggsave(
    here("reports", "feature_distributions.png"),
    p,
    width = 12,
    height = 8
  )
}

cat("\n✓ Feature extraction complete!\n")

# Optional: Feature selection ----------------------------------------------

# Uncomment to perform feature selection
# library(Boruta)
#
# # Requires labels - load if available
# # labels <- read_csv(here("data", "labels.csv"))
# # features_labeled <- features_complete %>% left_join(labels)
#
# # Run Boruta feature selection
# # boruta_result <- Boruta(species ~ ., data = features_labeled %>% select(-sound_file, -detection_id))
# # print(boruta_result)
#
# # Extract selected features
# # selected_features <- names(boruta_result$finalDecision[boruta_result$finalDecision == "Confirmed"])
# # write_lines(selected_features, here("features", "selected_features.txt"))
