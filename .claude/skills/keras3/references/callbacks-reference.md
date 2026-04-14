# Keras 3 Callbacks Reference

Complete reference for built-in callbacks and custom callback creation.

## Overview

Callbacks are objects that perform actions at various stages of training. They enable:
- Monitoring training metrics
- Saving model checkpoints
- Adjusting learning rates
- Early stopping
- Custom logging and visualization
- Fault tolerance

Callbacks are passed to `fit()`:

```r
model |> fit(
  x_train, y_train,
  epochs = 100,
  callbacks = list(
    callback_early_stopping(...),
    callback_model_checkpoint(...)
  )
)
```

## Built-in Callbacks

### callback_early_stopping()

Stops training when monitored metric stops improving.

**Parameters:**
- `monitor` - Metric to monitor (e.g., "val_loss", "val_accuracy")
- `min_delta` - Minimum change to qualify as improvement
- `patience` - Number of epochs with no improvement to wait
- `verbose` - Verbosity mode (0 or 1)
- `mode` - "auto", "min", or "max"
- `baseline` - Baseline value for monitored metric
- `restore_best_weights` - Restore weights from best epoch

**Use Cases:**
- Prevent overfitting
- Save training time
- Automatically find optimal epochs

**Example - Basic Usage:**
```r
early_stop <- callback_early_stopping(
  monitor = "val_loss",
  patience = 10,
  restore_best_weights = TRUE
)

model |> fit(
  x_train, y_train,
  validation_split = 0.2,
  epochs = 100,
  callbacks = list(early_stop)
)
```

**Example - With Baseline:**
```r
# Stop if validation accuracy doesn't reach 0.9
early_stop_baseline <- callback_early_stopping(
  monitor = "val_accuracy",
  baseline = 0.9,
  patience = 20,
  mode = "max",
  restore_best_weights = TRUE
)
```

**Example - Multiple Metrics:**
```r
# Stop on loss or accuracy
callbacks_list <- list(
  callback_early_stopping(
    monitor = "val_loss",
    patience = 10,
    restore_best_weights = TRUE
  ),
  callback_early_stopping(
    monitor = "val_accuracy",
    patience = 15,
    mode = "max",
    baseline = 0.95
  )
)
```

### callback_model_checkpoint()

Saves model at specified intervals.

**Parameters:**
- `filepath` - Path to save model (can include formatting like "{epoch:02d}")
- `monitor` - Metric to monitor
- `verbose` - Verbosity mode
- `save_best_only` - Only save when monitored metric improves
- `save_weights_only` - Save only weights (not full model)
- `mode` - "auto", "min", or "max"
- `save_freq` - "epoch" or integer (batches between saves)
- `initial_value_threshold` - Initial value for best metric

**Use Cases:**
- Periodic model backups
- Save best performing model
- Resume training from checkpoints

**Example - Save Best Model:**
```r
checkpoint <- callback_model_checkpoint(
  filepath = "models/best_model.keras",
  monitor = "val_loss",
  save_best_only = TRUE,
  save_weights_only = FALSE,
  verbose = 1
)

model |> fit(
  x_train, y_train,
  validation_data = list(x_val, y_val),
  epochs = 100,
  callbacks = list(checkpoint)
)

# Load best model
best_model <- load_model("models/best_model.keras")
```

**Example - Periodic Saves with Formatting:**
```r
checkpoint_periodic <- callback_model_checkpoint(
  filepath = "models/model_epoch_{epoch:02d}_loss_{val_loss:.4f}.keras",
  save_freq = "epoch",
  verbose = 1
)
```

**Example - Save Weights Only:**
```r
weights_checkpoint <- callback_model_checkpoint(
  filepath = "models/weights_epoch_{epoch:02d}.weights.h5",
  save_weights_only = TRUE,
  save_best_only = TRUE,
  monitor = "val_accuracy",
  mode = "max"
)

# Later, load weights
model |> load_model_weights("models/weights_epoch_25.weights.h5")
```

### callback_reduce_lr_on_plateau()

Reduces learning rate when metric stops improving.

**Parameters:**
- `monitor` - Metric to monitor
- `factor` - Factor to reduce learning rate (new_lr = lr * factor)
- `patience` - Number of epochs with no improvement
- `verbose` - Verbosity mode
- `mode` - "auto", "min", or "max"
- `min_delta` - Threshold for measuring improvement
- `cooldown` - Epochs to wait before resuming normal operation
- `min_lr` - Lower bound on learning rate

**Use Cases:**
- Adaptive learning rate scheduling
- Fine-tuning with progressively smaller steps
- Overcoming plateaus in training

**Example - Basic Usage:**
```r
reduce_lr <- callback_reduce_lr_on_plateau(
  monitor = "val_loss",
  factor = 0.5,
  patience = 5,
  min_lr = 0.00001,
  verbose = 1
)

model |> fit(
  x_train, y_train,
  validation_data = list(x_val, y_val),
  epochs = 100,
  callbacks = list(reduce_lr)
)
```

**Example - Aggressive Reduction:**
```r
reduce_lr_aggressive <- callback_reduce_lr_on_plateau(
  monitor = "val_loss",
  factor = 0.2,  # Reduce to 20% of current LR
  patience = 3,
  min_delta = 0.001,
  cooldown = 2,
  min_lr = 1e-7,
  verbose = 1
)
```

### callback_tensorboard()

Writes logs for TensorBoard visualization.

**Parameters:**
- `log_dir` - Directory for log files
- `histogram_freq` - Frequency (epochs) to compute histograms
- `write_graph` - Whether to visualize graph
- `write_images` - Whether to write model weights as images
- `update_freq` - "batch", "epoch", or integer (samples)
- `profile_batch` - Batch range for profiling (e.g., `c(10, 20)`)
- `embeddings_freq` - Frequency to save embeddings
- `embeddings_metadata` - Metadata for embeddings

**Use Cases:**
- Training visualization
- Performance profiling
- Debugging model architecture
- Comparing experiments

**Example - Basic Logging:**
```r
tensorboard_callback <- callback_tensorboard(
  log_dir = "logs/experiment_1",
  histogram_freq = 1,
  write_graph = TRUE
)

model |> fit(
  x_train, y_train,
  validation_data = list(x_val, y_val),
  epochs = 50,
  callbacks = list(tensorboard_callback)
)

# View in TensorBoard
tensorboard::tensorboard(log_dir = "logs")
```

**Example - Advanced Profiling:**
```r
tensorboard_profiling <- callback_tensorboard(
  log_dir = "logs/profiling",
  histogram_freq = 1,
  write_graph = TRUE,
  write_images = TRUE,
  update_freq = "epoch",
  profile_batch = c(10, 20),  # Profile batches 10-20
  embeddings_freq = 5
)
```

### callback_csv_logger()

Streams epoch results to CSV file.

**Parameters:**
- `filename` - Path to CSV file
- `separator` - String used to separate elements in CSV
- `append` - Append if file exists (else overwrite)

**Use Cases:**
- Simple logging without TensorBoard
- Post-processing training metrics
- Generating reports

**Example:**
```r
csv_logger <- callback_csv_logger(
  filename = "training_log.csv",
  append = FALSE
)

model |> fit(
  x_train, y_train,
  validation_data = list(x_val, y_val),
  epochs = 100,
  callbacks = list(csv_logger)
)

# Read and analyze
results <- read.csv("training_log.csv")
plot(results$epoch, results$loss, type = "l")
```

### callback_learning_rate_scheduler()

Schedules learning rate based on custom function.

**Parameters:**
- `schedule` - Function taking epoch index and current LR, returning new LR
- `verbose` - Verbosity mode

**Use Cases:**
- Custom learning rate schedules
- Step decay
- Exponential decay
- Cosine annealing

**Example - Step Decay:**
```r
step_decay_schedule <- function(epoch, lr) {
  drop_rate <- 0.5
  epochs_drop <- 10
  new_lr <- lr * drop_rate^(floor((1 + epoch) / epochs_drop))
  return(new_lr)
}

lr_scheduler <- callback_learning_rate_scheduler(
  schedule = step_decay_schedule,
  verbose = 1
)

model |> fit(
  x_train, y_train,
  epochs = 50,
  callbacks = list(lr_scheduler)
)
```

**Example - Exponential Decay:**
```r
exp_decay_schedule <- function(epoch, lr) {
  initial_lr <- 0.1
  k <- 0.05
  return(initial_lr * exp(-k * epoch))
}

lr_scheduler_exp <- callback_learning_rate_scheduler(
  schedule = exp_decay_schedule,
  verbose = 1
)
```

**Example - Cosine Annealing:**
```r
cosine_schedule <- function(epoch, lr) {
  max_lr <- 0.1
  min_lr <- 0.001
  total_epochs <- 100

  cos_val <- cos(pi * epoch / total_epochs)
  new_lr <- min_lr + (max_lr - min_lr) * (1 + cos_val) / 2
  return(new_lr)
}

lr_scheduler_cosine <- callback_learning_rate_scheduler(
  schedule = cosine_schedule,
  verbose = 1
)
```

### callback_terminate_on_nan()

Stops training when NaN loss is encountered.

**Parameters:** None

**Use Cases:**
- Debugging unstable training
- Fail-fast behavior
- Preventing wasted compute

**Example:**
```r
model |> fit(
  x_train, y_train,
  epochs = 100,
  callbacks = list(callback_terminate_on_nan())
)
```

### callback_backup_and_restore()

Backs up model for fault tolerance.

**Parameters:**
- `backup_dir` - Directory to save backups
- `save_freq` - "epoch" or integer (batches)
- `delete_checkpoint` - Delete checkpoint after successful training

**Use Cases:**
- Long training runs
- Preemptible compute instances
- Crash recovery

**Example:**
```r
backup_callback <- callback_backup_and_restore(
  backup_dir = "backup/model_checkpoint",
  save_freq = "epoch",
  delete_checkpoint = TRUE
)

# Training will resume from backup if interrupted
model |> fit(
  x_train, y_train,
  epochs = 100,
  callbacks = list(backup_callback)
)
```

## Custom Callbacks

### Callback Base Class

Create custom callbacks by extending the Callback class and implementing hooks.

**Available Hooks:**
- `on_train_begin(logs)` - Called at start of training
- `on_train_end(logs)` - Called at end of training
- `on_epoch_begin(epoch, logs)` - Called at start of each epoch
- `on_epoch_end(epoch, logs)` - Called at end of each epoch
- `on_batch_begin(batch, logs)` - Called at start of each batch
- `on_batch_end(batch, logs)` - Called at end of each batch
- `on_predict_begin(logs)` - Called at start of prediction
- `on_predict_end(logs)` - Called at end of prediction

**Access to Model:**
- `self$model` - Reference to Keras model
- `self$model$stop_training` - Set to TRUE to stop training

### Example 1: Custom Metric Logger

```r
library(keras3)

# Custom callback to track and plot metrics
MetricLogger <- new_callback_class(
  "MetricLogger",

  initialize = function(metric_name = "accuracy") {
    self$metric_name <- metric_name
    self$history <- list()
  },

  on_epoch_end = function(epoch, logs = NULL) {
    metric_value <- logs[[self$metric_name]]
    self$history[[epoch + 1]] <- metric_value

    cat(sprintf("Epoch %d: %s = %.4f\n",
                epoch, self$metric_name, metric_value))
  },

  on_train_end = function(logs = NULL) {
    cat("\nTraining complete. Final history:\n")
    print(unlist(self$history))
  }
)

# Usage
metric_logger <- MetricLogger(metric_name = "val_accuracy")

model |> fit(
  x_train, y_train,
  validation_split = 0.2,
  epochs = 10,
  callbacks = list(metric_logger)
)
```

### Example 2: Gradient Norm Monitor

```r
GradientMonitor <- new_callback_class(
  "GradientMonitor",

  initialize = function(log_freq = 10) {
    self$log_freq <- log_freq
    self$batch_count <- 0
  },

  on_batch_end = function(batch, logs = NULL) {
    self$batch_count <- self$batch_count + 1

    if (self$batch_count %% self$log_freq == 0) {
      # Access model weights
      weights <- self$model$trainable_weights

      # Compute total gradient norm
      total_norm <- 0
      for (w in weights) {
        # Access backend ops
        ops <- keras3::keras$ops
        norm <- ops$sqrt(ops$sum(ops$square(w)))
        total_norm <- total_norm + norm
      }

      cat(sprintf("Batch %d: Total gradient norm = %.4f\n",
                  self$batch_count, total_norm))
    }
  }
)

# Usage
grad_monitor <- GradientMonitor(log_freq = 100)

model |> fit(
  x_train, y_train,
  epochs = 5,
  callbacks = list(grad_monitor)
)
```

### Example 3: Learning Rate Warmup

```r
WarmupScheduler <- new_callback_class(
  "WarmupScheduler",

  initialize = function(warmup_epochs, base_lr, target_lr) {
    self$warmup_epochs <- warmup_epochs
    self$base_lr <- base_lr
    self$target_lr <- target_lr
  },

  on_epoch_begin = function(epoch, logs = NULL) {
    if (epoch < self$warmup_epochs) {
      # Linear warmup
      lr <- self$base_lr + (self$target_lr - self$base_lr) *
            (epoch / self$warmup_epochs)

      # Set learning rate
      self$model$optimizer$learning_rate <- lr

      cat(sprintf("Epoch %d: Learning rate = %.6f (warmup)\n",
                  epoch, lr))
    } else if (epoch == self$warmup_epochs) {
      self$model$optimizer$learning_rate <- self$target_lr
      cat(sprintf("Epoch %d: Learning rate = %.6f (warmup complete)\n",
                  epoch, self$target_lr))
    }
  }
)

# Usage
warmup <- WarmupScheduler(
  warmup_epochs = 5,
  base_lr = 0.0001,
  target_lr = 0.001
)

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.0001),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)

model |> fit(
  x_train, y_train,
  epochs = 50,
  callbacks = list(warmup)
)
```

### Example 4: Custom Early Stopping with Multiple Conditions

```r
SmartEarlyStopping <- new_callback_class(
  "SmartEarlyStopping",

  initialize = function(loss_threshold, acc_threshold, patience) {
    self$loss_threshold <- loss_threshold
    self$acc_threshold <- acc_threshold
    self$patience <- patience
    self$wait <- 0
    self$best_loss <- Inf
  },

  on_epoch_end = function(epoch, logs = NULL) {
    val_loss <- logs[["val_loss"]]
    val_acc <- logs[["val_accuracy"]]

    # Check if thresholds met
    if (val_loss < self$loss_threshold && val_acc > self$acc_threshold) {
      cat(sprintf("\nEpoch %d: Thresholds met! Stopping training.\n", epoch))
      self$model$stop_training <- TRUE
      return()
    }

    # Check for improvement
    if (val_loss < self$best_loss) {
      self$best_loss <- val_loss
      self$wait <- 0
    } else {
      self$wait <- self$wait + 1
      if (self$wait >= self$patience) {
        cat(sprintf("\nEpoch %d: No improvement for %d epochs. Stopping.\n",
                    epoch, self$patience))
        self$model$stop_training <- TRUE
      }
    }
  }
)

# Usage
smart_stop <- SmartEarlyStopping(
  loss_threshold = 0.1,
  acc_threshold = 0.95,
  patience = 10
)

model |> fit(
  x_train, y_train,
  validation_data = list(x_val, y_val),
  epochs = 100,
  callbacks = list(smart_stop)
)
```

### Example 5: Weight Statistics Logger

```r
WeightStatsLogger <- new_callback_class(
  "WeightStatsLogger",

  initialize = function(layer_names = NULL, log_freq = 5) {
    self$layer_names <- layer_names
    self$log_freq <- log_freq
  },

  on_epoch_end = function(epoch, logs = NULL) {
    if (epoch %% self$log_freq == 0) {
      cat(sprintf("\n=== Weight Statistics at Epoch %d ===\n", epoch))

      layers <- if (is.null(self$layer_names)) {
        self$model$layers
      } else {
        Filter(function(l) l$name %in% self$layer_names, self$model$layers)
      }

      for (layer in layers) {
        if (length(layer$trainable_weights) > 0) {
          weights <- layer$trainable_weights[[1]]

          ops <- keras3::keras$ops
          mean_val <- ops$mean(weights)
          std_val <- ops$std(weights)
          min_val <- ops$min(weights)
          max_val <- ops$max(weights)

          cat(sprintf("  %s: mean=%.4f, std=%.4f, min=%.4f, max=%.4f\n",
                      layer$name, mean_val, std_val, min_val, max_val))
        }
      }
      cat("\n")
    }
  }
)

# Usage
weight_stats <- WeightStatsLogger(log_freq = 5)

model |> fit(
  x_train, y_train,
  epochs = 50,
  callbacks = list(weight_stats)
)
```

## Combining Callbacks

### Complete Training Pipeline

```r
library(keras3)

# Build callbacks
callbacks_list <- list(
  # Early stopping with best weights
  callback_early_stopping(
    monitor = "val_loss",
    patience = 15,
    restore_best_weights = TRUE,
    verbose = 1
  ),

  # Save best model
  callback_model_checkpoint(
    filepath = "models/best_model.keras",
    monitor = "val_accuracy",
    mode = "max",
    save_best_only = TRUE,
    verbose = 1
  ),

  # Adaptive learning rate
  callback_reduce_lr_on_plateau(
    monitor = "val_loss",
    factor = 0.5,
    patience = 5,
    min_lr = 1e-7,
    verbose = 1
  ),

  # Logging
  callback_csv_logger("training_log.csv"),
  callback_tensorboard(log_dir = "logs"),

  # Safety
  callback_terminate_on_nan(),

  # Custom callback
  MetricLogger(metric_name = "val_accuracy")
)

# Train with all callbacks
model |> fit(
  x_train, y_train,
  validation_data = list(x_val, y_val),
  epochs = 100,
  batch_size = 32,
  callbacks = callbacks_list
)
```

## See Also

- [advanced-patterns.md](advanced-patterns.md) - Custom training loops with callbacks
- [backend-guide.md](backend-guide.md) - Backend-specific callback considerations
- [keras-applications.md](keras-applications.md) - Transfer learning with callbacks
