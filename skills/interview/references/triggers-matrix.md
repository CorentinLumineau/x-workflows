# Triggers Matrix

> **Purpose**: Define specific uncertainty scenarios that trigger interview per workflow.

## Overview

Each workflow has specific scenarios that should activate the interview behavioral skill. This matrix documents these triggers to ensure consistent application across all workflows.

## Trigger Categories

| Category | Description | Priority |
|----------|-------------|----------|
| **Ambiguity** | Multiple valid interpretations | HIGH |
| **Missing** | Required data not provided | HIGH |
| **Risk** | Irreversible or significant impact | CRITICAL |
| **Confidence** | Agent self-assessment low | MEDIUM |

## Per-Workflow Triggers

### x-plan

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| brainstorm | Undefined problem space | Ambiguity | "Help me plan something" |
| brainstorm | No success criteria | Missing | "Make it better" |
| brainstorm | Multiple stakeholders unspecified | Missing | "The team needs..." |
| design | Multiple architectural approaches | Ambiguity | "Add authentication" |
| design | Unknown technical constraints | Missing | No stack specified |
| design | Breaking change potential | Risk | Affects existing APIs |
| analyze | Scope boundaries unclear | Ambiguity | "Analyze the system" |
| analyze | No comparison baseline | Missing | "Is this good?" |

### x-implement

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| implement | Multiple implementation approaches | Ambiguity | "Add a button" (where?) |
| implement | Missing acceptance criteria | Missing | "Make it work" |
| implement | Breaking change to public API | Risk | Changes function signature |
| implement | TDD scope unclear | Ambiguity | "Add tests" (which?) |
| fix | Root cause unclear | Ambiguity | "Fix the bug" |
| fix | Multiple potential causes | Ambiguity | Error could be A, B, or C |
| fix | No reproduction steps | Missing | "It's broken" |
| refactor | Scope of refactoring undefined | Ambiguity | "Clean this up" |
| refactor | No performance baseline | Missing | "Make it faster" |
| cleanup | Definition of "clean" unclear | Ambiguity | "Remove dead code" |

### x-troubleshoot

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| troubleshoot | Vague problem description | Ambiguity | "It doesn't work" |
| troubleshoot | Multiple hypotheses valid | Ambiguity | Could be network, auth, or data |
| troubleshoot | No error message provided | Missing | "Something went wrong" |
| troubleshoot | Environment unspecified | Missing | "In production" (which?) |
| debug | Reproduction unclear | Missing | "Sometimes fails" |
| explain | Context level unclear | Ambiguity | "Explain this" (to whom?) |

### x-git

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| commit | Mixed changes in staging | Ambiguity | Multiple unrelated files |
| commit | Commit message scope unclear | Ambiguity | Large diff, unclear focus |
| release | Version bump type unclear | Ambiguity | Is this major/minor/patch? |
| release | Unreleased changes unreviewed | Risk | No changelog review |
| release | Tag already exists | Risk | Would overwrite |
| release | Breaking changes present | Risk | Needs migration guide |

### x-deploy

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| deploy | Target environment unclear | Missing | "Deploy it" (where?) |
| deploy | Production deployment | Risk | Always requires confirmation |
| deploy | No rollback plan | Risk | What if it fails? |
| deploy | Database migrations present | Risk | Irreversible data changes |
| deploy | Feature flags not configured | Missing | New feature exposure |
| rollback | Target version unclear | Missing | Roll back to what? |
| rollback | Data loss potential | Risk | Migration reversal |

### x-verify

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| verify | Test scope unclear | Ambiguity | "Run tests" (which?) |
| verify | Test failure interpretation | Ambiguity | Is this expected? |
| verify | Fix strategy for failures | Ambiguity | Fix code or fix test? |
| build | Build target unclear | Missing | "Build it" (what config?) |
| coverage | Coverage threshold undefined | Missing | "Check coverage" (target?) |

### x-review

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| review | Review focus unclear | Ambiguity | "Review this" (for what?) |
| review | Severity classification | Ambiguity | Is this blocking? |
| review | Standards reference missing | Missing | What style guide? |
| audit | Audit scope undefined | Ambiguity | "Audit security" (all?) |
| audit | Compliance requirements unclear | Missing | Which standards? |

### x-improve

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| improve | "Better" not defined | Ambiguity | "Make it better" |
| improve | Pareto assumptions | Confidence | Which 20% has 80% impact? |
| improve | Quick-win selection | Ambiguity | Multiple valid choices |
| improve | Scope boundaries | Ambiguity | Just this file? Module? |

### x-initiative

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| create | Scope definition unclear | Ambiguity | "Start a project" |
| create | Milestone breakdown missing | Missing | No phases defined |
| create | Success metrics undefined | Missing | How to measure done? |
| continue | Current state unknown | Missing | Where did we leave off? |
| archive | Completion criteria unclear | Ambiguity | Is it really done? |

### x-docs

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| docs | Target audience unclear | Ambiguity | "Document this" (for whom?) |
| docs | Documentation type undefined | Ambiguity | API docs? User guide? |
| generate | Template selection | Ambiguity | Multiple templates apply |
| sync | Source of truth unclear | Ambiguity | Which version is correct? |
| cleanup | Deletion criteria | Risk | What can be removed? |

### x-research

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| ask | Question scope unclear | Ambiguity | "Find out about..." |
| ask | No context provided | Missing | "What is this?" |
| deep | Research depth undefined | Ambiguity | "Research authentication" |
| deep | Deliverable format unclear | Ambiguity | "Do deep research" |
| deep | Success criteria missing | Missing | "Analyze competitors" |

### x-help

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| help | Command scope unclear | Ambiguity | "Help with something" |
| rules | Rule purpose undefined | Missing | "Create a rule" |
| rules | Rule scope unclear | Ambiguity | "Add rule for testing" |

### x-orchestrate

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| orchestrate | Workflow selection | Ambiguity | "Run a workflow" |
| orchestrate | Checkpoint placement | Ambiguity | "Orchestrate this" |
| background | Task scope unclear | Missing | "Run in background" |
| agent | Agent selection | Ambiguity | "Use an agent" |

### x-create

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| skill | Skill purpose unclear | Ambiguity | "Create a skill" |
| skill | Activation triggers missing | Missing | "Add new skill" |
| command | Command behavior undefined | Ambiguity | "Create command" |
| command | Arguments unclear | Missing | "Add slash command" |
| agent | Agent responsibility unclear | Ambiguity | "Create an agent" |

### x-setup

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| setup | Project type unclear | Ambiguity | "Set up documentation" |
| setup | Stack detection failed | Missing | "Initialize structure" |
| setup | Existing docs conflict | Risk | "Create doc structure" |

### x-monitor

| Mode | Trigger | Category | Example |
|------|---------|----------|---------|
| setup | Monitoring scope unclear | Ambiguity | "Set up monitoring" |
| setup | SLO targets undefined | Missing | "Configure observability" |
| alert | Alert thresholds undefined | Missing | "Add alerting" |
| alert | Severity classification unclear | Ambiguity | "Configure alerts" |
| dashboard | Target audience unclear | Ambiguity | "Create dashboard" |
| dashboard | Metrics selection needed | Ambiguity | "Build dashboard" |

## Universal Triggers

These triggers apply to ALL workflows:

| Trigger | Category | Detection |
|---------|----------|-----------|
| User says "just" | Ambiguity | Implies scope minimization |
| User says "like before" | Missing | References unknown context |
| User says "you know" | Missing | Assumes shared knowledge |
| User says "etc" | Missing | Incomplete specification |
| Request involves deletion | Risk | Data loss potential |
| Request affects production | Risk | User impact potential |
| First request in session | Confidence | No context established |

## Trigger Detection Keywords

```yaml
ambiguity_keywords:
  - "something like"
  - "maybe"
  - "probably"
  - "I think"
  - "sort of"
  - "kind of"
  - "or something"
  - "whatever works"
  - "you decide"

missing_keywords:
  - "the usual"
  - "as expected"
  - "you know what"
  - "like always"
  - "the thing"
  - "that file"
  - "fix it"

risk_keywords:
  - "production"
  - "delete"
  - "remove"
  - "deploy"
  - "release"
  - "all users"
  - "database"
  - "migration"
```

## Trigger Prioritization

When multiple triggers detected:

1. **CRITICAL (Risk)** - Always interview first
2. **HIGH (Missing)** - Address before proceeding
3. **HIGH (Ambiguity)** - Clarify interpretation
4. **MEDIUM (Confidence)** - Can batch with others

## State Representation

```json
{
  "triggers": [
    {
      "type": "ambiguity",
      "description": "Multiple implementation approaches",
      "source": "user_request",
      "keyword": "add a button",
      "priority": "HIGH"
    },
    {
      "type": "missing",
      "description": "No location specified",
      "source": "analysis",
      "dimension": "technical",
      "priority": "HIGH"
    }
  ]
}
```
