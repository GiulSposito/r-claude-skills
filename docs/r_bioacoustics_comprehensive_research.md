# R Bioacoustics Packages - Comprehensive Research

## Package Capabilities

### tuneR - Audio I/O and Basic Feature Extraction
**Purpose**: Analysis of music and speech, audio file handling, MFCC extraction
**Version**: 1.4.7 (2024)

**Core Functions**:
- Audio I/O: `readWave()`, `writeWave()`, `readMP3()`, `readMidi()`
- Waveform operations: `normalize()`, `downsample()`, `mono()`, `stereo()`
- Feature extraction: `melfcc()` (MFCC), `melodyFromDataFrame()`
- Wave manipulation: `bind()`, `extractWave()`, `cutWave()`
- Spectral analysis: Basic FFT operations

**Supported Formats**: WAV, MP3, MIDI
**Dependencies**: signal, methods
**Key Capabilities**: 
- MFCC extraction (ported from rastamat MATLAB package)
- Audio format conversion and resampling
- Basic transcription steps
- Integration point for all bioacoustics packages

### seewave - Comprehensive Sound Analysis and Synthesis
**Purpose**: Advanced sound analysis, visualization, and manipulation
**Version**: 2.2.4 (2025)

**Core Functions** (200+ functions):

*Time Domain Analysis*:
- `oscillo()` - Oscillogram display
- `env()` - Amplitude envelope
- `timer()` - Temporal measurements
- `zcr()` - Zero-crossing rate
- `csh()` - Crest factor and shape statistics

*Frequency Domain Analysis*:
- `spectro()` - Spectrogram generation (most used function)
- `meanspec()` - Mean frequency spectrum
- `spec()` - Spectral analysis
- `specprop()` - Spectral properties (centroid, flatness, etc.)
- `fpeaks()` - Dominant frequency peaks
- `dfreq()` - Dominant frequency tracking
- `fund()` - Fundamental frequency

*Acoustic Indices*:
- `ACI()` - Acoustic Complexity Index
- `H()` - Spectral entropy (Shannon, Renyi)
- `sh()` - Spectral entropy
- `th()` - Temporal entropy
- `sfm()` - Spectral flatness measure
- `roughness()` - Acoustic roughness
- `rms()` - Root mean square

*Filtering and Manipulation*:
- `ffilter()` - Frequency filter (high-pass, low-pass, band-pass)
- `bwfilter()` - Butterworth filter
- `afilter()` - Amplitude filter
- `combfilter()` - Comb filter
- `noisew()` - Noise generation/addition

*Advanced Analysis*:
- `corenv()` - Cross-correlation on envelopes
- `autoc()` - Autocorrelation
- `coh()` - Spectral coherence
- `Q()` - Quality factor (resonance)
- `kl.dist()`, `ks.dist()` - Spectral distance measures
- `simspec()` - Spectral similarity

*Visualization*:
- `spectro()`, `spectro3D()` - 2D/3D spectrograms
- `dynspec()` - Dynamic spectrogram
- `ggspectro()` - ggplot2 integration
- `wf()` - Waveform plots

**Dependencies**: tuneR, graphics, grDevices
**Suggests**: fftw, ggplot2, rgl, signal
**Key Capabilities**:
- Most comprehensive acoustic analysis toolkit
- Time-frequency analysis
- Acoustic indices for soundscape ecology
- Signal synthesis and filtering
- Multiple distance/similarity measures

### warbleR - Bioacoustic Signal Processing Pipeline
**Purpose**: Streamline bioacoustic analysis workflow for animal vocalizations
**Version**: 1.1.37

**Core Functions**:

*Signal Detection & Selection*:
- `auto_detec()` - Automatic signal detection using amplitude/frequency thresholds
- `song_param()` - Song parameter measurements
- `selection_table()` - Create selection tables
- `filter_sels()` - Filter selections by parameters

*Acoustic Measurements*:
- `specan()` - Spectral/temporal measurements (22 parameters)
  - Frequency: dominant freq, peak freq, freq range, quartiles
  - Energy: amplitude, RMS amplitude
  - Spectral: entropy, flatness, skewness, kurtosis
  - Temporal: duration
- `ff_param()` - Fundamental frequency parameters
- `dfDTW()`, `ffDTW()` - Dynamic Time Warping on frequency contours

*Cross-Correlation & Comparison*:
- `xcorr()` - Spectrogram cross-correlation
- `xcorr_graph()` - Visualize correlation networks
- `catalog()` - Create visual catalogs of signals

*Batch Processing*:
- `lspec()` - Create spectrograms for long recordings
- `catalog2pdf()` - Generate PDF catalogs
- `consolidate()` - Merge selection tables
- `check_sels()` - Check selection quality

*Signal Manipulation*:
- `cut_sels()` - Extract signals to individual files
- `filter_sels()` - Filter by frequency/time parameters
- `move_imgs()` - Organize spectrogram images

*Quality Control*:
- `check_sels()` - Check selection table integrity
- `check_wavs()` - Check WAV file quality
- `ovlp_sels()` - Detect overlapping selections

**Dependencies**: tuneR, seewave, NatureSounds, dtw, fftw, bioacoustics
**System Requirements**: sox, Ghostscript, libsndfile, GDAL
**Key Capabilities**:
- Complete bioacoustic analysis pipeline
- Batch processing of large datasets
- Automated measurements (specan - 22 parameters)
- Cross-correlation for signal comparison
- Integration with Xeno-Canto database

### bioacoustics - Automated Detection and Feature Extraction
**Purpose**: Automated processing of animal vocalizations with focus on bats and birds
**Repository**: wavesresearch/bioacoustics

**Core Functions**:

*Detection Methods*:
- `blob_detection()` - Spectrographic blob detection
  - Multi-algorithm approach for noisy recordings
  - Combines spectral and temporal analysis
- `threshold_detection()` - Amplitude-based detection
  - SNR-based thresholding
  - Kalman filtering for background noise estimation

*Audio I/O*:
- Reads: WAV, WAC, MP3, Zero-Crossing files (.zc, .#)
- `read_audio()` - Universal audio loader
- `metadata()` - Extract GUANO metadata
- Time-expansion factor support

*Feature Extraction*:
Automatically extracts:
- Frequency: min, max, peak, bandwidth, dominant
- Temporal: duration, call rate, inter-call intervals
- Amplitude: SNR, amplitude envelope patterns
- Spectral: shape, modulation patterns

*Filtering & Processing*:
- High-pass/low-pass filtering (HPF/LPF)
- Duration thresholds
- Background noise windowing
- FFT configuration options

**Integration**: Works with randomForest, extraTrees, mclust, keras for classification
**Key Capabilities**:
- Automated event detection in long recordings
- Bat echolocation analysis
- Bird vocalization analysis
- Robust to noise
- Extensive parameter tuning

### ohun - Signal Detection Optimization
**Purpose**: Optimize detection of acoustic signals in noisy recordings
**Documentation**: Limited web content available

**Core Approaches**:

*Energy-Based Detection*:
- Amplitude threshold detection
- Energy detector with adaptive thresholding
- Background noise estimation

*Template-Based Detection*:
- Template matching using cross-correlation
- Pattern recognition for known signal types

*Optimization Framework*:
- Parameter tuning workflows
- Performance diagnostics
- Precision/recall optimization
- Integration with warbleR selection tables

**Key Capabilities**:
- Detection parameter optimization
- Performance evaluation metrics
- Reduces false positives/negatives
- Pre-processing for classification pipelines

### soundecology - Ecoacoustic Indices
**Purpose**: Calculate soundscape ecology indices for biodiversity assessment
**Version**: 1.3.3 (2018)

**Ecoacoustic Indices**:
- **ACI** - Acoustic Complexity Index (variability in amplitude)
- **ADI** - Acoustic Diversity Index (entropy of amplitude distribution)
- **AEI** - Acoustic Evenness Index (Gini coefficient of spectrum)
- **BI** - Bioacoustic Index (energy in bird frequency range)
- **NDSI** - Normalized Difference Soundscape Index (anthrophony vs biophony)
- Entropy indices (temporal, spectral)

**Core Functions**:
- `acoustic_complexity()` - ACI calculation
- `acoustic_diversity()` - ADI calculation
- `acoustic_evenness()` - AEI calculation
- `bioacoustic_index()` - BI calculation
- `ndsi()` - NDSI calculation
- Batch processing for multiple files

**Dependencies**: tuneR, seewave, vegan, ineq
**Key Capabilities**:
- Soundscape characterization
- Biodiversity assessment
- Landscape-scale acoustic monitoring
- Temporal pattern analysis

## Core Workflows

### Workflow 1: Basic Audio Exploration and Cleaning
```r
library(tuneR)
library(seewave)

# 1. Load audio
wave <- readWave("recording.wav")

# 2. Basic inspection
duration(wave)
summary(wave)
oscillo(wave)  # Visualize waveform

# 3. Standardization
wave_mono <- mono(wave, which = "both")  # Convert to mono
wave_norm <- normalize(wave_mono, unit = "16")  # Normalize
wave_ds <- downsample(wave_norm, f = 22050)  # Resample to 22050 Hz

# 4. Filter noise
wave_filt <- ffilter(wave_ds, f = 22050, from = 1000, to = 10000, 
                     bandpass = TRUE, output = "Wave")

# 5. Check quality
meanspec(wave_filt, f = 22050, plot = TRUE)
```

### Workflow 2: Spectrogram Analysis and Visualization
```r
library(seewave)

# Generate spectrogram with optimal parameters
spectro(wave, f = 22050, 
        wl = 512,           # Window length (FFT)
        ovlp = 50,          # 50% overlap
        collevels = seq(-40, 0, 1),  # dB scale
        scale = FALSE,
        grid = FALSE)

# 3D spectrogram for detailed inspection
spectro3D(wave, f = 22050, wl = 512)

# Dynamic spectrogram (scrolling time window)
dynspec(wave, f = 22050, wl = 512)

# Mean spectrum analysis
spec <- meanspec(wave, f = 22050, plot = TRUE)
specprop(spec)  # Get spectral properties
```

### Workflow 3: Automated Signal Detection (warbleR + bioacoustics)
```r
library(warbleR)
library(bioacoustics)

# Method 1: warbleR auto_detec (amplitude-based)
detections_wb <- auto_detec(
  flist = "recording.wav",
  threshold = 15,          # % amplitude threshold
  ssmooth = 300,           # Smoothing (ms)
  mindur = 0.1,            # Min duration (s)
  maxdur = 1,              # Max duration (s)
  bp = c(1, 8),            # Bandpass 1-8 kHz
  parallel = 1
)

# Method 2: bioacoustics blob_detection (spectrogram-based)
detections_ba <- blob_detection(
  "recording.wav",
  threshold = 12,          # SNR threshold (dB)
  min_dur = 100,           # Min duration (ms)
  max_dur = 1000,          # Max duration (ms)
  LPF = 10000,             # Low-pass filter (Hz)
  HPF = 1000               # High-pass filter (Hz)
)

# Method 3: bioacoustics threshold_detection (amplitude-based with Kalman)
detections_td <- threshold_detection(
  "recording.wav",
  threshold = 12,
  min_dur = 100,
  max_dur = 1000,
  HPF = 1000,
  LPF = 10000,
  SNR_thr = 6              # SNR threshold
)
```

### Workflow 4: Feature Extraction for Classification
```r
library(warbleR)
library(tuneR)
library(seewave)

# Assuming detections in selection table format
sels <- detections_wb

# 1. Extract 22 spectral/temporal parameters
features <- specan(sels, bp = c(1, 10))
# Returns: meanfreq, sd, freq.median, freq.Q25, freq.Q75, 
#          freq.IQR, time.median, time.Q25, time.Q75, time.IQR,
#          skew, kurt, sp.ent, time.ent, entropy, sfm, 
#          meandom, mindom, maxdom, dfrange, duration, modindx

# 2. Extract MFCCs
mfcc_features <- data.frame()
for(i in 1:nrow(sels)) {
  # Extract signal
  signal <- readWave(sels$sound.files[i], 
                     from = sels$start[i], 
                     to = sels$end[i], 
                     units = "seconds")
  
  # Calculate MFCCs
  mfcc <- melfcc(signal, sr = 22050, 
                 numcep = 13,      # 13 coefficients
                 wintime = 0.025,  # 25ms window
                 hoptime = 0.010)  # 10ms hop
  
  # Aggregate (mean, sd, median, IQR)
  mfcc_stats <- data.frame(
    t(apply(mfcc, 2, function(x) {
      c(mean = mean(x), sd = sd(x), 
        median = median(x), IQR = IQR(x))
    }))
  )
  
  mfcc_features <- rbind(mfcc_features, mfcc_stats)
}

# 3. Extract acoustic indices per signal
aci_vals <- sapply(1:nrow(sels), function(i) {
  signal <- readWave(sels$sound.files[i], 
                     from = sels$start[i], 
                     to = sels$end[i], 
                     units = "seconds")
  ACI(signal, f = 22050)
})

# 4. Extract spectral entropy
ent_vals <- sapply(1:nrow(sels), function(i) {
  signal <- readWave(sels$sound.files[i], 
                     from = sels$start[i], 
                     to = sels$end[i], 
                     units = "seconds")
  H(signal, f = 22050)
})

# Combine all features
final_features <- cbind(features, mfcc_features, 
                        ACI = aci_vals, 
                        spectral_entropy = ent_vals)
```

### Workflow 5: Ecoacoustic Indices for Soundscape Assessment
```r
library(soundecology)
library(tuneR)

# Calculate multiple indices for one file
wave <- readWave("landscape_recording.wav")

# Acoustic Complexity Index (ACI)
aci_result <- acoustic_complexity(wave, j = 5)  # 5-second bins
aci_result$AciTotAll_left

# Acoustic Diversity Index (ADI)
adi_result <- acoustic_diversity(wave)
adi_result$adi_left

# Acoustic Evenness Index (AEI)
aei_result <- acoustic_evenness(wave, 
                                 freq_step = 1000,
                                 max_freq = 10000)
aei_result$aei_left

# Bioacoustic Index (BI) - bird frequency range
bi_result <- bioacoustic_index(wave, 
                                min_freq = 2000, 
                                max_freq = 8000)
bi_result$left_area

# NDSI - anthrophony vs biophony
ndsi_result <- ndsi(wave, 
                    fft_w = 1024,
                    anthro_min = 1000, anthro_max = 2000,
                    bio_min = 2000, bio_max = 11000)
ndsi_result$ndsi_left

# Batch processing for multiple files
files <- list.files(pattern = "*.wav")
indices_batch <- data.frame()

for(file in files) {
  wave <- readWave(file)
  row <- data.frame(
    file = file,
    ACI = acoustic_complexity(wave, j = 5)$AciTotAll_left,
    ADI = acoustic_diversity(wave)$adi_left,
    AEI = acoustic_evenness(wave)$aei_left,
    BI = bioacoustic_index(wave)$left_area,
    NDSI = ndsi(wave)$ndsi_left
  )
  indices_batch <- rbind(indices_batch, row)
}
```

### Workflow 6: Passive Acoustic Monitoring (PAM) Pipeline
```r
library(warbleR)
library(bioacoustics)
library(tuneR)
library(seewave)

# Full PAM pipeline for species classification

# 1. Organize files
files <- list.files("raw_audio/", pattern = "*.wav", full.names = TRUE)

# 2. Standardize audio (batch)
for(file in files) {
  wave <- readWave(file)
  wave_mono <- mono(wave, which = "both")
  wave_norm <- normalize(wave_mono, unit = "16")
  wave_22k <- downsample(wave_norm, f = 22050)
  writeWave(wave_22k, 
            file.path("processed/", basename(file)))
}

# 3. Detect events (blob detection for robustness)
all_detections <- data.frame()
processed_files <- list.files("processed/", pattern = "*.wav", 
                               full.names = TRUE)

for(file in processed_files) {
  det <- blob_detection(
    file,
    threshold = 12,
    min_dur = 100,
    max_dur = 3000,
    LPF = 12000,
    HPF = 500
  )
  
  if(nrow(det) > 0) {
    det$file <- basename(file)
    all_detections <- rbind(all_detections, det)
  }
}

# 4. Convert to warbleR selection table format
sels <- data.frame(
  sound.files = all_detections$file,
  selec = 1:nrow(all_detections),
  start = all_detections$starting_time,
  end = all_detections$ending_time,
  bottom.freq = all_detections$freq_min / 1000,  # Convert to kHz
  top.freq = all_detections$freq_max / 1000
)

# 5. Extract comprehensive features
features_specan <- specan(sels, bp = c(0.5, 12))

# 6. Extract MFCCs
mfcc_data <- extract_mfcc_batch(sels)  # Custom function

# 7. Calculate additional acoustic descriptors
additional_features <- data.frame()
for(i in 1:nrow(sels)) {
  wave_seg <- readWave(
    file.path("processed/", sels$sound.files[i]),
    from = sels$start[i],
    to = sels$end[i],
    units = "seconds"
  )
  
  row <- data.frame(
    zcr = zcr(wave_seg),
    spectral_centroid = specprop(meanspec(wave_seg, f = 22050, plot = FALSE))$cent,
    spectral_entropy = sh(wave_seg, f = 22050),
    temporal_entropy = th(wave_seg, f = 22050),
    Q_factor = Q(wave_seg, f = 22050)
  )
  
  additional_features <- rbind(additional_features, row)
}

# 8. Combine all features
final_dataset <- cbind(sels, features_specan, mfcc_data, additional_features)

# 9. Add labels (manual or from pre-labeled data)
# final_dataset$species <- labels  # Your labels here

# 10. Split data and train model
library(tidymodels)

split <- initial_split(final_dataset, strata = species)
train_data <- training(split)
test_data <- testing(split)

# Random Forest model
rf_model <- rand_forest(trees = 500, mtry = tune(), min_n = tune()) %>%
  set_engine("randomForest") %>%
  set_mode("classification")

# Create workflow
rf_workflow <- workflow() %>%
  add_formula(species ~ . - sound.files - selec - start - end) %>%
  add_model(rf_model)

# Tune and evaluate
# (Add your tuning code here)
```

## Integration Patterns

### Pattern 1: tuneR → seewave Pipeline
```r
# tuneR handles I/O, seewave handles analysis
library(tuneR)
library(seewave)

# Read with tuneR
wave <- readWave("file.wav")

# Analyze with seewave
spectro(wave, f = wave@samp.rate)
indices <- data.frame(
  ACI = ACI(wave, f = wave@samp.rate),
  spectral_entropy = sh(wave, f = wave@samp.rate),
  temporal_entropy = th(wave, f = wave@samp.rate)
)
```

### Pattern 2: bioacoustics → warbleR → Classification
```r
# bioacoustics for robust detection
detections <- blob_detection("file.wav", threshold = 12)

# Convert to warbleR format
sels <- detection_to_selection_table(detections)

# Use warbleR for feature extraction
features <- specan(sels, bp = c(1, 10))

# Classify with ML
library(randomForest)
model <- randomForest(species ~ ., data = labeled_features)
predictions <- predict(model, features)
```

### Pattern 3: ohun → warbleR Optimization
```r
library(ohun)
library(warbleR)

# Use ohun to optimize detection parameters
optimized_params <- optimize_energy_detector(
  reference = reference_selections,
  parameters = list(
    threshold = seq(5, 20, 2),
    smooth = seq(100, 500, 100)
  )
)

# Apply optimized parameters in warbleR
final_detections <- auto_detec(
  flist = audio_files,
  threshold = optimized_params$best_threshold,
  ssmooth = optimized_params$best_smooth
)
```

### Pattern 4: Hierarchical Feature Engineering
```r
# Level 1: Basic features (tuneR)
mfcc <- melfcc(wave, sr = 22050, numcep = 13)

# Level 2: Spectral features (seewave)
spec_features <- data.frame(
  centroid = specprop(meanspec(wave, f = 22050, plot = FALSE))$cent,
  flatness = sfm(wave, f = 22050),
  entropy = sh(wave, f = 22050)
)

# Level 3: Structural features (warbleR)
structural <- specan(selection_table, bp = c(1, 10))

# Level 4: Ecological indices (soundecology)
ecological <- data.frame(
  ACI = acoustic_complexity(wave)$AciTotAll_left,
  ADI = acoustic_diversity(wave)$adi_left
)

# Combine all levels
complete_features <- cbind(
  aggregate_mfcc(mfcc),
  spec_features,
  structural,
  ecological
)
```

### Pattern 5: Multi-Package Detection Ensemble
```r
# Combine multiple detection methods for robustness

# Method 1: warbleR amplitude-based
det1 <- auto_detec(flist = "file.wav", threshold = 15)

# Method 2: bioacoustics blob detection
det2 <- blob_detection("file.wav", threshold = 12)

# Method 3: bioacoustics threshold with Kalman
det3 <- threshold_detection("file.wav", threshold = 12, SNR_thr = 6)

# Consensus detection: keep detections found by 2+ methods
consensus <- find_consensus_detections(det1, det2, det3, 
                                        min_overlap = 0.5,
                                        min_methods = 2)
```

## Feature Engineering Methods

### MFCC Extraction and Aggregation
```r
library(tuneR)

# Extract MFCCs
wave <- readWave("signal.wav")
mfcc <- melfcc(wave, 
               sr = 22050,          # Sample rate
               numcep = 13,         # 13 coefficients (standard)
               wintime = 0.025,     # 25ms window
               hoptime = 0.010,     # 10ms hop (overlap)
               nbands = 40,         # 40 mel bands
               minfreq = 0,         # Min frequency
               maxfreq = 11025)     # Nyquist frequency

# Delta features (velocity)
delta_mfcc <- apply(mfcc, 2, diff)

# Delta-delta features (acceleration)
deltadelta_mfcc <- apply(delta_mfcc, 2, diff)

# Aggregate statistics
mfcc_features <- data.frame(
  # Mean
  t(apply(mfcc, 2, mean)),
  # Standard deviation
  t(apply(mfcc, 2, sd)),
  # Median
  t(apply(mfcc, 2, median)),
  # IQR
  t(apply(mfcc, 2, IQR)),
  # Min/Max
  t(apply(mfcc, 2, min)),
  t(apply(mfcc, 2, max)),
  # Skewness
  t(apply(mfcc, 2, function(x) moments::skewness(x))),
  # Kurtosis
  t(apply(mfcc, 2, function(x) moments::kurtosis(x)))
)

# Delta features aggregated
delta_features <- data.frame(
  t(apply(delta_mfcc, 2, function(x) c(mean(x), sd(x))))
)

colnames(mfcc_features) <- paste0("mfcc_", 
                                   rep(1:13, 8), "_",
                                   rep(c("mean", "sd", "median", "iqr", 
                                         "min", "max", "skew", "kurt"), 
                                       each = 13))
```

### Spectrogram-Based Features
```r
library(seewave)

# Generate mel-spectrogram for CNN input
mel_spec <- mel_spectrogram_2d(wave, f = 22050, 
                                wl = 512, ovlp = 75,
                                n_mels = 128)

# Log-mel spectrogram (commonly used)
log_mel_spec <- log(mel_spec + 1e-10)

# Spectral features from mean spectrum
spec <- meanspec(wave, f = 22050, plot = FALSE)
spec_props <- specprop(spec)

spectral_features <- data.frame(
  centroid = spec_props$cent,     # Spectral centroid
  mode = spec_props$mode,          # Dominant frequency
  flatness = sfm(wave, f = 22050), # Spectral flatness
  entropy = sh(wave, f = 22050),   # Spectral entropy
  skewness = spec_props$skewness,  # Spectral skewness
  kurtosis = spec_props$kurtosis   # Spectral kurtosis
)

# Frequency peak features
peaks <- fpeaks(spec, nmax = 5)  # Top 5 peaks
peak_features <- data.frame(
  peak1_freq = peaks$freq[1],
  peak1_amp = peaks$amp[1],
  peak2_freq = peaks$freq[2],
  peak2_amp = peaks$amp[2],
  n_peaks = nrow(peaks)
)
```

### Time-Domain Features
```r
library(seewave)

# Zero-crossing rate
zcr_val <- zcr(wave, f = 22050)

# Amplitude envelope
envelope <- env(wave, f = 22050, envt = "hil")  # Hilbert envelope
env_features <- data.frame(
  env_mean = mean(envelope),
  env_sd = sd(envelope),
  env_max = max(envelope),
  env_dynamic_range = max(envelope) - min(envelope)
)

# Temporal entropy
temp_entropy <- th(wave, f = 22050)

# RMS energy
rms_val <- rms(wave)

# Crest factor and shape
shape_stats <- csh(wave)

temporal_features <- data.frame(
  zcr = zcr_val,
  temporal_entropy = temp_entropy,
  rms = rms_val,
  crest_factor = shape_stats$crest,
  shape = shape_stats$shape,
  duration = duration(wave),
  env_mean = env_features$env_mean,
  env_sd = env_features$env_sd,
  dynamic_range = env_features$env_dynamic_range
)
```

### warbleR Acoustic Measurements (22 Parameters)
```r
library(warbleR)

# Requires selection table
features <- specan(selection_table, bp = c(1, 10))

# Returns:
# 1. meanfreq: Mean frequency (kHz)
# 2. sd: Standard deviation of frequency
# 3. freq.median: Median frequency
# 4. freq.Q25: First quartile frequency
# 5. freq.Q75: Third quartile frequency
# 6. freq.IQR: Interquartile range frequency
# 7. time.median: Median time
# 8. time.Q25: First quartile time
# 9. time.Q75: Third quartile time
# 10. time.IQR: Interquartile range time
# 11. skew: Skewness (asymmetry in freq distribution)
# 12. kurt: Kurtosis (tailedness in freq distribution)
# 13. sp.ent: Spectral entropy
# 14. time.ent: Temporal entropy
# 15. entropy: Combined entropy
# 16. sfm: Spectral flatness measure
# 17. meandom: Mean dominant frequency
# 18. mindom: Minimum dominant frequency
# 19. maxdom: Maximum dominant frequency
# 20. dfrange: Dominant frequency range
# 21. duration: Signal duration
# 22. modindx: Modulation index
```

### Ecoacoustic Indices as Features
```r
library(soundecology)
library(seewave)

# For each signal segment
eco_features <- data.frame(
  # Acoustic Complexity Index
  ACI = acoustic_complexity(wave, j = 5)$AciTotAll_left,
  
  # Acoustic Diversity Index
  ADI = acoustic_diversity(wave)$adi_left,
  
  # Acoustic Evenness Index
  AEI = acoustic_evenness(wave)$aei_left,
  
  # Bioacoustic Index
  BI = bioacoustic_index(wave, min_freq = 2000, max_freq = 8000)$left_area,
  
  # Additional seewave indices
  roughness = roughness(wave, f = 22050),
  Q_factor = Q(wave, f = 22050)
)
```

### Frequency Contour Features
```r
library(seewave)
library(warbleR)

# Dominant frequency tracking
df_contour <- dfreq(wave, f = 22050, plot = FALSE, threshold = 5)

# Frequency contour statistics
contour_features <- data.frame(
  df_mean = mean(df_contour[, 2], na.rm = TRUE),
  df_sd = sd(df_contour[, 2], na.rm = TRUE),
  df_range = diff(range(df_contour[, 2], na.rm = TRUE)),
  df_slope = lm(df_contour[, 2] ~ df_contour[, 1])$coefficients[2],
  df_n_inflections = count_inflections(df_contour[, 2])
)

# Fundamental frequency (for harmonic signals)
fund_freq <- fund(wave, f = 22050, plot = FALSE)
fund_features <- data.frame(
  fund_mean = mean(fund_freq[, 2], na.rm = TRUE),
  fund_sd = sd(fund_freq[, 2], na.rm = TRUE)
)

# DTW-based features (for signal comparison)
# Compare signal to reference template
dtw_dist <- dfDTW(selection_table[1:2, ], img = FALSE, parallel = 1)
```

### Cross-Correlation Features
```r
library(seewave)

# Auto-correlation (periodicity detection)
autocor <- autoc(wave, f = 22050, plot = FALSE)
autocor_features <- data.frame(
  autocor_peak = max(autocor[autocor[, 1] > 0, 2]),  # Peak correlation
  autocor_lag = autocor[which.max(autocor[autocor[, 1] > 0, 2]), 1]  # Lag at peak
)

# Cross-correlation with reference (for similarity)
# ref_wave <- readWave("reference.wav")
# xcor <- corenv(wave, ref_wave, f = 22050, plot = FALSE)
```

## Best Practices

### 1. Audio Standardization
**Always standardize before analysis**:
```r
# Standard preprocessing pipeline
preprocess_audio <- function(file, target_sr = 22050) {
  wave <- readWave(file)
  
  # Convert to mono
  if(wave@stereo) {
    wave <- mono(wave, which = "both")
  }
  
  # Normalize amplitude
  wave <- normalize(wave, unit = "16")
  
  # Resample to target sample rate
  if(wave@samp.rate != target_sr) {
    wave <- downsample(wave, f = target_sr)
  }
  
  # Apply gentle high-pass filter (remove DC offset and low rumble)
  wave <- ffilter(wave, f = target_sr, from = 100, 
                  output = "Wave")
  
  return(wave)
}
```

### 2. Windowing for Long Recordings
```r
# Sliding window approach for continuous audio
window_size <- 3  # seconds
hop_size <- 1.5   # 50% overlap

wave <- readWave("long_recording.wav")
sr <- wave@samp.rate
duration_sec <- length(wave@left) / sr

windows <- seq(0, duration_sec - window_size, by = hop_size)

features_list <- list()
for(i in seq_along(windows)) {
  # Extract window
  start_samp <- windows[i] * sr + 1
  end_samp <- min((windows[i] + window_size) * sr, length(wave@left))
  
  window_wave <- extractWave(wave, 
                              from = start_samp, 
                              to = end_samp, 
                              xunit = "samples")
  
  # Extract features for window
  features <- extract_all_features(window_wave)
  features$window_start <- windows[i]
  
  features_list[[i]] <- features
}

all_features <- do.call(rbind, features_list)
```

### 3. Robust Event Detection Strategy
```r
# Combine multiple detection methods
detect_events_robust <- function(file) {
  # Method 1: Blob detection (spectro-temporal)
  det_blob <- blob_detection(file, threshold = 12, 
                              min_dur = 100, max_dur = 3000)
  
  # Method 2: Threshold detection (amplitude + Kalman)
  det_thresh <- threshold_detection(file, threshold = 12, 
                                     SNR_thr = 6)
  
  # Method 3: warbleR energy-based
  det_warbler <- auto_detec(flist = file, threshold = 15,
                             ssmooth = 300, mindur = 0.1, maxdur = 3)
  
  # Consensus: Keep events detected by 2+ methods
  consensus <- merge_detections(det_blob, det_thresh, det_warbler,
                                 min_overlap = 0.5,
                                 min_methods = 2)
  
  return(consensus)
}
```

### 4. Feature Selection for Classification
```r
library(tidymodels)
library(recipes)

# Feature engineering recipe
feature_recipe <- recipe(species ~ ., data = train_data) %>%
  # Remove identifiers
  step_rm(sound.files, selec) %>%
  
  # Handle missing values
  step_impute_median(all_numeric_predictors()) %>%
  
  # Remove zero-variance predictors
  step_zv(all_numeric_predictors()) %>%
  
  # Remove highly correlated features (r > 0.9)
  step_corr(all_numeric_predictors(), threshold = 0.9) %>%
  
  # Normalize features
  step_normalize(all_numeric_predictors()) %>%
  
  # Optional: PCA for dimensionality reduction
  # step_pca(all_numeric_predictors(), threshold = 0.95)
  
  # Optional: Feature selection by importance
  step_select_forests(all_numeric_predictors(), 
                      outcome = "species",
                      threshold = 0.01)
```

### 5. Cross-Validation Strategy
```r
library(tidymodels)

# Prevent temporal/spatial leakage
# Group by recording file or location
cv_splits <- group_vfold_cv(train_data, 
                             group = sound.files, 
                             v = 5)

# Or use spatial blocks for geographic data
# cv_splits <- spatial_clustering_cv(train_data, 
#                                     coords = c("lon", "lat"),
#                                     v = 5)
```

### 6. Handle Class Imbalance
```r
library(themis)

# Add to recipe
balanced_recipe <- feature_recipe %>%
  # SMOTE for upsampling minority classes
  step_smote(species, over_ratio = 0.5) %>%
  
  # Or downsample majority
  step_downsample(species, under_ratio = 2)

# Or use weighted loss in model
rf_model <- rand_forest(trees = 500) %>%
  set_engine("randomForest", 
             classwt = class_weights) %>%  # Calculated from class frequencies
  set_mode("classification")
```

### 7. Parameter Tuning for Detection
```r
# Systematic parameter grid search
param_grid <- expand.grid(
  threshold = seq(8, 20, by = 2),
  min_dur = c(50, 100, 200),
  max_dur = c(1000, 2000, 3000),
  HPF = c(500, 1000, 2000),
  LPF = c(8000, 10000, 12000)
)

# Evaluate on labeled validation set
results <- data.frame()
for(i in 1:nrow(param_grid)) {
  det <- blob_detection(
    "validation_file.wav",
    threshold = param_grid$threshold[i],
    min_dur = param_grid$min_dur[i],
    max_dur = param_grid$max_dur[i],
    HPF = param_grid$HPF[i],
    LPF = param_grid$LPF[i]
  )
  
  # Compare to ground truth
  metrics <- evaluate_detection(det, ground_truth)
  
  results <- rbind(results, cbind(param_grid[i, ], metrics))
}

# Select best parameters
best_params <- results[which.max(results$f1_score), ]
```

### 8. Temporal Post-Processing
```r
# Smooth predictions over time windows
smooth_predictions <- function(predictions, window_times, smooth_window = 3) {
  # Convert to time series
  pred_ts <- zoo::zoo(predictions, order.by = window_times)
  
  # Rolling majority vote
  smoothed <- zoo::rollapply(pred_ts, 
                              width = smooth_window,
                              FUN = function(x) {
                                names(which.max(table(x)))
                              },
                              align = "center",
                              fill = NA)
  
  return(smoothed)
}

# Aggregate overlapping windows
aggregate_windows <- function(window_predictions, threshold = 0.5) {
  # Group by species and time
  # Average probabilities for overlapping windows
  # Return final classification per time segment
}
```

### 9. Quality Control Checks
```r
# Check audio quality before processing
check_audio_quality <- function(file) {
  wave <- readWave(file)
  
  checks <- list(
    sample_rate = wave@samp.rate,
    duration = duration(wave),
    bit_depth = wave@bit,
    stereo = wave@stereo,
    clipping = any(abs(wave@left) >= (2^(wave@bit - 1) - 1)),
    snr = estimate_snr(wave),
    dc_offset = mean(wave@left)
  )
  
  # Warn if issues
  if(checks$clipping) warning("Audio contains clipping")
  if(abs(checks$dc_offset) > 1000) warning("Significant DC offset")
  if(checks$snr < 10) warning("Low SNR (< 10 dB)")
  
  return(checks)
}

# Check selection table integrity
check_selections <- function(selection_table) {
  # Check for overlaps
  overlaps <- warbleR::check_sels(selection_table)
  
  # Check durations
  durations <- selection_table$end - selection_table$start
  if(any(durations < 0)) stop("Negative durations found")
  if(any(durations > 10)) warning("Very long selections (>10s)")
  
  # Check frequencies
  if(any(selection_table$top.freq < selection_table$bottom.freq)) {
    stop("Top frequency < bottom frequency")
  }
}
```

### 10. Reproducibility and Documentation
```r
# Log all parameters and versions
session_info <- list(
  date = Sys.time(),
  r_version = R.version.string,
  packages = sessionInfo()$otherPkgs,
  
  preprocessing = list(
    target_sr = 22050,
    normalization = TRUE,
    hp_filter = 100
  ),
  
  detection = list(
    method = "blob_detection",
    threshold = 12,
    min_dur = 100,
    max_dur = 3000,
    HPF = 1000,
    LPF = 10000
  ),
  
  features = list(
    mfcc_numcep = 13,
    mfcc_wintime = 0.025,
    mfcc_hoptime = 0.010,
    specan_bp = c(1, 10)
  ),
  
  model = list(
    algorithm = "random_forest",
    n_trees = 500,
    mtry = 6,
    min_node_size = 5
  )
)

# Save session info with results
saveRDS(session_info, "session_info.rds")

# Save full workflow
save.image("analysis_workspace.RData")
```

## Common Code Patterns

### Pattern: Batch Feature Extraction Function
```r
extract_features_batch <- function(selection_table, 
                                    feature_types = c("specan", "mfcc", "indices")) {
  
  features_list <- list()
  
  for(i in 1:nrow(selection_table)) {
    tryCatch({
      # Load segment
      wave <- readWave(
        selection_table$sound.files[i],
        from = selection_table$start[i],
        to = selection_table$end[i],
        units = "seconds"
      )
      
      row_features <- data.frame(
        file = selection_table$sound.files[i],
        selec = selection_table$selec[i]
      )
      
      # Extract requested feature types
      if("specan" %in% feature_types) {
        spec_feat <- specan(selection_table[i, ], bp = c(1, 10))
        row_features <- cbind(row_features, spec_feat)
      }
      
      if("mfcc" %in% feature_types) {
        mfcc <- melfcc(wave, sr = 22050, numcep = 13)
        mfcc_agg <- data.frame(t(apply(mfcc, 2, function(x) {
          c(mean(x), sd(x), median(x), IQR(x))
        })))
        colnames(mfcc_agg) <- paste0("mfcc_", rep(1:13, 4), "_",
                                      rep(c("mean", "sd", "med", "iqr"), each = 13))
        row_features <- cbind(row_features, mfcc_agg)
      }
      
      if("indices" %in% feature_types) {
        indices <- data.frame(
          ACI = ACI(wave, f = 22050),
          spectral_ent = sh(wave, f = 22050),
          temporal_ent = th(wave, f = 22050),
          zcr = zcr(wave, f = 22050)
        )
        row_features <- cbind(row_features, indices)
      }
      
      features_list[[i]] <- row_features
      
    }, error = function(e) {
      warning(paste("Error processing", selection_table$sound.files[i], 
                    "selection", selection_table$selec[i], ":", e$message))
      return(NULL)
    })
    
    # Progress bar
    if(i %% 100 == 0) message(paste("Processed", i, "of", nrow(selection_table)))
  }
  
  # Combine all features
  all_features <- do.call(rbind, features_list)
  return(all_features)
}
```

### Pattern: Create Spectrogram Dataset for CNN
```r
create_spectrogram_dataset <- function(selection_table, 
                                        output_dir,
                                        n_mels = 128,
                                        target_length = 128) {
  
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  
  for(i in 1:nrow(selection_table)) {
    # Load signal
    wave <- readWave(
      selection_table$sound.files[i],
      from = selection_table$start[i],
      to = selection_table$end[i],
      units = "seconds"
    )
    
    # Generate mel-spectrogram
    spec <- mel_spectrogram(wave, f = 22050, 
                             wl = 512, ovlp = 75,
                             n_mels = n_mels)
    
    # Log scale
    log_spec <- log(spec + 1e-10)
    
    # Pad or truncate to target length
    if(ncol(log_spec) < target_length) {
      # Pad with minimum value
      pad_width <- target_length - ncol(log_spec)
      log_spec <- cbind(log_spec, 
                        matrix(min(log_spec), nrow = n_mels, ncol = pad_width))
    } else if(ncol(log_spec) > target_length) {
      # Center crop
      start_col <- floor((ncol(log_spec) - target_length) / 2)
      log_spec <- log_spec[, start_col:(start_col + target_length - 1)]
    }
    
    # Save as RDS
    filename <- paste0(output_dir, "/", 
                       gsub(".wav", "", selection_table$sound.files[i]), "_",
                       selection_table$selec[i], ".rds")
    saveRDS(log_spec, filename)
    
    # Also save as PNG for visualization
    png_file <- gsub(".rds", ".png", filename)
    png(png_file, width = target_length, height = n_mels)
    par(mar = c(0,0,0,0))
    image(t(log_spec[n_mels:1, ]), axes = FALSE, col = viridis::viridis(256))
    dev.off()
  }
}
```

### Pattern: Hierarchical Classification
```r
# Two-stage classification: First detect presence/absence, then identify species
classify_hierarchical <- function(features, 
                                   binary_model,   # Presence/absence model
                                   species_model) { # Species identification model
  
  # Stage 1: Presence/absence
  presence_pred <- predict(binary_model, features, type = "prob")
  
  # Only classify as species if presence probability > threshold
  threshold <- 0.7
  presence_idx <- which(presence_pred[, "present"] > threshold)
  
  # Initialize predictions
  predictions <- rep("absent", nrow(features))
  
  # Stage 2: Species classification for detected events
  if(length(presence_idx) > 0) {
    species_pred <- predict(species_model, 
                            features[presence_idx, ],
                            type = "class")
    predictions[presence_idx] <- as.character(species_pred)
  }
  
  return(predictions)
}
```

### Pattern: Evaluate Detection Performance
```r
evaluate_detection <- function(predicted_events, true_events, 
                                tolerance = 0.5) {
  # Match predicted to true events within tolerance
  tp <- 0  # True positives
  fp <- 0  # False positives
  fn <- 0  # False negatives
  
  matched_true <- rep(FALSE, nrow(true_events))
  matched_pred <- rep(FALSE, nrow(predicted_events))
  
  # Find matches
  for(i in 1:nrow(predicted_events)) {
    for(j in 1:nrow(true_events)) {
      if(matched_true[j]) next
      
      # Check temporal overlap
      overlap <- min(predicted_events$end[i], true_events$end[j]) -
                 max(predicted_events$start[i], true_events$start[j])
      
      pred_dur <- predicted_events$end[i] - predicted_events$start[i]
      true_dur <- true_events$end[j] - true_events$start[j]
      
      # IoU (Intersection over Union)
      iou <- overlap / (pred_dur + true_dur - overlap)
      
      if(iou >= tolerance) {
        tp <- tp + 1
        matched_true[j] <- TRUE
        matched_pred[i] <- TRUE
        break
      }
    }
  }
  
  fp <- sum(!matched_pred)
  fn <- sum(!matched_true)
  
  # Calculate metrics
  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  f1 <- 2 * (precision * recall) / (precision + recall)
  
  return(list(
    tp = tp,
    fp = fp,
    fn = fn,
    precision = precision,
    recall = recall,
    f1_score = f1
  ))
}
```

### Pattern: Export Results for Analysis
```r
export_results <- function(predictions, features, 
                           selection_table, output_file) {
  
  results <- data.frame(
    file = selection_table$sound.files,
    start_time = selection_table$start,
    end_time = selection_table$end,
    duration = selection_table$end - selection_table$start,
    predicted_species = predictions,
    confidence = attr(predictions, "probabilities"),
    features
  )
  
  # Add temporal context
  results$hour <- hour(results$start_time)
  results$date <- as.Date(results$start_time)
  
  # Save as CSV
  write.csv(results, output_file, row.names = FALSE)
  
  # Also save as RDS for R-specific use
  saveRDS(results, gsub(".csv", ".rds", output_file))
  
  # Generate summary report
  summary_report <- list(
    total_detections = nrow(results),
    species_counts = table(results$predicted_species),
    date_range = range(results$date),
    mean_confidence = mean(results$confidence, na.rm = TRUE),
    duration_stats = summary(results$duration)
  )
  
  # Save summary
  sink(gsub(".csv", "_summary.txt", output_file))
  print(summary_report)
  sink()
  
  return(results)
}
```

---

## Summary

This comprehensive guide covers:
- **6 core packages** (tuneR, seewave, warbleR, bioacoustics, ohun, soundecology)
- **6 main workflows** (exploration, spectrogram analysis, detection, feature extraction, PAM pipeline, ecoacoustic indices)
- **5 integration patterns** (package combinations)
- **8 feature engineering approaches** (MFCC, spectrograms, time-domain, warbleR measurements, indices, contours)
- **10 best practices** (standardization, windowing, detection, feature selection, CV, class balance, tuning, post-processing, QC, reproducibility)
- **5 common code patterns** (batch processing, CNN datasets, hierarchical classification, evaluation, export)

This knowledge base provides everything needed to build a comprehensive r-bioacoustics Claude Code skill.
