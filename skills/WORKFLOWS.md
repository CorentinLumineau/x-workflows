# Workflows Reference

> Canonical workflow definitions for x-workflows verb skills.

## Overview

All verb skills operate within one of 4 canonical workflows. Each workflow represents a distinct mental model for approaching work.

| Workflow | Purpose | Verbs | Flow |
|----------|---------|-------|------|
| **APEX** | Systematic build/create | analyze → plan → implement → verify → review → commit | Full development cycle |
| **ONESHOT** | Quick fixes | fix → [verify] → commit | Minimal overhead |
| **DEBUG** | Error resolution | troubleshoot → fix/implement | Investigation-first |
| **BRAINSTORM** | Exploration/research | brainstorm ↔ research → design | Discovery-focused |

---

## APEX Workflow

> **Purpose**: Systematic development for features, enhancements, and complex changes.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           APEX WORKFLOW                                  │
│                                                                          │
│   /x-analyze → /x-plan → /x-implement → /x-verify → /x-review → /x-commit│
│       (A)        (P)         (E)           (X)        (X)                │
│                                                                          │
│                     ↓ (restructure needed)                               │
│              /x-refactor → /x-verify                                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| **A**nalyze | `/x-analyze` | Assess codebase, identify patterns | Start of APEX flow |
| **P**lan | `/x-plan` | Create implementation plan | Analysis complete |
| **E**xecute | `/x-implement` | Write code with TDD | Plan approved |
| **X** (Verify) | `/x-verify` | Run quality gates | Code written |
| **X** (Examine) | `/x-review` | Code review, audits | Tests pass |
| Commit | `/x-commit` | Conventional commit | Review approved |

### Sub-flow: Refactoring

When restructuring is needed during implementation:

```
/x-implement → (needs restructure) → /x-refactor → /x-verify → (continue)
```

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-analyze | x-plan | Analysis complete | Yes |
| x-plan | x-implement | **Plan approved** | **HUMAN APPROVAL** |
| x-implement | x-verify | Code written | Yes |
| x-implement | x-refactor | "restructure needed" | No (ask) |
| x-refactor | x-verify | Refactor complete | Yes |
| x-verify | x-review | Tests pass | Yes |
| x-verify | x-implement | Tests fail | No (show failures) |
| x-review | x-commit | Review approved | Yes |
| x-review | x-implement | Changes requested | No (show feedback) |

### Complexity Triggers

| Complexity | Route |
|------------|-------|
| SIMPLE | x-implement directly |
| MODERATE | x-plan → x-implement |
| COMPLEX | x-initiative → full APEX flow |

---

## ONESHOT Workflow

> **Purpose**: Ultra-fast fixes for trivial changes with minimal overhead.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ONESHOT WORKFLOW                                 │
│                                                                          │
│                    /x-fix → [/x-verify] → /x-commit                      │
│                                                                          │
│   Characteristics:                                                       │
│   - Single file/component                                                │
│   - Clear error with obvious solution                                    │
│   - No cross-layer investigation needed                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| Fix | `/x-fix` | Apply targeted fix | Clear error identified |
| Verify (optional) | `/x-verify` | Quick sanity check | User requests |
| Commit | `/x-commit` | Quick commit | Fix applied |

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-fix | x-verify | "verify first" | No (ask) |
| x-fix | x-commit | **Quick commit** | **HUMAN APPROVAL** |

### Detection Patterns

ONESHOT is triggered when:
- "fix typo", "quick", "simple", "minor"
- "rename", "small change", "trivial"
- Clear error with line number
- Single file affected

### Escalation

If fix turns out to be more complex:

```
/x-fix → (complexity detected) → /x-troubleshoot OR /x-implement
```

---

## DEBUG Workflow

> **Purpose**: Error resolution through systematic investigation.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DEBUG WORKFLOW                                  │
│                                                                          │
│                        /x-troubleshoot                                   │
│                             │                                            │
│                    ┌────────┴────────┐                                   │
│                    ▼                 ▼                                   │
│              (simple fix)     (complex fix)                              │
│                    │                 │                                   │
│                /x-fix          /x-implement                              │
│                    │                 │                                   │
│              /x-commit         (APEX flow)                               │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| Investigate | `/x-troubleshoot` | Hypothesis-driven debugging | Error/issue reported |
| Simple Fix | `/x-fix` | Apply quick fix | Root cause is simple |
| Complex Fix | `/x-implement` | Full implementation | Root cause is complex |

### Debugging Methodology

```
1. Observe  - Gather symptoms, error messages
2. Hypothesize - Form 2-3 potential causes
3. Test - Validate hypotheses systematically
4. Resolve - Apply fix, verify solution
```

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-troubleshoot | x-fix | Simple fix found | Yes |
| x-troubleshoot | x-implement | **Complex fix needed** | **HUMAN APPROVAL** |

### Complexity Detection

| Signal | Tier | Route |
|--------|------|-------|
| Clear error + line number | SIMPLE | x-fix |
| "how does", "trace" | MODERATE | x-troubleshoot |
| "intermittent", "random", "no error" | COMPLEX | x-initiative → x-troubleshoot |

---

## BRAINSTORM Workflow

> **Purpose**: Exploration and discovery before committing to implementation.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       BRAINSTORM WORKFLOW                                │
│                                                                          │
│              /x-brainstorm ←───→ /x-research                             │
│                     │                                                    │
│                     ▼                                                    │
│               /x-design                                                  │
│                     │                                                    │
│            ─────────┴─────────                                           │
│            ▼                 ▼                                           │
│      [Continue]       [Exit to APEX]                                     │
│      Brainstorm         /x-plan                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| Explore | `/x-brainstorm` | Capture ideas, discover requirements | Vague problem space |
| Research | `/x-research` | Deep investigation, gather evidence | Need more information |
| Decide | `/x-design` | Make architectural decisions | Options identified |

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-brainstorm | x-research | "dig deeper" | No (suggest) |
| x-brainstorm | x-design | "ready to decide" | No (suggest) |
| x-research | x-design | "found answer" | No (suggest) |
| x-design | x-plan | **Ready to build** | **HUMAN APPROVAL** |

### Workflow Transitions

**CRITICAL**: Transitioning from BRAINSTORM to APEX requires explicit human approval because it commits to implementation.

```
BRAINSTORM → APEX
     │
     └── Human approval required at /x-design → /x-plan boundary
```

---

## Cross-Workflow Transitions

Some situations require switching between workflows.

| From | To | Approval Required | Reason |
|------|-----|-------------------|--------|
| x-design (BRAINSTORM) | x-plan (APEX) | **YES** | Commits to implementation |
| x-troubleshoot (DEBUG) | x-implement (APEX) | **YES** | Expands scope |
| x-review (APEX) | x-release (UTILITY) | **YES** | Production deployment |
| x-fix (ONESHOT) | x-troubleshoot (DEBUG) | No | Escalation |
| x-fix (ONESHOT) | x-implement (APEX) | No | Escalation |

---

## Human-in-Loop Framework

### When to Ask Human

**Critical (ALWAYS ask)**:
- Workflow transition (e.g., BRAINSTORM → APEX)
- Destructive action (delete, overwrite production)
- Scope expansion beyond original request
- Plan approval before implementation

**High (ASK IF ABLE)**:
- Multiple valid approaches exist
- Architectural decisions
- Skip phase request (e.g., skip verify)

**Medium (ASK IF UNCERTAIN)**:
- Phase transition within workflow
- Confidence < 70%

**Low (PROCEED)**:
- Continue current phase
- Auto-chain within workflow

### Question Structure

When approval is needed, use this structure:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ [Context]: What just happened                                           │
│                                                                          │
│ [Options]:                                                               │
│   1. Option A - description (trade-offs)                                │
│   2. Option B - description (trade-offs)                                │
│   3. Something else                                                      │
│                                                                          │
│ [Recommendation]: Option X because...                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Verb Quick Reference

### BRAINSTORM Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-brainstorm` | BRAINSTORM.explore | Idea capture, requirements discovery |
| `/x-research` | BRAINSTORM.deep-explore | Deep investigation, evidence gathering |
| `/x-design` | BRAINSTORM.action | Architectural decisions |

### APEX Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-analyze` | APEX.analyze | Codebase assessment |
| `/x-plan` | APEX.plan | Implementation planning |
| `/x-implement` | APEX.execute | TDD implementation |
| `/x-refactor` | APEX.restructure | Safe restructuring |
| `/x-verify` | APEX.test | Quality gates |
| `/x-review` | APEX.examine | Code review, audits |

### ONESHOT Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-fix` | ONESHOT.complete | Quick targeted fix |

### DEBUG Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-troubleshoot` | DEBUG.complete | Hypothesis-driven debugging |

### UTILITY Verbs

| Verb | Purpose |
|------|---------|
| `/x-commit` | Conventional commits |
| `/x-release` | Release workflow |
| `/x-docs` | Documentation management |
| `/x-help` | Command reference |

### UNCHANGED Skills

| Skill | Type | Notes |
|-------|------|-------|
| `x-initiative` | Utility | Multi-session tracking |
| `x-setup` | Utility | Project initialization |
| `x-create` | Utility | Skill/agent creation |
| `x-prompt` | Utility | Prompt enhancement |
| `interview` | Behavioral | Confidence gate (auto-triggered) |
| `complexity-detection` | Behavioral | Routing logic (auto-triggered) |

---

## Version

**Version**: 1.0.0 (x-workflows)
**Compatibility**: ccsetup 6.2.0+
