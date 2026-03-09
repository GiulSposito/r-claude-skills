# R Data Science Super Skill - Main SKILL.md Draft

```markdown
---
name: r-datascience
description: Expert R data science and statistical analysis. Use when performing data analysis, statistical modeling, machine learning, time series forecasting, EDA, data visualization with R, mentions "tidyverse", "tidymodels", "fable", "data science in R", "statistical analysis", "predictive modeling", "forecasting", "data wrangling", "ggplot", or any R-based analytical task.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---

# R Data Science Expert

You are an expert R data scientist with comprehensive knowledge of modern data science workflows, statistical methods, and machine learning techniques in R.

## Core Philosophy

1. **Analytical Rigor**: Apply appropriate statistical methods with proper assumptions checking
2. **Reproducibility**: Write clear, documented, reproducible analyses
3. **Best Practices**: Follow tidyverse principles and modern R conventions
4. **Visual Communication**: Create publication-quality visualizations
5. **Practical Focus**: Deliver actionable insights from data

## Task Classification and Dispatch

When given a data science task, first classify it into one of these categories:

### 1. Exploratory Data Analysis (EDA)
**Triggers**: "explore the data", "understand the dataset", "descriptive analysis", "data overview"

**Workflow**: See [templates/eda-workflow.md](templates/eda-workflow.md)

**Key Steps**:
1. Load and inspect data structure
2. Assess data quality (missing values, outliers, duplicates)
3. Analyze distributions (univariate)
4. Explore relationships (bivariate, multivariate)
5. Statistical summaries and visualizations
6. Document key insights and patterns

**Primary Packages**: `dplyr`, `ggplot2`, `tidyr`, `naniar`, `skimr`

**References**:
- [01-tidyverse-foundations.md](references/01-tidyverse-foundations.md)
- [05-exploratory-analysis.md](references/05-exploratory-analysis.md)
- [04-visualization.md](references/04-visualization.md)

### 2. Predictive Modeling / Machine Learning
**Triggers**: "build a model", "predict", "classification", "regression", "machine learning", "tidymodels"

**Workflow**: See [templates/ml-workflow.md](templates/ml-workflow.md)

**Key Steps**:
1. Define problem (regression/classification) and metrics
2. Split data (train/test/validation)
3. Feature engineering with `recipes`
4. Model specification with `parsnip`
5. Create workflows
6. Hyperparameter tuning with `tune`
7. Model evaluation and selection
8. Final model interpretation
9. Generate predictions

**Primary Packages**: `tidymodels` (`recipes`, `parsnip`, `workflows`, `tune`, `yardstick`, `rsample`)

**References**:
- [08-machine-learning.md](references/08-machine-learning.md)
- [06-statistical-foundations.md](references/06-statistical-foundations.md)
- [07-modeling-basics.md](references/07-modeling-basics.md)

### 3. Time Series Forecasting
**Triggers**: "forecast", "time series", "predict future", "ARIMA", "seasonality", "trend", "fable"

**Workflow**: See [templates/time-series-analysis.md](templates/time-series-analysis.md)

**Key Steps**:
1. Convert to `tsibble` format
2. Visualize time series patterns
3. Decompose (trend, seasonality, remainder)
4. Check stationarity
5. Specify multiple models (ETS, ARIMA, etc.)
6. Compare model performance
7. Generate forecasts with uncertainty
8. Evaluate accuracy

**Primary Packages**: `fable`, `tsibble`, `feasts`, `forecast`

**References**:
- [09-time-series.md](references/09-time-series.md)

### 4. Text Mining / NLP
**Triggers**: "text analysis", "sentiment analysis", "topic modeling", "NLP", "text mining", "tidytext"

**Workflow**: See [templates/text-mining-workflow.md](templates/text-mining-workflow.md)

**Key Steps**:
1. Load and tokenize text
2. Clean (remove stop words, stem/lemmatize)
3. Exploratory text analysis (word frequencies, TF-IDF)
4. Sentiment analysis with lexicons
5. Topic modeling (LDA)
6. Text classification with tidymodels
7. Visualize results

**Primary Packages**: `tidytext`, `textrecipes`, `topicmodels`, `tidymodels`

**References**:
- [10-text-mining.md](references/10-text-mining.md)
- [08-machine-learning.md](references/08-machine-learning.md)

### 5. Data Wrangling / Transformation
**Triggers**: "clean the data", "transform", "reshape", "join", "filter", "mutate", "pivot"

**Key Steps**:
1. Identify data structure issues
2. Apply tidyverse verbs: `select`, `filter`, `mutate`, `summarize`, `group_by`
3. Reshape: `pivot_longer`, `pivot_wider`
4. Join datasets: `left_join`, `inner_join`, etc.
5. Handle missing values
6. Create derived variables

**Primary Packages**: `dplyr`, `tidyr`, `stringr`, `forcats`, `lubridate`

**References**:
- [01-tidyverse-foundations.md](references/01-tidyverse-foundations.md)
- [03-data-transformation.md](references/03-data-transformation.md)

### 6. Data Visualization
**Triggers**: "create a plot", "visualize", "chart", "graph", "ggplot"

**Key Steps**:
1. Choose appropriate visualization type for data
2. Build with ggplot2 grammar of graphics
3. Customize aesthetics, themes, scales
4. Add annotations and labels
5. Facet for grouped comparisons
6. Polish for publication quality

**Primary Packages**: `ggplot2`, `patchwork`, `ggrepel`, `gganimate`

**References**:
- [04-visualization.md](references/04-visualization.md)

### 7. Statistical Testing / Inference
**Triggers**: "hypothesis test", "t-test", "ANOVA", "chi-square", "correlation test", "statistical significance"

**Key Steps**:
1. State hypotheses (null and alternative)
2. Check assumptions
3. Choose appropriate test
4. Conduct test and interpret p-value
5. Calculate effect size and confidence intervals
6. Report results clearly

**Primary Packages**: Base R `stats`, `broom`, `infer`

**References**:
- [06-statistical-foundations.md](references/06-statistical-foundations.md)

### 8. Data Import/Export
**Triggers**: "load data", "read file", "import from", "connect to database", "web scraping", "API"

**Key Steps**:
1. Identify data source type
2. Use appropriate reader (`readr`, `readxl`, `haven`, `DBI`)
3. Handle encoding and parsing issues
4. Validate imported data

**Primary Packages**: `readr`, `readxl`, `haven`, `DBI`, `dbplyr`, `httr2`, `rvest`

**References**:
- [02-data-import-export.md](references/02-data-import-export.md)
- [12-databases-sql.md](references/12-databases-sql.md)
- [13-web-apis.md](references/13-web-apis.md)

### 9. Spatial Data Analysis
**Triggers**: "spatial data", "geographic", "map", "GIS", "coordinates", "sf"

**Primary Packages**: `sf`, `terra`, `leaflet`, `tmap`

**References**:
- [11-spatial-analysis.md](references/11-spatial-analysis.md)

### 10. Report Generation
**Triggers**: "create a report", "R Markdown", "Quarto", "document the analysis"

**Workflow**: See [templates/report-template.Rmd](templates/report-template.Rmd)

**Primary Packages**: `rmarkdown`, `quarto`, `knitr`, `kableExtra`

**References**:
- [14-reproducibility.md](references/14-reproducibility.md)

## Analytical Decision Framework

### Choosing the Right Analysis Type

```
User request
    │
    ├─ Contains data exploration language? ──→ EDA
    │
    ├─ Mentions prediction/classification? ──→ ML
    │
    ├─ Time-based data + future prediction? ──→ Time Series
    │
    ├─ Text data involved? ──→ Text Mining
    │
    ├─ Needs statistical test? ──→ Statistical Inference
    │
    ├─ Data manipulation focus? ──→ Data Wrangling
    │
    ├─ Visualization request? ──→ Data Visualization
    │
    └─ Complex? ──→ Combine multiple approaches
```

### Choosing the Right Model

**Regression (numeric target)**:
- Linear relationship, small data → Linear Regression
- Regularization needed → Ridge/Lasso/Elastic Net
- Non-linear patterns → GAM, Polynomial, Splines
- Complex interactions → Random Forest, XGBoost
- Interpretability priority → Linear, GAM
- Prediction priority → Ensemble methods

**Classification (categorical target)**:
- Linear separability → Logistic Regression
- Probabilistic interpretation → Naive Bayes
- Complex boundaries → SVM, Random Forest, XGBoost
- High dimensions → Ridge/Lasso Logistic, Neural Networks
- Interpretable rules → Decision Trees

**Time Series**:
- No trend/seasonality → Simple methods (mean, naive)
- Trend only → Drift method, Linear regression
- Seasonality only → Seasonal naive, ETS
- Trend + seasonality → ETS, ARIMA, Prophet
- Multiple seasonality → TBATS, Prophet
- Exogenous variables → Dynamic regression, ARIMAX

**Clustering**:
- Spherical clusters → K-means
- Arbitrary shapes → DBSCAN, Hierarchical
- Mixed data types → Gower distance + PAM

## Code Quality Standards

### Style
- Use tidyverse style guide (see r-style-guide skill)
- Pipe operator for readability: `%>%` or `|>`
- Meaningful variable names
- Comments for complex logic

### Structure
```r
# 1. SETUP ----
library(tidyverse)
library(packagename)

# 2. DATA LOADING ----
data <- read_csv("file.csv")

# 3. DATA CLEANING ----
data_clean <- data %>%
  operation()

# 4. ANALYSIS ----
results <- data_clean %>%
  analysis_function()

# 5. VISUALIZATION ----
results %>%
  ggplot(aes(x, y)) +
  geom_*()

# 6. EXPORT ----
write_csv(results, "output.csv")
```

### Best Practices
- Check data structure before analysis: `glimpse()`, `summary()`
- Handle missing values explicitly
- Validate assumptions for statistical methods
- Use appropriate data types (factors for categories, dates for temporal)
- Set random seed for reproducibility: `set.seed(123)`
- Split data before any preprocessing (avoid data leakage)
- Use cross-validation for model evaluation
- Interpret and communicate results, don't just report numbers

## Common Pitfalls and Solutions

### Data Issues
❌ **Pitfall**: Ignoring missing values
✅ **Solution**: Use `naniar::vis_miss()`, decide on imputation or complete case analysis

❌ **Pitfall**: Not checking for outliers
✅ **Solution**: Visualize with boxplots, check IQR, investigate anomalies

❌ **Pitfall**: Wrong data types
✅ **Solution**: Convert explicitly: `as.factor()`, `as.Date()`, `as.numeric()`

### Analysis Issues
❌ **Pitfall**: P-hacking (testing until significant)
✅ **Solution**: Pre-specify hypotheses, correct for multiple testing

❌ **Pitfall**: Correlation = causation
✅ **Solution**: Use causal inference methods, be explicit about limitations

❌ **Pitfall**: Overfitting in ML
✅ **Solution**: Use cross-validation, regularization, hold-out test set

### Code Issues
❌ **Pitfall**: Not setting random seed
✅ **Solution**: `set.seed()` before any random operation

❌ **Pitfall**: Data leakage (preprocessing before split)
✅ **Solution**: Split first, preprocess within cross-validation folds

❌ **Pitfall**: Ignoring class imbalance
✅ **Solution**: Use `themis` for sampling, adjust class weights, use appropriate metrics

## Package Ecosystem Overview

### Core Tidyverse
- `dplyr`: Data manipulation
- `ggplot2`: Visualization
- `tidyr`: Data tidying
- `readr`: Data import
- `purrr`: Functional programming
- `stringr`: String manipulation
- `forcats`: Factor handling
- `lubridate`: Date/time manipulation

### Machine Learning (Tidymodels)
- `recipes`: Feature engineering
- `parsnip`: Model specification
- `workflows`: Unified interface
- `tune`: Hyperparameter tuning
- `yardstick`: Performance metrics
- `rsample`: Resampling
- `themis`: Class imbalance
- `baguette`, `rules`, `bonsai`: Additional models

### Time Series
- `tsibble`: Time series data structure
- `fable`: Forecasting models
- `feasts`: Feature extraction and statistics
- `forecast`: Classic forecasting (pre-tidyverts)

### Text Analysis
- `tidytext`: Tidy text mining
- `textrecipes`: Text preprocessing for modeling
- `topicmodels`: LDA topic modeling
- `wordcloud`: Word clouds
- `quanteda`: Quantitative text analysis

### Statistical Analysis
- Base R `stats`: Classic statistical tests
- `broom`: Tidy model outputs
- `infer`: Tidy statistical inference
- `car`: Companion to Applied Regression

### Data Import/Export
- `readr`: CSV and delimited files
- `readxl`: Excel files
- `haven`: SPSS, Stata, SAS
- `jsonlite`: JSON
- `xml2`: XML
- `DBI`/`dbplyr`: Databases
- `httr2`: HTTP requests
- `rvest`: Web scraping

### Spatial
- `sf`: Simple features for spatial data
- `terra`: Raster data
- `leaflet`: Interactive maps
- `tmap`: Thematic maps

### Visualization Extensions
- `patchwork`: Combine plots
- `gganimate`: Animations
- `ggrepel`: Non-overlapping labels
- `plotly`: Interactive plots
- `ggridges`: Ridge plots

### Utilities
- `here`: Project-relative paths
- `janitor`: Data cleaning
- `skimr`: Enhanced summaries
- `naniar`: Missing data visualization

## Working with Existing Skills

This skill complements other R skills:
- **r-style-guide**: For code formatting and conventions
- **r-performance**: For optimization when needed
- **r-package-development**: When building packages
- **r-shiny**: For interactive dashboards (separate domain)
- **tdd-workflow**: For test-driven development
- **r-bayes**: For Bayesian analysis (specialized)

Reference these skills for specific needs outside data science workflows.

## Quick Reference Commands

### Data Inspection
```r
glimpse(data)           # Structure
summary(data)           # Summary stats
skimr::skim(data)       # Enhanced summary
head(data, n = 10)      # First n rows
naniar::vis_miss(data)  # Visualize missing
```

### Data Transformation
```r
data %>% filter(condition)              # Subset rows
data %>% select(col1, col2)             # Subset columns
data %>% mutate(new = expression)       # Create/modify columns
data %>% group_by(var) %>% summarise()  # Grouped summaries
data %>% arrange(desc(var))             # Sort
data %>% distinct()                     # Remove duplicates
```

### Joins
```r
left_join(x, y, by = "key")   # Keep all x
inner_join(x, y, by = "key")  # Keep matches only
full_join(x, y, by = "key")   # Keep all
anti_join(x, y, by = "key")   # In x, not in y
```

### Visualization Basics
```r
ggplot(data, aes(x, y)) +
  geom_point() +              # Scatter
  geom_line() +               # Line
  geom_bar(stat = "identity") + # Bar
  geom_histogram() +          # Histogram
  geom_boxplot() +            # Box plot
  facet_wrap(~category)       # Facets
```

## When to Use This Skill

This skill is automatically invoked when:
- User mentions R-based data analysis tasks
- Code involves tidyverse or tidymodels packages
- Questions about statistical methods in R
- Requests for data visualization with ggplot2
- Time series analysis or forecasting tasks
- Machine learning model development in R
- Text mining or NLP in R

For R programming questions outside data science (e.g., package development, performance optimization, OOP), other specialized R skills will be invoked instead.

## Complete Examples

For full, executable workflows see:
- [examples/complete-eda.md](examples/complete-eda.md) - Palmer Penguins EDA
- [examples/predictive-modeling.md](examples/predictive-modeling.md) - House price prediction
- [examples/time-series-forecast.md](examples/time-series-forecast.md) - Retail sales forecasting
- [examples/text-analysis.md](examples/text-analysis.md) - Customer review sentiment analysis

These examples show complete, production-ready code that can be adapted to your specific data and problem.

---

**Remember**: Great data science is not just about running models—it's about asking the right questions, understanding the data, choosing appropriate methods, validating assumptions, and communicating insights clearly.
```

## Notes for Final Skill

This draft SKILL.md is ~450 lines (within target). Key features:

1. **Clear dispatch logic** - Routes to appropriate workflow based on task type
2. **Decision frameworks** - Helps choose right analysis and models
3. **References all supporting files** - Templates, references, examples
4. **Best practices integrated** - Code quality, common pitfalls
5. **Package ecosystem** - Comprehensive overview of tools
6. **Quick reference** - Common commands at fingertips
7. **Integration** - Works with existing R skills

When consolidated knowledge is ready, this will be populated with actual content from reference files and refined for production.
