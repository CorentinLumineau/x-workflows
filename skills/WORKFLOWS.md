# Workflows Reference

> Canonical workflow definitions for x-workflows verb skills.

## Overview

All verb skills operate within one of 4 canonical workflows. Each workflow represents a distinct mental model for approaching work.

| Workflow | Purpose | Verbs | Flow |
|----------|---------|-------|------|
| **APEX** | Systematic build/create | analyze → plan → implement → verify → review → commit | Full development cycle |
| **ONESHOT** | Quick fixes | fix → [verify] → commit | Minimal overhead |
| **DEBUG** | Error resolution | troubleshoot → fix/implement | Investigation-first |
| **BRAINSTORM** | Exploration/research | brainstorm ↔ research → design | Discovery-focused |

---

## APEX Workflow

> **Purpose**: Systematic development for features, enhancements, and complex changes.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           APEX WORKFLOW                                  │
│                                                                          │
│   /x-analyze → /x-plan → /x-implement → /x-verify → /x-review → /x-commit│
│       (A)        (P)         (E)           (X)        (X)                │
│                                                                          │
│                     ↓ (restructure needed)                               │
│              /x-refactor → /x-verify                                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| **A**nalyze | `/x-analyze` | Assess codebase, identify patterns | Start of APEX flow |
| **P**lan | `/x-plan` | Create implementation plan | Analysis complete |
| **E**xecute | `/x-implement` | Write code with TDD | Plan approved |
| **X** (Verify) | `/x-verify` | Run quality gates | Code written |
| **X** (Examine) | `/x-review` | Code review, audits | Tests pass |
| Commit | `/x-commit` | Conventional commit | Review approved |

### Sub-flow: Refactoring

When restructuring is needed during implementation:

```
/x-implement → (needs restructure) → /x-refactor → /x-verify → (continue)
```

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-analyze | x-plan | Analysis complete | Yes |
| x-plan | x-implement | **Plan approved** | **HUMAN APPROVAL** |
| x-implement | x-verify | Code written | Yes |
| x-implement | x-refactor | "restructure needed" | No (ask) |
| x-refactor | x-verify | Refactor complete | Yes |
| x-verify | x-review | Tests pass | Yes |
| x-verify | x-implement | Tests fail | No (show failures) |
| x-review | x-commit | Review approved | Yes |
| x-review | x-implement | Changes requested | No (show feedback) |

### Complexity Triggers

| Complexity | Route |
|------------|-------|
| SIMPLE | x-implement directly |
| MODERATE | x-plan → x-implement |
| COMPLEX | x-initiative → full APEX flow |

---

## ONESHOT Workflow

> **Purpose**: Ultra-fast fixes for trivial changes with minimal overhead.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ONESHOT WORKFLOW                                 │
│                                                                          │
│                    /x-fix → [/x-verify] → /x-commit                      │
│                                                                          │
│   Characteristics:                                                       │
│   - Single file/component                                                │
│   - Clear error with obvious solution                                    │
│   - No cross-layer investigation needed                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| Fix | `/x-fix` | Apply targeted fix | Clear error identified |
| Verify (optional) | `/x-verify` | Quick sanity check | User requests |
| Commit | `/x-commit` | Quick commit | Fix applied |

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-fix | x-verify | "verify first" | No (ask) |
| x-fix | x-commit | **Quick commit** | **HUMAN APPROVAL** |

### Detection Patterns

ONESHOT is triggered when:
- "fix typo", "quick", "simple", "minor"
- "rename", "small change", "trivial"
- Clear error with line number
- Single file affected

### Escalation

If fix turns out to be more complex:

```
/x-fix → (complexity detected) → /x-troubleshoot OR /x-implement
```

---

## DEBUG Workflow

> **Purpose**: Error resolution through systematic investigation.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DEBUG WORKFLOW                                  │
│                                                                          │
│                        /x-troubleshoot                                   │
│                             │                                            │
│                    ┌────────┴────────┐                                   │
│                    ▼                 ▼                                   │
│              (simple fix)     (complex fix)                              │
│                    │                 │                                   │
│                /x-fix          /x-implement                              │
│                    │                 │                                   │
│              /x-commit         (APEX flow)                               │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| Investigate | `/x-troubleshoot` | Hypothesis-driven debugging | Error/issue reported |
| Simple Fix | `/x-fix` | Apply quick fix | Root cause is simple |
| Complex Fix | `/x-implement` | Full implementation | Root cause is complex |

### Debugging Methodology

```
1. Observe  - Gather symptoms, error messages
2. Hypothesize - Form 2-3 potential causes
3. Test - Validate hypotheses systematically
4. Resolve - Apply fix, verify solution
```

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-troubleshoot | x-fix | Simple fix found | Yes |
| x-troubleshoot | x-implement | **Complex fix needed** | **HUMAN APPROVAL** |

### Complexity Detection

| Signal | Tier | Route |
|--------|------|-------|
| Clear error + line number | SIMPLE | x-fix |
| "how does", "trace" | MODERATE | x-troubleshoot |
| "intermittent", "random", "no error" | COMPLEX | x-initiative → x-troubleshoot |

---

## BRAINSTORM Workflow

> **Purpose**: Exploration and discovery before committing to implementation.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       BRAINSTORM WORKFLOW                                │
│                                                                          │
│              /x-brainstorm ←───→ /x-research                             │
│                     │                                                    │
│                     ▼                                                    │
│               /x-design                                                  │
│                     │                                                    │
│            ─────────┴─────────                                           │
│            ▼                 ▼                                           │
│      [Continue]       [Exit to APEX]                                     │
│      Brainstorm         /x-plan                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phases

| Phase | Verb | Description | Entry Conditions |
|-------|------|-------------|------------------|
| Explore | `/x-brainstorm` | Capture ideas, discover requirements | Vague problem space |
| Research | `/x-research` | Deep investigation, gather evidence | Need more information |
| Decide | `/x-design` | Make architectural decisions | Options identified |

### Chaining Rules

| From | To | Trigger | Auto-Chain |
|------|-----|---------|------------|
| x-brainstorm | x-research | "dig deeper" | Yes (within BRAINSTORM) |
| x-brainstorm | x-design | "ready to decide" | Yes (within BRAINSTORM) |
| x-research | x-design | "found answer" | Yes (within BRAINSTORM) |
| x-design | x-plan | **Ready to build** | **HUMAN APPROVAL** |

### Workflow Transitions

**CRITICAL**: Transitioning from BRAINSTORM to APEX requires explicit human approval because it commits to implementation.

```
BRAINSTORM → APEX
     │
     └── Human approval required at /x-design → /x-plan boundary
```

---

## Cross-Workflow Transitions

Some situations require switching between workflows.

| From | To | Approval Required | Reason |
|------|-----|-------------------|--------|
| x-design (BRAINSTORM) | x-plan (APEX) | **YES** | Commits to implementation |
| x-troubleshoot (DEBUG) | x-implement (APEX) | **YES** | Expands scope |
| x-review (APEX) | x-release (UTILITY) | **YES** | Production deployment |
| x-fix (ONESHOT) | x-troubleshoot (DEBUG) | No | Escalation |
| x-fix (ONESHOT) | x-implement (APEX) | No | Escalation |

---

## Human-in-Loop Framework

### When to Ask Human

**Critical (ALWAYS ask)**:
- Workflow transition (e.g., BRAINSTORM → APEX)
- Destructive action (delete, overwrite production)
- Scope expansion beyond original request
- Plan approval before implementation

**High (ASK IF ABLE)**:
- Multiple valid approaches exist
- Architectural decisions
- Skip phase request (e.g., skip verify)

**Medium (ASK IF UNCERTAIN)**:
- Phase transition within workflow
- Confidence < 70%

**Low (PROCEED)**:
- Continue current phase
- Auto-chain within workflow

### Question Structure

When approval is needed, use this structure:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ [Context]: What just happened                                           │
│                                                                          │
│ [Options]:                                                               │
│   1. Option A - description (trade-offs)                                │
│   2. Option B - description (trade-offs)                                │
│   3. Something else                                                      │
│                                                                          │
│ [Recommendation]: Option X because...                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Automatic Workflow Execution

Verb skills auto-chain to their next phase using the Skill tool, reducing manual intervention while preserving human approval at critical gates.

### How Auto-Chaining Works

After each verb skill completes:
1. Updates `.claude/workflow-state.json` (marks current phase complete, sets next in_progress)
2. Checks chaining rules (auto-chain vs. human approval)
3. If auto-chain: invokes next skill via Skill tool with workflow context
4. If human approval: presents approval gate with options

### Chaining Modes

| Mode | Description | Used When |
|------|-------------|-----------|
| **Auto-chain** | Next skill invoked automatically | Low-risk transitions within a workflow |
| **Human approval** | User must confirm before proceeding | Scope expansion, workflow boundary crossing, commits |
| **Terminal** | Workflow ends, no auto-chain | Final phase (x-commit) |

### Complete Chaining Map

| From | To | Mode | Workflow |
|------|-----|------|----------|
| x-analyze | x-plan | Auto-chain | APEX |
| x-plan | x-implement | **Human approval** | APEX |
| x-implement | x-verify | Auto-chain | APEX |
| x-verify | x-review | Auto-chain | APEX |
| x-review | x-commit | Auto-chain (on approval) | APEX |
| x-commit | — | Terminal | APEX |
| x-refactor | x-verify | Auto-chain | APEX (sub-flow) |
| x-fix | x-commit/x-verify | **Human approval** | ONESHOT |
| x-troubleshoot | x-fix | Auto-chain (simple) | DEBUG |
| x-troubleshoot | x-implement | **Human approval** (complex) | DEBUG |
| x-brainstorm | x-research/x-design | Auto-chain | BRAINSTORM |
| x-research | x-design | Auto-chain | BRAINSTORM |
| x-design | x-plan | **Human approval** | BRAINSTORM→APEX |

### Invocation Pattern

Skills invoke the next phase using:
```
skill: "x-{next}"
args: "{workflow context summary}"
```

---

## Workflow State Tracking

All workflows persist their state in `.claude/workflow-state.json` with 3-layer persistence:

### State Layers

| Layer | Location | Purpose |
|-------|----------|---------|
| **L1** | `.claude/workflow-state.json` | Primary file-based state (same-session) |
| **L2** | MEMORY.md (auto-memory) | Cross-session summary |
| **L3** | Memory MCP entity `"workflow-state"` | Cross-session structured data |

### State Schema

```json
{
  "active": {
    "type": "APEX",
    "started": "2026-02-10T14:30:00Z",
    "phases": {
      "analyze": { "status": "completed", "timestamp": "..." },
      "plan": { "status": "completed", "timestamp": "...", "approved": true },
      "implement": { "status": "completed", "timestamp": "..." },
      "verify": { "status": "in_progress" },
      "review": { "status": "pending" },
      "commit": { "status": "pending" }
    }
  },
  "history": []
}
```

### Phase 0b: Pre-Flight Check

Every verb skill includes a Phase 0b that:
1. Reads `.claude/workflow-state.json`
2. Verifies the expected phase matches
3. Warns on phase skipping
4. Creates new workflow state if none exists

---

## Interruption Recovery

If a session ends mid-workflow, the state persists and can be resumed.

### Recovery Flow

```
Session ends mid-workflow
        ↓
State saved in .claude/workflow-state.json (L1)
Checkpoint in Memory MCP (L3)
        ↓
Next session starts
        ↓
context-awareness detects active workflow
        ↓
Offers: "Resume APEX workflow at phase 'verify' (4/6)? [Y/n]"
        ↓
Resume → Continues from last in_progress phase
Start Fresh → Archives current workflow to history
```

### Staleness Warning

If the active workflow is older than 24 hours, context-awareness warns:
```
Active workflow detected (stale — 36h old):
  Type: APEX, Phase: verify (4/6)

Resume anyway? State may be outdated.
```

---

## Verb Quick Reference

### BRAINSTORM Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-brainstorm` | BRAINSTORM.explore | Idea capture, requirements discovery |
| `/x-research` | BRAINSTORM.deep-explore | Deep investigation, evidence gathering |
| `/x-design` | BRAINSTORM.action | Architectural decisions |

### APEX Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-analyze` | APEX.analyze | Codebase assessment |
| `/x-plan` | APEX.plan | Implementation planning |
| `/x-implement` | APEX.execute | TDD implementation |
| `/x-refactor` | APEX.restructure | Safe restructuring |
| `/x-verify` | APEX.test | Quality gates |
| `/x-review` | APEX.examine | Code review, audits |

### ONESHOT Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-fix` | ONESHOT.complete | Quick targeted fix |

### DEBUG Verbs

| Verb | Workflow.Phase | Purpose |
|------|----------------|---------|
| `/x-troubleshoot` | DEBUG.complete | Hypothesis-driven debugging |

### UTILITY Verbs

| Verb | Purpose |
|------|---------|
| `/x-ask` | Zero-friction Q&A |
| `/x-commit` | Conventional commits |
| `/x-release` | Release workflow |
| `/x-docs` | Documentation management |
| `/x-help` | Command reference |

### UNCHANGED Skills

| Skill | Type | Notes |
|-------|------|-------|
| `x-ask` | Utility | Zero-friction Q&A |
| `x-initiative` | Utility | Multi-session tracking |
| `x-setup` | Utility | Project initialization |
| `x-create` | Utility | Skill/agent creation |
| `x-prompt` | Utility | Prompt enhancement |
| `interview` | Behavioral | Confidence gate (auto-triggered) |
| `complexity-detection` | Behavioral | Routing logic (auto-triggered) |

---

## Semantic Markers DSL Reference

> Agent-agnostic markers that platform adapters compile into native tool instructions.

Skills use XML-like semantic markers to declare tool interactions. These markers are **agent-agnostic** — they describe *intent* rather than specific tool calls. Platform adapters (e.g., ccsetup for Claude Code) compile markers into native instructions during skill sync.

**Key principle**: Markers **supplement** prose, they don't replace it. All prose descriptions remain valid fallback behavior on platforms without a compilation adapter.

### Marker Vocabulary (9 markers, 4 tiers)

#### Tier 1: Interaction & Orchestration

These markers enable workflow transitions and agent collaboration. Without compilation, Claude Code may not reliably invoke the correct tools.

**`<workflow-gate>`** — Human Decision Point

```xml
<workflow-gate type="choice" id="unique-id">
  <question>Question text presented to user</question>
  <header>Short header (max 12 chars)</header>
  <option key="option-key" recommended="true">
    <label>Display label (1-5 words)</label>
    <description>What this option does</description>
  </option>
  <!-- 2-4 options required -->
</workflow-gate>
```

| Attribute | Required | Description |
|-----------|----------|-------------|
| `type` | Yes | `choice` or `approval` |
| `id` | Yes | Unique identifier for this gate |
| `option.key` | Yes | Key referenced by `<workflow-chain on="">` |
| `option.recommended` | No | `"true"` marks the recommended option |
| `option.approval` | No | `"required"` for critical transitions |

**`<workflow-chain>`** — Skill Invocation (self-closing)

```xml
<workflow-chain on="option-key" skill="x-skill-name" args="{context}" />
<workflow-chain on="stop" action="end" />
```

| Attribute | Required | Description |
|-----------|----------|-------------|
| `on` | Yes | Matches `<workflow-gate>` option key |
| `skill` | Conditional | Skill to invoke (required unless `action="end"`) |
| `args` | No | Arguments passed to the skill |
| `action` | No | `"end"` to terminate workflow without chaining |

**`<agent-delegate>`** — Subagent Spawn

```xml
<agent-delegate role="role name" subagent="agent-id" model="model">
  <prompt>Task description for the agent</prompt>
  <context>Additional context to pass</context>
</agent-delegate>
```

| Attribute | Required | Description |
|-----------|----------|-------------|
| `role` | Yes | Abstract role (resolved by adapter's agent mapping) |
| `subagent` | No | Explicit agent ID override |
| `model` | No | Model override (`sonnet`, `haiku`, `opus`) |

**Standard Agent Role Mapping:**

| Role | Default Agent | Model |
|------|--------------|-------|
| code reviewer | x-reviewer | sonnet |
| codebase explorer | x-explorer | haiku |
| test runner | x-tester | sonnet |
| debugger | x-debugger | sonnet |
| refactoring agent | x-refactorer | sonnet |
| documentation writer | x-doc-writer | sonnet |
| designer | x-designer | opus |
| security reviewer | x-security-reviewer | sonnet |
| deep debugger | x-debugger-deep | opus |
| fast tester | x-tester-fast | haiku |
| quick reviewer | x-reviewer-quick | haiku |

#### Tier 2: MCP & Reasoning

These markers work via prose but compilation improves reliability by generating explicit tool references.

**`<deep-think>`** — Complex Reasoning (sequential-thinking MCP)

```xml
<deep-think trigger="when-to-trigger">
  <purpose>What to reason about</purpose>
  <context>Additional reasoning context</context>
</deep-think>
```

**`<doc-query>`** — Library Documentation (context7 MCP)

```xml
<doc-query trigger="when-to-trigger">
  <purpose>What documentation to look up</purpose>
  <context>Additional lookup context</context>
</doc-query>
```

#### Tier 3: State & Resources

These markers standardize inconsistent patterns across skills.

**`<state-checkpoint>`** — Workflow State Persistence

```xml
<state-checkpoint phase="phase-name" status="completed">
  <file path=".claude/workflow-state.json">Description of state update</file>
  <memory entity="workflow-state">Key-value state summary</memory>
</state-checkpoint>
```

**`<web-research>`** — External Research

```xml
<web-research trigger="when-to-trigger">
  <purpose>What to research</purpose>
  <strategy>Research approach description</strategy>
</web-research>
```

**`<state-cleanup>`** — Terminal Phase Cleanup

```xml
<state-cleanup phase="terminal">
  <delete path=".claude/workflow-state.json" condition="no-active-workflows" />
  <memory-prune entities="pattern-*" older-than="7d" />
  <history-prune max-entries="5" />
</state-cleanup>
```

#### Tier 4: Platform-Native

These markers compile to platform-specific features and are no-ops on unsupported platforms.

**`<plan-mode>`** — Read-Only Planning Sandbox

```xml
<plan-mode phase="exploration" trigger="after-interview">
  <enter>When and why to enter read-only mode</enter>
  <scope>What phases run inside plan mode</scope>
  <exit trigger="exit-condition">What happens at exit</exit>
</plan-mode>
```

| Platform | `<plan-mode>` behavior |
|----------|----------------------|
| Claude Code | Compiles to `EnterPlanMode`/`ExitPlanMode` (read-only sandbox) |
| Cursor | No-op (prose preserved as fallback) |
| Cline | No-op (prose preserved as fallback) |
| skills.sh | No-op (prose preserved as fallback) |

### Marker Usage Rules

1. **Supplement, don't replace**: Always keep prose descriptions alongside markers. Markers enhance behavior on supported platforms; prose ensures functionality everywhere.
2. **One gate, many chains**: A `<workflow-gate>` should be followed by `<workflow-chain>` entries matching each option key.
3. **Roles over IDs**: In `<agent-delegate>`, prefer `role` over `subagent`. Adapters resolve roles using their agent mapping tables.
4. **State consistency**: Every skill that modifies workflow state should use `<state-checkpoint>`. Only terminal skills use `<state-cleanup>`.
5. **Idempotent compilation**: Source files always copied fresh before transform. Never modify source files with compiled output.

### Adapter Compilation Notes

Adapters (like ccsetup) compile markers during their sync pipeline:

```
Source repo (markers) → copy to adapter → transform in-place → generate registry
```

The reference adapter (ccsetup) uses `tool-mapping.json` to define how each marker maps to Claude Code tools. Other adapters can define their own mappings for their target platforms.

---

## Agent Teams

Agent Teams are a cross-cutting platform capability available to all workflows. Teams enable true parallel coordination between multiple agents with inter-agent messaging and shared task lists.

### When Teams Trigger

Teams are advisory, triggered by the complexity-detection `Team` field:

| Complexity-Detection Output | Meaning |
|-----------------------------|---------|
| `Team: none` | Use subagents or direct execution (default) |
| `Team: Research Team (2 agents)` | Suggest spawning a research team |
| `Team: Feature Team (3 agents)` | Suggest spawning a feature team |

Teams never auto-spawn. They require user confirmation or explicit `/x-team` invocation.

### Relationship to Subagent Delegation

Teams are an escalation path from subagents, not a replacement:

```
Subagent delegation (default)
        ↓ escalate when
   - Items have cross-dependencies
   - Agents need to communicate
   - Shared intermediate results needed
        ↓
Agent Teams (coordinated)
```

### Team Lifecycle Within Workflows

```
1. Spawn   → TeamCreate + Task (per teammate)
2. Assign  → TaskCreate + TaskUpdate(owner)
3. Work    → Teammates execute, SendMessage for coordination
4. Collect → TaskList to check progress, TaskOutput for results
5. Shutdown → SendMessage(shutdown_request) per teammate + TeamDelete
```

### Per-Workflow Team Patterns

| Workflow | Team Pattern | Use Case |
|----------|-------------|----------|
| **APEX** | Feature Team | Multi-layer implementations with parallel testing and review |
| **DEBUG** | Debug Team | Parallel hypothesis testing across different system layers |
| **BRAINSTORM** | Research Team | Multi-perspective exploration with evidence synthesis |
| **ONESHOT** | none | Too lightweight for team overhead |

See @skills/agent-awareness/ for team composition details and @skills/x-team/references/team-patterns.md for spawn templates.

---

## Version

**Version**: 3.0.0 (x-workflows)
**Compatibility**: ccsetup 6.6.0+
**Changes**: Added semantic markers DSL (9 markers, 4 tiers), agent role mapping table, adapter compilation notes
