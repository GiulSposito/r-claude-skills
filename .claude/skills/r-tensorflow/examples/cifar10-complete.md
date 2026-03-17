# Complete Example: CIFAR-10 Image Classification

End-to-end example of building, training, and deploying a CNN for CIFAR-10 using TensorFlow for R with keras3.

## Overview

This example demonstrates:
- Data loading and preprocessing
- CNN architecture definition
- Training with callbacks
- Model evaluation
- Model saving and deployment
- Prediction on new images

---

## Complete Code

```r
library(tensorflow)
library(keras3)

# ============================================================================
# 1. DATA LOADING AND PREPROCESSING
# ============================================================================

# Load CIFAR-10 dataset
c(c(x_train, y_train), c(x_test, y_test)) %<-% dataset_cifar10()

# Class names
class_names <- c("airplane", "automobile", "bird", "cat", "deer",
                 "dog", "frog", "horse", "ship", "truck")

cat("Training samples:", nrow(x_train), "\n")
cat("Test samples:", nrow(x_test), "\n")
cat("Image shape:", dim(x_train)[2:4], "\n")

# Normalize pixel values to [0, 1]
x_train <- x_train / 255
x_test <- x_test / 255

# Verify labels
cat("Label range:", range(y_train), "\n")  # Should be 0-9

# ============================================================================
# 2. DATA AUGMENTATION (Optional)
# ============================================================================

# Define augmentation layers
data_augmentation <- keras_model_sequential() |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.1) |>
  layer_random_zoom(0.1)

# ============================================================================
# 3. MODEL ARCHITECTURE
# ============================================================================

# Define CNN model
model <- keras_model_sequential(input_shape = c(32, 32, 3)) |>

  # Data augmentation (only active during training)
  data_augmentation |>

  # Block 1
  layer_conv_2d(32, 3, padding = "same", activation = "relu") |>
  layer_batch_normalization() |>
  layer_conv_2d(32, 3, padding = "same", activation = "relu") |>
  layer_batch_normalization() |>
  layer_max_pooling_2d(pool_size = 2) |>
  layer_dropout(0.2) |>

  # Block 2
  layer_conv_2d(64, 3, padding = "same", activation = "relu") |>
  layer_batch_normalization() |>
  layer_conv_2d(64, 3, padding = "same", activation = "relu") |>
  layer_batch_normalization() |>
  layer_max_pooling_2d(pool_size = 2) |>
  layer_dropout(0.3) |>

  # Block 3
  layer_conv_2d(128, 3, padding = "same", activation = "relu") |>
  layer_batch_normalization() |>
  layer_conv_2d(128, 3, padding = "same", activation = "relu") |>
  layer_batch_normalization() |>
  layer_max_pooling_2d(pool_size = 2) |>
  layer_dropout(0.4) |>

  # Classification head
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_batch_normalization() |>
  layer_dropout(0.5) |>
  layer_dense(10, activation = "softmax")

# Print model summary
summary(model)

# ============================================================================
# 4. COMPILE MODEL
# ============================================================================

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c("accuracy")
)

# ============================================================================
# 5. CALLBACKS
# ============================================================================

callbacks <- list(
  # Early stopping
  callback_early_stopping(
    monitor = "val_loss",
    patience = 10,
    restore_best_weights = TRUE
  ),

  # Model checkpoint
  callback_model_checkpoint(
    filepath = "models/cifar10_best.keras",
    monitor = "val_accuracy",
    save_best_only = TRUE,
    verbose = 1
  ),

  # Learning rate reduction
  callback_reduce_lr_on_plateau(
    monitor = "val_loss",
    factor = 0.5,
    patience = 5,
    min_lr = 1e-7,
    verbose = 1
  ),

  # CSV logger
  callback_csv_logger("training_log.csv")
)

# ============================================================================
# 6. TRAINING
# ============================================================================

cat("\n=== Training Started ===\n\n")

history <- model |> fit(
  x_train, y_train,
  epochs = 100,
  batch_size = 128,
  validation_split = 0.2,
  callbacks = callbacks,
  verbose = 2
)

cat("\n=== Training Completed ===\n")

# ============================================================================
# 7. PLOT TRAINING HISTORY
# ============================================================================

plot(history)

# Or manually
library(ggplot2)

history_df <- as.data.frame(history)

ggplot(history_df, aes(x = epoch)) +
  geom_line(aes(y = loss, color = "Training Loss")) +
  geom_line(aes(y = val_loss, color = "Validation Loss")) +
  labs(title = "Model Loss", y = "Loss", color = "Legend") +
  theme_minimal()

ggplot(history_df, aes(x = epoch)) +
  geom_line(aes(y = accuracy, color = "Training Accuracy")) +
  geom_line(aes(y = val_accuracy, color = "Validation Accuracy")) +
  labs(title = "Model Accuracy", y = "Accuracy", color = "Legend") +
  theme_minimal()

# ============================================================================
# 8. EVALUATION
# ============================================================================

cat("\n=== Evaluation on Test Set ===\n")

# Evaluate
results <- model |> evaluate(x_test, y_test, verbose = 0)

cat(sprintf("Test Loss: %.4f\n", results["loss"]))
cat(sprintf("Test Accuracy: %.4f\n", results["accuracy"]))

# Predictions
predictions <- model |> predict(x_test, verbose = 0)
predicted_classes <- apply(predictions, 1, which.max) - 1  # 0-indexed

# Confusion matrix
library(caret)
conf_matrix <- confusionMatrix(
  factor(predicted_classes, levels = 0:9),
  factor(y_test, levels = 0:9)
)

print(conf_matrix)

# Per-class accuracy
per_class_acc <- conf_matrix$byClass[, "Balanced Accuracy"]
names(per_class_acc) <- class_names
print(per_class_acc)

# ============================================================================
# 9. VISUALIZATION
# ============================================================================

# Function to plot predictions
plot_predictions <- function(images, true_labels, pred_labels, n = 25) {
  par(mfrow = c(5, 5), mar = c(1, 1, 2, 1))
  for (i in 1:min(n, length(true_labels))) {
    img <- images[i, , , ]
    true_class <- class_names[true_labels[i] + 1]
    pred_class <- class_names[pred_labels[i] + 1]

    # Color: green if correct, red if wrong
    color <- ifelse(true_labels[i] == pred_labels[i], "darkgreen", "red")

    # Plot image
    plot(as.raster(img), main = sprintf("True: %s\nPred: %s",
                                        true_class, pred_class),
         col.main = color, cex.main = 0.8)
  }
}

# Plot first 25 test samples
plot_predictions(x_test, y_test, predicted_classes, n = 25)

# ============================================================================
# 10. SAVE MODEL
# ============================================================================

# Save in Keras format
save_model(model, "models/cifar10_final.keras")

cat("\n=== Model saved to models/cifar10_final.keras ===\n")

# Save in SavedModel format (for deployment)
save_model(model, "saved_models/cifar10")

cat("=== Model saved to saved_models/cifar10 (SavedModel format) ===\n")

# ============================================================================
# 11. LOAD AND TEST MODEL
# ============================================================================

# Load model
loaded_model <- load_model("models/cifar10_final.keras")

# Verify loaded model
test_results <- loaded_model |> evaluate(x_test, y_test, verbose = 0)
cat(sprintf("\nLoaded model test accuracy: %.4f\n", test_results["accuracy"]))

# ============================================================================
# 12. PREDICT ON NEW IMAGES
# ============================================================================

# Function to predict single image
predict_image <- function(model, image, true_label = NULL) {
  # Preprocess
  img <- array_reshape(image, c(1, 32, 32, 3))

  # Predict
  predictions <- model |> predict(img, verbose = 0)
  predicted_class <- which.max(predictions) - 1
  confidence <- max(predictions)

  # Print result
  cat(sprintf("Predicted: %s (%.2f%% confidence)\n",
              class_names[predicted_class + 1],
              confidence * 100))

  if (!is.null(true_label)) {
    cat(sprintf("True label: %s\n", class_names[true_label + 1]))
    cat(sprintf("Correct: %s\n", predicted_class == true_label))
  }

  # Plot
  par(mfrow = c(1, 2))
  plot(as.raster(image), main = sprintf("Predicted: %s\n%.2f%% confidence",
                                        class_names[predicted_class + 1],
                                        confidence * 100))

  # Plot probability distribution
  barplot(predictions[1, ], names.arg = class_names, las = 2,
          main = "Class Probabilities", ylab = "Probability",
          col = ifelse(seq_along(predictions[1, ]) == predicted_class + 1,
                      "darkgreen", "lightblue"))
}

# Test on random image
idx <- sample(1:nrow(x_test), 1)
predict_image(model, x_test[idx, , , ], y_test[idx])

# ============================================================================
# 13. BATCH PREDICTION
# ============================================================================

# Predict on batch
batch_indices <- 1:100
batch_predictions <- model |> predict(x_test[batch_indices, , , ], verbose = 0)
batch_classes <- apply(batch_predictions, 1, which.max) - 1

# Accuracy on batch
batch_accuracy <- mean(batch_classes == y_test[batch_indices])
cat(sprintf("\nBatch accuracy: %.4f\n", batch_accuracy))

# ============================================================================
# 14. MODEL INFERENCE OPTIMIZATION
# ============================================================================

# For production, use tf_function for faster inference
predict_fn <- tf_function(function(x) {
  model(x, training = FALSE)
})

# Benchmark
library(tictoc)

tic("Standard prediction")
_ <- model |> predict(x_test[1:100, , , ], verbose = 0)
toc()

tic("tf_function prediction")
_ <- predict_fn(tf$constant(x_test[1:100, , , ]))
toc()

# ============================================================================
# 15. EXPORT TO SAVEDMODEL (TF Serving)
# ============================================================================

# Export with serving signature
export_savedmodel(
  model,
  export_dir_base = "serving_models",
  versioned = TRUE
)

cat("\n=== Model exported for TensorFlow Serving ===\n")

# View saved model
# view_savedmodel("serving_models/[timestamp]")

# ============================================================================
# 16. SUMMARY
# ============================================================================

cat("\n" , strrep("=", 60), "\n")
cat("CIFAR-10 Training Summary\n")
cat(strrep("=", 60), "\n")
cat(sprintf("Final training accuracy: %.4f\n",
            tail(history$metrics$accuracy, 1)))
cat(sprintf("Final validation accuracy: %.4f\n",
            tail(history$metrics$val_accuracy, 1)))
cat(sprintf("Test accuracy: %.4f\n", results["accuracy"]))
cat(sprintf("Total epochs: %d\n", length(history$metrics$accuracy)))
cat(sprintf("Best validation accuracy: %.4f (epoch %d)\n",
            max(history$metrics$val_accuracy),
            which.max(history$metrics$val_accuracy)))
cat(strrep("=", 60), "\n\n")
```

---

## Key Takeaways

### Architecture Decisions

1. **Data Augmentation**: Applied as first layers for automatic augmentation
2. **Batch Normalization**: After each conv layer for training stability
3. **Dropout**: Increasing rates (0.2 → 0.3 → 0.4 → 0.5) for regularization
4. **Conv Blocks**: 3 blocks with increasing filters (32 → 64 → 128)

### Training Strategy

1. **High epochs (100)** with early stopping to find optimal point
2. **Learning rate reduction** on plateau for fine-tuning
3. **Checkpoint saving** to preserve best model
4. **20% validation split** for monitoring

### Expected Results

- Training accuracy: ~95%
- Validation accuracy: ~85-88%
- Test accuracy: ~85-87%
- Training time: ~30-60 minutes on GPU, 2-4 hours on CPU

### Common Issues

**Overfitting** (val_acc << train_acc):
- Increase dropout rates
- Add more data augmentation
- Reduce model capacity

**Underfitting** (both low):
- Decrease dropout
- Add more layers or filters
- Train longer (increase patience)

**Training too slow**:
- Reduce batch size if GPU memory is not full
- Use mixed precision training
- Ensure GPU is being used: `tf$config$list_physical_devices("GPU")`

---

## Production Deployment

### Save for Serving

```r
# SavedModel format for TF Serving
save_model(model, "production/cifar10_v1")

# Test loaded model
model_prod <- load_model("production/cifar10_v1")
model_prod |> evaluate(x_test, y_test)
```

### Docker Deployment

```dockerfile
FROM tensorflow/serving:latest

COPY production/cifar10_v1 /models/cifar10/1

ENV MODEL_NAME=cifar10
```

### Inference API (Plumber)

```r
# api.R
library(plumber)
library(keras3)

model <- load_model("production/cifar10_v1")

#* @post /predict
function(req) {
  # Parse image from request
  img <- req$postBody  # Assume 32x32x3 array
  img <- array_reshape(img, c(1, 32, 32, 3))
  img <- img / 255

  # Predict
  predictions <- model |> predict(img)
  predicted_class <- which.max(predictions) - 1

  list(
    class = class_names[predicted_class + 1],
    confidence = max(predictions),
    probabilities = as.list(predictions[1, ])
  )
}
```

---

## Extending the Example

### Transfer Learning

```r
# Use pretrained base
base_model <- application_resnet50(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(32, 32, 3)
)

base_model$trainable <- FALSE

model <- keras_model_sequential() |>
  layer_input(shape = c(32, 32, 3)) |>
  layer_lambda(function(x) tf$image$resize(x, c(224L, 224L))) |>
  base_model |>
  layer_global_average_pooling_2d() |>
  layer_dense(10, activation = "softmax")
```

### Multi-GPU Training

```r
strategy <- tf$distribute$MirroredStrategy()

with(strategy$scope(), {
  model <- keras_model_sequential() |>
    # ... model definition

  model |> compile(...)
})

model |> fit(x_train, y_train, epochs = 50)
```

### Mixed Precision

```r
# Enable mixed precision
policy <- tf$keras$mixed_precision$Policy("mixed_float16")
tf$keras$mixed_precision$set_global_policy(policy)

# Model automatically uses FP16 where beneficial
model <- keras_model_sequential() |>
  layer_conv_2d(32, 3, activation = "relu") |>
  # ... rest of model
  layer_dense(10, activation = "softmax", dtype = "float32")  # Keep output FP32
```

---

## Resources

- CIFAR-10 dataset: https://www.cs.toronto.edu/~kriz/cifar.html
- keras3 documentation: https://keras3.posit.co
- TensorFlow Serving: https://www.tensorflow.org/tfx/guide/serving
