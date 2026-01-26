# Mode: background

> **Invocation**: `/x-orchestrate background` or `/x-orchestrate background`
> **Legacy Command**: `/x:background`

<purpose>
Background task management - list, check status, and retrieve output from async agents.
</purpose>

<instructions>

## Instructions

### Phase 1: Task Discovery

List running background tasks:

```bash
# Find background processes
# Check .claude/tasks/ for task files
```

Display task list:

```markdown
## Background Tasks

| ID | Type | Status | Started | Description |
|----|------|--------|---------|-------------|
| {id} | {agent} | {status} | {time} | {desc} |

### Statuses
- 🟢 Complete
- 🟡 Running
- 🔴 Failed
```

### Phase 2: Task Operations

```json
{
  "questions": [{
    "question": "What would you like to do?",
    "header": "Action",
    "options": [
      {"label": "Check task output", "description": "View specific task result"},
      {"label": "Wait for completion", "description": "Block until task done"},
      {"label": "Kill task", "description": "Stop a running task"},
      {"label": "Done", "description": "Nothing more"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 3: Task Operations

#### Check Output
```javascript
TaskOutput({
  task_id: "{id}",
  block: false,
  timeout: 5000
})
```

#### Wait for Completion
```javascript
TaskOutput({
  task_id: "{id}",
  block: true,
  timeout: 60000
})
```

#### Kill Task
```javascript
KillShell({
  shell_id: "{id}"
})
```

### Phase 4: Report Output

```markdown
## Task Output: {id}

**Status**: {status}
**Duration**: {time}

### Output
```
{task_output}
```

### Next Steps
{recommendations based on output}
```

## Task States

| State | Meaning |
|-------|---------|
| `pending` | Queued, not started |
| `running` | Currently executing |
| `completed` | Finished successfully |
| `failed` | Finished with error |
| `killed` | Manually terminated |

## Common Operations

### Monitor Multiple Tasks
Check multiple tasks in parallel, report status.

### Retrieve Results
Get output from completed tasks for further processing.

### Cleanup
Kill stale tasks, clean up task files.

</instructions>

<critical_rules>

1. **Non-Blocking** - Default to non-blocking checks
2. **Timeout Aware** - Set appropriate timeouts
3. **Clean Up** - Remove stale tasks
4. **Report Clearly** - Show task state clearly

</critical_rules>

<success_criteria>

- [ ] Tasks listed
- [ ] Status displayed
- [ ] Operations executed
- [ ] Results reported

</success_criteria>

## References

- @core-docs/tools/task.md - Task tool usage
