# Mode: rules

> **Invocation**: `/x-help rules` or `/x-help rules`
> **Legacy Command**: `/x:rules`

<purpose>
Rules directory management - create, list, and manage `.claude/rules/` behavioral rules.
</purpose>

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 30%, technical 20%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Ask clarifying question
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Which rules to manage unclear.

---

### Phase 1: List Rules

List existing rules:

```bash
ls -la .claude/rules/
```

```markdown
## Behavioral Rules

| Rule File | Description | Active |
|-----------|-------------|--------|
| {filename} | {description} | ✓/✗ |
```

### Phase 2: Rule Operations

```json
{
  "questions": [{
    "question": "What would you like to do?",
    "header": "Action",
    "options": [
      {"label": "Create rule", "description": "Add new behavioral rule"},
      {"label": "View rule", "description": "Read specific rule"},
      {"label": "Disable rule", "description": "Turn off a rule"},
      {"label": "Done", "description": "Nothing more"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 3: Create Rule

Create new rule file:

```markdown
# Rule: {name}

## When Active
{Conditions when this rule applies}

## Behavior
{What Claude should do differently}

## Examples

### Do
- {Example of correct behavior}

### Don't
- {Example of incorrect behavior}
```

Save to `.claude/rules/{name}.md`

### Phase 4: View Rule

Display rule content:

```markdown
## Rule: {name}

{rule content}
```

</instructions>

<critical_rules>
- Rules must be specific with clear conditions
- Rules must be actionable with concrete behaviors
- Rules must be consistent with project style
- Rules must include examples and documentation
</critical_rules>

## Rule Structure

```
.claude/
└── rules/
    ├── testing.md      # Testing requirements
    ├── commits.md      # Commit message format
    └── security.md     # Security checks
```

## Rule Format

```markdown
# Rule: {Name}

## Applies When
- {condition}

## Behavior
{What to do}

## Priority
{High/Medium/Low}
```

## Common Rules

| Rule | Purpose |
|------|---------|
| testing | Test requirements |
| commits | Commit format |
| security | Security checks |
| documentation | Doc requirements |

## Critical Rules

1. **Specific** - Clear conditions
2. **Actionable** - Concrete behaviors
3. **Consistent** - Match project style
4. **Documented** - Examples help

## References

- @core-docs/RULES.md - Global rules

<output_format>
Markdown table listing rule files with descriptions and active status. Interactive prompt for rule operations. Rule content displayed with structured sections (When Active, Behavior, Examples).
</output_format>

<success_criteria>
- Existing rules listed accurately with active status
- User can select and execute rule operations
- New rules follow required format with all sections
- Rule changes persist to .claude/rules/ directory
</success_criteria>
