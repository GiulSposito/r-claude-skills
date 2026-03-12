# Event Detection Template for Bioacoustic Analysis
#
# This script detects acoustic events (vocalizations) in audio recordings.
# Supports multiple detection methods: warbleR, bioacoustics, ohun
#
# Author: [Your Name]
# Date: [Date]
# Project: [Project Name]

# Load required packages ---------------------------------------------------
library(tuneR)
library(seewave)
library(warbleR)
library(bioacoustics)
library(ohun)
library(tidyverse)
library(fs)
library(here)
library(glue)

# Configuration ------------------------------------------------------------

# Input directory (preprocessed audio)
audio_dir <- here("data", "processed")

# Output directory
output_dir <- here("features")
dir_create(output_dir)

# Detection method: "warbler", "bioacoustics", "ohun_energy", or "ohun_template"
DETECTION_METHOD <- "bioacoustics"

# Frequency range (Hz) - adjust for your target taxa
# Birds: 2000-11000 Hz
# Frogs: 500-5000 Hz
# Bats: 20000-100000 Hz
FREQ_MIN <- 2000
FREQ_MAX <- 10000

# Duration constraints (seconds for warbleR, milliseconds for bioacoustics)
MIN_DURATION <- 0.05   # seconds (warbleR) or 50 (bioacoustics ms)
MAX_DURATION <- 3.0    # seconds (warbleR) or 3000 (bioacoustics ms)

# Functions ----------------------------------------------------------------

#' Detect events using warbleR auto_detec
detect_warbler <- function(audio_path, bp, mindur, maxdur, threshold = 10) {

  tryCatch({
    # warbleR expects files in directory
    audio_file <- basename(audio_path)
    audio_parent <- dirname(audio_path)

    detections <- auto_detec(
      path = audio_parent,
      files = audio_file,
      bp = bp,
      threshold = threshold,
      ssmooth = 300,
      mindur = mindur,
      maxdur = maxdur,
      output = "data.frame"
    )

    if (is.null(detections) || nrow(detections) == 0) {
      return(tibble())
    }

    detections %>%
      as_tibble() %>%
      mutate(
        method = "warbleR",
        sound_file = audio_file,
        freq_min = bottom.freq * 1000,  # Convert kHz to Hz
        freq_max = top.freq * 1000,
        duration_sec = end - start
      ) %>%
      select(
        method, sound_file, selec,
        start, end, duration_sec,
        freq_min, freq_max
      )

  }, error = function(e) {
    tibble(error = as.character(e))
  })
}

#' Detect events using bioacoustics blob_detection
detect_bioacoustics <- function(audio_path, min_dur, max_dur, hpf, lpf) {

  tryCatch({
    audio <- readWave(audio_path)

    detections <- blob_detection(
      audio,
      time_exp = 1,
      min_dur = min_dur,    # milliseconds
      max_dur = max_dur,    # milliseconds
      min_area = 40,
      min_TBE = 50,
      max_TBE = 10000,
      LPF = lpf,
      HPF = hpf,
      bg_substract = 10,
      blur = 2
    )

    if (is.null(detections) || nrow(detections) == 0) {
      return(tibble())
    }

    detections %>%
      as_tibble() %>%
      mutate(
        method = "bioacoustics",
        sound_file = basename(audio_path),
        detection_id = row_number(),
        start = starting_time,
        end = starting_time + duration / 1000,
        duration_sec = duration / 1000,
        freq_min = freq_min_hz,
        freq_max = freq_max_hz
      ) %>%
      select(
        method, sound_file, detection_id,
        start, end, duration_sec,
        freq_min, freq_max, freq_bandwidth, freq_centroid,
        temp_centroid, area, smoothness
      )

  }, error = function(e) {
    tibble(error = as.character(e))
  })
}

#' Detect events using ohun energy_detector
#' Requires reference annotations for optimization (see ohun documentation)
detect_ohun_energy <- function(audio_path, bp, threshold = 15, smooth = 10) {

  tryCatch({
    audio_file <- basename(audio_path)
    audio_parent <- dirname(audio_path)

    detections <- energy_detector(
      files = audio_file,
      path = audio_parent,
      bp = bp,
      threshold = threshold,
      smooth = smooth,
      hop.size = 11.6,
      wl = 512
    )

    if (is.null(detections) || nrow(detections) == 0) {
      return(tibble())
    }

    detections %>%
      as_tibble() %>%
      mutate(
        method = "ohun_energy",
        sound_file = audio_file,
        duration_sec = end - start,
        freq_min = NA_real_,  # ohun doesn't extract frequency
        freq_max = NA_real_
      ) %>%
      select(
        method, sound_file, selec,
        start, end, duration_sec,
        freq_min, freq_max
      )

  }, error = function(e) {
    tibble(error = as.character(e))
  })
}

#' Wrapper function to call appropriate detection method
detect_events <- function(audio_path, method = "bioacoustics") {

  cat(glue("Processing: {basename(audio_path)}\n"))

  result <- switch(
    method,
    "warbler" = detect_warbler(
      audio_path,
      bp = c(FREQ_MIN / 1000, FREQ_MAX / 1000),  # Convert to kHz
      mindur = MIN_DURATION,
      maxdur = MAX_DURATION
    ),
    "bioacoustics" = detect_bioacoustics(
      audio_path,
      min_dur = MIN_DURATION * 1000,  # Convert to ms
      max_dur = MAX_DURATION * 1000,
      hpf = FREQ_MIN,
      lpf = FREQ_MAX
    ),
    "ohun_energy" = detect_ohun_energy(
      audio_path,
      bp = c(FREQ_MIN / 1000, FREQ_MAX / 1000),
      threshold = 15,
      smooth = 10
    ),
    stop("Unknown detection method")
  )

  # Add file metadata
  result %>%
    mutate(
      file_path = audio_path,
      .before = 1
    )
}

# Main processing ----------------------------------------------------------

cat("Event Detection\n")
cat("===============\n\n")
cat(glue("Method: {DETECTION_METHOD}\n"))
cat(glue("Frequency range: {FREQ_MIN}-{FREQ_MAX} Hz\n"))
cat(glue("Duration range: {MIN_DURATION}-{MAX_DURATION} s\n\n"))

# List audio files
audio_files <- dir_ls(audio_dir, glob = "*.wav")
cat(glue("Found {length(audio_files)} audio files\n\n"))

# Detect events in all files
all_detections <- audio_files %>%
  map_dfr(
    ~detect_events(.x, method = DETECTION_METHOD),
    .progress = list(
      type = "iterator",
      format = "Detecting {cli::pb_bar} {cli::pb_current}/{cli::pb_total}"
    )
  )

# Remove error rows if any
if ("error" %in% names(all_detections)) {
  errors <- all_detections %>% filter(!is.na(error))
  if (nrow(errors) > 0) {
    cat("\nWarning: Errors in detection:\n")
    print(errors)
  }
  all_detections <- all_detections %>% filter(is.na(error))
}

# Summary statistics -------------------------------------------------------

cat("\n\nDetection Summary\n")
cat("-----------------\n")

n_detections <- nrow(all_detections)
n_files <- n_distinct(all_detections$sound_file)
detections_per_file <- n_detections / n_files

cat(glue("Total detections: {n_detections}\n"))
cat(glue("Files processed: {n_files}\n"))
cat(glue("Detections per file: {round(detections_per_file, 1)}\n\n"))

# Duration statistics
duration_stats <- all_detections %>%
  summarize(
    min = min(duration_sec),
    q25 = quantile(duration_sec, 0.25),
    median = median(duration_sec),
    mean = mean(duration_sec),
    q75 = quantile(duration_sec, 0.75),
    max = max(duration_sec)
  )

cat("Duration (seconds):\n")
cat(glue("  Min: {round(duration_stats$min, 3)}\n"))
cat(glue("  Q25: {round(duration_stats$q25, 3)}\n"))
cat(glue("  Median: {round(duration_stats$median, 3)}\n"))
cat(glue("  Mean: {round(duration_stats$mean, 3)}\n"))
cat(glue("  Q75: {round(duration_stats$q75, 3)}\n"))
cat(glue("  Max: {round(duration_stats$max, 3)}\n\n"))

# Frequency statistics (if available)
if (all(!is.na(all_detections$freq_centroid))) {
  freq_stats <- all_detections %>%
    summarize(
      mean_centroid = mean(freq_centroid, na.rm = TRUE),
      mean_bandwidth = mean(freq_bandwidth, na.rm = TRUE)
    )

  cat("Frequency statistics:\n")
  cat(glue("  Mean centroid: {round(freq_stats$mean_centroid / 1000, 2)} kHz\n"))
  cat(glue("  Mean bandwidth: {round(freq_stats$mean_bandwidth / 1000, 2)} kHz\n\n"))
}

# Save detections ----------------------------------------------------------

output_path <- path(output_dir, glue("detections_{DETECTION_METHOD}.csv"))
write_csv(all_detections, output_path)
cat(glue("Detections saved: {output_path}\n"))

# Visualizations -----------------------------------------------------------

cat("\nGenerating visualizations...\n")

# Duration histogram
p1 <- ggplot(all_detections, aes(duration_sec)) +
  geom_histogram(bins = 50, fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Detection Duration Distribution",
    x = "Duration (s)",
    y = "Count"
  ) +
  theme_minimal()

ggsave(
  here("reports", glue("detection_duration_{DETECTION_METHOD}.png")),
  p1,
  width = 8,
  height = 5
)

# Frequency centroid histogram (if available)
if (all(!is.na(all_detections$freq_centroid))) {
  p2 <- ggplot(all_detections, aes(freq_centroid / 1000)) +
    geom_histogram(bins = 50, fill = "coral", alpha = 0.7) +
    labs(
      title = "Frequency Centroid Distribution",
      x = "Frequency Centroid (kHz)",
      y = "Count"
    ) +
    theme_minimal()

  ggsave(
    here("reports", glue("detection_frequency_{DETECTION_METHOD}.png")),
    p2,
    width = 8,
    height = 5
  )
}

# Detections per file
p3 <- all_detections %>%
  count(sound_file, name = "n_detections") %>%
  ggplot(aes(n_detections)) +
  geom_histogram(bins = 30, fill = "forestgreen", alpha = 0.7) +
  labs(
    title = "Detections per File",
    x = "Number of Detections",
    y = "Number of Files"
  ) +
  theme_minimal()

ggsave(
  here("reports", glue("detections_per_file_{DETECTION_METHOD}.png")),
  p3,
  width = 8,
  height = 5
)

cat("\n✓ Detection complete!\n")

# Optional: Quality filtering ----------------------------------------------

# Uncomment to apply quality filters
# filtered_detections <- all_detections %>%
#   filter(
#     duration_sec >= 0.05,          # At least 50ms
#     duration_sec <= 2.5,           # At most 2.5s
#     freq_bandwidth >= 500,         # At least 500 Hz bandwidth
#     if (exists("area")) area >= 50 else TRUE  # Blob area filter
#   )
#
# cat(glue("\nFiltered detections: {nrow(filtered_detections)} ({round(nrow(filtered_detections)/n_detections*100, 1)}%)\n"))
# write_csv(filtered_detections, path(output_dir, glue("detections_{DETECTION_METHOD}_filtered.csv")))
