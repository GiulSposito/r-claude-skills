# Keras 3 Advanced Patterns

Advanced training techniques, custom components, and optimization patterns.

## Custom Training Loops

### Basic Custom Training Loop

Complete control over training process.

```r
library(keras3)
library(tensorflow)

# Prepare data
x_train <- array(rnorm(1000 * 784), dim = c(1000, 784))
y_train <- array(sample(0:9, 1000, replace = TRUE), dim = c(1000))

# Build model
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dense(64, activation = "relu") |>
  layer_dense(10, activation = "softmax")

# Define optimizer and loss
optimizer <- optimizer_adam(learning_rate = 0.001)
loss_fn <- loss_sparse_categorical_crossentropy()

# Training step
train_step <- function(x_batch, y_batch) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x_batch, training = TRUE)
    loss <- loss_fn(y_batch, predictions)
  })

  gradients <- tape$gradient(loss, model$trainable_variables)
  optimizer$apply_gradients(
    purrr::transpose(list(gradients, model$trainable_variables))
  )

  return(loss)
}

# Training loop
batch_size <- 32
epochs <- 10

for (epoch in seq_len(epochs)) {
  cat(sprintf("Epoch %d/%d\n", epoch, epochs))

  # Shuffle data
  indices <- sample(nrow(x_train))
  x_train <- x_train[indices, ]
  y_train <- y_train[indices]

  epoch_loss <- 0
  num_batches <- ceiling(nrow(x_train) / batch_size)

  for (i in seq_len(num_batches)) {
    start_idx <- (i - 1) * batch_size + 1
    end_idx <- min(i * batch_size, nrow(x_train))

    x_batch <- x_train[start_idx:end_idx, , drop = FALSE]
    y_batch <- y_train[start_idx:end_idx]

    batch_loss <- train_step(x_batch, y_batch)
    epoch_loss <- epoch_loss + as.numeric(batch_loss)
  }

  cat(sprintf("  Loss: %.4f\n", epoch_loss / num_batches))
}
```

### Custom Training Loop with Metrics

Track custom metrics during training.

```r
library(keras3)
library(tensorflow)

# Build model and optimizer
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")

optimizer <- optimizer_adam()
loss_fn <- loss_sparse_categorical_crossentropy()

# Create metrics
train_loss_metric <- metric_mean(name = "train_loss")
train_acc_metric <- metric_sparse_categorical_accuracy(name = "train_accuracy")
val_loss_metric <- metric_mean(name = "val_loss")
val_acc_metric <- metric_sparse_categorical_accuracy(name = "val_accuracy")

# Training step
train_step <- function(x_batch, y_batch) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x_batch, training = TRUE)
    loss <- loss_fn(y_batch, predictions)
  })

  gradients <- tape$gradient(loss, model$trainable_variables)
  optimizer$apply_gradients(
    purrr::transpose(list(gradients, model$trainable_variables))
  )

  # Update metrics
  train_loss_metric$update_state(loss)
  train_acc_metric$update_state(y_batch, predictions)
}

# Validation step
val_step <- function(x_batch, y_batch) {
  predictions <- model(x_batch, training = FALSE)
  loss <- loss_fn(y_batch, predictions)

  val_loss_metric$update_state(loss)
  val_acc_metric$update_state(y_batch, predictions)
}

# Training loop
epochs <- 10
batch_size <- 32

for (epoch in seq_len(epochs)) {
  cat(sprintf("Epoch %d/%d\n", epoch, epochs))

  # Reset metrics
  train_loss_metric$reset_states()
  train_acc_metric$reset_states()
  val_loss_metric$reset_states()
  val_acc_metric$reset_states()

  # Training phase
  for (batch in train_dataset) {
    train_step(batch[[1]], batch[[2]])
  }

  # Validation phase
  for (batch in val_dataset) {
    val_step(batch[[1]], batch[[2]])
  }

  # Print metrics
  cat(sprintf("  Train Loss: %.4f, Train Acc: %.4f\n",
              train_loss_metric$result(), train_acc_metric$result()))
  cat(sprintf("  Val Loss: %.4f, Val Acc: %.4f\n",
              val_loss_metric$result(), val_acc_metric$result()))
}
```

### Custom Training Loop with tf_function

Compile training step for performance.

```r
library(keras3)
library(tensorflow)

# Build model
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")

optimizer <- optimizer_adam()
loss_fn <- loss_sparse_categorical_crossentropy()

# Compile training step with tf_function
train_step <- tf_function(function(x_batch, y_batch) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x_batch, training = TRUE)
    loss <- loss_fn(y_batch, predictions)
  })

  gradients <- tape$gradient(loss, model$trainable_variables)
  optimizer$apply_gradients(
    purrr::transpose(list(gradients, model$trainable_variables))
  )

  return(loss)
})

# Training loop (significantly faster)
for (epoch in seq_len(epochs)) {
  for (batch in train_dataset) {
    loss <- train_step(batch[[1]], batch[[2]])
  }
}
```

## Gradient Accumulation

Simulate larger batch sizes by accumulating gradients.

### Basic Gradient Accumulation

```r
library(keras3)
library(tensorflow)

model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")

optimizer <- optimizer_adam()
loss_fn <- loss_sparse_categorical_crossentropy()

# Accumulation parameters
accumulation_steps <- 4
effective_batch_size <- 32 * accumulation_steps  # 128

# Training with gradient accumulation
train_step_with_accumulation <- function(x_batch, y_batch, step) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x_batch, training = TRUE)
    loss <- loss_fn(y_batch, predictions) / accumulation_steps
  })

  gradients <- tape$gradient(loss, model$trainable_variables)

  # Accumulate gradients
  if (step == 1) {
    # Initialize accumulated gradients
    accumulated_gradients <<- gradients
  } else {
    # Add to accumulated gradients
    accumulated_gradients <<- Map(function(acc, grad) {
      acc + grad
    }, accumulated_gradients, gradients)
  }

  # Apply accumulated gradients
  if (step == accumulation_steps) {
    optimizer$apply_gradients(
      purrr::transpose(list(accumulated_gradients, model$trainable_variables))
    )
    accumulated_gradients <<- NULL
  }

  return(loss)
}

# Training loop
step <- 0
for (batch in train_dataset) {
  step <- (step %% accumulation_steps) + 1
  loss <- train_step_with_accumulation(batch[[1]], batch[[2]], step)
}
```

## Mixed Precision Training

Use 16-bit floats for faster training and reduced memory.

### TensorFlow Backend

```r
library(keras3)
library(tensorflow)

# Enable mixed precision
policy <- tf$keras$mixed_precision$Policy("mixed_float16")
tf$keras$mixed_precision$set_global_policy(policy)

# Build model (automatically uses mixed precision)
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax", dtype = "float32")  # Keep output in float32

# Use loss scaling optimizer
optimizer <- optimizer_adam()
optimizer <- tf$keras$mixed_precision$LossScaleOptimizer(optimizer)

# Custom training step with loss scaling
train_step <- function(x_batch, y_batch) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x_batch, training = TRUE)
    loss <- loss_fn(y_batch, predictions)
    scaled_loss <- optimizer$get_scaled_loss(loss)
  })

  scaled_gradients <- tape$gradient(scaled_loss, model$trainable_variables)
  gradients <- optimizer$get_unscaled_gradients(scaled_gradients)
  optimizer$apply_gradients(
    purrr::transpose(list(gradients, model$trainable_variables))
  )

  return(loss)
}
```

### Global Mixed Precision Setting

```r
# Set global dtype policy
config_set_dtype_policy("mixed_float16")

# All layers automatically use mixed precision
model <- keras_model_sequential(input_shape = c(224, 224, 3)) |>
  layer_conv_2d(32, c(3, 3), activation = "relu") |>
  layer_max_pooling_2d(c(2, 2)) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax", dtype = "float32")

# Regular training (Keras handles loss scaling internally)
model |> compile(
  optimizer = optimizer_adam(),
  loss = "sparse_categorical_crossentropy",
  metrics = "accuracy"
)

model |> fit(x_train, y_train, epochs = 10)
```

## Distributed Training

### TensorFlow MirroredStrategy (Multi-GPU)

```r
library(keras3)
library(tensorflow)

# Create distribution strategy
strategy <- tf$distribute$MirroredStrategy()

cat(sprintf("Number of devices: %d\n", strategy$num_replicas_in_sync))

# Build and compile model within strategy scope
with(strategy$scope(), {
  model <- keras_model_sequential(input_shape = c(784)) |>
    layer_dense(128, activation = "relu") |>
    layer_dense(64, activation = "relu") |>
    layer_dense(10, activation = "softmax")

  model |> compile(
    optimizer = optimizer_adam(),
    loss = "sparse_categorical_crossentropy",
    metrics = "accuracy"
  )
})

# Prepare distributed dataset
train_dataset <- tf$data$Dataset$from_tensor_slices(
  tuple(x_train, y_train)
)$batch(64)

train_dist_dataset <- strategy$experimental_distribute_dataset(train_dataset)

# Train
model |> fit(
  train_dist_dataset,
  epochs = 10
)
```

### JAX Distributed Training

```r
library(keras3)

Sys.setenv(KERAS_BACKEND = "jax")
library(keras3)

jax <- reticulate::import("jax")
jnp <- reticulate::import("jax.numpy")

# Detect available devices
devices <- jax$devices()
cat(sprintf("Available devices: %d\n", length(devices)))

# Data parallelism with pmap
parallel_train_step <- jax$pmap(function(params, x, y) {
  # Training step executed on each device
  # ...
})

# Training loop with data parallelism
for (epoch in seq_len(epochs)) {
  for (batch in train_dataset) {
    # Split batch across devices
    x_parallel <- reshape_for_devices(batch[[1]], length(devices))
    y_parallel <- reshape_for_devices(batch[[2]], length(devices))

    # Execute on all devices in parallel
    losses <- parallel_train_step(params, x_parallel, y_parallel)
  }
}
```

### Learning Rate Scaling for Large Batches

```r
# Linear scaling rule: scale LR with batch size
base_lr <- 0.001
base_batch_size <- 32
actual_batch_size <- 256
num_gpus <- 4

scaled_lr <- base_lr * (actual_batch_size * num_gpus) / base_batch_size

model |> compile(
  optimizer = optimizer_adam(learning_rate = scaled_lr),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)
```

## Custom Losses and Metrics

### Custom Loss Function

```r
# Focal loss for imbalanced classification
focal_loss <- function(gamma = 2.0, alpha = 0.25) {
  function(y_true, y_pred) {
    ops <- keras3::keras$ops

    # Cross entropy
    ce <- ops$categorical_crossentropy(y_true, y_pred)

    # Focal loss weight
    p_t <- ops$sum(y_true * y_pred, axis = -1)
    focal_weight <- ops$power(1 - p_t, gamma)

    # Apply focal weight and alpha
    loss <- alpha * focal_weight * ce

    return(ops$mean(loss))
  }
}

# Use in model
model |> compile(
  optimizer = optimizer_adam(),
  loss = focal_loss(gamma = 2.0, alpha = 0.25),
  metrics = "accuracy"
)
```

### Custom Metric

```r
# F1 score metric
F1Score <- new_metric_class(
  "F1Score",

  initialize = function(name = "f1_score", ...) {
    super$initialize(name = name, ...)
    self$true_positives <- self$add_weight(
      name = "tp",
      initializer = "zeros"
    )
    self$false_positives <- self$add_weight(
      name = "fp",
      initializer = "zeros"
    )
    self$false_negatives <- self$add_weight(
      name = "fn",
      initializer = "zeros"
    )
  },

  update_state = function(y_true, y_pred, sample_weight = NULL) {
    ops <- keras3::keras$ops

    y_pred <- ops$round(y_pred)

    tp <- ops$sum(ops$cast(y_true * y_pred, "float32"))
    fp <- ops$sum(ops$cast((1 - y_true) * y_pred, "float32"))
    fn <- ops$sum(ops$cast(y_true * (1 - y_pred), "float32"))

    self$true_positives$assign_add(tp)
    self$false_positives$assign_add(fp)
    self$false_negatives$assign_add(fn)
  },

  result = function() {
    ops <- keras3::keras$ops

    precision <- self$true_positives /
      (self$true_positives + self$false_positives + ops$epsilon())
    recall <- self$true_positives /
      (self$true_positives + self$false_negatives + ops$epsilon())

    f1 <- 2 * (precision * recall) / (precision + recall + ops$epsilon())
    return(f1)
  },

  reset_states = function() {
    self$true_positives$assign(0)
    self$false_positives$assign(0)
    self$false_negatives$assign(0)
  }
)

# Use in model
model |> compile(
  optimizer = optimizer_adam(),
  loss = "binary_crossentropy",
  metrics = list(metric_accuracy(), F1Score())
)
```

## Adversarial Training

### Fast Gradient Sign Method (FGSM)

```r
library(keras3)
library(tensorflow)

# Generate adversarial examples
generate_adversarial_examples <- function(model, x, y, epsilon = 0.1) {
  loss_fn <- loss_sparse_categorical_crossentropy()

  with(tf$GradientTape() %as% tape, {
    tape$watch(x)
    predictions <- model(x, training = FALSE)
    loss <- loss_fn(y, predictions)
  })

  # Get gradient of loss w.r.t. input
  gradient <- tape$gradient(loss, x)

  # Create adversarial example
  signed_grad <- tf$sign(gradient)
  adversarial_x <- x + epsilon * signed_grad
  adversarial_x <- tf$clip_by_value(adversarial_x, 0, 1)

  return(adversarial_x)
}

# Adversarial training loop
train_adversarial_step <- function(x_batch, y_batch) {
  # Train on clean examples
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x_batch, training = TRUE)
    loss_clean <- loss_fn(y_batch, predictions)
  })

  gradients <- tape$gradient(loss_clean, model$trainable_variables)
  optimizer$apply_gradients(
    purrr::transpose(list(gradients, model$trainable_variables))
  )

  # Generate and train on adversarial examples
  x_adv <- generate_adversarial_examples(model, x_batch, y_batch)

  with(tf$GradientTape() %as% tape, {
    predictions_adv <- model(x_adv, training = TRUE)
    loss_adv <- loss_fn(y_batch, predictions_adv)
  })

  gradients_adv <- tape$gradient(loss_adv, model$trainable_variables)
  optimizer$apply_gradients(
    purrr::transpose(list(gradients_adv, model$trainable_variables))
  )

  return(list(clean = loss_clean, adversarial = loss_adv))
}
```

## Curriculum Learning

Gradually increase training difficulty.

```r
library(keras3)

# Define curriculum schedule
curriculum_schedule <- function(epoch, num_epochs) {
  # Start with easy examples, gradually include harder ones
  difficulty_threshold <- epoch / num_epochs
  return(difficulty_threshold)
}

# Filter dataset by difficulty
filter_by_difficulty <- function(dataset, difficulty_scores, threshold) {
  indices <- which(difficulty_scores <= threshold)
  return(dataset[indices, , drop = FALSE])
}

# Curriculum training loop
train_with_curriculum <- function(model, x_full, y_full, difficulty_scores, epochs) {
  for (epoch in seq_len(epochs)) {
    threshold <- curriculum_schedule(epoch, epochs)

    # Get current curriculum subset
    x_curr <- filter_by_difficulty(x_full, difficulty_scores, threshold)
    y_curr <- y_full[which(difficulty_scores <= threshold)]

    cat(sprintf("Epoch %d: Training on %d/%d examples (difficulty <= %.2f)\n",
                epoch, nrow(x_curr), nrow(x_full), threshold))

    # Train on current curriculum
    model |> fit(
      x_curr, y_curr,
      epochs = 1,
      verbose = 0
    )
  }
}

# Example: Define difficulty based on model confidence
difficulty_scores <- 1 - predict(pretrained_model, x_full) |>
  apply(1, max)  # Lower confidence = harder

train_with_curriculum(model, x_train, y_train, difficulty_scores, epochs = 50)
```

## Debugging and Profiling

### Enable Eager Execution (TensorFlow)

```r
library(tensorflow)

# Disable tf_function for debugging
tf$config$run_functions_eagerly(TRUE)

# Now you can use browser(), print statements, etc.
train_step_debug <- function(x_batch, y_batch) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x_batch, training = TRUE)
    loss <- loss_fn(y_batch, predictions)

    # Debug statements work in eager mode
    cat(sprintf("Batch loss: %.4f\n", as.numeric(loss)))
    browser()  # Interactive debugging
  })

  gradients <- tape$gradient(loss, model$trainable_variables)
  optimizer$apply_gradients(
    purrr::transpose(list(gradients, model$trainable_variables))
  )
}
```

### TensorBoard Profiling

```r
library(keras3)
library(tensorflow)

# Create profiler callback
profiler_callback <- tf$keras$callbacks$TensorBoard(
  log_dir = "logs/profiler",
  profile_batch = "10,20"  # Profile batches 10-20
)

model |> fit(
  x_train, y_train,
  epochs = 5,
  callbacks = list(profiler_callback)
)

# View profile in TensorBoard
tensorboard::tensorboard(log_dir = "logs/profiler")
```

### Memory Optimization

```r
library(tensorflow)

# Enable memory growth for GPU
gpus <- tf$config$list_physical_devices("GPU")
if (length(gpus) > 0) {
  tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)
}

# Set memory limit
tf$config$set_logical_device_configuration(
  gpus[[1]],
  list(tf$config$LogicalDeviceConfiguration(memory_limit = 4096))  # 4GB
)

# Clear session between runs
keras3::keras$backend$clear_session()

# Use gradient checkpointing for large models
# (recompute activations during backward pass)
model <- keras_model_sequential() |>
  layer_dense(1024, activation = "relu") |>
  # Large layers here
  layer_dense(1024, activation = "relu")

# Reduce batch size if OOM
batch_size <- 16  # Instead of 32 or 64
```

## See Also

- [backend-guide.md](backend-guide.md) - Backend-specific optimizations
- [callbacks-reference.md](callbacks-reference.md) - Training callbacks
- [keras-applications.md](keras-applications.md) - Transfer learning patterns
- [preprocessing-layers.md](preprocessing-layers.md) - Data preprocessing
