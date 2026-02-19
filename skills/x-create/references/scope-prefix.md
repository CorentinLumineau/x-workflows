# Scope-Prefix Convention

> **Purpose**: Naming convention for component discoverability via autocomplete.

## Prefix System

| Scope | Prefix | Autocomplete | Applies To |
|-------|--------|-------------|------------|
| **plugin** | `x-` / `git-` | `/x-`, `/git-` | Existing convention (extensible) |
| **project** | `prj-` | `/prj-` | User-triggerable components |
| **user** | `usr-` | `/usr-` | User-triggerable components |

## When Prefixes Apply

Prefixes are added when **both** conditions are true:
1. **Scope** is `project` or `user` (plugin scope uses its own `x-`/`git-` convention)
2. **Component is user-triggerable**:
   - Commands → always user-triggerable
   - Agents → always user-triggerable
   - Skills with `user-invocable: true` → user-triggerable
   - Skills with `user-invocable: false` (behavioral) → NOT user-triggerable

## When Prefixes Do NOT Apply

| Scenario | Reason |
|----------|--------|
| Behavioral skills (any scope) | Auto-activated, not `/`-discoverable |
| Plugin scope components | Use existing `x-`/`git-` convention |
| Source-repo skills (x-workflows, x-devsecops) | Routed to source repos, not `.claude/` |

## Double-Prefix Detection

Before applying a prefix, check if the name already starts with the scope prefix:

```
input_name = user-provided name
scope_prefix = "prj-" | "usr-" | ""

if input_name starts with scope_prefix:
  final_name = input_name  # Already prefixed — use as-is
  note: "Prefix already present"
elif scope has different prefix AND input_name starts with OTHER scope prefix:
  WARN: "Name has '{other_prefix}' but scope is '{scope}'. Use '{scope_prefix}{base_name}' instead? [Y/n]"
  # Scope mismatch — prompt user
else:
  final_name = scope_prefix + input_name
  note: "Auto-prefixed: {final_name} ({scope} scope convention)"
```

## Examples

| Scope | User Provides | Component Type | Result |
|-------|--------------|----------------|--------|
| project | `lint` | command | `prj-lint` |
| project | `deploy` | command | `prj-deploy` |
| project | `db-migrator` | agent | `prj-db-migrator` |
| project | `validate-schema` | skill (user-invocable) | `prj-validate-schema` |
| project | `code-conventions` | skill (behavioral) | `code-conventions` (no prefix) |
| project | `prj-lint` | command | `prj-lint` (already prefixed) |
| user | `scratch` | command | `usr-scratch` |
| user | `my-helper` | agent | `usr-my-helper` |
| user | `usr-scratch` | command | `usr-scratch` (already prefixed) |
| user | `prj-lint` | command | **WARN**: scope mismatch |
| plugin | `x-reviewer` | agent | `x-reviewer` (plugin convention) |

## Future Extensibility

The prefix system is designed for additional scopes. Plugin sub-conventions (e.g., `git-` for forge workflows) follow the same pattern — each scope owns its prefix namespace. New scopes can be added by extending the prefix table without changing the detection algorithm.
