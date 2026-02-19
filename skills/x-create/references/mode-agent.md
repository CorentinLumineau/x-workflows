# Mode: agent

> **Invocation**: `/x-create agent`
> **Legacy Command**: `/x:create-agent`

<purpose>
Generate subagents through interactive wizard with ecosystem awareness, agentTypes cross-referencing, and coherence validation.
</purpose>

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 30%, context 25%, technical 25%, scope 15%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Agent type unclear, agent purpose undefined, model selection unclear.

---

### Phase 1: Agent Information (Enhanced with Ecosystem Context)

**Consume pre-processing context** from Phases 0.6-0.8:
- Cross-reference with existing agentTypes from tool-mapping.json (12 registered types)
- Check for duplicate roles or overlapping capabilities
- Apply guide consultation recommendations from Phase 0.8

**Existing agentTypes reference** (from `.github/config/tool-mapping.json`):

| Role | Subagent Type | Model | Description |
|------|--------------|-------|-------------|
| code reviewer | ccsetup:x-reviewer | sonnet | Expert code review with systematic checklist |
| codebase explorer | ccsetup:x-explorer | haiku | Fast read-only codebase exploration |
| test runner | ccsetup:x-tester | sonnet | Test execution with edit capabilities |
| debugger | ccsetup:x-debugger | sonnet | Application runtime debugging |
| refactoring agent | ccsetup:x-refactorer | sonnet | Safe refactoring with zero-regression guarantee |
| documentation writer | ccsetup:x-doc-writer | sonnet | Code-adjacent documentation generation |
| designer | ccsetup:x-designer | opus | System design and architecture decisions |
| security reviewer | ccsetup:x-security-reviewer | sonnet | OWASP-focused security analysis |
| deep debugger | ccsetup:x-debugger-deep | opus | Distributed system and complex debugging |
| fast tester | ccsetup:x-tester-fast | haiku | Speed-optimized test runner |
| quick reviewer | ccsetup:x-reviewer-quick | haiku | Fast code scanning for obvious issues |
| claude code guide | claude-code-guide | haiku | Built-in Claude Code documentation guide (read-only) |

**Overlap check**: Before creating, verify the new agent doesn't duplicate an existing role. If overlap detected, warn: "Existing agent '{name}' ({role}) has similar capabilities. Create anyway?"

Gather agent details:

```json
{
  "questions": [{
    "question": "What type of agent are you creating?",
    "header": "Type",
    "options": [
      {"label": "Explorer", "description": "Fast codebase exploration (haiku)"},
      {"label": "Implementation", "description": "Code changes (haiku/sonnet)"},
      {"label": "Review", "description": "Quality assessment (sonnet)"},
      {"label": "Specialist", "description": "Specific domain expertise"}
    ],
    "multiSelect": false
  }]
}
```

Then ask for:
- Agent name (x-{name})
- Purpose/description
- Recommended model (haiku/sonnet/opus)
- Tools available

### Phase 2: Generate Agent File

**REQUIRED**: Before generating, load `references/claude-code-platform.md` for the complete agent frontmatter field reference. Use the platform spec as the authoritative source — include all relevant optional fields as comments (memory, skills, mcpServers, hooks, permissionMode, maxTurns, disallowedTools, color).

Apply guide consultation patterns from Phase 0.8 if available.

**Model selection guidance** (from agentTypes patterns):

| Task Type | Model | Rationale | Examples |
|-----------|-------|-----------|---------|
| Fast read-only | haiku | Speed + cost | explorer, fast-tester, quick-reviewer |
| Standard changes | sonnet | Quality/cost balance | tester, reviewer, debugger, refactorer |
| Complex reasoning | opus | Maximum accuracy | designer, deep-debugger |

```markdown
---
name: x-{name}
description: "{purpose}"
model: {haiku|sonnet|opus}
tools:
  - Read
  - {other_tools}
# --- Optional fields (add only when needed) ---
# disallowedTools: [Bash, Write]             # Deny-list (overrides tools)
# memory: true                               # Enable persistent memory
# permissionMode: bypassPermissions           # Or: default, plan, acceptEdits
# maxTurns: 25                               # Limit agentic turns
# skills: [x-review, x-implement]            # Skills available to agent
# mcpServers: [sequential-thinking, context7] # MCP servers to connect
# hooks:
#   - PreToolUse                              # Hook event triggers
---

# Agent: x-{name}

{Purpose description}

## System Prompt

{Instructions for the agent}

## Capabilities

- {capability_1}
- {capability_2}

## Tools

| Tool | Purpose |
|------|---------|
| {tool} | {why} |

## When to Use

Use this agent when:
- {scenario_1}
- {scenario_2}

## Example Invocation

Delegate to a **x-{name}** agent ({model}):
> "{example_prompt}"

## References

- {relevant docs}

---

**Version**: 1.0.0
```

Save to `{scope.paths.agents}x-{name}.md`

**If creating a plugin-level agent**: Also consider registering in `tool-mapping.json` agentTypes for semantic marker resolution. This enables other skills to reference the agent via `<agent-delegate role="{role}">`.

### Phase 3: Validation

Check agent structure:

```bash
# Verify file exists
ls {scope.paths.agents}x-{name}.md

# Check frontmatter
head -15 {scope.paths.agents}x-{name}.md
```

### Phase 4: Integration & Completion

**Load and apply** `references/integration-checklist.md`:

1. **Run agent integration steps** — verify frontmatter, role overlap check, model selection, tool mapping
2. **Report checklist status** — show which items pass and which need attention
3. **Present post-creation workflow gate** from the integration checklist:
   - Chain to x-implement or x-review
   - Create another component
   - Complete integration manually
   - Done

If the agent should be registered in `tool-mapping.json` agentTypes, highlight this in the checklist report.
</instructions>

## Agent Types

### Explorer (haiku)
Fast, read-only operations:
- File discovery
- Pattern identification
- Quick analysis

### Implementation (haiku/sonnet)
Code changes:
- Tester - Test execution
- Refactorer - Safe changes
- Doc-writer - Documentation

### Review (sonnet)
Quality assessment:
- Reviewer - Code quality
- Debugger - Deep analysis

### Specialist (opus)
Complex domain tasks:
- Designer - Architecture decisions
- Deep-debugger - Distributed system debugging

## Model Selection

| Task | Model | Why |
|------|-------|-----|
| Fast exploration | haiku | Speed |
| Simple changes | haiku | Cost |
| Complex analysis | sonnet | Quality |
| Critical decisions | opus | Accuracy |

<critical_rules>
1. **Clear Purpose** - Single responsibility
2. **Right Model** - haiku vs sonnet vs opus (match existing agentTypes patterns)
3. **Limited Tools** - Only what's needed
4. **Good Prompt** - Clear instructions
5. **No Role Overlap** - Check existing agentTypes before creating
</critical_rules>

<success_criteria>
- [ ] Agent type determined
- [ ] Cross-referenced with existing agentTypes (no overlap)
- [ ] File created with correct model selection
- [ ] Tools configured
- [ ] Validation passed
</success_criteria>

## References

- references/claude-code-platform.md — Authoritative frontmatter fields, permission modes, model selection
- @skills/agent-awareness/ - Agent selection guide and task management
- boilerplates/agent-boilerplate.md - Agent structure template
- `.github/config/tool-mapping.json` - Registered agentTypes
