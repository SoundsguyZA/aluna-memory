# VERITAS VPS - Windows Deployment Guide

**Target VPS:** veritas.alunaafrica.cloud (72.62.235.217)  
**OS:** Ubuntu 24.04 LTS - Hostinger KVM2  
**Date:** 2026-01-30  
**Built by:** VERITAS - 150% Production Standard

---

## 🚀 Quick Start from Windows

### Option 1: Use PowerShell (Recommended)

1. **Download PuTTY** (if not installed):
   - Download from: https://www.putty.org/
   - Or use Windows built-in SSH (Windows 10+)

2. **Connect to VPS**:
```powershell
ssh root@72.62.235.217
# Password: Cl@wdB0tEcon0my2026
```

3. **Download and run setup script**:
```bash
curl -o setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh
chmod +x setup.sh
./setup.sh
```

4. **Follow on-screen instructions**

### Option 2: Use Windows Terminal + WSL

If you have WSL2 installed:

```bash
# From WSL terminal
ssh root@72.62.235.217
# Then run setup script as above
```

---

## 🖥️ Remote Desktop Access from Windows

After setup completes:

1. **Open Remote Desktop Connection** (Windows + R, type `mstsc`)

2. **Connect to:**
   - Computer: `72.62.235.217:3389`
   - Username: `root`
   - Password: (set during setup with `passwd` command)

3. **You'll get XFCE Desktop** with:
   - Visual Studio Code installed
   - Terminal access
   - Full GUI environment
   - Docker management via Portainer

---

## 🐳 Docker Management

### Portainer Web Interface

Access at: `https://72.62.235.217:9443`

Features:
- Visual container management
- Log viewing
- Resource monitoring
- Stack deployment
- Volume management

### Command Line (via SSH or RDP Terminal)

```bash
# Start all services
cd /opt/veritas && ./start-services.sh

# Stop all services
cd /opt/veritas && ./stop-services.sh

# Check status
cd /opt/veritas && ./status.sh

# View logs
docker compose logs -f cognivault
docker compose logs -f aluna-memory

# Restart a service
docker compose restart cognivault
```

---

## 🔧 Configuration

### 1. API Keys Configuration

```bash
# Edit environment file
nano /opt/veritas/.env
```

**Required API Keys:**
- `GROQ_API_KEY` - Get from: https://console.groq.com
- `GEMINI_API_KEY` - Get from: https://aistudio.google.com
- `NOVITA_API_KEY` - Get from: https://novita.ai
- `ANTHROPIC_API_KEY` - Get from: https://console.anthropic.com
- `OPENROUTER_API_KEY` - Get from: https://openrouter.ai

Save with: `Ctrl+O`, `Enter`, `Ctrl+X`

### 2. Start Services

```bash
cd /opt/veritas
./start-services.sh
```

Wait 2-3 minutes for services to initialize.

### 3. Verify Services

Check service status:
```bash
docker compose ps
```

All services should show `healthy` or `running`.

---

## 🌐 Access Your Services

Once DNS is configured:

| Service | URL | Port |
|---------|-----|------|
| **CogniVault** | http://72.62.235.217:50004 | 50004 |
| **Aluna-Memory** | http://72.62.235.217:50003 | 50003 |
| **Portainer** | https://72.62.235.217:9443 | 9443 |
| **Remote Desktop** | 72.62.235.217:3389 | 3389 |

### With Domain Names (after DNS setup):

| Service | URL |
|---------|-----|
| **CogniVault** | https://vault.veritas.alunaafrica.cloud |
| **Aluna-Memory** | https://memory.veritas.alunaafrica.cloud |
| **Agent Zero** | https://agent.veritas.alunaafrica.cloud |

---

## 🔐 DNS Configuration (Hostinger)

Add these A records in Hostinger DNS:

| Hostname | Type | Value | TTL |
|----------|------|-------|-----|
| veritas | A | 72.62.235.217 | 3600 |
| agent.veritas | A | 72.62.235.217 | 3600 |
| memory.veritas | A | 72.62.235.217 | 3600 |
| vault.veritas | A | 72.62.235.217 | 3600 |
| clawd.veritas | A | 72.62.235.217 | 3600 |

Wait 5-15 minutes for DNS propagation.

---

## 🔒 SSL Certificate Setup

After DNS propagation:

```bash
cd /opt/veritas
./setup-ssl.sh
```

This will:
- Install Let's Encrypt certificates
- Configure HTTPS for all services
- Set up auto-renewal

---

## 📊 Monitoring & Maintenance

### Check Service Health

```bash
# View all container status
docker compose ps

# View resource usage
docker stats

# View logs
docker compose logs -f
```

### Backup Important Data

```bash
# Backup volumes
docker run --rm \
  -v veritas_cognivault_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/cognivault-backup-$(date +%Y%m%d).tar.gz /data
```

### Update Services

```bash
cd /opt/veritas/cognivault
git pull
cd /opt/veritas
docker compose build cognivault
docker compose up -d cognivault
```

---

## 🐛 Troubleshooting

### Services won't start

```bash
# Check logs
docker compose logs

# Check if ports are available
netstat -tulpn | grep -E '50003|50004'

# Restart Docker
systemctl restart docker
```

### Can't connect via RDP

```bash
# Check XRDP status
systemctl status xrdp

# Restart XRDP
systemctl restart xrdp

# Check firewall
ufw status
```

### Out of disk space

```bash
# Clean up Docker
docker system prune -a --volumes

# Check disk usage
df -h
du -sh /opt/veritas/*
```

---

## 📦 What Gets Installed

### System Packages
- Docker & Docker Compose
- XFCE Desktop Environment
- XRDP (Remote Desktop)
- Visual Studio Code
- Nginx (reverse proxy)
- UFW Firewall
- Git, curl, wget, vim, htop

### Docker Services
- PostgreSQL 16 (database)
- Redis 7 (cache)
- Aluna-Memory (Mem0 framework)
- CogniVault (RAG system)
- Portainer CE (Docker management)

### Network Configuration
- Firewall rules configured
- Reverse proxy setup
- SSL certificate support
- Service isolation

---

## 🎯 Integration Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Windows Desktop                      │
│  ┌──────────────┐         ┌──────────────┐         │
│  │ Remote Desktop│         │  Web Browser │         │
│  │  (RDP Client)│         │              │         │
│  └───────┬──────┘         └───────┬──────┘         │
└──────────┼────────────────────────┼─────────────────┘
           │                        │
           │ Port 3389              │ Ports 50003-50004
           │                        │ & 9443
           ▼                        ▼
┌─────────────────────────────────────────────────────┐
│         VPS: veritas.alunaafrica.cloud              │
│              (72.62.235.217)                        │
│  ┌────────────────────────────────────────────┐    │
│  │  XFCE Desktop + XRDP                       │    │
│  │  - Visual Studio Code                       │    │
│  │  - Terminal                                 │    │
│  │  - Docker CLI                               │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │  Docker Containers                          │    │
│  │  ┌──────────────┐  ┌──────────────┐       │    │
│  │  │ CogniVault   │──│ Aluna-Memory │       │    │
│  │  │   (50004)    │  │   (50003)    │       │    │
│  │  └──────┬───────┘  └──────┬───────┘       │    │
│  │         │                  │                │    │
│  │         └──────┬───────────┘                │    │
│  │                │                            │    │
│  │         ┌──────▼───────┐  ┌──────────┐    │    │
│  │         │  PostgreSQL  │  │  Redis   │    │    │
│  │         │    (5432)    │  │  (6379)  │    │    │
│  │         └──────────────┘  └──────────┘    │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │  Portainer (9443)                          │    │
│  │  - Container Management                     │    │
│  │  - Logs & Monitoring                        │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### Data Flow

1. **Document Upload** (CogniVault):
   - User uploads docs via Streamlit interface
   - CogniVault processes: ChatGPT exports, WhatsApp exports, PDFs, audio files
   - Extracts text, metadata, embeddings

2. **Intelligent Indexing**:
   - TF-IDF vectorization in CogniVault
   - Semantic embeddings sent to Aluna-Memory
   - PostgreSQL stores structured data
   - Redis caches frequent queries

3. **Memory Storage** (Aluna-Memory):
   - Long-term memory via Mem0 framework
   - Graph relationships between documents
   - Conversation history tracking
   - Context-aware retrieval

4. **Query & Retrieval**:
   - Natural language queries
   - Vector similarity search
   - Context-aware responses
   - Multi-source data fusion

---

## 🎨 Claude Desktop Integration (Future)

**Note:** Claude Desktop doesn't run on Linux servers, but you can:

1. **Use VS Code** as your primary IDE on the VPS via RDP
2. **Run Claude Desktop on Windows** and connect to VPS services via API
3. **Use MCP (Model Context Protocol)** to connect Claude on Windows to Aluna-Memory on VPS

### MCP Setup (Windows → VPS)

On your Windows machine, configure Claude Desktop:

```json
{
  "mcpServers": {
    "aluna-memory": {
      "url": "http://72.62.235.217:50003",
      "type": "http"
    },
    "cognivault": {
      "url": "http://72.62.235.217:50004",
      "type": "http"
    }
  }
}
```

---

## 📞 Support & Resources

### Repositories
- **Aluna-Memory:** https://github.com/SoundsguyZA/aluna-memory
- **CogniVault:** https://github.com/SoundsguyZA/cognivault
- **Agent Zero:** https://github.com/frdel/agent-zero

### Documentation
- Docker Compose: https://docs.docker.com/compose/
- Portainer: https://docs.portainer.io/
- Mem0 Framework: https://mem0.ai/docs

### Author
**Rob "The Sounds Guy" Barenbrug**  
Email: soundslucrative@gmail.com  
Location: Durban, South Africa  

**Built by VERITAS - 150% Production Standard**

---

## 🔄 Update Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-30 | 1.0.0 | Initial Windows deployment guide |
| | | Complete VPS setup automation |
| | | RDP access configuration |
| | | Portainer integration |

---

## ✅ Deployment Checklist

- [ ] SSH access to VPS confirmed
- [ ] Setup script downloaded and executed
- [ ] Root password set for RDP access
- [ ] API keys configured in `/opt/veritas/.env`
- [ ] Services started successfully
- [ ] RDP connection from Windows tested
- [ ] Portainer web interface accessible
- [ ] CogniVault accessible at port 50004
- [ ] Aluna-Memory accessible at port 50003
- [ ] DNS A records added in Hostinger
- [ ] SSL certificates installed (after DNS)
- [ ] All services showing healthy status
- [ ] Backup strategy implemented

---

**Ready to deploy? SSH into your VPS and run the setup script!** 🚀
