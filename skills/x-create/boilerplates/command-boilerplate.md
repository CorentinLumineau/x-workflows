---
type: template
audience: [developers]
scope: command-development
last-updated: 2026-01-09
status: current
used-by:
  - /x:create-command
---

# Command Boilerplate Reference

> **Purpose**: Standardized sections for all `/x:` commands to ensure DRY compliance

This document defines the canonical boilerplate text used across all 33 commands. Commands should reference these patterns for consistency.

---

## 1. Tool Usage Section

**Required in all commands that use tools.**

```markdown
## Tool Usage

> **Reference**: All tool patterns follow @core-docs/tools/README.md

### Tools Used by This Command

| Tool | Purpose | Reference |
|------|---------|-----------|
| **{ToolName}** | {Purpose description} | @core-docs/{path} |
```

### Standard Tool References

| Tool | Standard Reference |
|------|-------------------|
| Task | @core-docs/tools/task.md |
| Context7 | @core-docs/mcp/context7.md |
| Sequential Thinking | @core-docs/mcp/sequential-thinking.md |
| Memory | @core-docs/mcp/memory.md |
| claude-in-chrome | Built-in browser automation MCP |
| AskUserQuestion | @core-docs/tools/ask-user-question.md |
| TodoWrite | @core-docs/tools/todo-write.md |
| SlashCommand | @core-docs/tools/slash-command.md |

---

## 2. MCP Integration Section

**Required for commands with MCP server dependencies.**

```markdown
## MCP Integration

| MCP | Role | Trigger |
|-----|------|---------|
| **{MCPName}** | {Primary/Optional} | {When activated} |
```

### MCP Role Definitions

| Role | Meaning |
|------|---------|
| **Primary** | Always used by this command |
| **Optional** | Used conditionally based on context |
| **Preferred** | Recommended but not required |

---

## 3. Context-Aware Execution Section

**Required for all commands.**

```markdown
## Context-Aware Execution

| Input Pattern | Detected Context | Execution Path |
|---------------|------------------|----------------|
| {Pattern description} | {Context type} | {What happens} |
| Default | {Fallback context} | {Default behavior} |
```

### Standard Context Patterns

| Pattern | Detection Keywords |
|---------|-------------------|
| Initiative mode | Active milestone in `documentation/milestones/` |
| Feature mode | Specific feature description |
| Bug fix mode | "fix", "error", "bug", error messages |
| Spec mode | `.md` file path provided |

---

## 4. Quality Gates Section

**Required for commands that produce output.**

```markdown
## Quality Gates

- [ ] {Gate 1 description}
- [ ] {Gate 2 description}
- [ ] {Gate 3 description}
```

### Common Quality Gates

| Gate | Commands |
|------|----------|
| Type Checking - No errors | implement, fix, refactor |
| SOLID Principles - All validated | implement, refactor |
| Testing Pyramid - 70/20/10 | implement, verify |
| Coverage - 95%+ changed files | implement, verify |
| Build & Lint - Passing | implement, verify, build |
| Documentation - Synced | implement, docs |

---

## 5. References Section

**Required at end of all commands.**

```markdown
## References

- **{Topic}**: @core-docs/{path}
- **{Topic}**: @core-docs/{path}

---

**Version**: 4.12.0{X.Y.Z} ({Brief description of version})
```

### Common Reference Paths

| Topic | Path |
|-------|------|
| SOLID | @core-docs/principles/solid.md |
| Testing | @core-docs/testing/testing-pyramid.md |
| Patterns | @core-docs/patterns/ |
| Debugging | @core-docs/error-handling/debugging-strategies.md |
| Error Handling | @templates/optional/error-handling/error-handling-patterns.md |

---

## 6. Task Subagents Section (Optional)

**For commands that spawn parallel agents.**

```markdown
## Task Subagents for Parallel Execution

> **Pattern**: {Pattern name} (see @core-docs/tools/task.md#{pattern-anchor})

**Conditional: {Condition description}** (when {trigger keywords} detected)

| Agent | Model | Focus |
|-------|-------|-------|
| {Agent name} | haiku/sonnet | {What it analyzes} |
```

### Model Selection Guidelines

| Model | Use For |
|-------|---------|
| `haiku` | Read-only exploration, pattern scanning, fast discovery |
| `sonnet` | Complex reasoning, analysis, debugging |
| `inherit` | Use caller's model (default for flexibility) |

---

## Usage Notes

1. **Copy exact structure** - Maintain consistency across commands
2. **Customize content** - Only change variable elements (tool names, references)
3. **Keep headers identical** - Don't modify "## Tool Usage", "## MCP Integration", etc.
4. **Version updates** - Increment version when command logic changes

---

**Version**: 4.12.0
**Created**: 2025-12-12
**Purpose**: DRY compliance for command documentation
