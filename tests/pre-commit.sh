#!/bin/bash
# Pre-commit hook for skill validation
# Install: cp tests/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

echo "🔍 Running skill validation..."

# Run validation script
./tests/validate-skills.sh

# Capture exit code
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Pre-commit validation failed!"
    echo "Fix the issues above before committing."
    echo ""
    echo "To skip this check (not recommended):"
    echo "  git commit --no-verify"
    exit 1
fi

echo ""
echo "✅ Pre-commit validation passed!"
exit 0
