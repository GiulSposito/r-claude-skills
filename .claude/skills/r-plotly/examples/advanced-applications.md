# Advanced Applications

Complete production-quality examples demonstrating real-world Plotly applications in R.

## 1. Financial Dashboard

Complete financial analysis dashboard with candlestick charts, volume, indicators, and interactivity.

### Standalone Financial Dashboard

```r
library(plotly)
library(dplyr)
library(lubridate)

# Generate realistic stock data
set.seed(123)
n_days <- 180
dates <- seq(as.Date("2025-01-01"), by = "day", length.out = n_days)

# Simulate stock prices with trend and volatility
generate_stock_data <- function(dates, start_price = 100, trend = 0.001, volatility = 0.02) {
  n <- length(dates)
  returns <- rnorm(n, mean = trend, sd = volatility)
  prices <- start_price * cumprod(1 + returns)

  data.frame(
    date = dates,
    close = prices,
    open = prices * (1 + rnorm(n, 0, 0.005)),
    high = prices * (1 + abs(rnorm(n, 0.01, 0.01))),
    low = prices * (1 - abs(rnorm(n, 0.01, 0.01))),
    volume = round(rnorm(n, 1000000, 300000))
  ) |>
    mutate(
      high = pmax(high, open, close),
      low = pmin(low, open, close)
    )
}

stock_data <- generate_stock_data(dates)

# Calculate technical indicators
stock_data <- stock_data |>
  arrange(date) |>
  mutate(
    sma_20 = zoo::rollmean(close, k = 20, fill = NA, align = "right"),
    sma_50 = zoo::rollmean(close, k = 50, fill = NA, align = "right"),
    ema_12 = TTR::EMA(close, n = 12),
    ema_26 = TTR::EMA(close, n = 26)
  ) |>
  mutate(
    macd = ema_12 - ema_26,
    signal = TTR::EMA(macd, n = 9),
    macd_hist = macd - signal
  )

# Create candlestick chart with moving averages
fig_candlestick <- plot_ly(stock_data, x = ~date, type = "candlestick",
                           open = ~open, high = ~high, low = ~low, close = ~close,
                           name = "Price",
                           increasing = list(line = list(color = "#26a69a"),
                                           fillcolor = "#26a69a"),
                           decreasing = list(line = list(color = "#ef5350"),
                                           fillcolor = "#ef5350")) |>
  add_lines(y = ~sma_20, name = "SMA 20",
           line = list(color = "#2196F3", width = 1.5, dash = "solid"),
           hovertemplate = "SMA 20: $%{y:.2f}<extra></extra>") |>
  add_lines(y = ~sma_50, name = "SMA 50",
           line = list(color = "#FF9800", width = 1.5, dash = "dash"),
           hovertemplate = "SMA 50: $%{y:.2f}<extra></extra>") |>
  layout(
    title = list(
      text = "<b>Stock Price Analysis</b>",
      font = list(size = 20)
    ),
    xaxis = list(
      title = "",
      rangeslider = list(visible = FALSE),
      rangeselector = list(
        buttons = list(
          list(count = 1, label = "1m", step = "month", stepmode = "backward"),
          list(count = 3, label = "3m", step = "month", stepmode = "backward"),
          list(count = 6, label = "6m", step = "month", stepmode = "backward"),
          list(step = "all", label = "All")
        ),
        x = 0, y = 1.05,
        bgcolor = "#f0f0f0",
        activecolor = "#2196F3"
      )
    ),
    yaxis = list(
      title = "Price ($)",
      tickprefix = "$",
      gridcolor = "#e0e0e0"
    ),
    hovermode = "x unified",
    plot_bgcolor = "#fafafa",
    paper_bgcolor = "white",
    margin = list(t = 80)
  )

# Create volume bar chart
fig_volume <- plot_ly(stock_data, x = ~date, y = ~volume, type = "bar",
                      name = "Volume",
                      marker = list(
                        color = ~ifelse(close >= open, "#26a69a", "#ef5350"),
                        line = list(width = 0)
                      ),
                      hovertemplate = "Volume: %{y:,.0f}<extra></extra>") |>
  layout(
    yaxis = list(
      title = "Volume",
      gridcolor = "#e0e0e0"
    ),
    xaxis = list(title = ""),
    plot_bgcolor = "#fafafa",
    showlegend = FALSE,
    margin = list(t = 20)
  )

# Create MACD indicator
fig_macd <- plot_ly(stock_data, x = ~date) |>
  add_bars(y = ~macd_hist, name = "MACD Histogram",
          marker = list(
            color = ~ifelse(macd_hist >= 0, "#26a69a", "#ef5350"),
            line = list(width = 0)
          ),
          hovertemplate = "MACD Hist: %{y:.3f}<extra></extra>") |>
  add_lines(y = ~macd, name = "MACD",
           line = list(color = "#2196F3", width = 2),
           hovertemplate = "MACD: %{y:.3f}<extra></extra>") |>
  add_lines(y = ~signal, name = "Signal",
           line = list(color = "#FF9800", width = 2),
           hovertemplate = "Signal: %{y:.3f}<extra></extra>") |>
  layout(
    yaxis = list(
      title = "MACD",
      gridcolor = "#e0e0e0"
    ),
    xaxis = list(title = "Date"),
    hovermode = "x unified",
    plot_bgcolor = "#fafafa",
    margin = list(t = 20)
  )

# Combine all charts using subplots
fig_dashboard <- subplot(
  fig_candlestick,
  fig_volume,
  fig_macd,
  nrows = 3,
  heights = c(0.5, 0.25, 0.25),
  shareX = TRUE,
  titleY = TRUE
) |>
  layout(
    title = list(
      text = "<b>Financial Analysis Dashboard</b><br><sub>Complete Technical Analysis with Interactive Controls</sub>",
      font = list(size = 24),
      y = 0.98
    ),
    showlegend = TRUE,
    legend = list(
      orientation = "h",
      x = 0.5,
      xanchor = "center",
      y = 1.02,
      bgcolor = "rgba(255,255,255,0.8)"
    ),
    margin = list(t = 100, b = 80)
  )

fig_dashboard
```

### Shiny Financial Dashboard

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("Advanced Financial Dashboard"),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("ticker", "Select Stock:",
                  choices = c("TECH", "FINANCE", "ENERGY", "HEALTH"),
                  selected = "TECH"),
      sliderInput("days", "Historical Days:",
                  min = 30, max = 365, value = 180, step = 30),
      sliderInput("sma_short", "Short MA Period:",
                  min = 5, max = 50, value = 20, step = 5),
      sliderInput("sma_long", "Long MA Period:",
                  min = 20, max = 200, value = 50, step = 10),
      hr(),
      h4("Current Metrics"),
      verbatimTextOutput("metrics"),
      hr(),
      h4("Trading Signals"),
      verbatimTextOutput("signals")
    ),

    mainPanel(
      width = 9,
      plotlyOutput("candlestick_plot", height = "400px"),
      plotlyOutput("volume_plot", height = "150px"),
      plotlyOutput("indicators_plot", height = "200px")
    )
  )
)

server <- function(input, output, session) {

  # Reactive stock data generation
  stock_data <- reactive({
    req(input$ticker, input$days)

    dates <- seq(Sys.Date() - input$days, Sys.Date(), by = "day")
    dates <- dates[!weekdays(dates) %in% c("Saturday", "Sunday")]

    # Different characteristics per ticker
    params <- list(
      TECH = list(start = 150, trend = 0.0015, vol = 0.025),
      FINANCE = list(start = 80, trend = 0.0005, vol = 0.015),
      ENERGY = list(start = 60, trend = -0.0003, vol = 0.030),
      HEALTH = list(start = 120, trend = 0.0010, vol = 0.020)
    )[[input$ticker]]

    set.seed(123)
    n <- length(dates)
    returns <- rnorm(n, mean = params$trend, sd = params$vol)
    prices <- params$start * cumprod(1 + returns)

    data.frame(
      date = dates,
      close = prices,
      open = prices * (1 + rnorm(n, 0, 0.005)),
      high = prices * (1 + abs(rnorm(n, 0.01, 0.01))),
      low = prices * (1 - abs(rnorm(n, 0.01, 0.01))),
      volume = round(rnorm(n, 1000000, 300000))
    ) |>
      mutate(
        high = pmax(high, open, close),
        low = pmin(low, open, close),
        sma_short = zoo::rollmean(close, k = input$sma_short, fill = NA, align = "right"),
        sma_long = zoo::rollmean(close, k = input$sma_long, fill = NA, align = "right"),
        rsi = TTR::RSI(close, n = 14),
        bb = TTR::BBands(close, n = 20)
      )
  })

  output$candlestick_plot <- renderPlotly({
    data <- stock_data()

    plot_ly(data, x = ~date, type = "candlestick",
            open = ~open, high = ~high, low = ~low, close = ~close,
            name = input$ticker,
            increasing = list(line = list(color = "#26a69a"), fillcolor = "#26a69a"),
            decreasing = list(line = list(color = "#ef5350"), fillcolor = "#ef5350")) |>
      add_lines(y = ~sma_short, name = paste("SMA", input$sma_short),
                line = list(color = "#2196F3", width = 2)) |>
      add_lines(y = ~sma_long, name = paste("SMA", input$sma_long),
                line = list(color = "#FF9800", width = 2)) |>
      layout(
        title = paste("<b>", input$ticker, "Stock Analysis</b>"),
        xaxis = list(title = "", rangeslider = list(visible = FALSE)),
        yaxis = list(title = "Price ($)", tickprefix = "$"),
        hovermode = "x unified",
        plot_bgcolor = "#fafafa"
      )
  })

  output$volume_plot <- renderPlotly({
    data <- stock_data()

    plot_ly(data, x = ~date, y = ~volume, type = "bar",
            marker = list(color = ~ifelse(close >= open, "#26a69a", "#ef5350"))) |>
      layout(
        yaxis = list(title = "Volume"),
        xaxis = list(title = ""),
        showlegend = FALSE,
        plot_bgcolor = "#fafafa",
        margin = list(t = 10)
      )
  })

  output$indicators_plot <- renderPlotly({
    data <- stock_data()

    plot_ly(data, x = ~date, y = ~rsi, type = "scatter", mode = "lines",
            line = list(color = "#9C27B0", width = 2),
            name = "RSI") |>
      add_lines(y = 70, line = list(color = "red", dash = "dash"), name = "Overbought") |>
      add_lines(y = 30, line = list(color = "green", dash = "dash"), name = "Oversold") |>
      layout(
        title = "Relative Strength Index (RSI)",
        yaxis = list(title = "RSI", range = c(0, 100)),
        xaxis = list(title = "Date"),
        hovermode = "x unified",
        plot_bgcolor = "#fafafa"
      )
  })

  output$metrics <- renderText({
    data <- stock_data()
    latest <- tail(data, 1)

    paste0(
      "Current Price: $", round(latest$close, 2), "\n",
      "Daily Change: ", ifelse(latest$close >= latest$open, "+", ""),
      round((latest$close - latest$open) / latest$open * 100, 2), "%\n",
      "High: $", round(latest$high, 2), "\n",
      "Low: $", round(latest$low, 2), "\n",
      "Volume: ", format(latest$volume, big.mark = ",")
    )
  })

  output$signals <- renderText({
    data <- stock_data()
    latest <- tail(data, 1)

    signals <- character()
    if (!is.na(latest$sma_short) && !is.na(latest$sma_long)) {
      if (latest$sma_short > latest$sma_long) {
        signals <- c(signals, "✓ Bullish MA Cross")
      } else {
        signals <- c(signals, "✗ Bearish MA Cross")
      }
    }

    if (!is.na(latest$rsi)) {
      if (latest$rsi > 70) {
        signals <- c(signals, "⚠ Overbought (RSI)")
      } else if (latest$rsi < 30) {
        signals <- c(signals, "⚠ Oversold (RSI)")
      } else {
        signals <- c(signals, "○ Neutral (RSI)")
      }
    }

    paste(signals, collapse = "\n")
  })
}

shinyApp(ui, server)
```

## 2. Geographic Analysis

Complete geographic visualization examples with multi-layer maps, animations, and rich interactivity.

### Multi-Layer Choropleth Map

```r
library(plotly)
library(dplyr)
library(sf)

# Create synthetic US state data
states_data <- data.frame(
  state = state.name,
  code = state.abb,
  region = state.region,
  population = c(5024279, 733391, 7151502, 3011524, 39538223, 5773714, 3605944,
                 989948, 21538187, 10711908, 1455271, 1839106, 12812508, 6785528,
                 3190369, 2937880, 4505836, 4657757, 1362359, 6177224, 7029917,
                 10077331, 5706494, 2961279, 6154913, 1084225, 1961504, 3104614,
                 1377529, 1359711, 9288994, 2117522, 19453561, 10439388, 779094,
                 11799448, 3959353, 4237256, 13002700, 1097379, 5118425, 886667,
                 6910840, 29145505, 3271616, 643077, 8631393, 7705281, 1793716,
                 5893718, 576851),
  gdp_billions = c(266, 54, 406, 146, 3598, 428, 301, 78, 1221, 680, 101, 91,
                   988, 411, 211, 203, 228, 252, 70, 448, 594, 637, 402, 147,
                   359, 58, 148, 230, 93, 88, 729, 123, 1986, 653, 58, 782,
                   241, 267, 901, 68, 282, 56, 391, 2357, 213, 39, 598, 632,
                   43, 409, 42),
  unemployment_rate = c(3.2, 5.1, 4.5, 3.8, 4.8, 3.9, 4.1, 4.3, 3.4, 3.7,
                        2.9, 4.2, 4.4, 3.1, 3.3, 3.5, 4.0, 4.1, 2.8, 4.3,
                        3.8, 3.9, 3.2, 4.0, 3.3, 3.1, 3.6, 3.4, 2.5, 3.7,
                        4.2, 4.5, 4.1, 3.8, 2.7, 4.3, 3.5, 3.9, 3.6, 2.6,
                        3.4, 3.0, 3.7, 3.9, 2.4, 3.3, 3.2, 4.0, 2.9, 3.5, 3.8)
) |>
  mutate(
    gdp_per_capita = gdp_billions * 1000000000 / population,
    category = case_when(
      gdp_per_capita > 70000 ~ "High Income",
      gdp_per_capita > 55000 ~ "Upper Middle",
      gdp_per_capita > 45000 ~ "Middle",
      TRUE ~ "Lower Middle"
    )
  )

# GDP per capita choropleth
fig_gdp <- plot_geo(states_data, locationmode = "USA-states") |>
  add_trace(
    z = ~gdp_per_capita,
    locations = ~code,
    color = ~gdp_per_capita,
    colors = "YlOrRd",
    text = ~paste0(
      "<b>", state, "</b><br>",
      "GDP per Capita: $", format(round(gdp_per_capita), big.mark = ","), "<br>",
      "Population: ", format(population, big.mark = ","), "<br>",
      "Total GDP: $", round(gdp_billions, 1), "B"
    ),
    hovertemplate = "%{text}<extra></extra>",
    marker = list(line = list(color = "white", width = 1))
  ) |>
  layout(
    title = list(
      text = "<b>US GDP per Capita by State</b><br><sub>Economic Output per Person (2025)</sub>",
      font = list(size = 20)
    ),
    geo = list(
      scope = "usa",
      projection = list(type = "albers usa"),
      showlakes = TRUE,
      lakecolor = toRGB("lightblue")
    )
  ) |>
  colorbar(title = "GDP per<br>Capita ($)", tickprefix = "$", tickformat = ",.0f")

# Unemployment rate choropleth
fig_unemployment <- plot_geo(states_data, locationmode = "USA-states") |>
  add_trace(
    z = ~unemployment_rate,
    locations = ~code,
    color = ~unemployment_rate,
    colors = "Blues",
    reversescale = TRUE,
    text = ~paste0(
      "<b>", state, "</b><br>",
      "Unemployment: ", unemployment_rate, "%<br>",
      "Category: ", category
    ),
    hovertemplate = "%{text}<extra></extra>",
    marker = list(line = list(color = "white", width = 1))
  ) |>
  layout(
    title = list(
      text = "<b>US Unemployment Rate by State</b><br><sub>Labor Market Conditions (2025)</sub>",
      font = list(size = 20)
    ),
    geo = list(
      scope = "usa",
      projection = list(type = "albers usa"),
      showlakes = TRUE,
      lakecolor = toRGB("lightblue")
    )
  ) |>
  colorbar(title = "Unemployment<br>Rate (%)", ticksuffix = "%")

fig_gdp
fig_unemployment
```

### Animated Geographic Map

```r
library(plotly)
library(dplyr)

# Generate time-series data for states
years <- 2015:2025
states <- state.abb[1:20]  # Top 20 states for clarity

geo_timeseries <- expand.grid(
  year = years,
  state = states,
  stringsAsFactors = FALSE
) |>
  arrange(year, state) |>
  mutate(
    base_gdp = runif(n(), 200, 800),
    growth_rate = rnorm(n(), 0.03, 0.02),
    gdp = base_gdp * (1 + growth_rate)^(year - 2015),
    population = round(runif(n(), 1000000, 20000000)),
    gdp_per_capita = gdp * 1000000000 / population
  )

# Create animated choropleth
fig_animated <- plot_geo(geo_timeseries, locationmode = "USA-states") |>
  add_trace(
    z = ~gdp_per_capita,
    locations = ~state,
    frame = ~year,
    color = ~gdp_per_capita,
    colors = "Viridis",
    text = ~paste0(
      "<b>", state, "</b><br>",
      "Year: ", year, "<br>",
      "GDP per Capita: $", format(round(gdp_per_capita), big.mark = ",")
    ),
    hovertemplate = "%{text}<extra></extra>",
    marker = list(line = list(color = "white", width = 1))
  ) |>
  layout(
    title = list(
      text = "<b>GDP per Capita Evolution (2015-2025)</b><br><sub>Animated State Economic Growth</sub>",
      font = list(size = 20)
    ),
    geo = list(
      scope = "usa",
      projection = list(type = "albers usa"),
      showlakes = TRUE,
      lakecolor = toRGB("lightblue")
    ),
    updatemenus = list(
      list(
        type = "buttons",
        direction = "left",
        x = 0.1,
        y = 0,
        xanchor = "right",
        yanchor = "top",
        showactive = FALSE,
        buttons = list(
          list(label = "Play", method = "animate",
               args = list(NULL, list(frame = list(duration = 500, redraw = TRUE),
                                     transition = list(duration = 300),
                                     fromcurrent = TRUE,
                                     mode = "immediate"))),
          list(label = "Pause", method = "animate",
               args = list(list(NULL), list(frame = list(duration = 0, redraw = FALSE),
                                           mode = "immediate",
                                           transition = list(duration = 0))))
        )
      )
    ),
    sliders = list(
      list(
        active = 0,
        steps = lapply(unique(geo_timeseries$year), function(yr) {
          list(
            label = as.character(yr),
            method = "animate",
            args = list(list(yr), list(frame = list(duration = 300, redraw = TRUE),
                                      mode = "immediate",
                                      transition = list(duration = 300)))
          )
        }),
        x = 0.1,
        y = 0,
        len = 0.9,
        xanchor = "left",
        yanchor = "top"
      )
    )
  ) |>
  colorbar(title = "GDP per<br>Capita ($)", tickprefix = "$", tickformat = ",.0f")

fig_animated
```

### Bubble Map with Rich Tooltips

```r
library(plotly)
library(dplyr)

# Major US cities data
cities <- data.frame(
  city = c("New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
           "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose",
           "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte",
           "San Francisco", "Indianapolis", "Seattle", "Denver", "Boston"),
  lat = c(40.7128, 34.0522, 41.8781, 29.7604, 33.4484,
          39.9526, 29.4241, 32.7157, 32.7767, 37.3382,
          30.2672, 30.3322, 32.7555, 39.9612, 35.2271,
          37.7749, 39.7684, 47.6062, 39.7392, 42.3601),
  lon = c(-74.0060, -118.2437, -87.6298, -95.3698, -112.0740,
          -75.1652, -98.4936, -117.1611, -96.7970, -121.8863,
          -97.7431, -81.6557, -97.3308, -82.9988, -80.8431,
          -122.4194, -86.1581, -122.3321, -104.9903, -71.0589),
  population = c(8336817, 3979576, 2693976, 2320268, 1680992,
                 1584064, 1547253, 1423851, 1343573, 1021795,
                 978908, 911507, 909585, 898553, 885708,
                 873965, 876384, 753675, 727211, 692600),
  tech_jobs = c(320000, 375000, 145000, 98000, 87000,
                67000, 45000, 89000, 112000, 285000,
                125000, 38000, 52000, 78000, 62000,
                268000, 56000, 215000, 95000, 178000),
  avg_salary = c(125000, 118000, 105000, 98000, 92000,
                 103000, 88000, 115000, 102000, 145000,
                 108000, 85000, 97000, 93000, 96000,
                 152000, 91000, 135000, 107000, 128000)
) |>
  mutate(
    tech_concentration = tech_jobs / population * 100,
    size_factor = sqrt(population) / 100
  )

# Create bubble map
fig_bubbles <- plot_geo(cities, locationmode = "USA-states") |>
  add_markers(
    x = ~lon,
    y = ~lat,
    size = ~population,
    sizes = c(10, 400),
    color = ~avg_salary,
    colors = "Plasma",
    marker = list(
      opacity = 0.7,
      line = list(color = "white", width = 1.5)
    ),
    text = ~paste0(
      "<b>", city, "</b><br>",
      "Population: ", format(population, big.mark = ","), "<br>",
      "Tech Jobs: ", format(tech_jobs, big.mark = ","), "<br>",
      "Avg Salary: $", format(avg_salary, big.mark = ","), "<br>",
      "Tech Concentration: ", round(tech_concentration, 2), "%"
    ),
    hovertemplate = "%{text}<extra></extra>"
  ) |>
  layout(
    title = list(
      text = "<b>US Tech Hubs Analysis</b><br><sub>Population, Jobs, and Salaries in Major Cities</sub>",
      font = list(size = 20)
    ),
    geo = list(
      scope = "usa",
      projection = list(type = "albers usa"),
      showland = TRUE,
      landcolor = toRGB("gray95"),
      showlakes = TRUE,
      lakecolor = toRGB("lightblue"),
      showcountries = TRUE,
      coastlinecolor = toRGB("gray80")
    ),
    margin = list(t = 100)
  ) |>
  colorbar(
    title = "Average<br>Salary ($)",
    tickprefix = "$",
    tickformat = ",.0f"
  )

fig_bubbles
```

## 3. Scientific Visualization

Advanced scientific plots for complex data analysis and presentation.

### 3D Surface with Contours and Projections

```r
library(plotly)

# Generate complex mathematical surface
x <- seq(-5, 5, length.out = 100)
y <- seq(-5, 5, length.out = 100)
xy_grid <- expand.grid(x = x, y = y)

# Complex function: combination of Gaussian and sinusoidal
z_matrix <- matrix(
  with(xy_grid,
       10 * exp(-(x^2 + y^2) / 8) * cos(sqrt(x^2 + y^2)) +
       5 * sin(x) * cos(y / 2)
  ),
  nrow = length(x),
  ncol = length(y)
)

# Create 3D surface with contour projections
fig_surface <- plot_ly() |>
  add_surface(
    x = x,
    y = y,
    z = z_matrix,
    colorscale = "Viridis",
    contours = list(
      z = list(
        show = TRUE,
        usecolormap = TRUE,
        highlightcolor = "#ff0000",
        project = list(z = TRUE)
      ),
      x = list(
        show = TRUE,
        usecolormap = FALSE,
        highlightcolor = "#ffffff",
        project = list(x = TRUE),
        color = "white",
        width = 2
      ),
      y = list(
        show = TRUE,
        usecolormap = FALSE,
        highlightcolor = "#ffffff",
        project = list(y = TRUE),
        color = "white",
        width = 2
      )
    ),
    hovertemplate = "x: %{x:.2f}<br>y: %{y:.2f}<br>z: %{z:.2f}<extra></extra>"
  ) |>
  layout(
    title = list(
      text = "<b>3D Surface with Contour Projections</b><br><sub>f(x,y) = 10·e^(-(x²+y²)/8)·cos(√(x²+y²)) + 5·sin(x)·cos(y/2)</sub>",
      font = list(size = 18)
    ),
    scene = list(
      xaxis = list(title = "X", gridcolor = "rgba(255,255,255,0.3)"),
      yaxis = list(title = "Y", gridcolor = "rgba(255,255,255,0.3)"),
      zaxis = list(title = "Z = f(X,Y)", gridcolor = "rgba(255,255,255,0.3)"),
      camera = list(
        eye = list(x = 1.5, y = 1.5, z = 1.3),
        center = list(x = 0, y = 0, z = 0)
      ),
      bgcolor = "#f0f0f0"
    ),
    margin = list(t = 100)
  )

fig_surface
```

### Parallel Coordinates for Multivariate Analysis

```r
library(plotly)
library(dplyr)

# Generate comprehensive dataset for chemical compounds
set.seed(42)
n_compounds <- 150

compounds <- data.frame(
  id = 1:n_compounds,
  molecular_weight = rnorm(n_compounds, 300, 80),
  logP = rnorm(n_compounds, 2.5, 1.2),
  pKa = rnorm(n_compounds, 7.4, 1.8),
  solubility = rnorm(n_compounds, -3, 1.5),
  bioavailability = runif(n_compounds, 0.1, 0.9),
  toxicity_score = runif(n_compounds, 0, 100)
) |>
  mutate(
    drug_class = case_when(
      molecular_weight < 250 ~ "Small Molecule",
      molecular_weight < 400 ~ "Medium Drug",
      TRUE ~ "Large Drug"
    ),
    druglike = bioavailability > 0.5 & toxicity_score < 50 &
               molecular_weight < 500 & abs(logP) < 5
  )

# Color mapping for drug-likeness
compounds$color_value <- ifelse(compounds$druglike, 1, 0)

# Create parallel coordinates plot
fig_parallel <- plot_ly(
  type = "parcoords",
  line = list(
    color = ~compounds$color_value,
    colorscale = list(c(0, "#ef5350"), c(1, "#26a69a")),
    showscale = TRUE,
    cmin = 0,
    cmax = 1,
    colorbar = list(
      title = "Drug-like",
      tickvals = c(0.25, 0.75),
      ticktext = c("No", "Yes"),
      len = 0.5
    )
  ),
  dimensions = list(
    list(
      label = "Mol. Weight",
      values = ~compounds$molecular_weight,
      range = c(min(compounds$molecular_weight), max(compounds$molecular_weight))
    ),
    list(
      label = "LogP",
      values = ~compounds$logP,
      range = c(-2, 6)
    ),
    list(
      label = "pKa",
      values = ~compounds$pKa,
      range = c(min(compounds$pKa), max(compounds$pKa))
    ),
    list(
      label = "Solubility",
      values = ~compounds$solubility,
      range = c(min(compounds$solubility), max(compounds$solubility))
    ),
    list(
      label = "Bioavailability",
      values = ~compounds$bioavailability,
      range = c(0, 1)
    ),
    list(
      label = "Toxicity",
      values = ~compounds$toxicity_score,
      range = c(0, 100)
    )
  )
) |>
  layout(
    title = list(
      text = "<b>Drug Compound Multivariate Analysis</b><br><sub>Parallel Coordinates for Chemical Property Exploration</sub>",
      font = list(size = 20)
    ),
    margin = list(t = 100, b = 50, l = 100, r = 100),
    paper_bgcolor = "white",
    plot_bgcolor = "#fafafa"
  )

fig_parallel
```

### Network Diagram with Node and Edge Data

```r
library(plotly)
library(igraph)
library(dplyr)

# Create a scientific collaboration network
set.seed(123)
n_researchers <- 30

# Generate network structure
g <- sample_pa(n_researchers, power = 1.2, directed = FALSE)

# Add node attributes (researchers)
V(g)$name <- paste0("R", 1:n_researchers)
V(g)$publications <- sample(5:50, n_researchers, replace = TRUE)
V(g)$citations <- sample(50:1000, n_researchers, replace = TRUE)
V(g)$h_index <- pmax(5, pmin(V(g)$publications, sqrt(V(g)$citations)))
V(g)$field <- sample(c("Biology", "Chemistry", "Physics", "Mathematics"),
                     n_researchers, replace = TRUE)

# Calculate centrality
V(g)$degree <- degree(g)
V(g)$betweenness <- betweenness(g)

# Add edge attributes (collaborations)
E(g)$weight <- sample(1:10, length(E(g)), replace = TRUE)
E(g)$joint_papers <- E(g)$weight

# Layout for visualization
layout_coords <- layout_with_fr(g)
colnames(layout_coords) <- c("x", "y")

# Prepare node data
nodes <- data.frame(
  id = V(g)$name,
  x = layout_coords[, 1],
  y = layout_coords[, 2],
  size = V(g)$h_index,
  publications = V(g)$publications,
  citations = V(g)$citations,
  h_index = V(g)$h_index,
  field = V(g)$field,
  degree = V(g)$degree,
  stringsAsFactors = FALSE
)

# Prepare edge data
edge_list <- as_edgelist(g, names = TRUE)
edges <- data.frame(
  from = edge_list[, 1],
  to = edge_list[, 2],
  weight = E(g)$weight,
  stringsAsFactors = FALSE
) |>
  left_join(nodes |> select(id, x, y), by = c("from" = "id")) |>
  rename(x_from = x, y_from = y) |>
  left_join(nodes |> select(id, x, y), by = c("to" = "id")) |>
  rename(x_to = x, y_to = y)

# Color mapping for fields
field_colors <- c(
  "Biology" = "#4CAF50",
  "Chemistry" = "#2196F3",
  "Physics" = "#FF9800",
  "Mathematics" = "#9C27B0"
)

nodes$color <- field_colors[nodes$field]

# Create network plot
fig_network <- plot_ly()

# Add edges
for (i in 1:nrow(edges)) {
  fig_network <- fig_network |>
    add_segments(
      x = edges$x_from[i],
      xend = edges$x_to[i],
      y = edges$y_from[i],
      yend = edges$y_to[i],
      line = list(
        color = "rgba(150, 150, 150, 0.3)",
        width = edges$weight[i] / 2
      ),
      showlegend = FALSE,
      hoverinfo = "text",
      text = paste0("Collaboration: ", edges$weight[i], " papers")
    )
}

# Add nodes
fig_network <- fig_network |>
  add_markers(
    data = nodes,
    x = ~x,
    y = ~y,
    marker = list(
      size = ~h_index * 3,
      color = ~color,
      line = list(color = "white", width = 2),
      sizemode = "diameter"
    ),
    text = ~paste0(
      "<b>", id, "</b><br>",
      "Field: ", field, "<br>",
      "Publications: ", publications, "<br>",
      "Citations: ", citations, "<br>",
      "H-index: ", h_index, "<br>",
      "Collaborations: ", degree
    ),
    hovertemplate = "%{text}<extra></extra>",
    showlegend = FALSE
  )

# Add legend manually
for (field in names(field_colors)) {
  fig_network <- fig_network |>
    add_markers(
      x = NA,
      y = NA,
      marker = list(size = 10, color = field_colors[field]),
      name = field,
      showlegend = TRUE
    )
}

fig_network <- fig_network |>
  layout(
    title = list(
      text = "<b>Scientific Collaboration Network</b><br><sub>Researcher Connections and Impact Metrics</sub>",
      font = list(size = 20)
    ),
    xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE, title = ""),
    yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE, title = ""),
    hovermode = "closest",
    plot_bgcolor = "#fafafa",
    paper_bgcolor = "white",
    legend = list(
      title = list(text = "<b>Research Field</b>"),
      x = 1.02,
      y = 1,
      bgcolor = "rgba(255,255,255,0.8)"
    ),
    margin = list(t = 100)
  )

fig_network
```

## 4. ML/Statistics Dashboard

Complete machine learning evaluation dashboard with multiple coordinated visualizations.

### Comprehensive ML Model Evaluation Dashboard

```r
library(plotly)
library(dplyr)
library(tidyr)

# Generate synthetic ML results for multiple models
set.seed(42)
n_samples <- 1000

# True labels and predictions for multiple models
true_labels <- sample(0:1, n_samples, replace = TRUE, prob = c(0.6, 0.4))

models <- list(
  "Random Forest" = list(prob = true_labels * 0.7 + runif(n_samples, 0, 0.3)),
  "XGBoost" = list(prob = true_labels * 0.75 + runif(n_samples, 0, 0.25)),
  "Logistic Regression" = list(prob = true_labels * 0.6 + runif(n_samples, 0, 0.4)),
  "Neural Network" = list(prob = true_labels * 0.72 + runif(n_samples, 0, 0.28))
)

# Calculate confusion matrices
get_confusion_matrix <- function(true_labels, pred_probs, threshold = 0.5) {
  pred_labels <- ifelse(pred_probs > threshold, 1, 0)
  cm <- table(Predicted = pred_labels, Actual = true_labels)
  if (nrow(cm) == 2 && ncol(cm) == 2) {
    return(list(
      tn = cm[1,1], fp = cm[1,2],
      fn = cm[2,1], tp = cm[2,2]
    ))
  } else {
    return(list(tn = 0, fp = 0, fn = 0, tp = 0))
  }
}

# ROC curve data
calculate_roc <- function(true_labels, pred_probs) {
  thresholds <- seq(0, 1, by = 0.01)
  roc_data <- lapply(thresholds, function(thresh) {
    pred <- ifelse(pred_probs > thresh, 1, 0)
    tp <- sum(pred == 1 & true_labels == 1)
    fp <- sum(pred == 1 & true_labels == 0)
    tn <- sum(pred == 0 & true_labels == 0)
    fn <- sum(pred == 0 & true_labels == 1)

    tpr <- tp / (tp + fn)
    fpr <- fp / (fp + tn)

    data.frame(threshold = thresh, tpr = tpr, fpr = fpr)
  })
  do.call(rbind, roc_data)
}

# Calculate AUC
calculate_auc <- function(roc_data) {
  roc_sorted <- roc_data[order(roc_data$fpr), ]
  sum(diff(roc_sorted$fpr) * (head(roc_sorted$tpr, -1) + tail(roc_sorted$tpr, -1)) / 2)
}

# 1. Confusion Matrix Heatmap (Random Forest)
cm_rf <- get_confusion_matrix(true_labels, models[["Random Forest"]]$prob)
cm_matrix <- matrix(c(cm_rf$tn, cm_rf$fn, cm_rf$fp, cm_rf$tp), nrow = 2, byrow = TRUE)

fig_confusion <- plot_ly(
  x = c("Negative", "Positive"),
  y = c("Negative", "Positive"),
  z = cm_matrix,
  type = "heatmap",
  colorscale = list(c(0, "#f0f0f0"), c(1, "#2196F3")),
  text = cm_matrix,
  texttemplate = "<b>%{text}</b>",
  textfont = list(size = 24, color = "black"),
  hovertemplate = "Predicted: %{x}<br>Actual: %{y}<br>Count: %{z}<extra></extra>",
  showscale = FALSE
) |>
  layout(
    title = list(text = "<b>Confusion Matrix - Random Forest</b>", font = list(size = 16)),
    xaxis = list(title = "Predicted Label", side = "top"),
    yaxis = list(title = "Actual Label", autorange = "reversed"),
    margin = list(t = 80)
  ) |>
  add_annotations(
    text = paste0(
      "Accuracy: ", round((cm_rf$tp + cm_rf$tn) / n_samples * 100, 1), "%<br>",
      "Precision: ", round(cm_rf$tp / (cm_rf$tp + cm_rf$fp) * 100, 1), "%<br>",
      "Recall: ", round(cm_rf$tp / (cm_rf$tp + cm_rf$fn) * 100, 1), "%"
    ),
    x = 1.15,
    y = 0.5,
    xref = "paper",
    yref = "paper",
    showarrow = FALSE,
    font = list(size = 12),
    align = "left"
  )

# 2. ROC Curves Comparison
roc_data_all <- lapply(names(models), function(model_name) {
  roc <- calculate_roc(true_labels, models[[model_name]]$prob)
  roc$model <- model_name
  roc$auc <- calculate_auc(roc)
  roc
})
roc_df <- do.call(rbind, roc_data_all)

fig_roc <- plot_ly()

model_colors <- c("#2196F3", "#4CAF50", "#FF9800", "#9C27B0")
for (i in seq_along(names(models))) {
  model_name <- names(models)[i]
  model_data <- roc_df |> filter(model == model_name)
  auc_value <- unique(model_data$auc)

  fig_roc <- fig_roc |>
    add_lines(
      data = model_data,
      x = ~fpr,
      y = ~tpr,
      name = paste0(model_name, " (AUC=", round(auc_value, 3), ")"),
      line = list(color = model_colors[i], width = 2.5),
      hovertemplate = paste0(
        model_name, "<br>",
        "FPR: %{x:.3f}<br>",
        "TPR: %{y:.3f}<br>",
        "<extra></extra>"
      )
    )
}

fig_roc <- fig_roc |>
  add_lines(
    x = c(0, 1),
    y = c(0, 1),
    line = list(color = "gray", dash = "dash", width = 1.5),
    name = "Random Classifier",
    showlegend = TRUE
  ) |>
  layout(
    title = list(text = "<b>ROC Curves - Model Comparison</b>", font = list(size = 16)),
    xaxis = list(title = "False Positive Rate", range = c(0, 1)),
    yaxis = list(title = "True Positive Rate", range = c(0, 1)),
    hovermode = "closest",
    plot_bgcolor = "#fafafa",
    legend = list(x = 0.6, y = 0.2, bgcolor = "rgba(255,255,255,0.8)"),
    margin = list(t = 80)
  )

# 3. Feature Importance
features <- data.frame(
  feature = c("Age", "Income", "Credit Score", "Employment Years", "Debt Ratio",
              "Previous Defaults", "Account Balance", "Monthly Expenses",
              "Education Level", "Location Risk"),
  importance = c(0.18, 0.22, 0.31, 0.12, 0.15, 0.25, 0.19, 0.08, 0.06, 0.11),
  category = c("Demographics", "Financial", "Financial", "Demographics", "Financial",
               "History", "Financial", "Financial", "Demographics", "Demographics")
) |>
  arrange(importance)

fig_importance <- plot_ly(
  data = features,
  y = ~reorder(feature, importance),
  x = ~importance,
  type = "bar",
  orientation = "h",
  marker = list(
    color = ~importance,
    colorscale = "Viridis",
    showscale = FALSE,
    line = list(color = "white", width = 1)
  ),
  text = ~paste0(round(importance * 100, 1), "%"),
  textposition = "outside",
  hovertemplate = "<b>%{y}</b><br>Importance: %{x:.3f}<extra></extra>"
) |>
  layout(
    title = list(text = "<b>Feature Importance - Random Forest</b>", font = list(size = 16)),
    xaxis = list(title = "Importance Score", range = c(0, max(features$importance) * 1.1)),
    yaxis = list(title = ""),
    plot_bgcolor = "#fafafa",
    margin = list(l = 150, t = 80)
  )

# 4. Model Performance Metrics Comparison
metrics <- data.frame(
  model = rep(names(models), each = 4),
  metric = rep(c("Accuracy", "Precision", "Recall", "F1-Score"), length(models)),
  value = c(
    0.85, 0.82, 0.78, 0.80,  # Random Forest
    0.88, 0.85, 0.82, 0.83,  # XGBoost
    0.79, 0.76, 0.74, 0.75,  # Logistic Regression
    0.86, 0.83, 0.80, 0.81   # Neural Network
  )
)

fig_metrics <- plot_ly(
  data = metrics,
  x = ~model,
  y = ~value,
  color = ~metric,
  colors = c("#2196F3", "#4CAF50", "#FF9800", "#9C27B0"),
  type = "bar",
  text = ~paste0(round(value * 100, 1), "%"),
  textposition = "outside",
  hovertemplate = "<b>%{x}</b><br>%{data.name}: %{y:.3f}<extra></extra>"
) |>
  layout(
    title = list(text = "<b>Model Performance Metrics</b>", font = list(size = 16)),
    xaxis = list(title = ""),
    yaxis = list(title = "Score", range = c(0, 1.05)),
    barmode = "group",
    plot_bgcolor = "#fafafa",
    legend = list(title = list(text = "<b>Metric</b>"), x = 1.02, y = 1),
    margin = list(t = 80)
  )

# Combine all plots into dashboard
fig_dashboard <- subplot(
  fig_confusion,
  fig_roc,
  fig_importance,
  fig_metrics,
  nrows = 2,
  titleX = TRUE,
  titleY = TRUE,
  margin = 0.08
) |>
  layout(
    title = list(
      text = "<b>Machine Learning Model Evaluation Dashboard</b><br><sub>Comprehensive Performance Analysis</sub>",
      font = list(size = 24),
      y = 0.98
    ),
    showlegend = TRUE,
    margin = list(t = 120)
  )

fig_dashboard

# Individual plots are also available:
# fig_confusion
# fig_roc
# fig_importance
# fig_metrics
```

### Interactive Model Explorer

```r
library(shiny)
library(plotly)
library(dplyr)

ui <- fluidPage(
  titlePanel("ML Model Interactive Explorer"),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("model", "Select Model:",
                  choices = c("Random Forest", "XGBoost", "Logistic Regression", "Neural Network"),
                  selected = "Random Forest"),
      sliderInput("threshold", "Classification Threshold:",
                  min = 0, max = 1, value = 0.5, step = 0.01),
      hr(),
      h4("Performance Metrics"),
      verbatimTextOutput("metrics_text"),
      hr(),
      downloadButton("download_report", "Download Report")
    ),

    mainPanel(
      width = 9,
      plotlyOutput("confusion_plot", height = "300px"),
      plotlyOutput("roc_plot", height = "300px"),
      plotlyOutput("calibration_plot", height = "300px")
    )
  )
)

server <- function(input, output, session) {

  # Generate predictions (same as before)
  predictions <- reactive({
    set.seed(42)
    n <- 1000
    true_labels <- sample(0:1, n, replace = TRUE, prob = c(0.6, 0.4))

    prob_mult <- switch(input$model,
                       "Random Forest" = 0.70,
                       "XGBoost" = 0.75,
                       "Logistic Regression" = 0.60,
                       "Neural Network" = 0.72)

    prob_noise <- switch(input$model,
                        "Random Forest" = 0.30,
                        "XGBoost" = 0.25,
                        "Logistic Regression" = 0.40,
                        "Neural Network" = 0.28)

    pred_probs <- true_labels * prob_mult + runif(n, 0, prob_noise)
    pred_labels <- ifelse(pred_probs > input$threshold, 1, 0)

    list(true_labels = true_labels, pred_probs = pred_probs, pred_labels = pred_labels)
  })

  output$confusion_plot <- renderPlotly({
    preds <- predictions()
    cm <- table(Predicted = preds$pred_labels, Actual = preds$true_labels)

    if (nrow(cm) == 2 && ncol(cm) == 2) {
      cm_matrix <- matrix(c(cm[1,1], cm[2,1], cm[1,2], cm[2,2]), nrow = 2)
    } else {
      cm_matrix <- matrix(c(0, 0, 0, 0), nrow = 2)
    }

    plot_ly(
      x = c("Negative", "Positive"),
      y = c("Negative", "Positive"),
      z = cm_matrix,
      type = "heatmap",
      colorscale = "Blues",
      text = cm_matrix,
      texttemplate = "<b>%{text}</b>",
      showscale = FALSE
    ) |>
      layout(
        title = paste("Confusion Matrix -", input$model),
        xaxis = list(title = "Predicted", side = "top"),
        yaxis = list(title = "Actual", autorange = "reversed")
      )
  })

  output$roc_plot <- renderPlotly({
    preds <- predictions()
    thresholds <- seq(0, 1, by = 0.01)

    roc_data <- lapply(thresholds, function(t) {
      pred <- ifelse(preds$pred_probs > t, 1, 0)
      tp <- sum(pred == 1 & preds$true_labels == 1)
      fp <- sum(pred == 1 & preds$true_labels == 0)
      tn <- sum(pred == 0 & preds$true_labels == 0)
      fn <- sum(pred == 0 & preds$true_labels == 1)

      data.frame(
        threshold = t,
        tpr = tp / (tp + fn),
        fpr = fp / (fp + tn)
      )
    }) |> bind_rows()

    plot_ly(roc_data, x = ~fpr, y = ~tpr, type = "scatter", mode = "lines",
            line = list(color = "#2196F3", width = 3)) |>
      add_segments(x = 0, xend = 1, y = 0, yend = 1,
                  line = list(dash = "dash", color = "gray")) |>
      layout(
        title = "ROC Curve",
        xaxis = list(title = "False Positive Rate"),
        yaxis = list(title = "True Positive Rate")
      )
  })

  output$calibration_plot <- renderPlotly({
    preds <- predictions()

    # Create calibration bins
    bins <- cut(preds$pred_probs, breaks = seq(0, 1, 0.1), include.lowest = TRUE)
    calib_data <- data.frame(
      predicted = preds$pred_probs,
      actual = preds$true_labels,
      bin = bins
    ) |>
      group_by(bin) |>
      summarise(
        mean_predicted = mean(predicted),
        mean_actual = mean(actual),
        count = n()
      )

    plot_ly(calib_data, x = ~mean_predicted, y = ~mean_actual,
            type = "scatter", mode = "markers+lines",
            marker = list(size = ~sqrt(count) * 2, color = "#4CAF50"),
            line = list(color = "#4CAF50", width = 2)) |>
      add_segments(x = 0, xend = 1, y = 0, yend = 1,
                  line = list(dash = "dash", color = "gray")) |>
      layout(
        title = "Calibration Curve",
        xaxis = list(title = "Mean Predicted Probability"),
        yaxis = list(title = "Mean Actual Probability")
      )
  })

  output$metrics_text <- renderText({
    preds <- predictions()

    tp <- sum(preds$pred_labels == 1 & preds$true_labels == 1)
    fp <- sum(preds$pred_labels == 1 & preds$true_labels == 0)
    tn <- sum(preds$pred_labels == 0 & preds$true_labels == 0)
    fn <- sum(preds$pred_labels == 0 & preds$true_labels == 1)

    accuracy <- (tp + tn) / (tp + tn + fp + fn)
    precision <- tp / (tp + fp)
    recall <- tp / (tp + fn)
    f1 <- 2 * (precision * recall) / (precision + recall)

    paste0(
      "Accuracy: ", round(accuracy * 100, 1), "%\n",
      "Precision: ", round(precision * 100, 1), "%\n",
      "Recall: ", round(recall * 100, 1), "%\n",
      "F1-Score: ", round(f1 * 100, 1), "%\n"
    )
  })
}

shinyApp(ui, server)
```

---

These advanced applications demonstrate production-quality Plotly visualizations for real-world scenarios. Each example includes complete data generation, multiple coordinated plots, rich interactivity, and professional styling suitable for deployment in data analysis pipelines, research publications, or business dashboards.
