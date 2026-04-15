# Phase 2: Installation & Environment Setup

Ready to deploy n8n? This phase covers all installation methods and production setup patterns.

**Time to complete:** 1-2 hours  
**Prerequisites:** Docker installed (or basic knowledge of your chosen installation method)

## What You'll Learn

- How to install n8n (Docker, Docker Compose, npm, binary)
- Environment configuration and secrets management
- Database choices: SQLite (dev) vs PostgreSQL (production)
- Setting up a reverse proxy (NGINX) for production patterns
- HTTPS and TLS termination
- Persistent storage and backups

## Installation Methods Explained

### Method 1: Docker (Recommended for Most Users)

**Pros:** Easy to start, production-ready, portable  
**Cons:** Requires Docker knowledge  
**Best for:** Teams, single deployments, learning

**Quick start:**

```bash
docker run -it --rm \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=yourpassword \
  n8nio/n8n
```

Then open http://localhost:5678

### Method 2: Docker Compose (Recommended for Production)

**Pros:** Multi-service orchestration, database included, closest to production  
**Cons:** Slightly more complex setup  
**Best for:** Production deployments, team environments, staging

See `examples/docker-compose/docker-compose.yml` for a complete example.

### Method 3: npm (Node.js)

**Pros:** Full control, good for customization  
**Cons:** Manual dependency management  
**Best for:** Developers, custom node development

```bash
npm install -g n8n
n8n start
```

### Method 4: Binary (Self-contained)

**Pros:** No dependencies  
**Cons:** Limited to certain platforms  
**Best for:** Quick testing, air-gapped environments

## Environment Configuration

n8n uses environment variables for all configuration. Never hardcode secrets!

### Critical Variables

| Variable | Purpose | Example |
| --- | --- | --- |
| `N8N_ENCRYPTION_KEY` | Encrypts credentials in database | `export N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)` |
| `N8N_BASIC_AUTH_ACTIVE` | Enable basic authentication | `true` |
| `N8N_BASIC_AUTH_USER` | Admin username | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | Admin password | Generate strong password |
| `DB_TYPE` | Database backend | `postgresdb` (production) or `sqlite` (dev) |
| `DB_POSTGRESDB_HOST` | PostgreSQL host | `postgres.example.com` |
| `DB_POSTGRESDB_PORT` | PostgreSQL port | `5432` |
| `DB_POSTGRESDB_DATABASE` | Database name | `n8n` |
| `DB_POSTGRESDB_USER` | DB username | `n8n_user` |
| `DB_POSTGRESDB_PASSWORD` | DB password | Generate strong password |
| `N8N_HOST` | Hostname or IP | `n8n.example.com` |
| `N8N_PROTOCOL` | HTTP or HTTPS | `https` (production) |
| `WEBHOOK_URL` | Public webhook base URL | `https://n8n.example.com` |
| `REDIS_URL` | Redis connection (queue mode) | `redis://redis:6379` |

### Generating Secure Keys

```bash
# Generate N8N_ENCRYPTION_KEY
openssl rand -base64 32

# Generate strong password
openssl rand -base64 20

# Test PostgreSQL connection
psql -h localhost -U n8n -d n8n -c "SELECT 1;"
```

## SQLite vs PostgreSQL

### SQLite (Development)

```
DB_TYPE=sqlite
```

**Pros:** No setup, single file, good for learning
**Cons:** Not thread-safe, single user, no backup tools
**Use when:** Learning, local testing, small team projects
**Limitation:** Can't scale with workers or queue mode

**Note:** Default n8n setup uses SQLite. OK for testing, not for production.

### PostgreSQL (Production)

```
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
```

**Pros:** Scalable, ACID transactions, production support, backup tools, HA capable
**Cons:** Requires separate database server
**Use when:** Production, multiple workers, HA, compliance required
**Why:** Supports queue mode and horizontal scaling

**Setup PostgreSQL:**

```bash
docker run --rm -d \
  -e POSTGRES_USER=n8n \
  -e POSTGRES_PASSWORD=your_password \
  -e POSTGRES_DB=n8n \
  -p 5432:5432 \
  postgres:16-alpine
```

## File System Structure

When n8n runs, it creates:

```
~/.n8n/
├── config.json        # Configuration
├── credentials.json   # Encrypted credentials vault
├── workflows.json     # (Optional) workflow exports
└── data/              # Logs, temporary files
```

**For Docker deployments, mount as volume:**

```bash
docker run -v n8n_data:/home/node/.n8n n8nio/n8n
```

## Reverse Proxy Setup (Production Pattern)

Never expose n8n directly to the internet. Use a reverse proxy for:

- TLS/HTTPS termination
- Load balancing (if multiple instances)
- Security headers
- Rate limiting
- Request filtering

### NGINX Configuration

```nginx
server {
    listen 80;
    server_name n8n.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name n8n.example.com;

    ssl_certificate /etc/ssl/certs/n8n.crt;
    ssl_certificate_key /etc/ssl/private/n8n.key;

    client_max_body_size 50m;

    location / {
        proxy_pass http://n8n:5678;
        proxy_http_version 1.1;
        
        # Required for WebSocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
```

See `examples/docker-compose/nginx.conf` for complete example.

## HTTPS & Let's Encrypt

For production, use valid SSL certificates:

**Option 1: Let's Encrypt with Certbot**

```bash
certbot certonly --standalone -d n8n.example.com
# Generates: /etc/letsencrypt/live/n8n.example.com/
```

**Option 2: Cloud provider (AWS ACM, Google Cloud, Azure)**

- Managed certificates, automatic renewal, no extra cost

**Option 3: Self-signed (dev/internal only)**

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

## Production Deployment Checklist

Before deploying to production:

- [ ] Set strong `N8N_ENCRYPTION_KEY`
- [ ] Use PostgreSQL (not SQLite)
- [ ] Configure reverse proxy (NGINX/Traefik)
- [ ] Enable HTTPS with valid certificates
- [ ] Set strong admin credentials
- [ ] Configure backup strategy
- [ ] Enable audit logs
- [ ] Set up monitoring and alerting
- [ ] Document all configuration
- [ ] Test recovery procedures

## Success Criteria

Before moving to Phase 3:

✅ Install n8n using Docker Compose (from `examples/`)  
✅ Access n8n at http://localhost  
✅ Verify PostgreSQL is running and connected  
✅ Understand environment variables and their purposes  
✅ Know how to generate encryption keys  
✅ Can set up NGINX reverse proxy (or understand the config)  
✅ Understand SQLite vs PostgreSQL trade-offs

## Troubleshooting

**"Cannot connect to database"**
- Check DB credentials in `.env`
- Verify database service is running: `docker compose ps`
- Test connection: `docker exec n8n psql -h postgres -U n8n -d n8n -c "SELECT 1;"`

**"Workflow data lost after restart"**
- You're using SQLite. Volume isn't mounted. Check `docker-compose.yml` volumes.

**"Port 5678 already in use"**
- Change port: `docker run -p 8000:5678 ...`

**"NGINX returns 502 Bad Gateway"**
- n8n container not accessible from NGINX. Check Docker network connectivity.

## Next Steps

You now have a working n8n deployment! Move to **Phase 3: Security & Authentication** to harden it for production.
