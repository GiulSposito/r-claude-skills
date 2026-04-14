# Plotly R Basic Plots Gallery

A comprehensive collection of runnable plotly examples for common visualization types. Each example is complete and self-contained.

## 1. Scatter and Line Plots

### Basic Scatter Plot

Simple scatter plot showing relationship between two variables.

```r
library(plotly)

# Use mtcars dataset
plot_ly(data = mtcars,
        x = ~wt,
        y = ~mpg,
        type = 'scatter',
        mode = 'markers',
        marker = list(size = 10, color = 'steelblue')) |>
  layout(title = 'Car Weight vs MPG',
         xaxis = list(title = 'Weight (1000 lbs)'),
         yaxis = list(title = 'Miles per Gallon'))
```

### Scatter Colored by Group

Scatter plot with points colored by categorical variable.

```r
library(plotly)

# Color by number of cylinders
plot_ly(data = mtcars,
        x = ~wt,
        y = ~mpg,
        type = 'scatter',
        mode = 'markers',
        color = ~factor(cyl),
        colors = 'Set1',
        marker = list(size = 10)) |>
  layout(title = 'MPG vs Weight by Cylinders',
         xaxis = list(title = 'Weight (1000 lbs)'),
         yaxis = list(title = 'Miles per Gallon'),
         legend = list(title = list(text = 'Cylinders')))
```

### Bubble Chart with Size

Scatter plot where point size represents a third dimension.

```r
library(plotly)

# Bubble size represents horsepower
plot_ly(data = mtcars,
        x = ~wt,
        y = ~mpg,
        type = 'scatter',
        mode = 'markers',
        marker = list(
          size = ~hp / 5,  # Scale down hp for reasonable bubble sizes
          color = ~hp,
          colorscale = 'Viridis',
          showscale = TRUE,
          colorbar = list(title = 'Horsepower')
        ),
        text = ~paste('Car:', rownames(mtcars), '<br>HP:', hp),
        hoverinfo = 'text') |>
  layout(title = 'MPG vs Weight (bubble size = horsepower)',
         xaxis = list(title = 'Weight (1000 lbs)'),
         yaxis = list(title = 'Miles per Gallon'))
```

### Line Plot with Time Series

Simple line plot for temporal data.

```r
library(plotly)

# Generate time series data
dates <- seq(as.Date('2024-01-01'), as.Date('2024-12-31'), by = 'day')
values <- cumsum(rnorm(length(dates), mean = 0.5, sd = 10))

df <- data.frame(date = dates, value = values)

plot_ly(data = df,
        x = ~date,
        y = ~value,
        type = 'scatter',
        mode = 'lines',
        line = list(color = 'darkgreen', width = 2)) |>
  layout(title = 'Time Series Example',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'Cumulative Value'))
```

### Multiple Lines on One Plot

Compare multiple time series on same axes.

```r
library(plotly)

# Generate multiple time series
dates <- seq(as.Date('2024-01-01'), as.Date('2024-12-31'), by = 'day')
series_a <- cumsum(rnorm(length(dates), mean = 0.3, sd = 5))
series_b <- cumsum(rnorm(length(dates), mean = 0.5, sd = 7))
series_c <- cumsum(rnorm(length(dates), mean = 0.2, sd = 6))

plot_ly() |>
  add_trace(x = ~dates, y = ~series_a, type = 'scatter', mode = 'lines',
            name = 'Product A', line = list(color = 'steelblue', width = 2)) |>
  add_trace(x = ~dates, y = ~series_b, type = 'scatter', mode = 'lines',
            name = 'Product B', line = list(color = 'firebrick', width = 2)) |>
  add_trace(x = ~dates, y = ~series_c, type = 'scatter', mode = 'lines',
            name = 'Product C', line = list(color = 'forestgreen', width = 2)) |>
  layout(title = 'Product Sales Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'Cumulative Sales'),
         legend = list(x = 0.1, y = 0.9))
```

### Line with Markers

Line plot with visible data points.

```r
library(plotly)

# Sample data - monthly metrics
months <- c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun')
revenue <- c(45, 52, 48, 61, 58, 67)

df <- data.frame(month = months, revenue = revenue)

plot_ly(data = df,
        x = ~month,
        y = ~revenue,
        type = 'scatter',
        mode = 'lines+markers',
        line = list(color = 'purple', width = 3),
        marker = list(size = 12, color = 'orange',
                     line = list(color = 'purple', width = 2))) |>
  layout(title = 'Monthly Revenue Trend',
         xaxis = list(title = 'Month'),
         yaxis = list(title = 'Revenue ($K)'))
```

---

## 2. Bar and Column Charts

### Simple Bar Chart

Vertical bars showing categorical data.

```r
library(plotly)

# Create sample data
categories <- c('North', 'South', 'East', 'West', 'Central')
sales <- c(120, 95, 140, 88, 105)

df <- data.frame(region = categories, sales = sales)

plot_ly(data = df,
        x = ~region,
        y = ~sales,
        type = 'bar',
        marker = list(color = 'steelblue',
                     line = list(color = 'navy', width = 1.5))) |>
  layout(title = 'Sales by Region',
         xaxis = list(title = 'Region'),
         yaxis = list(title = 'Sales ($K)'))
```

### Grouped Bars (Side-by-Side)

Compare multiple variables across categories.

```r
library(plotly)

# Sample data - quarterly results
quarters <- c('Q1', 'Q2', 'Q3', 'Q4')
product_a <- c(42, 48, 55, 61)
product_b <- c(38, 45, 41, 52)
product_c <- c(35, 38, 44, 48)

plot_ly() |>
  add_trace(x = ~quarters, y = ~product_a, type = 'bar',
            name = 'Product A',
            marker = list(color = '#1f77b4')) |>
  add_trace(x = ~quarters, y = ~product_b, type = 'bar',
            name = 'Product B',
            marker = list(color = '#ff7f0e')) |>
  add_trace(x = ~quarters, y = ~product_c, type = 'bar',
            name = 'Product C',
            marker = list(color = '#2ca02c')) |>
  layout(title = 'Quarterly Sales by Product',
         xaxis = list(title = 'Quarter'),
         yaxis = list(title = 'Sales ($K)'),
         barmode = 'group')  # Side-by-side bars
```

### Stacked Bars

Show composition and total together.

```r
library(plotly)

# Sample data - budget allocation
departments <- c('Engineering', 'Sales', 'Marketing', 'Operations')
salaries <- c(450, 320, 180, 280)
equipment <- c(120, 45, 85, 150)
overhead <- c(80, 60, 45, 90)

plot_ly() |>
  add_trace(x = ~departments, y = ~salaries, type = 'bar',
            name = 'Salaries',
            marker = list(color = '#636EFA')) |>
  add_trace(x = ~departments, y = ~equipment, type = 'bar',
            name = 'Equipment',
            marker = list(color = '#EF553B')) |>
  add_trace(x = ~departments, y = ~overhead, type = 'bar',
            name = 'Overhead',
            marker = list(color = '#00CC96')) |>
  layout(title = 'Department Budget Breakdown',
         xaxis = list(title = 'Department'),
         yaxis = list(title = 'Budget ($K)'),
         barmode = 'stack')  # Stacked bars
```

### Horizontal Bars

Useful for long category names or ranking.

```r
library(plotly)

# Sample data - top products
products <- c('Widget Pro Max', 'Gadget Ultra', 'Device Premium',
              'Tool Master', 'Kit Deluxe')
units_sold <- c(2840, 2620, 2380, 2150, 1950)

df <- data.frame(product = products, units = units_sold)

plot_ly(data = df,
        x = ~units,
        y = ~reorder(product, units),  # Order by value
        type = 'bar',
        orientation = 'h',  # Horizontal orientation
        marker = list(color = 'coral',
                     line = list(color = 'darkred', width = 1))) |>
  layout(title = 'Top 5 Products by Units Sold',
         xaxis = list(title = 'Units Sold'),
         yaxis = list(title = ''))
```

### Bars with Error Bars

Show uncertainty or variance in measurements.

```r
library(plotly)

# Sample data with standard errors
treatments <- c('Control', 'Treatment A', 'Treatment B', 'Treatment C')
means <- c(23.5, 28.2, 31.8, 26.9)
std_errors <- c(2.1, 2.5, 2.3, 2.7)

df <- data.frame(treatment = treatments, mean = means, se = std_errors)

plot_ly(data = df,
        x = ~treatment,
        y = ~mean,
        type = 'bar',
        error_y = list(  # Add error bars
          type = 'data',
          array = ~se,
          color = 'darkgray',
          thickness = 2,
          width = 8
        ),
        marker = list(color = 'lightblue',
                     line = list(color = 'steelblue', width = 1.5))) |>
  layout(title = 'Treatment Effects (mean ± SE)',
         xaxis = list(title = 'Treatment Group'),
         yaxis = list(title = 'Response Variable'))
```

---

## 3. Distributions

### Histogram (Single)

Show distribution of a continuous variable.

```r
library(plotly)

# Use mtcars mpg data
plot_ly(x = ~mtcars$mpg,
        type = 'histogram',
        nbinsx = 15,  # Number of bins
        marker = list(color = 'skyblue',
                     line = list(color = 'navy', width = 1))) |>
  layout(title = 'Distribution of MPG',
         xaxis = list(title = 'Miles per Gallon'),
         yaxis = list(title = 'Count'))
```

### Overlaid Histograms

Compare distributions of multiple groups.

```r
library(plotly)

# Compare MPG for different cylinder counts
mtcars_4cyl <- mtcars[mtcars$cyl == 4, ]
mtcars_6cyl <- mtcars[mtcars$cyl == 6, ]
mtcars_8cyl <- mtcars[mtcars$cyl == 8, ]

plot_ly(alpha = 0.6) |>  # Transparency for overlap
  add_histogram(x = ~mtcars_4cyl$mpg, name = '4 Cylinders',
                marker = list(color = 'green')) |>
  add_histogram(x = ~mtcars_6cyl$mpg, name = '6 Cylinders',
                marker = list(color = 'blue')) |>
  add_histogram(x = ~mtcars_8cyl$mpg, name = '8 Cylinders',
                marker = list(color = 'red')) |>
  layout(title = 'MPG Distribution by Cylinder Count',
         xaxis = list(title = 'Miles per Gallon'),
         yaxis = list(title = 'Count'),
         barmode = 'overlay')  # Overlay histograms
```

### Box Plots by Group

Show distribution statistics across categories.

```r
library(plotly)

# Box plots for iris species
plot_ly(data = iris,
        x = ~Species,
        y = ~Sepal.Length,
        type = 'box',
        color = ~Species,
        colors = c('#1f77b4', '#ff7f0e', '#2ca02c')) |>
  layout(title = 'Sepal Length Distribution by Species',
         xaxis = list(title = 'Species'),
         yaxis = list(title = 'Sepal Length (cm)'),
         showlegend = FALSE)
```

### Violin Plots

Show full distribution shape with kernel density.

```r
library(plotly)

# Violin plots for iris data
plot_ly(data = iris,
        x = ~Species,
        y = ~Petal.Length,
        type = 'violin',
        color = ~Species,
        colors = 'Set2',
        box = list(visible = TRUE),  # Show box plot inside violin
        meanline = list(visible = TRUE)) |>  # Show mean line
  layout(title = 'Petal Length Distribution by Species',
         xaxis = list(title = 'Species'),
         yaxis = list(title = 'Petal Length (cm)'),
         showlegend = FALSE)
```

### 2D Histogram (Density)

Show density of points in 2D space.

```r
library(plotly)

# Generate bivariate data
set.seed(42)
x <- rnorm(1000, mean = 50, sd = 15)
y <- rnorm(1000, mean = 60, sd = 20)

plot_ly(x = ~x, y = ~y,
        type = 'histogram2d',
        colorscale = 'Viridis',
        nbinsx = 20,
        nbinsy = 20) |>
  layout(title = '2D Histogram (Density Plot)',
         xaxis = list(title = 'X Variable'),
         yaxis = list(title = 'Y Variable'))
```

### Combined Box + Violin

Show both summary statistics and distribution shape.

```r
library(plotly)

# Create sample data with different distributions
set.seed(123)
group_a <- rnorm(100, mean = 50, sd = 10)
group_b <- rnorm(100, mean = 55, sd = 15)
group_c <- c(rnorm(50, mean = 45, sd = 8), rnorm(50, mean = 65, sd = 8))  # Bimodal

df <- data.frame(
  value = c(group_a, group_b, group_c),
  group = rep(c('Group A', 'Group B', 'Group C'), each = 100)
)

plot_ly(data = df,
        x = ~group,
        y = ~value,
        type = 'violin',
        box = list(visible = TRUE),  # Show box plot
        meanline = list(visible = TRUE),  # Show mean line
        color = ~group,
        colors = c('#8DD3C7', '#FFFFB3', '#BEBADA')) |>
  layout(title = 'Distribution Comparison with Box + Violin',
         xaxis = list(title = 'Group'),
         yaxis = list(title = 'Value'),
         showlegend = FALSE)
```

---

## 4. Compositions

### Pie Chart

Show proportions of a whole.

```r
library(plotly)

# Market share data
companies <- c('Company A', 'Company B', 'Company C', 'Company D', 'Others')
market_share <- c(32, 24, 18, 15, 11)

df <- data.frame(company = companies, share = market_share)

plot_ly(data = df,
        labels = ~company,
        values = ~share,
        type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        marker = list(colors = c('#1f77b4', '#ff7f0e', '#2ca02c',
                                  '#d62728', '#9467bd'),
                     line = list(color = 'white', width = 2))) |>
  layout(title = 'Market Share Distribution',
         showlegend = TRUE)
```

### Donut Chart

Pie chart with center removed, often easier to read.

```r
library(plotly)

# Budget allocation
categories <- c('Salaries', 'Marketing', 'R&D', 'Operations', 'Facilities')
amounts <- c(450, 180, 220, 280, 120)

df <- data.frame(category = categories, amount = amounts)

plot_ly(data = df,
        labels = ~category,
        values = ~amount,
        type = 'pie',
        hole = 0.4,  # Create donut by adding hole
        textposition = 'outside',
        textinfo = 'label+percent',
        marker = list(colors = c('#636EFA', '#EF553B', '#00CC96',
                                  '#AB63FA', '#FFA15A'),
                     line = list(color = 'white', width = 2))) |>
  layout(title = 'Annual Budget Allocation',
         annotations = list(  # Add text in center
           list(text = 'Total:<br>$1,250K',
                x = 0.5, y = 0.5,
                font = list(size = 16),
                showarrow = FALSE)
         ))
```

### Sunburst Diagram

Hierarchical data visualization.

```r
library(plotly)

# Create hierarchical sales data
labels <- c('Total',
            'North', 'South', 'East', 'West',
            'N-Q1', 'N-Q2', 'S-Q1', 'S-Q2', 'E-Q1', 'E-Q2', 'W-Q1', 'W-Q2')
parents <- c('',
             'Total', 'Total', 'Total', 'Total',
             'North', 'North', 'South', 'South', 'East', 'East', 'West', 'West')
values <- c(0,  # Root has no value
            120, 95, 140, 88,
            65, 55, 50, 45, 75, 65, 45, 43)

df <- data.frame(labels = labels, parents = parents, values = values)

plot_ly(data = df,
        labels = ~labels,
        parents = ~parents,
        values = ~values,
        type = 'sunburst',
        branchvalues = 'total',  # Size by total of children
        marker = list(colorscale = 'Blues',
                     line = list(width = 2))) |>
  layout(title = 'Regional Sales Breakdown by Quarter')
```

### Treemap

Space-filling hierarchical visualization.

```r
library(plotly)

# Product category sales
labels <- c('All Products',
            'Electronics', 'Clothing', 'Home',
            'Phones', 'Laptops', 'Shirts', 'Pants', 'Furniture', 'Decor')
parents <- c('',
             'All Products', 'All Products', 'All Products',
             'Electronics', 'Electronics', 'Clothing', 'Clothing', 'Home', 'Home')
values <- c(0,  # Root
            0, 0, 0,  # Categories (sum of children)
            280, 420, 150, 180, 310, 190)

df <- data.frame(labels = labels, parents = parents, values = values)

plot_ly(data = df,
        labels = ~labels,
        parents = ~parents,
        values = ~values,
        type = 'treemap',
        textposition = 'middle center',
        marker = list(colorscale = 'Viridis',
                     line = list(width = 2, color = 'white'))) |>
  layout(title = 'Product Sales by Category')
```

---

## 5. Statistical

### Heatmap from Matrix

Visualize correlation or other matrix data.

```r
library(plotly)

# Calculate correlation matrix
cor_matrix <- cor(mtcars[, c('mpg', 'cyl', 'disp', 'hp', 'drat', 'wt')])

plot_ly(z = ~cor_matrix,
        x = ~colnames(cor_matrix),
        y = ~colnames(cor_matrix),
        type = 'heatmap',
        colorscale = 'RdBu',
        zmid = 0,  # Center colorscale at 0
        colorbar = list(title = 'Correlation'),
        text = ~round(cor_matrix, 2),  # Show values
        texttemplate = '%{text}',
        textfont = list(size = 12)) |>
  layout(title = 'Correlation Matrix: mtcars Variables',
         xaxis = list(title = ''),
         yaxis = list(title = ''))
```

### Contour Plot

Show 3D surface as 2D contours.

```r
library(plotly)

# Generate 3D function data
x <- seq(-5, 5, length.out = 50)
y <- seq(-5, 5, length.out = 50)

# Create z values (2D Gaussian)
z <- outer(x, y, function(x, y) {
  exp(-0.1 * (x^2 + y^2))
})

plot_ly(x = ~x, y = ~y, z = ~z,
        type = 'contour',
        colorscale = 'Jet',
        contours = list(
          showlabels = TRUE,  # Show contour labels
          labelfont = list(size = 10, color = 'white')
        ),
        colorbar = list(title = 'Height')) |>
  layout(title = 'Contour Plot Example',
         xaxis = list(title = 'X'),
         yaxis = list(title = 'Y'))
```

### Scatter with Error Bars

Show measurement uncertainty in both dimensions.

```r
library(plotly)

# Sample experimental data
measurements <- data.frame(
  concentration = c(10, 20, 30, 40, 50),
  response = c(15.2, 28.5, 42.1, 54.8, 68.3),
  response_error = c(2.1, 2.8, 3.2, 3.5, 4.1),
  conc_error = c(0.5, 0.5, 0.5, 0.5, 0.5)
)

plot_ly(data = measurements,
        x = ~concentration,
        y = ~response,
        type = 'scatter',
        mode = 'markers',
        marker = list(size = 10, color = 'darkblue'),
        error_x = list(  # Horizontal error bars
          type = 'data',
          array = ~conc_error,
          color = 'gray',
          thickness = 2
        ),
        error_y = list(  # Vertical error bars
          type = 'data',
          array = ~response_error,
          color = 'gray',
          thickness = 2
        )) |>
  layout(title = 'Dose-Response Curve with Error Bars',
         xaxis = list(title = 'Concentration (µM)'),
         yaxis = list(title = 'Response'))
```

### Regression Line with Confidence

Show linear fit with confidence interval.

```r
library(plotly)

# Fit linear model
model <- lm(mpg ~ wt, data = mtcars)
mtcars$predicted <- predict(model)
mtcars$residuals <- residuals(model)

# Get confidence interval
pred_interval <- predict(model, interval = 'confidence', level = 0.95)
mtcars$lower <- pred_interval[, 'lwr']
mtcars$upper <- pred_interval[, 'upr']

# Sort by weight for smooth confidence band
mtcars <- mtcars[order(mtcars$wt), ]

plot_ly() |>
  # Confidence band
  add_ribbons(data = mtcars,
              x = ~wt,
              ymin = ~lower,
              ymax = ~upper,
              fillcolor = 'rgba(70, 130, 180, 0.2)',
              line = list(width = 0),
              name = '95% CI',
              showlegend = TRUE) |>
  # Regression line
  add_lines(data = mtcars,
            x = ~wt,
            y = ~predicted,
            line = list(color = 'steelblue', width = 2),
            name = 'Regression Line') |>
  # Original data points
  add_markers(data = mtcars,
              x = ~wt,
              y = ~mpg,
              marker = list(size = 8, color = 'darkred'),
              name = 'Data') |>
  layout(title = 'Linear Regression with 95% Confidence Interval',
         xaxis = list(title = 'Weight (1000 lbs)'),
         yaxis = list(title = 'Miles per Gallon'))
```

---

## 6. Maps

### Choropleth USA States

Color-coded map showing state-level data.

```r
library(plotly)

# Sample state data
state_data <- data.frame(
  state = c('CA', 'TX', 'FL', 'NY', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI',
            'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MO', 'MD', 'WI'),
  value = c(95, 88, 82, 91, 76, 73, 71, 68, 65, 64,
            78, 67, 72, 61, 81, 59, 58, 57, 75, 56),
  stringsAsFactors = FALSE
)

plot_ly(type = 'choropleth',
        locations = ~state_data$state,
        locationmode = 'USA-states',
        z = ~state_data$value,
        text = ~state_data$state,
        colorscale = 'Viridis',
        colorbar = list(title = 'Score')) |>
  layout(title = 'State Performance Scores',
         geo = list(scope = 'usa',
                   projection = list(type = 'albers usa'),
                   showlakes = TRUE,
                   lakecolor = toRGB('white')))
```

### Scatter on Map (Lat/Lon)

Plot points on geographic coordinates.

```r
library(plotly)

# Sample city data
cities <- data.frame(
  city = c('New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
           'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'),
  lat = c(40.7128, 34.0522, 41.8781, 29.7604, 33.4484,
          39.9526, 29.4241, 32.7157, 32.7767, 37.3382),
  lon = c(-74.0060, -118.2437, -87.6298, -95.3698, -112.0740,
          -75.1652, -98.4936, -117.1611, -96.7970, -121.8863),
  population = c(8336, 3979, 2693, 2320, 1680,
                 1584, 1547, 1423, 1343, 1021)
)

plot_ly(data = cities,
        type = 'scattergeo',
        lon = ~lon,
        lat = ~lat,
        text = ~paste(city, '<br>Pop:', format(population, big.mark = ',')),
        mode = 'markers',
        marker = list(
          size = ~population / 100,  # Scale marker size
          color = 'red',
          line = list(color = 'darkred', width = 1)
        )) |>
  layout(title = 'Top 10 US Cities by Population',
         geo = list(
           scope = 'usa',
           projection = list(type = 'albers usa'),
           showland = TRUE,
           landcolor = toRGB('gray95'),
           countrycolor = toRGB('gray80')
         ))
```

### Bubble Map

Size and color encode multiple variables on map.

```r
library(plotly)

# Sample data - earthquake magnitudes
earthquakes <- data.frame(
  location = c('San Francisco', 'Los Angeles', 'Seattle', 'Anchorage', 'Honolulu'),
  lat = c(37.7749, 34.0522, 47.6062, 61.2181, 21.3099),
  lon = c(-122.4194, -118.2437, -122.3321, -149.9003, -157.8581),
  magnitude = c(5.8, 6.2, 4.9, 7.1, 5.3),
  depth = c(10, 15, 8, 35, 12)
)

plot_ly(data = earthquakes,
        type = 'scattergeo',
        lon = ~lon,
        lat = ~lat,
        text = ~paste(location, '<br>Magnitude:', magnitude,
                     '<br>Depth:', depth, 'km'),
        mode = 'markers',
        marker = list(
          size = ~magnitude * 5,  # Size by magnitude
          color = ~depth,  # Color by depth
          colorscale = 'Reds',
          cmin = 0,
          cmax = 40,
          colorbar = list(title = 'Depth (km)'),
          line = list(color = 'black', width = 1)
        )) |>
  layout(title = 'Earthquake Data (size = magnitude, color = depth)',
         geo = list(
           scope = 'north america',
           showland = TRUE,
           landcolor = toRGB('gray90'),
           coastlinecolor = toRGB('gray50')
         ))
```

### Lines on Map

Show routes or connections between locations.

```r
library(plotly)

# Sample flight routes
routes <- data.frame(
  origin = c('New York', 'New York', 'Chicago', 'Chicago', 'Los Angeles'),
  origin_lat = c(40.7128, 40.7128, 41.8781, 41.8781, 34.0522),
  origin_lon = c(-74.0060, -74.0060, -87.6298, -87.6298, -118.2437),
  dest = c('London', 'Tokyo', 'London', 'Paris', 'Tokyo'),
  dest_lat = c(51.5074, 35.6762, 51.5074, 48.8566, 35.6762),
  dest_lon = c(-0.1278, 139.6503, -0.1278, 2.3522, 139.6503)
)

# Create plot with lines
p <- plot_ly()

# Add lines for each route
for (i in 1:nrow(routes)) {
  p <- p |>
    add_trace(
      type = 'scattergeo',
      lon = c(routes$origin_lon[i], routes$dest_lon[i]),
      lat = c(routes$origin_lat[i], routes$dest_lat[i]),
      mode = 'lines',
      line = list(width = 2, color = 'red'),
      opacity = 0.6,
      showlegend = FALSE
    )
}

# Add markers for cities
all_cities <- data.frame(
  city = c(routes$origin, routes$dest),
  lat = c(routes$origin_lat, routes$dest_lat),
  lon = c(routes$origin_lon, routes$dest_lon)
)
all_cities <- unique(all_cities)

p <- p |>
  add_trace(
    type = 'scattergeo',
    lon = all_cities$lon,
    lat = all_cities$lat,
    text = all_cities$city,
    mode = 'markers',
    marker = list(size = 8, color = 'darkblue'),
    showlegend = FALSE
  )

p |>
  layout(
    title = 'International Flight Routes',
    geo = list(
      projection = list(type = 'natural earth'),
      showland = TRUE,
      landcolor = toRGB('gray90'),
      coastlinecolor = toRGB('gray70')
    )
  )
```

---

## Additional Tips

### Customizing Hover Text

Control what appears when hovering over plot elements.

```r
library(plotly)

# Custom hover text
plot_ly(data = mtcars,
        x = ~wt,
        y = ~mpg,
        type = 'scatter',
        mode = 'markers',
        marker = list(size = 10, color = 'steelblue'),
        text = ~paste('Model:', rownames(mtcars),
                     '<br>Weight:', wt, '(1000 lbs)',
                     '<br>MPG:', mpg,
                     '<br>Cylinders:', cyl),
        hoverinfo = 'text') |>  # Only show custom text
  layout(title = 'Custom Hover Information')
```

### Color Scales

Common color scale options.

```r
library(plotly)

# Generate sample data
x <- seq(1, 10, length.out = 20)
y <- seq(1, 10, length.out = 20)
z <- outer(x, y, function(x, y) sin(x/2) * cos(y/2))

# Try different colorscales:
# 'Viridis', 'Blues', 'Greens', 'Reds', 'RdBu', 'Jet', 'Portland', etc.

plot_ly(x = ~x, y = ~y, z = ~z,
        type = 'heatmap',
        colorscale = 'Viridis') |>
  layout(title = 'Example Colorscale: Viridis')
```

### Subplots

Multiple plots in one figure.

```r
library(plotly)

# Create individual plots
p1 <- plot_ly(data = iris, x = ~Sepal.Length, type = 'histogram',
              marker = list(color = 'steelblue'))
p2 <- plot_ly(data = iris, x = ~Species, y = ~Sepal.Length, type = 'box',
              marker = list(color = 'coral'))

# Combine into subplots
subplot(p1, p2, nrows = 1, margin = 0.05) |>
  layout(title = 'Histogram and Box Plot Side-by-Side',
         showlegend = FALSE)
```

### Saving Plots

Export plots to HTML or static images.

```r
library(plotly)
library(htmlwidgets)  # For saving HTML

# Create plot
p <- plot_ly(data = mtcars, x = ~wt, y = ~mpg, type = 'scatter',
             mode = 'markers')

# Save as HTML (interactive)
saveWidget(p, "my_plot.html")

# Note: For static images (PNG, PDF, SVG), you need the 'orca' command-line tool
# or use kaleido package:
# install.packages('reticulate')
# reticulate::py_install('kaleido')
# save_image(p, "my_plot.png")
```

### Animation

Create animated transitions in plots.

```r
library(plotly)

# Generate time series data with multiple time points
set.seed(42)
years <- rep(2020:2024, each = 5)
countries <- rep(c('USA', 'China', 'India', 'Brazil', 'Germany'), times = 5)
gdp <- c(21000, 14000, 2800, 1800, 3800,  # 2020
         21500, 15000, 2900, 1750, 3850,  # 2021
         23000, 17000, 3200, 1900, 4000,  # 2022
         24000, 18000, 3500, 1950, 4100,  # 2023
         25000, 19000, 3900, 2000, 4200)  # 2024
population <- c(331, 1439, 1380, 212, 83,
                332, 1441, 1383, 213, 83,
                333, 1443, 1386, 214, 83,
                334, 1445, 1389, 215, 84,
                335, 1447, 1392, 216, 84)

df <- data.frame(year = years, country = countries,
                 gdp = gdp, population = population)

plot_ly(data = df,
        x = ~gdp,
        y = ~population,
        size = ~gdp / 100,
        color = ~country,
        frame = ~year,  # Animate over year
        text = ~country,
        hoverinfo = 'text',
        type = 'scatter',
        mode = 'markers') |>
  layout(title = 'GDP vs Population Over Time',
         xaxis = list(title = 'GDP (billions)'),
         yaxis = list(title = 'Population (millions)'))
```

---

## End of Gallery

This gallery contains ~1,000 lines of complete, runnable plotly R examples covering the most common visualization types. Each example includes:

- Complete working code with library() calls
- Realistic sample data
- Comments explaining key parameters
- Best practice implementations

All examples can be copied and run directly in R with plotly installed (`install.packages("plotly")`).
