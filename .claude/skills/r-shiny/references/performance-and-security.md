# Performance and Security

## Performance Optimization

### Profiling and Benchmarking

**Step 1: Profile Your App**

```r
library(profvis)

# Profile a section of code
profvis({
  # Run app or specific operations
  result <- expensive_computation(data)
})

# Profile during app development
server <- function(input, output, session) {
  output$plot <- renderPlot({
    profvis::pause(0.01)  # Help profiler capture short operations
    generate_plot(data())
  })
}
```

**Step 2: Load Testing**

```r
# Install shinyloadtest
# remotes::install_github("rstudio/shinyloadtest")

# Record session
shinyloadtest::record_session("http://localhost:3838")

# Run load test (simulate 10 concurrent users)
shinycannon record.log http://localhost:3838 \
  --workers 10 \
  --loaded-duration-minutes 5 \
  --output-dir run1

# Analyze results
shinyloadtest::load_runs("run1")
```

### Caching Strategies

**Pattern 1: bindCache() for Reactive Expressions**

```r
# Cache based on input parameters
expensive_data <- reactive({
  Sys.sleep(2)  # Simulated expensive operation
  process_data(input$param1, input$param2)
}) |> bindCache(input$param1, input$param2)

# First user with params (A, B): 2 seconds
# Second user with params (A, B): instant (cached)
# Third user with params (C, D): 2 seconds (cache miss)
```

**Pattern 2: bindCache() for Outputs**

```r
output$plot <- renderPlot({
  ggplot(filtered_data(), aes(x = var1, y = var2)) +
    geom_point() +
    theme_minimal()
}) |> bindCache(input$var1, input$var2, input$filter)

# Plots cached across all users with same parameters
```

**Pattern 3: renderCachedPlot()**

```r
# Specialized for plots, includes sizing in cache key
output$plot <- renderCachedPlot(
  {
    expensive_plot(data())
  },
  cacheKeyExpr = list(input$dataset, input$param),
  sizePolicy = sizeGrowthRatio(width = 400, height = 400, growthRate = 1.2)
)
```

**Pattern 4: Memoise for Function-Level Caching**

```r
library(memoise)

# Cache expensive function
expensive_calc <- memoise(function(x, y) {
  Sys.sleep(2)
  x + y
})

# First call: slow
result1 <- expensive_calc(1, 2)

# Second call with same args: instant
result2 <- expensive_calc(1, 2)

# Clear cache when needed
forget(expensive_calc)
```

### Data Preprocessing

**Pattern 1: Load Data at Startup**

```r
# Load once when app starts (outside server)
large_dataset <- readRDS("data/large_file.rds")
lookup_table <- read.csv("data/lookup.csv")

# Pre-process at startup
processed_data <- large_dataset |>
  mutate(date = as.Date(date)) |>
  filter(!is.na(value))

server <- function(input, output, session) {
  # Just filter pre-loaded data
  filtered <- reactive({
    processed_data |>
      filter(category == input$category)
  })
}
```

**Pattern 2: Scheduled Pre-computation**

```r
# R script run on schedule (cron/Task Scheduler)
# preprocess_data.R
library(dplyr)

raw <- fetch_from_database()

processed <- raw |>
  group_by(category, date) |>
  summarize(
    total = sum(value),
    mean = mean(value),
    .groups = "drop"
  )

saveRDS(processed, "data/processed.rds")

# App just loads pre-processed data
server <- function(input, output, session) {
  data <- reactive({
    readRDS("data/processed.rds")
  })
}
```

### Reduce Computation Scope

**Pattern 1: Conditional Computation by Tab**

```r
# Only compute when tab visible
output$expensive_analysis <- renderPlot({
  req(input$tabs == "analysis")  # Skip if tab not active
  run_complex_analysis(data())
})

# Or use tabset's built-in lazy loading
tabsetPanel(
  type = "hidden",  # Hide tabs, show via updateTabsetPanel
  tabPanelBody("tab1", ...)
)
```

**Pattern 2: Limit Data Processing**

```r
# Don't process entire dataset if showing top 10
top_products <- reactive({
  # Use slice_max instead of arrange + head
  sales_data() |>
    slice_max(revenue, n = 10)
})

# For data tables, let server handle pagination
output$table <- renderDataTable(
  large_dataset,
  server = TRUE,  # Only send visible rows to browser
  options = list(pageLength = 25)
)
```

**Pattern 3: Debounce Rapid Inputs**

```r
# Wait for user to stop typing
search_term <- reactive({
  input$search
}) |> debounce(500)  # 500ms delay

results <- reactive({
  search_database(search_term())
})

# Throttle for continuous inputs
mouse_pos <- reactive({
  c(input$plot_hover$x, input$plot_hover$y)
}) |> throttle(100)  # Max once per 100ms
```

### Async Programming

**For Blocking Operations**

```r
library(promises)
library(future)
plan(multisession)  # Enable parallel processing

# Async reactive
data <- reactive({
  future({
    # Long-running operation
    Sys.sleep(5)
    read_big_file()
  })
})

# Async output
output$result <- renderText({
  data() %...>% {
    paste("Loaded", nrow(.), "rows")
  }
})
```

## Security Best Practices

### Input Validation

**Always Validate Server-Side**

```r
# ✅ GOOD: Server-side validation
server <- function(input, output, session) {
  validated_data <- reactive({
    # Validate file upload
    req(input$file)

    # Check file extension
    ext <- tools::file_ext(input$file$name)
    validate(
      need(ext == "csv", "Only CSV files allowed")
    )

    # Check file size (10 MB limit)
    validate(
      need(input$file$size < 10e6, "File too large (max 10 MB)")
    )

    # Validate data contents
    data <- read.csv(input$file$datapath)
    validate(
      need(nrow(data) > 0, "File is empty"),
      need("id" %in% names(data), "Missing 'id' column")
    )

    data
  })
}
```

**Whitelist Inputs**

```r
# Define allowed values
ALLOWED_COLUMNS <- c("mpg", "cyl", "hp", "wt")
ALLOWED_METHODS <- c("lm", "glm", "loess")

server <- function(input, output, session) {
  # Validate against whitelist
  selected_col <- reactive({
    validate(
      need(input$column %in% ALLOWED_COLUMNS,
           "Invalid column selection")
    )
    input$column
  })

  # Use validated value
  output$plot <- renderPlot({
    plot(mtcars[[selected_col()]])
  })
}
```

**Sanitize Inputs**

```r
# Remove dangerous characters
sanitize_filename <- function(name) {
  # Keep only alphanumeric, dash, underscore, period
  gsub("[^A-Za-z0-9._-]", "", name)
}

server <- function(input, output, session) {
  output$download <- downloadHandler(
    filename = function() {
      # Sanitize user-provided filename
      base <- sanitize_filename(input$filename)
      paste0(base, ".csv")
    },
    content = function(file) {
      write.csv(data(), file)
    }
  )
}
```

### Avoiding Code Injection

**Never Use parse() or eval() with User Input**

```r
# ❌ DANGEROUS: User input executed as code
user_formula <- input$formula  # Could be: "system('rm -rf /')"
result <- eval(parse(text = user_formula))  # NEVER DO THIS

# ✅ SAFE: Whitelist allowed formulas
ALLOWED_FORMULAS <- c(
  "mpg ~ wt",
  "mpg ~ wt + hp",
  "mpg ~ wt + hp + cyl"
)

server <- function(input, output, session) {
  formula <- reactive({
    validate(
      need(input$formula %in% ALLOWED_FORMULAS,
           "Invalid formula")
    )
    as.formula(input$formula)
  })

  model <- reactive({
    lm(formula(), data = mtcars)
  })
}
```

**Safe String Interpolation**

```r
# ❌ DANGEROUS: glue() evaluates expressions
library(glue)
message <- glue("Hello {input$name}")  # If name = "{system('rm -rf /')}"

# ✅ SAFE: glue_safe() doesn't evaluate
library(glue)
message <- glue_safe("Hello {input$name}")

# ✅ SAFE: Use paste() for simple cases
message <- paste("Hello", input$name)
```

**Safe SQL Queries**

```r
library(DBI)
library(glue)

# ❌ DANGEROUS: SQL injection vulnerability
query <- paste0("SELECT * FROM users WHERE id = ", input$user_id)
result <- dbGetQuery(con, query)

# ✅ SAFE: Parameterized query
result <- dbGetQuery(
  con,
  "SELECT * FROM users WHERE id = ?",
  params = list(input$user_id)
)

# ✅ SAFE: glue_sql with proper quoting
library(glue)
result <- dbGetQuery(
  con,
  glue_sql("SELECT * FROM users WHERE id = {input$user_id}", .con = con)
)

# ✅ SAFE: Use dbplyr for complex queries
library(dplyr)
result <- tbl(con, "users") |>
  filter(id == !!input$user_id) |>
  collect()
```

### Credential Management

**Never Hardcode Credentials**

```r
# ❌ BAD: Hardcoded credentials
con <- dbConnect(
  RPostgres::Postgres(),
  host = "db.example.com",
  user = "admin",
  password = "secret123",  # NEVER DO THIS
  dbname = "mydb"
)

# ✅ GOOD: Environment variables
con <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("DB_HOST"),
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD"),
  dbname = Sys.getenv("DB_NAME")
)

# Set in .Renviron file (git-ignored):
# DB_HOST=db.example.com
# DB_USER=admin
# DB_PASSWORD=secret123
# DB_NAME=mydb
```

**Use config Package for Multiple Environments**

```r
# config.yml
default:
  database:
    host: localhost
    port: 5432
  api_key: dev_key

production:
  database:
    host: prod-db.example.com
    port: 5432
  api_key: !expr Sys.getenv("API_KEY")

# In app
library(config)
cfg <- config::get()

con <- dbConnect(
  RPostgres::Postgres(),
  host = cfg$database$host,
  port = cfg$database$port,
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD")
)

api_result <- GET(api_url, add_headers(Authorization = cfg$api_key))
```

### Rate Limiting and Resource Protection

**Limit Expensive Operations**

```r
# Track operation frequency per session
server <- function(input, output, session) {
  last_run <- reactiveVal(Sys.time() - 60)

  results <- eventReactive(input$run, {
    # Enforce minimum 10-second interval
    time_since_last <- as.numeric(Sys.time() - last_run())

    validate(
      need(time_since_last >= 10,
           "Please wait 10 seconds between requests")
    )

    last_run(Sys.time())
    expensive_computation()
  })
}
```

**File Upload Limits**

```r
# Set in app options
options(shiny.maxRequestSize = 10 * 1024^2)  # 10 MB limit

# Also validate in server
server <- function(input, output, session) {
  data <- reactive({
    req(input$file)

    validate(
      need(input$file$size <= 10 * 1024^2,
           "File must be under 10 MB")
    )

    read.csv(input$file$datapath)
  })
}
```

### Data Protection

**Don't Expose Sensitive Data**

```r
# ❌ BAD: Exposing full dataset with sensitive info
output$table <- renderDataTable({
  full_user_data  # Contains emails, passwords, SSNs
})

# ✅ GOOD: Filter sensitive columns
output$table <- renderDataTable({
  full_user_data |>
    select(-email, -password_hash, -ssn, -credit_card)
})
```

**Sanitize Error Messages**

```r
# ❌ BAD: Error reveals system information
tryCatch(
  dbGetQuery(con, query),
  error = function(e) {
    showNotification(e$message, type = "error")  # Could expose SQL structure
  }
)

# ✅ GOOD: Generic error message
tryCatch(
  dbGetQuery(con, query),
  error = function(e) {
    # Log full error server-side
    message("Database error: ", e$message)

    # Show generic error to user
    showNotification("An error occurred. Please try again.", type = "error")
  }
)
```

### Authentication and Authorization

**Basic Authentication with shinymanager**

```r
library(shinymanager)

# Define credentials
credentials <- data.frame(
  user = c("admin", "user"),
  password = c("admin_pw", "user_pw"),
  admin = c(TRUE, FALSE),
  stringsAsFactors = FALSE
)

# Secure app
ui <- secure_app(ui)

server <- function(input, output, session) {
  # Check credentials
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  # Access user info
  observe({
    username <- reactiveValuesToList(res_auth)$user
    is_admin <- reactiveValuesToList(res_auth)$admin
  })

  # Conditional logic based on role
  output$admin_panel <- renderUI({
    req(res_auth$admin == TRUE)
    adminPanelUI()
  })
}
```

### Content Security Policy

```r
# Add security headers
ui <- function(request) {
  tagList(
    tags$head(
      tags$meta(`http-equiv` = "Content-Security-Policy",
                content = "default-src 'self'; script-src 'self' 'unsafe-inline'")
    ),
    # ... rest of UI
  )
}
```

## Testing for Security

```r
# Test input validation
test_that("rejects invalid file types", {
  testServer(server, {
    session$setInputs(file = list(
      name = "malicious.exe",
      size = 1000,
      datapath = tempfile()
    ))

    expect_error(validated_data())
  })
})

# Test SQL injection prevention
test_that("prevents SQL injection", {
  testServer(server, {
    session$setInputs(user_id = "1 OR 1=1")

    # Should not return all users
    result <- user_data()
    expect_lte(nrow(result), 1)
  })
})
```

## Performance Checklist

✅ Profile app with `profvis` to identify bottlenecks
✅ Use `bindCache()` for expensive reactive expressions
✅ Preprocess data outside server function when possible
✅ Use `server = TRUE` for large data tables
✅ Debounce/throttle rapid user inputs
✅ Limit computation to visible tabs
✅ Consider async operations for blocking tasks
✅ Load test with `shinyloadtest` before deployment

## Security Checklist

✅ Validate ALL user inputs server-side
✅ Use whitelists for allowed values
✅ Never use `parse()` or `eval()` with user input
✅ Use parameterized SQL queries
✅ Store credentials in environment variables
✅ Limit file upload sizes
✅ Filter sensitive data before displaying
✅ Add rate limiting for expensive operations
✅ Implement authentication if needed
✅ Test security with malicious inputs

---

**Remember**: Performance optimization should be driven by profiling data, not guesswork. Security should be built in from the start, not added later.
