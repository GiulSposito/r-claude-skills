# Skill Validation Tests

This directory contains automated validation tests for R/Data Science skills.

## Quick Start

```bash
# Run validation on all skills
./tests/validate-skills.sh

# Expected output: ✅ All validations passed!
```

## What Gets Validated

The validation script checks:

1. **YAML Frontmatter** ✅
   - Valid YAML syntax
   - Required fields present (`name`, `description`)
   - Correct field values (`version` follows semver, `user-invocable` is boolean)

2. **File References** 📁
   - All markdown links point to existing files
   - Referenced directories (`examples/`, `templates/`, `references/`) exist when mentioned

3. **R Syntax** 💻
   - All `.R` files in `examples/` and `templates/` have valid R syntax
   - Code blocks in markdown are parseable (requires R installed)

4. **Trigger Phrases** 🎯
   - Skills have at least 5 trigger phrases in description
   - Helps with auto-invocation effectiveness

## Interpreting Results

### ✅ PASSED
All validations passed - skill is ready for use.

### ⚠️ WARNINGS
Minor issues found but skill should work. Consider fixing:
- Low trigger phrase count (< 5)
- Missing optional files

### ❌ FAILED
Critical issues prevent skill from working properly:
- Invalid YAML syntax
- Missing required files
- R syntax errors in examples

## Running in CI/CD

Validation runs automatically on:
- Every push to `main` or `develop` branches
- Every pull request
- Changes to `.claude/skills/**` or `tests/**`

See `.github/workflows/validate-skills.yml` for configuration.

## Manual Testing Before Commit

### Option 1: Run Script Directly
```bash
./tests/validate-skills.sh
```

### Option 2: Install Pre-commit Hook
```bash
# Install hook
cp tests/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Now validation runs before every commit automatically
```

## Validation Details

### YAML Validation

Checks frontmatter structure:
```yaml
---
name: skill-name                    # Required
description: [detailed description] # Required
version: 1.0.0                      # Optional, but checked if present
user-invocable: false               # Optional, must be boolean
allowed-tools: Read, Write          # Optional
---
```

### File Reference Validation

Finds all links like:
```markdown
[See guide](references/guide.md)
          ^^^^^^^^^^^^^^^^^^^^^^
          Checks this file exists
```

Also checks:
- `examples/` directory exists if mentioned in SKILL.md
- `templates/` directory exists if mentioned
- `references/` directory exists if mentioned

### R Syntax Validation

For each `.R` file:
```bash
Rscript --vanilla -e "tryCatch(parse('file.R'), error=function(e) quit(status=1))"
```

This checks:
- ✅ R syntax is valid
- ✅ Code can be parsed
- ❌ Does NOT check if code runs (just syntax)

### Trigger Phrase Validation

Counts phrases in quotes:
```yaml
description: Use when mentions "trigger1", "trigger2", "trigger3"...
                               ^^^^^^^^^  ^^^^^^^^^  ^^^^^^^^^
                               Counts these as triggers
```

Recommendation: 5+ triggers for good auto-invocation.

## Troubleshooting

### "Rscript not found"
Install R:
```bash
# macOS
brew install r

# Ubuntu
sudo apt-get install r-base
```

### "Permission denied"
Make script executable:
```bash
chmod +x tests/validate-skills.sh
```

### "No skills found"
Make sure you're running from project root:
```bash
cd /path/to/claudeSkiller
./tests/validate-skills.sh
```

### Validation fails but skill works fine
Some checks are conservative. Review the specific issue:
- Trigger phrase count is a suggestion, not requirement
- File references might be false positive if path is unusual

## Adding New Validations

To add a new validation check:

1. Add validation function in `validate-skills.sh`:
```bash
validate_new_check() {
    local skill_file=$1
    local skill_name=$(basename $(dirname "$skill_file"))
    local issues=0

    # Your validation logic here
    if [[ condition ]]; then
        add_issue "$skill_name" "Issue description"
        ((issues++))
    fi

    return $issues
}
```

2. Call it in `validate_skill()`:
```bash
validate_new_check "$skill_file" || ((has_errors+=$?))
```

3. Test on all skills:
```bash
./tests/validate-skills.sh
```

## Exit Codes

- `0` - All validations passed (or passed with warnings)
- `1` - One or more skills failed validation

In CI/CD, non-zero exit code will fail the build.

## Performance

Validation typically takes:
- **Without R:** ~1-2 seconds (17 skills)
- **With R syntax check:** ~3-5 seconds (17 skills)

Fast enough to run in pre-commit hooks.

## Support

- **Issues:** Report validation bugs in GitHub Issues
- **Feature requests:** Suggest new validation checks
- **Documentation:** This README or VALIDATION_SCRIPT_SPEC.md

---

Last updated: 2026-03-09
