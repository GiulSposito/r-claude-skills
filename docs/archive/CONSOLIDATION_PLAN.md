# Skill Consolidation Plan

**Version:** 1.0
**Date:** 2026-03-09
**Status:** Planning Phase
**Impact:** Reduces 17 → 12 skills, eliminates 70% redundancy

---

## 🎯 Executive Summary

This plan consolidates redundant R/Data Science skills to:
- **Reduce confusion** - Clear hierarchy and purpose for each skill
- **Eliminate overlap** - 70% content duplication removed
- **Improve discovery** - Easier to find the right skill
- **Better maintenance** - Fewer files to update

**Timeline:** 2-3 weeks
**Breaking changes:** Yes (but minimized with careful planning)
**User impact:** Minimal with proper migration guide

---

## 📊 Current State Analysis

### Skills by Type

**Reference Skills (Knowledge base):**
- tidyverse-expert (430L) - Comprehensive tidyverse guide
- tidyverse-patterns (335L) - Modern tidyverse patterns
- ggplot2 (448L) - Data visualization
- r-shiny (731L) - Shiny apps
- r-text-mining (513L) - Text/NLP
- r-timeseries (506L) - Time series
- r-tidymodels (769L) - Machine learning

**Simple Skills (Quick reference):**
- r-style-guide (~200L) - Code style
- r-bayes (~150L) - Bayesian inference
- r-oop (~150L) - Object-oriented programming
- r-performance (~150L) - Performance optimization
- r-package-development (~150L) - Package development
- rlang-patterns (~150L) - Metaprogramming
- dm-relational (~150L) - Relational data
- tdd-workflow (~150L) - Test-driven development

**Meta Skills:**
- r-datascience (619L) - Dispatcher/gateway
- skillMaker (558L) - Skill creation

### Identified Problems

1. **tidyverse-patterns vs tidyverse-expert**
   - 70% content overlap
   - Confusing when to use which
   - Both activate on similar triggers

2. **r-datascience**
   - Acts as dispatcher to other skills
   - Duplicates content from specialized skills
   - user-invocable: true but shouldn't be

3. **r-oop + r-performance + r-package-development**
   - All "advanced R" topics
   - Too small individually (~150L each)
   - Better as single comprehensive skill

4. **No onboarding skill**
   - Users don't know what skills exist
   - No guide to choosing the right skill
   - Discovery is difficult

---

## 🔄 Consolidation Strategy

### Phase 1: Tidyverse Consolidation (Week 1)

#### 1.1 Merge tidyverse-patterns → tidyverse-expert

**Rationale:**
- tidyverse-patterns focuses on "modern patterns" (dplyr 1.1+, native pipe)
- tidyverse-expert has comprehensive package reference
- Content is complementary, not conflicting

**Plan:**
```
tidyverse-expert/
├── SKILL.md (450L) - Keep expert content, add modern patterns
│   ├── Core Packages section (existing)
│   ├── Modern Patterns section (NEW - from tidyverse-patterns)
│   │   └── Native pipe, join_by, .by grouping, etc.
│   └── Package-Specific Guidance (existing)
├── references/
│   ├── dplyr-reference.md (existing)
│   ├── tidyr-reference.md (existing)
│   ├── purrr-reference.md (existing)
│   ├── stringr-reference.md (existing)
│   ├── forcats-reference.md (existing)
│   ├── lubridate-reference.md (existing)
│   └── modern-patterns.md (NEW - expanded from patterns skill)
├── examples/ (existing)
└── templates/ (existing)
```

**Actions:**
1. Add "Modern Patterns" section to tidyverse-expert/SKILL.md
2. Move tidyverse-patterns content into new section
3. Create references/modern-patterns.md with detailed examples
4. Update trigger phrases to include both skill's triggers
5. Deprecate tidyverse-patterns (move to archive/)

**Breaking changes:**
- `/tidyverse-patterns` will no longer work
- Auto-triggers will now activate tidyverse-expert

**Migration:**
- User message: "tidyverse-patterns merged into tidyverse-expert"
- No action needed - skills auto-activate

#### 1.2 Rename tidyverse-expert → tidyverse

**Rationale:**
- Simpler name
- More discoverable
- "expert" implies intimidating

**Plan:**
```bash
# Rename directory
mv .claude/skills/tidyverse-expert .claude/skills/tidyverse

# Update frontmatter
name: tidyverse (was: tidyverse-expert)
```

**Breaking changes:**
- `/tidyverse-expert` will no longer work
- References in other skills need updating

**Migration:**
- Update all skills that reference tidyverse-expert
- Update README.md
- Git commit message explaining rename

---

### Phase 2: r-datascience Transformation (Week 1-2)

#### 2.1 Transform r-datascience → r-quickstart

**Rationale:**
- Current r-datascience is too broad and dispatcher-like
- Need skill for onboarding/navigation
- Help users discover and choose skills

**New Purpose:**
```yaml
name: r-quickstart
description: R programming getting started guide and skill navigator.
Use when user asks "what R skills are available", "how to use R skills",
"getting started with R in Claude", "which skill should I use", or needs
help choosing the right R skill for their task.
version: 1.0.0
user-invocable: true  # Users can invoke manually
allowed-tools: Read
```

**New Content Structure:**
```markdown
# R Skills Navigator

Welcome to R programming with Claude Code! This guide helps you discover
and choose the right skills.

## Quick Start

### Your First R Task
[Simple decision tree for beginners]

### Available Skills

**Data Wrangling:** tidyverse
**Visualization:** ggplot2
**Machine Learning:** r-tidymodels
**Time Series:** r-timeseries
**Text Analysis:** r-text-mining
**Shiny Apps:** r-shiny
[etc.]

## Skill Selection Guide

### I want to...
- "Clean and transform data" → tidyverse
- "Create plots and charts" → ggplot2
- "Build ML models" → r-tidymodels
- "Forecast time series" → r-timeseries
- "Analyze text data" → r-text-mining
[etc.]

## Common Workflows

### Data Analysis Workflow
1. Load: tidyverse (readr)
2. Clean: tidyverse (dplyr/tidyr)
3. Visualize: ggplot2
4. Model: r-tidymodels (optional)

### Package Development
1. Setup: r-package-development
2. Write code: r-style-guide, r-oop
3. Test: tdd-workflow
4. Optimize: r-performance

## Getting Help

- Specific task? Just describe it in natural language
- Not sure which skill? Use /r-quickstart
- Learning R? Start with tidyverse → ggplot2 → r-tidymodels

## Skill Details

[Brief description of each skill with when to use]
```

**Actions:**
1. Create new r-quickstart skill structure
2. Remove dispatcher content from r-datascience
3. Keep useful general guidance
4. Update trigger phrases for navigation/help queries
5. Mark r-datascience as deprecated (or remove)

**Breaking changes:**
- r-datascience content significantly changes
- Less comprehensive, more focused on navigation

**Migration:**
- Users won't notice (auto-activation unchanged)
- r-datascience can coexist briefly before removal

---

### Phase 3: Advanced R Consolidation (Week 2)

#### 3.1 Merge r-oop + r-performance + r-package-development → r-advanced

**Rationale:**
- All three are "advanced R" topics
- Each ~150 lines is too small
- Natural progression: OOP → Performance → Packaging
- Better as comprehensive single resource

**Plan:**
```
r-advanced/
├── SKILL.md (500-600L)
│   ├── Introduction (NEW)
│   ├── Object-Oriented Programming (from r-oop)
│   │   ├── S7, S3, S4, vctrs
│   │   └── When to use each system
│   ├── Performance Optimization (from r-performance)
│   │   ├── Profiling (profvis)
│   │   ├── Benchmarking (bench)
│   │   ├── Vectorization
│   │   └── Rcpp integration
│   └── Package Development (from r-package-development)
│       ├── Package structure
│       ├── Dependencies
│       ├── Documentation
│       └── Testing
├── references/
│   ├── oop-systems.md (expanded r-oop)
│   ├── performance-guide.md (expanded r-performance)
│   └── packaging-guide.md (expanded r-package-development)
├── examples/
│   ├── s7-class-example.R
│   ├── profiling-workflow.R
│   └── package-skeleton/
└── templates/
    ├── package-template/
    └── performance-analysis.R
```

**Frontmatter:**
```yaml
name: r-advanced
description: Advanced R programming covering object-oriented programming
(S7, S3, S4, vctrs), performance optimization (profiling, benchmarking,
vectorization, Rcpp), and package development (structure, dependencies,
documentation, testing). Use when mentions "S3 class", "S4 class", "S7",
"vctrs", "profiling", "profvis", "benchmark", "optimize R", "vectorization",
"performance", "Rcpp", "R package", "devtools", "usethis", "roxygen2",
"package development", or working on advanced R programming topics.
version: 1.0.0
user-invocable: false
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(Rscript -e *)
```

**Actions:**
1. Create r-advanced skill structure
2. Merge all three skills' content
3. Organize by logical progression
4. Expand each section with cross-references
5. Add comprehensive examples
6. Archive r-oop, r-performance, r-package-development

**Breaking changes:**
- Three skills replaced by one
- Different skill name to invoke

**Migration:**
- Old trigger phrases still work (included in new description)
- Automatic for most users

---

### Phase 4: Final Adjustments (Week 2-3)

#### 4.1 Keep As-Is (No Changes)

These skills are well-structured and focused:
- ✅ **ggplot2** - Comprehensive visualization skill
- ✅ **r-shiny** - Complete Shiny development
- ✅ **r-tidymodels** - ML with tidymodels
- ✅ **r-text-mining** - Text/NLP analysis
- ✅ **r-timeseries** - Time series forecasting
- ✅ **r-bayes** - Bayesian inference (could expand later)
- ✅ **r-style-guide** - Code style guide
- ✅ **rlang-patterns** - Metaprogramming
- ✅ **dm-relational** - Relational data
- ✅ **tdd-workflow** - TDD workflow
- ✅ **skillMaker** - Skill creation

#### 4.2 Potential Future Consolidations (Not now)

**Low priority:**
- r-bayes could become bundled (but fine for now)
- r-style-guide could merge into tidyverse (but useful standalone)
- dm-relational could merge into tidyverse (but niche enough)

---

## 📅 Implementation Timeline

### Week 1: Tidyverse Consolidation

**Day 1-2:**
- [x] Create branch: `feature/consolidation`
- [ ] Merge tidyverse-patterns → tidyverse-expert
- [ ] Test merged skill thoroughly
- [ ] Update all references

**Day 3:**
- [ ] Rename tidyverse-expert → tidyverse
- [ ] Update README.md
- [ ] Commit changes with detailed message

**Day 4-5:**
- [ ] Create r-quickstart from scratch
- [ ] Test navigation/discovery
- [ ] Deprecate r-datascience
- [ ] Commit changes

### Week 2: Advanced R Consolidation

**Day 1-3:**
- [ ] Design r-advanced structure
- [ ] Merge r-oop content
- [ ] Merge r-performance content
- [ ] Merge r-package-development content
- [ ] Create comprehensive examples

**Day 4:**
- [ ] Test r-advanced thoroughly
- [ ] Verify all trigger phrases work
- [ ] Archive old skills

**Day 5:**
- [ ] Update all documentation
- [ ] Update TODO.md
- [ ] Prepare migration guide

### Week 3: Testing & Refinement

**Day 1-2:**
- [ ] Comprehensive testing of all changes
- [ ] Fix any issues found
- [ ] Validate with validation script

**Day 3:**
- [ ] Create MIGRATION_GUIDE.md
- [ ] Update README.md with new structure
- [ ] Update SKILL_ANALYSIS_REPORT.md status

**Day 4:**
- [ ] Merge to main
- [ ] Create GitHub release
- [ ] Announce changes

**Day 5:**
- [ ] Monitor for issues
- [ ] Update based on feedback
- [ ] Close consolidation milestone

---

## 🔀 Git Strategy

### Branch Structure

```
main
  └── feature/consolidation
       ├── feature/consolidation-tidyverse
       ├── feature/consolidation-datascience
       └── feature/consolidation-advanced
```

### Commit Strategy

Each consolidation gets its own commit:

```bash
# Tidyverse
git commit -m "Merge tidyverse-patterns into tidyverse-expert"
git commit -m "Rename tidyverse-expert to tidyverse"

# Datascience
git commit -m "Transform r-datascience into r-quickstart"

# Advanced
git commit -m "Consolidate r-oop, r-performance, r-package-dev into r-advanced"

# Final
git commit -m "Update documentation for consolidated skills"
```

### Archive Strategy

Don't delete - move to archive:

```bash
mkdir -p .claude/skills-archive/2026-03-consolidation/
mv .claude/skills/tidyverse-patterns .claude/skills-archive/2026-03-consolidation/
mv .claude/skills/r-datascience .claude/skills-archive/2026-03-consolidation/
mv .claude/skills/r-oop .claude/skills-archive/2026-03-consolidation/
mv .claude/skills/r-performance .claude/skills-archive/2026-03-consolidation/
mv .claude/skills/r-package-development .claude/skills-archive/2026-03-consolidation/
```

**Rationale:**
- Preserves history
- Easy rollback if needed
- Can reference old content
- Clean main skills/ directory

---

## ⚠️ Breaking Changes & Mitigation

### Breaking Change #1: Skill Name Changes

**Impact:**
- Manual invocations with `/skill-name` break
- Documentation references outdated

**Mitigation:**
```markdown
MIGRATION_GUIDE.md:

Old Command → New Command
/tidyverse-expert → /tidyverse
/tidyverse-patterns → /tidyverse (merged)
/r-datascience → /r-quickstart (transformed)
/r-oop → /r-advanced
/r-performance → /r-advanced
/r-package-development → /r-advanced
```

**Communication:**
- README.md update with migration table
- GitHub release notes
- CHANGELOG.md entry
- Deprecation notices in archived skills

### Breaking Change #2: Auto-trigger Behavior

**Impact:**
- Skills auto-activate differently
- Users might see different skill than expected

**Mitigation:**
- Comprehensive trigger phrase coverage in new skills
- Test common queries against new structure
- Monitor issues for unexpected behavior

**Testing scenarios:**
```bash
# Should activate tidyverse
"How do I use the native pipe?"
"What's the join_by syntax?"
"How do I use .by grouping?"

# Should activate r-quickstart
"What R skills are available?"
"Which skill should I use for data analysis?"
"Getting started with R in Claude"

# Should activate r-advanced
"How do I create an S7 class?"
"How do I profile my R code?"
"How do I create an R package?"
```

### Breaking Change #3: Content Reorganization

**Impact:**
- File paths change
- Cross-references break
- Examples move locations

**Mitigation:**
- Update all internal links
- Run validation script to catch broken references
- Comprehensive testing

---

## 📊 Before & After Comparison

### Before (Current State)

```
17 skills total
├── 6 bundled skills (well-structured)
├── 9 simple skills (some too small)
├── 2 meta skills (one problematic)
└── Identified issues:
    - 70% overlap (tidyverse skills)
    - Dispatcher anti-pattern (r-datascience)
    - Fragmented advanced topics
    - No onboarding/discovery
```

### After (Post-Consolidation)

```
12 skills total
├── 6 bundled skills (unchanged)
├── 1 new bundled skill (r-advanced)
├── 4 simple skills (focused)
├── 1 new meta skill (r-quickstart)
└── Improvements:
    - 0% overlap (clear boundaries)
    - Better discovery (r-quickstart)
    - Comprehensive advanced skill
    - Clearer organization
```

### Impact Summary

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total skills | 17 | 12 | -29% |
| Redundant content | ~70% | ~5% | -93% |
| Avg skill size | 285L | 383L | +34% |
| Onboarding | ❌ | ✅ | New |
| Advanced topics | Fragmented | Unified | Better |
| User confusion | High | Low | ⬇️ |

---

## 🎯 Success Criteria

### Quantitative

- [ ] Skills reduced from 17 → 12 (29% reduction)
- [ ] Content overlap < 10% (from 70%)
- [ ] All skills pass validation
- [ ] No broken file references
- [ ] All trigger phrases tested

### Qualitative

- [ ] Clear purpose for each skill
- [ ] Easy to discover right skill
- [ ] Natural progression (beginner → advanced)
- [ ] Comprehensive without redundancy
- [ ] Maintainable structure

### User Experience

- [ ] Faster skill discovery
- [ ] Less confusion about which skill to use
- [ ] Better onboarding for new users
- [ ] Improved auto-invocation accuracy
- [ ] Positive feedback from users

---

## 🔍 Testing Plan

### Phase 1: Unit Testing

Test each consolidated skill individually:

```bash
# Validate YAML and structure
./tests/validate-skills.sh

# Test manual invocation
/tidyverse
/r-quickstart
/r-advanced

# Verify file references
# Check all markdown links work
# Verify examples run
```

### Phase 2: Integration Testing

Test auto-triggering:

```markdown
Test queries:

Tidyverse:
- "How do I use dplyr?"
- "What's the native pipe syntax?"
- "How do I pivot data?"

R-quickstart:
- "What R skills are available?"
- "I'm new to R, where do I start?"
- "Which skill for data analysis?"

R-advanced:
- "How do I create an S7 class?"
- "How do I profile R code?"
- "How do I build an R package?"
```

### Phase 3: Regression Testing

Ensure nothing else broke:

```bash
# All skills still work
for skill in .claude/skills/*/; do
    echo "Testing $(basename $skill)..."
    # Test auto-trigger
    # Test file references
    # Test examples
done

# Validation passes
./tests/validate-skills.sh
```

---

## 📝 Documentation Updates

### Files to Update

```markdown
README.md
- [ ] Update skill count (17 → 12)
- [ ] Update skill list
- [ ] Add migration guide link
- [ ] Update examples

CLAUDE.md
- [ ] Update skill references
- [ ] Update examples

TODO.md
- [ ] Mark consolidation complete
- [ ] Update priorities

SKILL_ANALYSIS_REPORT.md
- [ ] Add "Implemented" note to Section 10.1
- [ ] Update metrics

CHANGELOG.md (new)
- [ ] Document all changes
- [ ] Breaking changes section
- [ ] Migration guide

MIGRATION_GUIDE.md (new)
- [ ] Old → New mapping
- [ ] What changed and why
- [ ] User action items
```

---

## 🚨 Rollback Plan

If consolidation causes problems:

### Quick Rollback (< 1 hour)

```bash
# Revert commits
git revert <consolidation-commits>

# Restore from archive
cp -r .claude/skills-archive/2026-03-consolidation/* .claude/skills/

# Verify
./tests/validate-skills.sh
```

### Partial Rollback

Keep successful consolidations, revert problematic ones:

```bash
# Example: Keep tidyverse consolidation, revert r-advanced
git revert <r-advanced-commit>
cp -r .claude/skills-archive/2026-03-consolidation/r-oop .claude/skills/
cp -r .claude/skills-archive/2026-03-consolidation/r-performance .claude/skills/
cp -r .claude/skills-archive/2026-03-consolidation/r-package-development .claude/skills/
```

### Decision Criteria for Rollback

Rollback if:
- ❌ Skills fail validation after 3+ fix attempts
- ❌ Users report major confusion (3+ issues)
- ❌ Auto-triggering accuracy drops > 20%
- ❌ Critical functionality lost

Don't rollback if:
- ⚠️ Minor trigger phrase adjustments needed
- ⚠️ Documentation needs updates
- ⚠️ 1-2 small bugs found (fix instead)

---

## 💬 Communication Plan

### Internal (Repository)

**GitHub Release:**
```markdown
# v2.0.0 - Skill Consolidation

## Major Changes
- Consolidated 17 → 12 skills
- Eliminated 70% content redundancy
- Added r-quickstart for onboarding
- Created unified r-advanced skill

## Breaking Changes
See MIGRATION_GUIDE.md

## Migration
Most changes are automatic. Manual invocations updated:
- /tidyverse-expert → /tidyverse
[etc.]
```

**CHANGELOG.md:**
```markdown
# [2.0.0] - 2026-03-XX

### Added
- r-quickstart skill for navigation and onboarding
- r-advanced skill (comprehensive advanced R)

### Changed
- Merged tidyverse-patterns into tidyverse (was tidyverse-expert)
- Renamed tidyverse-expert → tidyverse
- Transformed r-datascience → r-quickstart

### Removed
- tidyverse-patterns (merged into tidyverse)
- r-datascience (transformed into r-quickstart)
- r-oop (merged into r-advanced)
- r-performance (merged into r-advanced)
- r-package-development (merged into r-advanced)

### Migration
See MIGRATION_GUIDE.md
```

### External (Users)

**README.md notice:**
```markdown
## 🚀 Version 2.0 Update

Skills have been consolidated for better clarity:
- tidyverse-expert + tidyverse-patterns → tidyverse
- r-datascience → r-quickstart (new purpose)
- r-oop + r-performance + r-package-development → r-advanced

See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for details.
```

---

## ✅ Checklist

### Pre-Consolidation
- [x] Create CONSOLIDATION_PLAN.md (this document)
- [ ] Review plan with stakeholders
- [ ] Get approval to proceed
- [ ] Create feature branch
- [ ] Backup current state

### During Consolidation
- [ ] Phase 1: Tidyverse (Week 1)
  - [ ] Merge tidyverse-patterns
  - [ ] Rename to tidyverse
  - [ ] Create r-quickstart
  - [ ] Test thoroughly
- [ ] Phase 2: Advanced R (Week 2)
  - [ ] Create r-advanced
  - [ ] Merge three skills
  - [ ] Test thoroughly
- [ ] Phase 3: Documentation (Week 2-3)
  - [ ] Update all docs
  - [ ] Create migration guide
  - [ ] Update README

### Post-Consolidation
- [ ] Run validation script
- [ ] Test all auto-triggers
- [ ] Update documentation
- [ ] Merge to main
- [ ] Create GitHub release
- [ ] Monitor for issues
- [ ] Mark TODO item complete

---

## 📈 Expected Outcomes

### Developer Experience
- ✅ Faster to find right skill
- ✅ Clear skill boundaries
- ✅ Better onboarding
- ✅ Less maintenance burden

### Code Quality
- ✅ No redundant content
- ✅ Single source of truth
- ✅ Easier to keep updated
- ✅ Better organized

### User Experience
- ✅ Skills auto-activate correctly
- ✅ Easy to discover capabilities
- ✅ Natural learning progression
- ✅ Comprehensive without overwhelm

---

**Status:** Ready for implementation
**Approval needed:** Yes
**Risk level:** Medium (breaking changes, but well-planned)
**Estimated effort:** 2-3 weeks
**Expected value:** High (long-term maintainability and UX)

---

*Document version: 1.0*
*Last updated: 2026-03-09*
*Next review: After Phase 1 completion*
