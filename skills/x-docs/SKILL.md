---
name: x-docs
description: |
  Documentation management with sync detection, verification, and generation.
  Generate, sync, verify, cleanup docs. Ensures docs stay in sync with code.
  Triggers: docs, documentation, readme, generate docs, sync docs, verify docs, cleanup docs.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob
metadata:
  author: ccsetup contributors
  version: "2.0.0"
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
| verify | Check doc/code consistency |
| cleanup | Remove stale documentation |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "generate", "create docs", "add documentation" | generate |
| "sync", "update docs", "align", "synchronize" | sync |
| "verify", "check docs", "docs stale", "validate docs" | verify |
| "cleanup", "clean docs", "remove stale", "outdated" | cleanup |
| (default) | docs |

## Execution
- **Default mode**: docs
- **No-args behavior**: Analyze documentation state

## verify Mode

**Purpose**: Check doc/code consistency without modifying files.

### Trigger Keywords
- "verify docs", "check docs", "docs stale"
- "validate docs", "doc drift"

### Workflow

```
1. Scan changed files since last doc update
2. For each changed file:
   - Identify affected documentation
   - Check for signature changes (API docs)
   - Check for behavior changes (examples)
   - Check for reference changes (moved/renamed)
3. Report drift with file:line references
4. Suggest specific updates needed
```

### Output Format

```
┌─────────────────────────────────────────────────┐
│ Documentation Verification Report               │
├─────────────────────────────────────────────────┤
│ ✓ 12 docs checked                               │
│ ⚠ 3 docs need updates                           │
│ ✗ 1 doc has broken links                        │
├─────────────────────────────────────────────────┤
│ Drift detected:                                 │
│   • src/api/users.ts:45 → docs/api/users.md     │
│     Function signature changed                  │
│   • src/services/auth.ts → docs/auth.md         │
│     New method not documented                   │
│   • src/utils/format.ts (deleted)               │
│     Reference in docs/utils.md:23 is broken     │
└─────────────────────────────────────────────────┘
```

### References
See: `references/mode-verify.md`

## Auto-Trigger Integration

x-docs is automatically triggered after implementation workflows:

```
ENHANCED APEX FLOW:
x-plan → x-implement → x-verify → [x-docs sync] → x-review → x-git commit
                                       ↑
                                 AUTO-TRIGGERED
```

### Auto-Trigger Points

| After | Trigger | Mode |
|-------|---------|------|
| x-implement completes | Auto | sync |
| x-verify passes | Auto | sync |
| Before x-review | Auto | verify |
| Before x-git commit | Check | verify |

### Integration with x-review

Before code review, x-docs verify runs to ensure:
- Documentation matches the code being reviewed
- No stale documentation would be committed

### Integration with x-git commit

Before commit, a verify check runs:
- If drift detected → Warning with affected files
- User can choose to sync or commit anyway

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Sync Patterns Reference

For detailed sync patterns, staleness detection, and category placement rules:
- See `references/doc-sync-patterns.md`

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
- **For verify mode**: See `references/mode-verify.md`
- **For cleanup mode**: See `references/mode-cleanup.md`
