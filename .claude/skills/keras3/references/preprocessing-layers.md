# Keras 3 Preprocessing Layers Reference

Complete catalog of Keras 3 preprocessing layers organized by category.

## Audio/Spectral Preprocessing

### layer_mel_spectrogram()

Converts audio waveforms to mel-scale spectrograms.

**Parameters:**
- `fft_length` - Size of FFT window
- `sequence_stride` - Hop length between frames
- `sequence_length` - Length of input sequences
- `sampling_rate` - Audio sampling rate (Hz)
- `num_mel_bins` - Number of mel frequency bins
- `min_freq` - Minimum frequency (Hz)
- `max_freq` - Maximum frequency (Hz)
- `power_to_db` - Convert power spectrogram to decibels
- `top_db` - Threshold for dB conversion
- `mag_exp` - Exponent for magnitude calculation

**Use Cases:**
- Audio classification (speech, music, environmental sounds)
- Acoustic feature extraction
- Preprocessing for audio neural networks
- Bioacoustics analysis

**Example:**
```r
library(keras3)

# Create mel spectrogram layer
mel_layer <- layer_mel_spectrogram(
  fft_length = 2048,
  sequence_stride = 512,
  sequence_length = 16000,  # 1 second at 16kHz
  sampling_rate = 16000,
  num_mel_bins = 128,
  min_freq = 20,
  max_freq = 8000,
  power_to_db = TRUE
)

# Use in model
model <- keras_model_sequential(input_shape = c(16000)) |>
  mel_layer() |>
  layer_conv_2d(32, c(3, 3), activation = "relu") |>
  layer_flatten() |>
  layer_dense(10, activation = "softmax")
```

### layer_stft_spectrogram()

Computes Short-Time Fourier Transform spectrograms.

**Parameters:**
- `fft_length` - FFT window size
- `sequence_stride` - Hop length
- `sequence_length` - Input sequence length
- `window` - Window function ("hann", "hamming", etc.)
- `center` - Center the FFT window

**Use Cases:**
- General spectral analysis
- Time-frequency representation
- Custom audio feature extraction
- Research applications requiring raw STFT

**Example:**
```r
stft_layer <- layer_stft_spectrogram(
  fft_length = 1024,
  sequence_stride = 256,
  sequence_length = 16000,
  window = "hann"
)

# Build audio processing pipeline
audio_pipeline <- keras_model_sequential(input_shape = c(16000)) |>
  stft_layer() |>
  layer_conv_2d(64, c(3, 3), activation = "relu")
```

## Image Preprocessing

### Resizing and Cropping

#### layer_resizing()

Resizes images to target dimensions.

**Parameters:**
- `height` - Target height
- `width` - Target width
- `interpolation` - "bilinear", "nearest", "bicubic", "area", "lanczos3", "lanczos5", "gaussian", "mitchellcubic"
- `crop_to_aspect_ratio` - Crop to maintain aspect ratio
- `pad_to_aspect_ratio` - Pad to maintain aspect ratio
- `fill_mode` - "constant", "nearest", "reflect", "wrap"
- `fill_value` - Value for constant fill mode

**Example:**
```r
resize_layer <- layer_resizing(
  height = 224,
  width = 224,
  interpolation = "bilinear"
)

# Resize with aspect ratio preservation
resize_crop <- layer_resizing(
  height = 224,
  width = 224,
  crop_to_aspect_ratio = TRUE
)
```

#### layer_center_crop()

Crops center region of images.

**Parameters:**
- `height` - Crop height
- `width` - Crop width

**Example:**
```r
center_crop <- layer_center_crop(height = 200, width = 200)
```

### Basic Augmentation

#### layer_random_flip()

Randomly flips images horizontally or vertically.

**Parameters:**
- `mode` - "horizontal", "vertical", "horizontal_and_vertical"
- `seed` - Random seed for reproducibility

**Example:**
```r
flip_layer <- layer_random_flip(mode = "horizontal")

# Apply during training only
data_augmentation <- keras_model_sequential() |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.2)
```

#### layer_random_rotation()

Randomly rotates images.

**Parameters:**
- `factor` - Rotation range as fraction of 2π (e.g., 0.2 = ±36°)
- `fill_mode` - How to fill empty space
- `interpolation` - Interpolation method
- `seed` - Random seed

**Example:**
```r
rotation_layer <- layer_random_rotation(
  factor = 0.15,  # ±27 degrees
  fill_mode = "reflect",
  interpolation = "bilinear"
)
```

#### layer_random_zoom()

Randomly zooms images in or out.

**Parameters:**
- `height_factor` - Vertical zoom range (negative = zoom out)
- `width_factor` - Horizontal zoom range (optional, defaults to height_factor)
- `fill_mode` - "constant", "nearest", "reflect", "wrap"
- `interpolation` - Interpolation method
- `seed` - Random seed

**Example:**
```r
zoom_layer <- layer_random_zoom(
  height_factor = c(-0.2, 0.2),  # 80% to 120% zoom
  fill_mode = "reflect"
)

# Different zoom for height/width
zoom_anisotropic <- layer_random_zoom(
  height_factor = c(-0.2, 0.1),
  width_factor = c(-0.1, 0.2)
)
```

#### layer_random_crop()

Randomly crops images to specified size.

**Parameters:**
- `height` - Crop height
- `width` - Crop width
- `seed` - Random seed

**Example:**
```r
random_crop <- layer_random_crop(height = 200, width = 200)
```

#### layer_random_translation()

Randomly translates images horizontally and vertically.

**Parameters:**
- `height_factor` - Vertical translation range (fraction of height)
- `width_factor` - Horizontal translation range (fraction of width)
- `fill_mode` - How to fill empty space
- `interpolation` - Interpolation method
- `seed` - Random seed

**Example:**
```r
translation_layer <- layer_random_translation(
  height_factor = 0.2,  # ±20% of height
  width_factor = 0.2,   # ±20% of width
  fill_mode = "reflect"
)
```

### Color Augmentation

#### layer_random_brightness()

Randomly adjusts image brightness.

**Parameters:**
- `factor` - Brightness adjustment range
  - Single float: `[-factor, factor]`
  - Tuple: `[lower, upper]`
- `value_range` - Range of input values (e.g., `c(0, 1)` or `c(0, 255)`)
- `seed` - Random seed

**Example:**
```r
brightness_layer <- layer_random_brightness(
  factor = 0.2,
  value_range = c(0, 255)
)

# Asymmetric brightness adjustment
brightness_custom <- layer_random_brightness(
  factor = c(-0.1, 0.3),
  value_range = c(0, 1)
)
```

#### layer_random_contrast()

Randomly adjusts image contrast.

**Parameters:**
- `factor` - Contrast adjustment range
- `seed` - Random seed

**Example:**
```r
contrast_layer <- layer_random_contrast(factor = 0.2)

# Higher contrast variation
contrast_strong <- layer_random_contrast(factor = c(0.5, 1.5))
```

#### layer_random_hue()

Randomly shifts image hue.

**Parameters:**
- `factor` - Hue adjustment range (fraction of 2π)
- `value_range` - Range of input values
- `seed` - Random seed

**Example:**
```r
hue_layer <- layer_random_hue(
  factor = 0.1,  # ±10% hue shift
  value_range = c(0, 255)
)
```

#### layer_random_saturation()

Randomly adjusts image saturation.

**Parameters:**
- `factor` - Saturation adjustment range
- `seed` - Random seed

**Example:**
```r
saturation_layer <- layer_random_saturation(factor = c(0.5, 1.5))
```

### Advanced Augmentation

#### layer_aug_mix()

Applies AugMix augmentation strategy for improved robustness.

**Parameters:**
- `value_range` - Range of input values
- `severity` - Augmentation intensity (0.0-1.0)
- `num_chains` - Number of augmentation chains
- `chain_depth` - Augmentations per chain
- `alpha` - Dirichlet distribution parameter
- `seed` - Random seed

**Use Cases:**
- Improving model robustness to distribution shifts
- Domain generalization
- Competition-winning augmentation strategies

**Example:**
```r
augmix_layer <- layer_aug_mix(
  value_range = c(0, 255),
  severity = 0.3,
  num_chains = 3,
  chain_depth = c(1, 3)
)
```

#### layer_cut_mix()

Applies CutMix augmentation (cut and paste image patches).

**Parameters:**
- `alpha` - Beta distribution parameter controlling mix ratio
- `seed` - Random seed

**Use Cases:**
- Image classification with label smoothing
- Reducing overfitting
- Improved generalization

**Example:**
```r
cutmix_layer <- layer_cut_mix(alpha = 1.0)

# Use in training pipeline
model |> fit(
  train_dataset |> dataset_map(function(x, y) {
    cutmix_layer(list(x, y))
  }),
  epochs = 50
)
```

#### layer_mix_up()

Applies MixUp augmentation (linear interpolation of images and labels).

**Parameters:**
- `alpha` - Beta distribution parameter
- `seed` - Random seed

**Use Cases:**
- Regularization for image classification
- Smooth label transitions
- Reducing memorization

**Example:**
```r
mixup_layer <- layer_mix_up(alpha = 0.2)
```

#### layer_rand_augment()

Applies RandAugment strategy with automated augmentation magnitude.

**Parameters:**
- `value_range` - Range of input values
- `augmentations_per_image` - Number of augmentations to apply
- `magnitude` - Global augmentation magnitude (0-10)
- `magnitude_stddev` - Standard deviation for magnitude
- `rate` - Probability of applying augmentation
- `seed` - Random seed

**Use Cases:**
- State-of-the-art augmentation without hyperparameter tuning
- AutoML pipelines
- Large-scale image classification

**Example:**
```r
randaugment_layer <- layer_rand_augment(
  value_range = c(0, 255),
  augmentations_per_image = 2,
  magnitude = 10
)

# Complete augmentation pipeline
augmentation_pipeline <- keras_model_sequential() |>
  layer_resizing(224, 224) |>
  layer_random_flip("horizontal") |>
  randaugment_layer() |>
  layer_rescaling(scale = 1/255)
```

## Text Preprocessing

### layer_text_vectorization()

Converts text strings to integer sequences or TF-IDF vectors.

**Parameters:**
- `max_tokens` - Maximum vocabulary size
- `standardize` - Standardization function or "lower_and_strip_punctuation"
- `split` - Split function or "whitespace", "character"
- `ngrams` - N-gram range (e.g., `2` for bigrams)
- `output_mode` - "int", "multi_hot", "count", "tf_idf"
- `output_sequence_length` - Fixed output length (for "int" mode)
- `pad_to_max_tokens` - Pad output to max_tokens dimension
- `vocabulary` - Optional pre-defined vocabulary
- `idf_weights` - Optional IDF weights (for "tf_idf" mode)

**Use Cases:**
- Text classification
- Sentiment analysis
- Document vectorization
- NLP preprocessing pipelines

**Example - Integer Sequences:**
```r
text_vectorizer <- layer_text_vectorization(
  max_tokens = 10000,
  output_mode = "int",
  output_sequence_length = 100
)

# Adapt to training data
text_vectorizer |> adapt(train_texts)

# Use in model
text_model <- keras_model_sequential(input_shape = c(1), dtype = "string") |>
  text_vectorizer() |>
  layer_embedding(input_dim = 10000, output_dim = 128) |>
  layer_global_average_pooling_1d() |>
  layer_dense(64, activation = "relu") |>
  layer_dense(1, activation = "sigmoid")
```

**Example - TF-IDF:**
```r
tfidf_vectorizer <- layer_text_vectorization(
  max_tokens = 5000,
  output_mode = "tf_idf"
)

tfidf_vectorizer |> adapt(train_texts)

# TF-IDF model
tfidf_model <- keras_model_sequential(input_shape = c(1), dtype = "string") |>
  tfidf_vectorizer() |>
  layer_dense(64, activation = "relu") |>
  layer_dense(num_classes, activation = "softmax")
```

**Example - Custom Standardization:**
```r
custom_standardize <- function(text) {
  text |>
    tensorflow::tf$strings$lower() |>
    tensorflow::tf$strings$regex_replace("[^a-z0-9 ]", "")
}

custom_vectorizer <- layer_text_vectorization(
  max_tokens = 10000,
  standardize = custom_standardize,
  output_mode = "int",
  output_sequence_length = 50
)
```

### layer_string_lookup()

Maps categorical string features to integer indices.

**Parameters:**
- `max_tokens` - Maximum vocabulary size
- `num_oov_indices` - Number of out-of-vocabulary buckets
- `mask_token` - Optional mask token
- `oov_token` - Optional OOV token value
- `vocabulary` - Optional pre-defined vocabulary
- `idf_weights` - Optional IDF weights
- `invert` - Reverse mapping (indices to strings)
- `output_mode` - "int", "one_hot", "multi_hot", "count", "tf_idf"

**Use Cases:**
- Categorical feature encoding
- Entity mapping
- Multi-hot encoding for multi-label problems

**Example:**
```r
category_lookup <- layer_string_lookup(
  max_tokens = 100,
  num_oov_indices = 1
)

# Adapt to training data
category_lookup |> adapt(train_categories)

# Use in model
model <- keras_model_sequential() |>
  category_lookup() |>
  layer_embedding(input_dim = 101, output_dim = 16) |>
  layer_flatten() |>
  layer_dense(1)
```

**Example - Multi-hot Encoding:**
```r
multi_hot_lookup <- layer_string_lookup(
  max_tokens = 50,
  output_mode = "multi_hot"
)

multi_hot_lookup |> adapt(multi_label_data)
```

### layer_integer_lookup()

Maps integer features to indices or performs reverse lookup.

**Parameters:**
- `max_tokens` - Maximum vocabulary size
- `num_oov_indices` - Number of OOV buckets
- `mask_token` - Optional mask value
- `oov_token` - Optional OOV token value
- `vocabulary` - Optional pre-defined vocabulary
- `invert` - Reverse mapping
- `output_mode` - "int", "one_hot", "multi_hot", "count"

**Example:**
```r
int_lookup <- layer_integer_lookup(
  max_tokens = 1000,
  num_oov_indices = 1
)

int_lookup |> adapt(train_integer_features)

# Reverse lookup (indices to values)
reverse_lookup <- layer_integer_lookup(
  vocabulary = c(10, 20, 30, 40),
  invert = TRUE
)
```

## Categorical Preprocessing

### layer_category_encoding()

Encodes categorical features as one-hot, multi-hot, or count vectors.

**Parameters:**
- `num_tokens` - Size of vocabulary
- `output_mode` - "one_hot", "multi_hot", "count"

**Use Cases:**
- Encoding categorical features for neural networks
- Multi-label classification
- Feature engineering

**Example - One-hot:**
```r
onehot_encoder <- layer_category_encoding(
  num_tokens = 10,
  output_mode = "one_hot"
)
```

**Example - Multi-hot:**
```r
multihot_encoder <- layer_category_encoding(
  num_tokens = 50,
  output_mode = "multi_hot"
)
```

### layer_hashing()

Applies feature hashing (hashing trick) for categorical features.

**Parameters:**
- `num_bins` - Number of hash bins
- `mask_value` - Optional value to mask
- `salt` - Salt for hash function
- `output_mode` - "int", "one_hot"

**Use Cases:**
- High-cardinality categorical features
- Memory-efficient feature encoding
- Online learning scenarios

**Example:**
```r
hash_encoder <- layer_hashing(
  num_bins = 64,
  output_mode = "one_hot"
)

# No adaptation needed - stateless transformation
model <- keras_model_sequential() |>
  hash_encoder() |>
  layer_dense(32, activation = "relu")
```

### layer_hashed_crossing()

Creates crossed features using feature hashing.

**Parameters:**
- `num_bins` - Number of hash bins
- `output_mode` - "int", "one_hot"

**Use Cases:**
- Feature interactions
- Polynomial features
- Recommendation systems

**Example:**
```r
crossed_features <- layer_hashed_crossing(
  num_bins = 128,
  output_mode = "one_hot"
)

# Combine two categorical features
inputs <- list(
  feature1 = layer_input(shape = c(1), dtype = "int32"),
  feature2 = layer_input(shape = c(1), dtype = "int32")
)

crossed <- crossed_features(list(inputs$feature1, inputs$feature2))
```

## Numerical Preprocessing

### layer_normalization()

Normalizes numerical features (standardization).

**Parameters:**
- `axis` - Axis or axes to normalize
- `epsilon` - Small constant for numerical stability
- `center` - Subtract mean
- `scale` - Divide by standard deviation

**Use Cases:**
- Feature normalization
- Batch normalization alternative
- Layer normalization in transformers

**Example:**
```r
norm_layer <- layer_normalization(axis = -1)

# Feature normalization (adapt to training data)
feature_norm <- layer_normalization()
feature_norm |> adapt(train_features)
```

### layer_discretization()

Bins continuous features into discrete buckets.

**Parameters:**
- `bin_boundaries` - Explicit bucket boundaries
- `num_bins` - Number of bins (if boundaries not provided)
- `epsilon` - Small constant for boundary computation

**Use Cases:**
- Binning continuous features
- Creating categorical features from numerical ones
- Feature engineering

**Example:**
```r
# Explicit boundaries
age_bins <- layer_discretization(
  bin_boundaries = c(18, 25, 35, 50, 65)
)

# Automatic binning via adaptation
auto_bins <- layer_discretization(num_bins = 10)
auto_bins |> adapt(train_numerical_features)

# Use in model
model <- keras_model_sequential() |>
  auto_bins() |>
  layer_category_encoding(num_tokens = 11, output_mode = "one_hot") |>
  layer_dense(64, activation = "relu")
```

### layer_rescaling()

Rescales numerical features via linear transformation.

**Parameters:**
- `scale` - Multiplication factor
- `offset` - Addition offset

**Use Cases:**
- Normalizing image pixel values (0-255 to 0-1)
- Feature scaling
- Preprocessing pipelines

**Example:**
```r
# Image normalization (0-255 to 0-1)
rescale_images <- layer_rescaling(scale = 1/255)

# Custom scaling
rescale_custom <- layer_rescaling(scale = 2.0, offset = -1.0)  # to [-1, 1]

# In model
image_model <- keras_model_sequential(input_shape = c(224, 224, 3)) |>
  rescale_images() |>
  layer_conv_2d(32, c(3, 3), activation = "relu")
```

## Complete Preprocessing Pipeline Example

```r
library(keras3)

# Image preprocessing and augmentation
image_preprocessing <- keras_model_sequential(name = "preprocessing") |>
  layer_resizing(224, 224) |>
  layer_rescaling(scale = 1/255)

image_augmentation <- keras_model_sequential(name = "augmentation") |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.15) |>
  layer_random_zoom(0.2) |>
  layer_random_contrast(0.1)

# Complete image model
image_model <- keras_model_sequential(input_shape = c(NULL, NULL, 3)) |>
  image_preprocessing() |>
  image_augmentation() |>
  layer_conv_2d(32, c(3, 3), activation = "relu") |>
  layer_max_pooling_2d(c(2, 2)) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")

# Text preprocessing
text_preprocessing <- layer_text_vectorization(
  max_tokens = 10000,
  output_sequence_length = 100
)
text_preprocessing |> adapt(train_texts)

text_model <- keras_model_sequential(input_shape = c(1), dtype = "string") |>
  text_preprocessing() |>
  layer_embedding(10000, 128) |>
  layer_global_average_pooling_1d() |>
  layer_dense(64, activation = "relu") |>
  layer_dense(1, activation = "sigmoid")
```

## See Also

- [keras-applications.md](keras-applications.md) - Pretrained models with preprocessing
- [advanced-patterns.md](advanced-patterns.md) - Custom preprocessing layers
- [backend-guide.md](backend-guide.md) - Backend-specific preprocessing considerations
