# Per-Group Commit Loop Reference

> Extracted from git-commit SKILL.md Phase 4 — detailed commit loop steps for each strategy.

## Strategy: "all-separate" or "review-each"

Iterate through each group in order:

1. Present group summary:
   ```
   ## Group {i}/{total}: {group_name}
   Files: {file_list}
   Type: {inferred_type}({scope})
   ```

2. If strategy is "review-each": show `git diff` for the group's files (staged and unstaged)

3. Auto-generate conventional commit message by analyzing the group's diff:
   - Refine type from diff content (not just path heuristics)
   - Generate imperative description (<50 chars)
   - Add body if changes warrant explanation

4. Present for text confirmation:
   ```
   Proposed: {type}({scope}): {description}
   Accept [Y], Skip [n], Edit [e]?
   ```
   - **Y** (default): Proceed to commit
   - **n**: Skip this group entirely (files remain uncommitted)
   - **e**: User provides alternative message

5. If confirmed:
   ```bash
   # Stage specific files for this group
   git add {file1} {file2} ...

   # Commit with HEREDOC for message
   git commit -m "$(cat <<'EOF'
   {type}({scope}): {description}

   {body}

   {{#if CLOSE_ISSUE_NUMBER}}
   Closes #{CLOSE_ISSUE_NUMBER}
   {{/if}}
   EOF
   )"

   # Verify success
   git status
   ```

6. Record commit hash, continue to next group

## Strategy: "single"

Merge all groups into one commit:

1. Determine dominant type across all groups
2. Use broadest scope (or omit scope if too diverse)
3. Generate combined description
4. If `CLOSE_ISSUE_NUMBER` is set, append `Closes #N` footer (same pattern as per-group)
5. Present for confirmation (text prompt)
6. `git add` all files → single `git commit` → `git status`

## Safety Rules (enforced throughout)

- Never use `git add -A` or `git add .` — always add specific files
- Never commit sensitive files (auto-excluded in Phase 1)
- Always use HEREDOC for commit messages
- Verify with `git status` after each commit
