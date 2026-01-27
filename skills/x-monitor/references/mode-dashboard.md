# Mode: dashboard

> **Invocation**: `/x-monitor dashboard`

<purpose>
Create monitoring dashboards for service health visualization, targeting specific audiences with appropriate metrics and layout.
</purpose>

## Behavioral Skills

This mode activates:
- `monitoring` - Dashboard best practices, golden signals

<instructions>

### Phase 0: Interview Check (OPTIONAL)

For dashboard creation, interview may be needed when:
- Target audience is unclear (ops team vs developers vs business)
- Metrics selection is ambiguous
- Dashboard scope undefined

**If ambiguity detected**: Run interview with weights (problem 30%, context 35%, technical 20%, scope 15%, risk 0%).

---

### Phase 1: Identify Dashboard Purpose

Determine dashboard type:

| Type | Purpose | Refresh Rate |
|------|---------|--------------|
| **Operational** | Real-time health monitoring | 10-30s |
| **Service** | Service-specific deep dive | 1m |
| **Business** | KPIs, conversions | 5-15m |
| **Capacity** | Resource planning | 1h |

If purpose unclear, use AskUserQuestion:

```json
{
  "questions": [{
    "question": "What is the primary purpose of this dashboard?",
    "header": "Purpose",
    "options": [
      {"label": "Operational (Recommended)", "description": "Real-time health monitoring"},
      {"label": "Service deep-dive", "description": "Detailed service metrics"},
      {"label": "Business KPIs", "description": "Business metrics and conversions"},
      {"label": "Capacity planning", "description": "Resource utilization trends"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 2: Select Target Audience

Tailor content to audience:

| Audience | Focus | Complexity |
|----------|-------|------------|
| **On-call/SRE** | Alerts, errors, quick diagnosis | High detail |
| **Developers** | Service health, deployments | Medium detail |
| **Management** | SLO status, availability | Summary only |
| **Business** | User metrics, conversions | Business terms |

### Phase 3: Choose Key Metrics

Select metrics based on purpose and audience:

**Operational Dashboard**:
- Error rate (%, count)
- Latency (p50, p95, p99)
- Request rate
- Active alerts
- Recent deployments

**Service Dashboard**:
- Golden signals for service
- Dependency health
- Resource utilization
- Recent changes

**Business Dashboard**:
- Active users
- Conversion rates
- Revenue metrics
- SLO compliance

### Phase 4: Design Layout

Follow dashboard design principles:

1. **Top row**: Summary/status panels
2. **Second row**: Primary metrics (golden signals)
3. **Lower rows**: Supporting detail

Layout template:

```
┌─────────────────────────────────────────────────┐
│ Status │ Error Rate │ Latency p99 │ Requests/s │
├─────────────────────────────────────────────────┤
│         Error Rate Over Time                    │
├─────────────────────────────────────────────────┤
│   Latency Distribution  │  Top Endpoints       │
├─────────────────────────────────────────────────┤
│         Resource Utilization                    │
└─────────────────────────────────────────────────┘
```

**Design principles**:
- Most important metrics at top
- Group related metrics together
- Use consistent colors (green=good, red=bad)
- Include time selector
- Add annotations for deployments

### Phase 5: Create Dashboard

Implement dashboard:

1. **Create panels**
   - Configure queries
   - Set appropriate visualization type
   - Configure thresholds/colors

2. **Configure variables**
   - Service/environment selectors
   - Time range options
   - Enable filtering

3. **Add annotations**
   - Deployment markers
   - Incident markers
   - Change events

### Phase 6: Validate with Stakeholders

Review with intended audience:

- [ ] Metrics are relevant to their needs
- [ ] Layout is intuitive
- [ ] Refresh rate is appropriate
- [ ] No missing critical information
- [ ] No excessive noise

</instructions>

<critical_rules>
1. **Know your audience** - Tailor content appropriately
2. **Most important at top** - Critical metrics should be immediately visible
3. **Use consistent conventions** - Colors, layouts, naming
4. **Enable filtering** - Variables for service/environment selection
5. **Avoid dashboard sprawl** - Keep dashboards focused
</critical_rules>

<decision_making>
**Execute autonomously when**:
- Clear audience and purpose
- Metrics already defined
- Standard dashboard type

**Use AskUserQuestion when**:
- Target audience unclear
- Metrics selection ambiguous
- Multiple valid layout options
- Stakeholder preferences unknown
</decision_making>

## References

- SKILL.md - Monitoring overview
- mode-setup.md - Metrics setup
- mode-alert.md - Alerting configuration

<success_criteria>
- [ ] Dashboard purpose defined
- [ ] Target audience identified
- [ ] Key metrics selected
- [ ] Layout designed with hierarchy
- [ ] Dashboard created and configured
- [ ] Stakeholder validation obtained
</success_criteria>
