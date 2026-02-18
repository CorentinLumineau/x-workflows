---
name: x-create
description: Use when you need to create a new skill, agent, hook, or component in the ecosystem.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob
user-invocable: true
argument-hint: "[skill|agent|discover] [name]"
chains-from:
  - x-brainstorm
  - x-design
chains-to:
  - x-implement
  - x-review
metadata:
  author: ccsetup contributors
  version: "3.0.0"
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

Pipeline: **0.5 → 0.6 → 0.7 → 0.8 → mode file**

- **0.5** Scope Detection (existing — unchanged)
- **0.6** Ecosystem Scan (dedup, related components)
- **0.7** Smart Routing + Routing Gate (correct repo + path + user confirmation)
- **0.8** Guide Consultation (current best practices)
- **mode** Mode-specific wizard (skill/agent/discover)

**Default mode**: skill
**No-args behavior**: Enter discover mode

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

### Phase 0.6: Ecosystem Scan

Scan the existing ecosystem to prevent duplicates and show context.

**Protocol**: See `references/ecosystem-catalog.md` for full scan protocol.

1. **Glob** all existing components in detected scope:
   - `{plugin_root}/skills/*/SKILL.md` → Skills
   - `{plugin_root}/agents/*.md` → Agents
2. **Parse** frontmatter from each (name, description, category)
3. **Duplicate check**:
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
<purpose>Confirm routing decision with user before proceeding to creation</purpose>
<context>Show the user: component type classification, target repository, resolved file path, and routing rationale. Allow override if the auto-detected route is wrong.</context>
<options>
  <option id="confirm">Proceed with detected route</option>
  <option id="override">Choose different target</option>
  <option id="abort">Cancel creation</option>
</options>
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

### Phase 0.8: Guide Consultation

Query current Claude Code best practices for the component type being created.

<agent-delegate role="claude code guide" model="haiku">
<prompt>What are current Claude Code best practices for creating a {component_type}? Include: recommended file structure, frontmatter fields, naming conventions, and any recent changes to the skill/agent format. Focus on practical patterns, not theory.</prompt>
<context>Creating a {component_type} named "{name}" in {scope} scope. Purpose: {description}</context>
</agent-delegate>

1. **Query** the Claude Code guide for current patterns
2. **Extract** actionable recommendations (file structure, frontmatter, naming)
3. **Carry forward** recommendations into the mode-specific wizard phases
4. **Fallback**: If delegation is unavailable, use the static boilerplates in mode files

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
  Brief description of what this skill does.
  Activation triggers and use cases.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: your-name
  version: "1.0.0"
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

## When to Load References

- **For ecosystem scan protocol**: See `references/ecosystem-catalog.md`
- **For routing decisions**: See `references/routing-rules.md`
- **For skill mode**: See `references/mode-skill.md`
- **For agent mode**: See `references/mode-agent.md`
- **For discover mode**: See `references/mode-discover.md`
- **For post-creation integration**: See `references/integration-checklist.md`
