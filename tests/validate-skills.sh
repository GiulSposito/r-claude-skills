#!/bin/bash
# Skill Validation Script
# Validates R/Data Science skills for quality and consistency

set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Counters
TOTAL_SKILLS=0
PASSED_SKILLS=0
FAILED_SKILLS=0
WARNING_COUNT=0
FAILED_SKILL_NAMES=()
WARNING_SKILL_NAMES=()
PASSED_SKILL_NAMES=()

# Issue tracking (skill_name:issue format, one per line)
SKILL_ISSUES_FILE=$(mktemp)

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC}  $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

add_issue() {
    local skill=$1
    local issue=$2
    echo "$skill:$issue" >> "$SKILL_ISSUES_FILE"
}

get_issues() {
    local skill=$1
    grep "^$skill:" "$SKILL_ISSUES_FILE" 2>/dev/null | cut -d':' -f2- || true
}

# 1. Validate YAML Frontmatter
validate_yaml() {
    local skill_file=$1
    local skill_name=$(basename $(dirname "$skill_file"))
    local issues=0

    # Check if file exists
    if [[ ! -f "$skill_file" ]]; then
        add_issue "$skill_name" "File not found: $skill_file"
        return 1
    fi

    # Extract frontmatter (between first and second ---)
    local frontmatter=$(awk '/^---$/{n++; next} n==1' "$skill_file")

    if [[ -z "$frontmatter" ]]; then
        add_issue "$skill_name" "No YAML frontmatter found"
        return 1
    fi

    # Check required fields
    if ! echo "$frontmatter" | grep -q "^name:"; then
        add_issue "$skill_name" "Missing required field: name"
        ((issues++))
    fi

    if ! echo "$frontmatter" | grep -q "^description:"; then
        add_issue "$skill_name" "Missing required field: description"
        ((issues++))
    fi

    # Check if version is present and follows semver
    if echo "$frontmatter" | grep -q "^version:"; then
        local version=$(echo "$frontmatter" | grep "^version:" | cut -d':' -f2 | xargs)
        if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            add_issue "$skill_name" "Invalid version format: $version (should be semver like 1.0.0)"
            ((issues++))
        fi
    fi

    # Check user-invocable is boolean
    if echo "$frontmatter" | grep -q "^user-invocable:"; then
        local invocable=$(echo "$frontmatter" | grep "^user-invocable:" | cut -d':' -f2 | xargs)
        if [[ "$invocable" != "true" && "$invocable" != "false" ]]; then
            add_issue "$skill_name" "Invalid user-invocable value: $invocable (should be true or false)"
            ((issues++))
        fi
    fi

    # Check allowed-tools if present
    if echo "$frontmatter" | grep -q "^allowed-tools:"; then
        local tools=$(echo "$frontmatter" | grep "^allowed-tools:" | cut -d':' -f2-)
        # Basic validation - just check it's not empty
        if [[ -z "$(echo "$tools" | xargs)" ]]; then
            add_issue "$skill_name" "Empty allowed-tools field"
            ((issues++))
        fi
    fi

    return $issues
}

# 2. Validate File References
validate_file_references() {
    local skill_dir=$1
    local skill_name=$(basename "$skill_dir")
    local skill_file="$skill_dir/SKILL.md"
    local issues=0

    if [[ ! -f "$skill_file" ]]; then
        return 0
    fi

    # Find all markdown links [text](path)
    local references=$(grep -oE '\[([^\]]+)\]\(([^)]+)\)' "$skill_file" | grep -oE '\([^)]+\)' | tr -d '()' || true)

    while IFS= read -r ref; do
        # Skip URLs (http://, https://, etc.)
        if [[ "$ref" =~ ^https?:// ]]; then
            continue
        fi

        # Skip anchors
        if [[ "$ref" =~ ^# ]]; then
            continue
        fi

        # Check if file exists (relative to skill directory)
        local full_path="$skill_dir/$ref"
        if [[ ! -f "$full_path" && ! -d "$full_path" ]]; then
            add_issue "$skill_name" "Referenced file not found: $ref"
            ((issues++))
        fi
    done <<< "$references"

    # Check for references to examples/, templates/, references/ directories
    if grep -q "examples/" "$skill_file"; then
        if [[ ! -d "$skill_dir/examples" ]]; then
            add_issue "$skill_name" "References examples/ but directory doesn't exist"
            ((issues++))
        fi
    fi

    if grep -q "templates/" "$skill_file"; then
        if [[ ! -d "$skill_dir/templates" ]]; then
            add_issue "$skill_name" "References templates/ but directory doesn't exist"
            ((issues++))
        fi
    fi

    if grep -q "references/" "$skill_file"; then
        if [[ ! -d "$skill_dir/references" ]]; then
            add_issue "$skill_name" "References references/ but directory doesn't exist"
            ((issues++))
        fi
    fi

    return $issues
}

# 3. Validate R Syntax in Examples
validate_r_syntax() {
    local skill_dir=$1
    local skill_name=$(basename "$skill_dir")
    local issues=0

    # Check .R files in examples/
    if [[ -d "$skill_dir/examples" ]]; then
        while IFS= read -r r_file; do
            if [[ -f "$r_file" ]]; then
                # Try to parse the R file
                if ! Rscript --vanilla -e "tryCatch(parse('$r_file'), error=function(e) quit(status=1))" >/dev/null 2>&1; then
                    add_issue "$skill_name" "R syntax error in $(basename "$r_file")"
                    ((issues++))
                fi
            fi
        done < <(find "$skill_dir/examples" -name "*.R" 2>/dev/null || true)
    fi

    # Check .R files in templates/
    if [[ -d "$skill_dir/templates" ]]; then
        while IFS= read -r r_file; do
            if [[ -f "$r_file" ]]; then
                if ! Rscript --vanilla -e "tryCatch(parse('$r_file'), error=function(e) quit(status=1))" >/dev/null 2>&1; then
                    add_issue "$skill_name" "R syntax error in $(basename "$r_file")"
                    ((issues++))
                fi
            fi
        done < <(find "$skill_dir/templates" -name "*.R" 2>/dev/null || true)
    fi

    return $issues
}

# 4. Validate Shell Commands
validate_shell_commands() {
    local skill_file=$1
    local skill_name=$(basename $(dirname "$skill_file"))
    local issues=0

    if [[ ! -f "$skill_file" ]]; then
        return 0
    fi

    # For now, just check if there are any !`...` patterns at all
    # More sophisticated validation can be added later
    local cmd_count=$(grep -c '!`' "$skill_file" 2>/dev/null || echo "0")

    # This is just informational for now
    # We won't fail on shell commands

    return 0
}

# 5. Validate Trigger Phrases
validate_trigger_phrases() {
    local skill_file=$1
    local skill_name=$(basename $(dirname "$skill_file"))
    local issues=0

    if [[ ! -f "$skill_file" ]]; then
        return 0
    fi

    # Extract description from frontmatter
    local description=$(awk '/^---$/,/^---$/{if(/^description:/){p=1; sub(/^description: */, ""); print; next} if(p && /^[^ ]/){p=0} if(p){print}}' "$skill_file")

    if [[ -z "$description" ]]; then
        return 0
    fi

    # Count trigger phrases (words/phrases in quotes)
    local trigger_count=$(echo "$description" | grep -o '"[^"]*"' | wc -l | xargs)

    if [[ $trigger_count -lt 5 ]]; then
        add_issue "$skill_name" "Only $trigger_count trigger phrases (recommended: 5+)"
        ((issues++))
    fi

    return $issues
}

# Main validation function for a skill
validate_skill() {
    local skill_dir=$1
    local skill_name=$(basename "$skill_dir")
    local skill_file="$skill_dir/SKILL.md"

    ((TOTAL_SKILLS++))

    log_info "Validating $skill_name..."

    local has_errors=0
    local has_warnings=0

    # Run all validations
    validate_yaml "$skill_file" || ((has_errors+=$?))
    validate_file_references "$skill_dir" || ((has_errors+=$?))
    validate_r_syntax "$skill_dir" || ((has_errors+=$?))
    validate_shell_commands "$skill_file" || ((has_errors+=$?))
    validate_trigger_phrases "$skill_file" || ((has_warnings+=$?))

    # Categorize result
    if [[ $has_errors -gt 0 ]]; then
        FAILED_SKILL_NAMES+=("$skill_name")
        ((FAILED_SKILLS++))
    elif [[ $has_warnings -gt 0 ]]; then
        WARNING_SKILL_NAMES+=("$skill_name")
        ((WARNING_COUNT++))
    else
        PASSED_SKILL_NAMES+=("$skill_name")
        ((PASSED_SKILLS++))
    fi
}

# Generate final report
generate_report() {
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║          SKILL VALIDATION REPORT                          ║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}║${NC} Date: $(date '+%Y-%m-%d %H:%M:%S')                                 ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC} Skills analyzed: $TOTAL_SKILLS                                       ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC} Passed: $PASSED_SKILLS | Warnings: $WARNING_COUNT | Failed: $FAILED_SKILLS                    ${BOLD}║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"
    echo ""

    # Passed skills
    if [[ $PASSED_SKILLS -gt 0 ]]; then
        echo -e "${GREEN}✅ PASSED ($PASSED_SKILLS skills)${NC}"
        for skill in "${PASSED_SKILL_NAMES[@]}"; do
            echo "  • $skill"
        done
        echo ""
    fi

    # Warnings
    if [[ $WARNING_COUNT -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  WARNINGS ($WARNING_COUNT skills)${NC}"
        for skill in "${WARNING_SKILL_NAMES[@]}"; do
            echo "  • $skill:"
            local issues=$(get_issues "$skill")
            if [[ -n "$issues" ]]; then
                echo "$issues" | sed 's/^/    - /'
            fi
        done
        echo ""
    fi

    # Failed skills
    if [[ $FAILED_SKILLS -gt 0 ]]; then
        echo -e "${RED}❌ FAILED ($FAILED_SKILLS skills)${NC}"
        for skill in "${FAILED_SKILL_NAMES[@]}"; do
            echo "  • $skill:"
            local issues=$(get_issues "$skill")
            if [[ -n "$issues" ]]; then
                echo "$issues" | sed 's/^/    - /'
            fi
        done
        echo ""
    fi

    # Summary
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}║ SUMMARY                                                   ║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"

    if [[ $FAILED_SKILLS -eq 0 && $WARNING_COUNT -eq 0 ]]; then
        echo -e "${BOLD}║${NC} ${GREEN}✅ All validations passed!${NC}                                ${BOLD}║${NC}"
        echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
        return 0
    elif [[ $FAILED_SKILLS -eq 0 ]]; then
        echo -e "${BOLD}║${NC} ${YELLOW}⚠️  Passed with warnings${NC}                                  ${BOLD}║${NC}"
        echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
        return 0
    else
        echo -e "${BOLD}║${NC} ${RED}❌ Validation failed${NC}                                       ${BOLD}║${NC}"
        echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BOLD}🔍 Validating R/Data Science Skills...${NC}"
    echo ""

    # Check if R is available
    if ! command -v Rscript &> /dev/null; then
        log_warning "Rscript not found - skipping R syntax validation"
    fi

    # Find all skill directories
    local skills_found=0
    for skill_dir in .claude/skills/*/; do
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            validate_skill "$skill_dir"
            ((skills_found++))
        fi
    done

    if [[ $skills_found -eq 0 ]]; then
        log_error "No skills found in .claude/skills/"
        exit 1
    fi

    # Generate and display report
    generate_report
}

# Cleanup on exit
cleanup() {
    rm -f "$SKILL_ISSUES_FILE"
}
trap cleanup EXIT

# Run main
main
