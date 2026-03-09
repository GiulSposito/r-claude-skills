# Time Series Data Visualization

Essential visualizations for time series analysis and diagnostics.

## Time Plots

### Basic Time Plot
```r
autoplot(ts_data, value) +
  labs(title = "Time Series Plot",
       y = "Value",
       x = "Time")
```

**Purpose**: Show overall patterns, trends, seasonality, outliers

**Look for**:
- Trend (upward/downward)
- Seasonality (regular patterns)
- Cycles (non-fixed patterns)
- Outliers/anomalies
- Structural breaks

## Seasonal Plots

### Seasonal Plot
```r
gg_season(ts_data, value, labels = "both") +
  labs(title = "Seasonal Plot")
```

**Purpose**: Compare patterns across seasons

**Shows**:
- Timing of peaks/troughs within seasons
- Consistency of seasonal pattern
- Year-to-year changes

### Subseries Plot
```r
gg_subseries(ts_data, value) +
  labs(title = "Seasonal Subseries Plot")
```

**Purpose**: Show seasonal means and variation within each season

**Blue line**: Average for that season across all years

## ACF and PACF

### Combined Display
```r
gg_tsdisplay(ts_data, value, plot_type = "partial")
```

Shows:
1. Time plot
2. ACF (Autocorrelation Function)
3. PACF (Partial Autocorrelation Function)

### ACF Only
```r
ts_data |>
  ACF(value, lag_max = 48) |>
  autoplot()
```

**Interpretation**:
- **Slow decay**: Trend present
- **Spikes at seasonal lags**: Seasonality present
- **All near zero**: White noise (good residuals)

### PACF
Partial autocorrelations (controlling for intermediate lags).

**Use for**: AR order selection in ARIMA

## Decomposition Plots

### STL Decomposition
```r
ts_data |>
  model(stl = STL(value)) |>
  components() |>
  autoplot()
```

Shows four panels:
1. Original data
2. Trend component
3. Seasonal component
4. Remainder (residuals)

**Look for**:
- Strength of trend/seasonality
- Changes in seasonal pattern over time
- Outliers in remainder

## Lag Plots

```r
ts_data |>
  gg_lag(value, geom = "point", lags = 1:9)
```

**Purpose**: Visualize correlation at different lags

**Pattern indicates**:
- **Linear relationship**: Positive autocorrelation
- **No pattern**: No autocorrelation

## Multiple Series Comparison

```r
ts_data |>
  autoplot(value) +
  facet_wrap(~key_variable, scales = "free_y")
```

Compare patterns across different groups/categories.

## Forecast Visualization

### Basic Forecast Plot
```r
forecast_result |>
  autoplot(ts_data, level = c(80, 95))
```

Shows:
- Historical data
- Point forecasts
- Prediction intervals (80% and 95%)

### Forecast Fan Chart
```r
forecast_result |>
  autoplot(ts_data, level = seq(10, 90, by = 10)) +
  scale_fill_brewer(palette = "Blues")
```

Multiple prediction intervals create a "fan" showing increasing uncertainty.

## Residual Diagnostics

### Combined Residual Plot
```r
fit |> gg_tsresiduals()
```

Three panels:
1. **Residual time plot**: Check for patterns
2. **ACF of residuals**: Check for autocorrelation
3. **Histogram of residuals**: Check normality

**Good residuals**:
- No patterns in time plot
- ACF within bounds (white noise)
- Roughly normal histogram

### Individual Residual Plots
```r
# Time plot
augment(fit) |> autoplot(.innov)

# ACF
augment(fit) |> ACF(.innov) |> autoplot()

# Histogram
augment(fit) |>
  ggplot(aes(x = .innov)) +
  geom_histogram(bins = 30)
```

## Forecast Accuracy Visualization

### Actual vs Fitted
```r
augment(fit) |>
  ggplot(aes(x = Month)) +
  geom_line(aes(y = value, color = "Actual")) +
  geom_line(aes(y = .fitted, color = "Fitted")) +
  labs(title = "Actual vs Fitted Values")
```

### Forecast vs Actual (Test Set)
```r
forecast_result |>
  autoplot(train_data) +
  autolayer(test_data, color = "black") +
  labs(title = "Forecast vs Actual")
```

## Advanced Visualizations

### Multiple Model Comparison
```r
forecast_result |>
  autoplot(ts_data, level = NULL) +
  facet_wrap(~.model)
```

### Prediction Interval Coverage
```r
forecast_result |>
  accuracy(test_data, list(winkler = winkler_score), level = 95) |>
  ggplot(aes(x = .model, y = winkler)) +
  geom_col()
```

## Quick Visualization Workflow

```r
# Complete exploratory visualization
library(patchwork)

p1 <- autoplot(ts_data, value)
p2 <- gg_season(ts_data, value)
p3 <- gg_subseries(ts_data, value)
p4 <- ACF(ts_data, value) |> autoplot()

(p1 + p2) / (p3 + p4)
```

## Best Practices

✅ **Always start with**: Time plot, seasonal plot, ACF
✅ **For diagnostics**: Use `gg_tsresiduals()` for all models
✅ **For comparison**: Facet by model or series
✅ **For communication**: Include prediction intervals in forecasts
✅ **For interpretation**: Add clear titles and labels

❌ **Don't**: Skip exploratory visualization
❌ **Don't**: Ignore residual diagnostics
❌ **Don't**: Use inappropriate scales (allow free_y for different series)
❌ **Don't**: Over-complicate (simple is better)
