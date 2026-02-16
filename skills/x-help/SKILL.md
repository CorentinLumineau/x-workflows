---
name: x-help
description: Use when you need help finding the right command or understanding available workflows.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# /x-help

> Quick reference for all verb commands and workflow navigation.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | Entry point |

## Modes

| Mode | Description |
|------|-------------|
| commands (default) | Show command reference |
| context | Display current session context state |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "context", "loaded", "state", "session" | context |
| (default) | commands |

## Intention

**Topic**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Show command overview.
{{/if}}

<instructions>

### Phase 1: Command Reference

Display available verb commands organized by workflow:

**BRAINSTORM Workflow:**
| Verb | Purpose |
|------|---------|
| `/x-brainstorm` | Idea capture, requirements discovery |
| `/x-research` | Deep investigation, evidence gathering |
| `/x-design` | Architectural decisions |

**APEX Workflow:**
| Verb | Purpose |
|------|---------|
| `/x-analyze` | Codebase assessment |
| `/x-plan` | Implementation planning |
| `/x-implement` | TDD implementation |
| `/x-refactor` | Safe restructuring |
| `/x-verify` | Quality gates |
| `/x-review` | Code review, audits |

**ONESHOT Workflow:**
| Verb | Purpose |
|------|---------|
| `/x-fix` | Quick targeted fix |

**DEBUG Workflow:**
| Verb | Purpose |
|------|---------|
| `/x-troubleshoot` | Hypothesis-driven debugging |

**UTILITY:**
| Verb | Purpose |
|------|---------|
| `/git-create-commit` | Conventional commits |
| `/git-create-release` | Release workflow |
| `/x-docs` | Documentation management |
| `/x-help` | Command reference (this) |
| `/x-initiative` | Multi-session tracking |
| `/x-setup` | Project initialization |
| `/x-create` | Skill/agent creation |
| `/x-prompt` | Prompt enhancement |

### Phase 2: Workflow Patterns

**Feature Development (APEX):**
```
/x-analyze → /x-plan → /x-implement → /x-verify → /x-review → /git-create-commit
```

**Quick Bug Fix (ONESHOT):**
```
/x-fix → /x-verify (optional) → /git-create-commit
```

**Investigation (DEBUG):**
```
/x-troubleshoot → /x-fix (simple) OR /x-implement (complex)
```

**Exploration (BRAINSTORM):**
```
/x-brainstorm ↔ /x-research → /x-design → [exit to APEX]
```

**Multi-Session Project:**
```
/x-initiative create → [work] → /x-initiative continue → /x-initiative archive
```

</instructions>

## Workflow Quick Reference

### BRAINSTORM → APEX Transition
```
/x-brainstorm → /x-research → /x-design → [APPROVAL] → /x-plan
```
**Note:** Transitioning from BRAINSTORM to APEX requires human approval.

### APEX Full Flow
```
/x-analyze → /x-plan → [APPROVAL] → /x-implement → /x-verify → /x-review → /git-create-commit
```
**Note:** Plan approval required before implementation.

### DEBUG Resolution Paths
```
/x-troubleshoot → /x-fix (simple fix found)
/x-troubleshoot → [APPROVAL] → /x-implement (complex fix needed)
```

## Human Approval Gates

| Transition | Approval Required |
|------------|-------------------|
| BRAINSTORM → APEX | Yes (x-design → x-plan) |
| Plan → Implement | Yes |
| DEBUG → APEX | Yes (troubleshoot → implement) |
| Commit without verify | Yes |
| Release | Yes |

## Verb Categories

| Category | Verbs | Purpose |
|----------|-------|---------|
| Exploration | brainstorm, research, design | Discover requirements |
| Planning | analyze, plan | Prepare for implementation |
| Implementation | implement, refactor, fix | Write code |
| Quality | verify, review | Ensure quality |
| Delivery | commit, release | Ship code |
| Support | docs, help, initiative | Utilities |

## Getting Started

**For new features:**
```
/x-brainstorm    # If requirements unclear
/x-plan          # If requirements clear
/x-implement     # If plan is trivial
```

**For bugs:**
```
/x-fix           # If cause is obvious
/x-troubleshoot  # If investigation needed
```

**For research:**
```
/x-research      # Answer questions
```

## Navigation

For more details on any verb, use:
```
/x-{verb}        # See specific skill documentation
```

For workflow documentation:
```
See: skills/WORKFLOWS.md
```

## When to Load References

- **For context mode**: See `references/mode-context.md`

## Success Criteria

- [ ] User understands available commands
- [ ] User can navigate workflows
- [ ] Appropriate verb selected for task

## References

- skills/WORKFLOWS.md - Detailed workflow documentation
- @core-docs/X_COMMANDS_REFERENCE.md - Full command reference
