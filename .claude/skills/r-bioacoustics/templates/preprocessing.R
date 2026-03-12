# Audio Preprocessing Template for Bioacoustic Analysis
#
# This script standardizes raw audio files for downstream analysis.
# Standardization ensures consistent format across recordings.
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
library(glue)

# Configuration ------------------------------------------------------------

# Input/output directories
raw_dir <- here("data", "raw")
processed_dir <- here("data", "processed")

# Target audio parameters
TARGET_SAMPLE_RATE <- 22050  # Hz (for birds - adjust for your taxa)
TARGET_BIT <- 16             # bit depth

# Filtering parameters
HIGH_PASS_FREQ <- 1000       # Hz - remove low-frequency noise (wind, traffic)
LOW_PASS_FREQ <- NULL        # Hz - set if needed (e.g., 11000 for birds)

# Processing options
NORMALIZE <- TRUE
CONVERT_MONO <- TRUE         # Average both channels if stereo

# Functions ----------------------------------------------------------------

#' Standardize single audio file
#'
#' @param input_path Path to input WAV file
#' @param output_dir Directory for output file
#' @param sample_rate Target sample rate (Hz)
#' @param bit Target bit depth
#' @param normalize Normalize amplitude?
#' @param mono Convert to mono?
#' @param hpf High-pass filter frequency (Hz)
#' @param lpf Low-pass filter frequency (Hz)
#'
#' @return Tibble with processing log
standardize_audio <- function(input_path,
                               output_dir,
                               sample_rate = 22050,
                               bit = 16,
                               normalize = TRUE,
                               mono = TRUE,
                               hpf = NULL,
                               lpf = NULL) {

  # Start timing
  start_time <- Sys.time()

  # Read audio
  tryCatch({
    audio <- readWave(input_path)

    # Get original properties
    orig_sr <- audio@samp.rate
    orig_channels <- if (audio@stereo) 2 else 1
    orig_duration <- duration(audio)

    # Convert to mono if requested
    if (mono && audio@stereo) {
      audio <- mono(audio, which = "both")  # Average both channels
    }

    # Resample if needed
    if (audio@samp.rate != sample_rate) {
      audio <- downsample(audio, samp.rate = sample_rate)
    }

    # Apply filters
    if (!is.null(hpf)) {
      audio <- ffilter(audio, from = hpf, output = "Wave")
    }

    if (!is.null(lpf)) {
      audio <- ffilter(audio, to = lpf, output = "Wave")
    }

    # Normalize amplitude
    if (normalize) {
      audio <- normalize(audio, unit = as.character(bit))
    }

    # Ensure output directory exists
    dir_create(output_dir)

    # Save processed audio
    output_path <- path(output_dir, path_file(input_path))
    writeWave(audio, output_path)

    # Calculate processing time
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

    # Return log
    tibble(
      file = path_file(input_path),
      status = "success",
      orig_sr = orig_sr,
      orig_channels = orig_channels,
      duration_sec = orig_duration,
      new_sr = sample_rate,
      new_channels = if (mono) 1 else orig_channels,
      filters = paste(
        if (!is.null(hpf)) glue("HPF: {hpf} Hz") else NULL,
        if (!is.null(lpf)) glue("LPF: {lpf} Hz") else NULL,
        sep = ", "
      ),
      normalized = normalize,
      processing_time_sec = elapsed,
      output_path = output_path
    )

  }, error = function(e) {
    # Handle errors gracefully
    tibble(
      file = path_file(input_path),
      status = "error",
      error_message = as.character(e),
      output_path = NA_character_
    )
  })
}

# Main processing ----------------------------------------------------------

cat("Audio Preprocessing\n")
cat("===================\n\n")

# List all WAV files in raw directory
raw_files <- dir_ls(raw_dir, glob = "*.wav", recurse = TRUE)

cat(glue("Found {length(raw_files)} WAV files\n\n"))

# Process all files
processing_log <- raw_files %>%
  map_dfr(
    ~standardize_audio(
      input_path = .x,
      output_dir = processed_dir,
      sample_rate = TARGET_SAMPLE_RATE,
      bit = TARGET_BIT,
      normalize = NORMALIZE,
      mono = CONVERT_MONO,
      hpf = HIGH_PASS_FREQ,
      lpf = LOW_PASS_FREQ
    ),
    .progress = list(
      type = "iterator",
      format = "Processing {cli::pb_bar} {cli::pb_current}/{cli::pb_total} | ETA: {cli::pb_eta}"
    )
  )

# Summary statistics -------------------------------------------------------

n_success <- sum(processing_log$status == "success")
n_errors <- sum(processing_log$status == "error")
total_duration <- sum(processing_log$duration_sec, na.rm = TRUE)
total_processing_time <- sum(processing_log$processing_time_sec, na.rm = TRUE)
speedup <- total_duration / total_processing_time

cat("\n\nProcessing Summary\n")
cat("------------------\n")
cat(glue("Files processed: {n_success}/{length(raw_files)}\n"))
cat(glue("Errors: {n_errors}\n"))
cat(glue("Total audio duration: {round(total_duration / 3600, 2)} hours\n"))
cat(glue("Total processing time: {round(total_processing_time / 60, 2)} minutes\n"))
cat(glue("Speedup: {round(speedup, 1)}x real-time\n"))

# Save processing log
log_path <- here("data", "preprocessing_log.csv")
write_csv(processing_log, log_path)
cat(glue("\nProcessing log saved: {log_path}\n"))

# Check for errors
if (n_errors > 0) {
  cat("\nFiles with errors:\n")
  processing_log %>%
    filter(status == "error") %>%
    select(file, error_message) %>%
    print()
}

# Quality checks -----------------------------------------------------------

cat("\n\nQuality Checks\n")
cat("--------------\n")

# Check sample rates
unique_sr <- processing_log %>%
  filter(status == "success") %>%
  pull(new_sr) %>%
  unique()

cat(glue("Sample rates: {paste(unique_sr, collapse = ', ')} Hz\n"))

# Check durations
duration_stats <- processing_log %>%
  filter(status == "success") %>%
  summarize(
    min = min(duration_sec),
    median = median(duration_sec),
    mean = mean(duration_sec),
    max = max(duration_sec)
  )

cat(glue("Duration (seconds): min={round(duration_stats$min, 1)}, "))
cat(glue("median={round(duration_stats$median, 1)}, "))
cat(glue("mean={round(duration_stats$mean, 1)}, "))
cat(glue("max={round(duration_stats$max, 1)}\n"))

cat("\n✓ Preprocessing complete!\n")

# Optional: Visual check ---------------------------------------------------

# Uncomment to generate spectrograms for visual validation
# library(patchwork)
#
# sample_files <- processing_log %>%
#   filter(status == "success") %>%
#   slice_sample(n = 4) %>%
#   pull(output_path)
#
# plots <- sample_files %>%
#   map(function(file) {
#     audio <- readWave(file)
#     # Generate spectrogram (requires custom ggplot wrapper or base plot)
#     spectro(audio, flim = c(2, 10), main = basename(file))
#   })
#
# # Combine plots
# wrap_plots(plots, ncol = 2)
# ggsave(here("reports", "preprocessing_check.png"), width = 10, height = 8)
