# Mode: alert

> **Invocation**: `/x-monitor alert`

<purpose>
Configure alerting rules with runbooks, severity levels, and escalation paths. Create actionable, symptom-based alerts that avoid alert fatigue.
</purpose>

## Behavioral Skills

This mode activates:
- `interview` - Phase 0 confidence gate
- `monitoring` - Alerting best practices
- `incident-response` - Runbook creation, escalation paths

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 30%, technical 25%, scope 10%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research: Current alerts, on-call rotation, escalation policies, SLOs
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Alert thresholds undefined, severity classification unclear, escalation path missing, on-call rotation unknown.

---

### Phase 1: Identify Critical Paths

Map alerting priorities:

1. **Revenue-impacting paths**
   - Checkout/payment flows
   - User authentication
   - Core API endpoints

2. **User-facing services**
   - Frontend availability
   - API response times
   - Error rates

3. **Infrastructure dependencies**
   - Database health
   - Cache availability
   - Message queues

### Phase 2: Define Alert Conditions

Create symptom-based alerts (not cause-based):

**Good (symptom-based)**:
- "Error rate > 1% for 5 minutes"
- "p99 latency > 500ms for 10 minutes"
- "Availability < 99.9% over rolling hour"

**Bad (cause-based)**:
- "CPU > 80%" (may not impact users)
- "Memory > 90%" (may be normal)
- "Pod restarted" (may be expected)

Alert template:

```yaml
alert: HighErrorRate
expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.01
for: 5m
labels:
  severity: page
annotations:
  summary: "High error rate on {{ $labels.service }}"
  runbook: "https://runbooks.example.com/high-error-rate"
```

### Phase 3: Set Severity Levels

Define severity tiers:

| Severity | Criteria | Response | Notification |
|----------|----------|----------|--------------|
| **Page** | User impact, SLO at risk | Immediate | PagerDuty, phone |
| **Notify** | Degradation, needs attention | Business hours | Slack, email |
| **Log** | Informational, tracking | None | Logging only |

If classification unclear, use AskUserQuestion:

```json
{
  "questions": [{
    "question": "How should high error rate alerts be classified?",
    "header": "Severity",
    "options": [
      {"label": "Page (Recommended)", "description": "Immediate response, wake on-call"},
      {"label": "Notify", "description": "Business hours response"},
      {"label": "Log", "description": "Tracking only, no notification"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 4: Create Runbooks

Every paging alert MUST have a runbook:

```markdown
# Runbook: High Error Rate

## Alert
Error rate > 1% for 5 minutes

## Impact
Users experiencing failures on [service]

## Investigation Steps
1. Check error logs: `kubectl logs -l app=service --tail=100`
2. Check recent deployments: Was anything deployed in last hour?
3. Check dependencies: Database, cache, external APIs
4. Check traffic: Is this a traffic spike?

## Remediation
- If recent deployment: Consider rollback
- If dependency issue: Check dependency status
- If traffic spike: Scale horizontally

## Escalation
If unresolved in 15 minutes, escalate to [team lead]
```

### Phase 5: Configure Escalation

Define escalation paths:

```yaml
escalation_policy:
  name: "Primary On-Call"
  steps:
    - targets:
        - type: on_call
          id: primary
      timeout_minutes: 15
    - targets:
        - type: on_call
          id: secondary
      timeout_minutes: 15
    - targets:
        - type: user
          id: team_lead
```

### Phase 6: Test Alerts

Validate alert configuration:

1. **Syntax validation**
   - Alert rules parse correctly
   - Expressions are valid

2. **Threshold validation**
   - Would alert fire on historical data?
   - Is threshold appropriate?

3. **Notification testing**
   - Test notification channels
   - Verify runbook links work

</instructions>

<critical_rules>
1. **ALWAYS link runbook to paging alerts** - No page without runbook
2. **Alert on symptoms, not causes** - Focus on user impact
3. **AVOID alert fatigue** - Minimize noisy, non-actionable alerts
4. **Test alerts before deployment** - Validate thresholds and notifications
5. **Review alerts regularly** - Tune based on false positive rate
</critical_rules>

<decision_making>
**Execute autonomously when**:
- SLOs defined
- Severity criteria clear
- Runbook templates available

**Use AskUserQuestion when**:
- Severity classification unclear
- Escalation path undefined
- Threshold selection ambiguous
- Multiple services with different requirements
</decision_making>

## References

- SKILL.md - Monitoring overview
- mode-setup.md - Monitoring infrastructure
- mode-dashboard.md - Visualization

<success_criteria>
- [ ] Critical paths identified
- [ ] Alert conditions defined (symptom-based)
- [ ] Severity levels assigned
- [ ] Runbooks created for all paging alerts
- [ ] Escalation paths configured
- [ ] Alerts tested and validated
</success_criteria>
