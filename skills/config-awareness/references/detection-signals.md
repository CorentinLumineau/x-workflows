# Detection Signals -> Suggestion Mapping

Reference for config-awareness Phase 3 gap analysis. Maps detection signals to configuration suggestions with priorities.

## Signal Table

| Signal | Detection Method | Suggestion ID | Suggestion Text | Priority | Template |
|--------|-----------------|---------------|-----------------|----------|----------|
| No `.claude/rules/` | Directory absent | rules-bootstrap | Bootstrap rules structure | HIGH | -- (creates directory) |
| No CLAUDE.md | File absent | claudemd-create | Create project-level CLAUDE.md | HIGH | -- (scaffold) |
| Auth module detected, no security rules | `auth/`, `security/`, `crypto/` dirs exist | security-review | Add security review rule | HIGH | security.md |
| Security deps detected | package.json deps: helmet, cors, bcrypt, jsonwebtoken | security-deps | Add security conventions | HIGH | security.md |
| React detected | package.json deps: `react` | component-react | Add React component conventions | MEDIUM | component-structure.md (Phase 2) |
| Vue detected | package.json deps: `vue` | component-vue | Add Vue component conventions | MEDIUM | component-structure.md (Phase 2) |
| Angular detected | package.json deps: `@angular/core` | component-angular | Add Angular component conventions | MEDIUM | component-structure.md (Phase 2) |
| Express API | package.json deps: `express` | api-express | Add API conventions rule | MEDIUM | api-design.md |
| Fastify API | package.json deps: `fastify` | api-fastify | Add API conventions rule | MEDIUM | api-design.md |
| Hono API | package.json deps: `hono` | api-hono | Add API conventions rule | MEDIUM | api-design.md |
| Django detected | requirements.txt/pyproject.toml: `django` | api-django | Add Python API conventions | MEDIUM | api-design.md |
| Flask detected | requirements.txt/pyproject.toml: `flask` | api-flask | Add Python API conventions | MEDIUM | api-design.md |
| FastAPI detected | requirements.txt/pyproject.toml: `fastapi` | api-fastapi | Add Python API conventions | MEDIUM | api-design.md |
| Jest detected | package.json deps/devDeps: `jest` | testing-jest | Add testing conventions | MEDIUM | testing.md |
| Vitest detected | package.json deps/devDeps: `vitest` | testing-vitest | Add testing conventions | MEDIUM | testing.md |
| pytest detected | requirements.txt/pyproject.toml: `pytest` | testing-pytest | Add testing conventions | MEDIUM | testing.md |
| Mocha detected | package.json deps/devDeps: `mocha` | testing-mocha | Add testing conventions | MEDIUM | testing.md |
| Prisma detected | package.json deps: `prisma`, `@prisma/client` | database-prisma | Add database migration rules | MEDIUM | database.md (Phase 2) |
| TypeORM detected | package.json deps: `typeorm` | database-typeorm | Add database migration rules | MEDIUM | database.md (Phase 2) |
| Sequelize detected | package.json deps: `sequelize` | database-sequelize | Add database migration rules | MEDIUM | database.md (Phase 2) |
| TypeScript detected | `tsconfig.json` exists | typescript-config | Add TypeScript conventions | MEDIUM | typescript.md (Phase 2) |
| Monorepo signals | workspace config files (pnpm-workspace.yaml, nx.json, turbo.json) | monorepo-config | Add cross-package rules | MEDIUM | monorepo.md (Phase 2) |
| Stale rule detected | Rule references paths matching 0 files via glob check | stale-{rule} | Update or remove stale rule | LOW | -- (suggest edit/delete) |
| No output style config | `.claude/settings.json` missing or no `outputStyle` key | output-style | Configure output style | LOW | -- (suggest options) |

## Detection Priority Order

Suggestions are presented in this priority order:

1. **HIGH** signals first -- structural gaps and security concerns
   - Missing `.claude/rules/` directory
   - Missing CLAUDE.md
   - Security-sensitive code without security rules
   - Security dependencies without conventions

2. **MEDIUM** signals -- framework-specific conventions
   - API framework conventions (Express, Fastify, Django, FastAPI)
   - Testing conventions (Jest, Vitest, pytest)
   - Component conventions (React, Vue, Angular)
   - Database/ORM conventions
   - TypeScript conventions
   - Monorepo conventions

3. **LOW** signals -- cleanup and optimization
   - Stale rule detection
   - Output style configuration

Within the same priority level, sort by detection order (structural before framework-specific).

## Placeholder Resolution

Templates use placeholders filled from project analysis data:

```
{framework}   -> detected framework name (e.g., "React", "Express", "Django")
{runner}      -> detected test runner name (e.g., "Jest", "Vitest", "pytest")
{orm}         -> detected ORM name (e.g., "Prisma", "TypeORM", "SQLAlchemy")
{paths}       -> comma-separated relevant paths (e.g., "src/auth/, src/middleware/")
{test_dir}    -> detected test directory (e.g., "__tests__/", "tests/", "test/")
{validation_library} -> detected validation library (e.g., "Zod", "Pydantic")
```

### Resolution Algorithm

```
For each placeholder in template:
  1. Look up value from project analysis schema
  2. If value found -> substitute directly
  3. If value not found -> use sensible default from template's resolution table
  4. If no default available -> leave as {placeholder} and warn user to fill manually
```

## Deduplication Rules

Before presenting a suggestion, check for existing coverage:

1. **Rule file name match**: If `.claude/rules/testing.md` exists, skip `testing-jest`
2. **CLAUDE.md content match**: If CLAUDE.md mentions "testing conventions", skip testing suggestions
3. **Partial coverage**: If a rule exists but is incomplete (e.g., testing rule without coverage targets), suggest enhancement instead of new rule
4. **Multiple frameworks**: If both Express and Fastify detected, present one api-design suggestion (not two)
