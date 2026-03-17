# =============================================================================
# Simple Keras3 Classifier Template
# =============================================================================
# A production-ready template for standard classification tasks using the
# Sequential API. Copy and customize for your specific dataset and problem.
#
# This template demonstrates:
# - Data loading and preprocessing
# - Train/validation/test splits
# - Model definition with Sequential API
# - Training with callbacks
# - Evaluation and prediction
# =============================================================================

library(keras3)

# =============================================================================
# 1. DATA LOADING AND PREPROCESSING
# =============================================================================

# TODO: Load your data here
# Example for built-in dataset (replace with your data):
# c(c(x_train, y_train), c(x_test, y_test)) %<-% dataset_mnist()

# For CSV data:
# library(readr)
# data <- read_csv("your_data.csv")
# x <- as.matrix(data[, -which(names(data) == "target")])
# y <- data$target

# TODO: Replace with your actual data loading
cat("Loading data...\n")
# Load your features (x) and labels (y) here
# x <- ...  # Feature matrix
# y <- ...  # Target labels

# =============================================================================
# 2. DATA SPLITTING
# =============================================================================

# TODO: Adjust split ratios as needed (currently 70/15/15)
set.seed(42)
n <- nrow(x)
train_size <- floor(0.70 * n)
val_size <- floor(0.15 * n)

indices <- sample(n)
train_idx <- indices[1:train_size]
val_idx <- indices[(train_size + 1):(train_size + val_size)]
test_idx <- indices[(train_size + val_size + 1):n]

x_train <- x[train_idx, ]
y_train <- y[train_idx]
x_val <- x[val_idx, ]
y_val <- y[val_idx]
x_test <- x[test_idx, ]
y_test <- y[test_idx]

# =============================================================================
# 3. DATA NORMALIZATION
# =============================================================================

# TODO: Choose normalization strategy appropriate for your data

# Option 1: Min-Max scaling (0-1 range)
# x_min <- min(x_train)
# x_max <- max(x_train)
# x_train <- (x_train - x_min) / (x_max - x_min)
# x_val <- (x_val - x_min) / (x_max - x_min)
# x_test <- (x_test - x_min) / (x_max - x_min)

# Option 2: Standardization (mean=0, sd=1)
x_mean <- mean(x_train)
x_sd <- sd(x_train)
x_train <- (x_train - x_mean) / x_sd
x_val <- (x_val - x_mean) / x_sd
x_test <- (x_test - x_mean) / x_sd

# Convert labels to appropriate format
# For binary classification (0/1):
# y_train <- as.numeric(y_train)
# y_val <- as.numeric(y_val)
# y_test <- as.numeric(y_test)

# For multi-class classification, use to_categorical:
# num_classes <- length(unique(y))
# y_train <- to_categorical(y_train, num_classes)
# y_val <- to_categorical(y_val, num_classes)
# y_test <- to_categorical(y_test, num_classes)

cat("Data preprocessing complete.\n")
cat("Training samples:", nrow(x_train), "\n")
cat("Validation samples:", nrow(x_val), "\n")
cat("Test samples:", nrow(x_test), "\n")

# =============================================================================
# 4. MODEL ARCHITECTURE
# =============================================================================

# TODO: Customize architecture for your problem
# - Adjust input_shape to match your feature dimensions
# - Modify hidden layer sizes and number of layers
# - Change final layer units to match number of classes
# - Adjust dropout rates (0.2-0.5 typically)

input_dim <- ncol(x_train)
# TODO: Set num_classes based on your problem
# num_classes <- 10  # For multi-class
# num_classes <- 1   # For binary classification

model <- keras_model_sequential(input_shape = c(input_dim)) %>%
  # First hidden layer
  layer_dense(units = 128, activation = "relu") %>%
  layer_dropout(rate = 0.3) %>%

  # Second hidden layer
  layer_dense(units = 64, activation = "relu") %>%
  layer_dropout(rate = 0.3) %>%

  # Output layer
  # TODO: Adjust based on your problem:
  # - Binary: units = 1, activation = "sigmoid"
  # - Multi-class: units = num_classes, activation = "softmax"
  layer_dense(units = num_classes, activation = "softmax")

# View model architecture
summary(model)

# =============================================================================
# 5. MODEL COMPILATION
# =============================================================================

# TODO: Choose appropriate loss and optimizer for your problem

# For binary classification:
# loss <- "binary_crossentropy"
# metrics <- list("accuracy")

# For multi-class classification:
loss <- "categorical_crossentropy"
metrics <- list("accuracy")

# For regression:
# loss <- "mse"  # or "mae"
# metrics <- list("mae")

model %>% compile(
  optimizer = optimizer_adam(learning_rate = 0.001),  # TODO: Tune learning rate
  loss = loss,
  metrics = metrics
)

# =============================================================================
# 6. CALLBACKS
# =============================================================================

# TODO: Customize callbacks as needed

# Early stopping: stop training when validation loss stops improving
early_stop <- callback_early_stopping(
  monitor = "val_loss",
  patience = 10,
  restore_best_weights = TRUE
)

# Model checkpoint: save best model
checkpoint <- callback_model_checkpoint(
  filepath = "best_model.keras",
  monitor = "val_loss",
  save_best_only = TRUE,
  verbose = 1
)

# Learning rate reduction: reduce LR when loss plateaus
reduce_lr <- callback_reduce_lr_on_plateau(
  monitor = "val_loss",
  factor = 0.5,
  patience = 5,
  min_lr = 1e-7,
  verbose = 1
)

# =============================================================================
# 7. MODEL TRAINING
# =============================================================================

# TODO: Adjust hyperparameters
# - epochs: Start with 50-100, adjust based on convergence
# - batch_size: Typical values: 32, 64, 128, 256
# - validation_split: Alternative to validation_data

cat("Starting training...\n")

history <- model %>% fit(
  x = x_train,
  y = y_train,
  epochs = 100,              # TODO: Adjust based on your dataset size
  batch_size = 32,           # TODO: Tune for your hardware/data
  validation_data = list(x_val, y_val),
  callbacks = list(early_stop, checkpoint, reduce_lr),
  verbose = 1
)

# Plot training history
plot(history)

# =============================================================================
# 8. MODEL EVALUATION
# =============================================================================

cat("\nEvaluating model on test set...\n")

# Evaluate on test data
test_metrics <- model %>% evaluate(x_test, y_test, verbose = 0)
cat("Test loss:", test_metrics[1], "\n")
cat("Test accuracy:", test_metrics[2], "\n")

# =============================================================================
# 9. PREDICTIONS
# =============================================================================

# Make predictions on test set
predictions <- model %>% predict(x_test)

# For multi-class classification, get predicted class:
# predicted_classes <- apply(predictions, 1, which.max) - 1
# actual_classes <- apply(y_test, 1, which.max) - 1

# For binary classification:
# predicted_classes <- ifelse(predictions > 0.5, 1, 0)
# actual_classes <- y_test

# =============================================================================
# 10. MODEL SAVING
# =============================================================================

# Save the final model
model %>% save_model_tf("final_model")
cat("Model saved to 'final_model' directory\n")

# Save in Keras format
model %>% save_model_keras("final_model.keras")
cat("Model saved to 'final_model.keras'\n")

# To load later:
# loaded_model <- load_model_keras("final_model.keras")
# predictions <- loaded_model %>% predict(new_data)

# =============================================================================
# BEST PRACTICES & TIPS
# =============================================================================
#
# 1. BATCH SIZE:
#    - Smaller (32-64): Better generalization, slower training
#    - Larger (128-256): Faster training, may overfit
#    - Adjust based on GPU memory and dataset size
#
# 2. EPOCHS:
#    - Use early stopping to avoid manual tuning
#    - Monitor validation loss to detect overfitting
#    - Start with 50-100 and adjust
#
# 3. LEARNING RATE:
#    - Default Adam LR (0.001) works well for most cases
#    - Use ReduceLROnPlateau for automatic adjustment
#    - For fine-tuning: try 0.0001
#
# 4. ARCHITECTURE:
#    - Start simple (1-2 hidden layers)
#    - Add complexity only if needed
#    - More layers for complex patterns
#    - Dropout prevents overfitting (0.2-0.5)
#
# 5. OVERFITTING SIGNS:
#    - Training accuracy >> Validation accuracy
#    - Solutions: More dropout, L2 regularization, more data
#
# 6. UNDERFITTING SIGNS:
#    - Low training accuracy
#    - Solutions: Bigger model, more epochs, less regularization
#
# =============================================================================
