# R Time Series Forecasting Skill

Expert time series analysis and forecasting using R's modern fable/tsibble/feasts ecosystem.

## Overview

This skill provides comprehensive guidance for time series forecasting in R, covering:
- Data preparation and exploration
- Model selection and fitting (ETS, ARIMA, regression, advanced methods)
- Diagnostic checking and validation
- Forecast generation and evaluation
- Best practices and common pitfalls

## When to Use

Use this skill when you need to:
- Forecast future values from temporal data
- Analyze patterns (trend, seasonality, cycles)
- Build ARIMA, ETS, or other forecasting models
- Evaluate forecast accuracy
- Make data-driven predictions about the future

## Invocation

**Manual**: `/r-timeseries`
**Automatic**: Mention "forecast", "ARIMA", "time series", "seasonal", "fable", "tsibble", etc.

## Quick Start

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

# 3. Fit models
fit <- ts_data |>
  model(
    ets = ETS(value),
    arima = ARIMA(value)
  )

# 4. Forecast
fc <- fit |> forecast(h = 12)
fc |> autoplot(ts_data)
```

## Key Features

### Model Coverage
- **Simple Methods**: MEAN, NAIVE, SNAIVE, Drift
- **Exponential Smoothing (ETS)**: Complete framework with automatic selection
- **ARIMA**: Automatic and manual specification, seasonal ARIMA
- **Regression**: TSLM, dynamic regression
- **Advanced**: Prophet, NNETAR, TBATS, VAR

### Complete Workflows
- Data preparation (tsibble conversion, gap handling)
- Exploration (time plots, seasonal plots, ACF/PACF)
- Model selection (information criteria, cross-validation)
- Diagnostics (residual checks, Ljung-Box test)
- Evaluation (accuracy metrics, prediction intervals)

### Best Practices
- Model pluralism (fit multiple, compare)
- Proper cross-validation (time series aware)
- Residual diagnostics
- Forecast uncertainty quantification
- Performance monitoring

## Contents

### Main Skill File
- **SKILL.md**: Complete forecasting guide with decision frameworks

### References
- **forecasting-methods.md**: Comprehensive model catalog
- **data-visualization.md**: Essential time series visualizations
- **forecast-evaluation.md**: Accuracy metrics and model selection

### Templates
- **forecasting-workflow.md**: Step-by-step workflow template

### Examples
- **retail-sales-forecast.md**: End-to-end example with business context

## Model Selection Guide

| Data Pattern | Recommended Models |
|--------------|-------------------|
| Flat | MEAN, NAIVE, ETS(A,N,N) |
| Trend only | Drift, ETS(A,A,N), ARIMA(0,1,0) |
| Seasonality only | SNAIVE, ETS(A,N,A), Seasonal ARIMA |
| Trend + Seasonality | ETS(A,A,A/M), Seasonal ARIMA |
| Multiple Seasonality | TBATS, Prophet |
| With External Predictors | Dynamic Regression, ARIMAX |

## Common Tasks

### Seasonal Decomposition
```r
data |>
  model(STL(value)) |>
  components() |>
  autoplot()
```

### Model Comparison
```r
fit |>
  accuracy() |>
  arrange(MASE)
```

### Time Series Cross-Validation
```r
ts_cv <- data |>
  stretch_tsibble(.init = 60, .step = 3)

cv_fit <- ts_cv |> model(ets = ETS(value))
cv_fc <- cv_fit |> forecast(h = 12)
cv_fc |> accuracy(data)
```

## Integration with Other Skills

- **r-datascience**: For data preparation and EDA
- **ggplot2**: For custom visualizations
- **r-style-guide**: For code formatting
- **tdd-workflow**: For testing forecast pipelines
- **r-performance**: For large-scale forecasting

## Resources

### External Documentation
- [Forecasting: Principles and Practice (FPP3)](https://otexts.com/fpp3/)
- [fable package documentation](https://fable.tidyverts.org/)
- [tsibble package documentation](https://tsibble.tidyverts.org/)

### Internal References
See `references/` directory for detailed guides on methods, visualization, and evaluation.

## Tips

✅ **Always** start with visualization (time plot, seasonal plot, ACF)
✅ **Always** check residual diagnostics
✅ **Always** compare multiple models
✅ **Always** use time series cross-validation for robust evaluation
✅ **Always** report prediction intervals, not just point forecasts

❌ **Never** use random train/test splits (breaks temporal order)
❌ **Never** skip residual diagnostics
❌ **Never** select model based solely on training fit
❌ **Never** ignore seasonality in data
❌ **Never** forget to handle missing values/gaps

## Version

1.0.0 - Initial release

## Feedback

For issues or suggestions, consult the main skill documentation or CLAUDE.md in the project root.
