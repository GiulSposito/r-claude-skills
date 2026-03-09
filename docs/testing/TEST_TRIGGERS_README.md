# Test Triggers - Usage Guide

## Overview

`test_triggers.py` is an automated test suite for validating skill trigger activation in Claude Code. It tests whether R/Data Science skills are correctly invoked based on user prompts.

## Features

✅ **200+ Test Cases**: Comprehensive prompts for all 17 R/Data Science skills
✅ **3 Test Types**: Positive (should trigger), Context (implicit trigger), Negative (should NOT trigger)
✅ **Metrics Calculation**: Precision, Recall, Accuracy, F1 Score
✅ **Problem Detection**: Automatically identifies skills with low performance
✅ **JSON Reports**: Detailed results for further analysis

## Installation

### Prerequisites

```bash
# Python 3.7+
python3 --version

# No additional dependencies required (uses stdlib only)
```

### Setup

```bash
# Make executable
chmod +x test_triggers.py

# Or run with python
python3 test_triggers.py
```

## Usage

### Basic Usage

Run all tests:
```bash
./test_triggers.py
```

### Test Specific Skills

Test only tidymodels and ggplot2:
```bash
./test_triggers.py --skills r-tidymodels ggplot2
```

Test all tidyverse skills:
```bash
./test_triggers.py --skills tidyverse-expert tidyverse-patterns r-datascience
```

### Verbose Output

See each individual test result:
```bash
./test_triggers.py --verbose
```

### Custom Output File

Save report to specific location:
```bash
./test_triggers.py --output reports/trigger_test_$(date +%Y%m%d).json
```

### Combined Options

```bash
./test_triggers.py \
  --skills r-tidymodels ggplot2 r-shiny \
  --verbose \
  --output my_test_report.json
```

## Test Structure

### Test Types

**1. Positive Tests** - Prompts that SHOULD activate the skill:
```python
"Crie um modelo de classificação com tidymodels"
"Como fazer feature engineering com recipes?"
"Preciso fazer cross-validation"
```

**2. Context Tests** - Code snippets that should trigger implicitly:
```python
"library(tidymodels)\n\ndata_split <- initial_split(data)\n# Next steps?"
"I need to preprocess data before modeling"
```

**3. Negative Tests** - Prompts that should NOT activate:
```python
"Scikit-learn random forest"  # Wrong language
"Keras model training"        # Wrong framework
```

## Output

### Console Output

```
================================================================================
Testing skill: r-tidymodels
================================================================================

▶ Testing POSITIVE triggers (6 tests)...
▶ Testing CONTEXT triggers (3 tests)...
▶ Testing NEGATIVE triggers (3 tests)...

📊 Summary for r-tidymodels:
   Recall:    90.0% (9 TP, 1 FN)
   Precision: 100.0% (9 TP, 0 FP)
   Accuracy:  91.7%

================================================================================
FINAL REPORT
================================================================================

Skill                     Recall     Precision  Accuracy   F1
--------------------------------------------------------------------------------
r-tidymodels                90.0%      100.0%      91.7%      94.7%
ggplot2                    100.0%       91.0%      95.0%      95.3%
...
```

### JSON Report

Detailed results saved to `trigger_test_report_YYYYMMDD_HHMMSS.json`:

```json
{
  "timestamp": "2026-03-09T10:30:00",
  "tests_run": 204,
  "skills": {
    "r-tidymodels": {
      "positive": [
        {
          "prompt": "Crie um modelo...",
          "expected": "r-tidymodels",
          "detected": ["r-tidymodels", "r-datascience"],
          "success": true,
          "type": "true_positive"
        }
      ],
      "metrics": {
        "recall": 0.90,
        "precision": 1.0,
        "accuracy": 0.917,
        "f1_score": 0.947
      }
    }
  }
}
```

## Metrics Explained

**Recall** (Sensitivity): Of all prompts that SHOULD trigger the skill, what % actually did?
- Target: ≥90%
- Formula: TP / (TP + FN)

**Precision**: Of all times the skill triggered, what % were correct?
- Target: ≥95%
- Formula: TP / (TP + FP)

**Accuracy**: Overall correctness across all test types
- Formula: (TP + TN) / (TP + TN + FP + FN)

**F1 Score**: Harmonic mean of precision and recall
- Formula: 2 × (Precision × Recall) / (Precision + Recall)

## Problem Detection

The script automatically identifies skills needing improvement:

```
================================================================================
PROBLEM AREAS (Recall < 90% or Precision < 95%)
================================================================================

⚠️  r-performance:
   - Low recall (75.0%)
   False negatives (2):
      • Este código R está lento, como otimizar?
      • Como vectorizar este loop?
```

## Test Coverage by Skill

| Skill | Positive | Context | Negative | Total |
|-------|----------|---------|----------|-------|
| r-datascience | 5 | 3 | 3 | 11 |
| tidyverse-expert | 6 | 3 | 3 | 12 |
| tidyverse-patterns | 5 | 3 | 3 | 11 |
| r-tidymodels | 6 | 3 | 3 | 12 |
| ggplot2 | 6 | 3 | 3 | 12 |
| r-shiny | 6 | 3 | 3 | 12 |
| r-bayes | 6 | 3 | 3 | 12 |
| r-timeseries | 6 | 3 | 3 | 12 |
| r-text-mining | 6 | 3 | 3 | 12 |
| r-performance | 6 | 3 | 3 | 12 |
| r-package-development | 6 | 3 | 3 | 12 |
| r-oop | 6 | 3 | 3 | 12 |
| r-style-guide | 6 | 3 | 3 | 12 |
| tdd-workflow | 6 | 3 | 3 | 12 |
| dm-relational | 6 | 3 | 3 | 12 |
| rlang-patterns | 6 | 3 | 3 | 12 |
| skillMaker | 5 | 0 | 3 | 8 |
| **TOTAL** | **97** | **45** | **51** | **193** |

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Skill Trigger Tests

on: [push, pull_request]

jobs:
  test-triggers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Run trigger tests
        run: |
          ./test_triggers.py --output test_results.json

      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: trigger-test-results
          path: test_results.json

      - name: Check metrics
        run: |
          if grep -q '"recall": 0\.[0-8]' test_results.json; then
            echo "❌ Recall below 90% threshold"
            exit 1
          fi
```

## Extending the Test Suite

### Adding Tests for a New Skill

Edit `test_triggers.py` and add to `TRIGGER_TESTS` dict:

```python
TRIGGER_TESTS = {
    # ... existing skills ...

    "my-new-skill": {
        "positive": [
            "Prompt that should trigger the skill",
            "Another trigger phrase",
            # Add 5-6 prompts
        ],
        "context": [
            "Code snippet that should trigger implicitly",
            # Add 3 context tests
        ],
        "negative": [
            "Prompt that should NOT trigger",
            # Add 3 negative tests
        ],
    },
}
```

### Customizing Detection Logic

Modify `detect_skills_in_response()` function to improve skill detection:

```python
def detect_skills_in_response(response: str) -> List[str]:
    # Add your custom detection logic here
    # Example: Check for specific patterns, keywords, etc.

    skill_indicators = {
        "my-skill": ["keyword1", "keyword2", "pattern"],
    }
    # ... rest of logic
```

## Troubleshooting

### Issue: All tests failing

**Cause**: This is a MOCK implementation for demonstration

**Solution**:
1. Integrate with actual Claude Code CLI
2. Parse real skill invocation logs
3. Use Claude's debug output to detect skill activation

### Issue: Can't detect skill invocations

**Cause**: `detect_skills_in_response()` uses heuristics

**Solution**: Enhance detection by:
1. Parsing Claude Code logs (`~/.claude/logs/`)
2. Using `--debug` flag if available
3. Adding more skill indicators to `skill_indicators` dict

### Issue: Tests too slow

**Cause**: Making real API calls for each test

**Solution**:
1. Use parallel execution (add multiprocessing)
2. Cache responses for identical prompts
3. Test only changed skills in CI

## Production Integration Notes

⚠️ **Current Status**: This is a DEMONSTRATION script

To make production-ready:

### 1. Real Claude Code Integration

Replace `run_claude_command()` with actual CLI invocation:

```python
def run_claude_command(prompt: str) -> Dict[str, Any]:
    # Option A: Use subprocess with actual claude CLI
    result = subprocess.run(
        ['claude-code', '--non-interactive', '--debug', prompt],
        capture_output=True,
        text=True
    )

    # Option B: Use Claude Code Python API (if available)
    from claude_code import Client
    client = Client()
    response = client.chat(prompt, debug=True)

    # Parse debug output to extract invoked skills
    invoked_skills = parse_debug_output(response.debug_info)

    return {
        "success": True,
        "invoked_skills": invoked_skills,
        "response": response.text
    }
```

### 2. Log Parsing

```python
def parse_claude_logs() -> List[str]:
    """Parse ~/.claude/logs/ to find skill invocations"""
    log_dir = Path.home() / ".claude" / "logs"
    latest_log = max(log_dir.glob("*.log"), key=lambda p: p.stat().st_mtime)

    invoked_skills = []
    with open(latest_log) as f:
        for line in f:
            if "skill invoked:" in line:
                skill = extract_skill_name(line)
                invoked_skills.append(skill)

    return invoked_skills
```

### 3. Async Execution

```python
import asyncio

async def run_tests_parallel(prompts: List[str]) -> List[Dict]:
    tasks = [run_claude_command_async(prompt) for prompt in prompts]
    return await asyncio.gather(*tasks)
```

## Related Files

- `TESTING_STRATEGY.md` - Complete testing strategy document
- `test_quality.R` - Code quality evaluation script
- `coverage_analysis.R` - Skill coverage analysis script

## Contributing

To add more test cases:

1. Fork the repo
2. Add tests to `TRIGGER_TESTS` in `test_triggers.py`
3. Run the suite: `./test_triggers.py --verbose`
4. Submit PR with test results

## License

Part of claudeSkiller project - see root LICENSE file
