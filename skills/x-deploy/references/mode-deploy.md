# Mode: deploy

> **Invocation**: `/x-deploy` or `/x-deploy deploy`

<purpose>
Deploy application to target environment with comprehensive safety checks, rollback preparation, and post-deployment monitoring.
</purpose>

## Behavioral Skills

This mode activates:
- `interview` - Phase 0 confidence gate (CRITICAL for production)
- `infrastructure` - IaC patterns, Docker, Terraform
- `ci-cd` - Pipeline deployment patterns

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Infrastructure discovery | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Infrastructure documentation lookup |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 10%, context 20%, technical 20%, scope 10%, risk **40%**)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (infrastructure docs, CI/CD configs, runbooks)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Target environment unclear, production deployment, no rollback plan, database migrations present, feature flags not configured.

---

### Phase 1: Pre-deployment Verification

Run all quality gates before deployment:

1. **Build verification**
   - [ ] Build succeeds without errors
   - [ ] All tests pass
   - [ ] Linting and type checking pass

2. **Version verification**
   - [ ] Version tag exists
   - [ ] Changelog updated
   - [ ] Dependencies locked

### Phase 2: Environment Identification

Identify target environment and requirements:

| Environment | Approval | Verification |
|-------------|----------|--------------|
| development | None | Basic smoke tests |
| staging | Optional | Full test suite |
| production | **Required** | Full + smoke + monitoring |

If environment not specified, use AskUserQuestion:

```json
{
  "questions": [{
    "question": "Which environment should I deploy to?",
    "header": "Target",
    "options": [
      {"label": "development", "description": "No approval required"},
      {"label": "staging", "description": "Pre-production verification"},
      {"label": "production", "description": "Requires explicit approval"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 3: Approval Check (Production)

For production deployments:

1. **STOP and request explicit approval**
2. **Present deployment summary**:
   - Version being deployed
   - Changes since last deployment
   - Database migrations (if any)
   - Rollback plan
3. **Wait for user confirmation**

### Phase 4: Execute Deployment

1. **Prepare rollback**
   - Record current deployment version
   - Verify rollback procedure is documented
   - Ensure rollback can be executed quickly

2. **Deploy**
   - Execute deployment command/pipeline
   - Monitor deployment progress
   - Capture deployment logs

### Phase 5: Smoke Tests

Run post-deployment verification:

- [ ] Health endpoints responding
- [ ] Critical user flows working
- [ ] No error rate spike
- [ ] Latency within SLOs

### Phase 6: Post-deployment Monitoring

Monitor for issues:

1. **Immediate (0-15 min)**
   - Error rates
   - Response times
   - Resource utilization

2. **Short-term (15-60 min)**
   - User-reported issues
   - Logging patterns
   - Business metrics

If issues detected, recommend rollback.

</instructions>

<critical_rules>
1. **NEVER deploy to production without explicit approval**
2. **ALWAYS have rollback plan ready before deployment**
3. **ALWAYS run smoke tests after deployment**
4. **NEVER skip verification steps**
5. **ALWAYS monitor post-deployment**
</critical_rules>

<decision_making>
**Execute autonomously when**:
- Deploying to development environment
- All tests pass
- Rollback plan documented

**Use AskUserQuestion when**:
- Target environment unclear
- Production deployment (always)
- Database migrations present
- Breaking changes detected
</decision_making>

## References

- SKILL.md - Deployment workflow overview
- mode-rollback.md - Rollback procedures
- mode-status.md - Deployment status checks

<success_criteria>
- [ ] Target environment confirmed
- [ ] Approval obtained (if production)
- [ ] Pre-deployment verification passed
- [ ] Rollback plan documented
- [ ] Deployment executed successfully
- [ ] Smoke tests pass
- [ ] Post-deployment monitoring active
</success_criteria>
