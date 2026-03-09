# Complete Forecasting Workflow Template

Use this template for any time series forecasting task.

## Phase 1: Setup and Data Loading

```r
# Load required packages
library(fable)
library(tsibble)
library(feasts)
library(tidyverse)

# Load your data
raw_data <- read_csv("your_data.csv")

# Convert to tsibble
ts_data <- raw_data |>
  mutate(Month = yearmonth(date_column)) |>  # Adjust time function as needed
  as_tsibble(index = Month, key = group_var)  # Optional: add key for multiple series

# Check for gaps
scan_gaps(ts_data)

# Fill gaps if needed
ts_data <- ts_data |>
  fill_gaps() |>
  tidyr::fill(value, .direction = "down")
```

## Phase 2: Exploratory Analysis

```r
# Time plot
ts_data |> autoplot(value) +
  labs(title = "Time Series Plot", y = "Value")

# Seasonal plot
ts_data |> gg_season(value, labels = "both") +
  labs(title = "Seasonal Pattern")

# Subseries plot
ts_data |> gg_subseries(value) +
  labs(title = "Seasonal Subseries")

# ACF/PACF
ts_data |> gg_tsdisplay(value, plot_type = "partial")

# Decomposition
ts_data |>
  model(stl = STL(value)) |>
  components() |>
  autoplot()

# Check seasonality strength
ts_data |>
  features(value, feat_stl)
```

## Phase 3: Train/Test Split

```r
# Split data (e.g., last 12 months as test)
train_data <- ts_data |> filter(Month < yearmonth("2023-01"))
test_data <- ts_data |> filter(Month >= yearmonth("2023-01"))

# Verify split
cat("Train:", min(train_data$Month), "to", max(train_data$Month), "\n")
cat("Test:", min(test_data$Month), "to", max(test_data$Month), "\n")
```

## Phase 4: Model Fitting

```r
# Fit multiple candidate models
fit <- train_data |>
  model(
    # Simple benchmarks
    mean = MEAN(value),
    naive = NAIVE(value),
    snaive = SNAIVE(value),
    drift = RW(value ~ drift()),

    # Exponential smoothing
    ets_auto = ETS(value),
    ets_aaa = ETS(value ~ error("A") + trend("A") + season("A")),

    # ARIMA
    arima_auto = ARIMA(value),
    arima_manual = ARIMA(value ~ pdq(1,1,1) + PDQ(1,1,1)),

    # Optional: Advanced methods
    prophet = prophet(value),
    nnetar = NNETAR(value)
  )

# Quick accuracy check
fit |> accuracy() |> arrange(MASE)
```

## Phase 5: Diagnostics

```r
# Check residuals for best performers
fit |> select(arima_auto) |> gg_tsresiduals()
fit |> select(ets_auto) |> gg_tsresiduals()

# Ljung-Box test
augment(fit) |>
  filter(.model %in% c("arima_auto", "ets_auto")) |>
  features(.innov, ljung_box, lag = 24, dof = 0)

# Information criteria
fit |>
  glance() |>
  select(.model, AICc, BIC) |>
  arrange(AICc)
```

## Phase 6: Cross-Validation (Optional but Recommended)

```r
# Create CV folds
ts_cv <- train_data |>
  stretch_tsibble(.init = 24, .step = 3)

# Fit on CV folds
cv_fit <- ts_cv |>
  model(
    ets = ETS(value),
    arima = ARIMA(value)
  )

# Generate forecasts
h_forecast <- 12  # Forecast horizon
cv_fc <- cv_fit |> forecast(h = h_forecast)

# Evaluate
cv_results <- cv_fc |>
  accuracy(train_data) |>
  group_by(.model) |>
  summarise(
    mean_MASE = mean(MASE),
    mean_RMSE = mean(RMSE)
  ) |>
  arrange(mean_MASE)

print(cv_results)
```

## Phase 7: Model Selection

```r
# Select best model based on CV or information criteria
best_model_name <- cv_results |>
  slice(1) |>
  pull(.model)

best_model <- fit |> select(all_of(best_model_name))

# Display model
report(best_model)
```

## Phase 8: Generate Forecasts

```r
# Forecast test period
h_test <- nrow(test_data)
fc_test <- best_model |> forecast(h = h_test)

# Visualize
fc_test |>
  autoplot(train_data, level = c(80, 95)) +
  autolayer(test_data, color = "black") +
  labs(title = "Forecast vs Actual",
       y = "Value",
       x = "Time")
```

## Phase 9: Evaluate Test Performance

```r
# Calculate accuracy on test set
test_accuracy <- fc_test |>
  accuracy(test_data)

print(test_accuracy)

# Compare to naive benchmark
naive_fc <- train_data |>
  model(naive = SNAIVE(value)) |>
  forecast(h = h_test)

naive_accuracy <- naive_fc |>
  accuracy(test_data)

# Comparison
bind_rows(
  test_accuracy |> mutate(type = "Selected Model"),
  naive_accuracy |> mutate(type = "Benchmark")
) |>
  select(type, MASE, RMSE, MAE)
```

## Phase 10: Final Production Model

```r
# Refit on full data for production
final_model <- ts_data |>
  model(best = !!best_model[[1]][[1]])  # Extract model specification

# Generate future forecasts
h_future <- 12  # Next 12 periods
final_fc <- final_model |> forecast(h = h_future)

# Visualize
final_fc |>
  autoplot(ts_data, level = c(80, 95)) +
  labs(title = "Final Forecast",
       y = "Value",
       subtitle = paste("Model:", best_model_name))

# Extract forecast table
forecast_table <- final_fc |>
  as_tibble() |>
  select(Month, .mean, contains("80%"), contains("95%"))

# Export forecasts
write_csv(forecast_table, "forecasts.csv")

# Save model for future use
saveRDS(final_model, "production_forecast_model.rds")
```

## Phase 11: Monitoring and Updates

```r
# When new data arrives, re-evaluate
# Load model
production_model <- readRDS("production_forecast_model.rds")

# Compare forecasts to actuals
# (code depends on your data pipeline)

# Refit periodically (e.g., monthly)
updated_model <- ts_data_with_new_obs |>
  model(best = !!production_model[[1]][[1]])

# Save updated model
saveRDS(updated_model, "production_forecast_model.rds")
```

## Checklist

Before finalizing your forecast:

- [ ] Data is properly converted to tsibble
- [ ] Gaps are identified and handled
- [ ] Explored with time plot, seasonal plot, ACF
- [ ] Fitted multiple candidate models
- [ ] Checked residual diagnostics
- [ ] Used cross-validation or test set
- [ ] Selected model based on appropriate metrics
- [ ] Evaluated against naive benchmark
- [ ] Visualized forecasts with prediction intervals
- [ ] Documented model selection process
- [ ] Saved model for future use

## Quick Variations

### For Non-Seasonal Data
```r
fit <- train_data |>
  model(
    naive = NAIVE(value),
    drift = RW(value ~ drift()),
    ets = ETS(value ~ error("A") + trend("A") + season("N")),
    arima = ARIMA(value ~ PDQ(0,0,0))
  )
```

### For Multiple Seasonality
```r
fit <- train_data |>
  model(
    tbats = TBATS(value),
    prophet = prophet(value)
  )
```

### For External Predictors
```r
fit <- train_data |>
  model(
    tslm = TSLM(value ~ trend() + season() + external_var),
    arimax = ARIMA(value ~ external_var)
  )
```

### For Hierarchical Forecasting
```r
fit <- hierarchical_data |>
  aggregate_key(hierarchy_structure, value = sum(value)) |>
  model(ets = ETS(value)) |>
  reconcile(mint_shrink = min_trace(method = "mint_shrink"))
```

## Notes

- Adjust time class function (yearmonth, yearquarter, etc.) based on your data frequency
- Modify forecast horizon (h) based on business needs
- Consider computational cost for large datasets (reduce CV folds, use simpler models)
- Always validate assumptions (residuals, stationarity, etc.)
- Communicate uncertainty (prediction intervals) to stakeholders
