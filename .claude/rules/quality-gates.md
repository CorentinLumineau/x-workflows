# x-workflows Quality Gates

## Quality Gates

Before merging changes to x-workflows:

- [ ] Every skill has a `SKILL.md` file
- [ ] Every mode has a corresponding reference file
- [ ] No ccsetup command/agent dependencies
- [ ] Knowledge references point to x-devsecops (not inline)
- [ ] Skills are agent-agnostic (no Claude Code specific syntax)
- [ ] Steps are actionable (HOW, not WHAT)

---

## Skill Structure Template

```
skills/{skill-name}/
├── SKILL.md              # Main skill definition
├── references/
│   ├── mode-{mode1}.md   # Mode-specific guidance
│   └── mode-{mode2}.md
├── playbooks/            # Optional: complex scenarios
│   └── {playbook}.md
└── templates/            # Optional: output templates
    └── {template}.md
```
