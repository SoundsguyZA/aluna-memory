# Veritas VPS Deployment Guide

## Overview
This guide will help you deploy the complete Veritas AI ecosystem on your Hostinger VPS.

## Prerequisites
- VPS Access: SSH credentials for root@72.62.235.217
- Domain: alunaafrica.cloud with DNS access
- API Keys: OpenRouter, Groq, Gemini, Anthropic (Claude)

## Quick Start

### Step 1: Connect to VPS
```bash
ssh root@72.62.235.217
```

### Step 2: Upload and Run Setup Script
On your local machine:
```bash
# Copy the setup script to VPS
scp vps-setup.sh root@72.62.235.217:/root/

# SSH into VPS and run the script
ssh root@72.62.235.217
chmod +x /root/vps-setup.sh
sudo /root/vps-setup.sh
```

This script will:
- ✅ Update Ubuntu 24.04 LTS
- ✅ Install Docker & Docker Compose
- ✅ Install Nginx web server
- ✅ Install Certbot for SSL
- ✅ Configure firewall (UFW)
- ✅ Clone Agent Zero and Aluna Memory repositories
- ✅ Create deployment directory structure
- ✅ Generate configuration templates

### Step 3: Configure API Keys
```bash
# On the VPS
cd /opt/veritas
cp .env.template .env
nano .env
```

Edit the .env file with your actual API keys:
```env
OPENROUTER_API_KEY=sk-or-v1-your-actual-key-here
GROQ_API_KEY=gsk_your-actual-key-here
GEMINI_API_KEY=your-actual-gemini-key-here
ANTHROPIC_API_KEY=sk-ant-your-actual-key-here

POSTGRES_PASSWORD=YourSecurePassword123!
REDIS_PASSWORD=AnotherSecurePassword456!
```

### Step 4: Configure DNS Records
In your Hostinger DNS management panel for alunaafrica.cloud, add these A records:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | veritas | 72.62.235.217 | 3600 |
| A | agent.veritas | 72.62.235.217 | 3600 |
| A | memory.veritas | 72.62.235.217 | 3600 |
| A | vault.veritas | 72.62.235.217 | 3600 |
| A | clawd.veritas | 72.62.235.217 | 3600 |

**Wait 5-10 minutes for DNS propagation**, then verify:
```bash
dig agent.veritas.alunaafrica.cloud
dig memory.veritas.alunaafrica.cloud
```

### Step 5: Start Services
```bash
cd /opt/veritas
./start-services.sh
```

This will start:
- PostgreSQL database
- Redis cache
- Agent Zero (port 50001)
- Aluna Memory (port 50003)

Check service status:
```bash
cd /opt/veritas
docker compose ps
docker compose logs -f
```

### Step 6: Setup SSL Certificates
Once DNS is propagated (verify with `dig` command):
```bash
cd /opt/veritas
./setup-ssl.sh
```

This will:
- Obtain Let's Encrypt SSL certificates
- Configure HTTPS for all services
- Enable auto-renewal

### Step 7: Verify Deployment
Visit these URLs in your browser:
- https://agent.veritas.alunaafrica.cloud - Agent Zero interface
- https://memory.veritas.alunaafrica.cloud - Aluna Memory API

## Service Architecture

```
┌─────────────────────────────────────────┐
│         Internet                         │
└────────────┬────────────────────────────┘
             │
             v
┌─────────────────────────────────────────┐
│   Nginx Reverse Proxy (80/443)          │
│   - SSL Termination                      │
│   - Domain Routing                       │
└────┬──────┬──────┬──────┬───────────────┘
     │      │      │      │
     │      │      │      └──> ClawdBot (50002)
     │      │      └─────────> CogniVault (50004)
     │      └────────────────> Aluna Memory (50003)
     └───────────────────────> Agent Zero (50001)
                               │
                               v
                    ┌──────────────────┐
                    │  PostgreSQL DB   │
                    │  Redis Cache     │
                    └──────────────────┘
```

## Service Management

### Start all services:
```bash
cd /opt/veritas && ./start-services.sh
```

### Stop all services:
```bash
cd /opt/veritas && ./stop-services.sh
```

### View logs:
```bash
cd /opt/veritas
docker compose logs -f agent-zero
docker compose logs -f aluna-memory
```

### Restart a specific service:
```bash
cd /opt/veritas
docker compose restart agent-zero
```

### Update a service:
```bash
cd /opt/veritas/agent-zero
git pull
cd /opt/veritas
docker compose up -d --build agent-zero
```

## Troubleshooting

### Check if services are running:
```bash
docker compose ps
```

### Check service health:
```bash
curl http://localhost:50001/health
curl http://localhost:50003/health
```

### Check Nginx status:
```bash
systemctl status nginx
nginx -t  # Test configuration
```

### Check firewall:
```bash
ufw status
```

### View all logs:
```bash
cd /opt/veritas
docker compose logs --tail=100
```

### Restart everything:
```bash
cd /opt/veritas
./stop-services.sh
./start-services.sh
```

## Security Considerations

1. **Change Default Passwords**: Update POSTGRES_PASSWORD and REDIS_PASSWORD in .env
2. **Firewall**: UFW is configured to allow only ports 22, 80, 443
3. **SSL**: All services use HTTPS with Let's Encrypt certificates
4. **Updates**: Regularly update the system and services:
   ```bash
   apt update && apt upgrade -y
   cd /opt/veritas && git pull --recurse-submodules
   docker compose up -d --build
   ```

## Adding CogniVault and ClawdBot

When these repositories are ready:

1. Clone the repository:
```bash
cd /opt/veritas
git clone https://github.com/SoundsguyZA/cognivault.git
git clone https://github.com/SoundsguyZA/clawdbot.git
```

2. Uncomment the service in docker-compose.yml

3. Create Nginx configuration:
```bash
nano /etc/nginx/sites-available/cognivault
# Copy the pattern from agent-zero config
ln -s /etc/nginx/sites-available/cognivault /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

4. Add SSL:
```bash
certbot --nginx -d vault.veritas.alunaafrica.cloud --non-interactive --agree-tos --email soundslucrative@gmail.com
```

5. Restart services:
```bash
cd /opt/veritas && docker compose up -d
```

## Backup Strategy

### Backup databases:
```bash
# PostgreSQL
docker exec veritas-postgres pg_dump -U veritas veritas_db > /opt/veritas/backups/postgres_$(date +%Y%m%d).sql

# Redis
docker exec veritas-redis redis-cli --pass $REDIS_PASSWORD SAVE
docker cp veritas-redis:/data/dump.rdb /opt/veritas/backups/redis_$(date +%Y%m%d).rdb
```

### Restore databases:
```bash
# PostgreSQL
docker exec -i veritas-postgres psql -U veritas veritas_db < /opt/veritas/backups/postgres_YYYYMMDD.sql

# Redis
docker cp /opt/veritas/backups/redis_YYYYMMDD.rdb veritas-redis:/data/dump.rdb
docker compose restart redis
```

## Monitoring

### System resources:
```bash
htop
df -h
docker stats
```

### Service health:
```bash
cd /opt/veritas
docker compose ps
curl https://agent.veritas.alunaafrica.cloud/health
curl https://memory.veritas.alunaafrica.cloud/health
```

## Support

For issues or questions:
- GitHub: https://github.com/SoundsguyZA/aluna-memory
- Email: soundslucrative@gmail.com

---

**Last Updated**: 2026-01-29
**Version**: 1.0.0
