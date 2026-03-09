# Modules and Code Organization

## When to Use Modules

### Module Benefits

1. **Isolation**: Prevents ID conflicts through namespacing
2. **Reusability**: Use same component multiple times in one app
3. **Testability**: Test modules independently with `testServer()`
4. **Comprehension**: Understand components in isolation
5. **Collaboration**: Team members work on separate modules

### When NOT to Use Modules

- **Small apps** (< 200 lines): Unnecessary overhead
- **One-time use**: If component used once, extract to function instead
- **Simple repetition**: Use functional programming (`map()`) rather than modules

## Module Anatomy

### Basic Module Structure

```r
# Module UI function
mod_counter_ui <- function(id, label = "Counter") {
  ns <- NS(id)  # Creates namespace function

  tagList(
    h3(label),
    actionButton(ns("increment"), "Increment"),
    actionButton(ns("reset"), "Reset"),
    verbatimTextOutput(ns("value"))
  )
}

# Module server function
mod_counter_server <- function(id, initial_value = 0) {
  moduleServer(id, function(input, output, session) {
    count <- reactiveVal(initial_value)

    observeEvent(input$increment, {
      count(count() + 1)
    })

    observeEvent(input$reset, {
      count(initial_value)
    })

    output$value <- renderText({
      count()
    })

    # Return reactive for use by parent
    return(reactive({ count() }))
  })
}

# Usage in main app
ui <- fluidPage(
  mod_counter_ui("counter1", "First Counter"),
  mod_counter_ui("counter2", "Second Counter")
)

server <- function(input, output, session) {
  count1 <- mod_counter_server("counter1", initial_value = 0)
  count2 <- mod_counter_server("counter2", initial_value = 100)

  # Can use returned reactives
  observe({
    message("Counter 1: ", count1())
    message("Counter 2: ", count2())
  })
}
```

### Naming Conventions

```r
# Consistent naming pattern
mod_{module_name}_ui <- function(id) {}
mod_{module_name}_server <- function(id) {}

# Examples:
mod_data_import_ui()
mod_data_import_server()

mod_histogram_ui()
mod_histogram_server()

mod_user_settings_ui()
mod_user_settings_server()
```

## Module Communication Patterns

### Pattern 1: Parent Passes Data to Module

```r
# Module receives reactive data from parent
mod_plot_server <- function(id, data) {
  stopifnot(is.reactive(data))  # Validate input

  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      req(nrow(data()) > 0)
      hist(data()[[input$variable]])
    })

    observe({
      updateSelectInput(session, "variable", choices = names(data()))
    })
  })
}

# Parent provides reactive data
server <- function(input, output, session) {
  current_data <- reactive({
    read.csv(input$file$datapath)
  })

  mod_plot_server("plot1", data = current_data)
}
```

### Pattern 2: Module Returns Values to Parent

```r
# Module returns reactive outputs
mod_filter_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Update choices when data changes
    observe({
      updateSelectInput(session, "category",
        choices = unique(data()$category)
      )
    })

    # Return filtered data
    return(reactive({
      data() |> filter(category == input$category)
    }))
  })
}

# Parent uses returned reactive
server <- function(input, output, session) {
  raw_data <- reactive({ load_data() })

  filtered_data <- mod_filter_server("filter", data = raw_data)

  # Use filtered data
  output$table <- renderTable({
    filtered_data()
  })
}
```

### Pattern 3: Module Returns Multiple Values

```r
# Return list of reactives
mod_analysis_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    filtered <- reactive({
      data() |> filter(value > input$threshold)
    })

    summary_stats <- reactive({
      filtered() |>
        summarize(
          mean = mean(value),
          sd = sd(value),
          n = n()
        )
    })

    # Return multiple reactive values
    return(list(
      filtered_data = filtered,
      summary = summary_stats,
      threshold = reactive({ input$threshold })
    ))
  })
}

# Parent accesses returned values
server <- function(input, output, session) {
  results <- mod_analysis_server("analysis", data = raw_data)

  output$plot <- renderPlot({
    plot(results$filtered_data())
  })

  output$summary <- renderPrint({
    results$summary()
  })
}
```

### Pattern 4: Module-to-Module Communication

```r
# Filter module returns filtered data
mod_filter_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    return(reactive({
      data() |>
        filter(
          date >= input$start_date,
          date <= input$end_date,
          category %in% input$categories
        )
    }))
  })
}

# Plot module receives filtered data
mod_plot_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      ggplot(data(), aes(x = date, y = value)) +
        geom_line()
    })
  })
}

# Parent coordinates modules
server <- function(input, output, session) {
  raw_data <- reactive({ load_data() })

  # Filter module processes data
  filtered_data <- mod_filter_server("filter", data = raw_data)

  # Plot module visualizes filtered data
  mod_plot_server("plot", data = filtered_data)
}
```

### Pattern 5: Reactive Trigger from Module

```r
# Module signals events to parent
mod_editor_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Return action button as reactive
    return(reactive({
      input$save  # Returns integer of click count
    }))
  })
}

# Parent responds to module events
server <- function(input, output, session) {
  save_clicked <- mod_editor_server("editor", data = current_data)

  # React to save button from module
  observeEvent(save_clicked(), {
    saveRDS(current_data(), "data.rds")
    showNotification("Data saved!")
  })
}
```

## Nested Modules

Modules can contain other modules for complex hierarchies:

```r
# Child module
mod_metric_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "metric-box",
    h2(textOutput(ns("value"))),
    p(textOutput(ns("label")))
  )
}

mod_metric_server <- function(id, value, label) {
  moduleServer(id, function(input, output, session) {
    output$value <- renderText({ value() })
    output$label <- renderText({ label })
  })
}

# Parent module containing multiple metrics
mod_dashboard_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Dashboard"),
    fluidRow(
      column(4, mod_metric_ui(ns("metric1"))),
      column(4, mod_metric_ui(ns("metric2"))),
      column(4, mod_metric_ui(ns("metric3")))
    ),
    plotOutput(ns("plot"))
  )
}

mod_dashboard_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Use child modules with nested IDs
    mod_metric_server("metric1",
      value = reactive({ sum(data()$value) }),
      label = "Total"
    )

    mod_metric_server("metric2",
      value = reactive({ mean(data()$value) }),
      label = "Average"
    )

    mod_metric_server("metric3",
      value = reactive({ nrow(data()) }),
      label = "Count"
    )

    output$plot <- renderPlot({
      ggplot(data(), aes(x = category, y = value)) +
        geom_col()
    })
  })
}

# Main app uses parent module
ui <- fluidPage(
  mod_dashboard_ui("dashboard")
)

server <- function(input, output, session) {
  data <- reactive({ load_data() })
  mod_dashboard_server("dashboard", data = data)
}
```

## Module Testing

### Testing Module Server Logic

```r
# Test file: tests/testthat/test-mod-counter.R
test_that("counter module increments correctly", {
  testServer(mod_counter_server, {
    # Initial value
    expect_equal(count(), 0)

    # Click increment
    session$setInputs(increment = 1)
    expect_equal(count(), 1)

    session$setInputs(increment = 2)
    expect_equal(count(), 2)

    # Click reset
    session$setInputs(reset = 1)
    expect_equal(count(), 0)
  })
})

test_that("counter module accepts initial value", {
  testServer(mod_counter_server, args = list(initial_value = 100), {
    expect_equal(count(), 100)

    session$setInputs(increment = 1)
    expect_equal(count(), 101)

    session$setInputs(reset = 1)
    expect_equal(count(), 100)  # Resets to initial
  })
})
```

### Testing Module with Reactive Inputs

```r
test_that("plot module updates with data changes", {
  test_data <- reactive({
    data.frame(x = 1:10, y = rnorm(10))
  })

  testServer(mod_plot_server, args = list(data = test_data), {
    # Check that output exists
    expect_true(inherits(output$plot, "shiny.render.function"))

    # Change input
    session$setInputs(plot_type = "scatter")
    # Verify logic based on input change
  })
}
```

## File Organization Strategies

### Strategy 1: Single Module Per File

**Best for**: Medium to large apps with clear module boundaries

```
R/
├── app.R                     # Main app entry point
├── mod_data_import.R         # Data import module
├── mod_data_cleaning.R       # Data cleaning module
├── mod_visualization.R       # Visualization module
├── mod_report.R              # Report generation module
└── utils.R                   # Shared utility functions
```

**File structure (mod_data_import.R):**
```r
# UI function
mod_data_import_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Upload Data"),
    actionButton(ns("load"), "Load")
  )
}

# Server function
mod_data_import_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Module logic
  })
}

# Helper functions (module-specific, not exported)
validate_file_format <- function(file_path) {
  # Internal helper
}
```

### Strategy 2: Grouped Modules

**Best for**: Large apps with module families

```
R/
├── app.R
├── mod_data/
│   ├── mod_import.R
│   ├── mod_export.R
│   └── mod_transform.R
├── mod_analysis/
│   ├── mod_descriptive.R
│   ├── mod_regression.R
│   └── mod_clustering.R
└── mod_viz/
    ├── mod_scatter.R
    ├── mod_histogram.R
    └── mod_heatmap.R
```

### Strategy 3: Package Structure

**Best for**: Production apps, reusable apps, team development

```
myapp/
├── DESCRIPTION
├── NAMESPACE
├── R/
│   ├── app.R                 # Main app function
│   ├── run_app.R             # App launcher
│   ├── mod_*.R               # Modules
│   ├── utils_*.R             # Utility functions
│   └── data_processing.R     # Data functions
├── inst/
│   └── app/
│       └── www/              # Static assets
│           ├── custom.css
│           └── logo.png
├── tests/
│   └── testthat/
│       ├── test-mod_*.R      # Module tests
│       └── test-utils.R      # Utility tests
├── data/                     # Package data
├── man/                      # Documentation
└── vignettes/                # User guides
```

**Launch function (R/run_app.R):**
```r
#' Run the Shiny Application
#'
#' @param ... Additional arguments passed to shinyApp()
#' @export
run_app <- function(...) {
  shinyApp(
    ui = app_ui,
    server = app_server,
    ...
  )
}
```

## Code Organization Best Practices

### Separate Concerns

```r
# ❌ BAD: Everything in server function
server <- function(input, output, session) {
  output$plot <- renderPlot({
    # 50 lines of data processing
    # Then plotting
  })
}

# ✅ GOOD: Extract data processing
process_data <- function(data, params) {
  data |>
    filter(category == params$category) |>
    mutate(
      adjusted = value * params$adjustment,
      category_clean = clean_category(category)
    ) |>
    group_by(category_clean) |>
    summarize(
      mean_value = mean(adjusted),
      n = n()
    )
}

server <- function(input, output, session) {
  processed <- reactive({
    process_data(raw_data(), list(
      category = input$category,
      adjustment = input$adjustment
    ))
  })

  output$plot <- renderPlot({
    plot_data(processed())
  })
}
```

### UI Generation Functions

```r
# Extract repeated UI patterns
metric_box <- function(value, label, color = "primary") {
  div(
    class = paste("metric-box bg", color, sep = "-"),
    h2(value),
    p(label)
  )
}

# Use in UI
ui <- fluidPage(
  fluidRow(
    column(4, metric_box("$125K", "Revenue", "success")),
    column(4, metric_box("2,450", "Users", "info")),
    column(4, metric_box("98%", "Uptime", "primary"))
  )
)
```

### Shared Reactive State

For complex apps needing shared state across modules:

```r
# Create reactive values at top level
server <- function(input, output, session) {
  # Shared state
  shared <- reactiveValues(
    data = NULL,
    selected_rows = integer(0),
    filters = list()
  )

  # Pass shared state to modules
  mod_data_import_server("import", shared = shared)
  mod_data_table_server("table", shared = shared)
  mod_data_plot_server("plot", shared = shared)
}

# Modules access shared state
mod_data_import_server <- function(id, shared) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$file, {
      shared$data <- read.csv(input$file$datapath)
    })
  })
}

mod_data_table_server <- function(id, shared) {
  moduleServer(id, function(input, output, session) {
    output$table <- renderDataTable({
      req(shared$data)
      shared$data
    })

    observe({
      shared$selected_rows <- input$table_rows_selected
    })
  })
}
```

## Module Documentation

### Document Module Interfaces

```r
#' Data Import Module UI
#'
#' Creates the UI for the data import module
#'
#' @param id Character string, the namespace ID for the module
#' @param label Character string, label for the file input (default: "Upload File")
#' @param accept Character vector, accepted file types (default: ".csv")
#'
#' @return A tagList containing the UI elements
#'
#' @examples
#' ui <- fluidPage(
#'   mod_data_import_ui("import", label = "Upload CSV", accept = ".csv")
#' )
#'
#' @export
mod_data_import_ui <- function(id, label = "Upload File", accept = ".csv") {
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), label, accept = accept),
    actionButton(ns("load"), "Load Data")
  )
}

#' Data Import Module Server
#'
#' Server logic for the data import module
#'
#' @param id Character string, the namespace ID (must match UI)
#' @param validate_fn Function, optional custom validation function
#'
#' @return A reactive expression containing the loaded data frame,
#'   or NULL if no data loaded
#'
#' @examples
#' server <- function(input, output, session) {
#'   data <- mod_data_import_server("import")
#'
#'   output$summary <- renderPrint({
#'     req(data())
#'     summary(data())
#'   })
#' }
#'
#' @export
mod_data_import_server <- function(id, validate_fn = NULL) {
  moduleServer(id, function(input, output, session) {
    # Implementation
  })
}
```

---

**Key Principles:**
- Use modules for reusable components (used 2+ times)
- Pass reactive data to modules, return reactive results
- Use `stopifnot()` to validate module inputs
- One module per file for medium/large apps
- Test modules independently with `testServer()`
- Document module interfaces clearly
- Extract non-reactive functions to separate files
- Use namespacing consistently with `NS(id)`
