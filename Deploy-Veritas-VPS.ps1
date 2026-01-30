# VERITAS VPS Deployment from Windows
# PowerShell Script
# Rob "The Sounds Guy" Barenbrug - 2026-01-30

$ErrorActionPreference = "Stop"

# VPS Configuration
$VPS_IP = "72.62.235.217"
$VPS_HOST = "veritas.alunaafrica.cloud"
$VPS_USER = "root"
$VPS_PASS = "Cl@wdB0tEcon0my2026"

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║       VERITAS VPS Deployment - Windows Launcher          ║" -ForegroundColor Blue
Write-Host "║          veritas.alunaafrica.cloud (72.62.235.217)       ║" -ForegroundColor Blue
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Check for SSH
Write-Host "[1/5] Checking for SSH client..." -ForegroundColor Green
$sshPath = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $sshPath) {
    Write-Host "  ✗ SSH client not found!" -ForegroundColor Red
    Write-Host "  Please install OpenSSH or use PuTTY" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installation options:" -ForegroundColor Yellow
    Write-Host "  1. Windows Settings → Apps → Optional Features → Add OpenSSH Client" -ForegroundColor Yellow
    Write-Host "  2. Download PuTTY: https://www.putty.org/" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "  ✓ SSH client found: $($sshPath.Path)" -ForegroundColor Green
}

# Create temporary script
Write-Host ""
Write-Host "[2/5] Creating deployment script..." -ForegroundColor Green

$deployScript = @"
#!/bin/bash
echo '╔═══════════════════════════════════════════════════════════╗'
echo '║         VERITAS VPS Remote Deployment Started            ║'
echo '╚═══════════════════════════════════════════════════════════╝'
echo ''

# Download setup script
echo '[1/3] Downloading setup script...'
curl -o /root/veritas-setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh
if [ ! -f /root/veritas-setup.sh ]; then
    echo '✗ Failed to download setup script!'
    echo 'Manual download: curl -o setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh'
    exit 1
fi
echo '✓ Setup script downloaded'

# Make executable
echo ''
echo '[2/3] Making script executable...'
chmod +x /root/veritas-setup.sh
echo '✓ Script is executable'

# Run setup
echo ''
echo '[3/3] Running setup (this may take 10-15 minutes)...'
/root/veritas-setup.sh

echo ''
echo '╔═══════════════════════════════════════════════════════════╗'
echo '║              VERITAS VPS Setup Complete!                  ║'
echo '╚═══════════════════════════════════════════════════════════╝'
echo ''
echo 'Next steps:'
echo '  1. Set root password: passwd'
echo '  2. Configure API keys: nano /opt/veritas/.env'
echo '  3. Start services: cd /opt/veritas && ./start-services.sh'
echo ''
"@

$tempScript = "$env:TEMP\veritas-deploy.sh"
$deployScript | Out-File -FilePath $tempScript -Encoding ASCII -NoNewline

Write-Host "  ✓ Deployment script created" -ForegroundColor Green

# Show connection info
Write-Host ""
Write-Host "[3/5] VPS Connection Details:" -ForegroundColor Green
Write-Host "  Host:     $VPS_IP" -ForegroundColor Cyan
Write-Host "  User:     $VPS_USER" -ForegroundColor Cyan
Write-Host "  Domain:   $VPS_HOST" -ForegroundColor Cyan
Write-Host ""

# Interactive deployment menu
Write-Host "[4/5] Deployment Options:" -ForegroundColor Green
Write-Host "  1. Full Automatic Deployment (Recommended)" -ForegroundColor White
Write-Host "  2. Connect via SSH for Manual Setup" -ForegroundColor White
Write-Host "  3. Connect via Remote Desktop (RDP)" -ForegroundColor White
Write-Host "  4. Open Portainer Web Interface" -ForegroundColor White
Write-Host "  5. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Select option (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "[5/5] Starting automatic deployment..." -ForegroundColor Green
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
        Write-Host "Connecting to VPS and running setup script..." -ForegroundColor Yellow
        Write-Host "This may take 10-15 minutes. Please wait..." -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
        Write-Host ""
        
        # Upload and execute script via SSH
        $sshCommand = "bash -s"
        Get-Content $tempScript | ssh "$VPS_USER@$VPS_IP" $sshCommand
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║            Deployment Completed Successfully!             ║" -ForegroundColor Green
            Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            Write-Host "Access Your Services:" -ForegroundColor Cyan
            Write-Host "  Portainer:        https://$VPS_IP:9443" -ForegroundColor White
            Write-Host "  Remote Desktop:   $VPS_IP:3389 (user: root)" -ForegroundColor White
            Write-Host "  CogniVault:       http://$VPS_IP:50004" -ForegroundColor White
            Write-Host "  Aluna-Memory:     http://$VPS_IP:50003" -ForegroundColor White
            Write-Host ""
            Write-Host "Important Next Steps:" -ForegroundColor Yellow
            Write-Host "  1. Set root password for RDP: ssh $VPS_USER@$VPS_IP 'passwd'" -ForegroundColor White
            Write-Host "  2. Configure API keys: ssh $VPS_USER@$VPS_IP 'nano /opt/veritas/.env'" -ForegroundColor White
            Write-Host "  3. Start services: ssh $VPS_USER@$VPS_IP 'cd /opt/veritas && ./start-services.sh'" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "✗ Deployment failed! Check output above for errors." -ForegroundColor Red
            Write-Host ""
            Write-Host "Troubleshooting:" -ForegroundColor Yellow
            Write-Host "  - Verify VPS is accessible: ping $VPS_IP" -ForegroundColor White
            Write-Host "  - Check SSH connection: ssh $VPS_USER@$VPS_IP" -ForegroundColor White
            Write-Host "  - Review logs on VPS: ssh $VPS_USER@$VPS_IP 'journalctl -xe'" -ForegroundColor White
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "[5/5] Opening SSH connection..." -ForegroundColor Green
        Write-Host ""
        Write-Host "Commands to run on VPS:" -ForegroundColor Yellow
        Write-Host "  1. Download: curl -o setup.sh https://raw.githubusercontent.com/SoundsguyZA/aluna-memory/main/VERITAS_VPS_COMPLETE_SETUP.sh" -ForegroundColor Cyan
        Write-Host "  2. Execute: chmod +x setup.sh && ./setup.sh" -ForegroundColor Cyan
        Write-Host ""
        ssh "$VPS_USER@$VPS_IP"
    }
    
    "3" {
        Write-Host ""
        Write-Host "[5/5] Opening Remote Desktop connection..." -ForegroundColor Green
        Write-Host ""
        Write-Host "NOTE: You must complete VPS setup first!" -ForegroundColor Yellow
        Write-Host "      And set root password with: passwd" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Launching RDP client..." -ForegroundColor Green
        Start-Process "mstsc.exe" -ArgumentList "/v:${VPS_IP}:3389"
    }
    
    "4" {
        Write-Host ""
        Write-Host "[5/5] Opening Portainer web interface..." -ForegroundColor Green
        Write-Host ""
        Write-Host "NOTE: Portainer must be installed first!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Opening browser..." -ForegroundColor Green
        Start-Process "https://${VPS_IP}:9443"
    }
    
    "5" {
        Write-Host ""
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    
    default {
        Write-Host ""
        Write-Host "Invalid option. Exiting..." -ForegroundColor Red
        exit 1
    }
}

# Cleanup
Remove-Item $tempScript -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Script completed. Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
