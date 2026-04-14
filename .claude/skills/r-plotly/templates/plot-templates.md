# Plotly Plot Templates

Copy-paste ready templates for common plotly visualizations in R. Replace placeholders with your actual data and variables.

## How to Use These Templates

1. **Placeholders**: Replace ALL_CAPS words with your actual values:
   - `DATA` → your data frame name
   - `X_VAR`, `Y_VAR`, `Z_VAR` → column names (unquoted)
   - `COLOR_VAR`, `SIZE_VAR` → grouping/sizing columns
   - `"Title Text"` → your custom text

2. **Comments**: Lines starting with `#` explain options - remove or uncomment as needed

3. **Pipe Syntax**: Templates use native pipe `|>` (R ≥ 4.1)

4. **Common Modifications**:
   - Colors: Change `colors = "Set1"` or use `c("red", "blue", ...)`
   - Hover: Customize `hovertemplate` for different tooltip content
   - Layout: Adjust `layout()` for titles, axes, legends
   - Export: Add `config(toImageButtonOptions = list(format = "png"))` for downloads

---

## Scatter Plots (5 variations)

### 1. Basic Scatter
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  type = "scatter",
  mode = "markers",
  marker = list(
    size = 8,
    color = "#1f77b4",
    opacity = 0.7
  ),
  hovertemplate = paste0(
    "<b>X:</b> %{x}<br>",
    "<b>Y:</b> %{y}<extra></extra>"
  )
) |>
  layout(
    title = "Scatter Plot Title",
    xaxis = list(title = "X Axis Label"),
    yaxis = list(title = "Y Axis Label"),
    hovermode = "closest"
  )
```

### 2. Grouped Scatter (by color)
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  color = ~COLOR_VAR,
  colors = "Set1",  # or c("red", "blue", "green")
  type = "scatter",
  mode = "markers",
  marker = list(size = 10, opacity = 0.6),
  hovertemplate = paste0(
    "<b>Group:</b> %{fullData.name}<br>",
    "<b>X:</b> %{x}<br>",
    "<b>Y:</b> %{y}<extra></extra>"
  )
) |>
  layout(
    title = "Grouped Scatter Plot",
    xaxis = list(title = "X Axis"),
    yaxis = list(title = "Y Axis"),
    legend = list(title = list(text = "Legend Title"))
  )
```

### 3. Bubble Chart (size variation)
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  size = ~SIZE_VAR,
  color = ~COLOR_VAR,
  colors = "Viridis",
  type = "scatter",
  mode = "markers",
  marker = list(
    sizemode = "diameter",
    sizeref = 2,  # Adjust to scale bubble sizes
    opacity = 0.6,
    line = list(width = 1, color = "#FFFFFF")
  ),
  text = ~paste("Label:", LABEL_VAR),
  hovertemplate = paste0(
    "<b>%{text}</b><br>",
    "X: %{x}<br>",
    "Y: %{y}<br>",
    "Size: %{marker.size:,.0f}<extra></extra>"
  )
) |>
  layout(
    title = "Bubble Chart",
    xaxis = list(title = "X Axis"),
    yaxis = list(title = "Y Axis")
  )
```

### 4. Scatter with Smooth Line
```r
plot_ly(data = DATA) |>
  add_markers(
    x = ~X_VAR,
    y = ~Y_VAR,
    marker = list(color = "#1f77b4", size = 8, opacity = 0.6),
    name = "Data Points",
    hovertemplate = "X: %{x}<br>Y: %{y}<extra></extra>"
  ) |>
  add_lines(
    x = ~X_VAR,
    y = fitted(loess(Y_VAR ~ X_VAR, data = DATA)),  # or use your fitted values
    line = list(color = "#ff7f0e", width = 3),
    name = "Smooth Line",
    hoverinfo = "skip"
  ) |>
  layout(
    title = "Scatter with Trend Line",
    xaxis = list(title = "X Axis"),
    yaxis = list(title = "Y Axis"),
    showlegend = TRUE
  )
```

### 5. 3D Scatter
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  z = ~Z_VAR,
  color = ~COLOR_VAR,
  colors = "Spectral",
  type = "scatter3d",
  mode = "markers",
  marker = list(size = 5, opacity = 0.7),
  hovertemplate = paste0(
    "<b>Group:</b> %{fullData.name}<br>",
    "X: %{x}<br>",
    "Y: %{y}<br>",
    "Z: %{z}<extra></extra>"
  )
) |>
  layout(
    title = "3D Scatter Plot",
    scene = list(
      xaxis = list(title = "X Axis"),
      yaxis = list(title = "Y Axis"),
      zaxis = list(title = "Z Axis")
    )
  )
```

---

## Line Plots (4 variations)

### 6. Simple Line Plot
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  type = "scatter",
  mode = "lines",
  line = list(color = "#1f77b4", width = 2),
  hovertemplate = "X: %{x}<br>Y: %{y:.2f}<extra></extra>"
) |>
  layout(
    title = "Line Plot Title",
    xaxis = list(title = "X Axis"),
    yaxis = list(title = "Y Axis"),
    hovermode = "x unified"
  )
```

### 7. Multiple Line Series
```r
plot_ly(data = DATA) |>
  add_lines(
    x = ~X_VAR,
    y = ~Y_VAR1,
    name = "Series 1",
    line = list(color = "#1f77b4", width = 2),
    hovertemplate = "Series 1: %{y:.2f}<extra></extra>"
  ) |>
  add_lines(
    x = ~X_VAR,
    y = ~Y_VAR2,
    name = "Series 2",
    line = list(color = "#ff7f0e", width = 2),
    hovertemplate = "Series 2: %{y:.2f}<extra></extra>"
  ) |>
  add_lines(
    x = ~X_VAR,
    y = ~Y_VAR3,
    name = "Series 3",
    line = list(color = "#2ca02c", width = 2),
    hovertemplate = "Series 3: %{y:.2f}<extra></extra>"
  ) |>
  layout(
    title = "Multiple Time Series",
    xaxis = list(title = "Time"),
    yaxis = list(title = "Value"),
    hovermode = "x unified",
    legend = list(x = 0.02, y = 0.98)
  )
```

### 8. Area Chart
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  type = "scatter",
  mode = "lines",
  fill = "tozeroy",  # or "tonexty" for stacked areas
  fillcolor = "rgba(31, 119, 180, 0.3)",
  line = list(color = "#1f77b4", width = 2),
  hovertemplate = "X: %{x}<br>Y: %{y:,.0f}<extra></extra>"
) |>
  layout(
    title = "Area Chart",
    xaxis = list(title = "X Axis"),
    yaxis = list(title = "Y Axis", rangemode = "tozero"),
    hovermode = "x unified"
  )
```

### 9. Time Series with Range Slider
```r
plot_ly(
  data = DATA,
  x = ~DATE_VAR,  # Must be Date or POSIXct
  y = ~Y_VAR,
  type = "scatter",
  mode = "lines",
  line = list(color = "#1f77b4", width = 2),
  hovertemplate = "%{x|%Y-%m-%d}<br>Value: %{y:,.2f}<extra></extra>"
) |>
  layout(
    title = "Time Series with Slider",
    xaxis = list(
      title = "Date",
      rangeslider = list(visible = TRUE),
      rangeselector = list(
        buttons = list(
          list(count = 1, label = "1m", step = "month", stepmode = "backward"),
          list(count = 6, label = "6m", step = "month", stepmode = "backward"),
          list(count = 1, label = "YTD", step = "year", stepmode = "todate"),
          list(count = 1, label = "1y", step = "year", stepmode = "backward"),
          list(step = "all", label = "All")
        )
      )
    ),
    yaxis = list(title = "Value"),
    hovermode = "x unified"
  )
```

---

## Bar Charts (6 variations)

### 10. Simple Bar Chart
```r
plot_ly(
  data = DATA,
  x = ~CATEGORY_VAR,
  y = ~VALUE_VAR,
  type = "bar",
  marker = list(
    color = "#1f77b4",
    line = list(color = "#000000", width = 1)
  ),
  hovertemplate = "<b>%{x}</b><br>Value: %{y:,.0f}<extra></extra>"
) |>
  layout(
    title = "Bar Chart Title",
    xaxis = list(title = "Categories"),
    yaxis = list(title = "Values"),
    bargap = 0.2
  )
```

### 11. Grouped Bar Chart
```r
plot_ly(
  data = DATA,
  x = ~CATEGORY_VAR,
  y = ~VALUE_VAR,
  color = ~GROUP_VAR,
  colors = "Set1",
  type = "bar",
  hovertemplate = paste0(
    "<b>%{x}</b><br>",
    "Group: %{fullData.name}<br>",
    "Value: %{y:,.0f}<extra></extra>"
  )
) |>
  layout(
    title = "Grouped Bar Chart",
    xaxis = list(title = "Categories"),
    yaxis = list(title = "Values"),
    barmode = "group",
    bargap = 0.15,
    bargroupgap = 0.1,
    legend = list(title = list(text = "Groups"))
  )
```

### 12. Stacked Bar Chart
```r
plot_ly(
  data = DATA,
  x = ~CATEGORY_VAR,
  y = ~VALUE_VAR,
  color = ~GROUP_VAR,
  colors = "Pastel1",
  type = "bar",
  hovertemplate = paste0(
    "<b>%{x}</b><br>",
    "%{fullData.name}: %{y:,.0f}<extra></extra>"
  )
) |>
  layout(
    title = "Stacked Bar Chart",
    xaxis = list(title = "Categories"),
    yaxis = list(title = "Total Values"),
    barmode = "stack",
    legend = list(title = list(text = "Components"))
  )
```

### 13. Horizontal Bar Chart
```r
plot_ly(
  data = DATA |> arrange(VALUE_VAR),  # Sort for better visualization
  y = ~CATEGORY_VAR,
  x = ~VALUE_VAR,
  type = "bar",
  orientation = "h",
  marker = list(
    color = ~VALUE_VAR,
    colorscale = "Viridis",
    showscale = TRUE,
    colorbar = list(title = "Value")
  ),
  hovertemplate = "<b>%{y}</b><br>Value: %{x:,.0f}<extra></extra>"
) |>
  layout(
    title = "Horizontal Bar Chart",
    xaxis = list(title = "Values"),
    yaxis = list(title = "Categories", categoryorder = "trace"),
    margin = list(l = 150)  # Adjust for long labels
  )
```

### 14. Bar Chart with Error Bars
```r
plot_ly(
  data = DATA,
  x = ~CATEGORY_VAR,
  y = ~MEAN_VAR,
  type = "bar",
  error_y = list(
    type = "data",
    array = ~SD_VAR,  # or SE_VAR for standard error
    color = "#000000",
    thickness = 1.5,
    width = 4
  ),
  marker = list(color = "#1f77b4"),
  hovertemplate = paste0(
    "<b>%{x}</b><br>",
    "Mean: %{y:.2f}<br>",
    "SD: %{error_y.array:.2f}<extra></extra>"
  )
) |>
  layout(
    title = "Bar Chart with Error Bars",
    xaxis = list(title = "Categories"),
    yaxis = list(title = "Mean Value")
  )
```

### 15. Waterfall Chart
```r
# Prepare data with measure type: "relative", "total", or "absolute"
plot_ly(
  data = DATA,
  x = ~CATEGORY_VAR,
  y = ~VALUE_VAR,
  type = "waterfall",
  measure = ~MEASURE_VAR,  # Column with "relative", "total", or "absolute"
  connector = list(line = list(color = "rgb(63, 63, 63)")),
  increasing = list(marker = list(color = "#2ca02c")),
  decreasing = list(marker = list(color = "#d62728")),
  totals = list(marker = list(color = "#1f77b4")),
  hovertemplate = "<b>%{x}</b><br>Change: %{y:,.0f}<extra></extra>"
) |>
  layout(
    title = "Waterfall Chart",
    xaxis = list(title = "Categories"),
    yaxis = list(title = "Value"),
    showlegend = TRUE
  )
```

---

## Distribution Plots (4 variations)

### 16. Histogram
```r
plot_ly(
  data = DATA,
  x = ~NUMERIC_VAR,
  type = "histogram",
  nbinsx = 30,  # Adjust number of bins
  marker = list(
    color = "#1f77b4",
    line = list(color = "#FFFFFF", width = 1)
  ),
  hovertemplate = "Range: %{x}<br>Count: %{y}<extra></extra>"
) |>
  layout(
    title = "Histogram",
    xaxis = list(title = "Value"),
    yaxis = list(title = "Frequency"),
    bargap = 0.05
  )
```

### 17. Box Plot
```r
plot_ly(
  data = DATA,
  y = ~NUMERIC_VAR,
  x = ~GROUP_VAR,  # Optional: for grouped box plots
  color = ~GROUP_VAR,
  colors = "Set2",
  type = "box",
  boxmean = "sd",  # Show mean and SD; use TRUE for just mean
  hovertemplate = paste0(
    "<b>%{x}</b><br>",
    "Median: %{median:.2f}<br>",
    "Q1: %{q1:.2f}<br>",
    "Q3: %{q3:.2f}<extra></extra>"
  )
) |>
  layout(
    title = "Box Plot Distribution",
    xaxis = list(title = "Groups"),
    yaxis = list(title = "Value"),
    showlegend = FALSE
  )
```

### 18. Violin Plot
```r
plot_ly(
  data = DATA,
  y = ~NUMERIC_VAR,
  x = ~GROUP_VAR,
  color = ~GROUP_VAR,
  colors = "Pastel1",
  type = "violin",
  box = list(visible = TRUE),  # Show box plot inside
  meanline = list(visible = TRUE),
  opacity = 0.6,
  hovertemplate = "Value: %{y:.2f}<extra></extra>"
) |>
  layout(
    title = "Violin Plot Distribution",
    xaxis = list(title = "Groups"),
    yaxis = list(title = "Value"),
    showlegend = FALSE,
    violingap = 0.3,
    violinmode = "group"
  )
```

### 19. 2D Histogram (Heatmap)
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  type = "histogram2d",
  colorscale = "Viridis",
  nbinsx = 30,
  nbinsy = 30,
  hovertemplate = "X: %{x}<br>Y: %{y}<br>Count: %{z}<extra></extra>"
) |>
  layout(
    title = "2D Histogram",
    xaxis = list(title = "X Variable"),
    yaxis = list(title = "Y Variable")
  ) |>
  colorbar(title = "Count")
```

---

## Map Visualizations (3 variations)

### 20. Choropleth Map
```r
# Requires geographic data with location codes (e.g., state abbreviations, country codes)
plot_ly(
  data = DATA,
  type = "choropleth",
  locations = ~LOCATION_CODE,  # e.g., state abbreviations "CA", "NY"
  locationmode = "USA-states",  # or "country names", "ISO-3"
  z = ~VALUE_VAR,
  text = ~HOVER_TEXT,
  colorscale = "Viridis",
  reversescale = FALSE,
  hovertemplate = paste0(
    "<b>%{text}</b><br>",
    "Value: %{z:,.0f}<extra></extra>"
  )
) |>
  layout(
    title = "Choropleth Map",
    geo = list(
      scope = "usa",  # or "world", "europe", etc.
      projection = list(type = "albers usa"),
      showlakes = TRUE,
      lakecolor = toRGB("white")
    )
  ) |>
  colorbar(title = "Value")
```

### 21. Scatter Geo Map
```r
plot_ly(
  data = DATA,
  type = "scattergeo",
  lon = ~LONGITUDE,
  lat = ~LATITUDE,
  text = ~LABEL_VAR,
  mode = "markers",
  marker = list(
    size = ~SIZE_VAR,
    color = ~COLOR_VAR,
    colorscale = "Portland",
    sizemode = "diameter",
    sizeref = 2,
    line = list(width = 0.5, color = "white"),
    showscale = TRUE,
    colorbar = list(title = "Value")
  ),
  hovertemplate = paste0(
    "<b>%{text}</b><br>",
    "Lat: %{lat:.4f}<br>",
    "Lon: %{lon:.4f}<br>",
    "Value: %{marker.color:,.0f}<extra></extra>"
  )
) |>
  layout(
    title = "Scatter Geographic Map",
    geo = list(
      scope = "usa",  # or "world"
      projection = list(type = "albers usa"),
      showland = TRUE,
      landcolor = toRGB("gray95"),
      coastlinecolor = toRGB("gray80")
    )
  )
```

### 22. Bubble Map
```r
plot_ly(
  data = DATA,
  type = "scattergeo",
  lon = ~LONGITUDE,
  lat = ~LATITUDE,
  text = ~paste(LOCATION_NAME, "<br>Population:", POPULATION),
  mode = "markers",
  marker = list(
    size = ~sqrt(SIZE_VAR),  # Square root for better visual scaling
    color = ~CATEGORY_VAR,
    colors = "Set1",
    sizemode = "diameter",
    sizeref = 0.1,
    opacity = 0.6,
    line = list(width = 1, color = "white")
  ),
  hovertemplate = "%{text}<extra></extra>"
) |>
  layout(
    title = "Bubble Map",
    geo = list(
      scope = "world",
      projection = list(type = "natural earth"),
      showland = TRUE,
      landcolor = toRGB("gray90"),
      coastlinecolor = toRGB("gray60"),
      showocean = TRUE,
      oceancolor = toRGB("lightblue")
    ),
    legend = list(title = list(text = "Category"))
  )
```

---

## 3D Plots (2 variations)

### 23. 3D Surface Plot
```r
# Requires matrix or grid data
# Convert data frame to matrix if needed: z_matrix <- acast(DATA, X_VAR ~ Y_VAR, value.var = "Z_VAR")
plot_ly(
  z = ~Z_MATRIX,  # Matrix of z values
  type = "surface",
  colorscale = "Viridis",
  hovertemplate = "X: %{x}<br>Y: %{y}<br>Z: %{z:.2f}<extra></extra>"
) |>
  layout(
    title = "3D Surface Plot",
    scene = list(
      xaxis = list(title = "X Axis"),
      yaxis = list(title = "Y Axis"),
      zaxis = list(title = "Z Axis"),
      camera = list(
        eye = list(x = 1.5, y = 1.5, z = 1.5)
      )
    )
  ) |>
  colorbar(title = "Z Value")
```

### 24. Enhanced 3D Scatter with Projections
```r
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  z = ~Z_VAR,
  color = ~COLOR_VAR,
  colors = "Spectral",
  type = "scatter3d",
  mode = "markers",
  marker = list(
    size = 5,
    opacity = 0.8,
    line = list(width = 0.5, color = "white")
  ),
  hovertemplate = paste0(
    "<b>Group:</b> %{fullData.name}<br>",
    "X: %{x:.2f}<br>",
    "Y: %{y:.2f}<br>",
    "Z: %{z:.2f}<extra></extra>"
  )
) |>
  layout(
    title = "3D Scatter with Projections",
    scene = list(
      xaxis = list(title = "X Axis", showspikes = FALSE),
      yaxis = list(title = "Y Axis", showspikes = FALSE),
      zaxis = list(title = "Z Axis", showspikes = FALSE),
      camera = list(
        eye = list(x = 1.25, y = 1.25, z = 1.25),
        projection = list(type = "orthographic")  # or "perspective"
      )
    )
  )
```

---

## Animated Plots (3 variations)

### 25. Frame-Based Animation
```r
# Data must have a FRAME_VAR column (e.g., year, time step)
plot_ly(
  data = DATA,
  x = ~X_VAR,
  y = ~Y_VAR,
  size = ~SIZE_VAR,
  color = ~COLOR_VAR,
  colors = "Set1",
  frame = ~FRAME_VAR,
  text = ~LABEL_VAR,
  type = "scatter",
  mode = "markers",
  marker = list(
    sizemode = "diameter",
    sizeref = 1,
    opacity = 0.7,
    line = list(width = 1, color = "white")
  ),
  hovertemplate = paste0(
    "<b>%{text}</b><br>",
    "X: %{x:.2f}<br>",
    "Y: %{y:.2f}<br>",
    "Size: %{marker.size:,.0f}<extra></extra>"
  )
) |>
  layout(
    title = "Animated Scatter Plot",
    xaxis = list(title = "X Axis", range = c(MIN_X, MAX_X)),  # Fixed range
    yaxis = list(title = "Y Axis", range = c(MIN_Y, MAX_Y))
  ) |>
  animation_opts(
    frame = 1000,  # 1000ms per frame
    transition = 500,  # 500ms transition
    redraw = FALSE
  ) |>
  animation_slider(
    currentvalue = list(prefix = "Year: ", font = list(color = "black"))
  )
```

### 26. Racing Bar Chart
```r
# Data must have FRAME_VAR and be arranged properly
plot_ly(
  data = DATA,
  y = ~reorder(CATEGORY_VAR, VALUE_VAR),  # Sort by value
  x = ~VALUE_VAR,
  frame = ~FRAME_VAR,
  type = "bar",
  orientation = "h",
  marker = list(
    color = ~CATEGORY_VAR,
    colors = "Set3"
  ),
  text = ~VALUE_VAR,
  textposition = "outside",
  hovertemplate = "<b>%{y}</b><br>Value: %{x:,.0f}<extra></extra>"
) |>
  layout(
    title = "Racing Bar Chart",
    xaxis = list(title = "Value", range = c(0, MAX_VALUE * 1.1)),
    yaxis = list(title = "", categoryorder = "trace"),
    showlegend = FALSE,
    margin = list(l = 150)
  ) |>
  animation_opts(
    frame = 500,
    transition = 300,
    redraw = TRUE  # Important for racing bars
  ) |>
  animation_slider(
    currentvalue = list(prefix = "Period: ")
  ) |>
  animation_button(
    x = 1, xanchor = "right",
    y = 0, yanchor = "bottom"
  )
```

### 27. Animation with Trails
```r
plot_ly(data = DATA) |>
  add_markers(
    x = ~X_VAR,
    y = ~Y_VAR,
    frame = ~FRAME_VAR,
    ids = ~ID_VAR,  # Important: unique identifier for each point
    marker = list(size = 10, color = ~COLOR_VAR, colors = "Set1"),
    showlegend = TRUE,
    hovertemplate = paste0(
      "<b>%{fullData.name}</b><br>",
      "X: %{x:.2f}<br>",
      "Y: %{y:.2f}<extra></extra>"
    )
  ) |>
  add_lines(
    x = ~X_VAR,
    y = ~Y_VAR,
    frame = ~FRAME_VAR,
    ids = ~ID_VAR,
    color = ~COLOR_VAR,
    colors = "Set1",
    line = list(width = 1),
    showlegend = FALSE,
    hoverinfo = "skip"
  ) |>
  layout(
    title = "Animation with Movement Trails",
    xaxis = list(title = "X Axis"),
    yaxis = list(title = "Y Axis")
  ) |>
  animation_opts(
    frame = 500,
    transition = 400,
    redraw = FALSE,
    mode = "next"  # Show accumulated traces
  )
```

---

## Shiny Integration (3 variations)

### 28. Basic Shiny Integration
```r
# ui.R or UI section
fluidPage(
  titlePanel("Plotly in Shiny"),
  sidebarLayout(
    sidebarPanel(
      selectInput("variable", "Select Variable:",
                  choices = c("VAR1", "VAR2", "VAR3")),
      sliderInput("bins", "Number of Bins:",
                  min = 10, max = 50, value = 30)
    ),
    mainPanel(
      plotlyOutput("distPlot", height = "600px")
    )
  )
)

# server.R or server section
server <- function(input, output, session) {
  output$distPlot <- renderPlotly({
    plot_ly(
      data = DATA,
      x = ~get(input$variable),  # Dynamic variable selection
      type = "histogram",
      nbinsx = input$bins,
      marker = list(
        color = "#1f77b4",
        line = list(color = "white", width = 1)
      )
    ) |>
      layout(
        title = paste("Distribution of", input$variable),
        xaxis = list(title = input$variable),
        yaxis = list(title = "Frequency")
      )
  })
}
```

### 29. Shiny with Plotly Events
```r
# Capture click events from plotly
ui <- fluidPage(
  titlePanel("Interactive Plotly with Events"),
  fluidRow(
    column(6, plotlyOutput("scatterPlot")),
    column(6, verbatimTextOutput("clickInfo"))
  )
)

server <- function(input, output, session) {
  output$scatterPlot <- renderPlotly({
    plot_ly(
      data = DATA,
      x = ~X_VAR,
      y = ~Y_VAR,
      type = "scatter",
      mode = "markers",
      marker = list(size = 10),
      source = "scatterSource"  # Important: name the source
    ) |>
      layout(
        title = "Click on Points",
        xaxis = list(title = "X Variable"),
        yaxis = list(title = "Y Variable")
      )
  })

  # Capture click events
  output$clickInfo <- renderPrint({
    event_data <- event_data("plotly_click", source = "scatterSource")
    if (is.null(event_data)) {
      "Click on a point to see details"
    } else {
      list(
        x_value = event_data$x,
        y_value = event_data$y,
        point_number = event_data$pointNumber
      )
    }
  })
}
```

### 30. Shiny with PlotlyProxy (Update Without Redraw)
```r
# Efficient updates using plotlyProxy
ui <- fluidPage(
  titlePanel("Efficient Plotly Updates"),
  sidebarLayout(
    sidebarPanel(
      actionButton("addPoint", "Add Random Point"),
      actionButton("resetPlot", "Reset Plot")
    ),
    mainPanel(
      plotlyOutput("proxyPlot")
    )
  )
)

server <- function(input, output, session) {
  # Reactive values to store data
  rv <- reactiveValues(
    data = data.frame(x = rnorm(20), y = rnorm(20))
  )

  # Initial plot
  output$proxyPlot <- renderPlotly({
    plot_ly(
      data = rv$data,
      x = ~x,
      y = ~y,
      type = "scatter",
      mode = "markers",
      marker = list(size = 10, color = "#1f77b4")
    ) |>
      layout(
        title = "Dynamic Updates with PlotlyProxy",
        xaxis = list(title = "X", range = c(-3, 3)),
        yaxis = list(title = "Y", range = c(-3, 3))
      )
  })

  # Add point using plotlyProxy (efficient)
  observeEvent(input$addPoint, {
    new_point <- data.frame(x = rnorm(1), y = rnorm(1))
    rv$data <- rbind(rv$data, new_point)

    plotlyProxy("proxyPlot", session) |>
      plotlyProxyInvoke(
        "addTraces",
        list(
          x = new_point$x,
          y = new_point$y,
          type = "scatter",
          mode = "markers",
          marker = list(size = 10, color = "#ff7f0e")
        )
      )
  })

  # Reset plot
  observeEvent(input$resetPlot, {
    rv$data <- data.frame(x = rnorm(20), y = rnorm(20))
  })
}
```

---

## Advanced Customization Tips

### Custom Color Scales
```r
# Continuous color scale
marker = list(
  color = ~VALUE_VAR,
  colorscale = list(
    c(0, "#440154"),
    c(0.5, "#31688e"),
    c(1, "#fde725")
  ),
  showscale = TRUE
)

# Discrete colors
colors = c("Group1" = "#e41a1c", "Group2" = "#377eb8", "Group3" = "#4daf4a")
```

### Custom Hover Templates
```r
hovertemplate = paste0(
  "<b style='font-size:14px'>%{text}</b><br>",
  "<i>Category: %{x}</i><br>",
  "Value: <b>%{y:,.2f}</b><br>",
  "Percentage: %{customdata[0]:.1%}",
  "<extra></extra>"  # Removes secondary box
)
```

### Multiple Y-Axes
```r
plot_ly(data = DATA) |>
  add_lines(x = ~X_VAR, y = ~Y1_VAR, name = "Series 1", yaxis = "y") |>
  add_lines(x = ~X_VAR, y = ~Y2_VAR, name = "Series 2", yaxis = "y2") |>
  layout(
    yaxis = list(title = "Y1 Axis"),
    yaxis2 = list(
      title = "Y2 Axis",
      overlaying = "y",
      side = "right"
    )
  )
```

### Subplots
```r
subplot(
  plot_ly(DATA, x = ~X_VAR, y = ~Y1_VAR, type = "scatter", mode = "lines"),
  plot_ly(DATA, x = ~X_VAR, y = ~Y2_VAR, type = "bar"),
  nrows = 2,
  shareX = TRUE,
  titleY = TRUE
) |>
  layout(title = "Combined Subplots")
```

---

## Export & Configuration

### Save as HTML
```r
p <- plot_ly(...)  # Your plot
htmlwidgets::saveWidget(p, "plot.html", selfcontained = TRUE)
```

### Save as Static Image
```r
# Requires kaleido package: install.packages("kaleido")
save_image(p, "plot.png", width = 1200, height = 800)
```

### Enable Download Button
```r
plot_ly(...) |>
  config(
    toImageButtonOptions = list(
      format = "png",  # or "svg", "jpeg"
      filename = "custom_plot",
      width = 1200,
      height = 800
    )
  )
```

### Disable Interaction
```r
plot_ly(...) |>
  config(
    displayModeBar = FALSE,  # Hide toolbar
    staticPlot = TRUE  # Disable all interactions
  )
```
