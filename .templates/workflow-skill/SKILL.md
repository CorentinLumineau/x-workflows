---
name: x-__NAME__
description: __DESCRIPTION__
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "<task description>"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# /x-__NAME__

> __DESCRIPTION__

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | TODO: APEX or ONESHOT |
| **Phase** | TODO: phase name |
| **Position** | TODO: N of M |

**Flow**: TODO: `previous` → **`x-__NAME__`** → `next`

## Intention

**Task**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "TODO: What question to ask?"
{{/if}}

## Behavioral Skills

This skill activates:
- TODO: List behavioral skills (e.g., `interview`, `code-quality`)

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| TODO | TODO | TODO |

<instructions>

### Phase 1: TODO

TODO: Define implementation phases.

### Phase 2: TODO

TODO: Next phase.

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | TODO |
| **High** | ASK IF ABLE | TODO |
| **Medium** | ASK IF UNCERTAIN | TODO |
| **Low** | PROCEED | TODO |

## Workflow Chaining

**Next Verb**: TODO: `/x-next`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| TODO | TODO | TODO |

## Success Criteria

- [ ] TODO: Define success criteria
- [ ] TODO: All quality gates pass
- [ ] TODO: No regressions

## References

- TODO: @skills/category-skill/ - Description
