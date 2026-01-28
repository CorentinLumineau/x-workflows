# x-workflows Dependencies

> Explicit mapping of workflow skills (HOW) to knowledge skills (WHAT) from x-devsecops

---

## Overview

This document maps how x-workflows skills depend on x-devsecops knowledge skills. Maintaining this mapping prevents silent breakage when skills are renamed, moved, or removed.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     x-workflows                              │
│                 (HOW to work - 19 skills)                   │
│                                                             │
│  x-implement → x-verify → x-review → x-git → x-deploy       │
│       │            │          │         │         │         │
│       ▼            ▼          ▼         ▼         ▼         │
├─────────────────────────────────────────────────────────────┤
│                     x-devsecops                              │
│               (WHAT to know - 26 skills)                    │
│                                                             │
│  code-quality │ testing │ owasp │ release-mgmt │ infra      │
└─────────────────────────────────────────────────────────────┘
```

---

## Dependency Matrix

### Core Workflow Skills

| Workflow Skill | Required Dependencies | Context-Triggered |
|----------------|----------------------|-------------------|
| `x-implement` | code-quality, testing | authentication, owasp, database, api-design, error-handling |
| `x-verify` | testing, quality-gates | performance |
| `x-review` | code-quality, owasp | authentication, performance |
| `x-git` | release-management | - |
| `x-troubleshoot` | debugging | performance, error-handling |
| `x-plan` | analysis, decision-making | - |
| `x-improve` | analysis, code-quality, testing | - |
| `x-deploy` | infrastructure, ci-cd | container-security, secrets, compliance |
| `x-monitor` | monitoring | incident-response, performance |
| `x-initiative` | - | - |
| `x-docs` | - | - |
| `x-research` | - | - |
| `x-help` | - | - |
| `x-orchestrate` | - | - |
| `x-setup` | - | - |
| `x-create` | - | - |

### Behavioral Skills

| Workflow Skill | Required Dependencies | Context-Triggered |
|----------------|----------------------|-------------------|
| `complexity-detection` | debugging | - |

---

## Dependency Types

### Required Dependencies

Skills that **must** be available for the workflow to function correctly. If missing, the workflow should warn or fail gracefully.

### Context-Triggered Dependencies

Skills that are activated **conditionally** based on:
- File types being modified (e.g., auth files → `authentication`)
- Keywords in task description (e.g., "API" → `api-design`)
- Project stack detection (e.g., Docker → `container-security`)

---

## Detailed Dependency Descriptions

### x-implement

**Required:**
- `code-quality` - SOLID/DRY/KISS enforcement during implementation
- `testing` - Test-first patterns, coverage requirements

**Context-Triggered:**
| Trigger | Skill | Why |
|---------|-------|-----|
| Auth-related files | `authentication` | Secure auth patterns |
| Security-sensitive code | `owasp` | Vulnerability prevention |
| Database operations | `database` | Query patterns, migrations |
| API endpoints | `api-design` | REST/GraphQL best practices |
| Error scenarios | `error-handling` | Robust error patterns |

### x-verify

**Required:**
- `testing` - Test pyramid (70/20/10), TDD patterns
- `quality-gates` - Build, lint, type-check requirements

**Context-Triggered:**
| Trigger | Skill | Why |
|---------|-------|-----|
| Performance tests | `performance` | Benchmarking patterns |

### x-review

**Required:**
- `code-quality` - SOLID compliance checking
- `owasp` - Security vulnerability detection

**Context-Triggered:**
| Trigger | Skill | Why |
|---------|-------|-----|
| Auth changes | `authentication` | Auth security review |
| Performance-critical | `performance` | Performance impact analysis |

### x-git

**Required:**
- `release-management` - Versioning, changelog, release workflow

### x-troubleshoot

**Required:**
- `debugging` - Three-tier debugging, root cause analysis

**Context-Triggered:**
| Trigger | Skill | Why |
|---------|-------|-----|
| Performance issues | `performance` | Profiling patterns |
| Error investigation | `error-handling` | Error tracing |

### x-plan

**Required:**
- `analysis` - Pareto 80/20 prioritization
- `decision-making` - Trade-off analysis, architecture decisions

### x-improve

**Required:**
- `analysis` - Pareto prioritization for quick wins
- `code-quality` - Best practices scoring
- `testing` - Coverage evaluation

### x-deploy

**Required:**
- `infrastructure` - IaC patterns, deployment strategies
- `ci-cd` - Pipeline configuration, automation

**Context-Triggered:**
| Trigger | Skill | Why |
|---------|-------|-----|
| Container deployments | `container-security` | Image scanning, runtime security |
| Cloud deployments | `secrets` | Secrets management |
| Regulated industries | `compliance` | Compliance requirements |

### x-monitor

**Required:**
- `monitoring` - Metrics, alerting, dashboards

**Context-Triggered:**
| Trigger | Skill | Why |
|---------|-------|-----|
| Alert setup | `incident-response` | Runbook integration |
| Performance monitoring | `performance` | Performance baselines |

---

## x-devsecops Skill Catalog

### Code (5 skills)

| Skill | Description |
|-------|-------------|
| `code-quality` | SOLID, DRY, KISS, YAGNI principles |
| `design-patterns` | Creational, structural, behavioral patterns |
| `llm-optimization` | LLM-friendly code patterns |
| `error-handling` | Robust error handling patterns |
| `api-design` | REST/GraphQL API best practices |

### Security (8 skills)

| Skill | Description |
|-------|-------------|
| `authentication` | Auth patterns, session management |
| `authorization` | RBAC, ABAC, permission models |
| `owasp` | OWASP Top 10 vulnerability prevention |
| `input-validation` | Input sanitization, validation patterns |
| `secrets` | Secrets management, rotation |
| `container-security` | Image scanning, runtime security |
| `compliance` | Regulatory compliance patterns |
| `supply-chain` | Dependency security, SBOM |

### Quality (4 skills)

| Skill | Description |
|-------|-------------|
| `testing` | Testing pyramid, TDD, coverage |
| `debugging` | Three-tier debugging methodology |
| `quality-gates` | Build, lint, type-check gates |
| `performance` | Performance optimization, profiling |

### Delivery (4 skills)

| Skill | Description |
|-------|-------------|
| `ci-cd` | Pipeline automation, deployment |
| `release-management` | Versioning, changelog, releases |
| `infrastructure` | IaC, cloud patterns |
| `feature-flags` | Feature toggle patterns |

### Operations (2 skills)

| Skill | Description |
|-------|-------------|
| `monitoring` | Metrics, alerting, dashboards |
| `incident-response` | Runbooks, incident handling |

### Meta (2 skills)

| Skill | Description |
|-------|-------------|
| `analysis` | Pareto 80/20 prioritization |
| `decision-making` | Trade-off analysis, ADRs |

### Data (1 skill)

| Skill | Description |
|-------|-------------|
| `database` | Query patterns, migrations, optimization |

---

## Validation Script

Run this script to verify all dependencies exist:

```bash
#!/bin/bash
# validate-dependencies.sh

DEVSECOPS_PATH="../x-devsecops/skills"
ERRORS=0

# Required dependencies per workflow
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
)

echo "Validating x-workflows → x-devsecops dependencies..."
echo ""

for workflow in "${!REQUIRED_DEPS[@]}"; do
  deps=(${REQUIRED_DEPS[$workflow]})
  for dep in "${deps[@]}"; do
    # Search for skill in any category
    if ! find "$DEVSECOPS_PATH" -type d -name "$dep" 2>/dev/null | grep -q .; then
      echo "❌ MISSING: $workflow requires '$dep' but not found in x-devsecops"
      ((ERRORS++))
    else
      echo "✓ $workflow → $dep"
    fi
  done
done

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✅ All dependencies validated successfully"
  exit 0
else
  echo "❌ $ERRORS dependency error(s) found"
  exit 1
fi
```

---

## Maintenance Guidelines

### When to Update This Document

1. **Adding a new workflow skill** - Document its dependencies
2. **Adding a new knowledge skill** - Check if any workflow should reference it
3. **Renaming a skill** - Update all references in this matrix
4. **Removing a skill** - Check for breaking dependencies first

### Breaking Change Protocol

Before removing or renaming a knowledge skill:

1. Search this document for references
2. Update dependent workflow skills
3. Update this DEPENDENCIES.md
4. Test affected workflows
5. Document in changelog

---

## Version History

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-01-26 | Initial dependency mapping |

---

**Last Updated:** 2026-01-26
