# Deployment and Serialization Comparison

This guide compares different model serialization formats in Keras3 and provides guidance on choosing the right format for your deployment needs.

## Overview of Serialization Formats

Keras3 supports multiple serialization formats, each with different use cases and trade-offs.

| Format | Extension | Use Case | Includes | Backend Support |
|--------|-----------|----------|----------|----------------|
| Keras Native | .keras | Recommended for Keras workflows | Architecture + weights + optimizer | All (JAX, TF, PyTorch) |
| SavedModel | (directory) | TensorFlow ecosystem integration | Full computational graph | TensorFlow only |
| Weights Only | .weights.h5 | Transfer learning, checkpoints | Weights only | All |
| JSON Config | .json | Architecture sharing | Architecture only | All |

## .keras Format (Recommended)

The native Keras3 format, ideal for most use cases.

```r
library(keras3)

# Build a simple model
model <- keras_model_sequential() |>
  layer_dense(units = 64, activation = "relu", input_shape = 10) |>
  layer_dropout(rate = 0.5) |>
  layer_dense(units = 32, activation = "relu") |>
  layer_dense(units = 1, activation = "sigmoid")

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

# Train (example with dummy data)
x_train <- array(rnorm(1000 * 10), dim = c(1000, 10))
y_train <- array(rbinom(1000, 1, 0.5), dim = c(1000, 1))

history <- model |> fit(
  x = x_train,
  y = y_train,
  epochs = 5,
  batch_size = 32
)

# Save as .keras format
save_model(model, "my_model.keras")

# Load model
loaded_model <- load_model("my_model.keras")

# Everything is preserved:
# - Architecture
# - Weights
# - Optimizer state
# - Compilation settings
```

### Advantages of .keras Format

```r
# 1. Backend agnostic - works with JAX, TensorFlow, PyTorch
# 2. Single file - easy to distribute
# 3. Preserves optimizer state - can resume training
# 4. Native format - best compatibility with Keras3

# Example: Save and resume training
save_model(model, "checkpoint.keras")

# Later: Resume training
model <- load_model("checkpoint.keras")
history <- model |> fit(
  x = x_train,
  y = y_train,
  epochs = 5,  # Additional epochs
  initial_epoch = 5  # Continue from epoch 5
)
```

### Custom Objects with .keras Format

```r
# Define custom layer
CustomLayer <- Layer(
  "CustomLayer",
  initialize = function(units, ...) {
    super$initialize(...)
    self$units <- units
  },
  build = function(input_shape) {
    self$kernel <- self$add_weight(
      name = "kernel",
      shape = list(input_shape[[2]], self$units),
      initializer = "glorot_uniform"
    )
  },
  call = function(inputs, ...) {
    keras3::k_dot(inputs, self$kernel)
  },
  get_config = function() {
    config <- super$get_config()
    config$units <- self$units
    return(config)
  }
)

# Build model with custom layer
model <- keras_model_sequential() |>
  layer_input(shape = 10) |>
  CustomLayer(units = 32) |>
  layer_dense(units = 1)

model |> compile(optimizer = "adam", loss = "mse")

# Save
save_model(model, "custom_model.keras")

# Load with custom objects
loaded_model <- load_model(
  "custom_model.keras",
  custom_objects = list(CustomLayer = CustomLayer)
)
```

## SavedModel Format (TensorFlow Ecosystem)

For TensorFlow Serving, TFLite, or TensorFlow.js deployment.

```r
library(keras3)

# Note: Requires TensorFlow backend
# Set backend before importing keras3:
# Sys.setenv(KERAS_BACKEND = "tensorflow")

# Build model
model <- keras_model_sequential() |>
  layer_dense(units = 64, activation = "relu", input_shape = 10) |>
  layer_dense(units = 1, activation = "sigmoid")

model |> compile(
  optimizer = "adam",
  loss = "binary_crossentropy"
)

# Export as SavedModel
export_savedmodel(model, "saved_model_dir/")

# Directory structure:
# saved_model_dir/
#   ├── saved_model.pb
#   ├── variables/
#   │   ├── variables.data-00000-of-00001
#   │   └── variables.index
#   └── assets/

# Load SavedModel
loaded_model <- load_savedmodel("saved_model_dir/")

# Use for predictions
predictions <- loaded_model |> predict(x_test)
```

### SavedModel for TensorFlow Serving

```r
# Export with serving signature
model <- keras_model_sequential() |>
  layer_input(shape = 10, name = "input_features") |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dense(units = 1, activation = "sigmoid", name = "output")

model |> compile(optimizer = "adam", loss = "binary_crossentropy")

# Export for serving
export_savedmodel(model, "serving_model/1/")  # Version 1

# Deploy with TensorFlow Serving:
# docker run -p 8501:8501 \
#   --mount type=bind,source=/path/to/serving_model,target=/models/my_model \
#   -e MODEL_NAME=my_model -t tensorflow/serving

# Query via REST API:
# curl -X POST http://localhost:8501/v1/models/my_model:predict \
#   -d '{"instances": [[0.1, 0.2, ...]]}'
```

### TFLite Conversion (Mobile/Edge)

```r
# Convert SavedModel to TFLite for mobile deployment
# (Requires TensorFlow Python for conversion)

# 1. Export as SavedModel
export_savedmodel(model, "model_for_tflite/")

# 2. Convert using Python TensorFlow (via reticulate)
library(reticulate)

tf <- import("tensorflow")

converter <- tf$lite$TFLiteConverter$from_saved_model("model_for_tflite/")
tflite_model <- converter$convert()

# Save .tflite file
writeBin(tflite_model, "model.tflite")

# Deploy to Android/iOS/Edge devices
```

## Weights Only Format

Save and load weights without architecture or optimizer state.

```r
# Save weights only
model |> save_model_weights("model_weights.weights.h5")

# Or use HDF5 format
model |> save_model_weights("model_weights.h5")

# Load weights into existing model
new_model <- keras_model_sequential() |>
  layer_dense(units = 64, activation = "relu", input_shape = 10) |>
  layer_dropout(rate = 0.5) |>
  layer_dense(units = 32, activation = "relu") |>
  layer_dense(units = 1, activation = "sigmoid")

# Must compile before loading weights (if you plan to train)
new_model |> compile(optimizer = "adam", loss = "binary_crossentropy")

# Load weights
new_model |> load_model_weights("model_weights.weights.h5")

# Now ready for prediction or continued training
```

### Use Cases for Weights Only

```r
# 1. Transfer Learning: Load pre-trained weights
base_model <- application_resnet50(
  weights = NULL,  # Don't load ImageNet weights
  include_top = FALSE,
  input_shape = c(224, 224, 3)
)

# Load custom pre-trained weights
base_model |> load_model_weights("pretrained_resnet_weights.h5")

# 2. Checkpointing During Training
model <- build_my_model()
model |> compile(optimizer = "adam", loss = "mse")

checkpoint_callback <- callback_model_checkpoint(
  filepath = "checkpoints/weights_epoch_{epoch:02d}_loss_{loss:.4f}.weights.h5",
  save_weights_only = TRUE,
  save_best_only = TRUE,
  monitor = "val_loss"
)

history <- model |> fit(
  x = x_train,
  y = y_train,
  validation_split = 0.2,
  epochs = 50,
  callbacks = list(checkpoint_callback)
)

# 3. Model Ensembling: Share architecture, different weights
architecture <- function() {
  keras_model_sequential() |>
    layer_dense(units = 64, activation = "relu", input_shape = 10) |>
    layer_dense(units = 1)
}

# Train multiple models with different seeds
models <- list()
for (i in 1:5) {
  set.seed(i)
  model <- architecture()
  model |> compile(optimizer = "adam", loss = "mse")
  model |> fit(x_train, y_train, epochs = 10, verbose = 0)
  model |> save_model_weights(sprintf("ensemble_model_%d.weights.h5", i))
  models[[i]] <- model
}

# Ensemble predictions
ensemble_predict <- function(models, x) {
  predictions <- lapply(models, function(m) m |> predict(x, verbose = 0))
  averaged <- Reduce("+", predictions) / length(predictions)
  return(averaged)
}
```

## Config Export (Architecture Only)

Save and load model architecture without weights.

```r
# Get model configuration as list
config <- get_config(model)

# Convert to JSON string
json_config <- keras3::to_json(config)

# Save to file
writeLines(json_config, "model_architecture.json")

# Load architecture from JSON
json_config <- readLines("model_architecture.json")
config <- keras3::from_json(json_config)

# Reconstruct model (weights are randomly initialized)
new_model <- keras_model$from_config(config)

# Compile before use
new_model |> compile(optimizer = "adam", loss = "mse")

# Optionally load weights
new_model |> load_model_weights("trained_weights.weights.h5")
```

### Use Cases for Config Export

```r
# 1. Architecture Sharing: Share model design without trained weights
# 2. Model Documentation: Store architecture in version control
# 3. Hyperparameter Tuning: Save architecture templates

# Example: Save architecture template for hyperparameter search
base_architecture_config <- get_config(base_model)
saveRDS(base_architecture_config, "architecture_template.rds")

# Later: Load and modify
config <- readRDS("architecture_template.rds")
# Modify config (e.g., change layer sizes)
# Reconstruct and train with different hyperparameters
```

## JAX Backend Serialization

Keras3 with JAX backend has specific considerations.

```r
# Set JAX backend
# Sys.setenv(KERAS_BACKEND = "jax")

library(keras3)

# Build model
model <- keras_model_sequential() |>
  layer_dense(units = 64, activation = "relu", input_shape = 10) |>
  layer_dense(units = 1)

model |> compile(optimizer = "adam", loss = "mse")

# Train
history <- model |> fit(x_train, y_train, epochs = 5)

# Save as .keras (recommended)
save_model(model, "jax_model.keras")

# Load (automatically uses JAX backend)
loaded_model <- load_model("jax_model.keras")

# Note: SavedModel format not supported with JAX backend
# Use .keras format for JAX models
```

## Decision Tree: Choosing Serialization Format

```r
# Decision helper function
choose_serialization_format <- function(
  deployment_target = c("python_keras", "tensorflow_serving", "mobile", "edge",
                        "r_production", "sharing_architecture", "checkpointing"),
  need_optimizer_state = FALSE,
  need_weights = TRUE,
  backend = c("jax", "tensorflow", "pytorch")
) {

  deployment_target <- match.arg(deployment_target)
  backend <- match.arg(backend)

  if (deployment_target == "python_keras" || deployment_target == "r_production") {
    if (need_optimizer_state && need_weights) {
      return(".keras format - Full model serialization")
    } else if (need_weights && !need_optimizer_state) {
      return(".weights.h5 format - Weights only")
    } else {
      return(".json format - Architecture only")
    }
  }

  if (deployment_target == "tensorflow_serving") {
    if (backend != "tensorflow") {
      return("ERROR: TensorFlow Serving requires TensorFlow backend")
    }
    return("SavedModel format - Use export_savedmodel()")
  }

  if (deployment_target == "mobile" || deployment_target == "edge") {
    if (backend != "tensorflow") {
      return("WARNING: TFLite conversion requires TensorFlow backend. Consider ONNX for other backends.")
    }
    return("SavedModel -> TFLite conversion")
  }

  if (deployment_target == "sharing_architecture") {
    return(".json format - Share architecture without weights")
  }

  if (deployment_target == "checkpointing") {
    return(".weights.h5 format - Efficient checkpointing during training")
  }

  return("Unknown use case - default to .keras format")
}

# Examples
choose_serialization_format(deployment_target = "r_production",
                            need_optimizer_state = TRUE,
                            backend = "jax")
# Output: ".keras format - Full model serialization"

choose_serialization_format(deployment_target = "tensorflow_serving",
                            backend = "tensorflow")
# Output: "SavedModel format - Use export_savedmodel()"

choose_serialization_format(deployment_target = "checkpointing",
                            backend = "pytorch")
# Output: ".weights.h5 format - Efficient checkpointing during training"
```

## Format Comparison Table

### Storage and Portability

| Format | File Size | Backend Portability | Python/R Interop | Single File |
|--------|-----------|---------------------|------------------|-------------|
| .keras | Medium | Excellent (all backends) | Excellent | Yes |
| SavedModel | Large | TensorFlow only | Good | No (directory) |
| .weights.h5 | Small | Excellent | Good (needs architecture) | Yes |
| .json | Tiny | Excellent | Excellent | Yes |

### Content Preservation

| Format | Architecture | Weights | Optimizer State | Custom Objects | Training Config |
|--------|-------------|---------|----------------|----------------|----------------|
| .keras | Yes | Yes | Yes | Yes (with custom_objects) | Yes |
| SavedModel | Yes | Yes | No | Yes | No |
| .weights.h5 | No | Yes | No | N/A | No |
| .json | Yes | No | No | Partial | Partial |

### Deployment Scenarios

| Scenario | Recommended Format | Notes |
|----------|-------------------|-------|
| R to R | .keras | Best compatibility |
| R to Python | .keras | Requires Keras3 in Python |
| TensorFlow Serving | SavedModel | TensorFlow backend only |
| Mobile (TFLite) | SavedModel → TFLite | Conversion required |
| Transfer Learning | .weights.h5 | Load weights into new architecture |
| Hyperparameter Tuning | .weights.h5 | Save best weights only |
| Model Versioning | .keras | Complete snapshot |
| Architecture Sharing | .json | Share design, not weights |

## Best Practices

### 1. Default to .keras Format

```r
# For most use cases, use .keras
save_model(model, "production_model.keras")
```

### 2. Checkpointing During Training

```r
# Save weights periodically, save final model as .keras
checkpoint_callback <- callback_model_checkpoint(
  filepath = "checkpoints/epoch_{epoch:02d}.weights.h5",
  save_weights_only = TRUE,
  save_freq = "epoch"
)

model_checkpoint_callback <- callback_model_checkpoint(
  filepath = "checkpoints/best_model.keras",
  save_best_only = TRUE,
  monitor = "val_loss"
)

history <- model |> fit(
  x_train, y_train,
  validation_split = 0.2,
  epochs = 50,
  callbacks = list(checkpoint_callback, model_checkpoint_callback)
)
```

### 3. Version Control

```r
# Include architecture in version control, not weights
config <- get_config(model)
saveRDS(config, "model_architecture_v1.rds")

# Weights stored separately (e.g., model registry, cloud storage)
model |> save_model_weights("weights/model_v1_trained.weights.h5")
```

### 4. Production Deployment

```r
# Save with version and metadata
model_version <- "1.0.0"
save_model(model, sprintf("models/production_model_v%s.keras", model_version))

# Document model metadata
metadata <- list(
  version = model_version,
  training_date = Sys.Date(),
  accuracy = results["accuracy"],
  backend = keras3::backend(),
  input_shape = model$input_shape,
  output_shape = model$output_shape
)
saveRDS(metadata, sprintf("models/metadata_v%s.rds", model_version))
```

## Related Resources

- See main SKILL.md for model building basics
- Reference functional-api-advanced.md for complex architectures
- Check custom-layers-models.md for serializing custom components
- See r-tensorflow skill for TensorFlow-specific deployment
