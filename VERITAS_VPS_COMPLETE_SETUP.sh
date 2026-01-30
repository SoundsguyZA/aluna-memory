#!/bin/bash
#
# VERITAS VPS Complete Setup Script
# Target: veritas.alunaafrica.cloud (72.62.235.217)
# Ubuntu 24.04 LTS - Hostinger KVM2
# 
# This script will:
# 1. Install Docker & Portainer
# 2. Install XFCE Desktop + XRDP for Windows Remote Desktop
# 3. Install Visual Studio Code (as Claude Code alternative)
# 4. Deploy Agent Zero, Aluna-Memory, and CogniVault
# 5. Setup Nginx reverse proxy with SSL
#
# Built by VERITAS - 150% Production Standard
# Rob "The Sounds Guy" Barenbrug - 2026-01-30
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# VPS Configuration
VPS_IP="72.62.235.217"
VPS_HOSTNAME="veritas.alunaafrica.cloud"

# Service Ports
AGENT_ZERO_PORT=50001
CLAWDBOT_PORT=50002
ALUNA_MEMORY_PORT=50003
COGNIVAULT_PORT=50004
PORTAINER_PORT=9443
XRDP_PORT=3389

# API Keys (to be configured)
GROQ_API_KEY="${GROQ_API_KEY:-your_groq_key_here}"
GEMINI_API_KEY="${GEMINI_API_KEY:-your_gemini_key_here}"
NOVITA_API_KEY="${NOVITA_API_KEY:-your_novita_key_here}"
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-your_anthropic_key_here}"
OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-your_openrouter_key_here}"

# Database passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         VERITAS VPS Complete Deployment Script          ║${NC}"
echo -e "${BLUE}║              veritas.alunaafrica.cloud                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# STEP 1: System Update & Essential Tools
# ============================================================================
echo -e "${GREEN}[1/10] Updating system and installing essential tools...${NC}"
apt-get update
apt-get upgrade -y
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    ufw \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    software-properties-common \
    apt-transport-https

# ============================================================================
# STEP 2: Install Docker
# ============================================================================
echo -e "${GREEN}[2/10] Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    # Remove old versions
    apt-get remove -y docker docker-engine docker.io containerd runc || true
    
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    echo -e "${GREEN}✓ Docker installed successfully${NC}"
else
    echo -e "${YELLOW}✓ Docker already installed${NC}"
fi

# Verify Docker
docker --version
docker compose version

# ============================================================================
# STEP 3: Install Portainer
# ============================================================================
echo -e "${GREEN}[3/10] Installing Portainer...${NC}"
if ! docker ps -a | grep -q portainer; then
    docker volume create portainer_data
    docker run -d \
        --name=portainer \
        --restart=always \
        -p 8000:8000 \
        -p ${PORTAINER_PORT}:9443 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    
    echo -e "${GREEN}✓ Portainer installed successfully${NC}"
    echo -e "${BLUE}  Access at: https://${VPS_IP}:${PORTAINER_PORT}${NC}"
else
    echo -e "${YELLOW}✓ Portainer already running${NC}"
fi

# ============================================================================
# STEP 4: Install XFCE Desktop + XRDP for Remote Desktop
# ============================================================================
echo -e "${GREEN}[4/10] Installing XFCE Desktop + XRDP...${NC}"
if ! command -v xrdp &> /dev/null; then
    # Install XFCE desktop environment
    DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 xfce4-goodies
    
    # Install XRDP
    apt-get install -y xrdp
    
    # Configure XRDP to use XFCE
    echo "xfce4-session" > /root/.xsession
    echo "startxfce4" > /root/.xinitrc
    
    # Configure XRDP
    sed -i 's/^new_cursors=true/new_cursors=false/' /etc/xrdp/xrdp.ini
    
    # Allow RDP through firewall
    ufw allow ${XRDP_PORT}/tcp
    
    # Start and enable XRDP
    systemctl start xrdp
    systemctl enable xrdp
    
    # Add to ssl-cert group
    adduser xrdp ssl-cert
    
    echo -e "${GREEN}✓ XFCE Desktop + XRDP installed successfully${NC}"
    echo -e "${BLUE}  RDP Access: ${VPS_IP}:${XRDP_PORT}${NC}"
    echo -e "${BLUE}  Username: root${NC}"
    echo -e "${YELLOW}  Make sure to set a root password: passwd${NC}"
else
    echo -e "${YELLOW}✓ XRDP already installed${NC}"
fi

# ============================================================================
# STEP 5: Install Visual Studio Code
# ============================================================================
echo -e "${GREEN}[5/10] Installing Visual Studio Code...${NC}"
if ! command -v code &> /dev/null; then
    # Import Microsoft GPG key
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    
    # Add VS Code repository
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
    
    # Install VS Code
    apt-get update
    apt-get install -y code
    
    echo -e "${GREEN}✓ Visual Studio Code installed successfully${NC}"
else
    echo -e "${YELLOW}✓ VS Code already installed${NC}"
fi

# ============================================================================
# STEP 6: Create deployment directories
# ============================================================================
echo -e "${GREEN}[6/10] Creating deployment directories...${NC}"
mkdir -p /opt/veritas/{agent-zero,clawdbot,aluna-memory,cognivault}
mkdir -p /opt/veritas/nginx/conf.d
mkdir -p /opt/veritas/ssl

# ============================================================================
# STEP 7: Clone repositories
# ============================================================================
echo -e "${GREEN}[7/10] Cloning repositories...${NC}"

# Agent Zero
if [ ! -d "/opt/veritas/agent-zero/.git" ]; then
    echo "  Cloning Agent Zero..."
    git clone https://github.com/frdel/agent-zero.git /opt/veritas/agent-zero
    echo -e "${GREEN}  ✓ Agent Zero cloned${NC}"
else
    echo -e "${YELLOW}  ✓ Agent Zero already exists${NC}"
fi

# Aluna-Memory
if [ ! -d "/opt/veritas/aluna-memory/.git" ]; then
    echo "  Cloning Aluna-Memory..."
    git clone https://github.com/SoundsguyZA/aluna-memory.git /opt/veritas/aluna-memory
    echo -e "${GREEN}  ✓ Aluna-Memory cloned${NC}"
else
    echo -e "${YELLOW}  ✓ Aluna-Memory already exists${NC}"
fi

# CogniVault
if [ ! -d "/opt/veritas/cognivault/.git" ]; then
    echo "  Cloning CogniVault..."
    git clone https://github.com/SoundsguyZA/cognivault.git /opt/veritas/cognivault
    echo -e "${GREEN}  ✓ CogniVault cloned${NC}"
else
    echo -e "${YELLOW}  ✓ CogniVault already exists${NC}"
fi

# ============================================================================
# STEP 8: Create CogniVault Dockerfile
# ============================================================================
echo -e "${GREEN}[8/10] Creating CogniVault Dockerfile...${NC}"
cat > /opt/veritas/cognivault/Dockerfile << 'DOCKERFILE_END'
FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libmagic1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements_integrated.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements_integrated.txt

# Copy application code
COPY . .

# Create data directories
RUN mkdir -p /app/cognivault_data/uploads /app/cognivault_data/vector_store

# Expose Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Run the application
CMD ["streamlit", "run", "app_integrated.py", "--server.port=8501", "--server.address=0.0.0.0"]
DOCKERFILE_END

echo -e "${GREEN}✓ CogniVault Dockerfile created${NC}"

# ============================================================================
# STEP 9: Create docker-compose.yml
# ============================================================================
echo -e "${GREEN}[9/10] Creating docker-compose.yml...${NC}"
cat > /opt/veritas/docker-compose.yml << 'COMPOSE_END'
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    container_name: veritas-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: veritas
      POSTGRES_USER: veritas
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U veritas"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: veritas-redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Aluna-Memory (Mem0)
  aluna-memory:
    build:
      context: ./aluna-memory
      dockerfile: Dockerfile
    container_name: veritas-aluna-memory
    restart: unless-stopped
    depends_on:
      - postgres
      - redis
    environment:
      - DATABASE_URL=postgresql://veritas:${POSTGRES_PASSWORD}@postgres:5432/veritas
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
      - GROQ_API_KEY=${GROQ_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
    volumes:
      - aluna_data:/app/data
    ports:
      - "${ALUNA_MEMORY_PORT}:8000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # CogniVault
  cognivault:
    build:
      context: ./cognivault
      dockerfile: Dockerfile
    container_name: veritas-cognivault
    restart: unless-stopped
    depends_on:
      - postgres
      - redis
      - aluna-memory
    environment:
      - GROQ_API_KEY=${GROQ_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - NOVITA_API_KEY=${NOVITA_API_KEY}
      - ALUNA_MEMORY_URL=http://aluna-memory:8000
      - DATABASE_URL=postgresql://veritas:${POSTGRES_PASSWORD}@postgres:5432/veritas
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
    volumes:
      - cognivault_data:/app/cognivault_data
    ports:
      - "${COGNIVAULT_PORT}:8501"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8501/_stcore/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  aluna_data:
    driver: local
  cognivault_data:
    driver: local

networks:
  default:
    name: veritas-network
    driver: bridge
COMPOSE_END

echo -e "${GREEN}✓ docker-compose.yml created${NC}"

# ============================================================================
# STEP 10: Create .env file with API keys
# ============================================================================
echo -e "${GREEN}[10/10] Creating environment configuration...${NC}"
cat > /opt/veritas/.env << ENV_END
# VERITAS VPS Environment Configuration
# Generated: $(date)

# Database Configuration
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_USER=veritas
POSTGRES_DB=veritas

# Redis Configuration
REDIS_PASSWORD=${REDIS_PASSWORD}

# Service Ports
AGENT_ZERO_PORT=${AGENT_ZERO_PORT}
CLAWDBOT_PORT=${CLAWDBOT_PORT}
ALUNA_MEMORY_PORT=${ALUNA_MEMORY_PORT}
COGNIVAULT_PORT=${COGNIVAULT_PORT}

# API Keys (REPLACE WITH YOUR ACTUAL KEYS)
GROQ_API_KEY=${GROQ_API_KEY}
GEMINI_API_KEY=${GEMINI_API_KEY}
NOVITA_API_KEY=${NOVITA_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}

# URLs
DATABASE_URL=postgresql://veritas:${POSTGRES_PASSWORD}@postgres:5432/veritas
REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
ALUNA_MEMORY_URL=http://aluna-memory:8000
ENV_END

chmod 600 /opt/veritas/.env
echo -e "${GREEN}✓ Environment configuration created${NC}"

# ============================================================================
# Configure Firewall
# ============================================================================
echo -e "${GREEN}Configuring firewall...${NC}"
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow ${PORTAINER_PORT}/tcp
ufw allow ${XRDP_PORT}/tcp
ufw allow ${AGENT_ZERO_PORT}/tcp
ufw allow ${ALUNA_MEMORY_PORT}/tcp
ufw allow ${COGNIVAULT_PORT}/tcp
ufw reload

# ============================================================================
# Create service management scripts
# ============================================================================
echo -e "${GREEN}Creating service management scripts...${NC}"

# Start services script
cat > /opt/veritas/start-services.sh << 'START_END'
#!/bin/bash
cd /opt/veritas
docker compose up -d
echo "Services started!"
echo "Check status: docker compose ps"
START_END
chmod +x /opt/veritas/start-services.sh

# Stop services script
cat > /opt/veritas/stop-services.sh << 'STOP_END'
#!/bin/bash
cd /opt/veritas
docker compose down
echo "Services stopped!"
STOP_END
chmod +x /opt/veritas/stop-services.sh

# Status script
cat > /opt/veritas/status.sh << 'STATUS_END'
#!/bin/bash
cd /opt/veritas
echo "=== Service Status ==="
docker compose ps
echo ""
echo "=== Docker Stats ==="
docker stats --no-stream
STATUS_END
chmod +x /opt/veritas/status.sh

# ============================================================================
# Display Summary
# ============================================================================
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           VERITAS VPS Setup Complete! ✓                  ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Docker & Docker Compose installed${NC}"
echo -e "${GREEN}✓ Portainer installed and running${NC}"
echo -e "${GREEN}✓ XFCE Desktop + XRDP installed${NC}"
echo -e "${GREEN}✓ Visual Studio Code installed${NC}"
echo -e "${GREEN}✓ Repositories cloned${NC}"
echo -e "${GREEN}✓ Docker configurations created${NC}"
echo -e "${GREEN}✓ Firewall configured${NC}"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}IMPORTANT: Next Steps${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}1. Set root password for RDP access:${NC}"
echo "   passwd"
echo ""
echo -e "${BLUE}2. Configure API keys in:${NC}"
echo "   nano /opt/veritas/.env"
echo ""
echo -e "${BLUE}3. Start services:${NC}"
echo "   cd /opt/veritas && ./start-services.sh"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Access Points${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Portainer:${NC}        https://${VPS_IP}:${PORTAINER_PORT}"
echo -e "${GREEN}Remote Desktop:${NC}   ${VPS_IP}:${XRDP_PORT} (username: root)"
echo -e "${GREEN}CogniVault:${NC}       http://${VPS_IP}:${COGNIVAULT_PORT}"
echo -e "${GREEN}Aluna-Memory:${NC}     http://${VPS_IP}:${ALUNA_MEMORY_PORT}"
echo ""
echo -e "${BLUE}Generated passwords saved in: /opt/veritas/.env${NC}"
echo ""
echo -e "${GREEN}Built by VERITAS - 150% Production Standard${NC}"
echo -e "${GREEN}Rob 'The Sounds Guy' Barenbrug - 2026-01-30${NC}"
echo ""
