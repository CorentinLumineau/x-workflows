---
name: x-troubleshoot
description: |
  Deep diagnostic analysis with hypothesis testing methodology. Debugging, code explanation.
  Activate when debugging issues, troubleshooting problems, or explaining code behavior.
  Triggers: troubleshoot, debug, diagnose, explain, trace, root cause, investigate.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-troubleshoot

Deep diagnostic analysis with systematic root cause investigation using hypothesis testing methodology.

## Modes

| Mode | Description |
|------|-------------|
| troubleshoot (default) | Complex investigation |
| debug | Code flow debugging |
| explain | Code explanation |
| feedback | Post-implementation feedback intake |

## Mode Detection

Scan user input for keywords:

| Keywords | Mode |
|----------|------|
| "feedback", "report", "found bug", "discovered", "adjustment" | feedback |
| "debug", "trace", "flow", "step through" | debug |
| "explain", "understand", "what does", "how does" | explain |
| (default) | troubleshoot |

## Execution

1. **Detect mode** from user input
2. **If no valid mode detected**, use default (troubleshoot)
3. **If no arguments provided**, ask for problem description
4. **Load mode instructions** from `references/`
5. **Follow instructions** completely

## Behavioral Skills

This workflow activates these knowledge skills:
- `debugging` - Hypothesis-driven debugging methodology

## Agent Suggestions

If your agent supports subagents, consider using:
- A debugging agent for complex multi-layer issues
- An exploration agent for codebase investigation

## Debugging Methodology

All modes follow this pattern:

```
1. Observe - Gather symptoms, error messages
2. Hypothesize - Form 2-3 potential causes
3. Test - Validate hypotheses systematically
4. Resolve - Apply fix, verify solution
```

## Escalation Rules

| Complexity | Route To |
|------------|----------|
| Clear error, obvious fix | fix mode (x-implement) |
| Need flow understanding | debug mode |
| Intermittent, multi-layer | troubleshoot mode |

## Complexity Detection

Use `complexity-detection` skill to route appropriately:

| Signal | Tier |
|--------|------|
| Clear error + line number | Simple → fix |
| "how does", "trace" | Moderate → debug |
| "intermittent", "random" | Complex → troubleshoot |

## Checklist

- [ ] Symptoms clearly documented
- [ ] Hypotheses formed
- [ ] Each hypothesis tested
- [ ] Root cause identified
- [ ] Fix verified

## When to Load References

- **For troubleshoot mode**: See `references/mode-troubleshoot.md`
- **For debug mode**: See `references/mode-debug.md`
- **For explain mode**: See `references/mode-explain.md`
- **For feedback mode**: See `references/mode-feedback.md`
