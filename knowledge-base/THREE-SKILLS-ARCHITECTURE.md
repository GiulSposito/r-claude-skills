# Three Specialized R Data Science Skills - Architecture

## Overview
Instead of one massive super skill, we're creating **3 specialized skills** for better maintainability, performance, and user experience.

---

## Skill 1: r-timeseries

### Purpose
Expert time series analysis and forecasting with fable/tsibble ecosystem.

### Knowledge Sources
- **Primary**: Forecasting: Principles and Practice (FPP3) - Complete
- **Secondary**: R4DS (time series basics), MDSR (time series chapter if any)

### Frontmatter
```yaml
---
name: r-timeseries
description: Expert time series forecasting and analysis in R. Use when forecasting, analyzing time series data, mentions "ARIMA", "ETS", "seasonality", "fable", "tsibble", "feasts", "forecast", "temporal data", "trend", "prophet", or any time-based prediction task.
version: 1.0.0
user-invocable: true
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---
```

### Structure
```
.claude/skills/r-timeseries/
├── SKILL.md (~350 lines)
│   ├── Time series data structures (tsibble)
│   ├── Visualization (gg_season, gg_subseries, ACF/PACF)
│   ├── Decomposition methods (STL, classical)
│   ├── Stationarity and differencing
│   ├── Forecasting methods dispatch
│   ├── Model selection framework
│   └── Diagnostic workflows
├── README.md
├── references/
│   ├── forecasting-methods.md (~400 lines)
│   │   ├── Simple methods (naive, seasonal naive, drift)
│   │   ├── Exponential smoothing (ETS)
│   │   ├── ARIMA modeling (complete)
│   │   ├── Dynamic regression
│   │   ├── Prophet
│   │   └── Neural networks (NNETAR)
│   ├── diagnostics-evaluation.md (~250 lines)
│   │   ├── Residual diagnostics
│   │   ├── Accuracy measures (RMSE, MAE, MAPE, MASE)
│   │   ├── Cross-validation for time series
│   │   └── Model comparison frameworks
│   └── advanced-topics.md (~200 lines)
│       ├── Hierarchical forecasting
│       ├── Multiple seasonality
│       ├── Vector autoregression (VAR)
│       └── Dealing with missing data
├── templates/
│   ├── basic-forecast-workflow.md
│   └── advanced-forecast-workflow.md
└── examples/
    ├── retail-sales-forecast.md (from our examples)
    └── electricity-demand-forecast.md
```

**Estimated Total**: ~1,500 lines

### Key Features
- Complete fable/tsibble/feasts coverage
- Model selection decision trees
- Diagnostic workflows
- Cross-validation for time series
- Direct invocation with `/r-timeseries`

---

## Skill 2: r-text-mining

### Purpose
Expert NLP and text analysis with tidytext and textrecipes.

### Knowledge Sources
- **Primary**: Text Mining with R (tidytext book)
- **Primary**: Supervised ML for Text Analysis (SMLTAR book)
- **Secondary**: MDSR (text mining chapter), tidymodels (textrecipes)

### Frontmatter
```yaml
---
name: r-text-mining
description: Expert text mining and NLP in R. Use when analyzing text data, mentions "text analysis", "NLP", "sentiment analysis", "topic modeling", "tidytext", "textrecipes", "tokenization", "TF-IDF", "text classification", "word embeddings", or any natural language processing task.
version: 1.0.0
user-invocable: true
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---
```

### Structure
```
.claude/skills/r-text-mining/
├── SKILL.md (~350 lines)
│   ├── Tidy text principles
│   ├── Tokenization strategies
│   ├── Text preprocessing dispatch
│   ├── Analysis type routing (sentiment, topic, classification)
│   └── Visualization patterns
├── README.md
├── references/
│   ├── text-preprocessing.md (~300 lines)
│   │   ├── Tokenization (word, n-gram, sentence)
│   │   ├── Stop words and custom dictionaries
│   │   ├── Stemming and lemmatization
│   │   ├── Regular expressions patterns
│   │   └── Text cleaning pipelines
│   ├── sentiment-analysis.md (~250 lines)
│   │   ├── Sentiment lexicons (AFINN, bing, nrc, loughran)
│   │   ├── Sentiment scoring methods
│   │   ├── Context handling (negation, amplifiers)
│   │   └── Visualization patterns
│   ├── topic-modeling.md (~250 lines)
│   │   ├── Document-term matrices
│   │   ├── TF-IDF
│   │   ├── Latent Dirichlet Allocation (LDA)
│   │   ├── Topic interpretation
│   │   └── Perplexity and coherence
│   ├── text-classification.md (~300 lines)
│   │   ├── textrecipes for tidymodels
│   │   ├── Feature engineering for text
│   │   ├── Model selection for text
│   │   ├── Word embeddings (word2vec, GloVe)
│   │   └── Deep learning for NLP (LSTM, CNN)
│   └── advanced-nlp.md (~200 lines)
│       ├── Named entity recognition
│       ├── Part-of-speech tagging
│       ├── Dependency parsing
│       └── Text generation
├── templates/
│   ├── sentiment-analysis-workflow.md
│   ├── topic-modeling-workflow.md
│   └── text-classification-workflow.md
└── examples/
    ├── customer-reviews-sentiment.md (from our examples)
    ├── news-topic-modeling.md
    └── spam-classification.md
```

**Estimated Total**: ~1,800 lines

### Key Features
- Complete tidytext coverage
- Sentiment analysis with all major lexicons
- Topic modeling (LDA)
- Text classification with tidymodels
- Deep learning patterns for NLP
- Direct invocation with `/r-text-mining`

---

## Skill 3: r-datascience (Main)

### Purpose
Comprehensive general data science: EDA, ML, visualization, spatial, databases.

### Knowledge Sources
- **Primary**: R for Data Science (R4DS) - Tidyverse foundations
- **Primary**: Tidymodels books - ML workflows (non-text)
- **Primary**: ISLR - Statistical learning theory
- **Secondary**: MDSR - SQL, spatial, ethics, advanced topics

### Frontmatter
```yaml
---
name: r-datascience
description: Expert R data science covering EDA, machine learning, visualization, and statistical analysis. Use when performing data analysis, predictive modeling, mentions "tidyverse", "tidymodels", "ggplot", "dplyr", "data wrangling", "machine learning", "classification", "regression", "clustering", "EDA", "exploratory analysis", or general data science tasks in R.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---
```

### Structure
```
.claude/skills/r-datascience/
├── SKILL.md (~450 lines)
│   ├── Task classification (EDA, ML, viz, wrangling)
│   ├── Analytical dispatch logic
│   ├── Model selection frameworks
│   ├── Best practices integration
│   └── Quick reference commands
├── README.md
├── references/
│   ├── tidyverse-foundations.md (~400 lines)
│   │   ├── dplyr (select, filter, mutate, summarize, group_by)
│   │   ├── tidyr (pivot_longer, pivot_wider)
│   │   ├── purrr (map family, functional programming)
│   │   ├── stringr (string manipulation)
│   │   ├── forcats (factor handling)
│   │   └── lubridate (date/time)
│   ├── data-import-export.md (~300 lines)
│   │   ├── readr (CSV, delimited)
│   │   ├── readxl (Excel)
│   │   ├── haven (SPSS, Stata, SAS)
│   │   ├── Large data strategies
│   │   └── JSON, XML
│   ├── data-transformation.md (~300 lines)
│   │   ├── Advanced wrangling patterns
│   │   ├── Joins (inner, left, right, full, anti, semi)
│   │   ├── Window functions
│   │   ├── Missing data handling
│   │   └── Reshaping strategies
│   ├── visualization.md (~400 lines)
│   │   ├── Grammar of graphics (ggplot2)
│   │   ├── Geometric objects (geom_*)
│   │   ├── Statistical transformations
│   │   ├── Scales and coordinate systems
│   │   ├── Themes and customization
│   │   ├── Faceting strategies
│   │   └── Extensions (patchwork, ggrepel, plotly)
│   ├── exploratory-analysis.md (~350 lines)
│   │   ├── EDA workflow patterns
│   │   ├── Univariate analysis
│   │   ├── Bivariate relationships
│   │   ├── Multivariate exploration
│   │   ├── Correlation analysis
│   │   └── PCA for overview
│   ├── statistical-foundations.md (~350 lines)
│   │   ├── Probability concepts
│   │   ├── Statistical inference
│   │   ├── Hypothesis testing
│   │   ├── Confidence intervals
│   │   ├── Bootstrap methods
│   │   └── Bias-variance tradeoff
│   ├── modeling-basics.md (~300 lines)
│   │   ├── Linear regression
│   │   ├── Multiple regression
│   │   ├── Model diagnostics
│   │   ├── Residual analysis
│   │   ├── Polynomial regression
│   │   └── Interactions
│   ├── machine-learning.md (~500 lines)
│   │   ├── Tidymodels complete workflow
│   │   ├── recipes (feature engineering - 50+ steps)
│   │   ├── parsnip (model specifications)
│   │   ├── workflows (unified interface)
│   │   ├── tune (hyperparameter tuning)
│   │   ├── yardstick (metrics)
│   │   ├── Classification methods
│   │   ├── Regression methods
│   │   ├── Tree-based methods
│   │   ├── Ensemble methods
│   │   └── Model selection
│   ├── spatial-analysis.md (~250 lines)
│   │   ├── sf package (simple features)
│   │   ├── Spatial data structures
│   │   ├── CRS and projections
│   │   ├── Spatial joins
│   │   ├── Distance calculations
│   │   └── Mapping (leaflet, tmap)
│   ├── databases-sql.md (~300 lines)
│   │   ├── DBI connections
│   │   ├── SQL fundamentals
│   │   ├── dbplyr for dplyr → SQL
│   │   ├── Query optimization
│   │   └── Database design
│   ├── web-apis.md (~200 lines)
│   │   ├── httr2 for HTTP requests
│   │   ├── REST API patterns
│   │   ├── JSON parsing
│   │   ├── Authentication
│   │   ├── rvest for web scraping
│   │   └── Ethical considerations
│   ├── reproducibility.md (~250 lines)
│   │   ├── R Markdown fundamentals
│   │   ├── Quarto for publishing
│   │   ├── Project organization
│   │   ├── Version control integration
│   │   └── Literate programming
│   └── advanced-programming.md (~250 lines)
│       ├── Function writing
│       ├── Functional programming patterns
│       ├── Environments and scoping
│       ├── Error handling
│       └── Performance basics
├── templates/
│   ├── eda-workflow.md
│   ├── ml-workflow.md
│   ├── report-template.Rmd
│   └── package-analysis.md
└── examples/
    ├── complete-eda.md (Palmer Penguins)
    ├── predictive-modeling.md (House Prices)
    ├── clustering-segmentation.md
    └── spatial-analysis-example.md
```

**Estimated Total**: ~4,500 lines

### Key Features
- Complete tidyverse coverage
- Full tidymodels ML workflows
- Statistical learning theory (ISLR)
- Spatial analysis (sf)
- SQL/database integration
- Background skill (auto-invoked)
- Works with other specialized skills

---

## Knowledge Distribution Strategy

### From Agent Extractions to Skills

#### MDSR Extraction (851 lines) → Distribution:
- **r-datascience** (75%): SQL, spatial, ethics, base statistics, visualization, wrangling
- **r-text-mining** (20%): Text mining chapter, regex patterns
- **r-timeseries** (5%): Any time series content

#### Tidymodels Extraction (2,203 lines) → Distribution:
- **r-datascience** (70%): Core ML workflows, feature engineering (non-text), regression, classification
- **r-text-mining** (30%): textrecipes, text classification, NLP workflows, embeddings

#### R4DS Extraction (TBD) → Distribution:
- **r-datascience** (90%): Tidyverse, data import, visualization, programming
- **r-timeseries** (5%): Time series basics if any
- **r-text-mining** (5%): String manipulation (stringr)

#### FPP3 Extraction (TBD) → Distribution:
- **r-timeseries** (100%): All forecasting content

#### ISLR Extraction (TBD) → Distribution:
- **r-datascience** (95%): Statistical learning theory, algorithms
- **r-timeseries** (5%): Time series methods if any

---

## Invocation Strategy

### Skill Interaction Matrix

| User Mentions | Invokes | Mode |
|--------------|---------|------|
| "forecast", "ARIMA", "time series" | r-timeseries | Direct `/r-timeseries` or auto |
| "text analysis", "sentiment", "NLP" | r-text-mining | Direct `/r-text-mining` or auto |
| "data analysis", "EDA", "machine learning" | r-datascience | Auto (background) |
| "ggplot", "dplyr", "tidyverse" | r-datascience | Auto (background) |

### Multiple Domain Tasks
If a task involves multiple domains (rare):
- Example: "Forecast text volume" → r-timeseries + r-text-mining
- Claude can invoke both skills if needed
- Each skill focuses on its domain

---

## Development Timeline

### Current Status
- ✅ Templates created (can split into 3)
- ✅ Examples created (can distribute to appropriate skills)
- ✅ SKILL.md drafts ready (needs splitting)
- 🔄 Extractions: 2/5 complete (MDSR, Tidymodels)
- ⏳ Awaiting: R4DS, FPP3, ISLR

### Next Steps (When All Agents Complete)

1. **Consolidate Extractions** (30 min)
   - Read all 5 extraction files
   - Organize by skill (3 groups)
   - Create reference files for each skill

2. **Generate Skill 1: r-timeseries** (15 min)
   - Use `/skillMaker`
   - Populate with FPP3 content
   - Add templates and examples
   - Test

3. **Generate Skill 2: r-text-mining** (15 min)
   - Use `/skillMaker`
   - Populate with tidytext + textrecipes content
   - Add templates and examples
   - Test

4. **Generate Skill 3: r-datascience** (20 min)
   - Use `/skillMaker`
   - Populate with R4DS + tidymodels + ISLR + MDSR content
   - Add templates and examples
   - Test

5. **Integration Testing** (20 min)
   - Test each skill independently
   - Test multi-domain tasks
   - Verify no conflicts
   - Validate trigger phrases

**Total Time Remaining**: ~100 minutes (after extractions complete)

---

## Quality Criteria (Each Skill)

Each skill must have:
- ✅ Clear, focused domain
- ✅ Precise trigger phrases
- ✅ Complete workflows for domain
- ✅ Executable examples
- ✅ Best practices integrated
- ✅ Cross-references where needed
- ✅ Appropriate tool restrictions
- ✅ User documentation (README)

---

## Advantages of 3-Skill Architecture

### Specialization
- Each skill is expert in its domain
- No dilution of focus
- Easier to maintain and update

### Performance
- Smaller context per invocation
- Faster loading
- Only relevant knowledge active

### User Experience
- Clear mental model (time series → use r-timeseries)
- Direct invocation for specialized tasks
- Auto-invocation for general tasks

### Maintainability
- Easier to update one domain without affecting others
- Can version independently
- Clearer responsibility boundaries

### Scalability
- Easy to add new specialized skills later (e.g., r-survival, r-bayesian)
- No single monolithic skill to manage

---

## Success Metrics

### r-timeseries
- ✅ Can forecast any univariate/multivariate time series
- ✅ Proper model selection guidance
- ✅ Complete diagnostic workflows
- ✅ Handles seasonality, trends, exogenous variables

### r-text-mining
- ✅ Can perform sentiment analysis on any text corpus
- ✅ Topic modeling workflows complete
- ✅ Text classification with tidymodels
- ✅ Handles preprocessing, tokenization, cleaning

### r-datascience
- ✅ Complete EDA on any dataset
- ✅ Build, tune, evaluate ML models
- ✅ Publication-quality visualizations
- ✅ Statistical rigor
- ✅ Database and spatial integration

---

## File Size Targets

| Skill | Main SKILL.md | References | Templates | Examples | Total |
|-------|---------------|------------|-----------|----------|-------|
| r-timeseries | 350 | 850 | 200 | 300 | ~1,700 |
| r-text-mining | 350 | 1,100 | 250 | 300 | ~2,000 |
| r-datascience | 450 | 3,650 | 400 | 500 | ~5,000 |

**Grand Total**: ~8,700 lines across 3 skills (very manageable)

---

**Status**: Architecture defined, awaiting completion of 3 remaining agent extractions to begin consolidation and skill generation.
