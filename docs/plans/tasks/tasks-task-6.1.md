# タスク: パフォーマンス最適化

## 概要
マルチステージビルドの実装、Docker layerキャッシュの最適化、不要な依存関係の除去により、コンテナ起動時間を30秒以内、ビルド時間を最適化する。

## 前提条件
- 依存タスク: Task 5.3
- 必要な知識: Docker最適化技術、マルチステージビルド、キャッシュ戦略

## 対象ファイル
- [ ] `docker/Dockerfile.dev` - マルチステージビルド対応
- [ ] `docker/Dockerfile.prod` - 最適化実装
- [ ] `.dockerignore` - ビルド効率改善

## 実装手順
1. [ ] 現在のパフォーマンス測定（ベースライン）
   ```bash
   # ビルド時間測定
   echo "Measuring baseline performance..."
   
   # Development build time
   time docker build -f docker/Dockerfile.dev -t baseline-dev .
   
   # Production build time  
   time docker build -f docker/Dockerfile.prod -t baseline-prod .
   
   # Startup time
   time docker run --rm baseline-dev echo "Container started"
   
   # Image size
   docker images | grep baseline
   ```
2. [ ] マルチステージビルドの実装
   ```dockerfile
   # docker/Dockerfile.dev の最適化
   # Stage 1: Base setup
   FROM mcr.microsoft.com/devcontainers/base:ubuntu as base
   USER root
   
   # システムパッケージの一括インストール
   RUN apt-get update && apt-get install -y \
       curl wget git jq ca-certificates build-essential ripgrep \
       && rm -rf /var/lib/apt/lists/*
   
   # Stage 2: Tool installation
   FROM base as tools
   
   # GitHub CLI
   RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
       && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
       && apt-get update && apt-get install gh -y && rm -rf /var/lib/apt/lists/*
   
   # UV installation
   RUN curl -LsSf https://astral.sh/uv/install.sh | sh
   
   # Node.js installation
   RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
       && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*
   
   # Stage 3: Final setup
   FROM tools as final
   USER vscode
   WORKDIR /workspaces/claude-code-python-project-template
   
   # Environment variables
   ENV PYTHONUNBUFFERED=1 \
       PYTHONDONTWRITEBYTECODE=1 \
       UV_CACHE_DIR=/tmp/uv-cache \
       UV_LINK_MODE=copy \
       UV_PROJECT_ENVIRONMENT=/workspaces/claude-code-python-project-template/.venv \
       UV_COMPILE_BYTECODE=1 \
       DEV_MODE=true \
       PATH="/home/vscode/.cargo/bin:$PATH"
   
   # Cache directories
   RUN mkdir -p /tmp/uv-cache && sudo chown vscode:vscode /tmp/uv-cache
   ```
3. [ ] Docker layerキャッシュの最適化
   ```dockerfile
   # キャッシュ効率を考慮した順序での実装
   # 1. 変更頻度の低いものから高いものへ
   # 2. 依存関係の明確化
   # 3. 並列実行可能な処理の分離
   
   # Base packages (rarely change)
   RUN apt-get update && apt-get install -y \
       curl wget git jq ca-certificates build-essential ripgrep \
       && rm -rf /var/lib/apt/lists/*
   
   # External tools (change occasionally)
   RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
   
   # Dependencies (change frequently)
   COPY pyproject.toml ./
   RUN uv pip install -e .
   ```
4. [ ] 不要な依存関係の除去
   ```bash
   # 不要なパッケージの特定
   docker run --rm baseline-dev dpkg -l | grep -E "(doc|man|info)" | wc -l
   
   # パッケージサイズの分析
   docker run --rm baseline-dev du -sh /var/lib/apt/lists/* | head -10
   ```
   ```dockerfile
   # 不要なパッケージの除去
   RUN apt-get update && apt-get install -y \
       --no-install-recommends \
       curl wget git jq ca-certificates build-essential ripgrep \
       && apt-get autoremove -y \
       && apt-get clean \
       && rm -rf /var/lib/apt/lists/* \
       && rm -rf /tmp/* \
       && rm -rf /var/tmp/*
   ```
5. [ ] ビルドキャッシュ最適化の.dockerignore更新
   ```dockerignore
   # 追加の最適化項目
   **/.git
   **/node_modules
   **/__pycache__
   **/.*cache
   **/coverage
   **/dist
   **/build
   
   # 時間でソートされたファイル
   **/*.log
   **/*.tmp
   ```
6. [ ] 本番用Dockerfileの最適化
   ```dockerfile
   # Production用の最適化
   FROM mcr.microsoft.com/devcontainers/base:ubuntu as prod-base
   
   # 本番用の最小限パッケージのみ
   RUN apt-get update && apt-get install -y \
       --no-install-recommends \
       python3 python3-pip curl git \
       && rm -rf /var/lib/apt/lists/*
   
   # UV installation (production only)
   RUN curl -LsSf https://astral.sh/uv/install.sh | sh
   
   USER vscode
   WORKDIR /workspaces/claude-code-python-project-template
   
   # Copy only necessary files
   COPY --chown=vscode:vscode . .
   
   # Install dependencies
   RUN uv pip install -e . --no-cache-dir
   ```
7. [ ] 最適化後のパフォーマンス測定
   ```bash
   # 最適化後の測定
   echo "Measuring optimized performance..."
   
   # Build time
   time docker build -f docker/Dockerfile.dev -t optimized-dev .
   time docker build -f docker/Dockerfile.prod -t optimized-prod .
   
   # Startup time
   time docker run --rm optimized-dev echo "Container started"
   time docker run --rm optimized-prod echo "Container started"
   
   # Image size comparison
   echo "Image size comparison:"
   docker images | grep -E "(baseline|optimized)"
   
   # Layer analysis
   docker history optimized-dev --no-trunc
   ```
8. [ ] パフォーマンス結果の文書化
   ```bash
   # パフォーマンス結果をファイルに記録
   cat > performance_results.md << 'EOF'
   # Performance Optimization Results
   
   ## Before Optimization
   - Development build time: [baseline time]
   - Production build time: [baseline time]
   - Container startup time: [baseline time]
   - Image size: [baseline size]
   
   ## After Optimization
   - Development build time: [optimized time]
   - Production build time: [optimized time]  
   - Container startup time: [optimized time]
   - Image size: [optimized size]
   
   ## Improvements
   - Build time improvement: [percentage]
   - Startup time improvement: [percentage]
   - Size reduction: [percentage]
   
   ## Optimization Techniques Applied
   - Multi-stage builds
   - Layer caching optimization
   - Removed unnecessary dependencies
   - Improved .dockerignore
   EOF
   ```

## 完了条件
- [ ] コンテナ起動時間が30秒以内に短縮される
- [ ] ビルド時間が大幅に改善される（50%以上短縮目標）
- [ ] イメージサイズが最適化される
- [ ] Docker layerキャッシュが効率的に活用される
- [ ] 不要な依存関係が除去される
- [ ] マルチステージビルドが実装される
- [ ] パフォーマンス測定結果が文書化される

## 注意事項
- 最適化により機能が失われないよう注意深く実装する
- キャッシュ効率とビルド時間のバランスを取る
- セキュリティを損なわない範囲での最適化を行う
- 可読性を保ちながら最適化する

## コミットメッセージ案
```
perf: implement comprehensive Docker performance optimization

- Add multi-stage builds for development and production
- Optimize Docker layer caching strategy
- Remove unnecessary dependencies and packages
- Improve .dockerignore for better build context
- Achieve <30s startup time and significant build time reduction
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 6.1
- 推定時間: 45分
- 全体設計書: `_overview-tasks.md`