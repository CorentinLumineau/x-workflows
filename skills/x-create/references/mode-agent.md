# Mode: agent

> **Invocation**: `/x-create agent` or `/x-create agent`
> **Legacy Command**: `/x:create-agent`

<purpose>
Generate subagents through interactive wizard with coherence validation.
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

### Phase 1: Agent Information

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
- Recommended model (haiku/sonnet)
- Tools available

### Phase 2: Generate Agent File

```markdown
---
name: ccsetup:x-{name}
description: "{purpose}"
model: {haiku|sonnet}
tools:
  - Read
  - {other_tools}
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

```javascript
Task({
  subagent_type: "ccsetup:x-{name}",
  model: "{model}",
  prompt: "{example_prompt}"
})
```

## References

- {relevant docs}

---

**Version**: 1.0.0
```

Save to `ccsetup-plugin/agents/x-{name}.md`

### Phase 3: Validation

Check agent structure:

```bash
# Verify file exists
ls ccsetup-plugin/agents/x-{name}.md

# Check frontmatter
head -15 ccsetup-plugin/agents/x-{name}.md
```

### Phase 4: Completion

```json
{
  "questions": [{
    "question": "Agent 'x-{name}' created. What's next?",
    "header": "Next",
    "options": [
      {"label": "Test agent", "description": "Verify it works"},
      {"label": "Create another", "description": "Add another agent"},
      {"label": "Done", "description": "Agent complete"}
    ],
    "multiSelect": false
  }]
}
```
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

## Model Selection

| Task | Model | Why |
|------|-------|-----|
| Fast exploration | haiku | Speed |
| Simple changes | haiku | Cost |
| Complex analysis | sonnet | Quality |
| Critical decisions | sonnet | Accuracy |

<critical_rules>
1. **Clear Purpose** - Single responsibility
2. **Right Model** - haiku vs sonnet
3. **Limited Tools** - Only what's needed
4. **Good Prompt** - Clear instructions
</critical_rules>

<success_criteria>
- [ ] Agent type determined
- [ ] File created
- [ ] Tools configured
- [ ] Validation passed
</success_criteria>

## References

- @skills/agent-awareness/ - Agent selection guide and task management
- boilerplates/agent-boilerplate.md - Agent structure template
