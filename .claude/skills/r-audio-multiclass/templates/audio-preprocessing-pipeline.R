# Audio Preprocessing Pipeline for Multi-Label Classification
# Complete workflow from raw audio to mel-spectrograms

library(torch)
library(tuneR)
library(torchaudio)

# ============================================================================
# 1. Audio Loading and Resampling
# ============================================================================

#' Load audio file and convert to tensor
#'
#' @param file_path Path to audio file (WAV, MP3)
#' @param target_sr Target sample rate (Hz)
#' @param duration Target duration in seconds (NULL = full file)
#' @param offset Start time in seconds
#' @return List with waveform tensor and sample rate
load_audio <- function(file_path,
                       target_sr = 22050,
                       duration = NULL,
                       offset = 0) {
  # Read with tuneR
  if (tools::file_ext(file_path) == "mp3") {
    audio <- readMP3(file_path)
  } else {
    audio <- readWave(file_path)
  }

  # Extract mono waveform
  if (audio@stereo) {
    waveform <- (audio@left + audio@right) / 2
  } else {
    waveform <- audio@left
  }

  # Apply offset and duration
  sr <- audio@samp.rate
  start_sample <- round(offset * sr) + 1
  if (!is.null(duration)) {
    end_sample <- min(start_sample + round(duration * sr) - 1, length(waveform))
    waveform <- waveform[start_sample:end_sample]
  } else if (offset > 0) {
    waveform <- waveform[start_sample:length(waveform)]
  }

  # Resample if needed
  if (sr != target_sr) {
    # Use tuneR resample
    audio_resampled <- Wave(
      left = waveform,
      samp.rate = sr,
      bit = 16
    )
    audio_resampled <- resample(audio_resampled, target_sr)
    waveform <- audio_resampled@left
  }

  # Normalize to [-1, 1]
  waveform <- waveform / max(abs(waveform) + 1e-8)

  # Convert to torch tensor [1, samples]
  waveform_tensor <- torch_tensor(waveform)$unsqueeze(1)

  list(waveform = waveform_tensor, sample_rate = target_sr)
}


# ============================================================================
# 2. Mel-Spectrogram Transform
# ============================================================================

#' Create mel-spectrogram transform
#'
#' @param sample_rate Audio sample rate
#' @param n_fft FFT window size
#' @param hop_length Hop size between frames
#' @param n_mels Number of mel filter banks
#' @param f_min Minimum frequency
#' @param f_max Maximum frequency (NULL = sr/2)
#' @return Mel-spectrogram transform function
create_melspec_transform <- function(sample_rate = 22050,
                                     n_fft = 2048,
                                     hop_length = 512,
                                     n_mels = 128,
                                     f_min = 0,
                                     f_max = NULL) {
  if (is.null(f_max)) {
    f_max <- sample_rate / 2
  }

  transform_melspectrogram(
    sample_rate = sample_rate,
    n_fft = n_fft,
    hop_length = hop_length,
    n_mels = n_mels,
    f_min = f_min,
    f_max = f_max
  )
}


#' Convert amplitude to dB scale
#'
#' @param melspec Mel-spectrogram tensor
#' @param ref_value Reference value for dB calculation
#' @param amin Minimum amplitude (avoid log(0))
#' @return dB-scaled spectrogram
amplitude_to_db <- function(melspec, ref_value = 1.0, amin = 1e-10) {
  melspec_clamped <- torch_clamp(melspec, min = amin)
  melspec_db <- 10 * torch_log10(melspec_clamped / ref_value)
  melspec_db
}


#' Complete audio to mel-spectrogram pipeline
#'
#' @param audio_path Path to audio file
#' @param transform Mel-spectrogram transform
#' @param target_shape Target shape [n_mels, time] (NULL = no resize)
#' @return Mel-spectrogram tensor [1, n_mels, time]
audio_to_melspec <- function(audio_path, transform, target_shape = NULL) {
  # Load audio
  audio <- load_audio(audio_path)

  # Apply mel-spectrogram
  melspec <- transform(audio$waveform)  # [1, n_mels, time]

  # Convert to dB
  melspec_db <- amplitude_to_db(melspec)

  # Resize if needed
  if (!is.null(target_shape)) {
    melspec_db <- nnf_interpolate(
      melspec_db$unsqueeze(1),  # [1, 1, n_mels, time]
      size = target_shape,
      mode = "bilinear",
      align_corners = FALSE
    )$squeeze(1)  # [1, n_mels, time]
  }

  melspec_db
}


# ============================================================================
# 3. Augmentation (SpecAugment)
# ============================================================================

#' Time masking augmentation
#'
#' @param spec Spectrogram tensor [batch, channels, freq, time]
#' @param time_mask_param Maximum time mask size
#' @param n_masks Number of masks to apply
#' @param mask_value Value to fill masked regions (0 = silence)
#' @return Augmented spectrogram
time_mask <- function(spec, time_mask_param = 30, n_masks = 1, mask_value = 0) {
  for (i in 1:n_masks) {
    if (runif(1) > 0.5) {
      t <- spec$size(4)  # Time dimension
      t_mask_size <- sample(1:min(time_mask_param, t), 1)
      t_start <- sample(1:(t - t_mask_size + 1), 1)
      spec[, , , t_start:(t_start + t_mask_size - 1)] <- mask_value
    }
  }
  spec
}


#' Frequency masking augmentation
#'
#' @param spec Spectrogram tensor [batch, channels, freq, time]
#' @param freq_mask_param Maximum frequency mask size
#' @param n_masks Number of masks to apply
#' @param mask_value Value to fill masked regions
#' @return Augmented spectrogram
freq_mask <- function(spec, freq_mask_param = 20, n_masks = 1, mask_value = 0) {
  for (i in 1:n_masks) {
    if (runif(1) > 0.5) {
      f <- spec$size(3)  # Frequency dimension
      f_mask_size <- sample(1:min(freq_mask_param, f), 1)
      f_start <- sample(1:(f - f_mask_size + 1), 1)
      spec[, , f_start:(f_start + f_mask_size - 1), ] <- mask_value
    }
  }
  spec
}


#' Combined augmentation pipeline
#'
#' @param spec Spectrogram tensor
#' @param time_mask_param Max time mask size
#' @param freq_mask_param Max frequency mask size
#' @param n_time_masks Number of time masks
#' @param n_freq_masks Number of frequency masks
#' @return Augmented spectrogram
augment_spectrogram <- function(spec,
                                time_mask_param = 30,
                                freq_mask_param = 20,
                                n_time_masks = 2,
                                n_freq_masks = 2) {
  spec <- time_mask(spec, time_mask_param, n_time_masks)
  spec <- freq_mask(spec, freq_mask_param, n_freq_masks)
  spec
}


# ============================================================================
# 4. Batch Processing Utilities
# ============================================================================

#' Process batch of audio files to mel-spectrograms
#'
#' @param audio_files Character vector of file paths
#' @param transform Mel-spectrogram transform
#' @param target_shape Target shape for resize
#' @param augment Apply augmentation?
#' @return Tensor [N, 1, n_mels, time]
process_audio_batch <- function(audio_files,
                                transform,
                                target_shape = NULL,
                                augment = FALSE) {
  melspecs <- lapply(audio_files, function(file) {
    melspec <- audio_to_melspec(file, transform, target_shape)
    melspec
  })

  # Stack into batch
  batch <- torch_cat(melspecs, dim = 1)  # [N, 1, n_mels, time]

  # Augment if requested
  if (augment) {
    batch <- augment_spectrogram(batch)
  }

  batch
}


# ============================================================================
# 5. Normalization
# ============================================================================

#' Compute normalization statistics from training set
#'
#' @param audio_files Training audio files
#' @param transform Mel-spectrogram transform
#' @param n_samples Number of samples to estimate stats
#' @return List with mean and std tensors
compute_normalization_stats <- function(audio_files, transform, n_samples = 1000) {
  # Sample random files
  sampled_files <- sample(audio_files, min(n_samples, length(audio_files)))

  # Compute mel-spectrograms
  melspecs <- lapply(sampled_files, function(file) {
    melspec <- audio_to_melspec(file, transform)
    as.numeric(melspec)  # Flatten
  })

  # Compute stats
  all_values <- unlist(melspecs)
  mean_val <- mean(all_values)
  std_val <- sd(all_values)

  list(mean = mean_val, std = std_val)
}


#' Normalize mel-spectrogram with pre-computed stats
#'
#' @param melspec Mel-spectrogram tensor
#' @param mean Mean value
#' @param std Standard deviation
#' @return Normalized spectrogram
normalize_melspec <- function(melspec, mean, std) {
  (melspec - mean) / (std + 1e-8)
}


# ============================================================================
# Example Usage
# ============================================================================

# # Create transform
# melspec_transform <- create_melspec_transform(
#   sample_rate = 22050,
#   n_fft = 2048,
#   hop_length = 512,
#   n_mels = 128
# )
#
# # Process single file
# melspec <- audio_to_melspec(
#   "path/to/audio.wav",
#   melspec_transform,
#   target_shape = c(128, 128)
# )
#
# # With augmentation
# augmented <- augment_spectrogram(melspec)
#
# # Batch processing
# audio_files <- list.files("audio_dir", pattern = "\\.wav$", full.names = TRUE)
# batch <- process_audio_batch(
#   audio_files[1:32],
#   melspec_transform,
#   target_shape = c(128, 128),
#   augment = TRUE
# )
#
# # Normalization
# norm_stats <- compute_normalization_stats(audio_files, melspec_transform)
# normalized <- normalize_melspec(melspec, norm_stats$mean, norm_stats$std)
