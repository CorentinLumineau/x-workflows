# Mode: refine

> **Invocation**: `/x-prompt refine` or `/x-prompt improve`

<purpose>
Iteratively improve an existing prompt based on user feedback or identified weaknesses.
</purpose>

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score
3. **If confidence < 100%** - Ask clarifying questions
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: "refine", "improve", "iterate", "update", "fix prompt".

---

### Phase 1: Input Collection

Gather the existing prompt:

```json
{
  "questions": [{
    "question": "Please share the prompt you want to refine.",
    "header": "Input",
    "options": [
      {"label": "Paste prompt", "description": "I'll paste the existing prompt"},
      {"label": "Recent output", "description": "Use the prompt from our last enhancement"}
    ],
    "multiSelect": false
  }]
}
```

---

### Phase 2: Issue Identification

Analyze the prompt and identify improvement areas:

```json
{
  "questions": [{
    "question": "What aspect of the prompt needs improvement?",
    "header": "Issue",
    "options": [
      {"label": "Clarity", "description": "Instructions are confusing or ambiguous"},
      {"label": "Completeness", "description": "Missing important context or constraints"},
      {"label": "Output quality", "description": "LLM responses aren't meeting expectations"},
      {"label": "Structure", "description": "Organization or formatting needs work"}
    ],
    "multiSelect": true
  }]
}
```

---

### Phase 3: Targeted Refinement

Based on identified issues:

**For Clarity issues:**
- Simplify complex sentences
- Add explicit step-by-step instructions
- Define ambiguous terms
- Use concrete examples

**For Completeness issues:**
- Add missing context sections
- Specify edge cases to handle
- Include failure scenarios
- Add success criteria

**For Output Quality issues:**
- Strengthen output_format specifications
- Add few-shot examples showing desired output
- Include negative examples (what NOT to do)
- Add validation checkpoints

**For Structure issues:**
- Reorder sections logically
- Group related instructions
- Add section headers
- Improve XML nesting

---

### Phase 4: Delta Presentation

Show changes clearly:

1. **Highlight modifications** - Use diff-style presentation when helpful
2. **Explain rationale** - Brief note on why each change improves the prompt
3. **Present full refined prompt** - In fenced code block
4. **Refresh skill suggestions** - If the prompt's intent changed during refinement, update the suggested skills and workflow chain (see `mode-create.md` Phase 5 for routing logic)

Example output:
````markdown
**Changes made:**
- Clarified the output format requirement
- Added constraint for error handling
- Included chain-of-thought guidance

**Refined prompt:**
```xml
<purpose>
[Updated purpose]
</purpose>
...
```

**Suggested Execution** (updated):

| Skill | Why |
|-------|-----|
| `/x-implement` | Prompt describes building a new feature |

**Quick start**: `/x-implement` with your refined prompt above.
````

---

### Phase 5: Iteration Loop

Offer continued refinement:

```json
{
  "questions": [{
    "question": "How does this look?",
    "header": "Status",
    "options": [
      {"label": "Perfect", "description": "Ready to use"},
      {"label": "More refinement", "description": "Need additional changes"},
      {"label": "Try different approach", "description": "Start fresh with new direction"}
    ],
    "multiSelect": false
  }]
}
```

If "More refinement" selected, loop back to Phase 2.
If "Try different approach" selected, switch to `mode-create.md`.

</instructions>

<critical_rules>
1. **Preserve intent** - Don't change the core purpose unless requested
2. **Minimal changes** - Make targeted fixes, not wholesale rewrites
3. **Explain changes** - User should understand what changed and why
4. **Maintain structure** - Keep XML well-formed throughout
5. **No file persistence** - Output is text only
</critical_rules>

<success_criteria>
- [ ] Existing prompt analyzed
- [ ] Issues identified with user
- [ ] Targeted improvements applied
- [ ] Changes clearly explained
- [ ] Refined prompt in copy-ready format
- [ ] Skill suggestions refreshed if intent changed
- [ ] User satisfied or iteration offered
</success_criteria>

## References

- `templates/xml-schema.md` - XML structure template
- `mode-create.md` - For starting fresh
