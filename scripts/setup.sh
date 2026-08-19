#!/bin/bash
set -e
set -o pipefail

echo "============================================"
echo " Dream Vacations - Server Setup Script"
echo "============================================"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[SETUP]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Update system packages
log "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install essential tools
log "Installing essential tools..."
sudo apt-get install -y \
  curl \
  wget \
  git \
  unzip \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release

# Install Node.js 20.x (idempotent)
if command -v node &>/dev/null; then
  warn "Node.js already installed: $(node --version)"
else
  log "Installing Node.js 20.x..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
  log "Node.js installed: $(node --version)"
fi

# Install Docker (idempotent)
if command -v docker &>/dev/null; then
  warn "Docker already installed: $(docker --version)"
else
  log "Installing Docker..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER
  log "Docker installed: $(docker --version)"
fi

# Install Docker Compose plugin (idempotent)
if docker compose version &>/dev/null; then
  warn "Docker Compose already installed: $(docker compose version)"
else
  log "Installing Docker Compose plugin..."
  sudo apt-get install -y docker-compose-plugin
  log "Docker Compose installed: $(docker compose version)"
fi

# Install PostgreSQL client (idempotent)
if command -v psql &>/dev/null; then
  warn "PostgreSQL client already installed: $(psql --version)"
else
  log "Installing PostgreSQL client..."
  sudo apt-get install -y postgresql-client
  log "PostgreSQL client installed: $(psql --version)"
fi

# Create app directory
log "Creating app directory..."
sudo mkdir -p /opt/dream-vacations
sudo chown $USER:$USER /opt/dream-vacations

# Setup log directory
log "Setting up log directory..."
sudo mkdir -p /var/log/dream-vacations
sudo chown $USER:$USER /var/log/dream-vacations

echo ""
echo "============================================"
echo " Setup Complete!"
echo "============================================"
echo " Node.js : $(node --version)"
echo " npm     : $(npm --version)"
echo " Docker  : $(docker --version)"
echo " Compose : $(docker compose version)"
echo " psql    : $(psql --version)"
echo "============================================"
echo " NOTE: Log out and back in for Docker"
echo " group membership to take effect."
echo "============================================"
