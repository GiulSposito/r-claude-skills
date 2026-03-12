# R Bioacoustics Skill - Executive Summary

## Research Completion Status

**Document Created**: 2026-03-11
**Comprehensive Research File**: `/docs/r_bioacoustics_comprehensive_research.md`
**Size**: 41KB, 1,445 lines
**Structure**: 46 major sections, 39 subsections

## Package Coverage

Successfully researched 6 core R bioacoustics packages:

### 1. **tuneR** (v1.4.7, 2024)
- **Role**: Foundation for audio I/O and MFCC extraction
- **Core Functions**: `readWave()`, `writeWave()`, `melfcc()`, `normalize()`, `downsample()`
- **Formats**: WAV, MP3, MIDI
- **Key Feature**: MFCC extraction ported from MATLAB rastamat package

### 2. **seewave** (v2.2.4, 2025)
- **Role**: Comprehensive sound analysis toolkit (200+ functions)
- **Core Functions**:
  - Spectral: `spectro()`, `meanspec()`, `specprop()`, `dfreq()`
  - Indices: `ACI()`, `H()`, `sh()`, `th()`, `sfm()`
  - Filtering: `ffilter()`, `bwfilter()`, `afilter()`
- **Key Feature**: Most comprehensive acoustic analysis library in R

### 3. **warbleR** (v1.1.37)
- **Role**: Bioacoustic workflow orchestration and batch processing
- **Core Functions**:
  - Detection: `auto_detec()`, `selection_table()`
  - Measurement: `specan()` (22 acoustic parameters)
  - Comparison: `xcorr()`, `dfDTW()`, `ffDTW()`
  - Batch: `lspec()`, `catalog()`, `check_sels()`
- **Key Feature**: Complete pipeline from detection to measurement
- **Integration**: Built on tuneR + seewave

### 4. **bioacoustics**
- **Role**: Automated detection and feature extraction
- **Core Functions**:
  - `blob_detection()` - Spectrographic multi-algorithm detection
  - `threshold_detection()` - Amplitude-based with Kalman filtering
- **Formats**: WAV, WAC, MP3, Zero-Crossing (.zc)
- **Key Feature**: Robust detection in noisy recordings
- **Specialization**: Bat echolocation and bird vocalizations

### 5. **ohun**
- **Role**: Detection parameter optimization
- **Core Approaches**:
  - Energy-based detection with adaptive thresholds
  - Template-based matching
  - Performance diagnostics (precision/recall)
- **Key Feature**: Optimization framework for reducing false positives
- **Integration**: Works with warbleR selection tables

### 6. **soundecology** (v1.3.3, 2018)
- **Role**: Ecoacoustic indices for biodiversity assessment
- **Core Indices**:
  - **ACI** - Acoustic Complexity Index
  - **ADI** - Acoustic Diversity Index
  - **AEI** - Acoustic Evenness Index
  - **BI** - Bioacoustic Index (bird frequency range)
  - **NDSI** - Normalized Difference Soundscape Index
- **Key Feature**: Landscape-scale soundscape characterization

## Core Workflows Documented

### 1. **Basic Audio Exploration and Cleaning**
- Load → Inspect → Standardize → Filter → Validate
- Mono conversion, normalization, resampling, noise filtering

### 2. **Spectrogram Analysis and Visualization**
- 2D/3D spectrograms with optimal parameters
- Mean spectrum analysis, spectral properties
- Dynamic spectrograms for time-series inspection

### 3. **Automated Signal Detection** (Multi-Method)
- warbleR amplitude-based detection
- bioacoustics blob detection (spectro-temporal)
- bioacoustics threshold detection (Kalman filtering)
- Consensus detection combining multiple methods

### 4. **Feature Extraction for Classification**
- warbleR `specan()` - 22 spectral/temporal parameters
- tuneR MFCCs with delta and delta-delta features
- seewave acoustic indices (ACI, entropy)
- Comprehensive feature aggregation pipeline

### 5. **Ecoacoustic Indices for Soundscape Assessment**
- Batch calculation of multiple indices
- Temporal pattern analysis
- Biodiversity assessment workflows

### 6. **Complete PAM (Passive Acoustic Monitoring) Pipeline**
- File organization and standardization
- Multi-method event detection
- Feature extraction (specan + MFCC + indices)
- Model training with tidymodels
- Cross-validation and evaluation

## Integration Patterns

### Pattern 1: **tuneR → seewave**
Basic I/O + comprehensive analysis

### Pattern 2: **bioacoustics → warbleR → Classification**
Robust detection → feature extraction → ML models

### Pattern 3: **ohun → warbleR**
Parameter optimization → optimized detection

### Pattern 4: **Hierarchical Feature Engineering**
- Level 1: Basic (MFCCs)
- Level 2: Spectral (seewave indices)
- Level 3: Structural (warbleR measurements)
- Level 4: Ecological (soundecology indices)

### Pattern 5: **Multi-Package Detection Ensemble**
Consensus from warbleR + bioacoustics (blob + threshold)

## Feature Engineering Methods

### Time-Frequency Features
- **MFCCs**: 13 coefficients + deltas + delta-deltas
- **Spectrograms**: Mel-spectrograms, log-mel spectrograms
- **Spectral Properties**: Centroid, flatness, entropy, skewness, kurtosis

### Time-Domain Features
- **Zero-crossing rate** (ZCR)
- **Amplitude envelope** statistics
- **Temporal entropy**
- **RMS energy**, crest factor, shape statistics

### warbleR Measurements (22 Parameters)
- Frequency: mean, median, quartiles, IQR, range
- Temporal: median time, quartiles, IQR
- Distribution: skewness, kurtosis
- Entropy: spectral, temporal, combined
- Dominant frequency: mean, min, max, range, modulation index

### Ecoacoustic Indices
- **ACI** - Amplitude variability
- **ADI** - Entropy of amplitude distribution
- **AEI** - Gini coefficient of spectrum
- **BI** - Energy in bird frequency range (2-8 kHz)
- **NDSI** - Anthrophony vs biophony ratio
- **Roughness**, **Q factor** (resonance)

### Advanced Features
- **Frequency contours**: Dominant frequency tracking, slope, inflections
- **Fundamental frequency**: For harmonic signals
- **Cross-correlation**: Auto-correlation for periodicity, template matching
- **DTW distances**: Dynamic Time Warping on frequency contours

## Best Practices (10 Key Areas)

1. **Audio Standardization**: Mono, normalize, resample, high-pass filter
2. **Windowing**: Sliding windows with overlap for long recordings
3. **Robust Detection**: Multi-method consensus approach
4. **Feature Selection**: Remove zero-variance, high correlation, normalize
5. **Cross-Validation**: Group by file/location to prevent temporal leakage
6. **Class Imbalance**: SMOTE, downsampling, or weighted loss
7. **Parameter Tuning**: Systematic grid search with validation set
8. **Temporal Post-Processing**: Smoothing predictions, aggregating overlaps
9. **Quality Control**: Check clipping, SNR, DC offset, selection integrity
10. **Reproducibility**: Log all parameters, versions, session info

## Common Code Patterns

1. **Batch Feature Extraction**: `extract_features_batch()` function
2. **Spectrogram Dataset Creation**: For CNN training
3. **Hierarchical Classification**: Binary presence/absence → species ID
4. **Detection Evaluation**: IoU-based matching, precision/recall/F1
5. **Result Export**: CSV + RDS + summary reports

## PAM Workflow Context

### Typical PAM Challenges
- **Long continuous recordings** (hours to days)
- **Limited labeled data** (weak supervision)
- **Noisy environments** (wind, rain, anthropogenic noise)
- **Class imbalance** (rare species, common species)
- **Overlapping vocalizations** (multi-label problem)
- **Temporal/spatial leakage** in validation

### R Bioacoustics Solutions
- **Detection**: Multi-method consensus (blob + threshold + energy)
- **Features**: Hierarchical engineering (MFCC + spectral + structural + ecological)
- **Models**: Tabular (RF, XGBoost) + Deep (CNN on spectrograms)
- **Validation**: Grouped CV by recording/location
- **Post-processing**: Temporal smoothing, aggregation

### Machine Learning Integration
- **tidymodels**: Recipes, workflows, tuning, validation
- **mlr3**: Pipelines, benchmarking, nested resampling
- **torch/keras3**: Deep learning for spectrograms
- **Classification**: randomForest, XGBoost, SVM, CNN, CRNN

## Key Parameters and Configurations

### Audio Standardization
- **Sample Rate**: 22050 Hz (common) or 44100 Hz (high quality)
- **Channels**: Mono (average both channels)
- **Normalization**: 16-bit integer range
- **High-pass Filter**: 100-500 Hz (remove rumble)

### MFCC Extraction
- **Coefficients**: 13 (standard)
- **Window**: 25ms (0.025s)
- **Hop**: 10ms (0.010s)
- **Mel Bands**: 40
- **Frequency Range**: 0 Hz to Nyquist (sr/2)

### Spectrogram Generation
- **Window Length (wl)**: 512 samples (common)
- **Overlap**: 50-75%
- **Scale**: Log (dB)
- **Color Levels**: seq(-40, 0, 1)

### Detection Parameters
- **Threshold**: 8-20 dB (SNR) or 10-20% (amplitude)
- **Min Duration**: 50-200 ms
- **Max Duration**: 1000-5000 ms
- **High-pass Filter**: 500-2000 Hz
- **Low-pass Filter**: 8000-12000 Hz

### warbleR specan() Parameters
- **bp**: Bandpass filter, e.g., c(1, 10) for 1-10 kHz
- Returns 22 parameters automatically

### Ecoacoustic Indices
- **ACI j parameter**: 5 seconds (bin size)
- **NDSI frequency ranges**:
  - Anthrophony: 1-2 kHz
  - Biophony: 2-11 kHz
- **BI frequency range**: 2-8 kHz (birds)

## Use Cases

### Species Classification
- Multi-class classification from continuous audio
- Features: MFCC + specan + indices
- Models: Random Forest, XGBoost, CNN

### Event Detection
- Locate temporal boundaries of vocalizations
- Methods: Blob detection, threshold detection, energy detector
- Optimization: ohun parameter tuning

### Soundscape Characterization
- Quantify acoustic environment
- Indices: ACI, ADI, AEI, BI, NDSI
- Applications: Biodiversity monitoring, habitat assessment

### Temporal Pattern Analysis
- Diel patterns (day/night cycles)
- Seasonal variations
- Activity budgets

### Comparative Bioacoustics
- Cross-correlation between signals
- DTW for temporal alignment
- Acoustic distance measures

## Integration with tidymodels/mlr3

### tidymodels Recipe
```r
recipe(species ~ ., data) %>%
  step_rm(identifiers) %>%
  step_impute_median(all_numeric) %>%
  step_zv(all_numeric) %>%
  step_corr(all_numeric, threshold = 0.9) %>%
  step_normalize(all_numeric) %>%
  step_smote(species)  # Handle imbalance
```

### Cross-Validation Strategy
- **Group by**: Recording file (prevent temporal leakage)
- **Method**: `group_vfold_cv()` or `spatial_clustering_cv()`
- **Folds**: 5-10

### Model Options
- **Tabular**: `rand_forest()`, `boost_tree()`, `svm_rbf()`
- **Deep Learning**: `torch` for CNN, CRNN on spectrograms

## Resources and Documentation

### Package Documentation
- tuneR: CRAN documentation, rastamat MATLAB port
- seewave: 200+ functions, comprehensive manual, DOI:10.1080/09524622.2008.9753600
- warbleR: GitHub, vignettes, DOI:10.1111/2041-210X.12624
- bioacoustics: R-universe manual, GUANO metadata support
- ohun: CRAN vignettes, parameter optimization guide
- soundecology: CRAN manual, index interpretation guides

### Key References
- Sueur et al. (2008) - seewave introduction
- Araya-Salas et al. (2016) - warbleR methodology
- Recent literature on PAM, weak supervision, few-shot learning

### Existing Roadmap
- `/docs/audio_analisys_roadmap.md` - Portuguese language guide
- Comprehensive ML approach for bird sound classification
- References to BirdCLEF competition and recent research

## Skill Development Recommendations

### Skill Structure
Given the complexity (41KB, 1,445 lines of content), recommend **bundled skill**:

```
.claude/skills/r-bioacoustics/
├── SKILL.md              # Core skill (< 500 lines)
├── references/
│   ├── package-functions.md      # Function reference
│   ├── feature-engineering.md    # Feature extraction methods
│   ├── detection-methods.md      # Detection algorithms
│   └── acoustic-indices.md       # Index interpretation
├── examples/
│   ├── pam-pipeline.md          # Complete PAM workflow
│   ├── feature-extraction.md    # Feature engineering examples
│   └── detection-optimization.md # Parameter tuning examples
├── templates/
│   ├── preprocessing-pipeline.R
│   ├── detection-workflow.R
│   └── feature-extraction-batch.R
└── README.md             # User documentation
```

### Skill Frontmatter
```yaml
---
name: r-bioacoustics
description: Bioacoustic analysis in R using tuneR, seewave, warbleR, bioacoustics, ohun, and soundecology. Use when mentions "bioacoustics", "acoustic analysis", "bird sound", "animal vocalization", "PAM", "passive acoustic monitoring", "spectrogram analysis", "MFCC extraction", "acoustic indices", "sound detection", "ecoacoustics", "soundscape", "ACI", "ADI", "warbleR", "seewave", "tuneR", "bird song analysis", or discusses analyzing, detecting, or classifying animal sounds in R.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R *), WebFetch
---
```

### Core Content Areas for SKILL.md

1. **Overview**: Package ecosystem and integration
2. **When to Use**: PAM, species classification, soundscape analysis
3. **Package Selection Guide**: Which package for which task
4. **Quick Start Workflows**: Common pipelines
5. **Feature Engineering**: Decision framework
6. **Detection Strategy**: Multi-method approach
7. **Best Practices**: 10 key areas
8. **Integration with ML**: tidymodels/mlr3
9. **Common Patterns**: Links to examples
10. **Troubleshooting**: Common issues

### Supporting Files

**references/package-functions.md**:
- Complete function reference for all 6 packages
- Organized by task (I/O, analysis, detection, etc.)

**references/feature-engineering.md**:
- MFCC extraction and aggregation
- Spectral features
- Time-domain features
- Acoustic indices
- When to use each feature type

**references/detection-methods.md**:
- Blob detection deep-dive
- Threshold detection with Kalman
- Energy-based detection
- Parameter tuning strategies
- Evaluation metrics

**references/acoustic-indices.md**:
- ACI, ADI, AEI, BI, NDSI interpretation
- When indices are useful vs limitations
- Batch processing strategies

**examples/pam-pipeline.md**:
- Complete end-to-end PAM workflow
- From raw audio to classified detections
- Includes validation and evaluation

**examples/feature-extraction.md**:
- Hierarchical feature engineering
- Batch processing large datasets
- Feature selection strategies

**examples/detection-optimization.md**:
- Parameter grid search
- Multi-method consensus
- Performance evaluation

**templates/** (R scripts):
- Ready-to-use code templates
- Commented and parameterized
- Can be sourced directly

### Advantages of This Structure

1. **Context Efficient**: Main SKILL.md stays under 500 lines
2. **Comprehensive**: All research content preserved in references
3. **Practical**: Examples show complete workflows
4. **Reusable**: Templates provide starting points
5. **Maintainable**: Easy to update individual sections
6. **Discoverable**: Clear organization by task

## Next Steps

To create the skill:
1. Use `/skillMaker` with this summary as input
2. Request bundled structure with references, examples, templates
3. Organize content from comprehensive research document
4. Test with example bioacoustic analysis tasks
5. Validate against PAM workflow requirements

## Statistics

- **Research Document**: 41KB, 1,445 lines
- **Packages Covered**: 6 (tuneR, seewave, warbleR, bioacoustics, ohun, soundecology)
- **Workflows Documented**: 6 major workflows
- **Integration Patterns**: 5 patterns
- **Feature Types**: 8 categories
- **Best Practices**: 10 areas
- **Code Patterns**: 5 reusable patterns
- **Total Functions**: 200+ (seewave alone), 300+ across all packages

---

**Research Completed**: 2026-03-11
**Ready for Skill Creation**: Yes
**Recommended Approach**: Bundled skill with references, examples, templates
