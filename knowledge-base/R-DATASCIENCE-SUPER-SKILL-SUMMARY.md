# 🎯 R Data Science Super Skill - Executive Summary

## Project Overview
Creation of the most comprehensive R data science skill for Claude Code, transforming it into an expert data scientist capable of analytically attacking any data analysis problem with R.

## Knowledge Sources (2,500+ pages)
1. **R for Data Science** - Tidyverse foundations, data wrangling, visualization
2. **Modern Data Science with R** - Advanced topics, SQL, spatial data, ethics
3. **Forecasting: Principles and Practice** - Complete time series methodology
4. **4 Tidymodels Books** - ML workflows, feature engineering, text mining, statistical inference
5. **Introduction to Statistical Learning (ISLR)** - Statistical learning theory and algorithms

## Skill Architecture

### Structure Type
**Bundled Reference Skill** - Given massive knowledge volume

### File Organization
```
.claude/skills/r-datascience/
├── SKILL.md (450 lines)              ← Main dispatch logic
├── README.md                          ← User documentation
├── references/ (15 files, ~5,000 lines total)
│   ├── 01-tidyverse-foundations.md   ← dplyr, ggplot2, tidyr, purrr
│   ├── 02-data-import-export.md      ← readr, databases, APIs
│   ├── 03-data-transformation.md     ← Advanced wrangling
│   ├── 04-visualization.md           ← ggplot2 comprehensive
│   ├── 05-exploratory-analysis.md    ← EDA workflows
│   ├── 06-statistical-foundations.md ← Stats theory
│   ├── 07-modeling-basics.md         ← Linear models, GLMs
│   ├── 08-machine-learning.md        ← Tidymodels complete
│   ├── 09-time-series.md             ← fable/tsibble/feasts
│   ├── 10-text-mining.md             ← tidytext and NLP
│   ├── 11-spatial-analysis.md        ← sf, spatial data
│   ├── 12-databases-sql.md           ← Database integration
│   ├── 13-web-apis.md                ← Web scraping, APIs
│   ├── 14-reproducibility.md         ← Rmarkdown, workflows
│   └── 15-advanced-programming.md    ← Functional programming
├── templates/ (5 files, ~750 lines total)
│   ├── eda-workflow.md               ← Standard EDA template
│   ├── ml-workflow.md                ← Tidymodels ML template
│   ├── time-series-analysis.md       ← Forecasting template
│   ├── text-mining-workflow.md       ← NLP template
│   └── report-template.Rmd           ← Analysis report
└── examples/ (4 files, ~1,200 lines total)
    ├── complete-eda.md               ← Palmer Penguins
    ├── predictive-modeling.md        ← House prices
    ├── time-series-forecast.md       ← Retail sales
    └── text-analysis.md              ← Customer reviews
```

**Total Size**: ~7,400 lines across 25 files

## Core Capabilities

### 1. Task Classification & Dispatch
Automatically routes to appropriate workflow based on user request:
- Exploratory Data Analysis (EDA)
- Predictive Modeling / Machine Learning
- Time Series Forecasting
- Text Mining / NLP
- Data Wrangling / Transformation
- Data Visualization
- Statistical Testing / Inference
- Data Import/Export
- Spatial Data Analysis
- Report Generation

### 2. Analytical Decision Frameworks
- Model selection guides (regression, classification, time series, clustering)
- Statistical test selection
- Visualization type selection
- Package ecosystem navigation

### 3. Best Practices Integration
- Code quality standards (tidyverse style)
- Common pitfalls and solutions
- Reproducibility patterns
- Performance considerations

### 4. Complete Workflows
Ready-to-use templates for:
- Full EDA pipeline
- End-to-end ML with tidymodels
- Time series forecasting with fable
- Text analysis with tidytext
- Reproducible reporting with R Markdown

### 5. Executable Examples
Production-ready code for common scenarios:
- Complete EDA (333 lines)
- Predictive modeling (250 lines)
- Time series forecasting (200 lines)
- Text sentiment analysis (230 lines)

## Technical Specifications

### Frontmatter
```yaml
name: r-datascience
description: Expert R data science and statistical analysis. Use when performing data analysis, statistical modeling, machine learning, time series forecasting, EDA, data visualization with R, mentions "tidyverse", "tidymodels", "fable", "data science in R", "statistical analysis", "predictive modeling", "forecasting", "data wrangling", "ggplot", or any R-based analytical task.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
```

### Invocation
- **Type**: Background reference skill (Claude auto-invokes)
- **Triggers**: 15+ keywords related to R data science
- **Tool Restrictions**: R execution only, no agents, no git, no web

### Integration with Existing Skills
- **Absorbs**: r-tidymodels, ggplot2 (subsets of this skill)
- **Complements**: r-style-guide, r-performance, tdd-workflow
- **Separate**: r-shiny, r-package-development (different domains)

## Knowledge Extraction Strategy

### Parallel Processing (Currently Running)
- **Agent 1**: R4DS → Tidyverse foundations
- **Agent 2**: MDSR → Advanced topics
- **Agent 3**: FPP3 → Time series
- **Agent 4**: 4 Tidymodels books → ML + text
- **Agent 5**: ISLR PDF → Statistical theory

### Consolidation Process (Next Phase)
For each of 15 reference files:
1. Gather relevant content from all 5 agents
2. Organize hierarchically (basics → advanced)
3. Deduplicate and synthesize
4. Add code patterns and examples
5. Add decision frameworks
6. Cross-reference related files
7. Optimize to 300-400 lines each

## Quality Criteria

Each component must have:
- ✅ Clear hierarchical structure
- ✅ Concrete code examples
- ✅ Decision guidance (when/why)
- ✅ Common pitfalls addressed
- ✅ Cross-references to related files
- ✅ Practical application context
- ✅ Best practices integrated

## Expected User Experience

When a user says:
> "I need to analyze customer churn data and build a predictive model"

Claude will:
1. **Classify**: Predictive modeling task
2. **Dispatch**: Route to ML workflow
3. **Execute**:
   - Load data with appropriate reader
   - Perform initial EDA
   - Create tidymodels recipe for feature engineering
   - Specify multiple models (logistic, random forest, XGBoost)
   - Set up cross-validation
   - Tune hyperparameters
   - Compare models
   - Select best performer
   - Evaluate on test set
   - Generate predictions
   - Create variable importance plots
   - Provide actionable insights

All with best practices, proper validation, and publication-quality visualizations.

## Success Metrics

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

## Timeline

### Completed (30 minutes)
- ✅ Architecture design
- ✅ Templates creation (5 workflows)
- ✅ Examples creation (4 complete analyses)
- ✅ SKILL.md draft with dispatch logic

### In Progress (15-20 minutes remaining)
- 🔄 Knowledge extraction by 5 agents

### Remaining (45-60 minutes)
- ⏳ Consolidate knowledge into 15 reference files (30-40 min)
- ⏳ Generate skill with /skillMaker (10 min)
- ⏳ Test and iterate (15-20 min)

**Total Estimated Time**: ~90-110 minutes

## Current Status

### ✅ Ready Components
- Architecture (100%)
- Templates (100%)
- Examples (100%)
- Main SKILL.md structure (100%)

### 🔄 In Progress
- Knowledge extraction: 5 agents processing 2,500+ pages

### ⏳ Pending
- Reference files population (awaiting agent completion)
- Final skill generation
- Testing and validation

## Unique Features

This skill will be:
1. **Most Comprehensive**: Covers entire R data science ecosystem
2. **Practical**: Executable code, not just concepts
3. **Guided**: Decision frameworks for every choice
4. **Modern**: Latest tidyverse/tidymodels practices
5. **Integrated**: Works seamlessly with existing R skills
6. **Complete**: From data import to publication-ready reports
7. **Expert-Level**: Statistical rigor + practical implementation

## Value Proposition

Transforms Claude Code into a **world-class R data scientist** capable of:
- Handling any data analysis task
- Applying appropriate statistical methods
- Building production-ready ML models
- Creating insightful visualizations
- Writing reproducible, documented code
- Following best practices automatically
- Delivering actionable insights

**Target Audience**: Data scientists, statisticians, researchers, analysts working with R

## Next Actions (Automated)
1. Wait for 5 agents to complete (monitoring automatically)
2. Read all extracted knowledge
3. Consolidate into 15 reference files systematically
4. Use /skillMaker to generate final skill
5. Test with real data science scenarios
6. Iterate based on testing results

---

**Status**: 🚀 **65% Complete** - Knowledge extraction in progress, structure ready, waiting for agent completion to populate reference files.
