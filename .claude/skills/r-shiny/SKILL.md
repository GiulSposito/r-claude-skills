---
name: r-shiny
description: Expert Shiny app development in R - reactive programming, UI design, modules, performance, and security. Use when working with shiny, shinydashboard, or building interactive R web applications. Triggers on shiny library imports, server/ui function patterns, reactive expressions, or user requests for Shiny help.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Expert Shiny Development in R

You are an expert Shiny developer following best practices from Hadley Wickham's "Mastering Shiny". This skill provides comprehensive guidance for building production-quality Shiny applications.

## Core Shiny Architecture

Every Shiny app has three components:

1. **UI (User Interface)**: Visual layout using `fluidPage()`, inputs, and outputs
2. **Server Function**: Reactive logic connecting inputs to outputs
3. **shinyApp() Call**: Launches the application

```r
library(shiny)

ui <- fluidPage(
  titlePanel("My App"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Sample size", 1, 100, 50)
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    hist(rnorm(input$n))
  })
}

shinyApp(ui, server)
```

## Reactive Programming Principles

### The Three Reactive Components

1. **Reactive Sources (Inputs)**
   - User inputs: `input$name`
   - Read-only, reflects browser state
   - Automatically invalidate dependents when changed

2. **Reactive Conductors (Expressions)**
   - Created with `reactive({})`
   - Lazy and cached - only compute when needed
   - Called like functions: `filtered_data()`
   - Use for expensive computations used multiple times

```r
# Good: Computed once, used multiple times
filtered <- reactive({
  data |> filter(category == input$category)
})

output$plot <- renderPlot({ plot(filtered()) })
output$table <- renderTable({ head(filtered()) })
```

3. **Reactive Endpoints (Observers & Outputs)**
   - Outputs: `output$name <- render*()`
   - Observers: `observe({})`, `observeEvent()`
   - Eager and forgetful - run immediately when invalidated
   - Use for side effects (logging, file writes, external updates)

### Key Reactive Patterns

**Pattern 1: Input Validation**
```r
# Use req() to pause execution until valid
output$plot <- renderPlot({
  req(input$file)  # Wait for file upload
  data <- read.csv(input$file$datapath)
  plot(data)
})

# Use validate() for user-facing error messages
output$summary <- renderPrint({
  validate(
    need(input$n > 0, "Sample size must be positive"),
    need(input$n <= 1000, "Sample size too large")
  )
  rnorm(input$n)
})
```

**Pattern 2: Event-Driven Reactivity**
```r
# Only recalculate when button clicked
results <- eventReactive(input$run_button, {
  expensive_computation(input$params)
})

# Run side effects on specific events
observeEvent(input$save_button, {
  saveRDS(current_data(), "output.rds")
  showNotification("Data saved!")
})
```

**Pattern 3: Isolating Dependencies**
```r
# Prevent unwanted reactive dependencies
observe({
  # Reacts to input$trigger, but not input$value
  isolate({
    value <- input$value
  })
  process(input$trigger, value)
})
```

**Pattern 4: Manual Reactive Values**
```r
# For complex state management outside reactive graph
counter <- reactiveVal(0)

observeEvent(input$increment, {
  counter(counter() + 1)  # Get with (), set with (value)
})

output$count <- renderText({
  counter()
})
```

## UI Design Patterns

### Layout Structures

**Single-Page Layouts**
```r
# Sidebar layout (most common)
fluidPage(
  titlePanel("Title"),
  sidebarLayout(
    sidebarPanel(
      # Inputs here
    ),
    mainPanel(
      # Outputs here
    )
  )
)

# Custom grid layout (12-column system)
fluidPage(
  fluidRow(
    column(4, "Sidebar content"),
    column(8, "Main content")
  ),
  fluidRow(
    column(6, "Left half"),
    column(6, "Right half")
  )
)
```

**Multi-Page Layouts**
```r
# Tabbed interface
navbarPage("App Title",
  tabPanel("Analysis",
    # First page content
  ),
  tabPanel("Results",
    # Second page content
  ),
  navbarMenu("More",
    tabPanel("About"),
    tabPanel("Help")
  )
)
```

### Common Input Controls

```r
# Text inputs
textInput("name", "Name", value = "", placeholder = "Enter name")
textAreaInput("comments", "Comments", rows = 3)

# Numeric inputs
numericInput("age", "Age", value = 25, min = 0, max = 120)
sliderInput("height", "Height", min = 0, max = 250, value = 170)

# Choice inputs
selectInput("state", "State", choices = state.name)
radioButtons("type", "Type", choices = c("A", "B", "C"))
checkboxGroupInput("options", "Options", choices = c("X", "Y", "Z"))

# Date inputs
dateInput("start", "Start Date")
dateRangeInput("period", "Period")

# File and action inputs
fileInput("upload", "Upload File", accept = c(".csv", ".xlsx"))
actionButton("run", "Run Analysis", class = "btn-primary")
```

### Common Output Types

```r
# Text outputs
textOutput("message")          # renderText() for formatted text
verbatimTextOutput("code")     # renderPrint() for console output

# Table outputs
tableOutput("static_table")    # renderTable() for static display
dataTableOutput("data_table")  # renderDataTable() for interactive tables

# Plot outputs
plotOutput("plot")             # renderPlot() for ggplot2, base plots
plotOutput("plot",             # With interactivity
  click = "plot_click",
  brush = "plot_brush",
  hover = "plot_hover"
)

# Downloads
downloadButton("download", "Download Data")
```

## Dynamic UI Patterns

### Update Existing Inputs

```r
# Change input values programmatically
observeEvent(input$reset, {
  updateSliderInput(session, "n", value = 50)
  updateSelectInput(session, "category", selected = "All")
})

# Cascading inputs
observeEvent(input$country, {
  cities <- get_cities(input$country)
  updateSelectInput(session, "city", choices = cities)
})
```

### Generate UI Programmatically

```r
# Dynamic number of inputs
output$dynamic_inputs <- renderUI({
  n <- input$num_vars
  lapply(1:n, function(i) {
    numericInput(paste0("var_", i), paste("Variable", i), value = 0)
  })
})

# Access programmatically-named inputs
observe({
  values <- sapply(1:input$num_vars, function(i) {
    input[[paste0("var_", i)]]
  })
})
```

### Conditional Panels

```r
# Show/hide based on input value
conditionalPanel(
  condition = "input.type == 'advanced'",
  sliderInput("detail", "Detail Level", 1, 10, 5)
)
```

## Shiny Modules

Modules create reusable, isolated components with namespaced IDs.

### Module Structure

```r
# Module UI function
mod_analysis_ui <- function(id) {
  ns <- NS(id)  # Namespace function
  tagList(
    selectInput(ns("variable"), "Variable", choices = NULL),
    plotOutput(ns("plot"))
  )
}

# Module server function
mod_analysis_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Update choices when data changes
    observe({
      updateSelectInput(session, "variable", choices = names(data()))
    })

    output$plot <- renderPlot({
      req(input$variable)
      hist(data()[[input$variable]])
    })

    # Return reactive values if needed
    return(reactive({
      input$variable
    }))
  })
}

# Use in main app
ui <- fluidPage(
  mod_analysis_ui("analysis1"),
  mod_analysis_ui("analysis2")
)

server <- function(input, output, session) {
  data <- reactive({ mtcars })
  selected1 <- mod_analysis_server("analysis1", data)
  selected2 <- mod_analysis_server("analysis2", data)
}
```

### Module Best Practices

1. **Validate inputs with `stopifnot()`**
```r
mod_server <- function(id, data) {
  stopifnot(is.reactive(data))  # Ensure data is reactive
  moduleServer(id, function(input, output, session) {
    # ...
  })
}
```

2. **Return reactive values or lists of reactives**
```r
return(list(
  selected = reactive({ input$choice }),
  filtered = reactive({ filter_data() })
))
```

3. **Document module interfaces clearly**
```r
#' Analysis Module
#'
#' @param id Module namespace ID
#' @param data Reactive expression returning a data frame
#' @return List with selected (reactive string) and filtered (reactive data frame)
```

## User Feedback Patterns

### Validation and Error Handling

```r
# Graceful validation
output$result <- renderText({
  validate(
    need(input$file, "Please upload a file"),
    need(nrow(data()) > 0, "File is empty")
  )
  analyze(data())
})

# Feedback package for inline messages
library(shinyFeedback)

observeEvent(input$email, {
  if (grepl("@", input$email)) {
    feedbackSuccess("email", "Valid email")
  } else {
    feedbackDanger("email", "Invalid email format")
  }
})
```

### Notifications and Progress

```r
# Simple notifications
showNotification("Analysis complete!", type = "message")
showNotification("Error occurred", type = "error", duration = 10)

# Progress bars for long operations
observeEvent(input$run, {
  withProgress(message = "Processing...", {
    for (i in 1:10) {
      incProgress(1/10, detail = paste("Step", i))
      Sys.sleep(0.5)
    }
  })
})
```

### Modal Dialogs

```r
# Confirmation dialog
observeEvent(input$delete, {
  showModal(modalDialog(
    title = "Confirm Deletion",
    "Are you sure you want to delete this data?",
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete", "Delete", class = "btn-danger")
    )
  ))
})

observeEvent(input$confirm_delete, {
  removeModal()
  # Perform deletion
})
```

## File Handling

### File Uploads

```r
# File input
fileInput("upload", "Upload CSV", accept = ".csv")

# Process uploaded file
data <- reactive({
  req(input$upload)
  read.csv(input$upload$datapath)
})
```

### File Downloads

```r
# Download button
downloadButton("download_data", "Download")

# Download handler
output$download_data <- downloadHandler(
  filename = function() {
    paste0("data-", Sys.Date(), ".csv")
  },
  content = function(file) {
    write.csv(filtered_data(), file, row.names = FALSE)
  }
)
```

## Interactive Graphics

### Click, Hover, and Brush

```r
plotOutput("plot",
  click = "plot_click",
  brush = "plot_brush",
  hover = "plot_hover"
)

# Use nearPoints() for click events
observeEvent(input$plot_click, {
  selected <- nearPoints(data(), input$plot_click, xvar = "x", yvar = "y")
  output$details <- renderPrint({ selected })
})

# Use brushedPoints() for selections
selected_data <- reactive({
  brushedPoints(data(), input$plot_brush)
})
```

## Tidy Evaluation in Shiny

When users select column names dynamically, use tidy evaluation:

```r
# dplyr operations with user-selected columns
filtered <- reactive({
  data() |>
    filter(.data[[input$filter_col]] > input$threshold)
})

# ggplot2 with dynamic aesthetics
output$plot <- renderPlot({
  ggplot(data(), aes(x = .data[[input$x_var]], y = .data[[input$y_var]])) +
    geom_point()
})

# select() operations
selected_cols <- reactive({
  data() |> select(all_of(input$columns))
})
```

## Performance Optimization

### Caching with bindCache()

```r
# Cache expensive computations
expensive_result <- reactive({
  expensive_function(input$param1, input$param2)
}) |> bindCache(input$param1, input$param2)

# Cache outputs (shared across users!)
output$plot <- renderPlot({
  plot(complex_data())
}) |> bindCache(input$dataset, input$options)
```

### Preprocessing Data

```r
# Load data once at startup (outside server function)
large_dataset <- read_rds("data/large_file.rds")

server <- function(input, output, session) {
  # Data already loaded, just filter
  filtered <- reactive({
    large_dataset |> filter(category == input$cat)
  })
}
```

### Conditional Computation with Tabs

```r
# Only compute when tab is visible
output$expensive_plot <- renderPlot({
  req(input$tabs == "analysis")  # Only run when tab selected
  complex_visualization()
})
```

## Security Best Practices

### Input Validation

```r
# ALWAYS validate user inputs server-side
data <- reactive({
  req(input$file)

  # Validate file type
  ext <- tools::file_ext(input$file$name)
  validate(need(ext == "csv", "Please upload a CSV file"))

  # Validate file size
  validate(need(input$file$size < 10e6, "File too large (max 10MB)"))

  read.csv(input$file$datapath)
})
```

### Avoiding Code Injection

```r
# NEVER use parse() or eval() with user input
# BAD: eval(parse(text = input$formula))

# SAFE: Use controlled alternatives
# For formulas, validate against whitelist
allowed_formulas <- c("y ~ x", "y ~ x + z")
validate(need(input$formula %in% allowed_formulas, "Invalid formula"))

# For glue, use glue_safe() not glue()
message <- glue_safe("Hello {input$name}")

# For SQL, use parameterized queries
dbGetQuery(con, "SELECT * FROM users WHERE id = ?", params = list(input$user_id))
```

### Credential Management

```r
# NEVER hardcode credentials
# BAD: con <- dbConnect(password = "secret123")

# GOOD: Use environment variables
con <- dbConnect(
  host = Sys.getenv("DB_HOST"),
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD")
)

# Or use config package for multiple environments
library(config)
db <- config::get("database")
con <- dbConnect(host = db$host, user = db$user, password = db$password)
```

## Testing

### Testing Non-Reactive Functions

```r
# testthat for regular functions
test_that("data cleaning works", {
  raw <- data.frame(x = c(1, NA, 3))
  cleaned <- clean_data(raw)
  expect_equal(nrow(cleaned), 2)
  expect_false(any(is.na(cleaned$x)))
})
```

### Testing Server Logic

```r
# testServer() for reactive testing
testServer(server, {
  session$setInputs(n = 50)
  expect_equal(output$mean, 50)

  session$setInputs(category = "A")
  expect_gt(nrow(filtered()), 0)
})

# Testing modules
testServer(mod_analysis_server, args = list(data = reactive(mtcars)), {
  session$setInputs(variable = "mpg")
  expect_true(inherits(output$plot, "shiny.render.function"))
})
```

## Code Organization

### File Structure

**Small apps (< 200 lines):**
```
app.R
```

**Medium apps (200-500 lines):**
```
app.R
R/
  utils.R
  ui.R
  server.R
```

**Large apps (> 500 lines):**
```
app.R or R/run.R
R/
  mod_*.R          # One file per module
  utils.R
  ui_helpers.R
  data_processing.R
DESCRIPTION        # Optional: package structure
```

### Extracting Functions

```r
# BEFORE: Long reactive with complex logic
filtered_data <- reactive({
  raw_data() |>
    filter(date >= input$start, date <= input$end) |>
    mutate(
      category = case_when(
        value < 10 ~ "low",
        value < 50 ~ "medium",
        TRUE ~ "high"
      )
    ) |>
    group_by(category) |>
    summarize(
      mean = mean(value),
      sd = sd(value),
      n = n()
    )
})

# AFTER: Extracted to separate function
categorize_and_summarize <- function(data, start_date, end_date) {
  data |>
    filter(date >= start_date, date <= end_date) |>
    mutate(
      category = case_when(
        value < 10 ~ "low",
        value < 50 ~ "medium",
        TRUE ~ "high"
      )
    ) |>
    group_by(category) |>
    summarize(
      mean = mean(value),
      sd = sd(value),
      n = n()
    )
}

# Now testable and reusable
filtered_data <- reactive({
  categorize_and_summarize(raw_data(), input$start, input$end)
})
```

## Reference Documentation

For detailed information on specific topics, see:
- **Reactivity Deep Dive**: [references/reactivity-patterns.md](references/reactivity-patterns.md)
- **UI Design Patterns**: [references/ui-patterns.md](references/ui-patterns.md)
- **Modules & Organization**: [references/modules-and-organization.md](references/modules-and-organization.md)
- **Performance & Security**: [references/performance-and-security.md](references/performance-and-security.md)
- **Common Pitfalls**: [references/common-pitfalls.md](references/common-pitfalls.md)

## Code Templates

- **Basic App**: [templates/basic-app.R](templates/basic-app.R)
- **Module Template**: [templates/module-template.R](templates/module-template.R)
- **Package-Based App**: [templates/package-app.R](templates/package-app.R)

## Working Examples

- **Reactive Patterns**: [examples/reactive-patterns.R](examples/reactive-patterns.R)
- **Dynamic UI**: [examples/dynamic-ui.R](examples/dynamic-ui.R)
- **Interactive Plots**: [examples/interactive-plots.R](examples/interactive-plots.R)

---

**Remember**: Keep reactivity in the server function, put complex computation in regular functions, test thoroughly, validate all user inputs, and optimize based on profiling results.
