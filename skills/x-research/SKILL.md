---
name: x-research
description: Intelligent Q&A and comprehensive research with evidence-based methodology.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash WebFetch WebSearch
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# /x-research

> Investigate topics thoroughly with evidence-based methodology.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | BRAINSTORM |
| **Phase** | deep-explore |
| **Position** | 2 of 3 in workflow |

**Flow**: `x-brainstorm` ↔ **`x-research`** → `x-design`

## Intention

**Question**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to research?"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Codebase investigation | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library documentation |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Research scope too broad
- Multiple interpretations possible
- Success criteria undefined

### Phase 1: Scope Definition

Determine research depth:

| Mode | Depth | Output |
|------|-------|--------|
| Deep | Comprehensive investigation | PRD/analysis document |

> **Quick Q&A**: For simple questions, use `/x-ask` instead. This skill is for comprehensive research.

### Phase 2: Information Gathering

**For deep research:**
```
1. Define research scope
2. Gather information from multiple sources
3. Analyze and synthesize
4. Create structured output (PRD/report)
5. Include recommendations
```

### Phase 3: Source Verification

Apply evidence-based principles:

| Principle | Description |
|-----------|-------------|
| Cite sources | Reference documentation and code |
| Verify claims | Test assumptions against code |
| Multiple sources | Cross-reference information |
| Clear uncertainty | State when unsure |

### Phase 4: Output Generation

**Quick Answer Format:**
```markdown
**Answer**: [Direct answer]

**Sources**:
- [file/doc reference]
- [code reference]
```

**Deep Research Format:**
```markdown
# Research: [Topic]

## Executive Summary
[Key findings in 2-3 sentences]

## Findings
[Detailed findings organized by theme]

## Analysis
[Synthesis and interpretation]

## Recommendations
[Actionable next steps]

## Sources
[All references cited]
```

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Exit to implementation |
| **High** | ASK IF ABLE | Scope expansion |
| **Medium** | ASK IF UNCERTAIN | Research depth |
| **Low** | PROCEED | Continue research |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: What was found
2. **Options**: Continue research, take action, or refine scope
3. **Recommendation**: Based on findings
4. **Escape**: "Ask different question" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **codebase explorer** (codebase investigation)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large codebase search | Simple questions |
| Pattern analysis | Direct lookup |

## Workflow Chaining

**Next Verbs**: `/x-design`, `/x-brainstorm`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "found answer" | `/x-design` | No (suggest) |
| "need to explore more" | `/x-brainstorm` | No (suggest) |
| "ready to build" | `/x-plan` | **HUMAN APPROVAL** |

<chaining-instruction>

**Auto-chain**: research → design (within BRAINSTORM, no approval needed)

After research complete with clear findings:
1. Update `.claude/workflow-state.json` (mark research complete, set design in_progress)
2. Auto-invoke next skill via Skill tool:
   - skill: "x-design"
   - args: "{research findings and recommendations}"

On incomplete or branching research (manual):
"Research complete. What's next?"
- Option 1: `/x-design` (Recommended) - Make architectural decisions
- Option 2: `/x-brainstorm` - Explore more options
- Option 3: `/x-plan` - Start APEX workflow (requires approval)
- Option 4: Done - Research complete

**CRITICAL**: Direct transition to `/x-plan` crosses the BRAINSTORM → APEX boundary and requires human approval.

</chaining-instruction>

## Research Approaches

| Approach | When |
|----------|------|
| Codebase search | Implementation questions |
| Documentation lookup | API/library questions |
| Web search | Best practices, external info |
| Context7 | Library-specific docs |

## Evidence-Based Principles

1. **Cite sources** - Reference documentation and code
2. **Verify claims** - Test assumptions against code
3. **Multiple sources** - Cross-reference information
4. **Clear uncertainty** - State when unsure

## Critical Rules

1. **Be Evidence-Based** - Support claims with references
2. **State Uncertainty** - Don't pretend to know
3. **Appropriate Depth** - Match effort to question
4. **Cite Sources** - Always reference where info came from

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-brainstorm` | Need broader exploration |
| Next | `/x-design` | Ready for decisions |
| Exit to APEX | `/x-plan` | Ready to build (approval) |

## Success Criteria

- [ ] Question clearly understood
- [ ] Sources identified and verified
- [ ] Answer is evidence-based
- [ ] Uncertainty noted where applicable
- [ ] Appropriate depth achieved

## When to Load References

- **For quick Q&A**: Use `/x-ask` (standalone skill)
- **For deep research**: See `references/mode-deep.md`

## References

- @skills/meta-analysis/ - Analysis and prioritization
