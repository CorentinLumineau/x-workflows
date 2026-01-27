# Mode: rollback

> **Invocation**: `/x-deploy rollback`

<purpose>
Rollback deployment to previous stable version with data impact assessment and root cause documentation.
</purpose>

## Behavioral Skills

This mode activates:
- `interview` - Phase 0 confidence gate (data loss risk assessment)
- `infrastructure` - Rollback procedures
- `incident-response` - Issue documentation

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 15%, context 20%, technical 20%, scope 5%, risk **40%**)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research: Previous stable version, migration reversibility, data impact
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Target version unclear, data loss potential, migration reversal complexity.

---

### Phase 1: Identify Failing Deployment

1. **Gather symptoms**
   - Error messages
   - Failed health checks
   - User reports
   - Monitoring alerts

2. **Confirm rollback is appropriate**
   - Is this a deployment issue (vs. data issue)?
   - Can the issue be fixed forward?
   - Is rollback safer than hotfix?

### Phase 2: Determine Rollback Target

Identify the target version:

```
Current (failing): v1.2.3
Rollback target:   v1.2.2 (last stable)
```

If target unclear, use AskUserQuestion:

```json
{
  "questions": [{
    "question": "Which version should I roll back to?",
    "header": "Target",
    "options": [
      {"label": "v1.2.2 (Recommended)", "description": "Previous stable release"},
      {"label": "v1.2.1", "description": "2 versions back"},
      {"label": "Specific version", "description": "I'll specify the version"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 3: Assess Data Migration Impact

**CRITICAL**: Evaluate data reversibility:

| Migration Type | Rollback Safety | Action |
|----------------|-----------------|--------|
| Add column | Safe | Column remains, unused |
| Add table | Safe | Table remains, unused |
| Rename column | **Risky** | May break old code |
| Drop column | **Dangerous** | Data lost |
| Data transformation | **Dangerous** | May be irreversible |

If dangerous migrations detected:
1. **STOP immediately**
2. **Present impact assessment to user**
3. **Request explicit approval with risk acknowledgment**

### Phase 4: Execute Rollback

1. **Pre-rollback checklist**
   - [ ] Target version verified
   - [ ] Data impact assessed
   - [ ] Rollback procedure documented
   - [ ] Team notified (if applicable)

2. **Execute rollback**
   - Deploy target version
   - Monitor deployment
   - Verify health checks

3. **Verify stability**
   - Health endpoints responding
   - Error rates normalized
   - User flows working

### Phase 5: Verify System Stability

Post-rollback verification:

- [ ] All health checks passing
- [ ] Error rates back to baseline
- [ ] No new issues introduced
- [ ] Critical functionality verified

### Phase 6: Document Root Cause

Create incident documentation:

```markdown
## Rollback Incident

**Date**: [timestamp]
**Failed Version**: [version]
**Rolled Back To**: [version]
**Duration**: [time]

### Symptoms
- [What was observed]

### Root Cause
- [What caused the failure]

### Resolution
- [Rollback executed]

### Prevention
- [Actions to prevent recurrence]
```

</instructions>

<critical_rules>
1. **ALWAYS verify target rollback version before executing**
2. **ASSESS data loss potential before any rollback**
3. **NEVER execute rollback with dangerous migrations without explicit user approval**
4. **DOCUMENT root cause after recovery**
5. **VERIFY stability before considering rollback complete**
</critical_rules>

<decision_making>
**Execute autonomously when**:
- Target version is clear
- No data migrations involved
- Rollback is straightforward

**Use AskUserQuestion when**:
- Target version unclear
- Data migrations present (especially drops/renames)
- Multiple rollback options available
- Partial rollback might be needed
</decision_making>

## References

- SKILL.md - Deployment workflow overview
- mode-deploy.md - Deployment procedures
- mode-status.md - Check current state

<success_criteria>
- [ ] Failing deployment identified
- [ ] Rollback target determined
- [ ] Data impact assessed
- [ ] User approval obtained (if risky migrations)
- [ ] Rollback executed successfully
- [ ] System stability verified
- [ ] Root cause documented
</success_criteria>
