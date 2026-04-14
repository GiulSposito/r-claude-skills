# Quarto Code Chunk Options Reference

Complete reference for code chunk options in Quarto documents.

## Chunk Syntax

### R Chunks
```r
```{r}
#| label: chunk-name
#| echo: false
#| fig-cap: "Figure caption"

# R code here
```
```

### Python Chunks
```python
```{python}
#| label: chunk-name
#| echo: false

# Python code here
```
```

### Hash-Pipe (#|) vs. Traditional
```r
# Modern (recommended)
```{r}
#| echo: false
#| warning: false
```

# Traditional (still works)
```{r echo=FALSE, warning=FALSE}
```
```

## Core Execution Options

### Basic Control
| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `eval` | true/false/[integers] | true | Evaluate code |
| `echo` | true/false/fenced | true | Display code |
| `output` | true/false/asis | true | Include output |
| `warning` | true/false | true | Display warnings |
| `error` | true/false | false | Display errors (or halt) |
| `message` | true/false | true | Display messages |
| `include` | true/false | true | Include chunk in output |

### Examples
```r
# Run but don't show code or output
```{r}
#| include: false

data <- read.csv("data.csv")
```

# Show code but don't run
```{r}
#| eval: false

model <- lm(y ~ x, data = df)
```

# Show code as-is (no syntax highlighting)
```{r}
#| echo: fenced

print("This shows the chunk delimiters too")
```

# Run only specific lines
```{r}
#| eval: [1, 3, 5]

line1 <- 1  # Runs
line2 <- 2  # Skips
line3 <- 3  # Runs
line4 <- 4  # Skips
line5 <- 5  # Runs
```
```

## Figure Options

### Figure Dimensions
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `fig-width` | numeric | 7 | Width in inches |
| `fig-height` | numeric | 5 | Height in inches |
| `fig-asp` | numeric | NULL | Aspect ratio (height/width) |
| `fig-dpi` | numeric | 72 | DPI for raster images |
| `out-width` | string | NULL | Output width (e.g., "100%", "8in") |
| `out-height` | string | NULL | Output height |

### Figure Format and Quality
| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `fig-format` | png/jpg/svg/pdf/retina | png | Output format |
| `fig-dpi` | numeric | 96 | Resolution |
| `dev` | ragg/cairo/... | ragg | Graphics device |

### Figure Captions and Alt Text
| Option | Type | Description |
|--------|------|-------------|
| `fig-cap` | string | Figure caption |
| `fig-subcap` | array | Subcaptions for multiple figures |
| `fig-alt` | string | Alt text for accessibility |

### Figure Alignment and Position
| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `fig-align` | left/center/right/default | default | Horizontal alignment |
| `fig-pos` | H/t/b/p | NULL | LaTeX position (PDF only) |
| `fig-env` | string | figure | LaTeX environment (PDF only) |

### Multiple Figures
| Option | Type | Description |
|--------|------|-------------|
| `layout-ncol` | numeric | Number of columns |
| `layout-nrow` | numeric | Number of rows |
| `layout` | array | Custom layout matrix |

### Examples
```r
# Basic figure with caption
```{r}
#| label: fig-scatter
#| fig-cap: "Relationship between variables"
#| fig-alt: "Scatterplot showing positive correlation"

plot(cars)
```

# High-resolution figure
```{r}
#| fig-width: 10
#| fig-height: 6
#| fig-dpi: 300
#| fig-format: png

ggplot(mtcars, aes(mpg, hp)) + geom_point()
```

# Multiple figures side-by-side
```{r}
#| label: fig-comparison
#| fig-cap: "Model comparison"
#| fig-subcap:
#|   - "Linear model"
#|   - "Quadratic model"
#| layout-ncol: 2

plot(lm(y ~ x))  # First figure
plot(lm(y ~ poly(x, 2)))  # Second figure
```

# Custom layout
```{r}
#| layout: [[1,1], [1]]
#| fig-cap: "Three panel figure"

plot(cars)      # Top left
plot(iris)      # Top right
plot(mtcars)    # Bottom full width
```

# Responsive figure
```{r}
#| fig-width: 8
#| out-width: "100%"
#| fig-responsive: true

ggplot(data) + geom_line()
```

# SVG for web, PDF for print
```{r}
#| fig-format: svg

plot(data)
```
```

## Table Options

### Table Formatting
| Option | Type | Description |
|--------|------|-------------|
| `tbl-cap` | string | Table caption |
| `tbl-subcap` | array | Subcaptions for multiple tables |
| `tbl-colwidths` | array | Column width percentages |
| `tbl-cap-location` | top/bottom/margin | Caption position |

### Examples
```r
# Basic table with caption
```{r}
#| label: tbl-summary
#| tbl-cap: "Summary statistics"

knitr::kable(summary(cars))
```

# Control column widths
```{r}
#| tbl-colwidths: [25, 25, 50]

knitr::kable(data)
```

# Multiple tables
```{r}
#| label: tbl-compare
#| tbl-cap: "Data comparison"
#| tbl-subcap:
#|   - "Group A"
#|   - "Group B"
#| layout-ncol: 2

knitr::kable(group_a)
knitr::kable(group_b)
```
```

## Layout Options

### Page Layout
| Option | Values | Description |
|--------|--------|-------------|
| `column` | body/page/screen/margin | Content width |
| `fig-column` | body/page/screen/margin | Figure column |

### Examples
```r
# Full page width figure
```{r}
#| column: page
#| fig-width: 12

ggplot(data) + geom_point()
```

# Margin figure
```{r}
#| column: margin
#| fig-width: 3

plot(small_data)
```

# Screen width (for presentations)
```{r}
#| column: screen

large_table
```
```

## Code Display Options

### Code Folding and Tools
| Option | Values | Description |
|--------|--------|-------------|
| `code-fold` | true/false/show | Fold code blocks |
| `code-summary` | string | Summary text for folded code |
| `code-overflow` | wrap/scroll | Handle long lines |
| `code-line-numbers` | true/false | Show line numbers |

### Code Annotation
| Option | Values | Description |
|--------|--------|-------------|
| `code-annotations` | hover/select/below | Annotation display |

### Examples
```r
# Foldable code
```{r}
#| code-fold: true
#| code-summary: "Show the data processing code"

data_clean <- data |>
  filter(!is.na(value)) |>
  mutate(log_value = log(value))
```

# Line numbers
```{r}
#| code-line-numbers: true

function_with_many_lines <- function(x) {
  step1 <- x * 2
  step2 <- step1 + 10
  step3 <- sqrt(step2)
  return(step3)
}
```

# Code annotations
```{r}
#| code-annotations: hover

library(ggplot2)
ggplot(mtcars, aes(x = mpg, y = hp)) + # <1>
  geom_point() + # <2>
  theme_minimal() # <3>
```
1. Define the data and aesthetics
2. Add points to the plot
3. Apply minimal theme

# Wrap long lines
```{r}
#| code-overflow: wrap

very_long_function_name_that_would_normally_scroll_off_the_page(argument1, argument2, argument3)
```
```

## Caching Options

### Cache Control
| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `cache` | true/false/refresh | false | Cache chunk results |
| `cache.vars` | array | NULL | Variables to cache |
| `cache.lazy` | true/false | true | Lazy load cache |
| `dependson` | string/array | NULL | Dependencies |

### Examples
```r
# Cache expensive computation
```{r}
#| label: expensive-model
#| cache: true

model <- train_large_model(data)
```

# Cache specific variables
```{r}
#| cache: true
#| cache.vars: [processed_data, model_fit]

raw_data <- read.csv("large.csv")
processed_data <- preprocess(raw_data)
model_fit <- fit_model(processed_data)
temp_var <- some_calculation()  # Not cached
```

# Depend on another chunk
```{r}
#| label: analysis
#| cache: true
#| dependson: expensive-model

predictions <- predict(model, new_data)
```

# Force cache refresh
```{r}
#| cache: refresh

updated_data <- fetch_latest_data()
```
```

## Output Options

### Results Format
| Option | Values | Description |
|--------|--------|-------------|
| `results` | markup/asis/hold/hide | Output format |
| `collapse` | true/false | Collapse code and output |

### Examples
```r
# Raw HTML output
```{r}
#| results: asis

cat("<div class='custom'>Custom HTML</div>")
```

# Hold all output until end
```{r}
#| results: hold

print("First")
print("Second")
print("Third")
```

# Hide output
```{r}
#| results: hide

invisible_calculation <- compute_something()
```

# Collapse code and output together
```{r}
#| collapse: true

x <- 1:5
print(x)
```
```

## Language Engine Options

### Engine Selection
| Option | Values | Description |
|--------|--------|-------------|
| `engine` | r/python/julia/bash/... | Code engine |

### Examples
```r
# Python chunk
```{python}
#| label: python-analysis

import pandas as pd
df = pd.read_csv("data.csv")
```

# Bash chunk
```{bash}
#| label: system-info

uname -a
```

# Julia chunk
```{julia}
#| label: julia-math

using Statistics
mean([1, 2, 3, 4, 5])
```
```

## Environment Options

### Working Directory and Paths
| Option | Type | Description |
|--------|------|-------------|
| `root.dir` | string | Working directory for chunk |

### Examples
```r
# Change working directory for this chunk
```{r}
#| root.dir: "data/"

files <- list.files()
```
```

## Advanced Options

### Conditional Evaluation
| Option | Type | Description |
|--------|------|-------------|
| `eval` | expression | R expression returning TRUE/FALSE |

### Hook Functions
| Option | Type | Description |
|--------|------|-------------|
| `opts.label` | string | Use predefined option set |

### Examples
```r
# Conditional execution
```{r}
#| eval: !expr Sys.getenv("RENDER_FULL") == "true"

expensive_full_analysis()
```

# Use predefined options
```{r}
#| opts.label: "figure-large"

plot(data)
```
```

## Cross-Reference Options

### Labels and References
| Option | Type | Description |
|--------|------|-------------|
| `label` | string | Chunk label (must start with prefix) |

### Prefixes
- `fig-` for figures: `#| label: fig-scatter`
- `tbl-` for tables: `#| label: tbl-summary`
- `eq-` for equations: `#| label: eq-model`

### Examples
```r
# Figure with reference
```{r}
#| label: fig-distribution
#| fig-cap: "Data distribution"

hist(data)
```

See @fig-distribution for the distribution.

# Table with reference
```{r}
#| label: tbl-results
#| tbl-cap: "Regression results"

knitr::kable(model_summary)
```

Results are shown in @tbl-results.
```

## Knitr-Specific Options (Legacy)

### Common Knitr Options Still Useful
| Option | Type | Description |
|--------|------|-------------|
| `comment` | string | Comment prefix for output |
| `prompt` | true/false | Add R prompt to code |
| `strip.white` | true/false | Strip blank lines |
| `class.source` | string | CSS class for source |
| `class.output` | string | CSS class for output |
| `attr.source` | string | Attributes for source |
| `attr.output` | string | Attributes for output |

### Examples
```r
# Custom comment prefix
```{r}
#| comment: "#>"

1 + 1
```

# Add CSS classes
```{r}
#| class.source: "custom-code"
#| class.output: "custom-output"

print("Styled output")
```
```

## Option Sets

### Define Reusable Option Sets
```r
# In setup chunk
```{r}
#| label: setup
#| include: false

knitr::opts_template$set(
  figure_large = list(
    fig.width = 10,
    fig.height = 7,
    fig.dpi = 300
  ),
  figure_small = list(
    fig.width = 5,
    fig.height = 3,
    fig.dpi = 150
  ),
  table_clean = list(
    echo = FALSE,
    message = FALSE,
    warning = FALSE
  )
)
```

# Use option set
```{r}
#| opts.label: "figure_large"

plot(big_data)
```
```

## Quick Reference Table

### Most Common Options
| Option | Quick Description | Example |
|--------|------------------|---------|
| `label` | Chunk identifier | `#| label: fig-plot` |
| `echo` | Show code | `#| echo: false` |
| `eval` | Run code | `#| eval: false` |
| `include` | Include in output | `#| include: false` |
| `warning` | Show warnings | `#| warning: false` |
| `message` | Show messages | `#| message: false` |
| `fig-cap` | Figure caption | `#| fig-cap: "My plot"` |
| `fig-width` | Figure width | `#| fig-width: 8` |
| `fig-height` | Figure height | `#| fig-height: 6` |
| `tbl-cap` | Table caption | `#| tbl-cap: "Results"` |
| `cache` | Cache results | `#| cache: true` |
| `code-fold` | Fold code | `#| code-fold: true` |

## Common Patterns

### Setup Chunk
```r
```{r}
#| label: setup
#| include: false

library(tidyverse)
library(knitr)

# Set global options
knitr::opts_chunk$set(
  echo = TRUE,
  warning = FALSE,
  message = FALSE,
  fig.width = 8,
  fig.height = 6
)
```
```

### Data Import (Hidden)
```r
```{r}
#| label: load-data
#| include: false

data <- read_csv("data.csv")
```
```

### Analysis with Folded Code
```r
```{r}
#| label: analysis
#| code-fold: true
#| code-summary: "Show analysis code"

model <- lm(y ~ x, data = data)
summary(model)
```
```

### Publication-Ready Figure
```r
```{r}
#| label: fig-results
#| fig-cap: "Main results showing relationship between X and Y"
#| fig-alt: "Scatterplot with regression line showing positive correlation"
#| fig-width: 8
#| fig-height: 6
#| fig-dpi: 300
#| echo: false
#| warning: false

ggplot(data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  theme_minimal()
```
```

### Interactive Output
```r
```{r}
#| label: interactive-plot
#| warning: false
#| message: false

library(plotly)
plot_ly(data, x = ~x, y = ~y, type = "scatter", mode = "markers")
```
```

## Troubleshooting

### Common Issues

**Code not showing:**
- Check `echo: true`
- Check `include: true`

**Output not appearing:**
- Check `eval: true`
- Check `output: true`
- Check for errors with `error: true`

**Figures not rendering:**
- Check `fig-width` and `fig-height` are positive
- Verify graphics device is available
- Check `fig-format` is supported

**Cache not working:**
- Ensure `label` is set and unique
- Check `cache: true` is set
- Delete `_cache/` folder to reset

**Cross-references not working:**
- Ensure label has correct prefix (`fig-`, `tbl-`, etc.)
- Check `label` doesn't contain spaces or special characters
- Verify reference syntax: `@fig-label`

## References

- [Quarto Computations](https://quarto.org/docs/computations/)
- [Knitr Options](https://yihui.org/knitr/options/)
- [Quarto Figures](https://quarto.org/docs/authoring/figures.html)
- [Quarto Tables](https://quarto.org/docs/authoring/tables.html)
