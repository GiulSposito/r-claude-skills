# forcats Reference Guide

## Overview

forcats provides tools for working with categorical variables (factors) in R. The name comes from **for** **cat**egorical variable**s**. It provides:
- Reordering factor levels
- Recoding factor levels
- Combining and splitting levels
- Handling missing values in factors

**Core Philosophy:**
- Make common factor operations intuitive
- Preserve factor levels when subsetting
- Integration with tidyverse workflows
- Helper functions for plotting and analysis

---

## Creating & Inspecting Factors

### factor() - Create Factors

```r
# Basic factor
x <- factor(c("a", "b", "c", "a"))
x
# Returns: factor with levels: a, b, c

# Factor with ordered levels
x <- factor(c("low", "medium", "high"),
            levels = c("low", "medium", "high"),
            ordered = TRUE)

# Forcats alternative: as_factor() (preserves order of appearance)
x <- as_factor(c("c", "b", "a", "b"))
levels(x)
# Returns: "c" "b" "a" (order of first appearance)

# Compare with base factor()
x <- factor(c("c", "b", "a", "b"))
levels(x)
# Returns: "a" "b" "c" (alphabetical)
```

---

### fct_count() - Count Factor Levels

```r
# Count occurrences
f <- factor(c("a", "b", "a", "c", "a", "b"))
fct_count(f)
# Returns: tibble with f and n columns
#   f     n
#   a     3
#   b     2
#   c     1

# Sort by count
fct_count(f, sort = TRUE)

# Practical: survey analysis
responses <- factor(c("Yes", "No", "Yes", "Maybe", "Yes", "No"))
fct_count(responses)
```

---

### fct_unique() - Unique Levels

```r
# Get unique levels (in order of appearance)
f <- factor(c("a", "b", "a", "c", "a"))
fct_unique(f)
# Returns: c("a", "b", "c") as factor

# Compare with levels()
levels(f)  # All levels, even unused
fct_unique(f)  # Only observed levels in order
```

---

## Reordering Levels

### fct_reorder() - Reorder by Another Variable

Most useful for plotting - reorder factor levels by a numeric variable.

```r
# Basic reordering
df <- tibble(
  name = c("Alice", "Bob", "Charlie"),
  age = c(30, 25, 35)
)

df |>
  mutate(name = fct_reorder(name, age))
# Reorders name levels by age: Bob (25), Alice (30), Charlie (35)

# Practical: ordered bar plot
starwars |>
  filter(!is.na(height)) |>
  group_by(species) |>
  summarize(avg_height = mean(height)) |>
  mutate(species = fct_reorder(species, avg_height)) |>
  ggplot(aes(avg_height, species)) +
  geom_col()

# Reorder descending
df |>
  mutate(name = fct_reorder(name, age, .desc = TRUE))

# Custom function (default is median)
df |>
  mutate(name = fct_reorder(name, age, .fun = mean))

# Reorder by multiple values (uses first)
sales |>
  mutate(product = fct_reorder(product, revenue))

# Practical: ordered boxplot
ggplot(iris, aes(
  x = fct_reorder(Species, Sepal.Length, .fun = median),
  y = Sepal.Length
)) +
  geom_boxplot()
```

---

### fct_reorder2() - Reorder by Two Variables

Reorder by the y values at the largest x value - useful for line plots.

```r
# Line plot legend order
df <- tibble(
  year = rep(2020:2022, each = 3),
  country = rep(c("USA", "UK", "Japan"), 3),
  value = c(100, 80, 90, 110, 85, 95, 120, 90, 100)
)

df |>
  mutate(country = fct_reorder2(country, year, value)) |>
  ggplot(aes(year, value, color = country)) +
  geom_line()
# Legend order matches final y positions
```

---

### fct_infreq() - Reorder by Frequency

Order levels by frequency (most common first).

```r
# By frequency
f <- factor(c("a", "a", "a", "b", "b", "c"))
fct_infreq(f)
# Levels: a (3), b (2), c (1)

# Descending (least common first)
fct_infreq(f) |> fct_rev()

# Practical: bar plot by frequency
starwars |>
  mutate(species = fct_infreq(species)) |>
  ggplot(aes(species)) +
  geom_bar() +
  coord_flip()

# With fct_lump to show top N
starwars |>
  mutate(species = species |>
           fct_lump(n = 5) |>
           fct_infreq()) |>
  ggplot(aes(species)) +
  geom_bar()
```

---

### fct_inorder() - Reorder by First Appearance

Keep levels in order of first appearance (default for as_factor()).

```r
# Order of appearance
f <- factor(c("c", "a", "b", "a", "c"))
fct_inorder(f)
# Levels: c, a, b

# Practical: maintain data order in plot
df <- tibble(
  quarter = c("Q2", "Q3", "Q4", "Q1"),
  revenue = c(100, 120, 110, 95)
)

# Without fct_inorder (alphabetical)
df |>
  ggplot(aes(quarter, revenue)) +
  geom_col()  # Q1, Q2, Q3, Q4

# With fct_inorder (as in data)
df |>
  mutate(quarter = fct_inorder(quarter)) |>
  ggplot(aes(quarter, revenue)) +
  geom_col()  # Q2, Q3, Q4, Q1
```

---

### fct_inseq() - Reorder Numerically

Order levels by numeric value.

```r
# Numeric ordering
f <- factor(c("10", "2", "1", "20"))
fct_inseq(f)
# Levels: 1, 2, 10, 20 (numeric order, not alphabetic)

# Practical: month names
months <- factor(c("Jan", "Mar", "Feb", "Jan"))
# Need custom solution for month names - see fct_relevel()
```

---

### fct_rev() - Reverse Level Order

```r
# Reverse order
f <- factor(c("a", "b", "c"))
fct_rev(f)
# Levels: c, b, a

# Practical: flip axis in plot
starwars |>
  mutate(species = fct_infreq(species) |> fct_rev()) |>
  ggplot(aes(species)) +
  geom_bar() +
  coord_flip()  # Least common at top
```

---

### fct_shift() - Shift Levels

```r
# Shift levels left or right
f <- factor(c("a", "b", "c"))

fct_shift(f)  # Shift left by 1
# Levels: b, c, a

fct_shift(f, n = 2)  # Shift left by 2
# Levels: c, a, b

fct_shift(f, n = -1)  # Shift right by 1
# Levels: c, a, b

# Practical: rotate categories
days <- factor(c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))
fct_shift(days, n = -2)  # Start with Saturday
```

---

### fct_relevel() - Manually Reorder Levels

```r
# Move specific levels to front
f <- factor(c("a", "b", "c", "d"))
fct_relevel(f, "c")
# Levels: c, a, b, d

# Multiple levels
fct_relevel(f, "c", "a")
# Levels: c, a, b, d

# Move to end
fct_relevel(f, "c", after = Inf)
# Levels: a, b, d, c

# Move to specific position
fct_relevel(f, "d", after = 1)
# Levels: a, d, b, c

# Practical: custom order
satisfaction <- factor(c("Good", "Bad", "Okay", "Good"))
fct_relevel(satisfaction, "Bad", "Okay", "Good")

# Month order
months <- factor(c("Jan", "Mar", "Feb"))
fct_relevel(months, "Jan", "Feb", "Mar")

# With function
f <- factor(c("a1", "a2", "b1", "b2"))
fct_relevel(f, sort)  # Apply sort to levels
```

---

## Recoding Levels

### fct_recode() - Change Level Names

```r
# Recode individual levels
f <- factor(c("apple", "orange", "banana"))
fct_recode(f,
  fruit1 = "apple",
  fruit2 = "orange",
  fruit3 = "banana"
)

# Combine levels
f <- factor(c("Yes", "yes", "YES", "No", "no"))
fct_recode(f,
  "Yes" = "yes",
  "Yes" = "YES",
  "No" = "no"
)
# Levels: Yes, No

# Practical: clean survey responses
responses <- factor(c("y", "n", "Y", "N", "yes", "no"))
fct_recode(responses,
  "Yes" = "y",
  "Yes" = "Y",
  "Yes" = "yes",
  "No" = "n",
  "No" = "N",
  "No" = "no"
)

# Rename for display
species <- factor(c("setosa", "versicolor", "virginica"))
fct_recode(species,
  "Setosa" = "setosa",
  "Versicolor" = "versicolor",
  "Virginica" = "virginica"
)
```

---

### fct_collapse() - Combine Many Levels

```r
# Collapse to fewer categories
f <- factor(c("a", "b", "c", "d", "e"))
fct_collapse(f,
  group1 = c("a", "b"),
  group2 = c("c", "d")
)
# Levels: group1, group2, e

# Practical: group age categories
age_group <- factor(c("0-10", "11-20", "21-30", "31-40", "41-50", "51-60"))
fct_collapse(age_group,
  Young = c("0-10", "11-20", "21-30"),
  Middle = c("31-40", "41-50"),
  Senior = "51-60"
)

# Group product categories
product <- factor(c("Laptop", "Phone", "Tablet", "Monitor", "Keyboard"))
fct_collapse(product,
  Electronics = c("Laptop", "Phone", "Tablet"),
  Accessories = c("Monitor", "Keyboard")
)

# Keep other levels explicit
fct_collapse(f,
  group1 = c("a", "b"),
  other_level = "Other"
)
```

---

### fct_lump() - Lump Infrequent Levels

Combine rare levels into "Other" category.

```r
# Keep top n levels
f <- factor(c("a", "a", "a", "b", "b", "c", "d", "e"))
fct_lump(f, n = 2)
# Keeps: a, b, lumps c,d,e into "Other"

# Keep levels above proportion
fct_lump(f, prop = 0.2)
# Keeps levels that appear in >20% of data

# Lump least frequent
fct_lump_min(f, min = 2)
# Lump levels appearing less than 2 times

# Lump to specific number of levels
fct_lump_n(f, n = 3)
# Keep 3 most common + Other

# Custom "Other" label
fct_lump(f, n = 2, other_level = "Rare")

# Practical: simplify for plotting
starwars |>
  mutate(species = fct_lump(species, n = 5)) |>
  count(species) |>
  ggplot(aes(species, n)) +
  geom_col()

# Group rare categories
survey_data |>
  mutate(country = fct_lump_prop(country, prop = 0.05)) |>
  count(country)
```

---

### fct_other() - Manually Specify "Other"

```r
# Keep only specific levels
f <- factor(c("a", "b", "c", "d", "e"))
fct_other(f, keep = c("a", "b"))
# Levels: a, b, Other

# Drop specific levels to Other
fct_other(f, drop = c("d", "e"))
# Levels: a, b, c, Other

# Custom Other level name
fct_other(f, keep = c("a", "b"), other_level = "Rest")

# Practical: focus on main categories
product_sales |>
  mutate(category = fct_other(category,
                               keep = c("Electronics", "Clothing", "Food")))
```

---

## Handling Missing Values

### fct_explicit_na() - Make NA Explicit Level

```r
# Convert NA to explicit level
f <- factor(c("a", "b", NA, "c"))
fct_explicit_na(f)
# Levels: a, b, c, (Missing)

# Custom NA label
fct_explicit_na(f, na_level = "Unknown")
# Levels: a, b, c, Unknown

# Practical: include missing in analysis
survey |>
  mutate(response = fct_explicit_na(response, "No Response")) |>
  count(response)
```

---

### fct_drop() - Drop Unused Levels

```r
# Remove unused levels
f <- factor(c("a", "b"), levels = c("a", "b", "c", "d"))
levels(f)
# Returns: "a" "b" "c" "d"

fct_drop(f)
levels(fct_drop(f))
# Returns: "a" "b"

# Practical: after filtering
df <- starwars |>
  filter(species == "Human")

# Still has all species levels
levels(df$species)  # Many levels

df |>
  mutate(species = fct_drop(species)) |>
  pull(species) |>
  levels()  # Only "Human"

# Automatically drop in plots
starwars |>
  filter(mass < 100) |>
  mutate(species = fct_drop(species)) |>
  ggplot(aes(species)) +
  geom_bar() +
  coord_flip()
```

---

## Combining & Splitting Factors

### fct_unify() - Unify Levels Across Factors

```r
# Combine factor levels from multiple factors
f1 <- factor(c("a", "b"))
f2 <- factor(c("b", "c"))

fct_unify(list(f1, f2))
# Both now have levels: a, b, c

# Practical: prepare for binding
df1 <- tibble(group = factor(c("A", "B")))
df2 <- tibble(group = factor(c("B", "C")))

# Without unify - may cause issues
bind_rows(df1, df2)

# With unify
groups <- fct_unify(list(df1$group, df2$group))
bind_rows(
  df1 |> mutate(group = groups[[1]]),
  df2 |> mutate(group = groups[[2]])
)
```

---

### fct_c() - Concatenate Factors

```r
# Combine factors
f1 <- factor(c("a", "b"))
f2 <- factor(c("c", "d"))

fct_c(f1, f2)
# Returns: factor with levels a, b, c, d

# Handles different level sets
f1 <- factor(c("a", "b"))
f2 <- factor(c("b", "c"))
fct_c(f1, f2)
# Returns: factor with levels a, b, c (unified)

# Practical: combine data sources
site1_data <- factor(c("Product A", "Product B"))
site2_data <- factor(c("Product B", "Product C"))
combined <- fct_c(site1_data, site2_data)
```

---

### fct_cross() - Cross Product of Factors

```r
# Create combinations
f1 <- factor(c("a", "b"))
f2 <- factor(c("x", "y"))

fct_cross(f1, f2)
# Levels: a:x, a:y, b:x, b:y

# Custom separator
fct_cross(f1, f2, sep = "-")
# Levels: a-x, a-y, b-x, b-y

# Keep only observed combinations
f1 <- factor(c("a", "a", "b"))
f2 <- factor(c("x", "y", "x"))
fct_cross(f1, f2, keep_empty = FALSE)

# Practical: interaction terms
treatment <- factor(c("Drug", "Placebo"))
dose <- factor(c("Low", "High"))
fct_cross(treatment, dose)
# Levels: Drug:Low, Drug:High, Placebo:Low, Placebo:High
```

---

## Advanced Techniques

### Ordered Factors for Plotting

```r
# Create ordered factor for modeling
satisfaction <- factor(
  c("Low", "Medium", "High", "Medium"),
  levels = c("Low", "Medium", "High"),
  ordered = TRUE
)

# Or convert with fct_relevel
satisfaction <- fct_relevel(satisfaction, "Low", "Medium", "High")

# Useful for plotting with natural order
df <- tibble(
  satisfaction = factor(c("Low", "Medium", "High", "Low", "High")),
  count = c(10, 20, 15, 8, 22)
)

df |>
  mutate(satisfaction = fct_relevel(satisfaction, "Low", "Medium", "High")) |>
  ggplot(aes(satisfaction, count)) +
  geom_col()
```

---

### Dynamic Recoding

```r
# Recode based on lookup table
lookup <- c(
  "old1" = "new1",
  "old2" = "new2",
  "old3" = "new3"
)

f <- factor(c("old1", "old2", "old3"))
fct_recode(f, !!!lookup)  # !!! for dynamic splicing

# Practical: internationalization
labels_en <- c("Yes", "No", "Maybe")
labels_es <- c("Sí", "No", "Quizás")

responses <- factor(c("Yes", "No", "Yes", "Maybe"))

# Create lookup
lookup <- set_names(labels_en, labels_es)

# Recode
fct_recode(responses, !!!lookup)
```

---

### Working with Ordered Categories

```r
# For ordinal data
education <- factor(
  c("High School", "Bachelor", "Master", "PhD"),
  levels = c("High School", "Bachelor", "Master", "PhD"),
  ordered = TRUE
)

# Comparison works
education[1] < education[4]  # TRUE

# Useful in modeling
model <- lm(salary ~ education, data = employee_data)

# Plotting with order
ggplot(data, aes(education, salary)) +
  geom_boxplot() +
  scale_x_discrete(drop = FALSE)  # Show all levels
```

---

## Practical Workflows

### Cleaning Survey Data

```r
survey_data |>
  mutate(
    # Standardize responses
    satisfaction = fct_recode(satisfaction,
      "Very Satisfied" = "Very satisfied",
      "Very Satisfied" = "very satisfied"
    ),
    # Make NA explicit
    satisfaction = fct_explicit_na(satisfaction, "No Response"),
    # Order levels
    satisfaction = fct_relevel(satisfaction,
      "Very Unsatisfied", "Unsatisfied", "Neutral",
      "Satisfied", "Very Satisfied", "No Response"
    )
  )
```

---

### Preparing Factors for Plotting

```r
# Complete workflow
sales_data |>
  # Group rare categories
  mutate(category = fct_lump(category, n = 10)) |>
  # Order by total sales
  group_by(category) |>
  mutate(total_sales = sum(revenue)) |>
  ungroup() |>
  mutate(category = fct_reorder(category, total_sales)) |>
  # Plot
  ggplot(aes(category, revenue)) +
  geom_boxplot() +
  coord_flip()
```

---

### Combining Multiple Data Sources

```r
# Unify factor levels before combining
datasets <- list(data1, data2, data3)

# Extract factors
categories <- map(datasets, ~ .x$category)

# Unify levels
unified <- fct_unify(categories)

# Apply back
datasets_unified <- map2(datasets, unified, ~ {
  .x |> mutate(category = .y)
})

# Now safe to bind
combined_data <- bind_rows(datasets_unified)
```

---

## Best Practices

1. **Use fct_reorder() for plots** - Much better than manual reordering
2. **Lump before plotting** - Keep plots readable with fct_lump()
3. **Make NA explicit** - Use fct_explicit_na() for complete analysis
4. **Drop unused levels** - After filtering, use fct_drop()
5. **Standardize early** - Clean and recode factors at import
6. **Document recoding** - Keep clear record of factor transformations
7. **Use fct_relevel() for custom order** - More maintainable than numeric levels
8. **Consider ordered factors** - For ordinal data in modeling

---

## Common Pitfalls

1. **Forgetting to drop levels after filtering** - Old levels persist
2. **Not handling NA** - NA values can cause plotting issues
3. **Alphabetical ordering in plots** - Use fct_reorder() or fct_infreq()
4. **Combining factors with different levels** - Use fct_unify() first
5. **Overwriting original data** - Keep original factor for reference
6. **Not documenting recoding** - Hard to reproduce analysis later
7. **Using base factor() instead of as_factor()** - Order may not be preserved

---

## Quick Reference Card

| Task | Function | Example |
|------|----------|---------|
| Count levels | `fct_count()` | `fct_count(f)` |
| Reorder by value | `fct_reorder()` | `fct_reorder(f, x)` |
| Reorder by frequency | `fct_infreq()` | `fct_infreq(f)` |
| Order of appearance | `fct_inorder()` | `fct_inorder(f)` |
| Reverse order | `fct_rev()` | `fct_rev(f)` |
| Manual order | `fct_relevel()` | `fct_relevel(f, "a", "b")` |
| Rename levels | `fct_recode()` | `fct_recode(f, new = "old")` |
| Collapse levels | `fct_collapse()` | `fct_collapse(f, g = c("a","b"))` |
| Lump rare | `fct_lump()` | `fct_lump(f, n = 5)` |
| Other categories | `fct_other()` | `fct_other(f, keep = c("a"))` |
| Explicit NA | `fct_explicit_na()` | `fct_explicit_na(f)` |
| Drop unused | `fct_drop()` | `fct_drop(f)` |
| Concatenate | `fct_c()` | `fct_c(f1, f2)` |
| Cross product | `fct_cross()` | `fct_cross(f1, f2)` |
| Shift levels | `fct_shift()` | `fct_shift(f, n = 1)` |
