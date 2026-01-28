# Documentation Sync Patterns

> Reference for keeping documentation synchronized with code changes

## Critical Rules

| Rule | Reason |
|------|--------|
| Documentation follows code | Never update docs in isolation; trigger is code change |
| Detect before update | Check for drift before writing |
| Pareto documentation | Document 20% that delivers 80% value |
| Examples must work | Test all code examples before committing |

## Staleness Detection

Check for doc/code drift:

| Signal | Action |
|--------|--------|
| API signature changed | Update API docs |
| New feature added | Add feature docs |
| Behavior modified | Update examples |
| File moved/renamed | Update references |

## Documentation Types

| Type | Update Trigger | Approach |
|------|----------------|----------|
| API Reference | Code signature changes | Auto-sync |
| README | Setup/usage changes | Manual review |
| Architecture | Structural changes | Design review |
| Changelog | Any release | Release process |

## Sync Workflow

```
1. Detect code changes since last doc update
2. Identify affected documentation
3. Verify placement - Is doc in correct category?
4. Update documentation to match code
5. Validate examples still work
6. Update navigation - Category README, cross-references
7. Commit docs with related code
```

## Category Detection

When writing documentation, determine the correct category:

| Code/Content Type | Write To |
|-------------------|----------|
| Service, Repository, Component | `implementation/` |
| Business Rules, Domain Logic | `domain/` |
| Setup, Config, Dev Workflows | `development/` |
| API, Library, External Refs | `reference/` |
| Plans, Progress, Roadmaps | `milestones/` |

## Don't Over-Document

Apply Pareto to documentation:
- Document public APIs (80% value)
- Skip obvious implementation details
- Focus on "why" not "what"
- Keep examples minimal but complete

## Quality Gates

- [ ] Documentation matches current code behavior
- [ ] Examples are tested/runnable
- [ ] No broken internal links
- [ ] Changelog updated for releases

## Allowed Exceptions

These files can exist outside `/documentation/`:
- `README.md` files (project root, major directories)
- `CLAUDE.md` navigation files
- `CHANGELOG.md` at project root

---

**Version**: 1.0.0
**Source**: Consolidated from `documentation` behavioral skill
