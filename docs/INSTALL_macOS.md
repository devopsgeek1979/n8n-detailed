# macOS Installation Guide

Complete guide for installing n8n on macOS (Intel and Apple Silicon).

**This guide covers:**
- System requirements for macOS
- 4 installation methods optimized for macOS
- Apple Silicon (M1/M2/M3) specific guidance
- Homebrew setup
- Troubleshooting macOS-specific issues

---

## System Requirements (macOS)

### Supported macOS Versions

- macOS 11 Big Sur or later
- macOS 12 Monterey (recommended)
- macOS 13 Ventura (latest stable)
- macOS 14 Sonoma (latest)

### Hardware

| Component | Requirement | Notes |
| --- | --- | --- |
| CPU | Apple Silicon (M1+) or Intel Core i5+ | M1/M2 native support |
| RAM | 4 GB minimum | 8 GB+ recommended |
| Disk | 20 GB available | SSD highly recommended |
| Display | 1280x720 minimum | For UI development |

### Apple Silicon (M1/M2/M3/M4) Notes

All installation methods support Apple Silicon natively:
- Docker images are multi-arch (auto-selects ARM64)
- npm packages install for ARM64
- Binary releases include ARM64 build
- Performance is excellent (faster than Intel)

---

## Installation Method Comparison

| Method | Time | Best For | Difficulty | Notes |
| --- | --- | --- | --- | --- |
| Docker Desktop | 15 min | Teams, standard setup | Easy | Recommended for most |
| Homebrew + npm | 10 min | Developers, customization | Medium | Good for development |
| npm (npm installed) | 5 min | Quick testing | Easy | Fastest if Node.js ready |
| Binary | 10 min | Air-gapped, no deps | Easy | Manual management |

---

## Method 1: Docker Desktop (Recommended)

**Time:** 15 minutes  
**Best for:** Most users, teams, production-like environment

### Step 1: Install Docker Desktop

```bash
# Option A: Using Homebrew (easiest)
brew install --cask docker

# Option B: Manual download
# Visit https://www.docker.com/products/docker-desktop
# Download "Apple Silicon" or "Intel" version
# Drag Docker.app to Applications
```

### Step 2: Start Docker

```bash
# Open Launchpad or Applications folder
open /Applications/Docker.app

# Wait for Docker daemon to start (~1-2 minutes)
# Check status:
docker --version
docker ps  # Should work without error
```

### Step 3: Clone Repository and Configure

```bash
# Clone or download the repository
cd ~/projects  # or your preferred location
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops

# Copy environment template
cp examples/docker-compose/.env.example .env

# Edit .env with your values
nano .env
# Or use preferred editor:
# vim .env
# code .env
```

### Step 4: Start n8n Stack

```bash
cd examples/docker-compose

# Start all services (PostgreSQL, n8n, NGINX)
docker compose up -d

# Verify all services running
docker compose ps
```

Expected output:
```
NAME       STATUS
postgres   Up (healthy)
n8n        Up
nginx      Up
```

### Step 5: Access n8n

Open browser and navigate to:
```
http://localhost
```

Login with credentials from `.env`:
- Username: `admin`
- Password: (your password from `.env`)

### Useful Docker Commands

```bash
# View logs
docker compose logs -f n8n

# Stop all services
docker compose stop

# Start again
docker compose start

# Full restart
docker compose restart

# Stop and remove (keep data)
docker compose down

# Check resource usage
docker stats

# Access n8n container shell
docker compose exec n8n bash

# Access PostgreSQL
docker compose exec postgres psql -U n8n -d n8n
```

---

## Method 2: Homebrew + npm

**Time:** 10 minutes  
**Best for:** Developers, customization, source code access

### Step 1: Install Homebrew (if needed)

```bash
# Check if already installed
brew --version

# If not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile

# Verify installation
brew --version
```

### Step 2: Install Node.js

```bash
# Install Node.js (includes npm)
brew install node

# Verify installation
node --version  # v18+ required
npm --version   # 8+ required
```

### Step 3: Install n8n

```bash
# Install globally
npm install -g n8n

# Or in a specific project
mkdir ~/n8n-project && cd ~/n8n-project
npm init -y
npm install n8n
```

### Step 4: Create Configuration

```bash
# Create .env file
cat > ~/.n8n/.env << EOF
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
N8N_PORT=5678
EOF
```

### Step 5: Start n8n

```bash
# Simple start
n8n start

# Or with environment file
export $(cat ~/.n8n/.env | xargs)
n8n start

# With custom port
N8N_PORT=8000 n8n start
```

Visit: `http://localhost:5678`

### Running in Background (PM2)

```bash
# Install PM2
npm install -g pm2

# Start n8n with PM2
pm2 start "n8n start" --name n8n

# View logs
pm2 logs n8n

# Manage
pm2 list
pm2 stop n8n
pm2 restart n8n

# Make persistent across restarts
pm2 startup
pm2 save
```

---

## Method 3: Quick Install (npm already installed)

**Time:** 5 minutes  
**Best for:** Quick testing if Node.js already installed

### Single Command

```bash
# If Node.js already installed
npm install -g n8n && n8n start
```

Access: `http://localhost:5678`

---

## Method 4: Binary

**Time:** 10 minutes  
**Best for:** No dependencies, portable, air-gapped

### Step 1: Download Binary

```bash
# Determine your architecture
uname -m
# Intel: x86_64
# Apple Silicon: arm64

# Intel Macs - download x86 binary
# Apple Silicon - download arm64 binary

# Visit: https://github.com/n8n-io/n8n/releases
# Download appropriate macOS binary

# Or via command line:
# For Apple Silicon:
curl -L https://github.com/n8n-io/n8n/releases/download/n8n%400.xxx.x/n8n-macos-arm64 \
  -o n8n
chmod +x n8n

# For Intel:
curl -L https://github.com/n8n-io/n8n/releases/download/n8n%400.xxx.x/n8n-macos-x64 \
  -o n8n
chmod +x n8n
```

### Step 2: Run Binary

```bash
# Simple start
./n8n start

# Or with environment variables
N8N_PORT=5678 ./n8n start
```

---

## Apple Silicon Specific Tips

### All Methods Work Great on M1/M2/M3

```bash
# Verify running on ARM64 (Apple Silicon)
uname -m
# Output: arm64
```

### Docker on Apple Silicon

```bash
# Check Docker is using proper architecture
docker version | grep -i arch

# Some older images might use Rosetta 2 (compatibility mode)
# Prefer latest n8n images which are native ARM
docker pull n8nio/n8n:latest
docker inspect n8nio/n8n:latest | grep -i arch
```

### npm on Apple Silicon

```bash
# Homebrew Node.js is native ARM on M1/M2
node -p "process.arch"
# Output: arm64

# All npm packages auto-install for ARM
npm install n8n
```

### Performance Notes

- Apple Silicon provides 2-3x better CPU performance than Intel equivalents
- Rosetta 2 translation layer minimal overhead
- Recommend using native ARM versions (latest Docker images, npm packages)

---

## Troubleshooting (macOS Specific)

### Docker Desktop Won't Start

```bash
# Check if Docker app exists
ls -la /Applications/Docker.app

# Remove and reinstall
brew uninstall docker
brew install --cask docker

# Or manually:
# 1. Quit Docker from menu
# 2. Trash Docker.app from Applications
# 3. Download and reinstall from docker.com
```

### "Docker daemon is not running"

```bash
# Start Docker daemon
open /Applications/Docker.app

# Wait 1-2 minutes
# Verify
docker ps

# Or manually start daemon:
sudo /usr/local/bin/docker daemon
```

### Port 5678 Already in Use

```bash
# Find what's using port 5678
lsof -i :5678

# Kill process
kill -9 <PID>

# Or use different port
docker run -p 8000:5678 n8nio/n8n:latest
```

### "Permission denied" errors

```bash
# Add user to docker group
sudo dseditgroup -o edit -a $(whoami) -t user com.docker.vmnetd

# Or use sudo
sudo docker ps

# Restart Docker
open /Applications/Docker.app
```

### npm install fails

```bash
# Check Node.js version
node --version  # Should be v18+

# Update npm
npm install -g npm@latest

# Clear cache
npm cache clean --force

# Try install again
npm install -g n8n
```

### "Address already in use" on port 5678

```bash
# Kill existing process
pkill -f "n8n start"

# Or use different port
N8N_PORT=8000 n8n start
```

### Database Connection Fails (Docker Compose)

```bash
# Check PostgreSQL is running
docker compose ps postgres

# Check logs
docker compose logs postgres

# Verify credentials in .env
grep DB_POSTGRESDB .env

# Test connection
docker compose exec postgres psql -U n8n -d n8n -c "SELECT 1;"
```

### Slow Performance

```bash
# Check resource allocation in Docker Desktop
# Settings → Resources → increase:
# - CPUs: 4-6
# - Memory: 6-8 GB
# - Disk Image Size: 80+ GB

# Monitor usage
docker stats
```

### n8n Crashes on Startup

```bash
# Check logs
docker logs n8n

# Common causes:
# 1. Database not running: docker compose ps postgres
# 2. Encryption key mismatch: check N8N_ENCRYPTION_KEY
# 3. Port in use: docker ps | grep 5678

# Restart from scratch
docker compose down -v  # WARNING: deletes data!
docker compose up -d
```

---

## System Integration

### Create n8n Alias

```bash
# Add to ~/.zshrc (Apple's default shell)
echo 'alias n8n="open http://localhost:5678"' >> ~/.zshrc
source ~/.zshrc

# Now just type: n8n
```

### Launch at Startup

#### Docker Desktop Method

```bash
# Enable "Start Docker Desktop when you log in"
# Docker menu → Settings → General → "Start Docker Desktop when you log in"
```

#### PM2 Method

```bash
pm2 startup
pm2 save
# n8n starts automatically after reboot
```

#### Create macOS Launch Agent

```bash
# Create launch agent
mkdir -p ~/Library/LaunchAgents

cat > ~/Library/LaunchAgents/com.n8n.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.n8n.service</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/n8n</string>
        <string>start</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/n8n.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/n8n-error.log</string>
</dict>
</plist>
EOF

# Load agent
launchctl load ~/Library/LaunchAgents/com.n8n.plist

# Unload when needed
launchctl unload ~/Library/LaunchAgents/com.n8n.plist
```

---

## Next Steps

After successful installation:

1. ✅ Access n8n at http://localhost:5678
2. ✅ Create test workflow (Phase 1)
3. ✅ Set up credentials for integrations
4. ✅ Configure webhooks for external triggers
5. ✅ Explore example workflows

See main installation guide for all methods and additional platforms.
