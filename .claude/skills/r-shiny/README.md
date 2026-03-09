# Expert Shiny Development Skill

A comprehensive Claude Code skill for building production-quality Shiny applications in R, based on best practices from Hadley Wickham's "Mastering Shiny".

## What This Skill Provides

This skill gives Claude expert knowledge of:

- **Reactive Programming**: Understanding reactive sources, conductors, and endpoints
- **UI Design**: Modern layouts, responsive design, and user feedback patterns
- **Modules**: Creating reusable, isolated components with proper namespacing
- **Performance**: Caching strategies, profiling, and optimization techniques
- **Security**: Input validation, credential management, and preventing code injection
- **Testing**: Unit tests, reactive testing, and module testing strategies
- **Code Organization**: File structures, package development, and best practices

## When This Skill Is Used

This skill automatically activates when Claude detects:

- `library(shiny)` in R code
- Shiny-specific patterns (`ui <-`, `server <-`, reactive expressions)
- User mentions of Shiny, shinydashboard, or interactive R apps
- Questions about reactive programming or Shiny development

**User-invocable**: No (Claude invokes automatically)

## Skill Structure

```
r-shiny/
├── SKILL.md                            # Core patterns and quick reference
├── README.md                           # This file
├── references/                         # Detailed documentation
│   ├── reactivity-patterns.md         # Deep dive into reactive programming
│   ├── ui-patterns.md                 # UI design patterns and layouts
│   ├── modules-and-organization.md    # Modules and code organization
│   ├── performance-and-security.md    # Optimization and security
│   └── common-pitfalls.md             # Common mistakes and solutions
└── templates/                          # Working code templates
    ├── basic-app.R                    # Minimal complete app
    └── module-template.R              # Reusable module pattern
```

## Quick Start Examples

### Basic Shiny App

```r
library(shiny)

ui <- fluidPage(
  titlePanel("Hello Shiny"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Sample Size", 10, 100, 50)
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

### Using Reactive Expressions

```r
server <- function(input, output, session) {
  # Compute once, use many times
  filtered_data <- reactive({
    data |> filter(category == input$category)
  })

  output$plot <- renderPlot({ plot(filtered_data()) })
  output$table <- renderTable({ filtered_data() })
  output$summary <- renderPrint({ summary(filtered_data()) })
}
```

### Creating a Module

```r
# Module UI
mod_counter_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("increment"), "Increment"),
    textOutput(ns("value"))
  )
}

# Module Server
mod_counter_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    count <- reactiveVal(0)

    observeEvent(input$increment, {
      count(count() + 1)
    })

    output$value <- renderText({ count() })
  })
}

# Use in app
ui <- fluidPage(
  mod_counter_ui("counter1"),
  mod_counter_ui("counter2")
)

server <- function(input, output, session) {
  mod_counter_server("counter1")
  mod_counter_server("counter2")
}
```

## Key Concepts

### The Reactive Trinity

1. **Reactive Sources (Inputs)**: User inputs from the browser
   - Read-only: `input$name`
   - Automatically invalidate dependents

2. **Reactive Conductors (Expressions)**: Cached computations
   - Created with `reactive({})`
   - Lazy and cached
   - Called like functions: `data()`

3. **Reactive Endpoints (Observers/Outputs)**: Side effects
   - Outputs: `output$name <- render*()`
   - Observers: `observe({})`, `observeEvent()`
   - Eager and forgetful

### Essential Patterns

**Input Validation**
```r
output$result <- renderText({
  req(input$file)  # Wait for input
  validate(        # Show user-friendly errors
    need(input$n > 0, "N must be positive")
  )
  # Process input
})
```

**Event-Driven Reactivity**
```r
# Only recalculate when button clicked
results <- eventReactive(input$run_button, {
  expensive_computation(input$params)
})
```

**Performance: Caching**
```r
expensive_result <- reactive({
  complex_analysis(input$params)
}) |> bindCache(input$params)
```

**Security: Input Validation**
```r
# Always validate server-side
validate(
  need(input$file$size < 10e6, "File too large"),
  need(tools::file_ext(input$file$name) == "csv", "Must be CSV")
)
```

## Common Workflows

### Data Analysis App

1. **File Upload** → `fileInput()`, validate format and size
2. **Data Processing** → Reactive expression for filtering/transforming
3. **Visualization** → Multiple outputs using same reactive data
4. **Download Results** → `downloadHandler()` for exports

### Dashboard App

1. **Layout** → `shinydashboard` with `dashboardPage()`
2. **Metrics** → `valueBox()` or `infoBox()` for KPIs
3. **Interactive Plots** → Click/brush for drill-down
4. **Real-time Updates** → `reactiveTimer()` or `reactivePoll()`

### Multi-Page App

1. **Navigation** → `navbarPage()` or `tabsetPanel()`
2. **Modules** → One module per major section
3. **Shared State** → `reactiveValues()` passed to modules
4. **Testing** → `testServer()` for each module

## Testing Your Shiny Apps

```r
# Test pure functions
test_that("data processing works", {
  result <- process_data(test_data)
  expect_equal(nrow(result), 10)
})

# Test reactive logic
test_that("output updates correctly", {
  testServer(server, {
    session$setInputs(value = 10)
    expect_equal(output$result, 20)
  })
})

# Test modules
test_that("module filters data", {
  test_data <- reactive({ mtcars })
  testServer(mod_filter_server, args = list(data = test_data), {
    session$setInputs(threshold = 20)
    expect_true(all(filtered_data()$mpg > 20))
  })
})
```

## Performance Checklist

✅ Use `reactive()` for expensive computations used multiple times
✅ Apply `bindCache()` to cache results across users
✅ Load data outside `server` function when possible
✅ Use `server = TRUE` for large DataTables
✅ Debounce/throttle rapid inputs
✅ Profile with `profvis` before optimizing
✅ Load test with `shinyloadtest`

## Security Checklist

✅ Validate ALL user inputs server-side
✅ Use whitelists for allowed values
✅ Never use `parse()` or `eval()` with user input
✅ Use parameterized SQL queries
✅ Store credentials in environment variables
✅ Limit file upload sizes
✅ Sanitize error messages
✅ Test with malicious inputs

## Reference Documentation

For in-depth coverage of specific topics:

- **[reactivity-patterns.md](references/reactivity-patterns.md)**: Deep dive into reactive programming, the reactive graph, and advanced patterns
- **[ui-patterns.md](references/ui-patterns.md)**: UI layouts, input controls, output displays, theming, and responsive design
- **[modules-and-organization.md](references/modules-and-organization.md)**: Module structure, communication patterns, nested modules, and file organization
- **[performance-and-security.md](references/performance-and-security.md)**: Profiling, caching, async programming, input validation, and security best practices
- **[common-pitfalls.md](references/common-pitfalls.md)**: 22 common mistakes and their solutions

## Templates

Start new projects with working templates:

- **[basic-app.R](templates/basic-app.R)**: Minimal complete Shiny app with good structure
- **[module-template.R](templates/module-template.R)**: Reusable module pattern with documentation and demo app

## Learning Path

### Beginner
1. Start with `templates/basic-app.R`
2. Understand the reactive trinity (sources, conductors, endpoints)
3. Learn input validation with `req()` and `validate()`
4. Practice with different layouts and inputs

### Intermediate
1. Extract functions from reactive expressions
2. Create your first module
3. Implement user feedback (notifications, progress bars)
4. Add file upload/download capabilities

### Advanced
1. Build multi-module applications
2. Profile and optimize performance
3. Implement proper security measures
4. Package your app for deployment
5. Add comprehensive testing

## Resources

- **Mastering Shiny**: https://mastering-shiny.org/ (Hadley Wickham)
- **Shiny Gallery**: https://shiny.posit.co/r/gallery/
- **Shiny Cheat Sheet**: https://posit.co/resources/cheatsheets/
- **Engineering Production-Grade Shiny Apps**: https://engineering-shiny.org/

## Getting Help

When asking Claude for help with Shiny:

- **Describe the behavior**: "When I click the button, nothing happens"
- **Share relevant code**: UI definition and server logic
- **Mention errors**: Any error messages or warnings
- **Specify goal**: What you're trying to achieve

Claude will use this skill to provide expert guidance based on Mastering Shiny best practices.

---

**Skill Version**: 1.0.0
**Based on**: Mastering Shiny by Hadley Wickham (2021)
**Last Updated**: 2026-03-08
