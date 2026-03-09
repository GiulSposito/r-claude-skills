# Forecast Evaluation and Model Selection

Comprehensive guide to evaluating forecast accuracy and selecting models.

## Accuracy Metrics

### Scale-Dependent Metrics

**Mean Absolute Error (MAE)**:
```
MAE = mean(|actual - forecast|)
```
- Easy to interpret (same units as data)
- Less sensitive to outliers than RMSE
- Cannot compare across different scales

**Root Mean Squared Error (RMSE)**:
```
RMSE = sqrt(mean((actual - forecast)²))
```
- Penalizes large errors more
- Same units as data
- Cannot compare across different scales

### Percentage Errors

**Mean Absolute Percentage Error (MAPE)**:
```
MAPE = mean(|100 * (actual - forecast) / actual|)
```
- Scale-independent (percentage)
- Easy to understand
- **Problems**: Infinite/undefined when actual = 0, asymmetric

**Symmetric MAPE (sMAPE)**:
```
sMAPE = mean(200 * |actual - forecast| / (|actual| + |forecast|))
```
- More symmetric than MAPE
- Still has issues with zero values

### Scale-Independent Metrics (PREFERRED)

**Mean Absolute Scaled Error (MASE)**:
```
MASE = MAE / MAE_naive
```
where `MAE_naive` is the MAE from naive forecast on training set

- **< 1**: Better than naive baseline
- **> 1**: Worse than naive baseline
- No division by zero issues
- **RECOMMENDED for comparing models**

**Root Mean Squared Scaled Error (RMSSE)**:
```
RMSSE = RMSE / RMSE_naive
```
- Scaled version of RMSE
- Interpretation similar to MASE

## Computing Accuracy in R

### Training Set Accuracy
```r
fit |>
  accuracy()
```

Returns metrics for all fitted models.

### Test Set Accuracy
```r
forecast_result |>
  accuracy(actual_data)
```

### Selecting Best Model
```r
# By MASE
fit |>
  accuracy() |>
  arrange(MASE) |>
  slice(1)

# Extract best model
best_model <- fit |>
  select(best_model_name)
```

## Time Series Cross-Validation

### Why Not Random Split?
- **Temporal dependence**: Future observations depend on past
- **Data leakage**: Random split uses future to predict past
- **Invalid**: Breaks temporal order

### Time Series CV Approach

**Expanding Window (Recommended)**:
```r
# Create CV folds
ts_cv <- ts_data |>
  stretch_tsibble(.init = 60, .step = 1)

# Fit on each fold
cv_fit <- ts_cv |>
  model(
    ets = ETS(value),
    arima = ARIMA(value)
  )

# Forecast each fold
cv_fc <- cv_fit |> forecast(h = 12)

# Evaluate
cv_fc |>
  accuracy(ts_data) |>
  group_by(.model) |>
  summarise(MASE = mean(MASE))
```

**Parameters**:
- `.init`: Minimum training size
- `.step`: How many observations to add each fold
- `h`: Forecast horizon to evaluate

**Sliding Window**:
```r
ts_cv <- ts_data |>
  slide_tsibble(.size = 60, .step = 1)
```
Fixed window size, moves forward.

### Computational Considerations

```r
# Faster: Increase step size
stretch_tsibble(.init = 60, .step = 12)  # Annual steps instead of monthly

# Fewer horizons
forecast(h = 1)  # Only 1-step ahead
```

## Model Selection Criteria

### Information Criteria

**AIC (Akaike Information Criterion)**:
```
AIC = -2*log(L) + 2*k
```
- Balances fit and complexity
- Lower is better
- For comparing models on same data

**AICc (Corrected AIC)**:
```
AICc = AIC + 2*k*(k+1)/(n-k-1)
```
- **RECOMMENDED for small samples**
- Reduces overfitting risk
- Use when n/k < 40

**BIC (Bayesian Information Criterion)**:
```
BIC = -2*log(L) + k*log(n)
```
- Stronger penalty for complexity
- Prefers simpler models
- Asymptotically optimal

**In R**:
```r
fit |>
  glance() |>
  select(.model, AIC, AICc, BIC) |>
  arrange(AICc)
```

### Residual Diagnostics

**Ljung-Box Test**:
Tests whether residuals are white noise.

```r
augment(fit) |>
  features(.innov, ljung_box, lag = 24, dof = 0)
```

- **Null hypothesis**: Residuals are white noise
- **p-value > 0.05**: Good (fail to reject, residuals uncorrelated)
- **p-value < 0.05**: Bad (reject, residuals correlated)

**Visual Diagnostics**:
```r
fit |> gg_tsresiduals()
```

**Good residuals**:
- No patterns in time plot
- ACF mostly within bounds
- Roughly normal distribution

## Prediction Intervals

### Evaluating Coverage

Prediction intervals should contain actual values X% of the time.

```r
# Check 95% interval coverage
forecast_result |>
  hilo(level = 95) |>
  unpack_hilo("95%") |>
  mutate(
    in_interval = actual >= `95%_lower` & actual <= `95%_upper`
  ) |>
  summarise(coverage = mean(in_interval))
```

**Expected**: ~0.95 for 95% intervals

### Winkler Score

Penalizes both interval width and coverage violations.

```r
forecast_result |>
  accuracy(actual_data, list(winkler = winkler_score), level = 95)
```

Lower is better.

## Forecast Horizon Evaluation

Evaluate at multiple horizons to understand performance degradation.

```r
# Generate forecasts for h = 1 to 12
horizons <- 1:12

results <- map(horizons, function(h) {
  cv_fc <- cv_fit |> forecast(h = h)
  cv_fc |>
    accuracy(ts_data) |>
    mutate(horizon = h)
}) |> list_rbind()

# Plot accuracy by horizon
results |>
  ggplot(aes(x = horizon, y = MASE, color = .model)) +
  geom_line() +
  labs(title = "Forecast Accuracy by Horizon")
```

**Typical pattern**: Accuracy decreases with horizon

## Model Comparison Workflow

```r
# 1. Fit candidate models
fit <- ts_data |>
  model(
    naive = NAIVE(value),
    snaive = SNAIVE(value),
    ets = ETS(value),
    arima = ARIMA(value)
  )

# 2. Training set accuracy (quick check)
fit |>
  accuracy() |>
  arrange(MASE)

# 3. Information criteria (model complexity)
fit |>
  glance() |>
  arrange(AICc)

# 4. Residual diagnostics (check assumptions)
fit |> select(arima) |> gg_tsresiduals()

# 5. Cross-validation (robust evaluation)
ts_cv <- ts_data |>
  stretch_tsibble(.init = 60, .step = 6)

cv_fit <- ts_cv |>
  model(
    ets = ETS(value),
    arima = ARIMA(value)
  )

cv_fc <- cv_fit |> forecast(h = 12)

cv_fc |>
  accuracy(ts_data) |>
  group_by(.model) |>
  summarise(mean_MASE = mean(MASE)) |>
  arrange(mean_MASE)

# 6. Select best model
best_model_name <- cv_fc |>
  accuracy(ts_data) |>
  group_by(.model) |>
  summarise(mean_MASE = mean(MASE)) |>
  arrange(mean_MASE) |>
  slice(1) |>
  pull(.model)

final_model <- fit |> select(all_of(best_model_name))

# 7. Generate final forecasts
final_forecast <- final_model |> forecast(h = 12)
```

## Common Pitfalls

❌ **Using training accuracy only**
✅ Use cross-validation or hold-out test set

❌ **Comparing RMSE across different scales**
✅ Use MASE or percentage metrics

❌ **Ignoring residual diagnostics**
✅ Check residuals for all candidate models

❌ **Random train/test split**
✅ Use temporal split (latest data as test)

❌ **Testing once at one horizon**
✅ Evaluate at multiple horizons

❌ **Selecting model by training fit alone**
✅ Balance fit, complexity, and forecast accuracy

## Best Practices

### Model Selection Strategy
1. Start with simple benchmarks (naive, seasonal naive)
2. Fit several candidate models (ETS, ARIMA, etc.)
3. Check diagnostics (residuals, Ljung-Box)
4. Compare using cross-validation
5. Select based on MASE at relevant horizon
6. Verify prediction intervals are reasonable

### Reporting Results
- Report multiple metrics (MASE, RMSE, MAE)
- Include benchmark comparison (vs naive)
- Show prediction intervals
- Visualize forecasts
- Document model selection process

### Continuous Improvement
- Re-evaluate periodically
- Update models with new data
- Monitor forecast accuracy in production
- Adjust models if performance degrades
