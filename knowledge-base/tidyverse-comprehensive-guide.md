# Tidyverse Comprehensive Guide

## Overview

The tidyverse is an opinionated collection of R packages designed for data science. All packages share an underlying design philosophy, grammar, and data structures. The tidyverse package serves as a meta-package that loads nine core packages together while installing additional specialized packages.

**Installation:** `install.packages("tidyverse")`
**Loading:** `library(tidyverse)`

When loaded, tidyverse activates: ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats, and lubridate.

---

## Core Philosophy & Principles

### Tidy Data Principles

Tidy data follows three fundamental rules (representing Codd's 3rd normal form in statistical language):

1. **Each variable is a column; each column is a variable**
2. **Each observation is a row; each row is an observation**
3. **Each value is a cell; each cell is a single value**

This standardized structure:
- Reduces time spent on data preparation
- Enables consistent tool development
- Provides predictable data access patterns
- Facilitates efficient analysis workflows

### Design Philosophy

All tidyverse packages share:
- **Consistent function naming** - First argument is always data
- **Pipe-friendly design** - Functions chain naturally with `|>` or `%>%`
- **Type stability** - Functions return predictable output types
- **Tidy evaluation** - Direct variable references without quotes
- **Human-centered API** - Intuitive, readable code

---

## 1. dplyr: Data Manipulation

### Purpose
Provides a grammar for data manipulation with verbs addressing common data transformation challenges.

### Core Single-Table Verbs

#### Row Operations
- **`filter()`** - Keep rows matching conditions
- **`arrange()`** - Order rows by column values
- **`distinct()`** - Keep unique rows
- **`slice()`** - Select rows by position
  - `slice_head()`, `slice_tail()` - First/last n rows
  - `slice_sample()` - Random sample
  - `slice_min()`, `slice_max()` - Rows with extreme values

#### Column Operations
- **`select()`** - Keep or drop columns by name/type
- **`mutate()`** - Create, modify, or delete columns
- **`rename()`** - Rename columns
- **`relocate()`** - Reorder columns

#### Grouping & Summarizing
- **`group_by()`** - Group by one or more variables
- **`summarise()`** / **`summarize()`** - Reduce groups to single rows
- **`count()`** - Count observations per group
- **`reframe()`** - Like summarise but allows multiple rows per group

### Two-Table Verbs

#### Mutating Joins (Add variables)
- **`left_join()`** - Keep all rows from x (most common)
- **`right_join()`** - Keep all rows from y
- **`inner_join()`** - Keep only matching rows
- **`full_join()`** - Keep all rows from both tables

#### Filtering Joins (Filter observations)
- **`semi_join()`** - Keep rows with matches in y
- **`anti_join()`** - Remove rows with matches in y

#### Set Operations
- **`intersect()`** - Rows in both tables
- **`union()`** - Unique rows from both tables
- **`setdiff()`** - Rows in x but not y

### Essential Vector Functions

- **`case_when()`** - Vectorized if-else statements
- **`coalesce()`** - Find first non-missing element
- **`between()`** - Check if values fall in range
- **`lag()` / `lead()`** - Access previous/next values
- **`na_if()`** - Replace specific values with NA
- **`if_else()`** - Vectorized conditional

### Column-wise Operations

#### across()
Apply functions to multiple columns simultaneously:

```r
# Single function
df |> summarise(across(where(is.numeric), mean))

# Multiple functions
df |> summarise(across(
  where(is.numeric),
  list(mean = mean, sd = sd),
  .names = "{.fn}_{.col}"
))
```

**Selection helpers:**
- `everything()` - All columns
- `where(is.numeric)` - By type
- `starts_with()`, `ends_with()`, `contains()` - By name pattern
- `matches()` - Regex pattern
- `all_of()`, `any_of()` - Character vector of names

#### Companion Functions
- **`if_any()`** - Filter where any selected column meets condition
- **`if_all()`** - Filter where all selected columns meet condition
- **`pick()`** - Select columns without applying functions

### Row-wise Operations

**`rowwise()`** - Create special grouping where each row is its own group

Common uses:
- Row-wise aggregates across columns
- Repeated function calls with varying parameters
- List-column manipulation

**`c_across()`** - Select columns for row-wise operations using tidy selection:

```r
df |>
  rowwise() |>
  mutate(total = sum(c_across(col1:col10)))
```

**`nest_by()`** - Group and nest data, automatically row-wise:

```r
# Fit model per group
models <- data |>
  nest_by(species) |>
  mutate(model = list(lm(y ~ x, data = data)))
```

### Window Functions

Functions that return n values from n inputs:

#### Ranking Functions
- `row_number()` - Sequential numbering (1, 2, 3, 4)
- `min_rank()` - Standard ranking with gaps (1, 2, 2, 4)
- `dense_rank()` - Ranking without gaps (1, 2, 2, 3)
- `percent_rank()` - Percentage rank [0, 1]
- `cume_dist()` - Cumulative distribution
- `ntile()` - Divide into n bins

#### Offset Functions
- `lag()` - Previous values
- `lead()` - Next values

#### Cumulative Functions
- `cumsum()`, `cumprod()` - Cumulative sum/product
- `cummin()`, `cummax()` - Running min/max
- `cumany()`, `cumall()`, `cummean()` - dplyr additions

### Programming with dplyr

#### Data Masking & Tidy Evaluation

Two variable types:
- **env-variables** - Created with `<-`, exist in environments
- **data-variables** - Columns in data frames

#### The Embrace Operator {{ }}

Use doubled braces for indirect variable references:

```r
my_summary <- function(df, var) {
  df |> summarise(mean = mean({{ var }}))
}

# Dynamic naming
my_mutate <- function(df, var) {
  df |> mutate("mean_{{ var }}" := mean({{ var }}))
}
```

#### Pronouns

- **`.data[[var]]`** - Indirect access to data variables (use in loops)
- **`.env$var`** - Explicit access to environment variables

#### Multiple Expressions

Pass arbitrary expressions with `...`:

```r
my_group <- function(df, ...) {
  df |> group_by(...)
}
```

### Common dplyr Workflows

```r
# Basic transformation pipeline
data |>
  filter(condition) |>
  select(col1, col2, col3) |>
  mutate(new_col = calculation) |>
  arrange(col1)

# Grouped summary
data |>
  group_by(category) |>
  summarise(
    n = n(),
    mean = mean(value),
    sd = sd(value)
  )

# Complex multi-step transformation
data |>
  filter(!is.na(important_var)) |>
  mutate(processed = transform(raw)) |>
  group_by(group_var) |>
  mutate(group_mean = mean(processed)) |>
  ungroup() |>
  mutate(deviation = processed - group_mean)
```

---

## 2. tidyr: Data Tidying

### Purpose
Functions for achieving tidy data structure where variables align with columns and observations with rows.

### Pivoting (Reshaping Data)

#### pivot_longer()
**Increases rows, decreases columns** - Convert wide format to long format

```r
# Basic usage
data |>
  pivot_longer(
    cols = col1:col10,           # Columns to pivot
    names_to = "variable",        # New column for old names
    values_to = "value"           # New column for values
  )

# Multiple variables in column names
who |>
  pivot_longer(
    cols = new_sp_m014:newrel_f65,
    names_to = c("diagnosis", "gender", "age"),
    names_pattern = "new_?(.*)_(.)(.*)",
    values_to = "count"
  )

# .value sentinel for multiple value columns
household |>
  pivot_longer(
    cols = !family,
    names_to = c(".value", "child"),
    names_sep = "_"
  )
```

#### pivot_wider()
**Increases columns, decreases rows** - Convert long format to wide format

```r
# Basic usage
data |>
  pivot_wider(
    names_from = category,        # Column with new names
    values_from = measurement,    # Column with values
    values_fill = 0               # Fill missing combinations
  )

# Handle multiple values per cell
data |>
  pivot_wider(
    names_from = type,
    values_from = value,
    values_fn = mean              # Aggregate function
  )
```

### Rectangling (Nested Data)

Transform deeply nested lists (JSON/XML) into tidy tibbles.

#### unnest Functions
- **`unnest_longer()`** - Turn list elements into rows
- **`unnest_wider()`** - Turn list elements into columns
- **`unnest()`** - Unnest data frame list-columns into rows and columns

```r
# JSON workflow
json_data <- jsonlite::read_json(path, simplifyVector = FALSE)

tibble(data = json_data) |>
  unnest_wider(data) |>          # Spread top-level into columns
  unnest_longer(nested_array)    # Expand arrays into rows
```

#### hoist()
Selectively extract specific components from nested lists:

```r
df |>
  hoist(nested_col,
    id = "id",
    name = c("user", "name"),    # Nested path
    score = c("metrics", "score", 1)  # Deep nesting with index
  )
```

### Splitting & Combining Columns

#### Splitting Strings

**Into columns:**
- **`separate_wider_delim()`** - Split by delimiter
- **`separate_wider_position()`** - Split by character positions
- **`separate_wider_regex()`** - Split by regex pattern

**Into rows:**
- **`separate_longer_delim()`** - Split by delimiter, create rows
- **`separate_longer_position()`** - Split by position, create rows

```r
# Split column by delimiter
df |>
  separate_wider_delim(
    col,
    delim = "-",
    names = c("part1", "part2")
  )

# Split into rows
df |>
  separate_longer_delim(tags, delim = ", ")
```

#### Combining Columns

**`unite()`** - Combine multiple columns into one:

```r
df |> unite(combined, col1, col2, sep = "_")
```

### Nesting & Packing

#### Nesting
- **`nest()`** - Convert grouped rows into list-column of data frames
- **`unnest()`** - Expand nested data frames

```r
# Create nested structure
nested <- data |>
  nest(data = c(col1, col2, col3))

# Work with nested data
nested |>
  mutate(model = map(data, ~ lm(y ~ x, data = .x)))
```

#### Packing
- **`pack()`** - Bundle columns into data frame column
- **`unpack()`** - Spread data frame column into columns

#### Chopping
- **`chop()`** - Convert rows into list-column
- **`unchop()`** - Expand list-column into rows

### Missing Values

- **`complete()`** - Add missing combinations of variables
- **`expand()`** - Generate all combinations of variables
- **`fill()`** - Fill missing values with previous/next value
- **`drop_na()`** - Remove rows with missing values
- **`replace_na()`** - Replace NAs with specific value

```r
# Add all missing combinations
df |> complete(category, year)

# Fill down
df |> fill(group, .direction = "down")

# Expand grid of all combinations
df |> expand(category, year)
```

---

## 3. ggplot2: Data Visualization

### Purpose
Declarative graphics system based on The Grammar of Graphics. Users specify data, aesthetic mappings, and geometric objects; ggplot2 handles implementation.

### Grammar of Graphics Components

1. **Data** - The dataset
2. **Aesthetics** - Mapping variables to visual properties
3. **Geoms** - Geometric objects representing data
4. **Stats** - Statistical transformations
5. **Scales** - Control aesthetic mappings
6. **Coordinate systems** - Map position to plot plane
7. **Facets** - Subplots for data subsets
8. **Themes** - Control non-data visual elements

### Building Plots Layer by Layer

```r
ggplot(data, aes(x = var1, y = var2)) +  # Base + aesthetics
  geom_point() +                          # Geometric layer
  scale_y_log10() +                       # Scale transformation
  facet_wrap(~category) +                 # Faceting
  theme_minimal()                         # Theme
```

### Essential Geoms

#### Univariate
- **`geom_histogram()`** - Histograms
- **`geom_density()`** - Density plots
- **`geom_freqpoly()`** - Frequency polygons
- **`geom_bar()`** - Bar charts (counts)
- **`geom_boxplot()`** - Box and whisker plots
- **`geom_violin()`** - Violin plots

#### Bivariate
- **`geom_point()`** - Scatter plots
- **`geom_line()`** - Line graphs
- **`geom_smooth()`** - Smoothed conditional means
- **`geom_col()`** - Bar charts (values)

#### Spatial
- **`geom_hex()`** - Hexagonal heatmaps
- **`geom_bin2d()`** - 2D binning
- **`geom_density2d()`** - 2D density contours

#### Text & Annotation
- **`geom_text()`** - Text labels
- **`geom_label()`** - Text with background
- **`annotate()`** - Add single annotations

#### Statistics
- **`geom_smooth()`** - Fitted models/smoothers
- **`geom_quantile()`** - Quantile regression
- **`stat_summary()`** - Custom summaries

### Aesthetic Mappings

**Common aesthetics:**
- `x`, `y` - Position
- `color` / `colour` - Color of points/lines
- `fill` - Fill color of areas
- `size` - Size of points/text
- `alpha` - Transparency
- `shape` - Point shape
- `linetype` - Line pattern

**Fixed vs Mapped:**
```r
# Mapped (inside aes)
ggplot(data, aes(x = var1, y = var2, color = category))

# Fixed (outside aes)
geom_point(color = "blue", size = 3)
```

### Scales

Control how data values map to visual properties:

#### Position Scales
- **`scale_x_continuous()` / `scale_y_continuous()`**
- **`scale_x_discrete()` / `scale_y_discrete()`**
- **`scale_x_log10()` / `scale_y_log10()`**
- **`scale_x_reverse()` / `scale_y_reverse()`**

#### Color Scales
- **`scale_color_manual()`** - Custom colors
- **`scale_color_brewer()`** - ColorBrewer palettes
- **`scale_color_gradient()` / `scale_color_gradient2()`** - Continuous gradients
- **`scale_color_viridis_c()` / `scale_color_viridis_d()`** - Viridis palettes

#### Other Scales
- **`scale_size()` / `scale_size_area()`**
- **`scale_alpha()`**
- **`scale_shape_manual()`**

#### Scale Shortcuts
- **`labs()`** - Modify labels
- **`lims()` / `xlim()` / `ylim()`** - Set limits

### Faceting

Create small multiples:

#### facet_wrap()
Wrap 1D ribbon of panels into 2D:
```r
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_wrap(~ category, nrow = 2)
```

#### facet_grid()
Create grid based on two variables:
```r
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_grid(rows ~ cols)
```

### Coordinate Systems

- **`coord_cartesian()`** - Default Cartesian coordinates
- **`coord_fixed()`** - Fixed aspect ratio
- **`coord_flip()`** - Flip x and y axes
- **`coord_polar()`** - Polar coordinates
- **`coord_trans()`** - Transform coordinates

### Themes

#### Complete Themes
- **`theme_gray()`** - Default
- **`theme_bw()`** - Black and white
- **`theme_minimal()`** - Minimal elements
- **`theme_classic()`** - Classic look
- **`theme_void()`** - Empty theme

#### Theme Elements
Customize specific components with **`theme()`**:

```r
theme(
  plot.title = element_text(size = 14, face = "bold"),
  axis.text = element_text(size = 10),
  legend.position = "bottom",
  panel.grid.major = element_line(color = "gray90")
)
```

**Element functions:**
- `element_text()` - Text elements
- `element_line()` - Lines
- `element_rect()` - Rectangles
- `element_blank()` - Remove element

### Position Adjustments

Handle overlapping geoms:
- **`position_identity()`** - No adjustment (default)
- **`position_dodge()`** - Side by side
- **`position_stack()`** - Stack vertically
- **`position_fill()`** - Stack and normalize to 100%
- **`position_jitter()`** - Add random noise

### Common ggplot2 Patterns

```r
# Basic scatter plot with smooth
ggplot(data, aes(x = var1, y = var2)) +
  geom_point(aes(color = category), alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "My Plot",
    x = "X Variable",
    y = "Y Variable"
  ) +
  theme_minimal()

# Faceted time series
ggplot(data, aes(x = date, y = value)) +
  geom_line(aes(color = metric)) +
  facet_wrap(~region, scales = "free_y") +
  theme_bw()

# Grouped bar chart
ggplot(data, aes(x = category, y = count, fill = group)) +
  geom_col(position = "dodge") +
  scale_fill_viridis_d() +
  coord_flip()
```

---

## 4. readr: Data Import

### Purpose
Fast and friendly reading of rectangular data (CSV, TSV, fixed-width files) with informative error reporting and automatic type detection.

### Reading Functions

- **`read_csv()`** - Comma-separated values
- **`read_csv2()`** - Semicolon-separated (European)
- **`read_tsv()`** - Tab-separated values
- **`read_delim()`** - Custom delimiter
- **`read_fwf()`** - Fixed-width files
- **`read_table()`** - Whitespace-separated
- **`read_log()`** - Web log files

### Writing Functions

- **`write_csv()` / `write_tsv()`** - Write delimited files
- **`write_delim()`** - Custom delimiter
- **`write_excel_csv()`** - CSV for Excel
- **`format_csv()` / `format_tsv()`** - Format as string

### Column Specification

#### Automatic Type Detection
readr guesses column types from first 1000 rows:
```r
spec(data)  # View guessed specification
```

#### Manual Column Types
- **`col_logical()`** - TRUE/FALSE
- **`col_integer()`** - Integers
- **`col_double()`** - Doubles
- **`col_character()`** - Strings
- **`col_factor()`** - Factors with levels
- **`col_date()` / `col_datetime()` / `col_time()`** - Date/time
- **`col_number()`** - Flexible numeric parsing
- **`col_skip()`** - Don't import
- **`col_guess()`** - Auto-detect

```r
read_csv(file,
  col_types = cols(
    id = col_integer(),
    name = col_character(),
    date = col_date(format = "%Y-%m-%d"),
    amount = col_double()
  )
)
```

### Parsing Functions

Direct parsing of character vectors:
- **`parse_logical()` / `parse_integer()` / `parse_double()`**
- **`parse_character()`** - Encoding handling
- **`parse_datetime()` / `parse_date()` / `parse_time()`**
- **`parse_factor()`** - Factor with levels
- **`parse_number()`** - Flexible numeric extraction
- **`parse_guess()`** - Auto-detect type

### Locale Settings

Handle regional differences:
```r
read_csv(file, locale = locale(
  decimal_mark = ",",
  grouping_mark = ".",
  date_format = "%d/%m/%Y",
  encoding = "UTF-8"
))
```

### Common Patterns

```r
# Basic import with type specification
data <- read_csv("file.csv",
  col_types = cols(
    .default = col_character(),
    year = col_integer(),
    value = col_double()
  )
)

# Handle missing values
data <- read_csv("file.csv",
  na = c("", "NA", "NULL", "missing")
)

# Skip rows and select columns
data <- read_csv("file.csv",
  skip = 2,
  n_max = 1000,
  col_select = c(id, name, value)
)
```

---

## 5. purrr: Functional Programming

### Purpose
Enhances functional programming toolkit with complete and consistent tools for working with functions and vectors. Replaces loops with type-stable functional approaches.

### Map Functions (Core)

Apply function to each element, return various types:

- **`map()`** - Returns list
- **`map_lgl()`** - Returns logical vector
- **`map_int()`** - Returns integer vector
- **`map_dbl()`** - Returns double vector
- **`map_chr()`** - Returns character vector
- **`map_vec()`** - Returns vector of any type
- **`walk()`** - Called for side effects, returns input invisibly

```r
# Basic map
map(1:3, ~ .x * 2)  # Returns list(2, 4, 6)

# Type-specific
map_dbl(1:3, ~ .x * 2)  # Returns c(2, 4, 6)

# Extract elements
map_dbl(models, "r.squared")  # Extract named component
map_dbl(nested_list, 1)       # Extract by position
```

### Map Variants

#### Multiple Inputs
- **`map2()`** - Two parallel inputs
- **`pmap()`** - Any number of parallel inputs

```r
# Two inputs
map2_dbl(x, y, ~ .x + .y)

# Multiple inputs
pmap_dbl(list(x, y, z), ~ ..1 + ..2 + ..3)
```

#### Conditional Mapping
- **`map_if()`** - Apply function where predicate is TRUE
- **`map_at()`** - Apply function at specific positions

```r
# Apply to numeric columns only
map_if(df, is.numeric, ~ .x * 2)

# Apply to specific positions
map_at(list, c(1, 3), ~ .x + 10)
```

#### Side Effects
- **`walk()` / `walk2()` / `pwalk()`** - For functions called for side effects

```r
# Print each element
walk(files, ~ cat("Processing:", .x, "\n"))

# Save plots
walk2(plots, filenames, ggsave)
```

### Modify Functions

Apply function while preserving input type:

- **`modify()`** - Returns same type as input
- **`modify_if()` / `modify_at()`** - Conditional modification
- **`modify2()`** - Two parallel inputs
- **`imodify()`** - Include index/name

```r
# Modify all elements
modify(list, ~ .x * 2)

# Modify specific elements
modify_if(df, is.numeric, ~ round(.x, 2))
```

### Predicate Functionals

Test elements against conditions:

- **`keep()` / `discard()`** - Filter by predicate
- **`detect()` / `detect_index()`** - Find first match
- **`every()` / `some()` / `none()`** - Test all/any/none
- **`head_while()` / `tail_while()`** - Take while condition holds

```r
# Keep matching elements
keep(list, is.numeric)

# Find first match
detect(list, ~ .x > 10)

# Test conditions
every(list, is.numeric)  # All numeric?
some(list, is.na)        # Any NA?
```

### List Manipulation

- **`pluck()`** - Extract or set deep elements
- **`list_flatten()`** - Flatten one level
- **`list_c()` / `list_rbind()` / `list_cbind()`** - Combine elements
- **`list_transpose()`** - Transpose list structure

```r
# Deep extraction
pluck(nested, "data", "results", 1, "value")

# Flatten
list_flatten(nested_list)

# Combine
list_rbind(list_of_dfs)
```

### Function Manipulation (Adverbs)

Modify function behavior:

- **`safely()`** - Capture errors, return list(result, error)
- **`possibly()`** - Replace errors with default value
- **`quietly()`** - Capture output, messages, warnings
- **`partial()`** - Pre-fill function arguments
- **`compose()`** - Chain functions together

```r
# Handle errors gracefully
safe_log <- safely(log)
safe_log("invalid")  # Returns list(result = NULL, error = <error>)

# Provide defaults
possibly_log <- possibly(log, otherwise = NA)
possibly_log("invalid")  # Returns NA

# Partial application
add_10 <- partial(`+`, 10)
add_10(5)  # Returns 15
```

### Reduce Functions

Iteratively combine elements:

- **`reduce()`** - Left to right reduction
- **`reduce2()`** - With additional input
- **`accumulate()`** - Return intermediate results

```r
# Sum all elements
reduce(1:4, `+`)  # 1 + 2 + 3 + 4 = 10

# Accumulate intermediate results
accumulate(1:4, `+`)  # c(1, 3, 6, 10)
```

### Common purrr Patterns

```r
# Split-apply-combine
data |>
  split(data$category) |>
  map(~ lm(y ~ x, data = .x)) |>
  map_dbl("r.squared")

# Process multiple files
files <- c("data1.csv", "data2.csv", "data3.csv")
map(files, read_csv) |>
  list_rbind()

# Safely process with error handling
results <- map(inputs, safely(process_function))
successes <- keep(results, ~ is.null(.x$error))
failures <- discard(results, ~ is.null(.x$error))

# Nested iteration
expand.grid(x = 1:3, y = 1:3) |>
  pmap_dbl(~ .x * .y)
```

---

## 6. stringr: String Manipulation

### Purpose
Consistent, simple string manipulation built on ICU C library via stringi. All functions have consistent naming and argument order (string first).

### Pattern Matching

#### Detection & Counting
- **`str_detect()`** - Does string contain pattern?
- **`str_count()`** - Count pattern occurrences
- **`str_starts()` / `str_ends()`** - Starts/ends with pattern?

#### Extraction & Location
- **`str_extract()` / `str_extract_all()`** - Extract matches
- **`str_match()` / `str_match_all()`** - Extract with capture groups
- **`str_locate()` / `str_locate_all()`** - Find match positions

#### Vector Operations
- **`str_subset()`** - Keep strings matching pattern
- **`str_which()`** - Find indices of matching strings

```r
# Detection
str_detect(strings, "pattern")

# Extraction with groups
str_match(strings, "(\\d+)-(\\w+)")

# Get matching strings
str_subset(strings, "^A")
```

### String Manipulation

#### Replacement
- **`str_replace()` / `str_replace_all()`** - Replace matches
- **`str_remove()` / `str_remove_all()`** - Remove matches

#### Splitting
- **`str_split()`** - Split string by pattern
- **`str_split_fixed()`** - Split into fixed number of pieces
- **`str_split_n()`** - Split and extract nth piece

```r
# Replace
str_replace_all(strings, "old", "new")

# Remove
str_remove_all(strings, "\\d+")

# Split
str_split(strings, ",")
```

### String Properties

- **`str_length()`** - Number of characters
- **`str_width()`** - Display width
- **`str_sub()`** - Extract substring by position
- **`str_trunc()`** - Truncate to maximum width

```r
# Substring
str_sub(strings, 1, 5)  # Characters 1-5
str_sub(strings, -5, -1)  # Last 5 characters
```

### Case Conversion

- **`str_to_upper()` / `str_to_lower()`**
- **`str_to_title()`** - Title case
- **`str_to_sentence()`** - Sentence case

### Whitespace

- **`str_trim()`** - Remove leading/trailing whitespace
- **`str_squish()`** - Remove leading/trailing and normalize internal
- **`str_pad()`** - Add padding to minimum width

```r
str_trim("  text  ")       # "text"
str_squish("  too   much  ")  # "too much"
str_pad("text", 10, "right")  # "text      "
```

### Combining Strings

- **`str_c()`** - Concatenate strings
- **`str_flatten()`** - Collapse vector to single string
- **`str_glue()`** - Interpolate strings (uses glue package)

```r
# Concatenate
str_c("Hello", "world", sep = " ")

# Collapse
str_flatten(letters[1:5], collapse = ", ")

# Interpolation
name <- "Alice"
str_glue("Hello {name}!")
```

### Regular Expression Patterns

#### Basic Patterns
- `.` - Any character
- `^` - Start of string
- `$` - End of string
- `\b` - Word boundary

#### Character Classes
- `[abc]` - Any of a, b, or c
- `[^abc]` - Not a, b, or c
- `[a-z]` - Range
- `\d` - Digits
- `\w` - Word characters
- `\s` - Whitespace

#### Quantifiers
- `?` - 0 or 1
- `*` - 0 or more
- `+` - 1 or more
- `{n}` - Exactly n
- `{n,m}` - Between n and m

#### Groups
- `()` - Capture group
- `(?:...)` - Non-capturing group
- `\1`, `\2` - Backreferences

### Pattern Helpers

- **`fixed()`** - Match exact bytes (fast)
- **`regex()`** - Full regex with options
- **`coll()`** - Locale-aware collation
- **`boundary()`** - Match boundaries

```r
# Case-insensitive matching
str_detect(strings, regex("pattern", ignore_case = TRUE))

# Fixed matching (faster)
str_detect(strings, fixed("exact.match"))
```

### Common stringr Patterns

```r
# Clean text
text |>
  str_to_lower() |>
  str_squish() |>
  str_remove_all("[^a-z0-9 ]")

# Extract email domains
emails |>
  str_extract("(?<=@)[^.]+\\.\\w+")

# Parse structured text
str_match(codes, "([A-Z]+)-(\\d+)") |>
  as.data.frame() |>
  set_names(c("full", "prefix", "number"))
```

---

## 7. forcats: Factor Handling

### Purpose
Tools for handling categorical variables (factors) in R, solving common problems with level ordering and value modification.

### Reordering Levels

#### By Frequency/Appearance
- **`fct_infreq()`** - Order by frequency
- **`fct_inorder()`** - Order by first appearance
- **`fct_inseq()`** - Order by numeric sequence

#### By Another Variable
- **`fct_reorder()`** - Order by summary of another variable
- **`fct_reorder2()`** - Order by two variables (useful for legends)

#### Manual Reordering
- **`fct_relevel()`** - Move specific levels to front
- **`fct_rev()`** - Reverse level order
- **`fct_shuffle()`** - Random order

```r
# Order by frequency
fct_infreq(species)

# Order by median of another variable
fct_reorder(species, height, .fun = median)

# Move specific levels first
fct_relevel(size, "small", "medium", "large")
```

### Modifying Level Values

#### Renaming
- **`fct_recode()`** - Manually rename levels
- **`fct_relabel()`** - Apply function to rename
- **`fct_anon()`** - Anonymize with random labels

#### Collapsing
- **`fct_collapse()`** - Group multiple levels
- **`fct_lump()`** - Collapse infrequent levels to "Other"
  - `fct_lump_n()` - Keep n most frequent
  - `fct_lump_prop()` - Keep levels above proportion
  - `fct_lump_min()` - Keep levels with minimum count

```r
# Rename levels
fct_recode(fruit,
  citrus = "orange",
  citrus = "lemon",
  berry = "strawberry"
)

# Collapse infrequent
fct_lump(species, n = 5, other_level = "Other")
```

### Adding/Removing Levels

- **`fct_expand()`** - Add new levels
- **`fct_drop()`** - Remove unused levels
- **`fct_na_value_to_level()`** - Convert NAs to explicit level
- **`fct_na_level_to_value()`** - Convert level to NAs

### Combining Factors

- **`fct_c()`** - Concatenate factors
- **`fct_cross()`** - Create factor from level combinations

```r
# Combine multiple factors
fct_c(factor1, factor2, factor3)

# Cross-product
fct_cross(color, size)
```

### Common forcats Patterns

```r
# Improve plot ordering
data |>
  mutate(category = fct_reorder(category, value)) |>
  ggplot(aes(value, category)) +
  geom_col()

# Simplify categories for analysis
data |>
  mutate(species = fct_lump_n(species, 5))

# Clean up factor levels
data |>
  mutate(
    status = fct_recode(status,
      Active = "active",
      Active = "ACTIVE",
      Inactive = "inactive"
    )
  )
```

---

## 8. tibble: Modern Data Frames

### Purpose
Modern reimagining of data.frame, keeping effective features and removing problematic ones. Stricter behavior forces early problem confrontation, leading to cleaner code.

### Key Differences from data.frame

- Never alters variable names or types
- No row names functionality
- Only recycles length-1 inputs
- No partial matching on column access
- Enhanced printing for complex/large data

### Creation Functions

#### as_tibble()
Convert existing objects to tibbles:
```r
# From data.frame
as_tibble(df)

# From matrix
as_tibble(matrix, .name_repair = "unique")

# From named list
as_tibble(list(x = 1:3, y = letters[1:3]))
```

#### tibble()
Construct tibbles from vectors:
```r
tibble(
  x = 1:5,
  y = x * 2,          # Can reference previous columns
  z = letters[1:5]
)
```

#### tribble()
Row-by-row construction (readable for small data):
```r
tribble(
  ~x, ~y, ~z,
  1,  "a", TRUE,
  2,  "b", FALSE,
  3,  "c", TRUE
)
```

### Subsetting Behavior

Tibbles are stricter:
```r
# Single column always returns tibble
df[, "x"]     # Returns tibble, not vector

# Use $ or [[ for vectors
df$x          # Returns vector
df[["x"]]     # Returns vector

# No partial matching
df$na         # Error if no "na" column (unlike data.frame)
```

### Printing

Enhanced print method:
- Shows first 10 rows by default
- Displays column types
- Fits to screen width
- Better handling of list-columns

```r
# Control printing
print(df, n = 20, width = Inf)

# See all columns
glimpse(df)  # Transposed view
```

### Common tibble Patterns

```r
# Build iteratively
tibble(
  x = runif(100),
  y = rnorm(100),
  category = sample(letters[1:3], 100, replace = TRUE),
  result = case_when(
    x > 0.5 & y > 0 ~ "high",
    x < 0.5 & y < 0 ~ "low",
    TRUE ~ "medium"
  )
)

# Convert with name repair
messy_df |>
  as_tibble(.name_repair = "universal")
```

---

## 9. lubridate: Date-Time Manipulation

### Purpose
Makes working with dates and times in R easier by providing intuitive parsing, extraction, and arithmetic functions.

### Parsing Date-Times

#### Parsing Functions
Function names indicate date component order:

- **`ymd()` / `ydm()`** - Year, month, day variations
- **`mdy()` / `myd()`** - Month, day, year variations
- **`dmy()` / `dym()`** - Day, month, year variations
- **`ymd_hms()` / `ymd_hm()` / `ymd_h()`** - With time components

```r
# Flexible parsing
ymd("2024-03-15")
ymd("20240315")
mdy("03/15/2024")
dmy("15-03-2024")

# With times
ymd_hms("2024-03-15 14:30:00")
mdy_hm("03/15/2024 14:30")
```

### Time Spans

Three distinct classes:

#### Durations
Exact time spans (in seconds):
- **`dseconds()`, `dminutes()`, `dhours()`, `ddays()`, `dweeks()`, `dyears()`**

```r
now() + ddays(7)
dweeks(2) / ddays(1)  # 14 days
```

#### Periods
"Clock time" respecting human calendars:
- **`seconds()`, `minutes()`, `hours()`, `days()`, `weeks()`, `months()`, `years()`**

```r
# Respects daylight saving time
date + months(1)

# Compound periods
hours(2) + minutes(30)
```

#### Intervals
Time span between two specific points:
- **`interval()`** - Create interval
- **`%--%`** - Interval operator

```r
# Create interval
span <- interval(start_date, end_date)

# Check if date falls in interval
date %within% span

# Duration of interval
as.duration(span)
```

### Extraction & Manipulation

#### Get Components
- **`year()`, `month()`, `day()`**
- **`hour()`, `minute()`, `second()`**
- **`week()`, `quarter()`, `semester()`**
- **`wday()`, `yday()`, `mday()`** - Day of week/year/month
- **`date()`, `date<-()`** - Date component only

```r
# Extract
year(now())
month(now(), label = TRUE)  # "Mar"
wday(now(), label = TRUE)   # "Friday"

# Modify
year(date) <- 2025
month(date) <- 6
```

### Arithmetic

```r
# Add/subtract periods
today() + months(3)
now() - hours(2)

# Differences
difftime(end_date, start_date, units = "days")
interval(start_date, end_date) / days(1)

# Sequences
seq(from = today(), to = today() + months(6), by = "month")
```

### Time Zones

- **`with_tz()`** - Change display timezone (same moment)
- **`force_tz()`** - Force timezone (changes moment)

```r
# Same moment, different display
meeting <- ymd_hms("2024-03-15 14:00:00", tz = "America/New_York")
with_tz(meeting, "Europe/London")

# Force interpretation
force_tz(meeting, "Europe/London")
```

### Rounding

- **`round_date()`, `floor_date()`, `ceiling_date()`**

```r
# Round to nearest hour
round_date(now(), "hour")

# Start of month
floor_date(today(), "month")

# End of year
ceiling_date(today(), "year") - days(1)
```

### Common lubridate Patterns

```r
# Parse various formats
dates <- c("2024-03-15", "15/03/2024", "March 15, 2024")
parse_date_time(dates, orders = c("ymd", "dmy", "mdy"))

# Calculate age
age <- interval(birth_date, today()) / years(1)

# Business day calculations
today() + days(1:7) |>
  keep(~ wday(.x) %in% 2:6)  # Weekdays only

# Time series calculations
data |>
  mutate(
    date = ymd(date_string),
    year = year(date),
    quarter = quarter(date),
    day_of_week = wday(date, label = TRUE)
  )
```

---

## Integration & Common Workflows

### Complete Data Analysis Pipeline

```r
library(tidyverse)

# 1. Import
data <- read_csv("data.csv",
  col_types = cols(
    date = col_date(),
    category = col_character(),
    value = col_double()
  )
)

# 2. Tidy
tidy_data <- data |>
  # Parse dates
  mutate(date = ymd(date)) |>
  # Pivot longer
  pivot_longer(
    cols = starts_with("var"),
    names_to = "variable",
    values_to = "measurement"
  ) |>
  # Clean strings
  mutate(
    category = str_to_lower(category),
    category = str_trim(category),
    category = fct_lump_n(category, 10)
  )

# 3. Transform
transformed <- tidy_data |>
  # Filter
  filter(date >= ymd("2024-01-01")) |>
  # Create new variables
  mutate(
    year = year(date),
    month = month(date, label = TRUE),
    is_outlier = abs(measurement - mean(measurement)) > 3 * sd(measurement)
  ) |>
  # Group and summarize
  group_by(category, year, month) |>
  summarise(
    n = n(),
    mean = mean(measurement, na.rm = TRUE),
    sd = sd(measurement, na.rm = TRUE),
    .groups = "drop"
  )

# 4. Visualize
transformed |>
  ggplot(aes(month, mean, color = category, group = category)) +
  geom_line() +
  geom_point() +
  facet_wrap(~year) +
  scale_color_viridis_d() +
  theme_minimal() +
  labs(
    title = "Trends by Category",
    x = NULL,
    y = "Mean Measurement"
  )
```

### Advanced Nested Workflows

```r
# Nested modeling workflow
results <- data |>
  # Nest by group
  nest_by(category) |>
  # Fit models
  mutate(
    model = list(lm(y ~ x, data = data)),
    tidied = list(broom::tidy(model)),
    glanced = list(broom::glance(model)),
    predictions = list(broom::augment(model))
  ) |>
  # Extract results
  select(category, tidied, glanced) |>
  unnest(tidied) |>
  filter(term != "(Intercept)")
```

### Functional Programming with purrr

```r
# Process multiple files
files <- dir_ls("data/", glob = "*.csv")

all_data <- files |>
  set_names() |>
  map(read_csv, col_types = cols(.default = col_character())) |>
  map(~ mutate(.x, across(everything(), str_trim))) |>
  list_rbind(names_to = "source") |>
  mutate(source = str_remove(source, "data/|.csv"))
```

### Complex String Processing

```r
# Extract structured information
text_data |>
  mutate(
    # Extract email
    email = str_extract(text, "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"),
    # Extract phone
    phone = str_extract(text, "\\d{3}[-.]?\\d{3}[-.]?\\d{4}"),
    # Clean text
    clean = text |>
      str_to_lower() |>
      str_remove_all("[^a-z0-9 ]") |>
      str_squish()
  )
```

### Advanced Joining Patterns

```r
# Multiple joins
final_data <- customers |>
  left_join(orders, by = "customer_id") |>
  left_join(products, by = "product_id") |>
  left_join(categories, by = "category_id") |>
  # Anti-join to find unmatched
  anti_join(returned_orders, by = "order_id")
```

---

## Additional Resources

### Official Documentation
- **tidyverse.org** - Main website with package links
- **r4ds.hadley.nz** - R for Data Science (2e) book
- **ggplot2-book.org** - ggplot2 book (3e)

### Cheat Sheets
Available at **posit.co/resources/cheatsheets/**:
- Data transformation (dplyr)
- Data tidying (tidyr)
- Data visualization (ggplot2)
- Data import (readr)
- Apply functions (purrr)
- String manipulation (stringr)
- Factors (forcats)
- Dates and times (lubridate)

### Package Ecosystems

#### Data Import Extensions
- **haven** - SPSS, Stata, SAS files
- **readxl** - Excel files
- **googlesheets4** - Google Sheets
- **rvest** - Web scraping
- **jsonlite** - JSON data

#### Data Wrangling Extensions
- **dbplyr** - Database backends
- **dtplyr** - data.table backend
- **arrow** - Apache Arrow for large data

#### Modeling
- **tidymodels** - Complete modeling ecosystem
- **broom** - Tidy model outputs

### Best Practices

1. **Use the pipe** - Chain operations for readability
2. **Be explicit with types** - Specify column types in readr
3. **Embrace tidy data** - Invest time in tidying upfront
4. **Leverage type stability** - Use typed purrr functions
5. **Factor early** - Convert strings to factors early
6. **Handle missing data deliberately** - Don't ignore NAs
7. **Visualize often** - Plots reveal patterns and problems
8. **Document with comments** - Explain the why, not the what
9. **Use reproducible examples** - reprex package for help
10. **Keep learning** - Ecosystem constantly evolving

---

## Quick Reference: Common Operations

### Import CSV
```r
data <- read_csv("file.csv")
```

### Basic transformation
```r
data |>
  filter(condition) |>
  select(col1, col2) |>
  mutate(new = calculation) |>
  arrange(col1)
```

### Group summary
```r
data |> group_by(group) |> summarise(mean = mean(value))
```

### Pivot longer
```r
data |> pivot_longer(cols = -id, names_to = "var", values_to = "val")
```

### Pivot wider
```r
data |> pivot_wider(names_from = var, values_from = val)
```

### Join tables
```r
left_join(x, y, by = "id")
```

### Apply function to columns
```r
data |> mutate(across(where(is.numeric), ~ round(.x, 2)))
```

### Basic plot
```r
ggplot(data, aes(x, y)) + geom_point()
```

### Map over list
```r
map_dbl(list, mean)
```

### String manipulation
```r
str_c(x, y, sep = " ")
str_detect(x, "pattern")
str_replace(x, "old", "new")
```

### Factor reordering
```r
fct_reorder(factor, value)
fct_infreq(factor)
```

### Date parsing
```r
ymd("2024-03-15")
today() + days(7)
```

---

This comprehensive guide covers the core tidyverse ecosystem with practical examples and patterns for effective R data science programming.