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

### Skip Tracking (Feedback Loop)

When interview is bypassed via "explicit skip" (condition 1):

Write skip event to Memory MCP entity `"interview-state"`:
- `"interview_skip: {skill}, user said: {reason} at {timestamp}"`

**Adaptive Behavior**: On future invocations for the same skill:
- If ≥ 3 skips recorded for same skill → reduce interview aggressiveness (ask 1 question max)
- Log: "Interview adapted: {skill} marked as user-preferred-skip ({count} skips)"
- User can always request full re-interview by saying "full interview"

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

## State Persistence (3-Layer)

Interview state uses the 3-layer persistence model:

### Write (after each interview completion)

1. **L1: File** — Write to `.claude/interview-state.json`:
   ```json
   {
     "version": "1.0",
     "sessions": [
       {
         "skill": "x-plan",
         "timestamp": "2026-02-10T14:00:00Z",
         "expiresAt": "2026-02-11T14:00:00Z",
         "confidence": {
           "problem_understanding": 95,
           "context_completeness": 90,
           "technical_clarity": 100,
           "scope_definition": 85,
           "risk_awareness": 90,
           "composite": 92
         },
         "questions_asked": 3,
         "bypassed": false
       }
     ]
   }
   ```

   **TTL Rule**: Always set `expiresAt` to `timestamp + 24 hours` on each session entry.

2. **L2: Auto-memory** — Update MEMORY.md only if a persistent user preference is discovered:
   ```
   ## Interview Patterns
   - User prefers: {preference}
   - Common clarification needed: {pattern}
   ```

3. **L3: MCP Memory** — Write to Memory MCP entity `"interview-state"`:
   ```
   add_observations:
     entityName: "interview-state"
     contents:
       - "skill: {name}, confidence: {score}, questions: {count}, at: {timestamp}"
   ```

### Read (on interview activation)

1. Check conversation context (same session)
2. Read `.claude/interview-state.json`
   a. **TTL enforcement**: Check `expiresAt` on each session entry
   b. Remove expired entries (where `expiresAt < now`)
   c. If all entries expired → delete the file entirely
   d. If valid entries remain → write back pruned file, use as baseline
3. Search Memory MCP: `search_nodes("interview-state")`
   a. Remove observations older than 24 hours via `delete_observations`
4. Use most recent valid data as baseline

### Smart Bypass (Historical Confidence)

When interview state exists for the **same skill + similar context**:

```
Previous interview: x-plan at 92% confidence (3 questions ago)
Same context detected. Start at 80% baseline instead of 0%.
```

**Rules**:
- Smart bypass raises the **starting baseline**, reducing questions needed
- 100% confidence is **still required** to proceed (safety preserved)
- Baseline formula: `min(80, previous_composite * 0.85)`
- Only applies when: same skill AND context similarity > 70%
- User can always request full re-interview

Benefits:
- Cross-session continuity
- Audit trail of decisions
- Preventing re-asking validated questions
- Faster warmup for repeat contexts

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
