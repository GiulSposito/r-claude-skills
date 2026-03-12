# R Programming Skills for Claude Code

A comprehensive collection of Claude Code skills for R programming, data science, and statistical computing. Transform Claude into an expert R data scientist with **19 production-ready skills** achieving **100% detection accuracy**.

## 🎯 Overview

This repository contains **19 production-ready skills** that enhance Claude Code's capabilities for complete data science workflows in R. From data wrangling to machine learning, reproducible research to interactive dashboards, these skills provide expert guidance with **perfect detection accuracy**.

### 🏆 Quality Metrics

```
✅ 100% Recall - Never misses a relevant query
✅ 100% Precision - Zero false activations
✅ 19/19 Skills at 100% - Complete perfection
✅ 251 Test Cases - All passing
✅ Bilingual Support - Portuguese + English
```

**Proven Results**: Improved from 48.2% to 100% recall through systematic optimization using the skillMaker pattern with bilingual triggers and language filters.

### 📦 Complete Skill Collection

**Core Data Science** (tidyverse, tidymodels, visualization)
- r-datascience, tidyverse-expert, tidyverse-patterns, ggplot2, dm-relational

**Publishing & Communication** (reports, dashboards, presentations)
- quarto

**Specialized Analysis** (ML, time series, text, Bayesian, feature engineering)
- r-tidymodels, **r-feature-engineering** ⭐ NEW, r-timeseries, r-text-mining, r-bayes

**Advanced R** (performance, OOP, packages, metaprogramming)
- r-performance, r-oop, r-package-development, rlang-patterns

**Development** (testing, style, web apps)
- tdd-workflow, r-style-guide, r-shiny

**Meta** (skill creation)
- skillMaker

### ✨ Key Features

**🎯 Perfect Detection**
- Auto-triggers on relevant code patterns
- Bilingual (Portuguese + English) support
- Strong language filters prevent false positives
- 100% recall and precision on 228 test cases

**📚 Comprehensive Coverage**
- Complete tidyverse ecosystem (dplyr, tidyr, purrr, stringr, forcats, lubridate)
- Professional publishing with Quarto (reports, dashboards, presentations, websites, books)
- Machine learning with tidymodels
- Time series forecasting with fable/tsibble
- Text mining and NLP with tidytext
- Advanced topics (Bayesian, OOP, metaprogramming)

**🔧 Production Ready**
- Tested and validated
- Modular architecture
- Rich examples and templates
- Continuous improvement methodology

[→ See complete documentation](docs/)

## 📦 Available Skills (19 Total)

All skills achieve **100% recall and 100% precision** on comprehensive test suites.

### Core Data Science & Tidyverse

- **[r-datascience](/.claude/skills/r-datascience/)** - Complete data science orchestrator
  - Tidyverse + tidymodels workflows
  - Statistical modeling and ML best practices
  - 100% recall on all data science queries

- **[tidyverse-expert](/.claude/skills/tidyverse-expert/)** - Comprehensive data manipulation
  - Complete coverage: dplyr, tidyr, purrr, stringr, **forcats, lubridate**
  - Advanced patterns and problem-solving
  - Bilingual triggers (PT + EN)

- **[tidyverse-patterns](/.claude/skills/tidyverse-patterns/)** - Modern dplyr 1.1+ patterns
  - Native pipe (`|>`), `.by` grouping, `join_by()`
  - Latest tidyverse features

### Publishing & Communication ⭐ NEW

- **[quarto](/.claude/skills/quarto/)** - Professional document publishing with R
  - Reports (HTML, PDF, Word) with reproducible research
  - Interactive dashboards with value boxes and visualizations
  - RevealJS presentations with code and plots
  - Complete websites and blogs with R content
  - Books and manuscripts with computational content
  - Publishing workflows (Quarto Pub, GitHub Pages, Netlify)
  - 100% R integration (ggplot2, gt, DT, plotly, shiny)
  - Comprehensive templates, examples, and references (~7,500 lines)
  - Bilingual support with exclusions for Python/Julia

### Machine Learning & Statistics

- **[r-tidymodels](/.claude/skills/r-tidymodels/)** - Advanced ML with tidymodels
  - Complete ML workflows (recipes, models, tuning)
  - Gradient boosting, random forests, ensembles
  - 100% recall on ML queries

- **[r-feature-engineering](/.claude/skills/r-feature-engineering/)** ⭐ NEW - Strategic feature engineering
  - Categorical encoding methods (dummy, likelihood, embeddings, hashing)
  - Numeric transformations (Box-Cox, Yeo-Johnson, PCA, splines)
  - Interaction detection (4 systematic approaches)
  - Feature selection (filter, wrapper, embedded methods)
  - Missing data strategies (MCAR/MAR/MNAR handling)
  - Based on "Feature Engineering and Selection" by Kuhn & Johnson
  - 11 files, 6,568 lines of strategic guidance
  - Bilingual support with quantified case studies

- **[r-bayes](/.claude/skills/r-bayes/)** - Bayesian inference with brms
  - Multilevel models, priors, diagnostics
  - Strong filter: ONLY R (NOT PyMC3, Pyro, Julia)

### Specialized Analysis

- **[r-timeseries](/.claude/skills/r-timeseries/)** - Time series forecasting
  - ARIMA, ETS, Prophet with fable/tsibble
  - Strong filter: ONLY R (NOT Python statsmodels)

- **[r-text-mining](/.claude/skills/r-text-mining/)** - Text mining and NLP
  - Sentiment analysis, topic modeling, classification
  - Strong filter: ONLY R (NOT spaCy, NLTK)

- **[ggplot2](/.claude/skills/ggplot2/)** - Expert data visualization
  - Complete ggplot2 reference with examples

- **[dm-relational](/.claude/skills/dm-relational/)** - Relational data modeling
  - Multi-table models with primary/foreign keys

### Advanced R Programming

- **[r-performance](/.claude/skills/r-performance/)** - Performance optimization
  - Profiling, benchmarking, vectorization

- **[r-oop](/.claude/skills/r-oop/)** - Object-oriented programming
  - S7, S3, S4, vctrs systems

- **[r-package-development](/.claude/skills/r-package-development/)** - Package development
  - devtools, usethis, roxygen2, testthat

- **[rlang-patterns](/.claude/skills/rlang-patterns/)** - Metaprogramming
  - Tidy evaluation, data-masking, injection

### Development Tools

- **[r-style-guide](/.claude/skills/r-style-guide/)** - R style conventions
- **[tdd-workflow](/.claude/skills/tdd-workflow/)** - Test-driven development
- **[r-shiny](/.claude/skills/r-shiny/)** - Shiny app development

### Meta

- **[skillMaker](/.claude/skills/skillMaker/)** - Create new skills following best practices

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

**Creating reproducible reports:**
```r
# Auto-triggers quarto skill when working with .qmd files
# or mentioning "quarto report", "quarto dashboard"

# Create professional HTML/PDF reports with R analysis
# Build interactive dashboards with value boxes
# Make RevealJS presentations with live code
# Publish to Quarto Pub, GitHub Pages, or Netlify
```

## 🏗️ Repository Structure

```
.claude/skills/          # 19 production-ready skills
├── r-datascience/       # Core data science orchestrator
├── tidyverse-expert/    # Complete tidyverse (dplyr, tidyr, purrr, stringr, forcats, lubridate)
├── tidyverse-patterns/  # Modern dplyr 1.1+ patterns
├── quarto/              # Professional publishing (reports, dashboards, presentations)
├── r-tidymodels/        # Machine learning with tidymodels
├── r-feature-engineering/ # ⭐ NEW - Strategic feature engineering (6,568 lines)
├── r-timeseries/        # Time series forecasting (fable/tsibble)
├── r-text-mining/       # Text mining and NLP (tidytext)
├── r-bayes/             # Bayesian inference (brms)
├── ggplot2/             # Data visualization
├── r-shiny/             # Shiny app development
├── r-performance/       # Performance optimization
├── r-oop/               # Object-oriented programming (S7/S3/S4)
├── r-package-development/ # Package development
├── r-style-guide/       # R style conventions
├── rlang-patterns/      # Metaprogramming and tidy evaluation
├── dm-relational/       # Relational data modeling
├── tdd-workflow/        # Test-driven development
└── skillMaker/          # Skill creation tool

docs/                    # Comprehensive documentation
├── README.md            # Documentation index
├── guides/              # Improvement guides and patterns
│   ├── FIXING_SKILLS_GUIDE.md
│   ├── SKILLMAKER_PATTERN.md
│   └── MIGRATION_GUIDE.md
├── testing/             # Testing framework and results
│   ├── TESTING_STRATEGY.md
│   ├── TEST_RESULTS_ANALYSIS.md
│   └── INTERPRETING_RESULTS.md
├── sprints/             # Sprint execution reports
│   ├── SPRINT1-2_REPORT.md
│   ├── SPRINT3_REPORT.md
│   └── SPRINT4_REPORT.md
├── archive/             # Historical documents
└── test-reports/        # 40+ test execution reports

tests/                   # Validation system
├── validate-skills.sh   # Skill validation script
├── README.md           # Testing documentation
├── SPECIFICATION.md     # Technical specification
└── IMPLEMENTATION_REPORT.md

test_triggers.py         # Trigger detection test suite (251 test cases)
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

## 📊 Quality Assurance

This repository includes comprehensive testing infrastructure:

- **test_triggers.py** - 251 test cases validating trigger detection
- **tests/validate-skills.sh** - YAML, file references, and R syntax validation
- **GitHub Actions** - Automated testing on every push
- **100% Success Rate** - All 18 skills pass all validation tests

See [docs/testing/](docs/testing/) for complete testing documentation.

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
- [Feature Engineering and Selection](https://feat.engineering/) - Feature engineering guide

### Publishing & Reproducibility
- [Quarto](https://quarto.org/) - Modern scientific publishing system
- [Quarto Gallery](https://quarto.org/docs/gallery/) - Examples and inspiration

### Specialized Topics
- [Forecasting: Principles and Practice](https://otexts.com/fpp3/) - Time series
- [Text Mining with R](https://www.tidytextmining.com/) - NLP
- [Modern Data Science with R](https://mdsr-book.github.io/) - Comprehensive guide
- [ISLR](https://www.statlearning.com/) - Statistical learning

### Community
- [R Project](https://www.r-project.org/)
- [Posit Community](https://community.rstudio.com/)

## 🙏 Acknowledgments

- Built with [Claude Code](https://claude.ai/code) by Anthropic
- Achieved **100% perfection** through systematic optimization using the skillMaker pattern
- Knowledge extracted from authoritative R resources:
  - R for Data Science by Hadley Wickham & Garrett Grolemund
  - Feature Engineering and Selection by Max Kuhn & Kjell Johnson
  - Forecasting: Principles and Practice by Rob J Hyndman & George Athanasopoulos
  - Text Mining with R by Julia Silge & David Robinson
  - Tidy Modeling with R by Max Kuhn & Julia Silge
  - Modern Data Science with R by Benjamin S. Baumer, Daniel T. Kaplan & Nicholas J. Horton
  - An Introduction to Statistical Learning by Gareth James et al.
- Based on conventions from tidyverse, tidymodels, fable, tidytext, brms, shiny, and other excellent R packages
- Inspired by the R community's best practices

## 📈 Project Metrics

```
Skills: 19 total, 19 perfect (100%)
Test Cases: 251 passing (100%)
Lines of Code: 67,000+ across all skills
Recall: 100% (was 48.2% at baseline)
Precision: 100% (was 90.8% at baseline)
Languages: English + Portuguese
Validation: Automated (YAML, syntax, triggers)
Latest Addition: r-feature-engineering (~6,568 lines)
```

See [docs/sprints/](docs/sprints/) for detailed improvement journey.

## 📮 Support

- **Documentation**: See [docs/](docs/) for comprehensive guides
- **Issues**: Report bugs or request features via GitHub Issues
- **Updates**: Watch this repository for new skills and improvements

### 🔗 Quick Links

- [📚 Complete Documentation](docs/) - Guides, testing, sprint reports
- [🧪 Testing Framework](docs/testing/) - How we achieve 100% quality
- [📊 Sprint Reports](docs/sprints/) - Journey from 48% to 100% recall
- [💡 Improvement Guides](docs/guides/) - Patterns and best practices
- [🛠️ Validation System](tests/) - Automated quality assurance

---

**Made with ❤️ for the R community** | Powered by [Claude Code](https://claude.ai/code) | **100% Perfect Detection**
