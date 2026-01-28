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
    ((warnings++))
}

log_success() {
    echo -e "${GREEN}OK:${NC} $1"
}

echo "=========================================="
echo "x-workflows Repository Validation"
echo "=========================================="
echo ""

# Check 1: .claude/rules.md exists
echo "Checking .claude/rules.md..."
if [[ -f "$REPO_ROOT/.claude/rules.md" ]]; then
    log_success ".claude/rules.md exists"
else
    log_error ".claude/rules.md is missing"
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
