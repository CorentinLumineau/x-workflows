# x-workflows

Universal development workflow orchestration skills for AI-assisted development.

## Overview

x-workflows provides **workflow** skills - the "HOW to work" for software development. These skills are agent-agnostic and work with any skills.sh compatible AI agent.

Workflow skills orchestrate development tasks and reference knowledge skills (from x-devsecops) for domain expertise.

## Architecture

x-workflows is part of the **ccsetup 3-repository architecture** ("Swiss Watch" design):

| Repository | Role | Description |
|------------|------|-------------|
| **x-devsecops** | WHAT to know | 39 knowledge skills (domain expertise) |
| **x-workflows** | HOW to work | 25 workflow skills (development processes) ← *You are here* |
| **ccsetup** | Orchestration | Commands, agents, hooks |

For complete architectural documentation, see [ccsetup/ARCHITECTURE.md](https://github.com/CorentinLumineau/ccsetup/blob/main/ARCHITECTURE.md)

## Skills Catalog

### 4 Canonical Workflows

| Workflow | Purpose | Flow |
|----------|---------|------|
| **APEX** | Systematic development | analyze → plan → implement → verify → review → commit |
| **ONESHOT** | Quick fixes | fix → [verify] → commit |
| **DEBUG** | Error resolution | troubleshoot → fix/implement |
| **BRAINSTORM** | Exploration/research | brainstorm ↔ research → design |

### Workflow Skills (22)

| Skill | Workflow | Description |
|-------|----------|-------------|
| `x-analyze` | APEX | Codebase assessment and pattern discovery |
| `x-plan` | APEX | Implementation planning with complexity detection |
| `x-implement` | APEX | Feature implementation, fixes, refactoring |
| `x-verify` | APEX | Testing, building, coverage validation |
| `x-review` | APEX | Code review, auditing, security checks |
| `x-refactor` | APEX | Safe code restructuring with zero regression |
| `x-fix` | ONESHOT | Rapid bug fixing for clear errors |
| `x-commit` | All | Intelligent conventional commit messages |
| `x-release` | All | Automated release with semantic versioning |
| `x-troubleshoot` | DEBUG | Deep diagnostic analysis |
| `x-brainstorm` | BRAINSTORM | Transform ideas into structured requirements |
| `x-design` | BRAINSTORM | Technical architecture and system design |
| `x-research` | BRAINSTORM | Intelligent Q&A and evidence-based research |
| `x-ask` | BRAINSTORM | Quick questions and knowledge retrieval |
| `x-initiative` | Multi-session | Multi-phase project tracking across sessions |
| `x-archive` | Multi-session | Archive completed initiatives with lessons learned |
| `x-docs` | Utility | Documentation management and sync |
| `x-help` | Utility | Command reference and navigation |
| `x-setup` | Utility | Project documentation scaffolding |
| `x-create` | Utility | Create new skills, commands, agents |
| `x-prompt` | Utility | Transform prompts into structured XML format |
| `x-team` | Utility | Orchestrate teams of parallel agent sessions |

### Behavioral Skills (2)

| Skill | Description |
|-------|-------------|
| `interview` | Zero-doubt confidence gate (Phase 0 for all workflows) |
| `complexity-detection` | Route tasks to appropriate workflow based on complexity |

### Utility Skills (1)

| Skill | Description |
|-------|-------------|
| `orchestration` | Parallel workflow coordination for batch operations |

## Installation

### With skills.sh

```bash
skills install x-workflows
```

### Manual

Clone this repository and configure your AI agent to use the skills directory.

## Compatibility

Works with:
- Claude Code
- Cursor
- Cline
- Any skills.sh compatible agent

## Usage

Skills activate automatically based on context triggers defined in each skill's frontmatter.

### Common Workflows

**Feature Development (APEX):**
```
x-analyze → x-plan → x-implement → x-verify → x-review → x-commit
```

**Bug Fix (ONESHOT):**
```
x-fix → x-verify → x-commit
```

**Investigation (DEBUG):**
```
x-troubleshoot → x-fix/x-implement → x-verify → x-commit
```

**Release:**
```
x-verify → x-commit → x-release
```

**Multi-Session Project:**
```
x-initiative create → [work] → x-initiative continue → x-archive
```

## Knowledge Skills Integration

Workflow skills reference knowledge skills from x-devsecops for domain expertise.

**See [DEPENDENCIES.md](DEPENDENCIES.md) for the complete dependency matrix.**

| Workflow | Knowledge Skills Used |
|----------|----------------------|
| x-implement | code-quality, testing |
| x-verify | testing, quality-gates |
| x-review | code-quality, owasp |
| x-commit | release-management |
| x-troubleshoot | debugging |

## Structure

```
x-workflows/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── x-analyze/
│   ├── x-plan/
│   ├── x-implement/
│   ├── x-verify/
│   ├── x-review/
│   ├── x-refactor/
│   ├── x-fix/
│   ├── x-commit/
│   ├── x-release/
│   ├── x-troubleshoot/
│   ├── x-brainstorm/
│   ├── x-design/
│   ├── x-research/
│   ├── x-ask/
│   ├── x-initiative/
│   ├── x-archive/
│   ├── x-docs/
│   ├── x-help/
│   ├── x-setup/
│   ├── x-create/
│   ├── x-prompt/
│   ├── x-team/
│   ├── interview/          # Behavioral
│   ├── complexity-detection/ # Behavioral
│   └── orchestration/      # Utility
├── LICENSE
└── README.md
```

## License

Apache-2.0

## Contributing

Contributions welcome! Please follow the skill template format in each SKILL.md file.
See [AGENTS.md](AGENTS.md) for detailed skill structure conventions.
