# R Data Science Super Skill - Templates Preview

## Template 1: EDA Workflow Template

```markdown
# Exploratory Data Analysis Workflow

## 1. Load and Initial Inspection
- Load data with appropriate reader (readr, readxl, haven)
- Check dimensions: `dim()`, `nrow()`, `ncol()`
- View structure: `str()`, `glimpse()`
- Preview data: `head()`, `tail()`, `View()`

## 2. Data Quality Assessment
- Missing values: `sum(is.na())`, `naniar::vis_miss()`
- Duplicates: `duplicated()`, `distinct()`
- Data types: check and convert as needed
- Outliers: visual inspection, IQR method

## 3. Univariate Analysis
For each variable:
- **Numeric**: summary stats, histogram, boxplot, density plot
- **Categorical**: frequency tables, bar charts
- Check distributions and skewness

## 4. Bivariate Analysis
- Numeric vs Numeric: scatter plots, correlation
- Numeric vs Categorical: grouped boxplots, violin plots
- Categorical vs Categorical: contingency tables, mosaic plots

## 5. Multivariate Analysis
- Correlation matrix and heatmap
- Pairwise plots
- PCA for dimensionality overview
- Identify patterns and relationships

## 6. Key Insights
- Document main findings
- Highlight anomalies or interesting patterns
- Suggest next steps for modeling
```

## Template 2: Machine Learning Workflow Template

```markdown
# Tidymodels Machine Learning Workflow

## 1. Problem Definition
- Define target variable
- Classification or regression?
- Success metrics
- Business context

## 2. Data Preparation
- Load and clean data
- Split: training (70-80%), testing (20-30%), optional validation
- `initial_split()`, `training()`, `testing()`

## 3. Feature Engineering (recipes)
- Create recipe: `recipe(target ~ ., data = train)`
- Preprocessing steps:
  - Imputation: `step_impute_*()`
  - Normalization: `step_normalize()`
  - Encoding: `step_dummy()`, `step_other()`
  - Feature creation: `step_interact()`, `step_poly()`
  - Dimensionality: `step_pca()`, `step_corr()`

## 4. Model Specification (parsnip)
- Choose model type and engine
- Set mode (regression/classification)
- Specify hyperparameters to tune: `tune()`

## 5. Workflow Creation
- Combine recipe + model: `workflow() %>% add_recipe() %>% add_model()`

## 6. Resampling Strategy
- k-fold CV: `vfold_cv(train, v = 10)`
- Or: bootstrap, monte carlo CV, time series CV

## 7. Hyperparameter Tuning
- Grid search: `tune_grid()`
- Define grid: `grid_regular()`, `grid_random()`
- Parallel processing: `doParallel::registerDoParallel()`

## 8. Model Evaluation
- Select best model: `select_best()`
- Finalize workflow: `finalize_workflow()`
- Evaluate on test set
- Metrics: RMSE, R², accuracy, AUC, confusion matrix

## 9. Final Model and Predictions
- Fit final model: `last_fit()`
- Generate predictions
- Save model: `saveRDS()`

## 10. Model Interpretation
- Variable importance: `vip::vi()`
- Partial dependence plots
- SHAP values (via {treeshap} or {fastshap})
```

## Template 3: Time Series Forecasting Template

```markdown
# Time Series Forecasting Workflow (fable/tsibble)

## 1. Data Preparation
- Convert to tsibble: `as_tsibble()`
- Check for gaps: `scan_gaps()`
- Fill gaps if needed: `fill_gaps()`

## 2. Visualization and Exploration
- Time plot: `autoplot()`
- Seasonal plots: `gg_season()`, `gg_subseries()`
- ACF/PACF: `ACF()`, `PACF()`, `gg_tsdisplay()`

## 3. Decomposition
- STL: `STL()`
- Classical: `classical_decomposition()`
- Visualize: `autoplot(components())`

## 4. Stationarity Check
- Visual inspection
- Unit root test: `unitroot_kpss()`, `unitroot_ndiffs()`
- Differencing if needed: `difference()`

## 5. Model Specification
Fit multiple models for comparison:
- Naive methods: `NAIVE()`, `SNAIVE()`, `MEAN()`, `RW()`
- Exponential smoothing: `ETS()`
- ARIMA: `ARIMA()`
- Dynamic regression: `ARIMA() + xreg`
- Prophet: `prophet()`
- Neural networks: `NNETAR()`

## 6. Model Fitting
- Fit models: `model()` with multiple specifications
- Example: `models <- data %>% model(ets = ETS(), arima = ARIMA())`

## 7. Diagnostics
- Residual plots: `gg_tsresiduals()`
- Ljung-Box test: `augment() %>% features(.innov, ljung_box)`
- Check for white noise residuals

## 8. Model Selection
- Compare accuracy: `accuracy()`
- Information criteria: AIC, AICc, BIC
- Cross-validation: `stretch_tsibble()` with sliding windows

## 9. Forecasting
- Generate forecasts: `forecast(h = )`
- Visualize: `autoplot()`
- Prediction intervals

## 10. Evaluation
- Compare against actuals if available
- Forecast accuracy measures: MAE, RMSE, MAPE, MASE
- Update and refit as new data arrives
```

## Template 4: Text Mining Workflow Template

```markdown
# Text Mining and NLP Workflow (tidytext)

## 1. Data Loading and Inspection
- Load text data
- Check structure and encoding
- Sample review

## 2. Tokenization
- Convert to tidy format: `unnest_tokens()`
- Word tokens (unigrams)
- N-grams: bigrams, trigrams
- Sentences or paragraphs

## 3. Text Cleaning
- Remove stop words: `anti_join(stop_words)`
- Custom stop words
- Stemming or lemmatization: `SnowballC::wordStem()`
- Remove numbers, punctuation, URLs

## 4. Exploratory Text Analysis
- Word frequency: `count()`, bar plots
- Word clouds: `wordcloud::wordcloud()`
- TF-IDF: `bind_tf_idf()`
- Compare corpora

## 5. Sentiment Analysis
- Sentiment lexicons: AFINN, bing, nrc, loughran
- Join with text: `inner_join(get_sentiments())`
- Aggregate sentiment scores
- Visualize sentiment over time/documents

## 6. Topic Modeling
- Document-term matrix: `cast_dtm()`
- LDA: `topicmodels::LDA()`
- Interpret topics: `tidy()` to extract terms
- Assign documents to topics

## 7. Feature Engineering for ML
- Create document-term matrix
- TF-IDF features
- Word embeddings (word2vec, GloVe)
- N-gram features

## 8. Text Classification (with tidymodels)
- Prepare recipe with `textrecipes`
- Steps: tokenization, filtering, tf-idf, normalization
- Model specification (logistic, naive Bayes, SVM, neural nets)
- Tune and evaluate

## 9. Advanced NLP
- Named entity recognition
- Part-of-speech tagging
- Dependency parsing (via {udpipe})
- Text generation

## 10. Visualization and Communication
- Network graphs for word relationships
- Comparison clouds
- Topic distribution plots
- Interactive visualizations with {plotly}
```

## Template 5: Report Generation Template

```markdown
# R Markdown Analysis Report Template

## YAML Header
```yaml
---
title: "Data Analysis Report"
author: "Your Name"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_float: true
    code_folding: hide
    theme: flatly
  pdf_document:
    toc: true
---
```

## Report Structure

### 1. Executive Summary
- Key findings (bullet points)
- Main conclusions
- Recommendations

### 2. Introduction
- Background and context
- Research questions or objectives
- Data sources

### 3. Data Overview
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
library(tidyverse)
library(knitr)
library(kableExtra)
```

```{r load-data}
# Load and preview data
```

- Data description
- Variables and types
- Sample size

### 4. Data Cleaning and Preparation
```{r data-cleaning}
# Cleaning steps with explanations
```

- Missing values handled
- Outliers addressed
- Transformations applied

### 5. Exploratory Data Analysis
```{r eda}
# Visualizations and summary statistics
```

- Key distributions
- Relationships between variables
- Patterns and anomalies

### 6. Methodology
- Analytical approach
- Models used
- Assumptions and limitations

### 7. Results
```{r analysis}
# Main analysis code
```

```{r results-table}
# Format results as tables
results %>%
  kable(caption = "Analysis Results") %>%
  kable_styling(bootstrap_options = c("striped", "hover"))
```

- Statistical findings
- Model performance
- Visualizations of results

### 8. Discussion
- Interpretation of results
- Comparison with expectations
- Implications

### 9. Conclusions
- Summary of key findings
- Limitations
- Future work

### 10. Appendix
- Additional tables and figures
- Code details
- Data dictionary

## Rendering
- Knit to HTML for interactive reports
- Knit to PDF for formal documents
- Use `rmarkdown::render()` for batch processing
```

## Usage Notes

All templates should be:
- **Flexible**: Adapt to different data and contexts
- **Complete**: Cover all essential steps
- **Practical**: Include actual code patterns
- **Educational**: Explain why each step matters
- **Efficient**: Follow best practices

Templates will be referenced from main SKILL.md based on task type detection.
