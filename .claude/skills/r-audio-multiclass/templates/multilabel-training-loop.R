# Complete Multi-Label Audio Classification Training Loop
# End-to-end workflow with evaluation and model saving

library(torch)
library(luz)

source("audio-preprocessing-pipeline.R")  # Assumes preprocessing functions available


# ============================================================================
# 1. Dataset Definition
# ============================================================================

multilabel_audio_dataset <- dataset(
  name = "multilabel_audio_dataset",

  initialize = function(audio_files, labels_matrix, transform,
                       target_shape = c(128, 128), augment = FALSE) {
    self$audio_files <- audio_files
    self$labels <- torch_tensor(labels_matrix, dtype = torch_float())
    self$transform <- transform
    self$target_shape <- target_shape
    self$augment <- augment
  },

  .getitem = function(i) {
    melspec <- audio_to_melspec(
      self$audio_files[i],
      self$transform,
      self$target_shape
    )

    if (self$augment) {
      melspec <- augment_spectrogram(melspec)
    }

    list(x = melspec, y = self$labels[i, ])
  },

  .length = function() {
    length(self$audio_files)
  }
)


# ============================================================================
# 2. Model Definition
# ============================================================================

multilabel_cnn <- nn_module(
  "multilabel_cnn",

  initialize = function(n_mels = 128, n_classes = 50, dropout = 0.3) {
    self$conv_block1 <- nn_sequential(
      nn_conv2d(1, 32, kernel_size = 3, padding = 1),
      nn_batch_norm2d(32),
      nn_relu(),
      nn_max_pool2d(kernel_size = 2, stride = 2)
    )

    self$conv_block2 <- nn_sequential(
      nn_conv2d(32, 64, kernel_size = 3, padding = 1),
      nn_batch_norm2d(64),
      nn_relu(),
      nn_max_pool2d(kernel_size = 2, stride = 2)
    )

    self$conv_block3 <- nn_sequential(
      nn_conv2d(64, 128, kernel_size = 3, padding = 1),
      nn_batch_norm2d(128),
      nn_relu(),
      nn_max_pool2d(kernel_size = 2, stride = 2)
    )

    # Calculate flattened size: (n_mels // 8) * (n_mels // 8) * 128
    flattened_size <- (n_mels %/% 8) * (n_mels %/% 8) * 128

    self$classifier <- nn_sequential(
      nn_dropout(dropout),
      nn_linear(flattened_size, 256),
      nn_relu(),
      nn_dropout(dropout),
      nn_linear(256, n_classes)
    )
  },

  forward = function(x) {
    x <- self$conv_block1(x)
    x <- self$conv_block2(x)
    x <- self$conv_block3(x)
    x <- x$view(c(x$size(1), -1))
    logits <- self$classifier(x)
    logits
  }
)


# ============================================================================
# 3. Training Setup
# ============================================================================

#' Setup training with luz
#'
#' @param model Initialized model
#' @param train_dl Training dataloader
#' @param valid_dl Validation dataloader
#' @param pos_weights Class weights for imbalance (NULL = no weighting)
#' @param lr Learning rate
#' @param epochs Number of training epochs
#' @param device Device ("cuda" or "cpu")
#' @return Fitted model
train_multilabel_model <- function(model, train_dl, valid_dl,
                                  pos_weights = NULL,
                                  lr = 0.001, epochs = 50,
                                  device = "cpu") {
  # Loss function
  if (!is.null(pos_weights)) {
    loss_fn <- nn_bce_with_logits_loss(pos_weight = pos_weights$to(device = device))
  } else {
    loss_fn <- nn_bce_with_logits_loss()
  }

  # Optimizer
  optimizer <- optim_adam(model$parameters, lr = lr)

  # Learning rate scheduler
  scheduler <- lr_reduce_on_plateau(optimizer, mode = "min", patience = 5, factor = 0.5)

  # Setup luz
  fitted_model <- model %>%
    setup(
      loss = loss_fn,
      optimizer = optimizer,
      metrics = list(
        luz_metric_binary_accuracy_with_logits()
      )
    ) %>%
    set_hparams(n_classes = ncol(train_dl$dataset$labels)) %>%
    fit(
      train_dl,
      epochs = epochs,
      valid_data = valid_dl,
      callbacks = list(
        luz_callback_lr_scheduler(scheduler, call_on = "on_epoch_end"),
        luz_callback_early_stopping(monitor = "valid_loss", patience = 10, mode = "min"),
        luz_callback_model_checkpoint(path = "models/", monitor = "valid_loss", mode = "min")
      ),
      verbose = TRUE
    )

  fitted_model
}


# ============================================================================
# 4. Evaluation Metrics
# ============================================================================

#' Compute comprehensive multi-label metrics
#'
#' @param model Trained model
#' @param dataloader Evaluation dataloader
#' @param device Device
#' @param threshold Classification threshold
#' @return List of metrics
evaluate_model <- function(model, dataloader, device, threshold = 0.5) {
  model$eval()

  all_preds <- list()
  all_targets <- list()
  all_probs <- list()

  with_no_grad({
    coro::loop(for (batch in dataloader) {
      inputs <- batch$x$to(device = device)
      targets <- batch$y$to(device = device)

      logits <- model(inputs)
      probs <- torch_sigmoid(logits)

      all_preds <- c(all_preds, list((probs > threshold)$float()$cpu()))
      all_probs <- c(all_probs, list(probs$cpu()))
      all_targets <- c(all_targets, list(targets$cpu()))
    })
  })

  preds <- torch_cat(all_preds, dim = 1)
  probs <- torch_cat(all_probs, dim = 1)
  targets <- torch_cat(all_targets, dim = 1)

  # Compute metrics
  list(
    hamming_loss = compute_hamming_loss(preds, targets),
    exact_match = compute_exact_match(preds, targets),
    per_class_f1 = compute_per_class_f1(preds, targets),
    mean_f1 = mean(compute_per_class_f1(preds, targets), na.rm = TRUE),
    map = compute_map(probs, targets)
  )
}


#' Hamming loss (fraction of incorrect labels)
compute_hamming_loss <- function(preds, targets) {
  (preds != targets)$float()$mean()$item()
}


#' Exact match ratio (fraction of perfectly predicted samples)
compute_exact_match <- function(preds, targets) {
  ((preds == targets)$all(dim = 2))$float()$mean()$item()
}


#' Per-class F1 scores
compute_per_class_f1 <- function(preds, targets) {
  n_classes <- preds$size(2)
  f1_scores <- numeric(n_classes)

  for (i in 1:n_classes) {
    tp <- (preds[, i] * targets[, i])$sum()$item()
    fp <- (preds[, i] * (1 - targets[, i]))$sum()$item()
    fn <- ((1 - preds[, i]) * targets[, i])$sum()$item()

    precision <- tp / (tp + fp + 1e-8)
    recall <- tp / (tp + fn + 1e-8)
    f1 <- 2 * (precision * recall) / (precision + recall + 1e-8)

    f1_scores[i] <- f1
  }

  f1_scores
}


#' Mean Average Precision (mAP)
compute_map <- function(probs, targets) {
  n_classes <- probs$size(2)
  ap_scores <- numeric(n_classes)

  for (i in 1:n_classes) {
    class_probs <- as.numeric(probs[, i]$cpu())
    class_targets <- as.numeric(targets[, i]$cpu())

    if (sum(class_targets) == 0) {
      ap_scores[i] <- NA
      next
    }

    ord <- order(class_probs, decreasing = TRUE)
    sorted_targets <- class_targets[ord]

    tp_cumsum <- cumsum(sorted_targets)
    precisions <- tp_cumsum / seq_along(sorted_targets)
    ap <- sum(precisions * sorted_targets) / sum(sorted_targets)

    ap_scores[i] <- ap
  }

  mean(ap_scores, na.rm = TRUE)
}


# ============================================================================
# 5. Complete Workflow Example
# ============================================================================

run_training_workflow <- function(data_dir, labels_csv, n_classes = 50) {
  # 1. Load annotations
  annotations <- read.csv(labels_csv)
  species_list <- colnames(annotations)[-1]  # Exclude file_path column

  # 2. Split data
  set.seed(42)
  n_samples <- nrow(annotations)
  train_idx <- sample(1:n_samples, size = floor(0.7 * n_samples))
  valid_idx <- sample(setdiff(1:n_samples, train_idx), size = floor(0.15 * n_samples))
  test_idx <- setdiff(1:n_samples, c(train_idx, valid_idx))

  train_files <- file.path(data_dir, annotations$file_path[train_idx])
  valid_files <- file.path(data_dir, annotations$file_path[valid_idx])
  test_files <- file.path(data_dir, annotations$file_path[test_idx])

  train_labels <- as.matrix(annotations[train_idx, -1])
  valid_labels <- as.matrix(annotations[valid_idx, -1])
  test_labels <- as.matrix(annotations[test_idx, -1])

  # 3. Create transform
  melspec_transform <- create_melspec_transform(
    sample_rate = 22050,
    n_fft = 2048,
    hop_length = 512,
    n_mels = 128
  )

  # 4. Create datasets and dataloaders
  train_ds <- multilabel_audio_dataset(
    train_files, train_labels, melspec_transform,
    target_shape = c(128, 128), augment = TRUE
  )
  valid_ds <- multilabel_audio_dataset(
    valid_files, valid_labels, melspec_transform,
    target_shape = c(128, 128), augment = FALSE
  )
  test_ds <- multilabel_audio_dataset(
    test_files, test_labels, melspec_transform,
    target_shape = c(128, 128), augment = FALSE
  )

  train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE, num_workers = 0)
  valid_dl <- dataloader(valid_ds, batch_size = 32, shuffle = FALSE, num_workers = 0)
  test_dl <- dataloader(test_ds, batch_size = 32, shuffle = FALSE, num_workers = 0)

  # 5. Compute class weights
  pos_weights <- torch_tensor(colSums(1 - train_labels) / (colSums(train_labels) + 1e-8))

  # 6. Initialize model
  device <- if (cuda_is_available()) "cuda" else "cpu"
  model <- multilabel_cnn(n_mels = 128, n_classes = n_classes, dropout = 0.3)
  model$to(device = device)

  # 7. Train
  cat("Starting training...\n")
  fitted_model <- train_multilabel_model(
    model, train_dl, valid_dl,
    pos_weights = pos_weights,
    lr = 0.001, epochs = 50, device = device
  )

  # 8. Evaluate on test set
  cat("\nEvaluating on test set...\n")
  test_metrics <- evaluate_model(fitted_model, test_dl, device, threshold = 0.5)

  cat(sprintf("\nTest Metrics:\n"))
  cat(sprintf("  Hamming Loss: %.4f\n", test_metrics$hamming_loss))
  cat(sprintf("  Exact Match: %.4f\n", test_metrics$exact_match))
  cat(sprintf("  Mean F1: %.4f\n", test_metrics$mean_f1))
  cat(sprintf("  mAP: %.4f\n", test_metrics$map))

  # 9. Save model and metadata
  torch_save(fitted_model$model, "models/final_model.pt")
  saveRDS(list(
    species_list = species_list,
    test_metrics = test_metrics,
    per_class_f1 = test_metrics$per_class_f1
  ), "models/model_metadata.rds")

  cat("\nTraining complete. Model saved to models/final_model.pt\n")

  list(model = fitted_model, metrics = test_metrics)
}


# ============================================================================
# Usage Example
# ============================================================================

# # Run full workflow
# results <- run_training_workflow(
#   data_dir = "data/audio",
#   labels_csv = "data/labels.csv",
#   n_classes = 50
# )
#
# # Inspect per-class F1
# metadata <- readRDS("models/model_metadata.rds")
# df <- data.frame(
#   species = metadata$species_list,
#   f1_score = metadata$per_class_f1
# )
# df <- df[order(df$f1_score, decreasing = TRUE), ]
# print(df)
