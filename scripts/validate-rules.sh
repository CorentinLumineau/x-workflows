#!/usr/bin/env bash
# validate-rules.sh - Validates x-workflows repository structure and rules compliance
# Usage: ./scripts/validate-rules.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
    ((errors++))
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
    ((warnings++)) || true
}

log_success() {
    echo -e "${GREEN}OK:${NC} $1"
}

echo "=========================================="
echo "x-workflows Repository Validation"
echo "=========================================="
echo ""

# Check 1: .claude/rules/ directory exists (modular rules)
echo "Checking .claude/rules/..."
if [[ -d "$REPO_ROOT/.claude/rules" ]]; then
    rule_count=$(find "$REPO_ROOT/.claude/rules" -name "*.md" | wc -l)
    if [[ $rule_count -gt 0 ]]; then
        log_success ".claude/rules/ directory exists with $rule_count rule file(s)"
    else
        log_error ".claude/rules/ directory exists but has no .md files"
    fi
else
    log_error ".claude/rules/ directory is missing"
fi

# Check 2: Every skill directory has SKILL.md
echo ""
echo "Checking skill structures..."
if [[ -d "$REPO_ROOT/skills" ]]; then
    for skill_dir in "$REPO_ROOT/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
            skill_name=$(basename "$skill_dir")
            if [[ -f "${skill_dir}SKILL.md" ]]; then
                log_success "skills/$skill_name has SKILL.md"
            else
                log_error "skills/$skill_name is missing SKILL.md"
            fi
        fi
    done
else
    log_warning "skills/ directory not found"
fi

# Check 3: No ccsetup command dependencies
echo ""
echo "Checking for forbidden dependencies..."
if grep -r "ccsetup/commands" "$REPO_ROOT/skills" 2>/dev/null; then
    log_error "Found references to ccsetup/commands (forbidden dependency)"
else
    log_success "No ccsetup/commands dependencies found"
fi

if grep -r "ccsetup/agents" "$REPO_ROOT/skills" 2>/dev/null; then
    log_error "Found references to ccsetup/agents (forbidden dependency)"
else
    log_success "No ccsetup/agents dependencies found"
fi

# Check 4: Mode references exist for declared modes
echo ""
echo "Checking mode references..."
for skill_dir in "$REPO_ROOT/skills"/*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")
        if [[ -d "${skill_dir}references" ]]; then
            mode_count=$(find "${skill_dir}references" -name "mode-*.md" 2>/dev/null | wc -l)
            if [[ $mode_count -gt 0 ]]; then
                log_success "skills/$skill_name has $mode_count mode reference(s)"
            fi
        fi
    fi
done

# Check 5: Frontmatter contract for x-* workflow skills
echo ""
echo "Checking frontmatter contract for workflow skills..."
for skill_dir in "$REPO_ROOT/skills"/x-*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")
        skill_file="${skill_dir}SKILL.md"

        if [[ ! -f "$skill_file" ]]; then
            continue  # Already caught by Check 2
        fi

        # Extract frontmatter (content between first two --- lines)
        frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed '1d;$d')

        if [[ -z "$frontmatter" ]]; then
            log_error "skills/$skill_name/SKILL.md has no YAML frontmatter"
            continue
        fi

        # Check: name field matches directory name
        fm_name=$(echo "$frontmatter" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//')
        if [[ "$fm_name" == "$skill_name" ]]; then
            log_success "skills/$skill_name frontmatter name matches directory"
        else
            log_error "skills/$skill_name frontmatter name '$fm_name' does not match directory name '$skill_name'"
        fi

        # Check: category is workflow
        fm_category=$(echo "$frontmatter" | grep -E '^[[:space:]]*category:' | head -1 | sed 's/^[[:space:]]*category:[[:space:]]*//')
        if [[ "$fm_category" == "workflow" ]]; then
            log_success "skills/$skill_name has category: workflow"
        else
            log_error "skills/$skill_name missing or incorrect category (expected 'workflow', got '$fm_category')"
        fi

        # Check: description exists and is single-line (no | or > YAML multiline)
        fm_desc_line=$(echo "$frontmatter" | grep -E '^description:' | head -1)
        if [[ -n "$fm_desc_line" ]]; then
            fm_desc_value=$(echo "$fm_desc_line" | sed 's/^description:[[:space:]]*//')
            if [[ "$fm_desc_value" == "|" || "$fm_desc_value" == ">" || "$fm_desc_value" == "|+" || "$fm_desc_value" == ">-" ]]; then
                log_error "skills/$skill_name description must be single-line (found YAML multiline indicator)"
            else
                log_success "skills/$skill_name has single-line description"

                # Check: Description length (budget optimization)
                desc_len=${#fm_desc_value}
                if [[ $desc_len -gt 120 ]]; then
                    log_warning "skills/$skill_name description is $desc_len chars (recommended: ≤120)"
                fi

                # Check: Description is YAML-safe (no unquoted colon-space that breaks parsing)
                if echo "$fm_desc_value" | grep -qE ': [a-z]' && ! echo "$fm_desc_line" | grep -qE "^description: [\"']"; then
                    log_warning "skills/$skill_name description contains ': ' — should be quoted to avoid YAML parse errors"
                fi
            fi
        else
            log_error "skills/$skill_name is missing description field"
        fi

        # Check: allowed-tools is present
        if echo "$frontmatter" | grep -qE '^allowed-tools:'; then
            log_success "skills/$skill_name has allowed-tools"
        else
            log_error "skills/$skill_name is missing allowed-tools field"
        fi

        # Check: license is Apache-2.0
        fm_license=$(echo "$frontmatter" | grep -E '^license:' | head -1 | sed 's/^license:[[:space:]]*//')
        if [[ "$fm_license" == "Apache-2.0" ]]; then
            log_success "skills/$skill_name has license: Apache-2.0"
        else
            log_error "skills/$skill_name missing or incorrect license (expected 'Apache-2.0', got '$fm_license')"
        fi
    fi
done

# Check 6: Frontmatter description checks for behavioral skills (non x-* skills)
echo ""
echo "Checking frontmatter descriptions for behavioral skills..."
for skill_dir in "$REPO_ROOT/skills"/*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")

        # Skip x-* workflow skills (already checked above)
        if [[ "$skill_name" == x-* ]]; then
            continue
        fi

        skill_file="${skill_dir}SKILL.md"
        if [[ ! -f "$skill_file" ]]; then
            continue  # Already caught by Check 2
        fi

        # Extract frontmatter (content between first two --- lines)
        frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed '1d;$d')

        if [[ -z "$frontmatter" ]]; then
            continue
        fi

        # Check: description exists
        fm_desc_line=$(echo "$frontmatter" | grep -E '^description:' | head -1)
        if [[ -n "$fm_desc_line" ]]; then
            fm_desc_value=$(echo "$fm_desc_line" | sed 's/^description:[[:space:]]*//')

            # Check: Description is single-line (no | or > YAML multiline)
            if [[ "$fm_desc_value" == "|" || "$fm_desc_value" == ">" || "$fm_desc_value" == "|+" || "$fm_desc_value" == ">-" ]]; then
                log_error "skills/$skill_name description must be single-line (found YAML multiline indicator)"
            else
                log_success "skills/$skill_name has single-line description"

                # Check: Description length (budget optimization)
                desc_len=${#fm_desc_value}
                if [[ $desc_len -gt 120 ]]; then
                    log_warning "skills/$skill_name description is $desc_len chars (recommended: ≤120)"
                fi

                # Check: Description is YAML-safe (no unquoted colon-space that breaks parsing)
                if echo "$fm_desc_value" | grep -qE ': [a-z]' && ! echo "$fm_desc_line" | grep -qE "^description: [\"']"; then
                    log_warning "skills/$skill_name description contains ': ' — should be quoted to avoid YAML parse errors"
                fi
            fi
        fi
    fi
done

# Check 7: Frontmatter spec compliance (field placement)
echo ""
echo "Checking frontmatter spec compliance (field placement)..."

# Fields that MUST be at top-level (not nested under metadata:)
TOPLEVEL_FIELDS=("user-invocable" "argument-hint" "allowed-tools" "model" "context" "agent" "hooks" "disable-model-invocation")

# Behavioral skills (non-workflow, non-git, non-ci-*-issue)
BEHAVIORAL_SKILLS=()

for skill_dir in "$REPO_ROOT/skills"/*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")
        skill_file="${skill_dir}SKILL.md"

        if [[ ! -f "$skill_file" ]]; then
            continue  # Already caught by Check 2
        fi

        # Extract frontmatter (content between first two --- lines)
        frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed '1d;$d')

        if [[ -z "$frontmatter" ]]; then
            continue
        fi

        # Determine skill type
        # x-* and git-* are user-invocable workflow skills
        # Everything else is behavioral (auto-triggered)
        is_workflow=false
        if [[ "$skill_name" == x-* || "$skill_name" == git-* ]]; then
            is_workflow=true
        fi

        # Check 7a: Top-level fields must NOT be indented (nested under metadata:)
        for field in "${TOPLEVEL_FIELDS[@]}"; do
            # Look for the field with leading whitespace (indented = nested)
            if echo "$frontmatter" | grep -qE "^[[:space:]]+${field}:"; then
                log_error "skills/$skill_name has '$field' nested under metadata (must be top-level)"
            fi
        done

        # Check 7b: user-invocable presence and correctness by skill type
        if [[ "$is_workflow" == true ]]; then
            if echo "$frontmatter" | grep -qE "^user-invocable:[[:space:]]*true"; then
                log_success "skills/$skill_name has user-invocable: true (workflow)"
            elif echo "$frontmatter" | grep -qE "^user-invocable:"; then
                log_error "skills/$skill_name is a workflow skill but user-invocable is not 'true'"
            else
                log_error "skills/$skill_name is a workflow skill missing top-level user-invocable: true"
            fi
        else
            # Behavioral skill
            if echo "$frontmatter" | grep -qE "^user-invocable:[[:space:]]*false"; then
                log_success "skills/$skill_name has user-invocable: false (behavioral)"
            elif echo "$frontmatter" | grep -qE "^user-invocable:"; then
                log_error "skills/$skill_name is a behavioral skill but user-invocable is not 'false'"
            else
                log_error "skills/$skill_name is a behavioral skill missing top-level user-invocable: false"
            fi
        fi

        # Check 7c: argument-hint format (if present)
        arg_hint=$(echo "$frontmatter" | grep -E '^argument-hint:' | head -1 | sed 's/^argument-hint:[[:space:]]*//' | sed 's/^["'"'"']//' | sed 's/["'"'"']$//' || true)
        if [[ -n "$arg_hint" ]]; then
            if echo "$arg_hint" | grep -qE '[<\[]'; then
                log_success "skills/$skill_name argument-hint uses bracket convention"
            else
                log_warning "skills/$skill_name argument-hint '$arg_hint' should use <required> or [optional] brackets"
            fi
        fi
    fi
done

# Summary
echo ""
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "Errors:   ${RED}$errors${NC}"
echo -e "Warnings: ${YELLOW}$warnings${NC}"
echo ""

if [[ $errors -gt 0 ]]; then
    echo -e "${RED}Validation FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Validation PASSED${NC}"
    exit 0
fi
