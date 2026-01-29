# 🚀 Veritas VPS - Quick Start Card

## TL;DR - Get Everything Running in 8 Steps

### Prerequisites
- VPS IP: `72.62.235.217`
- VPS Password: Get from Hostinger
- API Keys: OpenRouter, Groq, Gemini, Anthropic

---

## 🎯 The 8-Step Launch Sequence

### 1️⃣ **SSH Into VPS**
```bash
ssh root@72.62.235.217
```

### 2️⃣ **Download & Run Setup Script**
```bash
curl -O https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/vps-setup.sh
chmod +x vps-setup.sh
sudo ./vps-setup.sh
```
⏱️ Takes ~5-10 minutes. Get coffee ☕

### 3️⃣ **Configure API Keys**
```bash
cd /opt/veritas
cp .env.template .env
nano .env
```
Fill in your actual API keys, then save (Ctrl+O, Enter, Ctrl+X)

### 4️⃣ **Setup DNS Records**
In Hostinger DNS panel for `alunaafrica.cloud`, add:

```
Type: A  |  Name: veritas        |  Value: 72.62.235.217  |  TTL: 3600
Type: A  |  Name: agent.veritas  |  Value: 72.62.235.217  |  TTL: 3600
Type: A  |  Name: memory.veritas |  Value: 72.62.235.217  |  TTL: 3600
Type: A  |  Name: vault.veritas  |  Value: 72.62.235.217  |  TTL: 3600
Type: A  |  Name: clawd.veritas  |  Value: 72.62.235.217  |  TTL: 3600
```

⏱️ Wait 5-10 minutes for DNS to propagate

### 5️⃣ **Start Services**
```bash
cd /opt/veritas
./start-services.sh
```

### 6️⃣ **Check Status**
```bash
docker compose ps
docker compose logs -f
```
Look for "running" status. Ctrl+C to exit logs.

### 7️⃣ **Setup SSL**
```bash
cd /opt/veritas
./setup-ssl.sh
```

### 8️⃣ **Test It**
Open browser and visit:
- https://agent.veritas.alunaafrica.cloud
- https://memory.veritas.alunaafrica.cloud

🎉 **You're live!**

---

## 📋 Useful Commands

### Service Management
```bash
cd /opt/veritas

# Start everything
./start-services.sh

# Stop everything
./stop-services.sh

# View logs
docker compose logs -f

# Restart a service
docker compose restart agent-zero
```

### Troubleshooting
```bash
# Check if services are running
docker compose ps

# Check individual service logs
docker compose logs agent-zero
docker compose logs aluna-memory

# Check Nginx status
systemctl status nginx

# Check firewall
ufw status

# Test local endpoints
curl http://localhost:50001/health
curl http://localhost:50003/health
```

### System Health
```bash
# System resources
htop

# Disk space
df -h

# Docker stats
docker stats
```

---

## 🔥 Emergency Commands

### Everything Broken?
```bash
cd /opt/veritas
./stop-services.sh
./start-services.sh
```

### Need to Update?
```bash
cd /opt/veritas/agent-zero && git pull && cd ..
cd /opt/veritas/aluna-memory && git pull && cd ..
docker compose up -d --build
```

### Full System Update
```bash
apt update && apt upgrade -y
systemctl restart docker
cd /opt/veritas && docker compose restart
```

---

## 📂 Important Locations

| What | Where |
|------|-------|
| Main directory | `/opt/veritas/` |
| Environment config | `/opt/veritas/.env` |
| Docker compose | `/opt/veritas/docker-compose.yml` |
| Nginx configs | `/etc/nginx/sites-available/` |
| Service scripts | `/opt/veritas/*.sh` |
| Logs | `docker compose logs` |

---

## 🌐 Service URLs (After Setup)

| Service | URL | Port |
|---------|-----|------|
| Agent Zero | https://agent.veritas.alunaafrica.cloud | 50001 |
| Aluna Memory | https://memory.veritas.alunaafrica.cloud | 50003 |
| CogniVault | https://vault.veritas.alunaafrica.cloud | 50004 |
| ClawdBot | https://clawd.veritas.alunaafrica.cloud | 50002 |

---

## 📖 Full Documentation

- **Complete Guide**: `DEPLOYMENT_GUIDE.md`
- **Setup Summary**: `VERITAS_SETUP_SUMMARY.md`
- **Architecture**: `VPS_DEPLOYMENT_PLAN.md`
- **Repository**: https://github.com/SoundsguyZA/aluna-memory

---

## 🆘 Need Help?

1. Check the logs: `docker compose logs -f`
2. Restart services: `./stop-services.sh && ./start-services.sh`
3. Review full documentation in repo
4. GitHub Issues: https://github.com/SoundsguyZA/aluna-memory/issues
5. Email: soundslucrative@gmail.com

---

**Quick Ref Version**: 1.0  
**Last Updated**: 2026-01-29  
**Status**: Production Ready ✅
