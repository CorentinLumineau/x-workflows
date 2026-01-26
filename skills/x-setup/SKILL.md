---
name: x-setup
description: |
  Project documentation setup with intelligent stack detection and structure creation.
  Activate when setting up project documentation, scaffolding docs, or initializing structure.
  Triggers: setup, scaffold, initialize, create structure, project setup, documentation setup.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-setup

Project documentation setup with intelligent stack detection and complete documentation structure creation.

## Modes

| Mode | Description |
|------|-------------|
| setup (default) | Project documentation setup |

## Execution

1. **Detect mode** from user input (always setup for this skill)
2. **If no arguments provided**, detect project stack automatically
3. **Load mode instructions** from `references/`
4. **Follow instructions** completely

## Documentation Structure

Creates complete structure:

```
documentation/
├── CLAUDE.md           # Hub navigation
├── config.yaml         # Stack configuration
├── domain/             # Business logic
│   ├── CLAUDE.md
│   └── README.md
├── development/        # Setup, workflows
│   ├── CLAUDE.md
│   └── README.md
├── implementation/     # Technical docs
│   ├── CLAUDE.md
│   └── README.md
├── milestones/         # Initiative tracking
│   ├── CLAUDE.md
│   ├── README.md
│   ├── MASTER-PLAN.md
│   └── _active/
├── reference/          # Stack docs
│   ├── CLAUDE.md
│   └── README.md
└── troubleshooting/    # Issue resolution
    ├── CLAUDE.md
    └── README.md
```

## Stack Detection

Auto-detects project stack from files:

| Stack | Detection |
|-------|-----------|
| Frontend | package.json with react/vue/angular |
| Backend | package.json, requirements.txt, go.mod |
| Database | docker-compose.yml, database configs |
| Build | Makefile, package.json scripts |

## Templates

Standard templates for each section:

| Section | Template Content |
|---------|------------------|
| domain | Business rules, domain models |
| development | Setup guide, workflows |
| implementation | Technical architecture |
| milestones | Initiative tracking |
| reference | API specs, stack docs |
| troubleshooting | Common issues, solutions |

## Config.yaml Format

```yaml
project:
  name: "project-name"
  description: "Project description"

stack:
  frontend:
    - React
    - TypeScript
  backend:
    - Node.js
  database:
    - PostgreSQL
  build:
    - npm
```

## Checklist

- [ ] Stack detected
- [ ] Directory structure created
- [ ] CLAUDE.md files created
- [ ] README.md files created
- [ ] config.yaml populated

## When to Load References

- **For setup mode**: See `references/mode-setup.md`
