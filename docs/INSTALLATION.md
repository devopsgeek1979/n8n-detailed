# n8n Installation Guide

Complete, detailed instructions for installing n8n using all available methods.

**This guide covers:**
- System requirements and prerequisites
- 5 installation methods with step-by-step instructions
- Platform-specific guides (macOS, Linux, Windows)
- Post-installation validation and testing
- Troubleshooting for common issues
- Migration and upgrade paths

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Installation Methods Overview](#installation-methods-overview)
3. [Method 1: Docker (Fastest)](#method-1-docker-fastest)
4. [Method 2: Docker Compose (Recommended for Production)](#method-2-docker-compose-recommended-for-production)
5. [Method 3: npm (Node.js Package Manager)](#method-3-npm-nodejs-package-manager)
6. [Method 4: Binary (Self-contained)](#method-4-binary-self-contained)
7. [Method 5: Cloud Platforms](#method-5-cloud-platforms)
8. [Platform-Specific Guides](#platform-specific-guides)
9. [Post-Installation Setup](#post-installation-setup)
10. [Validation & Testing](#validation--testing)
11. [Troubleshooting](#troubleshooting)
12. [Next Steps](#next-steps)

---

## System Requirements

### Minimum Requirements

| Component | Requirement | Notes |
| --- | --- | --- |
| CPU | 2 cores | More cores = better for workers |
| RAM | 2 GB | 4 GB+ recommended for production |
| Disk | 10 GB | SSD preferred for better I/O |
| Network | Stable internet | Required for API integrations |
| Port | 5678 (n8n) | Configurable, change if needed |

### Recommended for Production

| Component | Specification |
| --- | --- |
| CPU | 4-8 cores |
| RAM | 8-16 GB |
| Disk | 50+ GB SSD |
| Network | Dedicated bandwidth (100+ Mbps) |
| Database | PostgreSQL 12+ (not SQLite) |
| Cache | Redis 6+ (for queue mode) |

### Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Opera 76+

### Network Requirements

| Port | Protocol | Purpose | Configurable |
| --- | --- | --- | --- |
| 5678 | HTTP/HTTPS | n8n UI & API | Yes |
| 3306 | TCP | MySQL (if used) | N/A |
| 5432 | TCP | PostgreSQL (if used) | N/A |
| 6379 | TCP | Redis (queue mode) | N/A |

---

## Installation Methods Overview

### Quick Comparison

| Method | Setup Time | Best For | Difficulty | Production Ready |
| --- | --- | --- | --- | --- |
| Docker | 5 min | Learning, testing | Easy | ✅ Yes |
| Docker Compose | 10 min | Production baseline | Easy | ✅ Yes |
| npm | 15 min | Development, customization | Medium | ⚠️ Some setup |
| Binary | 5 min | Air-gapped networks | Easy | ✅ Yes |
| Cloud | 10 min | Managed services | Easy | ✅ Yes |

### Decision Tree

```
Do you have Docker installed?
├─ YES
│  ├─ Want production with DB?
│  │  ├─ YES → Docker Compose (Method 2)
│  │  └─ NO → Docker (Method 1)
│  └─ Want to understand n8n better?
│     ├─ YES → npm (Method 3)
│     └─ NO → Docker (Method 1)
│
└─ NO
   ├─ Can you install Docker?
   │  ├─ YES → Install Docker, then Docker Compose
   │  └─ NO → npm or Binary
   │
   └─ Node.js already installed?
      ├─ YES → npm (Method 3)
      └─ NO → Binary (Method 4) or Docker Compose (Method 2)
```

---

## Method 1: Docker (Fastest)

**Setup time:** 5 minutes  
**Best for:** Quick testing, learning, small single-instance deployments  
**Pros:** No dependencies, portable, clean environment  
**Cons:** Data lost on container stop (unless volume mounted)  
**Production ready:** ✅ Yes (with persistent volume)

### Prerequisites

- Docker installed ([install guide](https://docs.docker.com/get-docker/))
- Docker daemon running (`docker ps` should work)
- ~1 GB disk space

### Installation

#### Step 1: Pull the image

```bash
docker pull n8nio/n8n:latest
```

#### Step 2: Run the container

**Simplest (ephemeral - data lost on stop):**

```bash
docker run -it --rm \
  -p 5678:5678 \
  -e N8N_USER_MANAGEMENT_DISABLED=false \
  n8nio/n8n:latest
```

**With persistent storage (recommended):**

```bash
docker run -it --rm \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  -e N8N_USER_MANAGEMENT_DISABLED=false \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=changeme \
  n8nio/n8n:latest
```

**With custom encryption key:**

```bash
# Generate encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)

docker run -it --rm \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  -e N8N_ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=changeme \
  n8nio/n8n:latest
```

#### Step 3: Access n8n

Open browser: `http://localhost:5678`

Login with:
- Username: `admin`
- Password: `changeme`

#### Step 4: Verify installation

```bash
# Check container is running
docker ps | grep n8n

# Check logs
docker logs <container_id>

# Test API health
curl http://localhost:5678/api/v1/health
```

### Running in Background

```bash
# Run detached (no logs output)
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n:latest

# View logs anytime
docker logs -f n8n

# Stop
docker stop n8n

# Start again
docker start n8n
```

### Environment Variables for Docker

Pass any with `-e` flag:

```bash
docker run -e VAR_NAME=value -e VAR_NAME2=value2 n8nio/n8n:latest
```

Common variables:

```bash
N8N_BASIC_AUTH_ACTIVE=true          # Enable authentication
N8N_BASIC_AUTH_USER=admin           # Admin username
N8N_BASIC_AUTH_PASSWORD=securepass  # Admin password
N8N_ENCRYPTION_KEY=your-key-here    # Encrypt credentials
N8N_HOST=localhost                  # Bind hostname
N8N_PORT=5678                       # Listen port
N8N_PROTOCOL=http                   # http or https
WEBHOOK_URL=http://localhost:5678   # Public webhook URL
```

---

## Method 2: Docker Compose (Recommended for Production)

**Setup time:** 10 minutes  
**Best for:** Production deployments, team environments, with database  
**Pros:** Multi-service orchestration, persistent storage, environment management  
**Cons:** Requires Docker Compose, slightly more complex setup  
**Production ready:** ✅ Yes (best option)

### Prerequisites

- Docker and Docker Compose installed
- Cloned n8n-devops repository
- ~2 GB disk space (includes database)

### Installation

#### Step 1: Get configuration files

```bash
cd examples/docker-compose
cp .env.example .env
```

#### Step 2: Edit .env with your values

```bash
# Edit credentials
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your-secure-password

# Generate encryption key
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
echo "N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY" >> .env

# Database credentials
DB_POSTGRESDB_PASSWORD=your-db-password
POSTGRES_NON_ROOT_PASSWORD=your-db-password

# Hostname (for production)
N8N_HOST=n8n.example.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.example.com
```

#### Step 3: Start the stack

```bash
docker compose up -d
```

**What starts:**
- PostgreSQL (database)
- n8n (application)
- NGINX (reverse proxy)

#### Step 4: Verify all services

```bash
docker compose ps
# Expected: postgres (healthy), n8n (up), nginx (up)
```

#### Step 5: Access n8n

```
http://localhost (via NGINX)
or
http://localhost:5678 (direct to n8n)
```

Login with credentials from `.env`

### Docker Compose File Structure

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DB_POSTGRESDB_USER}
      POSTGRES_PASSWORD: ${DB_POSTGRESDB_PASSWORD}
      POSTGRES_DB: ${DB_POSTGRESDB_DATABASE}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  n8n:
    image: n8nio/n8n:latest
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      # ... other env vars
    depends_on:
      postgres:
        condition: service_healthy

  nginx:
    image: nginx:1.27-alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf

volumes:
  postgres_data:
```

See `examples/docker-compose/docker-compose.yml` for complete file.

### Common Operations

```bash
# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f n8n

# Restart single service
docker compose restart n8n

# Remove everything (data deleted!)
docker compose down -v
```

---

## Method 3: npm (Node.js Package Manager)

**Setup time:** 15 minutes  
**Best for:** Development, custom node creation, source control  
**Pros:** Full control, good for customization, source code access  
**Cons:** Manual dependency management, not ideal for production without extra setup  
**Production ready:** ⚠️ Partial (requires systemd/PM2 for reliability)

### Prerequisites

- Node.js 18+ ([install](https://nodejs.org/))
- npm 8+ (comes with Node.js)
- PostgreSQL 12+ (for production)
- ~500 MB disk space

### Installation

#### Step 1: Check Node.js installation

```bash
node --version  # Should be v18+
npm --version   # Should be 8+
```

#### Step 2: Install n8n globally

```bash
npm install -g n8n
```

Or locally (for specific project):

```bash
npm init -y
npm install n8n
```

#### Step 3: Configure environment

Create `.env` file in your project directory:

```bash
cat > .env << EOF
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=changeme
EOF
```

#### Step 4: Start n8n

**Development (with auto-reload):**

```bash
n8n start
```

**With custom port:**

```bash
N8N_PORT=8000 n8n start
```

**With specific database:**

```bash
DB_TYPE=postgresdb DB_POSTGRESDB_HOST=localhost n8n start
```

#### Step 5: Access

Open `http://localhost:5678`

### For Production (npm)

Use a process manager to keep n8n running:

#### Option A: PM2

```bash
npm install -g pm2

# Create PM2 ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'n8n',
    script: 'n8n start',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      N8N_PORT: 5678,
      N8N_ENCRYPTION_KEY: process.env.N8N_ENCRYPTION_KEY,
      DB_TYPE: 'postgresdb'
    }
  }]
};
EOF

# Start with PM2
pm2 start ecosystem.config.js

# View logs
pm2 logs n8n

# Stop
pm2 stop n8n

# Monitor
pm2 monit
```

#### Option B: systemd Service

```bash
sudo tee /etc/systemd/system/n8n.service > /dev/null << EOF
[Unit]
Description=n8n Workflow Automation
After=network.target

[Service]
Type=simple
User=n8n
WorkingDirectory=/opt/n8n
EnvironmentFile=/opt/n8n/.env
ExecStart=/usr/local/bin/n8n start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable n8n
sudo systemctl start n8n
sudo systemctl status n8n
```

### Custom Node Development with npm

```bash
# Create custom node
mkdir n8n-custom-nodes
cd n8n-custom-nodes

# Create TypeScript node
cat > MyCustomNode.ts << 'EOF'
import { INodeType, INodeTypeDescription } from 'n8n-workflow';

export class MyCustomNode implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'My Custom Node',
    name: 'myCustomNode',
    group: ['transform'],
    // ... node configuration
  };
}
EOF

# Load in n8n via environment
export N8N_CUSTOM_EXTENSIONS=/path/to/n8n-custom-nodes
n8n start
```

---

## Method 4: Binary (Self-contained)

**Setup time:** 5 minutes  
**Best for:** Air-gapped networks, no dependencies, quick setup  
**Pros:** No dependencies, single executable, portable  
**Cons:** Limited to specific OS, no auto-updates  
**Production ready:** ✅ Yes (with external process manager)

### Prerequisites

- 64-bit system (Linux, macOS, Windows)
- ~200 MB disk space
- No dependencies needed

### Installation

#### Step 1: Download binary

Visit [n8n releases](https://github.com/n8n-io/n8n/releases) and download appropriate binary:

```bash
# Linux x86
wget https://github.com/n8n-io/n8n/releases/download/n8n%400.xxx.x/n8n-linux-x64
chmod +x n8n-linux-x64

# macOS
wget https://github.com/n8n-io/n8n/releases/download/n8n%400.xxx.x/n8n-macos-arm64
chmod +x n8n-macos-arm64

# Windows
# Download .exe from releases page
```

#### Step 2: Run binary

```bash
./n8n-linux-x64 start
```

Or with environment variables:

```bash
N8N_PORT=5678 ./n8n-linux-x64 start
```

#### Step 3: Access

Open `http://localhost:5678`

### For Production (Binary)

Create systemd service:

```bash
sudo tee /etc/systemd/system/n8n.service > /dev/null << EOF
[Unit]
Description=n8n Workflow Automation
After=network.target

[Service]
Type=simple
User=n8n
ExecStart=/opt/n8n/n8n-linux-x64 start
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable n8n
sudo systemctl start n8n
```

---

## Method 5: Cloud Platforms

### AWS (EC2 + RDS + ALB)

#### Prerequisites

- AWS account
- IAM permissions for EC2, RDS, ALB
- Key pair for SSH

#### Steps

```bash
# 1. Launch EC2 instance (Ubuntu 22.04 LTS, t3.medium+)
# 2. Security group: Allow 22 (SSH), 80, 443
# 3. Create RDS PostgreSQL instance (db.t3.small+)
# 4. SSH into instance and run:

sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
exit  # Re-login

# 5. Clone repo and start
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops/examples/docker-compose
cp .env.example .env

# 6. Update .env with RDS endpoint
# 7. Start
docker compose up -d

# 8. Create Application Load Balancer pointing to EC2
# 9. Attach SSL certificate (ACM)
# 10. Access via ALB DNS
```

### Google Cloud (Cloud Run + Cloud SQL)

#### Steps

```bash
# 1. Create Cloud SQL PostgreSQL instance
gcloud sql instances create n8n-db \
  --database-version POSTGRES_15 \
  --tier db-f1-micro

# 2. Create Cloud Run service
gcloud run deploy n8n \
  --image n8nio/n8n:latest \
  --platform managed \
  --memory 2Gi \
  --cpu 2 \
  --set-env-vars DB_TYPE=postgresdb,DB_POSTGRESDB_HOST=cloudsql-proxy

# 3. Configure Cloud SQL proxy
# 4. Access via Cloud Run URL
```

### Azure (App Service + Azure Database)

#### Steps

```bash
# 1. Create Resource Group
az group create --name n8n-rg --location eastus

# 2. Create Azure Database for PostgreSQL
az postgres server create \
  --resource-group n8n-rg \
  --name n8n-db-server \
  --admin-user azureuser \
  --admin-password YourPassword123!

# 3. Create App Service
az appservice plan create \
  --resource-group n8n-rg \
  --name n8n-plan \
  --sku B2 --is-linux

# 4. Deploy Docker image
az webapp create \
  --resource-group n8n-rg \
  --plan n8n-plan \
  --name n8n-app \
  --deployment-container-image-name n8nio/n8n:latest

# 5. Configure connection string to Azure Database
# 6. Access via App Service URL
```

### Heroku (Legacy - Alternative Platforms Below)

Heroku ended free tier, but alternatives exist:

- **Railway**: `railway up` deployment
- **Render**: YAML-based deployment
- **Fly.io**: Edge deployment

Example with Railway:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway init
railway up
```

---

## Platform-Specific Guides

### macOS Installation

#### Option A: Homebrew

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker
brew install docker docker-compose

# Pull and run n8n
docker pull n8nio/n8n:latest
docker run -it --rm -p 5678:5678 n8nio/n8n:latest
```

#### Option B: Via npm

```bash
# Install Node.js
brew install node

# Install n8n
npm install -g n8n

# Start
n8n start
```

#### Option C: Manual Binary

```bash
# Download macOS binary
wget https://github.com/n8n-io/n8n/releases/download/n8n%400.xxx.x/n8n-macos-arm64
chmod +x n8n-macos-arm64

# Run
./n8n-macos-arm64 start
```

#### M1/M2 (Apple Silicon) Notes

- Use `arm64` binaries, not `x86`
- Docker images support ARM natively (pull latest)
- npm installs work seamlessly

### Linux Installation

#### Ubuntu/Debian

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Clone and run
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops/examples/docker-compose
cp .env.example .env
docker compose up -d
```

#### RHEL/CentOS

```bash
# Install Docker
sudo yum install -y docker

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user
sudo usermod -aG docker $USER
newgrp docker

# Run n8n
docker compose up -d
```

### Windows Installation

#### Option A: WSL2 + Docker Desktop

```powershell
# Install WSL2
wsl --install

# Install Docker Desktop for Windows
# Download from https://www.docker.com/products/docker-desktop

# In PowerShell
cd C:\Users\YourUser\Downloads
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops\examples\docker-compose
cp .env.example .env
docker compose up -d
```

Then access: `http://localhost`

#### Option B: Direct npm

```powershell
# Install Node.js
# Download from https://nodejs.org/

# In PowerShell
npm install -g n8n
n8n start
```

#### Option C: Binary

```powershell
# Download .exe from releases
# Run directly or create shortcut
```

#### WSL2 Tips

- File sharing: Place project in `C:\Users\...\` not `C:\Program Files`
- Performance: Store Docker images on WSL filesystem
- VPN issues: Disable VPN if Docker can't reach registry

---

## Post-Installation Setup

### Step 1: Initial Configuration

After installation, access n8n UI and:

1. Create first user (if user management enabled)
2. Set up credentials for integrations
3. Configure webhook URL (for external triggers)
4. Set admin password

### Step 2: Database Verification

Verify database connection is working:

```bash
# Docker Compose
docker compose exec postgres psql -U n8n -d n8n -c "SELECT 1;"

# npm
psql -h localhost -U n8n -d n8n -c "SELECT 1;"
```

### Step 3: Generate Encryption Key

If not already done:

```bash
# Generate and save
ENCRYPTION_KEY=$(openssl rand -base64 32)
echo "ENCRYPTION_KEY=$ENCRYPTION_KEY" > ~/.n8n_encryption_key
chmod 600 ~/.n8n_encryption_key

# Use in environment
export N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
```

### Step 4: Configure Webhooks (Production)

If you plan to use webhooks:

```bash
# Set public webhook URL
export WEBHOOK_URL=https://n8n.example.com

# Restart n8n
docker compose restart n8n  # or appropriate restart command
```

### Step 5: Set Up Reverse Proxy (HTTPS)

For production, use NGINX or similar:

```nginx
server {
    listen 443 ssl http2;
    server_name n8n.example.com;

    ssl_certificate /etc/ssl/certs/n8n.crt;
    ssl_certificate_key /etc/ssl/private/n8n.key;

    location / {
        proxy_pass http://n8n:5678;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Validation & Testing

### Health Check

```bash
# API health endpoint
curl http://localhost:5678/api/v1/health
# Expected: {"status":"ok"}

# UI accessibility
curl -I http://localhost:5678
# Expected: 200 or 302
```

### Database Connection

```bash
# Test database is being used
curl http://localhost:5678/api/v1/workflows -H "Authorization: Bearer $TOKEN"
# Should return workflow list (prove DB connected)
```

### Create Test Workflow

1. UI: Create new workflow
2. Add **Cron** trigger (every 5 minutes)
3. Add **Set** node with test data
4. Activate and wait for execution
5. Check execution history

### Webhook Test

```bash
# Get webhook URL from UI
WEBHOOK_URL="http://localhost/webhook/test"

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"message":"test"}'
```

---

## Troubleshooting

### Docker Issues

#### "Cannot connect to Docker daemon"

```bash
# Check Docker is running
docker ps

# Start Docker daemon
sudo systemctl start docker

# Or on macOS
open /Applications/Docker.app
```

#### "Port 5678 already in use"

```bash
# Find process using port
lsof -i :5678  # macOS/Linux
netstat -ano | findstr :5678  # Windows

# Kill process or use different port
docker run -p 8000:5678 n8nio/n8n:latest
```

### Database Connection

#### "Cannot connect to PostgreSQL"

```bash
# Verify PostgreSQL is running
docker compose ps postgres

# Check connection string
docker compose exec postgres psql -U n8n -d n8n -c "SELECT 1;"

# Verify credentials in .env match docker-compose.yml
grep DB_POSTGRESDB .env
```

#### "Password authentication failed"

```bash
# Ensure DB password matches in:
# 1. .env
# 2. docker-compose.yml POSTGRES_PASSWORD
# 3. Docker environment variables

# Update .env and restart
docker compose restart postgres n8n
```

### npm Issues

#### "Command not found: n8n"

```bash
# Check npm installation
npm list -g n8n

# Reinstall
npm install -g n8n

# Check npm path
echo $PATH | grep npm  # Should include ~/.npm/bin
```

#### "Port already in use"

```bash
# Use different port
N8N_PORT=8000 n8n start
```

### Performance Issues

#### "n8n is slow"

```bash
# Check resource usage
docker stats

# Increase memory allocation
docker run ... -m 4g n8nio/n8n:latest

# Check database performance
# Consider adding indexes, tuning PostgreSQL
```

#### "Workflows timeout"

```bash
# Increase execution timeout
export N8N_EXECUTION_TIMEOUT=3600000  # 1 hour in ms

# Restart n8n
```

### Access Issues

#### "Cannot reach http://localhost:5678"

```bash
# Check n8n is running
docker ps | grep n8n

# Check logs for errors
docker logs n8n

# Verify port mapping
docker port n8n

# Try direct access
curl -v http://localhost:5678
```

#### "Login not working"

```bash
# Reset admin password
# Docker: Set N8N_BASIC_AUTH_PASSWORD in .env and restart
# npm: Use n8n CLI or database query

# Check user management status
docker logs n8n | grep "user management"
```

---

## Next Steps

After successful installation:

1. **Phase 1:** Read `docs/phases/phase-01-foundations.md`
2. **First Workflow:** Create a Cron-triggered workflow
3. **Webhooks:** Test webhook integrations
4. **Database:** Verify PostgreSQL persistence
5. **Production:** Follow `docs/deployment/docker-compose-postgres-nginx.md`

For deeper learning, see:
- `docs/END_TO_END_GUIDE.md` — Complete learning roadmap
- `docs/phases/` — Phase-specific documentation
- `examples/` — Ready-to-use configurations

---

## Uninstallation

### Docker

```bash
# Stop container
docker stop n8n

# Remove container
docker rm n8n

# Remove image
docker rmi n8nio/n8n:latest

# Remove volumes (caution: deletes data!)
docker volume rm n8n_data
```

### Docker Compose

```bash
cd examples/docker-compose

# Stop and remove (keep data)
docker compose down

# Stop and remove everything (deletes data!)
docker compose down -v
```

### npm

```bash
# Uninstall global
npm uninstall -g n8n

# Or remove project
rm -rf node_modules package-lock.json
```

### Binary

```bash
# Simply delete the executable
rm /path/to/n8n-linux-x64

# Remove systemd service
sudo systemctl stop n8n
sudo rm /etc/systemd/system/n8n.service
sudo systemctl daemon-reload
```

---

## Support & Resources

- **Official Docs:** https://docs.n8n.io/
- **Community:** https://community.n8n.io/
- **GitHub:** https://github.com/n8n-io/n8n
- **GitHub Issues:** https://github.com/n8n-io/n8n/issues
- **Slack Community:** [Join](https://n8n.io/slack)

Happy automation!
