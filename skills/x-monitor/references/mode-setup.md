# Mode: setup

> **Invocation**: `/x-monitor` or `/x-monitor setup`

<purpose>
Set up monitoring infrastructure with golden signals, SLOs, and the three pillars of observability (metrics, logs, traces).
</purpose>

## Behavioral Skills

This mode activates:
- `interview` - Phase 0 confidence gate
- `monitoring` - Golden signals, SLOs, observability patterns

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Service discovery, dependency mapping | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Monitoring tool documentation (Prometheus, Grafana, etc.) |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 25%, technical 30%, scope 15%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research: Existing monitoring stack, service dependencies, SLO requirements
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Monitoring scope unclear, SLO targets undefined, tool selection needed, service boundaries unknown.

---

### Phase 1: Discover Services and Dependencies

Map the system:

1. **Service inventory**
   - List all services/applications
   - Identify service boundaries
   - Map dependencies

2. **Current monitoring state**
   - What's already monitored?
   - Existing tools and dashboards
   - Known blind spots

Use exploration agent if complex:

```
Task(
  subagent_type: "ccsetup:x-explorer",
  model: "haiku",
  prompt: "Map services and dependencies for monitoring setup"
)
```

### Phase 2: Define Golden Signals Per Service

For each service, define the four golden signals:

| Signal | What to Measure | Example Metrics |
|--------|-----------------|-----------------|
| **Latency** | Request duration | p50, p95, p99 response time |
| **Traffic** | Request volume | requests/second, active users |
| **Errors** | Failure rate | error rate %, 5xx count |
| **Saturation** | Resource usage | CPU, memory, queue depth |

### Phase 3: Set SLO Targets

Define Service Level Objectives:

```yaml
service: api-gateway
slos:
  availability: 99.9%  # 8.76h downtime/year
  latency:
    p50: 100ms
    p95: 250ms
    p99: 500ms
  error_rate: <0.1%
```

If targets unclear, use AskUserQuestion:

```json
{
  "questions": [{
    "question": "What availability target should we aim for?",
    "header": "SLO",
    "options": [
      {"label": "99.9% (Recommended)", "description": "~8.76 hours downtime/year"},
      {"label": "99.5%", "description": "~1.83 days downtime/year"},
      {"label": "99.99%", "description": "~52 minutes downtime/year"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 4: Configure Metrics Collection

Set up metrics infrastructure:

1. **Instrumentation**
   - Add metrics to application code
   - Use standard libraries (Prometheus client, OpenTelemetry)
   - Follow naming conventions

2. **Collection**
   - Configure scrape targets
   - Set scrape intervals
   - Define retention

3. **Storage**
   - Time-series database (Prometheus, InfluxDB)
   - Retention policies
   - Aggregation rules

### Phase 5: Set Up Log Aggregation

Configure centralized logging:

1. **Log format standardization**
   - Structured logging (JSON)
   - Consistent field names
   - Correlation IDs

2. **Collection pipeline**
   - Log shippers (Fluentd, Filebeat)
   - Processing/parsing
   - Storage (Elasticsearch, Loki)

### Phase 6: Enable Tracing

Set up distributed tracing:

1. **Instrumentation**
   - Trace context propagation
   - Span creation
   - Tag/attribute standards

2. **Collection**
   - Trace collector (Jaeger, Zipkin)
   - Sampling strategy
   - Storage backend

</instructions>

<critical_rules>
1. **Cover all four golden signals** for each service
2. **Define SLOs before alerting** - Alerts should be SLO-based
3. **Standardize naming** - Consistent metric/log naming
4. **Enable correlation** - Link metrics, logs, traces via trace IDs
</critical_rules>

<decision_making>
**Execute autonomously when**:
- Clear service scope
- Monitoring stack already chosen
- SLO targets defined

**Use AskUserQuestion when**:
- Service boundaries unclear
- Tool selection needed
- SLO targets undefined
- Budget/resource constraints
</decision_making>

## References

- SKILL.md - Monitoring overview
- mode-alert.md - Alerting configuration
- mode-dashboard.md - Dashboard creation

<success_criteria>
- [ ] Services mapped with dependencies
- [ ] Golden signals defined for each service
- [ ] SLOs documented
- [ ] Metrics collection configured
- [ ] Logs aggregated
- [ ] Tracing enabled
- [ ] All pillars correlated
</success_criteria>
