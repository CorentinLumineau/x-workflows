# Conflict Analysis Reference

## Conflict Marker Pattern

```
<<<<<<< HEAD (or branch name)
[ours content]
=======
[theirs content]
>>>>>>> {branch/commit}
```

Extract:
- **Ours**: Content from HEAD/current branch
- **Theirs**: Content from merging branch/commit
- **Context**: 5 lines before and after conflict region

## Conflict Types

1. **Content conflict**: Both sides modified same lines differently
2. **Addition conflict**: Both sides added content in same location
3. **Deletion conflict**: One side deleted, other modified
4. **Structural conflict**: Code structure changed (imports, class definitions)
5. **Whitespace conflict**: Only whitespace/formatting differs

## Resolution Strategies

- **Accept ours**: Keep HEAD version (use when current branch is authoritative)
- **Accept theirs**: Keep incoming version (use when merging authoritative changes)
- **Manual merge**: Combine both sides intelligently
- **Rewrite**: Neither side is correct, needs fresh implementation

## Recommendation Generation

For each conflict region, generate recommendation based on:
- Semantic analysis of code changes
- Function/method context
- Variable usage and dependencies
- Comments and documentation hints

Present recommendation with confidence level:
- **High confidence**: Clear winner (e.g., one side is clearly newer/better)
- **Medium confidence**: Both sides have merit, suggests manual merge
- **Low confidence**: Complex conflict, requires human judgment

## Syntax Verification After Resolution

- **JavaScript/TypeScript**: `npx eslint {file} --no-eslintrc` (syntax only)
- **Python**: `python -m py_compile {file}`
- **Go**: `go build {file}`
- **Rust**: `cargo check`

## Example Usage

```bash
# Detect and resolve conflicts automatically
/git-resolve-conflict

# Typically invoked by another workflow when conflict detected
# Not usually invoked directly by user
```

### Expected Workflow

1. User attempts merge/rebase that causes conflict
2. Calling workflow (git-merge-pr or x-implement) detects conflict
3. Skill activates automatically or user invokes manually
4. Skill analyzes each conflict and presents recommendations
5. User approves resolution strategy for each conflict
6. Skill applies resolutions and runs tests
7. Skill finalizes and chains back to original workflow
