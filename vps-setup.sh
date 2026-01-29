#!/bin/bash
#
# Veritas VPS Complete Setup Script
# For Ubuntu 24.04 LTS on Hostinger KVM2
# IP: 72.62.235.217
# Hostname: veritas.alunaafrica.cloud
#

set -e

echo "================================"
echo "Veritas VPS Setup Script"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo)"
    exit 1
fi

# Phase 1: System Update
print_status "Phase 1: Updating system packages..."
apt update && apt upgrade -y
print_status "System updated successfully"

# Install essential tools
print_status "Installing essential tools..."
apt install -y curl wget git nano vim ufw fail2ban htop

# Phase 2: Install Docker
print_status "Phase 2: Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    print_status "Docker installed successfully"
else
    print_warning "Docker already installed"
fi

# Install Docker Compose
print_status "Installing Docker Compose plugin..."
apt install -y docker-compose-plugin
docker compose version
print_status "Docker Compose installed"

# Start Docker service
systemctl enable docker
systemctl start docker
print_status "Docker service started"

# Phase 3: Install Nginx
print_status "Phase 3: Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
    print_status "Nginx installed and started"
else
    print_warning "Nginx already installed"
fi

# Phase 4: Install Certbot for SSL
print_status "Phase 4: Installing Certbot..."
apt install -y certbot python3-certbot-nginx
print_status "Certbot installed"

# Phase 5: Configure Firewall
print_status "Phase 5: Configuring firewall (UFW)..."
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw status
print_status "Firewall configured"

# Phase 6: Create deployment directory
print_status "Phase 6: Creating deployment directories..."
mkdir -p /opt/veritas/{agent-zero,clawdbot,aluna-memory,cognivault}
cd /opt/veritas
print_status "Created /opt/veritas directory structure"

# Phase 7: Clone repositories
print_status "Phase 7: Cloning repositories..."

# Agent Zero
if [ ! -d "/opt/veritas/agent-zero/.git" ]; then
    print_status "Cloning Agent Zero..."
    git clone https://github.com/frdel/agent-zero.git /opt/veritas/agent-zero
else
    print_warning "Agent Zero already cloned, pulling latest..."
    cd /opt/veritas/agent-zero && git pull
fi

# Aluna Memory
if [ ! -d "/opt/veritas/aluna-memory/.git" ]; then
    print_status "Cloning Aluna Memory..."
    git clone https://github.com/SoundsguyZA/aluna-memory.git /opt/veritas/aluna-memory
else
    print_warning "Aluna Memory already cloned, pulling latest..."
    cd /opt/veritas/aluna-memory && git pull
fi

print_status "Repositories cloned"

# Phase 8: Create environment template
print_status "Phase 8: Creating environment configuration templates..."
cat > /opt/veritas/.env.template << 'ENVEOF'
# Veritas VPS Environment Configuration
# Copy this file to each service directory and customize

# OpenRouter API
OPENROUTER_API_KEY=your_openrouter_key_here

# Groq API
GROQ_API_KEY=your_groq_key_here

# Google Gemini API
GEMINI_API_KEY=your_gemini_key_here

# Anthropic Claude API
ANTHROPIC_API_KEY=your_anthropic_key_here

# HuggingFace (optional)
HUGGINGFACE_API_KEY=your_hf_key_here

# Novita (optional)
NOVITA_API_KEY=your_novita_key_here

# Database Configuration
POSTGRES_USER=veritas
POSTGRES_PASSWORD=CHANGE_THIS_PASSWORD
POSTGRES_DB=veritas_db

# Redis Configuration
REDIS_PASSWORD=CHANGE_THIS_PASSWORD

# Service Ports
AGENT_ZERO_PORT=50001
CLAWDBOT_PORT=50002
ALUNA_MEMORY_PORT=50003
COGNIVAULT_PORT=50004
ENVEOF

print_status "Environment template created at /opt/veritas/.env.template"

# Phase 9: Create docker-compose for all services
print_status "Phase 9: Creating master Docker Compose configuration..."
cat > /opt/veritas/docker-compose.yml << 'COMPOSEEOF'
version: '3.8'

networks:
  veritas-network:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
  agent-zero-data:
  aluna-memory-data:
  cognivault-data:

services:
  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    container_name: veritas-postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-veritas}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-changeme}
      POSTGRES_DB: ${POSTGRES_DB:-veritas_db}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - veritas-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-veritas}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: veritas-redis
    command: redis-server --requirepass ${REDIS_PASSWORD:-changeme}
    volumes:
      - redis-data:/data
    networks:
      - veritas-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Agent Zero
  agent-zero:
    build: ./agent-zero
    container_name: veritas-agent-zero
    environment:
      - OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
      - GROQ_API_KEY=${GROQ_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    ports:
      - "${AGENT_ZERO_PORT:-50001}:80"
    volumes:
      - agent-zero-data:/app/data
    networks:
      - veritas-network
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  # Aluna Memory (Mem0)
  aluna-memory:
    build: ./aluna-memory
    container_name: veritas-aluna-memory
    environment:
      - POSTGRES_HOST=postgres
      - POSTGRES_USER=${POSTGRES_USER:-veritas}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-changeme}
      - POSTGRES_DB=${POSTGRES_DB:-veritas_db}
      - REDIS_HOST=redis
      - REDIS_PASSWORD=${REDIS_PASSWORD:-changeme}
    ports:
      - "${ALUNA_MEMORY_PORT:-50003}:8000"
    volumes:
      - aluna-memory-data:/app/data
    networks:
      - veritas-network
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  # CogniVault (placeholder - will be configured when repo is ready)
  # cognivault:
  #   build: ./cognivault
  #   container_name: veritas-cognivault
  #   ports:
  #     - "${COGNIVAULT_PORT:-50004}:8000"
  #   volumes:
  #     - cognivault-data:/app/data
  #   networks:
  #     - veritas-network
  #   depends_on:
  #     - postgres
  #   restart: unless-stopped

  # ClawdBot (placeholder - will be configured when repo is ready)
  # clawdbot:
  #   build: ./clawdbot
  #   container_name: veritas-clawdbot
  #   ports:
  #     - "${CLAWDBOT_PORT:-50002}:8000"
  #   networks:
  #     - veritas-network
  #   restart: unless-stopped

COMPOSEEOF

print_status "Master Docker Compose created"

# Phase 10: Create Nginx configuration
print_status "Phase 10: Creating Nginx reverse proxy configurations..."
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# Create Nginx config for Agent Zero
cat > /etc/nginx/sites-available/agent-zero << 'NGINXEOF'
server {
    listen 80;
    server_name agent.veritas.alunaafrica.cloud;

    location / {
        proxy_pass http://localhost:50001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

# Create Nginx config for Aluna Memory
cat > /etc/nginx/sites-available/aluna-memory << 'NGINXEOF'
server {
    listen 80;
    server_name memory.veritas.alunaafrica.cloud;

    location / {
        proxy_pass http://localhost:50003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

# Enable sites
ln -sf /etc/nginx/sites-available/agent-zero /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/aluna-memory /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t
systemctl reload nginx

print_status "Nginx reverse proxy configured"

# Phase 11: Create SSL setup script
cat > /opt/veritas/setup-ssl.sh << 'SSLEOF'
#!/bin/bash
# SSL Certificate Setup Script
# Run this after DNS records are properly configured

echo "Setting up SSL certificates..."
certbot --nginx -d agent.veritas.alunaafrica.cloud --non-interactive --agree-tos --email soundslucrative@gmail.com
certbot --nginx -d memory.veritas.alunaafrica.cloud --non-interactive --agree-tos --email soundslucrative@gmail.com

# Setup auto-renewal
systemctl enable certbot.timer
systemctl start certbot.timer

echo "SSL certificates configured!"
SSLEOF

chmod +x /opt/veritas/setup-ssl.sh
print_status "SSL setup script created at /opt/veritas/setup-ssl.sh"

# Phase 12: Create startup script
cat > /opt/veritas/start-services.sh << 'STARTEOF'
#!/bin/bash
cd /opt/veritas
docker compose up -d
docker compose ps
STARTEOF

chmod +x /opt/veritas/start-services.sh
print_status "Startup script created"

# Create stop script
cat > /opt/veritas/stop-services.sh << 'STOPEOF'
#!/bin/bash
cd /opt/veritas
docker compose down
STOPEOF

chmod +x /opt/veritas/stop-services.sh
print_status "Stop script created"

# Phase 13: Print summary
echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
print_status "All base components installed successfully"
echo ""
echo "Next Steps:"
echo "1. Configure API keys in /opt/veritas/.env.template"
echo "2. Copy .env.template to /opt/veritas/.env"
echo "3. Setup DNS A records for:"
echo "   - agent.veritas.alunaafrica.cloud → 72.62.235.217"
echo "   - memory.veritas.alunaafrica.cloud → 72.62.235.217"
echo "4. Run SSL setup: /opt/veritas/setup-ssl.sh"
echo "5. Start services: /opt/veritas/start-services.sh"
echo ""
echo "Service URLs (after DNS setup):"
echo "  Agent Zero: https://agent.veritas.alunaafrica.cloud"
echo "  Aluna Memory: https://memory.veritas.alunaafrica.cloud"
echo ""
print_status "Setup script completed!"

