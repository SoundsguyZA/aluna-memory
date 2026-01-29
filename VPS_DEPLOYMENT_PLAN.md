# Veritas VPS Deployment Plan
## VPS Details
- **Hostname**: veritas.alunaafrica.cloud
- **IP**: 72.62.235.217
- **Plan**: KVM2 (2 vCPU, 8GB RAM)
- **OS**: Ubuntu 24.04 LTS
- **Provider**: Hostinger

## Services to Deploy

### 1. Agent Zero
- **Description**: Autonomous AI agent with tool creation capabilities
- **Repository**: https://github.com/frdel/agent-zero.git
- **Port**: 50001
- **Subdomain**: agent.veritas.alunaafrica.cloud
- **Deployment**: Docker Compose

### 2. ClawdBot
- **Description**: WhatsApp/Telegram gateway to Agent Zero
- **Repository**: TBD (need to locate or create)
- **Port**: 50002
- **Subdomain**: clawd.veritas.alunaafrica.cloud
- **Deployment**: Docker Compose

### 3. Aluna-Memory (Mem0/OpenMemory)
- **Description**: Persistent memory layer for AI assistants
- **Repository**: https://github.com/SoundsguyZA/aluna-memory.git
- **Port**: 50003
- **Subdomain**: memory.veritas.alunaafrica.cloud
- **Deployment**: Docker Compose

### 4. CogniVault
- **Description**: RAG knowledge management system
- **Repository**: TBD (need to locate or create)
- **Port**: 50004
- **Subdomain**: vault.veritas.alunaafrica.cloud
- **Deployment**: Docker Compose

## Deployment Architecture

```
Internet
    |
    v
Nginx Reverse Proxy (80/443)
    |
    +-- agent.veritas.alunaafrica.cloud --> Agent Zero (50001)
    +-- clawd.veritas.alunaafrica.cloud --> ClawdBot (50002)
    +-- memory.veritas.alunaafrica.cloud --> Aluna-Memory (50003)
    +-- vault.veritas.alunaafrica.cloud --> CogniVault (50004)
```

## Deployment Steps

### Phase 1: Initial VPS Setup
1. SSH into VPS: `ssh root@72.62.235.217`
2. Update system: `apt update && apt upgrade -y`
3. Install Docker & Docker Compose
4. Install Nginx
5. Setup firewall (UFW)
6. Install Certbot for SSL

### Phase 2: Clone Repositories
1. Create deployment directory: `/opt/veritas`
2. Clone Agent Zero
3. Clone Aluna-Memory
4. Setup CogniVault (if repository exists)
5. Setup ClawdBot (if repository exists)

### Phase 3: Configure Services
1. Create Docker Compose configurations for each service
2. Setup environment variables
3. Configure API keys (Groq, OpenRouter, Gemini, etc.)

### Phase 4: Setup Nginx & SSL
1. Configure Nginx reverse proxy
2. Setup DNS A records for subdomains
3. Obtain SSL certificates with Certbot
4. Enable HTTPS redirect

### Phase 5: Testing & Monitoring
1. Test each service endpoint
2. Setup monitoring (optional: Portainer)
3. Configure backups
4. Document access credentials

## DNS Configuration Required

Add these A records to alunaafrica.cloud DNS:
- veritas.alunaafrica.cloud → 72.62.235.217
- agent.veritas.alunaafrica.cloud → 72.62.235.217
- clawd.veritas.alunaafrica.cloud → 72.62.235.217
- memory.veritas.alunaafrica.cloud → 72.62.235.217
- vault.veritas.alunaafrica.cloud → 72.62.235.217

## API Keys Required
- OpenRouter API Key
- Groq API Key
- Google Gemini API Key
- HuggingFace API Key (optional)
- Novita API Key (optional)

## Next Actions
1. ✅ Document deployment plan
2. 🔄 Locate or create CogniVault repository
3. 🔄 Locate or create ClawdBot repository
4. ⏳ Create deployment scripts
5. ⏳ Test VPS SSH access
6. ⏳ Execute deployment

