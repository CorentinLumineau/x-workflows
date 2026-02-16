# Ecosystem Catalog Reference

> Used by Phase 0.6 (Ecosystem Scan) to detect duplicates and show related components.

## Scan Protocol

### 1. Full Scan

Glob all existing components in the detected scope:

```
{plugin_root}/skills/*/SKILL.md    → Skills catalog
{plugin_root}/agents/*.md          → Agents catalog
{plugin_root}/commands/*.md        → Commands catalog
```

For each file found, extract:
- **name**: From frontmatter `name:` field
- **description**: From frontmatter `description:` field
- **category**: From frontmatter `metadata.category:` or inferred from path

### 2. Parse and Index

Build an in-memory catalog:

```yaml
catalog:
  skills:
    - name: "x-implement"
      description: "Context-aware implementation with TDD"
      category: workflow
    - name: "security-owasp"
      description: "OWASP Top 10 prevention"
      category: security
    # ... all discovered skills
  agents:
    - name: "x-tester"
      description: "Test execution specialist"
      model: sonnet
    # ... all discovered agents
  commands:
    - name: "commit"
      description: "Interactive commit"
      delegates_to: "x-commit"
    # ... all discovered commands
```

### 3. Duplicate Detection

| Check | Threshold | Action |
|-------|-----------|--------|
| Exact name match | 100% | **BLOCK** — Show existing component and ask user to confirm intent |
| Similar name (edit distance < 3) | ~80% | **WARN** — Show similar component, suggest reviewing before proceeding |
| Similar description | Semantic | **INFO** — Note overlap, proceed with awareness |

Similarity examples:
- `x-test` vs `x-tester` → WARN (edit distance = 2)
- `security-auth` vs `security-authentication` → WARN (prefix match)
- `x-implement` vs `x-implement` → BLOCK (exact match)

### 4. Related Components

After scanning, identify and display:

1. **Same category**: Skills sharing the category of the one being created
2. **Same scope**: Components at the same scope level (plugin/project/user)
3. **Workflow proximity**: For workflow skills, show skills that typically chain together

Display format:
```
Ecosystem: {total} skills, {agents} agents, {commands} commands
Category "{category}": {n} existing skills
Potential conflicts: {duplicates} found
Related: {skill_1}, {skill_2}, {skill_3}
```

### 5. Summary Report

Present to user before proceeding:

```markdown
## Ecosystem Scan Results

**Scope**: {scope} (`{root_path}`)
**Total**: {total} skills | {agents} agents | {commands} commands

### Category: {category}
- {existing_skill_1} — {description}
- {existing_skill_2} — {description}

### Potential Conflicts
{none | list of similar names with recommendations}

### Related Skills
- {related_1} — {why related}
- {related_2} — {why related}
```

## Naming Convention Index

| Pattern | Type | Examples |
|---------|------|---------|
| `x-{verb}` | Workflow skill | x-implement, x-review, x-plan |
| `{category}-{topic}` | Knowledge skill | security-owasp, quality-testing |
| `{noun}` | Behavioral skill | interview, orchestration, documentation |
| `x-{role}` | Agent | x-tester, x-reviewer, x-debugger |
| `{verb}` or `{verb}-{noun}` | Command | commit, fix-coherence, bump-version |

## Empty Ecosystem Handling

When scan finds 0 components:
- Report "Empty ecosystem — no existing components found"
- Skip duplicate detection
- Skip related components
- Proceed directly to routing phase
