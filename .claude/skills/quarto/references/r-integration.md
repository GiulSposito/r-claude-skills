# R Package Integration with Quarto

Comprehensive guide for integrating R packages with Quarto documents.

## Graphics and Visualization

### ggplot2

**Installation:**
```r
install.packages("ggplot2")
```

**Basic Integration:**
```r
```{r}
#| label: fig-ggplot
#| fig-cap: "ggplot2 visualization"
#| fig-width: 8
#| fig-height: 6

library(ggplot2)

ggplot(mtcars, aes(x = mpg, y = hp, color = factor(cyl))) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  labs(
    title = "Horsepower vs. MPG",
    x = "Miles per Gallon",
    y = "Horsepower",
    color = "Cylinders"
  )
```
```

**Best Practices:**
```r
# Theme for publication
```{r}
#| fig-width: 8
#| fig-height: 6
#| fig-dpi: 300

library(ggplot2)

theme_publication <- theme_minimal() +
  theme(
    text = element_text(size = 12, family = "sans"),
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_text(size = 12),
    legend.position = "bottom"
  )

ggplot(data, aes(x, y)) +
  geom_point() +
  theme_publication
```

# Multiple plots with patchwork
```{r}
#| fig-width: 10
#| fig-height: 8

library(patchwork)

p1 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()
p2 <- ggplot(mtcars, aes(mpg, disp)) + geom_point()
p3 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()

(p1 | p2) / p3 +
  plot_annotation(title = "Motor Trend Car Road Tests")
```

# Save high-quality output
```{r}
#| eval: false

ggsave("figure.png", width = 8, height = 6, dpi = 300)
ggsave("figure.pdf", width = 8, height = 6)  # For LaTeX
ggsave("figure.svg", width = 8, height = 6)  # For web
```
```

**Common Issues:**
- **Fonts not rendering:** Install `ragg` package for better font support
- **Long rendering times:** Use `cache: true` for complex plots
- **Size inconsistencies:** Set `fig-width`, `fig-height`, and `fig-dpi` explicitly

### plotly (Interactive Graphics)

**Installation:**
```r
install.packages("plotly")
```

**Basic Interactive Plot:**
```r
```{r}
#| label: fig-plotly
#| fig-cap: "Interactive plotly visualization"
#| warning: false

library(plotly)

plot_ly(
  data = mtcars,
  x = ~mpg,
  y = ~hp,
  color = ~factor(cyl),
  type = "scatter",
  mode = "markers",
  hovertemplate = paste(
    "<b>MPG:</b> %{x}<br>",
    "<b>HP:</b> %{y}<br>",
    "<extra></extra>"
  )
) |>
  layout(
    title = "Interactive Car Performance",
    xaxis = list(title = "Miles per Gallon"),
    yaxis = list(title = "Horsepower")
  )
```
```

**Converting ggplot2 to plotly:**
```r
```{r}
library(ggplot2)
library(plotly)

p <- ggplot(mtcars, aes(mpg, hp, color = factor(cyl))) +
  geom_point(size = 3) +
  theme_minimal()

ggplotly(p)
```
```

**Best Practices:**
- Works best with HTML output
- Use `config()` to customize toolbar
- Consider file size for large datasets
- Test interactivity before publishing

## Interactive Widgets

### leaflet (Maps)

**Installation:**
```r
install.packages("leaflet")
```

**Basic Map:**
```r
```{r}
library(leaflet)

leaflet() |>
  addTiles() |>
  addMarkers(
    lng = -122.4194, lat = 37.7749,
    popup = "San Francisco, CA"
  ) |>
  setView(lng = -122.4194, lat = 37.7749, zoom = 12)
```
```

**Advanced Map with Data:**
```r
```{r}
library(leaflet)
library(dplyr)

# Create sample data
locations <- data.frame(
  name = c("Point A", "Point B", "Point C"),
  lat = c(37.7749, 37.8044, 37.7849),
  lng = c(-122.4194, -122.2712, -122.4094),
  value = c(100, 200, 150)
)

# Color palette
pal <- colorNumeric(palette = "YlOrRd", domain = locations$value)

leaflet(locations) |>
  addProviderTiles(providers$CartoDB.Positron) |>
  addCircleMarkers(
    lng = ~lng,
    lat = ~lat,
    radius = ~value / 20,
    color = ~pal(value),
    popup = ~paste0("<b>", name, "</b><br>Value: ", value),
    fillOpacity = 0.7
  ) |>
  addLegend(
    position = "bottomright",
    pal = pal,
    values = ~value,
    title = "Value"
  )
```
```

### DT (Interactive Tables)

**Installation:**
```r
install.packages("DT")
```

**Basic Interactive Table:**
```r
```{r}
library(DT)

datatable(
  mtcars,
  caption = "Motor Trend Car Road Tests",
  filter = "top",
  options = list(
    pageLength = 10,
    scrollX = TRUE
  )
)
```
```

**Styled Table:**
```r
```{r}
library(DT)

datatable(
  iris,
  class = "cell-border stripe",
  filter = "top",
  extensions = c("Buttons", "ColReorder"),
  options = list(
    pageLength = 10,
    dom = "Bfrtip",
    buttons = c("copy", "csv", "excel", "pdf", "print"),
    colReorder = TRUE,
    columnDefs = list(
      list(className = "dt-center", targets = "_all")
    )
  )
) |>
  formatRound(columns = 1:4, digits = 2) |>
  formatStyle(
    "Sepal.Length",
    background = styleColorBar(iris$Sepal.Length, "lightblue"),
    backgroundSize = "100% 90%",
    backgroundRepeat = "no-repeat",
    backgroundPosition = "center"
  )
```
```

### dygraphs (Time Series)

**Installation:**
```r
install.packages("dygraphs")
```

**Basic Time Series Plot:**
```r
```{r}
library(dygraphs)

dygraph(nhtemp, main = "New Haven Temperatures") |>
  dyRangeSelector() |>
  dyOptions(fillGraph = TRUE, fillAlpha = 0.4) |>
  dyHighlight(highlightCircleSize = 5)
```
```

**Multiple Series:**
```r
```{r}
library(dygraphs)
library(xts)

# Create sample data
dates <- seq(as.Date("2020-01-01"), as.Date("2023-12-31"), by = "day")
series1 <- cumsum(rnorm(length(dates)))
series2 <- cumsum(rnorm(length(dates)))

data <- xts(cbind(series1, series2), order.by = dates)
colnames(data) <- c("Series A", "Series B")

dygraph(data, main = "Time Series Comparison") |>
  dyRangeSelector() |>
  dyOptions(colors = c("#1f77b4", "#ff7f0e")) |>
  dyLegend(width = 400)
```
```

## Table Packages

### gt (Grammar of Tables)

**Installation:**
```r
install.packages("gt")
```

**Basic Table:**
```r
```{r}
library(gt)
library(dplyr)

mtcars |>
  head(10) |>
  gt() |>
  tab_header(
    title = "Motor Trend Car Road Tests",
    subtitle = "Top 10 vehicles"
  ) |>
  fmt_number(
    columns = c(mpg, disp, hp, drat, wt, qsec),
    decimals = 1
  )
```
```

**Advanced Styling:**
```r
```{r}
library(gt)
library(dplyr)

mtcars |>
  group_by(cyl) |>
  summarize(
    count = n(),
    avg_mpg = mean(mpg),
    avg_hp = mean(hp),
    .groups = "drop"
  ) |>
  gt() |>
  tab_header(
    title = "Car Statistics by Cylinder Count"
  ) |>
  tab_stubhead(label = "Cylinders") |>
  fmt_number(
    columns = c(avg_mpg, avg_hp),
    decimals = 1
  ) |>
  cols_label(
    count = "Count",
    avg_mpg = "Avg MPG",
    avg_hp = "Avg HP"
  ) |>
  data_color(
    columns = avg_mpg,
    colors = scales::col_numeric(
      palette = c("red", "yellow", "green"),
      domain = NULL
    )
  ) |>
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_body(columns = avg_mpg)
  ) |>
  tab_source_note("Source: Motor Trend magazine")
```
```

**Best Practices:**
- Use `fmt_*()` functions for consistent formatting
- Apply `tab_style()` for conditional formatting
- Add `tab_header()` and `tab_source_note()` for context
- Use `summary_rows()` for group summaries

### knitr::kable + kableExtra

**Installation:**
```r
install.packages("kableExtra")
```

**Basic Table:**
```r
```{r}
library(knitr)

kable(head(mtcars), caption = "Motor Trend Cars")
```
```

**Enhanced Table:**
```r
```{r}
library(knitr)
library(kableExtra)

mtcars |>
  head(10) |>
  kable(
    caption = "Motor Trend Car Road Tests",
    digits = 1,
    col.names = c("MPG", "Cyl", "Disp", "HP", "Drat", "WT", "Qsec", "VS", "AM", "Gear", "Carb")
  ) |>
  kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width = FALSE,
    position = "left"
  ) |>
  row_spec(0, bold = TRUE) |>
  column_spec(1, bold = TRUE) |>
  add_header_above(c(" " = 1, "Engine" = 3, "Performance" = 7))
```
```

### flextable

**Installation:**
```r
install.packages("flextable")
```

**Basic Table:**
```r
```{r}
library(flextable)

mtcars |>
  head(10) |>
  flextable() |>
  set_caption("Motor Trend Cars") |>
  autofit()
```
```

**Advanced Formatting:**
```r
```{r}
library(flextable)
library(dplyr)

mtcars |>
  head(10) |>
  flextable() |>
  set_header_labels(
    mpg = "MPG",
    cyl = "Cylinders",
    hp = "Horsepower"
  ) |>
  colformat_double(digits = 1) |>
  bg(bg = "#EFEFEF", part = "header") |>
  bold(part = "header") |>
  color(j = "mpg", color = "blue") |>
  autofit() |>
  set_caption("Motor Trend Car Road Tests")
```
```

### reactable (Interactive React Tables)

**Installation:**
```r
install.packages("reactable")
```

**Basic Interactive Table:**
```r
```{r}
library(reactable)

reactable(
  iris,
  filterable = TRUE,
  searchable = TRUE,
  pagination = TRUE,
  defaultPageSize = 10,
  highlight = TRUE,
  striped = TRUE
)
```
```

**Advanced Features:**
```r
```{r}
library(reactable)

reactable(
  mtcars,
  columns = list(
    mpg = colDef(
      name = "MPG",
      format = colFormat(digits = 1),
      style = function(value) {
        color <- if (value > 20) "green" else "red"
        list(color = color, fontWeight = "bold")
      }
    ),
    hp = colDef(
      name = "Horsepower",
      cell = function(value) {
        width <- paste0(value / max(mtcars$hp) * 100, "%")
        bar <- div(style = list(background = "lightblue", width = width, height = "20px"))
        div(style = list(display = "flex", alignItems = "center"), bar, value)
      }
    )
  ),
  defaultSorted = "mpg",
  defaultSortOrder = "desc",
  searchable = TRUE,
  theme = reactableTheme(
    borderColor = "#dfe2e5",
    stripedColor = "#f6f8fa"
  )
)
```
```

## Data Manipulation

### tidyverse

**Installation:**
```r
install.packages("tidyverse")
```

**Common Patterns:**
```r
```{r}
#| label: data-processing
#| code-fold: true
#| code-summary: "Show data processing code"

library(tidyverse)

# Read and process data
data <- read_csv("data.csv") |>
  filter(!is.na(value)) |>
  mutate(
    log_value = log(value),
    category = case_when(
      value > 100 ~ "High",
      value > 50 ~ "Medium",
      TRUE ~ "Low"
    )
  ) |>
  group_by(category) |>
  summarize(
    count = n(),
    mean_value = mean(value),
    sd_value = sd(value),
    .groups = "drop"
  ) |>
  arrange(desc(mean_value))

# Display results
knitr::kable(data)
```
```

**Best Practices:**
- Use `read_csv()` for better defaults than `read.csv()`
- Pipe operations with `|>` for readability
- Use `group_by()` + `summarize()` for aggregations
- Add `.groups = "drop"` to avoid warnings

### data.table (High Performance)

**Installation:**
```r
install.packages("data.table")
```

**Basic Usage:**
```r
```{r}
library(data.table)

# Create data.table
dt <- as.data.table(mtcars)

# Fast operations
result <- dt[
  mpg > 20,
  .(avg_hp = mean(hp), count = .N),
  by = cyl
]

knitr::kable(result)
```
```

## Shiny Integration

### Shiny Documents

**Basic Shiny Document:**
```r
---
title: "Interactive Document"
format: html
server: shiny
---

```{r}
library(shiny)

sliderInput("n", "Number of observations:", 1, 100, 50)

plotOutput("plot")
```

```{r}
#| context: server

output$plot <- renderPlot({
  hist(rnorm(input$n), main = paste("Distribution of", input$n, "observations"))
})
```
```

**Shiny Dashboard:**
```r
---
title: "Shiny Dashboard"
format:
  dashboard:
    orientation: columns
server: shiny
---

## Column {width=30%}

```{r}
library(shiny)

selectInput("variable", "Variable:",
            choices = names(mtcars))

sliderInput("bins", "Number of bins:",
            min = 5, max = 50, value = 30)
```

## Column {width=70%}

```{r}
plotOutput("histogram")
```

```{r}
#| context: server

output$histogram <- renderPlot({
  hist(mtcars[[input$variable]],
       breaks = input$bins,
       main = paste("Distribution of", input$variable),
       xlab = input$variable)
})
```
```

## Statistical Modeling

### Common Modeling Packages

**Linear Models:**
```r
```{r}
# Fit model
model <- lm(mpg ~ hp + wt + cyl, data = mtcars)

# Display results
summary(model)

# Tidy results with broom
library(broom)
tidy(model) |> knitr::kable(digits = 3)
glance(model) |> knitr::kable(digits = 3)
```
```

**Mixed Effects Models:**
```r
```{r}
library(lme4)
library(broom.mixed)

model <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)

tidy(model) |> knitr::kable(digits = 3)
```
```

**Model Diagnostics:**
```r
```{r}
#| layout-ncol: 2
#| fig-width: 5
#| fig-height: 4

library(ggfortify)

model <- lm(mpg ~ hp + wt, data = mtcars)
autoplot(model, which = 1:4)
```
```

## Output Formats

### Format-Specific Code

**Conditional Code by Format:**
```r
```{r}
#| output: asis

if (knitr::is_html_output()) {
  # HTML-only code
  cat("<div class='custom-html'>HTML content</div>")
} else if (knitr::is_latex_output()) {
  # PDF-only code
  cat("\\textbf{PDF content}")
}
```
```

**Interactive vs. Static Graphics:**
```r
```{r}
library(ggplot2)

p <- ggplot(mtcars, aes(mpg, hp)) + geom_point()

if (knitr::is_html_output()) {
  library(plotly)
  ggplotly(p)
} else {
  p
}
```
```

## Common Issues and Solutions

### Memory Management
```r
# Clear large objects after use
```{r}
large_data <- read_csv("big_file.csv")
processed <- process_data(large_data)
rm(large_data)
gc()  # Force garbage collection
```
```

### Long-Running Code
```r
# Use caching for expensive operations
```{r}
#| cache: true
#| cache.vars: [processed_data, model]

processed_data <- expensive_preprocessing(raw_data)
model <- train_expensive_model(processed_data)
```
```

### Package Loading
```r
# Suppress messages in final output
```{r}
#| message: false
#| warning: false

library(tidyverse)
library(ggplot2)
```
```

### Random Seeds
```r
# Reproducible results
```{r}
set.seed(123)
random_data <- rnorm(100)
```
```

## Performance Tips

1. **Use caching strategically** - Cache expensive computations but not data loading
2. **Load packages efficiently** - Load in setup chunk, suppress messages
3. **Optimize graphics** - Use appropriate DPI and format for output
4. **Clean up memory** - Remove large intermediate objects
5. **Use appropriate data structures** - data.table for large data, tibbles for readability

## References

- [Quarto with R](https://quarto.org/docs/computations/r.html)
- [ggplot2 Documentation](https://ggplot2.tidyverse.org/)
- [htmlwidgets Gallery](http://www.htmlwidgets.org/showcase_leaflet.html)
- [gt Package](https://gt.rstudio.com/)
- [Shiny in Quarto](https://quarto.org/docs/interactive/shiny/)
