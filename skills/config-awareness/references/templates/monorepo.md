# Monorepo Conventions Template

> Adapts to: pnpm workspaces, Nx, Turborepo, Yarn workspaces

## Template

```markdown
# Monorepo Conventions

## Tool: {tool}

## Workspace Configuration

- Config file: `{workspace_config}`
- Workspace pattern: `{workspace_pattern}`
- Run across packages: `{run_command}`
- Shared configuration: `{shared_config_location}`

## Package Organization

```
{workspace_pattern}/
  app/              # Main application(s)
  shared/           # Shared libraries
  config/           # Shared configs (tsconfig, eslint, etc.)
```

## Dependency Rules

- Internal packages use workspace protocol: `"@scope/shared": "workspace:*"`
- Shared dependencies hoisted to root -- avoid version conflicts
- Package-specific dependencies stay in the package's `package.json`
- Pin exact versions for critical dependencies
- Run dependency updates at root level, not per-package

## Cross-Package Rules

- No circular dependencies between packages -- enforce with lint rules
- Shared types live in a dedicated `types` or `shared` package
- Changes to shared packages require tests across all consumers
- Use build caching to skip unchanged packages

## Package Naming

- Scope all packages under a single org: `@org/package-name`
- Use kebab-case for package names: `@org/api-client`, `@org/ui-components`
- Group by purpose: `@org/config-eslint`, `@org/config-tsconfig`

## Release & Versioning

- Use independent versioning per package (not fixed/locked)
- Changesets or conventional commits for version bumps
- Publish only packages with actual changes
- Tag releases as `@org/package@version`
```

## Placeholder Resolution

| Placeholder | pnpm workspaces | Nx | Turborepo | Yarn workspaces |
|------------|----------------|-----|-----------|-----------------|
| `{tool}` | pnpm workspaces | Nx | Turborepo | Yarn workspaces |
| `{workspace_config}` | `pnpm-workspace.yaml` | `nx.json` | `turbo.json` | `package.json` (`workspaces` field) |
| `{workspace_pattern}` | `packages/*` | `libs/*` | `packages/*` | `packages/*` |
| `{run_command}` | `pnpm -r run {script}` | `nx run-many --target={script}` | `turbo run {script}` | `yarn workspaces foreach run {script}` |
| `{shared_config_location}` | Root-level (`./config/`) | `libs/shared/` | Root-level (`./config/`) | Root-level (`./config/`) |
