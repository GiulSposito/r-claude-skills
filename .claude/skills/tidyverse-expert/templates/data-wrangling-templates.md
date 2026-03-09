# Data Wrangling Templates

Reusable code templates for common tidyverse data manipulation patterns. Copy, adapt, and customize for your specific use case.

---

## Template 1: Reading Multiple CSV Files

**When to use**: Import and combine multiple CSV files from a directory with consistent structure.

**Template**:
```r
library(tidyverse)

# List all CSV files in directory
file_paths <- list.files(
  path = "data/raw",           # Directory path
  pattern = "\\.csv$",         # File pattern
  full.names = TRUE            # Return full paths
)

# Read and combine all files
combined_data <- file_paths |>
  set_names() |>                               # Use file paths as names
  map(
    read_csv,
    col_types = cols(                           # Specify column types
      date = col_date(format = "%Y-%m-%d"),
      amount = col_double(),
      status = col_character()
    )
  ) |>
  list_rbind(names_to = "source_file") |>     # Combine and add file name column
  mutate(
    source_file = basename(source_file),        # Keep only filename
    import_date = Sys.Date()                    # Add import timestamp
  )
```

**Adaptation notes**:
- Replace `"data/raw"` with your directory path
- Adjust `pattern` for different file extensions (e.g., `"\\.xlsx$"`)
- Modify `col_types` to match your data structure
- Use `read_csv2()`, `read_tsv()`, or `read_delim()` as needed
- Add error handling with `possibly()` for inconsistent files:
  ```r
  safe_read <- possibly(read_csv, otherwise = NULL)
  map(file_paths, safe_read) |> list_rbind(names_to = "source_file")
  ```

---

## Template 2: Cleaning Messy Column Names

**When to use**: Standardize inconsistent column names (spaces, mixed case, special characters).

**Template**:
```r
library(tidyverse)

# Clean column names: lowercase, snake_case, no special chars
data_clean <- raw_data |>
  rename_with(~ str_to_lower(.)) |>                # Lowercase
  rename_with(~ str_replace_all(., "\\s+", "_")) |>  # Spaces to underscores
  rename_with(~ str_replace_all(., "[^a-z0-9_]", "")) |>  # Remove special chars
  rename_with(~ str_replace_all(., "_+", "_")) |>   # Collapse multiple underscores
  rename_with(~ str_remove(., "^_|_$"))              # Remove leading/trailing underscores

# Alternative: Use janitor package for automatic cleaning
# library(janitor)
# data_clean <- raw_data |> clean_names()
```

**Adaptation notes**:
- For camelCase instead of snake_case, use different replacements
- Add `rename()` calls after for specific column renaming
- Consider `janitor::clean_names()` for most cases (handles many edge cases)
- Preserve original names if needed:
  ```r
  data_clean <- raw_data |>
    mutate(original_columns = list(names(raw_data))) |>
    rename_with(...)
  ```

---

## Template 3: Strategic Missing Value Handling

**When to use**: Handle missing values with different strategies based on column type and context.

**Template**:
```r
library(tidyverse)

data_imputed <- raw_data |>
  mutate(
    # Numeric: Replace with median (robust to outliers)
    numeric_col = replace_na(numeric_col, median(numeric_col, na.rm = TRUE)),

    # Numeric: Replace with 0 when missing means "none"
    count_col = replace_na(count_col, 0),

    # Categorical: Replace with mode (most common value)
    category_col = replace_na(
      category_col,
      names(which.max(table(category_col)))
    ),

    # Categorical: Replace with "Unknown" or "Missing"
    status_col = replace_na(status_col, "Unknown"),

    # Forward fill: Use last known value (time series)
    status_col_filled = if_else(is.na(status_col),
                                lag(status_col),
                                status_col),

    # Create indicator for imputed values
    numeric_col_imputed = is.na(numeric_col),
    category_col_imputed = is.na(category_col)
  ) |>
  # Group-wise imputation (e.g., by category)
  group_by(group_var) |>
  mutate(
    group_median = replace_na(value, median(value, na.rm = TRUE))
  ) |>
  ungroup()

# Remove rows with critical missing values
data_filtered <- data_imputed |>
  filter(!is.na(critical_column))

# Or keep only complete cases
data_complete <- data_imputed |>
  drop_na(important_col1, important_col2)
```

**Adaptation notes**:
- Choose imputation strategy based on data meaning
- Always create flags for imputed values for transparency
- Consider multiple imputation for statistical modeling
- Use `tidyr::fill()` for forward/backward filling in ordered data
- For complex imputation, consider `mice` or `missForest` packages

---

## Template 4: Complex Grouping and Summarization

**When to use**: Calculate multiple summary statistics across groups with derived metrics.

**Template**:
```r
library(tidyverse)

summary_stats <- data |>
  group_by(group_var1, group_var2) |>
  summarise(
    # Count and size metrics
    n_obs = n(),
    n_unique_ids = n_distinct(id),

    # Central tendency
    mean_value = mean(value, na.rm = TRUE),
    median_value = median(value, na.rm = TRUE),
    mode_category = names(which.max(table(category))),

    # Dispersion
    sd_value = sd(value, na.rm = TRUE),
    iqr_value = IQR(value, na.rm = TRUE),
    cv_value = sd_value / mean_value,  # Coefficient of variation

    # Range
    min_value = min(value, na.rm = TRUE),
    max_value = max(value, na.rm = TRUE),
    range_value = max_value - min_value,

    # Quantiles
    p25 = quantile(value, 0.25, na.rm = TRUE),
    p75 = quantile(value, 0.75, na.rm = TRUE),
    p95 = quantile(value, 0.95, na.rm = TRUE),

    # Data quality
    n_missing = sum(is.na(value)),
    pct_missing = mean(is.na(value)) * 100,

    # Conditional aggregations
    n_above_threshold = sum(value > 100, na.rm = TRUE),
    pct_above_threshold = mean(value > 100, na.rm = TRUE) * 100,
    sum_positive = sum(value[value > 0], na.rm = TRUE),

    # Date ranges (if applicable)
    first_date = min(date, na.rm = TRUE),
    last_date = max(date, na.rm = TRUE),
    date_span_days = as.numeric(difftime(last_date, first_date, units = "days")),

    .groups = "drop"  # Ungroup after summarize
  ) |>
  # Post-aggregation calculations
  mutate(
    ratio_metric = mean_value / median_value,
    rank_by_mean = dense_rank(desc(mean_value)),
    pct_of_total = n_obs / sum(n_obs) * 100
  )
```

**Adaptation notes**:
- Remove metrics not relevant to your analysis
- Add custom summary functions: `my_stat = my_function(value)`
- Use `across()` to apply same summary to multiple columns:
  ```r
  summarise(across(c(val1, val2, val3), list(mean = mean, sd = sd)))
  ```
- Consider `reframe()` for returning multiple rows per group
- Always specify `.groups` behavior to avoid warnings

---

## Template 5: Conditional Recoding Patterns

**When to use**: Create new categorical variables based on complex business logic.

**Template**:
```r
library(tidyverse)

data_recoded <- data |>
  mutate(
    # Simple if-else
    simple_category = if_else(value > 100, "High", "Low"),

    # Multi-condition case_when (order matters - first match wins)
    complex_category = case_when(
      value < 50 ~ "Very Low",
      value < 100 ~ "Low",
      value < 500 ~ "Medium",
      value < 1000 ~ "High",
      value >= 1000 ~ "Very High",
      is.na(value) ~ "Missing",
      TRUE ~ "Other"  # Catch-all (optional but recommended)
    ),

    # Multiple conditions (AND)
    segment = case_when(
      age < 30 & income < 50000 ~ "Young Low Income",
      age < 30 & income >= 50000 ~ "Young High Income",
      age >= 30 & income < 50000 ~ "Mature Low Income",
      age >= 30 & income >= 50000 ~ "Mature High Income",
      TRUE ~ "Unknown"
    ),

    # Multiple conditions (OR)
    flag = case_when(
      status == "Active" | days_since_last > 90 ~ "Review",
      status == "Inactive" | amount == 0 ~ "Archive",
      TRUE ~ "Normal"
    ),

    # Using string detection
    category_clean = case_when(
      str_detect(description, "(?i)urgent|priority") ~ "High Priority",
      str_detect(description, "(?i)follow.?up") ~ "Follow-Up",
      str_detect(description, "(?i)question|inquiry") ~ "Information Request",
      TRUE ~ "General"
    ),

    # Quantile-based binning
    value_percentile = case_when(
      value <= quantile(value, 0.25, na.rm = TRUE) ~ "Bottom 25%",
      value <= quantile(value, 0.50, na.rm = TRUE) ~ "25-50%",
      value <= quantile(value, 0.75, na.rm = TRUE) ~ "50-75%",
      TRUE ~ "Top 25%"
    ),

    # Nested case_when for complex hierarchies
    risk_level = case_when(
      score >= 80 ~ "Low Risk",
      score >= 60 ~ if_else(has_collateral, "Low-Medium", "Medium"),
      score >= 40 ~ if_else(has_collateral, "Medium", "Medium-High"),
      TRUE ~ "High Risk"
    ),

    # Recoding with multiple variables
    customer_type = case_when(
      frequency >= 10 & monetary >= 1000 ~ "VIP",
      frequency >= 5 & monetary >= 500 ~ "Regular",
      frequency >= 1 ~ "Occasional",
      TRUE ~ "Inactive"
    )
  )
```

**Adaptation notes**:
- Order conditions from most specific to most general
- Always include a catch-all `TRUE ~` condition for robustness
- Use `(?i)` in regex for case-insensitive matching
- For simple binary splits, `if_else()` is faster than `case_when()`
- Consider creating ordered factors for ordinal categories
- Test edge cases (NAs, zeros, extreme values)

---

## Template 6: Custom Aggregation Functions

**When to use**: Apply complex or custom calculations within group_by() operations.

**Template**:
```r
library(tidyverse)

# Define custom aggregation function
weighted_mean <- function(x, w, na.rm = TRUE) {
  if (na.rm) {
    valid <- !is.na(x) & !is.na(w)
    x <- x[valid]
    w <- w[valid]
  }
  sum(x * w) / sum(w)
}

# Custom function returning multiple values
calculate_stats <- function(x) {
  tibble(
    mean = mean(x, na.rm = TRUE),
    sd = sd(x, na.rm = TRUE),
    n = sum(!is.na(x)),
    se = sd / sqrt(n)
  )
}

# Apply custom functions
custom_summary <- data |>
  group_by(category) |>
  summarise(
    # Single-value custom function
    wtd_avg = weighted_mean(value, weight),

    # Multiple-value custom function with reframe
    stats = list(calculate_stats(value))
  ) |>
  unnest(stats)  # Expand nested tibble

# Using across() with custom function
multi_col_summary <- data |>
  group_by(group) |>
  summarise(
    across(
      c(var1, var2, var3),
      list(
        mean = ~ mean(.x, na.rm = TRUE),
        wtd = ~ weighted_mean(.x, weight)
      ),
      .names = "{.col}_{.fn}"
    )
  )

# Conditional aggregation
conditional_agg <- data |>
  group_by(category) |>
  summarise(
    # Average only for positive values
    avg_positive = mean(value[value > 0], na.rm = TRUE),

    # Count matching condition
    n_above_100 = sum(value > 100, na.rm = TRUE),

    # Sum with condition
    total_flagged = sum(if_else(flag == TRUE, value, 0), na.rm = TRUE),

    # Percentage meeting criteria
    pct_complete = mean(status == "Complete") * 100
  )
```

**Adaptation notes**:
- Create reusable functions in separate script for complex calculations
- Use `...` in custom functions to pass additional arguments
- Consider performance for very large datasets (avoid complex operations in summarise)
- Test custom functions independently before using in pipelines
- Document assumptions (e.g., how NAs are handled)

---

## Template 7: Date Range Filtering

**When to use**: Filter data based on various date/time criteria and ranges.

**Template**:
```r
library(tidyverse)
library(lubridate)

data_filtered <- data |>
  mutate(
    # Ensure date column is Date type
    date = as.Date(date)
  ) |>
  # Filter patterns:

  # Specific date range
  filter(date >= as.Date("2024-01-01"),
         date <= as.Date("2024-12-31")) |>

  # Last N days
  filter(date >= today() - days(30)) |>

  # Current month
  filter(year(date) == year(today()),
         month(date) == month(today())) |>

  # Last complete month
  filter(date >= floor_date(today() - months(1), "month"),
         date < floor_date(today(), "month")) |>

  # Current quarter
  filter(quarter(date, with_year = TRUE) == quarter(today(), with_year = TRUE)) |>

  # Last N months (rolling)
  filter(date >= floor_date(today() - months(3), "month")) |>

  # Year to date
  filter(year(date) == year(today()),
         date <= today()) |>

  # Between two timestamps (datetime)
  filter(timestamp >= as.POSIXct("2024-01-01 00:00:00"),
         timestamp < as.POSIXct("2024-02-01 00:00:00")) |>

  # Business days only (weekdays)
  filter(!wday(date, label = FALSE) %in% c(1, 7)) |>  # 1=Sun, 7=Sat

  # Exclude specific dates (holidays)
  filter(!date %in% c(as.Date("2024-01-01"),
                      as.Date("2024-07-04"),
                      as.Date("2024-12-25"))) |>

  # Dynamic relative dates
  filter(date >= floor_date(today(), "year"),  # Start of current year
         date <= ceiling_date(today(), "year") - days(1))  # End of current year
```

**Adaptation notes**:
- Use `between()` for inclusive ranges: `filter(between(date, start, end))`
- For recurring patterns, create helper functions:
  ```r
  is_business_day <- function(date) {
    !wday(date, label = FALSE) %in% c(1, 7) &
    !date %in% holiday_dates
  }
  filter(is_business_day(date))
  ```
- Combine date filters with other conditions using `&` or `|`
- Consider time zones for datetime filtering: `with_tz()`, `force_tz()`
- Store frequently used date ranges as variables for reuse

---

## Template 8: Factor Releveling for Plots

**When to use**: Control factor order for clearer visualizations and meaningful comparisons.

**Template**:
```r
library(tidyverse)
library(forcats)

data_prepared <- data |>
  mutate(
    # Order by frequency (most common first)
    category_freq = fct_infreq(category),

    # Order by another numeric variable
    category_by_value = fct_reorder(category, value, .fun = mean),
    category_desc = fct_reorder(category, value, .fun = mean, .desc = TRUE),

    # Manual ordering for specific sequence
    priority = fct_relevel(priority, "High", "Medium", "Low"),

    # Collapse rare levels into "Other"
    category_lumped = fct_lump_n(category, n = 5, w = value,
                                 other_level = "Other Categories"),
    category_lumped_prop = fct_lump_prop(category, prop = 0.05,
                                         other_level = "< 5%"),

    # Reverse current order
    category_rev = fct_rev(category),

    # Combine multiple levels
    status_grouped = fct_collapse(status,
      Active = c("Active", "Engaged", "Current"),
      Inactive = c("Inactive", "Dormant", "Churned"),
      Pending = c("Pending", "In Progress", "Under Review")
    ),

    # Recode for clearer labels
    department_clean = fct_recode(department,
      "Engineering & IT" = "Engineering",
      "Sales & Marketing" = "Sales",
      "Customer Success" = "Support"
    ),

    # Order by first appearance
    item_order = fct_inorder(item),

    # Drop unused levels after filtering
    status_active = fct_drop(status)
  ) |>
  # Group-wise ordering (order categories within each group)
  group_by(region) |>
  mutate(
    product_rank = fct_reorder(product, sales, .fun = sum)
  ) |>
  ungroup()

# For plotting, ensure factors are in desired order
plot_data <- data_prepared |>
  # Order factor levels for x-axis display
  mutate(month = fct_relevel(month, month.abb)) |>
  # Order by value for sorted bar chart
  mutate(product = fct_reorder(product, sales, .desc = TRUE))
```

**Adaptation notes**:
- Apply factor ordering just before visualization for clarity
- Use `fct_reorder()` for bar charts ordered by height
- Use `fct_reorder2()` for line charts (orders by y-value at max x)
- Combine operations: `fct_lump_n() |> fct_reorder()`
- Check factor levels: `levels(data$category)`
- For complex hierarchies, consider creating separate grouping variables

---

## Template 9: String Cleaning and Standardization

**When to use**: Clean and normalize text data for analysis or matching.

**Template**:
```r
library(tidyverse)

data_cleaned <- data |>
  mutate(
    # Basic cleaning
    text_clean = str_trim(text) |>                    # Remove leading/trailing whitespace
                 str_squish() |>                      # Collapse internal whitespace
                 str_to_lower(),                       # Lowercase

    # Remove specific patterns
    text_no_punct = str_remove_all(text, "[[:punct:]]"),  # Remove punctuation
    text_no_digits = str_remove_all(text, "\\d"),          # Remove digits
    text_no_special = str_remove_all(text, "[^[:alnum:]\\s]"),  # Keep only alphanumeric

    # Extract patterns
    email = str_extract(text, "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"),
    phone = str_extract(text, "\\d{3}[-.]?\\d{3}[-.]?\\d{4}"),
    url = str_extract(text, "https?://[^\\s]+"),

    # Standardize formats
    phone_clean = str_remove_all(phone, "[-.]") |>
                  str_replace("(\\d{3})(\\d{3})(\\d{4})", "(\\1) \\2-\\3"),

    # Replace patterns
    text_normalized = str_replace_all(text, "\\s+", " ") |>      # Multiple spaces to single
                      str_replace_all("['\u2018\u2019]", "'") |>  # Standardize quotes
                      str_replace_all("\\n+", " "),                # Remove newlines

    # Extract numbers from text
    amount = str_extract(text, "\\$?[0-9,]+\\.?[0-9]*") |>
             str_remove_all("[$,]") |>
             as.numeric(),

    # Detect patterns (logical flags)
    contains_email = str_detect(text, "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"),
    contains_url = str_detect(text, "https?://"),
    is_all_caps = text == str_to_upper(text),

    # Word count
    word_count = str_count(text, "\\w+"),

    # Extract components (addresses, names, etc.)
    state_abbr = str_extract(address, "\\b[A-Z]{2}\\b"),  # 2-letter state code
    zip_code = str_extract(address, "\\d{5}(?:-\\d{4})?"), # ZIP code

    # Conditional replacements
    category_clean = case_when(
      str_detect(str_to_lower(category), "tech|software|it") ~ "Technology",
      str_detect(str_to_lower(category), "health|medical|care") ~ "Healthcare",
      str_detect(str_to_lower(category), "fin|bank|invest") ~ "Finance",
      TRUE ~ str_to_title(category)
    ),

    # Remove common prefixes/suffixes
    company_clean = str_remove(company, "(?i)(inc|llc|corp|ltd)\\.?$") |>
                    str_trim()
  )
```

**Adaptation notes**:
- Test regex patterns with `str_view()` or `str_view_all()` first
- Use `(?i)` in patterns for case-insensitive matching
- Consider `str_replace()` vs `str_replace_all()` (first vs all occurrences)
- For complex parsing, break into multiple steps for readability
- Handle international characters with Unicode categories: `[\\p{L}]` for letters
- Validate extraction results: check for NAs or unexpected patterns

---

## Template 10: Joining with Different Key Combinations

**When to use**: Combine datasets with various types of keys and join strategies.

**Template**:
```r
library(tidyverse)

# ============================================================================
# Simple joins with single key
# ============================================================================

# Inner join: Only matching records from both
result_inner <- table_a |>
  inner_join(table_b, by = "id")

# Left join: All from A, matching from B (NAs where no match)
result_left <- table_a |>
  left_join(table_b, by = "id")

# Right join: All from B, matching from A
result_right <- table_a |>
  right_join(table_b, by = "id")

# Full join: All records from both (NAs where no match either side)
result_full <- table_a |>
  full_join(table_b, by = "id")

# ============================================================================
# Joins with multiple keys
# ============================================================================

result_multi <- table_a |>
  left_join(table_b, by = c("customer_id", "date"))

# ============================================================================
# Joins with different column names
# ============================================================================

result_diff_names <- table_a |>
  left_join(table_b, by = c("id" = "customer_id",
                            "date" = "transaction_date"))

# ============================================================================
# Filtering joins (don't add columns)
# ============================================================================

# Semi join: Rows from A that have match in B (filter, don't merge)
result_semi <- table_a |>
  semi_join(table_b, by = "id")

# Anti join: Rows from A that DON'T have match in B
result_anti <- table_a |>
  anti_join(table_b, by = "id")

# ============================================================================
# Fuzzy/Approximate joins
# ============================================================================

# Join on date ranges (using between)
result_range <- table_a |>
  left_join(
    table_b |> select(id, start_date, end_date, status),
    by = "id"
  ) |>
  filter(date >= start_date, date <= end_date)

# Join with tolerance (e.g., dates within 7 days)
result_fuzzy <- table_a |>
  left_join(table_b, by = "id", suffix = c("_a", "_b")) |>
  filter(abs(difftime(date_a, date_b, units = "days")) <= 7) |>
  select(-date_b)  # Keep only one date column

# ============================================================================
# Many-to-many joins (handle duplicates)
# ============================================================================

# Join and add row number to identify duplicates
result_m2m <- table_a |>
  left_join(table_b, by = "id", relationship = "many-to-many") |>
  group_by(id) |>
  mutate(match_num = row_number()) |>
  ungroup()

# Keep only first match
result_first <- table_a |>
  left_join(
    table_b |>
      group_by(id) |>
      slice_head(n = 1) |>
      ungroup(),
    by = "id"
  )

# ============================================================================
# Self joins (join table to itself)
# ============================================================================

# Find pairs within same table
result_self <- table_a |>
  inner_join(table_a, by = c("group_id"), suffix = c("_1", "_2")) |>
  filter(id_1 < id_2)  # Avoid duplicate pairs

# ============================================================================
# Validate joins
# ============================================================================

# Check for unexpected row count changes
join_validation <- table_a |>
  left_join(table_b, by = "id") |>
  {
    cat(sprintf("Rows before join: %d\n", nrow(table_a)))
    cat(sprintf("Rows after join: %d\n", nrow(.)))
    cat(sprintf("Unmatched rows: %d\n", sum(is.na(.$column_from_b))))
    .
  }

# Identify non-matching keys
unmatched_keys <- table_a |>
  anti_join(table_b, by = "id") |>
  distinct(id)
```

**Adaptation notes**:
- Always validate join results by checking row counts before/after
- Use `suffix` parameter when column names collide
- Specify `relationship` parameter in dplyr 1.1.0+ to catch many-to-many issues
- Consider `coalesce()` to merge overlapping columns after joins
- For complex joins, break into steps with intermediate checks
- Use `anti_join()` to find orphaned records before final joins
- Add join diagnostics in production pipelines

---

## Template 11: Window Functions and Ranking

**When to use**: Calculate running totals, ranks, or group-wise comparisons.

**Template**:
```r
library(tidyverse)

data_windowed <- data |>
  group_by(category) |>
  arrange(date) |>  # Order matters for cumulative operations
  mutate(
    # Rankings
    rank_dense = dense_rank(desc(value)),      # 1,2,2,3 (no gaps)
    rank_min = min_rank(desc(value)),          # 1,2,2,4 (gaps after ties)
    rank_row = row_number(desc(value)),        # 1,2,3,4 (unique, breaks ties arbitrarily)
    rank_percent = percent_rank(value),        # 0 to 1 scale
    rank_ntile = ntile(value, 4),              # Divide into 4 equal groups (quartiles)

    # Cumulative operations
    cumsum_value = cumsum(value),
    cummean_value = cummean(value),
    cummax_value = cummax(value),
    cummin_value = cummin(value),

    # Running differences
    diff_from_prev = value - lag(value),
    diff_from_next = value - lead(value),
    pct_change = (value - lag(value)) / lag(value) * 100,

    # Lead and lag with defaults
    prev_value = lag(value, default = 0),
    next_value = lead(value, default = 0),
    value_2_periods_ago = lag(value, n = 2),

    # Group comparisons
    diff_from_mean = value - mean(value),
    diff_from_median = value - median(value),
    z_score = (value - mean(value)) / sd(value),
    pct_of_group_total = value / sum(value) * 100,

    # First and last values in group
    first_in_group = first(value),
    last_in_group = last(value),
    diff_from_first = value - first(value),

    # Rolling windows (requires slider or zoo package)
    # rolling_mean_3 = slider::slide_dbl(value, mean, .before = 2, .complete = TRUE),
    # rolling_sum_7 = slider::slide_dbl(value, sum, .before = 6, .complete = TRUE),

    # Identify min/max within group
    is_group_max = value == max(value),
    is_group_min = value == min(value)
  ) |>
  ungroup()

# Find top N per group
top_n_per_group <- data |>
  group_by(category) |>
  slice_max(value, n = 3) |>  # Top 3 per category
  ungroup()

# Calculate percentile within group
percentile_data <- data |>
  group_by(category) |>
  mutate(
    percentile = ecdf(value)(value) * 100,
    is_top_10_pct = percentile >= 90
  ) |>
  ungroup()
```

**Adaptation notes**:
- Always `arrange()` before using `lag()`, `lead()`, or cumulative functions
- Use `default` parameter in `lag()`/`lead()` to avoid NAs
- Choose rank function based on how ties should be handled
- Remember to `ungroup()` after grouped window operations
- For rolling windows, `slider` package is more flexible than built-ins
- Window functions respect grouping and ordering

---

## Template 12: Nested Data and List Columns

**When to use**: Work with hierarchical data, fit models per group, or store complex objects.

**Template**:
```r
library(tidyverse)

# ============================================================================
# Create nested data
# ============================================================================

nested_data <- data |>
  group_by(category, region) |>
  nest() |>                  # Creates 'data' list-column
  ungroup()

# ============================================================================
# Apply operations to nested data
# ============================================================================

nested_results <- nested_data |>
  mutate(
    # Count rows in each nested tibble
    n_rows = map_int(data, nrow),

    # Extract specific column
    values = map(data, ~ .x$value),

    # Calculate summary statistic
    mean_value = map_dbl(data, ~ mean(.x$value, na.rm = TRUE)),
    median_value = map_dbl(data, ~ median(.x$value, na.rm = TRUE)),

    # Fit model to each group
    model = map(data, ~ lm(y ~ x, data = .x)),

    # Extract model coefficients
    coef_slope = map_dbl(model, ~ coef(.x)[2]),
    r_squared = map_dbl(model, ~ summary(.x)$r.squared),

    # Apply custom function
    custom_summary = map(data, function(df) {
      tibble(
        n = nrow(df),
        sum = sum(df$value),
        max = max(df$value)
      )
    })
  )

# ============================================================================
# Unnest results
# ============================================================================

# Unnest back to flat structure
flat_data <- nested_data |>
  unnest(data)

# Unnest specific list-columns
summary_unnested <- nested_results |>
  select(category, region, custom_summary) |>
  unnest(custom_summary)

# ============================================================================
# Work with multiple list-columns
# ============================================================================

multi_list <- data |>
  group_by(category) |>
  summarise(
    data = list(tibble(x, y)),
    models = list(lm(y ~ x))
  ) |>
  mutate(
    predictions = map2(models, data, ~ predict(.x, newdata = .y))
  )

# ============================================================================
# Practical example: Group-wise operations
# ============================================================================

group_analysis <- data |>
  nest(group_data = -category) |>
  mutate(
    # Count records
    n_records = map_int(group_data, nrow),

    # Find outliers per group
    outliers = map(group_data, ~ {
      q1 <- quantile(.x$value, 0.25)
      q3 <- quantile(.x$value, 0.75)
      iqr <- q3 - q1
      .x |> filter(value < q1 - 1.5*iqr | value > q3 + 1.5*iqr)
    }),

    # Count outliers
    n_outliers = map_int(outliers, nrow),

    # Remove outliers from data
    clean_data = map2(group_data, outliers, ~ anti_join(.x, .y))
  )
```

**Adaptation notes**:
- Use `nest()` to create list-columns, `unnest()` to expand them
- `map()` returns lists, `map_dbl()`/`map_int()`/`map_chr()` return vectors
- Use `map2()` or `pmap()` for multiple inputs
- Consider `rowwise()` as alternative for row-by-row operations
- List-columns useful for storing plots, models, or complex results
- Be careful with memory when nesting large datasets

---

## Template 13: Handling Duplicates

**When to use**: Identify, investigate, and resolve duplicate records.

**Template**:
```r
library(tidyverse)

# ============================================================================
# Identify duplicates
# ============================================================================

# Find completely duplicate rows
exact_duplicates <- data |>
  group_by_all() |>
  filter(n() > 1) |>
  ungroup()

# Find duplicates on specific columns
key_duplicates <- data |>
  group_by(id, date) |>
  filter(n() > 1) |>
  ungroup() |>
  arrange(id, date)

# Count duplicates per key
duplicate_summary <- data |>
  count(id, name = "n_records") |>
  filter(n_records > 1)

# ============================================================================
# Remove duplicates
# ============================================================================

# Keep first occurrence
deduped_first <- data |>
  distinct(id, .keep_all = TRUE)

# Keep last occurrence
deduped_last <- data |>
  group_by(id) |>
  slice_tail(n = 1) |>
  ungroup()

# Keep row with max value
deduped_max <- data |>
  group_by(id) |>
  slice_max(timestamp, n = 1, with_ties = FALSE) |>
  ungroup()

# Keep most complete record (fewest NAs)
deduped_complete <- data |>
  group_by(id) |>
  mutate(n_missing = rowSums(is.na(.))) |>
  slice_min(n_missing, n = 1) |>
  select(-n_missing) |>
  ungroup()

# ============================================================================
# Merge duplicate information
# ============================================================================

# Aggregate duplicates (combine information)
merged_duplicates <- data |>
  group_by(id) |>
  summarise(
    # Numeric: take mean or sum
    avg_value = mean(value, na.rm = TRUE),
    total_amount = sum(amount, na.rm = TRUE),

    # Categorical: take most common (mode)
    status = names(sort(table(status), decreasing = TRUE))[1],

    # Text: concatenate unique values
    all_notes = paste(unique(notes[!is.na(notes)]), collapse = "; "),

    # Dates: take earliest or latest
    first_date = min(date, na.rm = TRUE),
    last_date = max(date, na.rm = TRUE),

    # Flags: any TRUE means TRUE
    any_flagged = any(flagged, na.rm = TRUE),

    # Count occurrences
    n_records = n(),

    .groups = "drop"
  )

# Coalesce across duplicate rows (take first non-NA)
coalesced_data <- data |>
  group_by(id) |>
  summarise(
    across(everything(), ~ na.omit(.x)[1]),
    .groups = "drop"
  )

# ============================================================================
# Investigate duplicates before removing
# ============================================================================

# Compare duplicates side-by-side
duplicate_comparison <- data |>
  group_by(id) |>
  filter(n() > 1) |>
  mutate(duplicate_num = row_number()) |>
  ungroup() |>
  pivot_longer(
    cols = -c(id, duplicate_num),
    names_to = "field",
    values_to = "value"
  ) |>
  pivot_wider(
    names_from = duplicate_num,
    values_from = value,
    names_prefix = "record_"
  )
```

**Adaptation notes**:
- Always investigate before blindly removing duplicates
- Document deduplication logic in comments
- Consider creating `is_duplicate` flag instead of removing
- For large datasets, identify duplicates first, then handle separately
- Validate row counts before and after deduplication
- Consider if duplicates represent real-world patterns (e.g., repeat purchases)

---

## Template 14: Cross-Tabulation and Pivot Tables

**When to use**: Create summary tables showing relationships between categorical variables.

**Template**:
```r
library(tidyverse)

# ============================================================================
# Basic cross-tabulation
# ============================================================================

# Count frequency table
freq_table <- data |>
  count(category_a, category_b) |>
  pivot_wider(
    names_from = category_b,
    values_from = n,
    values_fill = 0
  )

# With percentages
pct_table <- data |>
  count(category_a, category_b) |>
  mutate(
    pct = n / sum(n) * 100,
    pct_label = sprintf("%.1f%%", pct)
  ) |>
  select(-pct) |>
  pivot_wider(
    names_from = category_b,
    values_from = pct_label,
    values_fill = "0.0%"
  )

# ============================================================================
# Aggregation pivot tables
# ============================================================================

# Mean by two dimensions
pivot_mean <- data |>
  group_by(region, product_category) |>
  summarise(avg_sales = mean(sales, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(
    names_from = product_category,
    values_from = avg_sales,
    values_fill = 0
  ) |>
  mutate(total_avg = rowMeans(select(., -region)))

# Sum with row and column totals
pivot_with_totals <- data |>
  group_by(region, category) |>
  summarise(total = sum(amount, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(
    names_from = category,
    values_from = total,
    values_fill = 0
  ) |>
  mutate(
    row_total = rowSums(select(., -region))
  ) |>
  bind_rows(
    summarise(., across(where(is.numeric), sum)) |>
      mutate(region = "Total")
  )

# ============================================================================
# Multi-value pivot tables
# ============================================================================

# Multiple metrics in pivot
multi_metric_pivot <- data |>
  group_by(region, product) |>
  summarise(
    count = n(),
    total_sales = sum(sales),
    avg_sales = mean(sales),
    .groups = "drop"
  ) |>
  pivot_wider(
    names_from = product,
    values_from = c(count, total_sales, avg_sales),
    names_sep = "_",
    values_fill = list(count = 0, total_sales = 0, avg_sales = 0)
  )

# ============================================================================
# Conditional formatting for display
# ============================================================================

# Highlight high/low values
formatted_pivot <- data |>
  group_by(month, category) |>
  summarise(value = sum(amount), .groups = "drop") |>
  pivot_wider(names_from = category, values_from = value) |>
  mutate(
    across(
      where(is.numeric),
      ~ case_when(
        .x >= quantile(.x, 0.75, na.rm = TRUE) ~ paste0("🔴 ", .x),
        .x <= quantile(.x, 0.25, na.rm = TRUE) ~ paste0("🔵 ", .x),
        TRUE ~ as.character(.x)
      )
    )
  )
```

**Adaptation notes**:
- Use `values_fill` to replace NAs with sensible defaults
- Add `names_prefix` to column names for clarity
- Consider `janitor::tabyl()` for quick frequency tables
- For display, pipe to `knitr::kable()` or `DT::datatable()`
- Calculate row/column totals after pivoting for cleaner code
- Store pivot logic in functions for reusable reporting

---

## Template 15: Data Quality Profiling

**When to use**: Generate comprehensive data quality report for a dataset.

**Template**:
```r
library(tidyverse)

# ============================================================================
# Overall dataset summary
# ============================================================================

dataset_summary <- tibble(
  total_rows = nrow(data),
  total_columns = ncol(data),
  memory_size = object.size(data) |> format(units = "MB"),
  duplicate_rows = nrow(data) - nrow(distinct(data))
)

# ============================================================================
# Column-level profiling
# ============================================================================

column_profile <- data |>
  summarise(across(everything(), list(
    type = ~ class(.x)[1],
    n_missing = ~ sum(is.na(.x)),
    pct_missing = ~ mean(is.na(.x)) * 100,
    n_unique = ~ n_distinct(.x, na.rm = TRUE),
    pct_unique = ~ n_distinct(.x, na.rm = TRUE) / n() * 100
  ))) |>
  pivot_longer(
    everything(),
    names_to = c("column", ".value"),
    names_sep = "_"
  )

# ============================================================================
# Numeric column statistics
# ============================================================================

numeric_profile <- data |>
  summarise(across(where(is.numeric), list(
    min = ~ min(.x, na.rm = TRUE),
    q25 = ~ quantile(.x, 0.25, na.rm = TRUE),
    median = ~ median(.x, na.rm = TRUE),
    mean = ~ mean(.x, na.rm = TRUE),
    q75 = ~ quantile(.x, 0.75, na.rm = TRUE),
    max = ~ max(.x, na.rm = TRUE),
    sd = ~ sd(.x, na.rm = TRUE),
    n_zeros = ~ sum(.x == 0, na.rm = TRUE),
    n_negative = ~ sum(.x < 0, na.rm = TRUE)
  ))) |>
  pivot_longer(
    everything(),
    names_to = c("column", ".value"),
    names_sep = "_"
  )

# ============================================================================
# Categorical column frequencies
# ============================================================================

categorical_profile <- data |>
  select(where(~ is.character(.x) | is.factor(.x))) |>
  pivot_longer(everything(), names_to = "column", values_to = "value") |>
  filter(!is.na(value)) |>
  count(column, value, sort = TRUE) |>
  group_by(column) |>
  mutate(
    pct = n / sum(n) * 100,
    rank = row_number()
  ) |>
  filter(rank <= 10) |>  # Top 10 values per column
  ungroup()

# ============================================================================
# Identify potential issues
# ============================================================================

data_quality_issues <- column_profile |>
  mutate(
    issue = case_when(
      pct_missing > 50 ~ "High missing rate (>50%)",
      pct_missing > 20 ~ "Moderate missing rate (>20%)",
      n_unique == 1 ~ "Constant value (no variation)",
      pct_unique == 100 ~ "All unique values (potential ID)",
      TRUE ~ "OK"
    )
  ) |>
  filter(issue != "OK")

# ============================================================================
# Output quality report
# ============================================================================

cat("\n===== DATA QUALITY REPORT =====\n\n")

cat("DATASET SUMMARY:\n")
print(dataset_summary)

cat("\n\nCOLUMN STATISTICS:\n")
print(column_profile |> arrange(desc(pct_missing)), n = 20)

cat("\n\nPOTENTIAL DATA QUALITY ISSUES:\n")
print(data_quality_issues)

cat("\n\nNUMERIC COLUMN PROFILES:\n")
print(numeric_profile, n = 20)
```

**Adaptation notes**:
- Run profiling on data samples for very large datasets
- Customize issue detection thresholds based on domain
- Add checks for specific patterns (e.g., email formats, date ranges)
- Export profile to CSV for documentation
- Schedule regular profiling for production data pipelines
- Visualize distributions with `ggplot2` for deeper insights

---

## Notes

- All templates follow tidyverse style guidelines
- Templates prioritize readability over extreme conciseness
- Each template includes inline comments for self-documentation
- Test templates with your specific data before production use
- Combine templates as needed for complex workflows
- Consider wrapping frequently-used patterns in custom functions
