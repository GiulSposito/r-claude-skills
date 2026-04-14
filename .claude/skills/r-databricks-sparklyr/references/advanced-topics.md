# Advanced Topics & Resources

## 1. Spark Architecture Fundamentals

### Core Concepts

**Spark Execution Model**:
- **Driver**: Coordinates execution, runs main() program
- **Executors**: Distributed workers that execute tasks and store data
- **Cluster Manager**: Allocates resources (Databricks manages this)

**Data Distribution**:
- **Partitions**: Data divided into chunks, processed in parallel
- **Shuffle**: Data redistribution across partitions (expensive operation)
- **Broadcasting**: Sending small data to all executors efficiently

### Databricks-Specific Architecture

- **Databricks Runtime**: Optimized Spark distribution with additional libraries
- **Cluster Types**:
  - All-purpose clusters: Interactive development
  - Job clusters: Automated workflows
  - Serverless: Pay-per-query, no cluster management

**Key Principle**: Most R code runs on the driver; Spark operations run on executors. Use sparklyr to push computation to executors.

## 2. Machine Learning Pipelines

### ML Workflow with sparklyr

```r
library(sparklyr)
library(dplyr)

# 1. Connect
sc <- spark_connect(method = "databricks")

# 2. Load data
data <- spark_read_table(sc, "training_data")

# 3. Split
splits <- data |>
  sdf_random_split(training = 0.8, testing = 0.2, seed = 123)

# 4. Train model
model <- splits$training |>
  ml_logistic_regression(
    label ~ feature1 + feature2 + feature3
  )

# 5. Evaluate
predictions <- ml_predict(model, splits$testing)

metrics <- ml_metrics(predictions, label, prediction)
print(metrics)

# 6. Save model
ml_save(model, "path/to/model")
```

### Available ML Algorithms (ml_*)

**Classification**:
- `ml_logistic_regression()` - Binary/multiclass classification
- `ml_random_forest_classifier()` - Tree ensemble
- `ml_gradient_boosted_trees()` - Boosted trees
- `ml_naive_bayes()` - Probabilistic classifier
- `ml_decision_tree_classifier()` - Single decision tree

**Regression**:
- `ml_linear_regression()` - Linear regression
- `ml_random_forest_regressor()` - Random forest regression
- `ml_gradient_boosted_trees_regressor()` - GBT regression
- `ml_generalized_linear_regression()` - GLM

**Clustering**:
- `ml_kmeans()` - K-means clustering
- `ml_bisecting_kmeans()` - Hierarchical K-means
- `ml_gaussian_mixture()` - GMM clustering

**Dimensionality Reduction**:
- `ml_pca()` - Principal component analysis
- `ml_als()` - Alternating Least Squares (collaborative filtering)

**Feature Engineering** (ft_*):
- `ft_string_indexer()` - Encode categorical variables
- `ft_one_hot_encoder()` - One-hot encoding
- `ft_vector_assembler()` - Combine features
- `ft_standard_scaler()` - Standardize features
- `ft_bucketizer()` - Discretize continuous variables
- `ft_pca()` - PCA transformation

### ML Pipelines

```r
# Create pipeline
pipeline <- ml_pipeline(sc) |>
  ft_string_indexer("category", "category_idx") |>
  ft_one_hot_encoder("category_idx", "category_vec") |>
  ft_vector_assembler(
    c("category_vec", "numeric_feature1", "numeric_feature2"),
    "features"
  ) |>
  ml_random_forest_classifier(features_col = "features", label_col = "label")

# Fit pipeline
pipeline_model <- ml_fit(pipeline, training_data)

# Transform new data
predictions <- ml_transform(pipeline_model, test_data)
```

### Hyperparameter Tuning

```r
# Cross-validation
cv <- ml_cross_validator(
  sc,
  estimator = pipeline,
  evaluator = ml_binary_classification_evaluator(sc, label_col = "label"),
  estimator_param_maps = list(
    random_forest = list(
      num_trees = c(10, 20, 50),
      max_depth = c(5, 10, 15)
    )
  ),
  num_folds = 5
)

cv_model <- ml_fit(cv, training_data)
best_model <- ml_best_model(cv_model)
```

### MLlib Limitations in Databricks Connect

**From documentation**:
- Limited ML support via Databricks Connect
- Only Logistic Regression fully supported (starting DBR 14.1)
- Most ml_* functions require full cluster environment
- For production ML: Use notebooks or jobs, not Databricks Connect

## 3. Delta Lake Integration

### What is Delta Lake

**Delta Lake** provides ACID transactions and reliability on top of cloud data lakes. It's the default storage format in Databricks.

**Key Features**:
- ✅ ACID transactions
- ✅ Schema enforcement and evolution
- ✅ Time travel (query historical versions)
- ✅ Upserts and deletes
- ✅ Audit trail

### Reading Delta Tables

```r
# Method 1: spark_read_table() - for cataloged tables
delta_df <- spark_read_table(sc, "catalog.schema.table")

# Method 2: spark_read_delta() - for paths
delta_df <- spark_read_delta(sc, path = "dbfs:/path/to/delta/table")

# Method 3: Unity Catalog (three-level namespace)
library(dbplyr)
delta_df <- tbl(sc, in_catalog("catalog_name", "schema_name", "table_name"))
```

### Writing Delta Tables

```r
# Write new table
spark_df |>
  spark_write_delta(
    path = "dbfs:/path/to/delta/table",
    mode = "overwrite"  # or "append", "error", "ignore"
  )

# Write to catalog
spark_df |>
  spark_write_table(
    name = "catalog.schema.table",
    mode = "overwrite"
  )
```

### Time Travel

```r
# Query as of specific version
historical <- spark_read_delta(
  sc,
  path = "dbfs:/path/to/table",
  version = 5
)

# Query as of timestamp
historical <- spark_read_delta(
  sc,
  path = "dbfs:/path/to/table",
  timestamp = as.POSIXct("2024-01-01")
)

# View table history
history <- tbl(sc, sql("DESCRIBE HISTORY delta.`/path/to/table`"))
history |> collect()
```

### Optimization Operations

```r
# OPTIMIZE: Compact small files
DBI::dbExecute(sc, "OPTIMIZE catalog.schema.table")

# VACUUM: Remove old files (beyond retention)
DBI::dbExecute(sc, "VACUUM catalog.schema.table RETAIN 168 HOURS")

# Z-ORDER: Co-locate related data
DBI::dbExecute(sc, "OPTIMIZE catalog.schema.table ZORDER BY (date, customer_id)")
```

### Schema Evolution

```r
# Add columns automatically
spark_df_with_new_column |>
  spark_write_table(
    name = "my_table",
    mode = "append",
    options = list(mergeSchema = "true")
  )
```

### Lakehouse Architecture Patterns

**Medallion Architecture**:
- **Bronze**: Raw ingested data (as-is)
- **Silver**: Cleaned, validated, enriched data
- **Gold**: Business-level aggregates, ready for analytics

```r
# Bronze layer
raw_data |>
  spark_write_delta(path = "bronze/events", mode = "append")

# Silver layer
bronze <- spark_read_delta(sc, "bronze/events")
silver <- bronze |>
  filter(!is.na(important_field)) |>
  mutate(processed_date = today()) |>
  compute("silver.events")

# Gold layer
gold <- silver |>
  group_by(date, product) |>
  summarize(
    total_sales = sum(amount),
    total_units = sum(quantity)
  ) |>
  spark_write_table("gold.daily_sales")
```

## 4. Performance Optimization

### Query Optimization Best Practices

**1. Filter Early (Predicate Pushdown)**:
```r
# GOOD: Filter at source
spark_read_table(sc, "large_table") |>
  filter(date >= "2024-01-01") |>  # Pushed down to storage
  group_by(category) |>
  summarize(total = sum(amount))

# BAD: Filter after aggregation
spark_read_table(sc, "large_table") |>
  group_by(category) |>
  summarize(total = sum(amount)) |>
  filter(date >= "2024-01-01")  # Too late!
```

**2. Partition Pruning**:
```r
# Tables partitioned by date automatically skip irrelevant partitions
delta_table |>
  filter(year == 2024, month == 3) |>  # Only reads March 2024 partitions
  collect()
```

**3. Broadcast Small Tables**:
```r
# Broadcast dimension tables < 100MB
large_fact_table |>
  left_join(sdf_broadcast(small_dimension_table), by = "key")
```

**4. Avoid Shuffles When Possible**:
```r
# GOOD: Pre-partitioned on join key
data |>
  sdf_repartition(partition_by = "customer_id") |>
  left_join(other_data, by = "customer_id")  # No shuffle needed

# BAD: Join on different keys triggers shuffle
```

**5. Cache Intermediate Results**:
```r
# Reused dataframe
base <- spark_df |>
  filter(complex_conditions) |>
  compute("base")  # Cache in Spark

# Reuse without recomputing
result1 <- base |> filter(region == "US") |> collect()
result2 <- base |> filter(region == "EU") |> collect()
```

### Partitioning Strategies

```r
# Repartition for better parallelism
spark_df |>
  sdf_repartition(partitions = 200)  # Default: usually too few

# Repartition by key for joins/aggregations
spark_df |>
  sdf_repartition(partition_by = "user_id")

# Coalesce to reduce partitions (no shuffle)
result_df |>
  sdf_coalesce(partitions = 10) |>
  spark_write_parquet("output")
```

### Configuration Tuning

```r
# Increase executor memory
config <- spark_config()
config$spark.executor.memory <- "8g"
config$spark.executor.cores <- 4

sc <- spark_connect(method = "databricks", config = config)
```

**Key Settings**:
- `spark.sql.shuffle.partitions` - Partitions for shuffles (default 200)
- `spark.executor.memory` - Memory per executor
- `spark.driver.memory` - Driver memory
- `spark.sql.adaptive.enabled` - Adaptive query execution (AQE)

## 5. Production Deployment

### Databricks Notebook Workflows

**Best Practices**:
- ✅ Use parameters with widgets for flexibility
- ✅ Separate data processing from visualization
- ✅ Handle errors gracefully
- ✅ Log progress and metrics

```r
# Notebook parameters
library(dbutils)
date_param <- dbutils.widgets.get("processing_date")

# Error handling
tryCatch({
  result <- process_data(date_param)
  spark_write_table(result, "output_table")
  dbutils.notebook.exit("SUCCESS")
}, error = function(e) {
  log_error(e$message)
  dbutils.notebook.exit("FAILED")
})
```

### Scheduled Jobs

**Job Configuration**:
- Define schedule (cron or interval)
- Set cluster configuration
- Configure retries and alerts
- Monitor via UI or API

### RStudio Desktop → Databricks Workflow

**Development Pattern**:
1. Develop locally with RStudio + Databricks Connect
2. Test on sample data via Connect
3. Promote to notebook for production
4. Schedule as Databricks job

```r
# Local development (RStudio)
library(sparklyr)

sc <- spark_connect(
  method = "databricks",
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID")
)

# Develop code...

spark_disconnect(sc)
```

### Best Practices for Production

**Code Organization**:
- Modularize: Functions for reusable logic
- Parameterize: No hardcoded paths/dates
- Document: Clear comments and README
- Version control: Git for notebooks

**Performance**:
- Profile bottlenecks before optimizing
- Monitor Spark UI for shuffle/spill
- Use appropriate cluster size
- Consider autoscaling

**Reliability**:
- Handle failures gracefully
- Implement retry logic
- Monitor job success/failure
- Set up alerts

## 6. Streaming & Real-Time

### Structured Streaming with sparklyr

```r
# Read stream
stream <- spark_read_stream(
  sc,
  name = "events_stream",
  source = "delta",
  options = list(path = "dbfs:/path/to/delta/table")
)

# Transform (same as batch)
processed <- stream |>
  filter(event_type == "purchase") |>
  mutate(processed_time = now())

# Write stream
spark_write_stream(
  processed,
  output_mode = "append",
  trigger = list(processingTime = "30 seconds"),
  checkpoint = "dbfs:/checkpoints/purchases",
  path = "dbfs:/output/purchases_stream"
)
```

**Output Modes**:
- `append` - New rows only (most common)
- `complete` - Full result (for aggregations)
- `update` - Changed rows only

**Use Cases**:
- Real-time ETL pipelines
- Event processing
- Continuous aggregations
- Change Data Capture (CDC)

## 7. SparkR Legacy & Migration

### Why SparkR is Deprecated

**Official Databricks Guidance**:
- SparkR deprecated in Databricks Runtime 16.0+
- Limited functionality compared to sparklyr
- Less integration with R ecosystem
- No longer actively developed

### SparkR vs sparklyr Comparison

| Feature | SparkR | sparklyr |
|---------|--------|----------|
| **Ecosystem** | Standalone | Integrates with tidyverse, DBI |
| **Syntax** | Spark-specific | R-native (dplyr) |
| **ML** | Limited ML | Full MLlib access |
| **Community** | Limited | Active (Posit + community) |
| **Status** | Deprecated (DBR 16+) | Recommended |

### Migration Path

**Step 1: Identify SparkR Code Patterns**

```r
# SparkR pattern
library(SparkR)
sparkR.session()
df <- read.df("path/to/data", source = "parquet")
result <- select(df, "col1", "col2")
```

**Step 2: Convert to sparklyr**

```r
# sparklyr equivalent
library(sparklyr)
library(dplyr)

sc <- spark_connect(method = "databricks")
df <- spark_read_parquet(sc, "my_data", "path/to/data")
result <- df |> select(col1, col2)
```

### Common Migration Patterns

| SparkR | sparklyr |
|--------|----------|
| `read.df()` | `spark_read_*()` |
| `write.df()` | `spark_write_*()` |
| `select(df, "col")` | `df |> select(col)` |
| `filter(df, condition)` | `df |> filter(condition)` |
| `groupBy()` | `group_by()` |
| `summarize()` | `summarize()` |
| `collect()` | `collect()` |
| `createDataFrame()` | `sdf_copy_to()` |

**Migration Checklist**:
- [ ] Replace `sparkR.session()` with `spark_connect()`
- [ ] Convert `read.df()` to `spark_read_*()`
- [ ] Replace SparkR verbs with dplyr equivalents
- [ ] Update ML code to sparklyr ml_* functions
- [ ] Test thoroughly on sample data
- [ ] Update documentation

## 8. Troubleshooting & Debugging

### Common Issues

#### 1. Memory Errors

**Symptoms**: OutOfMemoryError, executor lost

**Solutions**:
```r
# Increase partitions
df |> sdf_repartition(partitions = 400)

# Avoid collect() on large data
# Use aggregation first
df |>
  group_by(category) |>
  summarize(count = n()) |>
  collect()  # Small result

# Configure memory
config <- spark_config()
config$spark.executor.memory <- "16g"
```

#### 2. Slow Queries

**Diagnosis**:
```r
# Check execution plan
df |> explain()

# Look for:
# - Full table scans (missing partition pruning)
# - Excessive shuffles
# - Skewed data distribution
```

**Solutions**:
- Filter early
- Broadcast small tables
- Repartition on join keys
- Use Delta Lake optimization (OPTIMIZE, Z-ORDER)

#### 3. Connection Issues (Databricks Connect)

**Symptoms**: Connection timeout, authentication errors

**Solutions**:
```r
# Check environment variables
Sys.getenv("DATABRICKS_HOST")
Sys.getenv("DATABRICKS_TOKEN")

# Verify cluster is running
# Check cluster ID is correct
# Ensure DBR version matches databricks-connect version

# Reinstall if needed
reticulate::py_install("databricks-connect==14.3.0", pip = TRUE)
```

#### 4. Translation Errors (dbplyr)

**Symptoms**: Error in SQL generation, unsupported function

**Diagnosis**:
```r
# See generated SQL
df |> show_query()
```

**Solutions**:
```r
# Use Spark SQL functions directly
df |> mutate(result = expr("spark_sql_function(column)"))

# Or use spark_apply() for custom R code
df |> spark_apply(function(data) {
  data |> mutate(result = custom_r_function(column))
})
```

### Debugging Tools

**1. Spark UI**: Monitor jobs, stages, tasks
- Access via Databricks cluster UI
- Check for skewed partitions
- Identify slow stages

**2. show_query() and explain()**:
```r
# SQL translation
query |> show_query()

# Execution plan
query |> explain()
```

**3. Logging**:
```r
# Log intermediate steps
message("Processing step 1...")
result1 <- step1() |> compute()

message("Row count: ", sdf_nrow(result1))
```

**4. Sampling for Testing**:
```r
# Test on small sample first
spark_df |>
  sdf_sample(fraction = 0.001) |>
  <your_transformation> |>
  collect()
```

## 9. Security & Governance

### Authentication

**Recommended Methods** (in order):
1. **Posit Workbench** - Integrated authentication
2. **Azure CLI / AAD SSO** - For Azure deployments
3. **Personal Access Tokens (PAT)** - User-generated tokens

**Best Practice**: Use environment variables
```r
# Set once in .Renviron
usethis::edit_r_environ()

# Add:
# DATABRICKS_HOST=https://your-workspace.databricks.com
# DATABRICKS_TOKEN=dapi...

# Connect without exposing credentials
sc <- spark_connect(method = "databricks")
```

**⚠️ Never commit credentials to version control!**

### Access Control

**Unity Catalog** provides:
- Table-level permissions
- Column-level security (masking)
- Row-level security (filtering)
- Audit logging

```r
# Access control is enforced at query time
# No special R code needed - Databricks handles it

# User sees only authorized data
tbl(sc, "catalog.schema.protected_table") |>
  collect()  # Automatically filtered by permissions
```

## 10. Key Resources

### Official Documentation

**Databricks**:
- Databricks for R developers: https://docs.databricks.com/en/sparkr/
- sparklyr on Databricks: https://docs.databricks.com/en/sparkr/sparklyr
- Databricks Connect for R: https://docs.databricks.com/en/dev-tools/databricks-connect/r/

**sparklyr**:
- Posit sparklyr portal: https://spark.posit.co/
- Package reference: https://spark.posit.co/packages/sparklyr/latest/reference/
- GitHub: https://github.com/sparklyr/sparklyr

**dbplyr**:
- Articles: https://dbplyr.tidyverse.org/articles/
- Reference: https://dbplyr.tidyverse.org/reference/

**Delta Lake**:
- Documentation: https://docs.delta.io/

### Books

1. **Mastering Apache Spark with R** by Javier Luraschi, Kevin Kuo, Edgar Ruiz
   - URL: https://therinspark.com/
   - Topics: Spark fundamentals, ML pipelines, deployment

2. **Scale Data Science with Spark and R**
   - URL: https://sparklyr.github.io/sparklyr-site/
   - Topics: Workflows, patterns, real-world use cases

### Key Topics Summary

- **Spark Architecture**: Driver, executors, partitions, shuffles
- **ML Pipelines**: ml_* functions, feature engineering (ft_*), cross-validation
- **Delta Lake**: ACID, time travel, optimization (OPTIMIZE, VACUUM, Z-ORDER)
- **Performance**: Filter early, broadcast joins, partition tuning, caching
- **Production**: Notebooks, jobs, workflows, monitoring
- **Streaming**: Structured streaming, real-time pipelines
- **SparkR Migration**: Deprecated in DBR 16+, migrate to sparklyr
- **Troubleshooting**: Memory errors, slow queries, connection issues, translation errors
- **Security**: PAT authentication, Unity Catalog, access control

---

**End of Advanced Topics Guide**
