#!/bin/bash
# validate-dependencies.sh
# Parses DEPENDENCIES.md and verifies all referenced x-devsecops skills exist.
# Also checks for circular dependencies between workflow skills.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPS_FILE="$REPO_ROOT/DEPENDENCIES.md"
DEVSECOPS_PATH="${DEVSECOPS_PATH:-$REPO_ROOT/../x-devsecops/skills}"
WORKFLOWS_PATH="$REPO_ROOT/skills"

ERRORS=0
WARNINGS=0
CHECKED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "=== x-workflows Dependency Validator ==="
echo ""

if [[ ! -f "$DEPS_FILE" ]]; then
  echo -e "${RED}ERROR: DEPENDENCIES.md not found at $DEPS_FILE${NC}"
  exit 1
fi

if [[ ! -d "$DEVSECOPS_PATH" ]]; then
  echo -e "${RED}ERROR: x-devsecops skills not found at $DEVSECOPS_PATH${NC}"
  echo "Set DEVSECOPS_PATH env var to override."
  exit 1
fi

# Hard-coded dependency matrix parsed from DEPENDENCIES.md structure
# Required dependencies
declare -A REQUIRED_DEPS=(
  ["x-implement"]="code-quality testing"
  ["x-verify"]="testing quality-gates"
  ["x-review"]="code-quality owasp"
  ["x-git"]="release-management"
  ["x-troubleshoot"]="debugging"
  ["x-plan"]="analysis decision-making"
  ["x-improve"]="analysis code-quality testing"
  ["x-deploy"]="infrastructure ci-cd"
  ["x-monitor"]="monitoring"
  ["complexity-detection"]="debugging"
)

# Context-triggered dependencies
declare -A CONTEXT_DEPS=(
  ["x-implement"]="authentication owasp database api-design error-handling"
  ["x-verify"]="performance"
  ["x-review"]="authentication performance"
  ["x-troubleshoot"]="performance error-handling"
  ["x-deploy"]="container-security secrets compliance"
  ["x-monitor"]="incident-response performance"
)

# Also dynamically parse any `skill-name` entries from the dependency matrix tables
# to catch additions not in the hardcoded list above
echo "Validating ${#REQUIRED_DEPS[@]} workflow skills with required dependencies."
echo "Validating ${#CONTEXT_DEPS[@]} workflow skills with context-triggered dependencies."
echo ""

check_skill_exists() {
  local skill_name="$1"
  find "$DEVSECOPS_PATH" -maxdepth 2 -type d -name "$skill_name" 2>/dev/null | grep -q .
}

echo "--- Checking Required Dependencies ---"
for workflow in $(echo "${!REQUIRED_DEPS[@]}" | tr ' ' '\n' | sort); do
  read -ra deps <<< "${REQUIRED_DEPS[$workflow]}"
  for dep in "${deps[@]}"; do
    ((CHECKED++))
    if check_skill_exists "$dep"; then
      echo -e "${GREEN}OK${NC}  $workflow -> $dep"
    else
      echo -e "${RED}MISSING${NC}  $workflow requires '$dep' — not found in x-devsecops"
      ((ERRORS++))
    fi
  done
done

echo ""
echo "--- Checking Context-Triggered Dependencies ---"
for workflow in $(echo "${!CONTEXT_DEPS[@]}" | tr ' ' '\n' | sort); do
  read -ra deps <<< "${CONTEXT_DEPS[$workflow]}"
  for dep in "${deps[@]}"; do
    ((CHECKED++))
    if check_skill_exists "$dep"; then
      echo -e "${GREEN}OK${NC}  $workflow ~> $dep (context)"
    else
      echo -e "${YELLOW}WARN${NC}  $workflow context-triggers '$dep' — not found in x-devsecops"
      ((WARNINGS++))
    fi
  done
done

echo ""
echo "--- Checking for Circular Dependencies ---"
CIRCULAR=0
for workflow in $(echo "${!REQUIRED_DEPS[@]}" | tr ' ' '\n' | sort); do
  read -ra deps <<< "${REQUIRED_DEPS[$workflow]}"
  for dep in "${deps[@]}"; do
    if [[ "$dep" == x-* ]]; then
      echo -e "${RED}CIRCULAR${NC}  $workflow depends on workflow skill '$dep'"
      ((CIRCULAR++))
      ((ERRORS++))
    fi
  done
done
if [[ $CIRCULAR -eq 0 ]]; then
  echo -e "${GREEN}OK${NC}  No circular dependencies detected."
fi

echo ""
echo "--- Checking Workflow Skills Exist ---"
for workflow in $(echo "${!REQUIRED_DEPS[@]}" | tr ' ' '\n' | sort); do
  if [[ -d "$WORKFLOWS_PATH/$workflow" ]]; then
    echo -e "${GREEN}OK${NC}  $workflow/ exists"
  else
    echo -e "${YELLOW}WARN${NC}  $workflow declared but not found in skills/"
    ((WARNINGS++))
  fi
done

echo ""
echo "=== Summary ==="
echo "Checked: $CHECKED dependencies"
echo "Errors:  $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}All dependencies validated successfully.${NC}"
  exit 0
else
  echo -e "${RED}$ERRORS dependency error(s) found.${NC}"
  exit 1
fi
