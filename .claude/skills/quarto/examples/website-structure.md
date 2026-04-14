# Quarto Website Structure Guide

This guide demonstrates how to structure and configure Quarto websites, including blogs, documentation sites, and multi-page projects.

## Basic Website Structure

### Minimal Website

```
my-website/
├── _quarto.yml          # Site configuration
├── index.qmd            # Home page
├── about.qmd            # About page
└── contact.qmd          # Contact page
```

**_quarto.yml:**
```yaml
project:
  type: website

website:
  title: "My Website"
  navbar:
    left:
      - href: index.qmd
        text: Home
      - about.qmd
      - contact.qmd
```

### Multi-Section Website

```
my-website/
├── _quarto.yml
├── index.qmd
├── about.qmd
├── research/
│   ├── index.qmd
│   ├── paper1.qmd
│   └── paper2.qmd
├── teaching/
│   ├── index.qmd
│   ├── course1.qmd
│   └── course2.qmd
└── blog/
    ├── index.qmd
    ├── post1.qmd
    └── post2.qmd
```

## Complete Website Configuration

### Full _quarto.yml Example

```yaml
project:
  type: website
  output-dir: docs        # GitHub Pages compatible

website:
  title: "Data Science Blog"
  site-url: "https://example.com"
  description: "Insights and tutorials on data science"
  favicon: images/favicon.png

  # Navigation
  navbar:
    background: primary
    search: true
    logo: images/logo.png
    left:
      - href: index.qmd
        text: Home
      - text: "Research"
        menu:
          - research/index.qmd
          - text: "Publications"
            href: research/publications.qmd
          - text: "Projects"
            href: research/projects.qmd
      - href: blog/index.qmd
        text: Blog
      - about.qmd
    right:
      - icon: github
        href: https://github.com/username
      - icon: twitter
        href: https://twitter.com/username

  # Sidebar (optional, for documentation)
  sidebar:
    style: "docked"
    search: true
    contents:
      - section: "Getting Started"
        contents:
          - intro/installation.qmd
          - intro/quickstart.qmd
      - section: "Guides"
        contents:
          - guides/data-viz.qmd
          - guides/modeling.qmd

  # Footer
  page-footer:
    left: "Copyright 2026, Your Name"
    right:
      - icon: github
        href: https://github.com/username
      - icon: twitter
        href: https://twitter.com/username

  # Comments (optional)
  comments:
    giscus:
      repo: username/repo

# Global formatting options
format:
  html:
    theme: cosmo
    css: styles.css
    toc: true
    toc-depth: 3
    code-fold: false
    code-tools: true
    highlight-style: github

# Execution options
execute:
  freeze: auto          # Re-render only when source changes
  warning: false
  message: false
```

## Blog Setup

### Blog Structure

```
blog/
├── index.qmd              # Blog listing page
├── posts/
│   ├── 2026-01-15-post1/
│   │   ├── index.qmd
│   │   └── images/
│   │       └── plot.png
│   ├── 2026-02-01-post2/
│   │   ├── index.qmd
│   │   └── data/
│   │       └── dataset.csv
│   └── 2026-03-01-post3/
│       └── index.qmd
└── _metadata.yml         # Shared blog metadata
```

### Blog Configuration

**blog/index.qmd:**
```yaml
---
title: "Blog"
listing:
  contents: posts
  sort: "date desc"
  type: default
  categories: true
  sort-ui: false
  filter-ui: false
  fields: [date, title, author, categories, description]
  feed: true
page-layout: full
title-block-banner: true
---

Welcome to my data science blog! Here I share tutorials, insights, and projects.
```

**blog/_metadata.yml:**
```yaml
# Options specified here will apply to all posts in this folder

# Freeze computational output
# Re-render only when source changes
freeze: true

# Enable banner style title blocks
title-block-banner: true

# Author info for all posts
author: "Your Name"

# Citations
citation: true
```

### Individual Blog Post

**blog/posts/2026-03-01-penguins/index.qmd:**
```yaml
---
title: "Analyzing Palmer Penguins"
description: "A deep dive into penguin morphology using tidyverse"
author: "Your Name"
date: "2026-03-01"
categories: [R, data-viz, tidyverse]
image: "featured-image.png"
draft: false
---

Your blog post content here...

```{r}
library(tidyverse)
library(palmerpenguins)

penguins |>
  ggplot(aes(x = species, y = body_mass_g)) +
  geom_boxplot()
```
```

## Documentation Site Structure

### Book/Documentation Format

```
docs/
├── _quarto.yml
├── index.qmd              # Landing page
├── intro/
│   ├── overview.qmd
│   └── installation.qmd
├── guides/
│   ├── basics.qmd
│   ├── advanced.qmd
│   └── examples.qmd
└── reference/
    ├── api.qmd
    └── faq.qmd
```

**_quarto.yml for documentation:**
```yaml
project:
  type: website

website:
  title: "Documentation"
  navbar:
    background: primary
  sidebar:
    style: "docked"
    background: light
    search: true
    collapse-level: 2
    contents:
      - section: "Introduction"
        contents:
          - intro/overview.qmd
          - intro/installation.qmd
      - section: "User Guides"
        contents:
          - guides/basics.qmd
          - guides/advanced.qmd
          - guides/examples.qmd
      - section: "Reference"
        contents:
          - reference/api.qmd
          - reference/faq.qmd

format:
  html:
    theme: cosmo
    toc: true
    toc-depth: 3
    code-copy: true
    code-fold: false
```

## Advanced Features

### Search

Search is automatically enabled for websites with multiple pages:

```yaml
website:
  navbar:
    search: true
  sidebar:
    search: true
```

### Custom CSS

**styles.css:**
```css
/* Custom website styling */

/* Navbar customization */
.navbar {
  font-family: 'Helvetica Neue', sans-serif;
}

/* Content area */
.quarto-title-block {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

/* Code blocks */
pre {
  border-radius: 8px;
  border-left: 4px solid #667eea;
}

/* Tables */
table {
  border-collapse: collapse;
  margin: 2em 0;
}

/* Callouts */
.callout {
  border-radius: 8px;
}
```

Reference in _quarto.yml:
```yaml
format:
  html:
    css: styles.css
```

### Custom Layouts

**Custom listing layout (_custom-listing.ejs):**
```html
<div class="post-card">
  <img src="<%- image %>" alt="<%- title %>">
  <h3><%- title %></h3>
  <p class="meta"><%- date %> | <%- author %></p>
  <p><%- description %></p>
  <a href="<%- url %>">Read more →</a>
</div>
```

Use in listing:
```yaml
listing:
  template: _custom-listing.ejs
```

### Multiple Languages

```yaml
website:
  navbar:
    left:
      - href: index.qmd
        text: Home
      - href: index-es.qmd
        text: Inicio (Español)
```

## Publishing Options

### GitHub Pages

**_quarto.yml:**
```yaml
project:
  type: website
  output-dir: docs
```

Then enable GitHub Pages with source: `main` branch, `docs` folder.

### Netlify

**_quarto.yml:**
```yaml
project:
  type: website
  output-dir: _site
```

Create **netlify.toml:**
```toml
[build]
  command = "quarto render"
  publish = "_site"

[build.environment]
  QUARTO_VERSION = "1.4.550"
```

### Quarto Pub

```bash
quarto publish quarto-pub
```

### Custom Domain

In _quarto.yml:
```yaml
website:
  site-url: "https://yourdomain.com"
```

Create CNAME file in project root:
```
yourdomain.com
```

## Complete Example: Personal Website

### File Structure
```
personal-site/
├── _quarto.yml
├── styles.css
├── index.qmd
├── about.qmd
├── cv.qmd
├── research/
│   ├── index.qmd
│   ├── publications.qmd
│   └── projects.qmd
├── blog/
│   ├── index.qmd
│   ├── _metadata.yml
│   └── posts/
│       ├── 2026-01-15-first-post/
│       │   └── index.qmd
│       └── 2026-02-20-second-post/
│           └── index.qmd
└── images/
    ├── profile.jpg
    └── logo.png
```

### Configuration

**_quarto.yml:**
```yaml
project:
  type: website
  output-dir: docs

website:
  title: "Dr. Jane Smith"
  description: "Data Scientist & Researcher"
  site-url: "https://janesmith.github.io/site"

  navbar:
    background: "#2C3E50"
    foreground: light
    logo: images/logo.png
    left:
      - href: index.qmd
        text: Home
      - href: research/index.qmd
        text: Research
      - href: blog/index.qmd
        text: Blog
      - href: cv.qmd
        text: CV
      - href: about.qmd
        text: About
    right:
      - icon: github
        href: https://github.com/janesmith
      - icon: twitter
        href: https://twitter.com/janesmith
      - icon: linkedin
        href: https://linkedin.com/in/janesmith
      - icon: envelope
        href: mailto:jane@example.com

  page-footer:
    left: |
      © 2026 Jane Smith | Built with [Quarto](https://quarto.org)
    right:
      - icon: github
        href: https://github.com/janesmith
      - icon: twitter
        href: https://twitter.com/janesmith

format:
  html:
    theme:
      light: [cosmo, styles.css]
      dark: [darkly, styles.css]
    toc: true
    code-fold: true
    code-tools: true
    highlight-style: github
    link-external-newwindow: true

execute:
  freeze: auto
```

### Home Page

**index.qmd:**
```yaml
---
title: "Jane Smith"
subtitle: "Data Scientist | R Enthusiast | Open Science Advocate"
image: images/profile.jpg
about:
  template: jolla
  image-shape: round
  image-width: 15em
  links:
    - icon: github
      text: GitHub
      href: https://github.com/janesmith
    - icon: twitter
      text: Twitter
      href: https://twitter.com/janesmith
    - icon: envelope
      text: Email
      href: mailto:jane@example.com
---

## Welcome!

I'm a data scientist specializing in statistical modeling and data visualization.
I work primarily with R and love sharing knowledge through blog posts and tutorials.

### Research Interests

- Bayesian statistics
- Machine learning applications
- Reproducible research
- Data visualization

### Recent Posts

::: {#recent-posts}
:::
```

## Rendering Commands

### Render entire site
```bash
quarto render
```

### Preview with live reload
```bash
quarto preview
```

### Render specific page
```bash
quarto render about.qmd
```

### Publish to Quarto Pub
```bash
quarto publish quarto-pub
```

### Publish to GitHub Pages
```bash
quarto publish gh-pages
```

### Publish to Netlify
```bash
quarto publish netlify
```

## Tips and Best Practices

1. **Freeze computation**: Use `freeze: auto` to avoid re-rendering unchanged content
2. **Organize by topic**: Use subdirectories for different content sections
3. **Consistent metadata**: Use `_metadata.yml` files for shared options
4. **Test locally**: Always preview changes before publishing
5. **Use drafts**: Set `draft: true` for work-in-progress posts
6. **Optimize images**: Compress images to reduce site size
7. **Cross-references**: Use `@fig-label` and `@tbl-label` for professional references
8. **RSS feeds**: Blog listings automatically generate RSS feeds
9. **Analytics**: Add Google Analytics or Plausible in `_quarto.yml`
10. **Version control**: Use Git to track changes to your site

## Resources

- [Quarto Websites Guide](https://quarto.org/docs/websites/)
- [Quarto Blog Guide](https://quarto.org/docs/websites/website-blog.html)
- [Gallery of Quarto Websites](https://quarto.org/docs/gallery/#websites)
- [Publishing Guide](https://quarto.org/docs/publishing/)
