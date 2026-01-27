# Mode: status

> **Invocation**: `/x-deploy status`

<purpose>
Check current deployment status across environments, compare versions, and report health status.
</purpose>

## Behavioral Skills

This mode activates:
- `monitoring` - Health check interpretation

<instructions>

### Phase 0: Interview Check (OPTIONAL)

For status checks, interview is typically not required unless:
- Environment specification is ambiguous ("check the deployment")
- User asks about "the deployment" without specifying which
- Multiple projects in scope

**If ambiguity detected**: Run interview with weights (problem 30%, context 40%, technical 20%, scope 10%, risk 0%).

---

### Phase 1: Identify Target Environments

Determine which environments to check:

| Option | Scope |
|--------|-------|
| All | Development, staging, production |
| Specific | User-specified environment |
| Current | Most recently deployed |

If scope unclear, use AskUserQuestion:

```json
{
  "questions": [{
    "question": "Which environment(s) should I check?",
    "header": "Scope",
    "options": [
      {"label": "All environments (Recommended)", "description": "Dev, staging, and production"},
      {"label": "Production only", "description": "Check production status"},
      {"label": "Development", "description": "Check dev environment"}
    ],
    "multiSelect": true
  }]
}
```

### Phase 2: Query Deployment Status

For each environment, gather:

1. **Version information**
   - Deployed version/tag
   - Deployment timestamp
   - Deployer (if available)

2. **Health status**
   - Health endpoint response
   - Recent error rates
   - Response times

### Phase 3: Compare Versions

Create comparison matrix:

```
| Environment | Version | Deployed | Health |
|-------------|---------|----------|--------|
| development | v1.2.4  | 2h ago   | ✅     |
| staging     | v1.2.3  | 1d ago   | ✅     |
| production  | v1.2.2  | 3d ago   | ✅     |
```

Highlight:
- Version drift between environments
- Stale deployments
- Health issues

### Phase 4: Report Health Status

Present status summary:

```markdown
## Deployment Status

### Overview
- **Latest version**: v1.2.4
- **Production version**: v1.2.2 (2 versions behind)

### Environment Health

| Env | Status | Notes |
|-----|--------|-------|
| dev | ✅ Healthy | Latest version |
| stg | ✅ Healthy | 1 version behind |
| prd | ✅ Healthy | 2 versions behind |

### Recommendations
- Consider promoting v1.2.3 to production
- Staging has been idle for 1 day
```

</instructions>

<critical_rules>
1. **Report factual status** - No assumptions about health
2. **Highlight version drift** - When environments are out of sync
3. **Flag stale deployments** - When promotion is overdue
</critical_rules>

<decision_making>
**Execute autonomously when**:
- Clear environment scope
- Status check is informational only

**Use AskUserQuestion when**:
- Environment specification ambiguous
- Multiple projects in scope
- User might want detailed breakdown
</decision_making>

## References

- SKILL.md - Deployment workflow overview
- mode-deploy.md - Deployment procedures
- mode-rollback.md - Rollback procedures

<success_criteria>
- [ ] Environment(s) identified
- [ ] Current versions retrieved
- [ ] Health status checked
- [ ] Version comparison provided
- [ ] Recommendations offered (if applicable)
</success_criteria>
