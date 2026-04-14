# dbplyr Translation & Remote Data Manipulation

## 1. Overview

### What is dbplyr

**dbplyr** is a database backend for dplyr that translates R code (dplyr verbs) into SQL queries. When used with sparklyr, it enables data manipulation on Spark DataFrames using familiar dplyr syntax without bringing data into R memory.

**Key Concept**: dbplyr provides lazy evaluation - operations are recorded but not executed until explicitly requested (via `collect()` or `compute()`).

### How sparklyr Uses dbplyr

sparklyr integrates with dbplyr to provide a seamless tidyverse experience for Spark data:

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(method = "databricks")
spark_df <- spark_read_table(sc, "my_table")

# dplyr operations are translated to Spark SQL
result <- spark_df |>
  filter(age > 25) |>
  group_by(department) |>
  summarize(avg_salary = mean(salary))

# No computation yet - it's lazy!
# Use show_query() to see the SQL
result |> show_query()

# Execute and bring to R
local_result <- result |> collect()
```

### Lazy Evaluation Model

**Advantages**:
- Operations are optimized before execution
- No unnecessary data transfer
- Spark's query optimizer can rewrite queries for efficiency
- Multiple operations are combined into single queries

**Key Functions**:
- `show_query()` - View the generated SQL without executing
- `explain()` - Show the Spark execution plan
- `compute()` - Execute query and cache results in Spark
- `collect()` - Execute query and bring results to R memory

### When to Use dbplyr vs Native Spark API

**Use dbplyr when**:
- Familiar with tidyverse/dplyr syntax
- Performing standard data manipulation (filter, select, mutate, group_by, summarize)
- Want readable, maintainable code
- Need quick prototyping

**Use native Spark API (sdf_*, spark_*) when**:
- Need Spark-specific operations (partitioning, broadcasting)
- Using ML pipelines
- Require operations not supported by dbplyr translation
- Performance-critical code requiring fine-tuned control

## 2. Core dplyr Verbs with Spark

### Single-Table Verbs

#### filter() - Row Selection

**Translation**: Converts to SQL `WHERE` clause

```r
# R code
spark_df |>
  filter(age > 30, department == "Engineering")

# Generated SQL
SELECT *
FROM table
WHERE (age > 30.0 AND department = 'Engineering')
```

**Caveats**:
- Logical operators: `&` (AND), `|` (OR), `!` (NOT) translate correctly
- `%in%` operator translates to SQL `IN`
- Complex R expressions may not translate; use simple comparisons

#### select() - Column Selection

**Translation**: Converts to SQL `SELECT` clause

```r
# R code
spark_df |>
  select(name, age, salary)

# Renaming
spark_df |>
  select(employee_name = name, years = age)

# Helper functions
spark_df |>
  select(starts_with("dept_"))
```

**Supported tidyselect helpers**:
- `starts_with()`, `ends_with()`, `contains()`
- `matches()` (regex)
- `everything()`, `last_col()`
- `where()` (select by type)

#### mutate() - Create/Modify Columns

**Translation**: Converts to SQL computed columns or `CASE` statements

```r
# R code
spark_df |>
  mutate(
    age_group = case_when(
      age < 30 ~ "Young",
      age < 50 ~ "Middle",
      TRUE ~ "Senior"
    ),
    salary_k = salary / 1000
  )

# Generated SQL uses CASE WHEN
```

**Supported operations**:
- Arithmetic: `+`, `-`, `*`, `/`, `%%`, `^`
- Comparisons: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Logical: `&`, `|`, `!`, `xor()`
- String: `str_*` functions (see Function Translation)
- Date: `lubridate` functions (see Function Translation)
- Conditional: `if_else()`, `case_when()`, `coalesce()`

#### summarize() - Aggregation

**Translation**: Converts to SQL aggregate functions with `GROUP BY`

```r
# R code
spark_df |>
  group_by(department) |>
  summarize(
    count = n(),
    avg_salary = mean(salary),
    max_age = max(age),
    sd_salary = sd(salary)
  )

# Generated SQL
SELECT department,
       COUNT(*) AS count,
       AVG(salary) AS avg_salary,
       MAX(age) AS max_age,
       STDDEV_SAMP(salary) AS sd_salary
FROM table
GROUP BY department
```

**Supported aggregate functions**:
- `n()` - COUNT(*)
- `n_distinct()` - COUNT(DISTINCT)
- `mean()`, `sum()`, `min()`, `max()`
- `sd()`, `var()` - Standard deviation and variance
- `first()`, `last()`

#### arrange() - Sorting

**Translation**: Converts to SQL `ORDER BY`

```r
# R code
spark_df |>
  arrange(desc(salary), name)

# Generated SQL
SELECT *
FROM table
ORDER BY salary DESC, name
```

**Note**: `arrange()` on large datasets can be expensive in Spark due to shuffling.

#### distinct() - Unique Rows

**Translation**: Converts to SQL `DISTINCT`

```r
# All columns
spark_df |> distinct()

# Specific columns
spark_df |> distinct(department, location)
```

#### slice() - Row Selection by Position

**Limited Support**: `slice()` has limited translation because row position is not a natural concept in distributed systems.

**Alternatives**:
- Use `filter()` with conditions instead
- Use `head()` / `tail()` for top/bottom N (translates to `LIMIT`)

```r
# Works: head() translates to LIMIT
spark_df |> head(10)

# Limited: slice() may not work as expected
```

### Multi-Table Verbs (Joins)

#### left_join(), inner_join(), full_join()

**Translation**: Converts to SQL `JOIN` operations

```r
# R code
employees |>
  left_join(departments, by = "dept_id")

# Modern join_by() syntax (dbplyr 2.0+)
employees |>
  left_join(departments, join_by(dept_id == id))

# Multiple keys
employees |>
  inner_join(assignments, by = c("emp_id", "project_id"))
```

**Join Types**:
- `left_join()` → `LEFT JOIN`
- `right_join()` → `RIGHT JOIN`
- `inner_join()` → `INNER JOIN`
- `full_join()` → `FULL OUTER JOIN`
- `semi_join()` → `LEFT SEMI JOIN` (Spark-optimized)
- `anti_join()` → `LEFT ANTI JOIN` (Spark-optimized)

#### Join Optimization with Spark

**Broadcast Joins**:
Small tables can be broadcast to all worker nodes for efficient joins:

```r
# Use sdf_broadcast() to hint broadcast join
large_table |>
  left_join(sdf_broadcast(small_lookup_table), by = "key")
```

**Performance Tips**:
- Broadcast small dimension tables (<100MB)
- Ensure join keys are partitioned appropriately
- Use `semi_join()` and `anti_join()` instead of filtering on join results

## 3. Function Translation

### String Functions (stringr)

**Commonly Translated Functions**:

| R Function | Spark SQL Equivalent | Example |
|------------|---------------------|---------|
| `str_to_upper()` | `UPPER()` | `mutate(name_upper = str_to_upper(name))` |
| `str_to_lower()` | `LOWER()` | `mutate(name_lower = str_to_lower(name))` |
| `str_length()` | `LENGTH()` | `mutate(name_len = str_length(name))` |
| `str_trim()` | `TRIM()` | `mutate(name_clean = str_trim(name))` |
| `str_sub()` | `SUBSTRING()` | `mutate(initial = str_sub(name, 1, 1))` |
| `str_detect()` | `LIKE` or `RLIKE` | `filter(str_detect(name, "^A"))` |
| `str_replace()` | `REGEXP_REPLACE()` | `mutate(name2 = str_replace(name, "old", "new"))` |
| `str_c()` | `CONCAT()` | `mutate(full = str_c(first, last, sep = " "))` |

**Regex Support**:
- `str_detect(x, pattern)` - Pattern matching
- `str_extract()` - Extract first match
- `str_replace()` / `str_replace_all()` - Replace patterns

### Date/Time Functions (lubridate)

**Commonly Translated Functions**:

| R Function | Spark SQL Equivalent | Example |
|------------|---------------------|---------|
| `year()` | `YEAR()` | `mutate(yr = year(date_col))` |
| `month()` | `MONTH()` | `mutate(mo = month(date_col))` |
| `day()` | `DAY()` | `mutate(d = day(date_col))` |
| `hour()` | `HOUR()` | `mutate(h = hour(datetime_col))` |
| `minute()` | `MINUTE()` | `mutate(m = minute(datetime_col))` |
| `second()` | `SECOND()` | `mutate(s = second(datetime_col))` |
| `wday()` | `DAYOFWEEK()` | `mutate(dow = wday(date_col))` |
| `floor_date()` | `DATE_TRUNC()` | `mutate(month_start = floor_date(date, "month"))` |
| `as_date()` | `TO_DATE()` | `mutate(d = as_date(timestamp_col))` |
| `now()` | `CURRENT_TIMESTAMP()` | `mutate(current = now())` |
| `today()` | `CURRENT_DATE()` | `mutate(today = today())` |

**Date Arithmetic**:
```r
# Add days
spark_df |>
  mutate(future_date = date_col + days(7))

# Difference between dates
spark_df |>
  mutate(days_diff = as.numeric(date2 - date1))
```

### Mathematical Operations

**Standard Math Functions**:
- `abs()`, `sqrt()`, `log()`, `log10()`, `exp()`
- `round()`, `floor()`, `ceiling()`
- `sin()`, `cos()`, `tan()`

```r
spark_df |>
  mutate(
    abs_value = abs(x),
    rounded = round(value, 2),
    log_value = log(amount)
  )
```

### Conditional Logic

**if_else() and case_when()**:

```r
# if_else()
spark_df |>
  mutate(status = if_else(age >= 18, "Adult", "Minor"))

# case_when()
spark_df |>
  mutate(
    category = case_when(
      score >= 90 ~ "A",
      score >= 80 ~ "B",
      score >= 70 ~ "C",
      TRUE ~ "F"
    )
  )
```

**coalesce() - Handle NULLs**:
```r
spark_df |>
  mutate(filled = coalesce(col1, col2, col3, 0))
```

### Window Functions

**Supported Window Operations**:

```r
# Row number
spark_df |>
  group_by(department) |>
  mutate(row_num = row_number())

# Rank
spark_df |>
  group_by(department) |>
  mutate(salary_rank = min_rank(desc(salary)))

# Lead/Lag
spark_df |>
  arrange(date) |>
  mutate(
    prev_value = lag(value, 1),
    next_value = lead(value, 1)
  )

# Cumulative sum
spark_df |>
  arrange(date) |>
  mutate(cumulative = cumsum(amount))
```

**Window Frame Specification**:
```r
# Moving average
spark_df |>
  arrange(date) |>
  mutate(ma_7day = mean(value, na.rm = TRUE)) |>
  dbplyr::window_frame(-6, 0)
```

### Aggregate Functions

| R Function | Spark SQL | Notes |
|------------|-----------|-------|
| `n()` | `COUNT(*)` | Count rows |
| `n_distinct()` | `COUNT(DISTINCT)` | Count unique |
| `sum()` | `SUM()` | Sum |
| `mean()` | `AVG()` | Average |
| `median()` | `PERCENTILE_APPROX(col, 0.5)` | Approximate |
| `min()` | `MIN()` | Minimum |
| `max()` | `MAX()` | Maximum |
| `sd()` | `STDDEV_SAMP()` | Sample std dev |
| `var()` | `VAR_SAMP()` | Sample variance |
| `first()` | `FIRST()` | First value |
| `last()` | `LAST()` | Last value |

## 4. Lazy Evaluation

### The Lazy Query Model

**Concept**: Operations build a query plan without executing. Execution happens only when results are needed.

```r
# These operations don't execute immediately
query <- spark_df |>
  filter(age > 30) |>
  group_by(department) |>
  summarize(avg_salary = mean(salary)) |>
  filter(avg_salary > 50000) |>
  arrange(desc(avg_salary))

# Still no execution - just a query plan

# Execution triggered by:
result <- query |> collect()        # Bring to R
query |> compute("temp_table")      # Materialize in Spark
query |> show_query()               # Show SQL (doesn't execute)
query |> head(10) |> collect()     # Execute with LIMIT
```

### show_query() - Inspecting Generated SQL

**Purpose**: See the SQL that dbplyr generates without executing it

```r
spark_df |>
  filter(age > 30) |>
  select(name, department, salary) |>
  show_query()

# Output:
# <SQL>
# SELECT name, department, salary
# FROM table
# WHERE age > 30.0
```

**Use Cases**:
- Debugging translation issues
- Learning SQL from dplyr code
- Optimizing queries
- Verifying correct translation

### explain() - Query Plans

**Purpose**: Show Spark's physical execution plan

```r
spark_df |>
  filter(age > 30) |>
  group_by(department) |>
  summarize(count = n()) |>
  explain()

# Shows:
# - Physical plan
# - Logical plan
# - Optimizations applied
# - Partition pruning
# - Broadcast joins
```

### compute() - Materializing Intermediate Results

**Purpose**: Execute query and cache results in Spark (not in R)

```r
# Expensive transformation
intermediate <- spark_df |>
  filter(status == "active") |>
  mutate(complex_calc = expensive_operation(x, y, z)) |>
  compute("intermediate_table")

# Reuse cached results
result1 <- intermediate |> filter(region == "US") |> collect()
result2 <- intermediate |> filter(region == "EU") |> collect()
```

**When to use compute()**:
- Reusing intermediate results multiple times
- Breaking complex queries into steps
- Checkpointing long transformation chains
- Debugging query performance

**Syntax**:
```r
# Named table (persists in Spark catalog)
df |> compute("my_table")

# Temporary table (session-scoped)
df |> compute()
```

### collect() - Bringing Data to R

**Purpose**: Execute query and transfer results to R memory

```r
# Execute and collect
local_df <- spark_df |>
  filter(age > 30) |>
  select(name, salary) |>
  collect()

# Now it's a regular R data.frame/tibble
class(local_df)  # [1] "tbl_df" "tbl" "data.frame"
```

**⚠️ Warning**: `collect()` brings ALL rows into R memory. Use with caution on large datasets.

**Best Practices**:
```r
# BAD: Collect entire dataset
all_data <- spark_df |> collect()  # May crash R!

# GOOD: Filter first
filtered <- spark_df |>
  filter(date == "2024-01-01") |>
  collect()

# GOOD: Aggregate first
summary <- spark_df |>
  group_by(department) |>
  summarize(count = n(), avg_salary = mean(salary)) |>
  collect()

# GOOD: Sample for exploration
sample <- spark_df |>
  sdf_sample(0.01) |>
  collect()
```

## 5. SQL Generation

### How dplyr Code Becomes Spark SQL

dbplyr translates dplyr operations into SQL AST (Abstract Syntax Tree), then renders to SQL dialect (Spark SQL).

**Translation Pipeline**:
1. dplyr verb → lazy_query object
2. Multiple operations → combined query tree
3. Query optimization
4. SQL generation for Spark dialect
5. Execution in Spark

**Example Translation**:
```r
# R code
spark_df |>
  filter(year == 2024) |>
  group_by(product) |>
  summarize(total = sum(revenue)) |>
  filter(total > 1000000) |>
  arrange(desc(total))

# Generated SQL
SELECT product, SUM(revenue) AS total
FROM table
WHERE year = 2024
GROUP BY product
HAVING SUM(revenue) > 1000000.0
ORDER BY total DESC
```

Note: `filter()` after `group_by()` becomes `HAVING` clause.

### Custom SQL with sql()

**Use Case**: When you need to write SQL directly

```r
# Use SQL string directly
library(DBI)

result <- dbGetQuery(sc, "
  SELECT department, COUNT(*) as count
  FROM employees
  WHERE hire_date >= '2020-01-01'
  GROUP BY department
")

# Or use tbl() with SQL
custom_query <- tbl(sc, sql("
  SELECT * FROM table
  WHERE complex_condition
"))

# Continue with dplyr operations
custom_query |>
  filter(additional_filter) |>
  collect()
```

### Mixing dplyr and Raw SQL

**Strategy 1: Start with SQL, continue with dplyr**
```r
base_query <- tbl(sc, sql("
  SELECT *
  FROM complex_join_or_cte
"))

result <- base_query |>
  filter(age > 30) |>
  select(name, salary) |>
  collect()
```

**Strategy 2: Use dplyr, then SQL for complex operations**
```r
# dplyr operations
intermediate <- spark_df |>
  filter(status == "active") |>
  compute("temp_table")

# Raw SQL for complex operation
final <- dbGetQuery(sc, "
  SELECT *,
         PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)
           OVER (PARTITION BY department) as median_salary
  FROM temp_table
")
```

### sql_render() for Debugging

**Purpose**: See the SQL without executing

```r
library(dbplyr)

# Create lazy query
query <- spark_df |>
  filter(age > 30) |>
  group_by(department) |>
  summarize(avg_salary = mean(salary))

# Render to SQL
sql_render(query)
```

## 6. Limitations & Workarounds

### Operations Not Supported

#### 1. Complex R Functions in mutate()

**Problem**: Custom R functions don't translate to SQL

```r
# DOESN'T WORK
my_function <- function(x) {
  x^2 + 2*x + 1
}

spark_df |>
  mutate(result = my_function(value))  # Error!
```

**Workaround 1**: Use spark_apply()
```r
spark_df |>
  spark_apply(function(df) {
    df |> mutate(result = my_function(value))
  })
```

**Workaround 2**: Break into SQL-translatable operations
```r
spark_df |>
  mutate(result = value^2 + 2*value + 1)  # Works!
```

#### 2. Some tidyr Operations

**Limited Support**:
- `pivot_wider()` / `pivot_longer()` - Limited or no translation
- `nest()` / `unnest()` - Not supported
- `separate()` / `unite()` - Limited support

**Workarounds**:
```r
# Option 1: Use compute() + collect() for small data
small_subset <- spark_df |>
  filter(category == "A") |>
  collect() |>
  pivot_wider(names_from = key, values_from = value)

# Option 2: Use Spark SQL functions
spark_df |>
  mutate(
    col1 = expr("split(column, ',')[0]"),
    col2 = expr("split(column, ',')[1]")
  )
```

#### 3. Advanced Statistical Functions

**Not Available in SQL**:
- Complex models (`lm()`, `glm()`)
- Advanced statistics beyond basic aggregates
- Most statistical tests

**Workaround**: Sample or aggregate, then use R
```r
# Aggregate in Spark
aggregated <- spark_df |>
  group_by(group) |>
  summarize(
    n = n(),
    mean = mean(value),
    sd = sd(value)
  ) |>
  collect()

# Statistical tests in R
result <- t.test(aggregated$mean)
```

### Workarounds

#### spark_apply() for Custom R Code

**Use Case**: Apply arbitrary R functions to Spark DataFrames

```r
# Apply custom function to partitions
result <- spark_df |>
  spark_apply(function(df) {
    # Any R code here
    df |>
      mutate(
        custom = my_complex_function(x, y),
        another = some_package_function(z)
      )
  })
```

**Performance Note**: `spark_apply()` serializes data between Spark and R, which can be slow. Use only when necessary.

#### compute() + Local Processing

**Strategy**: Process most data in Spark, then small results in R

```r
# Heavy lifting in Spark
intermediate <- spark_df |>
  filter(conditions) |>
  group_by(keys) |>
  summarize(metrics) |>
  collect()  # Small result set

# Complex operations in R
final <- intermediate |>
  pivot_wider(...) |>
  mutate(complex_r_operation(...))
```

#### Using Native Spark Functions via sql()

**Use Case**: Spark has the function, but dbplyr doesn't translate it

```r
# Use expr() for Spark SQL expressions
spark_df |>
  mutate(
    percentile = expr("percentile_approx(value, 0.95)"),
    array_col = expr("array(col1, col2, col3)"),
    exploded = expr("explode(array_column)")
  )
```

## 7. Best Practices

### When to Use dplyr vs Spark Native API

**Use dplyr (via dbplyr) when**:
- ✅ Standard data manipulation (filter, select, mutate, summarize, joins)
- ✅ Code readability is important
- ✅ Prototyping and exploration
- ✅ Team is familiar with tidyverse
- ✅ Operations translate cleanly to SQL

**Use Spark native API (sdf_*, spark_*) when**:
- ✅ Need Spark-specific operations (partitioning, broadcasting)
- ✅ ML pipelines (ml_* functions)
- ✅ Complex window functions
- ✅ Performance-critical code requiring tuning
- ✅ Operations not supported by dbplyr

**Hybrid Approach** (Best of Both):
```r
# Use dplyr for clarity
filtered <- spark_df |>
  filter(year == 2024, status == "active")

# Switch to Spark API for specialized operation
partitioned <- filtered |>
  sdf_repartition(partitions = 200, partition_by = "user_id")

# Back to dplyr
result <- partitioned |>
  group_by(user_id) |>
  summarize(total = sum(amount)) |>
  collect()
```

### Performance Tips

#### 1. Filter Early and Often
```r
# GOOD: Filter before expensive operations
spark_df |>
  filter(year == 2024, status == "active") |>  # Reduce data first
  group_by(user_id) |>
  summarize(complex_aggregation)

# BAD: Filter after expensive operations
spark_df |>
  group_by(user_id) |>
  summarize(complex_aggregation) |>
  filter(year == 2024)  # Too late!
```

#### 2. Use compute() for Reused Intermediates
```r
# Expensive transformation used multiple times
base_data <- spark_df |>
  filter(complex_conditions) |>
  mutate(expensive_calculation) |>
  compute("base_data")  # Cache it!

# Reuse without recomputing
result1 <- base_data |> filter(region == "US") |> collect()
result2 <- base_data |> filter(region == "EU") |> collect()
```

#### 3. Limit Data Before collect()
```r
# GOOD: Aggregate first
summary <- spark_df |>
  group_by(department) |>
  summarize(count = n(), avg_salary = mean(salary)) |>
  collect()  # Small result

# GOOD: Sample for exploration
sample <- spark_df |>
  sdf_sample(0.01) |>
  collect()

# BAD: Collect entire table
all_data <- spark_df |> collect()  # May crash R!
```

#### 4. Optimize Joins
```r
# Broadcast small lookup tables
large_table |>
  left_join(sdf_broadcast(small_table), by = "key")

# Repartition on join keys
large_table |>
  sdf_repartition(partition_by = "join_key") |>
  inner_join(other_table, by = "join_key")
```

### Debugging Translated Queries

#### 1. Use show_query() to Inspect SQL
```r
query |> show_query()
```

#### 2. Use explain() to See Execution Plan
```r
query |> explain()
```

#### 3. Test on Small Samples
```r
# Test query logic on sample
spark_df |>
  sdf_sample(0.001) |>
  <your_query_here> |>
  collect()
```

#### 4. Break Complex Queries into Steps
```r
# Instead of one long chain
step1 <- spark_df |> filter(...) |> compute()
step2 <- step1 |> mutate(...) |> compute()
step3 <- step2 |> group_by(...) |> summarize(...) |> collect()

# Verify each step
step1 |> show_query()
step2 |> show_query()
```

### Testing Query Performance

```r
# Time query execution
system.time({
  result <- spark_df |>
    <query> |>
    collect()
})

# Check query plan
spark_df |>
  <query> |>
  explain()

# Monitor in Spark UI
# Navigate to Databricks cluster -> Spark UI -> SQL tab
```

## 8. Modern dbplyr Patterns

### .by for Per-Operation Grouping

**Modern Syntax** (dbplyr 2.3.0+):
```r
# Old way
spark_df |>
  group_by(department) |>
  summarize(avg_salary = mean(salary)) |>
  ungroup()

# New way with .by
spark_df |>
  summarize(avg_salary = mean(salary), .by = department)

# Multiple grouping variables
spark_df |>
  summarize(
    total = sum(amount),
    .by = c(department, year)
  )
```

**Advantages**:
- No need to remember `ungroup()`
- Clearer intent
- Less error-prone

### across() with Remote Data

**Apply function to multiple columns**:
```r
# Summarize multiple columns
spark_df |>
  group_by(department) |>
  summarize(across(c(salary, bonus), mean))

# Mutate multiple columns
spark_df |>
  mutate(across(c(col1, col2, col3), ~ . * 1.1))

# With tidyselect helpers
spark_df |>
  mutate(across(where(is.numeric), ~ round(., 2)))

# Multiple functions
spark_df |>
  group_by(department) |>
  summarize(across(
    c(salary, bonus),
    list(mean = mean, max = max, min = min)
  ))
```

### New join_by() Syntax

**Modern Join Syntax** (dplyr 1.1.0+):
```r
# Old way
employees |>
  left_join(departments, by = c("dept_id" = "id"))

# New way with join_by()
employees |>
  left_join(departments, join_by(dept_id == id))

# More expressive for complex joins
employees |>
  left_join(assignments, join_by(
    emp_id == employee_id,
    hire_date <= assignment_date
  ))

# Inequality joins
sales |>
  left_join(targets, join_by(
    region,
    date >= start_date,
    date <= end_date
  ))
```

### Integration with tidyselect

**Column Selection Helpers**:
```r
# Select by pattern
spark_df |>
  select(starts_with("sales_"))

# Select by type
spark_df |>
  select(where(is.numeric))

# Select with complex conditions
spark_df |>
  select(where(~ is.numeric(.) && max(., na.rm = TRUE) > 1000))

# Remove columns
spark_df |>
  select(-c(temp_col1, temp_col2))
```

## 9. DBI Integration

### DBI's Role in sparklyr

**DBI (Database Interface)** provides a low-level connection layer. sparklyr implements DBI methods, allowing you to use DBI functions alongside dplyr.

**Connection Relationship**:
```r
sc <- spark_connect(method = "databricks")

# sc is BOTH a Spark connection AND a DBI connection
class(sc)
# [1] "spark_connection"       "spark_shell_connection"
# [3] "DBIConnection"

# Can use DBI functions
DBI::dbListTables(sc)
DBI::dbGetQuery(sc, "SELECT * FROM table LIMIT 10")
```

### dbConnect() vs spark_connect()

**spark_connect()**: High-level Spark connection
```r
sc <- spark_connect(
  method = "databricks",
  cluster_id = "xxxx"
)
```

**Equivalence**: `spark_connect()` returns a DBI-compatible connection, so you can use DBI functions on it.

### SQL Pass-Through

**Execute Raw SQL**:
```r
# Method 1: DBI
result <- DBI::dbGetQuery(sc, "
  SELECT department, AVG(salary) as avg_salary
  FROM employees
  WHERE hire_year >= 2020
  GROUP BY department
")

# Method 2: tbl() with sql()
query <- tbl(sc, sql("
  SELECT * FROM employees
  WHERE status = 'active'
"))

# Continue with dplyr
query |>
  filter(department == "Engineering") |>
  collect()
```

**Parameterized Queries**:
```r
# Safe from SQL injection
DBI::dbGetQuery(sc,
  "SELECT * FROM employees WHERE department = ?",
  params = list("Engineering")
)
```

### Transaction Handling

**Note**: Spark doesn't support traditional ACID transactions like RDBMS. However, Delta Lake provides ACID guarantees.

**DBI Transaction Functions** (limited support):
- `dbBegin()` - Start transaction (not applicable to Spark)
- `dbCommit()` - Commit (not applicable to Spark)
- `dbRollback()` - Rollback (not applicable to Spark)

**For ACID guarantees, use Delta Lake**:
```r
# Delta Lake provides atomicity
spark_write_table(
  df,
  "delta_table",
  mode = "overwrite"
)  # Atomic operation
```

## 10. Code Examples

### Example 1: Data Exploration Pipeline
```r
library(sparklyr)
library(dplyr)

# Connect
sc <- spark_connect(method = "databricks")

# Load data
transactions <- spark_read_table(sc, "sales.transactions")

# Exploration pipeline
summary_stats <- transactions |>
  filter(
    date >= as.Date("2024-01-01"),
    status == "completed"
  ) |>
  group_by(product_category, region) |>
  summarize(
    n_transactions = n(),
    total_revenue = sum(amount),
    avg_order_value = mean(amount),
    median_order = median(amount)
  ) |>
  filter(n_transactions >= 100) |>
  arrange(desc(total_revenue)) |>
  collect()

# View results
print(summary_stats)
```

### Example 2: Feature Engineering
```r
# Create features for ML
features <- transactions |>
  mutate(
    # Date features
    year = year(date),
    month = month(date),
    day_of_week = wday(date),

    # Categorical encoding
    is_weekend = day_of_week %in% c(1, 7),
    season = case_when(
      month %in% c(12, 1, 2) ~ "Winter",
      month %in% c(3, 4, 5) ~ "Spring",
      month %in% c(6, 7, 8) ~ "Summer",
      TRUE ~ "Fall"
    ),

    # Binning
    amount_category = case_when(
      amount < 50 ~ "Small",
      amount < 200 ~ "Medium",
      TRUE ~ "Large"
    ),

    # Log transform
    log_amount = log(amount + 1)
  ) |>
  compute("features_table")
```

### Example 3: Complex Aggregation with Window Functions
```r
# Calculate running totals and rankings
customer_metrics <- transactions |>
  group_by(customer_id) |>
  arrange(date) |>
  mutate(
    # Cumulative
    cumulative_spend = cumsum(amount),
    order_number = row_number(),

    # Moving average (7-day window)
    ma_7day = mean(amount, na.rm = TRUE),

    # Previous order
    prev_order_amount = lag(amount, 1),
    days_since_last_order = as.numeric(date - lag(date, 1))
  ) |>
  ungroup() |>
  compute("customer_metrics")
```

### Example 4: Multi-Table Join Pipeline
```r
# Complex join with multiple tables
comprehensive_view <- transactions |>
  # Join customer data
  left_join(
    tbl(sc, "customers"),
    by = "customer_id"
  ) |>
  # Join product data
  left_join(
    tbl(sc, "products"),
    by = "product_id"
  ) |>
  # Join regional data (broadcast small table)
  left_join(
    sdf_broadcast(tbl(sc, "regions")),
    by = "region_code"
  ) |>
  # Filter and select
  filter(
    customer_status == "active",
    product_availability == TRUE
  ) |>
  select(
    customer_id, customer_name, customer_segment,
    product_id, product_name, product_category,
    region_name, region_market,
    transaction_date = date,
    amount, quantity
  ) |>
  compute("comprehensive_view")
```

### Example 5: Debugging SQL Translation
```r
# Build complex query
query <- transactions |>
  filter(year(date) == 2024) |>
  group_by(product_category) |>
  summarize(
    total_sales = sum(amount),
    avg_order = mean(amount)
  ) |>
  filter(total_sales > 100000) |>
  arrange(desc(total_sales))

# Inspect SQL before executing
query |> show_query()

# Check execution plan
query |> explain()

# Execute on sample first
query |>
  head(10) |>
  collect()

# If satisfied, collect full results
results <- query |> collect()
```

## 11. Comparison Tables

### dplyr Verb → Spark SQL Translation

| dplyr Verb | Spark SQL Clause | Example |
|------------|------------------|---------|
| `filter()` | `WHERE` | `filter(age > 30)` → `WHERE age > 30.0` |
| `select()` | `SELECT` | `select(name, age)` → `SELECT name, age` |
| `mutate()` | Computed Column | `mutate(x2 = x * 2)` → `SELECT *, x * 2 AS x2` |
| `summarize()` | Aggregate + `GROUP BY` | `summarize(avg = mean(x))` → `SELECT AVG(x) AS avg` |
| `arrange()` | `ORDER BY` | `arrange(desc(x))` → `ORDER BY x DESC` |
| `distinct()` | `DISTINCT` | `distinct(dept)` → `SELECT DISTINCT dept` |
| `left_join()` | `LEFT JOIN` | `left_join(y, by = "id")` → `LEFT JOIN y ON ...` |
| `inner_join()` | `INNER JOIN` | `inner_join(y)` → `INNER JOIN y ON ...` |
| `semi_join()` | `LEFT SEMI JOIN` | Spark-optimized filtering join |
| `anti_join()` | `LEFT ANTI JOIN` | Spark-optimized exclusion join |
| `group_by()` | `GROUP BY` | `group_by(dept)` → `GROUP BY dept` |
| `ungroup()` | - | Removes grouping (no SQL equivalent) |

### R Function → Spark SQL Function

| R / stringr | Spark SQL | Translation |
|-------------|-----------|-------------|
| `toupper(x)` / `str_to_upper(x)` | `UPPER(x)` | Uppercase |
| `tolower(x)` / `str_to_lower(x)` | `LOWER(x)` | Lowercase |
| `nchar(x)` / `str_length(x)` | `LENGTH(x)` | String length |
| `trimws(x)` / `str_trim(x)` | `TRIM(x)` | Trim whitespace |
| `substr(x, 1, 3)` / `str_sub(x, 1, 3)` | `SUBSTRING(x, 1, 3)` | Substring |
| `grepl(pattern, x)` / `str_detect(x, pattern)` | `x RLIKE pattern` | Pattern match |
| `gsub(old, new, x)` / `str_replace_all(x, old, new)` | `REGEXP_REPLACE(x, old, new)` | Replace |
| `paste(x, y)` / `str_c(x, y)` | `CONCAT(x, y)` | Concatenate |

| R / lubridate | Spark SQL | Translation |
|---------------|-----------|-------------|
| `year(date)` | `YEAR(date)` | Extract year |
| `month(date)` | `MONTH(date)` | Extract month |
| `day(date)` | `DAY(date)` | Extract day |
| `hour(datetime)` | `HOUR(datetime)` | Extract hour |
| `wday(date)` | `DAYOFWEEK(date)` | Day of week |
| `now()` | `CURRENT_TIMESTAMP()` | Current timestamp |
| `today()` | `CURRENT_DATE()` | Current date |
| `as_date(x)` | `TO_DATE(x)` | Convert to date |
| `floor_date(date, "month")` | `DATE_TRUNC("month", date)` | Truncate to unit |

| R Math | Spark SQL | Translation |
|--------|-----------|-------------|
| `abs(x)` | `ABS(x)` | Absolute value |
| `sqrt(x)` | `SQRT(x)` | Square root |
| `log(x)` | `LOG(x)` | Natural log |
| `log10(x)` | `LOG10(x)` | Base-10 log |
| `exp(x)` | `EXP(x)` | Exponential |
| `round(x, 2)` | `ROUND(x, 2)` | Round |
| `floor(x)` | `FLOOR(x)` | Round down |
| `ceiling(x)` | `CEIL(x)` | Round up |

| R Conditional | Spark SQL | Translation |
|---------------|-----------|-------------|
| `ifelse(cond, yes, no)` | `CASE WHEN cond THEN yes ELSE no END` | If-else |
| `if_else(cond, yes, no)` | `CASE WHEN cond THEN yes ELSE no END` | Type-safe if-else |
| `case_when(...)` | `CASE WHEN ... WHEN ... ELSE ... END` | Multiple conditions |
| `coalesce(x, y, z)` | `COALESCE(x, y, z)` | First non-NULL |

| R Aggregate | Spark SQL | Translation |
|-------------|-----------|-------------|
| `n()` | `COUNT(*)` | Count rows |
| `n_distinct(x)` | `COUNT(DISTINCT x)` | Count unique |
| `sum(x)` | `SUM(x)` | Sum |
| `mean(x)` | `AVG(x)` | Average |
| `median(x)` | `PERCENTILE_APPROX(x, 0.5)` | Approximate median |
| `min(x)` | `MIN(x)` | Minimum |
| `max(x)` | `MAX(x)` | Maximum |
| `sd(x)` | `STDDEV_SAMP(x)` | Sample std dev |
| `var(x)` | `VAR_SAMP(x)` | Sample variance |

## 12. References

### Documentation Processed

1. **dbplyr Articles**
   - URL: https://dbplyr.tidyverse.org/articles/
   - Coverage: Introduction, translation, SQL generation, backend development
   - Key Topics: Lazy evaluation, verb translation, function translation

2. **dbplyr Function Reference**
   - URL: https://dbplyr.tidyverse.org/reference/
   - Coverage: Complete function catalog
   - Key Topics: tbl(), show_query(), compute(), collect(), translate_sql()

3. **CRAN dbplyr**
   - URL: https://cran.r-project.org/web/packages/dbplyr/
   - Coverage: Package metadata, dependencies, vignettes
   - Key Topics: Version compatibility, installation

4. **DBI Documentation**
   - URL: https://dbi.r-dbi.org/
   - Coverage: Database interface specification
   - Key Topics: Connection management, SQL execution, parameterized queries

### Key Concepts Summary

- **Lazy Evaluation**: Operations build query plan; execution deferred until collect()/compute()
- **SQL Translation**: dplyr verbs → SQL clauses; R functions → SQL functions
- **Query Inspection**: show_query() and explain() for debugging
- **Performance**: Filter early, compute() intermediates, avoid premature collect()
- **Limitations**: Complex R functions, some tidyr operations, custom statistical functions
- **Workarounds**: spark_apply(), compute() + R processing, native Spark functions via expr()
- **Modern Patterns**: .by grouping, across(), join_by(), tidyselect integration

### Related Resources

- sparklyr documentation for Spark-specific operations
- Spark SQL documentation for available functions
- dplyr documentation for verb semantics
- tidyselect documentation for selection helpers

---

**End of dbplyr Translation & Remote Data Manipulation Guide**
