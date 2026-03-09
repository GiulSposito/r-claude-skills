# R for Data Science (R4DS) - Essential Knowledge Extraction

*Source: https://r4ds.had.co.nz/*
*Extraction Date: 2026-03-08*

## Overview

This document contains essential patterns and concepts from "R for Data Science" focusing on tidyverse workflows. These are foundational data science patterns in R.

---

## 1. Data Transformation with dplyr

### Core Philosophy
dplyr provides five verbs that solve 90% of data manipulation challenges. All verbs work similarly:
- First argument is a data frame
- Subsequent arguments describe what to do using column names (no quotes)
- Result is a new data frame

### The Five Core Verbs

**filter()** - Subset rows by conditions
```r
# Single condition
filter(flights, month == 1)

# Multiple conditions (AND)
filter(flights, month == 1, day == 1)

# OR conditions
filter(flights, month %in% c(11, 12))
filter(flights, month == 11 | month == 12)
```

**select()** - Choose columns
```r
# By name
select(flights, year, month, day)

# By range
select(flights, year:day)

# Helper functions
select(flights, starts_with("dep"))
select(flights, ends_with("time"))
select(flights, contains("arr"))
select(flights, matches("(.)\\1"))  # regex
```

**arrange()** - Reorder rows
```r
# Ascending order
arrange(flights, year, month, day)

# Descending order
arrange(flights, desc(dep_delay))
```

**mutate()** - Create/modify columns
```r
# Add new columns
mutate(flights,
  gain = dep_delay - arr_delay,
  speed = distance / air_time * 60
)

# Keep only new columns
transmute(flights,
  gain = dep_delay - arr_delay,
  hours = air_time / 60
)
```

**summarise()** - Collapse to summary statistics
```r
summarise(flights,
  delay = mean(dep_delay, na.rm = TRUE),
  count = n()
)
```

### group_by() - The Game Changer

Applies operations to groups independently:

```r
# Group and summarize
flights %>%
  group_by(year, month, day) %>%
  summarise(mean_delay = mean(dep_delay, na.rm = TRUE))

# Group and mutate (adds column with group-level stats)
flights %>%
  group_by(dest) %>%
  mutate(avg_dest_delay = mean(arr_delay, na.rm = TRUE))

# Don't forget to ungroup()
flights %>%
  group_by(dest) %>%
  summarise(delay = mean(arr_delay, na.rm = TRUE)) %>%
  ungroup()
```

### Useful Summary Functions

```r
# Central tendency
mean(x, na.rm = TRUE)
median(x, na.rm = TRUE)

# Spread
sd(x)
IQR(x)
mad(x)  # median absolute deviation

# Position
min(x)
max(x)
quantile(x, 0.25)

# Count
n()           # current group size
n_distinct(x) # unique values
sum(!is.na(x)) # non-missing values

# Logic
sum(x > 10)   # count TRUE values
mean(y == 0)  # proportion TRUE
```

---

## 2. Data Visualization with ggplot2

### Grammar of Graphics Template

Every ggplot2 visualization follows this structure:

```r
ggplot(data = <DATA>) +
  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))
```

Extended template:
```r
ggplot(data = <DATA>) +
  <GEOM_FUNCTION>(
    mapping = aes(<MAPPINGS>),
    stat = <STAT>,
    position = <POSITION>
  ) +
  <COORDINATE_FUNCTION> +
  <FACET_FUNCTION> +
  <SCALE_FUNCTION> +
  <THEME_FUNCTION>
```

### Aesthetic Mappings

Map variables to visual properties:

```r
# Position aesthetics
aes(x = displ, y = hwy)

# Visual aesthetics
aes(color = class)   # point/line color
aes(fill = class)    # fill color for shapes
aes(size = cyl)      # point size
aes(alpha = year)    # transparency
aes(shape = drv)     # point shape
aes(linetype = drv)  # line type
```

**Setting vs Mapping:**
```r
# Mapping (inside aes, varies by data)
geom_point(aes(color = class))

# Setting (outside aes, constant)
geom_point(color = "blue")
```

### Common Geoms

```r
# Scatterplots
geom_point()
geom_jitter(width = 0.2, height = 0.2)

# Lines and smooths
geom_line()
geom_smooth(method = "lm", se = FALSE)

# Bar charts
geom_bar()        # counts
geom_col()        # pre-computed values

# Distributions
geom_histogram(binwidth = 0.5)
geom_freqpoly(binwidth = 0.5)
geom_density()
geom_boxplot()

# Two variables
geom_bin2d()
geom_hex()
geom_count()
```

### Faceting (Small Multiples)

```r
# One variable
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_wrap(~ category, nrow = 2)

# Two variables
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_grid(rows ~ cols)

# Free scales
facet_wrap(~ category, scales = "free")
facet_grid(rows ~ cols, scales = "free_x")
```

### Position Adjustments

```r
# Avoid overplotting
geom_point(position = "jitter")
geom_jitter(width = 0.1, height = 0.1)

# Bar charts
geom_bar(position = "stack")    # default
geom_bar(position = "dodge")    # side-by-side
geom_bar(position = "fill")     # proportions
geom_bar(position = "identity") # overlap
```

### Coordinate Systems

```r
# Flip axes
coord_flip()

# Fixed aspect ratio
coord_fixed(ratio = 1)

# Polar coordinates
coord_polar()

# Zoom without clipping
coord_cartesian(xlim = c(5, 7), ylim = c(10, 30))
```

### Complete Example

```r
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class), size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  facet_wrap(~ year) +
  labs(
    title = "Fuel Efficiency by Engine Size",
    x = "Engine Displacement (L)",
    y = "Highway MPG",
    color = "Vehicle Class"
  ) +
  theme_minimal()
```

---

## 3. Data Tidying with tidyr

### Tidy Data Principles

Three interrelated rules:
1. Each variable has its own column
2. Each observation has its own row
3. Each value has its own cell

**Why tidy?**
- Consistent structure → easier to learn tools
- Vectorized operations work naturally with columns
- Works seamlessly with tidyverse packages

### pivot_longer() - Wide to Long

Use when column names are values, not variable names:

```r
# Basic usage
table4a %>%
  pivot_longer(
    cols = c(`1999`, `2000`),
    names_to = "year",
    values_to = "cases"
  )

# With column selection helpers
billboard %>%
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank",
    values_drop_na = TRUE
  )

# Parse column names
who %>%
  pivot_longer(
    cols = new_sp_m014:newrel_f65,
    names_to = c("diagnosis", "gender", "age"),
    names_pattern = "new_?(.*)_(.)(.*)",
    values_to = "count"
  )
```

### pivot_wider() - Long to Wide

Use when observations are scattered across multiple rows:

```r
# Basic usage
table2 %>%
  pivot_wider(
    names_from = type,
    values_from = count
  )

# Handle duplicates with aggregation
df %>%
  pivot_wider(
    names_from = key,
    values_from = value,
    values_fn = list(value = mean)
  )
```

### separate() - Split Columns

```r
# Default: split on non-alphanumeric
table3 %>%
  separate(rate, into = c("cases", "population"))

# Specify separator
table3 %>%
  separate(rate, into = c("cases", "population"), sep = "/")

# Convert types
table3 %>%
  separate(rate, into = c("cases", "population"), convert = TRUE)

# Split at position
table3 %>%
  separate(year, into = c("century", "year"), sep = 2)
```

### unite() - Combine Columns

```r
# Default: underscore separator
table5 %>%
  unite(new, century, year)

# Custom separator
table5 %>%
  unite(new, century, year, sep = "")
```

### Missing Values

```r
# Make implicit missing values explicit
stocks %>%
  complete(year, qtr)

# Fill missing values with previous value
treatment %>%
  fill(person)

# Replace NA with specific value
df %>%
  replace_na(list(x = 0, y = "unknown"))
```

---

## 4. Data Import with readr

### Reading Functions

```r
# CSV files
read_csv("file.csv")           # comma-delimited
read_csv2("file.csv")          # semicolon-delimited
read_tsv("file.tsv")           # tab-delimited
read_delim("file.txt", delim = "|")  # custom delimiter

# Fixed width
read_fwf("file.fwf", fwf_widths(c(3, 7, 2)))
read_table("file.txt")         # whitespace-separated

# Other formats
read_log("access.log")         # web logs
```

### Key Arguments

```r
read_csv("file.csv",
  skip = 2,                    # skip first n lines
  comment = "#",               # ignore comment lines
  col_names = FALSE,           # no header row
  col_names = c("x", "y", "z"), # provide names
  na = c("", "NA", ".", "999"), # missing values
  quote = '"',                 # quote character
  trim_ws = TRUE,              # trim whitespace
  n_max = 1000                 # read only n rows
)
```

### Column Types

```r
# Let readr guess (default)
read_csv("file.csv")

# Specify explicitly
read_csv("file.csv",
  col_types = cols(
    x = col_double(),
    y = col_character(),
    z = col_date(format = "%Y-%m-%d")
  )
)

# Column type shortcuts
read_csv("file.csv", col_types = "dcifDTt")
# d = double, c = character, i = integer, f = factor
# D = date, T = datetime, t = time
```

### Parsing Functions

For vectors already in R:

```r
# Numbers
parse_double("1.23")
parse_number("$1,234.56")      # extracts numbers
parse_integer("123")

# Strings (with encoding)
parse_character("text", locale = locale(encoding = "UTF-8"))

# Factors
parse_factor(c("a", "b", "a"), levels = c("a", "b", "c"))

# Dates and times
parse_date("2010-10-01")
parse_datetime("2010-10-01T2010")
parse_time("20:10:01")

# Custom formats
parse_date("01/02/15", format = "%m/%d/%y")
parse_datetime("November 9, 2020", format = "%B %d, %Y")
```

### Writing Files

```r
# Write CSV/TSV
write_csv(df, "output.csv")
write_tsv(df, "output.tsv")
write_excel_csv(df, "output.csv")  # UTF-8 with BOM for Excel

# Preserve R data types
write_rds(df, "output.rds")
df <- read_rds("output.rds")

# Cross-language binary (requires feather package)
library(feather)
write_feather(df, "output.feather")
df <- read_feather("output.feather")
```

---

## 5. Pipes with magrittr

### The Pipe Operator (%>%)

Passes left-hand side as first argument to right-hand function:

```r
# Without pipes (nested)
arrange(filter(select(df, a, b, c), b > 10), a)

# With pipes (linear)
df %>%
  select(a, b, c) %>%
  filter(b > 10) %>%
  arrange(a)
```

**Benefits:**
- Read left-to-right, top-to-bottom
- Focus on verbs (actions) not nouns (objects)
- Avoid intermediate variables
- Clear step-by-step transformations

### Pipe Shortcuts

```r
# Placeholder for non-first argument
df %>% lm(y ~ x, data = .)

# Multiple uses of placeholder
df %>% {
  cor(.$x, .$y)
}
```

### When NOT to Use Pipes

Avoid pipes when:
- More than 10 steps (use intermediate objects)
- Multiple inputs/outputs (not a single primary object)
- Complex dependency graphs (pipes are linear)

### Other magrittr Operators

```r
# Tee pipe (return left side, for side effects)
df %>%
  mutate(new_col = x * 2) %T>%
  plot() %>%
  summary()

# Exposition pipe (explode for vector functions)
df %$% cor(x, y)  # instead of: cor(df$x, df$y)

# Assignment pipe (discouraged - use explicit assignment)
df %<>% mutate(new_col = x * 2)
# Better: df <- df %>% mutate(new_col = x * 2)
```

---

## 6. Functions

### When to Write Functions

**DRY Principle**: Write a function when you've copied code more than twice (3+ copies).

**Benefits:**
- Update logic in one place
- Reduce copy-paste errors
- Clear, evocative names improve readability
- Easier to adapt to changing requirements

### Function Anatomy

```r
function_name <- function(arg1, arg2, arg3 = default_value) {
  # Function body
  result <- arg1 + arg2 + arg3
  result  # Implicit return (last value)
}
```

Three components:
1. **Name**: Descriptive verb (e.g., `rescale_values`, `remove_outliers`)
2. **Arguments**: Data first, details last with defaults
3. **Body**: Enclosed in `{}`

### Argument Design

```r
# Good: data arguments first, detail arguments with defaults
compute_summary <- function(x, trim = 0, na.rm = FALSE) {
  mean(x, trim = trim, na.rm = na.rm)
}

# Common short names
x, y, z    # vectors
df         # data frame
i, j       # indices
n          # length or rows
p          # columns
```

### Return Values

```r
# Transformation function (returns modified data)
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

# Side-effect function (returns input invisibly)
save_plot <- function(plot, file) {
  ggsave(file, plot)
  invisible(plot)
}

# Early returns for edge cases
complicated_function <- function(x, y, z) {
  if (length(x) == 0) return(numeric())

  # Main computation here
  result
}
```

### Input Validation

```r
weighted_mean <- function(x, w) {
  # Check preconditions
  stopifnot(
    is.numeric(x),
    is.numeric(w),
    length(x) == length(w)
  )

  sum(x * w) / sum(w)
}
```

### Function Styles

```r
# Strict transformation (checks input, pure function)
f <- function(x) {
  stopifnot(is.numeric(x))
  x * 2
}

# Flexible transformation (coerces input)
f <- function(x) {
  as.numeric(x) * 2
}

# Side-effect function (prints, plots, saves files)
plot_data <- function(df) {
  ggplot(df, aes(x, y)) + geom_point()
}
```

---

## 7. Functional Programming with purrr

### Why purrr Over Loops

**Advantages:**
- Less boilerplate code
- Type-stable outputs
- Clearer intent
- Easier to reason about

### Map Functions - Basic Pattern

All map functions take a vector/list and apply a function to each element:

```r
# map() returns list
map(1:3, ~ . * 2)           # list(2, 4, 6)

# Type-specific maps
map_dbl(1:3, ~ . * 2)       # numeric vector: 2, 4, 6
map_chr(1:3, as.character)  # character vector
map_lgl(1:3, ~ . > 2)       # logical vector
map_int(1:3, ~ .x)          # integer vector
```

### Function Specification

Three ways to specify `.f`:

```r
# 1. Named function
map_dbl(df, mean, na.rm = TRUE)

# 2. Anonymous function with formula
map_dbl(df, ~ mean(.x, na.rm = TRUE))

# 3. String/integer shortcuts
models <- list(model1, model2, model3)
map_dbl(models, "r.squared")    # extract component
map_chr(list_data, 1)           # extract first element
```

### Mapping Over Multiple Inputs

```r
# map2() - two inputs in parallel
map2_dbl(x, y, ~ .x + .y)
map2_chr(names, values, ~ paste(.x, .y, sep = ": "))

# pmap() - list/data frame of arguments
params <- list(
  mean = c(0, 5, 10),
  sd = c(1, 2, 3),
  n = c(10, 20, 30)
)
pmap(params, rnorm)
```

### Walk Functions - For Side Effects

Use when you want the action, not the return value:

```r
# walk() - one input
walk(files, print)
walk(plots, ggsave, path = "plots/")

# walk2() - two inputs
walk2(names, plots, ~ ggsave(filename = .x, plot = .y))

# pwalk() - multiple inputs
params <- list(filename = files, plot = plots, width = widths)
pwalk(params, ggsave)
```

### Error Handling

```r
# safely() - never errors, returns list(result, error)
safe_log <- safely(log)
safe_log(10)    # list(result = 2.3, error = NULL)
safe_log("a")   # list(result = NULL, error = <error>)

# Use with map
results <- map(inputs, safely(risky_function))
successes <- map(results, "result") %>% compact()
errors <- map(results, "error") %>% compact()

# possibly() - errors return default value
map_dbl(list(1, "a", 3), possibly(log, otherwise = NA_real_))

# quietly() - captures printed output, messages, warnings
quiet_summary <- quietly(summary)
```

### Reducing Lists

```r
# reduce() - apply function to pairs, left to right
reduce(1:4, `+`)           # ((1 + 2) + 3) + 4 = 10
reduce(list(df1, df2, df3), left_join)

# accumulate() - keep intermediate results
accumulate(1:4, `+`)       # 1, 3, 6, 10
```

### Predicates (Logical Functions)

```r
# keep/discard - filter with predicate
keep(df, is.numeric)
discard(df, is.numeric)

# some/every - test if any/all elements match
some(df, is.numeric)
every(df, is.numeric)

# detect/detect_index - find first match
detect(df, is.factor)
detect_index(df, is.factor)
```

---

## 8. R Markdown

### Document Structure

R Markdown combines three components:

```markdown
---
title: "Analysis Report"
author: "Your Name"
date: "2026-03-08"
output: html_document
---

Text with **markdown** formatting.

```{r}
# R code chunk
plot(cars)
```

More text with inline code: `r mean(cars$speed)` mph average.
```

### YAML Headers

```yaml
---
title: "Document Title"
author: "Author Name"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_float: true
    theme: united
    code_folding: hide
  pdf_document:
    toc: true
  word_document: default
---
```

### Code Chunk Options

```r
# Chunk header syntax
```{r chunk-name, option1=value1, option2=value2}

# Key options
eval = FALSE        # Don't execute code
echo = FALSE        # Don't show code (show output)
include = FALSE     # Run code but hide code & output
message = FALSE     # Suppress messages
warning = FALSE     # Suppress warnings
error = TRUE        # Continue on errors
cache = TRUE        # Cache results (rerun only if changed)

# Figure options
fig.width = 7       # Figure width in inches
fig.height = 5      # Figure height in inches
fig.cap = "Title"   # Figure caption
fig.align = "center" # center/left/right

# Output options
results = "hide"    # Hide printed output
results = "asis"    # Raw output (for HTML/LaTeX)
```

### Global Options

Set defaults for all chunks:

```r
```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.width = 8,
  fig.height = 6
)
```

### Inline Code

Embed R results in text:

```markdown
The dataset has `r nrow(mtcars)` cars with an average MPG of
`r round(mean(mtcars$mpg), 1)`.
```

### Output Formats

```yaml
# HTML document
output: html_document

# PDF (requires LaTeX)
output: pdf_document

# Word document
output: word_document

# Presentations
output: ioslides_presentation
output: slidy_presentation
output: beamer_presentation

# Dashboards (requires flexdashboard package)
output: flexdashboard::flex_dashboard

# Websites (multiple .Rmd files)
output: bookdown::html_document2
```

### Tables

```r
# Simple tables
knitr::kable(head(mtcars))

# Formatted tables (requires kableExtra)
library(kableExtra)
kable(mtcars) %>%
  kable_styling(bootstrap_options = c("striped", "hover"))
```

### Parameterized Reports

```yaml
---
title: "Report"
params:
  year: 2020
  region: "North"
  show_code: FALSE
---

```{r}
# Access parameters
data %>% filter(year == params$year, region == params$region)
```

Render with custom parameters:
```r
rmarkdown::render("report.Rmd", params = list(year = 2021, region = "South"))
```

---

## 9. Essential Patterns & Best Practices

### Tidyverse Workflow

```r
# 1. Import
library(tidyverse)
df <- read_csv("data.csv")

# 2. Tidy
df_tidy <- df %>%
  pivot_longer(cols = starts_with("q"), names_to = "question", values_to = "response") %>%
  separate(question, into = c("q", "number"), sep = "_") %>%
  mutate(number = as.integer(number))

# 3. Transform
df_summary <- df_tidy %>%
  group_by(question) %>%
  summarise(
    mean_response = mean(response, na.rm = TRUE),
    n = n()
  )

# 4. Visualize
ggplot(df_summary, aes(x = question, y = mean_response)) +
  geom_col() +
  coord_flip()

# 5. Model (example)
model <- lm(response ~ question + age, data = df_tidy)

# 6. Communicate (in R Markdown)
```

### Common Patterns

**Safe aggregation with missing values:**
```r
df %>%
  summarise(
    mean_val = mean(x, na.rm = TRUE),
    median_val = median(x, na.rm = TRUE),
    n_missing = sum(is.na(x)),
    n_valid = sum(!is.na(x))
  )
```

**Window functions for rankings:**
```r
df %>%
  group_by(category) %>%
  mutate(
    rank = min_rank(desc(value)),
    percent_rank = percent_rank(value),
    row_num = row_number()
  ) %>%
  filter(rank <= 5)
```

**Conditional mutations:**
```r
df %>%
  mutate(
    category = case_when(
      value < 10 ~ "low",
      value < 50 ~ "medium",
      value < 100 ~ "high",
      TRUE ~ "very high"
    ),
    flag = if_else(condition, "yes", "no")
  )
```

**Reshaping for analysis:**
```r
# Wide to long for modeling
df_long <- df %>%
  pivot_longer(cols = -id, names_to = "variable", values_to = "value")

# Long to wide for tables
df_wide <- df %>%
  pivot_wider(names_from = category, values_from = value)
```

**Multiple group summaries:**
```r
df %>%
  group_by(group1, group2) %>%
  summarise(
    n = n(),
    mean_val = mean(value),
    sd_val = sd(value),
    .groups = "drop"  # Ungroup after
  )
```

---

## 10. Quick Reference

### Loading Tidyverse

```r
# Load core tidyverse packages
library(tidyverse)

# Includes: ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats
```

### Package Highlights

- **ggplot2**: Data visualization using grammar of graphics
- **dplyr**: Data manipulation (filter, select, mutate, summarise, arrange)
- **tidyr**: Data tidying (pivot_longer, pivot_wider, separate, unite)
- **readr**: Fast data import (read_csv, read_tsv, write_csv)
- **purrr**: Functional programming (map, map2, pmap, walk)
- **tibble**: Modern data frames with better printing
- **stringr**: String manipulation (str_detect, str_replace, str_extract)
- **forcats**: Factor handling (fct_reorder, fct_lump, fct_recode)

### Getting Help

```r
# Function documentation
?function_name
help(function_name)

# Package vignettes
vignette(package = "dplyr")
browseVignettes("dplyr")

# Search help
??search_term

# Examples
example(function_name)
```

### Common Gotchas

1. **Missing values propagate**: `NA + 1 = NA`, use `na.rm = TRUE`
2. **Integer division**: Use `%/%` for integer division, `%%` for remainder
3. **Logical operators**: `&` vs `&&`, `|` vs `||` (vectorized vs scalar)
4. **String comparison**: Use `==` for exact match, `str_detect()` for patterns
5. **Factor ordering**: Factors have levels, control with `fct_relevel()` or `fct_reorder()`
6. **Group persistence**: Always `ungroup()` after grouped operations
7. **Column names with spaces**: Use backticks: `` `column name` ``

---

## Additional Resources

- **Book website**: https://r4ds.had.co.nz/
- **Tidyverse website**: https://www.tidyverse.org/
- **RStudio cheatsheets**: https://rstudio.com/resources/cheatsheets/
- **R4DS community**: https://www.rfordatasci.com/

---

*This extraction focuses on practical patterns and commonly-used functions from R4DS. For comprehensive coverage, refer to the full book.*
