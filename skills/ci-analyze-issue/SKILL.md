---
name: ci-analyze-issue
description: Analyze codebase + issue for CI-driven implementation. Produces structured analysis, questions, and plan.
license: Apache-2.0
compatibility: CI-only — called programmatically by workclaude Python scripts.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: workclaude
  version: "1.0.0"
  category: ci
chains-to:
  - skill: ci-implement-issue
    condition: "plan approved"
chains-from: []
---

# ci-analyze-issue

> Analyze a codebase and issue to produce structured questions, confidence scores, and an implementation plan.

## Purpose

Called programmatically by workclaude `issue_handler.py` during the **PLAN phase**. Receives issue context and conversation history as input. Produces structured JSON output consumed by the Python orchestrator.

This skill is NOT interactive. It runs in CI with no human-in-the-loop during execution. All human interaction happens asynchronously via Gitea comments between invocations.

## Input Context

The following context is injected into the prompt by the Python caller:

| Input | Source | Description |
|-------|--------|-------------|
| Issue title | Gitea API | Issue title text |
| Issue body | Gitea API | Full issue description (markdown) |
| Issue number | Gitea API | Reference number for links |
| Conversation history | Gitea API | All comments on the issue (chronological) |
| Branch session files | Git branch | `analysis.md`, `decisions.md` from prior runs |
| Feedback | Comment | Human feedback triggering re-analysis |

## Behavioral References

This skill activates the following behavioral patterns:

- `@skills/complexity-detection/` -- Assess complexity tier (low/medium/high)
- `@skills/interview/` -- Confidence dimensions (problem, technical, scope, risk)
- `@skills/code-code-quality/` -- SOLID validation for plan quality

<instructions>

## Phase 1: Codebase Discovery

1. Read the repository structure to understand the project layout
2. Identify the tech stack, frameworks, and conventions in use
3. Find files and modules relevant to the issue description
4. Check for existing tests, CI configuration, and coding standards
5. If session files exist from a prior run, read them to avoid redundant analysis

## Phase 2: Issue Analysis

1. Parse the issue title and body to extract requirements
2. Review conversation history for clarifications, decisions, and feedback
3. If this is a re-analysis (feedback provided), focus on addressing the feedback
4. Map requirements to specific code areas that need modification

## Phase 3: Complexity Assessment

Assess complexity using `@skills/complexity-detection/` patterns:

| Tier | Criteria |
|------|----------|
| **low** | Single file change, clear requirement, no architectural impact |
| **medium** | Multiple files, some design decisions needed, moderate scope |
| **high** | Cross-cutting changes, architectural decisions, significant risk |

## Phase 4: Confidence Scoring

Score confidence across 4 dimensions (0-100 each):

| Dimension | What it measures |
|-----------|-----------------|
| **problem** | Is the problem statement clear and unambiguous? |
| **technical** | Are the technical approach and constraints understood? |
| **scope** | Are boundaries well-defined? What is in/out of scope? |
| **risk** | Are risks, edge cases, and failure modes identified? |

Calculate overall confidence as weighted average:
- problem: 30%, technical: 30%, scope: 20%, risk: 20%

## Phase 5: Generate Clarifying Questions

For each dimension scoring below 90, generate targeted questions:

- Each question MUST have a `category` matching one of the 4 dimensions
- Each question MUST have a `header` (short label) and `question` (full text)
- Each question MUST have `options` -- an array of labeled choices with descriptions
- Each question MUST have `multiSelect` (boolean) indicating if multiple options can be chosen
- Options SHOULD include a recommended choice where applicable (mark with "(Recommended)" in label)
- Questions should be actionable -- answerable by someone familiar with the project
- Limit to 5 questions maximum to avoid overwhelming the reviewer

## Phase 6: Implementation Plan

Generate a plan ONLY if overall confidence >= 70.

Plan requirements:
- Step-by-step with numbered steps
- Each step specifies files to modify or create
- Each step specifies tests to write
- Steps are ordered by dependency (foundations first)
- Plan follows TDD approach: test first, then implement
- Plan respects existing project conventions discovered in Phase 1
- Plan validates against SOLID principles (`@skills/code-code-quality/`)

If confidence < 70, set `plan` to `null` and rely on questions to gather missing information.

## Phase 7: Session Files

Produce session files for branch persistence:

| File | Content |
|------|---------|
| `analysis.md` | Codebase analysis summary, relevant files found, tech stack notes |
| `decisions.md` | Design decisions made, trade-offs considered, assumptions documented |

Session files allow subsequent runs (after human feedback) to build on prior analysis without starting from scratch.

## Output Format

Output MUST be valid JSON matching this exact schema. The Python caller enforces this via `output_format`.

```json
{
  "analysis": "string — codebase analysis summary",
  "questions": [
    {
      "category": "problem | technical | scope | risk",
      "question": "Full question text",
      "header": "Short label",
      "options": [
        {
          "label": "Option A (Recommended)",
          "description": "Why this option"
        }
      ],
      "multiSelect": false
    }
  ],
  "confidence": {
    "overall": 85,
    "problem": 90,
    "technical": 80,
    "scope": 85,
    "risk": 85
  },
  "plan": "## Step 1: ...\n\n## Step 2: ...\n\n(or null if confidence < 70)",
  "complexity": "low | medium | high",
  "session_files": {
    "analysis.md": "# Analysis\n\n...",
    "decisions.md": "# Decisions\n\n..."
  }
}
```

## Constraints

- **Read-only**: Do NOT modify any files in the repository. Analysis only.
- **No git operations**: Do NOT run git commands that modify state.
- **Deterministic**: Same input should produce consistent output structure.
- **Time-bounded**: Limit codebase exploration to files relevant to the issue.
- **No external calls**: Do NOT make HTTP requests or access external services.

</instructions>

## References

- @skills/complexity-detection/ -- Complexity tier assessment
- @skills/interview/ -- Confidence dimension model
- @skills/code-code-quality/ -- SOLID principles for plan validation
