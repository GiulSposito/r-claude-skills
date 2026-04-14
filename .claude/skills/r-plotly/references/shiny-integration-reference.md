# Shiny Integration Reference

Complete guide to integrating Plotly with Shiny applications. Covers basic setup, event handling, proxy updates, interactive dashboards, and advanced patterns for production applications.

## Table of Contents

1. [Basic Integration](#basic-integration)
2. [Event Data](#event-data)
3. [Plotly Proxy](#plotly-proxy)
4. [Interactive Dashboards](#interactive-dashboards)
5. [Advanced Patterns](#advanced-patterns)

---

## Basic Integration

### Core Functions

```r
# UI side
plotlyOutput(
  outputId,
  width = "100%",
  height = "400px",
  inline = FALSE
)

# Server side
renderPlotly(
  expr,
  env = parent.frame(),
  quoted = FALSE
)
```

### Minimal Shiny App

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel("Basic Plotly Integration"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Number of points:", 10, 100, 50)
    ),
    mainPanel(
      plotlyOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      x = rnorm(input$n),
      y = rnorm(input$n),
      type = "scatter",
      mode = "markers"
    )
  })
}

shinyApp(ui, server)
```

### Sizing and Layout

```r
# Fixed height
plotlyOutput("plot", height = "600px")

# Percentage-based
plotlyOutput("plot", height = "80vh")

# Responsive to container
ui <- fluidPage(
  tags$style(HTML("
    .plot-container {
      height: 100vh;
      width: 100%;
    }
  ")),
  div(
    class = "plot-container",
    plotlyOutput("plot", width = "100%", height = "100%")
  )
)

# Dynamic sizing in server
output$plot <- renderPlotly({
  plot_ly(data = mtcars, x = ~wt, y = ~mpg) |>
    layout(
      autosize = TRUE,
      margin = list(l = 50, r = 50, t = 50, b = 50)
    )
})
```

### Performance Considerations

```r
# Use ggplotly() with caution - can be slow for large data
output$plot <- renderPlotly({
  # Bad: converts entire ggplot object
  p <- ggplot(large_data, aes(x, y)) + geom_point()
  ggplotly(p)
})

# Better: Use plot_ly() directly
output$plot <- renderPlotly({
  plot_ly(large_data, x = ~x, y = ~y, type = "scattergl")
})

# Best: Sample data for visualization
output$plot <- renderPlotly({
  sampled <- large_data |> slice_sample(n = 1000)
  plot_ly(sampled, x = ~x, y = ~y, type = "scattergl")
})

# Cache static elements
cached_layout <- list(
  title = "My Plot",
  xaxis = list(title = "X"),
  yaxis = list(title = "Y")
)

output$plot <- renderPlotly({
  plot_ly(reactive_data(), x = ~x, y = ~y) |>
    layout(cached_layout)
})
```

---

## Event Data

### Event Types Overview

Plotly generates four main event types in Shiny:
- `plotly_click`: Single click on data point
- `plotly_hover`: Mouse hover over data point
- `plotly_selected`: Box/lasso selection of points
- `plotly_relayout`: Layout changes (zoom, pan)

### Click Events

```r
# Access click data
event_data("plotly_click", source = "plot_source")

# Structure of click event data:
# - curveNumber: trace index (0-based)
# - pointNumber: point index within trace
# - x, y: coordinates of clicked point
# - customdata: custom data attached to point

# Complete example
ui <- fluidPage(
  plotlyOutput("plot"),
  verbatimTextOutput("click_info")
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      mtcars,
      x = ~wt,
      y = ~mpg,
      type = "scatter",
      mode = "markers",
      source = "mtcars_plot"
    )
  })

  output$click_info <- renderPrint({
    click <- event_data("plotly_click", source = "mtcars_plot")
    if (is.null(click)) {
      "Click on a point"
    } else {
      cat("Clicked point:\n")
      cat("Curve:", click$curveNumber, "\n")
      cat("Point:", click$pointNumber, "\n")
      cat("Weight:", click$x, "\n")
      cat("MPG:", click$y, "\n")
    }
  })
}
```

### Hover Events

```r
# Hover event structure identical to click
# More frequent - use carefully for performance

ui <- fluidPage(
  plotlyOutput("plot"),
  verbatimTextOutput("hover_info")
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      iris,
      x = ~Sepal.Length,
      y = ~Sepal.Width,
      color = ~Species,
      type = "scatter",
      mode = "markers",
      source = "iris_plot",
      customdata = ~Species  # Add custom data
    )
  })

  output$hover_info <- renderText({
    hover <- event_data("plotly_hover", source = "iris_plot")
    if (is.null(hover)) {
      "Hover over a point"
    } else {
      paste0(
        "Species: ", hover$customdata, "\n",
        "Sepal Length: ", round(hover$x, 2), "\n",
        "Sepal Width: ", round(hover$y, 2)
      )
    }
  })
}
```

### Selection Events

```r
# Box or lasso selection returns multiple points
# Structure: data frame with all selected points

ui <- fluidPage(
  plotlyOutput("plot"),
  tableOutput("selected_data")
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      mtcars,
      x = ~wt,
      y = ~mpg,
      type = "scatter",
      mode = "markers",
      source = "car_plot"
    ) |>
      layout(
        dragmode = "select",  # or "lasso"
        selectdirection = "any"  # "h", "v", or "any"
      )
  })

  output$selected_data <- renderTable({
    selected <- event_data("plotly_selected", source = "car_plot")
    if (is.null(selected)) {
      data.frame(Message = "Select points with box or lasso")
    } else {
      # Get original data for selected points
      indices <- selected$pointNumber + 1  # Convert to 1-based
      mtcars[indices, c("wt", "mpg", "hp", "cyl")]
    }
  })
}
```

### Relayout Events

```r
# Captures zoom, pan, and axis range changes
# Structure includes axis ranges and layout properties

ui <- fluidPage(
  plotlyOutput("plot"),
  verbatimTextOutput("relayout_info")
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      x = 1:100,
      y = cumsum(rnorm(100)),
      type = "scatter",
      mode = "lines",
      source = "zoom_plot"
    )
  })

  output$relayout_info <- renderPrint({
    relayout <- event_data("plotly_relayout", source = "zoom_plot")
    if (is.null(relayout)) {
      cat("Zoom or pan the plot")
    } else {
      cat("Layout changes:\n")
      str(relayout)
    }
  })
}
```

### observeEvent Patterns

```r
# Pattern 1: Simple reactive action
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg, source = "cars")
  })

  observeEvent(event_data("plotly_click", source = "cars"), {
    click <- event_data("plotly_click", source = "cars")
    showNotification(
      paste("Clicked on point", click$pointNumber + 1),
      type = "message"
    )
  })
}

# Pattern 2: Update reactive value
server <- function(input, output, session) {
  selected_car <- reactiveVal(NULL)

  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg, source = "cars")
  })

  observeEvent(event_data("plotly_click", source = "cars"), {
    click <- event_data("plotly_click", source = "cars")
    car_name <- rownames(mtcars)[click$pointNumber + 1]
    selected_car(car_name)
  })

  output$car_details <- renderText({
    req(selected_car())
    paste("Selected:", selected_car())
  })
}

# Pattern 3: Update other plots
server <- function(input, output, session) {
  clicked_species <- reactiveVal(NULL)

  output$scatter <- renderPlotly({
    plot_ly(
      iris,
      x = ~Sepal.Length,
      y = ~Sepal.Width,
      color = ~Species,
      source = "scatter"
    )
  })

  observeEvent(event_data("plotly_click", source = "scatter"), {
    click <- event_data("plotly_click", source = "scatter")
    clicked_species(click$customdata)
  })

  output$histogram <- renderPlotly({
    req(clicked_species())
    data <- iris |> filter(Species == clicked_species())
    plot_ly(data, x = ~Petal.Length, type = "histogram")
  })
}

# Pattern 4: Debounced hover events
server <- function(input, output, session) {
  hover_debounced <- reactiveVal(NULL)
  hover_timer <- reactiveVal(NULL)

  observeEvent(event_data("plotly_hover", source = "plot"), {
    # Cancel previous timer
    if (!is.null(hover_timer())) {
      invalidateLater(0, hover_timer())
    }

    # Set new timer
    timer <- reactiveTimer(500)  # 500ms delay
    hover_timer(timer)

    observe({
      timer()
      isolate({
        hover_debounced(event_data("plotly_hover", source = "plot"))
      })
    })
  })

  output$info <- renderText({
    hover <- hover_debounced()
    if (is.null(hover)) "Hover over points" else paste("Point:", hover$x)
  })
}

# Pattern 5: Multi-event coordination
server <- function(input, output, session) {
  interaction <- reactiveVal(list(type = "none", data = NULL))

  observeEvent(event_data("plotly_click", source = "plot"), {
    interaction(list(
      type = "click",
      data = event_data("plotly_click", source = "plot")
    ))
  })

  observeEvent(event_data("plotly_selected", source = "plot"), {
    interaction(list(
      type = "selected",
      data = event_data("plotly_selected", source = "plot")
    ))
  })

  output$response <- renderUI({
    int <- interaction()
    switch(
      int$type,
      "click" = div("Single point clicked"),
      "selected" = div(nrow(int$data), "points selected"),
      div("No interaction yet")
    )
  })
}
```

### Complete Event Handling Example

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Complete Event Handling"),
  fluidRow(
    column(6, plotlyOutput("scatter")),
    column(6, plotlyOutput("bar"))
  ),
  hr(),
  fluidRow(
    column(4, verbatimTextOutput("click_info")),
    column(4, verbatimTextOutput("hover_info")),
    column(4, verbatimTextOutput("selected_info"))
  )
)

server <- function(input, output, session) {
  # Main scatter plot
  output$scatter <- renderPlotly({
    plot_ly(
      iris,
      x = ~Sepal.Length,
      y = ~Sepal.Width,
      color = ~Species,
      type = "scatter",
      mode = "markers",
      source = "iris_scatter",
      customdata = ~Species,
      marker = list(size = 10)
    ) |>
      layout(
        title = "Click, Hover, or Select Points",
        dragmode = "select"
      )
  })

  # Click response
  output$click_info <- renderPrint({
    click <- event_data("plotly_click", source = "iris_scatter")
    if (is.null(click)) {
      cat("Click on a point\n")
    } else {
      cat("Clicked Point:\n")
      cat("Species:", click$customdata, "\n")
      cat("Sepal Length:", round(click$x, 2), "\n")
      cat("Sepal Width:", round(click$y, 2), "\n")
    }
  })

  # Hover response
  output$hover_info <- renderPrint({
    hover <- event_data("plotly_hover", source = "iris_scatter")
    if (is.null(hover)) {
      cat("Hover over a point\n")
    } else {
      cat("Hovering:\n")
      cat("Point #", hover$pointNumber + 1, "\n")
      cat("Species:", hover$customdata, "\n")
    }
  })

  # Selection response with linked bar chart
  selected_data <- reactive({
    selected <- event_data("plotly_selected", source = "iris_scatter")
    if (is.null(selected)) {
      iris
    } else {
      indices <- selected$pointNumber + 1
      iris[indices, ]
    }
  })

  output$selected_info <- renderPrint({
    data <- selected_data()
    cat("Selected:", nrow(data), "points\n")
    cat("\nSpecies counts:\n")
    print(table(data$Species))
  })

  output$bar <- renderPlotly({
    data <- selected_data()
    counts <- as.data.frame(table(data$Species))
    names(counts) <- c("Species", "Count")

    plot_ly(
      counts,
      x = ~Species,
      y = ~Count,
      type = "bar",
      marker = list(
        color = c("setosa" = "#1f77b4", "versicolor" = "#ff7f0e",
                  "virginica" = "#2ca02c")[counts$Species]
      )
    ) |>
      layout(title = "Species Distribution (Selected)")
  })
}

shinyApp(ui, server)
```

---

## Plotly Proxy

### Core Proxy Functions

```r
# Create proxy to existing plot
plotlyProxy(outputId, session = getDefaultReactiveDomain())

# Invoke plotly.js methods
plotlyProxyInvoke(
  p,
  method,
  ...,
  session = getDefaultReactiveDomain()
)
```

### Basic Proxy Updates

```r
ui <- fluidPage(
  actionButton("add_trace", "Add Trace"),
  actionButton("remove_trace", "Remove Trace"),
  plotlyOutput("plot")
)

server <- function(input, output, session) {
  trace_count <- reactiveVal(1)

  # Initial plot
  output$plot <- renderPlotly({
    plot_ly(
      x = 1:10,
      y = rnorm(10),
      type = "scatter",
      mode = "lines+markers",
      name = "Trace 1"
    )
  })

  # Add trace without re-rendering
  observeEvent(input$add_trace, {
    count <- trace_count() + 1
    trace_count(count)

    plotlyProxy("plot", session) |>
      plotlyProxyInvoke(
        "addTraces",
        list(
          x = 1:10,
          y = rnorm(10),
          type = "scatter",
          mode = "lines+markers",
          name = paste("Trace", count)
        )
      )
  })

  # Remove last trace
  observeEvent(input$remove_trace, {
    count <- trace_count()
    if (count > 1) {
      trace_count(count - 1)
      plotlyProxy("plot", session) |>
        plotlyProxyInvoke("deleteTraces", count - 1)
    }
  })
}
```

### Efficient Data Updates

```r
# Update data without full re-render
ui <- fluidPage(
  actionButton("update", "Update Data"),
  plotlyOutput("plot")
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      x = 1:20,
      y = rnorm(20),
      type = "scatter",
      mode = "lines+markers"
    )
  })

  observeEvent(input$update, {
    plotlyProxy("plot", session) |>
      plotlyProxyInvoke(
        "restyle",
        list(y = list(rnorm(20))),  # New y values
        list(0)  # Trace index
      )
  })
}
```

### Restyle vs Relayout

```r
# restyle: changes to traces (data, colors, sizes)
# relayout: changes to layout (axes, title, annotations)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg, type = "scatter", mode = "markers")
  })

  # Change marker color (restyle)
  observeEvent(input$change_color, {
    plotlyProxy("plot", session) |>
      plotlyProxyInvoke(
        "restyle",
        list(marker.color = "red"),
        list(0)
      )
  })

  # Change axis title (relayout)
  observeEvent(input$change_title, {
    plotlyProxy("plot", session) |>
      plotlyProxyInvoke(
        "relayout",
        list(xaxis = list(title = "Weight (1000 lbs)"))
      )
  })
}
```

### Animate with Proxy

```r
ui <- fluidPage(
  actionButton("animate", "Animate"),
  plotlyOutput("plot")
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      x = 1:10,
      y = rep(0, 10),
      type = "scatter",
      mode = "markers",
      marker = list(size = 15)
    ) |>
      layout(yaxis = list(range = c(-5, 5)))
  })

  observeEvent(input$animate, {
    # Animate over 10 steps
    for (i in 1:10) {
      delay(i * 100, {
        plotlyProxy("plot", session) |>
          plotlyProxyInvoke(
            "animate",
            list(
              data = list(list(y = rnorm(10))),
              traces = list(0)
            ),
            list(
              transition = list(duration = 100),
              frame = list(duration = 100, redraw = FALSE)
            )
          )
      })
    }
  })
}
```

### Real-time Streaming

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel("Real-time Data Stream"),
  actionButton("start", "Start Stream"),
  actionButton("stop", "Stop Stream"),
  plotlyOutput("stream_plot")
)

server <- function(input, output, session) {
  values <- reactiveValues(
    x = 1:50,
    y = rnorm(50),
    streaming = FALSE
  )

  output$stream_plot <- renderPlotly({
    plot_ly(
      x = values$x,
      y = values$y,
      type = "scatter",
      mode = "lines"
    ) |>
      layout(
        xaxis = list(range = c(1, 50)),
        yaxis = list(range = c(-3, 3))
      )
  })

  observeEvent(input$start, {
    values$streaming <- TRUE
  })

  observeEvent(input$stop, {
    values$streaming <- FALSE
  })

  observe({
    invalidateLater(100, session)
    isolate({
      if (values$streaming) {
        # Shift data and add new point
        values$y <- c(values$y[-1], rnorm(1))

        plotlyProxy("stream_plot", session) |>
          plotlyProxyInvoke(
            "restyle",
            list(y = list(values$y)),
            list(0)
          )
      }
    })
  })
}

shinyApp(ui, server)
```

### Complex Proxy Example

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel("Plotly Proxy Controls"),
  sidebarLayout(
    sidebarPanel(
      selectInput("trace", "Select Trace:",
                  choices = c("Trace 1", "Trace 2", "Trace 3")),
      sliderInput("opacity", "Opacity:", 0, 1, 1, 0.1),
      selectInput("mode", "Mode:",
                  choices = c("markers", "lines", "lines+markers")),
      actionButton("add", "Add Random Trace"),
      actionButton("remove", "Remove Selected Trace")
    ),
    mainPanel(
      plotlyOutput("plot", height = "600px")
    )
  )
)

server <- function(input, output, session) {
  trace_counter <- reactiveVal(3)

  output$plot <- renderPlotly({
    plot_ly() |>
      add_trace(x = 1:10, y = rnorm(10), name = "Trace 1",
                type = "scatter", mode = "lines+markers") |>
      add_trace(x = 1:10, y = rnorm(10), name = "Trace 2",
                type = "scatter", mode = "lines+markers") |>
      add_trace(x = 1:10, y = rnorm(10), name = "Trace 3",
                type = "scatter", mode = "lines+markers")
  })

  # Update opacity
  observeEvent(input$opacity, {
    trace_idx <- as.numeric(sub("Trace ", "", input$trace)) - 1
    plotlyProxy("plot", session) |>
      plotlyProxyInvoke(
        "restyle",
        list(opacity = input$opacity),
        list(trace_idx)
      )
  })

  # Update mode
  observeEvent(input$mode, {
    trace_idx <- as.numeric(sub("Trace ", "", input$trace)) - 1
    plotlyProxy("plot", session) |>
      plotlyProxyInvoke(
        "restyle",
        list(mode = input$mode),
        list(trace_idx)
      )
  })

  # Add trace
  observeEvent(input$add, {
    count <- trace_counter() + 1
    trace_counter(count)

    plotlyProxy("plot", session) |>
      plotlyProxyInvoke(
        "addTraces",
        list(
          x = 1:10,
          y = rnorm(10),
          type = "scatter",
          mode = "lines+markers",
          name = paste("Trace", count)
        )
      )

    # Update trace selector
    updateSelectInput(
      session, "trace",
      choices = paste("Trace", 1:count)
    )
  })

  # Remove trace
  observeEvent(input$remove, {
    trace_idx <- as.numeric(sub("Trace ", "", input$trace)) - 1
    plotlyProxy("plot", session) |>
      plotlyProxyInvoke("deleteTraces", trace_idx)

    count <- trace_counter() - 1
    trace_counter(count)

    updateSelectInput(
      session, "trace",
      choices = paste("Trace", 1:count)
    )
  })
}

shinyApp(ui, server)
```

---

## Interactive Dashboards

### Click-to-Filter Pattern

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Click to Filter Dashboard"),
  fluidRow(
    column(6,
           h4("Click on a species to filter"),
           plotlyOutput("species_bar")
    ),
    column(6,
           h4("Filtered scatter plot"),
           plotlyOutput("scatter")
    )
  ),
  fluidRow(
    column(12,
           h4("Filtered data"),
           tableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  # Store selected species
  selected_species <- reactiveVal(NULL)

  # Bar chart of species counts
  output$species_bar <- renderPlotly({
    counts <- iris |>
      count(Species)

    plot_ly(
      counts,
      x = ~Species,
      y = ~n,
      type = "bar",
      source = "species_bar",
      customdata = ~Species
    ) |>
      layout(
        title = "Species Counts",
        xaxis = list(title = ""),
        yaxis = list(title = "Count")
      )
  })

  # Handle bar click
  observeEvent(event_data("plotly_click", source = "species_bar"), {
    click <- event_data("plotly_click", source = "species_bar")
    selected_species(click$x)
  })

  # Filtered scatter plot
  output$scatter <- renderPlotly({
    data <- iris
    if (!is.null(selected_species())) {
      data <- data |> filter(Species == selected_species())
    }

    plot_ly(
      data,
      x = ~Sepal.Length,
      y = ~Sepal.Width,
      color = ~Species,
      type = "scatter",
      mode = "markers"
    ) |>
      layout(
        title = if (is.null(selected_species())) {
          "All Species"
        } else {
          paste("Species:", selected_species())
        }
      )
  })

  # Filtered table
  output$table <- renderTable({
    data <- iris
    if (!is.null(selected_species())) {
      data <- data |> filter(Species == selected_species())
    }
    head(data, 10)
  })
}

shinyApp(ui, server)
```

### Linked Plots

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Linked Plot Dashboard"),
  fluidRow(
    column(6, plotlyOutput("scatter1")),
    column(6, plotlyOutput("scatter2"))
  ),
  fluidRow(
    column(6, plotlyOutput("histogram1")),
    column(6, plotlyOutput("histogram2"))
  )
)

server <- function(input, output, session) {
  # Shared selection state
  selected_points <- reactiveVal(NULL)

  # Scatter plot 1: Weight vs MPG
  output$scatter1 <- renderPlotly({
    plot_ly(
      mtcars,
      x = ~wt,
      y = ~mpg,
      type = "scatter",
      mode = "markers",
      source = "scatter1",
      marker = list(size = 10)
    ) |>
      layout(
        title = "Weight vs MPG",
        dragmode = "select"
      )
  })

  # Scatter plot 2: HP vs MPG
  output$scatter2 <- renderPlotly({
    plot_ly(
      mtcars,
      x = ~hp,
      y = ~mpg,
      type = "scatter",
      mode = "markers",
      source = "scatter2",
      marker = list(size = 10)
    ) |>
      layout(
        title = "Horsepower vs MPG",
        dragmode = "select"
      )
  })

  # Handle selection from either plot
  observe({
    sel1 <- event_data("plotly_selected", source = "scatter1")
    sel2 <- event_data("plotly_selected", source = "scatter2")

    if (!is.null(sel1)) {
      selected_points(sel1$pointNumber + 1)
    } else if (!is.null(sel2)) {
      selected_points(sel2$pointNumber + 1)
    } else {
      selected_points(NULL)
    }
  })

  # Histogram 1: Weight distribution
  output$histogram1 <- renderPlotly({
    data <- mtcars
    if (!is.null(selected_points())) {
      data <- mtcars[selected_points(), ]
    }

    plot_ly(
      data,
      x = ~wt,
      type = "histogram",
      nbinsx = 10
    ) |>
      layout(
        title = paste("Weight Distribution (n =", nrow(data), ")")
      )
  })

  # Histogram 2: HP distribution
  output$histogram2 <- renderPlotly({
    data <- mtcars
    if (!is.null(selected_points())) {
      data <- mtcars[selected_points(), ]
    }

    plot_ly(
      data,
      x = ~hp,
      type = "histogram",
      nbinsx = 10
    ) |>
      layout(
        title = paste("HP Distribution (n =", nrow(data), ")")
      )
  })
}

shinyApp(ui, server)
```

### Drill-Down Dashboard

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Drill-Down Dashboard"),
  fluidRow(
    column(12,
           actionButton("reset", "Reset View", class = "btn-primary"),
           hr()
    )
  ),
  fluidRow(
    column(12,
           h4(textOutput("current_level")),
           plotlyOutput("plot", height = "500px")
    )
  ),
  fluidRow(
    column(12,
           h4("Selected Data"),
           tableOutput("data_table")
    )
  )
)

server <- function(input, output, session) {
  # Navigation state
  drill_state <- reactiveValues(
    level = "overview",
    selected_cyl = NULL,
    selected_gear = NULL
  )

  # Current level text
  output$current_level <- renderText({
    if (drill_state$level == "overview") {
      "Overview: Click on a cylinder count to drill down"
    } else if (drill_state$level == "cylinder") {
      paste("Cylinder:", drill_state$selected_cyl,
            "- Click on a gear count to drill down")
    } else {
      paste("Cylinder:", drill_state$selected_cyl,
            "| Gears:", drill_state$selected_gear)
    }
  })

  # Main plot
  output$plot <- renderPlotly({
    if (drill_state$level == "overview") {
      # Level 1: Cylinders
      data <- mtcars |>
        group_by(cyl) |>
        summarise(
          count = n(),
          avg_mpg = mean(mpg)
        )

      plot_ly(
        data,
        x = ~factor(cyl),
        y = ~count,
        type = "bar",
        source = "main_plot",
        customdata = ~cyl,
        text = ~paste("Avg MPG:", round(avg_mpg, 1)),
        textposition = "outside"
      ) |>
        layout(
          title = "Cars by Cylinder Count",
          xaxis = list(title = "Cylinders"),
          yaxis = list(title = "Count")
        )

    } else if (drill_state$level == "cylinder") {
      # Level 2: Gears for selected cylinder
      data <- mtcars |>
        filter(cyl == drill_state$selected_cyl) |>
        group_by(gear) |>
        summarise(
          count = n(),
          avg_mpg = mean(mpg)
        )

      plot_ly(
        data,
        x = ~factor(gear),
        y = ~count,
        type = "bar",
        source = "main_plot",
        customdata = ~gear,
        text = ~paste("Avg MPG:", round(avg_mpg, 1)),
        textposition = "outside"
      ) |>
        layout(
          title = paste("Gears for", drill_state$selected_cyl, "Cylinder Cars"),
          xaxis = list(title = "Gears"),
          yaxis = list(title = "Count")
        )

    } else {
      # Level 3: Individual cars
      data <- mtcars |>
        filter(
          cyl == drill_state$selected_cyl,
          gear == drill_state$selected_gear
        ) |>
        mutate(car = rownames(.))

      plot_ly(
        data,
        x = ~wt,
        y = ~mpg,
        type = "scatter",
        mode = "markers+text",
        text = ~car,
        textposition = "top center",
        marker = list(size = 15)
      ) |>
        layout(
          title = paste(drill_state$selected_cyl, "Cyl,",
                       drill_state$selected_gear, "Gears"),
          xaxis = list(title = "Weight"),
          yaxis = list(title = "MPG")
        )
    }
  })

  # Handle clicks
  observeEvent(event_data("plotly_click", source = "main_plot"), {
    click <- event_data("plotly_click", source = "main_plot")

    if (drill_state$level == "overview") {
      drill_state$level <- "cylinder"
      drill_state$selected_cyl <- click$x

    } else if (drill_state$level == "cylinder") {
      drill_state$level <- "detail"
      drill_state$selected_gear <- click$x
    }
  })

  # Reset button
  observeEvent(input$reset, {
    drill_state$level <- "overview"
    drill_state$selected_cyl <- NULL
    drill_state$selected_gear <- NULL
  })

  # Data table
  output$data_table <- renderTable({
    if (drill_state$level == "overview") {
      mtcars |>
        group_by(cyl) |>
        summarise(
          Count = n(),
          `Avg MPG` = round(mean(mpg), 1),
          `Avg HP` = round(mean(hp), 0)
        )
    } else if (drill_state$level == "cylinder") {
      mtcars |>
        filter(cyl == drill_state$selected_cyl) |>
        group_by(gear) |>
        summarise(
          Count = n(),
          `Avg MPG` = round(mean(mpg), 1),
          `Avg HP` = round(mean(hp), 0)
        )
    } else {
      mtcars |>
        filter(
          cyl == drill_state$selected_cyl,
          gear == drill_state$selected_gear
        ) |>
        select(mpg, cyl, disp, hp, wt, gear)
    }
  })
}

shinyApp(ui, server)
```

### Multi-View Dashboard

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- navbarPage(
  "Multi-View Analytics",
  tabPanel("Overview",
    fluidRow(
      column(4, plotlyOutput("overview_bar")),
      column(4, plotlyOutput("overview_box")),
      column(4, plotlyOutput("overview_scatter"))
    ),
    hr(),
    fluidRow(
      column(12,
             h4("Summary Statistics"),
             tableOutput("summary_table"))
    )
  ),
  tabPanel("Detailed View",
    fluidRow(
      column(12,
             selectInput("detail_var", "Select Variable:",
                        choices = c("mpg", "hp", "wt", "qsec"))
      )
    ),
    fluidRow(
      column(6, plotlyOutput("detail_histogram")),
      column(6, plotlyOutput("detail_violin"))
    ),
    fluidRow(
      column(12, plotlyOutput("detail_scatter"))
    )
  )
)

server <- function(input, output, session) {
  # Shared selection
  selected_cyl <- reactiveVal(NULL)

  # Overview tab plots
  output$overview_bar <- renderPlotly({
    plot_ly(
      mtcars |> count(cyl),
      x = ~factor(cyl),
      y = ~n,
      type = "bar",
      source = "cyl_bar",
      customdata = ~cyl
    ) |>
      layout(title = "Cylinder Distribution")
  })

  observeEvent(event_data("plotly_click", source = "cyl_bar"), {
    click <- event_data("plotly_click", source = "cyl_bar")
    selected_cyl(as.numeric(click$x))
  })

  output$overview_box <- renderPlotly({
    data <- mtcars
    if (!is.null(selected_cyl())) {
      data <- data |> filter(cyl == selected_cyl())
    }

    plot_ly(data, y = ~mpg, type = "box", name = "MPG") |>
      layout(title = "MPG Distribution")
  })

  output$overview_scatter <- renderPlotly({
    data <- mtcars
    if (!is.null(selected_cyl())) {
      data <- data |> filter(cyl == selected_cyl())
    }

    plot_ly(
      data,
      x = ~wt,
      y = ~mpg,
      color = ~factor(cyl),
      type = "scatter",
      mode = "markers"
    ) |>
      layout(title = "Weight vs MPG")
  })

  output$summary_table <- renderTable({
    data <- mtcars
    if (!is.null(selected_cyl())) {
      data <- data |> filter(cyl == selected_cyl())
    }

    data |>
      summarise(
        N = n(),
        `Avg MPG` = round(mean(mpg), 1),
        `Avg HP` = round(mean(hp), 0),
        `Avg Weight` = round(mean(wt), 2)
      )
  })

  # Detailed view plots
  output$detail_histogram <- renderPlotly({
    data <- mtcars
    if (!is.null(selected_cyl())) {
      data <- data |> filter(cyl == selected_cyl())
    }

    plot_ly(
      data,
      x = ~get(input$detail_var),
      type = "histogram",
      nbinsx = 15
    ) |>
      layout(
        title = paste(input$detail_var, "Distribution"),
        xaxis = list(title = input$detail_var)
      )
  })

  output$detail_violin <- renderPlotly({
    data <- mtcars
    if (!is.null(selected_cyl())) {
      data <- data |> filter(cyl == selected_cyl())
    }

    plot_ly(
      data,
      y = ~get(input$detail_var),
      type = "violin",
      box = list(visible = TRUE),
      meanline = list(visible = TRUE)
    ) |>
      layout(
        title = paste(input$detail_var, "Violin Plot"),
        yaxis = list(title = input$detail_var)
      )
  })

  output$detail_scatter <- renderPlotly({
    data <- mtcars
    if (!is.null(selected_cyl())) {
      data <- data |> filter(cyl == selected_cyl())
    }

    plot_ly(
      data,
      x = ~wt,
      y = ~get(input$detail_var),
      color = ~factor(cyl),
      type = "scatter",
      mode = "markers",
      marker = list(size = 10)
    ) |>
      layout(
        title = paste("Weight vs", input$detail_var),
        yaxis = list(title = input$detail_var)
      )
  })
}

shinyApp(ui, server)
```

---

## Advanced Patterns

### Dynamic Trace Management

```r
library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel("Dynamic Trace Management"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "traces",
        "Select Traces:",
        choices = c("Sin" = "sin", "Cos" = "cos", "Tan" = "tan"),
        selected = c("sin", "cos")
      ),
      sliderInput("frequency", "Frequency:", 1, 5, 1),
      sliderInput("amplitude", "Amplitude:", 0.5, 2, 1, 0.1)
    ),
    mainPanel(
      plotlyOutput("dynamic_plot")
    )
  )
)

server <- function(input, output, session) {
  x <- seq(0, 4*pi, length.out = 100)

  # Track current traces
  current_traces <- reactiveVal(c("sin", "cos"))

  output$dynamic_plot <- renderPlotly({
    p <- plot_ly() |>
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "y", range = c(-2.5, 2.5))
      )

    # Add initial traces
    if ("sin" %in% input$traces) {
      p <- p |> add_trace(
        x = x,
        y = sin(input$frequency * x) * input$amplitude,
        type = "scatter",
        mode = "lines",
        name = "Sin",
        line = list(color = "blue")
      )
    }

    if ("cos" %in% input$traces) {
      p <- p |> add_trace(
        x = x,
        y = cos(input$frequency * x) * input$amplitude,
        type = "scatter",
        mode = "lines",
        name = "Cos",
        line = list(color = "red")
      )
    }

    if ("tan" %in% input$traces) {
      y_tan <- tan(input$frequency * x) * input$amplitude
      y_tan[abs(y_tan) > 2.5] <- NA  # Clip
      p <- p |> add_trace(
        x = x,
        y = y_tan,
        type = "scatter",
        mode = "lines",
        name = "Tan",
        line = list(color = "green")
      )
    }

    current_traces(input$traces)
    p
  })

  # Handle trace changes
  observe({
    req(input$frequency, input$amplitude)

    # Determine which traces to add/remove
    old_traces <- current_traces()
    new_traces <- input$traces

    to_add <- setdiff(new_traces, old_traces)
    to_remove <- setdiff(old_traces, new_traces)

    # Get current trace names
    # Note: This is simplified - in production, track trace indices

    current_traces(new_traces)
  })
}

shinyApp(ui, server)
```

### Custom JavaScript Integration

```r
library(shiny)
library(plotly)
library(htmlwidgets)

ui <- fluidPage(
  titlePanel("Custom JavaScript Events"),
  plotlyOutput("plot"),
  verbatimTextOutput("js_events"),
  tags$script(HTML("
    $(document).on('shiny:connected', function() {
      Shiny.addCustomMessageHandler('plotly-custom', function(message) {
        console.log('Custom message:', message);
      });
    });

    $(document).on('plotly_click', function(event, data) {
      Shiny.setInputValue('custom_click', {
        x: data.points[0].x,
        y: data.points[0].y,
        time: Date.now()
      });
    });
  "))
)

server <- function(input, output, session) {
  output$plot <- renderPlotly({
    plot_ly(
      mtcars,
      x = ~wt,
      y = ~mpg,
      type = "scatter",
      mode = "markers"
    ) |>
      onRender("
        function(el, x) {
          el.on('plotly_click', function(d) {
            var point = d.points[0];

            // Add annotation at clicked point
            Plotly.relayout(el, {
              annotations: [{
                x: point.x,
                y: point.y,
                text: 'Clicked!',
                showarrow: true,
                arrowhead: 2,
                ax: 0,
                ay: -40
              }]
            });

            // Remove after 2 seconds
            setTimeout(function() {
              Plotly.relayout(el, {annotations: []});
            }, 2000);
          });
        }
      ")
  })

  output$js_events <- renderPrint({
    req(input$custom_click)
    cat("Custom click event:\n")
    cat("X:", input$custom_click$x, "\n")
    cat("Y:", input$custom_click$y, "\n")
    cat("Time:", as.POSIXct(input$custom_click$time/1000, origin = "1970-01-01"), "\n")
  })
}

shinyApp(ui, server)
```

### Performance Optimization

```r
library(shiny)
library(plotly)
library(dplyr)

# Generate large dataset
large_data <- data.frame(
  x = rnorm(100000),
  y = rnorm(100000),
  category = sample(letters[1:5], 100000, replace = TRUE)
)

ui <- fluidPage(
  titlePanel("Performance Optimization"),
  sidebarLayout(
    sidebarPanel(
      selectInput("category", "Category:",
                  choices = c("All", letters[1:5])),
      sliderInput("sample_size", "Sample Size:",
                  100, 10000, 1000, 100),
      checkboxInput("use_webgl", "Use WebGL", TRUE)
    ),
    mainPanel(
      plotlyOutput("plot"),
      textOutput("render_time")
    )
  )
)

server <- function(input, output, session) {
  # Reactive filtered data
  filtered_data <- reactive({
    data <- large_data
    if (input$category != "All") {
      data <- data |> filter(category == input$category)
    }
    data
  })

  # Debounced sample size
  sample_size_debounced <- debounce(reactive(input$sample_size), 500)

  output$plot <- renderPlotly({
    start_time <- Sys.time()

    # Sample data
    data <- filtered_data() |>
      slice_sample(n = min(sample_size_debounced(), nrow(.)))

    # Use WebGL for large datasets
    plot_type <- if (input$use_webgl && nrow(data) > 1000) {
      "scattergl"
    } else {
      "scatter"
    }

    p <- plot_ly(
      data,
      x = ~x,
      y = ~y,
      color = ~category,
      type = plot_type,
      mode = "markers",
      marker = list(size = 5, opacity = 0.6)
    ) |>
      layout(
        showlegend = TRUE,
        hovermode = "closest"
      )

    end_time <- Sys.time()
    render_duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

    # Store for display
    session$userData$render_time <- render_duration

    p
  })

  output$render_time <- renderText({
    req(session$userData$render_time)
    paste("Render time:", round(session$userData$render_time, 3), "seconds")
  })
}

shinyApp(ui, server)
```

### Reactive Best Practices

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Reactive Best Practices"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset", "Dataset:",
                  choices = c("mtcars", "iris", "diamonds")),
      uiOutput("var_selector"),
      actionButton("update", "Update Plot", class = "btn-primary")
    ),
    mainPanel(
      plotlyOutput("plot"),
      verbatimTextOutput("computation_log")
    )
  )
)

server <- function(input, output, session) {
  # Computation log
  log_text <- reactiveVal("")

  add_log <- function(msg) {
    current <- log_text()
    new_log <- paste0(Sys.time(), " - ", msg, "\n", current)
    log_text(substr(new_log, 1, 1000))  # Keep last 1000 chars
  }

  # Reactive data source - cached
  data_source <- reactive({
    add_log(paste("Loading dataset:", input$dataset))

    switch(
      input$dataset,
      "mtcars" = mtcars,
      "iris" = iris,
      "diamonds" = {
        if (requireNamespace("ggplot2", quietly = TRUE)) {
          ggplot2::diamonds |> slice_sample(n = 1000)
        } else {
          mtcars
        }
      }
    )
  })

  # Dynamic UI for variable selection
  output$var_selector <- renderUI({
    data <- data_source()
    numeric_vars <- names(data)[sapply(data, is.numeric)]

    tagList(
      selectInput("xvar", "X Variable:", choices = numeric_vars),
      selectInput("yvar", "Y Variable:", choices = numeric_vars)
    )
  })

  # Processed data - only recalculates when button clicked
  processed_data <- eventReactive(input$update, {
    req(input$xvar, input$yvar)
    add_log("Processing data")

    data <- data_source()
    data |>
      select(x = all_of(input$xvar), y = all_of(input$yvar)) |>
      filter(!is.na(x), !is.na(y))
  })

  # Plot - only updates when processed_data changes
  output$plot <- renderPlotly({
    data <- processed_data()
    add_log(paste("Rendering plot with", nrow(data), "points"))

    plot_ly(
      data,
      x = ~x,
      y = ~y,
      type = "scatter",
      mode = "markers",
      marker = list(opacity = 0.6)
    ) |>
      layout(
        xaxis = list(title = input$xvar),
        yaxis = list(title = input$yvar)
      )
  })

  output$computation_log <- renderText({
    log_text()
  })
}

shinyApp(ui, server)
```

### Complete Production Example

```r
library(shiny)
library(plotly)
library(dplyr)
library(DT)

ui <- navbarPage(
  "Production Dashboard",
  theme = bslib::bs_theme(version = 5),

  tabPanel("Main",
    fluidRow(
      column(4,
        wellPanel(
          h4("Filters"),
          selectInput("cyl_filter", "Cylinders:",
                     choices = c("All", sort(unique(mtcars$cyl)))),
          sliderInput("mpg_range", "MPG Range:",
                     min = min(mtcars$mpg),
                     max = max(mtcars$mpg),
                     value = range(mtcars$mpg)),
          actionButton("apply_filters", "Apply",
                      class = "btn-primary btn-block")
        ),
        wellPanel(
          h4("Selection Info"),
          textOutput("selection_count"),
          actionButton("clear_selection", "Clear Selection")
        )
      ),
      column(8,
        plotlyOutput("main_scatter", height = "400px"),
        hr(),
        plotlyOutput("detail_bar", height = "300px")
      )
    )
  ),

  tabPanel("Data Table",
    fluidRow(
      column(12,
        h4("Filtered Data"),
        DTOutput("data_table")
      )
    )
  )
)

server <- function(input, output, session) {
  # Reactive values
  rv <- reactiveValues(
    filtered_data = mtcars,
    selected_indices = NULL
  )

  # Apply filters
  observeEvent(input$apply_filters, {
    data <- mtcars

    if (input$cyl_filter != "All") {
      data <- data |> filter(cyl == as.numeric(input$cyl_filter))
    }

    data <- data |>
      filter(mpg >= input$mpg_range[1], mpg <= input$mpg_range[2])

    rv$filtered_data <- data
    rv$selected_indices <- NULL
  })

  # Main scatter plot
  output$main_scatter <- renderPlotly({
    plot_ly(
      rv$filtered_data,
      x = ~wt,
      y = ~mpg,
      color = ~factor(cyl),
      colors = c("4" = "#1f77b4", "6" = "#ff7f0e", "8" = "#2ca02c"),
      type = "scatter",
      mode = "markers",
      source = "main_scatter",
      marker = list(size = 10, opacity = 0.7),
      text = ~paste("Car:", rownames(rv$filtered_data),
                   "<br>Weight:", wt,
                   "<br>MPG:", mpg,
                   "<br>Cyl:", cyl),
      hoverinfo = "text"
    ) |>
      layout(
        title = "Weight vs MPG",
        xaxis = list(title = "Weight (1000 lbs)"),
        yaxis = list(title = "Miles per Gallon"),
        dragmode = "select",
        legend = list(title = list(text = "Cylinders"))
      )
  })

  # Handle selection
  observeEvent(event_data("plotly_selected", source = "main_scatter"), {
    selected <- event_data("plotly_selected", source = "main_scatter")
    if (!is.null(selected)) {
      rv$selected_indices <- selected$pointNumber + 1
    }
  })

  # Clear selection
  observeEvent(input$clear_selection, {
    rv$selected_indices <- NULL
  })

  # Selection count
  output$selection_count <- renderText({
    if (is.null(rv$selected_indices)) {
      paste("Total points:", nrow(rv$filtered_data))
    } else {
      paste("Selected:", length(rv$selected_indices), "of",
            nrow(rv$filtered_data))
    }
  })

  # Detail bar chart
  output$detail_bar <- renderPlotly({
    data <- rv$filtered_data
    if (!is.null(rv$selected_indices)) {
      data <- data[rv$selected_indices, ]
    }

    summary_data <- data |>
      group_by(cyl) |>
      summarise(
        count = n(),
        avg_mpg = mean(mpg),
        avg_hp = mean(hp)
      )

    plot_ly(summary_data) |>
      add_bars(x = ~factor(cyl), y = ~count, name = "Count",
               marker = list(color = "#8884d8")) |>
      add_lines(x = ~factor(cyl), y = ~avg_mpg, name = "Avg MPG",
                yaxis = "y2", line = list(color = "#82ca9d", width = 3)) |>
      layout(
        title = "Summary by Cylinders",
        xaxis = list(title = "Cylinders"),
        yaxis = list(title = "Count"),
        yaxis2 = list(
          overlaying = "y",
          side = "right",
          title = "Avg MPG"
        ),
        hovermode = "x unified"
      )
  })

  # Data table
  output$data_table <- renderDT({
    data <- rv$filtered_data
    if (!is.null(rv$selected_indices)) {
      data <- data[rv$selected_indices, ]
    }

    datatable(
      data,
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ),
      rownames = TRUE
    )
  })
}

shinyApp(ui, server)
```
