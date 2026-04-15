# Operations Runbook

## Daily Checks

- n8n service healthy and reachable
- Queue latency within SLO
- Failed workflow count below threshold
- DB and Redis resource usage normal

## Backup Strategy

- PostgreSQL logical backups daily
- Volume snapshots for persistent data
- Restore drill at least monthly

## Incident Response

1. Identify impacted workflows
2. Check n8n logs and failed executions
3. Verify Redis and PostgreSQL health
4. Apply rollback or disable faulty workflow
5. Document root cause and preventive action

## Capacity Management

- Scale workers based on queue depth
- Track execution duration percentiles
- Tune database indexes and connection pools
