# Advanced ggplot2 Customization Techniques

Advanced techniques from R Graph Gallery for sophisticated plot customization beyond basics.

## Table of Contents

- [Advanced Annotations](#advanced-annotations)
- [Advanced Faceting](#advanced-faceting)
- [Advanced Axis Customization](#advanced-axis-customization)
- [Advanced Legend Techniques](#advanced-legend-techniques)
- [Advanced Theme Creation](#advanced-theme-creation)
- [Advanced Color Techniques](#advanced-color-techniques)
- [Coordinate System Transformations](#coordinate-system-transformations)
- [Text & Typography](#text--typography)
- [Highlighting & Emphasis](#highlighting--emphasis)

---

## Advanced Annotations

### End-of-Line Labels with ggrepel

**Problem**: Labeling line endpoints without overlaps in multi-line charts.

**Solution**: Use `geom_text_repel()` with direction constraints.

```r
library(ggrepel)

# Prepare data with labels only for final year
data <- data |>
  mutate(name_lab = if_else(year == max(year), name, NA_character_))

ggplot(data, aes(x = year, y = value, color = name)) +
  geom_line() +
  geom_text_repel(
    aes(label = name_lab),
    direction = "y",                    # Constrain to vertical movement only
    xlim = c(max(year) + 0.8, NA),     # Position beyond right edge
    segment.size = 0.3,
    segment.alpha = 0.5,
    segment.linetype = "dotted",
    box.padding = 0.4,
    segment.curvature = -0.1,
    segment.ncp = 3,
    segment.angle = 20,
    na.rm = TRUE
  ) +
  coord_cartesian(clip = "off") +       # Allow labels beyond plot boundaries
  theme(plot.margin = margin(r = 80))   # Add right margin for labels
```

**When to use**: Line charts with multiple series where legend is far from data.

**Gotchas**:
- Must set `clip = "off"` or labels will be cut off
- Need adequate plot margins for label space
- `direction = "y"` prevents horizontal spreading

---

### Inline Labels for Stacked Areas

**Problem**: Placing labels directly on stacked area chart segments.

**Solution**: Manual positioning with `annotate()` at specific coordinates.

```r
# Calculate midpoints for each area segment
data_midpoints <- data |>
  group_by(year) |>
  mutate(
    cumsum = cumsum(value),
    y_pos = cumsum - value/2  # Middle of each segment
  )

ggplot(data, aes(x = year, y = value, fill = category)) +
  geom_area() +
  annotate(
    "text",
    x = 2021,
    y = c(150, 420, 650, 820),  # Manually calculated positions
    label = c("Category A: $140B", "Category B: $280B", ...),
    hjust = 0,
    family = "Roboto",
    size = 4,
    color = c("#E31A1C", "#FF7F00", "#6A3D9A", "#1F78B4")  # Match fill colors
  ) +
  coord_cartesian(clip = "off") +
  theme(plot.margin = margin(r = 120))
```

**When to use**: Stacked area charts where you want direct labeling instead of legend.

**Tips**:
- Calculate positions in data coordinates
- Match label colors to fill colors
- Right-align labels (`hjust = 0`) for consistency

---

### Vertical Annotation Lines with Values

**Problem**: Marking specific points with vertical lines and labels.

**Solution**: Combine `geom_segment()` and `geom_text()`.

```r
# Key timepoints to highlight
highlights <- data.frame(
  year = c(2000, 2005, 2010, 2015, 2021),
  value = c(412, 567, 823, 1045, 1289)
)

ggplot(data, aes(x = year, y = value)) +
  geom_area() +
  geom_segment(
    data = highlights,
    aes(x = year, xend = year, y = 0, yend = value),
    color = "grey30",
    size = 0.3
  ) +
  geom_point(
    data = highlights,
    aes(x = year, y = value),
    size = 2,
    color = "grey30"
  ) +
  geom_text(
    data = highlights,
    aes(x = year, y = value, label = paste0("$", value, "B")),
    vjust = -0.5,
    fontface = "bold",
    size = 3.5
  )
```

**When to use**: Highlighting key milestones or totals in time series.

---

### Curved Annotations to Highlight Regions

**Problem**: Drawing attention to specific data features.

**Solution**: Use `geom_curve()` with custom curvature.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  annotate(
    "curve",
    x = 15, xend = 18,         # Start and end x coordinates
    y = 50, yend = 65,         # Start and end y coordinates
    curvature = 0.3,           # Positive = curves right, negative = left
    arrow = arrow(length = unit(2, "mm")),
    color = "red",
    size = 0.5
  ) +
  annotate(
    "text",
    x = 14, y = 48,
    label = "Notable outlier",
    hjust = 1,
    color = "red"
  )
```

**When to use**: Calling out specific features or outliers in scatter plots.

**Tips**:
- Adjust `curvature` between -1 and 1 for curve shape
- Use `angle` parameter for arrow angle at endpoints
- Coordinate curve with text annotation

---

### Low-Level Grid Graphics for Complex Layouts

**Problem**: Need precise control beyond ggplot2's capabilities.

**Solution**: Combine ggplot2 with `grid` package primitives.

```r
library(grid)

p <- ggplot(data, aes(x, y)) + geom_point()
print(p)

# Add decorative elements with grid
grid.lines(x = c(0, 0), y = c(0.05, 0.95),
           gp = gpar(col = "red", lwd = 3))
grid.rect(x = 0.5, y = 0.02, width = 1, height = 0.04,
          gp = gpar(fill = "grey90", lwd = 0))
grid.text("Source: Custom data", x = 0.5, y = 0.02,
          gp = gpar(fontsize = 8, col = "grey30"))
```

**When to use**: Publication-quality layouts needing precise positioning.

**Gotchas**:
- Must print plot first, then add grid elements
- Coordinates are in 0-1 viewport units
- Can't easily integrate with ggplot2 theme system

---

## Advanced Faceting

### Free Scales Strategies

**Problem**: Different facets have vastly different value ranges.

**Solution**: Use `scales` parameter strategically.

```r
# All scales independent
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_wrap(~ category, scales = "free")

# Only y-axis varies (common x-axis)
ggplot(data, aes(x = date, y = value)) +
  geom_line() +
  facet_wrap(~ country, scales = "free_y")

# Only x-axis varies (common y-axis for comparison)
ggplot(data, aes(x = value, y = category)) +
  geom_col() +
  facet_wrap(~ region, scales = "free_x")
```

**When to use**:
- `"free"`: When categories have completely different ranges and distributions
- `"free_y"`: Time series across groups with different magnitudes but same time scale
- `"free_x"`: Comparing distributions or rankings across groups with different ranges

**Gotchas**:
- `"free"` can be misleading - viewers may not notice different axes
- Always add clear axis labels and consider adding reference lines
- For comparisons, `"fixed"` (default) is often better despite compression

---

### Strip Label Customization

**Problem**: Need better control over facet labels.

**Solution**: Customize strip text and background.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_wrap(~ category, strip.position = "bottom") +
  theme(
    strip.background = element_rect(fill = "lightblue", color = "navy"),
    strip.text = element_text(
      face = "bold",
      size = 12,
      color = "navy",
      margin = margin(t = 5, b = 5)
    )
  )

# Remove strip background entirely
theme(
  strip.background = element_blank(),
  strip.text = element_text(face = "bold", hjust = 0)
)
```

**Options**:
- `strip.position`: "top" (default), "bottom", "left", "right"
- `strip.background`: Background rectangle styling
- `strip.text`: Text formatting
- `strip.text.x`, `strip.text.y`: Axis-specific styling

---

### Multi-Variable Faceting with facet_grid

**Problem**: Need to show combinations of two categorical variables.

**Solution**: Use `facet_grid()` for matrix layout.

```r
# Rows by treatment, columns by timepoint
ggplot(data, aes(x, y)) +
  geom_point() +
  facet_grid(treatment ~ timepoint)

# Single row or column
facet_grid(. ~ timepoint)  # One row, multiple columns
facet_grid(treatment ~ .)  # Multiple rows, one column

# With free scales (less common)
facet_grid(treatment ~ timepoint, scales = "free")
```

**When to use**:
- Factorial designs: showing all combinations of two factors
- Comparing patterns across two dimensions
- When you want a true grid rather than wrapped layout

**facet_wrap vs facet_grid**:
- `facet_wrap()`: One variable, wraps into 2D grid, can control nrow/ncol
- `facet_grid()`: Two variables, true matrix, all combinations shown

---

### Layout Control Parameters

**Problem**: Need specific facet arrangements.

**Solution**: Use `nrow`, `ncol`, `dir` parameters.

```r
# Vertical stacking
ggplot(data, aes(x, y)) +
  geom_line() +
  facet_wrap(~ country, ncol = 1, dir = "v")

# Specific grid dimensions
facet_wrap(~ category, nrow = 2, ncol = 3)

# Horizontal flow (default)
facet_wrap(~ category, dir = "h")
```

**Tips**:
- Use `ncol = 1` for long vertical scrolling dashboards
- Use `nrow = 1` for wide horizontal layouts
- Let one dimension be automatic: `nrow = 2` without specifying ncol

---

## Advanced Axis Customization

### Secondary Axes (Use with Caution)

**Problem**: Need to show transformed scale on opposite axis.

**Solution**: Use `sec.axis` with transformation function.

```r
# Temperature: Celsius with Fahrenheit on secondary axis
ggplot(data, aes(x = date, y = temp_celsius)) +
  geom_line() +
  scale_y_continuous(
    name = "Temperature (°C)",
    sec.axis = sec_axis(~ . * 9/5 + 32, name = "Temperature (°F)")
  )

# Duplicate axis on opposite side
scale_x_continuous(sec.axis = dup_axis())

# With custom breaks and labels
scale_y_continuous(
  sec.axis = sec_axis(
    ~ . / 1000,
    name = "Thousands",
    breaks = seq(0, 100, 20)
  )
)
```

**When to use**: ONLY for showing the same data in different units (temperature, currencies, etc).

**DO NOT use for**: Showing two different variables (highly misleading).

**Gotchas**:
- Secondary axis must be a transformation of primary axis
- Cannot have independent scales
- R Graph Gallery explicitly warns against dual Y-axes for different variables

---

### Complex Axis Breaks and Labels

**Problem**: Need non-standard tick mark positions or labels.

**Solution**: Manual break and label specification.

```r
# Custom breaks at specific values
ggplot(data, aes(x, y)) +
  geom_point() +
  scale_x_continuous(
    breaks = c(0, 5, 15, 30, 50, 100),
    labels = c("None", "Very Low", "Low", "Medium", "High", "Max")
  )

# Function-based labels
scale_y_continuous(
  breaks = seq(0, 1000000, 200000),
  labels = scales::label_number(scale = 1e-6, suffix = "M")
)

# Date axis with custom formatting
scale_x_date(
  date_breaks = "1 week",
  date_minor_breaks = "1 day",
  date_labels = "%b %d",
  expand = c(0, 0)
)
```

**Tips**:
- Use `scales::label_*()` functions for automatic formatting
- `expand = c(0, 0)` removes default padding
- Can use expressions for mathematical notation in labels

---

### Date/Time Axis Formatting

**Problem**: Date axes need specific formats and intervals.

**Solution**: Use `scale_x_date()` with date format codes.

```r
library(lubridate)

# Ensure date column is properly formatted
data$date <- as_date(data$date)

ggplot(data, aes(x = date, y = value)) +
  geom_line() +
  scale_x_date(
    date_breaks = "2 weeks",           # Major breaks
    date_minor_breaks = "1 week",      # Minor breaks
    date_labels = "%b %d",             # Month Day (Jan 15)
    limits = c(as_date("2023-01-01"), as_date("2023-12-31"))
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

**Common date format codes**:
- `%Y`: 4-digit year (2024)
- `%y`: 2-digit year (24)
- `%m`: Month number (01-12)
- `%b`: Abbreviated month (Jan)
- `%B`: Full month (January)
- `%d`: Day of month (01-31)
- `%A`: Full weekday (Monday)
- `%W`: Week number (00-53)

**Intervals**:
- `"1 day"`, `"2 weeks"`, `"1 month"`, `"3 months"`, `"1 year"`

---

### Axis Text Rotation and Alignment

**Problem**: Long labels overlap or are unreadable.

**Solution**: Strategic rotation and alignment.

```r
# 45-degree angle with right alignment
theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 90-degree vertical
theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Horizontal with multi-line labels
scale_x_discrete(labels = function(x) str_wrap(x, width = 10))

# Different sizes for emphasis
theme(
  axis.text.x = element_text(size = 8),
  axis.text.y = element_text(size = 10, face = "bold")
)
```

**Gotchas**:
- `hjust = 1` is crucial for 45-degree rotation (right-aligns with tick)
- `vjust = 0.5` centers text on 90-degree rotation
- Consider `coord_flip()` instead of rotation for long category names

---

### Logarithmic and Transformed Scales

**Problem**: Data spans many orders of magnitude.

**Solution**: Use log scales or other transformations.

```r
# Log10 scale
ggplot(data, aes(x, y)) +
  geom_point() +
  scale_y_log10(
    breaks = c(1, 10, 100, 1000, 10000),
    labels = scales::label_comma()
  )

# Natural log
scale_y_continuous(trans = "log")

# Square root transformation
scale_y_sqrt()

# Reverse scale
scale_y_reverse()

# Custom transformation
scale_y_continuous(trans = scales::trans_new(
  name = "cube_root",
  transform = function(x) x^(1/3),
  inverse = function(x) x^3
))
```

**When to use**:
- Log scales: Data spans multiple orders of magnitude
- Square root: Count data with some zeros
- Reverse: Convention (e.g., depth, rankings)

---

## Advanced Legend Techniques

### Legend Positioning Inside Plot

**Problem**: Save space by placing legend inside plot area.

**Solution**: Use coordinate-based positioning.

```r
ggplot(data, aes(x, y, color = category)) +
  geom_point() +
  theme(
    legend.position = c(0.9, 0.1),      # x, y in 0-1 coordinates
    legend.justification = c(1, 0),     # Which corner of legend to position
    legend.background = element_rect(fill = "white", color = "black"),
    legend.margin = margin(t = 5, r = 5, b = 5, l = 5)
  )

# Top-right corner
theme(
  legend.position = c(0.95, 0.95),
  legend.justification = c(1, 1)
)

# Bottom-left corner
theme(
  legend.position = c(0.05, 0.05),
  legend.justification = c(0, 0)
)
```

**Coordinates**:
- `c(0, 0)` = bottom-left
- `c(1, 0)` = bottom-right
- `c(0, 1)` = top-left
- `c(1, 1)` = top-right
- `c(0.5, 0.5)` = center

**Tips**:
- Match `justification` to position for natural alignment
- Add background and border for clarity
- Test positioning with actual data to avoid overlapping

---

### Multiple Legends Control

**Problem**: Need to show/hide specific legend components.

**Solution**: Use `guides()` for fine control.

```r
# Remove specific aesthetics
ggplot(data, aes(x, y, color = var1, size = var2, shape = var3)) +
  geom_point() +
  guides(size = "none")  # Keep color and shape legends only

# Modify individual legend properties
guides(
  color = guide_legend(title = "Category", nrow = 2, override.aes = list(size = 4)),
  size = guide_legend(title = "Value")
)

# Remove all legends
theme(legend.position = "none")
```

**Common guide types**:
- `guide_legend()`: Discrete scales
- `guide_colorbar()`: Continuous color scales
- `guide_colorsteps()`: Binned continuous scales

---

### Custom Legend Titles

**Problem**: Need better legend titles than variable names.

**Solution**: Use `labs()` for aesthetic-specific titles.

```r
ggplot(data, aes(x, y, color = category, shape = type)) +
  geom_point() +
  labs(
    color = "Product Category",
    shape = "Product Type",
    size = "Sales Volume"
  )

# Alternative: in scale function
scale_color_discrete(name = "Product Category")
```

---

### Legend Key and Text Styling

**Problem**: Need larger/different legend symbols or text.

**Solution**: Customize legend components.

```r
theme(
  legend.key = element_rect(fill = "white", color = NA),
  legend.key.size = unit(1.5, "cm"),
  legend.text = element_text(size = 12, color = "navy"),
  legend.title = element_text(face = "bold", size = 14)
)

# Override aesthetics in legend only
guides(color = guide_legend(override.aes = list(size = 5, alpha = 1)))
```

**Use cases**:
- Make small points visible in legend: `override.aes = list(size = 4)`
- Remove transparency from legend: `override.aes = list(alpha = 1)`
- Show different shape in legend: `override.aes = list(shape = 15)`

---

## Advanced Theme Creation

### Creating Custom Theme Functions

**Problem**: Need consistent styling across multiple plots.

**Solution**: Create reusable theme function.

```r
theme_publication <- function(base_size = 11, base_family = "Helvetica") {
  theme_minimal(base_size = base_size, base_family = base_family) +
  theme(
    # Text elements
    plot.title = element_text(face = "bold", size = rel(1.3), hjust = 0),
    plot.subtitle = element_text(size = rel(1.1), hjust = 0, margin = margin(b = 10)),
    plot.caption = element_text(size = rel(0.8), hjust = 1, color = "grey30"),

    # Axis
    axis.title = element_text(size = rel(1.0)),
    axis.text = element_text(size = rel(0.9)),
    axis.line = element_line(color = "black", size = 0.5),

    # Legend
    legend.position = "top",
    legend.title = element_text(size = rel(1.0), face = "bold"),
    legend.text = element_text(size = rel(0.9)),

    # Panel
    panel.grid.major = element_line(color = "grey90", size = 0.3),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),

    # Faceting
    strip.background = element_rect(fill = "grey90", color = NA),
    strip.text = element_text(face = "bold", size = rel(1.0)),

    # Margins
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  )
}

# Usage
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_publication()
```

**Benefits**:
- Consistency across all plots
- Easy to update styling globally
- Can accept parameters for flexibility
- Can extend existing themes as base

---

### Theme Element Combinations

**Problem**: Need sophisticated combinations of theme elements.

**Solution**: Layer multiple theme modifications.

```r
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_minimal() +
  theme(
    # Background layers
    plot.background = element_rect(fill = "#F5F5F5", color = NA),
    panel.background = element_rect(fill = "white", color = NA),

    # Grid customization
    panel.grid.major.x = element_line(color = "grey80", linetype = "solid"),
    panel.grid.major.y = element_line(color = "grey80", linetype = "dotted"),
    panel.grid.minor = element_blank(),

    # Selective axis styling
    axis.line.x.bottom = element_line(color = "black", size = 0.5),
    axis.line.y = element_blank(),
    axis.ticks.length = unit(2, "mm"),

    # Title hierarchy
    plot.title = element_text(face = "bold", size = 16, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 12, color = "grey30", margin = margin(b = 10)),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50")
  )
```

**Tips**:
- Start with complete theme, then override specific elements
- Use `.x` and `.y` suffixes for axis-specific styling
- Layer from general to specific
- Keep related modifications together

---

### Publication-Ready Themes (Economist Style)

**Problem**: Need to match publication style guidelines.

**Solution**: Detailed theme replication.

```r
theme_economist_custom <- function() {
  theme_minimal() +
  theme(
    # Typography
    text = element_text(family = "Helvetica", color = "grey20"),
    plot.title = element_text(face = "bold", size = 16, color = "black"),

    # Panel
    panel.background = element_rect(fill = "#D5E4EB"),  # Light blue
    panel.grid.major = element_line(color = "white", size = 0.8),
    panel.grid.minor = element_blank(),

    # Axis
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),  # The Economist minimizes axis titles
    axis.text = element_text(size = 11),

    # Legend
    legend.position = "top",
    legend.key = element_blank(),
    legend.text = element_text(size = 11),
    legend.title = element_blank(),

    # Remove clutter
    panel.border = element_blank(),
    plot.background = element_rect(fill = "white", color = NA)
  )
}
```

---

## Advanced Color Techniques

### Multi-Color Palettes with Paletteer

**Problem**: Need access to wide variety of color palettes.

**Solution**: Use `paletteer` for 2500+ palettes.

```r
library(paletteer)

# Discrete palettes
ggplot(data, aes(x, y, color = category)) +
  geom_point() +
  scale_color_paletteer_d("ggsci::default_nejm")

# Continuous palettes
ggplot(data, aes(x, y, color = value)) +
  geom_point() +
  scale_color_paletteer_c("viridis::plasma")

# Preview palettes
paletteer_d("nord::aurora")
paletteer_c("ggthemes::Temperature Diverging", n = 20)
```

**Popular palette packages**:
- `ggsci`: Scientific journal color schemes
- `nord`: Nordic-inspired palettes
- `dutchmasters`: Colors from Dutch paintings
- `wesanderson`: Wes Anderson film palettes
- `ggthemes`: Economist, FiveThirtyEight, etc.

**Exploring palettes**:
```r
# List all available palettes
palettes_d_names  # Discrete
palettes_c_names  # Continuous

# Extract hex codes
paletteer_d("nord::aurora", n = 5)
```

---

### Multiple Color Scales with ggnewscale

**Problem**: Need different color mappings for different geoms.

**Solution**: Use `ggnewscale` to reset color aesthetic.

```r
library(ggnewscale)

ggplot(data, aes(x, y)) +
  geom_point(aes(color = var1), size = 3) +
  scale_color_viridis_d() +

  new_scale_color() +  # Reset color scale

  geom_line(aes(color = var2), size = 1) +
  scale_color_brewer(palette = "Set1")
```

**When to use**: Rare cases where different data layers need independent color mappings.

**Gotchas**:
- Creates multiple legends (may need to suppress one)
- Can confuse readers if not carefully designed
- Consider faceting or separate plots instead

---

### Custom Color Functions

**Problem**: Need algorithmic color assignment.

**Solution**: Create custom color scale function.

```r
# Gradient between custom colors
scale_color_gradient(
  low = "#0066CC",
  high = "#FF6600",
  na.value = "grey50"
)

# Three-color diverging scale
scale_color_gradient2(
  low = "blue",
  mid = "white",
  high = "red",
  midpoint = 0
)

# N-color gradient
scale_color_gradientn(
  colors = c("#0066CC", "#3399FF", "#99CCFF", "#FFCC99", "#FF9966", "#FF6600"),
  values = scales::rescale(c(0, 20, 40, 60, 80, 100)),
  na.value = "grey50"
)
```

**Tips**:
- Use `values` to control where color transitions occur
- `midpoint` for diverging scales centers on specific value
- `na.value` explicitly handles missing data

---

### Perceptually Uniform Color Scales

**Problem**: Standard color scales can be misleading.

**Solution**: Use viridis or other perceptually uniform palettes.

```r
# Viridis options: "viridis", "magma", "plasma", "inferno", "cividis"
ggplot(data, aes(x, y, color = value)) +
  geom_point() +
  scale_color_viridis_c(option = "plasma", direction = -1)

# Discrete version
scale_color_viridis_d(option = "inferno")

# With custom limits and breaks
scale_color_viridis_c(
  option = "magma",
  limits = c(0, 100),
  breaks = c(0, 25, 50, 75, 100),
  labels = c("None", "Low", "Med", "High", "Max")
)
```

**Why viridis**:
- Perceptually uniform (equal perceptual distance)
- Colorblind-friendly
- Prints well in grayscale
- Aesthetically pleasing

---

### Strategic Use of Grey Scales

**Problem**: Need to de-emphasize certain categories.

**Solution**: Use grey scale for context, color for emphasis.

```r
# Greyscale palette
scale_color_grey(start = 0.2, end = 0.8)

# Mixed: grey for most, color for highlights
data_plot <- data |>
  mutate(color_var = ifelse(category %in% c("A", "B"), category, "Other"))

ggplot(data_plot, aes(x, y, color = color_var)) +
  geom_point() +
  scale_color_manual(
    values = c(
      "A" = "#E31A1C",
      "B" = "#1F78B4",
      "Other" = "grey70"
    )
  )
```

---

## Coordinate System Transformations

### Circular Barplots with coord_polar

**Problem**: Create circular/radial visualizations.

**Solution**: Convert Cartesian plot with `coord_polar()`.

```r
# Basic circular barplot
ggplot(data, aes(x = reorder(category, value), y = value)) +
  geom_col(fill = "steelblue") +
  coord_polar(theta = "x") +  # x-axis wraps around circle
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

# Circular lollipop with custom grid
ggplot(data, aes(x = reorder(category, value), y = value)) +
  geom_segment(aes(xend = category, y = 0, yend = value), color = "grey") +
  geom_point(size = 3, color = "navy") +
  geom_hline(
    yintercept = seq(0, max(data$value), by = 1000),
    color = "lightgrey",
    linetype = "dashed"
  ) +
  coord_polar(theta = "x") +
  ylim(-1000, max(data$value))  # Negative limit creates central space
```

**Text rotation for circular plots**:
```r
# Calculate angles for readable text
data <- data |>
  arrange(desc(value)) |>
  mutate(
    id = row_number(),
    angle = 90 - 360 * (id - 0.5) / n(),
    hjust = ifelse(angle < -90, 1, 0),
    angle = ifelse(angle < -90, angle + 180, angle)
  )

ggplot(data, aes(x = reorder(category, value), y = value)) +
  geom_col() +
  geom_text(
    aes(label = category, angle = angle, hjust = hjust),
    y = -200  # Position outside circle
  ) +
  coord_polar(theta = "x")
```

**When to use**:
- Cyclic data (time of day, days of week, directions)
- When visual impact matters more than precise reading
- Space-efficient display of many categories

**Gotchas**:
- Difficult to read precise values
- Text rotation requires manual calculation
- Not suitable for comparing magnitudes accurately

---

### Flipped Coordinates

**Problem**: Long category names or horizontal emphasis needed.

**Solution**: Use `coord_flip()`.

```r
# Horizontal barplot
ggplot(data, aes(x = reorder(category, value), y = value)) +
  geom_col() +
  coord_flip() +
  labs(x = NULL, y = "Value")

# Or use y aesthetic directly (ggplot2 3.3.0+)
ggplot(data, aes(y = reorder(category, value), x = value)) +
  geom_col()
```

**When to use**:
- Long category names
- Emphasize ranking
- Many categories (easier to read vertically)

---

### Fixed Aspect Ratios

**Problem**: Need squares to look square, circles to look circular.

**Solution**: Use `coord_fixed()` or `coord_equal()`.

```r
# 1:1 aspect ratio
ggplot(data, aes(x, y)) +
  geom_point() +
  coord_fixed(ratio = 1)

# Geographic data
ggplot(map_data, aes(x = long, y = lat)) +
  geom_polygon(aes(group = group)) +
  coord_fixed(ratio = 1.3)  # Adjust for latitude distortion
```

**When to use**:
- Spatial data
- Geometric shapes
- Any time distances should be visually comparable

---

## Text & Typography

### Custom Fonts with showtext

**Problem**: Need specific fonts not available in base R.

**Solution**: Use `showtext` for Google Fonts or system fonts.

```r
library(showtext)

# Load Google Font
font_add_google("Roboto", "roboto")
font_add_google("Merriweather", "merriweather")
showtext_auto()

# Use in plot
ggplot(data, aes(x, y)) +
  geom_point() +
  labs(title = "Custom Font Title") +
  theme(
    text = element_text(family = "roboto"),
    plot.title = element_text(family = "merriweather", face = "bold", size = 20)
  )

# For ggsave
ggsave("plot.png", dpi = 300)  # showtext handles export automatically
```

**For RMarkdown**:
```r
# In chunk options: fig.showtext=TRUE
# NOT showtext_auto() in code
```

---

### Custom Fonts with ragg

**Problem**: Want to use system fonts without extra packages.

**Solution**: Use `ragg` device with system fonts.

```r
library(ragg)

# Check available system fonts
systemfonts::system_fonts()

# Create plot
p <- ggplot(data, aes(x, y)) +
  geom_point() +
  theme(text = element_text(family = "Arial"))

# Save with ragg device
ggsave("plot.png", plot = p, device = agg_png, dpi = 300)

# In RMarkdown
# ```{r dev="ragg_png"}
```

**showtext vs ragg**:
- **showtext**: Google Fonts, requires activation, works everywhere
- **ragg**: System fonts only, no activation, better performance

---

### HTML/Markdown Formatting with ggtext

**Problem**: Need mixed formatting in text elements.

**Solution**: Use `ggtext` for HTML/markdown support.

```r
library(ggtext)

ggplot(data, aes(x, y)) +
  geom_point() +
  labs(
    title = "**Bold** and *italic* text",
    subtitle = "Text with <span style='color:red;'>colored words</span>",
    caption = "Line 1<br>Line 2<br>Line 3"
  ) +
  theme(
    plot.title = element_markdown(),
    plot.subtitle = element_markdown(),
    plot.caption = element_markdown()
  )

# In axis labels
scale_x_continuous(
  labels = c("**Low**", "*Medium*", "**High**")
) +
theme(axis.text.x = element_markdown())
```

**Supported HTML tags**:
- `<b>`, `**` for bold
- `<i>`, `*` for italic
- `<span style='...'>` for inline styling
- `<br>` for line breaks
- `<sup>` and `<sub>` for super/subscripts

---

### Mathematical Expressions

**Problem**: Need mathematical notation in labels.

**Solution**: Use `expression()` or `bquote()`.

```r
# expression() for static math
ggplot(data, aes(x, y)) +
  geom_point() +
  labs(
    title = expression(paste("Plot of ", alpha, " vs ", beta)),
    x = expression(x^2 + y^2),
    y = expression(sqrt(x))
  )

# bquote() for dynamic values
mean_val <- 42
ggplot(data, aes(x, y)) +
  geom_point() +
  labs(
    title = bquote("Mean = " ~ .(mean_val) ~ mu*g/L)
  )

# In scale labels
scale_y_continuous(
  labels = function(x) parse(text = paste0(x, "*10^3"))
)
```

**Common expressions**:
- Greek letters: `alpha`, `beta`, `gamma`, `theta`, `mu`, `sigma`
- Superscript: `x^2`
- Subscript: `x[i]`
- Fractions: `frac(a, b)`
- Square root: `sqrt(x)`

---

### Text Shadows and Outlines

**Problem**: Text hard to read over complex backgrounds.

**Solution**: Use `shadowtext` package.

```r
library(shadowtext)

ggplot(data, aes(x, y)) +
  geom_point() +
  geom_shadowtext(
    aes(label = label),
    color = "white",
    bg.color = "black",
    size = 5
  )
```

---

## Highlighting & Emphasis

### Conditional Aesthetics for Highlighting

**Problem**: Emphasize specific data points or groups.

**Solution**: Use `ifelse()` in aesthetic mappings.

```r
# Highlight specific groups
data_plot <- data |>
  mutate(
    highlight = category %in% c("A", "D"),
    color_var = ifelse(highlight, category, "Other"),
    size_var = ifelse(highlight, 3, 1),
    alpha_var = ifelse(highlight, 1, 0.3)
  )

ggplot(data_plot, aes(x, y)) +
  geom_point(
    aes(color = color_var, size = size_var, alpha = alpha_var)
  ) +
  scale_color_manual(
    values = c("A" = "red", "D" = "blue", "Other" = "grey70")
  ) +
  scale_size_identity() +
  scale_alpha_identity()
```

**Techniques for emphasis**:
- **Color**: Bright for emphasis, grey for context
- **Size**: Larger for important points
- **Alpha**: Lower transparency for emphasis
- **Shape**: Different shapes for key points
- **Line type**: Solid for emphasis, dashed for context

---

### Background Highlighting

**Problem**: Highlight regions or time periods.

**Solution**: Use `annotate("rect")` for shaded regions.

```r
# Highlight specific time periods
ggplot(data, aes(x = date, y = value)) +
  annotate(
    "rect",
    xmin = as.Date("2020-03-01"),
    xmax = as.Date("2020-06-01"),
    ymin = -Inf, ymax = Inf,
    fill = "pink",
    alpha = 0.3
  ) +
  geom_line() +
  labs(caption = "Pink region indicates lockdown period")

# Multiple highlight regions
highlight_periods <- data.frame(
  start = as.Date(c("2020-01-01", "2021-01-01")),
  end = as.Date(c("2020-03-01", "2021-03-01"))
)

ggplot(data, aes(x = date, y = value)) +
  geom_rect(
    data = highlight_periods,
    aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
    fill = "yellow",
    alpha = 0.2,
    inherit.aes = FALSE
  ) +
  geom_line()
```

---

### Combining Multiple Emphasis Techniques

**Problem**: Need multi-layered emphasis strategy.

**Solution**: Combine color, size, annotation, and alpha.

```r
# Complete highlighting example
data_plot <- data |>
  mutate(
    is_highlight = category %in% c("A", "D"),
    point_color = case_when(
      category == "A" ~ "#E31A1C",
      category == "D" ~ "#FF7F00",
      TRUE ~ "grey70"
    ),
    point_size = ifelse(is_highlight, 4, 2),
    point_alpha = ifelse(is_highlight, 1, 0.4)
  )

ggplot(data_plot, aes(x = value, y = reorder(category, value))) +
  geom_segment(
    aes(xend = 0, yend = category,
        color = point_color,
        size = point_size * 0.3,
        alpha = point_alpha),
    show.legend = FALSE
  ) +
  geom_point(
    aes(color = point_color, size = point_size, alpha = point_alpha),
    show.legend = FALSE
  ) +
  scale_color_identity() +
  scale_size_identity() +
  scale_alpha_identity() +
  annotate(
    "text",
    x = max(data_plot$value) * 0.7,
    y = which(levels(reorder(data_plot$category, data_plot$value)) == "A"),
    label = "Top performer\nthis quarter",
    hjust = 0,
    color = "#E31A1C",
    fontface = "bold"
  ) +
  labs(
    title = "**Category A** and **Category D** show exceptional results",
    subtitle = "Other categories in grey for context"
  ) +
  theme(
    plot.title = element_markdown(),
    axis.title.y = element_blank()
  )
```

---

## Tips & Best Practices

### Context Efficiency

1. **Start simple, then extend**: Build complex visualizations incrementally
2. **Reuse theme functions**: DRY principle for consistent styling
3. **Comment complex calculations**: Especially for angle calculations, transformations
4. **Test edge cases**: Missing data, extreme values, empty categories

### Common Gotchas

1. **coord_cartesian(clip = "off")**: Required for labels extending beyond plot
2. **Order matters**: Complete themes before specific theme() modifications
3. **Factor levels**: Control ordering explicitly, don't rely on default sorting
4. **Scale transformations**: Secondary axes must be transformations, not independent
5. **Print then grid**: Grid graphics need plot printed first

### Performance

1. **Avoid too many geom_text**: Use ggrepel judiciously, can be slow
2. **Simplify paths**: For complex polygons, consider simplifying before plotting
3. **Rasterize backgrounds**: For complex images, use `annotation_raster()`

### Accessibility

1. **Colorblind-safe palettes**: Use viridis, or test with colorblind simulators
2. **Sufficient contrast**: Ensure text readable on all backgrounds
3. **Multiple cues**: Don't rely on color alone (use shape, size, line type)
4. **Alt text**: Include descriptions for reports and publications
