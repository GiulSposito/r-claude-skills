# Advanced ggplot2 Techniques from R Graph Gallery
## Evolution and Ranking Categories

Captured from https://r-graph-gallery.com/ on 2026-03-08

---

## EVOLUTION CATEGORY

### 1. LINE PLOTS

#### 1.1 Multiple Series with gghighlight

**Package:** `gghighlight`

**Technique:** Automatic highlighting of specific groups while showing context

**Code Pattern:**
```r
library(gghighlight)

ggplot(data, aes(x = time, y = value, color = group)) +
  geom_line() +
  gghighlight(use_direct_label = FALSE,
              unhighlighted_params = list(colour = alpha("grey85", 1)))
```

**Use Cases:**
- Faceted line charts where each panel highlights one group while showing all others in grey
- Comparing individual trends against the full dataset
- Reducing visual clutter in multi-series plots

**Special Considerations:**
- `use_direct_label = FALSE` prevents automatic labeling
- `unhighlighted_params` controls appearance of background series
- Works particularly well with faceting for comparative analysis

---

#### 1.2 End-of-Line Labels with ggrepel

**Packages:** `ggrepel`, `ggtext`

**Technique:** Automatically positioned labels at line endpoints with connector segments

**Code Pattern:**
```r
library(ggrepel)
library(ggtext)

ggplot(data, aes(x = year, y = value, color = group)) +
  geom_line() +
  geom_text_repel(
    data = subset(data, year == max(year)),
    aes(label = group),
    family = "sans",
    fontface = "bold",
    size = 3.5,
    direction = "y",           # Constrain to vertical movement only
    xlim = c(2020.8, NA),       # Force labels to right of plot
    hjust = 0,
    segment.size = 0.7,
    segment.alpha = 0.5,
    segment.linetype = "dotted",
    box.padding = 0.4,
    segment.curvature = -0.1,
    segment.ncp = 3,
    segment.angle = 20
  )
```

**Use Cases:**
- Line charts with many series that need clear identification
- Time series where final values are most important
- Avoiding legend clutter by direct labeling

**Special Considerations:**
- `xlim` constraint keeps labels outside plot area
- `direction = "y"` prevents horizontal label spreading
- `segment.*` parameters create customizable connectors
- Requires extending x-axis limits with `coord_cartesian(clip = "off")`

---

#### 1.3 Confidence Intervals with geom_ribbon

**Package:** Base ggplot2

**Technique:** Adding uncertainty bands around lines

**Code Pattern:**
```r
ggplot(data, aes(x = x, y = y)) +
  geom_ribbon(aes(ymin = lower, ymax = upper),
              alpha = 0.3,
              fill = "grey70") +
  geom_line(color = "steelblue", size = 1)
```

**Use Cases:**
- Displaying model predictions with confidence intervals
- Showing error margins in time series
- Visualizing uncertainty ranges

**Special Considerations:**
- `geom_ribbon()` for pre-computed intervals
- `geom_smooth()` for automatic model-based intervals
- Layer order matters: ribbon before line for proper visibility
- `alpha` controls transparency for overlapping bands

---

#### 1.4 Dual Y-Axis Charts

**Package:** Base ggplot2

**Technique:** Secondary axis with `sec.axis`

**Code Pattern:**
```r
# Requires scaling transformation
coeff <- 10

ggplot(data, aes(x = date)) +
  geom_line(aes(y = var1), color = "blue") +
  geom_line(aes(y = var2 / coeff), color = "red") +
  scale_y_continuous(
    name = "First Variable",
    sec.axis = sec_axis(~.*coeff, name = "Second Variable")
  )
```

**Use Cases:**
- Comparing two variables with different scales
- Showing relationship between related metrics

**Special Considerations:**
- **WARNING:** Can be misleading through axis manipulation
- Requires careful scaling coefficient calculation
- Consider alternatives: faceting, standardization, or separate plots
- Use only when variables are truly related and audience understands the scaling

---

### 2. AREA CHARTS

#### 2.1 Stacked Area with Inline Labels

**Packages:** `ggstream` (or base `geom_area`), `ggtext`, `showtext`

**Technique:** Manual annotation placement at specific coordinates within stacked areas

**Code Pattern:**
```r
library(ggstream)
library(ggtext)

ggplot(data, aes(x = year, y = value, fill = category)) +
  geom_stream() +  # or geom_area(position = "stack")
  annotate("text",
           x = 2021,
           y = calculated_y_position,
           label = "Category Name",
           hjust = 0,
           color = "white") +
  coord_cartesian(clip = "off")
```

**Use Cases:**
- Publication-quality area charts with integrated labels
- Reducing need for external legends
- Financial/economic data showing composition over time

**Special Considerations:**
- Requires manual calculation of y-coordinates based on stacked heights
- `coord_cartesian(clip = "off")` allows labels outside plot area
- Color-match labels to their corresponding areas
- Labor-intensive but provides precise control

---

#### 2.2 Gradient and Pattern Fills

**Package:** `ggpattern`

**Technique:** Adding textures and patterns for accessibility

**Code Pattern:**
```r
library(ggpattern)

ggplot(data, aes(x = x, y = y, fill = category)) +
  geom_area_pattern(
    aes(pattern = category),
    pattern_fill = "grey80",
    pattern_density = 0.5,
    pattern_spacing = 0.05,
    alpha = 0.7
  )
```

**Use Cases:**
- Black and white publications
- Color-blind accessible visualizations
- Adding visual interest to filled areas

**Special Considerations:**
- Patterns work better at larger sizes
- Can create visual clutter if overused
- Combine with color for maximum accessibility
- Test printing appearance before publication

---

#### 2.3 Small Multiples with Context

**Package:** Base ggplot2 with `facet_wrap`

**Technique:** Showing individual trends with full dataset context

**Code Pattern:**
```r
ggplot(data, aes(x = time, y = value)) +
  geom_area(data = transform(data, category = NULL),
            fill = "grey85", alpha = 0.5) +
  geom_area(aes(fill = category)) +
  facet_wrap(~category) +
  theme(legend.position = "none")
```

**Use Cases:**
- Comparing individual categories against aggregate
- Maintaining context while highlighting specifics
- Exploratory analysis of grouped time series

**Special Considerations:**
- `transform(data, category = NULL)` removes grouping for background layer
- Creates two geom layers: one for all data, one for highlighted
- Can increase rendering time with large datasets

---

### 3. TIME SERIES

#### 3.1 Date Formatting with scale_x_date

**Package:** Base ggplot2

**Technique:** Customized date axis labels and breaks

**Code Pattern:**
```r
library(lubridate)  # For date parsing

ggplot(data, aes(x = date, y = value)) +
  geom_line() +
  scale_x_date(
    date_breaks = "1 month",        # Major tick spacing
    date_minor_breaks = "1 week",   # Minor tick spacing
    date_labels = "%b %Y",          # Format: Jan 2020
    limits = c(as.Date("2020-01-01"), as.Date("2020-12-31"))
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

**Date Format Codes:**
- `%Y` = 4-digit year (2020)
- `%y` = 2-digit year (20)
- `%m` = Month number (01-12)
- `%b` = Abbreviated month (Jan)
- `%B` = Full month (January)
- `%d` = Day of month (01-31)
- `%a` = Abbreviated weekday (Mon)
- `%A` = Full weekday (Monday)

**Use Cases:**
- Any time-based visualization requiring clear date labeling
- Controlling label density for readability
- Focusing on specific time periods

**Special Considerations:**
- Data must be Date or POSIXct class (verify with `str(data)`)
- Use `lubridate::ymd()`, `mdy()`, `dmy()` for parsing
- Angle rotated labels for dense timelines
- `date_minor_breaks` adds subtle tick marks without labels

---

#### 3.2 Geofaceting for Spatial Time Series

**Package:** `geofacet`

**Technique:** Faceting arranged by geographical layout

**Code Pattern:**
```r
library(geofacet)

ggplot(data, aes(x = year, y = value, color = category)) +
  geom_line() +
  facet_geo(~region, grid = "us_state_grid1") +  # or gb_london_boroughs_grid
  scale_x_continuous(breaks = seq(2010, 2020, 5)) +
  theme(strip.text = element_text(size = 8))
```

**Available Grids:**
- `us_state_grid1`, `us_state_grid2` - US states
- `gb_london_boroughs_grid` - London boroughs
- `africa_countries_grid1` - African countries
- Many others, or create custom grids

**Use Cases:**
- Regional comparisons maintaining geographical intuition
- Climate data across locations
- Public health or demographic trends

**Special Considerations:**
- Maintains spatial relationships unlike alphabetical faceting
- May require small font sizes for readable labels
- Works best with consistent scales across regions
- Consider data density - too many regions reduces readability

---

#### 3.3 Statistical Overlays with ggh4x

**Package:** `ggh4x`

**Technique:** Conditional fills based on line crossings

**Code Pattern:**
```r
library(ggh4x)

ggplot(data, aes(x = time, y = value1)) +
  stat_difference(aes(ymin = value1, ymax = value2),
                  alpha = 0.3) +
  geom_line(aes(y = value1, color = "Series 1")) +
  geom_line(aes(y = value2, color = "Series 2"))
```

**Use Cases:**
- Showing which of two series is larger at any point
- Highlighting crossover points
- Comparing performance metrics

**Special Considerations:**
- Automatically colors areas based on which series is higher
- Requires two variables to compare
- Part of ggh4x package with many other extensions

---

### 4. STREAMCHARTS

#### 4.1 ggStream Extension

**Package:** `ggstream`

**Technique:** Symmetric stacked areas centered on x-axis

**Code Pattern:**
```r
library(ggstream)

ggplot(data, aes(x = time, y = value, fill = category)) +
  geom_stream(type = "proportional",  # or "mirror", "ridge"
              bw = 0.75) +
  scale_fill_brewer(palette = "Set3")
```

**Stream Types:**
- `proportional` - Shows proportion of whole
- `mirror` - Symmetric around center
- `ridge` - Offset like ridgeline plot

**Use Cases:**
- Music streaming data over time by genre
- Topic evolution in text corpora
- Market share changes with smooth transitions

**Special Considerations:**
- Better for showing overall patterns than precise values
- Avoid when exact values matter
- Works best with 3-8 categories
- `bw` parameter controls smoothness

---

## RANKING CATEGORY

### 1. BARPLOTS

#### 1.1 Ordered Bars with forcats

**Package:** `forcats`

**Technique:** Reordering factors by associated numeric values

**Code Pattern:**
```r
library(forcats)

# Method 1: Order by value
ggplot(data, aes(x = fct_reorder(category, value), y = value)) +
  geom_col() +
  coord_flip()

# Method 2: Manual order
ggplot(data, aes(x = fct_relevel(category, "First", "Second", "Third"),
                 y = value)) +
  geom_col()

# Method 3: Order by frequency
ggplot(data, aes(x = fct_infreq(category))) +
  geom_bar()

# Method 4: Reverse order
ggplot(data, aes(x = fct_rev(fct_reorder(category, value)), y = value)) +
  geom_col()
```

**Key Functions:**
- `fct_reorder(f, x)` - Order factor by another variable
- `fct_relevel(f, ...)` - Manually reorder levels
- `fct_infreq(f)` - Order by frequency (count)
- `fct_rev(f)` - Reverse factor order
- `fct_reorder(f, x, .fun = median)` - Order by custom function

**Use Cases:**
- Any categorical comparison where order matters
- Top-N analyses
- Emphasizing highest/lowest values

**Special Considerations:**
- ggplot2 uses factor level order, NOT data frame row order
- Always verify factor levels with `levels(data$category)`
- `coord_flip()` for horizontal bars with readable labels
- Sorting data frame without changing factor levels has no effect

---

#### 1.2 Grouped and Stacked Bars

**Package:** Base ggplot2

**Technique:** Position adjustments for multi-category comparisons

**Code Pattern:**
```r
# Grouped (side-by-side)
ggplot(data, aes(x = category, y = value, fill = subcategory)) +
  geom_col(position = "dodge") +
  scale_fill_brewer(palette = "Set2")

# Stacked
ggplot(data, aes(x = category, y = value, fill = subcategory)) +
  geom_col(position = "stack")

# Proportional (100% stacked)
ggplot(data, aes(x = category, y = value, fill = subcategory)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent)
```

**Use Cases:**
- Grouped: Comparing subcategories directly
- Stacked: Showing composition and total
- Proportional: Comparing relative proportions

**Special Considerations:**
- Grouped bars require more horizontal space
- Stacked bars make subcategory comparison difficult (except first)
- Consider faceting as alternative for many categories
- Use consistent color schemes across related charts

---

#### 1.3 Error Bars and Annotations

**Package:** Base ggplot2

**Technique:** Adding uncertainty and context to bars

**Code Pattern:**
```r
# Error bars
ggplot(data, aes(x = category, y = mean)) +
  geom_col(fill = "steelblue") +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd),
                width = 0.2,
                position = position_dodge(0.9))

# Sample size annotations
ggplot(data, aes(x = category, y = value)) +
  geom_col() +
  geom_text(aes(label = paste0("n=", n)),
            vjust = -0.5,
            size = 3)

# Value labels
ggplot(data, aes(x = category, y = value)) +
  geom_col() +
  geom_text(aes(label = scales::comma(value)),
            vjust = 1.5,
            color = "white",
            fontface = "bold")
```

**Use Cases:**
- Scientific plots requiring error representation
- Showing sample sizes for context
- Making exact values readable

**Special Considerations:**
- Error bars work better with grouped bars using `position_dodge`
- Consider if error bars add clarity or clutter
- Value labels inside bars need sufficient height
- Use `scales::comma()` or `scales::dollar()` for formatting

---

#### 1.4 Variable Width Bars (Marimekko/Mekko Charts)

**Package:** `ggmosaic` or custom implementation

**Technique:** Bars with width representing an additional variable

**Use Cases:**
- Showing two dimensions simultaneously (height and width)
- Market share where both revenue and volume matter
- Budget allocations across categories with different sizes

**Special Considerations:**
- More complex to interpret than standard bars
- Requires careful labeling
- Consider if two separate charts might be clearer
- Effective for showing proportional relationships

---

### 2. LOLLIPOP CHARTS

#### 2.1 Basic Lollipop Pattern

**Package:** Base ggplot2

**Technique:** Combining segments and points for visual efficiency

**Code Pattern:**
```r
# Vertical lollipops
ggplot(data, aes(x = fct_reorder(category, value), y = value)) +
  geom_segment(aes(x = category, xend = category,
                   y = 0, yend = value),
               color = "grey50",
               size = 1) +
  geom_point(color = "steelblue", size = 4) +
  coord_flip() +
  theme_minimal()

# With custom baseline
ggplot(data, aes(x = category, y = value)) +
  geom_segment(aes(x = category, xend = category,
                   y = baseline, yend = value),
               color = ifelse(data$value > data$baseline,
                             "darkgreen", "darkred")) +
  geom_point(aes(color = value > baseline), size = 4) +
  geom_hline(yintercept = baseline, linetype = "dashed")
```

**Use Cases:**
- Alternative to bars with less visual weight
- Rankings and comparisons
- When emphasizing the endpoint value over the bar length
- Deviation from baseline or target

**Special Considerations:**
- Better than bars when many categories (less ink)
- Dots can be sized or colored by additional variables
- Horizontal orientation almost always better for readability
- Consider dumbbell chart if comparing two values per category

---

#### 2.2 Advanced Lollipop: The Office Example

**Package:** Base ggplot2

**Technique:** Complex position calculation for grouped timeline display

**Code Pattern:**
```r
# Create continuous x-axis from episodic data
data <- data |>
  arrange(season, episode) |>
  mutate(
    episode_id = row_number(),
    episode_mod = episode_id + (9 * season),  # Add gaps between seasons
    mid = mean(episode_mod)  # For season label positioning
  )

ggplot(data, aes(x = episode_mod, y = rating)) +
  geom_segment(aes(xend = episode_mod, yend = season_avg, color = season),
               size = 1) +
  geom_point(aes(size = total_votes, color = season)) +
  geom_hline(aes(yintercept = season_avg, color = season),
             linetype = "dashed", alpha = 0.5)
```

**Technique Breakdown:**
- `row_number()` creates sequential IDs
- `episode_id + (9 * season)` adds spacing between groups
- Segments show deviation from seasonal mean
- Point size encodes additional variable (vote count)

**Use Cases:**
- Time series with natural groupings
- Showing individual values plus group averages
- Multi-dimensional data (position, color, size)

**Special Considerations:**
- Requires data transformation before plotting
- Maintain group context while showing individual points
- Effective for 3-4 variables encoded simultaneously

---

### 3. DUMBBELL CHARTS

#### 3.1 Paired Comparison Pattern

**Package:** Base ggplot2

**Technique:** Connecting two related values with line and points

**Code Pattern:**
```r
# Basic dumbbell
ggplot(data, aes(y = fct_reorder(category, gap))) +
  geom_line(aes(x = value1, xend = value2, group = category),
            color = "grey70",
            size = 3) +
  geom_point(aes(x = value1), color = "blue", size = 4) +
  geom_point(aes(x = value2), color = "red", size = 4) +
  geom_text(aes(x = value1, label = value1),
            hjust = 1.5, size = 3) +
  geom_text(aes(x = value2, label = value2),
            hjust = -0.5, size = 3)

# Sorted by gap size
data <- data |>
  mutate(gap = abs(value2 - value1))

ggplot(data, aes(y = fct_reorder(category, gap)))
  # ... rest of code
```

**Use Cases:**
- Before/after comparisons
- Male vs Female statistics
- Treatment vs Control groups
- Any paired measurements where gap matters

**Special Considerations:**
- Order by gap size to highlight differences
- Color points by which is larger for instant interpretation
- Add gap labels to quantify differences
- Alternative to grouped bars when comparing exactly two groups

---

### 4. CIRCULAR BARPLOTS

#### 4.1 Basic Circular Transformation

**Package:** Base ggplot2

**Technique:** Using coord_polar to wrap bars around circle

**Code Pattern:**
```r
# Basic circular barplot
ggplot(data, aes(x = category, y = value, fill = group)) +
  geom_col() +
  coord_polar(theta = "x") +  # "x" = circular, "y" = bullseye
  ylim(c(-10, max(data$value)))  # Negative creates hole in center
```

**When to Use:**
- Cyclical data (hours, months, directions, seasons)
- When spatial/circular metaphor enhances understanding
- Aesthetic requirements for reports/dashboards

**When to Avoid:**
- Standard categorical comparisons
- When precise value reading is important
- More than 20-30 categories

**Special Considerations:**
- Inner bars appear compressed (not sharing same Y axis)
- Difficult to compare values accurately
- Better for pattern recognition than exact values
- `ylim` with negative value creates donut hole

---

#### 4.2 Grouped Circular Bars with Gaps

**Package:** Base ggplot2

**Technique:** Inserting empty rows to create visual separation

**Code Pattern:**
```r
# Add empty bars for gaps
empty_bar <- 3  # Number of empty spaces per group

to_add <- data.frame(
  matrix(NA, empty_bar * nlevels(data$group), ncol(data))
)
names(to_add) <- names(data)
to_add$group <- rep(levels(data$group), each = empty_bar)

data_with_gaps <- rbind(data, to_add) |>
  arrange(group, category)

# Add ID for positioning
data_with_gaps$id <- seq(1, nrow(data_with_gaps))

ggplot(data_with_gaps, aes(x = as.factor(id), y = value, fill = group)) +
  geom_col() +
  coord_polar() +
  ylim(c(-20, max(data_with_gaps$value, na.rm = TRUE)))
```

**Use Cases:**
- Multiple groups in circular layout
- Highlighting group distinctions
- Category comparison within circular constraint

**Special Considerations:**
- Gaps created by NA rows, not geometric calculation
- Requires careful ID numbering for correct positioning
- Group labels can be placed in gap regions
- More complex data preparation than linear bars

---

#### 4.3 Label Angle Calculation

**Package:** Base ggplot2

**Technique:** Mathematical rotation for readable circular labels

**Code Pattern:**
```r
# Calculate label positioning
number_of_bar <- nrow(data_with_gaps)

label_data <- data_with_gaps |>
  mutate(
    # Calculate angle for each bar
    angle = 90 - 360 * (id - 0.5) / number_of_bar,

    # Flip labels on left side for readability
    hjust = ifelse(angle < -90, 1, 0),
    angle = ifelse(angle < -90, angle + 180, angle)
  )

ggplot(data_with_gaps, aes(x = as.factor(id), y = value)) +
  geom_col() +
  geom_text(
    data = label_data,
    aes(x = id, y = value + 10, label = category,
        hjust = hjust, angle = angle),
    size = 3
  ) +
  coord_polar()
```

**Formula Breakdown:**
- `90 - 360 * (id - 0.5) / number_of_bar`:
  - `360 / number_of_bar` = degrees per bar
  - `(id - 0.5)` = centers label on bar
  - `90 -` starts at top of circle
- `angle < -90` = labels on left side
- `angle + 180` = flips upside-down labels

**Use Cases:**
- Any circular plot requiring readable labels
- Radial dendrograms
- Circular heatmaps

**Special Considerations:**
- Essential for labels beyond ~15 bars
- Adjust `+ 10` value to control label distance from bars
- Test with different font sizes
- Consider removing labels and using interactive hover instead

---

### 5. PUBLICATION-QUALITY STYLING

#### 5.1 The Economist Style

**Packages:** Base ggplot2, custom fonts via `showtext` or `ragg`

**Technique:** Branded theme with specific typography and colors

**Key Elements:**
```r
library(showtext)
font_add_google("Roboto Condensed", "econ")  # Substitute for Econ Sans
showtext_auto()

economist_theme <- theme_minimal() +
  theme(
    text = element_text(family = "econ"),
    plot.title = element_text(face = "bold", size = 16),
    axis.text = element_text(size = 10),
    axis.title = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey85"),
    legend.position = "top"
  )

economist_colors <- c("#AD8C97", "#2FC1D3", "#076FA1", "#C7C9CB")
accent_red <- "#E5001C"

# Add brand rectangle
ggplot(data, aes(x = x, y = y)) +
  geom_col(fill = economist_colors[3]) +
  annotate("rect", xmin = -Inf, xmax = Inf,
           ymin = Inf, ymax = Inf - 0.5,
           fill = accent_red) +
  economist_theme
```

**Styling Principles:**
- Consistent custom typography throughout
- Minimal gridlines (horizontal only)
- Curated color palette
- White/light backgrounds with strategic color accents
- Source attribution in small grey text
- Bold titles with mixed weights

**Use Cases:**
- Business reports and presentations
- Publications requiring professional appearance
- Branded internal analytics

**Special Considerations:**
- Custom fonts require `showtext` or `ragg` setup
- Test font availability before deployment
- Maintain brand guidelines if using for external publication
- Balance aesthetics with accessibility

---

#### 5.2 ggthemes Package

**Package:** `ggthemes`

**Pre-built Publication Themes:**
```r
library(ggthemes)

# The Economist
ggplot(data, aes(x, y)) + geom_point() + theme_economist()

# FiveThirtyEight
ggplot(data, aes(x, y)) + geom_point() + theme_fivethirtyeight()

# Tufte (minimal)
ggplot(data, aes(x, y)) + geom_point() + theme_tufte()

# Excel (ironically)
ggplot(data, aes(x, y)) + geom_point() + theme_excel()

# Wall Street Journal
ggplot(data, aes(x, y)) + geom_point() + theme_wsj()
```

**Use Cases:**
- Quick professional styling without custom theme development
- Maintaining consistency across team visualizations
- Matching publication house styles

---

## CROSS-CUTTING TECHNIQUES

### 1. Interactivity

#### 1.1 Plotly Conversion

**Package:** `plotly`

**Technique:** One-line conversion to interactive

**Code Pattern:**
```r
library(plotly)

p <- ggplot(data, aes(x = x, y = y, color = group)) +
  geom_point()

ggplotly(p)  # Instant interactivity with hover, zoom, pan
```

**Features:**
- Automatic tooltips showing data values
- Zoom and pan capabilities
- Export to PNG
- Click legend to hide/show series
- Works with most ggplot2 geometries

**Use Cases:**
- Exploratory data analysis
- Interactive reports and dashboards
- Web-based presentations
- Sharing with non-technical audiences

**Special Considerations:**
- Some complex ggplot2 features may not convert perfectly
- File size increases for large datasets
- Requires HTML output format
- Customize tooltips with `text` aesthetic

---

#### 1.2 ggiraph for Custom Interactions

**Package:** `ggiraph`

**Technique:** Fine-grained interactivity control with CSS

**Code Pattern:**
```r
library(ggiraph)

p <- ggplot(data, aes(x = category, y = value)) +
  geom_col_interactive(
    aes(tooltip = paste0(category, ": ", value),
        data_id = category),
    hover_css = "fill:orange;stroke:black;cursor:pointer;"
  )

girafe(ggobj = p)
```

**Advanced Features:**
- Custom CSS for hover effects
- Click actions and selections
- JavaScript integration
- Linked highlighting across multiple plots

**Use Cases:**
- When plotly's defaults aren't sufficient
- Custom dashboard interactivity
- Educational visualizations
- Complex multi-plot coordination

---

### 2. Statistical Enhancements

#### 2.1 ggstatsplot Package

**Package:** `ggstatsplot`

**Technique:** Automatic statistical testing with visualization

**Code Pattern:**
```r
library(ggstatsplot)

# Violin plot with statistical comparisons
ggbetweenstats(
  data = data,
  x = group,
  y = value,
  type = "parametric",  # or "nonparametric", "robust"
  plot.type = "violin",
  pairwise.comparisons = TRUE,
  pairwise.display = "significant",
  centrality.plotting = TRUE
)
```

**Features:**
- Automatic statistical test selection
- P-value annotations
- Effect size reporting
- Sample size display
- Confidence intervals

**Use Cases:**
- Academic publications
- Exploratory analysis with statistical rigor
- Group comparisons requiring significance testing
- When visualization and statistics need integration

**Special Considerations:**
- Heavier visual weight than minimalist designs
- Best for audiences familiar with statistical notation
- May be overwhelming for general audiences
- Excellent for exploratory analysis phase

---

### 3. Ordering and Reordering

**Three Equivalent Methods:**

```r
# Method 1: forcats (Recommended)
library(forcats)
ggplot(data, aes(x = fct_reorder(name, value), y = value))

# Method 2: dplyr
library(dplyr)
data |>
  arrange(value) |>
  mutate(name = factor(name, levels = name)) |>
  ggplot(aes(x = name, y = value))

# Method 3: Base R
ggplot(data, aes(x = reorder(name, value), y = value))
```

**Key Principle:**
ggplot2 respects factor level order, NOT data frame row order. Sorting the data frame without changing factor levels has no visual effect.

---

### 4. Essential ggplot2 Extensions

**Core Extensions Mentioned:**
- `ggrepel` - Smart label positioning
- `gghighlight` - Automatic highlighting
- `ggtext` - Markdown/HTML in text
- `ggpattern` - Pattern fills for accessibility
- `ggthemes` - Pre-built themes
- `ggExtra` - Marginal distributions
- `ggh4x` - Extended faceting and scales
- `geofacet` - Geographic facet layouts
- `ggstream` - Streamgraph layouts
- `ggstatsplot` - Statistical visualizations
- `ggiraph` - Custom interactivity
- `plotly` - Quick interactivity
- `showtext` / `ragg` - Custom fonts
- `forcats` - Factor manipulation

---

## KEY INSIGHTS AND RECOMMENDATIONS

### When to Use Advanced Techniques

1. **Multiple Series Management:**
   - Few series (2-5): Color differentiation sufficient
   - Medium (6-15): Add gghighlight or direct labels
   - Many (15+): Consider faceting or interactive filtering

2. **Label Placement:**
   - Basic: Legends work fine
   - Intermediate: Direct labeling with ggrepel
   - Advanced: Inline labels with manual positioning

3. **Circular Layouts:**
   - Use only for cyclical/temporal data
   - Avoid when precise comparisons needed
   - Consider aesthetics vs. functionality trade-off

4. **Interactivity:**
   - Static reports: Focus on polished static design
   - Exploratory: Use plotly for quick interactivity
   - Custom dashboards: Invest in ggiraph

### Context Efficiency Considerations

- **Simple SKILL.md approach:** For straightforward techniques (<200 lines)
- **Bundled approach:** When examples, templates, and references add value
- Keep main instructions focused, move details to supporting files
- Prioritize patterns that generalize across chart types

### Common Pitfalls to Avoid

1. **Over-complexity:** Advanced doesn't mean complicated
2. **Dual Y-axes:** Almost always misleading
3. **Too many colors:** Limit to 5-7 distinct colors
4. **Ignoring factor levels:** Remember ggplot2 uses factor order
5. **Circular bars for non-cyclical data:** Usually worse than linear
6. **Interactive overkill:** Not every chart needs interactivity

### Best Practices Summary

✅ **DO:**
- Order categorical data meaningfully
- Use direct labels when practical
- Consider colorblind-safe palettes
- Test with intended audience
- Prioritize clarity over decoration
- Use appropriate geometries for data type

❌ **DON'T:**
- Use dual Y-axes without extreme caution
- Rotate labels when horizontal bars would work
- Add interactivity to static documents
- Ignore date formatting in time series
- Stack more than 5-7 categories
- Use 3D effects (not covered, but avoid anyway)

---

## RESOURCES

- **Main Gallery:** https://r-graph-gallery.com/
- **Evolution Charts:** https://r-graph-gallery.com/ (Evolution section)
- **Ranking Charts:** https://r-graph-gallery.com/ (Ranking section)
- **ggplot2 Documentation:** https://ggplot2.tidyverse.org/
- **Extension Gallery:** https://exts.ggplot2.tidyverse.org/

---

*Document generated 2026-03-08 from R Graph Gallery examples focusing on advanced, production-ready techniques beyond basic ggplot2 usage.*
