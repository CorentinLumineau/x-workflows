---
type: template-index
scope: documentation-templates
version: 1.0.0
---

# Documentation Templates

> Reusable templates for `/x:setup` command and project documentation

## Overview

This directory contains templates extracted from the `/x:setup` command for:
- Documentation README files (5 templates)
- Navigation CLAUDE.md files (6 templates)
- Architecture diagrams (3 templates)
- Configuration files (1 template)

## Directory Structure

```
templates/
├── README.md                    # This file
├── documentation/               # Section README templates
│   ├── domain-readme.md
│   ├── development-readme.md
│   ├── implementation-readme.md
│   ├── milestones-readme.md
│   └── reference-readme.md
├── navigation/                  # CLAUDE.md navigation templates
│   ├── hub-claude-md.md
│   ├── domain-claude-md.md
│   ├── development-claude-md.md
│   ├── implementation-claude-md.md
│   ├── milestones-claude-md.md
│   └── reference-claude-md.md
├── architecture/                # Architecture diagram templates
│   ├── fullstack-diagram.md
│   ├── backend-diagram.md
│   └── frontend-diagram.md
└── config-yaml-template.md      # Stack configuration template
```

## Usage

Templates are referenced by `/x-setup` using relative paths from the skill folder:
```
templates/{category}/{template-name}.md
```

### Variable Substitution

Templates use `{{variable}}` syntax for dynamic content:

| Variable | Description |
|----------|-------------|
| `{{project-name}}` | Project name from package.json/go.mod/folder |
| `{{project-description}}` | Project description |
| `{{stack-framework}}` | Primary framework (Next.js, Go/Gin, etc.) |
| `{{stack-database}}` | Database (PostgreSQL, MySQL, etc.) |
| `{{stack-orm}}` | ORM (Prisma, GORM, etc.) |
| `{{stack-technologies}}` | List of additional technologies |
| `{{timestamp}}` | Generation timestamp |
| `{{section-name}}` | Documentation section name |

## Template Categories

### Documentation Templates
README files for each documentation section:
- **domain** - Business logic, entities, workflows, rules
- **development** - Setup guides, workflows, contributing
- **implementation** - Architecture, ADRs, integrations
- **milestones** - Initiative planning, progress tracking
- **reference** - Stack docs, AI-optimized project guides

### Navigation Templates
CLAUDE.md files for LLM navigation:
- **hub** - Central documentation navigation
- **section** - Per-folder navigation files

### Architecture Templates
Visual diagrams based on project type:
- **fullstack** - Frontend + Backend + Database layers
- **backend** - API and service layers only
- **frontend** - UI component architecture only

## Maintenance

Templates are bundled with the ccsetup plugin installation and work offline.

To update templates after plugin upgrade:
```bash
claude /plugin upgrade ccsetup
```

---

**Version**: 4.12.0
**Created**: 2025-11-26
**Part of**: Setup Command LLM Optimization Initiative
