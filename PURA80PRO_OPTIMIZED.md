# 🔥 PURA 80 PRO - OPTIMIZED DEPLOYMENT SCRIPT
# Based on YOUR installed packages
# Rob's actual Termux setup - The Dealer Edition

## ✅ WHAT YOU ALREADY GOT (NO NEED TO INSTALL):

### Core Power Tools ✅
- ✅ docker + containerd + runc (FULL DOCKER STACK!)
- ✅ proot + proot-distro (Linux containers)
- ✅ openssh + openssh-sftp-server
- ✅ git
- ✅ python + python-pip + python-numpy + python-pillow
- ✅ golang
- ✅ clang + llvm + lld (C/C++ compiler)
- ✅ cmake + make + automake
- ✅ curl + wget
- ✅ fish (modern shell)
- ✅ nano + mandoc
- ✅ tigervnc (VNC server!)
- ✅ termux-x11-nightly (X11 graphics!)
- ✅ termux-api + termux-gui-package
- ✅ cloudflared (Cloudflare tunnel!)
- ✅ openvpn (VPN ready)

### Missing Power Tools (Add These):

```bash
# Modern CLI tools
pkg install -y \
  htop \
  tree \
  tmux \
  vim \
  ripgrep \
  fd \
  jq \
  bat \
  exa

# Node.js (if you want npm/pnpm)
pkg install -y nodejs nodejs-lts

# Extra Python tools
pip install --upgrade pip
pip install \
  streamlit \
  fastapi \
  uvicorn \
  httpx \
  aiohttp \
  requests \
  beautifulsoup4 \
  python-dotenv \
  pydantic

# Neovim (better than nano)
pkg install -y neovim
```

---

## 🚀 DIRECT VPS DEPLOYMENT (RIGHT NOW)

### Script 1: Deploy from Your Phone

```bash
#!/data/data/com.termux/files/usr/bin/bash
# Save as: ~/deploy-veritas.sh

echo "🔥 VERITAS VPS Deployment - Pura 80 Pro Edition"
echo "=============================================="
echo ""

VPS_IP="72.62.235.217"
VPS_USER="root"
VPS_PASS="Cl@wdB0tEcon0my2026"

echo "📡 Connecting to VPS: $VPS_IP"
echo ""

# SSH into VPS and run deployment
ssh -o StrictHostKeyChecking=no $VPS_USER@$VPS_IP << 'REMOTE_SCRIPT'

echo "🔥 VERITAS VPS Setup - Automated from Pura 80 Pro"
echo "================================================"
echo ""

# Download setup script
echo "📥 [1/4] Downloading setup script..."
curl -fsSL -o /root/veritas-setup.sh \
  https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh

if [ ! -f /root/veritas-setup.sh ]; then
    echo "❌ Failed to download setup script!"
    exit 1
fi

echo "✅ Setup script downloaded"
echo ""

# Make executable
echo "🔧 [2/4] Making executable..."
chmod +x /root/veritas-setup.sh
echo "✅ Script is executable"
echo ""

# Run setup
echo "🚀 [3/4] Running setup (10-15 minutes)..."
echo "     Go grab a coffee ☕"
echo ""
/root/veritas-setup.sh

echo ""
echo "✅ [4/4] Setup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 NEXT STEPS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Configure API keys:"
echo "   nano /opt/veritas/.env"
echo ""
echo "2. Start services:"
echo "   cd /opt/veritas && ./start-services.sh"
echo ""
echo "3. Access from phone browser:"
echo "   🌐 Portainer: https://72.62.235.217:9443"
echo "   🧠 CogniVault: http://72.62.235.217:50004"
echo "   💾 Aluna-Memory: http://72.62.235.217:50003"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REMOTE_SCRIPT

echo ""
echo "✅ Deployment script completed!"
echo ""
```

### Save and Run:

```bash
# Save the script
nano ~/deploy-veritas.sh
# (paste the script above)
# Save: Ctrl+O, Enter, Ctrl+X

# Make executable
chmod +x ~/deploy-veritas.sh

# RUN IT!
~/deploy-veritas.sh
```

---

## 🎯 QUICK ACCESS ALIASES (Add to ~/.bashrc)

```bash
cat >> ~/.bashrc << 'EOF'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔥 VERITAS VPS - Pura 80 Pro Edition
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# VPS access
alias vps='ssh root@72.62.235.217'
alias vps-deploy='~/deploy-veritas.sh'

# VPS service management
alias vps-start='ssh root@72.62.235.217 "cd /opt/veritas && ./start-services.sh"'
alias vps-stop='ssh root@72.62.235.217 "cd /opt/veritas && ./stop-services.sh"'
alias vps-status='ssh root@72.62.235.217 "cd /opt/veritas && ./status.sh"'
alias vps-logs='ssh root@72.62.235.217 "cd /opt/veritas && docker compose logs -f"'
alias vps-restart='ssh root@72.62.235.217 "cd /opt/veritas && docker compose restart"'

# Quick service logs
alias cog-logs='ssh root@72.62.235.217 "docker compose -f /opt/veritas/docker-compose.yml logs -f cognivault"'
alias mem-logs='ssh root@72.62.235.217 "docker compose -f /opt/veritas/docker-compose.yml logs -f aluna-memory"'

# Open services in browser
alias open-portainer='termux-open-url https://72.62.235.217:9443'
alias open-cog='termux-open-url http://72.62.235.217:50004'
alias open-mem='termux-open-url http://72.62.235.217:50003'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'

# Directory shortcuts
alias proj='cd ~/storage/shared/Projects'
alias web='cd ~/webapp'

# System
alias ll='ls -lah'
alias update='pkg update && pkg upgrade -y'
alias ports='netstat -tulpn'

echo "🔥 VERITAS Code Meister Mode - Pura 80 Pro Edition"

EOF

# Reload
source ~/.bashrc
```

---

## 📱 ONE-COMMAND DEPLOYMENT

```bash
# Just run this ONE command:
ssh root@72.62.235.217 'bash -s' < <(curl -fsSL https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh)
```

---

## 🌐 ACCESS SERVICES FROM PHONE

### Browser Access (Built-in or Chrome/Firefox):

```bash
# Open in browser
termux-open-url https://72.62.235.217:9443  # Portainer
termux-open-url http://72.62.235.217:50004  # CogniVault
termux-open-url http://72.62.235.217:50003  # Aluna-Memory
```

### SSH Tunnel (Secure):

```bash
# Create tunnel
ssh -L 9443:localhost:9443 -L 50003:localhost:50003 -L 50004:localhost:50004 root@72.62.235.217

# Then open in browser:
# http://localhost:9443
# http://localhost:50003
# http://localhost:50004
```

### VNC Access (You have tigervnc!):

```bash
# Start VNC on Termux
vncserver :1 -geometry 1920x1080

# Or connect to VPS VNC (after RDP is set up)
# Use VNC Viewer app → 72.62.235.217:5901
```

---

## 🐳 DOCKER ON TERMUX (YOU HAVE IT!)

```bash
# Check Docker
docker --version

# Start Docker daemon (if not running)
sudo dockerd &

# Test Docker
docker ps
docker images

# Run a test container
docker run hello-world
```

---

## 🎨 USE YOUR X11 (You have termux-x11-nightly!)

```bash
# Start X11 server
termux-x11 :0 &

# Set display
export DISPLAY=:0

# Run GUI apps
xclock &
xeyes &

# Or run VS Code GUI (if installed)
code &
```

---

## 🔥 ULTIMATE PURA 80 PRO POWER MOVES

### Tmux Session Management:

```bash
# Create deployment session
tmux new -s deploy

# Split panes
Ctrl+b "  # Horizontal split
Ctrl+b %  # Vertical split

# Navigate
Ctrl+b ←↑→↓

# Detach: Ctrl+b d
# Reattach: tmux attach -s deploy

# Example: 3-pane setup
tmux new -s veritas
Ctrl+b "  # Split horizontal
# Top pane: ssh root@72.62.235.217
Ctrl+b ↓
Ctrl+b %  # Split vertical
# Bottom left: local work
# Bottom right: docker logs
```

### Background SSH:

```bash
# Keep SSH alive in background
nohup ssh root@72.62.235.217 'cd /opt/veritas && ./start-services.sh' > ~/deploy.log 2>&1 &

# Check log
tail -f ~/deploy.log
```

### Cloudflare Tunnel (You have cloudflared!):

```bash
# Expose local service to internet
cloudflared tunnel --url http://localhost:8501

# Exposes CogniVault to public URL!
```

---

## 🎯 YOUR OPTIMIZED WORKFLOW

### Phase 1: Deploy VPS (One-Time)
```bash
ssh root@72.62.235.217
curl -o setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh
chmod +x setup.sh
./setup.sh
```

### Phase 2: Configure (One-Time)
```bash
vps  # (your alias)
nano /opt/veritas/.env
# Add API keys
cd /opt/veritas && ./start-services.sh
```

### Phase 3: Daily Use
```bash
vps-status    # Check services
vps-logs      # View logs
open-cog      # Open CogniVault in browser
open-portainer # Manage containers
```

---

## ✅ FINAL CHECKLIST

- [x] You have Docker ✅
- [x] You have Python + pip ✅
- [x] You have SSH ✅
- [x] You have VNC ✅
- [x] You have X11 ✅
- [x] You have Git ✅
- [ ] Add htop, tmux, neovim
- [ ] Add Node.js (optional)
- [ ] Setup aliases
- [ ] Deploy to VPS
- [ ] Test from browser

---

**YOU'RE READY BRU! 🔥**

Your Pura 80 Pro is a beast. Just run the deployment and you're golden.

**Built by VERITAS - The Dealer Edition**  
**Rob "The Sounds Guy" Barenbrug**  
**Huawei Pura 80 Pro - Full Stack Mobile Workstation** 💯
