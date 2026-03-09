---
name: tidyverse-expert
description: Expert R data manipulation with tidyverse - dplyr, tidyr, purrr, stringr, forcats, lubridate. Use when working with tidyverse, mentions "filter", "select", "mutate", "summarize", "summarise", "arrange", "group_by", "join", "joins", "dplyr verbs", "data wrangling", "manipulação de dados", "data manipulation", "tidyr pivoting", "pivot_longer", "pivot_wider", "pivot", "purrr map", "map", "map_dbl", "purrr", "string manipulation", "manipulação de strings", "stringr", "str_detect", "str_replace", "regex", "factors", "forcats", "fct_reorder", "fct_lump", "fct_collapse", "fct_infreq", "fct_recode", "reorder factors", "reordenar fatores", "reordenar níveis", "factor levels", "níveis de fator", "collapse levels", "combinar níveis", "agrupar níveis", "dates in R", "datas em R", "lubridate", "ymd", "mdy", "dmy", "parse dates", "parsear datas", "parse date", "parsing dates", "year()", "month()", "day()", "hour()", "minute()", "date arithmetic", "aritmética de datas", "date math", "floor_date", "ceiling_date", "round_date", "adicionar dias", "add days", "subtrair dias", "subtract days", "days ago", "dias atrás", "extrair ano", "extract year", "extrair mês", "extract month", pipe operator", "%>%", "|>", or discusses advanced data transformation patterns, nesting, functional programming, or complex data cleaning tasks in R.
version: 1.2.0
allowed-tools: Read, Write, Edit, Grep, Glob
user-invocable: false
---

# Tidyverse Expert - Comprehensive Data Manipulation Skill

Master data manipulation in R using the tidyverse's coherent ecosystem of packages. This skill provides expert guidance on transforming, cleaning, and reshaping data with complete control over all transformation operations.

## The Tidyverse Philosophy

The tidyverse is built on a shared design philosophy:

1. **Tidy data** - Each variable is a column, each observation is a row, each value is a cell
2. **Composable functions** - First argument is always data, enabling pipe workflows
3. **Type stability** - Functions return predictable output types
4. **Human-centered API** - Intuitive, readable code that mirrors analytical thinking

**Philosophy**: Build data pipelines incrementally by composing focused functions, not by using monolithic operations. This enables infinite flexibility while maintaining code clarity.

## Core Packages

### Data Transformation Packages
- **dplyr** - Data manipulation grammar (filter, select, mutate, summarize, join)
- **tidyr** - Data tidying and reshaping (pivot, nest, separate, complete)
- **purrr** - Functional programming tools (map, walk, reduce, safely)

### Specialized Manipulation Packages
- **stringr** - Consistent string manipulation with regex support
- **forcats** - Factor (categorical variable) handling and reordering
- **lubridate** - Date-time parsing, manipulation, and arithmetic

## Package-Specific Guidance

### dplyr: Data Manipulation Grammar

See [references/dplyr-reference.md](references/dplyr-reference.md) for complete documentation.

**Five Core Verbs**:
1. **`filter()`** - Keep rows matching conditions
2. **`select()`** - Keep or drop columns
3. **`mutate()`** - Create or modify columns
4. **`summarize()`** - Aggregate data to summary statistics
5. **`arrange()`** - Order rows by column values

**Key Advanced Features**:
- `across()` - Apply functions to multiple columns
- `rowwise()` - Row-by-row operations
- Window functions - `lag()`, `lead()`, `cumsum()`, `rank()`
- Multiple table operations - joins, set operations, binding

**Common Patterns**:
```r
# Column selection helpers
select(starts_with("x"), ends_with("_id"), contains("temp"))

# Conditional mutation
mutate(category = case_when(
  value < 10 ~ "low",
  value < 50 ~ "medium",
  TRUE ~ "high"
))

# Grouped summaries
summarize(
  across(where(is.numeric), list(mean = mean, sd = sd)),
  .by = group_var
)
```

### tidyr: Data Tidying and Reshaping

See [references/tidyr-reference.md](references/tidyr-reference.md) for complete documentation.

**Core Operations**:
- **Pivoting** - `pivot_longer()`, `pivot_wider()` for reshaping
- **Nesting** - `nest()`, `unnest()` for list-columns
- **Rectangling** - `unnest_wider()`, `unnest_longer()` for JSON/hierarchical data
- **Missing values** - `complete()`, `fill()`, `drop_na()`, `replace_na()`
- **Column splitting** - `separate()`, `separate_wider_*()`, `unite()`

**Key Concepts**:
```r
# Pivot longer - wide to long format
pivot_longer(cols = -id, names_to = "variable", values_to = "value")

# Pivot wider - long to wide format
pivot_wider(names_from = category, values_from = measurement)

# Nesting for grouped operations
nest(.by = group_var) |>
  mutate(model = map(data, ~lm(y ~ x, data = .x))) |>
  mutate(predictions = map2(model, data, predict))
```

### purrr: Functional Programming

See [references/purrr-reference.md](references/purrr-reference.md) for complete documentation.

**Map Family** - Apply functions to lists/vectors:
- `map()` - Returns list
- `map_dbl()`, `map_int()`, `map_chr()`, `map_lgl()` - Type-specific output
- `map2()`, `pmap()` - Iterate over multiple inputs
- `imap()` - Iterate with indices/names
- `walk()` - For side effects (no return value)

**Error Handling**:
- `safely()` - Capture errors without stopping
- `possibly()` - Return default value on error
- `quietly()` - Capture messages, warnings, output

**Predicates & Logic**:
- `keep()`, `discard()` - Filter by predicate
- `some()`, `every()`, `none()` - Test conditions
- `detect()`, `detect_index()` - Find first match

**Common Patterns**:
```r
# Read multiple files
files |> map(read_csv) |> list_rbind()

# Safe operations
results <- data |> map(safely(risky_function))
errors <- results |> map("error") |> discard(is.null)
successes <- results |> map("result") |> discard(is.null)

# Nested iterations
params |> pmap(\(x, y, z) run_model(x, y, z))
```

### stringr: String Manipulation

See [references/stringr-reference.md](references/stringr-reference.md) for complete documentation.

**Core Functions** (all start with `str_*`):
- **Detection** - `str_detect()`, `str_starts()`, `str_ends()`, `str_which()`
- **Extraction** - `str_extract()`, `str_extract_all()`, `str_match()`, `str_sub()`
- **Replacement** - `str_replace()`, `str_replace_all()`, `str_remove()`, `str_remove_all()`
- **Transformation** - `str_to_lower()`, `str_to_upper()`, `str_to_title()`, `str_trim()`
- **Splitting** - `str_split()`, `str_split_fixed()`, `str_split_i()`

**Pattern Matching**:
```r
# Regex patterns
str_detect(text, "\\d{3}-\\d{4}")  # Phone pattern
str_extract_all(text, "[A-Z]\\w+")  # Capital words

# String cleaning
str_trim() |> str_squish() |> str_to_lower()
```

### forcats: Factor Handling

See [references/forcats-reference.md](references/forcats-reference.md) for complete documentation.

**Key Operations**:
- **Reordering** - `fct_reorder()`, `fct_infreq()`, `fct_inorder()`
- **Recoding** - `fct_recode()`, `fct_collapse()`, `fct_other()`
- **Level manipulation** - `fct_relevel()`, `fct_rev()`, `fct_shift()`
- **Missing values** - `fct_explicit_na()`, `fct_drop()`

**Common Use Cases**:
```r
# Reorder for plotting
mutate(country = fct_reorder(country, value))

# Collapse rare levels
mutate(category = fct_lump_min(category, min = 100))

# Order by frequency
mutate(item = fct_infreq(item))
```

### lubridate: Date-Time Manipulation

See [references/lubridate-reference.md](references/lubridate-reference.md) for complete documentation.

**Parsing Functions**:
- `ymd()`, `mdy()`, `dmy()` - Parse dates
- `ymd_hms()`, `mdy_hm()` - Parse date-times
- `parse_date_time()` - Flexible parsing

**Extraction**:
- `year()`, `month()`, `day()`, `wday()`
- `hour()`, `minute()`, `second()`
- `quarter()`, `week()`

**Arithmetic**:
- Durations - `ddays()`, `dhours()`, `dminutes()` (exact)
- Periods - `days()`, `months()`, `years()` (human-friendly)
- Intervals - `%--%` operator, `int_length()`, `int_overlaps()`

**Common Patterns**:
```r
# Parse dates
dates <- mdy(c("12/31/2023", "01/01/2024"))

# Date arithmetic
today() + days(7)
floor_date(now(), "month")

# Extract components
wday(date, label = TRUE)  # "Mon", "Tue", ...
month(date, label = TRUE)  # "Jan", "Feb", ...
```

## Common Workflow Patterns

### Pattern 1: Data Import and Initial Cleaning
```r
raw_data <- read_csv("data.csv") |>
  janitor::clean_names() |>                    # Standardize column names
  mutate(
    date = mdy(date_col),                      # Parse dates
    category = str_trim(str_to_lower(category)), # Clean strings
    value = as.numeric(str_remove(value, "\\$")) # Clean currency
  ) |>
  filter(!is.na(key_column)) |>                # Remove invalid rows
  distinct()                                   # Remove duplicates
```

### Pattern 2: Complex Grouping and Summarization
```r
summary <- data |>
  group_by(category, year = year(date)) |>
  summarize(
    across(where(is.numeric), list(
      mean = \(x) mean(x, na.rm = TRUE),
      median = \(x) median(x, na.rm = TRUE),
      sd = \(x) sd(x, na.rm = TRUE)
    )),
    n = n(),
    .groups = "drop"
  )
```

### Pattern 3: Pivoting and Reshaping
```r
# Wide to long
long_data <- wide_data |>
  pivot_longer(
    cols = matches("\\d{4}"),  # Year columns
    names_to = "year",
    values_to = "value",
    names_transform = list(year = as.integer)
  )

# Long to wide with multiple values
wide_data <- long_data |>
  pivot_wider(
    names_from = metric,
    values_from = c(value, error),
    names_glue = "{metric}_{.value}"
  )
```

### Pattern 4: Nested Data and Models
```r
nested_models <- data |>
  nest(.by = group) |>
  mutate(
    model = map(data, \(df) lm(y ~ x, data = df)),
    tidy = map(model, broom::tidy),
    glance = map(model, broom::glance),
    augment = map2(model, data, broom::augment)
  ) |>
  unnest(glance) |>
  arrange(desc(r.squared))
```

### Pattern 5: Multiple Joins
```r
combined <- sales |>
  left_join(customers, by = "customer_id") |>
  left_join(products, by = "product_id") |>
  left_join(regions, by = c("state" = "region_code")) |>
  mutate(
    revenue = quantity * unit_price,
    margin = revenue - (quantity * cost)
  )
```

## Best Practices

### Pipe Workflows
✅ **DO**:
- Use native pipe `|>` (R ≥ 4.1) preferred over magrittr `%>%`
- Break long pipes into intermediate objects for debugging
- Put each step on its own line
- Use `.by` argument in dplyr 1.1+ instead of `group_by() |> ... |> ungroup()`

❌ **DON'T**:
- Create pipes longer than 10 steps without breaking
- Mix pipe and base R assignment in confusing ways
- Forget to ungroup after group operations (if not using `.by`)

### Column Selection
✅ **DO**:
- Use tidy-select helpers: `starts_with()`, `ends_with()`, `contains()`, `matches()`, `where()`
- Use `across()` for multi-column operations
- Use `:` for column ranges: `select(id:name)`

❌ **DON'T**:
- Use `df$column` inside dplyr verbs (breaks data masking)
- Repeat similar operations instead of using `across()`

### Type Conversion
✅ **DO**:
- Use `readr::parse_*()` functions for robust parsing
- Use `lubridate` for dates, not base R
- Use `forcats` for factors, not base R

❌ **DON'T**:
- Use `as.Date()` with ambiguous formats
- Create factors with `factor()` when you need ordered levels
- Ignore parsing warnings from `read_csv()`

### Missing Values
✅ **DO**:
- Use `tidyr::complete()` to make implicit missing values explicit
- Use `tidyr::fill()` to carry forward/backward
- Use `coalesce()` for value replacement
- Specify `na.rm = TRUE` in summary functions

❌ **DON'T**:
- Forget that `filter()` drops NAs by default
- Use `na.omit()` carelessly (drops entire rows)

## Performance Tips

1. **Use data.table for large data**: tidyverse is optimized for readability, data.table for speed
2. **Filter early**: Reduce data size before expensive operations
3. **Avoid row-wise operations**: Vectorize when possible; use `rowwise()` only when necessary
4. **Use `where()` instead of `across(everything())`**: More targeted selections
5. **Pre-allocate with joins**: Use `left_join()` instead of `rbind()` in loops

## Debugging Strategies

1. **Break pipes**: Assign intermediate results to inspect
2. **Use `glimpse()`**: Quick data structure check
3. **Use `count()`**: Verify grouping and filtering
4. **Use `slice_sample()`**: Test on small subset first
5. **Check joins**: Use `anti_join()` to find non-matches

## Common Pitfalls

### Pitfall 1: Grouped Data Propagation
```r
# ❌ Group persists unexpectedly
df |>
  group_by(category) |>
  summarize(mean_val = mean(value)) |>
  mutate(diff = mean_val - lag(mean_val))  # Still grouped!

# ✅ Use .by or ungroup()
df |>
  summarize(mean_val = mean(value), .by = category) |>
  mutate(diff = mean_val - lag(mean_val))
```

### Pitfall 2: Implicit NA Behavior
```r
# ❌ filter() drops NAs silently
filter(value > 10)  # Loses NA rows

# ✅ Be explicit
filter(value > 10 | is.na(value))
```

### Pitfall 3: Factor Ordering
```r
# ❌ Alphabetical ordering
ggplot(aes(x = category, y = value)) + geom_col()

# ✅ Meaningful ordering
mutate(category = fct_reorder(category, value)) |>
  ggplot(aes(x = category, y = value)) + geom_col()
```

## Supporting Resources

### Complete Reference Documentation
- **dplyr** - [references/dplyr-reference.md](references/dplyr-reference.md)
- **tidyr** - [references/tidyr-reference.md](references/tidyr-reference.md)
- **purrr** - [references/purrr-reference.md](references/purrr-reference.md)
- **stringr** - [references/stringr-reference.md](references/stringr-reference.md)
- **forcats** - [references/forcats-reference.md](references/forcats-reference.md)
- **lubridate** - [references/lubridate-reference.md](references/lubridate-reference.md)

### Practical Examples
- Real-world workflows: [examples/workflow-examples.md](examples/workflow-examples.md)
- Complete case studies: [examples/case-studies.md](examples/case-studies.md)

### Reusable Templates
- Common patterns: [templates/data-wrangling-templates.md](templates/data-wrangling-templates.md)

## Integration with Other Skills

- Use **ggplot2** skill for visualization after data preparation
- Use **r-tidymodels** skill for machine learning workflows
- Use **r-datascience** skill for complete analysis guidance
- Use **tidyverse-patterns** skill for modern syntax updates

## Quick Reference: Function Lookup

| Task | Package | Function |
|------|---------|----------|
| Filter rows | dplyr | `filter()` |
| Select columns | dplyr | `select()` |
| Create columns | dplyr | `mutate()` |
| Aggregate data | dplyr | `summarize()` |
| Sort rows | dplyr | `arrange()` |
| Join tables | dplyr | `left_join()`, `inner_join()`, etc. |
| Wide to long | tidyr | `pivot_longer()` |
| Long to wide | tidyr | `pivot_wider()` |
| Nest data | tidyr | `nest()` |
| Fill missing | tidyr | `fill()`, `complete()` |
| Apply to list | purrr | `map()`, `map_dbl()`, etc. |
| Safe operations | purrr | `safely()`, `possibly()` |
| Match pattern | stringr | `str_detect()`, `str_match()` |
| Extract text | stringr | `str_extract()`, `str_sub()` |
| Replace text | stringr | `str_replace()`, `str_remove()` |
| Reorder factor | forcats | `fct_reorder()`, `fct_infreq()` |
| Collapse levels | forcats | `fct_collapse()`, `fct_lump()` |
| Parse date | lubridate | `ymd()`, `mdy()`, `dmy()` |
| Extract component | lubridate | `year()`, `month()`, `day()` |
| Date arithmetic | lubridate | `days()`, `months()`, `years()` |
