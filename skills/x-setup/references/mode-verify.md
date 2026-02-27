# Mode: verify

> **Invocation**: `/x-setup verify` or `/x-setup verify [path]`

<purpose>
Agent-readiness assessment for any Claude Code project. Scans .claude/ structure, CLAUDE.md quality, agent/skill/rule coverage, and MCP health — then produces a structured readiness report with actionable recommendations.
</purpose>

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 30%, technical 25%, scope 15%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: "verify", "check readiness", "agent-ready", "assess", "health check", "how ready is this project".

---

### Phase 1: Environment Detection

Determine the project scope and what layers to assess.

<context-query tool="project_context">
<purpose>Detect project type, stack, and Claude Code integration level</purpose>
<fallback>Manually scan for .claude/, .claude-plugin/, package.json, and project markers</fallback>
</context-query>

**1a. Base detection** — Always performed:
- Check if `.claude/` directory exists
- Check if `CLAUDE.md` or `.claude/CLAUDE.md` exists
- Check for `.claude/settings.json`, `.claude/settings.local.json`
- Detect project stack (reuse x-setup stack detection: package.json, go.mod, etc.)

**1b. Extended detection** — Check for ccsetup plugin:
- `.claude-plugin/` directory exists → plugin scope
- `ccsetup-plugin/` directory exists → ccsetup development scope
- Plugin markers in skills (compiled semantic markers) → ccsetup-powered
- `.mcp.json` references ccsetup MCP servers → ccsetup-powered

**1c. Scope determination**:

| Signal | Scope |
|--------|-------|
| No `.claude/` at all | **bare** — needs `/x-setup setup` first |
| `.claude/` exists, no plugin markers | **base** — assess base layer only |
| Plugin markers or `.claude-plugin/` detected | **extended** — assess both layers |

If scope is **bare**:
- Report: "No `.claude/` directory found. This project has no Claude Code configuration."
- Recommend: "Run `/x-setup setup` to initialize project structure."
- Skip to Phase 4 (minimal report) with overall score 0/10.

---

### Phase 2: Base Layer Assessment (any Claude Code project)

Assess the foundational Claude Code configuration. Each dimension gets a RED/YELLOW/GREEN status.

#### 2a. Directory Structure Health

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| `.claude/` exists | Yes | — | No |
| `.claude/settings.json` exists | Yes | — | No |
| Custom agents (`agents/*.md`) | 1+ agents | — | None |
| Custom rules (`.claude/rules/*.md`) | 1+ rules | — | None |

#### 2b. CLAUDE.md Quality

<deep-think trigger="claude-md-assessment">
<purpose>Evaluate the quality and completeness of the project's CLAUDE.md file against best practices for Claude Code projects. Consider: Does it provide build commands? Does it describe architecture? Does it have navigation to key directories? Is it maintainable (not bloated)?</purpose>
<context>Read the CLAUDE.md file (or .claude/CLAUDE.md) and assess against the checklist below.</context>
</deep-think>

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| Exists | Yes | — | No |
| Has build/test commands | Commands present | Partial (build but no test) | None |
| Has architecture overview | Section present | Brief mention | None |
| Has navigation/file map | Clear navigation | Some links | None |
| Size appropriate | 50-200 lines | 20-50 or 200-400 lines | <20 or >400 lines |
| No stale content | All refs valid | Some stale refs | Major stale sections |

#### 2c. Agent Coverage

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| Custom agents exist | 3+ agents | 1-2 agents | None |
| Agents match stack | Relevant to detected stack | Generic agents | Mismatched |
| Agent descriptions | Clear, actionable | Present but vague | Missing |

#### 2d. MCP Configuration

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| `.mcp.json` exists | Yes with servers | Empty/minimal | No |
| Servers are reachable | All configured correctly | Some issues | Misconfigured |

#### 2e. Git Integration

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| `.gitignore` covers `.claude/` secrets | Properly configured | Partial | No `.gitignore` |
| Hooks configured | Pre-commit or similar | — | None |

#### 2f. Settings Health

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| Permission mode configured | Explicit mode set | Default | — |
| Allowed tools scoped | Scoped to needed tools | — | Overly broad |

---

### Phase 3: Extended Layer Assessment (ccsetup-powered projects only)

**Skip this phase if scope is "base".**

Assess the ccsetup plugin ecosystem health beyond base Claude Code configuration.

#### 3a. Plugin Component Validation

<context-query tool="project_context">
<purpose>Get plugin component counts and structure</purpose>
<fallback>Manually glob ccsetup-plugin/agents/*.md, ccsetup-plugin/skills/*/SKILL.md, ccsetup-plugin/hooks/*.js</fallback>
</context-query>

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| Agent count | 10+ agents | 5-9 agents | <5 agents |
| Skill count | 50+ skills | 20-49 skills | <20 skills |
| Hook count | 3+ hooks | 1-2 hooks | None |
| Plugin manifest valid | `.claude-plugin/plugin.json` valid JSON | Present but incomplete | Missing |

#### 3b. Skill Coverage Analysis

Analyze skill distribution across categories:

| Category | Expected Coverage | Check |
|----------|-------------------|-------|
| Workflow skills (x-*) | Core APEX lifecycle covered | x-plan, x-implement, x-review exist |
| Git skills (git-*) | Basic git lifecycle | git-commit, git-create-pr, git-merge-pr exist |
| Knowledge skills | Stack-relevant domains | Security, testing, code quality present |
| Behavioral skills | Core behaviors | Interview, context-awareness, error-recovery present |

Report: "Skill coverage: {covered}/{expected} categories"

#### 3c. MCP Server Health

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| Context7 configured | Present in `.mcp.json` | — | Missing |
| Sequential-thinking configured | Present in `.mcp.json` | — | Missing |
| ccsetup-context configured | Present and server exists | Present but server missing | Not configured |

#### 3d. Compiler/Sync Health

| Check | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| No raw XML markers in compiled skills | Zero matches | — | Raw markers found |
| `tool-mapping.json` valid | Valid JSON | — | Invalid or missing |
| Skills recently synced | Last sync < 7 days | Last sync 7-30 days | Last sync > 30 days or never |

---

### Phase 4: Readiness Report

Produce a structured assessment report.

**Report format**:

```markdown
## Agent Readiness Report

**Project**: {project_name}
**Scope**: {base|extended}
**Date**: {date}

### Overall Score: {X}/10

### Dimension Scores

| Dimension | Status | Score | Notes |
|-----------|--------|-------|-------|
| Directory Structure | {🟢/🟡/🔴} | {0-2}/2 | {brief note} |
| CLAUDE.md Quality | {🟢/🟡/🔴} | {0-2}/2 | {brief note} |
| Agent Coverage | {🟢/🟡/🔴} | {0-2}/2 | {brief note} |
| MCP Configuration | {🟢/🟡/🔴} | {0-1}/1 | {brief note} |
| Git Integration | {🟢/🟡/🔴} | {0-1}/1 | {brief note} |
| Settings Health | {🟢/🟡/🔴} | {0-1}/1 | {brief note} |
| Plugin Components | {🟢/🟡/🔴} | {0-1}/1 | {extended only} |
```

**Scoring**:
- 🟢 GREEN = full points for dimension
- 🟡 YELLOW = half points
- 🔴 RED = 0 points
- Base layer: 9 points max (dimensions 1-6, weighted)
- Extended layer: 10 points max (adds plugin dimension)
- Normalize to X/10 scale

### Recommendations

Rank recommendations by impact (highest first):

```markdown
### Top Recommendations

1. **[HIGH]** {action} — {rationale}
2. **[MEDIUM]** {action} — {rationale}
3. **[LOW]** {action} — {rationale}
```

**Recommendation generation rules**:
- Every RED dimension generates a HIGH recommendation
- Every YELLOW dimension generates a MEDIUM recommendation
- GREEN dimensions may generate LOW recommendations for further improvement
- Maximum 7 recommendations (focus on highest impact)

---

### Phase 5: Action Gate

<workflow-gate id="verify-next-steps">
<purpose>Present actionable next steps based on the readiness assessment</purpose>
<context>Show the readiness score and top 3 recommendations. Offer paths forward based on what gaps were found.</context>
<options>
  <option id="create">Create recommended components → chain to /x-create or /x-create discover</option>
  <option id="setup">Re-run project setup → chain to /x-setup setup</option>
  <option id="done">Done — assessment complete</option>
</options>
</workflow-gate>

**Routing based on selection**:

- **"Create recommended components"**:
  - If specific component gaps identified → chain to `/x-create` with pre-filled context
  - If broad gaps → chain to `/x-create discover` for ecosystem gap analysis
  - Carry forward: recommendation list, detected scope, stack info

<workflow-chain on="create" skill="x-create" args="create from readiness report gaps: detected scope, stack, missing component types, and priority ranking from recommendations" />

- **"Re-run project setup"**:
  - Chain to `/x-setup setup` (useful if bare scope detected)
  - Carry forward: detected stack info

- **"Done"**:
  - End workflow with summary: "Agent readiness: {score}/10. Run `/x-setup verify` again after making changes."

</instructions>

<critical_rules>

## Critical Rules

1. **Read-only assessment** - Verify mode NEVER creates or modifies files. It only reads and reports.
2. **Layered scope** - Always detect scope first. Never assess extended layer on non-ccsetup projects.
3. **Evidence-based** - Every RED/YELLOW rating must cite the specific check that failed.
4. **Actionable output** - Every recommendation must include a concrete action the user can take.
5. **No false greens** - If a check cannot be performed (file unreadable, tool unavailable), mark as YELLOW with note, never GREEN.

</critical_rules>

<success_criteria>

## Success Criteria

- [ ] Environment detected (bare/base/extended scope)
- [ ] Base layer assessed (6 dimensions) — or bare scope reported with setup recommendation
- [ ] Extended layer assessed (4 dimensions) — if applicable
- [ ] Readiness report produced with per-dimension scores
- [ ] Recommendations ranked by impact
- [ ] Action gate presented with chain options

</success_criteria>

## References

- @core-docs/DOC_FRAMEWORK_ENFORCEMENT.md — Structure standards
- references/mode-setup.md — Setup mode (for chaining back)
- @skills/x-create/references/mode-discover.md — Discover mode (for chaining forward)
