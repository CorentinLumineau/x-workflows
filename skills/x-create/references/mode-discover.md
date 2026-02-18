# Mode: discover

> **Invocation**: `/x-create discover` or `/x-create` (no arguments)

<purpose>
Zero-context discovery mode. Scans the ecosystem, analyzes gaps, and presents ranked creation candidates — so users can decide what to build without already knowing the answer.
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

**Triggers for this mode**: No arguments provided, user says "what should I create", "what's missing", "discover", "gaps".

---

### Phase 1: Context Harvest

Gather ecosystem state through parallel scans.

**1a. Ecosystem inventory** (reuse Phase 0.6 output):
- Total count of skills, agents by category
- Recent additions (last 5 modified components)
- Categories with few or no entries

**1b. Session context scan**:
- Check for active initiative files in `documentation/milestones/_active/`
- Check recent git log for recent creation patterns
- Check if user recently ran x-brainstorm or x-design (session state)

**1c. Gap analysis**:

<deep-think trigger="gap-analysis">
<purpose>Cross-reference the ecosystem inventory against the component types and categories to identify meaningful gaps. Consider: which categories are underserved? Which workflows lack supporting skills? Are there agents without matching skills or vice versa? Are there knowledge domains with no coverage?</purpose>
<context>Use the ecosystem inventory from 1a and session context from 1b. Focus on gaps that would deliver practical value, not theoretical completeness.</context>
</deep-think>

Produce a gap report:
- **Missing coverage**: Categories or domains with no skills
- **Incomplete workflows**: Skills that chain-to components that don't exist
- **Imbalanced areas**: Categories with many skills but no agents, or vice versa
- **Session-relevant**: Gaps related to current initiative or recent work

---

### Phase 2: Rank Candidates

Score each gap from Phase 1 and present the top candidates.

**Scoring criteria**:

| Factor | Weight | Description |
|--------|--------|-------------|
| Ecosystem impact | 40% | How many existing components benefit |
| User relevance | 30% | Alignment with session context and recent work |
| Implementation effort | 20% | Estimated complexity (prefer quick wins) |
| Chain completeness | 10% | Fills a broken chain-to/chain-from link |

<workflow-gate id="candidate-selection">
<purpose>Present ranked creation candidates for user selection</purpose>
<context>Show 3-5 candidates with: rank, name suggestion, type (skill/agent), category, gap rationale, estimated effort (low/medium/high). Allow user to pick one, ask for more options, or describe their own idea.</context>
<options>
  <option id="select">Choose a candidate from the list</option>
  <option id="more">Show more candidates</option>
  <option id="custom">Describe my own idea instead</option>
</options>
</workflow-gate>

---

### Phase 3: Handoff

Route the selected candidate to the appropriate creation mode.

**If user selected a candidate**:
1. Pre-fill component name from candidate suggestion
2. Pre-fill description from gap rationale
3. Pre-fill category from gap analysis

**If user described a custom idea**:
1. Extract name, type, and purpose from description
2. Run duplicate check against ecosystem inventory

**Route to mode**:
- If candidate type is "skill" (behavioral, workflow, or knowledge) → switch to **skill** mode
- If candidate type is "agent" → switch to **agent** mode

Carry forward all gathered context (ecosystem inventory, gap analysis, pre-filled fields) into the target mode's Phase 1.

</instructions>

## Discover vs Direct Creation

| Aspect | Discover Mode | Skill/Agent Mode |
|--------|--------------|------------------|
| Entry | No arguments or "discover" keyword | Explicit type specified |
| User knows what to build | No | Yes |
| Ecosystem analysis | Full gap analysis | Duplicate check only |
| Output | Ranked candidates → handoff | Direct creation wizard |

<critical_rules>
1. **Never create directly** - Discover mode only suggests; creation happens in skill or agent mode
2. **Evidence-based** - Every candidate must cite a specific gap from the analysis
3. **No command mode** - Handoff targets skill or agent mode only (commands are deprecated)
4. **Carry context** - All pre-filled fields and analysis must transfer to the target mode
5. **Respect session** - Prioritize gaps relevant to current work over theoretical completeness
</critical_rules>

<success_criteria>
- [ ] Ecosystem inventory completed
- [ ] Gap analysis produced with evidence
- [ ] 3-5 candidates ranked and presented
- [ ] User selected a candidate or described custom idea
- [ ] Handoff to skill or agent mode with pre-filled context
</success_criteria>

## References

- references/ecosystem-catalog.md — Scan protocol
- references/routing-rules.md — Routing decision tree
- references/mode-skill.md — Skill creation wizard
- references/mode-agent.md — Agent creation wizard
