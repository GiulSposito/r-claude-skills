# R Graph Gallery - Distribution & Correlation Charts

Advanced ggplot2 techniques from the R Graph Gallery for distribution and correlation visualizations. These patterns go beyond basic usage and show production-ready techniques.

---

## DISTRIBUTION CHARTS

### Violin Plots

#### Combining Violin + Boxplot

**Technique**: Layer boxplot inside violin for dual perspective (distribution shape + quartiles)

```r
ggplot(data, aes(x = group, y = value, fill = group)) +
  geom_violin(width = 1.4) +
  geom_boxplot(width = 0.1, color = "grey", alpha = 0.2) +
  scale_fill_viridis_d()
```

**Key Pattern**:
- Violin width (1.4) provides main visual
- Boxplot width (0.1) creates compact overlay (14:1 ratio)
- Use `alpha = 0.2` for subtle integration
- **Order matters**: violin first, then boxplot

**When to Use**: Show both distribution shape AND statistical summaries without separate charts

**Special Considerations**:
- Adjust width ratio based on number of groups
- Grey boxplot provides neutral contrast
- Can add sample size to axis labels with `paste0(group, " (n=", n, ")")`

---

#### Horizontal Violin Plots

**Technique**: Use `coord_flip()` for better label readability with long category names

```r
library(forcats)

data |>
  mutate(category = fct_reorder(category, value)) |>
  ggplot(aes(x = category, y = value, fill = category)) +
    geom_violin(width = 2.1, linewidth = 0.2) +
    scale_fill_viridis_d() +
    coord_flip() +
    theme_minimal() +
    theme(legend.position = "none")
```

**Key Pattern**:
- Reorder groups with `fct_reorder()` BEFORE plotting
- Apply `coord_flip()` at END of ggplot chain
- Adjust width parameter for horizontal orientation (typically larger)
- Remove legend when fill matches x-axis (redundant)

**When to Use**: Long category names, many groups, or when comparison emphasis is more important than individual values

---

#### Grouped Violin Charts

**Technique**: Hierarchical grouping with position_dodge or faceting

```r
# Position dodge approach
ggplot(data, aes(x = main_group, y = value, fill = subgroup)) +
  geom_violin(position = position_dodge(width = 0.9)) +
  scale_fill_brewer(palette = "Set2")

# Faceting approach (clearer for many subgroups)
ggplot(data, aes(x = subgroup, y = value, fill = subgroup)) +
  geom_violin() +
  facet_wrap(~ main_group, scales = "free_x") +
  theme(legend.position = "none")
```

**When to Use**: Comparing distributions across groups AND subgroups simultaneously

**Choose position_dodge when**: 2-3 subgroups, direct comparison priority
**Choose faceting when**: >3 subgroups, clarity over compactness

---

### Density Plots

#### Professional Styling with hrbrthemes

**Technique**: Polished appearance with fill, color, and alpha

```r
library(hrbrthemes)

data |>
  filter(price < 300) |>
  ggplot(aes(x = price)) +
    geom_density(fill = "#69b3a2", color = "#e9ecef", alpha = 0.8) +
    labs(title = "Price Distribution",
         x = "Price ($)", y = "Density") +
    theme_ipsum()
```

**Key Pattern**:
- `fill` for main area color
- `color` for outline (use light color like "#e9ecef" for subtle definition)
- `alpha = 0.8` for subtle transparency
- `theme_ipsum()` from hrbrthemes package for clean, professional look

**When to Use**: Publication-quality single distribution plots

---

#### Multiple Overlapping Densities

**Technique**: Strategic transparency for overlap visibility

```r
ggplot(data, aes(x = value, fill = type)) +
  geom_density(alpha = 0.6) +
  scale_fill_manual(values = c("#69b3a2", "#404080")) +
  labs(title = "Distribution Comparison by Type") +
  theme_minimal()
```

**Key Pattern**:
- `alpha = 0.6` is sweet spot for 2-3 overlapping densities
- Use distinct colors from opposite parts of color wheel
- Lower alpha (0.4) for >3 groups
- Higher alpha (0.7-0.8) for 2 groups with minimal overlap

**Gotcha**: More than 4-5 overlapping densities becomes unreadable → use faceting or ridgelines instead

---

#### Stacked Density with position="fill"

**Technique**: Show proportional contribution at each point

```r
ggplot(data, aes(x = value, fill = category)) +
  geom_density(position = "fill", alpha = 0.7) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(y = "Proportion") +
  scale_fill_viridis_d()
```

**When to Use**: Understand how composition changes across the range
**Alternative**: Streamgraph for time series proportions

---

#### Direct Labeling with geomtextpath

**Technique**: Labels directly on density curves instead of legend

```r
library(geomtextpath)

ggplot(data, aes(x = value, color = group, label = group)) +
  geom_textdensity(size = 4, fontface = 2, hjust = 0.2, vjust = 0.3) +
  scale_color_viridis_d() +
  theme_minimal() +
  theme(legend.position = "none")
```

**Key Pattern**:
- geomtextpath package provides geom_textdensity()
- Adjust `hjust` and `vjust` to control label positioning
- Remove legend (redundant with direct labels)

**When to Use**: 2-4 groups with minimal overlap, publication-quality plots

---

### Histograms

#### Multiple Overlapping Histograms

**Technique**: position='identity' with transparency

```r
ggplot(data, aes(x = value, fill = group)) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 30) +
  scale_fill_manual(values = c("#69b3a2", "#404080"))
```

**Key Pattern**:
- `position = "identity"` overlays histograms (default is "stack")
- `alpha = 0.5` for 2 groups, lower (0.3-0.4) for 3 groups
- Specify `bins` explicitly (never rely on default)

**Alternatives**:
- `position = "dodge"` for side-by-side bars
- `geom_freqpoly()` for line-based comparison (clearer with 3+ groups)
- Faceting for >3 groups

---

### Boxplots

#### Boxplot with Individual Points (Jitter)

**Technique**: Show full distribution with jittered points

```r
ggplot(data, aes(x = category, y = value)) +
  geom_boxplot(outlier.shape = NA, fill = "lightblue", alpha = 0.5) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
  theme_minimal()
```

**Key Pattern**:
- Set `outlier.shape = NA` in boxplot to avoid duplicate outlier points
- `width = 0.2` controls jitter spread (adjust for number of groups)
- `alpha = 0.3` for jitter points to show density
- Layer boxplot FIRST, then jitter

**When to Use**: Small to medium datasets (<500 points per group), want to show individual observations

---

#### Boxplot with stat_summary for Means

**Technique**: Add mean markers automatically

```r
ggplot(data, aes(x = category, y = value)) +
  geom_boxplot(fill = "steelblue", alpha = 0.5) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 4, fill = "red") +
  labs(caption = "Red diamonds show means")
```

**Key Pattern**:
- `stat_summary()` calculates statistics on-the-fly (no pre-calculation needed)
- `fun = mean` specifies statistic (can use median, sd, etc.)
- `shape = 23` is filled diamond (good for means vs median line)
- `fill` for shape applies to interior

**When to Use**: Show mean alongside median for distributions that might be skewed

---

#### Variable Width Boxplots

**Technique**: Box width proportional to sample size

```r
ggplot(data, aes(x = category, y = value)) +
  geom_boxplot(varwidth = TRUE, fill = "steelblue") +
  labs(caption = "Box width proportional to sqrt(n)")
```

**When to Use**: Groups have very different sample sizes, want to visually communicate confidence

---

#### Notched Boxplots for Median Comparison

**Technique**: Notches show 95% CI for median

```r
ggplot(data, aes(x = category, y = value, fill = category)) +
  geom_boxplot(notch = TRUE) +
  scale_fill_brewer(palette = "Set2") +
  theme_minimal()
```

**Interpretation**: Non-overlapping notches suggest significant median difference (α≈0.05)

**When to Use**: Formal median comparisons, statistical reporting

---

### Ridgeline Plots (ggridges)

**Technique**: Stacked density plots for distribution comparison

```r
library(ggridges)

ggplot(data, aes(x = value, y = category, fill = category)) +
  geom_density_ridges(alpha = 0.7, scale = 0.9) +
  scale_fill_viridis_d() +
  theme_ridges() +
  theme(legend.position = "none")
```

**Key Pattern**:
- Requires ggridges package
- `scale` parameter controls overlap (0.9 = slight separation, 1.2 = moderate overlap)
- `alpha = 0.7` for filled ridges
- `theme_ridges()` provides appropriate defaults

**When to Use**: Comparing distributions across many categories (>5), time series of distributions

---

#### Histogram-Style Ridgelines

**Technique**: Use stat="binline" for discrete appearance

```r
ggplot(data, aes(x = value, y = category, fill = category)) +
  geom_density_ridges(stat = "binline", bins = 30, scale = 0.95, alpha = 0.7) +
  scale_fill_viridis_d()
```

**When to Use**: Discrete or count data, histogram-like appearance preferred

---

#### Ordering Ridgelines

**Technique**: Reorder categories by statistic

```r
library(forcats)

data |>
  mutate(category = fct_reorder(category, value, .fun = median)) |>
  ggplot(aes(x = value, y = category, fill = category)) +
    geom_density_ridges()
```

**Ordering strategies**:
- `median` - Center of distribution (most common)
- `mean` - For symmetric distributions
- `max` or `min` - Highlight extremes
- Custom function - `function(x) quantile(x, 0.75)` for 75th percentile

---

## CORRELATION CHARTS

### Scatter Plots

#### Mapping 4+ Dimensions

**Technique**: Combine x, y, color, size, shape, alpha

```r
ggplot(data, aes(x = var1, y = var2,
                 color = category,
                 size = var3,
                 shape = group)) +
  geom_point(alpha = 0.6) +
  scale_color_viridis_d() +
  scale_size_area(max_size = 10) +
  labs(title = "Multi-dimensional Relationships")
```

**Key Pattern**:
- Limit to 3-4 aesthetics for readability
- Use `scale_size_area()` for perceptually accurate sizing
- `alpha = 0.6` helps with overplotting
- Color > Size > Shape for perceptual priority

**Best combinations**:
- x, y, color (3D) - Most common
- x, y, color, size (4D) - For bubble charts
- x, y, color, shape (4D) - For categorical with limited levels (<7)

**Avoid**: >4 aesthetics becomes cognitively overwhelming

---

#### Smart Label Positioning with ggrepel

**Technique**: Automatic non-overlapping labels

```r
library(ggrepel)

ggplot(data, aes(x = var1, y = var2, label = name)) +
  geom_point(aes(color = category), size = 3) +
  geom_text_repel(
    box.padding = 0.5,
    point.padding = 0.3,
    segment.color = "grey50",
    max.overlaps = 10
  ) +
  theme_minimal()
```

**Key Pattern**:
- ggrepel automatically positions labels to avoid overlap
- `box.padding` - space around label box
- `point.padding` - minimum distance from point
- `segment.color` - color of connecting lines
- `max.overlaps` - hide labels if overcrowded

**Advanced**:
```r
geom_text_repel(
  data = data |> filter(important == TRUE),  # Label subset only
  nudge_x = 2,  # Encourage rightward positioning
  direction = "y",  # Restrict to vertical movement only
  force = 2  # Repulsion strength
)
```

---

#### Marginal Distributions with ggMarginal

**Technique**: Add density/histogram to scatter plot margins

```r
library(ggExtra)

p <- ggplot(data, aes(x = var1, y = var2, color = group)) +
  geom_point() +
  theme_minimal()

ggMarginal(p, type = "density", groupFill = TRUE)
```

**Types available**:
- `"density"` - Smooth density curves (default, most elegant)
- `"histogram"` - Binned counts
- `"boxplot"` - Show quartiles
- `"violin"` - Distribution shape

**Key Pattern**:
- Create base plot first, save to variable
- Apply ggMarginal() to saved plot
- `groupFill = TRUE` matches scatter plot colors
- `groupColour = TRUE` for outlined groups

---

#### Connected Scatter for Time Series

**Technique**: Show temporal order with connecting lines

```r
ggplot(data, aes(x = var1, y = var2)) +
  geom_path(color = "grey70", linewidth = 0.8, arrow = arrow(length = unit(0.2, "cm"))) +
  geom_point(aes(color = year), size = 3) +
  scale_color_viridis_c() +
  theme_minimal()
```

**Key Pattern**:
- `geom_path()` connects points in data order
- Use `arrow` to show direction
- Color points by time for temporal context
- Grey path provides structure without overpowering

**When to Use**: Time series plotted as scatter, showing trajectory/evolution

---

### Heatmaps

#### Correlation Matrix Heatmap

**Technique**: geom_tile() for matrix visualization

```r
library(reshape2)

# Compute correlation
cor_matrix <- cor(data_numeric)
cor_melted <- melt(cor_matrix)

ggplot(cor_melted, aes(Var1, Var2, fill = value)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = round(value, 2)), size = 3) +
  scale_fill_gradient2(
    low = "blue", mid = "white", high = "red",
    midpoint = 0, limits = c(-1, 1),
    name = "Correlation"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )
```

**Key Pattern**:
- Use `scale_fill_gradient2()` for diverging scale (correlation has meaningful zero)
- `midpoint = 0` centers white at zero correlation
- `geom_text()` adds actual values
- White borders between tiles improve readability
- Remove grid (redundant with tiles)

---

#### GGally ggpairs for Comprehensive View

**Technique**: All pairwise relationships automatically

```r
library(GGally)

ggpairs(data,
        columns = c("var1", "var2", "var3", "var4"),
        aes(color = category, alpha = 0.5),
        upper = list(continuous = "cor"),
        lower = list(continuous = "smooth"),
        diag = list(continuous = "densityDiag"))
```

**Key Pattern**:
- Automatically creates matrix of scatter, correlation, and distribution plots
- `upper` - what to show above diagonal (correlation values common)
- `lower` - what to show below diagonal (scatter with smooth common)
- `diag` - diagonal shows distributions
- Great for exploratory data analysis

**When to Use**: Initial exploration, understanding multivariate structure

---

### Bubble Charts

#### Proper Size Scaling

**Technique**: scale_size_area() for perceptual accuracy

```r
ggplot(data, aes(x = gdp, y = life_exp, size = population, color = continent)) +
  geom_point(alpha = 0.6) +
  scale_size_area(max_size = 20, name = "Population") +  # NOT scale_size()
  scale_x_log10(labels = scales::dollar_format()) +
  scale_color_viridis_d() +
  theme_minimal()
```

**Key Pattern**:
- **Use `scale_size_area()`** - area proportional to value (perceptually accurate)
- **NOT `scale_size()`** - radius proportional (misleading - area scales quadratically)
- `max_size` controls largest bubble (default 6, increase for emphasis)
- Often use log scales for skewed variables (GDP, population)

---

#### Handling Overlap

**Technique**: Strategic ordering and transparency

```r
data |>
  arrange(desc(size_var)) |>  # Plot largest first (background)
  ggplot(aes(x = var1, y = var2, size = size_var, color = category)) +
    geom_point(alpha = 0.4) +
    scale_size_area(max_size = 15)
```

**Strategies for overlap**:
1. **Transparency** (`alpha = 0.4-0.6`)
2. **Ordering** (largest first, via `arrange(desc())`)
3. **Faceting** (by category)
4. **Interactive** (plotly for hover information)

---

### 2D Density

#### Contour Lines

**Technique**: Show density as topographic map

```r
ggplot(data, aes(x = var1, y = var2)) +
  geom_density_2d(color = "blue", linewidth = 0.5) +
  geom_point(alpha = 0.2, size = 0.5) +
  theme_minimal()
```

**When to Use**: Want to see density structure while keeping points visible

---

#### Filled Contours

**Technique**: Color-filled density regions

```r
ggplot(data, aes(x = var1, y = var2)) +
  stat_density_2d(
    aes(fill = after_stat(level)),
    geom = "polygon",
    alpha = 0.5
  ) +
  geom_point(size = 0.5, alpha = 0.3) +
  scale_fill_viridis_c() +
  theme_minimal()
```

**Key Pattern**:
- `stat_density_2d()` with `geom = "polygon"`
- `after_stat(level)` maps computed density to fill
- Add points layer for data context

---

#### Raster/Tile 2D Density

**Technique**: Pixel-based density for massive datasets

```r
ggplot(data, aes(x = var1, y = var2)) +
  stat_density_2d(
    aes(fill = after_stat(density)),
    geom = "raster",
    contour = FALSE
  ) +
  scale_fill_viridis_c() +
  theme_minimal()
```

**When to Use**: Extremely large datasets (>100k points), prioritize computation speed

---

#### Hexbin for Massive Datasets

**Technique**: Hexagonal binning (requires hexbin package)

```r
library(hexbin)

ggplot(large_data, aes(x = var1, y = var2)) +
  geom_hex(bins = 50) +
  scale_fill_viridis_c(name = "Count", trans = "log10") +
  theme_minimal()
```

**Key Pattern**:
- Hexagons tessellate better than squares (more accurate)
- `bins` controls resolution (30-60 typical)
- `trans = "log10"` for skewed count distributions
- Much faster than density calculations for large data

**Performance**:
- 10k-100k points: geom_point with alpha
- 100k-1M points: hexbin
- >1M points: raster 2D density

---

### Connected Scatter / Dumbbell Charts

#### Dumbbell Chart for Before/After Comparison

**Technique**: Paired comparisons with gap highlighting

```r
ggplot(data, aes(y = category)) +
  # Gap line
  geom_segment(
    aes(x = before, xend = after, yend = category),
    color = "grey70",
    linewidth = 1
  ) +
  # Before points
  geom_point(aes(x = before), color = "red", size = 4) +
  # After points
  geom_point(aes(x = after), color = "blue", size = 4) +
  labs(
    title = "Before vs After Comparison",
    caption = "Red = Before, Blue = After"
  ) +
  theme_minimal()
```

**Key Pattern**:
- `geom_segment()` for connecting lines
- Two separate `geom_point()` calls for before/after
- Order matters: segment first, then points (overlays)
- Use contrasting colors for endpoints

**Variations**:
```r
# Color by direction of change
data |>
  mutate(change_direction = ifelse(after > before, "Increase", "Decrease")) |>
  ggplot(aes(y = category, color = change_direction)) +
    geom_segment(aes(x = before, xend = after, yend = category), linewidth = 1.5) +
    scale_color_manual(values = c("Decrease" = "red", "Increase" = "blue"))
```

---

#### End-of-Line Labels

**Technique**: Labels at final point instead of legend

```r
# Get last point per group
last_points <- data |>
  group_by(group) |>
  slice_max(time, n = 1)

ggplot(data, aes(x = time, y = value, color = group)) +
  geom_line(linewidth = 1) +
  geom_text(
    data = last_points,
    aes(label = group),
    hjust = 0, nudge_x = 0.1,
    size = 4
  ) +
  scale_color_viridis_d() +
  theme_minimal() +
  theme(legend.position = "none")
```

**Key Pattern**:
- Filter to last observation per group
- Use `hjust = 0` (left-align) with `nudge_x` for positioning
- Remove legend (redundant)
- May need `coord_cartesian(clip = "off")` if labels extend past plot area

---

## Cross-Cutting Techniques

### Layering Strategy

**Order matters** for visual hierarchy:

1. **Background elements** (reference lines, shaded regions)
2. **Main data** (geom_point, geom_line, etc.)
3. **Statistical overlays** (smooth, density, summaries)
4. **Annotations** (text, labels, arrows)
5. **Foreground emphasis** (highlighted points/lines)

```r
ggplot(data, aes(x, y)) +
  # 1. Background
  annotate("rect", xmin = 0, xmax = 10, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.5) +
  # 2. Main data
  geom_point(alpha = 0.3, color = "grey70") +
  # 3. Statistical
  geom_smooth(method = "lm", color = "blue") +
  # 4. Annotations
  annotate("text", x = 5, y = 20, label = "Key Region") +
  # 5. Emphasis
  geom_point(data = important_subset, color = "red", size = 3)
```

---

### Transparency Hierarchy

Strategic alpha values for visual depth:

- **0.1-0.2**: Very faint background/context
- **0.3-0.4**: Background data points
- **0.5-0.6**: Main data with moderate overlap
- **0.7-0.8**: Main data with light overlap
- **0.9-1.0**: Foreground/emphasis

---

### Reordering by Data

Always reorder categorical variables by data values for better communication:

```r
library(forcats)

# Reorder by value
data |>
  mutate(category = fct_reorder(category, value)) |>
  ggplot(...)

# Reorder by value within groups
data |>
  mutate(category = fct_reorder2(category, group, value)) |>
  ggplot(...)

# Manual reorder
data |>
  mutate(category = fct_relevel(category, "First", "Second", "Third")) |>
  ggplot(...)
```

**Default alphabetical order is rarely what you want!**

---

### When to Use Small Multiples vs Overlays

**Use overlays (single plot) when**:
- 2-4 groups
- Direct comparison is priority
- Groups have similar ranges
- Overlap is manageable with transparency

**Use faceting (small multiples) when**:
- >4 groups
- Within-group patterns are priority
- Groups have very different ranges (`scales = "free"`)
- Clarity over compactness

---

## Essential Packages

**Core**:
- ggplot2, dplyr

**Distribution**:
- ggridges (ridgeline plots)
- hrbrthemes (professional themes)
- viridis (color scales)

**Annotation & Labels**:
- ggrepel (smart label positioning)
- ggtext (HTML/markdown text)
- geomtextpath (text on paths)

**Enhanced Visualizations**:
- ggExtra (marginal distributions)
- GGally (matrix plots)
- patchwork (plot composition)

**Specialized**:
- hexbin (hexagonal binning)
- ggstatsplot (integrated statistics)

---

**See [gallery-evolution-ranking.md](gallery-evolution-ranking.md) for time series and ranking charts.**
**See [gallery-best-practices.md](gallery-best-practices.md) for curated examples.**
**See [../references/advanced-customization.md](../references/advanced-customization.md) for advanced theming.**
