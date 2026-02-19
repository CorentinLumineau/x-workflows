---
name: permission-awareness
description: Use when workflow must adapt to the current permission mode. Detects runtime permissions and adjusts tool usage.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
  user-invocable: false
---

# Permission Awareness

Detect runtime permission mode and adapt workflow behavior for safe tool usage.

## Purpose

Detect the current permission mode (default, acceptEdits, bypassPermissions) and adapt workflow behavior. Ensures skills request appropriate permissions and handle CI environments correctly.

This behavioral skill prevents permission-related failures by detecting what operations are allowed in the current context and adapting workflow execution accordingly.

---

## Activation Triggers

| Trigger | Condition |
|---------|-----------|
| Phase transitions | Before any phase that requires elevated permissions |
| Tool capability check | Before using tools that may need permission |
| CI detection | When headless environment detected |

Permission awareness activates automatically at workflow phase boundaries to ensure upcoming operations are allowed.

---

## Permission Modes

| Mode | Behavior | Tools Auto-Approved | Best For |
|------|----------|---------------------|----------|
| **default** | Prompt for each action | Read, Grep, Glob | Interactive development |
| **acceptEdits** | Auto-approve file edits | + Write, Edit | Active coding session |
| **bypassPermissions** | All tools approved | All tools | CI/CD, automation |

### Permission Hierarchy

```
default ⊂ acceptEdits ⊂ bypassPermissions

default:
  Allowed: Read, Grep, Glob
  Requires permission: Write, Edit, Bash, git commands

acceptEdits:
  Allowed: Read, Grep, Glob, Write, Edit
  Requires permission: Bash, git commands, destructive operations

bypassPermissions:
  Allowed: All tools
  Note: Still subject to allowed-tools whitelist in skill frontmatter
```

---

## Detection Algorithm

```
1. Check environment variables:
   - CI=true → bypassPermissions expected
   - CLAUDE_PERMISSION_MODE → use that value
   - GITHUB_ACTIONS=true → bypassPermissions
   - GITLAB_CI=true → bypassPermissions

2. If no env var, probe tool behavior:
   - Attempt Write to temp file in .claude/
   - If succeeds without prompt → acceptEdits or bypassPermissions
   - If fails with permission error → default mode
   - Delete temp file after test

3. If Write succeeded, probe Bash:
   - Attempt harmless Bash command: echo "test"
   - If succeeds without prompt → bypassPermissions
   - If fails with permission error → acceptEdits

4. Infer from context (fallback):
   - workclaude invocation → bypassPermissions
   - Interactive terminal session → default or acceptEdits
   - Headless (no TTY) → bypassPermissions

5. Cache detection result in workflow-state.json:
   - Only detect once per session
   - Re-use cached mode for subsequent checks
```

### Detection Example

```
Step 1: Check env
  CI=false, CLAUDE_PERMISSION_MODE=undefined → proceed to step 2

Step 2: Probe Write
  Write to .claude/permission-probe.txt
  Success without prompt → acceptEdits or bypassPermissions

Step 3: Probe Bash
  Bash: echo "permission-test"
  Requires permission prompt → acceptEdits (not bypass)

Result: acceptEdits mode detected
Cache: workflow-state.json → "permission_mode": "acceptEdits"
```

---

## Adaptation Rules

| Workflow Phase | default | acceptEdits | bypassPermissions |
|----------------|---------|-------------|-------------------|
| Read/analyze | ✓ Proceed | ✓ Proceed | ✓ Proceed |
| Edit files | ⚠ Request permission | ✓ Proceed | ✓ Proceed |
| Run commands | ⚠ Request permission | ⚠ Request permission | ✓ Proceed |
| Git operations | ⚠ Request permission | ⚠ Request permission | ✓ Proceed |
| Create/delete files | ⚠ Request permission | ✓ Proceed | ✓ Proceed |
| Network operations | ⚠ Request permission | ⚠ Request permission | ✓ Proceed |

### Adaptation Logic

```
Before each phase:
1. Determine required permission level:
   - READ_ONLY: Read, Grep, Glob
   - FILE_EDIT: Write, Edit
   - COMMAND_EXEC: Bash, git
   - DESTRUCTIVE: rm, git reset --hard

2. Check current mode vs required:
   - If mode >= required → proceed
   - If mode < required → request permission

3. In CI context (bypassPermissions):
   - ALSO check allowed-tools whitelist
   - If tool not in whitelist → skip with warning
   - This prevents accidental destructive ops in CI

4. Cache permission grants:
   - If user approves operation → cache for session
   - Don't re-ask for same operation type
```

---

## CI Context

In CI (bypassPermissions), validate via `allowed-tools` instead:

```
CI Safety Protocol:
1. Detect bypassPermissions mode
2. Read skill frontmatter allowed-tools
3. Before ANY tool use:
   - Check if tool in allowed-tools
   - If not whitelisted → skip with warning
   - Log: "Skipping {tool} in CI (not in allowed-tools)"

4. Never execute tools outside whitelist, even if permissions allow
5. This prevents accidental destructive operations in automated runs
```

### CI-Specific Adaptations

| Scenario | CI Behavior | Interactive Behavior |
|----------|-------------|----------------------|
| Missing optional dependency | Skip with warning | Prompt user to install |
| Tool not in allowed-tools | Skip operation | Request permission |
| Destructive operation | Validate extra carefully | Request confirmation |
| Network timeout | Fail fast (no retry) | Retry with backoff |
| File conflicts | Abort with error | Prompt for resolution |

**Example:**

```
Skill: x-implement
allowed-tools: Read Grep Glob Write Edit

In CI:
  ✓ Read, Grep, Glob, Write, Edit → allowed
  ✗ Bash, git → skipped (not in allowed-tools)
  Result: Files created, but no commit (manual commit required)

In Interactive:
  ✓ Read, Grep, Glob, Write, Edit → allowed
  ⚠ Bash, git → request permission
  Result: Files created + committed (if user approves)
```

---

## Escalation Pattern

When a skill needs higher permissions than current mode:

```
1. Detect required permission for next phase
2. Compare to current mode
3. If current mode insufficient:

   Interactive (default or acceptEdits):
     - Pause workflow
     - Ask user: "This phase requires {permission}. Proceed? (y/n)"
     - Wait for response
     - If approved → cache grant, continue
     - If denied → skip phase or abort workflow

   CI (bypassPermissions):
     - Check tool against allowed-tools
     - If whitelisted → proceed
     - If not whitelisted → log warning, skip phase
     - Never prompt (no user interaction in CI)

4. Never auto-escalate permissions without user consent
5. Log all permission requests and grants
```

### Permission Request Format

```
Interactive request:
┌─────────────────────────────────────────────┐
│ Permission Required                         │
│                                             │
│ Phase: implement                            │
│ Tool: Bash                                  │
│ Operation: Run tests (npm test)            │
│                                             │
│ Current mode: acceptEdits                   │
│ Required mode: bypassPermissions            │
│                                             │
│ Proceed? (y/n)                              │
└─────────────────────────────────────────────┘
```

CI warning:
```
[WARN] Skipping phase: verify
Reason: Tool 'Bash' not in allowed-tools [Read, Grep, Glob, Write, Edit]
Workaround: Run tests manually or add Bash to skill allowed-tools
```

---

## Integration Pattern

permission-awareness is **automatically active** in ALL workflow skills. It checks permissions before each phase and adapts execution accordingly.

### Skill Integration

Workflow skills reference permission-awareness for safe execution:

```markdown
## Permission Requirements

Uses: @skills/permission-awareness/

Minimum mode: acceptEdits (requires file editing)
Optional tools: Bash (for running tests)

If in default mode:
- Will request permission for file edits
- Will skip test execution (Bash not allowed)
```

### Phase Guard Pattern

```
Before each phase:
1. Detect current permission mode (cached or probe)
2. Determine phase requirements:
   - analyze: READ_ONLY
   - plan: READ_ONLY
   - implement: FILE_EDIT
   - verify: COMMAND_EXEC

3. Check mode vs requirement
4. If insufficient:
   - Interactive: request permission
   - CI: skip phase if tool not whitelisted

5. If sufficient or granted:
   - Proceed with phase
   - Cache permission grant
```

---

## References

- @skills/context-awareness/ - CI detection and environment context
- @skills/error-recovery/ - Permission denied error handling
