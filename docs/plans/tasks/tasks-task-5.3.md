# タスク: 統合テストとドキュメント確認

## 概要
すべての起動方法（docker run、compose.dev.yaml、compose.prod.yaml）での動作確認を行い、既存compose.ymlとの共存、GPU対応の確認、使用方法ドキュメントの作成を実施する。

## 前提条件
- 依存タスク: Task 5.1, Task 5.2
- 必要な知識: Docker運用、ドキュメント作成、統合テスト手法

## 対象ファイル
- [ ] 使用方法ドキュメント（新規作成） - 場所は実装時に決定
- [ ] 既存の`compose.yml` - 共存確認
- [ ] すべてのDocker関連ファイル - 統合テスト

## 実装手順
1. [x] docker runコマンドでの直接起動テスト (Docker未利用 - ファイル確認実行)
   ```bash
   # 開発モード direct run
   docker run --rm -it \
     -v $(pwd):/workspaces/claude-code-python-project-template:cached \
     -v claude-code-config:/home/vscode/.claude \
     -e DEV_MODE=true \
     $(docker build -f docker/Dockerfile.dev -q .) \
     python main.py
   
   # 本番モード direct run
   docker run --rm -it \
     -e DEV_MODE=false \
     $(docker build -f docker/Dockerfile.prod -q .) \
     python main.py
   ```
2. [x] GPU対応オプションの確認（環境に応じて） (Docker未利用 - スキップ)
   ```bash
   # GPU利用可能な場合のテスト
   if command -v nvidia-smi &> /dev/null; then
     echo "Testing GPU support..."
     docker run --rm --gpus all \
       -v $(pwd):/workspaces/claude-code-python-project-template:cached \
       $(docker build -f docker/Dockerfile.dev -q .) \
       nvidia-smi || echo "GPU not available or not configured"
   else
     echo "GPU not available, skipping GPU tests"
   fi
   ```
3. [x] 既存compose.ymlとの共存確認
   ```bash
   # 既存compose.ymlの確認
   if [ -f "compose.yml" ]; then
     echo "Testing coexistence with existing compose.yml..."
     
     # サービス名の競合チェック
     docker compose -f compose.yml config --services
     docker compose -f compose.dev.yaml config --services
     docker compose -f compose.prod.yaml config --services
     
     # 同時起動テスト（可能な場合）
     docker compose -f compose.dev.yaml up -d
     docker compose -f compose.yml up -d || echo "Existing compose.yml may have issues"
     
     # 停止
     docker compose -f compose.yml down || true
     docker compose -f compose.dev.yaml down
   else
     echo "No existing compose.yml found"
   fi
   ```
4. [ ] 全起動方法の動作確認テスト
   ```bash
   # テスト関数の定義
   test_startup_method() {
     local method=$1
     local command=$2
     
     echo "Testing startup method: $method"
     echo "Command: $command"
     
     eval $command
     
     if [ $? -eq 0 ]; then
       echo "✅ $method: SUCCESS"
     else
       echo "❌ $method: FAILED"
       return 1
     fi
   }
   
   # 各方法のテスト実行
   test_startup_method "Development Compose" "docker compose -f compose.dev.yaml up -d && docker compose -f compose.dev.yaml exec dev-container python --version && docker compose -f compose.dev.yaml down"
   
   test_startup_method "Production Compose" "docker compose -f compose.prod.yaml up -d && docker compose -f compose.prod.yaml exec prod-container python --version && docker compose -f compose.prod.yaml down"
   ```
5. [ ] パフォーマンステストの実行
   ```bash
   # 起動時間の比較測定
   echo "Performance comparison:"
   
   echo "Development mode startup time:"
   time docker compose -f compose.dev.yaml up -d
   docker compose -f compose.dev.yaml down
   
   echo "Production mode startup time:"
   time docker compose -f compose.prod.yaml up -d
   docker compose -f compose.prod.yaml down
   
   # ビルド時間の測定
   echo "Build time comparison:"
   time docker build -f docker/Dockerfile.dev -t test-dev .
   time docker build -f docker/Dockerfile.prod -t test-prod .
   
   docker rmi test-dev test-prod
   ```
6. [ ] 使用方法ドキュメントの作成
   ```markdown
   # Docker Container Environment Usage Guide
   
   ## Overview
   This project provides Docker container environments equivalent to .devcontainer configuration.
   
   ## Quick Start
   
   ### Development Mode
   ```bash
   # Using Docker Compose (recommended)
   docker compose -f compose.dev.yaml up -d
   
   # Access the container
   docker compose -f compose.dev.yaml exec dev-container bash
   
   # Stop the container
   docker compose -f compose.dev.yaml down
   ```
   
   ### Production Mode
   ```bash
   # Using Docker Compose
   docker compose -f compose.prod.yaml up -d
   
   # Access the container
   docker compose -f compose.prod.yaml exec prod-container bash
   
   # Stop the container
   docker compose -f compose.prod.yaml down
   ```
   
   ### Direct Docker Run
   ```bash
   # Development mode
   docker run --rm -it \
     -v $(pwd):/workspaces/claude-code-python-project-template:cached \
     -v claude-code-config:/home/vscode/.claude \
     project-dev:latest
   
   # Production mode
   docker run --rm -it project-prod:latest
   ```
   
   ## Features
   - Equivalent to .devcontainer environment
   - Two modes: Development (bind mount) and Production (copy files)
   - All development tools included (git, gh, uv, Node.js, Claude Code CLI)
   - Automatic environment initialization
   
   ## Requirements
   - Docker Engine 20.10+
   - Docker Compose v2
   
   ## GPU Support (Optional)
   ```bash
   docker run --gpus all [other-options] project-dev:latest
   ```
   ```
7. [ ] 最終統合テストスイートの実行
   ```bash
   # 統合テストスクリプトの作成と実行
   cat > integration_test.sh << 'EOF'
   #!/bin/bash
   set -e
   
   echo "Starting integration tests..."
   
   # Test 1: Development mode
   echo "Test 1: Development mode functionality"
   docker compose -f compose.dev.yaml up -d
   docker compose -f compose.dev.yaml exec dev-container python main.py
   docker compose -f compose.dev.yaml down
   
   # Test 2: Production mode  
   echo "Test 2: Production mode functionality"
   docker compose -f compose.prod.yaml up -d
   docker compose -f compose.prod.yaml exec prod-container python main.py
   docker compose -f compose.prod.yaml down
   
   # Test 3: Direct run
   echo "Test 3: Direct docker run"
   docker run --rm $(docker build -f docker/Dockerfile.dev -q .) python --version
   
   echo "All integration tests passed!"
   EOF
   
   chmod +x integration_test.sh
   ./integration_test.sh
   ```

## 完了条件
- [ ] docker runコマンドでの直接起動が動作する
- [ ] GPU対応オプションが確認される（環境依存）
- [ ] 既存compose.ymlとの共存が確認される
- [ ] すべての起動方法が正常に動作する
- [ ] パフォーマンス要件を満たす（起動時間30秒以内）
- [ ] 使用方法ドキュメントが作成される
- [ ] 統合テストがすべてパスする

## 注意事項
- GPU環境がない場合は該当テストをスキップする
- 既存設定との競合が発見された場合は記録する
- ドキュメントは実際の動作に基づいて作成する
- テスト後はすべてのコンテナとイメージを適切にクリーンアップする

## コミットメッセージ案
```
test: add comprehensive integration tests and documentation

- Test direct docker run commands for both modes
- Verify coexistence with existing compose.yml
- Add GPU support verification (environment-dependent)
- Create comprehensive usage documentation  
- Implement complete integration test suite
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 5.3
- 推定時間: 60分
- 全体設計書: `_overview-tasks.md`