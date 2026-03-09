# Data Wrangling Guide

Complete reference for data manipulation using dplyr and tidyr.

## Overview

Data wrangling transforms raw data into a format ready for analysis. This guide covers the tidyverse approach using dplyr (data manipulation) and tidyr (data reshaping).

## dplyr: The Five Verbs

All dplyr verbs work similarly:
- First argument is a data frame
- Subsequent arguments describe what to do (use column names without quotes)
- Result is a new data frame
- Use pipes (`|>`) to chain operations

### 1. filter() - Subset Rows

Select rows based on conditions.

```r
library(dplyr)

# Single condition
flights |>filter(month == 1)

# Multiple conditions (AND)
flights |>filter(month == 1, day == 1)
flights |>filter(month == 1 & day == 1)  # Equivalent

# OR conditions
flights |>filter(month == 11 | month == 12)
flights |>filter(month %in% c(11, 12))  # Better

# Combining AND and OR
flights |>filter((month == 11 | month == 12) & day == 1)

# NOT
flights |>filter(!(month %in% c(11, 12)))
flights |>filter(!between(month, 11, 12))

# Missing values
flights |>filter(is.na(dep_time))
flights |>filter(!is.na(dep_time))
```

**Common Operators**:
- `==`, `!=`: Equal, not equal
- `>`, `>=`, `<`, `<=`: Comparisons
- `&`, `|`, `!`: And, or, not
- `%in%`: Check membership in vector
- `between(x, left, right)`: Check if between values
- `near(x, y)`: Check floating point equality with tolerance

### 2. select() - Choose Columns

Select specific columns from a data frame.

```r
# Select by name
flights |>select(year, month, day)

# Select range
flights |>select(year:day)

# Exclude columns
flights |>select(-year, -month)
flights |>select(-(year:day))

# Helper functions
flights |>select(starts_with("dep"))
flights |>select(ends_with("time"))
flights |>select(contains("arr"))
flights |>select(matches("(.)\\1"))  # Regex: repeated character

# Select and rename
flights |>select(departure_time = dep_time, arrival_time = arr_time)

# Reorder columns
flights |>select(time_hour, air_time, everything())
```

**Helper Functions**:
- `starts_with("abc")`: Columns starting with "abc"
- `ends_with("xyz")`: Columns ending with "xyz"
- `contains("ijk")`: Columns containing "ijk"
- `matches("(.)\\1")`: Regex match
- `num_range("x", 1:3)`: Columns x1, x2, x3
- `everything()`: All columns (useful for reordering)
- `last_col()`: Last column
- `where(is.numeric)`: Columns matching predicate

### 3. arrange() - Reorder Rows

Sort rows by column values.

```r
# Ascending order
flights |>arrange(year, month, day)

# Descending order
flights |>arrange(desc(dep_delay))

# Mixed
flights |>arrange(desc(month), day)

# Missing values always at end
flights |>arrange(dep_time)  # NAs at end
```

### 4. mutate() - Create/Modify Columns

Add new columns or modify existing ones.

```r
# Add new columns
flights |>
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60
  )

# Reference newly created columns
flights |>
  mutate(
    gain = dep_delay - arr_delay,
    gain_per_hour = gain / (air_time / 60)
  )

# Keep only new columns
flights |>
  transmute(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours
  )

# Modify existing columns
flights |>
  mutate(
    dep_time = dep_time %/% 100 * 60 + dep_time %% 100,
    arr_time = arr_time %/% 100 * 60 + arr_time %% 100
  )

# Conditional creation
flights |>
  mutate(
    status = case_when(
      arr_delay > 15 ~ "late",
      arr_delay < -15 ~ "early",
      TRUE ~ "on_time"
    )
  )

# Apply to multiple columns
flights |>
  mutate(across(where(is.numeric), ~replace_na(.x, 0)))

flights |>
  mutate(across(c(dep_time, arr_time), ~.x %/% 100))
```

**Useful Functions with mutate()**:
- Arithmetic: `+`, `-`, `*`, `/`, `^`, `%%`, `%/%`
- Aggregates: `cumsum()`, `cumprod()`, `cummin()`, `cummax()`, `cummean()`
- Logical: `<`, `<=`, `>`, `>=`, `==`, `!=`
- Ranking: `min_rank()`, `row_number()`, `dense_rank()`, `percent_rank()`, `ntile()`
- Offsets: `lead()`, `lag()`

### 5. summarize() / summarise() - Collapse to Single Row

Reduce multiple rows to a single summary.

```r
# Single summary
flights |>
  summarise(
    mean_delay = mean(dep_delay, na.rm = TRUE),
    median_delay = median(dep_delay, na.rm = TRUE),
    n = n()
  )

# Multiple summaries
flights |>
  summarise(
    count = n(),
    mean_delay = mean(dep_delay, na.rm = TRUE),
    sd_delay = sd(dep_delay, na.rm = TRUE),
    min_delay = min(dep_delay, na.rm = TRUE),
    max_delay = max(dep_delay, na.rm = TRUE)
  )

# Use across() for multiple columns
flights |>
  summarise(across(c(dep_delay, arr_delay),
                   list(mean = ~mean(.x, na.rm = TRUE),
                        sd = ~sd(.x, na.rm = TRUE))))
```

**Common Summary Functions**:
- `n()`: Count rows
- `n_distinct(x)`: Count unique values
- `sum(x)`, `mean(x)`, `median(x)`
- `sd(x)`, `var(x)`, `IQR(x)`
- `min(x)`, `max(x)`, `quantile(x, 0.25)`
- `first(x)`, `last(x)`, `nth(x, 2)`

## group_by() - Grouped Operations

The game changer: apply operations to groups independently.

```r
# Group and summarize
flights |>
  group_by(year, month, day) |>
  summarise(mean_delay = mean(dep_delay, na.rm = TRUE))

# Group and mutate (adds column with group statistics)
flights |>
  group_by(dest) |>
  mutate(
    avg_dest_delay = mean(arr_delay, na.rm = TRUE),
    n_flights = n()
  )

# Group and filter (filter within groups)
flights |>
  group_by(dest) |>
  filter(n() > 365)  # Destinations with > 365 flights

# Multiple groups
flights |>
  group_by(year, month) |>
  summarise(total_flights = n())

# Always ungroup() when done
flights |>
  group_by(dest) |>
  summarise(delay = mean(arr_delay, na.rm = TRUE)) |>
  ungroup() |>
  arrange(desc(delay))
```

### Advanced Grouping

```r
# Group by expression
flights |>
  group_by(hour = dep_time %/% 100) |>
  summarise(avg_delay = mean(dep_delay, na.rm = TRUE))

# Count groups
flights |>
  group_by(dest) |>
  tally()  # Equivalent to summarise(n = n())

# Count with weights
flights |>
  group_by(dest) |>
  tally(wt = distance)  # Total distance by destination

# More concise counting
flights |>count(dest)
flights |>count(dest, sort = TRUE)  # Sort by count
flights |>count(dest, wt = distance)  # With weights
```

## tidyr: Reshaping Data

### Tidy Data Principles

1. Each variable is a column
2. Each observation is a row
3. Each type of observational unit is a table

### pivot_longer() - Wide to Long

Convert wide data to long format (multiple columns into key-value pairs).

```r
# Basic pivot
table4a |>
  pivot_longer(
    cols = c(`1999`, `2000`),
    names_to = "year",
    values_to = "cases"
  )

# Use helper functions for cols
table4a |>
  pivot_longer(
    cols = -country,  # All except country
    names_to = "year",
    values_to = "cases"
  )

# Multiple value columns
billboard |>
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank",
    values_drop_na = TRUE  # Drop missing values
  )

# Parse column names
who |>
  pivot_longer(
    cols = new_sp_m014:newrel_f65,
    names_to = c("diagnosis", "gender", "age"),
    names_pattern = "new_?(.*)_(.)(.*)",
    values_to = "count"
  )

# Names as numeric
table4a |>
  pivot_longer(
    cols = -country,
    names_to = "year",
    names_transform = list(year = as.integer),
    values_to = "cases"
  )
```

### pivot_wider() - Long to Wide

Convert long data to wide format (key-value pairs into multiple columns).

```r
# Basic pivot
table2 |>
  pivot_wider(
    names_from = type,
    values_from = count
  )

# Handle duplicates
df |>
  pivot_wider(
    names_from = name,
    values_from = value,
    values_fn = list(value = mean)  # Aggregate duplicates
  )

# Multiple value columns
us_rent_income |>
  pivot_wider(
    names_from = variable,
    values_from = c(estimate, moe)
  )

# Custom name separator
df |>
  pivot_wider(
    names_from = name,
    values_from = value,
    names_sep = "_"
  )
```

### separate_wider_delim() / separate_wider_position() - Split Column

Split one column into multiple columns.

```r
# Basic separation
table3 |>
  separate_wider_delim(rate, delim = "/", names = c("cases", "population"))

# Auto-detect separator (use older separate() for this)
table3 |>
  separate(rate, into = c("cases", "population"))

# Convert types
table3 |>
  separate_wider_delim(rate, delim = "/", names = c("cases", "population")) |>
  mutate(across(c(cases, population), as.numeric))

# Keep original column
table3 |>
  separate_wider_delim(rate, delim = "/", names = c("cases", "population"),
                       cols_remove = FALSE)

# Separate by position
table3 |>
  separate_wider_position(year, widths = c(century = 2, year = 2))
```

### unite() - Combine Columns

Combine multiple columns into one.

```r
# Basic unite
table5 |>
  unite(new_col, century, year, sep = "")

# Keep original columns
table5 |>
  unite(new_col, century, year, remove = FALSE)

# Custom separator
table5 |>
  unite(date, year, month, day, sep = "-")
```

### complete() - Fill in Missing Combinations

```r
# Generate all combinations
stocks |>
  complete(year, qtr)

# Fill with specific value
stocks |>
  complete(year, qtr, fill = list(return = 0))

# Nesting
stocks |>
  complete(year, nesting(company, product))
```

### fill() - Fill Missing Values

```r
# Forward fill
treatment |>
  fill(person)

# Backward fill
treatment |>
  fill(person, .direction = "up")

# Both directions
treatment |>
  fill(person, .direction = "downup")
```

## Joining Data

### Mutating Joins

Add columns from one data frame to another.

```r
# Inner join: Keep only matching rows
flights2 |>
  inner_join(airports, by = c("dest" = "faa"))

# Left join: Keep all rows from left
flights2 |>
  left_join(airports, by = c("dest" = "faa"))

# Right join: Keep all rows from right
flights2 |>
  right_join(airports, by = c("dest" = "faa"))

# Full join: Keep all rows from both
flights2 |>
  full_join(airports, by = c("dest" = "faa"))

# Natural join (match on all common columns)
flights2 |>
  left_join(weather)

# Multiple key columns
flights2 |>
  left_join(weather, by = c("year", "month", "day", "hour", "origin"))
```

### Filtering Joins

Filter rows based on another data frame.

```r
# semi_join: Keep rows with match in y
flights |>
  semi_join(top_dest, by = "dest")

# anti_join: Keep rows without match in y
flights |>
  anti_join(planes, by = "tailnum") |>
  count(tailnum, sort = TRUE)
```

### Set Operations

```r
# Rows in both
intersect(df1, df2)

# Rows in either or both
union(df1, df2)

# Rows in df1 but not df2
setdiff(df1, df2)
```

## across() - Apply Functions to Multiple Columns

Modern tidyverse pattern for operating on multiple columns.

```r
# Apply to all numeric columns
df |>
  summarise(across(where(is.numeric), mean, na.rm = TRUE))

# Apply multiple functions
df |>
  summarise(across(where(is.numeric),
                   list(mean = mean, sd = sd),
                   na.rm = TRUE))

# Apply to specific columns
df |>
  mutate(across(c(height, weight), ~.x * 2.54))

# Use with group_by
df |>
  group_by(category) |>
  summarise(across(where(is.numeric), mean, na.rm = TRUE))

# Rename output
df |>
  summarise(across(where(is.numeric),
                   mean,
                   .names = "mean_{.col}",
                   na.rm = TRUE))
```

## Best Practices

✅ **Use pipes** for readability: `data |>filter() |>select() |>arrange()`
✅ **Always handle NAs**: Use `na.rm = TRUE` in summary functions
✅ **Use `count()`** instead of `group_by() + summarise(n = n())`
✅ **Use `across()`** for operations on multiple columns
✅ **Verify joins** don't create unexpected rows
✅ **Use meaningful names** for new columns
✅ **Group carefully**, always `ungroup()` when done

❌ **Don't forget** to check for NAs before summarizing
❌ **Don't use** `$` or `[[]]` when pipes work better
❌ **Don't chain** too many operations without intermediate checks

## Quick Reference

| Task | Function | Example |
|------|----------|---------|
| Subset rows | `filter()` | `filter(df, x > 10)` |
| Choose columns | `select()` | `select(df, x, y)` |
| Sort rows | `arrange()` | `arrange(df, desc(x))` |
| Create columns | `mutate()` | `mutate(df, z = x + y)` |
| Summarize | `summarise()` | `summarise(df, mean_x = mean(x))` |
| Group | `group_by()` | `group_by(df, category)` |
| Count | `count()` | `count(df, category)` |
| Wide to long | `pivot_longer()` | `pivot_longer(df, cols = x:z)` |
| Long to wide | `pivot_wider()` | `pivot_wider(df, names_from = key)` |
| Split column | `separate_wider_delim()` | `separate_wider_delim(df, col, "/", names = c("a", "b"))` |
| Join columns | `unite()` | `unite(df, new_col, a, b)` |
| Left join | `left_join()` | `left_join(df1, df2, by = "id")` |

---

**Remember**: dplyr and tidyr are designed to work together. Clean, transform, and reshape iteratively until data is analysis-ready.
