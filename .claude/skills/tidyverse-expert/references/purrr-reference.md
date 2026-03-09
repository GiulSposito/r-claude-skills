# purrr Reference Guide

## Overview

purrr enhances R's functional programming toolkit with a consistent, type-stable set of tools for working with functions and vectors. It provides:
- Map family for iteration
- Error handling wrappers
- Predicates for filtering and testing
- List manipulation utilities
- Function composition tools

**Core Philosophy:**
- Type-stable outputs (know what you'll get)
- Consistent function signatures
- Integration with pipes
- Support for anonymous functions

---

## Map Functions

### map() - Apply Function to Each Element

The fundamental iteration function that always returns a list.

```r
# Basic map
x <- list(1, 2, 3)
map(x, ~ .x * 2)
# Returns: list(2, 4, 6)

# With named list
x <- list(a = 1, b = 2, c = 3)
map(x, ~ .x * 2)
# Returns: list(a = 2, b = 4, c = 6)

# Map over data frame columns
mtcars |>
  select(mpg, hp, wt) |>
  map(mean)

# Extract elements
people <- list(
  list(name = "Alice", age = 30),
  list(name = "Bob", age = 25)
)

map(people, "name")
# Returns: list("Alice", "Bob")

# Extract nested elements
map(people, list("address", "city"))

# With position
map(people, 1)  # First element of each

# Anonymous function variations
map(x, function(x) x * 2)  # Traditional
map(x, ~ .x * 2)           # Formula (preferred)
map(x, \(x) x * 2)         # R 4.1+ lambda
```

---

### Type-Specific Map Variants

Return specific types instead of lists.

```r
# map_dbl - Returns numeric vector
x <- list(1, 2, 3)
map_dbl(x, ~ .x * 2)
# Returns: c(2, 4, 6)

# map_chr - Returns character vector
map_chr(people, "name")
# Returns: c("Alice", "Bob")

# map_int - Returns integer vector
map_int(list(1, 2, 3), ~ as.integer(.x))
# Returns: c(1L, 2L, 3L)

# map_lgl - Returns logical vector
map_lgl(list(1, NA, 3), is.na)
# Returns: c(FALSE, TRUE, FALSE)

# map() with list_rbind() - Returns data frame (row-bind)
map(1:3, ~ tibble(x = .x, y = .x * 2)) |> list_rbind()
# Returns: tibble with 3 rows

# map() with list_cbind() - Returns data frame (column-bind)
map(1:3, ~ tibble(!!paste0("col", .x) := .x)) |> list_cbind()
# Returns: tibble with 3 columns

# Type safety - error if wrong type
map_dbl(list(1, "a", 3), ~ .x)
# Error: Can't coerce element 2 from string to double
```

**When to Use Each:**
- `map()` - When you need a list or mixed types
- `map_dbl()` - Numeric calculations, summarizing
- `map_chr()` - Text extraction, formatting
- `map_int()` - Counting, discrete values
- `map_lgl()` - Tests, boolean operations
- `map() |> list_rbind()` - Combining data frames vertically
- `map() |> list_cbind()` - Combining data frames horizontally

---

### map2() - Iterate Over Two Inputs

```r
# Basic map2
x <- list(1, 2, 3)
y <- list(10, 20, 30)

map2(x, y, ~ .x + .y)
# Returns: list(11, 22, 33)

# Different lengths (recycling)
map2(1:3, 100, ~ .x + .y)
# Returns: list(101, 102, 103)

# Type-specific variants
map2_dbl(x, y, ~ .x + .y)
# Returns: c(11, 22, 33)

map2_chr(x, y, ~ paste(.x, "plus", .y))
# Returns: c("1 plus 10", "2 plus 20", "3 plus 30")

# With data frames
params <- tibble(
  mean = c(0, 5, 10),
  sd = c(1, 2, 3)
)

params |>
  mutate(
    samples = map2(mean, sd, ~ rnorm(10, .x, .y))
  )

# Practical: multiple file reads
files <- c("data1.csv", "data2.csv")
skip_rows <- c(1, 2)

map2(files, skip_rows, ~ read_csv(.x, skip = .y))
```

---

### pmap() - Iterate Over Multiple Inputs

```r
# pmap with list of arguments
args <- list(
  x = 1:3,
  y = 10:12,
  z = 100:102
)

pmap(args, function(x, y, z) x + y + z)
# Returns: list(111, 122, 133)

# With formula (named arguments)
pmap(args, ~ ..1 + ..2 + ..3)

# Type-specific variants
pmap_dbl(args, ~ ..1 + ..2 + ..3)
# Returns: c(111, 122, 133)

# With data frame (column names = argument names)
params <- tibble(
  n = c(5, 10, 15),
  mean = c(0, 5, 10),
  sd = c(1, 2, 3)
)

params |>
  mutate(
    samples = pmap(list(n, mean, sd), rnorm)
  )

# Named arguments (more readable)
pmap(params, ~ rnorm(n = ..1, mean = ..2, sd = ..3))

# Real example: multiple API calls
api_params <- tibble(
  endpoint = c("/users", "/posts", "/comments"),
  method = c("GET", "GET", "POST"),
  body = list(NULL, NULL, list(text = "Hello"))
)

pmap(api_params, make_api_call)
```

---

### imap() - Iterate with Index/Name

```r
# imap with vector (index as second argument)
x <- c(10, 20, 30)
imap(x, ~ paste0("Element ", .y, " is ", .x))
# Returns: list("Element 1 is 10", "Element 2 is 20", "Element 3 is 30")

# With named vector/list
x <- c(a = 10, b = 20, c = 30)
imap(x, ~ paste0(.y, " = ", .x))
# Returns: list("a = 10", "b = 20", "c = 30")

# Type-specific variants
imap_chr(x, ~ paste0(.y, ": ", .x))
# Returns: c("a: 10", "b: 20", "c: 30")

# Practical: naming list elements
results <- list(100, 200, 300)
imap(results, ~ set_names(.x, paste0("result_", .y)))

# With data frames
iris |>
  select(where(is.numeric)) |>
  imap(~ tibble(
    column = .y,
    mean = mean(.x),
    sd = sd(.x)
  )) |>
  list_rbind()
```

---

### walk() - Iterate for Side Effects

Like map, but used when you want the side effects, not the return value.

```r
# walk returns input invisibly
x <- 1:3
walk(x, print)  # Prints 1, 2, 3
# Returns: x (invisibly)

# Save multiple plots
plots <- list(plot1, plot2, plot3)
filenames <- c("p1.png", "p2.png", "p3.png")

walk2(plots, filenames, ggsave)

# Print with formatting
walk(mtcars$mpg[1:5], ~ cat("MPG:", .x, "\n"))

# Multiple files and operations
walk2(
  c("data1.csv", "data2.csv"),
  c("cleaned1.csv", "cleaned2.csv"),
  ~ read_csv(.x) |> clean_data() |> write_csv(.y)
)

# pwalk for multiple arguments
params <- list(
  text = c("Hello", "World"),
  file = c("out1.txt", "out2.txt"),
  append = c(FALSE, TRUE)
)

pwalk(params, write_lines)
```

---

## Error Handling

### safely() - Capture Errors

Returns a list with `result` and `error` components.

```r
# Basic safely
safe_log <- safely(log)

safe_log(10)
# Returns: list(result = 2.302585, error = NULL)

safe_log("a")
# Returns: list(result = NULL, error = <error>)

# With map
x <- list(10, "a", 100)
results <- map(x, safely(log))

# Extract successful results
map(results, "result") |> compact()

# Extract errors
map(results, "error") |> compact()

# Check which failed
map_lgl(results, ~ is.null(.x$error))

# Practical: reading multiple files
files <- c("data1.csv", "missing.csv", "data3.csv")

results <- map(files, safely(read_csv))

# Get successful reads
successes <- results |>
  keep(~ is.null(.x$error)) |>
  map("result")

# Get failures
failures <- results |>
  keep(~ !is.null(.x$error)) |>
  map("error")

# With otherwise (default value on error)
safe_log <- safely(log, otherwise = NA)
map_dbl(x, ~ safe_log(.x)$result)
```

---

### possibly() - Provide Default

Like safely, but simpler - returns result or default value.

```r
# Basic possibly
poss_log <- possibly(log, otherwise = NA)

poss_log(10)
# Returns: 2.302585

poss_log("a")
# Returns: NA

# With map (type-stable!)
x <- list(10, "a", 100)
map_dbl(x, possibly(log, otherwise = NA))
# Returns: c(2.302585, NA, 4.605170)

# Multiple defaults
poss_mean <- possibly(mean, otherwise = 0)
map_dbl(list(1:5, "a", 10:15), poss_mean)

# Practical: API calls with fallback
poss_api_call <- possibly(api_call, otherwise = list(status = "error"))

urls |>
  map(poss_api_call) |>
  map_chr("status")
```

---

### quietly() - Capture Messages/Warnings

Returns list with `result`, `output`, `warnings`, and `messages`.

```r
# Basic quietly
quiet_sqrt <- quietly(sqrt)

quiet_sqrt(4)
# Returns: list(result = 2, output = "", warnings = character(0), messages = character(0))

quiet_sqrt(-1)
# Returns: list(result = NaN, output = "", warnings = "NaNs produced", messages = character(0))

# Practical: track warnings
results <- map(data_list, quietly(process_data))

# Filter to only items with warnings
results |>
  keep(~ length(.x$warnings) > 0) |>
  map("warnings")
```

---

## Predicates & Filtering

### keep() / discard() - Filter Elements

```r
# keep - keep elements where predicate is TRUE
x <- list(1, "a", 2, "b", 3)

keep(x, is.numeric)
# Returns: list(1, 2, 3)

# discard - remove elements where predicate is TRUE
discard(x, is.numeric)
# Returns: list("a", "b")

# With formula
x <- list(-1, 5, -3, 10)
keep(x, ~ .x > 0)
# Returns: list(5, 10)

# Named lists
data <- list(
  good = 10,
  bad = NULL,
  ok = 20,
  missing = NA
)

keep(data, ~ !is.null(.x))
compact(data)  # Shortcut for keep(!is.null)

# With data frames
models <- list(
  model1 = lm(mpg ~ wt, mtcars),
  model2 = lm(mpg ~ hp, mtcars),
  model3 = lm(mpg ~ wt + hp, mtcars)
)

# Keep models with R² > 0.7
keep(models, ~ summary(.x)$r.squared > 0.7)
```

---

### detect() / detect_index() - Find First Match

```r
# detect - return first matching element
x <- list(1, "a", 2, "b", 3)

detect(x, is.numeric)
# Returns: 1

detect(x, is.character)
# Returns: "a"

# detect_index - return position
detect_index(x, is.character)
# Returns: 2

# With formula
x <- list(-1, 5, -3, 10)
detect(x, ~ .x > 0)
# Returns: 5

# From the right
x <- c(1, 2, 3, 4, 5)
detect(x, ~ .x > 3, .dir = "backward")
# Returns: 5

# With default
detect(x, ~ .x > 100, .default = NA)
# Returns: NA
```

---

### every() / some() / none() - Test All/Any/None

```r
# every - all elements satisfy predicate
x <- list(1, 2, 3)
every(x, is.numeric)
# Returns: TRUE

every(x, ~ .x > 0)
# Returns: TRUE

every(x, ~ .x > 2)
# Returns: FALSE

# some - at least one element satisfies predicate
some(x, ~ .x > 2)
# Returns: TRUE

# none - no elements satisfy predicate
none(x, ~ .x > 10)
# Returns: TRUE

# Practical: validate data
data_list <- list(
  tibble(x = 1:5, y = 6:10),
  tibble(x = 1:5, y = 6:10)
)

every(data_list, ~ nrow(.x) == 5)  # All have 5 rows?
some(data_list, ~ any(is.na(.x)))  # Any have NAs?
```

---

## List Manipulation

### pluck() / chuck() - Extract Elements

```r
# pluck - safely extract nested elements
x <- list(
  a = list(b = list(c = 1, d = 2)),
  e = 3
)

pluck(x, "a", "b", "c")
# Returns: 1

# By position
pluck(x, 1, 1, 1)
# Returns: 1

# With default
pluck(x, "a", "b", "z", .default = NA)
# Returns: NA

# chuck - like pluck but errors on missing
chuck(x, "a", "b", "c")
# Returns: 1

chuck(x, "a", "b", "z")
# Error: Index 3 doesn't exist

# Practical: extract from nested JSON
api_response <- list(
  data = list(
    user = list(name = "Alice", id = 123),
    posts = list(list(id = 1), list(id = 2))
  )
)

pluck(api_response, "data", "user", "name")
# Returns: "Alice"

pluck(api_response, "data", "posts", 1, "id")
# Returns: 1
```

---

### modify() - Modify Elements

```r
# modify - like map but returns same type
x <- list(a = 1, b = 2, c = 3)
modify(x, ~ .x * 2)
# Returns: list(a = 2, b = 4, c = 6)

# With vector
x <- c(1, 2, 3)
modify(x, ~ .x * 2)
# Returns: c(2, 4, 6)

# modify_if - conditionally modify
x <- list(a = 1, b = "text", c = 3)
modify_if(x, is.numeric, ~ .x * 2)
# Returns: list(a = 2, b = "text", c = 6)

# modify_at - modify specific elements
x <- list(a = 1, b = 2, c = 3)
modify_at(x, c("a", "c"), ~ .x * 2)
# Returns: list(a = 2, b = 2, c = 6)

# modify_depth - modify at specific depth
x <- list(
  list(a = 1, b = 2),
  list(a = 3, b = 4)
)
modify_depth(x, 2, ~ .x * 2)
# Returns: all numeric elements doubled
```

---

### list_rbind() / list_cbind() - Combine Lists

```r
# list_rbind - row bind list of data frames
dfs <- list(
  tibble(x = 1:2, y = 3:4),
  tibble(x = 5:6, y = 7:8)
)

list_rbind(dfs)
# Returns: tibble with 4 rows

# With names (creates .id column)
dfs <- list(
  batch1 = tibble(x = 1:2),
  batch2 = tibble(x = 3:4)
)

list_rbind(dfs, names_to = "batch")

# list_cbind - column bind
dfs <- list(
  tibble(x = 1:3),
  tibble(y = 4:6)
)

list_cbind(dfs)
# Returns: tibble with 3 rows, 2 columns
```

---

### flatten() - Remove One Level of Nesting

```r
# flatten - remove one level
x <- list(list(1, 2), list(3, 4))
flatten(x)
# Returns: list(1, 2, 3, 4)

# Type-specific variants
flatten_dbl(list(c(1, 2), c(3, 4)))
# Returns: c(1, 2, 3, 4)

flatten_chr(list(c("a", "b"), c("c", "d")))
# Returns: c("a", "b", "c", "d")

# Practical: flatten nested results
results <- map(1:3, ~ list(value = .x, squared = .x^2))
flatten(results)
```

---

### transpose() - Transpose List

```r
# Transpose list of lists
x <- list(
  list(a = 1, b = "x"),
  list(a = 2, b = "y")
)

transpose(x)
# Returns: list(a = list(1, 2), b = list("x", "y"))

# Practical: reorganize data
people <- list(
  list(name = "Alice", age = 30, city = "NYC"),
  list(name = "Bob", age = 25, city = "LA")
)

transpose(people)
# Returns: list(name = list("Alice", "Bob"), age = list(30, 25), city = list("NYC", "LA"))
```

---

## Reducing and Accumulating

### reduce() - Combine Elements Sequentially

```r
# Basic reduce
reduce(1:4, `+`)
# Returns: 10 (1+2+3+4)

# With formula
reduce(1:4, ~ .x + .y)
# Returns: 10

# With initial value
reduce(1:4, `+`, .init = 100)
# Returns: 110

# Left vs right
reduce(list(1, 2, 3), `-`)
# Returns: -4 ((1-2)-3)

reduce(list(1, 2, 3), `-`, .dir = "backward")
# Returns: 2 (1-(2-3))

# Practical: multiple joins
datasets <- list(df1, df2, df3, df4)
reduce(datasets, left_join, by = "id")

# Combine strings
words <- c("Hello", "world", "from", "R")
reduce(words, paste)
# Returns: "Hello world from R"

# Intersection of sets
sets <- list(1:5, 2:6, 3:7)
reduce(sets, intersect)
# Returns: c(3, 4, 5)
```

---

### accumulate() - Keep Intermediate Results

```r
# accumulate - like reduce but keeps all steps
accumulate(1:4, `+`)
# Returns: c(1, 3, 6, 10)

# With formula
accumulate(1:4, ~ .x + .y)
# Returns: c(1, 3, 6, 10)

# With initial value
accumulate(1:4, `+`, .init = 100)
# Returns: c(100, 101, 103, 106, 110)

# Practical: running totals
sales <- c(100, 150, 200, 175)
accumulate(sales, `+`)
# Returns: c(100, 250, 450, 625)

# Compound interest
rates <- c(1.05, 1.03, 1.07, 1.04)
accumulate(rates, `*`, .init = 1000)
# Returns: c(1000, 1050, 1081.5, 1157.205, 1203.493)
```

---

## Function Composition

### compose() - Combine Functions

```r
# compose - create pipeline of functions (right to left)
f <- compose(sqrt, sum, ~ .x^2)
f(1:3)
# Returns: sqrt(sum((1:3)^2)) = 3.741657

# Practical: data cleaning pipeline
clean_name <- compose(
  str_to_lower,
  str_trim,
  ~ str_replace_all(.x, "[^a-z0-9]", "_")
)

clean_name("  Hello World! ")
# Returns: "hello_world_"
```

---

### partial() - Partial Function Application

```r
# partial - fix some arguments
mean_na_rm <- partial(mean, na.rm = TRUE)

mean_na_rm(c(1, 2, NA, 4))
# Returns: 2.333333

# Practical: custom read function
read_skip2 <- partial(read_csv, skip = 2, col_types = cols())

files |> map(read_skip2)
```

---

## Advanced Patterns

### Nested Iteration

```r
# Map over rows of a data frame
params <- tibble(
  n = c(5, 10, 15),
  mean = c(0, 5, 10),
  sd = c(1, 2, 3)
)

params |>
  mutate(
    samples = pmap(list(n, mean, sd), rnorm)
  )

# Nested maps
outer <- 1:3
inner <- 1:2

map(outer, ~ map(inner, function(y) .x * y))
```

### Error Handling Workflow

```r
# Complete error handling
results <- map(data_files, safely(read_csv))

# Separate successes and failures
successes <- results |>
  keep(~ is.null(.x$error)) |>
  map("result")

failures <- results |>
  keep(~ !is.null(.x$error)) |>
  imap(~ list(
    file = data_files[.y],
    error = .x$error$message
  ))

# Report
cat("Loaded:", length(successes), "files\n")
cat("Failed:", length(failures), "files\n")
walk(failures, ~ cat("  -", .x$file, ":", .x$error, "\n"))
```

### Working with Models

```r
# Fit models to groups
models <- mtcars |>
  group_by(cyl) |>
  nest() |>
  mutate(
    model = map(data, ~ lm(mpg ~ wt, data = .x)),
    rsq = map_dbl(model, ~ summary(.x)$r.squared),
    predictions = map2(model, data, predict)
  )

# Extract coefficients
models |>
  mutate(coefs = map(model, broom::tidy)) |>
  unnest(coefs)
```

---

## Best Practices

1. **Use type-specific map variants** - `map_dbl()` instead of `map() |> as.numeric()`
2. **Prefer formula syntax** - `~ .x + 1` is cleaner than `function(x) x + 1`
3. **Handle errors explicitly** - Use `safely()` or `possibly()` for robustness
4. **Use `walk()` for side effects** - Makes intent clear
5. **Keep predicates simple** - Complex logic in separate function
6. **Name function arguments** - In `pmap()`, use named lists for clarity
7. **Use `compact()` to remove NULLs** - Common after filtering
8. **Combine with dplyr** - `mutate()` + `map()` is powerful pattern

---

## Common Pitfalls

1. **Mixing map and map_*()** - Can cause type errors
2. **Forgetting .x in formulas** - Must use `.x` explicitly
3. **Not handling errors** - Unhandled errors stop entire iteration
4. **Wrong reduce direction** - Check if operation is commutative
5. **Deep nesting** - Keep structure simple; use helper functions
6. **Overusing purrr** - Sometimes vectorized base R is simpler

---

## Quick Reference Card

| Task | Function | Example |
|------|----------|---------|
| Apply function | `map()` | `map(x, log)` |
| Return numeric | `map_dbl()` | `map_dbl(x, mean)` |
| Return character | `map_chr()` | `map_chr(x, "name")` |
| Row-bind data frames | `map() |> list_rbind()` | `map(x, f) |> list_rbind()` |
| Column-bind data frames | `map() |> list_cbind()` | `map(x, f) |> list_cbind()` |
| Two inputs | `map2()` | `map2(x, y, `+`)` |
| Many inputs | `pmap()` | `pmap(list(x, y, z), sum)` |
| With index/name | `imap()` | `imap(x, paste)` |
| Side effects | `walk()` | `walk(x, print)` |
| Handle errors | `safely()` | `map(x, safely(log))` |
| Default on error | `possibly()` | `map_dbl(x, possibly(log, NA))` |
| Keep TRUE | `keep()` | `keep(x, is.numeric)` |
| Remove TRUE | `discard()` | `discard(x, is.null)` |
| Find first | `detect()` | `detect(x, is.character)` |
| Test all | `every()` | `every(x, is.numeric)` |
| Test any | `some()` | `some(x, is.na)` |
| Extract nested | `pluck()` | `pluck(x, "a", "b")` |
| Modify | `modify()` | `modify(x, log)` |
| Combine sequentially | `reduce()` | `reduce(x, `+`)` |
| Keep intermediates | `accumulate()` | `accumulate(x, `+`)` |
| Flatten one level | `flatten()` | `flatten(x)` |
| Transpose | `transpose()` | `transpose(x)` |
