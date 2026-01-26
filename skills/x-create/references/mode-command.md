# Mode: command

> **Invocation**: `/x-create command` or `/x-create command`
> **Legacy Command**: `/x:create-command`

<purpose>
Generate best-practice-compliant slash commands through interactive wizard.
</purpose>

<instructions>
### Phase 1: Command Information

Gather command details:

- Command name (without x: prefix)
- Purpose/description
- Which skill it delegates to
- Which mode to use

### Phase 2: Generate Command File

Create command wrapper (v5.1 format):

```markdown
---
name: x:{command}
description: "{brief} - delegates to x-{skill} skill"
---

# /x:{command}

> **Tip**: Try `/x-{skill}` for the new skill experience.

Invoke the `x-{skill}` skill with mode `{mode}`.
Prepend "{mode}" to user arguments before passing to the skill.
```

Save to `ccsetup-plugin/commands/{command}.md`

### Phase 3: Validation

Check command structure:

```bash
# Verify file exists
ls ccsetup-plugin/commands/{command}.md

# Check frontmatter
head -10 ccsetup-plugin/commands/{command}.md

# Verify skill invocation
grep "Invoke the" ccsetup-plugin/commands/{command}.md
```

### Phase 4: Completion

```json
{
  "questions": [{
    "question": "Command '/x:{command}' created. What's next?",
    "header": "Next",
    "options": [
      {"label": "Test command", "description": "Verify it works"},
      {"label": "Create another", "description": "Add another command"},
      {"label": "Done", "description": "Command complete"}
    ],
    "multiSelect": false
  }]
}
```
</instructions>

## Command Types

### Skill Invoker (v5.1 standard)
Commands that invoke skills:
- Minimal content (~15 lines)
- Standard frontmatter (name, description)
- "Invoke the skill" pattern in body

### Internal Command
Commands with full logic (not delegated):
- Used for plugin management
- Full content in command file
- No skill invocation

## Command Template

```markdown
---
name: x:{command}
description: "{brief} - delegates to x-{skill} skill"
---

# /x:{command}

> **Tip**: Try `/x-{skill}` for the new skill experience.

Invoke the `x-{skill}` skill with mode `{mode}`.
Prepend "{mode}" to user arguments before passing to the skill.
```

<critical_rules>
1. **Skill Invokers** - Use "Invoke the `skill-name` skill" pattern
2. **Minimal Content** - <20 lines
3. **Official Frontmatter Only** - Only use official Claude Code fields
4. **Tip Message** - Show new skill option
</critical_rules>

<success_criteria>
- [ ] Command information gathered
- [ ] File created
- [ ] Skill invocation configured
- [ ] Validation passed
</success_criteria>

## References

- @documentation/development/plugin-architecture.md
- boilerplates/command-boilerplate.md
