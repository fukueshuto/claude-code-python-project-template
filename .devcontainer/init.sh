#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "🚀 Initializing development container..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install additional security and development tools
echo "🔧 Installing additional tools..."
sudo apt-get install -y \
    iptables \
    ipset \
    fail2ban \
    ufw \
    htop \
    tree \
    vim \
    tmux \
    zsh-autosuggestions \
    zsh-syntax-highlighting

# Setup Python environment
echo "🐍 Setting up Python environment..."
uv sync

# Setup pre-commit hooks
echo "🔍 Setting up pre-commit hooks..."
if [ -f "pyproject.toml" ] || [ -f ".pre-commit-config.yaml" ]; then
    uv run pre-commit install
fi

# Setup firewall (requires sudo privileges)
echo "🛡️ Configuring firewall..."
if [ -f "init-firewall.sh" ]; then
    chmod +x init-firewall.sh
    sudo ./init-firewall.sh
else
    echo "⚠️ WARNING: init-firewall.sh not found, skipping firewall setup"
fi

# Setup git configuration if not already configured
echo "📋 Setting up git configuration..."
if [ -z "$(git config --global user.name 2>/dev/null || true)" ]; then
    echo "ℹ️ Git user.name not configured. You may want to run:"
    echo "   git config --global user.name 'Your Name'"
fi
if [ -z "$(git config --global user.email 2>/dev/null || true)" ]; then
    echo "ℹ️ Git user.email not configured. You may want to run:"
    echo "   git config --global user.email 'your.email@example.com'"
fi

# Setup shell environment
echo "🐚 Setting up shell environment..."
# Add useful aliases to .zshrc if it exists
if [ -f "/home/vscode/.zshrc" ]; then
    cat >> /home/vscode/.zshrc << 'EOF'

# Development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Python/UV aliases
alias py='uv run python'
alias pip='uv pip'
alias pytest='uv run pytest'
alias ruff='uv run ruff'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Firewall management aliases
alias fw-status='sudo iptables -L -n -v'
alias fw-blocked='sudo ipset list blocked-domains'
alias fw-allowed='sudo ipset list allowed-inbound'

EOF
fi

# Create useful directories
echo "📁 Creating project directories..."
mkdir -p /home/vscode/workspace/{logs,tmp,data,scripts}

# Setup Claude Code configuration directory permissions
echo "🤖 Setting up Claude Code permissions..."
sudo chown -R vscode:vscode /home/vscode/.claude 2>/dev/null || true

# Setup SSH directory with proper permissions
echo "🔑 Setting up SSH directory..."
mkdir -p /home/vscode/.ssh
chmod 700 /home/vscode/.ssh
sudo chown vscode:vscode /home/vscode/.ssh

# Create a simple system info script
echo "📊 Creating system info script..."
cat > /home/vscode/workspace/scripts/sysinfo.sh << 'EOF'
#!/bin/bash
echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "CPU Cores: $(nproc)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"
echo "Uptime: $(uptime -p)"
echo ""
echo "=== Network Configuration ==="
ip addr show | grep -E "(inet |UP)" | grep -v "127.0.0.1"
echo ""
echo "=== Firewall Status ==="
sudo iptables -L INPUT -n --line-numbers | head -10
echo ""
echo "=== Python Environment ==="
which python3
python3 --version
echo "UV Version: $(uv --version)"
EOF
chmod +x /home/vscode/workspace/scripts/sysinfo.sh

# Setup log rotation for development logs
echo "📝 Setting up log rotation..."
sudo tee /etc/logrotate.d/devcontainer << 'EOF' > /dev/null
/home/vscode/workspace/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 vscode vscode
}
EOF

# Set proper ownership for vscode user
echo "👤 Setting proper ownership..."
sudo chown -R vscode:vscode /home/vscode/workspace

# Display completion message with useful information
echo ""
echo "✅ Development container initialization complete!"
echo ""
echo "🎯 Quick Start Commands:"
echo "  - System info: ~/workspace/scripts/sysinfo.sh"
echo "  - Firewall status: fw-status"
echo "  - Python REPL: py"
echo "  - Install packages: uv add <package>"
echo "  - Run tests: pytest"
echo ""
echo "📁 Project structure:"
echo "  ~/workspace/logs/    - Application logs"
echo "  ~/workspace/tmp/     - Temporary files"
echo "  ~/workspace/data/    - Data files"
echo "  ~/workspace/scripts/ - Utility scripts"
echo ""

# Run system info on first setup
/home/vscode/workspace/scripts/sysinfo.sh