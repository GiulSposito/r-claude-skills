# Quarto Dashboards - Complete Reference

Comprehensive guide to creating interactive data dashboards with Quarto and R.

## Table of Contents

1. [Overview](#overview)
2. [Basic Structure](#basic-structure)
3. [Layout Patterns](#layout-patterns)
4. [Data Display Components](#data-display-components)
5. [Interactivity](#interactivity)
6. [Theming & Styling](#theming--styling)
7. [Navigation](#navigation)
8. [Deployment](#deployment)
9. [Advanced Patterns](#advanced-patterns)
10. [Best Practices](#best-practices)

---

## Overview

Quarto Dashboards enable creation of interactive data visualization interfaces with flexible, responsive layouts. They automatically adapt to different screen sizes and support both static and dynamic (Shiny) interactivity.

**Key Features:**
- Automatic responsive layouts (rows/columns)
- Value boxes for KPIs and metrics
- Integration with R visualization packages
- Optional Shiny for real-time interactivity
- Multi-page navigation
- Customizable themes

**Basic Dashboard:**
```yaml
---
title: "My Dashboard"
format: dashboard
---
```

**Requirements:**
- Quarto v1.4+
- R packages: `bslib`, `bsicons` (for value boxes)
- Optional: `shiny` (for interactivity)

---

## Basic Structure

### Hierarchy

Dashboards organize content through:
- **Pages** (Level 1 headings `#`) - Top-level navigation
- **Rows/Columns** (Level 2 headings `##`) - Layout sections
- **Tabsets** - Further subdivisions with `.tabset` class
- **Cards** - Container units (created from R chunks)

### Minimal Dashboard

```yaml
---
title: "Sales Dashboard"
format: dashboard
---

## Row

```{r}
#| title: "Monthly Revenue"
library(ggplot2)
ggplot(data, aes(x = month, y = revenue)) + geom_col()
```

```{r}
#| title: "Top Products"
knitr::kable(top_products)
```
```

Each R chunk automatically becomes a **card** with optional title.

---

## Layout Patterns

### Orientation Modes

**Row-First (Default):**
Level 2 headings create horizontal rows; chunks within create columns.

```yaml
---
title: "Dashboard"
format: dashboard
---

## Row {height=60%}

```{r}
# Left chart
```

```{r}
# Right chart
```

## Row {height=40%}

```{r}
# Bottom chart spans full width
```
```

**Column-First:**
Level 2 headings create vertical columns; chunks within create rows.

```yaml
---
title: "Dashboard"
format:
  dashboard:
    orientation: columns
---

## Column {width=30%}

```{r}
# Sidebar content
```

## Column {width=70%}

```{r}
# Main content
```
```

### Sizing Patterns

**Relative Sizing:**
Use percentages to control proportions:

```markdown
## Row {height=70%}
## Row {height=30%}

## Column {width=25%}
## Column {width=75%}
```

**Pixel Sizing:**
Use fixed pixels for specific dimensions:

```markdown
## Row {height=500px}
```

**Auto Sizing:**
Omit size attributes for equal distribution:

```markdown
## Row
## Row
```

### Fill vs. Flow Layouts

**Fill (Default):**
Content expands to fill available space. Best for plots and tables.

```markdown
## Row {.fill}
```

**Flow:**
Content uses natural height. Best for markdown text and value boxes.

```markdown
## Row {.flow}
```

### Scrolling

**Page-Level Scrolling:**
```yaml
format:
  dashboard:
    scrolling: true
```

**Section-Level Scrolling:**
```markdown
## Row {scrolling=true}
```

Enable scrolling to display more content without multiple pages.

### Tabsets

Create tabbed interfaces for organized navigation:

```markdown
## Row {.tabset}

```{r}
#| title: "Chart View"
plot(data)
```

```{r}
#| title: "Table View"
knitr::kable(data)
```

```{r}
#| title: "Summary"
summary(data)
```
```

**Nested Tabsets:**
```markdown
## Column {.tabset}

### Tab 1

#### Row {.tabset}

```{r}
#| title: "Nested Tab A"
```

```{r}
#| title: "Nested Tab B"
```
```

---

## Data Display Components

### Value Boxes

Display key metrics with icons and colors.

**Basic Value Box:**
```r
```{r}
library(bslib)
library(bsicons)

value_box(
  title = "Total Sales",
  value = "$1.2M",
  showcase = bs_icon("cash-coin"),
  theme = "primary"
)
```
```

**Alternative Syntax (YAML-style):**
```r
```{r}
#| content: valuebox
#| title: "Total Sales"
#| icon: "cash-coin"
#| color: "primary"

list(value = "$1.2M")
```
```

**Available Themes:**
- `primary` - Blue
- `secondary` - Gray
- `success` - Green
- `info` - Light blue
- `warning` - Orange/Yellow
- `danger` - Red
- `light` - White
- `dark` - Black

**Icon Sources:**
- `bs_icon("name")` - Bootstrap Icons (2,000+ icons)
- Browse: https://icons.getbootstrap.com/

**Advanced Value Box:**
```r
```{r}
library(bslib)
library(bsicons)

value_box(
  title = "Customer Growth",
  value = textOutput("growth_value"),  # Dynamic with Shiny
  showcase = bs_icon("graph-up-arrow"),
  theme = value_box_theme(bg = "#3498db", fg = "white"),
  p(class = "fs-6", "↑ 23% from last month"),
  p(class = "fs-6", "Target: 50% by Q4")
)
```
```

### Cards

Cards are automatically created from R chunks. Customize with chunk options:

```r
```{r}
#| title: "Revenue Trends"           # Card header
#| padding: 20px                     # Internal spacing
#| expandable: true                  # Allow zoom (default)
#| fill: true                        # Fill available height

library(plotly)
plot_ly(data, x = ~date, y = ~revenue, type = "scatter", mode = "lines")
```
```

**Markdown Cards:**
```markdown
::: {.card title="Key Insights"}
- Revenue increased 15% YoY
- Customer retention at 92%
- New market expansion successful
:::
```

### Plots

**Interactive Plots (Recommended):**
```r
# plotly
library(plotly)
p <- ggplot(data, aes(x, y)) + geom_point()
ggplotly(p)

# leaflet
library(leaflet)
leaflet() |> addTiles() |> addMarkers(lng=long, lat=lat)

# dygraphs
library(dygraphs)
dygraph(timeseries_data)
```

**Static Plots:**
```r
```{r}
#| fig-width: 10
#| fig-height: 6

library(ggplot2)
ggplot(data, aes(x, y)) + geom_point() + theme_minimal()
```
```

### Tables

**Interactive Tables:**
```r
# DT (recommended for interactivity)
library(DT)
datatable(
  data,
  options = list(pageLength = 25, scrollX = TRUE),
  filter = "top",
  class = "display"
)

# reactable
library(reactable)
reactable(data, searchable = TRUE, filterable = TRUE)
```

**Formatted Tables:**
```r
# gt (publication-quality)
library(gt)
gt(data) |>
  fmt_currency(columns = revenue) |>
  fmt_percent(columns = growth) |>
  tab_style(
    style = cell_fill(color = "#E8F4F8"),
    locations = cells_body()
  )

# knitr::kable (simple)
knitr::kable(data, format = "html", digits = 2)
```

---

## Interactivity

### Static Dashboards

Use interactive JavaScript widgets without backend servers:
- `plotly` - Interactive plots
- `leaflet` - Interactive maps
- `DT` - Interactive tables
- `dygraphs` - Time series

```r
```{r}
#| title: "Interactive Plot"

library(plotly)
plot_ly(data, x = ~x, y = ~y, type = "scatter", mode = "markers",
        marker = list(size = 10, color = ~category))
```
```

### Shiny Dashboards

Add reactive interactivity with Shiny:

```yaml
---
title: "Reactive Dashboard"
format: dashboard
server: shiny
---
```

**Input Controls:**
```r
## {.sidebar}

```{r}
selectInput("region", "Select Region:",
            choices = c("North", "South", "East", "West"))

sliderInput("year", "Year:",
            min = 2020, max = 2024, value = 2023)
```

## Column

```{r}
#| title: "Filtered Data"

renderPlotly({
  filtered <- data |>
    filter(region == input$region, year == input$year)

  plot_ly(filtered, x = ~month, y = ~sales, type = "scatter", mode = "lines")
})
```
```

**Sidebar Placement:**
```markdown
## {.sidebar}          # Left sidebar (default)
## {.sidebar width=250}  # Custom width
```

**Reactive Value Boxes:**
```r
```{r}
#| content: valuebox
#| title: "Dynamic Metric"

list(
  value = textOutput("metric_value"),
  icon = "speedometer",
  color = "success"
)
```

```{r}
#| context: server

output$metric_value <- renderText({
  calculate_metric(input$parameter)
})
```
```

---

## Theming & Styling

### Built-in Themes

```yaml
---
title: "Themed Dashboard"
format:
  dashboard:
    theme: cosmo
---
```

**Available Themes:**
- `default`, `cerulean`, `cosmo`, `darkly`, `flatly`, `journal`
- `litera`, `lumen`, `lux`, `materia`, `minty`, `morph`
- `pulse`, `quartz`, `sandstone`, `simplex`, `sketchy`, `slate`
- `solar`, `spacelab`, `superhero`, `united`, `vapor`, `yeti`, `zephyr`

Preview: https://bootswatch.com/

### Custom Styling

**Logo and Navigation:**
```yaml
format:
  dashboard:
    theme: cosmo
    logo: images/company-logo.png
    nav-buttons:
      - icon: github
        href: https://github.com/username/project
      - icon: twitter
        href: https://twitter.com/username
```

**Custom CSS:**
```yaml
format:
  dashboard:
    theme: cosmo
    css: custom-styles.css
```

```css
/* custom-styles.css */
.value-box {
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.card {
  border: 2px solid #3498db;
}
```

**Title Customization:**
```yaml
format:
  dashboard:
    theme: default
    title: "Q4 Analytics Dashboard"
    author: "Data Team"
    date: today
```

---

## Navigation

### Multi-Page Dashboards

Use Level 1 headings to create pages:

```markdown
---
title: "Multi-Page Dashboard"
format: dashboard
---

# Overview

## Row

```{r}
# Overview content
```

# Sales Analysis

## Row

```{r}
# Sales charts
```

# Customer Insights

## Row

```{r}
# Customer data
```
```

### Page-Specific Options

```markdown
# Sales {orientation="columns" scrolling="true"}

## Column {width=30%}

```{r}
# Sidebar
```

## Column {width=70%}

```{r}
# Main content
```
```

### Navigation Bar

```yaml
format:
  dashboard:
    nav-buttons:
      - icon: house-fill
        href: index.html
        text: Home
      - icon: bar-chart-fill
        href: analytics.html
        text: Analytics
```

---

## Deployment

### Static Deployment

Render to static HTML (no server required):

```bash
quarto render dashboard.qmd
```

**Hosting Options:**
- Quarto Pub: `quarto publish quarto-pub`
- GitHub Pages: `quarto publish gh-pages`
- Netlify: `quarto publish netlify`
- Any web server (upload HTML file)

### Shiny Deployment

For dashboards with `server: shiny`:

**Shiny Server:**
```bash
# Deploy to shinyapps.io
rsconnect::deployApp()
```

**Posit Connect:**
```bash
quarto publish connect
```

**Requirements:**
- Shiny Server infrastructure
- R packages installed on server
- Data accessible to server

---

## Advanced Patterns

### Conditional Layouts

Use R to generate dashboard structure dynamically:

```r
```{r}
#| output: asis

regions <- c("North", "South", "East", "West")

for (region in regions) {
  cat(sprintf("\n## %s Region\n\n", region))
  cat("```{r}\n")
  cat(sprintf("plot_region_data('%s')\n", region))
  cat("```\n\n")
}
```
```

### Dynamic Titles

```r
```{r}
metric_value <- calculate_metric()
title_text <- paste("Metric Value:", format(metric_value, big.mark = ","))

cat("title=", title_text, "\n")
plot(data)
```
```

### Mixed Content Layouts

Combine multiple output types in one card:

```r
```{r}
#| title: "Combined View"

# Print summary statistics
cat("Summary Statistics:\n")
print(summary(data))

# Show plot
plot(data$x, data$y)

# Display table
knitr::kable(head(data))
```
```

### Parameters

Create dashboard variants:

```yaml
---
title: "Parameterized Dashboard"
format: dashboard
params:
  region: "North"
  year: 2024
---
```

```r
```{r}
filtered_data <- data |>
  filter(region == params$region, year == params$year)
```
```

**Render with parameters:**
```bash
quarto render dashboard.qmd -P region:South -P year:2023
```

### Expandable Cards

Control zoom behavior:

```r
```{r}
#| title: "Fixed Size Chart"
#| expandable: false

plot(data)
```
```

### Toolbar

Add controls at the top:

```markdown
## {.toolbar}

```{r}
dateRangeInput("dates", "Date Range:",
               start = Sys.Date() - 30, end = Sys.Date())
```
```

---

## Best Practices

### Layout Design

1. **Use relative sizing** (percentages) for responsive layouts
2. **Limit dashboard width** to 3-4 cards per row maximum
3. **Prioritize content** with larger height/width allocations
4. **Group related metrics** using rows/columns/tabsets
5. **Use scrolling sparingly** - prefer pagination or tabsets

### Performance

1. **Cache expensive computations:**
```r
```{r}
#| cache: true

expensive_calculation <- process_large_dataset()
```
```

2. **Use `execute: freeze: auto` for large projects:**
```yaml
execute:
  freeze: auto
```

3. **Optimize Shiny reactivity:**
```r
# Use reactive expressions for shared computations
filtered_data <- reactive({
  data |> filter(region == input$region)
})

# Use isolate() to prevent unnecessary updates
observe({
  isolate({
    updateSelectInput(session, "category", choices = get_categories())
  })
})
```

4. **Lazy load data:**
```r
data <- reactive({
  req(input$load_button)
  read_csv("large-dataset.csv")
})
```

### Visual Design

1. **Consistent color schemes:**
```r
# Define palette upfront
brand_colors <- c("#3498db", "#e74c3c", "#2ecc71", "#f39c12")

# Use throughout dashboard
scale_fill_manual(values = brand_colors)
```

2. **Meaningful value box colors:**
- `success` (green) - Positive metrics, targets met
- `warning` (orange) - Caution, approaching limits
- `danger` (red) - Issues, targets missed
- `info` (blue) - Neutral information
- `primary` (blue) - Key metrics

3. **Appropriate chart types:**
- Line charts - Trends over time
- Bar charts - Comparisons across categories
- Scatter plots - Relationships between variables
- Pie charts - Part-to-whole (use sparingly)
- Heatmaps - Correlation matrices

4. **White space matters:**
```r
#| padding: 20px  # Add breathing room
```

### Content Organization

1. **Start with overview** (KPIs, value boxes)
2. **Progress to details** (charts, tables)
3. **End with raw data** (full dataset, filters)

**Example structure:**
```markdown
# Overview (Page 1)
## Row - Value boxes with KPIs
## Row - Key trend charts

# Detailed Analysis (Page 2)
## Row - Detailed breakdowns
## Row - Comparative visualizations

# Data Explorer (Page 3)
## Row - Interactive data table with filters
```

### Accessibility

1. **Use descriptive titles:**
```r
#| title: "Monthly Revenue Trends (2020-2024)"
```

2. **Add alt text to plots:**
```r
#| fig-alt: "Line chart showing revenue growth from $1M to $5M"
```

3. **High contrast colors:**
```yaml
format:
  dashboard:
    theme: [default, custom-high-contrast.scss]
```

4. **Keyboard navigation:**
- Tabsets automatically support keyboard navigation
- Interactive tables (DT) support arrow keys

### Testing

1. **Test multiple screen sizes** - Preview in browser with responsive mode
2. **Verify Shiny reactivity** - Check all input combinations
3. **Load test** - Ensure performance with realistic data volumes
4. **Cross-browser testing** - Chrome, Firefox, Safari, Edge

### Documentation

Include a documentation page:

```markdown
# About {orientation="rows"}

## Row

::: {.card title="Dashboard Purpose"}
This dashboard provides real-time insights into sales performance
across all regions. Data is updated daily at 6 AM UTC.
:::

::: {.card title="Data Sources"}
- Sales data: Salesforce API
- Customer data: PostgreSQL database
- Market data: External API (Bloomberg)
:::

::: {.card title="Contact"}
Questions? Contact the Data Team at data@company.com
:::
```

---

## Common Patterns Library

### KPI Dashboard

```yaml
---
title: "KPI Dashboard"
format: dashboard
---

## Row {height=20%}

```{r}
value_box(title = "Revenue", value = "$1.2M", icon = "currency-dollar", theme = "success")
```

```{r}
value_box(title = "Customers", value = "2,456", icon = "people", theme = "primary")
```

```{r}
value_box(title = "Growth", value = "+23%", icon = "graph-up", theme = "info")
```

## Row {height=80%}

```{r}
#| title: "Revenue Trend"
plotly::plot_ly(data, x = ~month, y = ~revenue, type = "scatter", mode = "lines")
```

```{r}
#| title: "Top Products"
DT::datatable(top_products)
```
```

### Regional Comparison

```yaml
---
title: "Regional Dashboard"
format:
  dashboard:
    orientation: columns
---

## Column {.tabset width=75%}

```{r}
#| title: "North Region"
plot_region("North")
```

```{r}
#| title: "South Region"
plot_region("South")
```

```{r}
#| title: "East Region"
plot_region("East")
```

```{r}
#| title: "West Region"
plot_region("West")
```

## Column {width=25%}

```{r}
#| title: "Summary Stats"
summarize_all_regions()
```
```

### Executive Summary

```yaml
---
title: "Executive Dashboard"
format:
  dashboard:
    theme: cosmo
    logo: images/logo.png
---

# Executive Summary

## Row {height=25%}

```{r}
value_box(title = "Annual Revenue", value = "$45.2M",
          icon = "cash-stack", theme = "success")
```

```{r}
value_box(title = "Profit Margin", value = "18.5%",
          icon = "percent", theme = "primary")
```

```{r}
value_box(title = "Customer Satisfaction", value = "4.7/5",
          icon = "star-fill", theme = "warning")
```

```{r}
value_box(title = "Market Share", value = "23%",
          icon = "pie-chart", theme = "info")
```

## Row {height=75%}

```{r}
#| title: "Quarterly Performance"
plot_quarterly_performance()
```

```{r}
#| title: "Department Breakdown"
plot_department_breakdown()
```
```

---

## Troubleshooting

### Layout Issues

**Problem:** Cards not sizing properly
```yaml
# Solution: Explicitly set heights/widths
## Row {height=60%}
## Row {height=40%}
```

**Problem:** Too much white space
```r
# Solution: Use fill layout
## Row {.fill}
```

**Problem:** Content cut off
```yaml
# Solution: Enable scrolling
format:
  dashboard:
    scrolling: true
```

### Value Box Issues

**Problem:** Icons not showing
```r
# Solution: Load bsicons explicitly
library(bsicons)
value_box(showcase = bs_icon("graph-up"))
```

**Problem:** Value box too tall
```r
# Solution: Use flow layout
## Row {.flow}
```

### Shiny Issues

**Problem:** Dashboard not reactive
```yaml
# Solution: Ensure server mode enabled
format: dashboard
server: shiny
```

**Problem:** Inputs not updating outputs
```r
# Solution: Use reactive expressions properly
filtered_data <- reactive({
  data |> filter(region == input$region)
})

renderPlot({
  plot(filtered_data())  # Call reactive with ()
})
```

---

## Additional Resources

- **Official Guide:** https://quarto.org/docs/dashboards/
- **Layout Examples:** https://quarto.org/docs/dashboards/layout.html
- **Data Display:** https://quarto.org/docs/dashboards/data-display.html
- **Interactivity:** https://quarto.org/docs/dashboards/interactivity/
- **Gallery:** https://quarto.org/docs/gallery/#dashboards
- **Bootstrap Icons:** https://icons.getbootstrap.com/
- **Bootswatch Themes:** https://bootswatch.com/
