# Time Series Forecasting Methods

Complete reference for forecasting methods in the fable ecosystem.

## Simple Forecasting Methods

### MEAN - Average Method
Forecasts all future values as the average of historical data.

```r
fit <- data |> model(mean_model = MEAN(value))
```

**Use when**: No trend, no seasonality, random fluctuations

### NAIVE - Last Value
All forecasts equal to the last observed value.

```r
fit <- data |> model(naive = NAIVE(value))
```

**Use when**: Random walk data, no clear patterns
**Also known as**: Random walk forecast

### SNAIVE - Seasonal Naive
Forecasts equal to the last observation from the same season.

```r
fit <- data |> model(snaive = SNAIVE(value))
```

**Use when**: Strong seasonality, no trend
**Benchmark**: Often used as baseline for seasonal data

### Drift Method
Naive forecast plus average historical change (linear trend).

```r
fit <- data |> model(drift = RW(value ~ drift()))
```

**Use when**: Linear trend, no seasonality
**Formula**: `y_t+h = y_t + h * (y_T - y_1)/(T-1)`

---

## Exponential Smoothing (ETS)

### Framework Overview
ETS decomposes forecasting into three components:
- **E**rror: Additive (A) or Multiplicative (M)
- **T**rend: None (N), Additive (A), Additive damped (Ad)
- **S**easonality: None (N), Additive (A), Multiplicative (M)

### Automatic Selection
```r
fit <- data |> model(ets = ETS(value))
```

Automatically selects best combination based on AICc.

### Manual Specification
```r
fit <- data |> model(
  ets_aan = ETS(value ~ error("A") + trend("A") + season("N")),
  ets_mam = ETS(value ~ error("M") + trend("A") + season("M")),
  ets_aad = ETS(value ~ error("A") + trend("Ad") + season("N"))
)
```

### Common Combinations

| Model | Trend | Seasonality | Use Case |
|-------|-------|-------------|----------|
| ETS(A,N,N) | None | None | Flat, stable series |
| ETS(A,A,N) | Linear | None | Linear trend, no seasons |
| ETS(A,Ad,N) | Damped | None | Flattening trend |
| ETS(A,N,A) | None | Additive | Seasonal, no trend |
| ETS(A,A,A) | Linear | Additive | Trend + constant seasonality |
| ETS(A,A,M) | Linear | Multiplicative | Trend + proportional seasonality |
| ETS(M,A,M) | Linear | Multiplicative | Proportional errors & seasonality |

### Damped Trend
Exponentially decaying trend (prevents unrealistic long-term forecasts).

```r
ETS(value ~ error("A") + trend("Ad") + season("N"))
```

**Use when**: Trend expected to flatten over time

---

## ARIMA Models

### Components
- **AR** (p): AutoRegressive - uses lagged observations
- **I** (d): Integrated - differencing to achieve stationarity
- **MA** (q): Moving Average - uses lagged forecast errors
- **Seasonal**: PDQ - seasonal equivalents

### Automatic Selection
```r
fit <- data |> model(arima = ARIMA(value))
```

Uses unit root tests and AICc to select orders.

### Manual Specification
```r
fit <- data |> model(
  arima_110 = ARIMA(value ~ pdq(1,1,0)),
  arima_seasonal = ARIMA(value ~ pdq(1,1,1) + PDQ(1,1,1)),
  arima_with_drift = ARIMA(value ~ pdq(0,1,0) + PDQ(0,1,1) + 1)
)
```

### Stationarity & Differencing

**Check stationarity**:
```r
# Visual check
gg_tsdisplay(data, value, plot_type = "partial")

# Statistical tests
data |> features(value, unitroot_kpss)    # p < 0.05 = non-stationary
data |> features(value, unitroot_ndiffs)  # Number of differences needed
data |> features(value, unitroot_nsdiffs) # Seasonal differences needed
```

**Apply differencing**:
```r
data |> mutate(diff_value = difference(value, lag = 1))       # First difference
data |> mutate(seasonal_diff = difference(value, lag = 12))  # Seasonal difference
```

### ACF/PACF Patterns for Identification

| Pattern | AR(p) | MA(q) | Model Hint |
|---------|-------|-------|------------|
| ACF decays, PACF cuts off at lag p | Yes | No | AR(p) |
| ACF cuts off at lag q, PACF decays | No | Yes | MA(q) |
| Both decay gradually | Yes | Yes | ARIMA(p,d,q) |

### Common ARIMA Models

| Model | Description | Use Case |
|-------|-------------|----------|
| ARIMA(0,1,0) | Random walk | No pattern after differencing |
| ARIMA(0,1,0) + drift | Random walk with drift | Linear trend |
| ARIMA(1,0,0) | AR(1) | Short-term autocorrelation |
| ARIMA(0,0,1) | MA(1) | Single shock effect |
| ARIMA(1,1,1) | General ARIMA | Mixed patterns |
| ARIMA(p,1,q)(P,1,Q) | Seasonal ARIMA | Seasonal + trend |

---

## Regression Models

### Time Series Linear Model (TSLM)
```r
fit <- data |>
  model(tslm = TSLM(value ~ trend() + season()))
```

**Predictors**:
- `trend()`: Linear time trend
- `season()`: Seasonal dummy variables
- Custom variables: Any external predictor

**Use when**: Clear linear relationships with time/season

### Dynamic Regression (ARIMAX)
ARIMA with external regressors.

```r
fit <- data |>
  model(
    arimax = ARIMA(value ~ temperature + holiday)
  )
```

**When to use**:
- Have relevant external predictors
- Predictors available for forecast horizon
- Relationships relatively stable

**Advantages over TSLM**:
- Handles autocorrelated errors
- More flexible for non-linear patterns
- Better long-term forecasts

---

## Advanced Methods

### Prophet
Developed by Facebook for business time series.

```r
fit <- data |> model(prophet = prophet(value))
```

**Strengths**:
- Handles missing data and outliers
- Multiple seasonality (daily, weekly, yearly)
- Holiday effects
- Robust to irregularities

**Use when**: Business data with strong seasonality and holidays

### Neural Network Autoregression (NNETAR)
```r
fit <- data |> model(nnetar = NNETAR(value))
```

**Strengths**:
- Captures non-linear patterns
- No stationarity assumption
- Flexible

**Weaknesses**:
- Computationally expensive
- Black box (hard to interpret)
- Prone to overfitting

**Use when**: Complex non-linear patterns, sufficient data

### TBATS
Multiple seasonality with Box-Cox transformation, ARMA errors, Trend, and Seasonal components.

```r
fit <- data |> model(tbats = TBATS(value))
```

**Use when**: Multiple seasonal patterns (e.g., daily + weekly + yearly)

### Vector Autoregression (VAR)
Multivariate time series (multiple related series).

```r
fit <- data |>
  model(var = VAR(cbind(series1, series2, series3)))
```

**Use when**: Multiple series influence each other

---

## Model Selection Guidelines

### By Data Characteristics

| Data Pattern | Recommended Models |
|--------------|-------------------|
| Flat (no trend/season) | MEAN, NAIVE, ETS(A,N,N) |
| Trend only | Drift, ETS(A,A,N), ARIMA(0,1,0) with drift |
| Seasonality only | SNAIVE, ETS(A,N,A), seasonal ARIMA |
| Trend + seasonality | ETS(A,A,A/M), seasonal ARIMA |
| Multiple seasonality | TBATS, Prophet |
| With external predictors | Dynamic regression, Prophet |
| Non-linear | NNETAR, GAM |
| Multiple related series | VAR |

### By Objective

- **Accuracy**: Fit multiple, select best via CV
- **Speed**: ETS or ARIMA automatic
- **Interpretability**: ETS or simple ARIMA
- **Automation**: ETS() or ARIMA() with defaults
- **External info**: Dynamic regression
- **Multiple seasonality**: TBATS or Prophet

### Information Criteria

| Criterion | Use Case |
|-----------|----------|
| AIC | General model selection |
| AICc | Small samples (preferred) |
| BIC | Stronger penalty for complexity |

Lower values indicate better fit.

```r
fit |> glance() |> arrange(AICc)
```

---

## Ensemble Methods

Combine multiple models for robust forecasts.

```r
# Average forecasts from multiple models
fit <- data |>
  model(
    ets = ETS(value),
    arima = ARIMA(value),
    snaive = SNAIVE(value)
  )

fc <- fit |>
  forecast(h = 12) |>
  summarise(.mean = mean(.mean))  # Average across models
```

**Benefits**:
- Reduces model selection risk
- Often more accurate than single model
- More robust to outliers

---

## Forecasting Process Workflow

```r
# 1. Load and prepare
library(fable)
library(tsibble)
library(feasts)

ts_data <- data |>
  mutate(Month = yearmonth(date)) |>
  as_tsibble(index = Month)

# 2. Explore
ts_data |> autoplot(value)
ts_data |> gg_season(value)
ts_data |> gg_tsdisplay(value, plot_type = "partial")

# 3. Fit multiple models
fit <- ts_data |>
  model(
    naive = NAIVE(value),
    snaive = SNAIVE(value),
    ets = ETS(value),
    arima = ARIMA(value),
    prophet = prophet(value)
  )

# 4. Check diagnostics
fit |> select(arima) |> gg_tsresiduals()

# 5. Compare accuracy
fit |> accuracy()

# 6. Generate forecasts
fc <- fit |> forecast(h = 12)

# 7. Visualize
fc |> autoplot(ts_data, level = 95)

# 8. Evaluate (if test data available)
fc |> accuracy(test_data)
```

---

## Summary Table

| Method | Trend | Season | External Vars | Complexity | Speed |
|--------|-------|--------|---------------|------------|-------|
| MEAN | No | No | No | Trivial | Instant |
| NAIVE | No | No | No | Trivial | Instant |
| SNAIVE | No | Yes | No | Trivial | Instant |
| Drift | Linear | No | No | Trivial | Instant |
| ETS | Yes | Yes | No | Low | Fast |
| ARIMA | Yes | Yes | No | Medium | Fast |
| TSLM | Linear | Yes | Yes | Low | Fast |
| Dynamic Reg | Yes | Yes | Yes | Medium | Medium |
| Prophet | Yes | Multiple | Yes | Medium | Medium |
| NNETAR | Yes | Yes | No | High | Slow |
| TBATS | Yes | Multiple | No | High | Slow |
| VAR | Yes | Yes | No | High | Slow |

---

For complete forecasting workflows, see [../templates/forecasting-workflow.md](../templates/forecasting-workflow.md)
