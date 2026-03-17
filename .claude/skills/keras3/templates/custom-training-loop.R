# =============================================================================
# Custom Training Loop Template with GradientTape
# =============================================================================
# A research-oriented template for advanced training scenarios requiring
# custom training loops. Use this when you need fine-grained control over
# the training process beyond what fit() provides.
#
# When to use custom training loops:
# - Custom loss functions with complex logic
# - Multiple models training simultaneously (GANs, multi-task learning)
# - Non-standard gradient updates
# - Custom metric computation per batch
# - Research experiments requiring detailed control
#
# Performance note: tf_function() compilation provides ~10x speedup
# =============================================================================

library(keras3)

# =============================================================================
# 1. DATA PREPARATION
# =============================================================================

# TODO: Load and preprocess your data
cat("Loading data...\n")

# Example data loading (replace with your data)
# c(c(x_train, y_train), c(x_test, y_test)) %<-% dataset_mnist()
# x_train <- x_train / 255
# x_test <- x_test / 255

# TODO: Replace with your actual data
# x_train <- ...
# y_train <- ...
# x_val <- ...
# y_val <- ...

# For multi-class classification, convert labels:
# num_classes <- length(unique(y_train))
# y_train <- to_categorical(y_train, num_classes)
# y_val <- to_categorical(y_val, num_classes)

# =============================================================================
# 2. CREATE TENSORFLOW DATASETS
# =============================================================================

# TODO: Adjust batch_size based on your data and hardware
batch_size <- 32

# Create tf.data.Dataset for efficient batching and shuffling
train_dataset <- tfdatasets::tensor_slices_dataset(list(x_train, y_train)) %>%
  tfdatasets::dataset_shuffle(buffer_size = 1024) %>%
  tfdatasets::dataset_batch(batch_size)

val_dataset <- tfdatasets::tensor_slices_dataset(list(x_val, y_val)) %>%
  tfdatasets::dataset_batch(batch_size)

# =============================================================================
# 3. MODEL DEFINITION
# =============================================================================

# TODO: Define your model architecture
# Option 1: Functional API (recommended for research)
# Option 2: Sequential API (simpler)
# Option 3: Model subclassing (most flexible)

# Example: Functional API
input_dim <- ncol(x_train)
# TODO: Set based on your problem
# num_classes <- 10  # Multi-class
# num_classes <- 1   # Binary

inputs <- layer_input(shape = c(input_dim))

outputs <- inputs %>%
  layer_dense(units = 128, activation = "relu") %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dropout(rate = 0.3) %>%
  # TODO: Adjust output layer for your problem
  layer_dense(units = num_classes, activation = "softmax")

model <- keras_model(inputs = inputs, outputs = outputs)

summary(model)

# =============================================================================
# 4. LOSS FUNCTION AND OPTIMIZER
# =============================================================================

# TODO: Choose appropriate loss function for your problem

# For multi-class classification:
loss_fn <- loss_categorical_crossentropy()

# For binary classification:
# loss_fn <- loss_binary_crossentropy()

# For regression:
# loss_fn <- loss_mean_squared_error()

# Custom loss function example:
# custom_loss <- function(y_true, y_pred) {
#   # Your custom loss logic here
#   mse <- tf$reduce_mean(tf$square(y_true - y_pred))
#   # Add custom terms, regularization, etc.
#   return(mse)
# }
# loss_fn <- custom_loss

# TODO: Choose and configure optimizer
optimizer <- optimizer_adam(learning_rate = 0.001)

# Other optimizers:
# optimizer <- optimizer_sgd(learning_rate = 0.01, momentum = 0.9)
# optimizer <- optimizer_rmsprop(learning_rate = 0.001)
# optimizer <- optimizer_adamw(learning_rate = 0.001, weight_decay = 0.01)

# =============================================================================
# 5. METRICS
# =============================================================================

# Initialize metrics that accumulate over batches
train_loss_metric <- metric_mean(name = "train_loss")
train_accuracy_metric <- metric_categorical_accuracy(name = "train_accuracy")

val_loss_metric <- metric_mean(name = "val_loss")
val_accuracy_metric <- metric_categorical_accuracy(name = "val_accuracy")

# Custom metric example:
# custom_metric <- metric_mean(name = "custom_metric")

# =============================================================================
# 6. TRAINING STEP FUNCTION
# =============================================================================

# Define training step with GradientTape
# This function will be compiled with tf_function for performance
train_step <- function(x_batch, y_batch) {
  # GradientTape records operations for automatic differentiation
  with(tf$GradientTape() %as% tape, {
    # Forward pass
    predictions <- model(x_batch, training = TRUE)

    # Compute loss
    loss_value <- loss_fn(y_batch, predictions)

    # TODO: Add custom loss terms if needed
    # Example: Add L2 regularization
    # l2_loss <- tf$add_n(lapply(model$trainable_variables, function(v) {
    #   tf$nn$l2_loss(v)
    # }))
    # loss_value <- loss_value + 0.001 * l2_loss
  })

  # Compute gradients
  gradients <- tape$gradient(loss_value, model$trainable_variables)

  # TODO: Gradient clipping (optional, useful for RNNs)
  # gradients <- lapply(gradients, function(g) {
  #   tf$clip_by_value(g, -1.0, 1.0)
  # })

  # Apply gradients
  optimizer$apply(gradients, model$trainable_variables)

  # Update metrics
  train_loss_metric$update_state(loss_value)
  train_accuracy_metric$update_state(y_batch, predictions)

  return(loss_value)
}

# Compile with tf_function for ~10x speedup
# Remove this line during debugging to get full stack traces
train_step <- tf_function(train_step)

# =============================================================================
# 7. VALIDATION STEP FUNCTION
# =============================================================================

val_step <- function(x_batch, y_batch) {
  # Forward pass without gradient tracking
  predictions <- model(x_batch, training = FALSE)

  # Compute loss
  loss_value <- loss_fn(y_batch, predictions)

  # Update metrics
  val_loss_metric$update_state(loss_value)
  val_accuracy_metric$update_state(y_batch, predictions)

  return(loss_value)
}

# Compile with tf_function
val_step <- tf_function(val_step)

# =============================================================================
# 8. CUSTOM TRAINING LOOP
# =============================================================================

# TODO: Adjust hyperparameters
epochs <- 50
print_every <- 10  # Print progress every N batches

# For model checkpointing
best_val_loss <- Inf
checkpoint_path <- "best_model_checkpoint.keras"

cat("Starting custom training loop...\n\n")

for (epoch in seq_len(epochs)) {
  cat(sprintf("Epoch %d/%d\n", epoch, epochs))

  # Reset metrics at the start of each epoch
  train_loss_metric$reset_state()
  train_accuracy_metric$reset_state()

  # ---------------------------------------------------------------------
  # Training Loop
  # ---------------------------------------------------------------------
  batch_num <- 0

  # Iterate over training batches
  train_iterator <- reticulate::as_iterator(train_dataset)
  coro::loop(for (batch in train_iterator) {
    batch_num <- batch_num + 1
    x_batch <- batch[[1]]
    y_batch <- batch[[2]]

    # Perform training step
    loss_value <- train_step(x_batch, y_batch)

    # Print progress
    if (batch_num %% print_every == 0) {
      cat(sprintf("  Batch %d - Loss: %.4f\n",
                  batch_num,
                  as.numeric(loss_value)))
    }
  })

  # Get training metrics for the epoch
  train_loss <- train_loss_metric$result()
  train_acc <- train_accuracy_metric$result()

  # ---------------------------------------------------------------------
  # Validation Loop
  # ---------------------------------------------------------------------
  val_loss_metric$reset_state()
  val_accuracy_metric$reset_state()

  val_iterator <- reticulate::as_iterator(val_dataset)
  coro::loop(for (batch in val_iterator) {
    x_batch <- batch[[1]]
    y_batch <- batch[[2]]
    val_step(x_batch, y_batch)
  })

  # Get validation metrics
  val_loss <- val_loss_metric$result()
  val_acc <- val_accuracy_metric$result()

  # Print epoch summary
  cat(sprintf("  Train Loss: %.4f - Train Acc: %.4f\n", train_loss, train_acc))
  cat(sprintf("  Val Loss: %.4f - Val Acc: %.4f\n", val_loss, val_acc))

  # ---------------------------------------------------------------------
  # Model Checkpointing
  # ---------------------------------------------------------------------
  if (val_loss < best_val_loss) {
    best_val_loss <- val_loss
    model %>% save_model_keras(checkpoint_path)
    cat("  >>> Best model saved!\n")
  }

  # TODO: Add custom logic here
  # Examples:
  # - Learning rate scheduling
  # - Early stopping
  # - Custom logging
  # - Visualization updates

  # Example: Learning rate decay
  # if (epoch %% 10 == 0) {
  #   new_lr <- optimizer$learning_rate * 0.5
  #   optimizer$learning_rate <- new_lr
  #   cat(sprintf("  Learning rate reduced to: %f\n", new_lr))
  # }

  cat("\n")
}

cat("Training complete!\n")
cat(sprintf("Best validation loss: %.4f\n", best_val_loss))

# =============================================================================
# 9. LOAD BEST MODEL AND EVALUATE
# =============================================================================

# Load the best model
best_model <- load_model_keras(checkpoint_path)

# Final evaluation
cat("\nFinal evaluation on validation set:\n")
final_val_loss_metric <- metric_mean()
final_val_acc_metric <- metric_categorical_accuracy()

val_iterator <- reticulate::as_iterator(val_dataset)
coro::loop(for (batch in val_iterator) {
  x_batch <- batch[[1]]
  y_batch <- batch[[2]]

  predictions <- best_model(x_batch, training = FALSE)
  loss_value <- loss_fn(y_batch, predictions)

  final_val_loss_metric$update_state(loss_value)
  final_val_acc_metric$update_state(y_batch, predictions)
})

cat(sprintf("Final Val Loss: %.4f\n", final_val_loss_metric$result()))
cat(sprintf("Final Val Acc: %.4f\n", final_val_acc_metric$result()))

# =============================================================================
# 10. ADVANCED EXTENSIONS
# =============================================================================

# TODO: Extend this template for your research needs

# Extension 1: Multiple Models (GAN example structure)
# generator <- keras_model(...)
# discriminator <- keras_model(...)
#
# gen_optimizer <- optimizer_adam(0.0002, beta_1 = 0.5)
# disc_optimizer <- optimizer_adam(0.0002, beta_1 = 0.5)
#
# train_step <- function(real_images) {
#   # Train discriminator
#   with(tf$GradientTape() %as% tape, {
#     # ... discriminator loss
#   })
#   disc_grads <- tape$gradient(d_loss, discriminator$trainable_variables)
#   disc_optimizer$apply(disc_grads, discriminator$trainable_variables)
#
#   # Train generator
#   with(tf$GradientTape() %as% tape, {
#     # ... generator loss
#   })
#   gen_grads <- tape$gradient(g_loss, generator$trainable_variables)
#   gen_optimizer$apply(gen_grads, generator$trainable_variables)
# }

# Extension 2: Mixed Precision Training (faster on modern GPUs)
# policy <- mixed_precision$Policy("mixed_float16")
# mixed_precision$set_global_policy(policy)
# optimizer <- mixed_precision$LossScaleOptimizer(optimizer)

# Extension 3: Custom Callbacks
# save_samples <- function(epoch) {
#   if (epoch %% 5 == 0) {
#     # Generate/save samples for visualization
#   }
# }

# Extension 4: Multi-GPU Training
# strategy <- tf$distribute$MirroredStrategy()
# with(strategy$scope(), {
#   model <- create_model()
#   optimizer <- optimizer_adam()
# })

# =============================================================================
# PERFORMANCE OPTIMIZATION TIPS
# =============================================================================
#
# 1. TF_FUNCTION COMPILATION:
#    - Provides 10-100x speedup by converting to graph execution
#    - Remove during debugging to get full error messages
#    - Recompiles when input shapes change
#
# 2. DATASET API:
#    - Use tensor_slices_dataset + batch for efficient loading
#    - Add prefetch for overlapping data loading and training:
#      dataset %>% dataset_prefetch(buffer_size = tf$data$AUTOTUNE)
#    - Use dataset_cache() to cache small datasets in memory
#
# 3. MIXED PRECISION:
#    - Use float16 for ~2x speedup on modern GPUs
#    - Requires loss scaling to prevent underflow
#
# 4. GRADIENT ACCUMULATION:
#    - Simulate larger batch sizes with limited memory
#    - Accumulate gradients over N steps before applying
#
# 5. PROFILING:
#    - Use TensorFlow Profiler to identify bottlenecks
#    - Check GPU utilization with nvidia-smi
#
# =============================================================================
# RESEARCH USE CASES
# =============================================================================
#
# This template is ideal for:
#
# 1. Novel loss functions requiring complex computation
# 2. Multi-model training (GANs, autoencoders, multi-task)
# 3. Curriculum learning with dynamic data sampling
# 4. Meta-learning algorithms (MAML, Reptile)
# 5. Reinforcement learning policy optimization
# 6. Custom gradient manipulation (gradient penalty, gradient clipping)
# 7. Online/continual learning scenarios
# 8. Debugging gradient flow and training dynamics
#
# =============================================================================
