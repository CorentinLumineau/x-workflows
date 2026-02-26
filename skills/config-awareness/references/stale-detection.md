# Stale Rule Detection

Reference for config-awareness stale rule detection. Identifies rules that reference filesystem paths which no longer exist.

## Algorithm

### Step 1: Scan Rules Directory

Read each `.md` file in `.claude/rules/`:

```
For each rule file:
  1. Read file content
  2. Extract path-like references via regex
  3. Build reference inventory per rule
```

### Step 2: Extract Path References

Regex patterns to match path-like references:

```
Patterns (in order of specificity):
1. Backtick-quoted paths: `src/auth/`, `lib/utils.ts`
2. Bare relative paths: src/, lib/, tests/, config/
3. File patterns: *.ts, *.js, *.py, *.json (when preceded by path context)
4. Explicit file references: tsconfig.json, package.json, Makefile

Exclude:
- URLs (https://, http://)
- Markdown image/link syntax that points to docs
- Known non-filesystem references (e.g., npm package names)
```

### Step 3: Validate References

For each extracted path reference:

```
1. Run Glob tool to check if path resolves to any files
2. Track: { path, exists: boolean, glob_result_count }
3. If glob returns 0 files → mark as dead reference
```

### Step 4: Classify Rule Staleness

Classification rules:

```
- SKIP rules with 0 path references (generic rules, no filesystem assertions)
- FLAG as stale if:
  - Rule has 3+ path references AND
  - ≥50% of references resolve to 0 files
- INFO (non-blocking) if:
  - Rule has 1-2 dead references out of many (partial staleness)
```

### Step 5: Present Results

```
Stale rules detected:
1. [LOW] Rule "api-structure.md" — 4/6 referenced paths no longer exist
   Dead: `src/api/v1/`, `src/api/v2/`, `lib/routes/`, `config/api.yml`
   Alive: `src/controllers/`, `tests/api/`
   → Suggest: update or remove

Options: view rule, update rule, remove rule, dismiss (7-day suppression)
```

## Integration

- Called from config-awareness Phase 3 (Gap Analysis)
- Stale suggestions use priority LOW (after structural and framework suggestions)
- Suppression: 7-day TTL per stale-{rule} suggestion ID
- Re-triggers if rule file mtime changes

## Edge Cases

| Case | Behavior |
|------|----------|
| Empty rules directory | Skip stale detection entirely |
| Rule with no path references | Skip (generic rules are valid) |
| Glob pattern in rule (e.g., `*.test.ts`) | Validate parent directory existence instead |
| Rule references other rules | Skip self-references (`.claude/rules/` paths) |
| Monorepo paths (`packages/*/`) | Validate at least one match exists |
