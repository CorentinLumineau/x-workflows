# Memory Patterns for Initiative Skill

> Reference for Memory MCP entity patterns

## Entity Naming Conventions

### Initiative Entities

```
initiative_{name}
├── type: "initiative"
├── observations:
│   ├── "status: active|completed|archived"
│   ├── "priority: P0|P1|P2|P3"
│   ├── "started: YYYY-MM-DD"
│   └── "milestones: M1,M2,M3..."
```

### Phase/Milestone Entities

```
phase_{initiative}_{milestone}
├── type: "phase"
├── observations:
│   ├── "status: pending|in_progress|completed"
│   ├── "tasks: 5/10 complete"
│   └── "blockers: none|description"
```

### Checkpoint Entity

```
checkpoint
├── type: "checkpoint"
├── observations:
│   ├── "initiative: {name}"
│   ├── "phase: M2"
│   ├── "task: Implement skill 3"
│   ├── "state: In progress, 60% complete"
│   └── "next: Finish MEMORY.md, then validate"
```

## Memory Operations

### Session Start

```
read_memory()
└── Look for: checkpoint, current_phase, initiative_*
└── Build context: What was I doing?
└── Resume: Continue from checkpoint
```

### Progress Update

```
write_memory("task_2.3", "completed")
write_memory("phase_skills_M1", "tasks: 3/3 complete")
```

### Checkpoint (Every 30min or major milestone)

```
write_memory("checkpoint", {
  initiative: "skills-integration-2025",
  phase: "M1",
  task: "Creating initiative skill",
  state: "2/3 skills complete",
  next: "Create MEMORY.md reference"
})
```

### Session End

```
write_memory("session_summary", {
  date: "2025-12-05",
  accomplished: ["context-awareness", "code-quality", "initiative skills"],
  next_session: "Start M2: testing, debugging, analysis"
})
```

## Relations

```
initiative_skills_2025 --has_phase--> phase_skills_M1
phase_skills_M1 --has_task--> task_context_awareness
phase_skills_M1 --has_task--> task_code_quality
phase_skills_M1 --has_task--> task_initiative
```

## Best Practices

1. **Consistent naming** - Use underscores, lowercase
2. **Atomic updates** - Update after each completed task
3. **Regular checkpoints** - Every 30 minutes or major milestone
4. **Clear next steps** - Always note what comes next
5. **Clean up** - Remove stale entries after initiative complete
