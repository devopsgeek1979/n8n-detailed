# Installation Quick Reference Checklist

Fast installation reference for all platforms and methods.

---

## 🐳 Docker Compose (Recommended for Most Users)

**Time:** 10 minutes | **Best for:** Production-like setup with database

### macOS & Linux

```bash
# 1. Install Docker Desktop
# - macOS: https://docs.docker.com/docker-for-mac/install/
# - Linux: https://docs.docker.com/engine/install/

# 2. Clone repository
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops

# 3. Configure
cp examples/docker-compose/.env.example .env
# Edit .env if needed: nano .env

# 4. Start
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env up -d

# 5. Access
# Browser: http://localhost
# Username: admin | Password: change-me (or from .env)

# 6. Verify
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env ps
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env logs n8n
```

### Windows

```powershell
# 1. Install Docker Desktop
# https://docs.docker.com/docker-for-windows/install/

# 2. Clone repository
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops

# 3. Configure
Copy-Item examples\docker-compose\.env.example -Destination .env
notepad .env  # Edit if needed

# 4. Start
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env up -d

# 5. Access
# Browser: http://localhost

# 6. Verify
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env ps
```

---

## 📦 npm Installation

**Time:** 5 minutes | **Best for:** Development, quick testing

### All Platforms

```bash
# 1. Install Node.js (v18+)
# https://nodejs.org/

# 2. Install n8n globally
npm install -g n8n

# 3. Start
n8n start

# 4. Access
# Browser: http://localhost:5678

# 5. Create .env for next run (optional)
export N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
export N8N_BASIC_AUTH_ACTIVE=true
export N8N_BASIC_AUTH_USER=admin
export N8N_BASIC_AUTH_PASSWORD=changeme
n8n start
```

### macOS with Homebrew

```bash
# 1. Install Node.js
brew install node

# 2. Install n8n
npm install -g n8n

# 3. Start
n8n start

# 4. Access: http://localhost:5678
```

### Windows PowerShell

```powershell
# 1. Download & install Node.js from https://nodejs.org/

# 2. Verify installation
node --version
npm --version

# 3. Install n8n
npm install -g n8n

# 4. Start
n8n start

# 5. Access: http://localhost:5678
```

---

## 🐧 Linux Systemd Service (Production)

**Time:** 15 minutes | **Best for:** Linux servers, background service

### Ubuntu/Debian

```bash
# 1. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 2. Create n8n user
sudo useradd -m -s /bin/bash n8n

# 3. Install n8n globally
sudo npm install -g n8n

# 4. Create systemd service
sudo tee /etc/systemd/system/n8n.service > /dev/null << 'EOF'
[Unit]
Description=n8n Workflow Automation
After=network.target
[Service]
Type=simple
User=n8n
ExecStart=/usr/local/bin/n8n start
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF

# 5. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable n8n
sudo systemctl start n8n

# 6. Check status
sudo systemctl status n8n

# 7. View logs
sudo journalctl -u n8n -f
```

### RHEL/CentOS/Fedora

```bash
# 1. Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -

# 2. Create n8n user
sudo useradd -m -s /bin/bash n8n

# 3. Install n8n globally
sudo npm install -g n8n

# 4. Create systemd service (same as Ubuntu above)
sudo tee /etc/systemd/system/n8n.service > /dev/null << 'EOF'
[Unit]
Description=n8n Workflow Automation
After=network.target
[Service]
Type=simple
User=n8n
ExecStart=/usr/local/bin/n8n start
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF

# 5. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable n8n
sudo systemctl start n8n
```

---

## 🔧 Binary Installation

**Time:** 5 minutes | **Best for:** No dependencies, quick standalone

### macOS & Linux

```bash
# 1. Download latest release
# https://github.com/n8n-io/n8n/releases

# Example for Linux:
wget https://github.com/n8n-io/n8n/releases/download/n8n@VERSION/n8n-linux-x64.tar.xz
tar -xf n8n-linux-x64.tar.xz
cd n8n

# 2. Start
./bin/n8n start

# 3. Access: http://localhost:5678
```

### Windows

```powershell
# 1. Download from: https://github.com/n8n-io/n8n/releases
# Look for: n8n-windows-x64.zip

# 2. Extract and run
cd n8n-windows-x64
.\n8n.exe start

# 3. Access: http://localhost:5678
```

---

## ☁️ Cloud Platforms (Quick Links)

| Platform | Time | Method |
| --- | --- | --- |
| AWS | 15 min | EC2 + RDS + n8n via CloudFormation |
| Google Cloud | 10 min | Cloud Run + Cloud SQL |
| Azure | 15 min | App Service + Azure Database |
| Heroku | 5 min | `git push heroku main` |
| DigitalOcean | 10 min | App Platform |

See `docs/INSTALLATION.md` for detailed cloud setup.

---

## 🔐 Encryption Key Generation

Required for production deployments:

```bash
# Linux/macOS
export N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
echo $N8N_ENCRYPTION_KEY

# Windows PowerShell
$key = [System.Convert]::ToBase64String((1..32 | ForEach-Object {Get-Random -Maximum 256}))
$env:N8N_ENCRYPTION_KEY = $key
echo $env:N8N_ENCRYPTION_KEY
```

---

## ✅ Verification Checklist

After installation, verify:

- [ ] n8n accessible at http://localhost:5678 (or your URL)
- [ ] Can login with credentials
- [ ] Create test workflow (Cron trigger + Set node)
- [ ] Workflow executes successfully
- [ ] Check logs for errors
- [ ] Database is initialized (if using Docker Compose)

```bash
# Quick health check
curl http://localhost:5678/healthz

# Test database (Docker Compose)
docker compose exec postgres psql -U n8n -d n8n -c "SELECT 1;"
```

---

## 🔴 Common Issues & Quick Fixes

| Issue | Solution |
| --- | --- |
| **Port already in use (5678)** | `n8n start --port 8000` or kill process using port |
| **Docker won't start** | `docker daemon start` or restart Docker Desktop |
| **Database connection failed** | Verify PostgreSQL is running: `docker compose ps` |
| **npm not found** | Add to PATH or restart terminal |
| **Permission denied** | Use `sudo` or check file permissions |
| **Encryption key missing** | Generate: `export N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)` |

---

## 📖 Full Documentation

| Guide | Best For |
| --- | --- |
| `docs/INSTALL_macOS.md` | macOS (Intel/Apple Silicon) specifics |
| `docs/INSTALL_Linux.md` | Linux (Ubuntu/RHEL) specifics |
| `docs/INSTALL_Windows.md` | Windows (WSL2/Docker/npm) |
| `docs/INSTALLATION.md` | Complete guide with all 5 methods |
| `docs/deployment/docker-compose-postgres-nginx.md` | Production Docker setup |
| `docs/deployment/kubernetes-helm.md` | Enterprise Kubernetes |

---

## 🚀 Next Steps After Installation

1. **First Workflow:** Create Cron + Set node workflow
2. **Learn Basics:** `docs/phases/phase-01-foundations.md`
3. **Build Real Workflows:** `docs/phases/phase-04-workflow-development.md`
4. **Add Security:** `docs/phases/phase-03-security-authentication.md`
5. **Scale to Production:** `docs/deployment/docker-compose-postgres-nginx.md`

---

**Happy Automating!** 🎉
