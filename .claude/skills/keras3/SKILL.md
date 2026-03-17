---
name: keras3
description: Expert Keras3 deep learning in R with multi-backend support. Use when working with keras3, mentions "keras3", "keras3 em R", "keras3 for R", "Functional API", "custom keras layer", "keras preprocessing", "keras application", "keras subclassing", "JAX backend", "multi-backend keras", "keras3 audio", "keras3 NLP", "keras3 vision", "preprocessing layer", "custom training loop", "model subclassing", "Sequential API", "layer_*", "optimizer_adam", "compile model", "fit model", or discusses deep learning with keras3 in R.
version: 1.0.0
---

# Keras3 Deep Learning in R

## Overview

**Keras3** is a modern deep learning API for R that provides a high-level interface for building and training neural networks. It represents a complete rewrite of Keras 2.x with a revolutionary multi-backend architecture.

### What is Keras3?

Keras3 is the third generation of Keras, designed as a unified API that works seamlessly with TensorFlow, JAX, and PyTorch backends. The R implementation (keras3 package) provides idiomatic R interfaces while maintaining full compatibility with the Python Keras ecosystem.

**Latest Version**: 1.5.1 (February 2026)

### Multi-Backend Philosophy

Unlike previous versions tied to TensorFlow, Keras3 lets you switch backends dynamically:

```r
library(keras3)

# Choose your backend
config_set_backend("tensorflow")  # Default, production-ready
config_set_backend("jax")         # Fast, functional programming style
config_set_backend("torch")       # PyTorch ecosystem integration
```

This means you can develop with one backend and deploy with another, or benchmark different backends for your specific workload.

### When to Use Keras3

**Use Keras3 when you want:**
- High-level, intuitive API for rapid prototyping
- Multi-backend flexibility (TensorFlow/JAX/PyTorch)
- Rich ecosystem of preprocessing layers (audio, image, text)
- 30+ pretrained models for transfer learning
- Built-in training loop with callbacks
- Keras-native preprocessing without external dependencies

**Consider alternatives:**
- **torch (via r-deeplearning)**: Direct PyTorch control, custom autograd, research flexibility
- **r-tensorflow**: Low-level TensorFlow operations, SavedModel deployment, TensorFlow Serving

For detailed framework comparison, see the **r-deeplearning** skill.

### Key Differentiators from Keras 2.x

1. **Multi-backend support**: Not tied to TensorFlow
2. **Modern preprocessing layers**: Audio (Mel-spectrogram, STFT), advanced image augmentation
3. **Improved subclassing API**: Cleaner custom layer/model creation
4. **Better serialization**: Universal .keras format across backends
5. **Enhanced R integration**: Pipe operator support, idiomatic patterns

## Core Concepts

Keras3 offers three APIs for model building, from simplest to most flexible.

### Sequential API

The **Sequential API** builds models as a linear stack of layers. Best for simple architectures without branching or skip connections.

**Pattern:**
```r
library(keras3)

model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(units = 128, activation = "relu") |>
  layer_dropout(rate = 0.2) |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dense(units = 10, activation = "softmax")

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_categorical_crossentropy(),
  metrics = c(metric_accuracy())
)
```

**Key points:**
- Use pipe operator (`|>`) for fluent chaining
- Specify `input_shape` in first layer or `keras_model_sequential(input_shape = ...)`
- Layers execute in order: input → layer_1 → layer_2 → ... → output

**When to use:**
- Feedforward networks (MLP)
- Simple CNNs
- Basic RNNs/LSTMs
- Any single-input, single-output sequential architecture

### Functional API

The **Functional API** builds models as directed acyclic graphs (DAGs). Enables complex architectures with multiple inputs/outputs, skip connections, and branching.

**Pattern:**
```r
# Define inputs
main_input <- keras_input(shape = c(100), name = "main_input")
auxiliary_input <- keras_input(shape = c(5), name = "aux_input")

# Build graph
x <- main_input |>
  layer_dense(64, activation = "relu") |>
  layer_dense(64, activation = "relu")

# Merge branches
merged <- layer_concatenate(list(x, auxiliary_input))

# Multiple outputs
main_output <- merged |>
  layer_dense(32, activation = "relu") |>
  layer_dense(1, activation = "sigmoid", name = "main_output")

auxiliary_output <- x |>
  layer_dense(1, activation = "sigmoid", name = "aux_output")

# Create model
model <- keras_model(
  inputs = list(main_input, auxiliary_input),
  outputs = list(main_output, auxiliary_output)
)
```

**Key points:**
- Use `keras_input()` to define input tensors
- Treat layers as functions: `output <- input |> layer_dense(...)`
- Create model with `keras_model(inputs = ..., outputs = ...)`
- Supports skip connections (ResNet-style), multi-head, encoder-decoder

**When to use:**
- Multi-input models (images + metadata)
- Multi-output models (multiple prediction tasks)
- Residual connections (ResNet, DenseNet)
- Encoder-decoder architectures (autoencoders, seq2seq)
- Any non-sequential topology

**Example: Skip connection (ResNet-style)**
```r
input <- keras_input(shape = c(32, 32, 3))

x <- input |>
  layer_conv_2d(64, 3, padding = "same", activation = "relu")

# Skip connection
residual <- x

x <- x |>
  layer_conv_2d(64, 3, padding = "same", activation = "relu") |>
  layer_conv_2d(64, 3, padding = "same")

# Add residual
x <- layer_add(list(x, residual)) |>
  layer_activation("relu")

output <- x |> layer_flatten() |> layer_dense(10, activation = "softmax")

model <- keras_model(inputs = input, outputs = output)
```

### Model Subclassing

**Model Subclassing** provides full control for research and custom training logic. Inherit from `Model()` and define forward pass in `call()` method.

**Pattern:**
```r
CustomModel <- new_model_class(
  classname = "CustomModel",

  initialize = function(num_classes = 10) {
    super$initialize()
    self$dense1 <- layer_dense(units = 64, activation = "relu")
    self$dense2 <- layer_dense(units = 32, activation = "relu")
    self$output_layer <- layer_dense(units = num_classes, activation = "softmax")
  },

  call = function(inputs, training = FALSE) {
    inputs |>
      self$dense1() |>
      self$dense2() |>
      self$output_layer()
  }
)

model <- CustomModel(num_classes = 10)
```

**Key points:**
- `initialize()` creates layers (deferred weight creation)
- `call()` defines forward pass logic
- `training` argument enables different behavior (dropout, batch norm)
- Use `super$initialize()` to call parent constructor

**When to use:**
- Custom architectures not expressible with Functional API
- Research models with complex control flow
- Dynamic computation graphs
- Custom training loops with manual gradient computation

For complete examples, see [examples/custom-layers-models.md](examples/custom-layers-models.md).

## Preprocessing Ecosystem

Keras3 includes a comprehensive preprocessing layer ecosystem for audio, image, text, and tabular data. These layers can be included directly in models, making preprocessing part of the model graph.

**Key benefit**: Preprocessing becomes part of the saved model, eliminating train/serve skew.

### Audio/Spectral Processing

```r
# Mel-spectrogram conversion
input <- keras_input(shape = c(16000))  # 1 second at 16kHz

spectrogram <- input |>
  layer_mel_spectrogram(
    num_mel_bins = 128,
    frame_length = 2048,
    frame_step = 512,
    fft_length = 2048,
    sampling_rate = 16000
  )

# STFT spectrogram
stft_spec <- input |>
  layer_stft_spectrogram(
    frame_length = 2048,
    frame_step = 512,
    fft_length = 2048
  )
```

### Image Processing

```r
# Preprocessing and augmentation pipeline
preprocessing <- keras_model_sequential() |>
  layer_rescaling(scale = 1/255) |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.2) |>
  layer_random_zoom(0.2) |>
  layer_random_crop(height = 224, width = 224)
```

### Text Processing

```r
# Text vectorization
text_vectorizer <- layer_text_vectorization(
  max_tokens = 10000,
  output_mode = "int",
  output_sequence_length = 100
)

# Adapt to training data
text_vectorizer |> adapt(train_texts)

# Use in model
input <- keras_input(shape = c(1), dtype = "string")
embedded <- input |>
  text_vectorizer() |>
  layer_embedding(input_dim = 10000, output_dim = 128)
```

### Categorical Processing

```r
# Category encoding
layer_category_encoding(num_tokens = 5, output_mode = "one_hot")

# Hashing for high cardinality
layer_hashing(num_bins = 1000)

# String lookup
lookup <- layer_string_lookup(vocabulary = c("cat", "dog", "bird"))
```

### Numerical Processing

```r
# Normalization (fit to training data)
normalizer <- layer_normalization(axis = -1)
normalizer |> adapt(train_data)

# Discretization (binning)
layer_discretization(bin_boundaries = c(0, 0.5, 1.0, 1.5, 2.0))
```

### Advanced Augmentation

```r
# RandAugment (automatic augmentation policy)
layer_rand_augment(
  value_range = c(0, 255),
  augmentations_per_image = 3,
  magnitude = 0.5
)

# MixUp augmentation
layer_mix_up(alpha = 0.2)

# CutMix augmentation
layer_cut_mix(alpha = 1.0)
```

**For complete preprocessing layers catalog with examples**, see [references/preprocessing-layers.md](references/preprocessing-layers.md).

## Keras Applications & Transfer Learning

Keras3 provides 30+ pretrained models for computer vision, trained on ImageNet. These models are the foundation for transfer learning.

### Available Architectures

**Popular families:**
- **ResNet**: ResNet50, ResNet101, ResNet152, ResNetV2 variants
- **EfficientNet**: EfficientNetB0-B7, EfficientNetV2
- **MobileNet**: MobileNetV2, MobileNetV3
- **ConvNeXt**: ConvNeXtTiny, ConvNeXtSmall, ConvNeXtBase
- **DenseNet**: DenseNet121, DenseNet169, DenseNet201
- **VGG**: VGG16, VGG19
- **Inception**: InceptionV3, InceptionResNetV2
- **Xception**: Xception

### Transfer Learning Pattern

Standard workflow: **freeze base → train head → fine-tune**

```r
library(keras3)

# Load pretrained model (without top classification layer)
base_model <- application_resnet50(
  include_top = FALSE,
  weights = "imagenet",
  input_shape = c(224, 224, 3),
  pooling = "avg"
)

# Freeze base model weights
base_model$trainable <- FALSE

# Add custom classification head
inputs <- keras_input(shape = c(224, 224, 3))
x <- inputs |>
  base_model() |>
  layer_dense(256, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(10, activation = "softmax")  # Custom number of classes

model <- keras_model(inputs = inputs, outputs = x)

# Train only the head
model |> compile(
  optimizer = optimizer_adam(learning_rate = 1e-3),
  loss = loss_categorical_crossentropy(),
  metrics = c(metric_accuracy())
)

model |> fit(train_data, epochs = 10, validation_data = val_data)

# Fine-tune: unfreeze some layers
base_model$trainable <- TRUE
freeze_weights(base_model, from = 1, to = 143)  # Freeze early layers

model |> compile(
  optimizer = optimizer_adam(learning_rate = 1e-5),  # Lower LR
  loss = loss_categorical_crossentropy(),
  metrics = c(metric_accuracy())
)

model |> fit(train_data, epochs = 5, validation_data = val_data)
```

### Preprocessing for Applications

Each application has a specific preprocessing function:

```r
# Load image
img <- image_load("photo.jpg", target_size = c(224, 224))
img_array <- image_to_array(img)
img_array <- array_reshape(img_array, c(1, 224, 224, 3))

# Preprocess for specific architecture
preprocessed <- application_resnet50_preprocess_input(img_array)

# Or generic
preprocessed <- application_preprocess_inputs(img_array, mode = "caffe")
```

**For complete applications guide with architecture details**, see [references/keras-applications.md](references/keras-applications.md).

## Training & Compilation

### Compile: Define Optimization Strategy

```r
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c(metric_accuracy(), metric_top_k_categorical_accuracy(k = 5))
)
```

**Common optimizers:**
- `optimizer_adam()`: Adaptive learning rate, momentum, good default
- `optimizer_sgd(momentum = 0.9)`: Stochastic gradient descent with momentum
- `optimizer_rmsprop()`: RMSprop for recurrent networks
- `optimizer_adamw()`: Adam with weight decay (better generalization)

**Common losses:**
- `loss_categorical_crossentropy()`: One-hot encoded labels
- `loss_sparse_categorical_crossentropy()`: Integer labels
- `loss_binary_crossentropy()`: Binary classification
- `loss_mean_squared_error()`: Regression
- `loss_mean_absolute_error()`: Regression, robust to outliers

**Common metrics:**
- `metric_accuracy()`: Classification accuracy
- `metric_auc()`: Area under ROC curve
- `metric_precision()`, `metric_recall()`: Precision/recall
- `metric_mean_absolute_error()`: Regression MAE

### Fit: Train the Model

```r
history <- model |> fit(
  x = train_data,
  y = train_labels,
  epochs = 50,
  batch_size = 32,
  validation_split = 0.2,  # Or validation_data = list(val_x, val_y)
  callbacks = list(
    callback_early_stopping(patience = 5, restore_best_weights = TRUE),
    callback_model_checkpoint("best_model.keras", save_best_only = TRUE)
  ),
  verbose = 1
)

# Plot training history
plot(history)
```

### Evaluate: Test Performance

```r
results <- model |> evaluate(test_data, test_labels)
cat("Test loss:", results$loss, "\n")
cat("Test accuracy:", results$accuracy, "\n")
```

### Predict: Generate Predictions

```r
# Batch prediction
predictions <- model |> predict(test_data)

# Single sample
single_pred <- model |> predict(array_reshape(sample, c(1, dim(sample))))

# With named outputs (multi-output models)
preds <- model |> predict(test_data)
main_pred <- preds$main_output
aux_pred <- preds$aux_output
```

## Advanced Topics

### Custom Layers

Create custom layers by subclassing `Layer()` with `build()` for weight creation and `call()` for forward pass.

```r
CustomDense <- new_layer_class(
  classname = "CustomDense",

  initialize = function(units = 32, ...) {
    super$initialize(...)
    self$units <- units
  },

  build = function(input_shape) {
    # Deferred weight creation (input shape known)
    self$w <- self$add_weight(
      shape = list(input_shape[[2]], self$units),
      initializer = "random_normal",
      trainable = TRUE,
      name = "kernel"
    )
    self$b <- self$add_weight(
      shape = list(self$units),
      initializer = "zeros",
      trainable = TRUE,
      name = "bias"
    )
  },

  call = function(inputs) {
    op_matmul(inputs, self$w) + self$b
  }
)

# Use in model
model <- keras_model_sequential() |>
  CustomDense(units = 64) |>
  layer_activation("relu") |>
  layer_dense(10, activation = "softmax")
```

**Key patterns:**
- `build()` is called automatically on first forward pass
- Use `self$add_weight()` to create trainable parameters
- `call()` receives inputs and returns outputs
- `super$initialize()` calls parent constructor

**For complete custom layer examples**, see [examples/custom-layers-models.md](examples/custom-layers-models.md).

### Custom Training Loops

For research or custom training logic, implement manual training loops with gradient tape.

```r
# Define loss and optimizer
loss_fn <- loss_sparse_categorical_crossentropy()
optimizer <- optimizer_adam()

# Training step
train_step <- function(x, y) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x, training = TRUE)
    loss <- loss_fn(y, predictions)
  })

  gradients <- tape$gradient(loss, model$trainable_variables)
  optimizer$apply(gradients, model$trainable_variables)

  loss
}

# Training loop
for (epoch in 1:epochs) {
  losses <- c()

  for (batch in train_dataset) {
    c(x, y) %<-% batch
    loss <- train_step(x, y)
    losses <- c(losses, as.numeric(loss))
  }

  cat("Epoch", epoch, "- Loss:", mean(losses), "\n")
}
```

**Key components:**
- `tf$GradientTape()`: Records operations for autodiff
- `tape$gradient()`: Computes gradients
- `optimizer$apply()`: Updates weights
- Manual metric tracking and logging

**For complete custom training loop examples**, see [templates/custom-training-loop.R](templates/custom-training-loop.R) and [references/advanced-patterns.md](references/advanced-patterns.md).

### Callbacks

Callbacks provide hooks into the training process for monitoring, checkpointing, and dynamic behavior.

```r
callbacks <- list(
  # Stop training when validation loss stops improving
  callback_early_stopping(
    monitor = "val_loss",
    patience = 5,
    restore_best_weights = TRUE
  ),

  # Save best model
  callback_model_checkpoint(
    filepath = "best_model.keras",
    monitor = "val_accuracy",
    save_best_only = TRUE
  ),

  # Reduce learning rate on plateau
  callback_reduce_lr_on_plateau(
    monitor = "val_loss",
    factor = 0.5,
    patience = 3,
    min_lr = 1e-7
  ),

  # TensorBoard logging
  callback_tensorboard(
    log_dir = "logs",
    histogram_freq = 1
  )
)

model |> fit(
  train_data, train_labels,
  epochs = 100,
  validation_split = 0.2,
  callbacks = callbacks
)
```

**Custom callbacks:**
```r
CustomCallback <- new_callback_class(
  classname = "CustomCallback",

  on_epoch_end = function(epoch, logs = NULL) {
    cat(sprintf("Epoch %d: loss = %.4f\n", epoch, logs$loss))
  },

  on_train_end = function(logs = NULL) {
    cat("Training completed!\n")
  }
)

callback <- CustomCallback()
```

**For complete callbacks reference**, see [references/callbacks-reference.md](references/callbacks-reference.md).

## Multi-Backend Support

Keras3's revolutionary feature: seamless backend switching between TensorFlow, JAX, and PyTorch.

### Backend Selection

```r
library(keras3)

# Set backend before first keras operation
config_set_backend("tensorflow")  # Default
config_set_backend("jax")
config_set_backend("torch")

# Check current backend
config_backend()
```

### Backend Comparison

| Backend | Strengths | Use Cases |
|---------|-----------|-----------|
| **TensorFlow** | Production-ready, TF ecosystem, TF Serving | Deployment, serving, mature tooling |
| **JAX** | Fast, functional, XLA compilation, TPU-optimized | Research, TPU training, numerical computing |
| **PyTorch** | Debugging, dynamic graphs, torch ecosystem | Development, eager execution, PyTorch integration |

### Backend-Specific Optimizations

**JAX**: Functional programming, JIT compilation
```r
config_set_backend("jax")

# JAX benefits from static shapes and pure functions
model <- keras_model_sequential() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")

# JAX will JIT-compile the model for faster execution
```

**TensorFlow**: Graph optimization, SavedModel export
```r
config_set_backend("tensorflow")

# TensorFlow benefits from tf.function and AutoGraph
# Ideal for production deployment with TF Serving
```

**PyTorch**: Dynamic computation, debugging
```r
config_set_backend("torch")

# PyTorch ideal for development with easy debugging
# Direct access to PyTorch tensors and operations
```

**For complete backend guide with performance comparisons**, see [references/backend-guide.md](references/backend-guide.md).

## R-Specific Patterns

Keras3 for R provides idiomatic interfaces that feel natural to R users.

### Pipe Operator Integration

```r
# Native R pipe (|>) fully supported
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dropout(0.2) |>
  layer_dense(10, activation = "softmax")
```

### Array Reshaping: Use array_reshape()

**IMPORTANT**: Always use `array_reshape()`, NOT `dim<-()` assignment.

```r
# Correct
x <- array_reshape(x, c(nrow(x), 28, 28, 1))

# Wrong (breaks gradient tracking)
dim(x) <- c(nrow(x), 28, 28, 1)
```

### List Unpacking with %<-%

```r
# Unpack list elements
c(x_train, y_train) %<-% dataset$train
c(x_test, y_test) %<-% dataset$test

# Unpack batch in training loop
for (batch in dataset) {
  c(images, labels) %<-% batch
  # Process batch
}
```

### Named Lists for Multi-Output

```r
# Multi-output model training
model |> fit(
  x = list(
    main_input = x_train_main,
    aux_input = x_train_aux
  ),
  y = list(
    main_output = y_train_main,
    aux_output = y_train_aux
  ),
  epochs = 10
)
```

### Anonymous Functions

```r
# Modern R anonymous function syntax
layer_lambda(\(x) x^2)

# Or traditional
layer_lambda(function(x) x^2)
```

## Model Serialization

### Save and Load Complete Models

**Recommended**: Use `.keras` format (cross-backend compatible)

```r
# Save entire model (architecture + weights + optimizer state)
model |> save_model("my_model.keras")

# Load model
loaded_model <- load_model("my_model.keras")

# Ready to use immediately
predictions <- loaded_model |> predict(test_data)
```

### Save Weights Only

```r
# Save weights
model |> save_model_weights("model_weights.weights.h5")

# Load weights (model architecture must match)
model |> load_model_weights("model_weights.weights.h5")
```

### Configuration-Based Serialization

```r
# Get model configuration
config <- get_config(model)

# Save config (JSON-serializable)
jsonlite::write_json(config, "model_config.json")

# Recreate model from config
config <- jsonlite::read_json("model_config.json")
model_new <- from_config(config)
```

### Custom Objects Registration

For custom layers/models, register them for serialization:

```r
# Save with custom objects
model |> save_model("custom_model.keras")

# Load with custom objects
loaded_model <- load_model(
  "custom_model.keras",
  custom_objects = list(
    CustomLayer = CustomLayer,
    CustomModel = CustomModel
  )
)
```

**For deployment patterns and SavedModel export**, see [examples/deployment-comparison.md](examples/deployment-comparison.md). For TensorFlow-specific deployment, refer to the **r-tensorflow** skill.

## Domain Applications

### Vision: Image Classification

**Simple CNN with Sequential API:**
```r
model <- keras_model_sequential(input_shape = c(28, 28, 1)) |>
  layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = "relu") |>
  layer_max_pooling_2d(pool_size = c(2, 2)) |>
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = "relu") |>
  layer_max_pooling_2d(pool_size = c(2, 2)) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(10, activation = "softmax")
```

**Transfer learning with data augmentation:**
```r
# Include augmentation in model
input <- keras_input(shape = c(224, 224, 3))

augmented <- input |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.1) |>
  layer_random_zoom(0.1)

base_model <- application_efficientnet_b0(
  include_top = FALSE,
  weights = "imagenet",
  input_tensor = augmented,
  pooling = "avg"
)

base_model$trainable <- FALSE

output <- base_model$output |>
  layer_dense(256, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(num_classes, activation = "softmax")

model <- keras_model(inputs = input, outputs = output)
```

### NLP: Text Classification

```r
# Text preprocessing in model
input <- keras_input(shape = c(1), dtype = "string", name = "text")

# Vectorize and embed
vectorizer <- layer_text_vectorization(
  max_tokens = 10000,
  output_sequence_length = 100
)
vectorizer |> adapt(train_texts)

x <- input |>
  vectorizer() |>
  layer_embedding(input_dim = 10000, output_dim = 128) |>
  layer_lstm(64) |>
  layer_dense(64, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(num_classes, activation = "softmax")

model <- keras_model(inputs = input, outputs = x)

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c(metric_accuracy())
)
```

**For complete NLP patterns including attention mechanisms**, see [examples/nlp-patterns.md](examples/nlp-patterns.md).

### Audio: Audio Classification

**Keras3-native audio classification** using `layer_mel_spectrogram()` (no torch dependency):

```r
# Audio preprocessing directly in model
input <- keras_input(shape = c(16000), name = "audio")  # 1 second at 16kHz

# Convert to Mel-spectrogram
spectrogram <- input |>
  layer_mel_spectrogram(
    num_mel_bins = 128,
    frame_length = 2048,
    frame_step = 512,
    fft_length = 2048,
    sampling_rate = 16000
  ) |>
  layer_normalization()

# CNN on spectrogram
x <- spectrogram |>
  layer_conv_2d(32, c(3, 3), activation = "relu", padding = "same") |>
  layer_max_pooling_2d(c(2, 2)) |>
  layer_conv_2d(64, c(3, 3), activation = "relu", padding = "same") |>
  layer_max_pooling_2d(c(2, 2)) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(num_classes, activation = "softmax")

model <- keras_model(inputs = input, outputs = x)
```

**For complete audio classification examples**, see [examples/audio-classification.md](examples/audio-classification.md).

### Time Series: Forecasting

```r
# LSTM for time series
model <- keras_model_sequential(input_shape = c(window_size, num_features)) |>
  layer_lstm(64, return_sequences = TRUE) |>
  layer_dropout(0.2) |>
  layer_lstm(32) |>
  layer_dropout(0.2) |>
  layer_dense(1)  # Forecast next value

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_mean_squared_error(),
  metrics = c(metric_mean_absolute_error())
)

# GRU alternative (faster, similar performance)
model <- keras_model_sequential(input_shape = c(window_size, num_features)) |>
  layer_gru(64, return_sequences = TRUE) |>
  layer_dropout(0.2) |>
  layer_gru(32) |>
  layer_dense(1)
```

## Integration with Other Skills

### r-tensorflow Skill

**When to use r-tensorflow:**
- TensorFlow backend infrastructure setup (GPU configuration, CUDA)
- SavedModel deployment for TensorFlow Serving
- Low-level TensorFlow operations (tf$* functions)
- TFRecord data pipelines
- TensorFlow Lite export

**Pattern**: Use keras3 for model building, defer to r-tensorflow for TensorFlow-specific deployment.

### r-deeplearning Skill

**When to use r-deeplearning:**
- Framework comparison (keras3 vs torch vs tensorflow)
- Decision guidance on which framework to use
- General deep learning concepts and paradigms

**Pattern**: Reference r-deeplearning for strategic framework decisions, then use keras3 for implementation.

### learning-paradigms Skill

**When to use learning-paradigms:**
- Transfer learning conceptual guidance
- Learning paradigm selection (supervised, unsupervised, reinforcement)
- Meta-learning and few-shot learning patterns

**Pattern**: Use learning-paradigms for high-level strategy, keras3 for implementation.

## Supporting Files

This skill includes comprehensive supporting documentation:

### Examples
- **[examples/functional-api-advanced.md](examples/functional-api-advanced.md)**: Complex Functional API patterns (multi-input/output, skip connections, encoder-decoder)
- **[examples/custom-layers-models.md](examples/custom-layers-models.md)**: Custom layer and model subclassing with complete examples
- **[examples/audio-classification.md](examples/audio-classification.md)**: Keras3-native audio classification using Mel-spectrogram layers
- **[examples/nlp-patterns.md](examples/nlp-patterns.md)**: Text classification, embeddings, LSTMs, attention mechanisms
- **[examples/deployment-comparison.md](examples/deployment-comparison.md)**: Model serialization and deployment strategies

### References
- **[references/preprocessing-layers.md](references/preprocessing-layers.md)**: Complete catalog of preprocessing layers (audio, image, text, categorical, numerical, augmentation)
- **[references/keras-applications.md](references/keras-applications.md)**: 30+ pretrained model architectures with transfer learning patterns
- **[references/backend-guide.md](references/backend-guide.md)**: Multi-backend comparison, selection guide, performance characteristics
- **[references/callbacks-reference.md](references/callbacks-reference.md)**: Complete callbacks documentation with custom callback patterns
- **[references/advanced-patterns.md](references/advanced-patterns.md)**: Custom training loops, gradient manipulation, advanced techniques

### Templates
- **[templates/simple-classifier.R](templates/simple-classifier.R)**: Template for basic image/tabular classification
- **[templates/custom-training-loop.R](templates/custom-training-loop.R)**: Template for manual training loop with gradient tape

---

**Note**: This skill focuses on keras3-first patterns. For TensorFlow backend infrastructure (GPU setup, SavedModel export, TF Serving), defer to the **r-tensorflow** skill. For framework comparison and decision guidance, reference the **r-deeplearning** skill.
