# Docker Compose + PostgreSQL + NGINX: Production Baseline

This is your recommended starting point for production deployments. It's proven, scalable to small/medium workloads, and easy to upgrade to Kubernetes later.

**Time to complete:** 15 minutes  
**Requirements:** Docker & Docker Compose installed

## Architecture Overview

```
External Traffic (HTTPS)
    ↓
┌──────────────────┐
│ NGINX Proxy      │  - TLS termination
│ (reverse proxy)  │  - Load balancing
└────────┬─────────┘
         │ (HTTP)
    ┌────┴────────────────────────────┐
    ▼                                 ▼
┌─────────────────┐           ┌─────────────────┐
│ n8n instance    │           │ (optional: n8n  │
│ (main + exec)   │           │  worker layer)  │
└────────┬────────┘           └────────┬────────┘
         │                            │
         └──────────────┬─────────────┘
                        ▼
                   ┌──────────────┐
                   │ PostgreSQL   │  - Durable metadata
                   │              │  - Credentials vault
                   └──────────────┘
```

## Files

All files are in `examples/docker-compose/`:

- `.env.example` — Configuration template
- `docker-compose.yml` — Multi-service stack
- `nginx.conf` — Reverse proxy config

## Step-by-Step Deployment

### Step 1: Prepare Configuration

```bash
cd examples/docker-compose
cp .env.example .env
```

Edit `.env` to customize:

```bash
# Admin credentials (change these!)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=use-a-strong-password-here

# Encryption key (generate fresh)
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Database password
DB_POSTGRESDB_PASSWORD=use-a-strong-db-password

# Your domain/hostname
N8N_HOST=n8n.example.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.example.com
```

### Step 2: Start Services

```bash
docker compose up -d
```

**What starts:**
- PostgreSQL (port 5432, internal only)
- n8n (port 5678, internal only)
- NGINX (port 80, external)

### Step 3: Verify Health

```bash
# Check all services running
docker compose ps

# Expected output:
# NAME          STATUS
# postgres      Up (healthy)
# n8n           Up
# nginx         Up

# Check n8n startup logs
docker compose logs n8n | tail -20

# Test NGINX proxy
curl -I http://localhost
# Expected: 200 or 302 (redirect to login)
```

### Step 4: Access n8n

**Via NGINX proxy:**
```
http://localhost (local)
OR
https://n8n.example.com (production with HTTPS)
```

**Login with credentials from `.env`**

### Step 5: Enable HTTPS (Production)

**Option A: Self-signed certificate (dev/test)**

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Update nginx.conf to use:
ssl_certificate /etc/nginx/certs/cert.pem;
ssl_certificate_key /etc/nginx/certs/key.pem;
```

**Option B: Let's Encrypt (production)**

```bash
docker run --rm -it \
  -v /etc/letsencrypt:/etc/letsencrypt \
  certbot/certbot certonly --standalone \
  -d n8n.example.com
```

Then update `nginx.conf` with actual certificate paths.

## Configuration Details

### Environment Variables

Key variables in `.env`:

| Variable | Purpose | Example |
| --- | --- | --- |
| N8N_ENCRYPTION_KEY | Encrypts credentials | openssl rand -base64 32 |
| N8N_BASIC_AUTH_ACTIVE | Enable auth | true |
| N8N_BASIC_AUTH_USER | Admin username | admin |
| N8N_BASIC_AUTH_PASSWORD | Admin password | SecurePassword123! |
| DB_POSTGRESDB_HOST | Database host | postgres |
| DB_POSTGRESDB_PORT | Database port | 5432 |
| DB_POSTGRESDB_DATABASE | Database name | n8n |
| DB_POSTGRESDB_USER | Database user | n8n |
| DB_POSTGRESDB_PASSWORD | Database password | GenerateStrong123 |
| N8N_HOST | Hostname/IP | n8n.example.com |
| N8N_PROTOCOL | HTTP or HTTPS | https |
| WEBHOOK_URL | Public webhook base URL | https://n8n.example.com |

### NGINX Configuration

The `nginx.conf` includes:

- HTTP → HTTPS redirect
- Reverse proxy to n8n:5678
- WebSocket upgrade support (for real-time features)
- Proper headers (X-Real-IP, X-Forwarded-For, etc.)
- Client upload size limit (50MB)
- Connection timeouts

Customize as needed for your environment.

## Operations

### Daily Checks

```bash
# Service status
docker compose ps

# Recent logs
docker compose logs -f n8n --tail 50

# Check database connectivity
docker exec postgres psql -U n8n -d n8n -c "SELECT 1;"
```

### Backup Database

```bash
docker exec postgres pg_dump -U n8n -d n8n | \
  gzip > n8n_backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Verify backup
gunzip -t n8n_backup_*.sql.gz
```

### Stop/Restart

```bash
# Graceful shutdown
docker compose down

# Restart all services
docker compose restart

# Restart single service
docker compose restart n8n
```

### View Detailed Logs

```bash
# n8n application logs
docker compose logs n8n

# PostgreSQL logs
docker compose logs postgres

# NGINX logs
docker compose logs nginx

# Follow logs (streaming)
docker compose logs -f n8n
```

## Scaling (Next Steps)

### Add Queue Mode + Workers

Update `docker-compose.yml` to add:

```yaml
services:
  redis:
    image: redis:7-alpine

  n8n-worker-1:
    image: n8nio/n8n:latest
    environment:
      EXECUTIONS_MODE: worker
      QUEUE_TYPE: redis
      REDIS_URL: redis://redis:6379
```

See Phase 7 for full queue mode setup.

### Upgrade to Kubernetes

Once you're comfortable with this setup, move to Kubernetes + Helm for:
- Multi-region deployment
- Automatic scaling
- Zero-downtime updates
- Enterprise HA

See `docs/deployment/kubernetes-helm.md`.

## Troubleshooting

### "Cannot connect to database"

```bash
# Check PostgreSQL is running
docker compose ps postgres

# Check credentials in .env match docker-compose.yml
grep DB_POSTGRESDB .env

# Test connection manually
docker exec n8n psql -h postgres -U n8n -d n8n -c "SELECT 1;"
```

### "NGINX returns 502 Bad Gateway"

```bash
# Verify n8n is running and listening
docker compose ps n8n

# Check n8n logs for startup errors
docker compose logs n8n

# Verify Docker network connectivity
docker network inspect n8n_default
```

### "Workflows lost after restart"

Check that PostgreSQL data is persisted:

```bash
# Verify volume exists
docker volume ls | grep postgres

# Check n8n is configured to use PostgreSQL (not SQLite)
docker compose exec n8n env | grep DB_TYPE
# Should show: DB_TYPE=postgresdb
```

## Security Checklist

Before going to production:

- [ ] Strong encryption key set (N8N_ENCRYPTION_KEY)
- [ ] Strong admin password (not "change-me")
- [ ] Strong database password
- [ ] PostgreSQL credentials rotated
- [ ] HTTPS enabled with valid certificate
- [ ] NGINX firewall rules applied
- [ ] Secrets stored in secret manager (not .env)
- [ ] Database backups tested and scheduled
- [ ] Encryption key backed up separately
- [ ] Audit logging enabled

See `docs/security-hardening-checklist.md` for complete list.

## Next Steps

1. ✅ Deploy this stack
2. ✅ Build Phase 1-4 workflows
3. ✅ Enable queue mode (Phase 7) if you need high throughput
4. ✅ Move to Kubernetes (Phase 8) for enterprise HA
