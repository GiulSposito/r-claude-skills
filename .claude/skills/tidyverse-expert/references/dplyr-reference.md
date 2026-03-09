# dplyr Reference Guide

## Overview

dplyr provides a grammar of data manipulation with a consistent set of verbs that help you solve the most common data manipulation challenges. All dplyr functions:
- Take a data frame as the first argument
- Return a data frame
- Work naturally with the pipe operator (`|>` or `|>`)
- Use tidy evaluation for direct column references

---

## Core Single-Table Verbs

### filter() - Subset Rows

Select rows based on logical conditions.

```r
# Basic filtering
starwars |>
  filter(species == "Droid")

# Multiple conditions (AND)
starwars |>
  filter(height > 180, mass < 100)

# OR conditions
starwars |>
  filter(species == "Droid" | species == "Human")

# Using %in% for multiple values
starwars |>
  filter(eye_color %in% c("blue", "brown", "black"))

# Excluding values
starwars |>
  filter(!species %in% c("Droid", "Human"))

# Filtering with between()
starwars |>
  filter(between(height, 150, 200))

# Filtering with is.na()
starwars |>
  filter(!is.na(hair_color))
```

**Common Pitfalls:**
- Using `=` instead of `==` for equality testing
- Forgetting to handle NA values (filter removes NAs by default)

---

### select() - Subset Columns

Choose columns by name or using helper functions.

```r
# Select by name
starwars |>
  select(name, height, mass)

# Select range
starwars |>
  select(name:mass)

# Exclude columns
starwars |>
  select(-films, -vehicles, -starships)

# Using helpers
starwars |>
  select(starts_with("s"))

starwars |>
  select(ends_with("color"))

starwars |>
  select(contains("_"))

starwars |>
  select(matches("^[hs]"))  # Regex

# Select by type
starwars |>
  select(where(is.numeric))

starwars |>
  select(where(is.character))

# Reorder and rename
starwars |>
  select(character_name = name, height, mass, everything())

# Select and rename
starwars |>
  select(character = name, home = homeworld)
```

**Helper Functions:**
- `starts_with("prefix")` - Columns starting with prefix
- `ends_with("suffix")` - Columns ending with suffix
- `contains("string")` - Columns containing string
- `matches("regex")` - Columns matching regex
- `num_range("x", 1:5)` - Columns x1, x2, x3, x4, x5
- `all_of(vars)` - All variables in character vector (errors if missing)
- `any_of(vars)` - Any variables in character vector (silent if missing)
- `everything()` - All remaining columns
- `last_col()` - Last column
- `where(predicate)` - Columns where predicate is TRUE

---

### mutate() - Create/Modify Columns

Add new columns or modify existing ones.

```r
# Create new column
starwars |>
  mutate(bmi = mass / ((height / 100) ^ 2))

# Multiple columns
starwars |>
  mutate(
    height_m = height / 100,
    bmi = mass / (height_m ^ 2)
  )

# Reference newly created columns
starwars |>
  mutate(
    height_m = height / 100,
    bmi = mass / (height_m ^ 2),
    bmi_category = case_when(
      bmi < 18.5 ~ "Underweight",
      bmi < 25 ~ "Normal",
      bmi < 30 ~ "Overweight",
      TRUE ~ "Obese"
    )
  )

# Conditional mutation with if_else()
starwars |>
  mutate(
    size = if_else(height > 180, "tall", "short")
  )

# Multiple conditions with case_when()
starwars |>
  mutate(
    species_group = case_when(
      species == "Human" ~ "Human",
      species == "Droid" ~ "Droid",
      is.na(species) ~ "Unknown",
      TRUE ~ "Other"
    )
  )

# Modify existing column
starwars |>
  mutate(name = str_to_upper(name))

# Only keep new columns
starwars |>
  transmute(
    name,
    bmi = mass / ((height / 100) ^ 2)
  )
```

**Best Practices:**
- Use `if_else()` for simple two-way conditions (type-safe)
- Use `case_when()` for multiple conditions
- Reference newly created columns in the same mutate() call
- Use `transmute()` to only keep new/selected columns

---

### summarize() / summarise() - Aggregate Data

Reduce multiple values to a single summary value.

```r
# Single summary
starwars |>
  summarize(
    avg_height = mean(height, na.rm = TRUE)
  )

# Multiple summaries
starwars |>
  summarize(
    n = n(),
    avg_height = mean(height, na.rm = TRUE),
    median_mass = median(mass, na.rm = TRUE),
    min_height = min(height, na.rm = TRUE),
    max_height = max(height, na.rm = TRUE),
    sd_height = sd(height, na.rm = TRUE)
  )

# With grouping
starwars |>
  group_by(species) |>
  summarize(
    n = n(),
    avg_height = mean(height, na.rm = TRUE)
  )

# Multiple grouping variables
starwars |>
  group_by(species, gender) |>
  summarize(
    n = n(),
    avg_height = mean(height, na.rm = TRUE),
    .groups = "drop"  # Remove grouping
  )

# Counting unique values
starwars |>
  summarize(
    n_species = n_distinct(species),
    n_homeworlds = n_distinct(homeworld)
  )
```

**Common Summary Functions:**
- `n()` - Count rows
- `n_distinct(x)` - Count unique values
- `mean(x, na.rm = TRUE)` - Average
- `median(x, na.rm = TRUE)` - Median
- `sd(x, na.rm = TRUE)` - Standard deviation
- `IQR(x, na.rm = TRUE)` - Interquartile range
- `min(x, na.rm = TRUE)` - Minimum
- `max(x, na.rm = TRUE)` - Maximum
- `sum(x, na.rm = TRUE)` - Sum
- `first(x)` - First value
- `last(x)` - Last value
- `nth(x, n)` - Nth value

---

### arrange() - Sort Rows

Order rows by column values.

```r
# Ascending order
starwars |>
  arrange(height)

# Descending order
starwars |>
  arrange(desc(height))

# Multiple columns
starwars |>
  arrange(species, desc(height))

# Handle NAs
starwars |>
  arrange(desc(is.na(hair_color)), hair_color)  # NAs last
```

---

## Grouping Operations

### group_by() - Group Data

Create groups for subsequent operations.

```r
# Single grouping variable
starwars |>
  group_by(species) |>
  summarize(avg_height = mean(height, na.rm = TRUE))

# Multiple grouping variables
starwars |>
  group_by(species, gender) |>
  summarize(count = n())

# Add grouping to existing groups
starwars |>
  group_by(species) |>
  group_by(gender, .add = TRUE)  # Now grouped by species AND gender

# Remove grouping
starwars |>
  group_by(species) |>
  summarize(avg_height = mean(height, na.rm = TRUE)) |>
  ungroup()

# Grouping with mutate
starwars |>
  group_by(species) |>
  mutate(
    species_avg_height = mean(height, na.rm = TRUE),
    diff_from_avg = height - species_avg_height
  )
```

### count() - Count Observations

Quick counting shortcut.

```r
# Basic count
starwars |>
  count(species)

# Sort by count
starwars |>
  count(species, sort = TRUE)

# Multiple variables
starwars |>
  count(species, gender)

# With weights
starwars |>
  count(species, wt = mass)

# Add count to existing data
starwars |>
  add_count(species)
```

---

## Joins

### Mutating Joins

Combine data from two tables while preserving observations.

```r
# Sample data
band_members <- tibble(
  name = c("Mick", "John", "Paul"),
  band = c("Stones", "Beatles", "Beatles")
)

band_instruments <- tibble(
  name = c("John", "Paul", "Keith"),
  plays = c("guitar", "bass", "guitar")
)

# left_join - Keep all rows from left table
band_members |>
  left_join(band_instruments, by = "name")
#   name  band     plays
#   Mick  Stones   NA
#   John  Beatles  guitar
#   Paul  Beatles  bass

# right_join - Keep all rows from right table
band_members |>
  right_join(band_instruments, by = "name")
#   name   band     plays
#   John   Beatles  guitar
#   Paul   Beatles  bass
#   Keith  NA       guitar

# inner_join - Keep only matching rows
band_members |>
  inner_join(band_instruments, by = "name")
#   name  band     plays
#   John  Beatles  guitar
#   Paul  Beatles  bass

# full_join - Keep all rows from both tables
band_members |>
  full_join(band_instruments, by = "name")
#   name   band     plays
#   Mick   Stones   NA
#   John   Beatles  guitar
#   Paul   Beatles  bass
#   Keith  NA       guitar

# Join by different column names
band_members |>
  left_join(band_instruments, by = c("name" = "artist"))

# Join by multiple columns
left_join(df1, df2, by = c("id", "date"))

# Natural join (by all common columns)
left_join(df1, df2)
```

### Filtering Joins

Filter one table based on matches in another.

```r
# semi_join - Keep rows that have a match
band_members |>
  semi_join(band_instruments, by = "name")
#   name  band
#   John  Beatles
#   Paul  Beatles

# anti_join - Keep rows that DON'T have a match
band_members |>
  anti_join(band_instruments, by = "name")
#   name  band
#   Mick  Stones
```

**Join Best Practices:**
- Use `left_join()` when you want to keep all records from the primary table
- Use `inner_join()` when you only want matching records
- Use `anti_join()` to find missing matches
- Always specify `by = ` explicitly for clarity
- Check for duplicate keys before joining

---

## Window Functions

Functions that operate within groups of rows.

### Ranking Functions

```r
# row_number - Sequential ranking
starwars |>
  select(name, height) |>
  mutate(rank = row_number(desc(height)))

# min_rank - Standard ranking (ties get same rank)
starwars |>
  mutate(rank = min_rank(desc(height)))

# dense_rank - Dense ranking (no gaps after ties)
starwars |>
  mutate(rank = dense_rank(desc(height)))

# Ranking within groups
starwars |>
  group_by(species) |>
  mutate(rank_in_species = min_rank(desc(height))) |>
  ungroup()

# percent_rank - Percentile ranking (0 to 1)
starwars |>
  mutate(percentile = percent_rank(height))

# ntile - Divide into n groups
starwars |>
  mutate(quartile = ntile(height, 4))
```

### Offset Functions

```r
# lag - Previous value
starwars |>
  arrange(birth_year) |>
  mutate(prev_birth_year = lag(birth_year))

# lead - Next value
starwars |>
  arrange(birth_year) |>
  mutate(next_birth_year = lead(birth_year))

# Lag with default for first row
starwars |>
  mutate(prev_height = lag(height, default = 0))

# Calculate differences
starwars |>
  arrange(birth_year) |>
  mutate(
    age_gap = birth_year - lag(birth_year)
  )

# Within groups
starwars |>
  group_by(species) |>
  arrange(height) |>
  mutate(
    height_diff_from_prev = height - lag(height)
  )
```

### Cumulative Functions

```r
# cumsum - Cumulative sum
df |>
  mutate(running_total = cumsum(sales))

# cummin, cummax - Cumulative min/max
df |>
  mutate(
    cum_min = cummin(value),
    cum_max = cummax(value)
  )

# cummean - Cumulative mean
df |>
  mutate(running_avg = cummean(value))

# Within groups
sales |>
  group_by(product) |>
  arrange(date) |>
  mutate(
    cumulative_sales = cumsum(amount)
  )
```

---

## Advanced Operations

### across() - Apply Function to Multiple Columns

```r
# Apply to multiple columns
starwars |>
  summarize(across(c(height, mass), mean, na.rm = TRUE))

# Using selection helpers
starwars |>
  summarize(across(where(is.numeric), mean, na.rm = TRUE))

# Multiple functions
starwars |>
  summarize(
    across(
      c(height, mass),
      list(mean = mean, sd = sd),
      na.rm = TRUE
    )
  )

# With mutate
starwars |>
  mutate(across(where(is.character), str_to_upper))

# With custom function
starwars |>
  mutate(
    across(
      c(height, mass),
      ~ . / 100,
      .names = "{.col}_scaled"
    )
  )

# With grouping
starwars |>
  group_by(species) |>
  summarize(
    across(where(is.numeric), mean, na.rm = TRUE),
    n = n()
  )
```

### rowwise() - Row-wise Operations

```r
# Create row-wise tibble
df <- tibble(
  x = 1:3,
  y = 4:6,
  z = 7:9
)

# Sum across columns for each row
df |>
  rowwise() |>
  mutate(total = sum(c(x, y, z)))

# With c_across
df |>
  rowwise() |>
  mutate(
    total = sum(c_across(x:z)),
    mean = mean(c_across(x:z))
  )

# List columns
df <- tibble(
  name = c("Alice", "Bob", "Charlie"),
  scores = list(c(85, 90), c(88, 92, 95), c(78, 82, 85, 88))
)

df |>
  rowwise() |>
  mutate(
    avg_score = mean(scores),
    n_tests = length(scores)
  )
```

### slice() Functions - Row Selection by Position

```r
# slice - Select rows by position
starwars |>
  slice(1:5)

# slice_head - First n rows
starwars |>
  slice_head(n = 5)

starwars |>
  slice_head(prop = 0.1)  # First 10%

# slice_tail - Last n rows
starwars |>
  slice_tail(n = 5)

# slice_sample - Random sample
starwars |>
  slice_sample(n = 10)

starwars |>
  slice_sample(prop = 0.1)

# slice_min/slice_max - Rows with min/max values
starwars |>
  slice_min(height, n = 5)

starwars |>
  slice_max(mass, n = 5)

# Within groups
starwars |>
  group_by(species) |>
  slice_max(height, n = 1)
```

---

## Programming with dplyr

### Using {{ }} (Curly-Curly) for Function Arguments

```r
# Function that takes column name
grouped_mean <- function(data, group_var, summary_var) {
  data |>
    group_by({{ group_var }}) |>
    summarize(mean = mean({{ summary_var }}, na.rm = TRUE))
}

starwars |> grouped_mean(species, height)

# Multiple variables
scatter_plot <- function(data, x_var, y_var, color_var) {
  data |>
    ggplot(aes({{ x_var }}, {{ y_var }}, color = {{ color_var }})) +
    geom_point()
}
```

### Using .data[[]] for String Variables

```r
# When column name is a string
summarize_column <- function(data, col_name) {
  data |>
    summarize(
      mean = mean(.data[[col_name]], na.rm = TRUE),
      sd = sd(.data[[col_name]], na.rm = TRUE)
    )
}

starwars |> summarize_column("height")

# Dynamic column selection
select_cols <- function(data, cols) {
  data |>
    select(all_of(cols))
}

starwars |> select_cols(c("name", "height", "mass"))
```

---

## Performance Tips

1. **Use `filter()` early** - Reduce data before expensive operations
2. **Avoid `rowwise()`** - Use vectorized operations when possible
3. **Use `across()` instead of loops** - More efficient and readable
4. **Specify columns explicitly** - Faster than `everything()`
5. **Use `summarize()` with `.groups = "drop"`** - Avoid unexpected grouping behavior
6. **Use appropriate joins** - `inner_join()` is faster than `full_join()`
7. **Remove groups when done** - Use `ungroup()` to avoid confusion

---

## Common Pitfalls

1. **Forgetting to handle NA values** - Most functions need `na.rm = TRUE`
2. **Using `=` instead of `==`** - Assignment vs comparison
3. **Not ungrouping after group_by()** - Can cause unexpected behavior
4. **Overwriting important columns** - Use new names for derived columns
5. **Using base R `[` with dplyr** - Prefer dplyr verbs for consistency
6. **Not specifying join keys** - Always use `by = ` explicitly
7. **Forgetting `.groups` in summarize()** - Can lead to unexpected grouping

---

## Quick Reference Card

| Task | Function | Example |
|------|----------|---------|
| Subset rows | `filter()` | `filter(height > 180)` |
| Subset columns | `select()` | `select(name, height)` |
| Create columns | `mutate()` | `mutate(bmi = mass/height^2)` |
| Aggregate | `summarize()` | `summarize(avg = mean(height))` |
| Sort | `arrange()` | `arrange(desc(height))` |
| Group | `group_by()` | `group_by(species)` |
| Count | `count()` | `count(species)` |
| Join (keep left) | `left_join()` | `left_join(df2, by = "id")` |
| Join (keep both) | `full_join()` | `full_join(df2, by = "id")` |
| Join (keep matches) | `inner_join()` | `inner_join(df2, by = "id")` |
| Filter by match | `semi_join()` | `semi_join(df2, by = "id")` |
| Filter by no match | `anti_join()` | `anti_join(df2, by = "id")` |
| Rank | `min_rank()` | `min_rank(desc(height))` |
| Previous value | `lag()` | `lag(value)` |
| Next value | `lead()` | `lead(value)` |
| Cumulative sum | `cumsum()` | `cumsum(sales)` |
| Apply to columns | `across()` | `across(where(is.numeric), mean)` |
| Row-wise ops | `rowwise()` | `rowwise() |> mutate(sum = x + y)` |
