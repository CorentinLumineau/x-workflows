---
name: x-docs
description: |
  Documentation management with sync detection and generation. Generate, sync, cleanup docs.
  Activate when managing documentation, syncing docs with code, or cleaning up stale docs.
  Triggers: docs, documentation, readme, generate docs, sync docs, cleanup docs.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-docs

Documentation management with intelligent sync detection, generation, and cleanup capabilities.

## Modes

| Mode | Description |
|------|-------------|
| docs (default) | Documentation router |
| generate | Generate new documentation |
| sync | Sync docs with code changes |
| cleanup | Remove stale documentation |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "generate", "create docs", "add documentation" | generate |
| "sync", "update docs", "align", "synchronize" | sync |
| "cleanup", "clean docs", "remove stale", "outdated" | cleanup |
| (default) | docs |

## Execution
- **Default mode**: docs
- **No-args behavior**: Analyze documentation state

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `documentation` - Doc sync patterns

## Agent Suggestions

Consider delegating to specialized agents:
- **Documentation**: Generation, formatting, structure
- **Exploration**: Code analysis, API extraction

## Documentation Principles

| Principle | Description |
|-----------|-------------|
| Docs follow code | Never update docs in isolation |
| Detect before update | Check for drift before writing |
| Pareto documentation | Document 20% that delivers 80% value |
| Examples must work | Test all code examples |

## Sync Workflow

```
1. Detect code changes since last doc update
2. Identify affected documentation
3. Verify placement (correct category)
4. Update documentation to match code
5. Validate examples still work
6. Update navigation
7. Commit docs with related code
```

## Documentation Structure

Standard structure expected:

```
documentation/
├── domain/           # Business logic
├── development/      # Setup, workflows
├── implementation/   # Technical docs
├── milestones/       # Initiative tracking
├── reference/        # Stack docs
└── troubleshooting/  # Issue resolution
```

## Checklist

- [ ] Documentation matches code
- [ ] Examples are tested
- [ ] No broken internal links
- [ ] Navigation updated
- [ ] Changelog updated (if release)

## When to Load References

- **For docs mode**: See `references/mode-docs.md`
- **For generate mode**: See `references/mode-generate.md`
- **For sync mode**: See `references/mode-sync.md`
- **For cleanup mode**: See `references/mode-cleanup.md`
