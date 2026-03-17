---
name: r-tensorflow
description: Expert TensorFlow for R using tensorflow package and keras3 integration. Use when working with TensorFlow in R, mentions "tensorflow em R", "tensorflow for R", "tensorflow R interface", "install_tensorflow", "TensorFlow deployment", "TensorFlow infrastructure", "keras3 backend", "TensorFlow graph", "SavedModel", "tf_function", discusses TensorFlow-specific features, deployment pipelines, or integration with Python TensorFlow code. ONLY R - do NOT activate for Python TensorFlow.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Grep, Glob, Bash
---

# TensorFlow for R - Infrastructure and Deployment

Expert guidance for using TensorFlow in R through the `tensorflow` package, with emphasis on installation, keras3 integration, deployment, and when to choose TensorFlow vs other deep learning frameworks in R.

## Overview

The **tensorflow** R package provides a complete interface to TensorFlow, enabling:
- Full TensorFlow API access through `reticulate` bridge
- Seamless keras3 integration for high-level modeling
- Production deployment with SavedModel format
- Graph optimization with `tf_function()`
- GPU acceleration and distributed training
- Integration with Python TensorFlow ecosystems

**Key Distinction**: TensorFlow for R serves as the infrastructure layer, while keras3 provides the high-level API. Most users interact primarily with keras3, accessing TensorFlow directly for deployment, custom operations, or advanced control.

## When to Use TensorFlow in R

### Choose TensorFlow When:
- **Existing TensorFlow infrastructure**: Integrating with existing TF pipelines
- **Deployment requirements**: Need TensorFlow Serving or SavedModel format
- **Cross-platform models**: Deploying to mobile (TFLite) or web (TF.js)
- **Python interop**: Working with Python TensorFlow code
- **Graph optimization**: Need `tf_function()` compilation
- **Multi-backend flexibility**: keras3 with TensorFlow backend

### Choose torch When:
- Research and experimentation requiring flexibility
- Custom training loops and novel architectures
- State-of-the-art research implementations
- Need full control over training process
- PyTorch-based pretrained models

### Choose keras3 Alone When:
- Standard architectures (ResNet, LSTM, transformers)
- Rapid prototyping with high-level API
- Backend-agnostic code (TensorFlow/JAX/torch)
- Production with built-in `fit()` workflow

**Study Path**: Start with keras3 (gentle intro) → torch (low-level control) → TensorFlow (infrastructure/deployment)

For complete framework comparison, see [references/framework-comparison.md](references/framework-comparison.md)

---

## Installation and Setup

### Basic Installation

```r
# Step 1: Install R package
install.packages("tensorflow")
# Or development version
remotes::install_github("rstudio/tensorflow")

# Step 2: Install Python (if needed)
library(reticulate)
install_python()

# Step 3: Install TensorFlow in isolated environment
library(tensorflow)
install_tensorflow(envname = "r-tensorflow")

# Verification
tf$constant("Hello TensorFlow!")
```

### Installation Variants

```r
# GPU-capable (default)
install_tensorflow()

# Specific version
install_tensorflow(version = "2.10")

# CPU-only (smaller package)
install_tensorflow(version = "cpu")

# Nightly development build
install_tensorflow(version = "nightly")

# Custom environment name
install_tensorflow(envname = "my-tf-env")

# Virtual environment method
install_tensorflow(method = "virtualenv")

# Conda method (Windows recommended)
install_tensorflow(method = "conda")

# With additional packages
install_tensorflow(extra_packages = c("tensorflow-hub", "tensorflow-probability"))

# Specific Python version
install_tensorflow(python_version = "3.10")

# Linux GPU with automatic CUDA/cuDNN (v2.16.0+)
install_tensorflow()  # Auto-detects GPU and installs CUDA
```

### Configuration and Verification

```r
# Check configuration
tf_config()

# Check version
tf_version()

# GPU availability
tf$config$list_physical_devices("GPU")

# Set visible GPUs
Sys.setenv(CUDA_VISIBLE_DEVICES = "0,1")

# Memory growth (prevent GPU memory preallocation)
gpus <- tf$config$list_physical_devices("GPU")
if (length(gpus) > 0) {
  tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)
}
```

### Common Installation Issues

For comprehensive troubleshooting guide, see [references/installation-troubleshooting.md](references/installation-troubleshooting.md)

**Quick fixes:**
- **Module not found**: Reinstall with `install_tensorflow(force = TRUE)`
- **Environment corruption**: Remove and recreate with new envname
- **GPU not detected (Linux)**: Update CUDA/cuDNN or use auto-install (v2.16.0+)
- **WSL issues**: Use latest tensorflow (v2.20.0+) with improved WSL support
- **Mac M1**: Use method="virtualenv" with ARM64-compatible builds

---

## Core TensorFlow Concepts

### Tensors and Operations

```r
# Create tensors
x <- tf$constant(c(1, 2, 3, 4), shape = c(2, 2))
y <- tf$Variable(initial_value = 0.0, trainable = TRUE)

# Operations
z <- tf$add(x, 10)
product <- tf$matmul(x, x)

# Type conversion
as.array(x)  # Convert to R array
as_tensor(matrix(1:4, 2, 2))  # R to tensor
```

### Automatic Differentiation

```r
# GradientTape for custom gradients
with(tf$GradientTape() %as% tape, {
  loss <- model(x, training = TRUE)
})

gradients <- tape$gradient(loss, model$trainable_weights)
optimizer$apply_gradients(zip_lists(gradients, model$trainable_weights))
```

### Graph Compilation with tf_function

```r
# Compile R functions to TensorFlow graphs
train_step <- tf_function(function(x, y) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x, training = TRUE)
    loss <- loss_fn(y, predictions)
  })

  gradients <- tape$gradient(loss, model$trainable_weights)
  optimizer$apply_gradients(zip_lists(gradients, model$trainable_weights))

  return(loss)
})

# Significant performance improvement for loops
for (epoch in 1:num_epochs) {
  loss <- train_step(x_batch, y_batch)
}
```

---

## Keras3 Integration

TensorFlow for R primarily uses **keras3** as the high-level API. The keras3 package supports multiple backends (TensorFlow, JAX, torch), with TensorFlow as the default.

### Model Building Patterns

```r
library(keras3)

# Sequential API
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dropout(0.2) |>
  layer_dense(10, activation = "softmax")

# Functional API (multi-input/output)
input_a <- keras_input(shape = c(100))
input_b <- keras_input(shape = c(50))

x <- layer_dense(input_a, 64, activation = "relu")
y <- layer_dense(input_b, 32, activation = "relu")

merged <- layer_concatenate(c(x, y))
output <- layer_dense(merged, 1, activation = "sigmoid")

model <- keras_model(
  inputs = list(input_a, input_b),
  outputs = output
)

# Model subclassing (custom models)
CustomModel <- new_keras_model(
  "CustomModel",
  initialize = function() {
    super$initialize()
    self$dense1 <- layer_dense(128, activation = "relu")
    self$dense2 <- layer_dense(10, activation = "softmax")
  },
  call = function(inputs) {
    x <- self$dense1(inputs)
    self$dense2(x)
  }
)
```

### Training Workflow

```r
# Compile model
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c("accuracy")
)

# Train with callbacks
history <- model |> fit(
  x_train, y_train,
  epochs = 50,
  batch_size = 128,
  validation_split = 0.2,
  callbacks = list(
    callback_early_stopping(monitor = "val_loss", patience = 5),
    callback_model_checkpoint("best_model.keras", save_best_only = TRUE),
    callback_reduce_lr_on_plateau(monitor = "val_loss", factor = 0.5, patience = 3)
  )
)

# Evaluate and predict
results <- model |> evaluate(x_test, y_test)
predictions <- model |> predict(x_test)
```

For complete Keras3 workflows and examples, see [examples/keras-workflows.md](examples/keras-workflows.md)

---

## Model Deployment and Serialization

### SavedModel Format (Recommended)

```r
# Save complete model
save_model(model, "saved_model/my_model")

# Load model
loaded_model <- load_model("saved_model/my_model")

# Verify loaded model
loaded_model |> evaluate(x_test, y_test)
```

### Keras Format (.keras)

```r
# Save as .keras (zip archive)
save_model(model, "my_model.keras")

# Load
model <- load_model("my_model.keras")
```

### Weights-Only Checkpoint

```r
# Save weights during training
checkpoint <- callback_model_checkpoint(
  filepath = "checkpoints/weights_epoch_{epoch:02d}.h5",
  save_weights_only = TRUE,
  save_best_only = TRUE,
  monitor = "val_loss"
)

model |> fit(x, y, callbacks = list(checkpoint))

# Load weights into existing model
model |> load_model_weights_tf("checkpoints/weights_epoch_10.h5")
```

### Export to ONNX (Cross-Platform)

```r
# Requires onnx package
# Export for deployment to non-TensorFlow runtimes
# See references/deployment-strategies.md for details
```

### TensorFlow Serving Integration

```r
# Export SavedModel with serving signature
export_savedmodel(
  model,
  export_dir_base = "serving_models/",
  versioned = TRUE  # Creates timestamped versions
)

# View saved model
view_savedmodel("serving_models/1234567890")
```

For production deployment patterns, see [references/deployment-strategies.md](references/deployment-strategies.md)

---

## Data Pipelines with tfdatasets

The **tfdatasets** package provides efficient data loading and preprocessing:

```r
library(tfdatasets)

# Load from tensors
dataset <- tensor_slices_dataset(list(x_train, y_train))

# Transform pipeline
dataset <- dataset |>
  dataset_shuffle(buffer_size = 10000) |>
  dataset_batch(batch_size = 32) |>
  dataset_map(function(x, y) {
    list(x / 255, y)  # Normalize
  }) |>
  dataset_prefetch(buffer_size = tf$data$AUTOTUNE) |>
  dataset_cache()  # Cache in memory

# Use in training
model |> fit(dataset, epochs = 10)

# Load from files
text_dataset <- text_line_dataset("data.txt") |>
  dataset_map(preprocess_function) |>
  dataset_batch(32)

# TFRecord format
tfrecord_dataset <- tfrecord_dataset("data.tfrecord") |>
  dataset_map(parse_function)
```

---

## GPU Configuration and Optimization

### GPU Detection and Setup

```r
# List available GPUs
gpus <- tf$config$list_physical_devices("GPU")
print(gpus)

# Set visible devices
tf$config$set_visible_devices(gpus[[1]], "GPU")

# Memory growth (prevent preallocation)
for (gpu in gpus) {
  tf$config$experimental$set_memory_growth(gpu, TRUE)
}

# Set memory limit
tf$config$set_logical_device_configuration(
  gpus[[1]],
  list(tf$config$LogicalDeviceConfiguration(memory_limit = 4096))
)
```

### Mixed Precision Training

```r
# Enable mixed precision (FP16)
policy <- tf$keras$mixed_precision$Policy("mixed_float16")
tf$keras$mixed_precision$set_global_policy(policy)

# Build model (automatically uses mixed precision)
model <- keras_model_sequential() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax", dtype = "float32")  # Keep output FP32

# ~2x speedup with minimal accuracy loss
```

### Multi-GPU Training

```r
# MirroredStrategy for single-machine multi-GPU
strategy <- tf$distribute$MirroredStrategy()

with(strategy$scope(), {
  model <- keras_model_sequential() |>
    layer_dense(128, activation = "relu") |>
    layer_dense(10, activation = "softmax")

  model |> compile(
    optimizer = optimizer_adam(),
    loss = loss_sparse_categorical_crossentropy(),
    metrics = c("accuracy")
  )
})

# Adjust batch size for all replicas
global_batch_size <- 32 * strategy$num_replicas_in_sync

model |> fit(dataset, epochs = 10)
```

For comprehensive GPU optimization strategies, see [references/gpu-optimization.md](references/gpu-optimization.md)

---

## Custom Training Loops

When `fit()` is insufficient, use custom training loops:

```r
# Setup
optimizer <- optimizer_adam()
loss_fn <- loss_sparse_categorical_crossentropy()
train_acc_metric <- metric_sparse_categorical_accuracy()

# Training loop
for (epoch in 1:num_epochs) {
  cat("Epoch", epoch, "\n")

  # Iterate over batches
  for (batch in iterate(train_dataset)) {
    with(tf$GradientTape() %as% tape, {
      logits <- model(batch[[1]], training = TRUE)
      loss_value <- loss_fn(batch[[2]], logits)
    })

    grads <- tape$gradient(loss_value, model$trainable_weights)
    optimizer$apply_gradients(zip_lists(grads, model$trainable_weights))

    # Update metrics
    train_acc_metric$update_state(batch[[2]], logits)
  }

  # Display metrics
  train_acc <- train_acc_metric$result()
  cat("Training accuracy:", as.numeric(train_acc), "\n")
  train_acc_metric$reset_state()
}
```

For advanced custom training patterns, see [examples/custom-training-loops.md](examples/custom-training-loops.md)

---

## Transfer Learning and Fine-Tuning

### Basic Transfer Learning

```r
# Load pretrained model
base_model <- application_resnet50(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(224, 224, 3)
)

# Freeze base model
base_model$trainable <- FALSE

# Add custom head
inputs <- keras_input(shape = c(224, 224, 3))
x <- base_model(inputs, training = FALSE)  # Inference mode
x <- layer_global_average_pooling_2d()(x)
outputs <- layer_dense(x, units = 10, activation = "softmax")

model <- keras_model(inputs, outputs)

# Train only new layers
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_categorical_crossentropy(),
  metrics = c("accuracy")
)

model |> fit(train_data, epochs = 10)
```

### Fine-Tuning

```r
# Unfreeze base model for fine-tuning
base_model$trainable <- TRUE

# Recompile with very low learning rate
model |> compile(
  optimizer = optimizer_adam(learning_rate = 1e-5),  # Very low LR
  loss = loss_categorical_crossentropy(),
  metrics = c("accuracy")
)

# Fine-tune
model |> fit(train_data, epochs = 5)
```

**Important**: Use `training = FALSE` when calling BatchNormalization layers during fine-tuning to keep them in inference mode.

---

## TensorFlow Hub Integration

```r
library(tfhub)

# Use pretrained embeddings
hub_layer <- layer_hub(
  handle = "https://tfhub.dev/google/nnlm-en-dim50/2",
  trainable = TRUE
)

model <- keras_model_sequential() |>
  hub_layer |>
  layer_dense(16, activation = "relu") |>
  layer_dense(1, activation = "sigmoid")

# Train
model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_binary_crossentropy(),
  metrics = c("accuracy")
)
```

---

## Preprocessing Layers

Keras3 preprocessing layers enable end-to-end models:

```r
# Text preprocessing
text_vectorizer <- layer_text_vectorization(max_tokens = 10000)

# Adapt to vocabulary
text_vectorizer |> adapt(raw_text_data)

# Use in model
model <- keras_model_sequential() |>
  text_vectorizer |>
  layer_embedding(input_dim = 10000, output_dim = 128) |>
  layer_lstm(64) |>
  layer_dense(1, activation = "sigmoid")

# Image preprocessing
model <- keras_model_sequential(input_shape = c(NULL, NULL, 3)) |>
  layer_rescaling(scale = 1/255) |>
  layer_resizing(height = 224, width = 224) |>
  layer_conv_2d(32, 3, activation = "relu") |>
  # ... rest of model
```

**Advantage**: Preprocessing embedded in model ensures consistency between training and serving.

---

## Experiment Tracking with tfruns

```r
library(tfruns)

# Define training script with flags
# train.R:
FLAGS <- flags(
  flag_numeric("learning_rate", 0.001),
  flag_integer("epochs", 10),
  flag_integer("batch_size", 32)
)

# Run training
training_run("train.R", flags = list(
  learning_rate = 0.01,
  epochs = 20
))

# Compare runs
compare_runs()

# List runs
ls_runs()

# View specific run
view_run("runs/2024-03-16T10-30-00Z")
```

---

## Package Architecture and Integration

### Lazy Loading Pattern

The tensorflow package uses lazy loading for fast startup:

```r
# TensorFlow loads only when first accessed
library(tensorflow)  # Fast

# First access triggers loading
tf$constant(1)  # Loads TensorFlow
```

### Reticulate Integration

TensorFlow for R bridges to Python via `reticulate`:

```r
# Access Python TensorFlow API
tf$nn$relu(...)
tf$keras$layers$Dense(...)

# Type conversion
tensor <- as_tensor(r_array)  # R to TF
r_array <- as.array(tensor)   # TF to R

# Custom Python code
py_run_string("import tensorflow as tf")
```

### S3 Methods for Tensors

```r
# Tensors behave like R arrays
x <- tf$constant(c(1, 2, 3, 4), shape = c(2, 2))

as.array(x)      # Convert to array
dim(x)           # Get dimensions
length(x)        # Get length
x[1, ]           # Subset (converts to R)
```

---

## Migration and Compatibility

### TensorFlow 1.x to 2.x Migration

```r
# Use compatibility mode for gradual migration
tf$compat$v1$enable_eager_execution()  # TF 2.x behavior in TF 1.x code

# Or use compatibility API
use_compat("v1")  # Run TF 1.x code in TF 2.x
use_compat("v2")  # Run TF 2.x code explicitly
```

### Breaking Changes (v2.7.0)

**shape() behavior changed**:
```r
# Old behavior (< v2.7.0)
shape <- shape(tensor)  # Returns R list

# New behavior (>= v2.7.0)
shape <- shape(tensor)  # Returns tf.TensorShape object

# Migration
shape_list <- as.list(shape(tensor))
shape_int <- as.integer(shape(tensor))
```

### Package Version History

- **v2.20.0** (Aug 2024): NumPy 2.0 support, WSL GPU fixes
- **v2.16.0** (Apr 2024): keras3 integration, auto CUDA/cuDNN (Linux)
- **v2.14.0**: Removed `install_tensorflow_extras()`
- **v2.13.0**: Default env changed to "r-tensorflow"
- **v2.7.0**: Breaking change in `shape()` return type

---

## Best Practices

### Installation
- Use isolated environments (`envname` parameter)
- Pin specific versions for reproducibility
- Test GPU detection immediately after install
- Use conda method on Windows for reliability

### Model Development
- Start with keras3 high-level API
- Use `tf_function()` for performance-critical loops
- Implement callbacks for training control
- Save checkpoints frequently during long training

### Deployment
- Use SavedModel format for production
- Test loaded models before deployment
- Version models with timestamps
- Include preprocessing in model for consistency

### Performance
- Enable memory growth to prevent GPU memory issues
- Use `dataset_prefetch()` and `dataset_cache()` for data loading
- Apply mixed precision for 2x speedup on modern GPUs
- Profile with `tf$profiler` for bottleneck identification

### Debugging
- Use `tf$debugging$assert_*` functions for runtime checks
- Enable eager execution during debugging
- Use `tf$print()` inside `tf_function()` for debugging
- Check tensor shapes frequently with `shape()`

---

## Common Gotchas

1. **Forgetting to recompile** after changing `trainable` status
2. **BatchNorm in training mode during inference** (use `training = FALSE`)
3. **Not adapting preprocessing layers** before training
4. **Memory growth not enabled** causing GPU OOM
5. **Using `training = TRUE`** in transfer learning base model
6. **Hardcoding batch size** in model architecture
7. **Not using `dataset_prefetch()`** causing training slowdowns
8. **Shape mismatches** between Python (0-indexed) and R (1-indexed)

For comprehensive troubleshooting, see [references/common-gotchas.md](references/common-gotchas.md)

---

## Complete Example

For a complete end-to-end example (CIFAR-10 image classification), see [examples/cifar10-complete.md](examples/cifar10-complete.md)

---

## Related Packages

- **keras3**: High-level neural networks API (primary interface)
- **tfdatasets**: Efficient data input pipelines
- **tfhub**: Access to pretrained models and embeddings
- **tfruns**: Experiment tracking and hyperparameter tuning
- **tfautograph**: Automatic graph compilation
- **tfprobability**: Probabilistic programming and statistical modeling

---

## When to Use Low-Level TensorFlow API

Most users should use **keras3** for model building. Access low-level TensorFlow API when:

- Custom operations not available in Keras
- Need `tf_function()` graph compilation
- Implementing research papers with TF-specific operations
- Deployment requiring SavedModel manipulation
- Integration with TensorFlow Serving or TFLite
- Advanced distributed training strategies

---

## Resources

### Documentation
- Official site: https://tensorflow.rstudio.com
- Keras3 docs: https://keras3.posit.co
- TensorFlow API: https://www.tensorflow.org/api_docs

### Supporting Files
- Framework comparison: [references/framework-comparison.md](references/framework-comparison.md)
- Installation troubleshooting: [references/installation-troubleshooting.md](references/installation-troubleshooting.md)
- GPU optimization: [references/gpu-optimization.md](references/gpu-optimization.md)
- Deployment strategies: [references/deployment-strategies.md](references/deployment-strategies.md)
- Keras workflows: [examples/keras-workflows.md](examples/keras-workflows.md)
- Custom training: [examples/custom-training-loops.md](examples/custom-training-loops.md)
- Complete example: [examples/cifar10-complete.md](examples/cifar10-complete.md)

### Books
- **Deep Learning with R** (2nd edition) - Comprehensive coverage of keras3 and TensorFlow

---

## Summary

TensorFlow for R provides robust infrastructure for deep learning in R, with keras3 serving as the primary high-level interface. Key strengths:

✅ **Seamless keras3 integration** for rapid development
✅ **Production deployment** with SavedModel and TensorFlow Serving
✅ **GPU acceleration** with automatic CUDA setup
✅ **Multi-backend flexibility** through keras3 (TensorFlow/JAX/torch)
✅ **Python interoperability** for TensorFlow ecosystem integration
✅ **Graph optimization** with `tf_function()` compilation

**Recommended workflow**: Build models with keras3, deploy with TensorFlow SavedModel format, optimize with `tf_function()` when needed.
