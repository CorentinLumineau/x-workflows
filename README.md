# x-workflows

Universal development workflow orchestration skills for AI-assisted development.

## Overview

x-workflows provides **workflow** skills - the "HOW to work" for software development. These skills are agent-agnostic and work with any skills.sh compatible AI agent.

Workflow skills orchestrate development tasks and reference knowledge skills (from x-devsecops) for domain expertise.

## Architecture

x-workflows is part of the **ccsetup 3-repository architecture** ("Swiss Watch" design):

| Repository | Role | Description |
|------------|------|-------------|
| **x-devsecops** | WHAT to know | 26 knowledge skills (domain expertise) |
| **x-workflows** | HOW to work | 19 workflow skills (development processes) ← *You are here* |
| **ccsetup** | Orchestration | Commands, agents, hooks |

For complete architectural documentation, see [ccsetup/ARCHITECTURE.md](https://github.com/clmusic/ccsetup/blob/main/ARCHITECTURE.md)

## Skills Catalog

### Core Workflow Skills (14)

| Skill | Description |
|-------|-------------|
| `x-plan` | Planning, brainstorming, design, analysis |
| `x-implement` | Feature implementation, fixes, refactoring |
| `x-verify` | Testing, building, coverage |
| `x-review` | Code review, auditing, best practices |
| `x-git` | Commits, releases, version management |
| `x-troubleshoot` | Debugging, troubleshooting, code explanation |
| `x-initiative` | Multi-session project tracking |
| `x-docs` | Documentation management |
| `x-research` | Q&A, comprehensive research |
| `x-improve` | Code health analysis, quick wins |
| `x-help` | Command reference, rules management |
| `x-orchestrate` | Workflow orchestration, background tasks |
| `x-setup` | Project documentation scaffolding |
| `x-create` | Create skills, commands, agents |

### Behavioral Skills (4)

| Skill | Description |
|-------|-------------|
| `interview` | Zero-doubt confidence gate (Phase 0 for all workflows) |
| `complexity-detection` | Route issues to appropriate debugging tier |
| `documentation` | Sync documentation with code changes |
| `initiative` | Cross-session project tracking patterns |

### NEW Workflow Skills (2)

| Skill | Description |
|-------|-------------|
| `x-deploy` | Deployment workflows, rollback support |
| `x-monitor` | Monitoring setup, alerting configuration |

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

**Feature Development:**
```
x-plan brainstorm → x-plan design → x-plan
    ↓
x-implement → x-verify → x-review → x-git commit
```

**Bug Fix:**
```
x-troubleshoot → x-implement fix → x-verify → x-git commit
```

**Release:**
```
x-verify → x-git commit → x-git release
```

**Multi-Session Project:**
```
x-initiative create → [work] → x-initiative continue → x-initiative archive
```

## Knowledge Skills Integration

Workflow skills reference knowledge skills from x-devsecops for domain expertise.

**See [DEPENDENCIES.md](DEPENDENCIES.md) for the complete dependency matrix.**

| Workflow | Knowledge Skills Used |
|----------|----------------------|
| x-implement | code-quality, testing |
| x-verify | testing, quality-gates |
| x-review | code-quality, owasp |
| x-git | release-management |
| x-troubleshoot | debugging |
| x-deploy | infrastructure, container-security |
| x-monitor | monitoring, incident-response |

## Structure

```
x-workflows/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── x-plan/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── x-implement/
│   ├── x-verify/
│   ├── x-review/
│   ├── x-git/
│   ├── x-troubleshoot/
│   ├── x-initiative/
│   ├── x-docs/
│   ├── x-research/
│   ├── x-improve/
│   ├── x-help/
│   ├── x-orchestrate/
│   ├── x-setup/
│   ├── x-create/
│   ├── interview/
│   ├── complexity-detection/
│   ├── documentation/
│   ├── initiative/
│   ├── x-deploy/
│   └── x-monitor/
├── LICENSE
└── README.md
```

## License

Apache-2.0

## Contributing

Contributions welcome! Please follow the skill template format in each SKILL.md file.
