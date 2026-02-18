# Grouping Rules Reference

> Extracted from git-commit SKILL.md — detailed patterns for change grouping.

## Config File Patterns

Files matching these patterns are grouped into the `config` group:
- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `tsconfig*.json`, `jsconfig*.json`
- `Makefile`, `Rakefile`, `CMakeLists.txt`
- `.github/**`, `.claude/**`, `.vscode/**`
- `.gitignore`, `.gitattributes`, `.editorconfig`
- `*.config.js`, `*.config.ts`, `*.config.mjs`, `*.config.cjs`
- `.eslintrc*`, `.prettierrc*`, `.stylelintrc*`
- `docker-compose*.yml`, `Dockerfile*`
- `*.toml` (at root), `*.yaml`/`*.yml` (at root, excluding data files)

## Sensitive File Patterns (Auto-Excluded)

Files matching these patterns are **excluded from all groups** with a warning:
- `.env`, `.env.*` (e.g., `.env.local`, `.env.production`)
- `credentials*`, `secret*`, `*password*`, `*token*`
- `*.key`, `*.pem`, `*.p12`, `*.pfx`, `*.keystore`
- `id_rsa*`, `id_ed25519*`, `id_ecdsa*`
- `*.secret`, `*.credentials`

## Collection Directory Patterns

Directories that group at the second level (e.g., `skills/git-commit`):
- `skills`, `agents`, `hooks`, `commands`
- `src`, `lib`, `pkg`, `internal`
- `test`, `tests`, `__tests__`, `spec`
- `components`, `pages`, `routes`, `views`
- `modules`, `packages`, `apps`
