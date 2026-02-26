---
name: x-setup
description: Use when initializing a new project or assessing agent-readiness of an existing project.
version: "2.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "[setup|verify] [path]"
chains-to:
  - x-create
metadata:
  author: ccsetup contributors
  category: workflow
---

# x-setup

Project initialization and agent-readiness assessment. Setup mode scaffolds documentation structure with intelligent stack detection. Verify mode assesses `.claude/` health, CLAUDE.md quality, agent/skill/rule coverage, and produces a structured readiness report.

## Modes

| Mode | Description |
|------|-------------|
| setup (default) | Project documentation setup — creates `/documentation/**` structure |
| verify | Agent-readiness assessment — scans project configuration and produces readiness report |

## Mode Detection

| Keywords | Mode |
|----------|------|
| "verify", "check", "assess", "readiness", "health", "audit setup" | verify |
| "setup", "init", "initialize", "scaffold", "create docs" | setup |
| (default — no arguments) | setup |

## Execution

Pipeline: **Phase 0 (shared) → mode file**

- **Phase 0** Interview check (shared across modes)
- **mode** Mode-specific phases (setup or verify)

**Default mode**: setup
**No-args behavior**: Detect project stack automatically and run setup

<permission-scope mode="default">
  <allowed>Read, Grep, Glob (assessment and detection); Write, Edit, Bash (setup mode only — file creation and stack detection)</allowed>
  <denied>Write, Edit in verify mode (read-only assessment); direct writes to ccsetup-plugin/skills/ (must use source repos)</denied>
</permission-scope>

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `context-awareness` - Environment detection (verify mode Phase 1)

## Documentation Structure

Setup mode creates complete structure:

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

## When to use x-setup vs x-create

| Aspect | x-setup | x-create |
|--------|---------|----------|
| Purpose | Project-level initialization and readiness assessment | Component-level creation (skills, agents, hooks) |
| Scope | Whole project configuration | Individual ecosystem components |
| Creates | `/documentation/**` structure, config files | Skill files, agent definitions, hooks |
| Assesses | `.claude/` health, CLAUDE.md quality, agent coverage | Ecosystem gaps (discover mode) |
| Entry point | Start here for new projects or readiness checks | Use after x-setup when you know what to build |
| Chains to | x-create (from verify mode recommendations) | x-implement, x-review |

**Rule of thumb**: x-setup answers "Is this project agent-ready?" while x-create answers "What component should I build next?"

## Workflow Chaining

| From Mode | Chains To | Trigger |
|-----------|-----------|---------|
| verify | `/x-create` or `/x-create discover` | User selects "Create recommended components" at action gate |
| setup | `/x-setup verify` | Suggested in Phase 5.5 lightweight verification |

## Checklist

- [ ] Stack detected (setup) or environment detected (verify)
- [ ] Mode-specific phases completed
- [ ] Output delivered (structure created or readiness report)
- [ ] Next steps presented

## When to Load References

- **For setup mode**: See `references/mode-setup.md`
- **For verify mode**: See `references/mode-verify.md`
