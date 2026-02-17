---
name: orchestration
description: Parallel workflow coordination for batch operations. Auto-triggered when batch detection identifies >5 similar items.
license: Apache-2.0
allowed-tools: Read, Grep, Glob
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
  user-invocable: false
triggers:
  - batch_operation_detected
  - parallel_execution_needed
  - multi_phase_workflow
---

# Orchestration

> Coordinate parallel agent execution for multi-phase workflows.

Behavioral skill that auto-activates when batch operations are detected. Prevents sequential bottlenecks that cause session truncation by spawning background agents for independent work streams.

## Purpose

Based on usage analysis showing 66 sessions with truncation friction due to sequential processing of large batches. This skill:

1. **Detects parallelizable work** → Identifies independent phases
2. **Spawns background agents** → Concurrent execution
3. **Coordinates results** → Aggregates findings
4. **Checkpoints progress** → Enables recovery

## Activation Triggers

| Trigger | Description | Auto? |
|---------|-------------|-------|
| **Batch >5 items** | complexity-detection flags batch | Yes |
| **Create + Review** | Independent phases detected | Yes |
| **Implement + Test** | Parallelizable work | Yes |
| **Multiple fixes** | Independent fix targets | Yes |

## Orchestration Patterns

### Pattern 1: Parallel Review (Auto-triggered)

When creating multiple items, spawn reviewer in background:

```
1. Create items 1-3
2. Delegate to a **code reviewer** agent (quality analysis) in background:
   > "Review items 1-3 for quality and security"
3. Continue creating items 4-6
4. Collect agent responses
5. Aggregate review findings
6. Apply fixes before next batch
```

### Pattern 2: Parallel Testing (Auto-triggered)

When implementing features, spawn tester concurrently:

```
1. Implement feature A
2. Delegate to a **test runner** agent (can edit and run commands) in background:
   > "Run tests for feature A"
3. Continue implementing feature B
4. Check test results
5. Fix any failures before proceeding
```

### Pattern 3: Batch Workers (Manual)

For very large batches, spawn parallel workers:

```
1. Split items into batches of 3-5
2. For each batch (up to 3 parallel):
   Delegate to a **batch worker** agent in background:
   > "Process batch {n}: {items}"
3. Monitor agent progress
4. Checkpoint completed batches to Memory MCP
5. Aggregate results when all complete
```

## Coordination Protocol

### State Tracking

Track all spawned agents:

```yaml
orchestration_state:
  main_task: "{description}"
  spawned_agents:
    - id: "{agent_1}"
      type: "x-reviewer"
      status: "running|completed|failed"
      batch: 1
    - id: "{agent_2}"
      type: "x-tester"
      status: "running"
      batch: 2
  completed_batches: [1]
  pending_batches: [2, 3, 4]
```

### Checkpoint Integration

Save orchestration state to Memory MCP:

```yaml
# Save to Memory MCP (or equivalent persistence)
entity:
  name: "orchestration-{timestamp}"
  type: "OrchestrationCheckpoint"
  observations:
    - "task: {main_task}"
    - "total_batches: {count}"
    - "completed_batches: [{list}]"
    - "active_agents: [{agent_ids}]"
    - "pending_work: [{items}]"
    - "status: in_progress"
```

### Result Aggregation

When background agents complete:

1. Read agent results (non-blocking check)
2. Aggregate findings across all agents
3. Prioritize issues by severity (CRITICAL first)
4. Apply fixes in severity order
5. Update checkpoint with aggregated state

### Checkpoint Cleanup

After orchestration completes (all batches done or workflow ends):

1. **Delete orchestration checkpoint**: Remove the `orchestration-{timestamp}` entity from Memory MCP via `delete_entities`
2. **Prune delegation-log**: Remove detailed batch observations, keep only the summary line (task, total agents, outcome, duration)
3. **Update status**: Final checkpoint update with `"status: completed"` before deletion

```yaml
# Cleanup call
delete_entities:
  entityNames: ["orchestration-{timestamp}"]
```

**Graceful degradation**: If Memory MCP is unavailable, skip cleanup — entities will be pruned by git-commit's Phase 5 cleanup sweep.

## Integration with Workflow Skills

### With complexity-detection

```
complexity-detection detects batch (>5 items)
        ↓
orchestration skill activates
        ↓
Identifies parallelizable phases
        ↓
Suggests or auto-spawns background agents
```

### With x-implement

```
x-implement (batch mode)
        ↓
orchestration: spawn code reviewer after batch 1
        ↓
Continue creating while review runs
        ↓
Aggregate and apply fixes
```

### With x-plan

```
x-plan (large task, auto-batched)
        ↓
orchestration: tag parallelizable batches
        ↓
x-implement uses tags for parallel execution
```

## Output Format

When orchestration is active, display status:

```
## Orchestration Active

### Spawned Agents
| Agent | Type | Batch | Status |
|-------|------|-------|--------|
| agent-1 | x-reviewer | 1-3 | ✓ Complete |
| agent-2 | x-tester | 1-3 | Running... |

### Progress
- Batches: 1/4 complete
- Items: 3/14 processed
- Checkpoint: orchestration-{id}

### Aggregated Issues
- Critical: 0
- High: 2 (from review)
- Medium: 5
```

## Delegation History Logging

When orchestration spawns agents, record each delegation:

### On Spawn

Write to Memory MCP entity `"delegation-log"`:
```
add_observations:
  entityName: "delegation-log"
  contents:
    - "delegation: {agent} ({model}) for {task_type} [{complexity}] -> pending at {timestamp}"
```

### On Completion

Update the delegation record:
```
add_observations:
  entityName: "delegation-log"
  contents:
    - "delegation: {agent} ({model}) for {task_type} [{complexity}] -> {outcome} ({duration_ms}ms) at {timestamp}"
```

Where `outcome` is: `success`, `failure`, `escalated`, or `timeout`.

### Summary to Auto-Memory

After delegation completes, write a summary line to MEMORY.md:
```
## Delegation Patterns
- Delegation: {agent} ({model}) for {task_type} -> {outcome} ({duration_ms}ms)
```

Only write to MEMORY.md when the delegation reveals a **pattern** (e.g., same agent type succeeding/failing repeatedly).

## Automated Variant Escalation

When a spawned agent returns an insufficient result, orchestration auto-escalates using the agent-awareness escalation table.

### Auto-Escalation Protocol

```
Spawned agent completes
        ↓
Outcome == "insufficient"? ── No → Continue normally
        ↓ Yes
Lookup escalation target from @skills/agent-awareness/ Escalation Table
        ↓
Target found? ── No → Log failure, continue with other agents
        ↓ Yes
Already escalated once for this task? ── Yes → Log, report to user
        ↓ No
1. Log escalation in delegation-log (Memory MCP)
2. Re-delegate task to upgraded variant
3. Continue orchestration with upgraded agent
4. On upgraded agent completion → aggregate normally
```

### Escalation State Tracking

Track escalations in orchestration state:

```yaml
orchestration_state:
  escalations:
    - original_agent: "x-tester-fast"
      escalated_to: "x-tester"
      reason: "tests still failing after fix attempt"
      task_batch: 1
      timestamp: "{ISO}"
```

### Insufficient Result Detection

| Agent Type | Insufficient Signal |
|------------|---------------------|
| Test runners | Tests still failing (exit code != 0) |
| Reviewers | Issues flagged but no actionable analysis |
| Explorers | Returned "not found" or minimal context |
| Debuggers | Exhausted hypotheses without root cause |

## Behavioral Rules

1. **Auto-activate on batch detection** - No manual invocation needed
2. **Checkpoint before spawn** - Save state before spawning agents
3. **Monitor all agents** - Check status regularly
4. **Aggregate results** - Combine findings from parallel work
5. **Fail gracefully** - If agent fails, continue with others
6. **Severity first** - Process critical issues immediately
7. **Log all delegations** - Record every agent spawn and outcome
8. **Auto-escalate on failure** - Use variant escalation table, max 1 per delegation

## When NOT to Activate

| Scenario | Reason |
|----------|--------|
| Single item | No parallelization benefit |
| <5 items | Sequential is fine |
| Dependent items | Must be sequential |
| Quick fixes | Overhead not worth it |

## When to Escalate to Agent Teams

Orchestration uses subagents by default. Escalate to Agent Teams when subagent delegation is insufficient.

### Escalation Triggers

| Condition | Action | Team Pattern |
|-----------|--------|-------------|
| Batch >5 items AND items have cross-dependencies | Suggest team | Feature Team or Refactor Team |
| Subagents would benefit from inter-agent communication | Suggest team | Based on complexity-detection Team field |
| Multiple subagents need shared intermediate results | Suggest team | Debug Team or Research Team |

### Subagents vs Teams

| Characteristic | Subagents (default) | Agent Teams (escalated) |
|---------------|---------------------|------------------------|
| Task coupling | Independent, no shared state | Interdependent, shared task list |
| Communication | Result-only (TaskOutput) | Bidirectional (SendMessage) |
| Coordination | Fire-and-forget or sequential | Task dependencies, blocking |
| Best for | Batch processing, parallel review | Multi-domain features, debugging |

### Escalation Protocol

1. **Read complexity-detection Team field** — if `Team: none`, use subagents
2. **If Team pattern suggested** — advisory only, present option to user
3. **Never auto-spawn teams** — teams require explicit user confirmation or command invocation (e.g., `/x-team`)
4. **Fallback** — if team tools unavailable (no `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`), continue with subagent delegation

## References

- @skills/complexity-detection/ - Batch detection patterns
- @skills/interview/ - Batch question integration
- @skills/agent-awareness/ - Team composition patterns and model selection
