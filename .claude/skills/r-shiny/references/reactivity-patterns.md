# Reactivity Patterns - Deep Dive

## Understanding the Reactive Graph

The reactive graph is a **dynamic dependency network** that Shiny builds and maintains automatically. It visualizes data flow through your app.

### Key Concepts

1. **Discovery Through Execution**: Shiny discovers dependencies by running code, not analyzing it statically
2. **Dynamic Restructuring**: Graph changes based on actual execution paths (conditional logic)
3. **Invalidation Propagation**: When inputs change, invalidation flows through the graph to all dependents

### Visualizing with reactlog

```r
# Enable reactlog
options(shiny.reactlog = TRUE)

# Run your app, then visualize
shiny::reactlogShow()
```

## The Three Fundamental Building Blocks

### 1. Reactive Sources (Inputs)

**Characteristics:**
- Read-only from server perspective
- Reflect browser state (single source of truth)
- Automatically invalidate dependents when changed
- Cannot create dependencies during execution

**Types:**
```r
# UI inputs
input$text, input$slider, input$select

# Manual reactive values
counter <- reactiveVal(0)        # Single value
state <- reactiveValues(x = 1, y = 2)  # List of values
```

**Best Practices:**
```r
# Never modify input directly (will error)
# BAD: input$value <- 10

# Use update functions instead
updateSliderInput(session, "slider", value = 10)

# For manual reactive values, use reference semantics
counter(counter() + 1)  # Get with (), set with (value)
state$x <- state$x + 1  # Direct assignment for reactiveValues
```

### 2. Reactive Conductors (Expressions)

**Characteristics:**
- **Lazy**: Only compute when actually needed
- **Cached**: Return stored result if dependencies unchanged
- **Intermediate nodes**: Can depend on inputs and be used by outputs
- **Error propagation**: Errors flow through graph like regular values

**When to Use:**
```r
# ✅ Expensive computation used multiple times
filtered_data <- reactive({
  data |> filter(category == input$cat)  # Computed once
})

output$plot <- renderPlot({ plot(filtered_data()) })
output$table <- renderTable({ filtered_data() })
output$summary <- renderPrint({ summary(filtered_data()) })

# ❌ Simple computation or used only once
# Don't create reactive for: x <- reactive({ input$n * 2 })
# Just use: input$n * 2 directly
```

**Reactive Expression Patterns:**

**Pattern: Multi-Step Pipeline**
```r
# Break complex logic into readable steps
raw_data <- reactive({
  req(input$file)
  read.csv(input$file$datapath)
})

cleaned_data <- reactive({
  raw_data() |>
    filter(!is.na(value)) |>
    mutate(value = as.numeric(value))
})

filtered_data <- reactive({
  cleaned_data() |>
    filter(
      date >= input$start,
      date <= input$end,
      category %in% input$categories
    )
})

summarized <- reactive({
  filtered_data() |>
    group_by(category) |>
    summarize(mean = mean(value), n = n())
})
```

**Pattern: Conditional Reactive**
```r
# Different computations based on mode
result <- reactive({
  if (input$mode == "simple") {
    simple_analysis(data())
  } else {
    complex_analysis(data(), input$advanced_params)
  }
})
```

**Pattern: Debouncing (Delayed Reaction)**
```r
# Only react after user stops typing for 500ms
search_term_debounced <- reactive({
  input$search
}) |> debounce(500)

results <- reactive({
  search_database(search_term_debounced())
})
```

**Pattern: Throttling (Rate Limiting)**
```r
# Update at most once per second
mouse_position_throttled <- reactive({
  list(x = input$plot_hover$x, y = input$plot_hover$y)
}) |> throttle(1000)
```

### 3. Reactive Endpoints (Observers & Outputs)

**Characteristics:**
- **Eager**: Execute as soon as dependencies are ready
- **Forgetful**: Don't return values or cache results
- **Terminal nodes**: Cannot be used by other reactive components
- **Side-effects focused**: Logging, saving, updating external systems

**Outputs:**
```r
# Special observers that update UI
output$plot <- renderPlot({
  hist(rnorm(input$n))
})

# Different render functions for different content types
output$text <- renderText({ paste("Value:", input$n) })
output$table <- renderTable({ head(data()) })
output$ui <- renderUI({ sliderInput("dynamic", "Dynamic", 1, 10, 5) })
```

**Observers:**
```r
# observe() - reacts to all dependencies
observe({
  message("Input changed: ", input$value)
  log_to_file(input$value)
})

# observeEvent() - reacts to specific trigger
observeEvent(input$save, {
  saveRDS(current_data(), "output.rds")
  showNotification("Saved!")
})

# observeEvent with ignoreInit
observeEvent(input$trigger, {
  # Won't run on app start
  perform_action()
}, ignoreInit = TRUE)

# observeEvent with once
observeEvent(input$initialize, {
  # Runs only first time triggered
  setup_environment()
}, once = TRUE)
```

## Event-Driven Reactivity

### eventReactive() - Controlled Computation

```r
# Only recalculate when button clicked, not when params change
results <- eventReactive(input$run, {
  expensive_analysis(
    data(),
    input$param1,
    input$param2,
    input$param3
  )
})

output$plot <- renderPlot({
  plot(results())
})
```

**When to Use:**
- Long-running computations (prevent constant recalculation)
- User wants explicit control (click to update)
- Multiple inputs should be "batched" together

**Common Pattern: Action Button Workflow**
```r
# Multiple parameters, single trigger
ui <- fluidPage(
  numericInput("n", "N", 100),
  numericInput("mean", "Mean", 0),
  numericInput("sd", "SD", 1),
  actionButton("generate", "Generate Data"),
  plotOutput("plot")
)

server <- function(input, output, session) {
  data <- eventReactive(input$generate, {
    rnorm(input$n, input$mean, input$sd)
  })

  output$plot <- renderPlot({
    hist(data())
  })
}
```

### observeEvent() - Side Effects

```r
# File operations
observeEvent(input$save, {
  write.csv(data(), "output.csv")
  showNotification("Data saved")
})

# Logging
observeEvent(input$action, {
  message(glue::glue("User performed action at {Sys.time()}"))
})

# External API calls
observeEvent(input$submit, {
  response <- POST(api_url, body = list(data = input$values))
  if (response$status_code == 200) {
    showNotification("Submitted successfully", type = "message")
  } else {
    showNotification("Submission failed", type = "error")
  }
})
```

## Escaping the Reactive Graph

Sometimes you need manual control outside automatic reactivity.

### reactiveVal() and reactiveValues()

**Single Value:**
```r
counter <- reactiveVal(0)

observeEvent(input$increment, {
  counter(counter() + 1)
})

observeEvent(input$reset, {
  counter(0)
})

output$count <- renderText({
  counter()
})
```

**Multiple Values:**
```r
state <- reactiveValues(
  data = NULL,
  filtered = NULL,
  selected_rows = integer(0)
)

observeEvent(input$file, {
  state$data <- read.csv(input$file$datapath)
})

observe({
  state$filtered <- state$data |>
    filter(category == input$category)
})

observeEvent(input$table_rows_selected, {
  state$selected_rows <- input$table_rows_selected
})
```

### isolate() - Breaking Dependencies

```r
# Prevent reactive dependency
observe({
  # Only reacts to input$trigger, NOT input$value
  input$trigger

  value <- isolate(input$value)
  process(value)
})

# Common pattern: Preserving user input during updates
observeEvent(input$category, {
  choices <- get_items(input$category)

  # Try to preserve previous selection if valid
  current <- isolate(input$item)
  if (current %in% choices) {
    selected <- current
  } else {
    selected <- choices[1]
  }

  updateSelectInput(session, "item",
    choices = choices,
    selected = selected
  )
})
```

### freezeReactiveValue() - Preventing Flicker

```r
# Prevents intermediate invalid states during cascading updates
observeEvent(input$country, {
  # Freeze city while updating to prevent validation errors
  freezeReactiveValue(input, "city")

  cities <- get_cities(input$country)
  updateSelectInput(session, "city", choices = cities)
})
```

## Advanced Reactive Patterns

### Pattern: Accumulating Data

```r
# Build up dataset from repeated user actions
accumulated <- reactiveVal(data.frame())

observeEvent(input$add, {
  new_row <- data.frame(
    time = Sys.time(),
    value = input$value
  )
  accumulated(rbind(accumulated(), new_row))
})

observeEvent(input$clear, {
  accumulated(data.frame())
})

output$table <- renderTable({
  accumulated()
})
```

### Pattern: Reactive Timer

```r
# Periodic updates
timer <- reactiveTimer(intervalMs = 5000)  # 5 seconds

current_time <- reactive({
  timer()  # Invalidates every 5 seconds
  Sys.time()
})

output$clock <- renderText({
  format(current_time(), "%H:%M:%S")
})
```

### Pattern: Reactive File Reader

```r
# Monitor file for changes
file_data <- reactivePoll(
  intervalMillis = 1000,
  session = session,
  checkFunc = function() {
    if (file.exists("data.csv")) {
      file.info("data.csv")$mtime
    } else {
      ""
    }
  },
  valueFunc = function() {
    read.csv("data.csv")
  }
)

output$data <- renderTable({
  file_data()
})
```

### Pattern: Conditional Reactive Chain

```r
# Different data sources based on input
data_source <- reactive({
  switch(input$source,
    "file" = reactive({ read.csv(input$file$datapath) }),
    "database" = reactive({ dbGetQuery(con, "SELECT * FROM table") }),
    "api" = reactive({ fromJSON(input$api_url) })
  )
})

# Use the selected source
current_data <- reactive({
  data_source()()  # Call reactive to get reactive, then call that
})

# Better approach using direct conditional
current_data <- reactive({
  switch(input$source,
    "file" = read.csv(input$file$datapath),
    "database" = dbGetQuery(con, "SELECT * FROM table"),
    "api" = fromJSON(input$api_url)
  )
})
```

### Pattern: Reactive Caching with Cache Invalidation

```r
# Manual cache control
cache <- reactiveVal(NULL)
cache_valid <- reactiveVal(FALSE)

# Invalidate cache when parameters change
observe({
  input$param1
  input$param2
  cache_valid(FALSE)
})

# Use cached value or recompute
result <- reactive({
  if (cache_valid()) {
    cache()
  } else {
    new_result <- expensive_computation(input$param1, input$param2)
    cache(new_result)
    cache_valid(TRUE)
    new_result
  }
})

# Modern approach: use bindCache()
result <- reactive({
  expensive_computation(input$param1, input$param2)
}) |> bindCache(input$param1, input$param2)
```

## Debugging Reactivity

### Common Issues and Solutions

**Issue 1: Reactive Dependency Not Detected**
```r
# Problem: indirect reference
var_name <- "mpg"
reactive({ mtcars[[var_name]] })  # No dependency on input$var

# Solution: direct reference
reactive({ mtcars[[input$var]] })  # Creates dependency
```

**Issue 2: Unwanted Reactive Dependency**
```r
# Problem: reactive depends on input$trigger AND input$params
result <- reactive({
  if (input$trigger > 0) {
    compute(input$params)
  }
})

# Solution: use eventReactive
result <- eventReactive(input$trigger, {
  compute(input$params)
})
```

**Issue 3: Infinite Reactive Loop**
```r
# Problem: observer modifies its own dependency
observe({
  state$counter <- state$counter + 1  # INFINITE LOOP!
})

# Solution: use triggered observer
observeEvent(input$increment, {
  state$counter <- state$counter + 1  # Only on button click
})
```

**Issue 4: Reactive Runs Too Often**
```r
# Problem: multiple dependencies cause multiple runs
reactive({
  data() |>
    filter(category == input$cat) |>
    filter(value > input$threshold) |>
    arrange(input$sort_by)
})

# Solution: debounce or use action button
filtered <- reactive({
  data() |>
    filter(category == input$cat) |>
    filter(value > input$threshold) |>
    arrange(input$sort_by)
}) |> debounce(1000)
```

### Print Debugging for Reactivity

```r
# Track execution with messages
data <- reactive({
  message("data() reactive executing")
  read.csv(input$file$datapath)
})

filtered <- reactive({
  message(glue::glue("filtered() executing with category = {input$category}"))
  data() |> filter(category == input$category)
})

observe({
  message("Observer triggered at ", Sys.time())
  print(filtered())
})
```

## Performance Considerations

### Reactive Expressions vs. Functions

```r
# ❌ BAD: Function called multiple times
get_data <- function() {
  expensive_operation()
}

output$plot <- renderPlot({ plot(get_data()) })
output$table <- renderTable({ get_data() })  # Runs twice!

# ✅ GOOD: Reactive computed once
data <- reactive({
  expensive_operation()
})

output$plot <- renderPlot({ plot(data()) })
output$table <- renderTable({ data() })  # Uses cached result
```

### Strategic Reactivity Splitting

```r
# ❌ BAD: One giant reactive
everything <- reactive({
  raw <- load_data()
  cleaned <- clean_data(raw)
  filtered <- filter_data(cleaned, input$filters)
  summarized <- summarize_data(filtered)
  summarized
})

# ✅ GOOD: Pipeline of reactives
raw_data <- reactive({
  load_data()  # Only when data source changes
})

cleaned_data <- reactive({
  clean_data(raw_data())  # Only when raw changes
})

filtered_data <- reactive({
  filter_data(cleaned_data(), input$filters)  # When filters change
})

summarized_data <- reactive({
  summarize_data(filtered_data())  # When filtered changes
})
```

Each step only recomputes when its specific dependencies change, not when earlier steps' inputs change.

---

**Key Takeaways:**
- Reactive expressions are lazy and cached
- Observers are eager and forgetful
- Use `eventReactive()` for controlled computation
- Use `isolate()` to break unwanted dependencies
- Use `reactiveVal()` / `reactiveValues()` for manual state management
- Use `reactlog` to visualize and debug reactive graphs
