# Skills Navigation

> ccsetup v7.0 - Verb-based workflow skills with 4 canonical workflows + git-forge layer

## Workflows Overview

All verb skills operate within one of 4 canonical workflows:

| Workflow | Purpose | Key Verbs |
|----------|---------|-----------|
| **APEX** | Systematic build/create | analyze → plan → implement → review → commit |
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
| **x-workflows** | HOW to work | 20 workflow skills | `x-{verb}/` |
| x-workflows | Git operations | 14 git skills | `git-{verb}-{type}/` |
| x-workflows | Auto-triggered | 11 behavioral skills | `{name}/` (includes interview, orchestration) |
| **x-devsecops** | WHAT to know | 22 knowledge skills | `{category}-{skill}/` |
| **local** | Project-specific | 1 | initiative |

**Total: 68 skills**

## Verb Skills by Workflow (20)

### BRAINSTORM Workflow (3)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-brainstorm` | Idea capture, requirements discovery | brainstorm, ideas, requirements |
| `/x-research` | Deep investigation, evidence gathering | research, ask, investigate |
| `/x-design` | Architectural decisions | design, architecture |

### APEX Workflow (5)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-analyze` | Codebase assessment | analyze, assess, evaluate |
| `/x-plan` | Implementation planning | plan, task breakdown |
| `/x-implement` | TDD implementation | implement, build, create |
| `/x-refactor` | Safe restructuring | refactor, restructure |
| `/x-review` | Quality gates, code review, audits | review, verify, test, lint, audit |

### ONESHOT Workflow (1)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-fix` | Quick targeted fix | fix, bug, error, typo |

### DEBUG Workflow (1)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-troubleshoot` | Hypothesis-driven debugging | troubleshoot, debug, diagnose |

### UTILITY (10)
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

## Git Workflow Skills (14)

| Verb | Purpose | Triggers |
|------|---------|----------|
| `/git-check-ci` | CI pipeline status check | check ci, pipeline status |
| `/git-cleanup-branches` | Branch cleanup after merges | cleanup branches, prune |
| `/git-commit` | Conventional commits | commit, git commit |
| `/git-create-issue` | Create forge issue | create issue, new issue |
| `/git-create-pr` | Create pull request | create pr, pull request |
| `/git-create-release` | Release workflow | release, tag, version |
| `/git-fix-pr` | Fix PR from review feedback | fix pr, address review |
| `/git-implement-issue` | Issue-driven development | issue, gitea issue |
| `/git-implement-multiple-issue` | Batch issue implementation | implement issues, batch implement |
| `/git-merge-pr` | Merge pull request | merge pr, merge |
| `/git-quickwins-to-pr` | Quick wins to tracked issues+PRs | quickwins to pr, batch quickwins |
| `/git-resolve-conflict` | Resolve merge conflicts | resolve conflict, merge conflict |
| `/git-review-multiple-pr` | Batch PR review | review prs, batch review |
| `/git-review-pr` | Review pull request | review pr, code review |

## Behavioral Skills (11)

| Skill | Purpose |
|-------|---------|
| `agent-awareness` | Agent delegation catalog (auto-triggered) |
| `ci-awareness` | CI pipeline detection and querying (auto-triggered) |
| `complexity-detection` | Routing logic (auto-triggered) |
| `context-awareness` | Context loading (auto-triggered) |
| `error-recovery` | Error recovery patterns (auto-triggered) |
| `forge-awareness` | Git forge detection — GitHub/Gitea/GitLab (auto-triggered) |
| `interview` | Zero-doubt confidence gate (auto-triggered) |
| `orchestration` | Batch operation coordination (auto-triggered) |
| `permission-awareness` | Permission escalation patterns (auto-triggered) |
| `verification-before-completion` | Fresh evidence verification before task completion (auto-triggered) |
| `worktree-awareness` | Worktree lifecycle and parallel work suggestions (auto-triggered) |

## Knowledge Skills (22)

Skills are prefixed by category for organization:

| Category | Count | Skills |
|----------|-------|--------|
| **code-** | 4 | api-design, code-quality, design-patterns, error-handling |
| **data-** | 2 | data-persistence, messaging |
| **delivery-** | 3 | ci-cd-delivery, infrastructure, release-git |
| **meta-** | 2 | analysis-architecture, persuasion-principles |
| **operations-** | 1 | sre-operations |
| **quality-** | 3 | debugging-performance, observability, testing |
| **security-** | 4 | git, identity-access, secrets-supply-chain, secure-coding |
| **vcs-** | 3 | conventional-commits, forge-operations, git-workflows |

## Local Skills (1)

| Skill | Purpose |
|-------|---------|
| initiative | Cross-session tracking |

## Quick Reference

### Feature Development (APEX)
```
/x-analyze → /x-plan → [APPROVAL] → /x-implement → /x-review → /git-commit
```

### Quick Bug Fix (ONESHOT)
```
/x-fix → /x-review quick (optional) → /git-commit
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

## Reference Pointer Convention

Skills use a 3-layer system to connect SKILL.md to its `references/` directory:

### Layer 1: Inline Pointers (within `<instructions>`)

Direct links inside phase text with a content summary — not a filename restatement.

```markdown
> **Reference**: See `references/merge-readiness-checklist.md` for full validation matrix
> (PR state, CI, reviews, mergeable, force-merge gate).
```

### Layer 2: "When to Load References" Section

A dedicated section **after** `</instructions>` and **before** `## References` (or `## Success Criteria`). Lists every reference file with a descriptive use-case trigger:

```markdown
## When to Load References

- **For enforcement audit checklists and violation codes**: See `references/enforcement-audit.md`
- **For full review mode workflow**: See `references/mode-review.md`
```

**Format**: `- **For {descriptive use case}**: See \`references/{filename}.md\``

Content summaries should describe what is in the file, not restate the filename.

### Layer 3: Agent Prompt Summaries (batch skills only)

For batch orchestrators (`git-review-multiple-pr`, `git-implement-multiple-issue`), the agent prompt inside `<parallel-delegate>` includes a 2-3 line inline summary of what the reference contains. This prevents agents from needing to load the reference at runtime:

```markdown
> **Full agent prompt and output format**: See `references/review-agent-prompt.md`
> Review focus areas (bugs, security, quality, tests, breaking changes),
> output format with verdict/severity/categories, UNTRUSTED-FORGE-DATA wrapping.
```

## Version

**Version**: 7.0.0
**x-workflows**: 2.0.0 (git-forge-layer)
