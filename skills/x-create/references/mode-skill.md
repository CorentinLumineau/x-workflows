# Mode: skill

> **Invocation**: `/x-create` or `/x-create skill`
> **Legacy Command**: `/x:create-skill`

<purpose>
Generate behavioral skills through interactive wizard with coherence validation.
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

### Phase 1: Skill Information

Gather skill details:

```json
{
  "questions": [{
    "question": "What type of skill are you creating?",
    "header": "Type",
    "options": [
      {"label": "Behavioral", "description": "Auto-activated based on context"},
      {"label": "User-invocable", "description": "Directly callable via /x-{name}"}
    ],
    "multiSelect": false
  }]
}
```

Then ask for:
- Skill name
- Purpose/description
- Activation triggers (for behavioral)

### Phase 2: Skill Structure

Create skill directory:

```bash
mkdir -p {scope.paths.skills}{name}
```

### Phase 3: Generate SKILL.md

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

## References

- {relevant docs}

---

**Version**: 1.0.0
```

For user-invocable skill:
```markdown
---
name: x-{name}
description: "{purpose}. Modes: {modes}. Uses: {behavioral_skills}. Use when {triggers}."
---

# /x-{name}

{Purpose description}

## Mode Routing

| Mode | File | Legacy Command | Description |
|------|------|----------------|-------------|
| {mode} (default) | `references/mode-{mode}.md` | `/x:{cmd}` | {desc} |

## Execution

1. Detect mode from user input
2. If no valid mode, use default
3. Read mode file from references/
4. Follow instructions

## Behavioral Skills

This skill activates:
- {skill_1}
- {skill_2}

---

**Version**: 5.0.0
```

### Phase 4: Coherence Validation

Run validation:

```bash
# Check frontmatter
head -10 {scope.paths.skills}{name}/SKILL.md

# Verify structure
ls -la {scope.paths.skills}{name}/
```

### Phase 5: Completion

```json
{
  "questions": [{
    "question": "Skill '{name}' created. What's next?",
    "header": "Next",
    "options": [
      {"label": "Create mode files", "description": "Add mode references"},
      {"label": "Test skill", "description": "Verify it works"},
      {"label": "Done", "description": "Skill complete"}
    ],
    "multiSelect": false
  }]
}
```
</instructions>

## Skill Requirements

### Frontmatter
- `name`: Required (x-prefix for user-invocable)
- `description`: Required (comprehensive)

### Content
- Purpose statement
- Activation triggers (behavioral) or mode routing (user-invocable)
- Behavioral skills used
- References

<critical_rules>
1. **Minimal Frontmatter** - Only name and description
2. **Clear Triggers** - When does it activate
3. **Coherent** - Pass validation
4. **Documented** - Include references
</critical_rules>

<success_criteria>
- [ ] Name and type determined
- [ ] Directory created
- [ ] SKILL.md generated
- [ ] Validation passed
</success_criteria>

## References

- @documentation/development/plugin-architecture.md
- boilerplates/skill-boilerplate.md
