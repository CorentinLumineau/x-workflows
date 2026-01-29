# x-workflows

> Agent-agnostic workflow orchestration skills providing HOW to work patterns.
> Compatible with Claude Code, Cursor, Copilot, Cline, Devin, and any AI agent.

## Project Overview

x-workflows is a skills.sh-compatible plugin providing workflow skills for software development automation. Part of the Skills Ecosystem 2026.

**Key Principle**: Skills define WHAT to do; agents decide HOW to execute.

## Quick Reference

| Category | Skills | Primary Modes |
|----------|--------|---------------|
| Planning | x-plan | brainstorm, design, analyze |
| Implementation | x-implement, x-improve | implement, fix, refactor, enhance, cleanup |
| Verification | x-verify | verify, build, coverage |
| Review | x-review | review, audit |
| Git | x-git | commit, release |
| Debugging | x-troubleshoot | troubleshoot, debug, explain |
| Documentation | x-docs | docs, generate, sync, cleanup |
| Project Tracking | x-initiative | create, continue, archive, status |
| Research | x-research | ask, deep |
| Help | x-help | help, rules |
| Orchestration | x-orchestrate | orchestrate, background, agent |
| Setup | x-setup, x-create | setup, skill, command, agent |
| Behavioral | interview, complexity-detection | (auto-activated) |

## Workflow Patterns

**Feature Development:**
```
x-plan → x-implement → x-verify → x-review → x-git
```

**Bug Fix:**
```
x-troubleshoot → x-implement fix → x-verify → x-git
```

**Multi-Session Project:**
```
x-initiative create → [work] → x-initiative continue → x-initiative archive
```

## Build & Test

No build required - pure markdown documentation.

```bash
# Validate skill structure
find skills -name "SKILL.md" | wc -l  # Should be 18

# Validate mode references
find skills -path "*/references/mode-*.md" | wc -l  # Should be 46

# Check for empty files
find skills -name "*.md" -empty

# Verify playbooks & templates
find skills/x-initiative/playbooks -name "*.md" | wc -l  # Should be 8
find skills/x-setup/templates -name "*.md" | wc -l       # Should be 16
```

## Skill Structure Convention

Every workflow skill follows this structure:
```
skills/{skill-name}/
├── SKILL.md           # Main skill file with mode routing
├── references/        # Mode implementation files
│   ├── mode-{name}.md
│   └── ...
├── boilerplates/     # (optional) Generation templates
├── playbooks/        # (optional) Guides and examples
└── templates/        # (optional) Output templates
```

### SKILL.md Format
```markdown
---
title: {Title}
modes: [list, of, modes]
category: workflow
---

# /{skill-name}

{Description}

## Mode Routing

| Mode | File | Description |
|------|------|-------------|
| {mode} | `references/mode-{mode}.md` | {desc} |

## Mode Detection
{Keywords that trigger each mode}

## Execution
{How to execute the skill}
```

### Mode Reference Format
```markdown
# Mode: {name}

> **Invocation**: `/{skill} {mode}`

<purpose>
{What this mode does}
</purpose>

<instructions>
{Step-by-step instructions for any AI agent}
</instructions>

<critical_rules>
{Must-follow rules}
</critical_rules>

<success_criteria>
- [ ] {Checklist}
</success_criteria>
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

**Agent Implementation Examples:**

| Pattern | Claude Code | Cursor | Generic |
|---------|-------------|--------|---------|
| Testing | `ccsetup:x-tester` | Test rule | Subagent with test tools |
| Review | `ccsetup:x-reviewer` | Review rule | Read-only analysis agent |
| Explorer | `ccsetup:x-explorer` | Search rule | Navigation-focused agent |

See [AGENT-PATTERNS.md](AGENT-PATTERNS.md) for detailed pattern definitions.

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
Scopes: skill-name, templates, playbooks, refs
```

Example: `feat(x-verify): add coverage mode reference`

## Testing Instructions

When modifying skills:
1. Ensure SKILL.md has valid YAML frontmatter
2. Verify all referenced mode files exist in `references/`
3. Check cross-references resolve correctly
4. Test mode detection keywords
5. Validate no empty files created

---

**Version**: 0.2.0
**Compatibility**: skills.sh, Claude Code, Cursor, Copilot, Cline, Devin
