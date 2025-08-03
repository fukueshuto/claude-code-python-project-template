#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "🚀 Initializing development container..."

# Update system packages
echo "📦 Updating system packages..."
# sudo apt-get update && sudo apt-get upgrade -y

# Install additional security and development tools
# echo "🔧 Installing additional tools..."

# Setup Python environment
echo "🐍 Setting up Python environment..."
uv sync

# Setup pre-commit hooks
# echo "🔍 Setting up pre-commit hooks..."
# if [ -f "pyproject.toml" ] || [ -f ".pre-commit-config.yaml" ]; then
#     uv run pre-commit install
# fi

# Setup firewall (requires sudo privileges)
echo "🛡️ Configuring firewall..."
FIREWALL_SCRIPT=".devcontainer/init-firewall.sh"
if [ -f "$FIREWALL_SCRIPT" ]; then
    # ファイルが見つかるので、こちらの処理が実行される
    chmod +x "$FIREWALL_SCRIPT"
    sudo "$FIREWALL_SCRIPT"
else
    echo "⚠️ WARNING: $FIREWALL_SCRIPT not found, skipping firewall setup"
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

# pwdコマンドの実行結果（=現在の絶対パス）を使って、安全なディレクトリとしてGitに登録する
git config --global --add safe.directory "$(pwd)/*"

# Configure npm global path to avoid permission issues
# Fix nvm permissions by taking ownership of the nvm directory
# This allows global npm installs without sudo and is compatible with nvm
echo "🔧 Taking ownership of nvm directory..."
sudo chown -R vscode:vscode /usr/local/share/nvm
# echo "🔧 Configuring npm global path..."
# NPM_GLOBAL_PATH_EXPORT='export PATH=/home/vscode/.npm-global/bin:$PATH'
# # Add to .bashrc if it's not already there
# if [ -f "/home/vscode/.bashrc" ] && ! grep -qF -- "$NPM_GLOBAL_PATH_EXPORT" /home/vscode/.bashrc; then
#     echo -e "\n# Set path for globally installed npm packages" >> /home/vscode/.bashrc
#     echo "$NPM_GLOBAL_PATH_EXPORT" >> /home/vscode/.bashrc
# fi
# # Add to .zshrc if it's not already there
# if [ -f "/home/vscode/.zshrc" ] && ! grep -qF -- "$NPM_GLOBAL_PATH_EXPORT" /home/vscode/.zshrc; then
#     echo -e "\n# Set path for globally installed npm packages" >> /home/vscode/.zshrc
#     echo "$NPM_GLOBAL_PATH_EXPORT" >> /home/vscode/.zshrc
# fi

# Setup shell environment
echo "🐚 Setting up shell environment..."
# Define shell additions (git wrapper and aliases)
# The git wrapper function is from: https://zenn.dev/cozy_corner/articles/60531a4b25b059
SHELL_ADDITIONS=$(cat <<'EOF'

# --- Function to prevent `git commit --no-verify` ---
git() {
    # Check if the subcommand is 'commit'
    if [ "$1" = "commit" ]; then
        # Loop through arguments to find '--no-verify'
        for arg in "$@"; do
            if [ "$arg" = "--no-verify" ]; then
                echo -e "\033[0;31m❌ ERROR: --no-verify bypasses quality checks and is forbidden.\033[0m" >&2
                echo "Pre-commit hooks ensure code quality. Please fix issues instead of bypassing them." >&2
                return 1
            fi
        done
    fi
    # Execute the original git command
    command git "$@"
}

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
)

# Append the additions to shell config files if they exist
if [ -f "/home/vscode/.bashrc" ]; then
    echo -e "\n${SHELL_ADDITIONS}" >> /home/vscode/.bashrc
fi
if [ -f "/home/vscode/.zshrc" ]; then
    echo -e "\n${SHELL_ADDITIONS}" >> /home/vscode/.zshrc
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

echo "export CLAUDE_CODE_AUTO_UPDATE=0" >> ~/.bashrc
echo "export CLAUDE_CODE_AUTO_UPDATE=0" >> ~/.zshrc
echo "export DISABLE_INTERLEAVED_THINKING=1" >> ~/.bashrc
echo "export DISABLE_INTERLEAVED_THINKING=1" >> ~/.zshrc

# Set up MCP servers
# Serena
# uvx --from git+https://github.com/oraios/serena serena start-mcp-server
# claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)

# nohup npx claude-code-templates@latest --analytics > /dev/null 2>&1 &

# Run system info on first setup
/home/vscode/workspace/scripts/sysinfo.sh