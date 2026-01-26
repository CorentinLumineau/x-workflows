# Mode: ask

> **Invocation**: `/x-research` or `/x-research ask`
> **Legacy Command**: `/x:ask`

<purpose>
Intelligent Q&A - answers questions about the project, libraries, or anything else with context awareness.
</purpose>

## Behavioral Skills

This mode activates:
- `context-awareness` - Project context

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Codebase questions | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library documentation |

<instructions>

## Instructions

### Phase 1: Question Classification

Classify the question:

| Type | Example | Approach |
|------|---------|----------|
| Project | "How does auth work?" | Read code |
| Library | "How to use React hooks?" | Context7 |
| Concept | "What is SOLID?" | Knowledge |
| Debug | "Why is this failing?" | → Debug mode |

### Phase 2: Answer Generation

#### For Project Questions
Use x-explorer to find relevant code:

```
Task(
  subagent_type: "ccsetup:x-explorer",
  model: "haiku",
  prompt: "Find code related to {topic}"
)
```

#### For Library Questions
Use Context7:

```javascript
mcp__context7__resolve_library_id({
  libraryName: "{library}",
  query: "{question}"
})

mcp__context7__query_docs({
  libraryId: "{id}",
  query: "{question}"
})
```

#### For Concepts
Answer from knowledge, with references to core-docs.

### Phase 3: Structured Answer

```markdown
## Answer

{Direct answer to the question}

### Details

{Explanation with context}

### Example

{Code example if applicable}

### References

- {Reference 1}
- {Reference 2}
```

### Phase 4: Follow-up

```json
{
  "questions": [{
    "question": "Does this answer your question?",
    "header": "Follow-up",
    "options": [
      {"label": "Yes, thanks", "description": "Question answered"},
      {"label": "Explain more", "description": "Need more detail"},
      {"label": "Different question", "description": "Ask something else"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

<decision_making>

## Answer Guidelines

- **Direct**: Answer the question first
- **Concise**: Don't over-explain
- **Accurate**: Verify against code/docs
- **Helpful**: Provide next steps if useful

## When to Escalate

- Complex investigation → `/x-troubleshoot`
- Multi-source research → `/x-research deep`
- Implementation help → `/x-implement`

</decision_making>

<critical_rules>

1. **Answer First** - Direct answer, then details
2. **Cite Sources** - Reference code or docs
3. **Be Accurate** - Verify before answering
4. **Know Limits** - Escalate when appropriate

</critical_rules>

## References

- @core-docs/mcp/context7.md - Documentation lookup

<success_criteria>

- [ ] Question understood
- [ ] Answer provided
- [ ] Sources cited
- [ ] Follow-up offered

</success_criteria>
