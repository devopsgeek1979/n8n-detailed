# Phase 7: Administration & Operations

Scale n8n to handle high throughput. Master queue mode, workers, monitoring, and operational excellence.

**Time to complete:** 3 hours  
**Prerequisites:** Phase 2 (Docker Compose setup), n8n running with PostgreSQL

## What You'll Learn

- Queue mode architecture (main + workers)
- Redis for distributed job queues
- Worker scaling and load balancing
- Execution logs and history
- Backup and disaster recovery
- Workflow versioning and rollback
- Resource monitoring and alerting

## Core Concepts

### Queue Mode: Why and How

**Default n8n:** Single instance runs everything
```
[Webhook] → [n8n main] → Process workflow → [Done]
```

**Problem:** If processing takes 10 seconds and 100 webhooks arrive, bottleneck!

**Solution: Queue Mode**
```
[Webhook] → [n8n main] → [Redis Queue] → [Worker 1]
                                       → [Worker 2]
                                       → [Worker 3]
```

Main instance handles requests quickly; workers process in parallel.

**Benefits:**
- Handle 10x+ more throughput
- Separate concerns (scheduling vs execution)
- Scale workers independently
- Resilient: if one worker fails, queue persists

### Architecture with Queue Mode

```
┌──────────────┐
│   Webhooks   │
│   Triggers   │
└────────┬─────┘
         │
         ▼
┌──────────────────┐
│   n8n Main       │  (no execution)
│  - UI/Editor     │  Just scheduling &
│  - Credentials   │  webhook receiving
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Redis Queue    │  Job queue
│  (persistent)    │
└────────┬─────────┘
         │
    ┌────┴────┬──────────┬──────────┐
    ▼         ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Worker 1│ │Worker 2│ │Worker 3│ │Worker 4│  Execution
└────────┘ └────────┘ └────────┘ └────────┘
    │         │          │          │
    └────────────┬────────────────┘
                 ▼
            ┌──────────────┐
            │ PostgreSQL   │  Results &
            │ (results)    │  History
            └──────────────┘
```

### Environment Setup for Queue Mode

```bash
# Main instance
export EXECUTIONS_MODE=queue
export QUEUE_TYPE=redis
export REDIS_URL=redis://redis:6379

# Worker instances
export EXECUTIONS_MODE=worker
export QUEUE_TYPE=redis
export REDIS_URL=redis://redis:6379
```

## Hands-on: Enable Queue Mode

### Lab 1: Single Main + 2 Workers (30 minutes)

**Goal:** Set up queue mode with 1 main and 2 workers

**Docker Compose with queue mode:**

```yaml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: n8n
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  n8n-main:
    image: n8nio/n8n:latest
    environment:
      EXECUTIONS_MODE: queue
      QUEUE_TYPE: redis
      REDIS_URL: redis://redis:6379
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      # ... other DB settings
    depends_on:
      - redis
      - postgres

  n8n-worker-1:
    image: n8nio/n8n:latest
    environment:
      EXECUTIONS_MODE: worker
      QUEUE_TYPE: redis
      REDIS_URL: redis://redis:6379
    depends_on:
      - redis

  n8n-worker-2:
    image: n8nio/n8n:latest
    environment:
      EXECUTIONS_MODE: worker
      QUEUE_TYPE: redis
      REDIS_URL: redis://redis:6379
    depends_on:
      - redis

volumes:
  postgres_data:
```

**Steps:**

1. Update `examples/docker-compose/docker-compose.yml` with above
2. Start stack: `docker compose up -d`
3. Verify: `docker compose ps` (should show main + 2 workers + redis + postgres)
4. Check logs: `docker logs n8n-worker-1`

### Lab 2: Monitor Queue Depth & Worker Health (20 minutes)

**Goal:** Understand queue metrics and worker status

```bash
# Check Redis queue
docker exec redis redis-cli INFO | grep keys

# See how many jobs are queued
docker exec redis redis-cli LLEN n8n_queue_standard

# Monitor worker connections
docker exec redis redis-cli CLIENT LIST

# View worker logs in real-time
docker logs -f n8n-worker-1
```

### Lab 3: Load Testing (20 minutes)

**Goal:** Verify queue handles concurrent load

Create a test workflow:

```
[Webhook] → [Wait 5 seconds] → [Done]
```

Send parallel requests:

```bash
for i in {1..20}; do
  curl -X POST http://localhost/webhook/test \
    -H "Content-Type: application/json" \
    -d "{\"id\": $i}" &
done
wait

# Watch workers process in parallel
docker logs -f n8n-worker-1 | grep "Processing"
```

## Backup & Disaster Recovery

### What to Backup

1. **PostgreSQL database** (critical!)
   - All workflow definitions
   - Execution history
   - Credentials (encrypted)
2. **Encryption key** (separate from DB!)
3. **Workflows as JSON** (optional, for Git)
4. **Configuration & secrets**

### Backup Strategy

```bash
# Daily PostgreSQL backup
docker exec postgres pg_dump -U n8n -d n8n \
  | gzip > n8n_backup_$(date +%Y%m%d).sql.gz

# Store encryption key separately (secret manager)
echo $N8N_ENCRYPTION_KEY > ~/.n8n_encryption_key
chmod 600 ~/.n8n_encryption_key

# Archive everything
tar -czf n8n_full_backup_$(date +%Y%m%d).tar.gz \
  n8n_backup_*.sql.gz \
  ~/.n8n_encryption_key
```

### Recovery Procedure

```bash
# Restore database
gunzip < n8n_backup_20250415.sql.gz | \
  docker exec -i postgres psql -U n8n -d n8n

# Restore encryption key
export N8N_ENCRYPTION_KEY=$(cat ~/.n8n_encryption_key)

# Restart n8n
docker compose restart n8n-main
```

## Monitoring & Alerting

### Key Metrics

| Metric | Target | Alert Threshold |
| --- | --- | --- |
| Queue length | 0-10 | > 100 |
| Worker CPU | < 70% | > 85% |
| Worker memory | < 80% | > 90% |
| Failed executions | < 1% | > 5% |
| DB connection pool | < 80% | > 90% |
| Redis memory | < 80% | > 90% |

### Simple Monitoring (Cron-based)

Create a workflow that runs every 5 minutes:

```
[Cron: 5 minutes]
  ↓
[Redis: Check queue length]
  ↓
[HTTP: Get PostgreSQL metrics]
  ↓
[Conditional: Thresholds exceeded?]
  ├─ YES → [Slack: Alert ops]
  └─ NO → [NoOp]
```

## Success Criteria

✅ Enable queue mode with Redis  
✅ Deploy 2+ workers alongside main  
✅ Verify queue processes jobs in parallel  
✅ Create and test backup procedure  
✅ Monitor key metrics  

## Next Steps

Queue mode is ready! Move to **Phase 8: Scaling & High Availability** to deploy to Kubernetes.
