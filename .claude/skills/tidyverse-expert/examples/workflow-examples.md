# Tidyverse Workflow Examples

Complete, runnable workflows demonstrating real-world tidyverse patterns. Each example includes setup, processing, and expected outputs.

---

## 1. Data Import and Cleaning Pipeline

**Scenario**: Import messy CSV files with inconsistent column names, missing values, and mixed data types.

```r
library(tidyverse)

# Import CSV with custom parsing
raw_data <- read_csv(
  "sales_data.csv",
  col_types = cols(
    date = col_date(format = "%m/%d/%Y"),
    amount = col_number(),           # Handles "$1,234.56" format
    status = col_factor(levels = c("pending", "complete", "cancelled"))
  ),
  na = c("", "NA", "N/A", "null", "-"),  # Multiple NA representations
  trim_ws = TRUE
)

# Clean and standardize
clean_data <- raw_data |>
  # Standardize column names: lowercase, snake_case
  rename_with(~ str_to_lower(.) |> str_replace_all("\\s+", "_")) |>
  # Remove completely empty rows/columns
  filter(if_any(everything(), ~ !is.na(.))) |>
  select(where(~ !all(is.na(.)))) |>
  # Handle missing values strategically
  mutate(
    # Fill forward for status (carry last known value)
    status = if_else(is.na(status), lag(status), status),
    # Replace numeric NAs with 0 where appropriate
    amount = replace_na(amount, 0),
    # Create flag for originally missing data
    amount_imputed = is.na(amount)
  ) |>
  # Type conversions and formatting
  mutate(
    # Extract year/month/quarter for aggregation
    year = year(date),
    month = month(date, label = TRUE),
    quarter = quarter(date),
    # Create categorical bins
    amount_category = case_when(
      amount < 100 ~ "small",
      amount < 1000 ~ "medium",
      amount < 10000 ~ "large",
      TRUE ~ "enterprise"
    )
  ) |>
  # Remove duplicates based on key columns
  distinct(date, customer_id, .keep_all = TRUE)

# Summary statistics for quality check
data_quality <- clean_data |>
  summarise(
    total_rows = n(),
    missing_dates = sum(is.na(date)),
    missing_amounts = sum(is.na(amount)),
    date_range = paste(min(date), "to", max(date)),
    avg_amount = mean(amount, na.rm = TRUE)
  )

print(data_quality)
```

**Expected Output**: Clean tibble with standardized names, handled NAs, derived date features, and quality report.

---

## 2. Complex Multi-Table Joins

**Scenario**: Combine customer orders, product information, and shipping data with different key structures.

```r
library(tidyverse)

# Sample data frames
customers <- tibble(
  customer_id = 1:5,
  name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
  region = c("North", "South", "North", "West", "East")
)

orders <- tibble(
  order_id = 101:108,
  customer_id = c(1, 2, 1, 3, 4, 2, 5, 6),  # Note: customer 6 doesn't exist
  product_id = c("A", "B", "A", "C", "B", "A", "C", "B"),
  quantity = c(2, 1, 3, 1, 2, 1, 4, 1),
  order_date = as.Date("2024-01-01") + c(0, 1, 2, 3, 4, 5, 6, 7)
)

products <- tibble(
  product_id = c("A", "B", "C", "D"),  # Note: product D never ordered
  product_name = c("Widget", "Gadget", "Doohickey", "Thingamajig"),
  price = c(10.99, 25.50, 15.75, 8.25),
  category = c("Tools", "Electronics", "Tools", "Accessories")
)

# Multi-table join workflow
complete_orders <- orders |>
  # Left join to keep all orders, even with missing customers
  left_join(customers, by = "customer_id") |>
  # Inner join with products (only valid products)
  inner_join(products, by = "product_id") |>
  # Calculate derived values
  mutate(
    # Total order value
    order_total = quantity * price,
    # Flag orphaned records
    customer_exists = !is.na(name),
    # Create readable order description
    order_description = str_glue("{name} ordered {quantity}x {product_name}")
  ) |>
  # Handle missing customer data
  mutate(
    name = replace_na(name, "Unknown Customer"),
    region = replace_na(region, "Unassigned")
  ) |>
  # Reorder columns logically
  select(order_id, order_date, customer_id, name, region,
         product_id, product_name, category, quantity, price, order_total,
         customer_exists)

# Find unmatched records for data quality
orphaned_orders <- orders |>
  anti_join(customers, by = "customer_id") |>
  select(order_id, customer_id, order_date)

unused_products <- products |>
  anti_join(orders, by = "product_id") |>
  select(product_id, product_name, category)

# Summary by region and category
regional_summary <- complete_orders |>
  filter(customer_exists) |>  # Only valid customers
  group_by(region, category) |>
  summarise(
    total_orders = n(),
    total_quantity = sum(quantity),
    total_revenue = sum(order_total),
    avg_order_value = mean(order_total),
    .groups = "drop"
  ) |>
  arrange(desc(total_revenue))

print(regional_summary)
```

**Expected Output**: Joined dataset with all order details, flagged data quality issues, and aggregated sales summary.

---

## 3. Pivoting and Reshaping for Analysis

**Scenario**: Transform wide survey data to long format for statistical analysis, then create summary tables.

```r
library(tidyverse)

# Wide format survey data (one row per respondent)
survey_wide <- tibble(
  respondent_id = 1:5,
  age = c(25, 34, 45, 29, 52),
  gender = c("F", "M", "F", "M", "F"),
  q1_satisfaction = c(4, 5, 3, 4, 5),
  q2_likelihood = c(5, 4, 3, 5, 4),
  q3_recommendation = c(4, 5, 2, 4, 5),
  q4_support = c(3, 4, 4, 5, 3)
)

# Pivot to long format for analysis
survey_long <- survey_wide |>
  pivot_longer(
    cols = starts_with("q"),
    names_to = "question",
    values_to = "score",
    names_prefix = "q"  # Remove "q" prefix
  ) |>
  separate(question, into = c("question_num", "question_topic"), sep = "_") |>
  mutate(
    question_num = as.integer(question_num),
    # Create age groups for segmentation
    age_group = case_when(
      age < 30 ~ "18-29",
      age < 40 ~ "30-39",
      age < 50 ~ "40-49",
      TRUE ~ "50+"
    )
  )

# Calculate summary statistics by question
question_summary <- survey_long |>
  group_by(question_topic) |>
  summarise(
    n_responses = n(),
    mean_score = mean(score),
    median_score = median(score),
    sd_score = sd(score),
    min_score = min(score),
    max_score = max(score),
    pct_positive = mean(score >= 4) * 100  # 4-5 considered positive
  )

# Create crosstab: age group by question topic (wide format for reporting)
age_crosstab <- survey_long |>
  group_by(age_group, question_topic) |>
  summarise(mean_score = mean(score), .groups = "drop") |>
  pivot_wider(
    names_from = question_topic,
    values_from = mean_score,
    names_prefix = "avg_"
  ) |>
  arrange(age_group)

# Pivot back to create comparative table
gender_comparison <- survey_long |>
  group_by(gender, question_topic) |>
  summarise(avg_score = round(mean(score), 2), .groups = "drop") |>
  pivot_wider(
    names_from = gender,
    values_from = avg_score
  ) |>
  mutate(
    difference = M - F,
    larger_gap = abs(difference) > 0.5
  )

print(question_summary)
print(age_crosstab)
```

**Expected Output**: Long-format analysis-ready data, summary statistics table, and demographic crosstabs.

---

## 4. Nested Modeling Workflow

**Scenario**: Fit separate models for each group, extract coefficients, and compare model performance.

```r
library(tidyverse)
library(broom)  # For tidy model outputs

# Sample dataset: sales by region and product
sales_data <- tibble(
  region = rep(c("North", "South", "East", "West"), each = 50),
  month = rep(1:50, times = 4),
  advertising_spend = runif(200, 1000, 5000),
  sales = 5000 + runif(200, -500, 500) +
         rep(c(100, -50, 75, -25), each = 50) +  # Region effect
         rnorm(200, 0, 200)
)

# Nested modeling: separate model per region
regional_models <- sales_data |>
  # Create nested data structure
  nest(data = -region) |>
  # Fit linear model for each region
  mutate(
    model = map(data, ~ lm(sales ~ advertising_spend + month, data = .x)),
    # Extract model coefficients
    coefficients = map(model, tidy),
    # Extract model statistics
    model_stats = map(model, glance),
    # Generate predictions
    predictions = map2(model, data, ~ augment(.x, newdata = .y))
  )

# Extract and compare coefficients across regions
coefficient_comparison <- regional_models |>
  select(region, coefficients) |>
  unnest(coefficients) |>
  select(region, term, estimate, std.error, p.value) |>
  # Flag statistically significant terms
  mutate(significant = p.value < 0.05) |>
  # Pivot for easy comparison
  select(region, term, estimate) |>
  pivot_wider(names_from = term, values_from = estimate)

# Extract model performance metrics
model_performance <- regional_models |>
  select(region, model_stats) |>
  unnest(model_stats) |>
  select(region, r.squared, adj.r.squared, sigma, AIC, BIC) |>
  arrange(desc(r.squared))

# Find best and worst performing regions
best_region <- model_performance |> slice_max(r.squared, n = 1)
worst_region <- model_performance |> slice_min(r.squared, n = 1)

# Extract predictions for visualization
all_predictions <- regional_models |>
  select(region, predictions) |>
  unnest(predictions) |>
  select(region, month, advertising_spend, sales, .fitted, .resid)

# Calculate prediction accuracy by region
accuracy_summary <- all_predictions |>
  group_by(region) |>
  summarise(
    mae = mean(abs(.resid)),           # Mean Absolute Error
    rmse = sqrt(mean(.resid^2)),       # Root Mean Squared Error
    mape = mean(abs(.resid / sales)) * 100,  # Mean Absolute % Error
    .groups = "drop"
  ) |>
  arrange(rmse)

print(coefficient_comparison)
print(model_performance)
print(accuracy_summary)
```

**Expected Output**: Regional model coefficients, R² comparisons, prediction accuracy metrics, and nested model objects.

---

## 5. Text Data Cleaning and Standardization

**Scenario**: Clean messy text data with inconsistent formatting, extra whitespace, and special characters.

```r
library(tidyverse)

# Messy customer feedback data
feedback <- tibble(
  id = 1:8,
  customer_name = c("  John Smith ", "JANE DOE", "Bob O'Brien",
                    "Mary-Anne Jones", "jose garcia", "李明",
                    "Dr. Susan Miller, PhD", "robert BROWN jr."),
  email = c("john@email.com", "JANE@EMAIL.COM", "bob@Email.Com",
            "mary.anne@email.com", "jose_garcia@email.com",
            "liming@email.cn", "s.miller@uni.edu", "rbrown@email.com"),
  phone = c("(555) 123-4567", "555.123.4567", "5551234567",
            "+1-555-123-4567", "555 123 4567", "5551234567",
            "(555)123-4567", "555-123-4567"),
  comment = c("Great service!!! ", "  good product  ", "TERRIBLE EXPERIENCE",
              "It's okay...", "Would recommend :)", "非常好",
              "Needs improvement.", "Best purchase ever!!!")
)

# Comprehensive text cleaning pipeline
cleaned_feedback <- feedback |>
  mutate(
    # Standardize names: Title Case, trim whitespace
    customer_name = str_to_title(str_squish(customer_name)),

    # Normalize email: lowercase, trim
    email = str_to_lower(str_trim(email)),

    # Standardize phone: extract digits only, format consistently
    phone_digits = str_extract_all(phone, "\\d") |>
                   map_chr(~ paste(.x, collapse = "")),
    phone_clean = str_replace(phone_digits,
                             "(\\d{3})(\\d{3})(\\d{4})",
                             "(\\1) \\2-\\3"),

    # Clean comments: trim, remove extra punctuation
    comment_clean = str_squish(comment) |>
                    str_remove_all("!{2,}") |>  # Multiple exclamation marks
                    str_remove_all("\\.{2,}"),   # Multiple periods

    # Extract sentiment indicators
    has_positive = str_detect(str_to_lower(comment),
                             "great|good|best|recommend"),
    has_negative = str_detect(str_to_lower(comment),
                             "terrible|worst|bad|poor"),

    # Categorize sentiment
    sentiment = case_when(
      has_positive & !has_negative ~ "positive",
      has_negative & !has_positive ~ "negative",
      has_positive & has_negative ~ "mixed",
      TRUE ~ "neutral"
    ),

    # Extract special characters count (non-English indicator)
    has_special_chars = str_detect(comment, "[^\\x00-\\x7F]"),

    # Length metrics
    name_length = str_length(customer_name),
    comment_length = str_length(comment_clean),
    comment_words = str_count(comment_clean, "\\w+")
  ) |>
  # Select final columns
  select(id, customer_name, email, phone_clean,
         comment_clean, sentiment, comment_words, has_special_chars)

# Create summary of text cleaning
cleaning_summary <- tibble(
  metric = c("Names cleaned", "Emails normalized", "Phones standardized",
             "Comments cleaned", "Positive comments", "Negative comments"),
  count = c(
    sum(feedback$customer_name != cleaned_feedback$customer_name),
    sum(feedback$email != cleaned_feedback$email),
    sum(feedback$phone != cleaned_feedback$phone_clean),
    sum(feedback$comment != cleaned_feedback$comment_clean),
    sum(cleaned_feedback$sentiment == "positive"),
    sum(cleaned_feedback$sentiment == "negative")
  )
)

print(cleaned_feedback)
print(cleaning_summary)
```

**Expected Output**: Standardized names/emails/phones, cleaned comments, sentiment classification, and cleaning metrics.

---

## 6. Date-Time Manipulation and Aggregation

**Scenario**: Process timestamped transactions, extract temporal features, and aggregate by multiple time periods.

```r
library(tidyverse)
library(lubridate)

# Transaction data with timestamps
transactions <- tibble(
  transaction_id = 1:100,
  timestamp = as.POSIXct("2024-01-01 00:00:00") +
              runif(100, 0, 90 * 24 * 3600),  # Random times over 90 days
  amount = rnorm(100, mean = 100, sd = 30),
  customer_id = sample(1:20, 100, replace = TRUE)
)

# Comprehensive date-time feature engineering
transactions_enriched <- transactions |>
  mutate(
    # Extract date components
    date = as.Date(timestamp),
    year = year(timestamp),
    month = month(timestamp, label = TRUE, abbr = FALSE),
    week = week(timestamp),
    day = day(timestamp),
    weekday = wday(timestamp, label = TRUE, abbr = FALSE),
    hour = hour(timestamp),

    # Create time-based categories
    quarter = quarter(timestamp, with_year = TRUE),
    is_weekend = weekday %in% c("Saturday", "Sunday"),
    time_of_day = case_when(
      hour < 6 ~ "Night",
      hour < 12 ~ "Morning",
      hour < 18 ~ "Afternoon",
      TRUE ~ "Evening"
    ),

    # Business day calculations
    is_business_hours = hour >= 9 & hour < 17 & !is_weekend,

    # Days since start of data
    days_since_start = as.numeric(difftime(date, min(date), units = "days"))
  )

# Daily aggregation
daily_summary <- transactions_enriched |>
  group_by(date) |>
  summarise(
    n_transactions = n(),
    total_amount = sum(amount),
    avg_amount = mean(amount),
    unique_customers = n_distinct(customer_id),
    .groups = "drop"
  ) |>
  # Add rolling averages
  mutate(
    roll_avg_7day = slider::slide_dbl(total_amount, mean,
                                       .before = 6, .complete = TRUE),
    roll_avg_30day = slider::slide_dbl(total_amount, mean,
                                        .before = 29, .complete = TRUE)
  )

# Weekly aggregation (by week and weekday)
weekly_pattern <- transactions_enriched |>
  group_by(week, weekday) |>
  summarise(
    n_transactions = n(),
    total_amount = sum(amount),
    .groups = "drop"
  ) |>
  # Calculate average pattern across all weeks
  group_by(weekday) |>
  summarise(
    avg_transactions = mean(n_transactions),
    avg_amount = mean(total_amount)
  )

# Hourly patterns
hourly_pattern <- transactions_enriched |>
  group_by(hour, is_weekend) |>
  summarise(
    n_transactions = n(),
    avg_amount = mean(amount),
    .groups = "drop"
  ) |>
  mutate(day_type = if_else(is_weekend, "Weekend", "Weekday"))

# Time period comparison
period_comparison <- transactions_enriched |>
  mutate(
    period = if_else(days_since_start < 45, "First 45 Days", "Last 45 Days")
  ) |>
  group_by(period) |>
  summarise(
    total_transactions = n(),
    total_revenue = sum(amount),
    avg_transaction = mean(amount),
    unique_customers = n_distinct(customer_id),
    .groups = "drop"
  ) |>
  # Calculate growth metrics
  mutate(
    pct_change = (total_revenue / lag(total_revenue) - 1) * 100
  )

print(head(daily_summary, 10))
print(weekly_pattern)
print(period_comparison)
```

**Expected Output**: Enriched transactions with temporal features, daily/weekly aggregations, and period-over-period comparisons.

---

## 7. Factor Reordering for Visualization

**Scenario**: Prepare categorical data with optimal factor ordering for clear, informative plots.

```r
library(tidyverse)
library(forcats)

# Product sales by category
product_sales <- tibble(
  product = c("Widget A", "Widget B", "Widget C", "Gadget X", "Gadget Y",
              "Tool M", "Tool N", "Tool P", "Accessory 1", "Accessory 2"),
  category = c("Widgets", "Widgets", "Widgets", "Gadgets", "Gadgets",
               "Tools", "Tools", "Tools", "Accessories", "Accessories"),
  sales = c(15000, 8500, 23000, 45000, 12000,
            5500, 18000, 9500, 3200, 6800),
  margin_pct = c(35, 42, 28, 45, 38, 52, 31, 44, 58, 49),
  units_sold = c(150, 85, 230, 300, 100, 75, 200, 110, 95, 125)
)

# Factor reordering strategies
sales_prepared <- product_sales |>
  mutate(
    # 1. Order by frequency (most common first)
    category_by_freq = fct_infreq(category),

    # 2. Order by another variable (descending sales)
    category_by_sales = fct_reorder(category, sales, .fun = sum, .desc = TRUE),
    product_by_sales = fct_reorder(product, sales, .desc = TRUE),

    # 3. Reverse order
    product_reverse = fct_rev(product_by_sales),

    # 4. Manually specify order (strategic grouping)
    category_manual = fct_relevel(category,
                                  "Tools", "Widgets", "Gadgets", "Accessories"),

    # 5. Lump small categories together
    category_lumped = fct_lump_n(category, n = 2, w = sales,
                                 other_level = "Other Products"),

    # 6. Collapse specific levels
    category_collapsed = fct_collapse(category,
      "Core Products" = c("Widgets", "Gadgets"),
      "Specialty Items" = c("Tools", "Accessories")
    ),

    # 7. Recode for clearer labels
    category_clean = fct_recode(category,
      "Widget Line" = "Widgets",
      "Gadget Line" = "Gadgets",
      "Tool Collection" = "Tools",
      "Accessory Items" = "Accessories"
    )
  )

# Create visualization-ready summary
viz_summary <- product_sales |>
  # Order categories by total sales
  mutate(category = fct_reorder(category, sales, .fun = sum)) |>
  # Order products within categories by margin
  mutate(product = fct_reorder(product, margin_pct)) |>
  arrange(category, desc(margin_pct))

# Top/bottom performers with meaningful ordering
top_bottom <- product_sales |>
  mutate(
    performance = case_when(
      sales >= quantile(sales, 0.75) ~ "Top Performers",
      sales <= quantile(sales, 0.25) ~ "Low Performers",
      TRUE ~ "Mid Performers"
    ),
    # Order performance levels logically
    performance = fct_relevel(performance,
                             "Top Performers", "Mid Performers", "Low Performers"),
    # Order products by sales within each performance tier
    product = fct_reorder(product, sales)
  ) |>
  select(product, category, sales, margin_pct, performance)

# Category summary with ordered factors
category_summary <- product_sales |>
  group_by(category) |>
  summarise(
    total_sales = sum(sales),
    avg_margin = mean(margin_pct),
    product_count = n(),
    .groups = "drop"
  ) |>
  # Order by total sales for visualization
  mutate(category = fct_reorder(category, total_sales, .desc = TRUE))

print(head(viz_summary))
print(category_summary)
```

**Expected Output**: Properly ordered factors for bar charts, rankings, and categorical comparisons ready for ggplot2.

---

## Notes

- All examples use base R and tidyverse packages (no additional dependencies except where noted)
- Code includes extensive comments explaining each step
- Examples demonstrate defensive programming with NA handling
- Output summaries provided to verify results
- Patterns are production-ready and follow tidyverse style guidelines
