---
name: x-ask
description: Use when you have a question about the codebase, a library, or need quick factual answers.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob WebFetch WebSearch
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# /x-ask

> Ask anything. Get a sourced answer.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | complete (self-contained) |
| **Position** | Standalone |

**Flow**: **`x-ask`** → `[optional: x-research deep | x-troubleshoot | x-implement]`

> **Why UTILITY?** Unlike x-research (BRAINSTORM workflow, multi-phase investigation), x-ask is self-contained and instant — no sequential flow, no PRD output, no story files. It parallels x-help and git-create-commit: ask a question, get an answer, done.

## Intention

**Question**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to know?"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0, lightweight bypass)
- `context-awareness` - Project context loading

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Codebase questions | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library/framework documentation |
| `sequential-thinking` | Complex reasoning (compare, analyze) |

<instructions>

### Phase 0: Confidence Check (Lightweight)

For UTILITY workflow, interview check can be bypassed when:
- Question is clear and specific
- Single topic, no ambiguity
- No implementation action needed

Activate `@skills/interview/` only if:
- Question is vague or multi-part
- Multiple interpretations possible

### Phase 1: Question Classification

Classify the question to select the right tool:

| Type | Signal | Approach |
|------|--------|----------|
| **Codebase** | "how does", "where is", file/component names, "this project" | codebase explorer agent |
| **Library** | Named framework/library, API usage, "how to use" | Context7 MCP |
| **External** | "latest", dates, external services, current events | WebSearch + WebFetch |
| **Reasoning** | "compare", "trade-offs", "pros and cons", "should I" | Sequential Thinking |
| **Knowledge** | Concepts, definitions, best practices, patterns | Direct answer + knowledge skills |

### Phase 2: Answer Generation

#### For Codebase Questions

<agent-delegate subagent="codebase explorer" context="Codebase questions requiring file search and pattern discovery">
Delegate to a codebase explorer agent for fast, read-only codebase investigation.
</agent-delegate>

Delegate to a **codebase explorer** agent (fast, read-only):
> "Find code related to {topic}. Report file paths, key functions, and patterns."

Then synthesize the explorer's findings into a direct answer.

#### For Library Questions

<doc-query library="$DETECTED_LIBRARY" topic="$QUESTION">
Use Context7 MCP for authoritative library documentation: resolve-library-id then query-docs.
</doc-query>

Use Context7 for authoritative documentation:

```
1. resolve-library-id → get library ID
2. query-docs → get relevant documentation
3. Synthesize into answer with code examples
```

#### For External Information

<web-research query="$QUESTION" sources="WebSearch,WebFetch">
Use WebSearch for current information, then WebFetch for detail extraction with source attribution.
</web-research>

Use WebSearch for current information, then WebFetch for detail:

```
1. WebSearch → find relevant sources
2. WebFetch → extract specific information
3. Synthesize with source attribution
```

#### For Complex Reasoning

Use Sequential Thinking MCP for structured multi-step analysis:

```
sequentialthinking({
  thought: "Dimension 1: {aspect} — {analysis}",
  thoughtNumber: 1,
  totalThoughts: 3,
  nextThoughtNeeded: true
})
// Repeat for each dimension, then synthesize
```

Pattern:
1. Break question into comparison dimensions
2. Analyze each dimension as a sequential thought
3. Synthesize into recommendation with trade-offs

#### For General Knowledge

Answer directly, referencing knowledge skills:

```
1. Draw from relevant @skills/ knowledge
2. Provide concise explanation
3. Reference authoritative sources
```

### Phase 3: Structured Answer

Deliver the answer in this format:

```markdown
## Answer

{Direct answer to the question — lead with the answer, not the explanation}

### Details

{Supporting context, code examples, or explanation as needed}

### Sources

- {file:line references for code}
- {URLs for web sources}
- {Library docs via Context7}
```

**Adaptive depth**:
- Simple questions → 2-3 sentence answer, no Details section needed
- Medium questions → Answer + Details with examples
- Complex questions → Full structured response

### Phase 4: Follow-up

Offer contextual next steps:

```json
{
  "questions": [{
    "question": "Does this answer your question?",
    "header": "Follow-up",
    "options": [
      {"label": "Yes, thanks", "description": "Question answered"},
      {"label": "Explain more", "description": "Need deeper explanation"},
      {"label": "Different question", "description": "Ask something else"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Transition to implementation |
| **High** | ASK IF ABLE | Scope expansion to research |
| **Medium** | ASK IF UNCERTAIN | Multiple valid answers |
| **Low** | PROCEED | Direct answer delivery |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: What was found
2. **Options**: Answer as-is, dig deeper, or ask differently
3. **Recommendation**: Based on question complexity
4. **Escape**: "Ask different question" option

</human-approval-framework>

## Agent Delegation (Summary)

**Recommended Agent**: **codebase explorer** (for codebase questions)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Codebase search needed | Simple lookup or concept |
| Pattern discovery | Library docs (use Context7) |
| Multi-file investigation | Direct knowledge answer |

## Workflow Chaining

**Next Verbs**: Escalation-only (x-ask is self-contained)

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "dig deeper" | `/x-research deep` | No (suggest) |
| Debug question | `/x-troubleshoot` | No (suggest) |
| "help me build this" | `/x-implement` | No (suggest) |
| "plan this" | `/x-plan` | No (suggest) |

<chaining-instruction>

After answering, if the user needs more:
- "Need comprehensive investigation?" → `/x-research deep`
- "Want to debug this?" → `/x-troubleshoot`
- "Ready to implement?" → `/x-plan` or `/x-implement`
- "Another question?" → Stay in `/x-ask`

On escalation, use Skill tool:
- skill: "x-research"
- args: "deep {original question with context}"

</chaining-instruction>

## Answer Guidelines

1. **Answer First** — Lead with the direct answer, then explain
2. **Cite Sources** — Always reference where information came from
3. **Be Accurate** — Verify against code/docs before answering
4. **Appropriate Depth** — Match answer length to question complexity
5. **Know Limits** — Escalate to x-research when depth is insufficient

## Escalation Rules

| Situation | Escalate To |
|-----------|-------------|
| Needs multi-source investigation | `/x-research deep` |
| Debugging/error analysis | `/x-troubleshoot` |
| Implementation needed | `/x-implement` |
| Architecture decision | `/x-design` |
| Comprehensive comparison | `/x-research assess` |

## Critical Rules

1. **Speed First** — Minimal overhead, answer quickly
2. **Direct Answers** — No preamble, lead with the answer
3. **Source Everything** — Always cite references
4. **Escalate Complexity** — Don't struggle, route to x-research

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Escalate | `/x-research` | Needs deep investigation |
| Escalate | `/x-troubleshoot` | It's a debugging question |
| Exit to APEX | `/x-plan` | Ready to build (approval) |

## Success Criteria

- [ ] Question classified correctly
- [ ] Right tool selected for question type
- [ ] Direct answer provided
- [ ] Sources cited
- [ ] Follow-up offered
- [ ] Escalation suggested if appropriate

## References

- @skills/context-awareness/ - Project context loading
- @skills/meta-analysis/ - Analysis and prioritization
