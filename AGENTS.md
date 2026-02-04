# x-workflows

> Agent-agnostic verb-based workflow skills with 4 canonical workflows.
> Compatible with Claude Code, Cursor, Copilot, Cline, Devin, and any AI agent.

## Project Overview

x-workflows is a skills.sh-compatible plugin providing workflow skills for software development automation. Part of the Skills Ecosystem 2026.

**Key Principle**: Skills define WHAT to do; agents decide HOW to execute.

## Quick Reference

| Workflow | Purpose | Verbs |
|----------|---------|-------|
| **APEX** | Systematic build/create | analyze → plan → implement → verify → review → commit |
| **ONESHOT** | Quick fixes | fix → [verify] → commit |
| **DEBUG** | Error resolution | troubleshoot → fix/implement |
| **BRAINSTORM** | Exploration/research | brainstorm ↔ research → design |

## Verb Skills by Workflow (19)

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

### UTILITY (8)
| Verb | Purpose | Triggers |
|------|---------|----------|
| `/x-commit` | Conventional commits | commit, git commit |
| `/x-release` | Release workflow | release, tag, version |
| `/x-docs` | Documentation management | docs, documentation |
| `/x-help` | Command reference | help, commands |
| `/x-initiative` | Multi-session tracking | initiative, milestone |
| `/x-setup` | Project initialization | setup, scaffold |
| `/x-create` | Skill/agent creation | create skill, create agent |
| `/x-prompt` | Prompt enhancement | enhance prompt |

## Behavioral Skills (2)

| Skill | Purpose |
|-------|---------|
| `interview` | Confidence gate (auto-triggered) |
| `complexity-detection` | Routing logic (auto-triggered) |

## Workflow Patterns

**APEX - Feature Development:**
```
/x-analyze → /x-plan → [APPROVAL] → /x-implement → /x-verify → /x-review → /x-commit
```

**ONESHOT - Quick Bug Fix:**
```
/x-fix → [optional: /x-verify] → /x-commit
```

**DEBUG - Investigation:**
```
/x-troubleshoot → /x-fix (simple) OR /x-implement (complex)
```

**BRAINSTORM - Exploration:**
```
/x-brainstorm ↔ /x-research → /x-design → [APPROVAL] → /x-plan (APEX)
```

**Multi-Session Project:**
```
/x-initiative create → [work] → /x-initiative continue → /x-initiative archive
```

> See `skills/WORKFLOWS.md` for detailed workflow documentation.

## Human Approval Gates

| Transition | Approval Required |
|------------|-------------------|
| BRAINSTORM → APEX | Yes (x-design → x-plan) |
| Plan → Implement | Yes |
| DEBUG → APEX | Yes (troubleshoot → implement) |
| Quick commit | Yes |
| Release | Yes |

## Build & Test

No build required - pure markdown documentation.

```bash
# Validate skill structure (should be 19 x-* + 2 behavioral = 21)
find skills -name "SKILL.md" | wc -l

# Verify new verb skills exist
for skill in x-brainstorm x-design x-analyze x-refactor x-fix x-commit x-release; do
  [ -f "skills/$skill/SKILL.md" ] || echo "MISSING: skills/$skill/SKILL.md"
done

# Verify deprecated skills removed
for skill in x-git x-improve x-orchestrate; do
  [ -d "skills/$skill" ] && echo "ERROR: skills/$skill should be deleted"
done
```

## Skill Structure Convention

Every workflow skill follows this structure:
```
skills/{verb}/
├── SKILL.md           # Main skill file with workflow context
└── references/        # (optional) Supporting documentation
```

### SKILL.md Format
```yaml
---
name: x-{verb}
description: |
  {One-line description}. {Workflow} workflow.
  Triggers: {trigger keywords}.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: {Tool list}
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# /x-{verb}

> {Tagline describing the action}

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | {APEX/ONESHOT/DEBUG/BRAINSTORM} |
| **Phase** | {phase-name} |
| **Position** | {N} of {M} in workflow |

**Flow**: `{prev}` → **`{current}`** → `{next}`

<instructions>
...
</instructions>
```

## Agent Capability Patterns

Skills may suggest leveraging subagents with these capability patterns:

| Pattern | Purpose | Required Capabilities |
|---------|---------|----------------------|
| Testing | Test execution, coverage | Read, Edit, Execute commands |
| Review | Code quality analysis | Read, Search, Pattern match |
| Explorer | Codebase navigation | Read, Glob, Grep |
| Docs | Documentation generation | Read, Write |
| Refactor | Safe code restructuring | Read, Edit, Execute tests |
| Debug | Issue investigation | Read, Execute, Analyze output |

## Knowledge Skills Integration

Workflows reference these knowledge skills from x-devsecops:
- **Quality**: testing, debugging, code-quality, quality-gates
- **Security**: owasp, authentication, authorization, secrets
- **Delivery**: release-management, infrastructure, ci-cd
- **Operations**: monitoring, incident-response

## Security Considerations

- No secrets in files
- YAML frontmatter must not contain executable code
- External links use HTTPS only
- No real user data in examples
- Sanitize all inputs in examples

## Commit Message Format

```
{type}({scope}): {description}

Types: feat, fix, docs, refactor, test, chore
Scopes: skill-name, workflows, refs
```

Example: `feat(x-fix): add new ONESHOT verb skill`

## Testing Instructions

When modifying skills:
1. Ensure SKILL.md has valid YAML frontmatter
2. Verify workflow context is correct
3. Check cross-references resolve correctly
4. Test trigger keywords
5. Validate no empty files created

---

**Version**: 1.0.0
**Compatibility**: skills.sh, Claude Code, Cursor, Copilot, Cline, Devin
