---
name: x-team
description: Use when a task is large enough to benefit from multiple agents working in parallel.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent. Claude Code Agent Teams provides the richest multi-agent experience.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# /x-team

> Spawn and orchestrate Agent Teams for complex parallel tasks.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | orchestration |
| **Position** | standalone (spawns parallel workflows) |

**Flow**: `/x-team` prompt → team spawned → teammates execute → results synthesized

## Intention

**Task**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What task should the agent team work on?"
{{/if}}

## Prerequisites

Agent Teams must be enabled in settings:
```json
{
  "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" },
  "teammateMode": "auto"
}
```

## Platform Notes

| Platform | Team Support | Notes |
|----------|-------------|-------|
| Claude Code | Full (Agent Teams) | Native multi-agent coordination with shared task lists |
| Cursor | Partial | Sequential delegation via skill chaining |
| Cline | Partial | Sequential delegation via skill chaining |
| skills.sh | Partial | Script-based coordination |

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `complexity-detection` - Task parallelizability assessment
- `agent-awareness` - Agent capability catalog

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Team composition decisions |
| `memory` | Cross-session team pattern recall |

<instructions>

### Phase 0: Confidence Check

<workflow-gate options="use-teams,use-subagents,cancel" default="use-teams">
Determine if task benefits from Agent Teams (multi-agent coordination) or if subagents suffice.
</workflow-gate>

Activate `@skills/interview/` if:
- Task scope is unclear
- Unsure if task benefits from parallelism
- Team composition is ambiguous

**Gate**: Does this task benefit from Agent Teams?

| Signal | Use Agent Teams | Use Subagents Instead |
|--------|----------------|----------------------|
| Teammates need to discuss | Yes | No |
| Multiple independent explorations | Yes | No |
| Cross-layer coordination needed | Yes | No |
| Only result matters, not discussion | No | Yes |
| Simple focused subtask | No | Yes |
| Sequential dependencies | No | Yes |

If subagents are better, suggest using `/x-implement` or `/x-analyze` with their built-in agent delegation instead.

### Phase 1: Task Analysis

<deep-think purpose="team composition" context="Analyzing task for parallelizability, team size, coordination needs, and risk level">
Reason about: independent work streams, optimal team size (2-5), coordination requirements, teammate model selection, and file ownership boundaries.
</deep-think>

Analyze the prompt to determine:

1. **Parallelizability** — Can the work be split into independent streams?
2. **Team size** — How many teammates are optimal? (2-5 recommended)
3. **Coordination needs** — Do teammates need to share findings?
4. **Risk level** — Should teammates require plan approval?

### Phase 2: Team Pattern Selection

Select the best pattern for the task. See `references/team-patterns.md` for detailed templates.

| Pattern | When | Team Size | Key Trait |
|---------|------|-----------|-----------|
| **Research** | Investigation, exploration | 2-4 | Adversarial debate |
| **Feature** | Building new functionality | 2-3 | File ownership |
| **Review** | Code review, audit | 2-3 | Different lenses |
| **Debug** | Competing hypotheses | 3-5 | Theory testing |
| **Refactor** | Large restructuring | 2-3 | Module ownership |

### Phase 3: Team Creation

Instruct Claude to create the Agent Team using natural language. Structure the instruction as:

```
Create an agent team for: {task summary}

Spawn {N} teammates:
- {Role 1}: "{detailed spawn prompt with context, scope, and deliverable}"
- {Role 2}: "{detailed spawn prompt with context, scope, and deliverable}"
[...]

Team rules:
- {coordination rules from selected pattern}
- Each teammate should use /x-{appropriate-verb} for their work
- {plan approval requirements if high-risk}

When all teammates finish, synthesize their findings and present a unified result.
```

**Spawn prompt best practices:**
- Include full task context (teammates don't inherit conversation history)
- Specify the files or modules each teammate owns (avoid conflicts)
- Reference project conventions and CLAUDE.md
- Assign a clear deliverable per teammate
- Suggest which `/x-*` workflow each teammate should follow

### Phase 4: Coordination Mode

Based on task risk, configure the team lead behavior:

| Risk | Delegate Mode | Plan Approval | Monitoring |
|------|--------------|---------------|------------|
| Low | Optional | No | Light check-ins |
| Medium | Recommended | For risky teammates | Regular check-ins |
| High | Required | All teammates | Active steering |

**Delegate mode** (Shift+Tab): Restricts the lead to coordination only — no direct code changes. Recommended for complex tasks where the lead should focus on orchestrating.

### Phase 5: Monitoring & Synthesis

Guide the user on monitoring the team:

**In-process mode:**
- `Shift+Up/Down` — Navigate between teammates
- `Enter` — View a teammate's session
- `Escape` — Interrupt a teammate
- `Ctrl+T` — Toggle task list

**Split-pane mode (tmux):**
- Click into any pane to interact directly
- Each teammate has full terminal visibility

**Synthesis checklist:**
- [ ] All teammates have completed their tasks
- [ ] Findings have been aggregated
- [ ] Conflicts between teammates resolved
- [ ] Final result presented to user
- [ ] Team cleaned up (`Clean up the team`)

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Team composition before spawning |
| **High** | ASK IF ABLE | Model selection per teammate |
| **Medium** | ASK IF UNCERTAIN | Delegate mode on/off |
| **Low** | PROCEED | Standard pattern application |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Task analysis and selected team pattern
2. **Options**: Team compositions with role descriptions
3. **Recommendation**: Best pattern with rationale
4. **Escape**: "Use subagents instead" or "Handle sequentially"

**CRITICAL**: Team composition must be approved before spawning teammates.

</human-approval-framework>

## Workflow Chaining

**Next Verb**: Depends on team output

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| Team produces code | `/x-verify` | No (suggest) |
| Team produces plan | `/x-implement` | No (suggest) |
| Team produces review | `/git-commit` | No (suggest) |
| Team cleanup done | (end) | Yes |

<chaining-instruction>

When team work is complete:
"Agent team has completed. Results synthesized."
- Option 1: `/x-verify` - Verify the team's output
- Option 2: `/git-commit` - Commit the changes
- Option 3: Stop - Review results first

</chaining-instruction>

## Token Considerations

Agent Teams use significantly more tokens than single sessions:
- Each teammate is a **full Claude Code instance**
- Token usage scales linearly with team size (3 teammates ≈ 3-4x tokens)
- Use the minimum team size that achieves parallelism

### Model Selection per Teammate

Choose the cheapest model that fits the task. **Never use Opus for teammates** — reserve it for the lead session only.

| Teammate Role | Model | Cost | When |
|---------------|-------|------|------|
| Explorer, search, grep | **Haiku** | Lowest | Read-only codebase navigation, finding files, understanding structure |
| Test writer, test runner | **Haiku** | Lowest | Writing tests, running validation, coverage checks |
| Doc writer, changelog | **Haiku** | Lowest | Generating documentation, updating READMEs |
| Simple/focused implementation | **Haiku** | Lowest | Single-file changes, clear requirements, boilerplate |
| Complex implementation | **Sonnet** | Medium | Multi-file features, architectural decisions |
| Security/performance review | **Sonnet** | Medium | Domain expertise, nuanced analysis |
| Debugging, hypothesis testing | **Sonnet** | Medium | Complex reasoning, root cause analysis |
| Refactoring | **Sonnet** | Medium | Safe restructuring, SOLID enforcement |

**Rule of thumb**: If the teammate's task could be done by a junior dev following clear instructions → Haiku. If it requires senior-level judgment → Sonnet.

## Critical Rules

1. **Verify parallelizability** — Don't use teams for sequential tasks
2. **Avoid file conflicts** — Each teammate must own different files
3. **Include full context** — Teammates don't inherit conversation history
4. **Size appropriately** — 2-5 teammates; more adds overhead without benefit
5. **Clean up** — Always clean up the team when done
6. **Monitor actively** — Don't let teammates run unattended too long

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Alternative | `/x-implement` | Task doesn't need parallelism |
| Alternative | `/x-analyze` | Need analysis before teaming |
| After | `/x-verify` | Verify team output |
| After | `/git-commit` | Commit team changes |

## Related Verbs

- `/x-plan` — Plan before spawning (for complex tasks)
- `/x-implement` — Single-session implementation (simpler tasks)
- `/x-analyze` — Analyze codebase before splitting work

## Success Criteria

- [ ] Task analyzed for parallelizability
- [ ] Team pattern selected and approved
- [ ] Teammates spawned with detailed prompts
- [ ] File ownership assigned (no conflicts)
- [ ] Results synthesized
- [ ] Team cleaned up

## When to Load References

- **For team composition templates**: See `references/team-patterns.md`

## References

- @skills/orchestration/ - Subagent orchestration patterns (complementary)
- @skills/agent-awareness/ - Agent capability catalog
- @skills/complexity-detection/ - Task complexity assessment
