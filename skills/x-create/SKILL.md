---
name: x-create
description: Use when you need to create a new skill, agent, hook, or component in the ecosystem.
version: "3.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob
user-invocable: true
argument-hint: "[skill|agent|discover] [name]"
chains-from:
  - x-brainstorm
  - x-design
  - x-setup
chains-to:
  - x-implement
  - x-review
metadata:
  author: ccsetup contributors
  category: workflow
---

# x-create

Ecosystem-aware creation wizard for plugin components. Scans the existing ecosystem before generating to prevent duplicates, enforce routing rules, and apply current best practices.

## Modes

| Mode | Description |
|------|-------------|
| skill (default) | Create behavioral or workflow skill |
| agent | Create subagent |
| discover | Zero-context gap analysis — scan ecosystem, suggest candidates |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "agent", "subagent", "worker" | agent |
| "discover", "what to create", "gaps", "what's missing" | discover |
| (default) | skill |

## Agent Delegation

| Role | Model | Purpose |
|------|-------|---------|
| claude code guide | haiku | Query current Claude Code best practices for component creation |

## MCP Servers

| Server | Tool | Purpose |
|--------|------|---------|
| sequential-thinking | sequentialthinking | Structured reasoning for routing decisions |

## Execution

Pipeline: **0.5 → 0.5b → 0.6 → 0.7 → 0.8 → mode file**

- **0.5** Scope Detection (existing — unchanged)
- **0.5b** Scope-Prefix Injection (auto-prefix based on scope + triggerability)
- **0.6** Ecosystem Scan (dedup, related components — prefix-aware)
- **0.7** Smart Routing + Routing Gate (correct repo + path + user confirmation)
- **0.8** Guide Consultation (current best practices)
- **mode** Mode-specific wizard (skill/agent/discover)

**Default mode**: skill
**No-args behavior**: Enter discover mode

<hook-trigger event="PostToolUse" tool="Write" condition="After new component file is created">
  <action>Run component validation: verify frontmatter fields, naming convention, and routing compliance</action>
</hook-trigger>

<permission-scope mode="acceptEdits">
  <allowed>Read, Write, Edit, Grep, Glob (component creation and ecosystem scanning)</allowed>
  <denied>Bash (no command execution needed for component creation); direct writes to ccsetup-plugin/skills/ (must use source repos)</denied>
</permission-scope>

## Scope Detection

Before creating any component, detect the target scope:

```yaml
scopes:
  plugin:
    description: "Plugin development (directory with .claude-plugin/)"
    detect: "Current directory contains .claude-plugin/"
    paths:
      agents: "{plugin_root}/agents/"
      skills: "{plugin_root}/skills/"
      hooks: "{plugin_root}/hooks/"
  project:
    description: "Project-level configuration"
    detect: "Current directory contains .claude/ directory"
    paths:
      agents: ".claude/agents/"
      skills: ".claude/skills/"
  user:
    description: "User-level (global)"
    detect: "~/.claude/ exists"
    paths:
      agents: "~/.claude/agents/"
      skills: "~/.claude/skills/"
```

### Phase 0.5: Scope Detection (before any mode)

1. **Auto-detect** current scope by checking (in order):
   - `.claude-plugin/` exists in current/parent directory → **plugin** scope
   - `.claude/` exists in current directory → **project** scope
   - `~/.claude/` exists → **user** scope
2. **Show** detected scope: "Detected scope: **{scope}** (`{root_path}`)"
3. **Confirm** with user or allow override
4. **Resolve** all `{scope.paths.*}` templates using confirmed scope

### Phase 0.5b: Scope-Prefix Injection

Apply scope-based naming prefix after scope is confirmed.

**Protocol**: See `references/scope-prefix.md` for complete convention.

1. **Determine triggerability**:
   - Commands → always user-triggerable
   - Agents → always user-triggerable
   - Skills with `user-invocable: true` → user-triggerable
   - Skills with `user-invocable: false` (behavioral) → NOT user-triggerable
2. **If user-triggerable AND scope has a prefix**:
   - project → `prj-`
   - user → `usr-`
   - plugin → no scope prefix (uses existing `x-`/`git-` convention)
3. **Double-prefix detection**:
   - If name already starts with scope prefix → use as-is, note: "Prefix already present"
   - If name starts with a *different* scope prefix → **WARN**: "Name has `{other_prefix}` but scope is `{scope}`. Use `{scope_prefix}{base_name}` instead? [Y/n]"
   - Otherwise → prepend prefix, show: "Auto-prefixed: `{prefix}{name}` ({scope} scope convention)"
4. **If NOT user-triggerable** → no prefix, note: "No prefix for behavioral skills"
5. **Pass prefixed name** downstream to all subsequent phases

### Phase 0.6: Ecosystem Scan

Scan the existing ecosystem to prevent duplicates and show context.

**Protocol**: See `references/ecosystem-catalog.md` for full scan protocol.

1. **Glob** all existing components in detected scope:
   - `{plugin_root}/skills/*/SKILL.md` → Skills
   - `{plugin_root}/agents/*.md` → Agents
2. **Parse** frontmatter from each (name, description, category)
3. **Duplicate check** (prefix-aware):
   - Strip any scope prefix (`prj-`, `usr-`) before comparing to catch conflicts
   - Match both `{prefix}{name}` and `{name}` against existing components
   - Cross-check against other scope prefixes (e.g., `usr-{name}` when creating `prj-{name}`)
   - Exact name match → **BLOCK** (show existing, confirm intent)
   - Similar name (edit distance < 3) → **WARN** (show similar, suggest review)
4. **Show related** components in same category/scope
5. **Summary**: "{total} skills, {n} in {category}, {duplicates} potential conflicts"

If scan finds 0 components, report "Empty ecosystem" and proceed.

### Phase 0.7: Smart Routing

Determine the correct repository and path for the new component.

<deep-think trigger="routing-decision">
<purpose>Analyze the component being created and determine the correct target repository and path based on routing rules. Consider: Is this a workflow skill (x-*), behavioral skill, knowledge skill, or agent? Does the source repo exist locally?</purpose>
<context>Reference routing-rules.md for the complete decision tree. Check if ../x-workflows or ../x-devsecops exists relative to the current workspace.</context>
</deep-think>

<workflow-gate id="routing-confirmation">
  <question>Confirm routing decision: component type, target repository, resolved file path, and routing rationale shown above. Proceed?</question>
  <header>Routing</header>
  <option key="confirm" recommended="true">
    <label>Proceed with detected route</label>
    <description>Route is correct — continue to creation</description>
  </option>
  <option key="override">
    <label>Choose different target</label>
    <description>Override the auto-detected routing</description>
  </option>
  <option key="abort">
    <label>Cancel creation</label>
    <description>Abort the creation process</description>
  </option>
</workflow-gate>

**Protocol**: See `references/routing-rules.md` for full decision tree.

1. **Classify** the component:
   - Workflow skill (x-*) → target: x-workflows
   - Behavioral skill → target: x-workflows
   - Knowledge skill → target: x-devsecops
   - Agent → target: current scope (plugin/project/user)
2. **Smart detection**: Check if target source repo exists locally
   - Look for `../x-workflows` or `../x-devsecops` relative to workspace
   - If found → create directly in source repo
   - If not found → create locally + add `<!-- TODO: migrate to {repo} -->` note
3. **Resolve path**: Apply routing rules to determine exact file path
4. **Present routing gate**: Show classification, target, path, and rationale for confirmation

### Phase 0.8: Platform Reference & Guide Consultation

Load the Claude Code platform specification and optionally query for latest best practices.

1. **Load platform reference** — Read `references/claude-code-platform.md` for authoritative frontmatter fields, hook events, environment variables, and file structure patterns
2. **Carry forward** platform spec into mode-specific wizard phases — use this as the source of truth for all frontmatter fields and component structure
3. **Optional live query** — If the claude code guide agent is available, query for any recent changes not yet in the static reference:

<agent-delegate role="claude code guide" model="haiku">
<prompt>Are there any recent Claude Code changes (since 2026-02-19) affecting {component_type} creation? Only report NEW changes to frontmatter fields, file structure, or naming conventions. Say "no changes" if nothing new.</prompt>
<context>Creating a {component_type} named "{name}" in {scope} scope. We already have the platform spec loaded — only report deltas.</context>
</agent-delegate>

4. **Merge** any live query deltas with static reference (static reference wins on conflicts)
5. **Fallback**: If both delegation and reference are unavailable, use the static boilerplates in mode files

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Component Types

### Skills

Behavioral rules that guide AI behavior:

```
skills/{name}/
├── SKILL.md        # Main skill file
└── references/     # Supporting docs
```

### Agents

Specialized subagent definitions:

```
agents/{name}.md
```

## Skill Template

```markdown
---
name: skill-name
description: |
version: "3.0.0"
  Brief description of what this skill does.
  Activation triggers and use cases.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: your-name
  category: category
---

# Skill Name

[Content]
```

## Validation

All created components must pass:

| Check | Requirement |
|-------|-------------|
| Frontmatter | Valid YAML with required fields |
| Description | 1-1024 characters |
| Body | <500 lines, <5000 tokens |
| Naming | Lowercase, kebab-case |

## Checklist

- [ ] Clear single responsibility
- [ ] Valid frontmatter
- [ ] Agent-agnostic (no tool-specific refs)
- [ ] Examples included
- [ ] References linked

## When to use x-create vs x-setup

| Aspect | x-create | x-setup |
|--------|----------|---------|
| Purpose | Build ecosystem components (skills, agents, hooks) | Initialize project or assess agent-readiness |
| Input | User knows (or discovers) what to build | User wants project-level setup or health check |
| Output | New component files with frontmatter and structure | Documentation structure (setup) or readiness report (verify) |
| Scope | Individual component creation | Whole-project assessment |
| Ecosystem scan | Duplicate detection and gap analysis | Configuration health and coverage assessment |
| Chains from | x-brainstorm, x-design, **x-setup** (verify recommendations) | — |
| Chains to | x-implement, x-review | **x-create** (from verify action gate) |

**Rule of thumb**: x-setup tells you "your project needs better agent coverage" — then x-create helps you build the missing agents. x-create's discover mode finds *component* gaps (missing skills, agents); x-setup's verify mode finds *project-level* gaps (missing CLAUDE.md sections, unconfigured MCP, no rules).

## When to Load References

- **For Claude Code platform spec**: See `references/claude-code-platform.md` (frontmatter fields, hooks, env vars, file structures)
- **For scope-prefix convention**: See `references/scope-prefix.md` (prj-, usr- prefixing rules)
- **For ecosystem scan protocol**: See `references/ecosystem-catalog.md`
- **For routing decisions**: See `references/routing-rules.md`
- **For skill mode**: See `references/mode-skill.md`
- **For agent mode**: See `references/mode-agent.md`
- **For discover mode**: See `references/mode-discover.md`
- **For post-creation integration**: See `references/integration-checklist.md`
