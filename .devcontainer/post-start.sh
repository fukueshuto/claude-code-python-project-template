#!/bin/bash
set -euo pipefail

echo "🚀 Running post-start commands..."

# Install pre-commit hooks
uv run pre-commit install

# Start Claude Code templates in the background
echo "🤖 Starting Claude Code templates in the background..."
nohup npx claude-code-templates@latest --analytics > /home/vscode/workspace/logs/claude-templates.log 2>&1 &

# --- ここからが重要 ---
# Wait for the server to be ready before finishing
echo "⏳ Waiting for port 3333 to be available..."
# while ! nc -z 127.0.0.1 3333; do
#   sleep 0.1 # wait for 100ms before check again
# done
echo "✅ Port 3333 is now open."

# MCPサーバーのセットアップなど、他の依存するコマンドがあればここに書く
# （例：init.shから移動する場合）
echo "🔗 Setting up MCP servers..."
# uvx --from git+https://github.com/oraios/serena serena start-mcp-server
# claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --enable-web-dashboard false --context ide-assistant --project $(pwd) || true
