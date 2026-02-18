# Post-Creation Integration Checklist

> **Purpose**: Reusable checklist for integrating newly created skills and agents into the ecosystem after file creation is complete.

This checklist is referenced by mode-skill.md (Phase 5) and mode-agent.md (Phase 4) to ensure consistent post-creation steps.

---

## Skill Integration Steps

After creating a new skill, verify these integration points:

### 1. Ecosystem Registration

- [ ] **Frontmatter valid** — name, description present and within limits
- [ ] **No duplicates** — ecosystem scan confirmed no conflicts
- [ ] **Routing correct** — file created in the right repository (x-workflows, x-devsecops, or local scope)

### 2. Chaining Metadata

- [ ] **chains-from** — list upstream skills that naturally precede this one
- [ ] **chains-to** — list downstream skills that naturally follow
- [ ] **Reciprocal update** — upstream skills should add this skill to their `chains-to` (follow-on task, not blocking)

### 3. Behavioral Skill Activation

- [ ] **Behavioral skills listed** — document which behavioral skills this skill activates
- [ ] **Interview gate present** — Phase 0 interview check exists in all modes

### 4. References and Cross-Links

- [ ] **Mode files exist** — every mode in the Modes table has a corresponding `references/mode-{name}.md`
- [ ] **Boilerplate alignment** — generated content matches current boilerplate patterns
- [ ] **Related skills section** — populated from ecosystem scan results

---

## Agent Integration Steps

After creating a new agent, verify these integration points:

### 1. Agent Registration

- [ ] **Frontmatter valid** — name, description, model, tools present
- [ ] **No role overlap** — checked against existing agentTypes
- [ ] **Model appropriate** — haiku for read-only, sonnet for changes, opus for critical decisions

### 2. Tool Mapping (Plugin-Level Only)

- [ ] **agentTypes entry** — if plugin-level, consider adding to `tool-mapping.json`
- [ ] **Semantic marker resolution** — if registered, other skills can reference via `<agent-delegate role="{role}">`

### 3. Skill Binding

- [ ] **Skills list** — document which skills the agent has access to (if any)
- [ ] **Used-by mapping** — list which skills/commands delegate to this agent

---

## Post-Creation Workflow Gate

<workflow-gate id="post-creation-next">
<purpose>Guide user to the logical next step after component creation</purpose>
<context>Component has been created and basic validation passed. Present options based on what was created and what the ecosystem needs next.</context>
<options>
  <option id="chain-next">Chain to next workflow (x-implement or x-review)</option>
  <option id="create-more">Create another component (return to x-create)</option>
  <option id="integrate">Complete integration steps manually</option>
  <option id="done">Finished — no further action</option>
</options>
</workflow-gate>

### Chain Routing

Based on user selection:

| Selection | Action |
|-----------|--------|
| Chain to next | Invoke `x-implement` (if skill needs code) or `x-review` (if ready for review) |
| Create more | Return to x-create with ecosystem context preserved |
| Integrate | Show remaining unchecked items from the checklist above |
| Done | Summarize what was created and exit |

---

## BRAINSTORM Routing

If the user arrived here from `x-brainstorm`:
- **Carry forward** brainstorm output (ideas, constraints, decisions)
- **Pre-fill** name and description from brainstorm conclusions
- After creation, suggest chaining to `x-implement` to build what was brainstormed

If the user arrived here from `x-design`:
- **Carry forward** design decisions (ADR, architecture choices)
- **Pre-fill** component structure from design output
- After creation, suggest chaining to `x-implement` with the design as input
