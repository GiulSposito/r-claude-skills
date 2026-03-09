# Migration Guide - Skill Consolidation v2.0

**Status:** Planning phase - will be updated when consolidation is implemented
**Applies to:** Consolidation from 17 → 12 skills

---

## 🎯 Quick Reference

### Skill Name Changes

| Old Name | New Name | Status | Action |
|----------|----------|--------|--------|
| `tidyverse-expert` | `tidyverse` | Renamed | Use `/tidyverse` |
| `tidyverse-patterns` | `tidyverse` | Merged | Use `/tidyverse` |
| `r-datascience` | `r-quickstart` | Transformed | Use `/r-quickstart` |
| `r-oop` | `r-advanced` | Merged | Use `/r-advanced` |
| `r-performance` | `r-advanced` | Merged | Use `/r-advanced` |
| `r-package-development` | `r-advanced` | Merged | Use `/r-advanced` |

### Skills Unchanged

These skills remain exactly as they were:
- ✅ ggplot2
- ✅ r-shiny
- ✅ r-tidymodels
- ✅ r-text-mining
- ✅ r-timeseries
- ✅ r-bayes
- ✅ r-style-guide
- ✅ rlang-patterns
- ✅ dm-relational
- ✅ tdd-workflow
- ✅ skillMaker

---

## 📋 What Changed and Why

### 1. Tidyverse Consolidation

**What happened:**
- `tidyverse-patterns` merged into `tidyverse-expert`
- `tidyverse-expert` renamed to `tidyverse`

**Why:**
- 70% content overlap between the two
- Confusing which one to use
- Better as single comprehensive resource

**User impact:**
- ✅ Auto-triggering still works (triggers merged)
- ⚠️ Manual invocation: use `/tidyverse` instead
- ✅ All content still available (just reorganized)

**What you get:**
```
tidyverse skill now includes:
- All package references (dplyr, tidyr, purrr, stringr, forcats, lubridate)
- Modern patterns (native pipe, join_by, .by grouping)
- Comprehensive examples
- Migration guide from old patterns
```

### 2. r-datascience Transformation

**What happened:**
- `r-datascience` transformed into `r-quickstart`
- New purpose: onboarding and skill navigation

**Why:**
- Old r-datascience was "dispatcher" anti-pattern
- Duplicated content from specialized skills
- Need dedicated onboarding skill

**User impact:**
- ✅ Auto-triggering adjusted for new purpose
- ✅ Better for "getting started" queries
- ✅ Helps discover other skills

**What you get:**
```
r-quickstart provides:
- Skill discovery guide
- Decision tree for choosing skills
- Common workflows
- Getting started tutorials
- Links to specialized skills
```

### 3. Advanced R Consolidation

**What happened:**
- Three skills merged into one `r-advanced`
  - r-oop (Object-oriented programming)
  - r-performance (Performance optimization)
  - r-package-development (Package development)

**Why:**
- Each was too small (~150 lines)
- All are "advanced R" topics
- Better as comprehensive resource
- Natural progression path

**User impact:**
- ✅ All content preserved and expanded
- ✅ Better organization
- ⚠️ Manual invocation: use `/r-advanced`
- ✅ Auto-triggers still work

**What you get:**
```
r-advanced covers:
- OOP systems (S7, S3, S4, vctrs)
- Performance optimization (profiling, benchmarking, Rcpp)
- Package development (structure, dependencies, testing)
- Comprehensive examples
- Cross-topic integration
```

---

## 🔄 Migration Steps

### For Users

**No action required for most users!**

Auto-triggering continues to work. The skills activate based on what you're working on, not the skill name.

**If you manually invoke skills:**

Update your commands:
```bash
# Old → New
/tidyverse-expert    → /tidyverse
/tidyverse-patterns  → /tidyverse
/r-datascience       → /r-quickstart
/r-oop               → /r-advanced
/r-performance       → /r-advanced
/r-package-development → /r-advanced
```

**If you have documentation/notes:**

Update skill references:
```markdown
Old: "Use tidyverse-expert for data wrangling"
New: "Use tidyverse for data wrangling"

Old: "r-oop for class definitions"
New: "r-advanced for class definitions"
```

### For Contributors

**If you're developing skills:**

1. Update cross-references:
```markdown
# In your SKILL.md
Old: See tidyverse-expert skill
New: See tidyverse skill

Old: See r-oop, r-performance, r-package-development
New: See r-advanced skill
```

2. Update file paths:
```markdown
# Examples in your skill
Old: .claude/skills/tidyverse-expert/references/
New: .claude/skills/tidyverse/references/

Old: .claude/skills/r-oop/
New: .claude/skills/r-advanced/ (OOP section)
```

3. Run validation:
```bash
./tests/validate-skills.sh
```

---

## 🧪 Testing Your Workflows

### Test Scenarios

After consolidation, test these common queries:

**Tidyverse:**
```
✅ "How do I use dplyr?"
✅ "What's the native pipe syntax?"
✅ "How do I join data frames with join_by?"
✅ "How do I use .by grouping?"
```
Expected: `tidyverse` skill activates

**Getting Started:**
```
✅ "What R skills are available?"
✅ "I'm new to R, where should I start?"
✅ "Which skill should I use for data analysis?"
```
Expected: `r-quickstart` skill activates

**Advanced Topics:**
```
✅ "How do I create an S7 class?"
✅ "How do I profile my R code with profvis?"
✅ "How do I create an R package?"
```
Expected: `r-advanced` skill activates

### If Something Doesn't Work

1. **Check skill name** - Did you use the new name?
2. **Try auto-trigger** - Just describe what you want
3. **Report issue** - If auto-trigger fails, open GitHub issue

---

## 📚 Where to Find Things

### Content Moved

**From tidyverse-patterns:**
```
Old location: .claude/skills/tidyverse-patterns/SKILL.md
New location: .claude/skills/tidyverse/SKILL.md (Modern Patterns section)
          or: .claude/skills/tidyverse/references/modern-patterns.md
```

**From r-oop:**
```
Old location: .claude/skills/r-oop/SKILL.md
New location: .claude/skills/r-advanced/SKILL.md (OOP section)
          or: .claude/skills/r-advanced/references/oop-systems.md
```

**From r-performance:**
```
Old location: .claude/skills/r-performance/SKILL.md
New location: .claude/skills/r-advanced/SKILL.md (Performance section)
          or: .claude/skills/r-advanced/references/performance-guide.md
```

**From r-package-development:**
```
Old location: .claude/skills/r-package-development/SKILL.md
New location: .claude/skills/r-advanced/SKILL.md (Package Dev section)
          or: .claude/skills/r-advanced/references/packaging-guide.md
```

### Archived Skills

Old skills are preserved in:
```
.claude/skills-archive/2026-03-consolidation/
├── tidyverse-patterns/
├── r-datascience/
├── r-oop/
├── r-performance/
└── r-package-development/
```

**Note:** Archived skills are not active. Use for reference only.

---

## ❓ FAQ

### Q: Will my existing code/workflows break?

**A:** No. The consolidation affects skill organization, not R code functionality.

### Q: Do I need to update my project's .claude/skills/?

**A:** Only if you're using project-level skills. System-wide skills update automatically.

### Q: What if I prefer the old organization?

**A:** Archived skills are available in `.claude/skills-archive/`. You can copy them back to `.claude/skills/` but won't receive updates.

### Q: When does this take effect?

**A:** After the consolidation merge (estimated: Week 3). Check GitHub releases.

### Q: Can I use both old and new names during transition?

**A:** During transition period (1-2 weeks), old skills may coexist with deprecation warnings. After that, only new skills remain.

### Q: How do I know which version I have?

**A:** Run:
```bash
ls .claude/skills/ | grep tidyverse
```
- If you see `tidyverse-expert` → Old version
- If you see `tidyverse` → New version

Or check your skill count:
```bash
ls -d .claude/skills/*/ | wc -l
```
- 17+ skills → Old version
- ~12 skills → New version

### Q: What if auto-triggering doesn't work?

**A:** The new skills include all trigger phrases from old skills, so auto-triggering should work the same or better. If not, please report an issue.

### Q: Can I roll back if I have problems?

**A:** Yes. See CONSOLIDATION_PLAN.md "Rollback Plan" section.

---

## 🚨 Troubleshooting

### Issue: "Skill not found"

**Symptom:** `/tidyverse-expert` shows "skill not found"

**Solution:**
```bash
# Use new name
/tidyverse

# Or just describe your task (auto-trigger)
"How do I use dplyr to filter data?"
```

### Issue: "Content is missing"

**Symptom:** Can't find specific content from old skill

**Solution:**
1. Check new skill's table of contents
2. Content may be reorganized under different section
3. Check `references/` directory in new skill
4. Consult archived skill if needed

### Issue: "Wrong skill activates"

**Symptom:** Auto-trigger activates unexpected skill

**Solution:**
1. Be more specific in your query
2. Manually invoke correct skill
3. Report issue if trigger phrase should be adjusted

### Issue: "Examples don't run"

**Symptom:** Code examples from skill don't work

**Solution:**
1. Check if example paths changed
2. Verify you're using current examples
3. Run validation: `./tests/validate-skills.sh`
4. Report issue if examples are broken

---

## 📊 Before & After Comparison

### Skill Structure

**Before:**
```
.claude/skills/
├── tidyverse-expert/      (430 lines)
├── tidyverse-patterns/    (335 lines) ← Overlap!
├── r-datascience/         (619 lines) ← Dispatcher
├── r-oop/                 (150 lines) ← Too small
├── r-performance/         (150 lines) ← Too small
├── r-package-development/ (150 lines) ← Too small
└── [11 other skills]

Total: 17 skills, ~30% redundancy
```

**After:**
```
.claude/skills/
├── tidyverse/        (500 lines) ← Merged & renamed
├── r-quickstart/     (300 lines) ← New purpose
├── r-advanced/       (600 lines) ← 3 skills merged
└── [9 other skills]

Total: 12 skills, <5% redundancy
```

### User Experience

**Before:**
```
User: "How do I use the native pipe?"
Claude: [Could activate tidyverse-expert OR tidyverse-patterns]
User: [Confused which has the right info]
```

**After:**
```
User: "How do I use the native pipe?"
Claude: [Activates tidyverse]
User: [Gets comprehensive answer in one place]
```

---

## 📞 Support

### Getting Help

**Questions about migration:**
- Check this guide first
- See CONSOLIDATION_PLAN.md for technical details
- Open GitHub issue if stuck

**Bug reports:**
- Use GitHub Issues
- Include: what you tried, what happened, what you expected
- Tag with `consolidation` label

**Feedback:**
- GitHub Discussions for suggestions
- Let us know what works well
- Let us know what needs improvement

---

## 📅 Timeline

### Transition Period

**Week 1-2: Implementation**
- Consolidation happens
- Skills coexist briefly

**Week 3: Cutover**
- Old skills deprecated
- New skills active
- Documentation updated

**Week 4+: Stable**
- Only new skills remain
- Archived skills available for reference
- Normal development resumes

### Key Dates

- **Planning complete:** 2026-03-09 ✅
- **Implementation start:** TBD
- **Testing complete:** TBD
- **Merge to main:** TBD
- **Release v2.0:** TBD

---

## ✅ Migration Checklist

### For Users

- [ ] Read this migration guide
- [ ] Update manual invocations (if any)
- [ ] Update documentation/notes (if any)
- [ ] Test your workflows
- [ ] Report issues if found

### For Contributors

- [ ] Update skill cross-references
- [ ] Update file paths in examples
- [ ] Run validation script
- [ ] Test auto-triggering
- [ ] Update your local documentation

### For Maintainers

- [ ] Complete consolidation implementation
- [ ] Run comprehensive tests
- [ ] Update all documentation
- [ ] Create GitHub release
- [ ] Monitor for issues
- [ ] Support users during transition

---

**Last updated:** 2026-03-09 (Planning phase)
**Consolidation status:** Not yet implemented
**Questions?** Open a GitHub issue

---

*This guide will be updated as consolidation progresses.*
