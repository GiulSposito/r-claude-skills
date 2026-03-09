# Common Pitfalls and Solutions

## Reactivity Pitfalls

### 1. Treating Reactive Expressions as Variables

```r
# ❌ WRONG: Treating reactive as variable
data <- reactive({ load_data() })
output$plot <- renderPlot({ plot(data) })  # Error: data is function

# ✅ CORRECT: Call reactive with ()
output$plot <- renderPlot({ plot(data()) })
```

### 2. Forgetting req() for Optional Inputs

```r
# ❌ WRONG: Errors when file not uploaded
output$summary <- renderPrint({
  data <- read.csv(input$file$datapath)  # Fails if NULL
  summary(data)
})

# ✅ CORRECT: Wait for input
output$summary <- renderPrint({
  req(input$file)
  data <- read.csv(input$file$datapath)
  summary(data)
})
```

### 3. Creating Infinite Reactive Loops

```r
# ❌ WRONG: Infinite loop
state <- reactiveValues(count = 0)
observe({
  state$count <- state$count + 1  # Triggers itself!
})

# ✅ CORRECT: Event-driven
observeEvent(input$button, {
  state$count <- state$count + 1
})
```

### 4. Using Reactive Expressions Outside Reactive Context

```r
# ❌ WRONG: Calling reactive outside context
data <- reactive({ mtcars })
summary(data())  # Error: outside reactive context

# ✅ CORRECT: Call inside reactive context
output$summary <- renderPrint({
  summary(data())  # Inside render function
})
```

### 5. Not Isolating Update Calls

```r
# ❌ WRONG: Creates unwanted dependency
observeEvent(input$dataset, {
  choices <- get_variables(input$dataset)
  # This also depends on input$selected!
  updateSelectInput(session, "variable",
    choices = choices,
    selected = input$selected
  )
})

# ✅ CORRECT: Isolate to prevent dependency
observeEvent(input$dataset, {
  choices <- get_variables(input$dataset)
  current <- isolate(input$selected)  # Don't create dependency
  if (current %in% choices) {
    selected <- current
  } else {
    selected <- choices[1]
  }
  updateSelectInput(session, "variable",
    choices = choices,
    selected = selected
  )
})
```

## UI Pitfalls

### 6. Forgetting NS() in Modules

```r
# ❌ WRONG: IDs not namespaced
mod_example_ui <- function(id) {
  tagList(
    textInput("name", "Name"),  # Conflict!
    textOutput("result")
  )
}

# ✅ CORRECT: Use NS()
mod_example_ui <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(ns("name"), "Name"),
    textOutput(ns("result"))
  )
}
```

### 7. Mismatched UI and Render Functions

```r
# ❌ WRONG: Mismatched pair
ui: plotOutput("myplot")
server: output$myplot <- renderText({ "text" })  # Wrong render!

# ✅ CORRECT: Match pairs
# textOutput() ↔ renderText()
# verbatimTextOutput() ↔ renderPrint()
# plotOutput() ↔ renderPlot()
# tableOutput() ↔ renderTable()
# dataTableOutput() ↔ renderDataTable()
# uiOutput() ↔ renderUI()
```

### 8. Updating Non-existent Inputs

```r
# ❌ WRONG: Updating before input exists
ui <- uiOutput("dynamic")

server <- function(input, output, session) {
  updateTextInput(session, "name", value = "John")  # Doesn't exist yet!

  output$dynamic <- renderUI({
    textInput("name", "Name")
  })
}

# ✅ CORRECT: Update after rendering
server <- function(input, output, session) {
  output$dynamic <- renderUI({
    textInput("name", "Name")
  })

  observe({
    req(input$name)  # Wait until it exists
    updateTextInput(session, "name", value = "John")
  })
}
```

## Data Handling Pitfalls

### 9. Not Using Reactive Expressions for Shared Data

```r
# ❌ WRONG: Repeating expensive computation
output$plot <- renderPlot({
  data <- expensive_load()  # Computed 3 times!
  plot(data)
})
output$table <- renderTable({
  data <- expensive_load()
  head(data)
})
output$summary <- renderPrint({
  data <- expensive_load()
  summary(data)
})

# ✅ CORRECT: Use reactive expression
data <- reactive({
  expensive_load()  # Computed once
})
output$plot <- renderPlot({ plot(data()) })
output$table <- renderTable({ head(data()) })
output$summary <- renderPrint({ summary(data()) })
```

### 10. Modifying Inputs Directly

```r
# ❌ WRONG: Can't modify input directly
server <- function(input, output, session) {
  input$value <- 100  # Error: input is read-only
}

# ✅ CORRECT: Use update functions
server <- function(input, output, session) {
  updateNumericInput(session, "value", value = 100)
}
```

### 11. File Path Issues After Upload

```r
# ❌ WRONG: Using name instead of datapath
output$contents <- renderPrint({
  req(input$file)
  read.csv(input$file$name)  # File not at this path!
})

# ✅ CORRECT: Use datapath
output$contents <- renderPrint({
  req(input$file)
  read.csv(input$file$datapath)  # Temporary server path
})
```

## Module Pitfalls

### 12. Forgetting Module IDs Must Match

```r
# ❌ WRONG: Mismatched IDs
ui <- mod_example_ui("module1")
server <- function(input, output, session) {
  mod_example_server("different_id")  # Won't connect!
}

# ✅ CORRECT: Same ID
ui <- mod_example_ui("module1")
server <- function(input, output, session) {
  mod_example_server("module1")
}
```

### 13. Not Validating Module Arguments

```r
# ❌ WRONG: No validation
mod_plot_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({ plot(data()) })  # Fails if data not reactive
  })
}

# ✅ CORRECT: Validate arguments
mod_plot_server <- function(id, data) {
  stopifnot(is.reactive(data))
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({ plot(data()) })
  })
}
```

### 14. Using input$id Instead of input[[id]]

```r
# ❌ WRONG: Hardcoded input name
output$dynamic_inputs <- renderUI({
  lapply(1:3, function(i) {
    textInput(paste0("var_", i), paste("Var", i))
  })
})
observe({
  val1 <- input$var_1  # Works
  val2 <- input$var_2  # Works
  # But can't use variable to access
})

# ✅ CORRECT: Use [[ ]] for variable names
observe({
  values <- sapply(1:3, function(i) {
    input[[paste0("var_", i)]]
  })
})
```

## Performance Pitfalls

### 15. Running Server Code at Startup

```r
# ❌ WRONG: Expensive operation in server function body
server <- function(input, output, session) {
  big_data <- read_huge_file()  # Runs once per session (per user!)

  output$plot <- renderPlot({ plot(big_data) })
}

# ✅ CORRECT: Load outside server function
big_data <- read_huge_file()  # Runs once at app startup

server <- function(input, output, session) {
  output$plot <- renderPlot({ plot(big_data) })
}
```

### 16. Not Using server = TRUE for Large Tables

```r
# ❌ WRONG: Sends all data to browser
output$table <- renderDataTable({
  huge_dataset  # Millions of rows sent to browser!
})

# ✅ CORRECT: Server-side processing
output$table <- renderDataTable({
  huge_dataset
}, server = TRUE)  # Only sends visible rows
```

### 17. Forgetting to Cache Shared Computations

```r
# ❌ WRONG: Every user recalculates
expensive_result <- reactive({
  complex_analysis(input$params)  # User 1: slow, User 2: slow, User 3: slow
})

# ✅ CORRECT: Cache across users
expensive_result <- reactive({
  complex_analysis(input$params)
}) |> bindCache(input$params)  # User 1: slow, Users 2+: instant
```

## Testing Pitfalls

### 18. Not Testing Reactive Logic

```r
# ❌ WRONG: Only testing pure functions
test_that("calculation works", {
  expect_equal(calculate(10), 20)
})
# Missing tests for reactive interactions!

# ✅ CORRECT: Test reactive logic
test_that("output updates when input changes", {
  testServer(server, {
    session$setInputs(value = 10)
    expect_equal(output$result, 20)

    session$setInputs(value = 20)
    expect_equal(output$result, 40)
  })
})
```

### 19. Not Testing Module Interfaces

```r
# ❌ WRONG: No module tests
# Modules only tested as part of full app

# ✅ CORRECT: Test modules independently
test_that("filter module returns filtered data", {
  test_data <- reactive({ mtcars })

  testServer(mod_filter_server, args = list(data = test_data), {
    session$setInputs(threshold = 20)
    result <- filtered_data()
    expect_true(all(result$mpg > 20))
  })
})
```

## Deployment Pitfalls

### 20. Hardcoded File Paths

```r
# ❌ WRONG: Absolute paths
data <- read.csv("/Users/myname/data.csv")  # Breaks on server

# ✅ CORRECT: Relative paths
data <- read.csv("data/data.csv")  # Relative to app directory
```

### 21. Missing Package Dependencies

```r
# ❌ WRONG: Packages not declared
# App uses dplyr, ggplot2 but DESCRIPTION missing

# ✅ CORRECT: Declare in DESCRIPTION
# Or use explicit library() calls
library(shiny)
library(dplyr)
library(ggplot2)
```

### 22. Forgetting Error Handling

```r
# ❌ WRONG: No error handling
output$result <- renderText({
  result <- api_call(input$params)  # What if it fails?
  result$value
})

# ✅ CORRECT: Handle errors gracefully
output$result <- renderText({
  tryCatch(
    {
      result <- api_call(input$params)
      result$value
    },
    error = function(e) {
      message("API error: ", e$message)
      "Data temporarily unavailable"
    }
  )
})
```

## Quick Reference: Common Fixes

| Problem | Fix |
|---------|-----|
| "object of type 'closure' is not subsettable" | Call reactive with `()`: `data()` not `data` |
| "Operation not allowed without an active reactive context" | Use inside `reactive({})` or `render*({})` |
| "Cannot read property of NULL" | Add `req(input$name)` before using |
| Inputs not updating | Check `session` parameter exists |
| Module not working | Verify IDs match between UI and server |
| Slow app | Profile with `profvis`, add `bindCache()` |
| App crashes with large data | Use `server = TRUE` in DataTable |
| Unwanted reactivity | Use `isolate()` or `eventReactive()` |
| Flickering updates | Use `freezeReactiveValue()` |
| File upload fails | Check size limit, use `datapath` not `name` |

---

**Prevention Strategy**: Test early, validate inputs, use `req()` liberally, profile performance, and follow naming conventions consistently.
