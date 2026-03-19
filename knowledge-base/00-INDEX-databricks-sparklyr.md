# R + Databricks + sparklyr Knowledge Base - INDEX

## Overview

This knowledge base provides comprehensive guidance for using **R with Databricks and Apache Spark** via the **sparklyr** package. It covers platform setup, data manipulation, machine learning, and production deployment.

**Target Audience**: R developers working with big data on Databricks
**Scope**: sparklyr-first approach (SparkR is deprecated in Databricks Runtime 16.0+)
**Version**: Based on Databricks Runtime 13.0+ and sparklyr 1.8+

---

## Knowledge Base Structure

### 📘 [01-platform-core.md](01-platform-core.md) (~33KB)
**Databricks Platform Core for R**

**Topics Covered**:
- R on Databricks ecosystem overview
- Development environments (notebooks, RStudio, jobs)
- Connection methods and authentication
- Package management (notebook-scoped vs cluster libraries)
- DataFrames and tables operations
- Databricks Connect setup and limitations
- Runtime considerations and best practices

**Key Sections**:
1. Overview (SparkR deprecation, runtime versions)
2. Development Environments
3. Connection & Setup
4. Package Management
5. DataFrames & Tables
6. Databricks Connect for R
7. Runtime Considerations
8. Best Practices
9. Code Examples
10. References

**When to Consult**:
- Setting up Databricks environment
- Connecting R to Databricks clusters
- Managing R packages in Databricks
- Using Databricks Connect with RStudio
- Platform-specific configurations

---

### 📗 [02-sparklyr-api.md](02-sparklyr-api.md) (~28KB)
**sparklyr API & Ecosystem**

**Topics Covered**:
- sparklyr package overview and philosophy
- Connection management (spark_connect, configurations)
- Spark DataFrame API (sdf_* functions)
- Machine learning (ml_* functions, pipelines, model operations)
- Data import/export (spark_read_*, spark_write_*)
- dplyr integration patterns
- Streaming operations
- Extensions and advanced features (spark_apply, UDFs)
- Performance optimization strategies

**Key Sections**:
1. Package Overview
2. Connection Management
3. Spark DataFrame API (sdf_*)
4. Machine Learning (ml_*)
5. Data Import/Export
6. dplyr Integration
7. Streaming
8. Extensions & Advanced
9. Performance & Optimization
10. Common Patterns
11. Code Examples
12. References

**When to Consult**:
- Learning sparklyr function APIs
- Building ML pipelines
- Reading/writing data in various formats
- Implementing streaming workflows
- Optimizing Spark operations

---

### 📙 [03-dbplyr-translation.md](03-dbplyr-translation.md) (~33KB)
**dbplyr Translation & Remote Data Manipulation**

**Topics Covered**:
- dbplyr overview and lazy evaluation model
- dplyr verbs translation to Spark SQL
- Function translation (string, date, math, conditional)
- Lazy evaluation (show_query, explain, compute, collect)
- SQL generation and inspection
- Limitations and workarounds
- Best practices for remote data manipulation
- Modern dbplyr patterns (.by, across, join_by)
- DBI integration

**Key Sections**:
1. Overview
2. Core dplyr Verbs with Spark
3. Function Translation
4. Lazy Evaluation
5. SQL Generation
6. Limitations & Workarounds
7. Best Practices
8. Modern dbplyr Patterns
9. DBI Integration
10. Code Examples
11. Comparison Tables (R → SQL)
12. References

**When to Consult**:
- Using dplyr with Spark data
- Understanding query translation
- Debugging SQL generation issues
- Optimizing dplyr queries for Spark
- Handling translation limitations

---

### 📕 [04-advanced-topics.md](04-advanced-topics.md) (~25KB)
**Advanced Topics & Resources**

**Topics Covered**:
- Spark architecture fundamentals (driver, executors, partitions)
- Machine learning pipelines and MLlib
- Delta Lake integration (ACID, time travel, optimization)
- Performance optimization strategies
- Production deployment patterns
- Streaming and real-time processing
- SparkR legacy and migration guidance
- Troubleshooting common issues
- Security and governance

**Key Sections**:
1. Spark Architecture Fundamentals
2. Machine Learning Pipelines
3. Delta Lake Integration
4. Performance Optimization
5. Production Deployment
6. Streaming & Real-Time
7. SparkR Legacy & Migration
8. Troubleshooting & Debugging
9. Security & Governance
10. Key Resources

**When to Consult**:
- Understanding Spark internals
- Working with Delta Lake tables
- Optimizing query performance
- Deploying to production
- Migrating from SparkR
- Troubleshooting issues

---

## Quick Reference by Task

### Getting Started
→ **01-platform-core.md**: Setup, connection, authentication

### Data Manipulation
→ **03-dbplyr-translation.md**: dplyr verbs, filtering, joining, aggregating
→ **02-sparklyr-api.md**: sdf_* functions for Spark-specific operations

### Machine Learning
→ **02-sparklyr-api.md**: ml_* functions overview
→ **04-advanced-topics.md**: ML pipelines, feature engineering, tuning

### Data I/O
→ **02-sparklyr-api.md**: spark_read_* and spark_write_* functions
→ **04-advanced-topics.md**: Delta Lake operations

### Performance
→ **03-dbplyr-translation.md**: Query optimization, lazy evaluation
→ **04-advanced-topics.md**: Partitioning, caching, broadcast joins

### Production
→ **04-advanced-topics.md**: Deployment patterns, scheduling, monitoring
→ **01-platform-core.md**: Jobs, workflows, cluster configuration

### Troubleshooting
→ **04-advanced-topics.md**: Common issues and solutions
→ **03-dbplyr-translation.md**: Translation debugging (show_query, explain)

---

## Key Concepts Across All Docs

### Core Technologies
- **Databricks**: Cloud platform for Apache Spark
- **Apache Spark**: Distributed data processing engine
- **sparklyr**: R interface to Spark (recommended)
- **SparkR**: Legacy R interface (deprecated in DBR 16+)
- **dbplyr**: Translates dplyr to SQL/Spark operations
- **Delta Lake**: ACID-compliant storage layer

### Development Patterns
- **Lazy Evaluation**: Operations build query plan; execution deferred until collect()
- **Distributed Computing**: Data partitioned across cluster; operations parallelized
- **Broadcast Joins**: Small tables sent to all executors for efficient joins
- **Medallion Architecture**: Bronze (raw) → Silver (cleaned) → Gold (aggregated)

### Common Workflows

**1. Interactive Analysis** (Databricks Notebooks):
```r
library(sparklyr)
library(dplyr)

sc <- spark_connect(method = "databricks")
data <- spark_read_table(sc, "catalog.schema.table")

result <- data %>%
  filter(date >= "2024-01-01") %>%
  group_by(category) %>%
  summarize(total = sum(amount)) %>%
  collect()
```

**2. Local Development** (RStudio + Databricks Connect):
```r
sc <- spark_connect(
  method = "databricks",
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID")
)

# Develop and test locally...

spark_disconnect(sc)
```

**3. Production Jobs** (Scheduled Notebooks):
```r
# Parameterized notebook
library(dbutils)
date <- dbutils.widgets.get("date")

# ETL pipeline
process_data(date) %>%
  spark_write_table("output_table", mode = "overwrite")

dbutils.notebook.exit("SUCCESS")
```

---

## Critical Warnings & Best Practices

### ⚠️ SparkR Deprecation
**SparkR is deprecated in Databricks Runtime 16.0+**. Migrate to sparklyr for all new development.
→ See **04-advanced-topics.md** Section 7 for migration guide.

### ⚠️ Memory Management
**Never `collect()` large datasets** - always aggregate or filter first.
```r
# BAD
all_data <- spark_read_table(sc, "huge_table") %>% collect()

# GOOD
summary <- spark_read_table(sc, "huge_table") %>%
  group_by(category) %>%
  summarize(total = sum(amount)) %>%
  collect()
```

### ⚠️ Databricks Connect Limitations
- No `spark_apply()` support
- Limited MLlib (only Logistic Regression in DBR 14.1+)
- Serverless cannot persist data in memory
→ See **01-platform-core.md** Section 6 for full limitations.

### ✅ Performance Best Practices
1. **Filter early**: Push predicates down to storage
2. **Broadcast small tables**: Use `sdf_broadcast()` for dimension tables < 100MB
3. **Cache reused data**: Use `compute()` for intermediate results
4. **Partition appropriately**: Match parallelism to cluster size
5. **Avoid shuffles**: Repartition on join keys when possible

### ✅ Query Inspection
Always inspect generated SQL before collecting large results:
```r
query %>% show_query()  # See SQL
query %>% explain()     # See execution plan
```

---

## External Resources

### Official Documentation
- **Databricks R Guide**: https://docs.databricks.com/en/sparkr/
- **sparklyr Portal**: https://spark.posit.co/
- **sparklyr Reference**: https://spark.posit.co/packages/sparklyr/latest/reference/
- **dbplyr**: https://dbplyr.tidyverse.org/
- **Delta Lake**: https://docs.delta.io/

### Books
- **Mastering Apache Spark with R**: https://therinspark.com/
- **Scale Data Science with Spark and R**: https://sparklyr.github.io/sparklyr-site/

### Support
- **sparklyr GitHub**: https://github.com/sparklyr/sparklyr
- **Posit Community**: https://community.rstudio.com/
- **Databricks Community**: https://community.databricks.com/

---

## Knowledge Base Metadata

**Created**: 2026-03-19
**Sources Processed**: 17 references (Priority A & B)
**Total Size**: ~120KB across 4 files
**Focus**: Practical, production-ready guidance for R + Databricks + sparklyr
**Complementary Skills**:
- `r-datascience` - Local data analysis with tidyverse/tidymodels
- `tidyverse-expert` - Advanced dplyr/tidyr patterns
- `r-tidymodels` - Local machine learning
- `r-performance` - R code optimization

**Next Steps**: Use this knowledge base to create `r-databricks-sparklyr` Claude Code skill.

---

**End of Index**
