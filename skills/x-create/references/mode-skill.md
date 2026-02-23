# Mode: skill

> **Invocation**: `/x-create` or `/x-create skill`
> **Legacy Command**: `/x:create-skill`

<purpose>
Generate behavioral skills through interactive wizard with ecosystem awareness, routing enforcement, and coherence validation.
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

**Triggers for this mode**: Skill type unclear, skill purpose undefined, activation triggers unclear.

---

### Phase 1: Skill Information (Enhanced with Ecosystem Context)

**Consume pre-processing context** from Phases 0.5b-0.8:
- Show ecosystem scan results (total count, category breakdown)
- Display any duplicate warnings or blocks from Phase 0.6
- Show the resolved target path from Phase 0.7
- Apply guide consultation recommendations from Phase 0.8

**Apply scope-prefix** (from Phase 0.5b — see `references/scope-prefix.md`):
- If scope is `project` AND skill is user-invocable → auto-apply `prj-` prefix to name
- If scope is `user` AND skill is user-invocable → auto-apply `usr-` prefix to name
- If skill is behavioral → no prefix (note: "No prefix for behavioral skills")
- Show prefixed name in confirmation: "Skill name: **{prefixed_name}** ({scope} scope)"

Gather skill details:

```json
{
  "questions": [{
    "question": "What type of skill are you creating?",
    "header": "Type",
    "options": [
      {"label": "Behavioral", "description": "Auto-activated based on context (e.g., interview, documentation)"},
      {"label": "Workflow (x-*)", "description": "User-invocable with modes (e.g., x-implement, x-review)"},
      {"label": "Knowledge", "description": "Domain expertise reference (e.g., security-owasp, quality-testing)"}
    ],
    "multiSelect": false
  }]
}
```

Then ask for:
- Skill name
- Purpose/description
- Activation triggers (for behavioral)
- Modes (for workflow/user-invocable)

**For workflow skills**, suggest semantic markers based on purpose:

| Purpose | Suggested Markers |
|---------|-------------------|
| Needs user decisions | `workflow-gate` |
| Chains to other skills | `workflow-chain` |
| Delegates to agents | `agent-delegate` |
| Needs complex reasoning | `deep-think` |
| Looks up library docs | `doc-query` |
| Needs external research | `web-research` |

### Phase 2: Skill Structure

Create skill directory:

```bash
mkdir -p {resolved_path}
```

Where `{resolved_path}` comes from Phase 0.7 routing (may be in source repo or local scope).

### Phase 3: Generate SKILL.md

**REQUIRED**: Before generating, load `references/claude-code-platform.md` for the complete frontmatter field reference. Use the platform spec as the authoritative source for all frontmatter fields — do not guess or use outdated field names. Include all relevant optional fields as comments so the user sees available options.

For behavioral skill:
```markdown
---
name: {name}
description: "{purpose}. Use when {triggers}."
---

# {Name}

{Purpose description}

## Activation Triggers

Activate this skill when:
- {trigger_1}
- {trigger_2}

## Behavior

{What Claude should do when activated}

## Examples

### Example 1
{scenario and response}

## Related Skills

- {related_skill_1} — {relationship}
- {related_skill_2} — {relationship}

## References

- {relevant docs}

---

**Version**: 1.0.0
```

For user-invocable/workflow skill:
```markdown
---
name: x-{name}
description: "{purpose}. Modes: {modes}. Uses: {behavioral_skills}. Use when {triggers}."
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: {tools}
user-invocable: true
# argument-hint: "[mode] [name]"           # Optional: shown in command palette
# disable-model-invocation: true            # Optional: prevent auto-invocation
# context: fork                             # Optional: run in subagent context
# agent: x-{agent-name}                    # Optional: bind to agent definition
# chains-from:                              # Optional: workflow DAG
#   - x-{upstream-skill}
# chains-to:
#   - x-{downstream-skill}
metadata:
  author: {author}
  version: "1.0.0"
  category: workflow
---

# /x-{name}

{Purpose description}

## Mode Routing

| Mode | File | Legacy Command | Description |
|------|------|----------------|-------------|
| {mode} (default) | `references/mode-{mode}.md` | `/x:{cmd}` | {desc} |

## Workflow Context

| Aspect | Value |
|--------|-------|
| Workflow | {parent workflow or standalone} |
| Phase | {typical execution phase} |
| Position | {where in pipeline: early/middle/late} |
| Flow | {what comes before → this → what comes after} |

## Execution

1. Detect mode from user input
2. If no valid mode, use default
3. Read mode file from references/
4. Follow instructions

## Behavioral Skills

This skill activates:
- {skill_1}
- {skill_2}

## Related Skills

- {related_1} — {why related, from ecosystem scan}
- {related_2} — {why related}

---

**Version**: 1.0.0
```

For knowledge skill:
```markdown
---
name: {category}-{name}
description: "{purpose}. Use when {triggers}."
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: {author}
  version: "1.0.0"
  category: {category}
---

# {Name}

{Purpose description}

## When to Apply

Apply this knowledge when:
- {trigger_1}
- {trigger_2}

## Core Principles

{Knowledge content}

## Related Skills

- {related_skill_1} — {relationship}
- {related_skill_2} — {relationship}

## References

- {relevant docs}

---

**Version**: 1.0.0
```

### Phase 4: Coherence Validation

Run validation:

```bash
# Check frontmatter
head -10 {resolved_path}/SKILL.md

# Verify structure
ls -la {resolved_path}/
```

Validate against guide recommendations from Phase 0.8 if available.

### Phase 5: Integration & Completion

**Load and apply** `references/integration-checklist.md`:

1. **Run skill integration steps** — verify frontmatter, chaining metadata, behavioral skills, references
2. **Report checklist status** — show which items pass and which need attention
3. **Present post-creation workflow gate** from the integration checklist:
   - Chain to x-implement or x-review
   - Create another component
   - Complete integration manually
   - Done

If user arrived from x-brainstorm or x-design, pre-select "Chain to next workflow" as the recommended option.
</instructions>

## Skill Requirements

### Frontmatter
- `name`: Required (x-prefix for user-invocable)
- `description`: Required (comprehensive)

### Content
- Purpose statement
- Activation triggers (behavioral) or mode routing (user-invocable)
- Behavioral skills used
- Related skills (from ecosystem scan)
- References

<critical_rules>
1. **Minimal Frontmatter** - Only name and description required; license, compatibility, metadata recommended
2. **Clear Triggers** - When does it activate
3. **Coherent** - Pass validation
4. **Documented** - Include references
5. **Ecosystem-Aware** - Include Related Skills section from scan results
6. **Correctly Routed** - Created in the right repository per routing rules
</critical_rules>

<success_criteria>
- [ ] Name and type determined
- [ ] Ecosystem scanned for duplicates
- [ ] Routing resolved to correct repo/path
- [ ] Directory created
- [ ] SKILL.md generated with Related Skills
- [ ] Validation passed
</success_criteria>

## References

- references/claude-code-platform.md — Authoritative frontmatter fields, hook events, env vars
- @documentation/development/plugin-architecture.md
- boilerplates/skill-boilerplate.md
- references/ecosystem-catalog.md
- references/routing-rules.md
