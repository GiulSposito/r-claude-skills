# Keras 3 Backend Guide

Comprehensive guide to Keras 3's multi-backend support: TensorFlow, JAX, and PyTorch.

## Backend Overview

Keras 3 supports three computational backends, allowing you to write code once and run it on any backend:

- **TensorFlow**: Production-ready, mature ecosystem, excellent GPU support
- **JAX**: Research-focused, functional programming, advanced autodiff, XLA compilation
- **PyTorch**: Popular in research, extensive ecosystem, dynamic graphs

### Key Characteristics

| Feature | TensorFlow | JAX | PyTorch |
|---------|------------|-----|---------|
| **Maturity** | Mature, stable | Growing | Mature |
| **Use Case** | Production | Research | Research/Production |
| **Compilation** | XLA optional | XLA default | TorchScript |
| **Autodiff** | Good | Excellent | Good |
| **Ecosystem** | TF ecosystem | NumPy-like | PyTorch ecosystem |
| **GPU Support** | Excellent | Excellent | Excellent |
| **TPU Support** | Excellent | Excellent | Limited |
| **Dynamic Graphs** | Via eager | Functional | Native |
| **Debugging** | Good | Challenging | Excellent |

## Switching Backends

### Method 1: Environment Variable (Before Import)

```r
# Set before loading keras3
Sys.setenv(KERAS_BACKEND = "jax")
library(keras3)
```

### Method 2: Configuration Function

```r
library(keras3)

# Check current backend
config_backend()  # Returns "tensorflow", "jax", or "torch"

# Switch backend (must be done before creating models)
config_set_backend("jax")

# Verify
config_backend()
```

### Method 3: Configuration File

Create `~/.keras/keras.json`:

```json
{
  "backend": "jax",
  "image_data_format": "channels_last",
  "floatx": "float32"
}
```

### Backend Selection Guidelines

**Use TensorFlow when:**
- Deploying to production
- Using TensorFlow Serving, TFLite
- Need mature ecosystem and tools
- Working with TensorFlow datasets
- Need TensorBoard integration
- Using Google Cloud AI Platform

**Use JAX when:**
- Research requiring advanced autodiff
- Functional programming preferred
- Need custom gradient transformations
- Experimenting with new architectures
- Performance-critical applications
- Working with TPUs on Google Cloud

**Use PyTorch when:**
- Integrating with PyTorch ecosystem
- Need dynamic computation graphs
- Using PyTorch-specific libraries
- Debugging complex models
- Working with PyTorch datasets
- Research in PyTorch community

## Backend-Specific Code

### Accessing Backend Tensors

```r
library(keras3)

# Get backend namespace
backend <- keras3::keras$ops

# Create tensor (backend-agnostic)
x <- backend$ones(shape = c(3, 3))

# Access native backend
if (config_backend() == "tensorflow") {
  # Direct TensorFlow access
  tf <- tensorflow::tf
  tf_tensor <- tf$constant(c(1, 2, 3))
}

if (config_backend() == "jax") {
  # Direct JAX access
  jax <- reticulate::import("jax")
  jnp <- reticulate::import("jax.numpy")
  jax_array <- jnp$array(c(1, 2, 3))
}

if (config_backend() == "torch") {
  # Direct PyTorch access
  torch <- reticulate::import("torch")
  torch_tensor <- torch$tensor(c(1, 2, 3))
}
```

### Backend-Agnostic Operations

Use `keras$ops` for portable code:

```r
ops <- keras3::keras$ops

# Array operations
x <- ops$ones(c(10, 10))
y <- ops$zeros(c(10, 10))
z <- ops$add(x, y)

# Mathematical operations
result <- ops$matmul(x, y)
norm <- ops$norm(x)
mean_val <- ops$mean(x)

# Activation functions
relu_out <- ops$relu(x)
softmax_out <- ops$softmax(x)

# Shape manipulation
reshaped <- ops$reshape(x, c(5, 20))
transposed <- ops$transpose(x)
```

## TensorFlow Backend

### TensorFlow-Specific Features

#### tf.function Compilation

```r
library(keras3)
library(tensorflow)

Sys.setenv(KERAS_BACKEND = "tensorflow")
library(keras3)

# Define TensorFlow function
train_step <- tf_function(function(x, y) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x, training = TRUE)
    loss <- loss_fn(y, predictions)
  })

  gradients <- tape$gradient(loss, model$trainable_variables)
  optimizer$apply_gradients(
    zip_lists(gradients, model$trainable_variables)
  )

  return(loss)
})

# Use in training loop
for (batch in train_dataset) {
  loss <- train_step(batch[[1]], batch[[2]])
}
```

#### Mixed Precision Training

```r
# Enable mixed precision
policy <- tensorflow::tf$keras$mixed_precision$Policy("mixed_float16")
tensorflow::tf$keras$mixed_precision$set_global_policy(policy)

# Build model (automatically uses mixed precision)
model <- keras_model_sequential() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax", dtype = "float32")  # Output in float32

# Use loss scaling
optimizer <- optimizer_adam()
optimizer <- tensorflow::tf$keras$mixed_precision$LossScaleOptimizer(optimizer)
```

#### TensorBoard Integration

```r
# TensorBoard callback
tensorboard_callback <- callback_tensorboard(
  log_dir = "logs",
  histogram_freq = 1,
  write_graph = TRUE,
  write_images = TRUE,
  update_freq = "epoch",
  profile_batch = c(10, 20)
)

model |> fit(
  train_data,
  epochs = 50,
  callbacks = list(tensorboard_callback)
)

# View in browser
tensorboard::tensorboard(log_dir = "logs")
```

### TensorFlow Optimizations

```r
# Enable XLA compilation
tensorflow::tf$config$optimizer$set_jit(TRUE)

# Configure GPU memory growth
gpus <- tensorflow::tf$config$list_physical_devices("GPU")
if (length(gpus) > 0) {
  tensorflow::tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)
}

# Mixed precision
tensorflow::tf$keras$mixed_precision$set_global_policy("mixed_float16")
```

## JAX Backend

### JAX-Specific Features

#### JIT Compilation

```r
Sys.setenv(KERAS_BACKEND = "jax")
library(keras3)

jax <- reticulate::import("jax")
jnp <- reticulate::import("jax.numpy")

# JIT compile function
jit_fn <- jax$jit(function(x, y) {
  jnp$dot(x, y)
})

# Use compiled function
x <- jnp$ones(c(1000L, 1000L))
y <- jnp$ones(c(1000L, 1000L))
result <- jit_fn(x, y)  # Fast!
```

#### Functional Transformations

```r
# Vectorization with vmap
def <- function(x) {
  jnp$sum(x^2)
}

# Apply to batch
batch_fn <- jax$vmap(def)
x_batch <- jnp$ones(c(32L, 100L))
results <- batch_fn(x_batch)

# Gradient computation
grad_fn <- jax$grad(def)
x <- jnp$array(c(1.0, 2.0, 3.0))
gradient <- grad_fn(x)

# Value and gradient together
value_and_grad_fn <- jax$value_and_grad(def)
list(value, grad) %<-% value_and_grad_fn(x)
```

#### Custom Training Loop with JAX

```r
library(keras3)
Sys.setenv(KERAS_BACKEND = "jax")
library(keras3)

jax <- reticulate::import("jax")
jnp <- reticulate::import("jax.numpy")

# Define loss and gradient function
loss_and_grad_fn <- jax$value_and_grad(function(params, x, y) {
  predictions <- model(x, training = TRUE)
  loss_fn(y, predictions)
})

# Training step
train_step <- jax$jit(function(state, x, y) {
  list(loss, grads) %<-% loss_and_grad_fn(model$trainable_variables, x, y)

  # Apply gradients
  optimizer$apply_gradients(grads, model$trainable_variables)

  return(loss)
})

# Training loop
for (batch in train_data) {
  loss <- train_step(NULL, batch[[1]], batch[[2]])
}
```

#### JAX Performance Tips

```r
# Disable JIT for debugging
jax$config$update("jax_disable_jit", TRUE)

# Enable 64-bit precision
jax$config$update("jax_enable_x64", TRUE)

# Pre-allocate GPU memory (75%)
Sys.setenv(XLA_PYTHON_CLIENT_PREALLOCATE = "true")
Sys.setenv(XLA_PYTHON_CLIENT_MEM_FRACTION = "0.75")
```

## PyTorch Backend

### PyTorch-Specific Features

#### DataLoader Integration

```r
Sys.setenv(KERAS_BACKEND = "torch")
library(keras3)

torch <- reticulate::import("torch")
torch_data <- reticulate::import("torch.utils.data")

# Create PyTorch DataLoader
dataset <- torch_data$TensorDataset(
  torch$randn(1000L, 28L, 28L),
  torch$randint(0L, 10L, c(1000L,))
)

dataloader <- torch_data$DataLoader(
  dataset,
  batch_size = 32L,
  shuffle = TRUE,
  num_workers = 4L
)

# Train with DataLoader
for (batch in reticulate::iterate(dataloader)) {
  x <- batch[[1]]
  y <- batch[[2]]
  # Training step
}
```

#### Dynamic Computation Graphs

```r
# Build model with conditional logic
custom_model <- new_model_class(
  "CustomModel",
  initialize = function() {
    self$dense1 <- layer_dense(units = 128)
    self$dense2 <- layer_dense(units = 64)
    self$dense3 <- layer_dense(units = 10)
  },

  call = function(inputs, training = FALSE) {
    x <- self$dense1(inputs)

    # Dynamic branching
    if (training) {
      x <- layer_dropout(rate = 0.5)(x)
    }

    x <- self$dense2(x)

    # Conditional computation
    if (keras3::keras$ops$mean(x) > 0) {
      x <- keras3::keras$ops$relu(x)
    } else {
      x <- keras3::keras$ops$tanh(x)
    }

    self$dense3(x)
  }
)
```

#### TorchScript Export

```r
# Create and train model
model <- keras_model_sequential() |>
  layer_dense(128, activation = "relu", input_shape = c(784)) |>
  layer_dense(10, activation = "softmax")

# Train model
# ...

# Export to TorchScript (via PyTorch)
torch <- reticulate::import("torch")

# Trace model
example_input <- torch$randn(1L, 784L)
traced_model <- torch$jit$trace(model, example_input)

# Save
torch$jit$save(traced_model, "model.pt")

# Load
loaded_model <- torch$jit$load("model.pt")
```

## Multi-Backend Development

### Writing Portable Code

```r
# Use keras$ops for backend-agnostic operations
ops <- keras3::keras$ops

# Avoid backend-specific code
portable_function <- function(x) {
  # Good: backend-agnostic
  result <- ops$matmul(x, ops$transpose(x))
  result <- ops$relu(result)
  return(ops$mean(result))
}

# Check backend at runtime if needed
if (config_backend() == "tensorflow") {
  # TensorFlow-specific optimization
} else if (config_backend() == "jax") {
  # JAX-specific optimization
}
```

### Testing Across Backends

```r
# Test function on all backends
test_all_backends <- function(model_fn, data) {
  backends <- c("tensorflow", "jax", "torch")

  results <- list()
  for (backend in backends) {
    message(sprintf("Testing on %s", backend))
    config_set_backend(backend)

    model <- model_fn()
    result <- model(data)
    results[[backend]] <- result
  }

  return(results)
}

# Usage
model_fn <- function() {
  keras_model_sequential() |>
    layer_dense(128, activation = "relu", input_shape = c(784)) |>
    layer_dense(10, activation = "softmax")
}

test_data <- ops$random$normal(c(32, 784))
all_results <- test_all_backends(model_fn, test_data)
```

## Backend Performance Comparison

### Benchmarking Template

```r
library(keras3)
library(tictoc)

benchmark_backend <- function(backend_name) {
  config_set_backend(backend_name)

  # Build model
  model <- keras_model_sequential(input_shape = c(784)) |>
    layer_dense(512, activation = "relu") |>
    layer_dense(256, activation = "relu") |>
    layer_dense(10, activation = "softmax")

  model |> compile(
    optimizer = optimizer_adam(),
    loss = "sparse_categorical_crossentropy",
    metrics = "accuracy"
  )

  # Generate synthetic data
  x_train <- array(rnorm(60000 * 784), c(60000, 784))
  y_train <- array(sample(0:9, 60000, replace = TRUE), c(60000))

  # Benchmark training
  tic(sprintf("%s training", backend_name))
  history <- model |> fit(
    x_train, y_train,
    epochs = 5,
    batch_size = 256,
    verbose = 0
  )
  timing <- toc()

  return(list(
    backend = backend_name,
    time = timing$toc - timing$tic,
    final_acc = tail(history$metrics$accuracy, 1)
  ))
}

# Run benchmarks
results <- lapply(c("tensorflow", "jax", "torch"), benchmark_backend)
print(do.call(rbind, lapply(results, as.data.frame)))
```

## Backend Migration Guide

### TensorFlow to JAX

```r
# TensorFlow code
# Sys.setenv(KERAS_BACKEND = "tensorflow")
# tf_function for compilation

# JAX equivalent
# Sys.setenv(KERAS_BACKEND = "jax")
# jax.jit for compilation

# Model code remains the same!
model <- keras_model_sequential() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")
```

### TensorFlow to PyTorch

```r
# TensorFlow code with tf.data
# train_ds <- tensorflow::tf$data$Dataset$from_tensor_slices(...)

# PyTorch equivalent with DataLoader
# dataloader <- torch$utils$data$DataLoader(...)

# Model code remains the same!
model <- keras_model_sequential() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")
```

## Best Practices

### Development Workflow

1. **Prototype with PyTorch**: Fast iteration, easy debugging
2. **Validate with TensorFlow**: Production readiness
3. **Optimize with JAX**: Performance tuning

### Code Organization

```r
# config.R - Backend configuration
setup_backend <- function(backend = "tensorflow") {
  config_set_backend(backend)

  if (backend == "tensorflow") {
    tensorflow::tf$config$optimizer$set_jit(TRUE)
  } else if (backend == "jax") {
    jax <- reticulate::import("jax")
    jax$config$update("jax_enable_x64", TRUE)
  }
}

# model.R - Backend-agnostic model
build_model <- function() {
  keras_model_sequential() |>
    layer_dense(128, activation = "relu") |>
    layer_dense(10, activation = "softmax")
}

# train.R - Training script
train_model <- function(backend = "tensorflow") {
  setup_backend(backend)
  model <- build_model()
  # ... training code ...
}
```

## Troubleshooting

### Backend Not Available

```r
# Check available backends
tryCatch({
  config_set_backend("jax")
  message("JAX available")
}, error = function(e) {
  message("JAX not available, install with: pip install jax jaxlib")
})
```

### Memory Issues

```r
# TensorFlow: Enable memory growth
gpus <- tensorflow::tf$config$list_physical_devices("GPU")
if (length(gpus) > 0) {
  tensorflow::tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)
}

# JAX: Preallocate fraction
Sys.setenv(XLA_PYTHON_CLIENT_MEM_FRACTION = "0.5")

# PyTorch: Clear cache
torch <- reticulate::import("torch")
torch$cuda$empty_cache()
```

## See Also

- [advanced-patterns.md](advanced-patterns.md) - Custom training loops per backend
- [keras-applications.md](keras-applications.md) - Pretrained models work on all backends
- [preprocessing-layers.md](preprocessing-layers.md) - Preprocessing layers are backend-agnostic
