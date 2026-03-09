---
name: r-timeseries
description: Expert time series forecasting and analysis in R using fable/tsibble/feasts. ONLY R - do NOT activate for Python time series (statsmodels, prophet in Python). Use when user mentions "série temporal", "time series", "time series in R", "time series with R", "previsão", "forecasting", "forecast in R", "predict time series", "prever série temporal", "analisar série temporal", "analyze time series", "temporal data in R", "dados temporais", "time-based prediction", "ARIMA in R", "ARIMA model", "ETS in R", "ETS model", "fable", "tsibble", "feasts", "forecast package", "prophet in R", "sazonalidade", "seasonality", "seasonal patterns", "padrões sazonais", "lidar com sazonalidade", "handle seasonality", "tendência", "trend", "decomposição", "decomposition", "temporal", "time-based", "temporal patterns", "padrões temporais", or any R-specific time series task.
version: 1.1.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---

# R Time Series Forecasting Expert

You are an expert in time series analysis and forecasting using R's modern fable/tsibble/feasts ecosystem.

## Core Philosophy

1. **Model Pluralism**: Fit multiple models and compare performance
2. **Diagnostic Rigor**: Always check residuals and model assumptions
3. **Cross-Validation**: Use time series CV for robust evaluation
4. **Forecast Uncertainty**: Communicate prediction intervals
5. **Domain Context**: Consider business/scientific context in model selection

## When This Skill Activates

Use this skill when:
- Forecasting future values from time series data
- Analyzing temporal patterns (trend, seasonality, cycles)
- Building ARIMA, ETS, or regression models for time series
- Evaluating forecast accuracy
- Working with tsibble/fable/feasts packages
- Decomposing time series
- Detecting seasonality or trends

## Task Classification & Dispatch

### 1. Data Preparation & Exploration
**Triggers**: "explore time series", "understand patterns", "visualize temporal data"

**Workflow**:
1. Convert to tsibble format
2. Visualize with time plots, seasonal plots, ACF/PACF
3. Check for missing values and gaps
4. Identify patterns (trend, seasonality, cycles)
5. Assess stationarity

**See**: [references/data-visualization.md](references/data-visualization.md)

### 2. Model Selection & Fitting
**Triggers**: "build forecast model", "fit ARIMA", "which model to use"

**Workflow**:
1. Specify multiple candidate models
2. Fit models using `model()`
3. Check diagnostics (residuals, Ljung-Box test)
4. Compare model accuracy
5. Select best model based on criteria

**See**: [references/forecasting-methods.md](references/forecasting-methods.md)

### 3. Forecasting & Prediction
**Triggers**: "forecast next", "predict future", "generate forecast"

**Workflow**:
1. Use selected model to generate forecasts
2. Specify forecast horizon (`h =`)
3. Visualize forecasts with prediction intervals
4. Export predictions if needed

**See**: [templates/forecasting-workflow.md](templates/forecasting-workflow.md)

### 4. Forecast Evaluation
**Triggers**: "evaluate accuracy", "test performance", "compare models"

**Workflow**:
1. Create train/test split or time series CV
2. Generate forecasts on test set
3. Calculate accuracy measures (MAE, RMSE, MASE)
4. Compare multiple models
5. Select best performer

**See**: [references/forecast-evaluation.md](references/forecast-evaluation.md)

## Quick Start Workflows

### Complete Forecasting Workflow

```r
library(fable)
library(tsibble)
library(feasts)
library(tidyverse)

# 1. Prepare data
ts_data <- data |>
  mutate(Month = yearmonth(date)) |>
  as_tsibble(index = Month)

# 2. Explore
ts_data |> autoplot(value)
ts_data |> gg_season(value)
ts_data |> gg_tsdisplay(value, plot_type = "partial")

# 3. Fit models
fit <- ts_data |>
  model(
    mean = MEAN(value),
    naive = NAIVE(value),
    snaive = SNAIVE(value),
    ets = ETS(value),
    arima = ARIMA(value)
  )

# 4. Check diagnostics
fit |> select(arima) |> gg_tsresiduals()

# 5. Compare accuracy
fit |> accuracy()

# 6. Forecast
fc <- fit |> forecast(h = 12)
fc |> autoplot(ts_data)

# 7. Evaluate
fc |> accuracy(test_data)
```

## Model Selection Decision Framework

### By Data Pattern

| Pattern | Recommended Models |
|---------|-------------------|
| No trend, no seasonality | MEAN, NAIVE, ETS(A,N,N) |
| Trend, no seasonality | Drift, ARIMA(0,1,0), ETS(A,A,N) |
| No trend, seasonality | SNAIVE, ETS(A,N,A/M), ARIMA seasonal |
| Trend + seasonality | ETS(A,A,A/M), ARIMA with seasonal terms |
| Multiple seasonality | TBATS, Prophet |
| With predictors | Dynamic regression, ARIMAX |

### By Objective

- **Accuracy Priority**: Try multiple models, select by cross-validation
- **Interpretability**: ETS (error/trend/seasonal framework is intuitive)
- **Automation**: ARIMA()/ETS() with automatic selection
- **Multiple Seasonality**: TBATS, Prophet
- **External Predictors**: Dynamic regression (ARIMA with xreg)

## Time Series Data Structures (tsibble)

### Creating tsibbles

```r
# From data frame
library(tsibble)
library(lubridate)

ts_data <- data |>
  mutate(Month = yearmonth(date_column)) |>
  as_tsibble(index = Month, key = group_var)

# Time class functions by frequency
yearquarter()   # Quarterly data
yearmonth()     # Monthly data
yearweek()      # Weekly data
as_date()       # Daily data
as_datetime()   # Sub-daily data
```

### Key Operations

```r
# Filter
ts_data |> filter(condition)

# Aggregate
ts_data |>
  index_by(Year = year(Month)) |>
  summarise(total = sum(value))

# Fill gaps
ts_data |>
  fill_gaps() |>
  tidyr::fill(value, .direction = "down")

# Check for gaps
scan_gaps(ts_data)
```

## Visualization Patterns

```r
# Time plot
autoplot(ts_data, value)

# Seasonal plot
gg_season(ts_data, value, labels = "both")

# Subseries plot
gg_subseries(ts_data, value)

# ACF and PACF
gg_tsdisplay(ts_data, value, plot_type = "partial")

# Decomposition
ts_data |>
  model(stl = STL(value)) |>
  components() |>
  autoplot()
```

## Forecasting Methods Overview

### Simple Methods
```r
model(
  mean = MEAN(value),           # Average of all observations
  naive = NAIVE(value),         # Last observation
  snaive = SNAIVE(value),       # Last observation from same season
  drift = RW(value ~ drift())   # Naive + linear trend
)
```

### Exponential Smoothing (ETS)
```r
model(
  ets_auto = ETS(value),                              # Automatic selection
  ets_aaa = ETS(value ~ error("A") + trend("A") + season("A")),
  ets_mam = ETS(value ~ error("M") + trend("A") + season("M"))
)
```

### ARIMA
```r
model(
  arima_auto = ARIMA(value),                       # Automatic selection
  arima_manual = ARIMA(value ~ pdq(1,1,1) + PDQ(1,1,1)),
  arima_with_drift = ARIMA(value ~ pdq(1,1,0) + PDQ(0,1,1) + 1)
)
```

### Regression Models
```r
model(
  tslm = TSLM(value ~ trend() + season()),
  dynamic_reg = ARIMA(value ~ xreg_var)
)
```

### Advanced Methods
```r
model(
  prophet = prophet(value),
  nnetar = NNETAR(value),
  tbats = TBATS(value)
)
```

## Diagnostic Workflows

### Residual Diagnostics
```r
# Visual diagnostics
fit |>
  select(model_name) |>
  gg_tsresiduals()

# Ljung-Box test (should be non-significant)
augment(fit) |>
  features(.innov, ljung_box, lag = 24, dof = 0)

# Residuals should be:
# 1. Uncorrelated (no patterns in ACF)
# 2. Zero mean
# 3. Constant variance
# 4. Normally distributed (for prediction intervals)
```

### Model Comparison
```r
# Training set accuracy
fit |> accuracy()

# Information criteria (lower is better)
fit |> glance()  # AIC, AICc, BIC

# Cross-validation
ts_cv <- ts_data |>
  stretch_tsibble(.init = 60, .step = 1)

cv_fit <- ts_cv |> model(arima = ARIMA(value))
cv_fc <- cv_fit |> forecast(h = 12)
cv_fc |> accuracy(ts_data)
```

## Forecast Evaluation Metrics

- **MAE**: Mean Absolute Error (scale-dependent)
- **RMSE**: Root Mean Squared Error (penalizes large errors)
- **MAPE**: Mean Absolute Percentage Error (percentage)
- **MASE**: Mean Absolute Scaled Error (scale-independent, preferred)

```r
# Calculate accuracy
forecast_results |>
  accuracy(actual_data) |>
  select(.model, MAE, RMSE, MASE) |>
  arrange(MASE)
```

## Transformations

### Box-Cox Transformation
```r
# Stabilize variance
lambda <- ts_data |>
  features(value, features = guerrero) |>
  pull(lambda_guerrero)

fit <- ts_data |>
  model(ARIMA(box_cox(value, lambda)))
```

### Differencing
```r
# Remove trend (first difference)
ts_data |> mutate(diff_value = difference(value))

# Remove seasonality (seasonal difference)
ts_data |> mutate(seasonal_diff = difference(value, lag = 12))

# Determine number of differences needed
ts_data |>
  features(value, unitroot_ndiffs)  # Non-seasonal

ts_data |>
  features(value, unitroot_nsdiffs) # Seasonal
```

## Seasonality Handling

### Detecting Seasonality
```r
# Visual inspection
gg_season(ts_data, value)
gg_subseries(ts_data, value)

# Statistical test
ts_data |>
  features(value, feat_stl) |>
  select(seasonal_strength_year)  # > 0.64 suggests strong seasonality
```

### Modeling Seasonal Patterns
```r
# Seasonal ARIMA
ARIMA(value ~ pdq() + PDQ())  # Automatic seasonal terms

# Multiple seasonality
TBATS(value)   # Multiple seasonal periods
prophet(value)  # Flexible seasonality
```

## Common Patterns and Solutions

### Pattern: Missing Values
```r
# Identify gaps
scan_gaps(ts_data)

# Fill gaps with interpolation
ts_data |>
  fill_gaps() |>
  mutate(value = na.interp(value))
```

### Pattern: Outliers
```r
# Visual detection
autoplot(ts_data, value)

# Treatment options:
# 1. Remove and interpolate
# 2. Use robust methods (median-based)
# 3. Model with intervention variables
```

### Pattern: Structural Breaks
```r
# Split data at break point
train_data <- ts_data |> filter(Month < break_date)
test_data <- ts_data |> filter(Month >= break_date)

# Or use intervention variables in regression
```

## Best Practices

### Data Preparation
1. Always convert to tsibble format first
2. Check for gaps: `scan_gaps()`
3. Visualize before modeling: time plot, seasonal plot, ACF
4. Assess stationarity: `gg_tsdisplay()` and unit root tests

### Model Building
1. Fit multiple models for comparison
2. Check residual diagnostics for all candidates
3. Use automatic model selection as starting point
4. Refine based on domain knowledge
5. Consider forecast horizon (different models excel at different horizons)

### Forecasting
1. Always report prediction intervals
2. Use h-step ahead forecast matching business needs
3. Consider computational cost for large-scale forecasting
4. Re-fit models regularly as new data arrives

### Evaluation
1. Use time series cross-validation, not random splits
2. Evaluate on multiple horizons (1-step, 3-step, 12-step)
3. Use scale-independent metrics (MASE) for comparison
4. Compare against simple benchmark (naive, seasonal naive)

## Common Pitfalls

❌ **Using non-time series methods** (random split, standard regression)
✅ Use tsibble, time series cross-validation, ARIMA/ETS

❌ **Ignoring residual diagnostics**
✅ Always check gg_tsresiduals() and Ljung-Box test

❌ **Overfitting** (too many parameters)
✅ Use information criteria (AICc), cross-validation

❌ **Forgetting seasonality**
✅ Check gg_season() and include seasonal terms

❌ **Not handling missing values**
✅ Use scan_gaps() and fill_gaps()

❌ **Comparing models on different data**
✅ Use consistent train/test splits

## Supporting Resources

### Comprehensive References
- **Forecasting Methods**: [references/forecasting-methods.md](references/forecasting-methods.md)
  - Simple methods, ETS, ARIMA, regression, advanced models
- **Data Visualization**: [references/data-visualization.md](references/data-visualization.md)
  - Time plots, seasonal plots, ACF/PACF, decomposition
- **Forecast Evaluation**: [references/forecast-evaluation.md](references/forecast-evaluation.md)
  - Accuracy metrics, cross-validation, model selection

### Workflow Templates
- **Basic Forecast Workflow**: [templates/forecasting-workflow.md](templates/forecasting-workflow.md)
  - Step-by-step template for standard forecasting tasks

### Complete Examples
- **Retail Sales Forecast**: [examples/retail-sales-forecast.md](examples/retail-sales-forecast.md)
  - End-to-end example from data to deployment

## Quick Reference

### Package Loading
```r
library(fable)      # Forecasting models
library(tsibble)    # Time series data structures
library(feasts)     # Feature extraction and statistics
library(tidyverse)  # Data manipulation
```

### Essential Functions

| Task | Function |
|------|----------|
| Create tsibble | `as_tsibble(index = , key = )` |
| Visualize | `autoplot()`, `gg_season()`, `gg_tsdisplay()` |
| Fit models | `model()` |
| Generate forecasts | `forecast(h = )` |
| Check diagnostics | `gg_tsresiduals()` |
| Evaluate accuracy | `accuracy()` |
| Cross-validation | `stretch_tsibble()` |

### Quick Model Comparison Template
```r
fit <- ts_data |>
  model(
    naive = NAIVE(value),
    snaive = SNAIVE(value),
    ets = ETS(value),
    arima = ARIMA(value)
  )

fit |> accuracy() |> arrange(MASE)
best_model <- fit |> select(arima)  # Or best performer
forecast <- best_model |> forecast(h = 12)
forecast |> autoplot(ts_data)
```

## Integration with Other Skills

- **r-datascience**: Use for data preparation, EDA, visualization
- **r-style-guide**: Follow for R code formatting
- **tdd-workflow**: Use for testing forecast pipelines
- **r-performance**: Use for large-scale forecasting optimization

---

**Remember**: Good forecasting combines statistical rigor with domain expertise. Always validate model assumptions, use multiple models, and communicate forecast uncertainty.
