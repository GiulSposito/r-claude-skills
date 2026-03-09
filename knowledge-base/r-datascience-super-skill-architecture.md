# R Data Science Super Skill - Architecture Plan

## Overview
A comprehensive skill that transforms Claude into an expert R data scientist, capable of analytically attacking data analysis and data science problems.

## Knowledge Sources
1. **R for Data Science (r4ds)** - Tidyverse foundations, data wrangling, visualization
2. **Modern Data Science with R (mdsr)** - Advanced topics, SQL, spatial, ethics
3. **Forecasting: Principles and Practice (fpp3)** - Time series, forecasting methods
4. **Tidymodels Books (4 books)** - ML, feature engineering, text mining
5. **Introduction to Statistical Learning (ISLR)** - Statistical foundations

## Skill Structure

### Type: Bundled Reference Skill
Given the massive volume of knowledge (5+ books, ~2000+ pages), this MUST be a bundled skill with:
- **SKILL.md** (<500 lines) - Core analytical workflows and dispatch logic
- **references/** - Organized domain knowledge
- **templates/** - Analysis pattern templates
- **examples/** - Complete workflow examples

### Proposed Directory Structure
```
.claude/skills/r-datascience/
├── SKILL.md                          # Main skill with analytical framework
├── README.md                         # User documentation
├── references/
│   ├── 01-tidyverse-foundations.md   # dplyr, ggplot2, tidyr, purrr (from r4ds)
│   ├── 02-data-import-export.md      # readr, haven, databases, APIs (r4ds + mdsr)
│   ├── 03-data-transformation.md     # Advanced wrangling patterns (r4ds + mdsr)
│   ├── 04-visualization.md           # ggplot2 comprehensive guide (r4ds)
│   ├── 05-exploratory-analysis.md    # EDA workflows and patterns (r4ds + mdsr)
│   ├── 06-statistical-foundations.md # Stats theory for DS (ISLR + mdsr)
│   ├── 07-modeling-basics.md         # Linear models, GLMs (ISLR + r4ds)
│   ├── 08-machine-learning.md        # Tidymodels comprehensive (4 tidymodels books)
│   ├── 09-time-series.md             # fable/tsibble/feasts (fpp3)
│   ├── 10-text-mining.md             # tidytext and NLP (tidymodels books)
│   ├── 11-spatial-analysis.md        # sf, spatial data (mdsr)
│   ├── 12-databases-sql.md           # Database integration (mdsr)
│   ├── 13-web-apis.md                # Web scraping, APIs (mdsr)
│   ├── 14-reproducibility.md         # Rmarkdown, quarto, workflows (r4ds + mdsr)
│   └── 15-advanced-programming.md    # Functional programming, performance (r4ds)
├── templates/
│   ├── eda-workflow.md               # Standard EDA template
│   ├── ml-workflow.md                # Tidymodels ML template
│   ├── time-series-analysis.md       # Forecasting template
│   ├── report-template.Rmd           # Analysis report template
│   └── package-analysis.md           # Package data analysis template
└── examples/
    ├── complete-eda.md               # Full EDA example
    ├── predictive-modeling.md        # End-to-end ML example
    ├── time-series-forecast.md       # Complete forecasting example
    └── text-analysis.md              # NLP workflow example
```

## Core Skill Logic (SKILL.md)

### Frontmatter
```yaml
---
name: r-datascience
description: Expert R data science and statistical analysis. Use when performing data analysis, statistical modeling, machine learning, time series forecasting, EDA, data visualization with R, mentions "tidyverse", "tidymodels", "data science in R", "statistical analysis", "predictive modeling", "forecasting", "data wrangling", or any R-based analytical task.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---
```

### Main Workflow in SKILL.md
The SKILL.md should contain:
1. **Problem Classification** - Identify the type of data science task
2. **Workflow Dispatch** - Route to appropriate reference/template
3. **Analytical Framework** - Step-by-step approach for each task type
4. **Quality Checks** - Validation and diagnostic patterns

### Task Types to Handle
- **Exploratory Data Analysis (EDA)**
- **Data Cleaning & Transformation**
- **Statistical Inference**
- **Predictive Modeling (ML)**
- **Time Series Forecasting**
- **Text Mining & NLP**
- **Data Visualization**
- **Hypothesis Testing**
- **Dimensionality Reduction**
- **Clustering & Segmentation**
- **Causal Inference**
- **Survey Analysis**
- **Spatial Analysis**
- **Database Integration**

## Reference Files Organization

### 01-tidyverse-foundations.md
- Core tidyverse packages (dplyr, ggplot2, tidyr, readr, purrr, tibble, stringr, forcats)
- Pipe operators (%>%, |>)
- Data manipulation verbs (select, filter, mutate, summarize, arrange, group_by)
- Tidying data (pivot_longer, pivot_wider, separate, unite)
- Functional programming with purrr (map family)

### 02-data-import-export.md
- Reading files (CSV, Excel, JSON, XML)
- Database connections (DBI, dbplyr)
- Web APIs and scraping
- Large data handling

### 08-machine-learning.md (Critical)
- Complete tidymodels workflow:
  - recipes (feature engineering)
  - parsnip (model specification)
  - workflows (unified interface)
  - tune (hyperparameter tuning)
  - yardstick (performance metrics)
  - rsample (resampling)
- Model types: regression, classification, tree-based, ensemble, neural networks
- Feature engineering patterns
- Model selection and comparison
- Cross-validation strategies

### 09-time-series.md (Critical)
- tsibble data structures
- Time series visualization (gg_season, gg_subseries, ACF/PACF)
- Decomposition (STL, classical)
- Forecasting methods:
  - Simple methods (mean, naive, seasonal naive, drift)
  - Exponential smoothing (ETS)
  - ARIMA
  - Dynamic regression
  - Prophet
  - Neural networks
- Model comparison and selection
- Forecast diagnostics

## Templates Organization

### eda-workflow.md
Step-by-step EDA template:
1. Load and inspect data
2. Check data quality (missing, duplicates, outliers)
3. Univariate analysis
4. Bivariate analysis
5. Multivariate analysis
6. Key insights and patterns

### ml-workflow.md
Complete ML pipeline:
1. Problem definition
2. Data split (training/testing/validation)
3. Feature engineering with recipes
4. Model specification
5. Hyperparameter tuning
6. Model evaluation
7. Final model and predictions
8. Model interpretation

## Examples Organization
Complete, runnable examples showing:
- Full workflow from data to insights
- Best practices
- Common pitfalls and how to avoid them
- Code that can be adapted to user's data

## Integration Strategy

### With Existing Skills
This skill should work alongside:
- `r-style-guide` - For code style
- `r-package-development` - For package creation
- `r-performance` - For optimization
- `r-tidymodels` - May be absorbed or referenced
- `ggplot2` - May be absorbed or referenced
- `r-shiny` - Separate, for app development
- `tdd-workflow` - For testing

### Decision:
- **Absorb** r-tidymodels and ggplot2 content into this super skill (they're subsets)
- **Keep separate** r-shiny, r-package-development (different domains)
- **Reference** r-style-guide, r-performance (complementary)

## Knowledge Consolidation Strategy

### Phase 1: Extract (IN PROGRESS)
4 agents extracting knowledge from online books + ISLR PDF

### Phase 2: Organize
For each reference file:
1. Combine knowledge from all sources for that topic
2. Remove redundancy
3. Organize hierarchically (basic → advanced)
4. Add code patterns and examples
5. Include decision trees (when to use what)

### Phase 3: Optimize
- Keep main SKILL.md under 500 lines
- Each reference file: 300-500 lines (readable, focused)
- Templates: 100-200 lines (practical)
- Examples: 200-300 lines (complete but concise)

### Phase 4: Validate
- Test with real data science tasks
- Ensure coverage of common workflows
- Verify code patterns are correct
- Check cross-references between files

## Invocation Strategy

### user-invocable: false
This is a background reference skill - Claude invokes it automatically when:
- User mentions data analysis, statistics, ML, forecasting
- User works with R code involving tidyverse/tidymodels
- User asks data science questions

### Trigger Phrases in Description
- "data analysis in R"
- "statistical modeling"
- "machine learning"
- "tidyverse"
- "tidymodels"
- "data science"
- "forecasting"
- "time series"
- "exploratory analysis"
- "predictive modeling"
- "data wrangling"
- "data visualization with R"

## Tool Restrictions
```yaml
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
```
- Read: Read data files, reference docs
- Write: Create R scripts, reports
- Edit: Modify existing R code
- Bash(Rscript *): Run R scripts
- Bash(R -e *): Execute R commands

No Agent, no git operations, no web tools (references are local).

## Success Criteria

A data scientist using this skill should be able to:
1. ✅ Perform complete EDA on any dataset
2. ✅ Build, tune, and evaluate ML models
3. ✅ Create publication-quality visualizations
4. ✅ Conduct time series forecasting
5. ✅ Perform text mining and NLP
6. ✅ Apply appropriate statistical tests
7. ✅ Write reproducible analyses
8. ✅ Handle databases and APIs
9. ✅ Make data-driven decisions
10. ✅ Follow best practices automatically

## Next Steps

1. ✅ Wait for 4 agents to complete knowledge extraction
2. ✅ Extract ISLR PDF knowledge
3. ✅ Consolidate all knowledge into reference files
4. ✅ Create templates and examples
5. ✅ Write main SKILL.md with dispatch logic
6. ✅ Use /skillMaker to generate the skill
7. ✅ Test with real data science tasks
8. ✅ Iterate based on testing

## Estimated Complexity
- **Total lines**: ~6,000-8,000 lines across all files
- **Main SKILL.md**: ~400-500 lines
- **15 reference files**: ~5,000 lines (300-350 each)
- **5 templates**: ~500-750 lines
- **4 examples**: ~1,000-1,200 lines
- **README**: ~200 lines

This is the most comprehensive R skill, approaching the limits of what's practical while maintaining usability.
