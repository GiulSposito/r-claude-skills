# R Programming Skills for Claude Code

A comprehensive collection of Claude Code skills for R programming, data science, and statistical computing. Transform Claude into an expert R data scientist with **8,465+ lines** of specialized knowledge.

## 🎯 Overview

This repository contains production-ready skills that enhance Claude Code's capabilities for complete data science workflows in R. From data wrangling to machine learning, time series forecasting to text mining, these skills provide expert guidance extracted from authoritative R resources.

**🆕 Complete Data Science Suite**: Three specialized skills covering the entire R data science ecosystem:
- **r-timeseries** (2,328 lines) - Time series forecasting
- **r-text-mining** (3,747 lines) - NLP and text analysis
- **r-datascience** (2,390 lines) - Core tidyverse/tidymodels

**Plus**: Machine learning with **r-tidymodels** (4,150 lines) for advanced ML workflows

### ✨ New Data Science Skills

**🔮 r-timeseries** - Expert forecasting with fable/tsibble
- Complete forecasting workflows (ARIMA, ETS, Prophet, NNETAR, TBATS)
- Model selection frameworks and diagnostics
- Cross-validation and accuracy metrics
- Production deployment patterns
- 7 files with templates and examples

**📝 r-text-mining** - NLP and text analysis
- Sentiment analysis (AFINN, Bing, NRC, Loughran lexicons)
- Topic modeling with LDA
- Text classification with tidymodels
- Complete preprocessing reference
- 7 files with comprehensive guides

**📊 r-datascience** - Core data science workflows
- Data wrangling (dplyr/tidyr complete reference)
- Feature engineering with recipes
- Statistical modeling (lm, glm, mixed models)
- Machine learning best practices
- 5 files covering the full data science pipeline

[→ See r-timeseries documentation](/.claude/skills/r-timeseries/)
[→ See r-text-mining documentation](/.claude/skills/r-text-mining/)
[→ See r-datascience documentation](/.claude/skills/r-datascience/)

## 📦 Available Skills

### 🆕 Data Science Suite (8,465 lines)

- **[r-datascience](/.claude/skills/r-datascience/)** (2,390 lines) - Complete tidyverse/tidymodels workflows
  - Data wrangling with dplyr/tidyr
  - Feature engineering with recipes
  - Statistical modeling (lm, glm, mixed models)
  - ML workflows and best practices

- **[r-timeseries](/.claude/skills/r-timeseries/)** (2,328 lines) - Expert time series forecasting
  - ARIMA, ETS, Prophet, NNETAR, TBATS
  - Model selection and diagnostics
  - Forecast evaluation and cross-validation
  - Production deployment

- **[r-text-mining](/.claude/skills/r-text-mining/)** (3,747 lines) - NLP and text analysis
  - Sentiment analysis (multiple lexicons)
  - Topic modeling (LDA)
  - Text classification with tidymodels
  - Complete preprocessing reference

### Machine Learning & Statistics

- **[r-tidymodels](/.claude/skills/r-tidymodels/)** (4,150 lines) - Advanced ML with tidymodels
  - 3-phase ML workflow (Foundation → Optimization → Production)
  - 100+ preprocessing recipe steps
  - Hyperparameter tuning and ensembles
  - 6 production templates, 4 case studies

- **[r-bayes](/.claude/skills/r-bayes/)** - Bayesian inference with brms
  - Multilevel models and marginal effects
  - Prior specification and diagnostics
  - Model comparison

### Data Visualization

- **[ggplot2](/.claude/skills/ggplot2/)** - Expert data visualization
  - Grammar of graphics patterns
  - Geoms, themes, scales, faceting
  - Custom themes and styling

- **[dm-relational](/.claude/skills/dm-relational/)** - Relational data modeling
  - Multi-table data models
  - Primary/foreign key relationships

### Core R Skills

- **[tidyverse-patterns](/.claude/skills/tidyverse-patterns/)** - Modern tidyverse patterns
  - Pipes, joins, grouping
  - purrr functional programming
  - stringr text manipulation

- **[rlang-patterns](/.claude/skills/rlang-patterns/)** - Metaprogramming
  - Data-masking and injection
  - Tidy evaluation patterns

- **[r-style-guide](/.claude/skills/r-style-guide/)** - R style conventions
- **[r-performance](/.claude/skills/r-performance/)** - Performance optimization
- **[r-oop](/.claude/skills/r-oop/)** - Object-oriented programming (S7, S3, S4)
- **[r-package-development](/.claude/skills/r-package-development/)** - Package development

### Development Workflow

- **[tdd-workflow](/.claude/skills/tdd-workflow/)** - Test-driven development workflow using testthat with 80%+ coverage enforcement
- **[r-shiny](/.claude/skills/r-shiny/)** - Expert Shiny app development covering reactive programming, UI design, modules, and performance

### Meta Skills

- **[skillMaker](/.claude/skills/skillMaker/)** - Create new Claude Code skills following best practices (used to generate these skills!)

## 🚀 Installation

### Project-Level Installation

Clone this repository into your R project:

```bash
cd your-r-project/
git clone https://github.com/yourusername/claude-r-skills.git .claude/skills
```

Or add as a git submodule:

```bash
git submodule add https://github.com/yourusername/claude-r-skills.git .claude/skills
```

### System-Wide Installation

Install skills globally for use across all projects:

```bash
# Clone the repository
git clone https://github.com/yourusername/claude-r-skills.git

# Copy skills to Claude's system directory
cp -r claude-r-skills/.claude/skills/* ~/.claude/skills/
```

## 📖 Usage

### Manual Invocation

Most skills can be invoked directly using slash commands:

```bash
/r-style-guide     # Get R style guidance
/ggplot2           # ggplot2 visualization help
/tdd-workflow      # Start test-driven development
/skillMaker        # Create a new skill
```

### Automatic Triggering

Skills automatically activate based on context:

- **Import detection**: Skills trigger when relevant packages are imported
- **File patterns**: Activated by file types (.R, .Rmd, tests/, etc.)
- **Keywords**: Mentioning specific terms (e.g., "ggplot", "shiny app", "package development")
- **Code patterns**: Detecting tidyverse pipes, ggplot layers, test files, etc.

### Example Workflows

**Creating a ggplot visualization:**
```r
# Simply start coding - the skill activates automatically
library(ggplot2)
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point()  # Claude provides expert ggplot2 guidance
```

**Developing an R package:**
```bash
/r-package-development  # Manually invoke for comprehensive guidance
```

**Building a Shiny app:**
```r
library(shiny)  # Auto-triggers r-shiny skill
# Claude provides reactive programming patterns, UI best practices, etc.
```

**Machine learning with tidymodels:**
```r
library(tidymodels)  # Auto-triggers r-tidymodels skill

# Claude provides expert guidance on:
# - Data splitting and resampling
# - Feature engineering with recipes
# - Model specification and tuning
# - Hyperparameter optimization
# - Model deployment patterns
```

**Time series forecasting:**
```r
library(fable)  # Auto-triggers r-timeseries skill
# Expert forecasting workflows with ARIMA, ETS, Prophet
```

**Text mining and NLP:**
```r
library(tidytext)  # Auto-triggers r-text-mining skill
# Sentiment analysis, topic modeling, text classification
```

**Data science workflows:**
```r
library(tidyverse)  # Auto-triggers r-datascience skill
# Complete data wrangling, visualization, and modeling guidance
```

## 🏗️ Repository Structure

```
.claude/skills/
├── r-datascience/         # 🆕 Core data science (2,390 lines)
│   ├── SKILL.md           # Complete tidyverse/tidymodels guide
│   ├── README.md          # User documentation
│   └── references/        # dplyr, tidyr, recipes, statistical modeling
├── r-timeseries/          # 🆕 Forecasting (2,328 lines)
│   ├── SKILL.md           # Complete forecasting workflows
│   ├── README.md
│   ├── references/        # Methods, visualization, evaluation
│   ├── templates/         # Forecasting workflow template
│   └── examples/          # Retail sales case study
├── r-text-mining/         # 🆕 NLP (3,747 lines)
│   ├── SKILL.md           # Text mining workflows
│   ├── README.md
│   ├── references/        # Sentiment, topics, classification, preprocessing
│   └── examples/          # Customer reviews analysis
├── r-tidymodels/          # Advanced ML (4,150 lines)
│   ├── SKILL.md           # 3-phase ML workflow
│   ├── README.md
│   ├── templates/         # 6 ML templates
│   ├── examples/          # 4 case studies
│   └── references/        # 100+ recipe steps
├── ggplot2/
│   ├── SKILL.md
│   ├── templates/
│   └── references/
├── tidyverse-patterns/
├── r-shiny/
├── r-bayes/
├── r-style-guide/
├── r-performance/
├── r-oop/
├── r-package-development/
├── dm-relational/
├── rlang-patterns/
├── tdd-workflow/
└── skillMaker/

knowledge-base/             # Extracted knowledge sources
├── README.md
├── r4ds-knowledge-extraction.md              (21K)
├── mdsr-knowledge-extraction.md              (27K)
├── tidymodels-ml-knowledge-base.md           (52K)
├── islr-statistical-learning-knowledge.md    (30K)
├── time_series_forecasting_knowledge.md      (34K)
└── [planning and architecture docs]
```

## 🛠️ Creating Custom Skills

Use the included `skillMaker` skill to create your own:

```bash
/skillMaker
```

Follow the guided workflow to generate production-ready skills. See [CLAUDE.md](CLAUDE.md) for detailed skill development guidelines.

## 🤝 Contributing

Contributions are welcome! To add or improve a skill:

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/new-skill`
3. Use `/skillMaker` to generate your skill following best practices
4. Test thoroughly in real-world scenarios
5. Submit a pull request with clear description

### Contribution Guidelines

- Follow the [skill creation conventions](CLAUDE.md#skill-creation-workflow)
- Include concrete examples and trigger phrases
- Test both manual and automatic invocation
- Document all features in README.md
- Keep SKILL.md under 500 lines (use supporting files for larger skills)

## 📋 Requirements

- **Claude Code CLI** - Install from [claude.ai/code](https://claude.ai/code)
- **R** (version 4.0+) - For R-specific skills
- **RStudio** (optional) - Enhanced integration with R skills

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

## 🔗 Resources

### Claude Code
- [Claude Code Documentation](https://docs.claude.ai/code)
- [Skill Development Guide](CLAUDE.md)
- [SkillMaker Architecture](/.claude/skills/skillMaker/ARCHITECTURE.md)

### R Data Science
- [R for Data Science](https://r4ds.had.co.nz/) - Tidyverse foundation
- [Tidyverse](https://www.tidyverse.org/) - Core data science packages
- [Tidymodels](https://www.tidymodels.org/) - Machine learning framework
- [Tidy Modeling with R](https://www.tmwr.org/) - ML book

### Specialized Topics
- [Forecasting: Principles and Practice](https://otexts.com/fpp3/) - Time series
- [Text Mining with R](https://www.tidytextmining.com/) - NLP
- [Modern Data Science with R](https://mdsr-book.github.io/) - Comprehensive guide
- [ISLR](https://www.statlearning.com/) - Statistical learning

### Community
- [R Project](https://www.r-project.org/)
- [Posit Community](https://community.rstudio.com/)

## 🙏 Acknowledgments

- Built with [Claude Code](https://claude.ai/code)
- Knowledge extracted from authoritative R resources:
  - R for Data Science by Hadley Wickham & Garrett Grolemund
  - Forecasting: Principles and Practice by Rob J Hyndman & George Athanasopoulos
  - Text Mining with R by Julia Silge & David Robinson
  - Tidy Modeling with R by Max Kuhn & Julia Silge
  - Modern Data Science with R by Benjamin S. Baumer, Daniel T. Kaplan & Nicholas J. Horton
  - An Introduction to Statistical Learning by Gareth James et al.
- Based on conventions from tidyverse, tidymodels, fable, tidytext, brms, shiny, and other excellent R packages
- Inspired by the R community's best practices

## 📮 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/claude-r-skills/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/claude-r-skills/discussions)
- **Updates**: Watch this repository for new skills and improvements

---

Made with ❤️ for the R community | Powered by Claude Code
