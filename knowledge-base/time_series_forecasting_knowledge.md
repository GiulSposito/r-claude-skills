# Time Series Forecasting: Comprehensive Knowledge Base

*Extracted from "Forecasting: Principles and Practice" (3rd ed) - https://otexts.com/fpp3/*

## Table of Contents

1. [Foundations & Core Concepts](#foundations--core-concepts)
2. [Data Structures: tsibble](#data-structures-tsibble)
3. [Visualization & Exploration](#visualization--exploration)
4. [Time Series Features](#time-series-features)
5. [Transformations](#transformations)
6. [Decomposition Methods](#decomposition-methods)
7. [Simple Forecasting Methods](#simple-forecasting-methods)
8. [Exponential Smoothing (ETS)](#exponential-smoothing-ets)
9. [ARIMA Models](#arima-models)
10. [Regression Models](#regression-models)
11. [Dynamic Regression](#dynamic-regression)
12. [Advanced Methods](#advanced-methods)
13. [Hierarchical Forecasting](#hierarchical-forecasting)
14. [Model Diagnostics](#model-diagnostics)
15. [Forecast Evaluation](#forecast-evaluation)
16. [Practical Issues](#practical-issues)

---

## Foundations & Core Concepts

### What Makes Forecasting Predictable?

Four key factors determine forecast reliability:

1. **Understanding of Contributing Factors**: How well we comprehend drivers
2. **Data Availability**: Sufficient historical observations
3. **Historical Continuity**: Future resembles past patterns
4. **Forecast Independence**: Predictions don't influence outcomes

**Example - Good Conditions**: Short-term electricity demand (known temperature/calendar effects, extensive data, stable patterns, no self-fulfilling dynamics)

**Example - Poor Conditions**: Currency exchange rates (limited understanding, crisis risk, self-fulfilling prophecies)

### Key Principle

> "Good forecasts capture the genuine patterns and relationships which exist in the historical data, but do not replicate past events that will not occur again."

### R Ecosystem

The FPP3 approach uses three core packages:

- **tsibble**: Time series data structures
- **fable**: Forecasting models and workflows
- **feasts**: Feature extraction and statistics

---

## Data Structures: tsibble

### What is a tsibble?

A tsibble extends tidy data frames with temporal structure, containing:

1. **Index variable**: Time dimension (when observations occurred)
2. **Key variables**: Identifiers for multiple series
3. **Values**: Measured observations

### Creating tsibbles

**Basic creation:**
```r
library(tsibble)

y <- tsibble(
  Year = 2015:2019,
  Observation = c(123, 39, 78, 52, 110),
  index = Year
)
```

**Time class functions by frequency:**

| Frequency | Function |
|-----------|----------|
| Annual | `start:end` |
| Quarterly | `yearquarter()` |
| Monthly | `yearmonth()` |
| Weekly | `yearweek()` |
| Daily | `as_date()`, `ymd()` |
| Sub-daily | `as_datetime()`, `ymd_hms()` |

**Converting from CSV:**
```r
library(tidyverse)
library(lubridate)

prison <- read_csv("file.csv") |>
  mutate(Quarter = yearquarter(Date)) |>
  select(-Date) |>
  as_tsibble(
    key = c(State, Gender, Legal),
    index = Quarter
  )
```

### Key Variables for Multiple Series

Keys enable storing related time series in one object:

```r
# Example: Olympic running records
# Keys: Length, Sex
# Creates 14 distinct series within one tsibble
```

### Working with tsibbles

**Filtering & selecting:**
```r
PBS |>
  filter(ATC2 == "A10") |>
  select(Month, Concession, Type, Cost)
```

**Aggregation:**
```r
PBS |>
  filter(ATC2 == "A10") |>
  summarise(TotalC = sum(Cost))
```

**Creating variables:**
```r
data |>
  mutate(Cost_millions = TotalC / 1e6)
```

### Seasonal Periods

The seasonal period indicates observations before pattern repeats:

- **Quarterly**: 4 per year
- **Monthly**: 12 per year
- **Weekly**: 52.18 per year (accounting for leap years)
- **Daily**: 7 (weekly) or 365.25 (annually)

System typically auto-detects from index variable.

---

## Visualization & Exploration

### Core Principle

> "The first thing to do in any data analysis task is to plot the data."

Graphs reveal patterns, unusual observations, changes over time, and relationships between variables.

### Time Plots

Basic temporal visualization:

```r
library(fabletools)

data |> autoplot(variable)
```

### Seasonal Plots

**gg_season()** displays data against individual seasons, overlaying multiple years:

```r
# Basic seasonal plot
data |> gg_season(variable, labels = "both")

# Multiple seasonal periods
vic_elec |> gg_season(Demand, period = "day")
vic_elec |> gg_season(Demand, period = "week")
vic_elec |> gg_season(Demand, period = "year")
```

**Interpretation**: Reveals consistent seasonal patterns and years where patterns change. Example: January spikes in drug sales reveal customer stockpiling behavior.

### Seasonal Subseries Plots

Decomposed views of each season separately.

### Scatterplots

Relationship analysis between variables.

### Lag Plots

Temporal dependencies visualization.

### Autocorrelation Function (ACF)

**Definition**: Measures linear relationship between lagged values of a time series.

**Formula:**
```
r_k = Σ(y_t - ȳ)(y_{t-k} - ȳ) / Σ(y_t - ȳ)²
```

**Interpretation patterns:**

- **Trend**: Large positive autocorrelations at small lags (nearby observations similar in value)
- **Seasonality**: Elevated autocorrelations at seasonal lag multiples
- **Combined**: Slow decrease (trend) with scalloped shape (seasonality)
- **White noise**: All autocorrelations near zero

**R implementation:**
```r
library(feasts)

# Calculate ACF
data |> ACF(variable, lag_max = 48)

# Visualize
data |>
  ACF(Cost, lag_max = 48) |>
  autoplot() +
  labs(title = "Autocorrelation plot")
```

---

## Time Series Features

Features are numerical summaries that characterize time series properties.

### Using the feasts Package

**Feature Extraction And Statistics for Time Series**

```r
library(feasts)

# Extract features
tourism |>
  features(Trips, feature_set(pkgs = "feasts"))
```

### Categories of Features

1. **Simple statistics**: Mean, variance, quantiles
2. **ACF features**: Characteristics from autocorrelation analysis
3. **STL features**: Properties from seasonal decomposition
4. **Other features**: Custom analytical measures

### Use Cases

- Characterizing large collections of time series
- Identifying unusual series
- Clustering similar series
- Selecting appropriate models

---

## Transformations

### Purpose

Transform data when "variation increases or decreases with the level of the series" to:

- Stabilize variance
- Simplify patterns
- Improve forecast accuracy

### Box-Cox Transformations

Unified family including logarithms and power transformations, controlled by parameter λ:

- **λ = 0**: Natural logarithm
- **λ = 1**: No transformation (shift only)
- **Other values**: Power transformations with scaling

**Automatic lambda selection:**
```r
# Guerrero method - selects λ to make seasonal variation constant
data |>
  features(variable, features = guerrero)
```

### Logarithmic Transforms

Convert absolute changes to relative (percentage) changes.

**Requirements**:
- All values must be positive
- "If any value is zero or negative, logarithms are not possible"

### When to Use Transformations

- Heteroscedastic data (non-constant variance)
- Variation proportional to level
- Multiplicative seasonality

### Back-Transformation

Simpler patterns from transformations "lead to more accurate forecasts."

**Important**: Account for bias when back-transforming point forecasts.

---

## Decomposition Methods

### Core Concept

Break time series into three primary components:

1. **Trend-cycle (T)**: Long-term movement and cycles
2. **Seasonal (S)**: Recurring patterns
3. **Remainder (R)**: Everything else

For high-frequency data, multiple seasonal components may exist.

### Additive vs Multiplicative

**Additive**: y = T + S + R (constant seasonal variation)
**Multiplicative**: y = T × S × R (proportional seasonal variation)

### Classical Decomposition (NOT RECOMMENDED)

Traditional 1920s approach with significant limitations:

**Process:**
1. Calculate trend using moving averages
2. Remove trend from data
3. Average by season, adjust to sum appropriately
4. Calculate remainders

**Limitations:**
- Missing edge values (no trend estimate for first/last observations)
- Over-smoothing of rapid changes
- Rigid seasonality (assumes constant across years)
- Sensitivity to outliers

> "While classical decomposition is still widely used, it is not recommended, as there are now several much better methods."

### STL Decomposition (RECOMMENDED)

**STL = Seasonal and Trend decomposition using Loess**

**Advantages over classical methods:**
- Handles any seasonal pattern type
- Seasonality can change over time
- Customizable trend smoothness
- Robust to outliers

**Key parameters:**

- **Trend window** (`trend(window = ?)`): Consecutive observations for trend estimation
  - Default: 21 for monthly data
  - Smaller = faster changes

- **Seasonal window** (`season(window = ?)`): Consecutive years for seasonal estimation
  - Default: 11
  - `"periodic"` = fixed seasonality

**R implementation:**
```r
us_retail_employment |>
  model(
    STL(Employed ~ trend(window = 7) +
                   season(window = "periodic"),
        robust = TRUE)
  ) |>
  components() |>
  autoplot()
```

**Handling multiplicative data:**
- Log-transform first
- Apply STL
- Back-transform components
- Box-Cox (0 < λ < 1) for intermediate solutions

### Forecasting with Decomposition

**Workflow:**
1. Decompose series using STL
2. Forecast seasonally adjusted data
3. Forecast seasonal component (usually seasonal naive)
4. Recombine forecasts

```r
# Example workflow
fit <- data |>
  model(
    stlf = decomposition_model(
      STL(variable),
      ETS(season_adjust ~ season("N"))
    )
  )

fc <- fit |> forecast(h = 24)
```

---

## Simple Forecasting Methods

These serve as benchmarks - any new method should beat these simple alternatives.

### 1. Mean Method

**Formula**: ŷ(T+h|T) = ȳ = (y₁ + ... + y_T)/T

**Description**: All forecasts equal historical average

**Use**: Baseline comparison, rarely optimal

```r
fit <- data |> model(MEAN(variable))
```

### 2. Naive Method

**Formula**: ŷ(T+h|T) = y_T

**Description**: All forecasts equal last observed value (random walk)

**Use**: Economic/financial series; optimal when data follow random walk

```r
fit <- data |> model(NAIVE(variable))
# or
fit <- data |> model(RW(variable))
```

### 3. Seasonal Naive

**Formula**: ŷ(T+h|T) = y(T+h-m(k+1))

Where m = seasonal period, k = complete years before forecast

**Description**: Each forecast equals last value from same season

**Use**: Highly seasonal data with repeating patterns

```r
fit <- data |> model(SNAIVE(variable))
```

### 4. Drift Method

**Formula**: ŷ(T+h|T) = y_T + h × (y_T - y₁)/(T-1)

**Description**: Forecasts increase/decrease based on average historical change

**Use**: Trending non-seasonal data

```r
fit <- data |> model(RW(variable ~ drift()))
```

---

## Exponential Smoothing (ETS)

### Core Concept

> "Forecasts produced using exponential smoothing methods are weighted averages of past observations, with the weights decaying exponentially as the observations get older."

### Simple Exponential Smoothing (SES)

For data with no trend or seasonality.

**Forecast equation**: ŷ(t+h|t) = ℓ_t
**Smoothing equation**: ℓ_t = αy_t + (1-α)ℓ(t-1)

Where α is the smoothing parameter (0 < α < 1).

```r
fit <- data |> model(ETS(variable ~ error("A") + trend("N") + season("N")))
# or simply
fit <- data |> model(ETS(variable ~ trend("N") + season("N")))
```

### Holt's Linear Trend Method

For data with trend but no seasonality.

**Forecast equation**: ŷ(t+h|t) = ℓ_t + hb_t
**Level equation**: ℓ_t = αy_t + (1-α)(ℓ(t-1) + b(t-1))
**Trend equation**: b_t = β*(ℓ_t - ℓ(t-1)) + (1-β*)b(t-1)

### Damped Trend Method

Dampens trend to flat line for long-term forecasts.

**Forecast equation**: ŷ(t+h|t) = ℓ_t + (φ + φ² + ... + φ^h)b_t

Where φ is damping parameter (0.8 < φ < 0.98).

```r
fit <- data |> model(ETS(variable ~ trend("Ad")))
```

### Holt-Winters Seasonal Methods

**Additive seasonality** (constant seasonal variation):
```r
fit <- data |> model(ETS(variable ~ trend("A") + season("A")))
```

**Multiplicative seasonality** (proportional to level):
```r
fit <- data |> model(ETS(variable ~ trend("A") + season("M")))
```

### ETS Framework

Systematic approach organizing exponential smoothing methods by:

- **Error type**: Additive (A) or Multiplicative (M)
- **Trend type**: None (N), Additive (A), Additive damped (Ad)
- **Seasonal type**: None (N), Additive (A), Multiplicative (M)

**Notation**: ETS(Error, Trend, Seasonal)

Examples:
- ETS(A,N,N) = Simple exponential smoothing
- ETS(A,A,N) = Holt's linear method
- ETS(A,Ad,N) = Damped trend
- ETS(A,A,A) = Additive Holt-Winters
- ETS(M,A,M) = Multiplicative Holt-Winters

### Automatic Model Selection

```r
# Automatic selection via AICc
fit <- data |> model(ETS(variable))

# View selected model
report(fit)
```

### Parameter Estimation

- Parameters estimated by **maximizing likelihood**
- Smoothing parameters (α, β, γ, φ) constrained for stability
- Initial states estimated simultaneously
- Damping parameter restricted to 0.8 < φ < 0.98

### Model Selection Criteria

**AICc** (preferred): AIC + 2k(k+1)/(T-k-1)
**AIC**: -2log(L) + 2k
**BIC**: AIC + k[log(T)-2]

Where k = total estimated parameters + initial states.

### Restrictions

Some combinations excluded due to instability:
- ETS(A,N,M), ETS(A,A,M), ETS(A,Ad,M) involve division by near-zero
- Multiplicative error requires strictly positive data

---

## ARIMA Models

### Core Concept

> "ARIMA models aim to describe the autocorrelations in the data."

While exponential smoothing models describe trend and seasonality, ARIMA models capture the autocorrelation structure.

### Stationarity

**Definition**: Statistical properties independent of observation time

**Characteristics:**
- No predictable long-term patterns
- Roughly horizontal time plot
- Constant variance
- Cyclic behavior acceptable (variable length cycles)

**Testing**: KPSS test (null hypothesis: data are stationary)

```r
# Determine required differences
data |> features(variable, unitroot_ndiffs)    # non-seasonal
data |> features(variable, unitroot_nsdiffs)   # seasonal
```

### Differencing

**First differencing**: y'_t = y_t - y(t-1)
**Second differencing**: y''_t = y'_t - y'(t-1)
**Seasonal differencing**: y'_t = y_t - y(t-m)

**Important**: "Applying more differences than required will induce false dynamics or autocorrelations that do not really exist."

```r
# Apply differencing
data |> mutate(diff_value = difference(variable))
data |> mutate(seasonal_diff = difference(variable, lag = 12))
```

### Autoregressive Models - AR(p)

Uses lagged values of the variable itself.

**Formula**: y_t = c + φ₁y(t-1) + φ₂y(t-2) + ... + φ_p y(t-p) + ε_t

**Stationarity constraints:**
- AR(1): -1 < φ₁ < 1
- AR(2): -1 < φ₂ < 1, φ₁ + φ₂ < 1, φ₂ - φ₁ < 1
- AR(p ≥ 3): Complex restrictions (auto-enforced)

**Identification**: PACF shows significant spikes at lags 1 to p

### Moving Average Models - MA(q)

Uses past forecast errors rather than past values.

**Formula**: y_t = c + ε_t + θ₁ε(t-1) + θ₂ε(t-2) + ... + θ_q ε(t-q)

**Invertibility constraints:**
- MA(1): -1 < θ₁ < 1
- MA(2): -1 < θ₂ < 1 (plus additional conditions)

**Identification**: ACF shows significant spikes at lags 1 to q

**Important**: MA models differ from MA smoothing - models forecast, smoothing estimates trend.

### ARIMA(p,d,q) Models

**Notation:**
- p = AR order
- d = differencing order
- q = MA order

**Full model**: After d differences, fit ARMA(p,q)

### Seasonal ARIMA

**Notation**: ARIMA(p,d,q)(P,D,Q)_m

- (p,d,q) = non-seasonal parameters
- (P,D,Q) = seasonal parameters
- m = seasonal period

**Example**: ARIMA(2,1,0)(1,1,1)₁₂ for monthly data with trend and seasonality

**Model identification:**
1. Apply seasonal differencing first if needed
2. Apply first differencing if still non-stationary
3. Examine ACF/PACF at seasonal lags
4. Minimize AICc for final parameter selection

### ARIMA in fable

**Automatic model selection:**
```r
fit <- data |> model(ARIMA(variable))

# View selected model
report(fit)
```

**Manual specification:**
```r
fit <- data |>
  model(
    arima210 = ARIMA(variable ~ pdq(2,1,0)),
    sarima = ARIMA(variable ~ pdq(1,0,1) + PDQ(1,1,1))
  )
```

**Search options:**
```r
# Exhaustive search (slower, potentially better)
fit <- data |> model(ARIMA(variable, stepwise = FALSE))

# Include/exclude constant
fit <- data |> model(
  with_constant = ARIMA(variable ~ 1 + pdq(1,1,1)),
  no_constant = ARIMA(variable ~ 0 + pdq(1,1,1))
)
```

**Hyndman-Khandakar algorithm:**
1. Use KPSS tests to determine d
2. Test four baseline models
3. Stepwise search of neighboring models by varying p, q by ±1
4. Select model with lowest AICc

---

## Regression Models

### Time Series Linear Model (TSLM)

**Core concept**: Forecast variable y has linear relationship with predictor variables x.

**Formula**: y_t = β₀ + β₁x(1,t) + ... + β_k x(k,t) + ε_t

### Common Predictors

**Trend**:
```r
fit <- data |> model(TSLM(variable ~ trend()))
```

**Seasonality** (dummy variables):
```r
fit <- data |> model(TSLM(variable ~ season()))
```

**Combined**:
```r
fit <- data |> model(TSLM(variable ~ trend() + season()))
```

**External variables**:
```r
fit <- data |> model(TSLM(Sales ~ Advertising + trend() + season()))
```

### Forecasting with Regression

**Critical requirement**: Future values of predictors must be known or forecasted.

```r
# Create future scenarios
future_data <- new_data(data, 12) |>
  mutate(Advertising = c(10, 12, 15, ...))

# Generate forecasts
fc <- fit |> forecast(new_data = future_data)
```

### Model Evaluation

```r
# Model summary
report(fit)

# Check R-squared, adjusted R-squared
glance(fit)

# Residual diagnostics (see Model Diagnostics section)
augment(fit) |> gg_tsresiduals()
```

---

## Dynamic Regression

### Concept

Combines regression with ARIMA error structure, addressing two limitations:
- ARIMA lacks external variable capacity
- Standard regression can't handle time series dynamics

**Model structure**: y_t = β₀ + β₁x(1,t) + ... + β_k x(k,t) + η_t

Where η_t follows ARIMA process (not white noise).

**Dual error terms:**
- η_t: regression residuals (ARIMA process)
- ε_t: ARIMA errors (white noise)

### Regression with ARIMA Errors

```r
fit <- data |>
  model(
    ARIMA(Demand ~ Temperature + WorkingDay +
          pdq(2,0,0) + PDQ(2,1,0))
  )
```

**Automatic error structure:**
```r
fit <- data |> model(ARIMA(Demand ~ Temperature + WorkingDay))
```

### Harmonic Regression

Uses Fourier terms to model seasonality:

**Fourier terms**: sin(2πkt/m), cos(2πkt/m)

```r
# Single seasonal pattern
fit <- data |>
  model(
    ARIMA(variable ~ fourier(K = 5) + PDQ(0,0,0))
  )

# Multiple seasonal patterns
fit <- data |>
  model(
    ARIMA(Demand ~
          fourier(period = 24, K = 10) +
          fourier(period = 168, K = 5) +
          Temperature + pdq(d=0) + PDQ(0,0,0))
  )
```

**K selection**: Choose via AICc or cross-validation

### Lagged Predictors

```r
# Include lagged values
fit <- data |>
  model(
    ARIMA(Sales ~ lag(Advertising, 1) + lag(Advertising, 2))
  )
```

### Advantages

- Captures complex relationships
- Handles serial correlation in errors
- Incorporates external information
- Flexible seasonal patterns

---

## Advanced Methods

### Complex Seasonality

**Challenges**: Multiple seasonal patterns (daily, weekly, annual) common in hourly/daily data.

**Solutions:**

**1. STL with multiple seasonality:**
```r
fit <- data |>
  model(
    STL(Demand ~
        season(period = 24) +
        season(period = 168) +
        season(period = 8766))
  )
```

**2. Dynamic harmonic regression:**
```r
fit <- data |>
  model(
    ARIMA(Demand ~
          fourier(period = 24, K = 10) +
          fourier(period = 168, K = 5) +
          fourier(period = 8766, K = 3) +
          Temperature +
          pdq(d=0) + PDQ(0,0,0))
  )
```

### Prophet Model

**Components:**
1. **Trend**: Piecewise-linear with automatic changepoints or logistic growth
2. **Seasonality**: Fourier terms (default order 10 annual, 3 weekly)
3. **Holidays**: Dummy variables

**Formula**: y = g(t) + s(t) + h(t) + ε

**When to use**: Strong seasonality, multiple historical seasons, daily observations

**Advantages:**
- Fully automated
- Fast estimation
- Handles missing data and outliers

**Limitations:**
- Often underperforms ARIMA/ETS
- Can produce residual autocorrelation
- Piecewise-linear may be inappropriate

```r
library(fable.prophet)

fit <- data |>
  model(
    prophet(Demand ~ Temperature + Working_Day +
            season(period = "day", order = 10) +
            season(period = "week", order = 3))
  )
```

### Neural Network Autoregression (NNETAR)

**Structure**: Feed-forward neural network with lagged inputs

**Notation**: NNAR(p,k) or NNAR(p,P,k)_m
- p = number of lagged inputs
- P = number of seasonal lagged inputs
- k = nodes in hidden layer
- m = seasonal period

**Default**: k = (p + P + 1)/2

**Advantages:**
- Captures complex nonlinear relationships
- Robust to outliers (sigmoid activation)
- No distributional assumptions

**Limitations:**
- Computationally intensive
- Prediction intervals via simulation only
- Can overfit with insufficient data

```r
# Automatic specification
fit <- data |> model(NNETAR(variable))

# Manual specification
fit <- data |> model(NNETAR(variable ~ AR(p = 12, P = 1)))

# Forecasting (averages multiple networks)
fc <- fit |> forecast(h = 24)
```

**Multi-step forecasts**: Iterative one-step predictions

**Prediction intervals**: Bootstrap simulations

### Vector Autoregression (VAR)

**Purpose**: Model multiple related time series simultaneously with bidirectional relationships.

**Structure**: Each variable regressed on lagged values of all system variables.

**Two-variable VAR(1) example:**
- y(1,t) = c₁ + φ(11,1)y(1,t-1) + φ(12,1)y(2,t-1) + ε(1,t)
- y(2,t) = c₂ + φ(21,1)y(1,t-1) + φ(22,1)y(2,t-1) + ε(2,t)

**When to use:**
- Forecasting multiple related variables
- Testing Granger causality
- Impulse response analysis
- Variance decomposition

**Parameter count**: K + pK² (where K = variables, p = lags)

**Lag selection**: BIC preferred (AICc tends toward too many lags)

```r
# VAR model
fit <- data |>
  model(VAR(vars(var1, var2, var3)))

# Specify lag order
fit <- data |>
  model(VAR(vars(var1, var2) ~ AR(3)))
```

### Bootstrapping & Bagging

**Residual bootstrapping**: Resample errors to generate prediction intervals

**Block bootstrap**: Preserve autocorrelation by resampling contiguous blocks

**Bagging** (Bootstrap AGGregatING):
1. Create multiple bootstrapped versions of data
2. Fit model to each
3. Average forecasts

**Advantage**: Improved accuracy vs direct fitting

```r
# Bagged ETS
fit <- data |>
  model(ETS(variable)) |>
  generate(h = 24, times = 100, bootstrap = TRUE)

# Aggregate
fc <- fit |>
  as_tibble() |>
  group_by(.model, index) |>
  summarise(.mean = mean(.sim))
```

---

## Hierarchical Forecasting

### Concept

Collections of time series with coherent aggregation structures require forecasts that "add up in a manner consistent with the aggregation structure."

### Structures

1. **Hierarchical**: Nested disaggregation (e.g., total → regions → stores)
2. **Grouped**: Crossed attributes (e.g., product type × location)
3. **Mixed**: Both nested and crossed

### Traditional Approaches

**Bottom-up**: Forecast lowest level, aggregate upward
- Unbiased
- Ignores higher-level information
- Can be noisy

**Top-down**: Forecast top level, disaggregate with proportions
- Biased
- Simple
- Loss of lower-level detail

**Middle-out**: Combine both approaches from middle level

### Optimal Reconciliation: MinT

**Minimum Trace** approach finds optimal weighting to minimize total forecast variance.

**Formula**: Ỹ_h = S(S'W_h⁻¹S)⁻¹S'W_h⁻¹Ŷ_h

Uses information from all levels simultaneously.

**Variants:**

1. **OLS** (`method = "ols"`): Equal error variance
2. **WLS variance** (`method = "wls_var"`): Scale by residual variance
3. **WLS structural** (`method = "wls_struct"`): Scale by aggregation structure
4. **MinT covariance** (`method = "mint_cov"` or `"mint_shrink"`): Full covariance matrix

```r
library(fabletools)

# Create forecasts at all levels
fc <- tourism |>
  aggregate_key(State / Region / Purpose, Trips = sum(Trips)) |>
  model(ETS(Trips)) |>
  forecast(h = 4)

# Reconcile
fc_reconciled <- fc |>
  reconcile(
    bu = bottom_up(ETS),
    ols = min_trace(ETS, method = "ols"),
    mint = min_trace(ETS, method = "mint_shrink")
  )
```

---

## Model Diagnostics

### Fitted Values and Residuals

**Fitted values** (ŷ(t|t-1)): One-step-ahead forecasts using all prior observations

**Residuals**: e_t = y_t - ŷ_t

**Innovation residuals**: Account for transformations

```r
# Extract fitted values and residuals
augmented <- fit |> augment()

# Columns: .fitted, .resid, .innov
```

### Essential Properties

Good forecasting method produces residuals with:

1. **Uncorrelated** - No information left to use
2. **Zero mean** - Forecasts unbiased

### Desirable Properties

3. **Constant variance** (homoscedastic) - Easier prediction intervals
4. **Normal distribution** - Simpler interval estimation

### Visual Diagnostics

**Automated plot:**
```r
fit |> gg_tsresiduals()
```

Creates three plots:
1. Time plot of residuals (check variance stability)
2. ACF plot (check autocorrelation)
3. Histogram (check distribution)

**Manual approach:**
```r
augmented <- fit |> augment()

# Time plot
augmented |> autoplot(.innov)

# ACF
augmented |> ACF(.innov) |> autoplot()

# Histogram
augmented |> ggplot(aes(.innov)) + geom_histogram()
```

### Formal Tests

**Ljung-Box test**: Tests group of autocorrelations

**Statistic**: Q* = T(T+2) Σ (T-k)⁻¹r_k²

**Implementation:**
```r
# Test residuals
fit |> augment() |> features(.innov, ljung_box, lag = 10)
```

**Interpretation**: Large p-value (> 0.05) indicates residuals resemble white noise.

### Complete Diagnostic Workflow

```r
# 1. Fit model
fit <- data |> model(ARIMA(variable))

# 2. Visual diagnostics
fit |> gg_tsresiduals()

# 3. Ljung-Box test
fit |> augment() |> features(.innov, ljung_box, lag = 10, dof = 2)

# 4. If problems found, revise model
```

**Note**: dof parameter equals number of model parameters estimated.

---

## Forecast Evaluation

### Training and Test Sets

**Time series cross-validation**: Rolling forecasting origin evaluation

```r
# Create rolling training sets
cv <- data |>
  stretch_tsibble(.init = 36, .step = 1)

# Fit and forecast
fc_cv <- cv |>
  model(ARIMA(variable)) |>
  forecast(h = 1)

# Calculate accuracy
fc_cv |> accuracy(data)
```

### Forecast Accuracy Measures

#### Scale-Dependent (same units)

**MAE (Mean Absolute Error)**:
- Average absolute errors
- Interpretable
- Minimizing MAE produces median forecasts

**RMSE (Root Mean Squared Error)**:
- Square root of mean squared errors
- Minimizing RMSE produces mean forecasts
- Penalizes large errors more heavily

#### Percentage Errors (unit-free)

**MAPE (Mean Absolute Percentage Error)**:
- Percentage errors
- Problematic near zero
- Assumes meaningful zero point

**sMAPE (Symmetric MAPE)**:
- Attempts symmetric penalization
- Still unstable near zero
- NOT RECOMMENDED

#### Scaled Errors (RECOMMENDED)

**MASE (Mean Absolute Scaled Error)**:
- Scales errors using naive benchmark from training data
- Values < 1 indicate better than naive
- Suitable for cross-series comparison
- RECOMMENDED

**RMSSE (Root Mean Squared Scaled Error)**:
- Squared error version
- Similar properties to MASE

### Implementation

```r
# Single test set
accuracy(fc, test_data)

# Automatic extraction of test period
fc |> accuracy(full_data)

# Compare multiple models
fits |>
  forecast(h = 12) |>
  accuracy(test_data)
```

### Model Selection Criteria (Training Data)

**AIC**: -2log(L) + 2k
**AICc**: AIC + 2k(k+1)/(T-k-1) [RECOMMENDED for small samples]
**BIC**: AIC + k[log(T) - 2]

```r
# Compare models
fits |> glance() |> arrange(AICc)
```

### When to Use Each

- **MAE**: Single series, interpretability important
- **MASE**: Cross-series comparison, default choice
- **AICc**: Model selection on training data
- **Cross-validation**: Final model selection, realistic performance

---

## Practical Issues

### Weekly and Daily Data

**Weekly challenge**: Seasonal period non-integer (52.18 weeks/year)

**Solutions:**
1. STL decomposition
2. Dynamic harmonic regression
3. Prophet model

```r
# Dynamic harmonic regression for weekly
fit <- data |>
  model(
    ARIMA(variable ~ fourier(K = 5) + PDQ(0,0,0))
  )
```

**Daily/sub-daily**: Multiple seasonal patterns

**Moving holidays**: Easter, Chinese New Year

```r
# Include holiday dummy variables
fit <- data |>
  model(
    ARIMA(Sales ~ holiday_indicator + pdq() + PDQ())
  )
```

### Count Time Series

**When standard methods work**: Counts ≥ 100

**When specialized methods needed**: Small counts, many zeros (intermittent demand)

**Croston's method**: Separate exponential smoothing for:
- Non-zero quantities
- Inter-arrival times

```r
library(fable)

fit <- data |> model(CROSTON(variable))
```

**Limitations**:
- Biased forecasts
- No prediction intervals
- No formal statistical model

**Better alternatives**: Poisson models for true count data

### Missing Values and Outliers

**Outlier detection**:
```r
# Using STL
outliers <- data |>
  model(STL(variable ~ robust = TRUE)) |>
  components() |>
  filter(abs(remainder) > 3 * IQR(remainder))
```

**Outlier treatment**:
- Investigate why they occurred (may contain valuable information)
- Replace with ARIMA-interpolated values if genuine errors
- Don't simply delete

**Missing value handling**:

**Methods that handle gaps**:
- Naive methods
- ARIMA
- Dynamic regression
- Neural networks

**Methods requiring complete data**:
- ETS
- STL

**Interpolation**:
```r
# Fill gaps with ARIMA interpolation
data_filled <- data |>
  model(ARIMA(variable)) |>
  interpolate(data)
```

### Ensuring Positive Forecasts

**Problem**: Some data must be positive (prices, demand, counts)

**Solutions**:

1. **Transformation** (log, Box-Cox)
```r
fit <- data |> model(ETS(log(variable)))
```

2. **Model constraints** (multiplicative models)
```r
fit <- data |> model(ETS(variable ~ error("M")))
```

### Forecast Combinations

**Why combine**: Reduces risk, improves robustness, often better than individual models

**Simple average** (often best):
```r
# Fit multiple models
fits <- data |>
  model(
    ets = ETS(variable),
    arima = ARIMA(variable),
    nnetar = NNETAR(variable)
  )

# Forecast
fc <- fits |> forecast(h = 12)

# Average forecasts
fc_combo <- fc |>
  as_tibble() |>
  group_by(index) |>
  summarise(.mean = mean(.mean))
```

**Weighted combinations**: Use inverse of error variance

---

## Complete Workflow Example

```r
library(fpp3)

# 1. Load and visualize data
tourism |>
  filter(Region == "Snowy Mountains") |>
  autoplot(Trips)

# 2. Check features
tourism |>
  filter(Region == "Snowy Mountains") |>
  features(Trips, feat_stl)

# 3. Train/test split
train <- tourism |>
  filter(Region == "Snowy Mountains", Quarter < yearquarter("2015 Q1"))

test <- tourism |>
  filter(Region == "Snowy Mountains", Quarter >= yearquarter("2015 Q1"))

# 4. Fit multiple models
fits <- train |>
  model(
    naive = SNAIVE(Trips),
    ets = ETS(Trips),
    arima = ARIMA(Trips),
    snaive_decomp = decomposition_model(
      STL(Trips),
      SNAIVE(season_adjust)
    )
  )

# 5. Generate forecasts
fc <- fits |> forecast(h = 8)

# 6. Evaluate accuracy
accuracy(fc, test)

# 7. Residual diagnostics for best model
fits |>
  select(arima) |>
  gg_tsresiduals()

# 8. Final forecast
final_fit <- tourism |>
  filter(Region == "Snowy Mountains") |>
  model(ARIMA(Trips))

final_fc <- final_fit |> forecast(h = 12)

# 9. Plot forecast
final_fc |>
  autoplot(tourism |> filter(Region == "Snowy Mountains")) +
  labs(title = "Forecast: Snowy Mountains tourism",
       y = "Trips ('000)")
```

---

## Key Principles Summary

1. **Always start with plots** - visualize before modeling
2. **Use simple methods as benchmarks** - new methods must beat them
3. **Check residuals thoroughly** - uncorrelated, zero mean
4. **Use proper train/test splits** - or cross-validation
5. **Compare multiple models** - no single best method
6. **Prefer MASE for accuracy** - especially across series
7. **Transform when variance changes** - stabilize patterns
8. **Account for seasonality** - choose appropriate period
9. **Handle missing data carefully** - interpolate or use robust methods
10. **Consider forecast combinations** - often improve robustness

---

## Quick Reference: Method Selection

| Data Pattern | Recommended Methods |
|-------------|-------------------|
| No trend/seasonality | MEAN, NAIVE, ETS(A,N,N) |
| Trend, no seasonality | RW(drift), ETS(A,A,N), ARIMA(p,1,q) |
| Seasonality, no trend | SNAIVE, ETS(A,N,A), ARIMA(p,d,q)(P,D,Q) |
| Trend + seasonality | ETS(A,A,A), ARIMA(p,d,q)(P,D,Q) |
| Complex seasonality | Dynamic harmonic regression, Prophet |
| Multiple seasonality | STL + ETS, Dynamic regression |
| With external predictors | TSLM, Dynamic regression, Prophet |
| Nonlinear relationships | NNETAR, dynamic regression |
| Multiple related series | VAR |
| Hierarchical structure | Forecast + reconcile |
| Intermittent demand | CROSTON |
| Count data | Specialized count models |

---

## R Package Ecosystem

**Core packages:**
- `tsibble`: Time series data structures
- `fable`: Forecasting models
- `feasts`: Feature extraction and statistics
- `fabletools`: Forecasting workflow tools

**Additional packages:**
- `fable.prophet`: Prophet integration
- `lubridate`: Date/time handling
- `tidyverse`: Data manipulation and visualization

**Installation:**
```r
install.packages("fpp3")  # Includes all core packages
```

---

## Resources

- **Textbook**: https://otexts.com/fpp3/
- **Package docs**: https://fable.tidyverts.org/
- **Example data**: Built into fpp3 package
- **Community**: Tidyverts organization on GitHub

---

*This comprehensive knowledge base synthesizes content from "Forecasting: Principles and Practice" (3rd edition) by Rob J Hyndman and George Athanasopoulos, available at https://otexts.com/fpp3/*
