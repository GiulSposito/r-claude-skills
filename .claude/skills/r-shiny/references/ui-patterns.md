# UI Design Patterns

## Layout Patterns

### 1. Classic Sidebar Layout

**When to use**: Most common pattern for data exploration apps with controls on left, results on right.

```r
ui <- fluidPage(
  titlePanel("Data Explorer"),

  sidebarLayout(
    sidebarPanel(
      width = 3,  # 3 out of 12 columns (default: 4)
      h3("Controls"),
      selectInput("dataset", "Dataset", choices = c("iris", "mtcars")),
      selectInput("variable", "Variable", choices = NULL),
      sliderInput("bins", "Number of bins", 10, 50, 30)
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Plot", plotOutput("plot", height = "600px")),
        tabPanel("Summary", verbatimTextOutput("summary")),
        tabPanel("Data", dataTableOutput("table"))
      )
    )
  )
)
```

### 2. Dashboard Layout (shinydashboard)

**When to use**: Professional dashboards with navigation, metrics, and multiple sections.

```r
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Sales Dashboard"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Analysis", tabName = "analysis", icon = icon("chart-line")),
      menuItem("Settings", tabName = "settings", icon = icon("cog"))
    )
  ),

  dashboardBody(
    tabItems(
      tabItem(tabName = "overview",
        fluidRow(
          valueBoxOutput("total_sales", width = 3),
          valueBoxOutput("avg_order", width = 3),
          valueBoxOutput("customers", width = 3),
          valueBoxOutput("growth", width = 3)
        ),
        fluidRow(
          box(title = "Sales Over Time", plotOutput("sales_plot"), width = 8),
          box(title = "Top Products", tableOutput("top_products"), width = 4)
        )
      ),

      tabItem(tabName = "analysis",
        # Analysis content
      )
    )
  )
)
```

### 3. Navbar Multi-Page Layout

**When to use**: Apps with distinct sections that feel like separate pages.

```r
ui <- navbarPage("My App",
  tabPanel("Home",
    fluidRow(
      column(12,
        h2("Welcome"),
        p("App description here")
      )
    )
  ),

  tabPanel("Analysis",
    sidebarLayout(
      sidebarPanel(
        # Analysis controls
      ),
      mainPanel(
        # Analysis outputs
      )
    )
  ),

  navbarMenu("More",
    tabPanel("Documentation",
      # Help content
    ),
    tabPanel("About",
      # About content
    )
  )
)
```

### 4. Custom Grid Layout

**When to use**: Complex layouts requiring precise control over positioning.

```r
ui <- fluidPage(
  # Header row spanning full width
  fluidRow(
    column(12,
      titlePanel("Custom Layout"),
      hr()
    )
  ),

  # Control row
  fluidRow(
    column(3,
      wellPanel(
        h4("Filters"),
        selectInput("category", "Category", choices = NULL)
      )
    ),
    column(6,
      wellPanel(
        h4("Search"),
        textInput("search", NULL, placeholder = "Search...")
      )
    ),
    column(3,
      wellPanel(
        h4("Options"),
        checkboxInput("advanced", "Advanced mode")
      )
    )
  ),

  # Main content row
  fluidRow(
    column(8,
      # Main plot area
      plotOutput("main_plot", height = "600px")
    ),
    column(4,
      # Side panel with tabs
      tabsetPanel(
        tabPanel("Details", verbatimTextOutput("details")),
        tabPanel("Notes", textAreaInput("notes", NULL, height = "400px"))
      )
    )
  ),

  # Footer row
  fluidRow(
    column(12,
      hr(),
      p("Footer information", class = "text-muted")
    )
  )
)
```

### 5. Responsive Cards Layout (bslib)

**When to use**: Modern responsive designs with card-based layouts.

```r
library(bslib)

ui <- page_fluid(
  h1("Card Layout"),

  layout_column_wrap(
    width = 1/3,  # Each card takes 1/3 width (responsive)

    card(
      card_header("Metric 1"),
      card_body(
        h2("$125K"),
        p("Revenue", class = "text-muted")
      )
    ),

    card(
      card_header("Metric 2"),
      card_body(
        h2("2,450"),
        p("Customers", class = "text-muted")
      )
    ),

    card(
      card_header("Metric 3"),
      card_body(
        h2("98%"),
        p("Satisfaction", class = "text-muted")
      )
    )
  ),

  card(
    full_screen = TRUE,  # Allows fullscreen toggle
    card_header("Analysis"),
    card_body(
      plotOutput("plot", height = "400px")
    )
  )
)
```

## Input Control Patterns

### Grouped Related Inputs

```r
# Visual grouping with wellPanel
wellPanel(
  h4("Date Range"),
  dateRangeInput("dates", NULL, start = Sys.Date() - 30),
  checkboxInput("include_weekends", "Include weekends", TRUE)
)

# Or with tags
tags$fieldset(
  tags$legend("Filter Options"),
  selectInput("category", "Category", choices = categories),
  sliderInput("threshold", "Threshold", 0, 100, 50)
)
```

### Inline Controls

```r
# Place controls side by side
fluidRow(
  column(6, textInput("first_name", "First Name")),
  column(6, textInput("last_name", "Last Name"))
)

# Or using splitLayout
splitLayout(
  cellWidths = c("50%", "50%"),
  textInput("from", "From"),
  textInput("to", "To")
)
```

### Conditional Inputs

```r
# Show inputs based on selection
selectInput("analysis_type", "Analysis Type",
  choices = c("Simple", "Advanced")
),

conditionalPanel(
  condition = "input.analysis_type == 'Advanced'",
  sliderInput("complexity", "Complexity", 1, 10, 5),
  checkboxInput("use_bootstrap", "Use Bootstrap")
)
```

### Dynamic Choice Updates

```r
# Cascading dropdowns
server <- function(input, output, session) {
  # Update regions when country changes
  observeEvent(input$country, {
    regions <- get_regions(input$country)
    updateSelectInput(session, "region", choices = regions)
  })

  # Update cities when region changes
  observeEvent(input$region, {
    cities <- get_cities(input$country, input$region)
    updateSelectInput(session, "city", choices = cities)
  })
}
```

### Input Validation Feedback

```r
library(shinyFeedback)

server <- function(input, output, session) {
  # Enable feedback
  useShinyFeedback()

  # Validate email
  observeEvent(input$email, {
    if (grepl("^[^@]+@[^@]+\\.[^@]+$", input$email)) {
      feedbackSuccess("email", "Valid email")
    } else {
      feedbackDanger("email", "Please enter a valid email")
    }
  })

  # Validate number range
  observeEvent(input$value, {
    if (input$value >= 0 && input$value <= 100) {
      feedbackSuccess("value", "Within range")
    } else {
      feedbackWarning("value", "Value should be between 0 and 100")
    }
  })
}
```

## Output Display Patterns

### Tabbed Output Groups

```r
mainPanel(
  tabsetPanel(
    id = "results_tabs",  # For programmatic control

    tabPanel("Visualization",
      value = "viz",  # For updateTabsetPanel()
      plotOutput("main_plot", height = "600px"),
      downloadButton("download_plot", "Download Plot")
    ),

    tabPanel("Statistical Summary",
      value = "stats",
      verbatimTextOutput("summary"),
      downloadButton("download_summary", "Download")
    ),

    tabPanel("Data Table",
      value = "data",
      DTOutput("table"),
      downloadButton("download_data", "Download CSV")
    )
  )
)
```

### Conditional Output Display

```r
# Show different outputs based on state
output$dynamic_output <- renderUI({
  if (is.null(data())) {
    tags$div(
      class = "alert alert-info",
      h4("No Data"),
      p("Please upload a file to begin.")
    )
  } else if (nrow(data()) == 0) {
    tags$div(
      class = "alert alert-warning",
      h4("Empty Dataset"),
      p("The uploaded file contains no data.")
    )
  } else {
    tagList(
      h4(sprintf("%d records loaded", nrow(data()))),
      dataTableOutput("table")
    )
  }
})
```

### Loading Indicators

```r
# Built-in spinner for outputs
plotOutput("plot") |> withSpinner()

# Or manual loading state
output$results <- renderUI({
  if (input$run == 0) {
    p("Click 'Run' to start analysis")
  } else {
    # Wrap in isolate to prevent re-rendering
    isolate({
      # Show spinner during computation
      withProgress(message = "Computing...", {
        results <- expensive_computation()
      })
      renderResults(results)
    })
  }
})
```

### Placeholder Messages

```r
output$plot <- renderPlot({
  # Use validate() for informative empty states
  validate(
    need(input$file, "Please upload a data file"),
    need(nrow(data()) > 0, "The file is empty"),
    need(input$x_var %in% names(data()), "Please select X variable"),
    need(input$y_var %in% names(data()), "Please select Y variable")
  )

  ggplot(data(), aes(x = .data[[input$x_var]], y = .data[[input$y_var]])) +
    geom_point()
})
```

## Theming and Styling

### Modern Theme with bslib

```r
library(bslib)

# Pre-made themes
ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),  # Or: darkly, cosmo, etc.
  # ... rest of UI
)

# Custom theme
ui <- fluidPage(
  theme = bs_theme(
    bg = "#FFFFFF",
    fg = "#000000",
    primary = "#3498db",
    secondary = "#7f8c8d",
    success = "#2ecc71",
    danger = "#e74c3c",
    base_font = font_google("Open Sans"),
    heading_font = font_google("Raleway")
  ),
  # ... rest of UI
)

# Match plots to theme
server <- function(input, output, session) {
  thematic::thematic_shiny()  # Auto-match ggplot2 to theme

  output$plot <- renderPlot({
    ggplot(mtcars, aes(mpg, wt)) + geom_point()
  })
}
```

### Custom CSS

```r
ui <- fluidPage(
  # Inline CSS
  tags$style(HTML("
    .sidebar {
      background-color: #f8f9fa;
      padding: 20px;
      border-radius: 5px;
    }

    .metric-box {
      text-align: center;
      padding: 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border-radius: 10px;
      margin: 10px 0;
    }

    .metric-box h2 {
      margin: 0;
      font-size: 48px;
      font-weight: bold;
    }
  ")),

  # Use custom classes
  div(class = "sidebar",
    h3("Controls"),
    selectInput("var", "Variable", choices = NULL)
  ),

  div(class = "metric-box",
    h2("$125,000"),
    p("Total Revenue")
  )
)
```

### Bootstrap Utilities

```r
# Text utilities
p("Primary text", class = "text-primary")
p("Muted text", class = "text-muted")
p("Success message", class = "text-success")

# Background utilities
div(class = "bg-light p-3", "Light background")
div(class = "bg-primary text-white p-3", "Primary background")

# Spacing utilities
div(class = "mt-3 mb-2", "Margin top 3, bottom 2")
div(class = "p-4", "Padding 4 on all sides")

# Alignment
div(class = "text-center", "Centered text")
div(class = "text-right", "Right-aligned text")

# Display utilities
div(class = "d-none d-md-block", "Hidden on small screens")
```

## Interactive Element Patterns

### Action Links vs Buttons

```r
# Standard button
actionButton("submit", "Submit", class = "btn-primary")

# Link-styled button
actionLink("details", "Show details")

# Button with icon
actionButton("refresh", "Refresh", icon = icon("sync"))

# Button styles
actionButton("delete", "Delete", class = "btn-danger")
actionButton("save", "Save", class = "btn-success")
actionButton("cancel", "Cancel", class = "btn-secondary")
```

### Progress Bars

```r
# Static progress bar
progressBar <- function(value, color = "primary") {
  tags$div(
    class = "progress",
    tags$div(
      class = paste("progress-bar bg", color, sep = "-"),
      style = sprintf("width: %d%%", value),
      sprintf("%d%%", value)
    )
  )
}

# In UI
uiOutput("progress")

# In server
output$progress <- renderUI({
  progressBar(completion_percent(), "success")
})
```

### Tooltips and Popovers

```r
library(bslib)

# Tooltip
tooltip(
  actionButton("help", "Help"),
  "Click for assistance"
)

# Popover with more content
popover(
  actionButton("info", "Info"),
  "More Information",
  "This is a more detailed explanation that can include multiple lines."
)
```

### Collapsible Sections

```r
library(bsCollapse)

ui <- fluidPage(
  bsCollapse(
    id = "collapse_panel",
    open = "panel1",  # Start with first panel open

    bsCollapsePanel("Data Import",
      value = "panel1",
      fileInput("file", "Upload Data"),
      actionButton("load", "Load")
    ),

    bsCollapsePanel("Data Transformation",
      value = "panel2",
      selectInput("operation", "Operation", choices = c("Filter", "Mutate"))
    ),

    bsCollapsePanel("Visualization",
      value = "panel3",
      plotOutput("plot")
    )
  )
)

# Programmatic control
observeEvent(input$next_step, {
  updateCollapse(session, "collapse_panel", open = "panel2")
})
```

## Responsive Design

### Mobile-Friendly Layouts

```r
ui <- fluidPage(
  # Meta tag for responsive design
  tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),

  # Responsive columns
  fluidRow(
    column(12,  # Full width on mobile
      column(6, class = "col-md-4",  # 6 cols on mobile, 4 on medium+
        wellPanel(
          selectInput("input1", "Input 1", choices = NULL)
        )
      ),
      column(6, class = "col-md-8",
        plotOutput("plot", height = "300px")
      )
    )
  )
)
```

### Hide Elements on Small Screens

```r
# Hide sidebar on mobile, show button to toggle
ui <- fluidPage(
  tags$button(
    class = "btn btn-primary d-md-none",  # Only show on small screens
    `data-toggle` = "collapse",
    `data-target` = "#sidebar",
    "Show Filters"
  ),

  fluidRow(
    column(3,
      id = "sidebar",
      class = "collapse d-md-block",  # Collapsed on mobile, always visible on desktop
      wellPanel(
        # Sidebar controls
      )
    ),
    column(9,
      # Main content
    )
  )
)
```

---

**Key Principles:**
- Use semantic HTML structure
- Leverage Bootstrap's grid system (12 columns)
- Apply consistent spacing with utility classes
- Provide clear visual hierarchy
- Ensure responsive behavior on mobile devices
- Use wellPanel() or card() to group related elements
- Add loading states and empty state messages
- Validate inputs and provide immediate feedback
