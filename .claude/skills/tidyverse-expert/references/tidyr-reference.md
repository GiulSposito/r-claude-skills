# tidyr Reference Guide

## Overview

tidyr helps you create tidy data - data where each variable is a column, each observation is a row, and each value is a cell. It provides tools for:
- Pivoting data between wide and long formats
- Nesting and unnesting data structures
- Handling missing values
- Splitting and combining columns

---

## Pivoting Data

### pivot_longer() - Wide to Long

Transform data from wide format (multiple columns) to long format (fewer columns, more rows).

**Basic Syntax:**
```r
pivot_longer(
  data,
  cols,                    # Columns to pivot
  names_to = "name",       # Name of new column for old column names
  values_to = "value"      # Name of new column for values
)
```

**Examples:**

```r
# Basic pivot
relig_income |>
  pivot_longer(
    cols = -religion,
    names_to = "income",
    values_to = "count"
  )

# Using column selection helpers
billboard |>
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank"
  )

# Multiple value columns
who |>
  pivot_longer(
    cols = new_sp_m014:newrel_f65,
    names_to = "key",
    values_to = "cases"
  )

# Drop NA values
billboard |>
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank",
    values_drop_na = TRUE
  )

# Parse column names with pattern
billboard |>
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    names_prefix = "wk",        # Remove "wk" prefix
    names_transform = as.integer,
    values_to = "rank"
  )

# Split names into multiple columns
who |>
  pivot_longer(
    cols = new_sp_m014:newrel_f65,
    names_to = c("diagnosis", "gender", "age"),
    names_pattern = "new_?(.*)_(.)(.*)",
    values_to = "count"
  )

# Use ".value" to create multiple value columns
household |>
  pivot_longer(
    cols = -family,
    names_to = c(".value", "child"),
    names_sep = "_"
  )
# Result: dob_child1, dob_child2 -> dob (column), child (1, 2)
```

**Key Arguments:**
- `cols` - Columns to pivot (use selection helpers)
- `names_to` - Name(s) of new column(s) for old column names
- `values_to` - Name of new column for values
- `names_prefix` - String to remove from start of column names
- `names_sep` / `names_pattern` - How to split column names
- `names_transform` - Function to apply to name columns
- `values_drop_na` - Drop rows with NA values (default FALSE)
- `values_transform` - Function to apply to value columns

---

### pivot_wider() - Long to Wide

Transform data from long format to wide format.

**Basic Syntax:**
```r
pivot_wider(
  data,
  names_from = name_col,      # Column(s) to get new column names from
  values_from = value_col,    # Column(s) to get values from
  values_fill = NULL          # Value for missing combinations
)
```

**Examples:**

```r
# Basic pivot
fish_encounters |>
  pivot_wider(
    names_from = station,
    values_from = seen
  )

# Fill missing values
fish_encounters |>
  pivot_wider(
    names_from = station,
    values_from = seen,
    values_fill = 0
  )

# Multiple names_from columns
production |>
  pivot_wider(
    names_from = c(product, country),
    values_from = production
  )

# Custom name separator
production |>
  pivot_wider(
    names_from = c(product, country),
    values_from = production,
    names_sep = "."
  )

# Add prefix to new columns
us_rent_income |>
  pivot_wider(
    names_from = variable,
    values_from = c(estimate, moe),
    names_glue = "{variable}_{.value}"
  )

# Handle duplicate combinations (aggregate)
warpbreaks |>
  pivot_wider(
    names_from = wool,
    values_from = breaks,
    values_fn = mean  # Aggregate duplicates
  )

# Multiple value columns
us_rent_income |>
  pivot_wider(
    names_from = variable,
    values_from = c(estimate, moe)
  )
```

**Key Arguments:**
- `names_from` - Column(s) to get new column names from
- `values_from` - Column(s) to get values from
- `values_fill` - Value to use for missing combinations
- `values_fn` - Function to aggregate duplicate combinations
- `names_sep` - Separator between combined column names
- `names_prefix` - Prefix for new column names
- `names_glue` - Custom naming pattern using glue syntax

**Common Pitfalls:**
- Duplicate row identifiers will cause warnings - use `values_fn` to aggregate
- Missing combinations create NA values - use `values_fill` to replace them

---

## Nesting Data

### nest() - Create List-Columns

Nest grouped data into list-columns.

```r
# Nest by grouping
mtcars |>
  group_by(cyl) |>
  nest()
# Result: cyl column + data column (list of tibbles)

# Nest specific columns
starwars |>
  nest(films_data = films)

# Nest multiple columns
iris |>
  nest(measurements = c(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width))

# Nest by multiple groups
mtcars |>
  group_by(cyl, gear) |>
  nest()
```

### unnest() - Expand List-Columns

Expand list-columns back to regular columns.

```r
# Basic unnest
df <- tibble(
  x = 1:3,
  y = list(c("a", "b"), "c", c("d", "e", "f"))
)

df |>
  unnest(y)

# Unnest with longer
df |>
  unnest_longer(y)

# Unnest with wider
df |>
  unnest_wider(y, names_sep = "_")

# Multiple list-columns
df <- tibble(
  x = 1:2,
  y = list(c(1, 2), c(3, 4)),
  z = list(c("a", "b"), c("c", "d"))
)

df |>
  unnest(c(y, z))

# Keep empty rows
df |>
  unnest(y, keep_empty = TRUE)
```

### nest_by() - Nest with Grouping

Create a rowwise tibble with nested data.

```r
# Nest and perform row-wise operations
mtcars |>
  nest_by(cyl) |>
  mutate(
    n = nrow(data),
    avg_mpg = mean(data$mpg)
  )

# With model fitting
mtcars |>
  nest_by(cyl) |>
  mutate(
    model = list(lm(mpg ~ wt, data = data)),
    rsq = summary(model)$r.squared
  )
```

---

## Rectangling Data

Tools for converting deeply nested lists (like JSON) into tidy tibbles.

### unnest_longer() - One Row per Element

```r
# Unnest list column to multiple rows
df <- tibble(
  id = 1:3,
  values = list(
    c(1, 2),
    c(3, 4, 5),
    c(6)
  )
)

df |>
  unnest_longer(values)
# Result: 6 rows (one per element)

# Keep indices
df |>
  unnest_longer(values, indices_to = "position")

# Simplify automatically
df <- tibble(
  id = 1:2,
  x = list(list(a = 1, b = 2), list(a = 3, b = 4))
)

df |>
  unnest_longer(x)
```

### unnest_wider() - One Column per Element

```r
# Unnest named list to columns
df <- tibble(
  id = 1:2,
  data = list(
    list(x = 1, y = "a"),
    list(x = 2, y = "b")
  )
)

df |>
  unnest_wider(data)
# Result: id, x, y columns

# With name separator
df |>
  unnest_wider(data, names_sep = "_")
# Result: id, data_x, data_y columns

# Handle inconsistent names
df <- tibble(
  id = 1:3,
  data = list(
    list(x = 1, y = "a"),
    list(x = 2, z = "b"),
    list(y = "c")
  )
)

df |>
  unnest_wider(data)
# Result: Fills missing with NA
```

### hoist() - Extract Specific Elements

```r
# Extract specific elements from nested list
df <- tibble(
  id = 1:2,
  metadata = list(
    list(name = "Alice", age = 30, city = "NYC", state = "NY"),
    list(name = "Bob", age = 25, city = "LA", state = "CA")
  )
)

df |>
  hoist(metadata,
    name = "name",
    age = "age"
  )
# Result: id, name, age, metadata (without name/age)

# Extract nested elements
df <- tibble(
  id = 1,
  data = list(list(
    user = list(name = "Alice", email = "alice@example.com"),
    score = 95
  ))
)

df |>
  hoist(data,
    user_name = c("user", "name"),
    user_email = c("user", "email"),
    score = "score"
  )
```

### unnest_auto() - Automatic Unnesting

```r
# Automatically choose unnest_longer or unnest_wider
df |>
  unnest_auto(column)
```

---

## Column Operations

### separate_wider_delim() - Split into Columns

```r
# Split by delimiter
df <- tibble(x = c("a-b-c", "d-e-f", "g-h-i"))

df |>
  separate_wider_delim(
    x,
    delim = "-",
    names = c("first", "second", "third")
  )

# Too many pieces
df <- tibble(x = c("a-b", "c-d-e"))

df |>
  separate_wider_delim(
    x,
    delim = "-",
    names = c("first", "second"),
    too_many = "drop"  # or "merge", "error"
  )

# Too few pieces
df <- tibble(x = c("a-b-c", "d-e"))

df |>
  separate_wider_delim(
    x,
    delim = "-",
    names = c("first", "second", "third"),
    too_few = "align_start"  # or "align_end", "error"
  )
```

### separate_wider_position() - Split by Position

```r
# Split by character positions
df <- tibble(x = c("AB123", "CD456", "EF789"))

df |>
  separate_wider_position(
    x,
    widths = c(code = 2, number = 3)
  )
# Result: code = "AB", "CD", "EF"; number = "123", "456", "789"
```

### separate_wider_regex() - Split by Pattern

```r
# Split using regex groups
df <- tibble(x = c("name: Alice, age: 30", "name: Bob, age: 25"))

df |>
  separate_wider_regex(
    x,
    patterns = c(
      "name: ", name = "[^,]+",
      ", age: ", age = "\\d+"
    )
  )
```

### separate_longer_delim() - Split into Rows

```r
# Split into multiple rows
df <- tibble(
  id = 1:3,
  x = c("a,b,c", "d", "e,f")
)

df |>
  separate_longer_delim(x, delim = ",")
# Result: 6 rows

# Multiple columns
df |>
  separate_longer_delim(c(x, y), delim = ",")
```

### separate_longer_position() - Split by Position into Rows

```r
# Split fixed-width into rows
df <- tibble(x = c("AB", "CDEF"))

df |>
  separate_longer_position(x, width = 1)
# Result: "A", "B", "C", "D", "E", "F" (6 rows)
```

### unite() - Combine Columns

```r
# Combine multiple columns
df <- tibble(
  year = c(2020, 2021),
  month = c(1, 2),
  day = c(15, 20)
)

df |>
  unite("date", year, month, day, sep = "-")
# Result: "2020-1-15", "2021-2-20"

# Remove original columns (default)
df |>
  unite("date", year:day)

# Keep original columns
df |>
  unite("date", year:day, remove = FALSE)

# Handle NAs
df <- tibble(x = c("a", NA), y = c("b", "c"))

df |>
  unite("z", x, y, na.rm = TRUE)
# Result: "a_b", "c" (NA removed from first)
```

---

## Missing Values

### complete() - Make Implicit Missing Values Explicit

```r
# Complete all combinations
df <- tibble(
  group = c("A", "A", "B", "B"),
  item = c(1, 2, 1, 3),
  value = c(10, 20, 30, 40)
)

df |>
  complete(group, item)
# Adds rows for A-3 and B-2 with NA values

# With fill values
df |>
  complete(group, item, fill = list(value = 0))

# Complete within groups
df |>
  complete(nesting(group), item)

# Complete sequences
sales <- tibble(
  year = c(2020, 2020, 2021),
  quarter = c(1, 3, 2),
  revenue = c(100, 120, 110)
)

sales |>
  complete(
    year = 2020:2021,
    quarter = 1:4
  )
```

### expand() - Create All Combinations

```r
# All combinations (doesn't add to data)
df |>
  expand(group, item)

# Sequences
expand(tibble(), year = 2020:2022, quarter = 1:4)

# Nesting (only observed combinations)
df |>
  expand(nesting(year, quarter), product)

# With other variables
df |>
  expand(group, item, value = c(0, 100))
```

### fill() - Fill Missing Values

```r
# Fill down (default)
df <- tibble(
  group = c("A", NA, NA, "B", NA, NA),
  value = 1:6
)

df |>
  fill(group)
# Result: "A", "A", "A", "B", "B", "B"

# Fill up
df |>
  fill(group, .direction = "up")

# Fill both directions
df |>
  fill(group, .direction = "downup")

# Fill multiple columns
df |>
  fill(group, value)
```

### drop_na() - Remove Rows with NAs

```r
# Drop rows with any NA
df |>
  drop_na()

# Drop rows with NA in specific columns
df |>
  drop_na(group, value)

# Drop rows with NA in any of these columns
df |>
  drop_na(starts_with("col"))
```

### replace_na() - Replace NAs with Values

```r
# Replace in specific columns
df <- tibble(
  x = c(1, NA, 3),
  y = c("a", "b", NA)
)

df |>
  replace_na(list(x = 0, y = "unknown"))

# In mutate
df |>
  mutate(x = replace_na(x, 0))
```

---

## Advanced Techniques

### Working with Multiple List-Columns

```r
# Nest multiple columns into separate list-columns
iris |>
  nest(
    sepal = starts_with("Sepal"),
    petal = starts_with("Petal")
  )

# Unnest multiple list-columns in parallel
df <- tibble(
  x = 1:2,
  y = list(c(1, 2), c(3, 4)),
  z = list(c("a", "b"), c("c", "d"))
)

df |>
  unnest(c(y, z))  # Parallel: same length required
```

### JSON-like Data Wrangling

```r
# Complex nested JSON structure
json_data <- tibble(
  id = 1:2,
  data = list(
    list(
      user = list(name = "Alice", age = 30),
      purchases = list(
        list(item = "book", price = 20),
        list(item = "pen", price = 5)
      )
    ),
    list(
      user = list(name = "Bob", age = 25),
      purchases = list(
        list(item = "laptop", price = 1000)
      )
    )
  )
)

# Extract user info
json_data |>
  hoist(data,
    name = c("user", "name"),
    age = c("user", "age"),
    purchases = "purchases"
  ) |>
  unnest_longer(purchases) |>
  unnest_wider(purchases)
```

### Pivot with Multiple Value Columns

```r
# Multiple measures
us_rent_income |>
  pivot_wider(
    names_from = variable,
    values_from = c(estimate, moe),
    names_glue = "{variable}_{.value}"
  )
```

---

## Best Practices

### Pivoting
1. **Start wide, analyze long** - Most tidyverse functions work best with long data
2. **Use descriptive names** - `names_to` and `values_to` should be meaningful
3. **Handle NAs explicitly** - Use `values_drop_na` or `values_fill`
4. **Parse names when needed** - Use `names_pattern` or `names_sep` to extract information

### Nesting
1. **Nest for modeling** - Great for fitting many models at once
2. **Use nest_by() for row-wise** - Automatically creates row-wise tibble
3. **Keep nesting simple** - Deep nesting is hard to work with
4. **Unnest carefully** - Check dimensions before unnesting

### Missing Values
1. **Make implicit explicit** - Use `complete()` to find missing combinations
2. **Document assumptions** - Note why you're filling or dropping NAs
3. **Use appropriate method** - `fill()` for carry-forward, `replace_na()` for defaults
4. **Consider data meaning** - NA might be meaningful, not just missing

### Column Operations
1. **Validate splits** - Check for edge cases in your data
2. **Handle errors** - Use `too_many`, `too_few` arguments
3. **Test with samples** - Try separating on a small subset first
4. **Keep originals when debugging** - Use `remove = FALSE` initially

---

## Common Pitfalls

1. **Pivot creates too many rows** - Check for duplicate identifiers
2. **Unnest loses rows** - Use `keep_empty = TRUE` if needed
3. **Complete creates huge output** - Be careful with many grouping variables
4. **Fill propagates wrong values** - Check direction and grouping
5. **Separate fails silently** - Always check for warnings
6. **Lost column types** - Some operations convert to character

---

## Quick Reference Card

| Task | Function | Example |
|------|----------|---------|
| Wide to long | `pivot_longer()` | `pivot_longer(cols = -id)` |
| Long to wide | `pivot_wider()` | `pivot_wider(names_from = name)` |
| Create list-column | `nest()` | `nest(data = c(x, y))` |
| Expand list-column | `unnest()` | `unnest(data)` |
| One row per element | `unnest_longer()` | `unnest_longer(values)` |
| One col per element | `unnest_wider()` | `unnest_wider(data)` |
| Extract elements | `hoist()` | `hoist(data, name = "name")` |
| Split to columns | `separate_wider_delim()` | `separate_wider_delim(x, "-")` |
| Split to rows | `separate_longer_delim()` | `separate_longer_delim(x, ",")` |
| Combine columns | `unite()` | `unite("date", year, month)` |
| Add missing combos | `complete()` | `complete(group, item)` |
| Fill missing | `fill()` | `fill(group)` |
| Drop NAs | `drop_na()` | `drop_na(x, y)` |
| Replace NAs | `replace_na()` | `replace_na(list(x = 0))` |
