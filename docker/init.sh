#!/bin/bash
set -euo pipefail

# ログ出力関数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&2
}

# エラーハンドリング
error_handler() {
    local line_no=$1
    log "ERROR: Script failed at line $line_no"
    exit 1
}

trap 'error_handler $LINENO' ERR

log "Starting initialization script..."

# 冪等性チェック関数
is_initialized() {
    [ -f "/workspaces/claude-code-python-project-template/.init_complete" ]
}

mark_initialized() {
    touch "/workspaces/claude-code-python-project-template/.init_complete"
    log "Marked initialization as complete"
}

# Python仮想環境の設定
setup_python_env() {
    log "Setting up Python virtual environment..."
    
    if [ ! -d "/workspaces/claude-code-python-project-template/.venv" ]; then
        cd /workspaces/claude-code-python-project-template
        uv venv .venv
        log "Created Python virtual environment"
    else
        log "Python virtual environment already exists"
    fi
    
    # 依存関係のインストール
    if [ -f "pyproject.toml" ]; then
        uv pip install -e .
        log "Installed project dependencies"
    fi
}

# pre-commit hooksの設定
setup_precommit() {
    log "Setting up pre-commit hooks..."
    
    cd /workspaces/claude-code-python-project-template
    
    if [ -f ".pre-commit-config.yaml" ]; then
        if ! command -v pre-commit &> /dev/null; then
            uv pip install pre-commit
        fi
        
        pre-commit install
        log "Pre-commit hooks installed"
    else
        log "No .pre-commit-config.yaml found, skipping pre-commit setup"
    fi
}

# 設定ファイルの生成
setup_config_files() {
    log "Setting up configuration files..."
    
    # .env.localの生成（存在しない場合のみ）
    if [ ! -f "/workspaces/claude-code-python-project-template/.env.local" ]; then
        cat > /workspaces/claude-code-python-project-template/.env.local << EOF
# Local development environment variables
DEV_MODE=true
PYTHONPATH=/workspaces/claude-code-python-project-template
EOF
        log "Created .env.local file"
    fi
}

# コマンド存在チェック関数
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ツール検証関数
verify_tool() {
    local tool_name="$1"
    local command_name="$2"
    local version_flag="${3:---version}"
    
    log "Checking $tool_name..."
    if command_exists "$command_name"; then
        local version
        version=$($command_name $version_flag 2>/dev/null | head -1)
        log "✓ $tool_name: $version"
        return 0
    else
        log "✗ $tool_name: Not found"
        return 1
    fi
}

# 必須ツールの検証
verify_essential_tools() {
    log "Verifying essential development tools..."
    
    local tool_check_failed=0
    
    # Essential tools verification
    verify_tool "Python" "python3" || tool_check_failed=1
    verify_tool "uv (Python package manager)" "uv" || tool_check_failed=1
    verify_tool "Node.js" "node" || tool_check_failed=1
    verify_tool "npm" "npm" || tool_check_failed=1
    verify_tool "GitHub CLI" "gh" || tool_check_failed=1
    verify_tool "Git" "git" || tool_check_failed=1
    verify_tool "ripgrep" "rg" "--version" || tool_check_failed=1
    verify_tool "jq" "jq" || tool_check_failed=1
    verify_tool "curl" "curl" || tool_check_failed=1
    verify_tool "wget" "wget" || tool_check_failed=1
    
    # Additional development tools (optional)
    verify_tool "zsh" "zsh" "--version" || log "⚠ zsh not found (optional)"
    verify_tool "tree" "tree" || log "⚠ tree not found (optional)"
    
    if [ $tool_check_failed -eq 1 ]; then
        log "❌ Some essential tools are missing. Please check the Dockerfile configuration."
        exit 1
    fi
    
    log "✅ All essential development tools are available."
}

# 必要なディレクトリの作成
setup_directories() {
    log "Creating necessary directories..."
    mkdir -p .venv
    mkdir -p ~/.claude
    mkdir -p .pytest_cache
    mkdir -p /workspaces/claude-code-python-project-template/.cache/uv
}

# シェル環境のセットアップ
setup_shell_environment() {
    log "Setting up shell environment..."
    if [ ! -f ~/.zshrc ]; then
        touch ~/.zshrc
    fi
    
    # Add development tools to PATH if not already present
    if ! grep -q "/home/vscode/.local/bin" ~/.zshrc 2>/dev/null; then
        echo 'export PATH="/home/vscode/.local/bin:$PATH"' >> ~/.zshrc
    fi
}

# システム情報の表示
display_system_info() {
    log "System Information:"
    log "  OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")"
    log "  Architecture: $(uname -m)"
    log "  User: $(whoami)"
    log "  Working Directory: $(pwd)"
    log "  Python Location: $(which python3)"
    log "  Node.js Location: $(which node)"
}

# 認証状態の確認
check_authentication() {
    # Verify Claude Code CLI authentication
    log "Checking Claude Code CLI authentication..."
    if command_exists "claude-code" && claude-code auth status >/dev/null 2>&1; then
        log "✓ Claude Code CLI is authenticated"
    else
        log "⚠ Claude Code CLI is not authenticated. Run 'claude-code auth login' to authenticate."
    fi
    
    # Verify GitHub CLI authentication
    log "Checking GitHub CLI authentication..."
    if gh auth status >/dev/null 2>&1; then
        log "✓ GitHub CLI is authenticated"
    else
        log "⚠ GitHub CLI is not authenticated. Run 'gh auth login' to authenticate."
    fi
}

# メイン処理
main() {
    if is_initialized; then
        log "Environment already initialized, skipping..."
    else
        verify_essential_tools
        setup_directories
        setup_python_env
        setup_precommit
        setup_config_files
        setup_shell_environment
        check_authentication
        display_system_info
        
        mark_initialized
        log "🎉 Initialization completed successfully!"
        log ""
        log "Next steps:"
        log "  1. Run 'uv sync' to install Python dependencies"
        log "  2. Run 'gh auth login' to authenticate with GitHub"
        log "  3. Run 'claude-code auth login' to authenticate with Claude Code"
        log "  4. Start developing with all tools available!"
        log ""
        log "To run health check anytime: /tmp/health-check.sh"
        log "========================================================"
    fi
    
    # Execute the command passed as arguments
    if [ $# -gt 0 ]; then
        log "Executing command: $*"
        exec "$@"
    fi
}

main "$@"