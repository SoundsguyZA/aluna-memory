# 🔥 TERMUX POWERHOUSE - Huawei Pura 80 Pro Linux Workstation Setup

**Device:** Huawei Pura 80 Pro (No Google Play)  
**OS:** Termux + Linux environment  
**Target:** Full VPS deployment + local dev environment  
**Vibe:** Code Meister Guru Mode 💯  
**Built by:** VERITAS - Rob "The Sounds Guy" Barenbrug

---

## 📱 STEP 1: Check What You Got

```bash
# List ALL installed Termux packages
pkg list-installed

# Or for cleaner output
dpkg --get-selections | grep -v deinstall

# Show package count
pkg list-installed | wc -l

# Show only package names (clean list)
pkg list-installed | awk '{print $1}' | cut -d'/' -f1

# Export to file for analysis
pkg list-installed > ~/termux_packages.txt
cat ~/termux_packages.txt
```

---

## 🚀 STEP 2: Ultimate Termux Dev Environment

### Core System Essentials
```bash
# Update everything first
pkg update && pkg upgrade -y

# Essential tools
pkg install -y \
  termux-api \
  termux-tools \
  termux-services \
  openssh \
  git \
  curl \
  wget \
  rsync \
  zip \
  unzip \
  tar \
  gzip \
  htop \
  tree \
  ncdu \
  tmux \
  vim \
  nano \
  micro \
  bat \
  exa \
  ripgrep \
  fd \
  jq
```

### Python Power Stack
```bash
pkg install -y \
  python \
  python-pip \
  python-numpy \
  python-pandas \
  python-pillow

# Upgrade pip
pip install --upgrade pip

# Essential Python tools
pip install \
  streamlit \
  requests \
  httpx \
  aiohttp \
  beautifulsoup4 \
  lxml \
  pandas \
  numpy \
  pillow \
  python-dotenv \
  pydantic \
  fastapi \
  uvicorn
```

### Node.js & JavaScript
```bash
pkg install -y nodejs nodejs-lts

# Global utilities
npm install -g \
  npm \
  pnpm \
  yarn \
  pm2 \
  nodemon \
  http-server \
  serve \
  vercel \
  netlify-cli
```

### Docker Alternative - PRoot Distro
```bash
# Install PRoot for full Linux distro
pkg install -y proot-distro

# Install Ubuntu (recommended for Docker-like experience)
proot-distro install ubuntu

# Or install Debian
proot-distro install debian

# Login to Ubuntu
proot-distro login ubuntu

# Inside Ubuntu, install Docker (if needed)
apt update && apt install -y docker.io
```

### Code Editors & IDEs
```bash
# Neovim (lightweight, powerful)
pkg install -y neovim

# Emacs (if you're into that)
pkg install -y emacs

# Micro (modern, easy)
pkg install -y micro

# Code-server (VS Code in browser!)
npm install -g code-server

# Start code-server
code-server --bind-addr 0.0.0.0:8080 --auth none
# Access via phone browser: http://localhost:8080
```

### Terminal Enhancement
```bash
# Oh My Termux (beautiful prompt)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/4679/oh-my-termux/master/install.sh)"

# Or Zsh + Oh My Zsh
pkg install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Starship prompt (modern, fast)
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init bash)"' >> ~/.bashrc
```

### SSH & Remote Access
```bash
# Setup SSH server on Termux
pkg install -y openssh

# Generate SSH keys
ssh-keygen -t ed25519 -C "rob@pura80pro"

# Start SSH server
sshd

# Get your IP
ifconfig

# Get SSH port (usually 8022)
echo "SSH Port: 8022"
echo "Connect with: ssh -p 8022 u0_a123@your-phone-ip"
```

### Database Tools
```bash
# SQLite
pkg install -y sqlite

# PostgreSQL client
pkg install -y postgresql

# Redis (if available)
pkg install -y redis
```

### Network & API Tools
```bash
pkg install -y \
  nmap \
  netcat-openbsd \
  dnsutils \
  iproute2 \
  net-tools

# API testing
npm install -g httpie
pip install httpie
```

### File Sync & Cloud
```bash
# Rclone (sync to cloud)
pkg install -y rclone

# Syncthing (sync between devices)
pkg install -y syncthing
```

---

## 🔧 STEP 3: VPS Deployment from Termux

### Option A: Direct SSH Deployment
```bash
# Add VPS to known hosts
ssh-keyscan -p 22 72.62.235.217 >> ~/.ssh/known_hosts

# SSH into VPS
ssh root@72.62.235.217
# Password: Cl@wdB0tEcon0my2026

# Once connected, run deployment
curl -o setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh
chmod +x setup.sh
./setup.sh
```

### Option B: Automated Deploy Script
```bash
# Create deploy script
cat > ~/deploy-veritas.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 VERITAS VPS Deployment from Pura 80 Pro"
echo "=========================================="
echo ""

VPS_IP="72.62.235.217"
VPS_USER="root"

echo "📡 Connecting to VPS: $VPS_IP"
echo ""

# Copy SSH key to VPS (optional, for passwordless login)
# ssh-copy-id -p 22 $VPS_USER@$VPS_IP

# SSH and run deployment
ssh -t $VPS_USER@$VPS_IP << 'REMOTE_EOF'
echo "📥 Downloading setup script..."
curl -o /root/veritas-setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh

echo "🔧 Making executable..."
chmod +x /root/veritas-setup.sh

echo "🚀 Running setup..."
/root/veritas-setup.sh

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "  1. Set root password: passwd"
echo "  2. Configure API keys: nano /opt/veritas/.env"
echo "  3. Start services: cd /opt/veritas && ./start-services.sh"
REMOTE_EOF

echo ""
echo "✅ Script completed!"
EOF

chmod +x ~/deploy-veritas.sh
~/deploy-veritas.sh
```

### Option C: Tmux Session Management
```bash
# Start tmux session
tmux new -s veritas

# Split screen horizontally
Ctrl+b "

# Split screen vertically
Ctrl+b %

# Navigate between panes
Ctrl+b ←↑→↓

# Create deployment session
tmux new -s deploy
ssh root@72.62.235.217

# Detach from tmux: Ctrl+b d
# Reattach: tmux attach -t deploy
```

---

## 🌐 STEP 4: Access VPS Services from Pura 80 Pro

### Via Browser
```bash
# Open Termux-API browser (if available)
termux-open-url https://72.62.235.217:9443  # Portainer
termux-open-url http://72.62.235.217:50004  # CogniVault
termux-open-url http://72.62.235.217:50003  # Aluna-Memory

# Or use w3m (terminal browser)
pkg install -y w3m
w3m http://72.62.235.217:50004
```

### Via SSH Tunnel (Secure Access)
```bash
# Create SSH tunnel for Portainer
ssh -L 9443:localhost:9443 root@72.62.235.217

# Now access on phone: http://localhost:9443

# Multiple tunnels
ssh -L 9443:localhost:9443 \
    -L 50003:localhost:50003 \
    -L 50004:localhost:50004 \
    root@72.62.235.217
```

### VNC Server (GUI Access)
```bash
# Install VNC server on Termux
pkg install -y tigervnc

# Start VNC server
vncserver :1

# Connect with VNC Viewer app
# Address: localhost:5901
```

---

## 🎨 STEP 5: Code Meister Guru Setup

### Neovim Config (The Vibe)
```bash
# Install Neovim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Create config
mkdir -p ~/.config/nvim
cat > ~/.config/nvim/init.vim << 'EOF'
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
colorscheme desert
EOF

# Install plugins
nvim +PlugInstall +qall
```

### Git Config
```bash
git config --global user.name "Rob Barenbrug"
git config --global user.email "soundslucrative@gmail.com"
git config --global core.editor "nvim"
git config --global init.defaultBranch main
```

### Aliases (The Dealer Shortcuts)
```bash
cat >> ~/.bashrc << 'EOF'

# VERITAS Aliases - Code Meister Edition
alias ll='exa -la --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias v='nvim'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias vps='ssh root@72.62.235.217'
alias deploy='~/deploy-veritas.sh'
alias ports='netstat -tulpn'
alias serve='python -m http.server 8000'
alias update='pkg update && pkg upgrade -y'
alias edit='micro'
alias code='code-server'

# Quick VPS commands
alias vps-status='ssh root@72.62.235.217 "cd /opt/veritas && ./status.sh"'
alias vps-start='ssh root@72.62.235.217 "cd /opt/veritas && ./start-services.sh"'
alias vps-stop='ssh root@72.62.235.217 "cd /opt/veritas && ./stop-services.sh"'
alias vps-logs='ssh root@72.62.235.217 "cd /opt/veritas && docker compose logs -f"'

# Directory shortcuts
alias web='cd ~/webapp'
alias cog='cd ~/cognivault'
alias proj='cd ~/projects'

echo "🔥 VERITAS Code Meister Mode Activated"
EOF

source ~/.bashrc
```

---

## 📦 STEP 6: Setup Dev Workspace

```bash
# Create directory structure
mkdir -p ~/projects/{aluna-memory,cognivault,agent-zero,scripts}
mkdir -p ~/backup
mkdir -p ~/temp

# Clone repos
cd ~/projects
git clone https://github.com/SoundsguyZA/aluna-memory.git
git clone https://github.com/SoundsguyZA/cognivault.git

# Setup virtual environments
cd ~/projects/cognivault
python -m venv venv
source venv/bin/activate
pip install -r requirements_integrated.txt
```

---

## 🎯 STEP 7: Local Testing Before VPS Deploy

```bash
# Test CogniVault locally
cd ~/projects/cognivault
streamlit run app_integrated.py --server.port 8501

# Access on phone browser: http://localhost:8501

# Test in background
streamlit run app_integrated.py --server.port 8501 &
```

---

## 🔥 ULTIMATE TERMUX POWER USER COMMANDS

```bash
# System info
uname -a
cat /proc/cpuinfo | grep "model name" | head -1
free -h
df -h

# Network info
ifconfig
netstat -tulpn
ss -tulpn

# Process management
htop
ps aux | grep python
pkill -f streamlit

# File management
tree -L 2 ~/projects
ncdu ~
du -sh ~/projects/*

# Search files
fd -e py  # Find all .py files
rg "memory_bridge" ~/projects  # Search in files

# Quick HTTP server
python -m http.server 8000 --bind 0.0.0.0

# Monitor logs
tail -f ~/logs/app.log
```

---

## 📱 BONUS: Phone-Optimized Workflow

### Termux Widget (Quick Actions)
```bash
# Create widget scripts
mkdir -p ~/.shortcuts

cat > ~/.shortcuts/deploy-vps.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
ssh root@72.62.235.217 'cd /opt/veritas && ./start-services.sh'
EOF

cat > ~/.shortcuts/vps-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
ssh root@72.62.235.217 'cd /opt/veritas && ./status.sh'
EOF

chmod +x ~/.shortcuts/*.sh
```

### Termux:Boot (Auto-start SSH)
```bash
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-sshd.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
sshd
EOF
chmod +x ~/.termux/boot/start-sshd.sh
```

---

## 🚀 READY TO DEPLOY?

```bash
# 1. List your current packages
pkg list-installed

# 2. Install the essentials above
# (copy-paste the install commands)

# 3. SSH into VPS
ssh root@72.62.235.217

# 4. Run deployment
curl -o setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh
chmod +x setup.sh
./setup.sh

# 5. Enjoy from your Pura 80 Pro! 🎉
```

---

**Built by VERITAS - Code Meister Guru Edition**  
**Rob "The Sounds Guy" Barenbrug**  
**Huawei Pura 80 Pro Linux Workstation** 💯🔥  
**2026-01-30**
