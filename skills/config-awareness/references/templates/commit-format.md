# Commit Format Template

> Adapts to: Any project (conventional commits spec)

## Template

```markdown
# Commit Format

## Conventional Commits

All commits follow the Conventional Commits specification:

```
{type}({scope}): {description}

[optional body]

[optional footer(s)]
```

## Allowed Types

{types}

## Scopes

Scopes are derived from project structure:
{scopes}

## Rules

- Subject line: max 72 characters, imperative mood, no period
- Body: wrap at 80 characters, explain WHY not WHAT
- Breaking changes: add `!` after type/scope and `BREAKING CHANGE:` footer
- Reference issues: `Closes #123` or `Fixes #456` in footer

## Examples

{example_feat}
{example_fix}
```

## Placeholder Resolution

| Placeholder | Default (any project) |
|------------|----------------------|
| `{types}` | `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert` |
| `{scopes}` | Auto-populated from top-level `src/` subdirectories (e.g., `auth`, `api`, `ui`, `core`) |
| `{example_feat}` | `feat(auth): add OAuth2 login flow` |
| `{example_fix}` | `fix(api): handle null response in user endpoint` |
