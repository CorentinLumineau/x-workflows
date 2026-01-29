# Mode: lessons

> **Invocation**: `/x-research lessons` or `/x-research lessons --source {source}`
> **Legacy Command**: `/x:update-lessons`

<purpose>
Systematically fetch best practices from authoritative web sources, analyze for relevance, categorize into existing knowledge structure, and integrate approved content while preserving existing lessons.
</purpose>

## Configuration Variables

Projects configure these via thin wrappers:

| Variable | Purpose | Example |
|----------|---------|---------|
| `$SOURCE_1` through `$SOURCE_5` | Web sources to fetch | `https://www.anthropic.com/news` |
| `$LESSONS_PATH` | Destination path for lessons | `documentation/lessons/` |
| `$LESSONS_INDEX` | Index file to update | `documentation/lessons/README.md` |
| `$CATEGORY_STRUCTURE` | Category definitions | 9 categories with keywords |
| `$VALIDATION_COMMAND` | Post-integration validation | `/validate-coherence` |

## Behavioral Skills

This mode activates:
- `context-awareness` - Project context loading

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Analysis structuring |

<instructions>

### Phase 0: Context Loading

**Load before execution:**

```
1. Read $LESSONS_INDEX → Understand category structure, current lesson counts
2. Read $LESSONS_PATH/*.md → Current content for duplication checking
3. Grep existing lessons → Index for keyword comparison

Tool Usage:
- Read: Index file, category files
- Grep: Keywords in existing lessons
```

**Why**: Ensures understanding of existing structure, avoids duplication, and respects established patterns.

---

## Instructions

### Phase 1: Discovery (Web Fetch)

**Parallel source fetching** using background WebFetch operations:

```javascript
// Source 1
WebFetch({
  url: "$SOURCE_1",
  prompt: "Extract posts from the past 6 months related to best practices, patterns, and techniques. For each post, extract: title, URL, publication date, key takeaways (3-5 bullet points), and relevance to development workflows."
})

// Source 2
WebFetch({
  url: "$SOURCE_2",
  prompt: "Extract content about coding best practices, IDE integration patterns, context management, and developer workflows. Focus on actionable techniques and user-reported best practices."
})

// ... Sources 3-5 similarly
```

**Consolidation**: Collect all source results, deduplicate by URL, organize by source.

### Phase 2: Analysis (Quality + Relevance)

For each discovered article/post:

**1. Relevance Scoring** (1-10 scale):
- Domain-specific? (+3)
- Actionable techniques? (+2)
- Novel information? (+2)
- From authoritative source? (+2)
- Includes examples/code? (+1)

**2. Duplication Check**:
- Extract key concepts from article
- Compare against existing lessons (use Grep for keyword matching)
- Mark as "New" (no overlap), "Enhancement" (>70% overlap), or "Duplicate" (>90% overlap)

**3. Category Mapping**:
- Analyze article content
- Map to existing categories using keyword matching
- If no fit: Propose new category (requires 3+ lessons to justify)

**4. Integration Assessment**:
- Does article suggest project features?
- Identify actionable integrations
- Queue for `/x-research assess` if project-relevant

**Output**: Analysis report with 3 sections:
- **New Lessons** (relevance ≥7, duplication <70%)
- **Enhancements** (relevance ≥6, duplication 70-90%)
- **Feature Opportunities** (integration opportunities)

### Phase 3: User Review & Approval

Present comprehensive report:

```markdown
# Lessons Update Report ({date})

## Summary
- Sources Fetched: {N}
- Articles Analyzed: {N}
- New Lessons: {N}
- Enhancements: {N}
- Feature Opportunities: {N}

## New Lessons ({N})

### 1. {Lesson Title}
- **Source**: {Source Name} ({date})
- **URL**: {url}
- **Category**: {Category Name}
- **Relevance**: {score}/10 ({rationale})
- **Key Takeaways**:
  - {takeaway 1}
  - {takeaway 2}
- **Proposed Filename**: {filename}.md

[... more lessons ...]

## Enhancements ({N})

### 1. Update "{Existing Lesson}" ({category}.md)
- **Source**: {Source Name} ({date})
- **Addition**: {description of new content}
- **Lines to Add**: {N} lines after existing "{section}" section
- **Preview**:
  ```markdown
  ### {New Section Title}

  {Content preview...}
  ```

[... more enhancements ...]

## Feature Opportunities ({N})

### 1. {Feature Name}
- **Source**: {Source Name}
- **Description**: {feature description}
- **Assessment**: Queue for `/x-research assess {feature-name}`
- **Estimated Effort**: {effort}

[... more features ...]
```

**Use AskUserQuestion to get approval:**

```json
{
  "questions": [{
    "question": "Which updates should be applied?",
    "header": "Approval",
    "multiSelect": true,
    "options": [
      { "label": "All new lessons ({N})", "description": "Create {N} new lesson files" },
      { "label": "All enhancements ({N})", "description": "Update {N} existing lessons" },
      { "label": "Feature opportunities only", "description": "Run /x-research assess for {N} features" },
      { "label": "Review individually", "description": "I'll approve each item one by one" }
    ]
  }]
}
```

### Phase 4: Integration (Write Operations)

**For New Lessons:**

1. Generate lesson file using template structure:

```markdown
---
difficulty: {beginner|intermediate|advanced}
impact: {low|medium|high}
topics: [{topic-list}]
source: {source-name}
date-added: {date}
---

# Lesson: {Title}

## Core Insight
{One-sentence summary}

## Problem
{What problem does this solve?}

## Solution
{Actionable technique}

## Example
{Code/workflow example}

## When to Use
{Applicability guidance}

## Cautions
{Limitations or risks}

## Related
- See: @{path/to/related-lesson}.md
- Reference: {source URL}
```

2. Write to `$LESSONS_PATH/{category}.md` (append to existing category file)
3. Update `$LESSONS_INDEX` (increment lesson counts)

**For Enhancements:**

1. Read existing lesson file
2. Use Edit tool to insert new content at specified location
3. Preserve existing structure and cross-references

**For Feature Opportunities:**

1. For each feature, invoke `/x-research assess {feature-name}`
2. Follow assessment recommendations (implement, defer, or reject)

### Phase 5: Validation & Commit

**1. Validation:**
- Run `$VALIDATION_COMMAND` to check for broken references
- Verify lesson counts match index file
- Spot-check 3 random updated files for structure compliance

**2. Git Commit:**
- Commit per source (separate commits for traceability)
- Commit message format:

```
docs(lessons): add {count} lessons from {source}

Source: {URL}
Date: {fetch-date}

New Lessons:
- {lesson-1-title}
- {lesson-2-title}

Enhancements:
- Updated {category} with {feature}
```

**3. Report Summary:**

```markdown
✅ Lessons Update Complete

- {N} new lessons added
- {N} existing lessons enhanced
- {N} feature opportunities assessed
- {N} commits created

Next Steps:
- Review lessons in {$LESSONS_PATH}
- Implement approved features
- Schedule next update (recommended: monthly)
```

</instructions>

<decision_making>

## Decision Making

**Execute autonomously when:**
- `--dry-run` flag provided (no file writes, just analysis)
- Source fetch and analysis (Phase 1-2) - no approval needed for reading
- Category mapping logic (deterministic, no ambiguity)
- Validation command execution (automated check)

**Ask questions when:**
- User approval required (Phase 3 - which updates to apply?)
- New category creation needed (>3 lessons don't fit existing categories)
- Conflict detected (existing lesson has incompatible update)
- Integration assessment unclear (feature applicability ambiguous)
- Source fetch fails (retry? skip? abort?)

**Principle**: Fetch and analyze autonomously, but always get explicit approval before writing files.

</decision_making>

<critical_rules>

1. **User Approval Required Before Updates** - Never write to lessons without explicit confirmation. Present analysis report first, get approval, then integrate. Prevents accidental overwrites.

2. **Preserve Existing Content** - Always read existing files before modification. Use Edit tool for updates (never Write to overwrite). Maintain git history with atomic commits. Ensures zero data loss.

3. **Follow Category Structure** - Analyze existing index to understand current categories. Map new lessons to existing categories or propose new categories only when genuinely needed (>3 lessons justify new category).

4. **Rate Limiting & Ethics** - Respect robots.txt, limit pages per source per run, cache results. Use WebFetch tool (respects rate limits) instead of raw scraping.

5. **Quality Assessment Required** - Evaluate for: Relevance, Actionability, Novelty, Authority. Reject low-quality, speculative, or promotional content.

</critical_rules>

## Context-Aware Execution

| Input Pattern | Detected Context | Execution Path |
|---------------|------------------|----------------|
| No arguments | Full sync | Fetch from all sources, analyze, report, await approval |
| `--source {name}` | Single source | Fetch only specified source, faster iteration |
| `--dry-run` | Analysis only | Fetch and analyze, generate report, no file writes |
| `--category {name}` | Targeted update | Focus on specific category only |
| Default | Standard flow | All sources, semi-automated with approval gates |

## Quality Gates

**Before Phase 3 (Report Generation):**
- [ ] All sources fetched successfully (or failures logged)
- [ ] Minimum threshold articles analyzed
- [ ] At least 1 new lesson or enhancement identified
- [ ] Duplication check completed for all articles

**Before Phase 4 (Integration):**
- [ ] User approval received via AskUserQuestion
- [ ] Existing lesson files read successfully (for enhancements)
- [ ] Category files identified for new lessons
- [ ] No file write conflicts detected

**After Phase 5 (Completion):**
- [ ] Validation command passes (no broken references)
- [ ] Index lesson counts updated correctly
- [ ] Git commits created (one per source)
- [ ] Summary report generated

## References

- WebFetch tool - Web content fetching (built-in)
- AskUserQuestion tool - User approval gates (built-in)

<success_criteria>

- [ ] Fetched content from all sources (or failures logged)
- [ ] Generated analysis report with relevance scores
- [ ] User approved at least 1 update (new lesson or enhancement)
- [ ] All approved updates applied successfully
- [ ] Validation passes after updates
- [ ] Git commits created with clear attribution
- [ ] No existing content overwritten without approval

</success_criteria>
