---
name: config-awareness
description: Detects .claude/ configuration gaps and suggests rules, skills, hooks. Auto-triggers on session start when gaps detected.
version: "1.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: ccsetup contributors
  category: behavioral
---

# Config Awareness

Detect `.claude/` configuration gaps in projects and suggest enhancements (rules, agents, skills, hooks, output styles).

## Purpose

Provide configuration gap detection and enhancement suggestions for projects that install the ccsetup plugin. Follows the `{noun}-awareness` pattern: forge-awareness detects forges, agent-awareness suggests agents, config-awareness suggests `.claude/` enhancements.

This behavioral skill:
1. Scans the existing `.claude/` directory structure
2. Analyzes the project's tech stack from dependency files
3. Cross-references what exists vs. what should exist
4. Presents ranked, non-intrusive suggestions with template-based creation

<!-- COMPILED: hook-trigger -> Hook event documentation (Claude Code only) -->
**Hook Integration** -- This workflow triggers Claude Code hooks:
- **Event**: `SessionStart` via `setup.js`
- **Action**: detectConfigContext() scans .claude/ directory, counts rules, identifies tech stack, outputs compact context string

---

## Activation Triggers

| Trigger | Condition | Timing |
|---------|-----------|--------|
| Session start | detectConfigContext() signals gaps | After setup.js hook |
| On demand | User asks about project configuration | When requested |
| Dependency change | package.json/requirements.txt mtime change | When detected by context-awareness |

config-awareness activates automatically when `.claude/` configuration gaps are detected.

---

## Phase 1: Configuration Inventory

<!-- COMPILED: context-query -> ccsetup-context MCP -->
**Call MCP tool** `mcp__plugin_ccsetup_ccsetup-context__project_context` (no params).
Use the returned JSON for project stack detection and environment context.

**Fallback** (if MCP unavailable):

Scan the `.claude/` directory structure:

```
1. Check `.claude/` directory exists
2. Count files in `.claude/rules/`
3. Check for CLAUDE.md (project-level)
4. Check for `.claude/settings.json` or `.claude/settings.local.json`
5. List existing hooks in `.claude/hooks/` or via hooks.json
```

### Inventory Schema

```json
{
  "config_inventory": {
    "claude_dir_exists": true,
    "rules_count": 3,
    "has_claudemd": true,
    "has_settings": false,
    "has_hooks": true,
    "hook_count": 2,
    "existing_rules": ["security.md", "testing.md", "git.md"],
    "scanned_at": "ISO-8601"
  }
}
```

---

## Phase 2: Project Analysis

Detect the project's tech stack from dependency and configuration files:

```
1. Read package.json -> extract framework deps
   - Frontend: React, Vue, Angular, Svelte, Solid
   - Backend: Express, Fastify, Hono, Koa, NestJS, Next.js
   - Test runners: Jest, Vitest, Mocha, Playwright, Cypress

2. Read requirements.txt / pyproject.toml -> Python frameworks
   - Django, Flask, FastAPI, Starlette

3. Detect ORM/DB tools
   - Prisma, TypeORM, Sequelize, Drizzle (package.json)
   - SQLAlchemy, Tortoise-ORM (requirements.txt)

4. Detect monorepo signals
   - workspaces in package.json
   - pnpm-workspace.yaml
   - nx.json, turbo.json, lerna.json

5. Detect security-sensitive directories
   - auth/, security/, crypto/, middleware/

6. Detect TypeScript
   - tsconfig.json exists
```

### Project Analysis Schema

```json
{
  "project_analysis": {
    "frameworks": ["express", "react"],
    "test_runners": ["jest"],
    "orms": ["prisma"],
    "is_monorepo": false,
    "has_typescript": true,
    "security_dirs": ["src/auth/", "src/middleware/"],
    "analyzed_at": "ISO-8601"
  }
}
```

---

## Phase 3: Gap Analysis

Cross-reference inventory (what exists) vs. project analysis (what should exist) to generate ranked suggestions.

> See [references/detection-signals.md](references/detection-signals.md) for the full signal-to-suggestion mapping with priorities.

### Gap Detection Algorithm

```
For each detection signal in priority order:
  1. Check if signal condition is met (e.g., Jest detected in package.json)
  2. Check if corresponding rule already exists in .claude/rules/
  3. If signal met AND no matching rule -> add to suggestions list
  4. Assign priority from detection-signals reference (HIGH, MEDIUM, LOW)
  5. Sort suggestions: HIGH first, then MEDIUM, then LOW
```

### Deduplication Rules

- If a rule file name contains the suggestion keyword, skip (e.g., `testing.md` exists -> skip `testing-jest`)
- If CLAUDE.md already documents a convention, skip the matching suggestion
- If a `.claude/settings.json` exists with relevant config, skip that suggestion

---

## Phase 4: Suggestion Presentation

Present suggestions as a numbered list, ranked by priority (HIGH first). Keep it non-intrusive:

```
Config suggestions for this project:
1. [HIGH] No .claude/rules/ directory -- Bootstrap rules structure
2. [HIGH] Auth module detected but no security rules -- Add security review rule
3. [MEDIUM] Jest detected but no testing conventions -- Add testing conventions rule
4. [MEDIUM] Express API detected -- Add API design conventions
5. [LOW] No output style configured -- Configure output style
Choose numbers to apply, "all" for all, or "skip" to dismiss.
```

### Presentation Rules

1. Maximum 7 suggestions per session (avoid overwhelming the user)
2. If more than 7, show top 7 and note "N more suggestions available"
3. Group by priority level for visual clarity
4. Include a one-line rationale per suggestion

---

## Phase 5: Template-Based Creation

For each accepted suggestion:

```
1. Read the appropriate template from references/templates/
2. Fill {placeholders} from project analysis data:
   - {framework} -> detected framework name
   - {runner} -> detected test runner
   - {orm} -> detected ORM name
   - {sensitive_paths_list} -> formatted path list
   - {test_dir} -> detected test directory
3. Present filled template for user confirmation:
   "Here's the proposed rule for testing conventions.
    Review and confirm to write to .claude/rules/testing.md"
4. On confirmation -> write to .claude/rules/{name}.md
5. Update suppression state
```

### Human Gates

| Action | Gate |
|--------|------|
| Write new rule file | **Always confirm** -- show filled template first |
| Create `.claude/rules/` directory | **Always confirm** -- structural change |
| Modify existing rule | **Never** -- only create new rules |
| Delete stale rule | **Always confirm** -- show what will be removed |

---

## Suppression State

Track analysis state to avoid repeating dismissed suggestions:

```json
// .claude/config-awareness-state.json
{
  "version": "1.0",
  "last_analysis": "ISO-8601",
  "expires_at": "ISO-8601 (7 days later)",
  "suggestions": [
    {"id": "testing-jest", "status": "created"},
    {"id": "security-review", "status": "dismissed"},
    {"id": "api-express", "status": "pending"}
  ],
  "suppressed": false
}
```

### Re-analysis Triggers

| Trigger | Behavior |
|---------|----------|
| Dependency file mtime change | Re-run Phase 2 + Phase 3 |
| Rule file deleted | Re-check that suggestion |
| Explicit user request | Full re-analysis (ignore TTL) |
| TTL expired (7 days) | Full re-analysis |
| `"suppressed": true` | Skip analysis entirely |

---

## Interaction Flow

```
Suggestions found -> Present ranked summary -> User chooses:
  |-- "Yes, show me #1"        -> Template + confirmation gate
  |-- "Yes, show all"          -> Sequential templates
  |-- "Not now"                -> Record dismissed, TTL 7 days
  |-- "Never for this project" -> Permanent suppression
```

---

## Integration Pattern

config-awareness is **automatically active** when `.claude/` gaps are detected. Other skills can reference it for configuration enhancement suggestions.

### Skill Integration

```markdown
## Configuration Enhancement

Uses: @skills/config-awareness/

When configuration gaps are detected:
1. config-awareness scans .claude/ directory
2. Cross-references with project tech stack
3. Presents ranked suggestions
4. Creates rules from templates with human confirmation
```

### Complementary Skills

- **context-awareness** provides environment data consumed by this skill
- **x-setup** handles initial project setup (config-awareness handles ongoing enhancement)
- **x-help** can link to auto-suggestions for configuration improvements

---

## When to Load References

- **For signal-to-suggestion mapping with priorities**: See `references/detection-signals.md`
- **For rule templates (testing, security, api-design)**: See `references/templates/`
- **For stale rule detection algorithm**: See `references/stale-detection.md` (Phase 2)

## References

- @skills/context-awareness/ - Environment detection (context consumer)
- @skills/x-setup/ - Project initialization (complementary)
- @skills/x-help/ - Command discovery (link to auto-suggestions)
