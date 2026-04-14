# Computer Vision Example

Image classification using transfer learning with pretrained models in torch/keras3.

## Overview

**Use Case**: Classify images into categories using transfer learning

**Key Components**:
- Transfer learning with pretrained ResNet/EfficientNet
- Two-phase training (frozen backbone then fine-tuning)
- Data augmentation for images
- Mixed precision training
- Model evaluation and inference

---

## 1. Setup and Data

```r
library(torch)
library(torchvision)
library(luz)
library(dplyr)

# Prepare image metadata
metadata <- data.frame(
  filename = list.files("data/images", pattern = "\\.(jpg|png)$"),
  class_name = c("cat", "dog", "cat", "dog", ...)
)

# Encode labels
metadata <- metadata |>
  mutate(class_id = as.integer(factor(class_name)) - 1L)

# Split data
set.seed(42)
train_idx <- sample(nrow(metadata), nrow(metadata) * 0.7)
val_idx <- sample(setdiff(seq_len(nrow(metadata)), train_idx),
                  nrow(metadata) * 0.15)
test_idx <- setdiff(seq_len(nrow(metadata)), c(train_idx, val_idx))

train_meta <- metadata[train_idx, ]
val_meta <- metadata[val_idx, ]
test_meta <- metadata[test_idx, ]

n_classes <- length(unique(metadata$class_name))
```

---

## 2. Image Dataset with Augmentation

```r
library(magick)

# Image classification dataset
image_dataset <- dataset(
  name = "ImageDataset",

  initialize = function(metadata_df, image_dir,
                       img_size = c(224, 224),
                       augment = FALSE) {
    self$metadata <- metadata_df
    self$image_dir <- image_dir
    self$img_size <- img_size
    self$augment <- augment

    # ImageNet normalization (for pretrained models)
    self$mean <- c(0.485, 0.456, 0.406)
    self$std <- c(0.229, 0.224, 0.225)
  },

  .getitem = function(index) {
    row <- self$metadata[index, ]
    img_path <- file.path(self$image_dir, row$filename)

    # Load image
    img <- magick::image_read(img_path)

    # Data augmentation (training only)
    if (self$augment) {
      # Random horizontal flip
      if (runif(1) > 0.5) {
        img <- magick::image_flop(img)
      }

      # Random rotation (-15 to 15 degrees)
      angle <- runif(1, -15, 15)
      img <- magick::image_rotate(img, angle)

      # Random crop and resize
      crop_scale <- runif(1, 0.8, 1.0)
      crop_w <- as.integer(magick::image_info(img)$width * crop_scale)
      crop_h <- as.integer(magick::image_info(img)$height * crop_scale)
      img <- magick::image_crop(img,
                               geometry = sprintf("%dx%d", crop_w, crop_h),
                               gravity = "center")

      # Random brightness
      brightness <- runif(1, 0.8, 1.2)
      img <- magick::image_modulate(img, brightness = brightness * 100)
    }

    # Resize
    img <- magick::image_resize(img,
                               sprintf("%dx%d!", self$img_size[1], self$img_size[2]))

    # Convert to array: (H, W, C)
    img_array <- as.integer(magick::image_data(img, channels = "rgb"))
    img_array <- aperm(img_array, c(2, 3, 1))  # (C, H, W) -> (H, W, C)

    # Normalize to [0, 1]
    img_array <- img_array / 255.0

    # Convert to tensor: (C, H, W)
    img_tensor <- torch_tensor(img_array)$permute(c(3, 1, 2))

    # Normalize with ImageNet stats
    for (c in 1:3) {
      img_tensor[c, , ] <- (img_tensor[c, , ] - self$mean[c]) / self$std[c]
    }

    # Get label
    label <- torch_tensor(row$class_id, dtype = torch_long())

    return(list(x = img_tensor, y = label))
  },

  .length = function() {
    nrow(self$metadata)
  }
)

# Create datasets
train_ds <- image_dataset(train_meta, "data/images", augment = TRUE)
val_ds <- image_dataset(val_meta, "data/images", augment = FALSE)
test_ds <- image_dataset(test_meta, "data/images", augment = FALSE)

# Create dataloaders
train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE)
val_dl <- dataloader(val_ds, batch_size = 32, shuffle = FALSE)
test_dl <- dataloader(test_ds, batch_size = 32, shuffle = FALSE)

# Verify
batch <- train_dl$.iter()$.next()
cat("Image shape:", batch$x$shape, "\n")  # [32, 3, 224, 224]
cat("Label shape:", batch$y$shape, "\n")  # [32]
```

---

## 3. Transfer Learning with ResNet

```r
# Load pretrained ResNet18
pretrained_model <- model_resnet18(pretrained = TRUE)

# Transfer learning model
transfer_model <- nn_module(
  "TransferModel",

  initialize = function(n_classes, pretrained_backbone, freeze_backbone = TRUE) {
    # Use pretrained backbone (feature extractor)
    self$backbone <- pretrained_backbone

    # Freeze backbone weights initially
    if (freeze_backbone) {
      for (param in self$backbone$parameters) {
        param$requires_grad_(FALSE)
      }
    }

    # Get output features from backbone
    # ResNet18/34: 512 features
    # ResNet50/101/152: 2048 features
    n_features <- 512

    # Replace classifier head
    self$classifier <- nn_sequential(
      nn_dropout(0.5),
      nn_linear(n_features, 256),
      nn_relu(),
      nn_dropout(0.3),
      nn_linear(256, n_classes)
    )
  },

  forward = function(x) {
    # Extract features
    features <- self$backbone(x)

    # Classify
    output <- self$classifier(features)

    return(output)
  },

  # Method to unfreeze backbone for fine-tuning
  unfreeze_backbone = function() {
    for (param in self$backbone$parameters) {
      param$requires_grad_(TRUE)
    }
  }
)

# Create model
model <- transfer_model(
  n_classes = n_classes,
  pretrained_backbone = pretrained_model,
  freeze_backbone = TRUE
)

cat("Model created with frozen backbone\n")
```

---

## 4. Two-Phase Training

### Phase 1: Train Only Classifier Head

```r
# Phase 1: Train classifier with frozen backbone
fitted_phase1 <- model |>
  setup(
    loss = nn_cross_entropy_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_accuracy(),
      luz_metric_recall(),
      luz_metric_precision()
    )
  ) |>

  set_hparams(
    n_classes = n_classes,
    pretrained_backbone = pretrained_model,
    freeze_backbone = TRUE
  ) |>

  set_opt_hparams(
    lr = 0.001,  # Higher LR for new layers
    weight_decay = 1e-4
  ) |>

  fit(
    train_dl,
    epochs = 10,
    valid_data = val_dl,

    callbacks = list(
      luz_callback_early_stopping(
        monitor = "valid_loss",
        patience = 5
      ),

      luz_callback_model_checkpoint(
        path = "models/phase1/",
        monitor = "valid_loss",
        save_best_only = TRUE
      ),

      luz_callback_csv_logger("phase1_log.csv")
    ),

    verbose = TRUE
  )

cat("\nPhase 1 complete. Unfreezing backbone for fine-tuning...\n")
```

### Phase 2: Fine-tune Entire Model

```r
# Unfreeze backbone
fitted_phase1$model$unfreeze_backbone()

# Phase 2: Fine-tune entire model with lower learning rate
fitted_phase2 <- fitted_phase1 |>
  set_opt_hparams(
    lr = 1e-5,  # Much lower LR for fine-tuning
    weight_decay = 1e-4
  ) |>

  fit(
    train_dl,
    epochs = 20,
    valid_data = val_dl,

    callbacks = list(
      luz_callback_early_stopping(
        monitor = "valid_loss",
        patience = 10
      ),

      luz_callback_lr_scheduler(
        lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 3
      ),

      luz_callback_model_checkpoint(
        path = "models/phase2/",
        monitor = "valid_loss",
        save_best_only = TRUE
      ),

      luz_callback_csv_logger("phase2_log.csv")
    ),

    verbose = TRUE
  )

# Save final model
luz_save(fitted_phase2, "image_classifier_final.pt")

cat("\nTraining complete!\n")
```

---

## 5. Evaluation

```r
# Evaluate on test set
evaluate_image_model <- function(model, test_dl) {
  model$eval()

  all_preds <- list()
  all_labels <- list()

  with_no_grad({
    coro::loop(for (batch in test_dl) {
      logits <- model(batch$x)
      preds <- torch_argmax(logits, dim = 2)

      all_preds[[length(all_preds) + 1]] <- as.integer(preds$cpu())
      all_labels[[length(all_labels) + 1]] <- as.integer(batch$y$cpu())
    })
  })

  predictions <- unlist(all_preds)
  labels <- unlist(all_labels)

  # Metrics
  results <- tibble(
    truth = factor(labels),
    estimate = factor(predictions)
  )

  overall_metrics <- results |>
    metrics(truth, estimate)

  conf_mat <- results |>
    conf_mat(truth, estimate)

  per_class <- results |>
    group_by(truth) |>
    summarise(
      n = n(),
      accuracy = mean(truth == estimate),
      .groups = "drop"
    )

  return(list(
    overall = overall_metrics,
    confusion_matrix = conf_mat,
    per_class = per_class
  ))
}

eval_results <- evaluate_image_model(fitted_phase2$model, test_dl)

print("Overall Metrics:")
print(eval_results$overall)

print("\nPer-Class Accuracy:")
print(eval_results$per_class)

# Plot confusion matrix
library(ggplot2)
autoplot(eval_results$confusion_matrix, type = "heatmap") +
  theme_minimal()
```

---

## 6. Inference on New Images

```r
# Predict single image
predict_image <- function(model, img_path, class_names) {
  model$eval()

  # Preprocess
  img <- magick::image_read(img_path)
  img <- magick::image_resize(img, "224x224!")

  img_array <- as.integer(magick::image_data(img, channels = "rgb"))
  img_array <- aperm(img_array, c(2, 3, 1))
  img_array <- img_array / 255.0

  img_tensor <- torch_tensor(img_array)$permute(c(3, 1, 2))

  # Normalize
  mean <- c(0.485, 0.456, 0.406)
  std <- c(0.229, 0.224, 0.225)
  for (c in 1:3) {
    img_tensor[c, , ] <- (img_tensor[c, , ] - mean[c]) / std[c]
  }

  # Add batch dimension
  img_tensor <- img_tensor$unsqueeze(1)

  # Predict
  with_no_grad({
    logits <- model(img_tensor)
    probs <- nnf_softmax(logits, dim = 2)
  })

  probs_vec <- as.numeric(probs$cpu())
  names(probs_vec) <- class_names

  predicted_class <- class_names[which.max(probs_vec)]
  confidence <- max(probs_vec)

  return(list(
    predicted_class = predicted_class,
    confidence = confidence,
    all_probabilities = probs_vec
  ))
}

# Usage
class_names <- sort(unique(metadata$class_name))
result <- predict_image(
  model = fitted_phase2$model,
  img_path = "new_image.jpg",
  class_names = class_names
)

cat("Predicted class:", result$predicted_class, "\n")
cat("Confidence:", sprintf("%.2f%%", result$confidence * 100), "\n")
```

---

## 7. Alternative: Using Keras3

```r
library(keras3)

# Load pretrained ResNet50
base_model <- application_resnet50(
  weights = "imagenet",
  include_top = FALSE,  # Remove classifier
  input_shape = c(224, 224, 3)
)

# Freeze base model
freeze_weights(base_model)

# Build model
model <- keras_model_sequential() |>
  base_model |>
  layer_global_average_pooling_2d() |>
  layer_dropout(0.5) |>
  layer_dense(256, activation = "relu") |>
  layer_dropout(0.3) |>
  layer_dense(n_classes, activation = "softmax")

# Compile
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "sparse_categorical_crossentropy",
  metrics = c("accuracy")
)

# Train phase 1
history1 <- model |> fit(
  train_dl,
  epochs = 10,
  validation_data = val_dl,
  callbacks = list(
    callback_early_stopping(patience = 5),
    callback_reduce_lr_on_plateau(patience = 3)
  )
)

# Unfreeze and fine-tune
unfreeze_weights(base_model)

model |> compile(
  optimizer = optimizer_adam(learning_rate = 1e-5),
  loss = "sparse_categorical_crossentropy",
  metrics = c("accuracy")
)

history2 <- model |> fit(
  train_dl,
  epochs = 20,
  validation_data = val_dl,
  callbacks = list(
    callback_early_stopping(patience = 10),
    callback_reduce_lr_on_plateau(patience = 3)
  )
)

# Save
save_model_tf(model, "image_classifier_keras.keras")
```

---

## Best Practices

### Transfer Learning
- Use ImageNet-pretrained models as starting point
- Freeze backbone initially, train only classifier head
- Fine-tune entire model with much lower learning rate (10-100x smaller)
- Use same normalization as pretrained model (ImageNet stats)

### Data Augmentation
- Horizontal flip, rotation, crop, brightness for images
- Test-time augmentation: average predictions over multiple augmented versions

### Model Selection
- ResNet18/34: Fast, good for simple tasks
- ResNet50/101: More powerful, needs more data
- EfficientNet: Best accuracy/efficiency trade-off
- Vision Transformer (ViT): State-of-art but needs large datasets

### Training
- Batch size 32-64 typical for images
- Use mixed precision training to fit larger batches
- Learning rate: 1e-3 for new layers, 1e-5 for fine-tuning

---

## References

See also:
- [references/architectures.md](../references/architectures.md) - CNN architectures
- [templates/training-recipes.R](../templates/training-recipes.R) - Training patterns
