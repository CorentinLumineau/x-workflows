---
name: x-docs
description: |
  Documentation management with sync detection and generation.
  UTILITY skill. Triggers: docs, documentation, readme, generate docs, sync docs.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob
metadata:
  author: ccsetup contributors
  version: "3.0.0"
  category: workflow
---

# /x-docs

> Manage documentation - generate, sync, verify, and cleanup.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | Auto-triggered after implementation |

**Flow**: `[x-implement completes]` → **`x-docs`** (auto) → `[x-review]`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Analyze documentation state.
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-doc-writer` | Documentation generation | sonnet |
| `ccsetup:x-explorer` | Code analysis | haiku |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Documentation scope unclear
- Multiple doc types affected
- Breaking changes need documenting

### Phase 1: Documentation Analysis

Determine what's needed:

| Action | Trigger |
|--------|---------|
| Generate | "generate", "create docs", "add documentation" |
| Sync | "sync", "update docs", "align", "synchronize" |
| Verify | "verify", "check docs", "docs stale" |
| Cleanup | "cleanup", "clean docs", "remove stale" |

### Phase 2: Sync Detection

Check for documentation drift:

```
1. Scan changed files since last doc update
2. For each changed file:
   - Identify affected documentation
   - Check for signature changes (API docs)
   - Check for behavior changes (examples)
   - Check for reference changes (moved/renamed)
3. Report drift with file:line references
```

### Phase 3: Execute Action

**Generate**: Create new documentation
**Sync**: Update existing docs to match code
**Verify**: Report drift without modifying
**Cleanup**: Remove stale documentation

### Phase 4: Validation

After any doc change:
- Verify examples still work
- Check internal links
- Update navigation if needed

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Delete documentation |
| **High** | ASK IF ABLE | Major doc restructure |
| **Medium** | ASK IF UNCERTAIN | Sync decisions |
| **Low** | PROCEED | Standard updates |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: What documentation drift was found
2. **Options**: Sync, generate new, or defer
3. **Recommendation**: Based on drift severity
4. **Escape**: "Skip doc update" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: `ccsetup:x-doc-writer`

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large doc generation | Simple updates |
| API documentation | README updates |

## Workflow Chaining

**Next Verb**: Return to calling workflow

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| Docs synced | Return to workflow | Yes |
| Drift detected | Stay for user decision | No |

## Auto-Trigger Integration

x-docs is automatically triggered after implementation:

```
APEX Flow:
x-plan → x-implement → x-verify → [x-docs sync] → x-review → x-commit
                                       ↑
                                 AUTO-TRIGGERED
```

### Auto-Trigger Points

| After | Mode |
|-------|------|
| x-implement completes | sync |
| Before x-review | verify |
| Before x-commit | verify |

## Documentation Principles

| Principle | Description |
|-----------|-------------|
| Docs follow code | Never update docs in isolation |
| Detect before update | Check for drift before writing |
| Pareto documentation | Document 20% that delivers 80% value |
| Examples must work | Test all code examples |

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

## Verification Output Format

```
┌─────────────────────────────────────────────────┐
│ Documentation Verification Report               │
├─────────────────────────────────────────────────┤
│ Checked: 12 docs                                │
│ Need updates: 3 docs                            │
│ Broken links: 1 doc                             │
├─────────────────────────────────────────────────┤
│ Drift detected:                                 │
│   • src/api/users.ts:45 → docs/api/users.md     │
│     Function signature changed                  │
└─────────────────────────────────────────────────┘
```

## Critical Rules

1. **Docs Follow Code** - Never update docs without code context
2. **Verify First** - Check drift before making changes
3. **Working Examples** - All code examples must be tested
4. **Keep Navigation Updated** - Update TOCs and links

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Return | (calling workflow) | Docs complete |
| Stay | x-docs | More doc work needed |

## Success Criteria

- [ ] Documentation matches code
- [ ] Examples are tested
- [ ] No broken internal links
- [ ] Navigation updated
- [ ] Changelog updated (if release)

## When to Load References

- **For generate patterns**: See `references/mode-generate.md`
- **For sync patterns**: See `references/mode-sync.md`
- **For verification**: See `references/mode-verify.md`
- **For cleanup**: See `references/mode-cleanup.md`
- **For sync patterns reference**: See `references/doc-sync-patterns.md`

## References

- @skills/documentation/ - Doc sync behavioral skill
