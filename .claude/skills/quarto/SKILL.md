---
name: quarto
description: |
  Expert Quarto document creation and publishing with R. Use when working with Quarto,
  mentions "criar relatório", "quarto report", "quarto dashboard", "quarto presentation",
  "apresentação quarto", "quarto slides", "quarto website", "site quarto", "blog quarto",
  "quarto book", "livro quarto", "documento quarto", "render quarto", "renderizar quarto",
  "publicar quarto", "publish quarto", ".qmd file", "arquivo qmd", discusses reproducible
  research, data storytelling, interactive reports, scientific writing with R, or asks
  about creating reports, dashboards, presentations, websites, or books with R.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash(quarto *), Bash(Rscript *)
---

# Quarto Expert - Professional R Document Publishing

Create publication-quality reports, dashboards, presentations, websites, and books using Quarto with R.

## Overview

Quarto is the next-generation scientific and technical publishing system that uses **knitr** for R code execution. It combines the power of R with modern publishing capabilities to create:

- **Reports**: Reproducible analytical documents (HTML, PDF, Word)
- **Dashboards**: Interactive data dashboards with or without Shiny
- **Presentations**: Professional slides with RevealJS
- **Websites & Blogs**: Full websites with R-powered content
- **Books**: Complete manuscripts and technical books

Quarto maintains strong R Markdown compatibility while adding extensive new features.

## Current Environment

- Working directory: /Users/gsposito/Projects/claudeSkiller
- Available formats: HTML, PDF, Word, RevealJS, Dashboard

## When This Skill Activates

Use this skill when the user wants to:
- Create or modify Quarto documents (`.qmd` files)
- Generate reports with R code and visualizations
- Build interactive dashboards
- Create presentations with R content
- Set up websites or blogs with R analysis
- Write books or manuscripts with computational content
- Convert R Markdown to Quarto
- Troubleshoot rendering or publishing issues
- Configure YAML frontmatter for Quarto documents
- Integrate R packages (ggplot2, gt, DT, plotly, shiny) with Quarto

## Workflow

### Phase 1: Understand Requirements

Ask the user (if not clear from context):

1. **Document Type**
   - Report (analytical document)
   - Dashboard (interactive visualizations)
   - Presentation (slides)
   - Website/Blog
   - Book/Manuscript

2. **Output Format**
   - HTML (interactive, web-based)
   - PDF (print-ready, requires LaTeX)
   - Word (editable document)
   - Multiple formats

3. **R Integration Level**
   - Code visibility (show/hide code)
   - Interactive widgets (plotly, leaflet, DT)
   - Shiny components
   - Parameter support

4. **Content Scope**
   - Single document or project
   - Existing content to convert
   - New document from scratch

### Phase 2: Structure Selection

Based on document type, use appropriate template:

**Simple Report** → [templates/report-template.qmd](templates/report-template.qmd)
**Dashboard** → [templates/dashboard-template.qmd](templates/dashboard-template.qmd)
**Presentation** → [templates/presentation-template.qmd](templates/presentation-template.qmd)
**Website** → [templates/website-quarto.yml](templates/website-quarto.yml)
**Book** → [templates/book-quarto.yml](templates/book-quarto.yml)

### Phase 3: Content Generation

#### A. Create YAML Frontmatter

Use appropriate configuration from [references/yaml-options.md](references/yaml-options.md):

**Basic Report:**
```yaml
---
title: "Analysis Report"
author: "Author Name"
date: today
format: html
execute:
  echo: false
  warning: false
---
```

**Multi-Format:**
```yaml
---
title: "Report"
format:
  html:
    code-fold: true
    toc: true
  pdf:
    keep-tex: true
  docx:
    toc: true
---
```

#### B. Add R Code Chunks

Use YAML-style chunk options (see [references/chunk-options.md](references/chunk-options.md)):

```r
```{r}
#| label: fig-analysis
#| fig-cap: "Data visualization"
#| echo: false
#| warning: false

library(ggplot2)
ggplot(data, aes(x, y)) + geom_point()
```
```

#### C. Integrate R Packages

Common patterns (see [references/r-integration.md](references/r-integration.md)):

- **ggplot2**: Static visualizations
- **plotly**: Interactive plots
- **gt/DT**: Professional tables
- **leaflet**: Interactive maps
- **shiny**: Interactive applications

### Phase 4: Preview & Render

```bash
# Preview with live reload
quarto preview document.qmd

# Render to default format
quarto render document.qmd

# Render to specific format
quarto render document.qmd --to pdf

# Render entire project
quarto render
```

### Phase 5: Publishing (Optional)

See [references/publishing.md](references/publishing.md) for complete workflows:

```bash
# Quarto Pub
quarto publish quarto-pub

# GitHub Pages
quarto publish gh-pages

# Netlify
quarto publish netlify
```

## Document Types Guide

### 1. Reports & Documents

**Use Case**: Analytical reports, research papers, technical documentation

**Key Features**:
- Code folding and hiding
- Cross-references (figures, tables, equations)
- Citations and bibliographies
- Multiple output formats
- Parameters for reproducibility

**Quick Start**:
```yaml
---
title: "Analysis Report"
format:
  html:
    code-fold: true
    toc: true
execute:
  echo: false
  warning: false
---

```{r setup}
library(tidyverse)
```

## Analysis

```{r}
#| label: fig-results
#| fig-cap: "Key findings"

ggplot(data, aes(x, y)) + geom_point()
```
```

See [examples/complete-report.qmd](examples/complete-report.qmd) for full example.

### 2. Dashboards

**Use Case**: Interactive data dashboards, KPI monitors, analytics displays

**Key Features**:
- Automatic layout with rows/columns
- Value boxes and cards
- Integration with Shiny for reactivity
- Tabsets and navigation
- Real-time data updates

**Quick Start**:
```yaml
---
title: "Sales Dashboard"
format: dashboard
---

## Row

```{r}
#| title: "Total Sales"
library(bslib)
value_box(
  title = "Total Sales",
  value = "$1.2M",
  showcase = bsicons::bs_icon("cash")
)
```

```{r}
#| title: "Revenue Trend"
library(ggplot2)
ggplot(sales, aes(date, revenue)) + geom_line()
```
```

See [examples/dashboard-example.qmd](examples/dashboard-example.qmd) for full example.

For comprehensive dashboard patterns including layout strategies, value boxes, theming, Shiny integration, and deployment, see [references/dashboards.md](references/dashboards.md).

### 3. Presentations

**Use Case**: Conference talks, teaching slides, webinars

**Key Features**:
- RevealJS for web-based slides
- Incremental content reveal
- Speaker notes
- Code highlighting with execution
- Multi-column layouts
- Themes and customization

**Quick Start**:
```yaml
---
title: "Data Analysis Presentation"
format:
  revealjs:
    theme: dark
    slide-number: true
---

## Introduction

Content here

## Analysis

```{r}
#| echo: true
#| output-location: column

plot(cars)
```
```

See [examples/presentation-example.qmd](examples/presentation-example.qmd) for full example.

### 4. Websites & Blogs

**Use Case**: Project websites, documentation sites, data blogs

**Key Features**:
- Navigation and site structure
- Blog listings with RSS
- Search functionality
- Responsive design
- R-powered content pages

**Quick Start** (create `_quarto.yml`):
```yaml
project:
  type: website

website:
  title: "My Data Blog"
  navbar:
    left:
      - href: index.qmd
        text: Home
      - href: about.qmd
        text: About

format:
  html:
    theme: cosmo
    toc: true
```

See [examples/website-structure.md](examples/website-structure.md) for full example.

### 5. Books

**Use Case**: Technical books, course materials, comprehensive documentation

**Key Features**:
- Multi-chapter structure
- Part/chapter organization
- Cross-references across chapters
- Multiple output formats (HTML, PDF, ePub)
- Search and navigation

**Quick Start** (create `_quarto.yml`):
```yaml
project:
  type: book

book:
  title: "R for Data Analysis"
  author: "Author Name"
  chapters:
    - index.qmd
    - chapter1.qmd
    - chapter2.qmd

format:
  html:
    theme: cosmo
  pdf:
    documentclass: scrbook
```

## R Integration Patterns

### Code Chunk Options

All chunk options use YAML-style comments:

```r
```{r}
#| label: descriptive-name
#| echo: false          # Hide code
#| warning: false       # Hide warnings
#| message: false       # Hide messages
#| fig-cap: "Caption"   # Figure caption
#| fig-width: 8         # Figure width in inches
#| fig-height: 6        # Figure height in inches
#| cache: true          # Cache results
#| code-fold: true      # Collapsible code

# R code here
```
```

Complete reference: [references/chunk-options.md](references/chunk-options.md)

### Common R Packages

**Visualization:**
- `ggplot2` - Grammar of graphics
- `plotly` - Interactive plots (use `ggplotly()` for easy conversion)
- `leaflet` - Interactive maps
- `dygraphs` - Time series charts

**Tables:**
- `knitr::kable()` - Simple tables
- `gt` - Grammar of tables (publication-quality)
- `DT::datatable()` - Interactive tables
- `reactable` - Modern interactive tables

**Data Processing:**
- `dplyr` - Data manipulation
- `tidyr` - Data tidying
- `readr` - Data import

**Interactive Apps:**
- `shiny` - Web applications
- `bslib` - Bootstrap components for dashboards

Example integration:
```r
```{r}
#| label: fig-interactive
#| fig-cap: "Interactive visualization"

library(plotly)
p <- ggplot(data, aes(x, y, color = group)) + geom_point()
ggplotly(p)
```
```

### Cross-References

**Figures:**
```r
```{r}
#| label: fig-scatter
#| fig-cap: "Relationship between variables"

plot(cars)
```

See @fig-scatter for details.
```

**Tables:**
```r
```{r}
#| label: tbl-summary
#| tbl-cap: "Summary statistics"

knitr::kable(summary(mtcars))
```

Results in @tbl-summary show...
```

**Sections:**
```markdown
## Methods {#sec-methods}

As described in @sec-methods...
```

## Parameters for Reproducibility

**Define parameters:**
```yaml
---
title: "Monthly Report"
params:
  month: "January"
  year: 2024
  region: "North"
---
```

**Use in R code:**
```r
```{r}
# Access parameters
current_month <- params$month
data_filtered <- data |>
  filter(month == params$month,
         year == params$year,
         region == params$region)
```
```

**Render with different parameters:**
```bash
quarto render report.qmd -P month:February -P year:2024
```

## Project Organization

For multi-file projects, create `_quarto.yml`:

```yaml
project:
  type: default
  output-dir: _output

execute:
  freeze: auto  # Cache computations

format:
  html:
    theme: cosmo
    toc: true
    code-fold: true
```

Project structure:
```
project/
  _quarto.yml          # Project config
  index.qmd            # Main page
  analysis/            # Analysis documents
    report1.qmd
    report2.qmd
  data/                # Data files
  _freeze/             # Cached computations (auto-generated)
  _output/             # Rendered output
```

## Troubleshooting

### Rendering Errors

**R package not found:**
```r
# Add to setup chunk
if (!require("package")) install.packages("package")
library(package)
```

**LaTeX not available (for PDF):**
```r
# Install TinyTeX from R
install.packages("tinytex")
tinytex::install_tinytex()
```

**Caching issues:**
```bash
# Clear cache and re-render
quarto render --cache-refresh
```

### Code Chunk Issues

**Chunk not executing:**
- Check YAML syntax (use `#|` not `#:`)
- Verify indentation in chunk options
- Ensure `execute: eval: true` is not overridden

**Figures not showing:**
- Check `fig-cap` is set for cross-references
- Verify chunk produces a plot
- Check `include: false` is not set

### YAML Errors

**Common mistakes:**
```yaml
# ❌ Wrong
format:
html:
  toc: true

# ✅ Correct
format:
  html:
    toc: true
```

## Best Practices

### Code Organization

1. **Setup chunk first:**
```r
```{r setup}
#| include: false

library(tidyverse)
library(gt)
theme_set(theme_minimal())

# Set global chunk options
knitr::opts_chunk$set(
  fig.retina = 3,
  fig.width = 8,
  fig.asp = 0.618
)
```
```

2. **Label all chunks:** Use descriptive `label:` for cross-references and debugging

3. **Hide code by default:** Set `execute: echo: false` in YAML, show selectively

4. **Use caching wisely:** Cache expensive computations, but be aware of dependencies

### Reproducibility

- Use parameters for variable inputs
- Include session info: `sessionInfo()` or `quarto::quarto_version()`
- Document data sources and versions
- Use relative paths (not absolute)
- Pin package versions with `renv`

### Performance

- Enable `freeze: auto` for large projects
- Cache expensive chunks with `cache: true`
- Use `eval: false` for example code
- Optimize figure sizes (`fig-width`, `fig-height`, `dpi`)

## Migration from R Markdown

Most `.Rmd` files work in Quarto with minimal changes:

**Key differences:**
1. Chunk options: `#| option: value` instead of `{r, option=value}`
2. YAML key: `format:` instead of `output:`
3. Hyphenation: `fig-cap` instead of `fig.cap` or `fig_cap`

**Quick conversion:**
```bash
# Render .Rmd with Quarto
quarto render document.Rmd

# Convert chunk options (manual)
# Old: ```{r, echo=FALSE, fig.cap="Plot"}
# New: ```{r}
#      #| echo: false
#      #| fig-cap: "Plot"
```

## Supporting Resources

**Templates:**
- [templates/report-template.qmd](templates/report-template.qmd) - Basic report structure
- [templates/dashboard-template.qmd](templates/dashboard-template.qmd) - Dashboard layout
- [templates/presentation-template.qmd](templates/presentation-template.qmd) - Slides template
- [templates/website-quarto.yml](templates/website-quarto.yml) - Website configuration
- [templates/book-quarto.yml](templates/book-quarto.yml) - Book configuration

**Examples:**
- [examples/complete-report.qmd](examples/complete-report.qmd) - Full analytical report
- [examples/dashboard-example.qmd](examples/dashboard-example.qmd) - Interactive dashboard
- [examples/presentation-example.qmd](examples/presentation-example.qmd) - Complete presentation
- [examples/website-structure.md](examples/website-structure.md) - Website project setup

**References:**
- [references/yaml-options.md](references/yaml-options.md) - Complete YAML configuration
- [references/chunk-options.md](references/chunk-options.md) - All code chunk options
- [references/r-integration.md](references/r-integration.md) - R packages and patterns
- [references/dashboards.md](references/dashboards.md) - Comprehensive dashboard patterns
- [references/publishing.md](references/publishing.md) - Publishing workflows

**External Resources:**
- Official Guide: https://quarto.org/docs/guide/
- R Integration: https://quarto.org/docs/computations/r.html
- Dashboard Guide: https://quarto.org/docs/dashboards/
- Gallery: https://quarto.org/docs/gallery/
- Reference: https://quarto.org/docs/reference/

## Quick Reference

### Common Commands

```bash
# Create new document
quarto create document.qmd

# Preview with live reload
quarto preview document.qmd

# Render to default format
quarto render document.qmd

# Render to specific format
quarto render document.qmd --to pdf

# Render entire project
quarto render

# Publish to Quarto Pub
quarto publish quarto-pub

# Check installation
quarto check
```

### Essential YAML Patterns

**HTML with code folding:**
```yaml
format:
  html:
    code-fold: true
    code-tools: true
    toc: true
```

**PDF with LaTeX:**
```yaml
format:
  pdf:
    toc: true
    number-sections: true
    keep-tex: true
```

**Dashboard:**
```yaml
format: dashboard
```

**RevealJS Presentation:**
```yaml
format:
  revealjs:
    theme: dark
    slide-number: true
```

### Essential Chunk Options

```r
```{r}
#| label: chunk-name         # Required for cross-ref
#| echo: false               # Hide code
#| eval: true                # Run code
#| include: true             # Include output
#| warning: false            # Hide warnings
#| message: false            # Hide messages
#| fig-cap: "Caption"        # Figure caption
#| tbl-cap: "Caption"        # Table caption
#| cache: true               # Cache results
#| code-fold: show           # Show but collapsible
```
```
