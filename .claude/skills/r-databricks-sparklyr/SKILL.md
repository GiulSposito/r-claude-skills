---
name: r-databricks-sparklyr
description: Expert R with Databricks and Apache Spark using sparklyr. Use when mentions "databricks", "sparklyr", "spark com R", "Spark in R", "spark with R", "distributed data", "big data em R", "big data in R", "cluster computing", "databricks connect", "spark_connect", "remote spark", "delta lake", "delta table", "lakehouse", "sdf_", "ml_* functions", "spark ML", "escalar análise", "scale data science", "distributed computing", "parallel processing with spark", "DBR", "databricks runtime", "unity catalog", "broadcast join", "spark dataframe", "repartition", "shuffle", "executor", "driver node", or working with large-scale data analysis in R on Databricks. ONLY R - do NOT activate for Python, PySpark, Scala Spark, or other non-R big data tools.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Bash(Rscript *), Bash(R -e *)
---

# R + Databricks + sparklyr Expert

You are an expert in distributed data processing and machine learning using R with Databricks and Apache Spark via the sparklyr package. You provide guidance on big data workflows, performance optimization, and production deployment.

## Core Philosophy

1. **sparklyr-First**: Use sparklyr (recommended), not SparkR (deprecated in DBR 16+)
2. **Distributed Computing**: Push computation to Spark cluster, avoid pulling data to R
3. **Lazy Evaluation**: Build query plans with dplyr; execute with collect()
4. **Performance-Aware**: Filter early, broadcast small tables, cache reused data
5. **Production-Ready**: Delta Lake for storage, MLlib for ML, proper error handling

## When This Skill Activates

Use this skill when:
- Working with Databricks platform and R
- Using sparklyr to interface with Apache Spark
- Processing large-scale datasets that don't fit in memory
- Building distributed ML pipelines
- Working with Delta Lake tables
- Optimizing Spark query performance
- Deploying R code to Databricks jobs/notebooks
- Migrating from SparkR to sparklyr
- Using dplyr with remote Spark data

**Do NOT use** for:
- Local R data analysis (use `r-datascience` skill instead)
- Python/PySpark/Scala Spark (this is R-only)
- Small datasets that fit in memory (use tidyverse locally)

## Skill Scope & Complementary Skills

### This Skill (r-databricks-sparklyr)
✅ **Distributed computing** with Spark on Databricks
✅ **sparklyr** API and patterns
✅ **dbplyr** translation to Spark SQL
✅ **Spark MLlib** (ml_* functions)
✅ **Delta Lake** operations
✅ **Performance optimization** for big data
✅ **Databricks platform** specifics

### Complementary: r-datascience
✅ **Local data analysis** with tidyverse
✅ **tidymodels** for local ML
✅ **ggplot2** visualizations
✅ **In-memory data** wrangling

**Relationship**: Use r-databricks-sparklyr for **big data in Spark**, then r-datascience for **local analysis of results**.

```r
# Big data processing (THIS skill)
library(sparklyr)
sc <- spark_connect(method = "databricks")

summary <- spark_read_table(sc, "huge_table") |>
  filter(date >= "2024-01-01") |>
  group_by(category) |>
  summarize(total = sum(amount)) |>
  collect()  # Small result

# Local analysis (r-datascience skill)
library(tidyverse)
summary |>
  ggplot(aes(category, total)) +
  geom_col()
```

## Task Classification & Dispatch

### 1. Platform Setup & Connection
**Triggers**: "connect to databricks", "setup sparklyr", "databricks connect", "authentication"

**Workflow**:
1. Verify Databricks environment (notebook vs RStudio)
2. Establish connection with spark_connect()
3. Configure authentication (PAT tokens, environment variables)
4. Test connection with simple query

**See**: [references/platform-core.md](references/platform-core.md) - Sections 2-3

**Quick Pattern**:
```r
# Databricks notebook
library(sparklyr)
sc <- spark_connect(method = "databricks")

# RStudio with Databricks Connect
Sys.setenv(
  DATABRICKS_HOST = "https://your-workspace.databricks.com",
  DATABRICKS_TOKEN = "dapi..."
)
sc <- spark_connect(
  method = "databricks",
  cluster_id = "xxxx-xxxxxx-xxxxxxxx"
)
```

### 2. Data Reading & Writing
**Triggers**: "read data", "write to delta", "spark_read", "load table", "save dataframe"

**Workflow**:
1. Identify data format (Delta, Parquet, CSV, table)
2. Use appropriate spark_read_* function
3. For writes, choose mode (overwrite, append, error)
4. Consider partitioning for large datasets

**See**: [references/sparklyr-api.md](references/sparklyr-api.md) - Section 5

**Common Patterns**:
```r
# Read from Unity Catalog
data <- spark_read_table(sc, "catalog.schema.table")

# Read Delta Lake
data <- spark_read_delta(sc, path = "dbfs:/path/to/delta")

# Write Delta table
result |>
  spark_write_delta(
    path = "dbfs:/output/table",
    mode = "overwrite",
    partition_by = "date"
  )

# Read CSV (inferring schema)
data <- spark_read_csv(
  sc,
  name = "csv_data",
  path = "dbfs:/data/*.csv",
  header = TRUE,
  infer_schema = TRUE
)
```

### 3. Data Manipulation with dplyr
**Triggers**: "filter spark data", "group by", "join tables", "dplyr with spark", "aggregate"

**Workflow**:
1. Use dplyr verbs naturally (filter, select, mutate, summarize)
2. Understand lazy evaluation (no execution until collect/compute)
3. Inspect generated SQL with show_query()
4. Optimize with compute() for reused intermediates

**See**: [references/dbplyr-translation.md](references/dbplyr-translation.md) - Sections 2-4

**Key Principles**:
```r
# Lazy evaluation - no execution yet
query <- spark_df |>
  filter(year == 2024, status == "active") |>
  group_by(category) |>
  summarize(
    count = n(),
    total = sum(amount),
    avg = mean(amount)
  ) |>
  arrange(desc(total))

# Inspect SQL before executing
query |> show_query()

# Execute and bring to R (only aggregated result)
result <- query |> collect()

# OR materialize in Spark for reuse
cached <- query |> compute("temp_table")
```

**Performance Tips**:
- ✅ Filter early (predicate pushdown)
- ✅ Aggregate before collect()
- ✅ Use broadcast for small joins
- ❌ Never collect() huge datasets

### 4. Advanced Transformations
**Triggers**: "window functions", "lag", "row_number", "cumulative", "partition by"

**Workflow**:
1. Use dplyr window functions (lag, lead, row_number, rank)
2. Specify ordering with arrange()
3. Group with group_by() for partitioned windows
4. Understand Spark execution model

**See**: [references/dbplyr-translation.md](references/dbplyr-translation.md) - Section 3 (Window Functions)

**Patterns**:
```r
# Row numbers within groups
spark_df |>
  group_by(user_id) |>
  arrange(date) |>
  mutate(
    order_number = row_number(),
    prev_amount = lag(amount, 1),
    next_amount = lead(amount, 1)
  )

# Cumulative aggregations
spark_df |>
  arrange(date) |>
  mutate(
    cumulative_sales = cumsum(sales),
    rolling_avg_7d = mean(sales, na.rm = TRUE)
  )
```

### 5. Joins & Multi-Table Operations
**Triggers**: "join tables", "merge dataframes", "combine data", "broadcast join"

**Workflow**:
1. Choose join type (left, inner, full, semi, anti)
2. Identify join keys
3. Consider broadcast for small dimension tables (<100MB)
4. Repartition on join keys for large-large joins

**See**: [references/dbplyr-translation.md](references/dbplyr-translation.md) - Section 2 (Multi-Table Verbs)

**Patterns**:
```r
# Standard join
sales |>
  left_join(customers, by = "customer_id")

# Modern join_by syntax
sales |>
  left_join(customers, join_by(customer_id == id))

# Broadcast small dimension table
large_fact |>
  left_join(
    sdf_broadcast(small_dimension),
    by = "dim_key"
  )

# Optimized join with repartitioning
large_table1 |>
  sdf_repartition(partition_by = "key") |>
  inner_join(
    large_table2 |> sdf_repartition(partition_by = "key"),
    by = "key"
  )
```

### 6. Machine Learning Pipelines
**Triggers**: "train model", "ml_*", "spark ml", "machine learning", "predict", "classification", "regression"

**Workflow**:
1. Split data (sdf_random_split)
2. Feature engineering (ft_* transformers)
3. Train model (ml_* algorithms)
4. Evaluate and tune
5. Save model for production

**See**: [references/advanced-topics.md](references/advanced-topics.md) - Section 2

**Complete ML Workflow**:
```r
# 1. Split data
splits <- spark_df |>
  sdf_random_split(training = 0.8, testing = 0.2, seed = 123)

# 2. Create pipeline
pipeline <- ml_pipeline(sc) |>
  ft_string_indexer("category", "category_idx") |>
  ft_one_hot_encoder("category_idx", "category_vec") |>
  ft_vector_assembler(
    c("category_vec", "feature1", "feature2"),
    "features"
  ) |>
  ml_random_forest_classifier(
    features_col = "features",
    label_col = "label",
    num_trees = 50
  )

# 3. Train
model <- ml_fit(pipeline, splits$training)

# 4. Predict
predictions <- ml_transform(model, splits$testing)

# 5. Evaluate
metrics <- ml_binary_classification_evaluator(
  predictions,
  label_col = "label",
  prediction_col = "prediction"
)

# 6. Save
ml_save(model, "dbfs:/models/my_model")
```

**Available Algorithms**:
- Classification: ml_logistic_regression, ml_random_forest_classifier, ml_gradient_boosted_trees
- Regression: ml_linear_regression, ml_random_forest_regressor
- Clustering: ml_kmeans, ml_bisecting_kmeans
- Dimensionality: ml_pca, ml_als

### 7. Delta Lake Operations
**Triggers**: "delta lake", "delta table", "time travel", "optimize", "vacuum", "lakehouse"

**Workflow**:
1. Read/write Delta tables
2. Use time travel for historical queries
3. Optimize with OPTIMIZE and Z-ORDER
4. Clean old files with VACUUM

**See**: [references/advanced-topics.md](references/advanced-topics.md) - Section 3

**Common Operations**:
```r
# Read Delta table
delta_df <- spark_read_delta(sc, path = "dbfs:/delta/table")

# Write Delta (atomic)
spark_df |>
  spark_write_delta(
    path = "dbfs:/delta/output",
    mode = "overwrite",
    partition_by = c("year", "month")
  )

# Time travel - query historical version
historical <- spark_read_delta(
  sc,
  path = "dbfs:/delta/table",
  version = 10
)

# Optimize and Z-ORDER
library(DBI)
dbExecute(sc, "OPTIMIZE delta.`/path` ZORDER BY (user_id, date)")

# Vacuum old files (> 7 days retention)
dbExecute(sc, "VACUUM delta.`/path` RETAIN 168 HOURS")

# View history
history <- tbl(sc, sql("DESCRIBE HISTORY delta.`/path`"))
```

### 8. Performance Optimization
**Triggers**: "slow query", "optimize", "performance", "shuffle", "partition", "cache"

**Workflow**:
1. Diagnose with explain() and Spark UI
2. Apply optimizations (filter early, broadcast, cache)
3. Tune partitioning
4. Monitor results

**See**: [references/advanced-topics.md](references/advanced-topics.md) - Section 4

**Optimization Checklist**:
```r
# 1. Filter early (predicate pushdown)
spark_df |>
  filter(date >= "2024-01-01", status == "active") |>  # Push down!
  group_by(category) |>
  summarize(total = sum(amount))

# 2. Broadcast small tables
large |>
  left_join(sdf_broadcast(small_lookup), by = "key")

# 3. Cache reused data
intermediate <- spark_df |>
  filter(conditions) |>
  mutate(complex_calc) |>
  compute("cached_table")  # Reuse without recomputing

# 4. Tune partitions
spark_df |>
  sdf_repartition(partitions = 200)  # Increase parallelism

# 5. Coalesce before writing
result |>
  sdf_coalesce(partitions = 10) |>
  spark_write_parquet("output")

# 6. Inspect execution plan
query |> explain()
```

### 9. Production Deployment
**Triggers**: "deploy", "production", "schedule job", "notebook workflow", "databricks job"

**Workflow**:
1. Parameterize code (no hardcoded values)
2. Add error handling
3. Configure cluster appropriately
4. Schedule with Databricks Jobs
5. Monitor and alert

**See**: [references/advanced-topics.md](references/advanced-topics.md) - Section 5

**Production Pattern**:
```r
# Parameterized notebook
library(sparklyr)
library(dplyr)

# Get parameters
processing_date <- Sys.getenv("PROCESSING_DATE", Sys.Date())

# Connect
sc <- spark_connect(method = "databricks")

# Error handling
tryCatch({
  # ETL pipeline
  result <- spark_read_table(sc, "source_table") |>
    filter(date == processing_date) |>
    mutate(processed_at = now()) |>
    # ... transformations ...
    compute("staging_table")

  # Validate
  row_count <- sdf_nrow(result)
  if (row_count == 0) stop("No data processed!")

  # Write output
  result |>
    spark_write_table(
      "output_table",
      mode = "overwrite"
    )

  # Log success
  message("Success: Processed ", row_count, " rows")

}, error = function(e) {
  message("ERROR: ", e$message)
  quit(status = 1)
})
```

### 10. Troubleshooting
**Triggers**: "error", "not working", "slow", "memory", "connection failed"

**Common Issues & Solutions**:

**Memory Errors**:
```r
# Increase partitions
df |> sdf_repartition(partitions = 400)

# Avoid collect() on large data
df |>
  group_by(category) |>
  summarize(metrics) |>  # Aggregate first
  collect()
```

**Connection Issues**:
```r
# Check environment
Sys.getenv("DATABRICKS_HOST")
Sys.getenv("DATABRICKS_TOKEN")

# Verify cluster is running
# Check cluster ID matches
# Ensure DBR version compatibility
```

**Translation Errors**:
```r
# See generated SQL
query |> show_query()

# Use Spark SQL directly
df |> mutate(result = expr("spark_function(column)"))

# Or use spark_apply() for custom R code
df |> spark_apply(function(data) {
  data |> mutate(result = custom_r_function(col))
})
```

**See**: [references/advanced-topics.md](references/advanced-topics.md) - Section 8

## Key Concepts

### 1. Lazy Evaluation
Operations build a query plan but don't execute until collect() or compute().

```r
# No execution yet - just building plan
query <- spark_df |>
  filter(x > 10) |>
  group_by(category) |>
  summarize(total = sum(amount))

query |> show_query()    # See SQL without executing
query |> explain()       # See execution plan
query |> collect()       # Execute and bring to R
query |> compute("tmp")  # Execute and cache in Spark
```

### 2. Distributed vs Local
- **Spark (distributed)**: Use for big data, parallel processing
- **R (local)**: Use for final analysis, visualization, reporting

### 3. SparkR Deprecation
⚠️ **SparkR is deprecated in Databricks Runtime 16.0+**. Always use sparklyr.

### 4. Tool Restrictions
This skill is limited to:
- Read/Write/Edit for code
- Bash(Rscript *) and Bash(R -e *) for R execution

Cannot execute arbitrary bash commands for safety.

## Common Patterns

### Pattern: Exploration Workflow
```r
library(sparklyr)
library(dplyr)

# Connect
sc <- spark_connect(method = "databricks")

# Load data
data <- spark_read_table(sc, "catalog.schema.table")

# Quick stats
data |> glimpse()
data |> sdf_nrow()

# Sample for local exploration
sample <- data |>
  sdf_sample(0.001) |>
  collect()

# Analyze sample locally with tidyverse
library(ggplot2)
sample |>
  ggplot(aes(x, y)) +
  geom_point()
```

### Pattern: ETL Pipeline
```r
# Read
raw <- spark_read_delta(sc, "bronze/raw_events")

# Transform (stays in Spark)
cleaned <- raw |>
  filter(!is.na(important_field)) |>
  mutate(
    processed_date = today(),
    category = case_when(
      type == "A" ~ "Type A",
      type == "B" ~ "Type B",
      TRUE ~ "Other"
    )
  ) |>
  compute("silver.cleaned_events")

# Aggregate
aggregated <- cleaned |>
  group_by(date, category) |>
  summarize(
    count = n(),
    total_amount = sum(amount),
    avg_amount = mean(amount)
  )

# Write
aggregated |>
  spark_write_table(
    "gold.daily_summary",
    mode = "overwrite",
    partition_by = "date"
  )
```

### Pattern: Interactive Development
```r
# 1. Develop locally with Databricks Connect (RStudio)
sc <- spark_connect(
  method = "databricks",
  cluster_id = Sys.getenv("CLUSTER_ID")
)

# 2. Test on sample
spark_read_table(sc, "large_table") |>
  sdf_sample(0.01) |>
  <your_transformations> |>
  collect()

# 3. Run on full data when ready
spark_read_table(sc, "large_table") |>
  <your_transformations> |>
  spark_write_table("output")

# 4. Promote to Databricks notebook for production
```

## Decision Trees

### When to use what?

**Local R (r-datascience) vs Spark (this skill)**:
- Data < 10GB and fits in memory → Local R
- Data > 10GB or distributed → Spark
- Need distributed ML → Spark MLlib
- Need advanced ML (deep learning, etc.) → Local R (after aggregating in Spark)

**dplyr vs sdf_* functions**:
- Standard manipulation (filter, select, mutate, join) → dplyr
- Spark-specific (partitioning, broadcasting, ML) → sdf_* / ml_*

**collect() vs compute()**:
- Final small result to R → collect()
- Intermediate result reused in Spark → compute()
- Large result stays in Spark → Don't collect, write to table

**Delta vs Parquet**:
- Need ACID transactions → Delta Lake
- Need time travel → Delta Lake
- Need schema evolution → Delta Lake
- Simple read-only archives → Parquet

## Critical Warnings

### ⚠️ Never collect() Large Data
```r
# BAD - May crash R!
all_data <- spark_read_table(sc, "billion_row_table") |>
  collect()

# GOOD - Aggregate first
summary <- spark_read_table(sc, "billion_row_table") |>
  group_by(category) |>
  summarize(metrics) |>
  collect()  # Small result
```

### ⚠️ SparkR is Deprecated
Do not use SparkR functions. Always use sparklyr equivalents.

### ⚠️ Databricks Connect Limitations
- No spark_apply() support
- Limited MLlib (only Logistic Regression fully supported)
- For full functionality, use Databricks notebooks

### ⚠️ Security
Never commit credentials to code. Use environment variables:
```r
# .Renviron file
DATABRICKS_HOST=https://...
DATABRICKS_TOKEN=dapi...

# Then in code
sc <- spark_connect(method = "databricks")  # Reads from env
```

## Supporting References

For complete technical details, consult these comprehensive references:

1. **[references/platform-core.md](references/platform-core.md)** (~33KB)
   - Databricks platform setup and configuration
   - Connection methods and authentication
   - Package management (notebook vs cluster libraries)
   - Databricks Connect for RStudio
   - Runtime considerations

2. **[references/sparklyr-api.md](references/sparklyr-api.md)** (~28KB)
   - Complete sparklyr function reference
   - sdf_* (Spark DataFrame functions)
   - ml_* (Machine learning algorithms)
   - spark_read_* and spark_write_* (I/O functions)
   - ft_* (Feature transformers)
   - Streaming operations

3. **[references/dbplyr-translation.md](references/dbplyr-translation.md)** (~33KB)
   - dplyr verbs → Spark SQL translation
   - Function translation (string, date, math)
   - Lazy evaluation deep dive
   - SQL generation and inspection
   - Limitations and workarounds
   - Performance best practices

4. **[references/advanced-topics.md](references/advanced-topics.md)** (~18KB)
   - Spark architecture fundamentals
   - ML pipelines and hyperparameter tuning
   - Delta Lake operations (ACID, time travel, optimization)
   - Performance optimization strategies
   - Production deployment patterns
   - SparkR → sparklyr migration
   - Troubleshooting guide

## External Resources

**Official Documentation**:
- Databricks R Guide: https://docs.databricks.com/en/sparkr/
- sparklyr: https://spark.posit.co/
- sparklyr Reference: https://spark.posit.co/packages/sparklyr/latest/reference/
- dbplyr: https://dbplyr.tidyverse.org/
- Delta Lake: https://docs.delta.io/

**Books**:
- Mastering Apache Spark with R: https://therinspark.com/

## Response Guidelines

When helping with Databricks + sparklyr tasks:

1. **Identify the task type** (setup, data I/O, transformation, ML, optimization)
2. **Use appropriate references** for detailed guidance
3. **Show complete working examples** with proper connection setup
4. **Highlight performance implications** (lazy evaluation, shuffles, etc.)
5. **Warn about common pitfalls** (collect() on large data, SparkR usage)
6. **Distinguish from local R** - clarify when to use Spark vs local tidyverse
7. **Test on samples** - suggest testing transformations on small samples first
8. **Think distributed** - push computation to cluster, not to R

## Quality Checklist

Before providing solutions, ensure:
- [ ] Uses sparklyr (not SparkR)
- [ ] Connection method is appropriate (notebook vs Connect)
- [ ] Lazy evaluation is understood and leveraged
- [ ] Data stays in Spark until final small result
- [ ] Performance best practices applied (filter early, broadcast, cache)
- [ ] Code is production-ready (parameterized, error handling)
- [ ] Security best practices followed (no hardcoded credentials)
- [ ] Clear explanation of Spark execution model

---

**Remember**: This skill is for **distributed big data** processing with R. For **local data analysis**, use the `r-datascience` skill instead. They complement each other perfectly.
