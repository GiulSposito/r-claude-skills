# Tidyverse Gap Analysis: Comprehensive Report

**Date**: 2026-03-09
**Purpose**: Identify gaps in existing R skills and recommend structure for comprehensive tidyverse expertise

---

## Executive Summary

The repository contains **three main R skills** with overlapping tidyverse coverage:
1. **r-datascience** (619 lines) - Broad overview of tidyverse + tidymodels
2. **tidyverse-patterns** (335 lines) - Modern syntax and best practices
3. **ggplot2** (449 lines + extensive supporting files) - Visualization expert (user-invocable: false)

**Key Finding**: There's significant **breadth** but limited **depth** in tidyverse data manipulation coverage. The skills provide good overviews but lack deep expertise in advanced patterns, edge cases, and real-world problem-solving.

---

## Detailed Coverage Analysis

### 1. r-datascience/SKILL.md (619 lines)

**Scope**: Broad data science skill covering tidyverse, tidymodels, and statistical modeling

**Tidyverse Coverage**:
- **dplyr basics**: filter, select, mutate, summarize, group_by (lines 213-242)
- **tidyr basics**: pivot_longer, pivot_wider, separate, unite, nesting (lines 244-271)
- **purrr basics**: map, map2, pmap, map_if, reduce, safely (lines 273-294)
- **Workflow examples**: Data analysis pipeline, ML pipeline (lines 100-209)

**Depth Assessment**:
- ✅ Good: High-level workflow guidance
- ✅ Good: Integration with ggplot2 and tidymodels
- ✅ Good: Best practices checklist
- ⚠️ Limited: No advanced dplyr patterns (window functions, complex joins)
- ⚠️ Limited: No advanced tidyr patterns (nesting strategies, complex pivots)
- ⚠️ Limited: No purrr advanced patterns (walk, imap, complex error handling)
- ⚠️ Limited: No stringr coverage beyond basic mentions
- ❌ Missing: forcats (factor handling)
- ❌ Missing: lubridate (date/time manipulation)
- ❌ Missing: Real-world problem-solving patterns
- ❌ Missing: Performance optimization strategies
- ❌ Missing: Debugging complex pipes

**Supporting Files**:
- `references/data-wrangling.md` (563 lines) - Comprehensive dplyr/tidyr reference
  - Covers: Five verbs, group_by, reshaping, joins, across()
  - Good depth on basics but lacks advanced scenarios

**Focus**: 80% on ML workflows, 20% on data wrangling

---

### 2. tidyverse-patterns/SKILL.md (335 lines)

**Scope**: Modern tidyverse syntax and migration guide (dplyr 1.1+, R 4.3+)

**Tidyverse Coverage**:
- ✅ **Native pipe** `|>` vs `%>%` (lines 17-32)
- ✅ **Modern joins** with `join_by()` including inequality/rolling joins (lines 34-70)
- ✅ **Per-operation grouping** `.by` vs `group_by()` (lines 99-135)
- ✅ **pick() and across()** for column operations (lines 102-129)
- ✅ **Modern purrr** `list_rbind()` vs deprecated `map_dfr()` (lines 137-166)
- ✅ **stringr comprehensive patterns** (lines 168-210)
- ✅ **Migration guide** from base R and old tidyverse (lines 270-334)

**Depth Assessment**:
- ✅ Excellent: Modern syntax patterns (dplyr 1.1+)
- ✅ Excellent: Migration patterns
- ✅ Good: stringr coverage (comprehensive vs r-datascience)
- ⚠️ Limited: No practical examples, mostly syntax reference
- ⚠️ Limited: No problem-solving scenarios
- ❌ Missing: forcats, lubridate
- ❌ Missing: Complex real-world use cases
- ❌ Missing: Performance considerations
- ❌ Missing: Troubleshooting guidance

**Focus**: 100% syntax modernization, 0% applied problem-solving

---

### 3. ggplot2/SKILL.md (449 lines + 11 supporting files)

**Scope**: Comprehensive ggplot2 visualization expert (user-invocable: false)

**Structure**:
- Main SKILL.md: Grammar of graphics, workflow, quick reference
- Supporting files:
  - `references/geoms-reference.md`
  - `references/scales-reference.md`
  - `references/themes-styling.md`
  - `references/best-practices.md`
  - `references/advanced-customization.md`
  - `examples/plot-examples.md`
  - `examples/gallery-*.md` (3 files)
  - `templates/plot-templates.md`

**Depth Assessment**:
- ✅ Excellent: Comprehensive ggplot2 coverage
- ✅ Excellent: Layered structure with supporting files
- ✅ Excellent: Examples and templates
- ✅ Excellent: Best practices and troubleshooting
- ✅ Good: Programming with ggplot2 (tidy eval)

**Note**: This skill demonstrates the **ideal structure** for a comprehensive tidyverse skill - main SKILL.md with extensive supporting references, examples, and templates.

---

## Gap Analysis: What's Missing

### Critical Gaps (Not Covered Anywhere)

#### 1. **forcats - Factor Manipulation** (0% coverage)
No mention of forcats anywhere in the three skills.

**Missing capabilities**:
- `fct_reorder()`, `fct_infreq()`, `fct_lump()`, `fct_recode()`
- Factor level reordering for visualization
- Combining and collapsing factors
- Missing value handling in factors

**Impact**: High - Factor manipulation is critical for categorical data and ggplot2 ordering

---

#### 2. **lubridate - Date/Time Manipulation** (0% coverage)
No mention of lubridate in any skill.

**Missing capabilities**:
- Parsing dates: `ymd()`, `mdy()`, `dmy()`
- Extracting components: `year()`, `month()`, `day()`, `hour()`
- Date arithmetic: `days()`, `weeks()`, `months()`, `years()`
- Time zones and periods vs durations
- Rounding dates: `floor_date()`, `ceiling_date()`, `round_date()`

**Impact**: High - Date/time manipulation is extremely common in real-world data

---

#### 3. **Advanced dplyr Patterns** (~20% coverage)
Basic verbs covered, but missing advanced patterns:

**Missing**:
- **Window functions**: `row_number()`, `ntile()`, `lead()`, `lag()`, `cumsum()` in real scenarios
- **Complex joins**: Multiple join conditions, join diagnostics, join problems
- **Grouped mutations**: Within-group rankings, standardization, differences
- **slice_ family**: `slice_head()`, `slice_tail()`, `slice_min()`, `slice_max()`, `slice_sample()`
- **Advanced filtering**: `filter()` with `all()`, `any()`, `if_all()`, `if_any()`
- **Column-wise operations**: Complex `across()` patterns with `.names` and multiple functions

**Impact**: Medium-High - These patterns solve common real-world problems

---

#### 4. **Advanced tidyr Patterns** (~30% coverage)
Basics covered, but missing advanced use cases:

**Missing**:
- **Nesting strategies**: When and why to nest, working with list-columns
- **Complex pivots**: Multi-value pivots, pivoting with multiple value columns
- **Rectangle**: `unnest()`, `unnest_wider()`, `unnest_longer()`, `hoist()`
- **Missing data patterns**: `complete()`, `expand()`, `crossing()`, `nesting()`
- **separate_wider_**: Modern alternatives to `separate()` (dplyr 1.1+)

**Impact**: Medium - Needed for hierarchical data and complex reshaping

---

#### 5. **purrr Advanced Patterns** (~40% coverage)
Basics covered, missing advanced patterns:

**Missing**:
- **walk family**: Side effects, file I/O, plotting
- **imap**: Index-aware mapping
- **Error handling**: `safely()`, `possibly()`, `quietly()` in practice
- **Predicate functions**: `keep()`, `discard()`, `compact()`, `detect()`
- **List manipulation**: `pluck()`, `chuck()`, `flatten()`, `transpose()`
- **Reduce patterns**: Complex reductions, accumulate
- **Parallel processing**: `in_parallel()` with mirai (covered briefly in tidyverse-patterns)

**Impact**: Medium - Critical for functional programming workflows

---

#### 6. **stringr Deep Patterns** (~30% coverage)
Basic functions covered in tidyverse-patterns, missing depth:

**Missing**:
- **Regex patterns library**: Common patterns for emails, phone numbers, URLs, etc.
- **String extraction**: Complex `str_extract_all()` patterns
- **Boundary detection**: `boundary()` for word/character/sentence splitting
- **Locale handling**: Working with non-English text
- **String normalization**: Case folding, Unicode normalization

**Impact**: Medium - Text data is increasingly common

---

### Moderate Gaps (Partial Coverage)

#### 7. **Real-World Problem Patterns** (~10% coverage)
Skills show basic workflows but lack real problem-solving patterns:

**Missing**:
- Cleaning messy data (inconsistent types, malformed values)
- Handling duplicates (finding, diagnosing, removing)
- Data validation patterns
- Exploratory data analysis workflows
- Data quality checks
- Common data transformation recipes (wide to long with multiple measures, etc.)

**Impact**: High - This is what users actually need help with

---

#### 8. **Performance and Debugging** (~5% coverage)
Brief mentions in tidyverse-patterns, but insufficient:

**Missing**:
- Profiling tidyverse code
- Common performance pitfalls (growing objects, inefficient joins)
- When to use data.table vs tidyverse
- Debugging complex pipes (intermediate results, print debugging)
- Memory efficiency patterns

**Impact**: Medium - Important for production code

---

#### 9. **Integration Patterns** (~20% coverage)
Some coverage in r-datascience, but not comprehensive:

**Missing**:
- Tidyverse + SQL workflows
- Tidyverse + databases (dbplyr)
- Tidyverse + Apache Arrow/Parquet
- Tidyverse + big data (chunking, sampling strategies)
- Tidyverse + APIs (httr/httr2 integration)

**Impact**: Medium-High - Real-world data doesn't always fit in memory

---

### Minor Gaps (Mostly Covered)

#### 10. **readr** (~60% coverage)
Basic `read_csv()` covered, missing some advanced features:

**Missing**:
- Column type specification
- Parsing problems diagnosis
- `read_lines()`, `read_file()` for raw text
- Writing functions (`write_csv()`, `write_rds()`)

**Impact**: Low - Basic usage is well-covered

---

## Comparison to Knowledge Base

The `knowledge-base/` directory contains **extensive extracted knowledge** (164K from 5 authoritative sources):

1. **r4ds-knowledge-extraction.md** (21K) - R for Data Science
2. **mdsr-knowledge-extraction.md** (27K) - Modern Data Science with R
3. **tidymodels-ml-knowledge-base.md** (52K) - Tidymodels (4 books)
4. **islr-statistical-learning-knowledge.md** (30K) - Statistical Learning
5. **time_series_forecasting_knowledge.md** (34K) - Forecasting

**Key Observation**: The knowledge base likely contains much deeper tidyverse expertise than what made it into the skills. The skills prioritized breadth (covering ML, statistics, time series) over depth in tidyverse fundamentals.

---

## Recommendations

### Option A: Create New Comprehensive Tidyverse Skill (RECOMMENDED)

**Structure**: Follow ggplot2 skill as a model

**Main SKILL.md** (~400-500 lines):
- Philosophy and principles
- Quick reference to all tidyverse packages
- Common workflow patterns
- Integration with existing skills
- Task dispatch to reference files

**Supporting Reference Files**:
1. `references/dplyr-deep-dive.md` - All dplyr patterns including window functions, complex joins
2. `references/tidyr-deep-dive.md` - Advanced reshaping, nesting, rectangling
3. `references/purrr-functional.md` - Comprehensive purrr patterns and error handling
4. `references/stringr-patterns.md` - Regex library and text manipulation
5. `references/forcats-guide.md` - Factor manipulation comprehensive guide
6. `references/lubridate-guide.md` - Date/time comprehensive guide
7. `references/readr-guide.md` - Data import/export patterns
8. `references/problem-solving.md` - Real-world data cleaning patterns
9. `references/performance.md` - Optimization and debugging

**Example Files**:
1. `examples/data-cleaning-recipes.md` - Common cleaning scenarios
2. `examples/complex-transformations.md` - Advanced reshape examples
3. `examples/text-processing.md` - String manipulation examples
4. `examples/date-time-examples.md` - Date/time scenarios

**Templates**:
1. `templates/eda-template.md` - Exploratory data analysis
2. `templates/data-cleaning-template.md` - Data cleaning workflow
3. `templates/transformation-template.md` - Data transformation workflow

**Skill Configuration**:
```yaml
---
name: tidyverse-expert
description: Comprehensive tidyverse data manipulation expert - dplyr, tidyr, purrr, stringr, forcats, lubridate, readr. Use when working with tidyverse, mentions "data cleaning", "data transformation", "text manipulation", "date manipulation", "factor handling", "functional programming", "complex joins", "data reshaping", "tidy data", or asks for tidyverse help, best practices, or problem-solving.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(Rscript *)
---
```

**Estimated Size**: ~3,500-4,000 lines total (similar to ggplot2 skill)

**Relationship to Existing Skills**:
- **r-datascience**: Delegates tidyverse questions to tidyverse-expert
- **tidyverse-patterns**: Keep for modern syntax reference, but tidyverse-expert has comprehensive patterns
- **ggplot2**: Complementary - tidyverse-expert handles data prep, ggplot2 handles visualization

**Advantages**:
- ✅ Comprehensive coverage of all gaps
- ✅ Follows proven structure (ggplot2 model)
- ✅ Non-redundant (user-invocable: false, acts as reference)
- ✅ Easy to maintain and extend
- ✅ Clear separation of concerns

**Disadvantages**:
- ⚠️ Large undertaking (~4,000 lines to write)
- ⚠️ Some overlap with existing skills (but manageable with delegation)

---

### Option B: Enhance Existing tidyverse-patterns Skill

**Approach**: Expand tidyverse-patterns from 335 lines to ~1,500-2,000 lines

**Add to SKILL.md**:
- forcats section (80-100 lines)
- lubridate section (100-120 lines)
- Advanced dplyr patterns (150-200 lines)
- Advanced tidyr patterns (100-150 lines)
- Advanced purrr patterns (100-150 lines)
- Expanded stringr with regex patterns (100-150 lines)
- Problem-solving section (150-200 lines)
- Performance section (80-100 lines)

**Add Supporting Files**:
- `examples/real-world-problems.md`
- `references/regex-library.md`
- `templates/data-cleaning.md`

**Skill Configuration Update**:
```yaml
---
name: tidyverse-patterns
description: Comprehensive tidyverse patterns and expertise - modern dplyr, tidyr, purrr, stringr, forcats, lubridate, readr. Use when working with tidyverse, data manipulation, text processing, dates, factors, functional programming, mentions tidyverse packages, or asks for tidyverse patterns, best practices, or problem-solving.
version: 2.0.0
user-invocable: true  # Change to allow direct invocation
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(Rscript *)
---
```

**Advantages**:
- ✅ Builds on existing work
- ✅ Moderate effort (~1,500 lines to add)
- ✅ Consolidates in one place

**Disadvantages**:
- ⚠️ Single file might get too large (1,500-2,000 lines)
- ⚠️ Harder to maintain than modular approach
- ⚠️ Less clear separation between syntax reference and problem-solving

---

### Option C: Minimal Enhancement (NOT RECOMMENDED)

**Approach**: Add missing packages to existing skills without restructuring

- Add forcats section to r-datascience (~100 lines)
- Add lubridate section to r-datascience (~120 lines)
- Add advanced patterns to data-wrangling.md (~200 lines)

**Advantages**:
- ✅ Minimal effort

**Disadvantages**:
- ❌ Maintains fragmentation
- ❌ No comprehensive tidyverse reference
- ❌ Still missing problem-solving focus
- ❌ Doesn't solve discoverability issues

---

## Final Recommendation: Option A

**Create comprehensive `tidyverse-expert` skill** following the ggplot2 model.

**Rationale**:
1. **Proven Structure**: ggplot2 skill demonstrates this approach works well
2. **Comprehensive**: Addresses ALL identified gaps
3. **Maintainable**: Modular structure with clear separation
4. **Non-Redundant**: `user-invocable: false` means it doesn't compete with other skills
5. **Discoverable**: Clear trigger phrases guide invocation
6. **Professional**: Matches quality standard of ggplot2 skill

**Scope Definition**:

**IN SCOPE** (tidyverse-expert):
- All core tidyverse packages: dplyr, tidyr, purrr, stringr, forcats, lubridate, readr
- Data manipulation and transformation
- Text processing
- Date/time handling
- Factor management
- Functional programming patterns
- Real-world problem-solving
- Performance and debugging

**OUT OF SCOPE** (delegated to other skills):
- Data visualization → ggplot2 skill
- Machine learning → r-tidymodels skill
- Statistical modeling → r-datascience skill
- Time series → r-timeseries skill
- Text mining/NLP → r-text-mining skill

**Integration Strategy**:

1. **r-datascience SKILL.md** - Update to delegate:
   ```r
   # For tidyverse data manipulation questions, see tidyverse-expert skill
   # This skill focuses on ML workflows and statistical modeling
   ```

2. **tidyverse-patterns SKILL.md** - Keep as modern syntax reference:
   ```yaml
   description: Modern tidyverse syntax patterns (dplyr 1.1+, R 4.3+). Use for syntax modernization, migration from old patterns, or quick modern syntax reference.
   ```

3. **New tidyverse-expert SKILL.md**:
   ```yaml
   description: Comprehensive tidyverse data manipulation expert - dplyr, tidyr, purrr, stringr, forcats, lubridate, readr. Use when working with tidyverse, mentions "data cleaning", "data transformation", "text manipulation", "date manipulation", "factor handling", "functional programming", "complex joins", "data reshaping", "tidy data", or asks for tidyverse help, best practices, or problem-solving.
   ```

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
1. Create skill structure and main SKILL.md (~400 lines)
2. Create dplyr-deep-dive.md (~600 lines)
3. Create tidyr-deep-dive.md (~500 lines)

### Phase 2: Core Packages (Week 2)
4. Create purrr-functional.md (~500 lines)
5. Create stringr-patterns.md (~400 lines)
6. Create forcats-guide.md (~300 lines)
7. Create lubridate-guide.md (~350 lines)

### Phase 3: Applied Knowledge (Week 3)
8. Create problem-solving.md (~400 lines)
9. Create performance.md (~300 lines)
10. Create examples/ directory (3 files, ~600 lines total)
11. Create templates/ directory (3 files, ~400 lines total)

### Phase 4: Integration & Testing (Week 4)
12. Update r-datascience to delegate
13. Update tidyverse-patterns scope
14. Test trigger phrases and invocation
15. Create README and documentation

**Total Estimated Effort**: ~4,000 lines, 4 weeks

---

## Conclusion

The current R skills provide **good breadth** but **lack depth** in tidyverse data manipulation. The biggest gaps are:

1. **forcats** - 0% coverage (Critical)
2. **lubridate** - 0% coverage (Critical)
3. **Advanced dplyr/tidyr/purrr patterns** - 20-40% coverage (High Impact)
4. **Real-world problem-solving** - 10% coverage (High Impact)
5. **Performance & debugging** - 5% coverage (Medium Impact)

**Recommended Solution**: Create new comprehensive `tidyverse-expert` skill following the proven ggplot2 model. This provides complete coverage, clear separation of concerns, and professional-quality reference material for all tidyverse data manipulation needs.

The knowledge base contains deep expertise that hasn't been fully utilized in the current skills. Creating tidyverse-expert would properly leverage this knowledge and provide the missing comprehensive tidyverse reference this repository needs.
