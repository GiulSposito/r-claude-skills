# sparklyr API & Ecosystem

## 1. Package Overview

### Purpose and Design Philosophy

sparklyr is an R interface to Apache Spark that enables R users to leverage Spark's distributed computing capabilities through familiar R workflows and tooling. The package provides:

- **Data Interaction**: Work with Spark using established R interfaces including dplyr, broom, and DBI
- **Machine Learning**: Access Spark's distributed machine learning libraries
- **Advanced Features**: Structure Streaming for real-time data, ML Pipelines for complex modeling
- **Extensibility**: Integration with XGBoost, MLeap, H2O, and Graphframes
- **Distributed Computing**: Run R code across clusters with spark_apply()

### Installation and Requirements

**Install from CRAN:**
```r
install.packages("sparklyr")
```

**Install local Spark instance:**
```r
library(sparklyr)
spark_install()
```

**Development version:**
```r
install.packages("devtools")
devtools::install_github("sparklyr/sparklyr")
```

### Version Information

- **Current Version**: Available on CRAN
- **R Requirement**: ≥ 3.6
- **Dependencies**: DBI, dplyr (≥ 1.1.2), tibble, tidyr, rlang, and 16 additional packages
- **Active Maintenance**: 969 stars, 346 open issues on GitHub

### Cluster Flexibility

Sparklyr connects to Spark across multiple environments:
- Databricks
- Snowflake
- YARN (Hadoop)
- Kubernetes
- Standalone clusters
- Spark Connect
- Apache Livy (remote connections)

## 2. Connection Management

### spark_connect()

The primary function for establishing Spark connections:

```r
library(sparklyr)

# Local connection
sc <- spark_connect(master = "local")

# YARN client mode
sc <- spark_connect(master = "yarn-client")

# Databricks
sc <- spark_connect(master = "databricks")
```

### Connection Methods

**Local Mode:**
```r
spark_install()  # First time only
sc <- spark_connect(master = "local")
```

**YARN:**
- **Client mode** (`yarn-client`): R server acts as the Spark driver
- **Cluster mode** (`yarn-cluster`): YARN selects driver location; requires `yarn-site.xml` and `hive-site.xml`

**Standalone:** Uses multiple worker nodes with one executor per worker by default

### Configuration Options

Essential configuration settings are passed via `spark_config()`:

```r
config <- spark_config()
config$spark.executor.memory <- "8g"
config$spark.executor.cores <- 4
config$spark.executor.instances <- 10
config$spark.dynamicAllocation.enabled <- TRUE

# Local development
config$sparklyr.cores.local <- 2
config$sparklyr.shell.driver-memory <- "2g"
config$spark.memory.fraction <- 0.9

sc <- spark_connect(master = "local", config = config)
```

**Key Principle**: Spark configuration properties passed by R are just requests—clusters retain final authority over resource allocation.

### Authentication

**Kerberos-secured clusters:**
- Use `system()` calls with `kinit`
- RStudio Server Pro's integrated Kerberos support

### spark_disconnect()

Close connections when finished:
```r
spark_disconnect(sc)
```

### Utility Functions

- `spark_connection_is_open(sc)` - Check connection status
- `spark_version(sc)` - Retrieve Spark version (returns `numeric_version`)
- `spark_web(sc)` - Open Spark web interface for monitoring

**Note**: `spark_version()` trims suffixes from preview/snapshot versions. For complete version: `invoke(spark_context(sc), "version")`

## 3. Spark DataFrame API (sdf_*)

### sdf_copy_to()

Transfer R objects into Spark and return wrapped Spark DataFrame:

```r
sc <- spark_connect(master = "local")
iris_tbl <- sdf_copy_to(sc, iris)
```

**Parameters:**
- `sc`: Spark connection
- `x`: R object to convert
- `name`: Table identifier in Spark
- `memory`: In-memory caching (boolean)
- `repartition`: Partition count (0 = no partitioning)
- `overwrite`: Replace existing table
- `struct_columns`: Convert columns to Spark SQL StructType (Spark 2.4.0+)

**Important**: When using `struct_columns`, all rows must have identical schemas.

### sdf_register()

Register an existing Spark DataFrame as a table name for SQL queries.

### sdf_sql()

Execute SQL queries on Spark DataFrames:
```r
sdf_sql(sc, "SELECT * FROM iris_tbl WHERE Sepal_Length > 5.0")
```

### sdf_schema()

Inspect DataFrame schema:
```r
sdf_schema(iris_tbl)
```

### Data Manipulation Functions

**sdf_partition()** - Split data for train/test:
```r
partitions <- sdf_random_split(iris_tbl, training = 0.7, test = 0.3, seed = 123)
training_data <- partitions$training
test_data <- partitions$test
```

**sdf_sample()** - Sample data:
```r
sample_data <- sdf_sample(iris_tbl, fraction = 0.1)
```

**Transformations:**
- `sdf_distinct()` - Unique rows
- `sdf_sort()` - Sort data
- `sdf_pivot()` - Pivot tables
- `sdf_coalesce()` - Reduce partitions (no shuffle)
- `sdf_repartition()` - Repartition data with shuffle

**Statistical:**
- `sdf_describe()` - Summary statistics
- `sdf_quantile()` - Quantile calculation
- `sdf_crosstab()` - Cross-tabulation

**Utilities:**
- `sdf_dim()`, `sdf_nrow()`, `sdf_ncol()` - Dimensions
- `sdf_num_partitions()` - Count partitions
- `sdf_broadcast()` - Broadcast smaller DataFrames for joins
- `sdf_persist()` - Cache DataFrame
- `sdf_checkpoint()` - Break lineage for performance
- `sdf_with_sequential_id()` - Add sequential IDs

## 4. Machine Learning (ml_*)

### Supervised Learning - Regression

**ml_linear_regression():**
```r
ml_linear_regression(
  x,
  formula = NULL,
  fit_intercept = TRUE,
  elastic_net_param = 0,  # 0 = Ridge, 1 = Lasso
  reg_param = 0,          # Regularization strength
  max_iter = 100,
  standardization = TRUE,
  features_col = "features",
  label_col = "label",
  prediction_col = "prediction"
)
```

**Example:**
```r
# Split data
partitions <- sdf_random_split(mtcars_tbl, training = 0.7, test = 0.3)

# Train model
lm_model <- partitions$training |>
  ml_linear_regression(mpg ~ .)

# Predict
predictions <- ml_predict(lm_model, partitions$test)

# Evaluate
ml_regression_evaluator(predictions, label_col = "mpg")
```

**Other Regression Algorithms:**
- `ml_generalized_linear_regression()` - GLMs with various families
- `ml_isotonic_regression()` - Isotonic regression
- `ml_aft_survival_regression()` - Survival analysis

### Supervised Learning - Classification

**ml_logistic_regression():**
- Binary and multinomial classification
- Same regularization options as linear regression

**Tree-Based:**
- `ml_decision_tree_classifier()` - Single decision tree
- `ml_random_forest_classifier()` - Random forest ensemble
- `ml_gbt_classifier()` - Gradient-boosted trees

**Other Classifiers:**
- `ml_naive_bayes()` - Naive Bayes
- `ml_multilayer_perceptron_classifier()` - Neural network
- `ml_linear_svc()` - Linear SVM
- `ml_one_vs_rest()` - Multi-class wrapper

### Unsupervised Learning

**Clustering:**
- `ml_kmeans()` - K-means clustering
- `ml_bisecting_kmeans()` - Bisecting K-means
- `ml_gaussian_mixture()` - Gaussian mixture models
- `ml_power_iteration()` - Power iteration clustering

**Dimensionality Reduction:**
- `ml_pca()` - Principal Component Analysis
- `ml_lda()` - Latent Dirichlet Allocation (topic modeling)

**Recommender Systems:**
- `ml_als()` - Alternating Least Squares for collaborative filtering

**Pattern Mining:**
- `ml_fpgrowth()` - Frequent pattern mining
- `ml_prefixspan()` - Sequential pattern mining

### ML Pipelines & Features

**Pipeline Creation:**
```r
pipeline <- ml_pipeline(sc) |>
  ft_string_indexer(input_col = "species", output_col = "species_idx") |>
  ft_vector_assembler(
    input_cols = c("Sepal_Length", "Sepal_Width", "species_idx"),
    output_col = "features"
  ) |>
  ml_logistic_regression(features_col = "features", label_col = "label")

# Fit pipeline
pipeline_model <- ml_fit(pipeline, training_data)
```

**Feature Transformers (ft_*):**

*Scaling/Normalization:*
- `ft_standard_scaler()` - Z-score normalization
- `ft_min_max_scaler()` - Min-max scaling
- `ft_robust_scaler()` - Robust scaling with IQR
- `ft_max_abs_scaler()` - Scale by maximum absolute value

*Encoding:*
- `ft_one_hot_encoder()` - One-hot encoding
- `ft_string_indexer()` - Convert strings to indices
- `ft_index_to_string()` - Convert indices back to strings

*Text Processing:*
- `ft_tokenizer()` - Tokenize text
- `ft_ngram()` - Generate n-grams
- `ft_stop_words_remover()` - Remove stop words
- `ft_hashing_tf()` - Hashing term frequency
- `ft_idf()` - Inverse document frequency
- `ft_word2vec()` - Word embeddings

*Feature Generation:*
- `ft_interaction()` - Feature interactions
- `ft_polynomial_expansion()` - Polynomial features
- `ft_vector_assembler()` - Combine features into vector
- `ft_bucketizer()` - Bin continuous features
- `ft_binarizer()` - Binary threshold

*Dimensionality:*
- `ft_pca()` - Principal Component Analysis
- `ft_dct()` - Discrete Cosine Transform

### Model Operations

**Save/Load:**
```r
ml_save(model, "path/to/model")
loaded_model <- ml_load(sc, "path/to/model")
```

**Prediction:**
```r
predictions <- ml_predict(model, test_data)
```

**Evaluation:**
```r
# Regression
ml_regression_evaluator(predictions, label_col = "label")

# Binary classification
ml_binary_classification_evaluator(predictions)

# Clustering
ml_clustering_evaluator(predictions)
```

### Hyperparameter Tuning

**Cross-Validation:**
```r
cv <- ml_cross_validator(
  sc,
  estimator = pipeline,
  estimator_param_maps = list(
    elastic_net_param = c(0, 0.5, 1),
    reg_param = c(0.01, 0.1, 1.0)
  ),
  evaluator = ml_regression_evaluator(label_col = "label"),
  num_folds = 3
)

cv_model <- ml_fit(cv, training_data)
```

**Train-Validation Split:**
```r
tv <- ml_train_validation_split(
  sc,
  estimator = pipeline,
  estimator_param_maps = param_grid,
  evaluator = evaluator,
  train_ratio = 0.8
)
```

### Tidier Functions

Integration with broom-style methods:
```r
library(broom)

# Model coefficients
tidy(lm_model)

# Predictions with residuals
augment(lm_model, test_data)

# Model metrics
glance(lm_model)
```

## 5. Data Import/Export

### Reading Data

**CSV:**
```r
df <- spark_read_csv(
  sc,
  name = "my_data",
  path = "s3://bucket/data.csv",
  header = TRUE,
  delimiter = ",",
  quote = "\"",
  escape = "\\",
  charset = "UTF-8",
  null_value = "NA",
  infer_schema = TRUE,  # Automatic type detection
  columns = NULL,       # Or specify schema
  repartition = 0,
  memory = TRUE,
  overwrite = TRUE
)
```

**Column Schema:**
```r
columns <- c(
  "binary", "boolean", "byte", "integer", "integer64",
  "double", "character", "timestamp", "date"
)
```

**Other Formats:**
- `spark_read_json()` - JSON files
- `spark_read_parquet()` - Parquet files
- `spark_read_orc()` - ORC files
- `spark_read_avro()` - Avro files
- `spark_read_text()` - Text files
- `spark_read_binary()` - Binary files
- `spark_read_image()` - Image files
- `spark_read_libsvm()` - LIBSVM format
- `spark_read_jdbc()` - JDBC sources
- `spark_read_delta()` - Delta Lake tables
- `spark_read_table()` - Hive tables

**Path Protocols:**
- `hdfs://` - HDFS
- `s3a://` - Amazon S3
- `file://` - Local filesystem

### Writing Data

**CSV:**
```r
spark_write_csv(
  df,
  path = "s3://bucket/output/",
  mode = "overwrite",  # "append", "overwrite", "error", "ignore"
  header = TRUE
)
```

**Other Write Functions:**
- `spark_write_json()`
- `spark_write_parquet()`
- `spark_write_orc()`
- `spark_write_avro()`
- `spark_write_text()`
- `spark_write_delta()`
- `spark_write_table()`
- `spark_insert_table()`
- `spark_save_table()`

### Delta Lake Support

**Reading:**
```r
delta_df <- spark_read_delta(sc, path = "s3://bucket/delta-table")
```

**Writing:**
```r
spark_write_delta(df, path = "s3://bucket/delta-table", mode = "overwrite")
```

## 6. dplyr Integration

### How dplyr Verbs Work with Spark

Sparklyr provides seamless integration with dplyr, allowing familiar R syntax for distributed data:

```r
library(dplyr)

result <- iris_tbl |>
  filter(Sepal_Length > 5.0) |>
  select(Species, Sepal_Length, Petal_Length) |>
  mutate(sepal_petal_ratio = Sepal_Length / Petal_Length) |>
  group_by(Species) |>
  summarize(
    avg_ratio = mean(sepal_petal_ratio),
    count = n()
  ) |>
  arrange(desc(avg_ratio))
```

### Lazy Evaluation

**Key Concept**: No database queries execute until explicitly requested.

**Query Execution Triggers:**
- Printing the result
- `collect()` - Bring data to R
- `compute()` - Persist intermediate results in Spark
- `show_query()` - View generated SQL
- `explain()` - View execution plan

```r
# Build query (no execution)
lazy_result <- iris_tbl |>
  filter(Sepal_Length > 5.0) |>
  select(Species, Sepal_Length)

# Inspect SQL
lazy_result |> show_query()

# Execute and collect
local_data <- lazy_result |> collect()
```

### collect() vs compute()

**collect():**
- Pulls all data into local R memory
- Returns a tibble
- Use after finalizing query
- Potentially expensive operation

```r
local_df <- remote_df |> collect()
```

**compute():**
- Persists intermediate results on Spark
- Keeps data distributed
- Returns a new Spark DataFrame
- Useful for iterative operations

```r
cached_df <- remote_df |>
  complex_transformation() |>
  compute("cached_table")
```

### Supported vs Unsupported Operations

**Fully Supported:**
- Single-table verbs: `filter()`, `select()`, `mutate()`, `summarize()`, `arrange()`, `distinct()`
- Multi-table verbs: All joins
- Grouping: `group_by()`, `ungroup()`
- Aggregations: `mean()`, `sum()`, `min()`, `max()`, `sd()`, `var()`, `n()`

**Limited Support:**
- `slice()` operations - limited on remote backends
- `tail()` - unsupported (requires executing full query)
- `nrow()` - returns `NA` (would require full execution)

**Workarounds:**
- Use `spark_apply()` for complex R functions
- `compute()` + local processing for unsupported operations
- Native Spark functions via `sql()`

### Modern dplyr Patterns

**Per-operation grouping with `.by`:**
```r
# Instead of group_by() + summarize() + ungroup()
result <- df |>
  summarize(
    avg_value = mean(value),
    .by = c(category, region)
  )
```

**across() for multiple columns:**
```r
result <- df |>
  mutate(across(
    where(is.numeric),
    ~ .x * 2,
    .names = "{.col}_doubled"
  ))
```

**join_by() syntax:**
```r
result <- left_join(
  df1,
  df2,
  by = join_by(id, date)
)
```

## 7. Streaming

### Structured Streaming Concept

Spark Streaming processes real-time data by conceptualizing it as an infinite table. Apply the same analytical techniques to continuously arriving data.

### Reading Streams

**Stream Sources:**
```r
# CSV stream
stream <- stream_read_csv(sc, "path/to/stream/directory/")

# JSON stream
stream <- stream_read_json(sc, "path/to/stream/")

# Kafka stream
stream <- stream_read_kafka(sc, "localhost:9092", "topic-name")

# Socket stream
stream <- stream_read_socket(sc, "localhost", 9999)

# Delta stream
stream <- stream_read_delta(sc, "path/to/delta/")
```

### Transforming Streams

Use standard dplyr operations:
```r
transformed_stream <- stream |>
  filter(value > 100) |>
  mutate(processed_value = value * 2) |>
  group_by(category) |>
  summarize(total = sum(processed_value))
```

**Watermarks for time-windowed aggregations:**
```r
windowed_stream <- stream |>
  stream_watermark(timestamp_col = "event_time", threshold = "10 minutes")
```

### Writing Streams

**Stream Sinks:**
```r
# Write to CSV
stream_write_csv(stream, "path/to/output/")

# Write to Kafka
stream_write_kafka(stream, "localhost:9092", "output-topic")

# Write to memory (for testing)
stream_write_memory(stream, "stream_table")

# Write to Delta
stream_write_table(stream, "output_table", mode = "append")
```

### Stream Management

```r
# Stop stream
stream_stop(stream)

# View statistics
stream_stats(stream)

# View running streams
stream_view(sc)

# Find specific stream
stream_find(sc, "stream_name")
```

### Stream Triggers

**Trigger intervals:**
```r
stream_trigger_interval(stream, interval = "10 seconds")
stream_trigger_continuous(stream, checkpoint_interval = "1 second")
```

### Processing Modes

- `complete` - Output entire result table
- `update` - Output only changed rows
- `append` - Output only new rows

### Limitations

- **Training**: Spark streams currently don't support training on real-time datasets
- **Scoring**: Pre-trained pipelines and feature transformers enable real-time scoring
- **Custom R**: Use `spark_apply()` for custom transformations

### Real-Time Visualization

**Shiny Integration:**
```r
library(shiny)

ui <- fluidPage(
  tableOutput("stream_data")
)

server <- function(input, output, session) {
  output$stream_data <- renderTable({
    reactiveSpark(stream_table) |>
      head(10)
  })
}

shinyApp(ui, server)
```

## 8. Extensions & Advanced

### spark_apply()

Run arbitrary R code across Spark cluster:

```r
# Apply custom R function to each partition
result <- spark_apply(
  df,
  function(data) {
    # Custom R processing
    data |>
      mutate(custom_col = some_r_function(value))
  },
  columns = list(
    id = "integer",
    value = "double",
    custom_col = "double"
  )
)
```

**Group-wise application:**
```r
result <- spark_apply(
  df,
  function(data, group_key) {
    # Process each group with custom logic
    model <- lm(y ~ x, data = data)
    data.frame(group = group_key, r_squared = summary(model)$r.squared)
  },
  group_by = "category",
  columns = list(
    group = "character",
    r_squared = "double"
  )
)
```

**Note**: `spark_apply()` unsupported on Databricks serverless compute (no R environment).

### Higher-Order Functions (hof_*)

Work with array and map columns:

**hof_transform():**
```r
# Element-wise transformation on arrays
df |>
  hof_transform(~ .x * .x)  # Square each element
```

**Other HOF functions:**
- `hof_filter()` - Filter array elements
- `hof_aggregate()` - Aggregate array values
- `hof_exists()` - Check if element exists
- `hof_forall()` - Check if all elements satisfy condition
- `hof_map_filter()` - Filter map entries
- `hof_zip_with()` - Combine two arrays

### invoke() for Scala/Java API

Access underlying Spark API directly:

```r
# Get Spark context
spark_ctx <- spark_context(sc)

# Call Java/Scala methods
invoke(spark_ctx, "version")

# Invoke static methods
invoke_static(sc, "org.apache.spark.util.Utils", "getCurrentUserName")

# Create new objects
invoke_new(sc, "org.apache.spark.ml.feature.Tokenizer")
```

### Custom Transformers

Create custom ML pipeline transformers:

```r
custom_transformer <- ml_pipeline_stage(
  sc,
  class = "my.custom.Transformer",
  uid = "custom_transformer",
  input_col = "input",
  output_col = "output",
  param1 = value1
)
```

### UDFs (User-Defined Functions)

Register R functions as Spark UDFs:

```r
# Note: Limited support, prefer spark_apply() for complex logic
# UDF functionality varies by connection type
```

## 9. Performance & Optimization

### Caching Strategies

**In-Memory Caching:**
```r
# Cache DataFrame
cached_df <- df |>
  tbl_cache()

# Uncache when done
tbl_uncache(cached_df)
```

**Persistence Levels:**
```r
# Persist with specific storage level
df |> sdf_persist(storage_level = "MEMORY_AND_DISK")
```

### Partitioning Recommendations

**Repartitioning:**
```r
# Increase partitions for better parallelism
df_repartitioned <- df |>
  sdf_repartition(partitions = 100)

# Reduce partitions to minimize overhead
df_coalesced <- df |>
  sdf_coalesce(partitions = 10)
```

**Best Practices:**
- Align partitions with CPU count: 2-4 partitions per CPU core
- Too few partitions = underutilization
- Too many partitions = excessive overhead
- Use `sdf_num_partitions()` to check current count

### Broadcast Joins

Push smaller DataFrames to workers:

```r
# Broadcast small lookup table
result <- large_df |>
  left_join(
    sdf_broadcast(small_df),
    by = "key"
  )
```

**Automatic broadcast threshold:**
```r
config$spark.sql.autoBroadcastJoinThreshold <- 10485760  # 10MB
```

### Configuration Tuning

**Memory Configuration:**
```r
config <- spark_config()

# Executor memory
config$spark.executor.memory <- "8g"

# Driver memory
config$spark.driver.memory <- "4g"

# Memory fraction for storage
config$spark.memory.storageFraction <- 0.5

# Memory fraction for execution
config$spark.memory.fraction <- 0.6
```

**Parallelism:**
```r
# Shuffle partitions
config$spark.sql.shuffle.partitions <- 200

# Dynamic allocation
config$spark.dynamicAllocation.enabled <- TRUE
config$spark.dynamicAllocation.minExecutors <- 2
config$spark.dynamicAllocation.maxExecutors <- 20
```

**Serialization:**
```r
# Use Kryo serializer
config$spark.serializer <- "org.apache.spark.serializer.KryoSerializer"
```

### Checkpointing

Break lineage to reduce optimization overhead:

```r
# Set checkpoint directory
spark_set_checkpoint_dir(sc, "/path/to/checkpoint/")

# Checkpoint DataFrame
checkpointed_df <- df |>
  complex_transformations() |>
  sdf_checkpoint()
```

### Adaptive Query Execution

Enable AQE for dynamic optimization:

```r
spark_adaptive_query_execution(sc, enable = TRUE)
```

### Monitoring with Spark UI

```r
# Open Spark web interface
spark_web(sc)
```

**Key metrics to monitor:**
- Task duration and GC time
- Shuffle read/write sizes
- Executor memory usage
- Stage and job execution times
- Data locality

## 10. Common Patterns

### ETL Pipeline Pattern

```r
# Extract
raw_data <- spark_read_parquet(sc, "s3://bucket/raw/")

# Transform
clean_data <- raw_data |>
  filter(!is.na(key_column)) |>
  mutate(
    processed_date = to_date(timestamp),
    normalized_value = (value - mean(value)) / sd(value)
  ) |>
  group_by(category, processed_date) |>
  summarize(
    total_value = sum(normalized_value),
    count = n()
  ) |>
  compute("clean_data")

# Load
spark_write_delta(
  clean_data,
  "s3://bucket/clean/data",
  mode = "overwrite"
)
```

### Train-Score Pattern

```r
# Load and prepare data
data <- spark_read_delta(sc, "s3://bucket/training-data/")

partitions <- sdf_random_split(data, training = 0.8, test = 0.2, seed = 123)

# Create pipeline
pipeline <- ml_pipeline(sc) |>
  ft_string_indexer("category", "category_idx") |>
  ft_vector_assembler(c("feature1", "feature2", "category_idx"), "features") |>
  ml_random_forest_classifier(features_col = "features", label_col = "label")

# Train
model <- ml_fit(pipeline, partitions$training)

# Save model
ml_save(model, "s3://bucket/models/rf-model/")

# Score
predictions <- ml_predict(model, partitions$test)

# Evaluate
ml_multiclass_classification_evaluator(predictions, metric_name = "accuracy")
```

### Incremental Processing Pattern

```r
# Process new data only
existing_processed <- spark_read_delta(sc, "s3://bucket/processed/")

new_data <- spark_read_parquet(sc, "s3://bucket/raw/latest/") |>
  anti_join(existing_processed, by = "id") |>
  transform_data()

# Append to processed
spark_write_delta(
  new_data,
  "s3://bucket/processed/",
  mode = "append"
)
```

### Sampling for Visualization

```r
# Sample for ggplot2
sample_data <- large_df |>
  sdf_sample(fraction = 0.01, seed = 42) |>
  collect()

library(ggplot2)
ggplot(sample_data, aes(x = feature1, y = feature2)) +
  geom_point() +
  theme_minimal()
```

### Iterative Algorithm Pattern

```r
# Initialize
current_df <- initial_data |> compute("iteration_0")

for (i in 1:max_iterations) {
  # Update
  current_df <- current_df |>
    mutate(value = value + delta) |>
    compute(paste0("iteration_", i))

  # Check convergence
  converged <- check_convergence(current_df)
  if (converged) break
}
```

## 11. Code Examples

### Example 1: Basic Data Analysis

```r
library(sparklyr)
library(dplyr)

# Connect
sc <- spark_connect(master = "local")

# Load data
flights <- spark_read_csv(sc, "flights", "flights.csv", header = TRUE)

# Analysis
summary_stats <- flights |>
  filter(!is.na(dep_delay)) |>
  group_by(carrier) |>
  summarize(
    avg_delay = mean(dep_delay),
    max_delay = max(dep_delay),
    flight_count = n()
  ) |>
  arrange(desc(avg_delay)) |>
  collect()

# Disconnect
spark_disconnect(sc)
```

### Example 2: Machine Learning Pipeline

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(master = "local", version = "3.4")

# Prepare data
iris_tbl <- copy_to(sc, iris, overwrite = TRUE)

# Split data
partitions <- sdf_random_split(iris_tbl, training = 0.7, test = 0.3)

# Build pipeline
pipeline <- ml_pipeline(sc) |>
  ft_string_indexer("Species", "species_idx") |>
  ft_vector_assembler(
    c("Sepal_Length", "Sepal_Width", "Petal_Length", "Petal_Width"),
    "features"
  ) |>
  ml_random_forest_classifier(
    label_col = "species_idx",
    features_col = "features",
    num_trees = 20
  )

# Train
model <- ml_fit(pipeline, partitions$training)

# Predict
predictions <- ml_predict(model, partitions$test)

# Evaluate
accuracy <- ml_multiclass_classification_evaluator(
  predictions,
  label_col = "species_idx",
  metric_name = "accuracy"
)

print(paste("Accuracy:", accuracy))
```

### Example 3: Distributed R with spark_apply()

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(master = "local")

# Create data
data_tbl <- copy_to(sc, data.frame(
  group = rep(letters[1:5], each = 100),
  x = rnorm(500),
  y = rnorm(500)
))

# Apply custom R function per group
results <- spark_apply(
  data_tbl,
  function(df, group_key) {
    model <- lm(y ~ x, data = df)
    coefs <- coef(model)

    data.frame(
      group = group_key,
      intercept = coefs[1],
      slope = coefs[2],
      r_squared = summary(model)$r.squared,
      n_obs = nrow(df)
    )
  },
  group_by = "group",
  columns = list(
    group = "character",
    intercept = "double",
    slope = "double",
    r_squared = "double",
    n_obs = "integer"
  )
) |>
  collect()

print(results)
```

### Example 4: Streaming with Kafka

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(master = "local")

# Read from Kafka
stream <- stream_read_kafka(
  sc,
  kafka_brokers = "localhost:9092",
  topics = "input-topic"
)

# Process stream
processed <- stream |>
  mutate(
    value_str = as.character(value),
    timestamp = current_timestamp()
  ) |>
  filter(nchar(value_str) > 10)

# Write to Kafka
stream_write_kafka(
  processed,
  kafka_brokers = "localhost:9092",
  topic = "output-topic",
  mode = "append"
)
```

### Example 5: Delta Lake Operations

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(master = "local")

# Write Delta table
data <- data.frame(
  id = 1:1000,
  value = rnorm(1000),
  category = sample(letters[1:5], 1000, replace = TRUE)
)

data_tbl <- copy_to(sc, data)
spark_write_delta(data_tbl, "delta-table", mode = "overwrite")

# Read Delta table
delta_df <- spark_read_delta(sc, "delta-table")

# Update (via overwrite)
updated_data <- delta_df |>
  mutate(value = value * 2)

spark_write_delta(updated_data, "delta-table", mode = "overwrite")

# Time travel (if supported by backend)
# historical_df <- spark_read_delta(sc, "delta-table", version = 0)
```

## 12. References

### Official Documentation

1. **Posit sparklyr portal**: https://spark.posit.co/
   - Complete documentation hub
   - Guides and tutorials
   - Deployment guides

2. **sparklyr package reference**: https://spark.posit.co/packages/sparklyr/latest/reference/
   - Complete API reference
   - ~300+ functions documented
   - Function signatures and examples

3. **CRAN: sparklyr**: https://cran.r-project.org/package=sparklyr
   - Package metadata
   - Version information
   - Dependencies

4. **GitHub sparklyr**: https://github.com/sparklyr/sparklyr
   - Source code
   - Issue tracking
   - Development versions
   - Release notes

### Key Articles

- Connection methods: https://spark.posit.co/guides/connections.html
- Databricks deployment: https://spark.posit.co/deployment/databricks-connect.html
- ML pipelines: https://spark.posit.co/guides/pipelines.html
- Distributed R: https://spark.posit.co/guides/distributed-r.html

### Books

- **Mastering Apache Spark with R**: https://therinspark.com/
- **Scale Data Science with Spark and R**: https://sparklyr.github.io/sparklyr-site/

### Ecosystem

- DBI: https://dbi.r-dbi.org/
- dplyr: https://dplyr.tidyverse.org/
- Apache Spark: https://spark.apache.org/
- Delta Lake: https://docs.delta.io/

---

*Last Updated: 2026-03-19*
*Compiled from official sparklyr documentation and resources*
