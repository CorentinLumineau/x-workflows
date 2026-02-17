# Mode: setup

> **Invocation**: `/x-setup` or `/x-setup setup`
> **Legacy Command**: `/x:setup`

<purpose>
Project documentation setup - creates complete `/documentation/**` structure with intelligent stack detection.
</purpose>

## References

See `@skills/x-docs/references/doc-sync-patterns.md` for documentation patterns.

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

**Triggers for this mode**: Project type unclear, stack preferences undefined.

---

## Instructions

### Phase 1: Stack Detection

Auto-detect project stack:

```bash
# Check for package managers
ls package.json pnpm-lock.yaml yarn.lock package-lock.json 2>/dev/null

# Check for frameworks
cat package.json | grep -E "react|vue|angular|svelte|next|express"

# Check for languages
ls *.py setup.py pyproject.toml go.mod Cargo.toml 2>/dev/null
```

Detect:
- **Frontend**: React, Vue, Angular, Svelte, Next.js
- **Backend**: Node, Python, Go, Rust
- **Database**: PostgreSQL, MySQL, MongoDB
- **Build**: npm, yarn, pnpm, make

### Phase 2: Structure Creation

Create documentation structure:

```bash
mkdir -p documentation/{domain,development,implementation,milestones/_active,reference,troubleshooting}
```

### Phase 3: Generate Files

#### documentation/CLAUDE.md
```markdown
# Project Documentation Hub

> Central navigation for all project documentation

## Subfolders

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| [domain/](domain/) | Business logic | Understanding requirements |
| [development/](development/) | Setup, workflows | Getting started |
| [implementation/](implementation/) | Technical docs | Architecture reference |
| [milestones/](milestones/) | Planning | Current initiatives |
| [reference/](reference/) | Stack docs | Configuration reference |
| [troubleshooting/](troubleshooting/) | Issue resolution | Debugging problems |

## Quick Links

- [config.yaml](./config.yaml) - Project stack configuration
```

#### documentation/config.yaml
```yaml
project:
  name: {project_name}
  type: {detected_type}

stack:
  frontend: {detected_frontend}
  backend: {detected_backend}
  database: {detected_database}
  build: {detected_build}

testing:
  command: {test_command}
  coverage: 95

documentation:
  structure: standard
  last_updated: {date}
```

### Phase 4: Section READMEs

Create README.md in each folder with appropriate template.

### Phase 5: Completion Report

```markdown
## Documentation Setup Complete

### Structure Created
```
documentation/
├── CLAUDE.md           ✅
├── config.yaml         ✅
├── domain/             ✅
│   └── README.md
├── development/        ✅
│   └── README.md
├── implementation/     ✅
│   └── README.md
├── milestones/         ✅
│   ├── README.md
│   └── _active/
├── reference/          ✅
│   └── README.md
└── troubleshooting/    ✅
    └── README.md
```

### Stack Detected
- Frontend: {frontend}
- Backend: {backend}
- Database: {database}
```

### Phase 6: Next Steps

```json
{
  "questions": [{
    "question": "Documentation structure created. What's next?",
    "header": "Next",
    "options": [
      {"label": "Populate docs (Recommended)", "description": "Add initial content"},
      {"label": "Start development", "description": "Begin coding"},
      {"label": "Done", "description": "Setup complete"}
    ],
    "multiSelect": false
  }]
}
```

## Documentation Templates

Uses templates from:
- ../templates/documentation/
- ../templates/navigation/

## Structure Standards

| Folder | Purpose | Key Files |
|--------|---------|-----------|
| domain/ | Business logic | Domain models, rules |
| development/ | Setup | Contributing, workflow |
| implementation/ | Architecture | Design docs |
| milestones/ | Planning | Initiatives |
| reference/ | Stack | API, config docs |
| troubleshooting/ | Debug | Common issues |

</instructions>

<critical_rules>

## Critical Rules

1. **Consistent Structure** - Use standard layout
2. **Stack Aware** - Tailor to detected stack
3. **Navigable** - Clear CLAUDE.md hubs
4. **Maintainable** - Easy to update

</critical_rules>

## References

- @core-docs/DOC_FRAMEWORK_ENFORCEMENT.md - Structure standards
- ../templates/README.md - Available templates

<success_criteria>

## Success Criteria

- [ ] Stack detected
- [ ] Structure created
- [ ] Config generated
- [ ] READMEs in place

</success_criteria>
