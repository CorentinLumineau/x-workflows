# Mode: orchestrate

> **Invocation**: `/x-orchestrate` or `/x-orchestrate orchestrate`
> **Legacy Command**: `/x:orchestrate`

<purpose>
Start a guided workflow with human-first checkpoints at every transition. Multi-command sequences with user approval at each step.
</purpose>

## Behavioral Skills

This mode activates:
- `context-awareness` - Project context

<instructions>

## Instructions

### Phase 1: Workflow Selection

Present available workflows:

```json
{
  "questions": [{
    "question": "Which workflow would you like to run?",
    "header": "Workflow",
    "options": [
      {"label": "Full Feature", "description": "brainstorm → plan → design → implement → verify → review → commit"},
      {"label": "Standard Feature", "description": "plan → implement → verify → commit"},
      {"label": "Bug Fix", "description": "debug → fix → verify → commit"},
      {"label": "Refactor", "description": "analyze → refactor → verify → commit"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 2: Workflow Initialization

Initialize workflow state:

```yaml
# .claude/WORKFLOW-STATUS.yaml
workflow: {selected_workflow}
current_step: 1
total_steps: {count}
started: {timestamp}
steps:
  - name: {step_1}
    status: pending
  - name: {step_2}
    status: pending
```

### Phase 3: Step Execution

For each step:

1. **Announce** - Display current step
2. **Execute** - Run the skill
3. **Checkpoint** - Ask to continue
4. **Update** - Mark step complete

```markdown
## Workflow: {name}

**Step {n}/{total}**: {step_name}

Executing...
```

After step completion:
```json
{
  "questions": [{
    "question": "Step {n}/{total} complete. Continue to {next_step}?",
    "header": "Continue",
    "options": [
      {"label": "Continue (Recommended)", "description": "Proceed to {next_step}"},
      {"label": "Stop here", "description": "Pause workflow"},
      {"label": "Skip next", "description": "Skip {next_step}"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 4: Workflow Completion

On completion:

```markdown
## Workflow Complete ✅

**Workflow**: {name}
**Steps Completed**: {completed}/{total}
**Duration**: {time}

### Steps
- [x] {step_1} ✅
- [x] {step_2} ✅
- [x] {step_3} ✅
```

## Available Workflows

| Workflow | Steps | When |
|----------|-------|------|
| Full Feature | 7 | Complex features |
| Standard Feature | 4 | Normal features |
| Bug Fix | 4 | Bug fixing |
| Refactor | 4 | Code cleanup |
| Release | 3 | Publishing |

## Workflow Details

### Full Feature
1. `/x-plan brainstorm` - Requirements
2. `/x-plan` - Implementation plan
3. `/x-plan design` - Architecture
4. `/x-implement` - Build feature
5. `/x-verify` - Quality gates
6. `/x-review` - Code review
7. `/x-git commit` - Commit changes

### Bug Fix
1. `/x-troubleshoot debug` - Investigation
2. `/x-implement fix` - Apply fix
3. `/x-verify` - Quality gates
4. `/x-git commit` - Commit fix

</instructions>

<critical_rules>

1. **Human First** - Always checkpoint
2. **Pausable** - Can stop anytime
3. **Resumable** - Can continue later
4. **Skipable** - Can skip steps

</critical_rules>

<success_criteria>

- [ ] Workflow selected
- [ ] Each step executed
- [ ] Checkpoints honored
- [ ] Workflow completed or paused

</success_criteria>

## References

- @core-docs/tools/task.md - Task and agent management
