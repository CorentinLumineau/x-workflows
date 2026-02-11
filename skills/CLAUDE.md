# Skills Navigation

> ccsetup v6.6 - Verb-based workflow skills with 4 canonical workflows

## Workflows Overview

All verb skills operate within one of 4 canonical workflows:

| Workflow | Purpose | Key Verbs |
|----------|---------|-----------|
| **APEX** | Systematic build/create | analyze → plan → implement → verify → review → commit |
| **ONESHOT** | Quick fixes | fix → [verify] → commit |
| **DEBUG** | Error resolution | troubleshoot → fix/implement |
| **BRAINSTORM** | Exploration/research | brainstorm ↔ research → design |

> See `WORKFLOWS.md` for detailed workflow documentation with chaining rules.

## Auto-Routing

Skills are automatically selected based on intent and complexity:

| Intent | Complexity | Route |
|--------|------------|-------|
| Build/Create | SIMPLE | x-implement |
| Build/Create | MODERATE | x-plan → x-implement |
| Build/Create | COMPLEX | **x-initiative** → full APEX flow |
| Quick Fix | SIMPLE | x-fix (autonomous) |
| Debug | SIMPLE | x-fix |
| Debug | MODERATE | x-troubleshoot |
| Debug | COMPLEX | **x-initiative** → x-troubleshoot |
| Research | ANY | x-research |
| Explore | ANY | x-brainstorm → x-design |

> See `complexity-detection` behavioral skill for detection patterns.
> Override by using explicit `/x-*` commands.

## Skills Architecture

All skills are organized in a flat structure under `skills/` for Claude Code auto-discovery:

| Source | Purpose | Skills | Naming |
|--------|---------|--------|--------|
| **x-workflows** | HOW to work | 23 verb skills | `x-{verb}/` |
| **x-devsecops** | WHAT to know | 39 knowledge skills | `{category}-{skill}/` |
| **local** | Project-specific | 4 | documentation, initiative, interview, orchestration |
| **behavioral** | Auto-triggered | 3 | agent-awareness, complexity-detection, context-awareness |

**Total: 69 skills**

## Verb Skills by Workflow (23)

### BRAINSTORM Workflow (3)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-brainstorm` | Idea capture, requirements discovery | brainstorm, ideas, requirements |
| `/x-research` | Deep investigation, evidence gathering | research, ask, investigate |
| `/x-design` | Architectural decisions | design, architecture |

### APEX Workflow (6)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-analyze` | Codebase assessment | analyze, assess, evaluate |
| `/x-plan` | Implementation planning | plan, task breakdown |
| `/x-implement` | TDD implementation | implement, build, create |
| `/x-refactor` | Safe restructuring | refactor, restructure |
| `/x-verify` | Quality gates | verify, test, lint |
| `/x-review` | Code review, audits | review, PR, audit |

### ONESHOT Workflow (1)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-fix` | Quick targeted fix | fix, bug, error, typo |

### DEBUG Workflow (1)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-troubleshoot` | Hypothesis-driven debugging | troubleshoot, debug, diagnose |

### UTILITY (12)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-archive` | Archive completed initiatives | archive, complete initiative |
| `/x-ask` | Zero-friction Q&A | ask, question, how |
| `/x-auto` | Auto-routing command | auto, route |
| `/x-commit` | Conventional commits | commit, git commit |
| `/x-create` | Skill/agent creation | create skill, create agent |
| `/x-docs` | Documentation management | docs, documentation |
| `/x-help` | Command reference | help, commands |
| `/x-initiative` | Multi-session tracking | initiative, milestone |
| `/x-prompt` | Prompt enhancement | enhance prompt |
| `/x-release` | Release workflow | release, tag, version |
| `/x-setup` | Project initialization | setup, scaffold |
| `/x-team` | Team orchestration | team, parallel, swarm |

## Behavioral Skills (3)

| Skill | Purpose |
|-------|---------|
| `agent-awareness` | Agent delegation catalog (auto-triggered) |
| `complexity-detection` | Routing logic (auto-triggered) |
| `context-awareness` | Context loading (auto-triggered) |

## Knowledge Skills (39)

Skills are prefixed by category for organization:

| Category | Count | Skills |
|----------|-------|--------|
| **code-** | 7 | api-design, code-quality, design-patterns, error-handling, llm-optimization, refactoring-patterns, sdk-design |
| **security-** | 9 | api-security, authentication, authorization, compliance, container-security, input-validation, owasp, secrets, supply-chain |
| **quality-** | 7 | accessibility-wcag, debugging, load-testing, observability, performance, quality-gates, testing |
| **delivery-** | 5 | ci-cd, deployment-strategies, feature-flags, infrastructure, release-management |
| **meta-** | 3 | analysis, architecture-patterns, decision-making |
| **data-** | 4 | caching, database, message-queues, nosql |
| **operations-** | 4 | disaster-recovery, incident-response, monitoring, sre-practices |

## Local Skills (4)

| Skill | Purpose |
|-------|---------|
| documentation | Doc sync patterns |
| initiative | Cross-session tracking |
| interview | Confidence gate |
| orchestration | Batch operation coordination |

## Quick Reference

### Feature Development (APEX)
```
/x-analyze → /x-plan → [APPROVAL] → /x-implement → /x-verify → /x-review → /x-commit
```

### Quick Bug Fix (ONESHOT)
```
/x-fix → /x-verify (optional) → /x-commit
```

### Investigation (DEBUG)
```
/x-troubleshoot → /x-fix (simple) OR /x-implement (complex)
```

### Exploration (BRAINSTORM)
```
/x-brainstorm ↔ /x-research → /x-design → [APPROVAL to exit] → /x-plan
```

### Multi-Session Project
```
/x-initiative create → [work] → /x-initiative continue → /x-archive
```

## Human Approval Gates

| Transition | Approval Required |
|------------|-------------------|
| BRAINSTORM → APEX | Yes (x-design → x-plan) |
| Plan → Implement | Yes |
| DEBUG → APEX | Yes (troubleshoot → implement) |
| Quick commit | Yes |
| Release | Yes |

## For Contributors

Skills are synced from external repositories during release:

```bash
# Sync skills from source repos
make sync-skills

# Skills are flattened:
# - x-workflows/skills/x-plan/ → skills/x-plan/
# - x-devsecops/skills/security/owasp/ → skills/security-owasp/
```

## Version

**Version**: 6.6.0
**x-workflows**: 1.0.0 (verb-first refactoring)
