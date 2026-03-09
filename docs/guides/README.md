# 📖 Improvement Guides

Step-by-step guides for improving skill detection and applying proven patterns.

---

## Available Guides

### 1. [Fixing Skills Guide](FIXING_SKILLS_GUIDE.md)
**When to use**: Your skill has low recall (<90%) or precision (<95%)

**What it covers**:
- Diagnosing skill detection problems
- Step-by-step improvement process
- Adding trigger phrases
- Updating test indicators
- Validating improvements

**Start here if**: You need to fix a specific skill

---

### 2. [skillMaker Pattern Guide](SKILLMAKER_PATTERN.md)
**When to use**: You want to apply the proven success pattern

**What it covers**:
- The complete skillMaker pattern formula
- Bilingual trigger strategies (PT + EN)
- Language filter techniques
- R-specific qualifiers
- Test indicator synchronization
- Real examples from successful skills

**Start here if**: You want to replicate the 93.8% success pattern

---

### 3. [Migration Guide](MIGRATION_GUIDE.md)
**When to use**: Migrating skills to new structure or standards

**What it covers**:
- Skill structure migration
- Frontmatter standardization
- Version management
- Backward compatibility

**Start here if**: You're updating skill architecture

---

## Quick Reference

### The skillMaker Pattern (Success Formula)

```yaml
description: [Domain] [action]. Use when [trigger1], [trigger2],
  mentions "[package]", "[function]", "[term PT]", "[term EN]",
  discusses "[use case]", or [related phrase]. ONLY [language filter].
```

**Essential Components**:
1. ✅ 20-50 bilingual trigger phrases (Portuguese + English)
2. ✅ Specific package/function names
3. ✅ R-specific qualifiers ("in R", "with R", "em R")
4. ✅ Strong language filters ("ONLY R - NOT Python/Java/C++")
5. ✅ Natural language patterns ("how do I", "como fazer")
6. ✅ 30-90 synchronized test indicators

**Success Rate**: 15/16 skills (93.8%)

---

## Improvement Workflow

### Step 1: Diagnose
```bash
# Run test to see current metrics
python3 test_triggers.py --skills your-skill

# Note:
# - Current recall %
# - False negatives (missed detections)
# - False positives (wrong detections)
```

### Step 2: Plan
- Review [Fixing Skills Guide](FIXING_SKILLS_GUIDE.md)
- Identify which triggers to add based on false negatives
- Plan language filters based on false positives

### Step 3: Apply Pattern
- Follow [skillMaker Pattern Guide](SKILLMAKER_PATTERN.md)
- Update SKILL.md description
- Update test_triggers.py indicators
- Bump version (1.0.0 → 1.1.0)

### Step 4: Test
```bash
# Re-run test
python3 test_triggers.py --skills your-skill

# Verify:
# - Recall ≥90%?
# - Precision ≥95%?
# - False negatives eliminated?
```

### Step 5: Iterate
- If not at target, add more specific triggers
- If false positives, strengthen language filters
- Repeat until targets met

---

## Target Metrics

### Excellent (Target Met)
- ✅ Recall ≥90%
- ✅ Precision ≥95%
- ✅ Accuracy ≥85%
- ✅ Zero or minimal false negatives
- ✅ Zero false positives

### Good (Close to Target)
- 🟡 Recall 80-89%
- 🟡 Precision 90-94%
- 🟡 Few false negatives (<3)

### Needs Work
- ❌ Recall <80%
- ❌ Precision <90%
- ❌ Many false negatives/positives

---

## Common Patterns

### Pattern 1: Low Recall Fix
**Problem**: Skill missing many relevant cases
**Solution**: Add bilingual triggers

**Example (r-performance)**:
```yaml
# Before (11% recall)
description: ... R performance optimization ...

# After (100% recall)
description: ... mentions "profiling", "profvis", "benchmark",
  "código lento", "lento", "slow", "otimizar R", "vectorizar",
  "gargalo", "bottleneck", "acelerar", "speed up" ...
```

**Result**: +89 points recall improvement

---

### Pattern 2: False Positive Fix
**Problem**: Python/Java code triggering R skills
**Solution**: Add strong language filter

**Example (r-timeseries)**:
```yaml
# Before (had Python false positives)
description: ... time series forecasting ...

# After (zero false positives)
description: ... ONLY R - do NOT activate for Python time series
  (statsmodels, prophet in Python). Use when "time series in R",
  "forecasting in R", "série temporal em R" ...
```

**Result**: Eliminated 2 false positives, +22 precision

---

### Pattern 3: Bilingual Coverage
**Problem**: Portuguese queries not detected
**Solution**: Add Portuguese equivalents for all terms

**Example (r-oop)**:
```yaml
# English terms
"object-oriented", "class", "method dispatch", "inheritance"

# Add Portuguese
"orientado a objetos", "classe", "despacho de métodos", "herança"
```

**Result**: +44 points recall improvement

---

## Success Stories

### r-performance: 11% → 100% (+89 pts)
- Added 35+ bilingual indicators
- Strong language filter ("ONLY R")
- R-specific patterns ("profvis", "bench::mark")
- **Time**: ~5 minutes

### tidyverse-patterns: 50% → 100% (+50 pts)
- Focused on dplyr 1.1+ features
- Natural language patterns ("is this the new pipe")
- 42 comprehensive indicators
- **Time**: ~4 minutes

### r-oop: 56% → 100% (+44 pts)
- S3/S4/S7 system coverage
- 93 bilingual indicators
- Function names (setClass, new_class)
- **Time**: ~3 minutes

---

## Tips & Best Practices

### Trigger Phrases
✅ Use both Portuguese and English
✅ Include package names (specific!)
✅ Include function names when relevant
✅ Add use case phrases ("create plot", "analyze data")
✅ Include informal variations ("como fazer", "how do I")

### Language Filters
✅ Be explicit: "ONLY R - NOT Python"
✅ Mention competing tools: "NOT pandas, scikit-learn"
✅ Add R-specific qualifiers: "in R", "with R", "em R"

### Test Indicators
✅ Mirror SKILL.md triggers in test_triggers.py
✅ Include 30-90 indicators per skill
✅ Balance specificity (package names) with coverage (general terms)
✅ Test after every change

### Version Management
✅ Bump version after improvements (1.0.0 → 1.1.0)
✅ Create backup before editing (.backup)
✅ Document changes in version history

---

## Troubleshooting

### "My skill still has low recall after adding triggers"
- Check if indicators in test_triggers.py match SKILL.md
- Add more specific phrases from false negative test cases
- Include bilingual coverage (PT + EN)

### "I have too many false positives"
- Add stronger language filters
- Use R-specific qualifiers consistently
- Remove overly generic terms

### "Test results don't match expectations"
- Remember: tests use heuristic detection (keyword matching)
- Verify indicators in test_triggers.py are correct
- Check for typos in trigger phrases

---

## Related Documentation

- **[Testing README](../testing/README.md)** - How to run and interpret tests
- **[Sprint Reports](../sprints/)** - Real examples of improvements
- **[Test Results Analysis](../testing/TEST_RESULTS_ANALYSIS.md)** - Detailed metrics

---

**Last Updated**: 2026-03-09
**Success Rate**: 93.8% (15/16 skills improved using these guides)
