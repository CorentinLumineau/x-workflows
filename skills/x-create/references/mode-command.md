# Mode: command

> **Invocation**: `/x-create command`
> **Legacy Command**: `/x:create-command`
> **Status**: Legacy mode — skills are the recommended approach for new slash commands

<purpose>
Redirect users to skill creation (recommended) or generate legacy command wrappers as a fallback.
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

**Triggers for this mode**: Command name unclear, skill delegation unclear.

---

### Phase 0.9: Skill Redirect (NEW — before Phase 1)

Claude Code has merged commands into skills. Skills are strictly superior:

| Feature | Commands | Skills |
|---------|----------|--------|
| Slash command invocation | Yes | Yes |
| Supporting files (references/) | No | Yes |
| Auto-invocation by Claude | No | Yes |
| Invocation control | No | Yes |
| Tool restrictions (allowed-tools) | No | Yes |
| Subagent execution (context: fork) | No | Yes |

**Present redirect choice to user**:

```json
{
  "questions": [{
    "question": "Claude Code now recommends skills over commands. Skills have all command features plus supporting files, auto-invocation, and tool restrictions. How would you like to proceed?",
    "header": "Approach",
    "options": [
      {"label": "Create as skill (Recommended)", "description": "Full-featured skill in .claude/skills/ — the modern approach"},
      {"label": "Create as command (Legacy)", "description": "Thin command wrapper in .claude/commands/ — still works but limited"}
    ],
    "multiSelect": false
  }]
}
```

- **If "Create as skill"** → Switch to skill mode: invoke `x-create` skill with mode `skill`, carrying forward all gathered context
- **If "Create as command"** → Continue to Phase 1 below (legacy path)

---

### Phase 1: Command Information (Legacy Path)

> **Note**: User chose legacy command creation after being informed about skills.

**Consume pre-processing context** from Phases 0.6-0.8:
- Check for existing commands that already delegate to the same skill
- Display any duplicate warnings from ecosystem scan
- Apply guide consultation recommendations from Phase 0.8

**Duplicate delegation check**: Before creating, verify no existing command already delegates to the target skill. If found, warn: "Command '{existing}' already delegates to {skill}. Create anyway?"

Gather command details:

- Command name (without x: prefix)
- Purpose/description
- Which skill it delegates to
- Which mode to use

### Phase 2: Generate Command File

Apply guide consultation patterns from Phase 0.8 if available.

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

Save to `{scope.paths.commands}{command}.md`

### Phase 3: Validation

Check command structure:

```bash
# Verify file exists
ls {scope.paths.commands}{command}.md

# Check frontmatter
head -10 {scope.paths.commands}{command}.md

# Verify skill invocation
grep "Invoke the" {scope.paths.commands}{command}.md
```

### Phase 4: Completion

```json
{
  "questions": [{
    "question": "Command '/x:{command}' created. Consider migrating to a skill in the future for auto-invocation and supporting files. What's next?",
    "header": "Next",
    "options": [
      {"label": "Convert to skill", "description": "Create equivalent skill (recommended migration)"},
      {"label": "Test command", "description": "Verify it works"},
      {"label": "Done", "description": "Command complete"}
    ],
    "multiSelect": false
  }]
}
```
</instructions>

## Why Skills Over Commands

Claude Code merged commands into skills. Both `.claude/commands/review.md` and `.claude/skills/review/SKILL.md` create the same `/review` slash command. Existing commands keep working, but skills are the active development focus with strictly more features.

**When commands still make sense**:
- Backward-compatible aliases for existing skill invocations
- Plugin-internal thin wrappers that delegate to skills
- Legacy projects that already use the commands/ pattern

**When to use skills instead**:
- All new slash command creation
- Any command that needs supporting files
- Commands that should be auto-discoverable by Claude

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
1. **Redirect First** - Always offer skill creation before command creation
2. **Skill Invokers** - Use "Invoke the `skill-name` skill" pattern for legacy commands
3. **Minimal Content** - <20 lines
4. **Official Frontmatter Only** - Only use official Claude Code fields
5. **Tip Message** - Show new skill option
6. **No Duplicate Delegation** - Check existing commands before creating
</critical_rules>

<success_criteria>
- [ ] User informed that skills are recommended over commands
- [ ] If user chose skill → redirected to skill mode
- [ ] If user chose command → command information gathered
- [ ] Ecosystem checked for duplicate delegations
- [ ] File created (if command path chosen)
- [ ] Validation passed
</success_criteria>

## References

- @documentation/development/plugin-architecture.md
- boilerplates/command-boilerplate.md
- Claude Code skills documentation: commands merged into skills
