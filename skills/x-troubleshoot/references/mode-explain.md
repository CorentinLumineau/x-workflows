# Mode: explain

> **Invocation**: `/x-troubleshoot explain` or `/x-troubleshoot explain "code/concept"`
> **Legacy Command**: `/x:explain`

<purpose>
Educational code explanations for learning and onboarding. Provide clear, comprehensive explanations of how code works.
</purpose>

## Behavioral Skills

This mode activates:
- `context-awareness` - Code understanding

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Code analysis | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library documentation |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 35%, context 30%, technical 20%, scope 10%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Context level unclear (explain to whom?), explanation scope undefined.

---

## Instructions

### Phase 1: Target Identification

Determine what to explain:

| Target | Approach |
|--------|----------|
| Function | Purpose, params, return, usage |
| Class | Responsibility, methods, patterns |
| Module | Purpose, exports, dependencies |
| Flow | Step-by-step execution |
| Pattern | Why used, how it works |

### Phase 2: Context Gathering

Gather context for comprehensive explanation:

1. **Read the code** - Understand what it does
2. **Find usage** - How is it called?
3. **Check dependencies** - What does it depend on?
4. **Identify patterns** - What design patterns are used?

### Phase 3: Explanation Generation

Structure the explanation:

```markdown
## {Code Element} Explanation

### Purpose
{What this code does and why it exists}

### How It Works
{Step-by-step walkthrough}

### Key Concepts
- **{Concept 1}**: {Explanation}
- **{Concept 2}**: {Explanation}

### Example Usage
```{language}
{example code showing how to use it}
```

### Related Code
- `{related_file}` - {relationship}

### Notes
- {Important considerations}
- {Edge cases}
```

### Phase 4: Learning Prompts

Suggest follow-up learning:

```json
{
  "questions": [{
    "question": "What would you like to explore next?",
    "header": "Learn",
    "options": [
      {"label": "Related patterns", "description": "Explain patterns used here"},
      {"label": "Usage examples", "description": "Show more examples"},
      {"label": "Dive deeper", "description": "Explain implementation details"},
      {"label": "Done", "description": "Explanation complete"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Explanation Levels

### Beginner
- Simple language
- More analogies
- Basic concepts first
- Step-by-step detail

### Intermediate
- Technical terms with explanations
- Pattern identification
- Trade-offs discussed
- Connection to principles

### Advanced
- Concise technical explanation
- Architecture implications
- Performance considerations
- Alternative approaches

## Explanation Templates

### Function Explanation
```markdown
## Function: {name}

**Purpose**: {one-liner}

**Signature**: `{function signature}`

**Parameters**:
- `{param}`: {type} - {description}

**Returns**: {type} - {description}

**Example**:
```{lang}
{example}
```

**How it works**:
1. {Step 1}
2. {Step 2}
```

### Pattern Explanation
```markdown
## Pattern: {name}

**Category**: {Creational/Structural/Behavioral}

**Problem it solves**: {problem}

**How it works**: {mechanism}

**In this codebase**: {where used and why}
```

<critical_rules>

## Critical Rules

1. **Clarity First** - Understandable beats comprehensive
2. **Progressive Depth** - Start simple, add detail
3. **Use Examples** - Show, don't just tell
4. **Connect Concepts** - Link to related code

</critical_rules>

## Decision Making

**Explain more when**:
- User asks follow-up
- Concept is complex
- Multiple patterns involved

**Keep brief when**:
- Simple code
- User seems experienced
- Straightforward logic

<decision_making>

</decision_making>

<success_criteria>

## Success Criteria

- [ ] Code understood
- [ ] Explanation clear
- [ ] Examples provided
- [ ] Learning prompts offered

</success_criteria>

## References

- @core-docs/patterns/ - Design patterns
- @core-docs/principles/solid.md - SOLID principles
