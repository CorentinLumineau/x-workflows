# TypeScript Conventions Template

> Adapts to: TypeScript projects (all TS projects share conventions)

## Template

```markdown
# TypeScript Conventions

## Compiler Configuration

- Strict mode: `{strict_mode}`
- Target: `{target}`
- Module resolution: `{module_resolution}`
- Path aliases: `{paths}`

## Type Conventions

- Prefer `interface` for public API contracts and object shapes
- Use `type` for unions, intersections, and computed types
- Use `type` imports for type-only dependencies: `import type { User } from './types'`
- Export types from a dedicated `types.ts` file per module
- Never use `any` -- use `unknown` and narrow with type guards

## Strict Mode Rules

- Enable `noUncheckedIndexedAccess` -- array/object access returns `T | undefined`
- Enable `exactOptionalProperties` -- distinguish `undefined` from missing
- Treat all function parameters as required unless explicitly optional
- Use `satisfies` for type checking without widening

## Naming

- Types and interfaces: PascalCase (`UserProfile`, `ApiResponse`)
- Type parameters: single uppercase or descriptive (`T`, `TData`, `TError`)
- Enums: PascalCase with PascalCase members (`enum Status { Active, Inactive }`)
- Prefer union types over enums for simple cases: `type Status = 'active' | 'inactive'`

## Patterns

- Use discriminated unions for state machines and result types
- Define error types explicitly -- never throw untyped errors
- Use `readonly` for immutable data structures
- Prefer `Record<K, V>` over index signatures for known key sets
- Use `as const` for literal tuples and object constants
```

## Placeholder Resolution

| Placeholder | Strict (recommended) | Relaxed (legacy) |
|------------|---------------------|------------------|
| `{strict_mode}` | `"strict": true` | `"strict": false` |
| `{target}` | `ES2022` or later | `ES2018` (broader compat) |
| `{module_resolution}` | `bundler` or `node16` | `node` (classic) |
| `{paths}` | `{ "@/*": ["./src/*"] }` | None (relative imports only) |
