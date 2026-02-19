# Claude Code Platform Reference

> **Purpose**: Complete platform specification for component creation. Loaded by x-create to generate components with correct frontmatter, structure, and platform integration.
>
> **Last Refreshed**: 2026-02-19

## Skill / Command Frontmatter

**Location**: `skills/{name}/SKILL.md` or `commands/{name}.md`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | Recommended | dir/file name | Display name. Lowercase, hyphens, max 64 chars |
| `description` | string | Recommended | first paragraph | Purpose and activation triggers. Used for auto-invocation |
| `allowed-tools` | string | No | all | Comma-separated tool allowlist: `Read, Write, Edit, Grep, Glob, Bash, Task, WebFetch, WebSearch` |
| `argument-hint` | string | No | none | Autocomplete hint: `[mode] [name]`, `<environment>` |
| `disable-model-invocation` | boolean | No | `false` | `true` = only user can invoke (prevents Claude auto-loading) |
| `user-invocable` | boolean | No | `true` | `false` = only Claude can invoke (hidden from `/` menu) |
| `model` | string | No | inherit | `sonnet`, `opus`, `haiku`, or `inherit` |
| `context` | string | No | inline | `fork` = run in isolated subagent context |
| `agent` | string | No | general-purpose | Subagent type when `context: fork`. Custom agent name or built-in |
| `hooks` | object | No | none | Skill-scoped hooks (same format as settings.json) |

### String Substitutions (in skill body)

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking |
| `$ARGUMENTS[N]` | Nth argument (0-based) |
| `$N` | Shorthand for `$ARGUMENTS[N]` ($0, $1, $2...) |
| `${CLAUDE_SESSION_ID}` | Current session unique identifier |

### Skill File References

| Syntax | Purpose |
|--------|---------|
| `@path/to/file` | Include file content inline |
| `!`command`` | Execute bash and include output |
| `[link](relative/path.md)` | Link to supporting reference files |

### Skill Directory Structure

```
skills/{name}/
  SKILL.md           # Main skill file (required)
  references/        # Supporting docs (optional)
    mode-{mode}.md   # Mode files for multi-mode skills
    {reference}.md   # Additional references
```

---

## Agent Frontmatter

**Location**: `agents/{name}.md`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | Yes | — | Lowercase-hyphens, 3-50 chars |
| `description` | string | Yes | — | When Claude should delegate. Include `<example>` blocks for auto-invocation |
| `model` | string | No | `inherit` | `sonnet`, `opus`, `haiku`, or `inherit` |
| `color` | string | No | none | Visual indicator: `blue`, `cyan`, `green`, `yellow`, `magenta`, `red` |
| `tools` | string | No | all | Comma-separated tool allowlist |
| `disallowedTools` | string | No | none | Tool deny-list (overrides tools) |
| `permissionMode` | string | No | `default` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | number | No | unlimited | Maximum agentic turns before stopping |
| `skills` | array | No | none | Skills to preload (injected at startup) |
| `mcpServers` | string\|object | No | inherited | MCP server names or inline config |
| `hooks` | object | No | none | Agent-scoped lifecycle hooks |
| `memory` | string | No | none | Persistent memory: `user`, `project`, or `local` |

### Agent Description Best Practice

Include `<example>` blocks for automatic invocation:

```markdown
description: Use this agent when [conditions]. Examples:

<example>
Context: [Situation]
user: "[Request]"
assistant: "[Response using this agent]"
<commentary>
[Why this agent triggers]
</commentary>
</example>
```

### Model Selection Guide

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| Fast read-only | haiku | Speed + cost efficiency |
| Standard changes | sonnet | Quality/cost balance |
| Critical decisions | opus | Maximum accuracy |

---

## Hook Events

Components can declare hooks to respond to lifecycle events.

### All Events

| Event | Matcher | Can Block | Description |
|-------|---------|-----------|-------------|
| `SessionStart` | `startup`, `resume`, `clear`, `compact` | No | Session begins/resumes |
| `UserPromptSubmit` | (none) | Yes | Before Claude processes user input |
| `PreToolUse` | Tool name | Yes | Before tool executes |
| `PermissionRequest` | Tool name | Yes | Before permission dialog shows |
| `PostToolUse` | Tool name | Yes | After tool executes successfully |
| `PostToolUseFailure` | Tool name | No | After tool execution fails |
| `Notification` | `permission_prompt`, `idle_prompt`, `auth_success` | No | System notifications |
| `SubagentStart` | Agent type name | No | Subagent spawned |
| `SubagentStop` | Agent type name | Yes | Subagent finished |
| `Stop` | (none) | Yes | Claude finishes responding |
| `TeammateIdle` | (none) | Exit 2 | Team agent goes idle |
| `TaskCompleted` | (none) | Exit 2 | Task marked complete |
| `PreCompact` | `manual`, `auto` | No | Before context compaction |
| `SessionEnd` | `clear`, `logout`, `prompt_input_exit` | No | Session terminates |

### Hook Handler Types

| Type | Config | Input | Output |
|------|--------|-------|--------|
| `command` | `command`, `async?`, `timeout?` | JSON on stdin | Exit code + JSON stdout |
| `prompt` | `prompt`, `model?`, `timeout?` | `$ARGUMENTS` in prompt | `{ok, reason}` |
| `agent` | `prompt`, `model?`, `timeout?` | `$ARGUMENTS` in prompt | `{ok, reason}` |

### Hook JSON Structure

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "Pattern",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/handler.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Exit Code Semantics

| Code | Meaning |
|------|---------|
| `0` | Success — process JSON output |
| `2` | Block — execute event-specific blocking action, feed stderr to Claude |
| Other | Non-blocking error — show stderr in verbose mode only |

---

## Environment Variables

### Available in Components

| Variable | Available In | Description |
|----------|-------------|-------------|
| `${CLAUDE_PLUGIN_ROOT}` | Hooks, MCP config | Absolute path to plugin root |
| `${CLAUDE_PROJECT_DIR}` | Hooks, MCP config | Current project directory |
| `${CLAUDE_SESSION_ID}` | Skills, hooks | Current session unique ID |

### Key Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTHROPIC_MODEL` | — | Override model selection |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 32,000 | Max output tokens (max 64,000) |
| `MAX_THINKING_TOKENS` | 31,999 | Extended thinking budget |
| `MCP_TIMEOUT` | — | MCP server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | — | MCP tool execution timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 | Max tokens in MCP responses |

---

## MCP Server Configuration

**Location**: `.mcp.json` or plugin `mcpServers` field

```json
{
  "mcpServers": {
    "server-name": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/server-bin",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": { "KEY": "value" },
      "cwd": "${CLAUDE_PLUGIN_ROOT}"
    }
  }
}
```

---

## Plugin Manifest

**Location**: `.claude-plugin/plugin.json`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Unique identifier (kebab-case) |
| `version` | string | No | Semantic version (X.Y.Z) |
| `description` | string | No | Brief plugin purpose |
| `author` | object | No | `{name, email, url}` |
| `homepage` | string | No | Documentation URL |
| `repository` | string | No | Source code URL |
| `license` | string | No | License identifier |
| `keywords` | array | No | Discovery tags |
| `commands` | string\|array | No | Command file paths |
| `agents` | string\|array | No | Agent file paths |
| `skills` | string\|array | No | Skill directory paths |
| `hooks` | string\|array\|object | No | Hook config or inline |
| `mcpServers` | string\|array\|object | No | MCP config or inline |
| `outputStyles` | string\|array | No | Output style paths |
| `lspServers` | string\|array\|object | No | LSP config or inline |

---

## Output Styles

**Location**: `output-styles/{name}.md`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | file name | Display name |
| `description` | string | none | Description for `/output-style` menu |
| `keep-coding-instructions` | boolean | `false` | Retain software engineering instructions |

---

## LSP Servers

**Location**: `.lsp.json` or inline in `plugin.json`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | LSP binary (must be in PATH) |
| `extensionToLanguage` | object | Yes | Maps extensions to language IDs: `{".go": "go"}` |
| `args` | array | No | Command-line arguments |
| `transport` | string | No | `stdio` (default) or `socket` |
| `env` | object | No | Environment variables |
| `initializationOptions` | object | No | Server init options |
| `settings` | object | No | Workspace config settings |

---

## Permission Modes

| Mode | Behavior |
|------|----------|
| `default` | Standard permission prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny unpermitted tools |
| `bypassPermissions` | Skip all permission checks |
| `plan` | Read-only mode (no writes) |

---

## Naming Conventions

| Component | Scope | Pattern | Examples |
|-----------|-------|---------|---------|
| Workflow skill | plugin | `x-{verb}` | x-implement, x-review |
| Behavioral skill | any | `{noun}` or `{noun}-{modifier}` | interview, code-quality |
| Knowledge skill | plugin | `{category}-{topic}` | security-owasp, quality-testing |
| Agent | plugin | `x-{role}` | x-tester, x-reviewer |
| Agent | project | `prj-{name}` | prj-db-migrator |
| Agent | user | `usr-{name}` | usr-my-helper |
| Command | plugin | `{verb}` or `{verb}-{noun}` | commit, bump-version |
| Command | project | `prj-{name}` | prj-lint, prj-deploy |
| Command | user | `usr-{name}` | usr-scratch |
| Skill (user-invocable) | project | `prj-{name}` | prj-validate-schema |
| Skill (user-invocable) | user | `usr-{name}` | usr-my-linter |
| Output style | any | `{adjective}` or `{style-name}` | explanatory, learning |

### Scope-Prefix Convention

Components at project and user scope receive automatic name prefixes for autocomplete discoverability:
- **`prj-`** for project scope (`/prj-<TAB>` → all project components)
- **`usr-`** for user scope (`/usr-<TAB>` → all personal components)
- **No prefix** for behavioral skills (auto-activated, not `/`-discoverable)

See `references/scope-prefix.md` for the complete convention.

---

**Source**: Context7 + Claude Code Official Documentation
**Spec Version**: Claude Code v2.1.39+
