# Windows Installation Guide

Complete guide for installing n8n on Windows (10, 11 and Windows Server).

**This guide covers:**
- System requirements for Windows
- 3 installation methods (WSL2 + Docker, Docker Desktop, npm)
- WSL2 setup and troubleshooting
- PowerShell and Command Prompt commands
- Windows Server deployment

---

## System Requirements (Windows)

### Supported Windows Versions

- Windows 10 (21H2 or later)
- Windows 11 (any version)
- Windows Server 2019 or later

### Hardware

| Component | Requirement | Notes |
| --- | --- | --- |
| CPU | Intel Core i5+ or AMD equivalent | Virtualization support required |
| RAM | 6 GB minimum | 8 GB+ for Docker |
| Disk | 30 GB available | SSD highly recommended |
| Virtualization | Enabled in BIOS | Required for Hyper-V/WSL2 |

### Processor Feature Requirements

Check in PowerShell (as Administrator):

```powershell
# Check virtualization support
Get-WmiObject -Class Win32_Processor | Select-Object Name, VirtualizationFirmwareEnabled

# Enable Hyper-V (Windows 10/11 Pro/Enterprise only)
# Windows Home needs WSL2 without Hyper-V
```

---

## Method 1: Docker Desktop + WSL2 (Recommended)

**Time:** 20 minutes  
**Best for:** Windows 10/11 Pro/Enterprise, standard development  
**OS:** Requires Windows 10 v2004+ or Windows 11

### Step 1: Enable WSL2

Open PowerShell as Administrator:

```powershell
# Enable WSL feature
wsl --install

# This installs WSL2 and Ubuntu LTS automatically
# Or install specific distribution:
wsl --install -d Ubuntu-22.04

# Restart when prompted
```

### Step 2: Complete WSL2 Setup

After restart:

```powershell
# Open Windows Terminal and select Ubuntu tab

# Update Ubuntu packages
sudo apt update && sudo apt upgrade -y

# Verify WSL2
wsl --list --verbose
# Should show: Ubuntu    Running    2
```

### Step 3: Install Docker Desktop

1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Run installer and follow prompts
3. When prompted, ensure **WSL2 backend** is selected
4. Restart computer

### Step 4: Configure Docker

```powershell
# In Windows Terminal (PowerShell tab)

# Check Docker installation
docker --version
docker compose --version

# Verify WSL2 integration
docker context list
# Should show: desktop-linux (running)
```

### Step 5: Clone and Run n8n

```powershell
# Create projects directory
mkdir C:\Users\YourUsername\projects
cd C:\Users\YourUsername\projects

# Clone repository
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops\examples\docker-compose

# Copy configuration
Copy-Item .env.example -Destination .env

# Edit .env (use notepad or VSCode)
notepad .env

# Start services
docker compose up -d

# Verify
docker compose ps
```

### Step 6: Access n8n

Open browser: `http://localhost`

---

## Method 2: Docker Desktop (Without WSL2)

**Time:** 15 minutes  
**For:** Windows Home, users without WSL2  
**Note:** Windows Home doesn't support Hyper-V, uses Docker's virtualization

### Installation

1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Run installer (agrees to Hyper-V requirement)
3. Choose **Not to use WSL2** (Windows Home)
4. Restart computer

### Run n8n

```powershell
# In PowerShell
cd C:\your-n8n-path\examples\docker-compose

# Copy configuration
Copy-Item .env.example -Destination .env

# Edit if needed
notepad .env

# Start
docker compose up -d

# Access
# Browser: http://localhost
```

---

## Method 3: npm (Node.js)

**Time:** 10 minutes  
**Best for:** Development, no Docker needed

### Step 1: Install Node.js

1. Download [Node.js LTS](https://nodejs.org/)
2. Run installer
3. Accept defaults (includes npm)
4. Restart computer

### Step 2: Verify Installation

Open PowerShell:

```powershell
node --version  # v18+
npm --version   # 8+
```

### Step 3: Install n8n

```powershell
# Install globally
npm install -g n8n

# Or in specific directory
mkdir C:\n8n-app
cd C:\n8n-app
npm init -y
npm install n8n
```

### Step 4: Create Configuration

```powershell
# Create .env file
$env:N8N_ENCRYPTION_KEY = [guid]::NewGuid().ToString()
$env:N8N_BASIC_AUTH_ACTIVE = "true"
$env:N8N_BASIC_AUTH_USER = "admin"
$env:N8N_BASIC_AUTH_PASSWORD = "changeme"

# Save for later use
[Environment]::SetEnvironmentVariable("N8N_ENCRYPTION_KEY", $env:N8N_ENCRYPTION_KEY, "User")
```

### Step 5: Start n8n

```powershell
# Start n8n
n8n start

# Or with custom port
$env:N8N_PORT = 8000
n8n start

# Access: http://localhost:5678 (or your port)
```

---

## Method 4: Windows Subsystem for Linux (WSL2) + npm

**Time:** 15 minutes  
**Best for:** Linux-like development environment

### Setup WSL2

See "Method 1: Step 1" above

### Install Node.js in WSL2

```bash
# In WSL2 Ubuntu terminal

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version
npm --version
```

### Install and Run n8n

```bash
# Install
npm install -g n8n

# Create .env
cat > ~/.n8n/.env << 'EOF'
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
EOF

# Start
n8n start
```

---

## Running n8n as Windows Service

### Using NSSM (Non-Sucking Service Manager)

Best for npm-based installation:

```powershell
# Download NSSM
# https://nssm.cc/download

# Extract and navigate to nssm-2.24\win64

# Install n8n as service
.\nssm.exe install n8n "C:\path\to\node.exe" "C:\path\to\n8n\bin\n8n.js start"

# Start service
.\nssm.exe start n8n

# Check status
.\nssm.exe status n8n

# Stop service
.\nssm.exe stop n8n

# Uninstall
.\nssm.exe remove n8n confirm
```

---

## WSL2 Best Practices

### File System Performance

Store projects in WSL filesystem (not Windows):

```bash
# Good (WSL filesystem)
~/projects/n8n-devops
/home/username/projects/n8n-devops

# Slower (Windows filesystem, accessed from WSL)
/mnt/c/Users/username/projects/n8n-devops
```

### Docker Performance

```bash
# Configure WSL resource allocation
# File: ~/.wslconfig
[wsl2]
memory=4GB
processors=4
swap=2GB
localhostForwarding=true

# Apply changes
wsl --shutdown
```

### Access from Windows

Forward ports from WSL:

```powershell
# WSL2 automatically forwards ports
# Access: http://localhost:5678

# Or get WSL IP
wsl hostname -I
# Then access from Windows: http://<wsl-ip>:5678
```

---

## Windows Server Setup

For Windows Server 2019+:

```powershell
# As Administrator

# Install Docker
Invoke-WebRequest -Uri https://docker.com/wsl -OutFile DockerDesktopInstaller.exe
& '.\DockerDesktopInstaller.exe' install --backend=wsl --quiet

# Or use chocolatey
choco install docker-for-windows -y

# Install git
choco install git -y

# Clone and run
git clone https://github.com/your-org/n8n-devops.git
cd n8n-devops\examples\docker-compose
Copy-Item .env.example .env
docker compose up -d
```

---

## Troubleshooting (Windows)

### Docker Desktop Won't Start

```powershell
# Check if Hyper-V is enabled
Get-WindowsOptionalFeature -FeatureName Hyper-V -Online

# Enable if needed (requires Admin, restart required)
Enable-WindowsOptionalFeature -FeatureName Hyper-V -Online -All

# Restart Docker
Restart-Service docker
```

### WSL2 Installation Issues

```powershell
# Update WSL kernel
wsl --update

# Set default version
wsl --set-default-version 2

# Troubleshoot
wsl --list --verbose
wsl --status
```

### Port Already in Use

```powershell
# Find process using port 5678
netstat -ano | findstr :5678

# Kill process
taskkill /PID <PID> /F

# Or use different port
$env:N8N_PORT = 8000
n8n start
```

### PowerShell Execution Policy

If scripts won't run:

```powershell
# Check policy
Get-ExecutionPolicy

# Set permissive (temporary)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or use command prompt instead
cmd.exe
# then run: npm install -g n8n
```

### Docker Memory Issues

```powershell
# Check resource usage
docker stats

# Increase Docker memory (Docker Desktop)
# Settings → Resources → Memory: increase to 4-6 GB

# Or edit .wslconfig
notepad $env:USERPROFILE\.wslconfig
# Set: memory=6GB
```

### Database Connection Fails

```powershell
# Verify all services running
docker compose ps

# Check PostgreSQL logs
docker compose logs postgres

# Test connection
docker compose exec postgres psql -U n8n -d n8n -c "SELECT 1;"
```

### "docker command not found"

```powershell
# Docker not in PATH, restart terminal or computer
# Or manually add to PATH:
# Settings → Environment Variables → User variables for username
# Add: C:\Program Files\Docker\Docker\resources\bin

# Then restart PowerShell
```

---

## PowerShell Useful Commands

```powershell
# Check what's running
Get-Process | Select-Object Name, CPU, Memory | Sort CPU -Descending

# Monitor Docker
docker stats --no-stream

# View logs
docker compose logs -f n8n

# SSH into WSL
wsl

# Get WSL IP
wsl hostname -I

# Access shared folders
\\wsl$\Ubuntu-22.04

# Create symlink (requires Admin)
New-Item -ItemType SymbolicLink -Path "C:\link-name" -Target "C:\actual-path"
```

---

## File Sharing Between Windows and WSL2

### Access WSL Files from Windows

```powershell
# In File Explorer
\\wsl$

# Or via PowerShell
wsl ls /home/username/projects
```

### Access Windows Files from WSL

```bash
# In WSL terminal
ls /mnt/c/Users/username/Documents

# Create symlink to frequently used folder
ln -s /mnt/c/Users/username/projects ~/projects
```

---

## Next Steps

After successful installation:

1. ✅ Access n8n at http://localhost:5678
2. ✅ Login with admin credentials
3. ✅ Create test workflow
4. ✅ Explore example workflows
5. ✅ Read Phase 1 documentation

See main installation guide for additional help and other methods.
