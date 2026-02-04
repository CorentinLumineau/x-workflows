---
name: interview
description: Universal confidence gate ensuring human-in-the-loop before any significant action.
category: behavioral
user-invocable: false
triggers:
  - ambiguity_detected
  - missing_information
  - high_risk_action
  - confidence_below_100
---

# Interview

> **Zero-Doubt Policy**: Never act with uncertainty.

Universal behavioral skill that enforces human-in-the-loop across ALL workflows whenever the agent has any doubt. The agent must reach 100% confidence before taking any significant action.

## Philosophy

Traditional workflows assume the agent understands the request. This behavioral skill inverts that assumption: **assume nothing, verify everything**. The agent must prove its understanding through structured questioning, research, and reformulation before proceeding.

## Activation Triggers

| Trigger | Description | Examples |
|---------|-------------|----------|
| **Ambiguity** | Multiple valid interpretations | "Make it better", "Fix the issue", "Improve performance" |
| **Missing Info** | Required data not provided | No error message, no file path, no version specified |
| **High Risk** | Irreversible or significant impact | Production deploy, version bump, data deletion |
| **Low Confidence** | Agent self-assessment < 100% | Complex decision, unfamiliar pattern, conflicting requirements |

## Core Loop

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌───────────┐
│   ASK   │───→│ DOCUMENT │───→│ RESEARCH │───→│ SYNTHESIZE│
└─────────┘    └──────────┘    └──────────┘    └───────────┘
     ↑                                               │
     └───────────────────────────────────────────────┘
                    (until 100% confidence)
```

1. **ASK** - Targeted question for lowest-confidence dimension
2. **DOCUMENT** - Record answer in interview state
3. **RESEARCH** - Context7, codebase, web based on answer content
4. **SYNTHESIZE** - Update confidence scores, reformulate if > 80%

## References

| Reference | Purpose |
|-----------|---------|
| [confidence-model.md](references/confidence-model.md) | Adaptive dimension scoring with workflow weights |
| [research-loop.md](references/research-loop.md) | Research protocol between questions |
| [reformulation-templates.md](references/reformulation-templates.md) | 3-format validation templates |
| [triggers-matrix.md](references/triggers-matrix.md) | Per-workflow trigger conditions |
| [bypass-conditions.md](references/bypass-conditions.md) | When interview is not needed |

## Templates

| Template | Purpose |
|----------|---------|
| [interview-state-schema.md](templates/interview-state-schema.md) | JSON persistence schema |

## Bypass Conditions

Interview can be bypassed (with warning logged) when:

1. **Explicit skip** - User says "skip interview" (logged with warning)
2. **Trivial action** - Single-line fix with clear error message
3. **Already interviewed** - State shows complete for this exact topic
4. **Continuation** - Resuming previous validated work

See [bypass-conditions.md](references/bypass-conditions.md) for details.

## Integration Pattern

All workflow modes include Phase 0:

```markdown
### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score for this workflow
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1
```

## State Persistence

Interview state is persisted to `.claude/interview-state.json` for:

- Cross-session continuity
- Audit trail of decisions
- Preventing re-asking validated questions

## Example Flow

```
User: "Fix the login issue"

Interview activates (ambiguity: which issue?):
├─ Q1: "What error are you seeing?" → Research: Codebase auth patterns
├─ Q2: "Which browser/environment?" → Update context confidence
├─ Q3: "When did this start happening?" → Research: Recent commits
├─ Confidence 85% → Reformulation
├─ "So users get a 401 error on Chrome after the March deploy, correct?"
├─ User: "Yes, exactly"
├─ Confidence = 100%
└─ → Workflow proceeds
```
