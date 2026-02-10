---
name: orchestration
description: Parallel workflow coordination for batch operations. Auto-triggered when batch detection identifies >5 similar items.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Task, TaskOutput, Read, Grep, Glob
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
4. Check reviewer status via TaskOutput
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
   Task(
     subagent_type: "appropriate-agent",
     run_in_background: true,
     prompt: "Process batch {n}: {items}"
   )
3. Monitor all workers via TaskOutput
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
    - id: "{task_id_1}"
      type: "x-reviewer"
      status: "running|completed|failed"
      batch: 1
    - id: "{task_id_2}"
      type: "x-tester"
      status: "running"
      batch: 2
  completed_batches: [1]
  pending_batches: [2, 3, 4]
```

### Checkpoint Integration

Save orchestration state to Memory MCP:

```
mcp__memory__create_entities({
  entities: [{
    name: "orchestration-{timestamp}",
    entityType: "OrchestrationCheckpoint",
    observations: [
      "task: {main_task}",
      "total_batches: {count}",
      "completed_batches: [{list}]",
      "active_agents: [{agent_ids}]",
      "pending_work: [{items}]",
      "status: in_progress"
    ]
  }]
})
```

### Result Aggregation

When background agents complete:

1. Read results via `TaskOutput(task_id: "{id}", block: false)`
2. Aggregate findings across all agents
3. Prioritize issues by severity (CRITICAL first)
4. Apply fixes in severity order
5. Update checkpoint with aggregated state

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
| task-123 | x-reviewer | 1-3 | ✓ Complete |
| task-456 | x-tester | 1-3 | Running... |

### Progress
- Batches: 1/4 complete
- Items: 3/14 processed
- Checkpoint: orchestration-{id}

### Aggregated Issues
- Critical: 0
- High: 2 (from review)
- Medium: 5
```

## Behavioral Rules

1. **Auto-activate on batch detection** - No manual invocation needed
2. **Checkpoint before spawn** - Save state before spawning agents
3. **Monitor all agents** - Check status regularly
4. **Aggregate results** - Combine findings from parallel work
5. **Fail gracefully** - If agent fails, continue with others
6. **Severity first** - Process critical issues immediately

## When NOT to Activate

| Scenario | Reason |
|----------|--------|
| Single item | No parallelization benefit |
| <5 items | Sequential is fine |
| Dependent items | Must be sequential |
| Quick fixes | Overhead not worth it |

## References

- @skills/complexity-detection/ - Batch detection patterns
- @skills/interview/ - Batch question integration
