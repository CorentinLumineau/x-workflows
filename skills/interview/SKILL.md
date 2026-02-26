---
name: interview
description: Use when about to take a significant action needing confirmation. Confidence gate with human-in-the-loop validation.
version: "2.0.0"
category: behavioral
metadata:
  author: ccsetup contributors
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

1. **ASK** - Targeted question for lowest-confidence dimension **using an interactive gate** (see Question-Type Mapping below)
2. **DOCUMENT** - Record answer in interview state
3. **RESEARCH** - Context7, codebase, web based on answer content
4. **SYNTHESIZE** - Update confidence scores, reformulate if > 80%

### Question-Type → Gate Mapping

Every question in the ASK step **MUST** use a `<workflow-gate>` interactive gate. The gate format depends on the question type:

| Question Type | Gate Pattern | Example |
|---------------|-------------|---------|
| **Discrete choices** (design decisions, scope, type selection) | `<workflow-gate>` with concrete `<option>` elements | "Which approach?" → options: A, B, C |
| **Multi-select** (labels, features to include) | `<workflow-gate type="multi">` with enumerable options | "Which areas affected?" → options list |
| **Free-form input** (descriptions, error messages) | `<workflow-gate>` with descriptive option stubs + "Other" fallback | "What error?" → common patterns as options |
| **Simple confirmation** (reformulation validation) | `<workflow-gate>` with approve/reject options | "Is this correct?" → Yes / No / Partially |

### Anti-Pattern: Prose-Text Questions

**VIOLATION**: Outputting questions as plain text prose instead of using interactive gates.

```
❌ WRONG — plain text question:
   "What approach should we take? We could do A, B, or C."

✅ CORRECT — interactive gate with structured options:
   <workflow-gate type="choice" id="approach-selection">
     <question>What approach should we take?</question>
     <header>Approach</header>
     <option key="a"><label>Option A</label><description>First approach</description></option>
     <option key="b"><label>Option B</label><description>Second approach</description></option>
   </workflow-gate>
```

**Why this matters**: Plain text questions are easily missed by users, provide no structured input mechanism, and cannot be tracked for confidence scoring. Interactive gates create explicit decision points that ensure the user actively makes a choice.

## Previously Assessed Dimensions

When receiving a routing context from complexity-detection with confidence >= 70%:
- Start overlapping dimensions at baseline 80% instead of 0%
- Skip re-asking questions whose answers are already captured in the routing context
- Only probe dimensions where complexity-detection expressed low confidence or ambiguity
- Always allow the user to override any pre-assessed value

This avoids redundant questioning when the decision engine has already classified the task.

## When to Load References

- **For adaptive dimension scoring and workflow-specific weights**: See `references/confidence-model.md`
- **For context7/codebase/web research protocol between questions**: See `references/research-loop.md`
- **For 3-format validation templates (checklist, prose, visual)**: See `references/reformulation-templates.md`
- **For per-workflow trigger conditions and activation thresholds**: See `references/triggers-matrix.md`
- **For bypass rules and when interview can be skipped**: See `references/bypass-conditions.md`

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The scope is obvious" | Obvious to whom? The user's mental model may differ from yours. Ask. |
| "I already know the answer" | Knowing the answer doesn't mean the user agrees. Confirm anyway. |
| "This is too simple to ask about" | Simple tasks with wrong assumptions create complex rework. |
| "The user seems impatient" | A 10-second question prevents a 10-minute redo. Users prefer accuracy. |

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

Write skip event to `.claude/interview-state.json`:
- Add to the session entry: `"skipped": true, "skip_reason": "{reason}"`

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

## State Persistence (2-Layer)

Interview state uses the 2-layer persistence model:

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

### Read (on interview activation)

1. Check conversation context (same session)
2. Read `.claude/interview-state.json`
   a. **TTL enforcement**: Check `expiresAt` on each session entry
   b. Remove expired entries (where `expiresAt < now`)
   c. If all entries expired → delete the file entirely
   d. If valid entries remain → write back pruned file, use as baseline
3. Use most recent valid data as baseline

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
