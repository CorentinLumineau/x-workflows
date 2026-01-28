# Mode: create

> **Invocation**: `/x-prompt` or `/x-prompt create`
> **Legacy Command**: `/x:enhance-prompt`

<purpose>
Transform raw user prompts into well-structured, XML-tagged prompts optimized for LLM execution.
</purpose>

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 30%, context 25%, technical 25%, scope 15%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Prompt unclear, goal type unknown, output format unspecified.

---

### Phase 1: Intent Extraction

Gather core information via AskUserQuestion:

**Question 1: Raw Prompt** (text input)
```json
{
  "questions": [{
    "question": "What is the raw prompt or task you want to enhance?",
    "header": "Input",
    "options": [
      {"label": "Describe task", "description": "I'll describe what I need"},
      {"label": "Paste prompt", "description": "I have an existing prompt to enhance"}
    ],
    "multiSelect": false
  }]
}
```

**Question 2: Goal Type**
```json
{
  "questions": [{
    "question": "What type of task is this prompt for?",
    "header": "Goal",
    "options": [
      {"label": "Generate", "description": "Create new content, code, or text"},
      {"label": "Analyze", "description": "Examine, evaluate, or assess something"},
      {"label": "Transform", "description": "Convert, translate, or reformat content"},
      {"label": "Q&A", "description": "Answer questions or explain concepts"}
    ],
    "multiSelect": false
  }]
}
```

**Question 3: Detail Level**
```json
{
  "questions": [{
    "question": "How detailed should the enhanced prompt be?",
    "header": "Detail",
    "options": [
      {"label": "Concise", "description": "Essential structure only, minimal sections"},
      {"label": "Standard (Recommended)", "description": "Balanced structure with key sections"},
      {"label": "Comprehensive", "description": "Full structure with all optional sections"}
    ],
    "multiSelect": false
  }]
}
```

---

### Phase 2: Context Enrichment

Based on goal type, ask conditional questions:

**If Goal = Generate/Code:**
```json
{
  "questions": [{
    "question": "What language, framework, or format?",
    "header": "Tech",
    "options": [
      {"label": "Specify", "description": "I'll provide specific tech requirements"},
      {"label": "General", "description": "No specific tech constraints"}
    ],
    "multiSelect": false
  }]
}
```

**If Goal = Analyze:**
```json
{
  "questions": [{
    "question": "What aspects should the analysis focus on?",
    "header": "Focus",
    "options": [
      {"label": "Quality", "description": "Code quality, best practices, patterns"},
      {"label": "Security", "description": "Vulnerabilities, risks, compliance"},
      {"label": "Performance", "description": "Speed, efficiency, optimization"},
      {"label": "Custom", "description": "I'll specify the focus areas"}
    ],
    "multiSelect": true
  }]
}
```

**Enhancement Options:**
```json
{
  "questions": [{
    "question": "Which enhancements should be included?",
    "header": "Enhance",
    "options": [
      {"label": "Chain-of-thought (Recommended)", "description": "Add thinking guidance for reasoning tasks"},
      {"label": "Few-shot examples", "description": "Include example inputs/outputs"},
      {"label": "Output format", "description": "Specify exact response structure"},
      {"label": "None", "description": "Basic enhancement only"}
    ],
    "multiSelect": true
  }]
}
```

---

### Phase 3: Structure Application

Apply XML template from `templates/xml-schema.md`:

1. **Parse intent** from Phase 1 responses
2. **Map goal type** to appropriate sections
3. **Determine optional sections** based on detail level:
   - Concise: purpose, instructions, output_format
   - Standard: + context, constraints, success_criteria
   - Comprehensive: + role, examples, thinking_guidance
4. **Apply enhancements** selected in Phase 2

---

### Phase 4: Output Generation

Present the enhanced prompt:

1. **Wrap in fenced code block** for easy copying:
   ````markdown
   ```xml
   <purpose>
   [Clear, single-sentence goal statement]
   </purpose>

   <context>
   [Background information and relevant details]
   </context>

   ...
   ```
   ````

2. **Include only relevant sections** (omit empty optional sections)
3. **Ensure XML is well-formed** (proper nesting, no unclosed tags)

---

### Phase 5: Refinement Offer

After output, offer iteration:

```json
{
  "questions": [{
    "question": "Would you like to refine this prompt?",
    "header": "Next",
    "options": [
      {"label": "Done", "description": "Prompt is ready to use"},
      {"label": "Add examples", "description": "Include few-shot examples"},
      {"label": "Adjust tone", "description": "Change formality or style"},
      {"label": "Modify scope", "description": "Expand or narrow the prompt"}
    ],
    "multiSelect": false
  }]
}
```

If refinement selected, loop back to relevant phase.

</instructions>

<critical_rules>
1. **No file persistence** - Output is text only, never write files
2. **Copy-ready output** - Always use fenced code blocks
3. **LLM-agnostic** - No Claude/GPT-specific constructs
4. **Modular sections** - Omit empty optional sections
5. **Valid XML** - Well-formed, properly nested tags
</critical_rules>

<success_criteria>
- [ ] User intent clearly captured
- [ ] Goal type identified
- [ ] XML output well-formed
- [ ] All relevant sections included
- [ ] Output in fenced code block (copy-ready)
- [ ] No files written during execution
</success_criteria>

## References

- `templates/xml-schema.md` - XML structure template
- `mode-refine.md` - For iterative improvement
