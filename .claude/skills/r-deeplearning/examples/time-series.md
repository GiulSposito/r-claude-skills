# Time Series Forecasting Example

Time series forecasting using GRU and 1D CNN in torch.

## Overview

**Use Case**: Forecast future values from historical time series data

**Key Components**:
- Time series windowing and preprocessing
- GRU for sequence modeling
- 1D CNN for pattern detection
- Multi-step forecasting
- Walk-forward validation

---

## 1. Setup and Data

```r
library(torch)
library(luz)
library(dplyr)

# Example: Monthly sales data
ts_data <- data.frame(
  date = seq.Date(as.Date("2020-01-01"), by = "month", length.out = 100),
  value = rnorm(100, mean = 100, sd = 10) + seq(1, 100, length.out = 100)
)

# Normalize data (important for neural networks)
normalize_data <- function(x, min_val = NULL, max_val = NULL) {
  if (is.null(min_val)) {
    min_val <- min(x)
    max_val <- max(x)
  }

  normalized <- (x - min_val) / (max_val - min_val + 1e-8)

  return(list(
    data = normalized,
    min = min_val,
    max = max_val
  ))
}

# Inverse normalization
denormalize_data <- function(x, min_val, max_val) {
  return(x * (max_val - min_val) + min_val)
}

# Normalize
norm_result <- normalize_data(ts_data$value)
ts_data$value_norm <- norm_result$data

# Split data (temporal split - no shuffling!)
train_size <- floor(nrow(ts_data) * 0.7)
val_size <- floor(nrow(ts_data) * 0.15)

train_df <- ts_data[1:train_size, ]
val_df <- ts_data[(train_size + 1):(train_size + val_size), ]
test_df <- ts_data[(train_size + val_size + 1):nrow(ts_data), ]

cat("Train:", nrow(train_df), "Val:", nrow(val_df), "Test:", nrow(test_df), "\n")
```

---

## 2. Time Series Dataset

```r
# Create sequences for supervised learning
create_sequences <- function(data, seq_length, forecast_horizon = 1) {
  sequences <- list()
  targets <- list()

  for (i in 1:(length(data) - seq_length - forecast_horizon + 1)) {
    seq <- data[i:(i + seq_length - 1)]
    target <- data[(i + seq_length):(i + seq_length + forecast_horizon - 1)]

    sequences[[length(sequences) + 1]] <- seq
    targets[[length(targets) + 1]] <- target
  }

  return(list(
    sequences = do.call(rbind, sequences),
    targets = do.call(rbind, targets)
  ))
}

# Time series dataset
timeseries_dataset <- dataset(
  name = "TimeSeriesDataset",

  initialize = function(data, seq_length = 20, forecast_horizon = 1) {
    # Create sequences
    seq_data <- create_sequences(data, seq_length, forecast_horizon)

    self$sequences <- seq_data$sequences
    self$targets <- seq_data$targets
    self$seq_length <- seq_length
    self$forecast_horizon <- forecast_horizon
  },

  .getitem = function(index) {
    # Get sequence and target
    seq <- torch_tensor(self$sequences[index, ])$unsqueeze(2)  # (seq_len, 1)
    target <- torch_tensor(self$targets[index, ])

    return(list(x = seq, y = target))
  },

  .length = function() {
    nrow(self$sequences)
  }
)

# Parameters
seq_length <- 20  # Look back 20 time steps
forecast_horizon <- 5  # Predict next 5 time steps

# Create datasets
train_ds <- timeseries_dataset(
  train_df$value_norm,
  seq_length = seq_length,
  forecast_horizon = forecast_horizon
)

val_ds <- timeseries_dataset(
  val_df$value_norm,
  seq_length = seq_length,
  forecast_horizon = forecast_horizon
)

test_ds <- timeseries_dataset(
  test_df$value_norm,
  seq_length = seq_length,
  forecast_horizon = forecast_horizon
)

# Create dataloaders
train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE)
val_dl <- dataloader(val_ds, batch_size = 32, shuffle = FALSE)
test_dl <- dataloader(test_ds, batch_size = 32, shuffle = FALSE)

# Verify
batch <- train_dl$.iter()$.next()
cat("Sequence shape:", batch$x$shape, "\n")  # [32, 20, 1]
cat("Target shape:", batch$y$shape, "\n")    # [32, 5]
```

---

## 3. GRU Forecaster

```r
# GRU model for time series forecasting
gru_forecaster <- nn_module(
  "GRUForecaster",

  initialize = function(input_dim = 1, hidden_dim = 128,
                       n_layers = 2, forecast_horizon = 5,
                       dropout = 0.3) {

    # GRU layers
    self$gru <- nn_gru(
      input_size = input_dim,
      hidden_size = hidden_dim,
      num_layers = n_layers,
      batch_first = TRUE,
      dropout = dropout
    )

    # Forecast head
    self$dropout <- nn_dropout(dropout)
    self$fc <- nn_linear(hidden_dim, forecast_horizon)
  },

  forward = function(x) {
    # x: (batch, seq_len, input_dim)

    # GRU: output (batch, seq_len, hidden_dim)
    gru_out <- self$gru(x)[[1]]

    # Take last hidden state
    last_hidden <- gru_out[, -1, ]  # (batch, hidden_dim)

    # Forecast
    out <- self$dropout(last_hidden)
    out <- self$fc(out)  # (batch, forecast_horizon)

    return(out)
  }
)

# Create model
model_gru <- gru_forecaster(
  input_dim = 1,
  hidden_dim = 128,
  n_layers = 2,
  forecast_horizon = forecast_horizon,
  dropout = 0.3
)

# Test
dummy_input <- torch_randn(4, seq_length, 1)
output <- model_gru(dummy_input)
cat("Output shape:", output$shape, "\n")  # [4, 5]
```

---

## 4. 1D CNN Forecaster

```r
# 1D CNN for time series
cnn_1d_forecaster <- nn_module(
  "CNN1DForecaster",

  initialize = function(input_dim = 1, forecast_horizon = 5) {

    # 1D Convolutional blocks
    self$conv1 <- nn_conv1d(input_dim, 64, kernel_size = 3, padding = "same")
    self$bn1 <- nn_batch_norm1d(64)
    self$pool1 <- nn_max_pool1d(2)

    self$conv2 <- nn_conv1d(64, 128, kernel_size = 3, padding = "same")
    self$bn2 <- nn_batch_norm1d(128)
    self$pool2 <- nn_max_pool1d(2)

    self$conv3 <- nn_conv1d(128, 256, kernel_size = 3, padding = "same")
    self$bn3 <- nn_batch_norm1d(256)

    # Global pooling and forecast
    self$gap <- nn_adaptive_avg_pool1d(1)
    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(256, forecast_horizon)
  },

  forward = function(x) {
    # x: (batch, seq_len, input_dim)
    # Conv1d expects: (batch, channels, seq_len)
    x <- x$permute(c(1, 3, 2))

    x <- x |>
      self$conv1() |>
      self$bn1() |>
      nnf_relu() |>
      self$pool1()

    x <- x |>
      self$conv2() |>
      self$bn2() |>
      nnf_relu() |>
      self$pool2()

    x <- x |>
      self$conv3() |>
      self$bn3() |>
      nnf_relu()

    # Global pooling
    x <- self$gap(x)  # (batch, 256, 1)
    x <- torch_flatten(x, start_dim = 2)  # (batch, 256)

    # Forecast
    x <- self$dropout(x)
    x <- self$fc(x)  # (batch, forecast_horizon)

    return(x)
  }
)
```

---

## 5. Hybrid CNN-GRU Model

```r
# Combine CNN for feature extraction and GRU for temporal modeling
cnn_gru_forecaster <- nn_module(
  "CNNGRUForecaster",

  initialize = function(input_dim = 1, hidden_dim = 128,
                       forecast_horizon = 5, dropout = 0.3) {

    # CNN feature extractor
    self$conv1 <- nn_conv1d(input_dim, 32, kernel_size = 3, padding = "same")
    self$bn1 <- nn_batch_norm1d(32)
    self$pool1 <- nn_max_pool1d(2)

    self$conv2 <- nn_conv1d(32, 64, kernel_size = 3, padding = "same")
    self$bn2 <- nn_batch_norm1d(64)
    self$pool2 <- nn_max_pool1d(2)

    # GRU for temporal modeling
    self$gru <- nn_gru(
      input_size = 64,
      hidden_size = hidden_dim,
      num_layers = 2,
      batch_first = TRUE,
      dropout = dropout
    )

    # Forecast head
    self$dropout <- nn_dropout(dropout)
    self$fc <- nn_linear(hidden_dim, forecast_horizon)
  },

  forward = function(x) {
    # x: (batch, seq_len, input_dim)

    # CNN expects (batch, channels, seq_len)
    x <- x$permute(c(1, 3, 2))

    x <- x |>
      self$conv1() |>
      self$bn1() |>
      nnf_relu() |>
      self$pool1()

    x <- x |>
      self$conv2() |>
      self$bn2() |>
      nnf_relu() |>
      self$pool2()

    # Back to (batch, seq_len, channels) for GRU
    x <- x$permute(c(1, 3, 2))

    # GRU
    gru_out <- self$gru(x)[[1]]
    last_hidden <- gru_out[, -1, ]

    # Forecast
    out <- self$dropout(last_hidden)
    out <- self$fc(out)

    return(out)
  }
)
```

---

## 6. Training

```r
# Train GRU model
fitted <- model_gru |>
  setup(
    loss = nn_mse_loss(),  # MSE for regression
    optimizer = optim_adam,
    metrics = list(
      luz_metric_mae()  # Mean Absolute Error
    )
  ) |>

  set_hparams(
    input_dim = 1,
    hidden_dim = 128,
    n_layers = 2,
    forecast_horizon = forecast_horizon,
    dropout = 0.3
  ) |>

  set_opt_hparams(
    lr = 0.001,
    weight_decay = 1e-5
  ) |>

  fit(
    train_dl,
    epochs = 100,
    valid_data = val_dl,

    callbacks = list(
      luz_callback_early_stopping(
        monitor = "valid_loss",
        patience = 15
      ),

      luz_callback_lr_scheduler(
        lr_reduce_on_plateau,
        mode = "min",
        factor = 0.5,
        patience = 5
      ),

      luz_callback_model_checkpoint(
        path = "models/",
        monitor = "valid_loss",
        save_best_only = TRUE
      ),

      luz_callback_csv_logger("ts_training.csv")
    ),

    verbose = TRUE
  )

# Save
luz_save(fitted, "ts_forecaster.pt")
```

---

## 7. Evaluation

```r
# Evaluate model
evaluate_forecaster <- function(model, test_dl, min_val, max_val) {
  model$eval()

  all_preds <- list()
  all_targets <- list()

  with_no_grad({
    coro::loop(for (batch in test_dl) {
      preds <- model(batch$x)

      all_preds[[length(all_preds) + 1]] <- as.matrix(preds$cpu())
      all_targets[[length(all_targets) + 1]] <- as.matrix(batch$y$cpu())
    })
  })

  predictions <- do.call(rbind, all_preds)
  targets <- do.call(rbind, all_targets)

  # Denormalize
  predictions <- denormalize_data(predictions, min_val, max_val)
  targets <- denormalize_data(targets, min_val, max_val)

  # Calculate metrics
  mae <- mean(abs(predictions - targets))
  rmse <- sqrt(mean((predictions - targets)^2))
  mape <- mean(abs((predictions - targets) / targets)) * 100

  return(list(
    mae = mae,
    rmse = rmse,
    mape = mape,
    predictions = predictions,
    targets = targets
  ))
}

# Run evaluation
eval_results <- evaluate_forecaster(
  fitted$model,
  test_dl,
  norm_result$min,
  norm_result$max
)

cat("MAE:", eval_results$mae, "\n")
cat("RMSE:", eval_results$rmse, "\n")
cat("MAPE:", eval_results$mape, "%\n")

# Plot predictions vs actual
library(ggplot2)

plot_data <- data.frame(
  step = rep(1:forecast_horizon, nrow(eval_results$predictions)),
  predicted = as.vector(t(eval_results$predictions)),
  actual = as.vector(t(eval_results$targets)),
  sequence = rep(1:nrow(eval_results$predictions), each = forecast_horizon)
)

# Plot first few sequences
ggplot(plot_data |> filter(sequence <= 5),
       aes(x = step)) +
  geom_line(aes(y = actual, color = "Actual")) +
  geom_line(aes(y = predicted, color = "Predicted"), linetype = "dashed") +
  facet_wrap(~sequence, scales = "free_y") +
  theme_minimal() +
  labs(
    title = "Time Series Forecasts",
    x = "Forecast Horizon",
    y = "Value",
    color = ""
  )
```

---

## 8. Multi-Step Forecasting

```r
# Iterative multi-step forecasting (autoregressive)
forecast_iterative <- function(model, initial_sequence, n_steps,
                              min_val, max_val) {
  model$eval()

  # Initial sequence (normalized)
  current_seq <- torch_tensor(initial_sequence)$unsqueeze(1)$unsqueeze(1)

  forecasts <- numeric(n_steps)

  with_no_grad({
    for (i in 1:n_steps) {
      # Predict next step
      pred <- model(current_seq)
      next_val <- as.numeric(pred$cpu())[1]  # Take first forecast

      forecasts[i] <- next_val

      # Update sequence: remove oldest, append new prediction
      current_seq <- torch_cat(
        list(current_seq[1, 2:current_seq$shape[2], 1],
             torch_tensor(next_val)),
        dim = 1
      )$unsqueeze(1)$unsqueeze(1)
    }
  })

  # Denormalize
  forecasts <- denormalize_data(forecasts, min_val, max_val)

  return(forecasts)
}

# Usage: Forecast 10 steps ahead
initial_seq <- tail(train_df$value_norm, seq_length)
future_forecast <- forecast_iterative(
  fitted$model,
  initial_seq,
  n_steps = 10,
  min_val = norm_result$min,
  max_val = norm_result$max
)

cat("10-step forecast:", future_forecast, "\n")
```

---

## Best Practices

### Data Preparation
- Always use temporal splits (no shuffling)
- Normalize data (min-max or z-score)
- Choose sequence length based on seasonality/patterns
- Test multiple forecast horizons

### Model Selection
- **GRU/LSTM**: Best for capturing long-term dependencies
- **1D CNN**: Good for detecting local patterns, faster than RNN
- **Hybrid CNN-GRU**: Combines both strengths
- **Attention**: Helpful for very long sequences

### Training
- Use MSE or MAE loss for regression
- Lower learning rates (1e-4 to 1e-3)
- Monitor validation loss carefully (early stopping essential)
- Avoid overfitting: dropout, weight decay, simpler models

### Evaluation
- Use walk-forward validation for realistic assessment
- Report multiple metrics (MAE, RMSE, MAPE)
- Visualize predictions vs actuals
- Test on multiple forecast horizons

### Advanced
- Try ensemble methods (average multiple models)
- Incorporate external variables (multivariate forecasting)
- Use attention mechanisms for interpretability
- Consider probabilistic forecasting (predict distributions)

---

## References

See also:
- [references/architectures.md](../references/architectures.md) - RNN and 1D CNN patterns
- [templates/training-recipes.R](../templates/training-recipes.R) - Training patterns
