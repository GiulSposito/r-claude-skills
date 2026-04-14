# Databricks Platform Core for R

## 1. Overview

### R on Databricks Ecosystem

Databricks provides two primary R APIs for Apache Spark integration:

- **SparkR**: Provides distributed data frame implementation supporting selection, filtering, and aggregation on large datasets
  - **DEPRECATED**: SparkR is deprecated in Databricks Runtime 16.0 and above
  - Databricks recommends migrating to sparklyr instead

- **sparklyr**: Offers functionality similar to dplyr, broom, and DBI packages
  - Automatically distributed with every Databricks Runtime release
  - Recommended for all new R development on Databricks

Both APIs enable working with Spark DataFrames and tables alongside traditional R data.frames.

### Runtime Versions and sparklyr Support

- **sparklyr Distribution**: Latest stable sparklyr version automatically included with every Databricks Runtime release
- **Databricks Connect**: Requires Databricks Runtime 13.0 and above
- **Python Compatibility**: Python 3.10 required for Databricks Connect (must match cluster version)
- No manual installation or `spark_install()` calls necessary since Spark already exists on clusters

### SparkR Deprecation (Runtime 16.0+)

**Critical Notice**: SparkR is deprecated in Databricks Runtime 16.0 and above. All documentation recommends using sparklyr instead for new projects.

**Migration Impact**:
- Existing SparkR code will continue to function on Runtime versions < 16.0
- New development should use sparklyr
- Both APIs can coexist in single notebooks/jobs during transition period

## 2. Development Environments

### Databricks Notebooks

**Primary Development Interface**:
- Native R notebook support
- Pre-configured Spark environment
- Automatic SparkSession initialization for SparkR
- Requires explicit `spark_connect()` for sparklyr

**Session Customization** (Runtime 12.2 LTS and above):
- `.Rprofile` customization supported at `$R_HOME/etc/Rprofile.site`
- Earlier versions require setting `DATABRICKS_ENABLE_RPROFILE=true`

**Visualization Support**:
- `display()` function for visualizations
- Integration with R plotting libraries

### RStudio Desktop with Databricks Connect

**Setup Requirements**:
- RStudio Desktop installed locally
- Python 3.10 (matching cluster version)
- R and required packages
- Databricks personal access token for authentication

**Supported Features**:
- DataFrame API access
- Catalog, schema, table, and view exploration via Connections view
- Debugging with breakpoints and variable inspection in Environment view
- Integration with dplyr for data manipulation

**Key Limitation**:
- MLlib has limited compatibility (see section 6 for details)
- Not officially provided or directly supported by Databricks
- Community support via Posit Community forums
- Issue reporting via sparklyr GitHub repository

### Jobs and Workflows

**Job Support**:
- Notebook-scoped libraries available to associated jobs
- Same R environment as parent notebook
- spark-submit jobs supported (deprecated) with specific configuration

**Spark Submit Configuration** (deprecated):
```r
library(sparklyr)
sc <- spark_connect(method = "databricks", spark_home = "<spark-home-path>")
```

## 3. Connection & Setup

### spark_connect() Methods

#### Databricks Notebooks - Basic Connection

```r
library(sparklyr)
sc <- spark_connect(method = "databricks")
```

**No additional parameters required** - establishes sparklyr connection to existing cluster Spark environment.

#### RStudio Desktop via Databricks Connect

**Connection Code**:
```r
library(sparklyr)
library(dplyr)
library(dbplyr)

sc <- sparklyr::spark_connect(
  master     = Sys.getenv("DATABRICKS_HOST"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  token      = Sys.getenv("DATABRICKS_TOKEN"),
  method     = "databricks_connect",
  envname    = "r-reticulate"
)
```

**Environment Variables Setup** (stored in `.Renviron`):
```
DATABRICKS_HOST=<workspace-url>
DATABRICKS_TOKEN=<personal-access-token>
DATABRICKS_CLUSTER_ID=<cluster-id>
```

Edit using: `usethis::edit_r_environ()`

#### SparkR Connection

SparkR automatically establishes a SparkSession - no explicit connection step required:

```r
library(SparkR)
sparkR.session()
```

### Databricks-Specific Configuration

**Progress Tracking**:
- Assigning connection to variable named `sc` enables progress bars
- Displays "Spark progress" after job-triggering commands
- Provides clickable links to Spark UI

**Cluster Architecture Considerations**:

**Single-node clusters**:
- Support RStudio, notebooks, and libraries
- No Spark distribution required
- Ideal for projects not requiring parallel processing

**Distributed clusters**:
- Driver and worker nodes architecture
- Enables distributed computation packages (SparkR, sparklyr)
- Key distributed functions: `sparklyr::spark_apply()`, `SparkR::dapply()`, `SparkR::gapply()`, `SparkR::spark.lapply()`

### Authentication Patterns

**Databricks Connect Authentication**:
- **Currently supports only personal access tokens**
- Create token through workspace user settings
- Store in `.Renviron` file for security
- Never hardcode tokens in scripts

**Token Creation**:
1. Navigate to workspace user settings
2. Generate personal access token
3. Copy token immediately (not retrievable later)
4. Store in `.Renviron` using `usethis::edit_r_environ()`

## 4. Package Management

### Notebook-Scoped Libraries

**Definition**: Custom R environments specific to individual notebook sessions.

**Scope**: "Only the current notebook and any jobs associated with that notebook have access to that library." Other notebooks on the same cluster remain unaffected.

#### Installation Methods

**Standard CRAN Installation**:
```r
install.packages("arrow")
```

**Specific Version Installation**:
```r
require(devtools)
install_version(
  package = "dplyr",
  version = "0.7.4",
  repos = "http://cran.r-project.org"
)
```

**Custom Package from Source**:
```r
install.packages(
  pkgs = "/path/to/tar/file/<custom-package>.tar.gz",
  type = "source",
  repos = NULL
)
```

**GitHub Packages**:
```r
# Using DevTools APIs
devtools::install_github("username/repository")
```

**Bioconductor Packages**:
```r
# Standard Bioconductor installation
BiocManager::install("package_name")
```

**Package Removal**:
```r
remove.packages("package_name")
```

#### Best Practices

- **Use CRAN Snapshots**: Databricks recommends using CRAN snapshots for reproducible results
- **Version Pinning**: Pin specific versions using `install_version()` for consistency
- **Documentation**: Document required packages and versions in notebook

### Cluster Libraries

**When to Use**: For sharing libraries across all notebooks on a cluster, use compute-scoped (cluster-installed) libraries.

**Driver-Only Installation**: Requires explicitly setting directory to `/databricks/spark/R/lib`

**Installation via Cluster UI**:
- Navigate to cluster configuration
- Add libraries through Libraries tab
- Available to all notebooks on cluster
- Persists across cluster restarts

### install.packages() Behavior

**Notebook Scope Default**:
- `install.packages()` creates notebook-scoped installation by default
- Not visible to other notebooks on same cluster
- Requires reinstallation each notebook session

**No Caching**:
- Databricks implements no caching mechanism
- Duplicate installations across different notebooks result in repeated downloads and compilation
- Can impact startup time for notebooks with many dependencies

### Library Scope Differences

| Feature | Notebook-Scoped | Cluster-Scoped |
|---------|----------------|----------------|
| **Visibility** | Single notebook + associated jobs | All notebooks on cluster |
| **Persistence** | Lost on detach/restart | Survives cluster restarts |
| **Caching** | No caching (reinstalls each time) | Cached on cluster |
| **Installation Method** | `install.packages()` in notebook | Cluster Libraries UI |
| **Use Case** | Notebook-specific dependencies | Shared team libraries |
| **Spark Integration** | Automatically available on workers for UDFs | Available on all nodes |

### Spark Integration

**Notebook-Scoped Libraries with Spark**:
- Automatically available on workers for SparkR UDFs
- Both SparkR and sparklyr can access these libraries
- sparklyr requires `packages` argument set to `TRUE` (default)

**Example**:
```r
require(devtools)
install_version(package = "caesar",
                repos = "http://cran.us.r-project.org")
library(SparkR)
sparkR.session()

# Library now available in SparkR UDFs across cluster
```

## 5. DataFrames & Tables

### Package Loading and Setup

**Loading Required Packages**:
```r
library(SparkR)    # Auto-establishes SparkSession
library(sparklyr)  # Requires explicit connection
library(dplyr)     # Pre-installed on Databricks
```

**Establishing sparklyr Connection**:
```r
sc <- spark_connect(method = "databricks")
```

### Creating Spark DataFrames from R

#### From JSON Files

```r
jsonDF <- spark_read_json(
  sc      = sc,
  name    = "jsonTable",
  path    = "/FileStore/tables/books.json",
  options = list("multiLine" = TRUE),
  columns = c(
    author    = "character",
    country   = "character",
    pages     = "integer"
  ))
```

#### From Local R Data

```r
irisDF <- sdf_copy_to(
  sc = sc,
  x = iris,
  name = "iris",
  overwrite = TRUE
)
```

### Reading Tables

**sparklyr Method**:
```r
fromTable <- spark_read_table(sc = sc, name = "json_books_agg")
collect(fromTable)
```

**Three-Level Namespace (Unity Catalog)**:
```r
trips <- dplyr::tbl(
  sc,
  dbplyr::in_catalog("samples", "nyctaxi", "trips")
)
```

### Writing Data

**Write to Table**:
```r
group_by(jsonDF, author) |>
  count() |>
  arrange(desc(n)) |>
  spark_write_table(name = "json_books_agg", mode = "overwrite")
```

**Mode Options**:
- `"overwrite"`: Replace existing table
- `"append"`: Add to existing table
- `"error"`: Fail if table exists (default)
- `"ignore"`: Do nothing if table exists

### Displaying DataFrame Contents

**Three Methods**:

1. **SparkR::head** - displays 6 rows by default
```r
head(jsonDF)
```

2. **SparkR::show** - displays 10 rows by default
```r
show(jsonDF)
```

3. **sparklyr::collect** - displays 10 rows by default
```r
collect(jsonDF)
```

### Conversions Between R and Spark

#### Spark to R (Collect to Local Memory)

```r
# Collect entire DataFrame
local_df <- collect(sparkDF)

# Collect with row limit (recommended)
local_df <- sparkDF |>
  head(1000) |>
  collect()
```

**Warning**: Collecting large DataFrames can exhaust driver memory. Always filter/limit before collecting.

#### R to Spark (Distribute to Cluster)

```r
# Copy local R data to Spark
sparkDF <- sdf_copy_to(
  sc = sc,
  x = local_data,
  name = "spark_table_name",
  overwrite = TRUE
)
```

### Data Manipulation with dplyr

#### Adding and Computing Columns

```r
withDate <- jsonDF |>
  mutate(today = current_timestamp())

withMMyyyy <- withDate |>
  mutate(
    month = month(today),
    year  = year(today)
  )

withUnixTimestamp <- withMMyyyy |>
  mutate(
    formatted_date = date_format(today, "yyyy-MM-dd"),
    day = dayofmonth(formatted_date)
  )
```

**Important**: Functions in `dplyr::mutate()` and `dplyr::summarize()` must comply with Hive built-in functions (UDFs/UDAFs).

#### Filtering and Selecting

```r
# Filter rows
filtered_df <- jsonDF |>
  filter(pages > 200)

# Select columns
selected_df <- jsonDF |>
  select(author, pages)
```

**Best Practice**: Use `dplyr::select()` to filter columns before collecting results to minimize data transfer.

#### Grouping and Aggregation

```r
aggregated <- jsonDF |>
  group_by(author) |>
  count() |>
  arrange(desc(n))
```

### Creating Temporary Views

```r
createOrReplaceTempView(withTimestampDF, viewName = "timestampTable")

# Read view back
spark_read_table(sc = sc, name = "timestampTable") |>
  collect()
```

### Statistical Operations

#### Quantile Calculations (Method 1 - dplyr)

```r
quantileDF <- irisDF |>
  group_by(Species) |>
  summarize(
    quantile_25th = percentile_approx(Sepal_Length, 0.25),
    quantile_50th = percentile_approx(Sepal_Length, 0.50),
    quantile_75th = percentile_approx(Sepal_Length, 0.75)
  )
collect(quantileDF)
```

#### Quantile Calculations (Method 2 - sparklyr)

```r
sdf_quantile(
  x = irisDF |> filter(Species == "virginica"),
  column = "Sepal_Length",
  probabilities = c(0.25, 0.5, 0.75, 1.0)
)
```

## 6. Databricks Connect for R

### Setup and Configuration

#### Prerequisites
- Target Databricks workspace and cluster meeting Databricks Connect specifications
- Available cluster ID (found in workspace URL between "clusters" and "configuration")
- R and RStudio Desktop installed
- Python 3.10 (matching cluster version)
- Databricks personal access token

#### Installation Steps

**1. Create Personal Access Token**:
Generated through workspace user settings

**2. Create RStudio Project**:
File > New Project > New Directory > New Project
- Select "Use renv with this project" for dependency isolation

**3. Install Required R Packages** (via Tools > Install Packages):
- sparklyr
- pysparklyr
- reticulate
- usethis
- dplyr
- dbplyr

**4. Configure Python**:
```R
reticulate::install_python(version = "3.10")
```

**5. Install Databricks Connect Package**:

**Option A - Specific Version**:
```R
pysparklyr::install_databricks(version = "13.3")
```

**Option B - Auto-detect from Cluster**:
```R
pysparklyr::install_databricks(cluster_id = "<cluster-id>")
```

**6. Configure Environment Variables**:

Store credentials in `.Renviron` file using:
```R
usethis::edit_r_environ()
```

Add the following:
```
DATABRICKS_HOST=<workspace-url>
DATABRICKS_TOKEN=<personal-access-token>
DATABRICKS_CLUSTER_ID=<cluster-id>
```

### Local Development Workflow

#### Connection Establishment

```R
library(sparklyr)
library(dplyr)
library(dbplyr)

sc <- sparklyr::spark_connect(
  master     = Sys.getenv("DATABRICKS_HOST"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  token      = Sys.getenv("DATABRICKS_TOKEN"),
  method     = "databricks_connect",
  envname    = "r-reticulate"
)
```

#### Working with Tables

```R
# Access Unity Catalog tables
trips <- dplyr::tbl(
  sc,
  dbplyr::in_catalog("samples", "nyctaxi", "trips")
)

# View data
print(trips, n = 5)
```

#### Debugging Workflow

**Supported Features**:
- Set breakpoints in R code
- Inspect variables in Environment view
- Step through code execution
- View DataFrame contents in real-time

**RStudio Integration**:
- Connections view shows catalogs, schemas, tables, and views
- Environment view for variable inspection
- Console for interactive debugging

### Limitations and Differences from Notebooks

#### MLlib Support Considerations

**Critical Limitation**: "Databricks Connect has limited compatibility with Apache Spark MLlib, because Spark MLlib uses RDDs, while Databricks Connect only supports the DataFrame API."

**Workarounds for Full MLlib Access**:
1. Use Databricks notebooks instead
2. Use `db_repl` function from the brickster package for interactive REPL

**Supported ML Operations**:
- DataFrame-based ML pipelines
- Feature engineering with Spark DataFrames
- Limited ML algorithms that don't rely on RDDs

#### Unsupported Features

**Browser-Based Methods**:
- `spark_web()` - not supported (requires local browser access)
- `spark_log()` - not supported (requires local browser access)

**Alternative**: Inspect Spark jobs and logs through Databricks' built-in Spark UI or driver/worker logs in the workspace.

#### API Restrictions

**Only DataFrame API Supported**:
- Full support for DataFrame operations
- No RDD operations
- No low-level Spark Core functionality

#### Support and Maintenance

**Important Notes**:
- This integration isn't officially provided or directly supported by Databricks
- Community support available through Posit Community forums
- Issue reporting via sparklyr GitHub repository
- Refer to sparklyr documentation for detailed Databricks Connect v2 information

### Authentication

**Currently Supported**:
- Databricks personal access tokens ONLY

**Not Supported**:
- OAuth
- Azure AD authentication
- Service principals
- Other authentication methods

## 7. Runtime Considerations

### Available R Versions by Runtime

**Runtime 12.2 LTS and Above**:
- Full `.Rprofile` customization support at `$R_HOME/etc/Rprofile.site`
- Automatic sparklyr distribution
- Pre-configured Spark environment

**Earlier Runtimes**:
- Require `DATABRICKS_ENABLE_RPROFILE=true` for `.Rprofile` support
- sparklyr still automatically distributed

**Runtime 16.0 and Above**:
- SparkR deprecated
- sparklyr recommended for all R development
- Existing SparkR code still functional but not recommended for new projects

### Pre-installed Packages

**Always Available**:
- SparkR (Runtime < 16.0)
- sparklyr (all Runtime versions)
- dplyr (tidyverse integration)
- Base R standard library

**Additional Tools**:
- MLflow for model lifecycle management
- Delta Lake integration
- Visualization libraries

### Runtime-Specific Behaviors

#### Databricks Connect Compatibility

**Minimum Runtime**: 13.0
- Required for Databricks Connect for R
- Earlier runtimes not supported

**Python Version Matching**:
- Python 3.10 required (must match cluster)
- Version mismatch causes connection failures

#### Package Installation Behavior

**Notebook-Scoped Libraries**:
- No persistence across sessions
- No caching between notebooks
- Reinstallation required on each start/reattach

**Cluster Libraries**:
- Persist across cluster restarts
- Available immediately to all notebooks
- Cached on cluster nodes

## 8. Best Practices

### Performance Tips

#### Data Collection

**Always Filter Before Collect**:
```r
# BAD - Collects entire table
local_data <- collect(large_sparkDF)

# GOOD - Filters first
local_data <- large_sparkDF |>
  filter(date > "2023-01-01") |>
  select(essential_columns) |>
  collect()
```

**Reason**: Collecting large DataFrames exhausts driver memory and causes job failures.

#### Column Selection

**Select Early, Select Often**:
```r
# BAD - Carries unnecessary columns
result <- sparkDF |>
  join(other_df) |>
  filter(condition) |>
  select(needed_cols)

# GOOD - Selects early
result <- sparkDF |>
  select(needed_cols) |>
  join(other_df |> select(join_col, other_needed)) |>
  filter(condition)
```

**Benefit**: Reduces data shuffling and network transfer.

#### Caching Strategies

**Cache Reused DataFrames**:
```r
# Cache expensive computation
expensive_df <- sparkDF |>
  complex_transformation() |>
  compute("cached_table")

# Reuse multiple times
result1 <- expensive_df |> operation1()
result2 <- expensive_df |> operation2()
```

### Memory Management

#### Driver Memory

**Monitor Collections**:
- Large `collect()` operations load data into driver memory
- Use `head()` or `limit()` to preview data
- Stream results when possible

**Clear Unused Variables**:
```r
# Clear R workspace
rm(large_object)
gc()

# Clear Spark cache
dbClearCache()
```

#### Worker Memory

**Distributed Operations**:
- sparklyr `spark_apply()` distributes R code across workers
- SparkR `dapply()`, `gapply()`, `spark.lapply()` for distributed processing
- Ensure sufficient worker memory for partition-level operations

**Partition Management**:
```r
# Repartition for better parallelism
optimized_df <- sparkDF |>
  sdf_repartition(partitions = 200)
```

### Common Pitfalls

#### Package Conflicts (SparkR and dplyr)

**Problem**: SparkR masks numerous dplyr functions (arrange, filter, select, mutate, etc.)

**Solutions**:

**Option 1 - Fully Qualified Names**:
```r
library(SparkR)
library(dplyr)

# Use explicit package reference
result <- dplyr::arrange(df, column)
```

**Option 2 - Selective Detachment**:
```r
library(SparkR)
library(dplyr)

# Detach SparkR when using dplyr
detach("package:SparkR")

# Use dplyr functions
result <- arrange(df, column)

# Reattach if needed
library(SparkR)
```

**Option 3 - Load Order**:
```r
# Load SparkR first, dplyr second
library(SparkR)
library(dplyr)
# dplyr functions take precedence
```

#### Hive Function Compliance

**Problem**: Not all R functions work in `mutate()` and `summarize()`

**Solution**: Use Hive built-in functions or create UDFs

**Example - Date Functions**:
```r
# WORKS - Hive functions
withDate <- df |>
  mutate(
    current_ts = current_timestamp(),
    month_num = month(date_col),
    year_num = year(date_col),
    formatted = date_format(date_col, "yyyy-MM-dd")
  )

# DOESN'T WORK - Base R functions
withDate <- df |>
  mutate(formatted = format(date_col, "%Y-%m-%d"))  # ERROR
```

#### Notebook-Scoped Library Reinstallation

**Problem**: Libraries don't persist across sessions

**Solution 1 - Cluster Libraries** (recommended for shared packages):
- Install via cluster Libraries UI
- Available to all notebooks
- Persists across restarts

**Solution 2 - Installation Script** (for notebook-specific packages):
```r
# First cell in notebook
required_packages <- c("arrow", "caesar", "specific_version_pkg")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}
```

**Solution 3 - renv** (for reproducibility):
```r
# Initialize renv in notebook
renv::init()
renv::snapshot()

# Restore environment
renv::restore()
```

#### Connection Variable Naming

**Problem**: Progress tracking doesn't work

**Solution**: Always name connection variable `sc`

```r
# GOOD - Enables progress bars and Spark UI links
sc <- spark_connect(method = "databricks")

# BAD - No progress tracking
connection <- spark_connect(method = "databricks")
```

#### Authentication Security

**Problem**: Hardcoded credentials in scripts

**Solution**: Always use environment variables

```r
# BAD - Hardcoded token
sc <- spark_connect(
  token = "dapi1234567890abcdef"  # NEVER DO THIS
)

# GOOD - Environment variable
sc <- spark_connect(
  token = Sys.getenv("DATABRICKS_TOKEN")
)
```

#### CRAN Repository Reproducibility

**Problem**: Package versions change over time

**Solution**: Use CRAN snapshots (Databricks recommendation)

```r
# Specify CRAN snapshot date
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2024-01-15"))

# Then install packages
install.packages("dplyr")
```

## 9. Code Examples

### Complete Workflow Examples

#### Example 1: Data Analysis Pipeline (sparklyr + dplyr)

```r
# Load libraries
library(sparklyr)
library(dplyr)

# Connect to cluster
sc <- spark_connect(method = "databricks")

# Read data from Unity Catalog
sales_data <- dplyr::tbl(
  sc,
  dbplyr::in_catalog("main", "sales", "transactions")
)

# Data transformation pipeline
monthly_summary <- sales_data |>
  # Add date components
  mutate(
    year = year(transaction_date),
    month = month(transaction_date)
  ) |>
  # Filter recent data
  filter(year >= 2023) |>
  # Select relevant columns
  select(year, month, product_id, amount, quantity) |>
  # Group and aggregate
  group_by(year, month, product_id) |>
  summarize(
    total_amount = sum(amount),
    total_quantity = sum(quantity),
    avg_price = sum(amount) / sum(quantity),
    transaction_count = n()
  ) |>
  # Sort results
  arrange(desc(year), desc(month), desc(total_amount))

# Write results to table
monthly_summary |>
  spark_write_table(
    name = "sales_monthly_summary",
    mode = "overwrite"
  )

# Preview results (collect small sample)
monthly_summary |>
  head(20) |>
  collect() |>
  print()
```

#### Example 2: Statistical Analysis with Iris Dataset

```r
library(sparklyr)
library(dplyr)

# Connect
sc <- spark_connect(method = "databricks")

# Copy local R data to Spark
irisDF <- sdf_copy_to(
  sc = sc,
  x = iris,
  name = "iris",
  overwrite = TRUE
)

# Calculate quantiles by species
quantiles_summary <- irisDF |>
  group_by(Species) |>
  summarize(
    sepal_length_25th = percentile_approx(Sepal_Length, 0.25),
    sepal_length_50th = percentile_approx(Sepal_Length, 0.50),
    sepal_length_75th = percentile_approx(Sepal_Length, 0.75),
    sepal_width_mean = mean(Sepal_Width),
    sepal_width_sd = sd(Sepal_Width),
    count = n()
  )

# Collect and display
results <- collect(quantiles_summary)
print(results)

# Alternative: sparklyr quantile function
virginica_quantiles <- sdf_quantile(
  x = irisDF |> filter(Species == "virginica"),
  column = "Sepal_Length",
  probabilities = c(0.25, 0.5, 0.75, 1.0)
)
print(virginica_quantiles)
```

#### Example 3: JSON Data Processing

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(method = "databricks")

# Read JSON with schema
booksDF <- spark_read_json(
  sc = sc,
  name = "books",
  path = "/FileStore/tables/books.json",
  options = list("multiLine" = TRUE),
  columns = c(
    author = "character",
    title = "character",
    country = "character",
    pages = "integer",
    year = "integer"
  )
)

# Analyze books by author
author_stats <- booksDF |>
  group_by(author) |>
  summarize(
    book_count = n(),
    total_pages = sum(pages),
    avg_pages = mean(pages),
    earliest_year = min(year),
    latest_year = max(year)
  ) |>
  arrange(desc(book_count))

# Write aggregated results
author_stats |>
  spark_write_table(
    name = "books_author_summary",
    mode = "overwrite"
  )

# Display top authors
author_stats |>
  head(10) |>
  collect()
```

#### Example 4: Databricks Connect with Local RStudio

```r
# Setup (run once)
library(sparklyr)
library(pysparklyr)
library(reticulate)
library(usethis)

# Configure environment
usethis::edit_r_environ()
# Add:
# DATABRICKS_HOST=https://your-workspace.cloud.databricks.com
# DATABRICKS_TOKEN=dapi...
# DATABRICKS_CLUSTER_ID=1234-567890-abc123

# Install Python and Databricks Connect
reticulate::install_python(version = "3.10")
pysparklyr::install_databricks(cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"))

# Connect to remote cluster (in new session)
library(sparklyr)
library(dplyr)
library(dbplyr)

sc <- sparklyr::spark_connect(
  master = Sys.getenv("DATABRICKS_HOST"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  token = Sys.getenv("DATABRICKS_TOKEN"),
  method = "databricks_connect",
  envname = "r-reticulate"
)

# Work with remote data
trips <- dplyr::tbl(
  sc,
  dbplyr::in_catalog("samples", "nyctaxi", "trips")
)

# Local development with debugging
trip_summary <- trips |>
  filter(!is.na(fare_amount)) |>
  group_by(pickup_zip) |>
  summarize(
    trip_count = n(),
    avg_fare = mean(fare_amount),
    total_fare = sum(fare_amount)
  ) |>
  arrange(desc(trip_count))

# Collect results
local_results <- trip_summary |>
  head(100) |>
  collect()

# Inspect in RStudio Environment view
View(local_results)
```

#### Example 5: Notebook-Scoped Library Installation

```r
# Install specific package versions
require(devtools)

# Install from CRAN with version control
install_version(
  package = "dplyr",
  version = "1.1.4",
  repos = "http://cran.r-project.org"
)

# Install from GitHub
devtools::install_github("tidyverse/ggplot2")

# Install custom package from file
install.packages(
  pkgs = "/dbfs/FileStore/packages/custom_package_1.0.0.tar.gz",
  type = "source",
  repos = NULL
)

# Verify installation
library(dplyr)
packageVersion("dplyr")

# Use in SparkR UDF (automatically available on workers)
library(SparkR)
sparkR.session()

# Create UDF using notebook-scoped library
schema <- structType(structField("result", "string"))

custom_udf <- dapply(
  sparkDF,
  function(df) {
    # Library available here
    result <- some_function_from_library(df$column)
    data.frame(result = result)
  },
  schema
)
```

#### Example 6: Temporary Views and SQL Integration

```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(method = "databricks")

# Create DataFrame with date transformations
sales_with_dates <- spark_read_table(sc, "sales_raw") |>
  mutate(
    transaction_timestamp = current_timestamp(),
    transaction_date = date_format(transaction_timestamp, "yyyy-MM-dd"),
    year = year(transaction_timestamp),
    month = month(transaction_timestamp),
    day = dayofmonth(transaction_timestamp)
  )

# Create temporary view
createOrReplaceTempView(
  sales_with_dates,
  viewName = "sales_with_dates_view"
)

# Query view with SQL (from Python/SQL notebook)
# %sql SELECT * FROM sales_with_dates_view WHERE year = 2024

# Read view back in R
from_view <- spark_read_table(
  sc = sc,
  name = "sales_with_dates_view"
) |>
  collect()

print(from_view)
```

### Quick Reference Snippets

#### Connection Patterns

```r
# Databricks Notebook
sc <- spark_connect(method = "databricks")

# RStudio Desktop (Databricks Connect)
sc <- spark_connect(
  master = Sys.getenv("DATABRICKS_HOST"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  token = Sys.getenv("DATABRICKS_TOKEN"),
  method = "databricks_connect",
  envname = "r-reticulate"
)

# SparkR (auto-connects)
library(SparkR)
sparkR.session()
```

#### Data Reading Patterns

```r
# From table
df <- spark_read_table(sc, "table_name")

# From Unity Catalog
df <- dplyr::tbl(sc, dbplyr::in_catalog("catalog", "schema", "table"))

# From JSON
df <- spark_read_json(sc, "table", "path/to/file.json")

# From CSV
df <- spark_read_csv(sc, "table", "path/to/file.csv")

# From Parquet
df <- spark_read_parquet(sc, "table", "path/to/file.parquet")
```

#### Data Writing Patterns

```r
# Write to table
spark_write_table(df, "table_name", mode = "overwrite")

# Write to Parquet
spark_write_parquet(df, "path/to/output", mode = "overwrite")

# Write to CSV
spark_write_csv(df, "path/to/output", mode = "overwrite")

# Write to JSON
spark_write_json(df, "path/to/output", mode = "overwrite")
```

#### Common Transformations

```r
# Filter and select
result <- df |>
  filter(column > 100) |>
  select(col1, col2, col3)

# Group and aggregate
result <- df |>
  group_by(category) |>
  summarize(
    count = n(),
    avg_value = mean(value),
    sum_value = sum(value)
  )

# Join operations
result <- df1 |>
  left_join(df2, by = "key_column")

# Window functions
result <- df |>
  group_by(partition_col) |>
  mutate(row_num = row_number(order_by = sort_col))
```

## 10. References

### Official Documentation URLs Processed

1. **Databricks for R developers**
   https://docs.databricks.com/aws/en/sparkr/
   - Overview of R on Databricks ecosystem
   - Runtime versions and sparklyr support
   - SparkR deprecation notice (Runtime 16.0+)
   - Cluster architecture (single-node vs distributed)
   - Library installation methods and customization

2. **sparklyr | Databricks**
   https://docs.databricks.com/aws/en/sparkr/sparklyr
   - sparklyr connection methods
   - Progress tracking configuration
   - SparkR and sparklyr compatibility
   - Unsupported features (spark_web, spark_log)
   - Ecosystem integration with tidyverse

3. **Work with DataFrames and tables in R**
   https://docs.databricks.com/aws/pt/sparkr/dataframes-tables
   - Creating Spark DataFrames from R data and files
   - Reading and writing tables
   - Data manipulation with dplyr
   - Statistical operations (quantiles, aggregations)
   - Temporary views and SQL integration
   - Conversions between R and Spark DataFrames

4. **Databricks Connect for R**
   https://docs.databricks.com/aws/en/dev-tools/databricks-connect/r/
   - RStudio Desktop setup and configuration
   - Authentication with personal access tokens
   - Environment variable configuration
   - Connection code examples
   - MLlib limitations and workarounds
   - Unsupported features and alternatives
   - Community support information

5. **Notebook-scoped R libraries**
   https://docs.databricks.com/aws/en/libraries/notebooks-r-libraries
   - Scope and persistence characteristics
   - Installation methods (CRAN, GitHub, Bioconductor)
   - Cluster vs notebook library differences
   - Spark integration for UDFs
   - Caching limitations
   - Package removal procedures

### Additional Resources Mentioned

- **MLflow**: Model lifecycle management integration
- **Delta Lake**: Table format integration
- **RStudio on Databricks**: Native RStudio environment
- **Shiny on Databricks**: Interactive app deployment
- **renv**: Dependency management support
- **brickster package**: `db_repl` function for MLlib access
- **Posit Community forums**: Community support for Databricks Connect
- **sparklyr GitHub repository**: Issue reporting and documentation

### Related Documentation

- SparkR vs sparklyr comparison guide
- Databricks Connect specifications and requirements
- Unity Catalog three-level namespace documentation
- Spark UI and logging documentation
- Cluster configuration and library management
- Runtime release notes and version compatibility

### Version-Specific References

| Runtime Version | Key Features |
|----------------|--------------|
| **< 12.2 LTS** | Requires `DATABRICKS_ENABLE_RPROFILE=true` for customization |
| **12.2 LTS+** | Native `.Rprofile` support at `$R_HOME/etc/Rprofile.site` |
| **13.0+** | Databricks Connect for R support |
| **16.0+** | SparkR deprecated, sparklyr recommended |

### Support Channels

- **Databricks Support**: Official platform issues
- **Posit Community**: Databricks Connect for R questions
- **sparklyr GitHub**: sparklyr-specific issues and feature requests
- **Stack Overflow**: Community Q&A (tags: databricks, sparkly r, sparkr)

---

**Document Version**: 1.0
**Last Updated**: 2026-03-19
**Coverage**: Databricks Runtime 13.0+ with focus on sparklyr
**Status**: Comprehensive extraction complete
