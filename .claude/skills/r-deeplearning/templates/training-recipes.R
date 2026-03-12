# Training Script Templates
# Ready-to-use training patterns for torch and keras3

# =============================================================================
# Recipe 1: Torch Manual Training Loop
# =============================================================================

# Use when you need full control over training process
# Good for custom loss functions, complex validation logic

library(torch)

# Define model
model <- your_model(n_classes = 10)
model$to(device = "cuda")  # Move to GPU if available

# Setup
optimizer <- optim_adam(model$parameters, lr = 0.001, weight_decay = 1e-4)
criterion <- nn_cross_entropy_loss()

# Learning rate scheduler
scheduler <- lr_reduce_on_plateau(
  optimizer,
  mode = "min",
  factor = 0.5,
  patience = 5
)

# Training loop
n_epochs <- 50
best_val_loss <- Inf

for (epoch in 1:n_epochs) {
  # Training phase
  model$train()
  train_loss <- 0
  train_correct <- 0
  train_total <- 0

  coro::loop(for (batch in train_dl) {
    # Move to device
    inputs <- batch$x$to(device = "cuda")
    targets <- batch$y$to(device = "cuda")

    # Forward pass
    optimizer$zero_grad()
    outputs <- model(inputs)
    loss <- criterion(outputs, targets)

    # Backward pass
    loss$backward()
    optimizer$step()

    # Metrics
    train_loss <- train_loss + loss$item()
    preds <- torch_argmax(outputs, dim = 2)
    train_correct <- train_correct + (preds == targets)$sum()$item()
    train_total <- train_total + targets$size(1)
  })

  train_acc <- train_correct / train_total

  # Validation phase
  model$eval()
  val_loss <- 0
  val_correct <- 0
  val_total <- 0

  with_no_grad({
    coro::loop(for (batch in val_dl) {
      inputs <- batch$x$to(device = "cuda")
      targets <- batch$y$to(device = "cuda")

      outputs <- model(inputs)
      loss <- criterion(outputs, targets)

      val_loss <- val_loss + loss$item()
      preds <- torch_argmax(outputs, dim = 2)
      val_correct <- val_correct + (preds == targets)$sum()$item()
      val_total <- val_total + targets$size(1)
    })
  })

  val_acc <- val_correct / val_total
  val_loss_avg <- val_loss / length(val_dl)

  # Learning rate scheduling
  scheduler$step(val_loss_avg)

  # Print progress
  cat(sprintf(
    "Epoch %d/%d - train_loss: %.4f - train_acc: %.4f - val_loss: %.4f - val_acc: %.4f\n",
    epoch, n_epochs, train_loss / length(train_dl), train_acc, val_loss_avg, val_acc
  ))

  # Save best model
  if (val_loss_avg < best_val_loss) {
    best_val_loss <- val_loss_avg
    torch_save(model, "best_model.pt")
    cat("  -> Saved best model\n")
  }

  # Early stopping
  if (epoch > 20 && val_loss_avg > best_val_loss * 1.1) {
    cat("Early stopping triggered\n")
    break
  }
}


# =============================================================================
# Recipe 2: Luz High-Level Training
# =============================================================================

# Recommended for most use cases
# Clean, declarative, built-in callbacks

library(torch)
library(luz)

# Train model
fitted <- model %>%
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_accuracy(),
      luz_metric_precision(),
      luz_metric_recall()
    )
  ) %>%

  set_hparams(
    # Model hyperparameters
    n_classes = 10,
    dropout = 0.5
  ) %>%

  set_opt_hparams(
    # Optimizer hyperparameters
    lr = 0.001,
    weight_decay = 1e-4
  ) %>%

  fit(
    train_dl,
    epochs = 50,
    valid_data = val_dl,

    callbacks = list(
      # Early stopping
      luz_callback_early_stopping(
        monitor = "valid_loss",
        patience = 10,
        mode = "min"
      ),

      # Learning rate scheduler
      luz_callback_lr_scheduler(
        lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 5,
        threshold = 0.001
      ),

      # Model checkpointing
      luz_callback_model_checkpoint(
        path = "models/",
        monitor = "valid_loss",
        save_best_only = TRUE,
        mode = "min"
      ),

      # CSV logger
      luz_callback_csv_logger("training_log.csv"),

      # Print progress
      luz_callback_progress()
    ),

    verbose = TRUE
  )

# Save final model
luz_save(fitted, "final_model.pt")

# Load model
loaded <- luz_load("final_model.pt")

# Continue training from checkpoint
fitted <- loaded %>%
  fit(
    train_dl,
    epochs = 20,  # Additional epochs
    valid_data = val_dl
  )


# =============================================================================
# Recipe 3: Keras3 Training
# =============================================================================

# Use for compatibility with Keras/TensorFlow ecosystem
# Good for deployment with TensorFlow Serving

library(keras3)

# Build model
model <- keras_model_sequential() %>%
  layer_conv_2d(32, c(3, 3), activation = "relu", input_shape = c(128, 216, 1)) %>%
  layer_max_pooling_2d(c(2, 2)) %>%
  layer_conv_2d(64, c(3, 3), activation = "relu") %>%
  layer_max_pooling_2d(c(2, 2)) %>%
  layer_flatten() %>%
  layer_dropout(0.5) %>%
  layer_dense(128, activation = "relu") %>%
  layer_dense(10, activation = "softmax")

# Compile
model %>% compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "sparse_categorical_crossentropy",
  metrics = c("accuracy")
)

# Train
history <- model %>% fit(
  train_dl,
  epochs = 50,
  validation_data = val_dl,
  callbacks = list(
    callback_early_stopping(
      monitor = "val_loss",
      patience = 10,
      restore_best_weights = TRUE
    ),
    callback_reduce_lr_on_plateau(
      monitor = "val_loss",
      factor = 0.5,
      patience = 5
    ),
    callback_model_checkpoint(
      filepath = "models/model_{epoch:02d}_{val_loss:.4f}.keras",
      monitor = "val_loss",
      save_best_only = TRUE
    ),
    callback_csv_logger("keras_log.csv")
  )
)

# Plot training history
plot(history)

# Save model
save_model_tf(model, "final_model.keras")

# Load model
model <- load_model_tf("final_model.keras")


# =============================================================================
# Recipe 4: Custom Callbacks
# =============================================================================

# Create custom luz callback for advanced logging/monitoring

library(luz)

# Custom callback: Log to external service (e.g., Weights & Biases)
luz_callback_wandb <- luz_callback(
  name = "wandb_logger",

  initialize = function(project_name, run_name) {
    self$project <- project_name
    self$run <- run_name
    # Initialize wandb (hypothetical)
    # wandb$init(project = project_name, name = run_name)
  },

  on_epoch_end = function() {
    # Log metrics
    metrics <- ctx$get_metrics()
    # wandb$log(metrics)

    cat(sprintf("Logged to wandb: %s\n", paste(names(metrics), collapse = ", ")))
  },

  on_fit_end = function() {
    cat("Training complete - closing wandb\n")
    # wandb$finish()
  }
)

# Custom callback: Save predictions on validation set
luz_callback_save_predictions <- luz_callback(
  name = "save_predictions",

  initialize = function(output_path = "predictions/") {
    self$output_path <- output_path
    dir.create(output_path, showWarnings = FALSE, recursive = TRUE)
  },

  on_epoch_end = function() {
    epoch <- ctx$epoch

    # Get model
    model <- ctx$model
    model$eval()

    all_preds <- list()
    all_targets <- list()

    with_no_grad({
      coro::loop(for (batch in ctx$valid_data) {
        preds <- model(batch$x)
        all_preds[[length(all_preds) + 1]] <- as.matrix(preds$cpu())
        all_targets[[length(all_targets) + 1]] <- as.matrix(batch$y$cpu())
      })
    })

    # Save predictions
    predictions <- do.call(rbind, all_preds)
    targets <- do.call(rbind, all_targets)

    saveRDS(
      list(predictions = predictions, targets = targets),
      file.path(self$output_path, sprintf("epoch_%03d.rds", epoch))
    )

    cat(sprintf("Saved predictions for epoch %d\n", epoch))
  }
)

# Use custom callbacks
fitted <- model %>%
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(luz_metric_accuracy())
  ) %>%
  set_hparams(n_classes = 10) %>%
  set_opt_hparams(lr = 0.001) %>%
  fit(
    train_dl,
    epochs = 50,
    valid_data = val_dl,
    callbacks = list(
      luz_callback_wandb(project_name = "audio-classification", run_name = "run_001"),
      luz_callback_save_predictions(output_path = "predictions/")
    )
  )


# =============================================================================
# Recipe 5: Multi-GPU Training
# =============================================================================

# Distributed training across multiple GPUs
# Requires torch >= 0.10 and multi-GPU setup

library(torch)
library(luz)

# Check available GPUs
if (cuda_is_available()) {
  n_gpus <- cuda_device_count()
  cat(sprintf("Found %d GPU(s)\n", n_gpus))
} else {
  stop("CUDA not available")
}

# Wrap model for data parallelism
model <- your_model(n_classes = 10)
model <- nn_data_parallel(model, device_ids = c(0, 1))  # Use GPUs 0 and 1

# Adjust batch size for multiple GPUs
# If single-GPU batch_size = 32, use 64 for 2 GPUs
train_dl <- dataloader(train_ds, batch_size = 64, shuffle = TRUE)

# Scale learning rate proportionally
base_lr <- 0.001
lr <- base_lr * (64 / 32)  # Scale by effective batch size

# Train as usual
fitted <- model %>%
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(luz_metric_accuracy())
  ) %>%
  set_hparams(n_classes = 10) %>%
  set_opt_hparams(lr = lr) %>%
  fit(train_dl, epochs = 50, valid_data = val_dl)


# =============================================================================
# Recipe 6: Gradient Accumulation (Simulate Larger Batches)
# =============================================================================

# When GPU memory is limited, accumulate gradients over multiple mini-batches

library(torch)

# Setup
model <- your_model(n_classes = 10)$to(device = "cuda")
optimizer <- optim_adam(model$parameters, lr = 0.001)
criterion <- nn_cross_entropy_loss()

accumulation_steps <- 4  # Simulate batch_size * 4
effective_batch_size <- 16 * 4  # 64

model$train()
epoch_loss <- 0

coro::loop(for (i in seq_along(train_dl)) {
  batch <- train_dl[[i]]
  inputs <- batch$x$to(device = "cuda")
  targets <- batch$y$to(device = "cuda")

  # Forward pass
  outputs <- model(inputs)
  loss <- criterion(outputs, targets)

  # Normalize loss by accumulation steps
  loss <- loss / accumulation_steps
  loss$backward()

  # Update weights every accumulation_steps
  if (i %% accumulation_steps == 0) {
    optimizer$step()
    optimizer$zero_grad()
  }

  epoch_loss <- epoch_loss + loss$item() * accumulation_steps
})

# Don't forget to update after final batch
optimizer$step()
optimizer$zero_grad()


# =============================================================================
# Recipe 7: Mixed Precision Training (FP16)
# =============================================================================

# Train with 16-bit floats for speed and memory efficiency
# Requires torch >= 0.8 and compatible GPU (Volta or newer)

library(torch)

# Create model and move to GPU
model <- your_model(n_classes = 10)$to(device = "cuda")
optimizer <- optim_adam(model$parameters, lr = 0.001)
criterion <- nn_cross_entropy_loss()

# Gradient scaler for mixed precision
scaler <- cuda_amp_grad_scaler()

# Training loop
for (epoch in 1:50) {
  model$train()

  coro::loop(for (batch in train_dl) {
    inputs <- batch$x$to(device = "cuda")
    targets <- batch$y$to(device = "cuda")

    optimizer$zero_grad()

    # Forward pass with autocast
    with_autocast(device_type = "cuda", {
      outputs <- model(inputs)
      loss <- criterion(outputs, targets)
    })

    # Backward pass with gradient scaling
    scaler$scale(loss)$backward()
    scaler$step(optimizer)
    scaler$update()
  })
}


# =============================================================================
# Recipe 8: Learning Rate Warmup
# =============================================================================

# Gradually increase learning rate at start of training
# Helps stabilize training, especially for large models

library(torch)

# Warmup scheduler
create_warmup_scheduler <- function(optimizer, warmup_epochs, base_lr) {
  current_epoch <- 0

  function() {
    current_epoch <<- current_epoch + 1

    if (current_epoch <= warmup_epochs) {
      # Linear warmup
      lr <- base_lr * (current_epoch / warmup_epochs)
    } else {
      # After warmup, use base_lr
      lr <- base_lr
    }

    # Set learning rate
    for (param_group in optimizer$param_groups) {
      param_group$lr <- lr
    }

    invisible(lr)
  }
}

# Usage
base_lr <- 0.001
warmup_epochs <- 5

optimizer <- optim_adam(model$parameters, lr = base_lr)
warmup_scheduler <- create_warmup_scheduler(optimizer, warmup_epochs, base_lr)

# In training loop
for (epoch in 1:50) {
  # Apply warmup
  current_lr <- warmup_scheduler()
  cat(sprintf("Epoch %d - LR: %.6f\n", epoch, current_lr))

  # Train epoch
  # ...
}


# =============================================================================
# Recipe 9: Training with Class Weights
# =============================================================================

# Handle imbalanced datasets by weighting loss per class

library(torch)

# Compute class weights
compute_class_weights <- function(labels) {
  class_counts <- table(labels)
  total <- sum(class_counts)
  n_classes <- length(class_counts)

  # Inverse frequency weighting
  weights <- total / (n_classes * class_counts)

  # Normalize
  weights <- weights / sum(weights) * n_classes

  return(torch_tensor(as.numeric(weights)))
}

# Example
train_labels <- train_metadata$label_id
class_weights <- compute_class_weights(train_labels)

cat("Class weights:\n")
print(class_weights)

# Use in loss function
criterion <- nn_cross_entropy_loss(weight = class_weights$to(device = "cuda"))

# Or use Focal Loss for extreme imbalance
focal_loss <- function(alpha = 0.25, gamma = 2.0) {
  function(input, target) {
    ce_loss <- nnf_cross_entropy(input, target, reduction = "none")
    pt <- torch_exp(-ce_loss)
    focal <- alpha * (1 - pt)^gamma * ce_loss
    return(focal$mean())
  }
}

criterion <- focal_loss(alpha = 0.25, gamma = 2.0)


# =============================================================================
# Recipe 10: Transfer Learning Two-Phase Training
# =============================================================================

# Train pretrained model in two phases: frozen then fine-tuning

library(torch)
library(luz)

# Load pretrained backbone
pretrained_backbone <- model_resnet18(pretrained = TRUE)

# Create transfer learning model
model <- transfer_model(
  n_classes = 10,
  backbone = pretrained_backbone,
  freeze_backbone = TRUE
)

# Phase 1: Train only classifier head (frozen backbone)
cat("Phase 1: Training classifier head\n")

fitted_phase1 <- model %>%
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(luz_metric_accuracy())
  ) %>%
  set_hparams(n_classes = 10, freeze_backbone = TRUE) %>%
  set_opt_hparams(lr = 0.001) %>%  # Higher LR for new layers
  fit(
    train_dl,
    epochs = 10,
    valid_data = val_dl,
    callbacks = list(
      luz_callback_early_stopping(patience = 5),
      luz_callback_model_checkpoint(path = "models/phase1/")
    )
  )

# Phase 2: Fine-tune entire model (unfreeze backbone)
cat("Phase 2: Fine-tuning entire model\n")

# Unfreeze backbone
fitted_phase1$model$unfreeze_backbone()

fitted_phase2 <- fitted_phase1 %>%
  set_opt_hparams(lr = 1e-5) %>%  # Much lower LR for fine-tuning
  fit(
    train_dl,
    epochs = 20,
    valid_data = val_dl,
    callbacks = list(
      luz_callback_early_stopping(patience = 10),
      luz_callback_lr_scheduler(lr_reduce_on_plateau, patience = 3),
      luz_callback_model_checkpoint(path = "models/phase2/")
    )
  )

luz_save(fitted_phase2, "final_transfer_model.pt")


# =============================================================================
# Notes
# =============================================================================

# GPU Memory Management:
# - Clear cache between runs: cuda_empty_cache()
# - Monitor memory: cuda_memory_allocated() / 1e9  # GB
# - Reduce batch size if OOM

# Debugging:
# - Check for NaN: torch_any(torch_isnan(tensor))
# - Gradient clipping: torch_nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)
# - Overfit single batch first (sanity check)

# Model Saving:
# - luz_save(): Full model + optimizer state
# - torch_save(model): Model weights only
# - save_model_tf(): Keras models

# Reproducibility:
# - Set seed: torch_manual_seed(42)
# - Deterministic ops: torch_set_deterministic(TRUE)
