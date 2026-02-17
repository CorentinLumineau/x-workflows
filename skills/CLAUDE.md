# Skills Navigation

> ccsetup v7.0 - Verb-based workflow skills with 4 canonical workflows + git-forge layer

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
| **x-workflows** | HOW to work | 22 workflow skills | `x-{verb}/` |
| x-workflows | Git operations | 10 git skills | `git-{verb}-{type}/` |
| x-workflows | Auto-triggered | 7 behavioral skills | `{name}/` |
| **x-devsecops** | WHAT to know | 53 knowledge skills | `{category}-{skill}/` |
| **local** | Project-specific | 4 | documentation, initiative, interview, orchestration |

**Total: 96 skills**

## Verb Skills by Workflow (22)

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

### UTILITY (11)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-archive` | Archive completed initiatives | archive, complete initiative |
| `/x-ask` | Zero-friction Q&A | ask, question, how |
| `/x-auto` | Auto-routing command | auto, route |
| `/x-create` | Skill/agent creation | create skill, create agent |
| `/x-docs` | Documentation management | docs, documentation |
| `/x-help` | Command reference | help, commands |
| `/x-initiative` | Multi-session tracking | initiative, milestone |
| `/x-prompt` | Prompt enhancement | enhance prompt |
| `/x-quickwins` | Pareto-scored quick wins | quickwins, quick wins, low-hanging fruit |
| `/x-setup` | Project initialization | setup, scaffold |
| `/x-team` | Team orchestration | team, parallel, swarm |

## Git Workflow Skills (10)

| Verb | Purpose | Triggers |
|------|---------|----------|
| `/git-check-ci` | CI pipeline status check | check ci, pipeline status |
| `/git-cleanup-branches` | Branch cleanup after merges | cleanup branches, prune |
| `/git-commit` | Conventional commits | commit, git commit |
| `/git-create-issue` | Create forge issue | create issue, new issue |
| `/git-create-pr` | Create pull request | create pr, pull request |
| `/git-create-release` | Release workflow | release, tag, version |
| `/git-implement-issue` | Issue-driven development | issue, gitea issue |
| `/git-merge-pr` | Merge pull request | merge pr, merge |
| `/git-resolve-conflict` | Resolve merge conflicts | resolve conflict, merge conflict |
| `/git-review-pr` | Review pull request | review pr, code review |

## Behavioral Skills (7)

| Skill | Purpose |
|-------|---------|
| `agent-awareness` | Agent delegation catalog (auto-triggered) |
| `ci-awareness` | CI pipeline detection and querying (auto-triggered) |
| `complexity-detection` | Routing logic (auto-triggered) |
| `context-awareness` | Context loading (auto-triggered) |
| `error-recovery` | Error recovery patterns (auto-triggered) |
| `forge-awareness` | Git forge detection — GitHub/Gitea/GitLab (auto-triggered) |
| `permission-awareness` | Permission escalation patterns (auto-triggered) |

## Knowledge Skills (53)

Skills are prefixed by category for organization:

| Category | Count | Skills |
|----------|-------|--------|
| **code-** | 7 | api-design, code-quality, design-patterns, error-handling, llm-optimization, refactoring-patterns, sdk-design |
| **data-** | 6 | caching, database, data-persistence, message-queues, messaging, nosql |
| **delivery-** | 7 | ci-cd, ci-cd-delivery, deployment-strategies, feature-flags, infrastructure, release-git, release-management |
| **meta-** | 4 | analysis, analysis-architecture, architecture-patterns, decision-making |
| **operations-** | 5 | disaster-recovery, incident-response, monitoring, sre-operations, sre-practices |
| **quality-** | 8 | accessibility-wcag, debugging, debugging-performance, load-testing, observability, performance, quality-gates, testing |
| **security-** | 13 | api-security, authentication, authorization, compliance, container-security, git, identity-access, input-validation, owasp, secrets, secrets-supply-chain, secure-coding, supply-chain |
| **vcs-** | 3 | conventional-commits, forge-operations, git-workflows |

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
/x-analyze → /x-plan → [APPROVAL] → /x-implement → /x-verify → /x-review → /git-commit
```

### Quick Bug Fix (ONESHOT)
```
/x-fix → /x-verify (optional) → /git-commit
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

**Version**: 7.0.0
**x-workflows**: 2.0.0 (git-forge-layer)
