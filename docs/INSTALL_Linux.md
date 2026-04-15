# Linux Installation Guide

Complete guide for installing n8n on Linux (Ubuntu, Debian, RHEL, CentOS, Fedora).

**This guide covers:**
- System requirements for Linux
- 4 installation methods optimized for Linux
- Distribution-specific setup (Ubuntu/Debian vs RHEL/CentOS)
- Systemd service configuration
- Server deployment and monitoring

---

## System Requirements (Linux)

### Supported Distributions

- Ubuntu 18.04 LTS or later (20.04, 22.04 recommended)
- Debian 10 or later
- RHEL 7 or later
- CentOS 7 or later
- Fedora 30 or later
- Amazon Linux 2

### Hardware

| Component | Requirement | Notes |
| --- | --- | --- |
| CPU | 2+ cores | More cores = better for workers |
| RAM | 2 GB minimum | 4 GB+ for production |
| Disk | 20 GB available | SSD highly recommended |
| Network | Stable connectivity | For API integrations |

---

## Method 1: Docker Compose (Recommended)

**Time:** 10 minutes  
**Best for:** Production, teams, reproducible setup

### Ubuntu/Debian

```bash
# Update package manager
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install -y docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose --version
```

### RHEL/CentOS/Fedora

```bash
# Install Docker
sudo yum install -y docker

# Start Docker daemon
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker compose --version
```

### Configure and Run

```bash
# Clone repository
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops/examples/docker-compose

# Copy and edit configuration
cp .env.example .env
nano .env  # Edit as needed

# Start services
docker compose up -d

# Verify
docker compose ps
```

---

## Method 2: npm + Node.js

**Time:** 15 minutes  
**Best for:** Development, customization

### Ubuntu/Debian

```bash
# Install Node.js from NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version  # v18+
npm --version   # 8+
```

### RHEL/CentOS/Fedora

```bash
# Install Node.js
sudo yum install -y nodejs npm

# Or use NodeSource repository for latest
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify
node --version
npm --version
```

### Install and Configure n8n

```bash
# Install globally
npm install -g n8n

# Or in specific directory
mkdir ~/n8n-app
cd ~/n8n-app
npm init -y
npm install n8n

# Create configuration
cat > ~/.n8n/.env << 'EOF'
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
N8N_PORT=5678
EOF

# Start n8n
n8n start
```

---

## Method 3: Systemd Service (npm-based)

**Time:** 20 minutes  
**Best for:** Server deployments, production with process management

### Prerequisites

```bash
# Install Node.js (see Method 2 above)
node --version
npm --version

# Install n8n globally
npm install -g n8n
```

### Create n8n User

```bash
# Create dedicated user (optional but recommended)
sudo useradd -r -s /bin/bash -d /var/lib/n8n n8n

# Or use existing user
USER=$(whoami)
```

### Create Systemd Service File

```bash
# Create configuration directory
sudo mkdir -p /etc/n8n
sudo mkdir -p /var/lib/n8n

# Create .env file
sudo tee /etc/n8n/.env > /dev/null << 'EOF'
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your-secure-password-here
N8N_ENCRYPTION_KEY=your-encryption-key-here
N8N_PORT=5678
N8N_SECURE_COOKIE=true
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=your-db-password-here
EOF

# Set permissions
sudo chown -R n8n:n8n /etc/n8n
sudo chmod 600 /etc/n8n/.env
```

### Create Systemd Service

```bash
sudo tee /etc/systemd/system/n8n.service > /dev/null << 'EOF'
[Unit]
Description=n8n Workflow Automation
After=network.target postgresql.service redis-server.service
Wants=postgresql.service

[Service]
Type=simple
User=n8n
Group=n8n
WorkingDirectory=/var/lib/n8n
EnvironmentFile=/etc/n8n/.env
ExecStart=/usr/local/bin/n8n start

# Restart policy
Restart=on-failure
RestartSec=10

# Security
NoNewPrivileges=true
PrivateTmp=true

# Resource limits
LimitNOFILE=65536
MemoryMax=4G

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable n8n

# Start service
sudo systemctl start n8n

# Check status
sudo systemctl status n8n
```

### Manage Systemd Service

```bash
# Start
sudo systemctl start n8n

# Stop
sudo systemctl stop n8n

# Restart
sudo systemctl restart n8n

# View logs (last 50 lines)
sudo journalctl -u n8n -n 50

# Follow logs in real-time
sudo journalctl -u n8n -f

# Check status
sudo systemctl status n8n
```

---

## Method 4: Binary

**Time:** 10 minutes  
**Best for:** No dependencies, air-gapped servers

### Download Binary

```bash
# Determine architecture
uname -m
# x86_64 = 64-bit Intel
# aarch64 = 64-bit ARM (including AWS Graviton)

# Download appropriate binary
# Visit: https://github.com/n8n-io/n8n/releases

# For x86_64:
curl -L https://github.com/n8n-io/n8n/releases/download/n8n%400.xxx.x/n8n-linux-x64 \
  -o /usr/local/bin/n8n
chmod +x /usr/local/bin/n8n

# For aarch64/ARM:
curl -L https://github.com/n8n-io/n8n/releases/download/n8n%400.xxx.x/n8n-linux-arm64 \
  -o /usr/local/bin/n8n
chmod +x /usr/local/bin/n8n

# Verify
/usr/local/bin/n8n --version
```

### Run Binary

```bash
# Simple start
n8n start

# Or with environment variables
export N8N_PORT=5678
export N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
n8n start
```

### Create Systemd Service for Binary

```bash
sudo tee /etc/systemd/system/n8n.service > /dev/null << 'EOF'
[Unit]
Description=n8n Workflow Automation
After=network.target

[Service]
Type=simple
User=n8n
ExecStart=/usr/local/bin/n8n start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable n8n
sudo systemctl start n8n
```

---

## Database Setup (PostgreSQL)

For production, use PostgreSQL instead of SQLite:

### Ubuntu/Debian

```bash
# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Start and enable service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create n8n database and user
sudo -u postgres psql << 'EOF'
CREATE USER n8n WITH PASSWORD 'your-password-here';
CREATE DATABASE n8n OWNER n8n;
ALTER USER n8n CREATEDB;
\q
EOF

# Test connection
psql -h localhost -U n8n -d n8n -c "SELECT 1;"
```

### RHEL/CentOS/Fedora

```bash
# Install PostgreSQL
sudo yum install -y postgresql-server postgresql-contrib

# Initialize database
sudo /usr/bin/postgresql-setup initdb

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database
sudo -u postgres psql << 'EOF'
CREATE USER n8n WITH PASSWORD 'your-password-here';
CREATE DATABASE n8n OWNER n8n;
ALTER USER n8n CREATEDB;
\q
EOF
```

---

## Server Deployment (Production Setup)

### Full Production Stack

```bash
#!/bin/bash
# Full production setup script

# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install dependencies
sudo apt install -y \
  curl \
  wget \
  git \
  build-essential \
  postgresql \
  postgresql-contrib \
  redis-server \
  nginx

# 3. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 4. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. Clone n8n-devops
git clone https://github.com/your-org/n8n-devops.git ~/n8n-devops
cd ~/n8n-devops/examples/docker-compose

# 6. Configure
cp .env.example .env
nano .env  # Edit with your values

# 7. Start
docker compose up -d

# 8. Configure NGINX
sudo cp nginx.conf /etc/nginx/sites-available/n8n
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo systemctl reload nginx

echo "Installation complete!"
```

### Firewall Setup (ufw)

```bash
# If using ufw firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

---

## Monitoring and Logging

### Monitor n8n Process

```bash
# CPU and memory usage
top -p $(pgrep -f "n8n start")

# Or use htop (install first: sudo apt install htop)
htop

# Check if running
ps aux | grep n8n

# Check port listening
sudo netstat -tlnp | grep 5678

# Using ss (newer alternative)
ss -tlnp | grep 5678
```

### Log Rotation

```bash
# If running as service, logs go to journalctl
# Automatic rotation handled by systemd

# View persistent logs
sudo journalctl -u n8n --all

# Keep logs for 30 days
sudo journalctl -u n8n --vacuum-time=30d
```

### Backup Database

```bash
# Backup PostgreSQL
sudo -u postgres pg_dump -d n8n | gzip > ~/n8n_backup_$(date +%Y%m%d).sql.gz

# Backup encryption key (store separately!)
cp ~/.n8n_encryption_key ~/.n8n_encryption_key.backup

# Full backup
tar -czf n8n_full_backup_$(date +%Y%m%d).tar.gz \
  ~/n8n_backup_*.sql.gz \
  ~/.n8n_encryption_key.backup
```

---

## Troubleshooting (Linux)

### Docker Issues

#### Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo docker ps
```

#### Cannot Connect to Daemon

```bash
# Start Docker
sudo systemctl start docker

# Enable on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

### npm Issues

#### Command Not Found

```bash
# Verify npm installation
npm list -g n8n

# Reinstall
npm install -g n8n

# Add npm to PATH (if needed)
export PATH=~/.npm/bin:$PATH
echo 'export PATH=~/.npm/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Database Issues

#### Cannot Connect to PostgreSQL

```bash
# Check PostgreSQL running
sudo systemctl status postgresql

# Start if stopped
sudo systemctl start postgresql

# Test connection
psql -h localhost -U n8n -d n8n -c "SELECT 1;"
```

#### "Password Authentication Failed"

```bash
# Reset password
sudo -u postgres psql -c "ALTER USER n8n WITH PASSWORD 'new-password';"

# Update .env file
nano /etc/n8n/.env
# Update DB_POSTGRESDB_PASSWORD

# Restart n8n
sudo systemctl restart n8n
```

### Performance Issues

#### n8n Using Too Much Memory

```bash
# Check memory usage
free -h

# See n8n process
ps aux | grep n8n | grep -v grep

# Limit memory (systemd)
# Edit /etc/systemd/system/n8n.service
# Add: MemoryMax=2G
# Reload: sudo systemctl daemon-reload
```

#### Slow Disk I/O

```bash
# Check disk usage
df -h

# Monitor I/O
iostat -x 1

# Check if SSD
lsblk -d -o name,rota
# rota=0 means SSD, rota=1 means HDD
```

---

## Auto-Update Script

Keep n8n updated:

```bash
#!/bin/bash
# /usr/local/bin/update-n8n.sh

set -e

# Pull latest image
docker pull n8nio/n8n:latest

# Stop and start
cd ~/n8n-devops/examples/docker-compose
docker compose down
docker compose up -d

# Verify
docker compose ps

echo "n8n updated successfully!"
```

```bash
# Make executable
chmod +x /usr/local/bin/update-n8n.sh

# Add to cron (weekly updates)
sudo crontab -e
# Add: 0 2 * * 0 /usr/local/bin/update-n8n.sh
```

---

## Next Steps

After successful installation:

1. ✅ Access n8n at http://localhost:5678
2. ✅ Create test workflow
3. ✅ Set up credentials
4. ✅ Enable webhooks
5. ✅ Configure backups

See main installation guide for all methods and additional help.
