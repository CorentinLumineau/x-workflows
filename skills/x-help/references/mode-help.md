# Mode: help

> **Invocation**: `/x-help` or `/x-help help`
> **Legacy Command**: `/x:help`

<purpose>
Quick reference for all x/ commands and skills. Show available commands, their purposes, and usage.
</purpose>

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 30%, context 30%, technical 15%, scope 20%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Ask clarifying question
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Help topic unclear (which commands?).

**Note**: Help mode is typically low-risk - bypass often appropriate.

---

### Phase 1: Display Command Overview

```markdown
## ccsetup Commands Reference

### Implementation Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:implement` | x-implement | Feature implementation |
| `/x:fix` | x-implement fix | Bug fixing |
| `/x:improve-refactor` | x-implement refactor | Code refactoring |
| `/x:improve` | x-implement improve | Quality improvements |
| `/x:cleanup` | x-implement cleanup | Dead code removal |

### Verification Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:verify` | x-verify | Quality gates |
| `/x:build` | x-verify build | Build management |
| `/x:improve-coverage` | x-verify coverage | Coverage improvement |

### Review Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:review` | x-review | Pre-merge review |
| `/x:best-practices` | x-review audit | SOLID audit |
| `/x:improve-best-practices` | x-review improve | Quality fixes |

### Planning Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:plan` | x-plan | Implementation planning |
| `/x:brainstorm` | x-plan brainstorm | Requirements discovery |
| `/x:design` | x-plan design | Architecture design |
| `/x:analyze` | x-plan analyze | Code analysis |

### Debugging Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:troubleshoot` | x-troubleshoot | Deep investigation |
| `/x:debug` | x-troubleshoot debug | Code flow debugging |
| `/x:explain` | x-troubleshoot explain | Code explanation |

### Documentation Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:docs` | x-docs | Doc management |
| `/x:generate-docs` | x-docs generate | Create new docs |
| `/x:sync-docs` | x-docs sync | Sync with code |
| `/x:cleanup-docs` | x-docs cleanup | Remove stale docs |

### Git Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:commit` | x-git | Create commit |
| `/x:release` | x-git release | GitHub release |

### Initiative Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:initiative` | x-initiative | Create initiative |
| `/x:continue` | x-initiative continue | Resume work |
| `/x:archive` | x-initiative archive | Archive complete |
| `/x:workflow-status` | x-initiative status | View status |

### Research Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:ask` | x-research | Quick Q&A |
| `/x:deep-research` | x-research deep | Comprehensive research |

### Orchestration Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:orchestrate` | x-orchestrate | Guided workflows |
| `/x:background` | x-orchestrate background | Task management |
| `/x:agent` | x-orchestrate agent | Agent info |

### Creation Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:create-command` | x-create command | Create command |
| `/x:create-skill` | x-create | Create skill |
| `/x:create-agent` | x-create agent | Create agent |

### Setup Commands
| Command | Skill | Description |
|---------|-------|-------------|
| `/x:setup` | x-setup | Project setup |
| `/x:help` | x-help | This help |
| `/x:rules` | x-help rules | Rules management |
```

### Phase 2: Category Selection

```json
{
  "questions": [{
    "question": "Need help with a specific area?",
    "header": "Category",
    "options": [
      {"label": "Implementation", "description": "Building features"},
      {"label": "Verification", "description": "Testing, quality"},
      {"label": "Planning", "description": "Design, analysis"},
      {"label": "All commands", "description": "Full reference"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

<critical_rules>
- All commands must be current and accurate
- Categorization must reflect actual skill organization
- Provide actionable usage tips for each category
</critical_rules>

## Quick Tips

- Use `/x-{skill}` for direct skill invocation
- Use `/x-{skill} {mode}` for specific mode
- Use `--skip-routing` to bypass workflow suggestions
- Most commands accept descriptions as arguments

## References

- @core-docs/X_COMMANDS_REFERENCE.md - Full reference

<output_format>
Markdown table with command name, associated skill, and description. Category selection prompt. Quick tips for command usage.
</output_format>

<success_criteria>
- Commands listed with accurate skill mapping
- Category selection prompt interactive and responsive
- Quick tips are clear and actionable
</success_criteria>
