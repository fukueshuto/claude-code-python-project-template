# タスク: 開発環境Compose設定

## 概要
開発環境用のDocker Compose設定ファイルを作成する。bind mountによるリアルタイムファイル同期、ボリューム設定、適切な環境変数を含む完全な開発環境を構築する。

## 前提条件
- 依存タスク: Task 2.4, Task 4.2, Task 4.3（並行実行可能）
- 必要な知識: Docker Compose v2、bind mount、開発環境設定

## 対象ファイル
- [x] `compose.dev.yaml` - 開発環境用Compose設定（新規作成）

## 実装手順
1. [x] `compose.dev.yaml`の基本構成作成
   ```yaml
   name: claude-code-python-project-dev
   
   services:
     devcontainer-dev:
       build:
         context: .
         dockerfile: docker/Dockerfile.dev
       container_name: devcontainer-dev
       volumes:
         # Project files - bind mount for real-time sync
         - .:/workspaces/claude-code-python-project-template:cached
         # Claude Code config
         - claude-code-config:/home/vscode/.claude
       environment:
         - DEV_MODE=true
       working_dir: /workspaces/claude-code-python-project-template
       command: sleep infinity
       stdin_open: true
       tty: true
   
   volumes:
     claude-code-config:
       external: false
   ```

2. [x] 環境変数設定の追加
   ```yaml
   environment:
     - DEV_MODE=true
     - PYTHONUNBUFFERED=1
     - PYTHONDONTWRITEBYTECODE=1
     - DISPLAY=${DISPLAY:-}
     - UV_CACHE_DIR=/tmp/uv-cache
     - UV_LINK_MODE=copy
     - UV_PROJECT_ENVIRONMENT=/workspaces/claude-code-python-project-template/.venv
     - UV_COMPILE_BYTECODE=1
   ```

3. [x] 開発効率化設定の追加
   ```yaml
   # Add to service configuration
   networks:
     - default
   restart: unless-stopped
   init: true
   ```

4. [x] 動作確認テスト
   ```bash
   # Compose設定の検証
   docker compose -f compose.dev.yaml config
   
   # 開発環境の起動テスト
   docker compose -f compose.dev.yaml up -d
   
   # コンテナ内アクセステスト
   docker compose -f compose.dev.yaml exec devcontainer-dev whoami
   docker compose -f compose.dev.yaml exec devcontainer-dev pwd
   docker compose -f compose.dev.yaml exec devcontainer-dev env | grep UV_
   
   # ファイル同期テスト
   echo "test" > test-sync.txt
   docker compose -f compose.dev.yaml exec devcontainer-dev cat test-sync.txt
   rm test-sync.txt
   
   # 停止
   docker compose -f compose.dev.yaml down
   ```

5. [x] ボリューム確認
   ```bash
   # ボリューム作成確認
   docker volume ls | grep claude-code-config
   ```

## 完了条件
- [x] compose.dev.yamlが作成されている
- [x] Docker Compose v2最新仕様に準拠している
- [x] bind mountによるファイル同期が動作する
- [x] claude-code-configボリュームが設定されている
- [x] 環境変数がすべて正しく設定されている
- [x] コンテナが正常に起動・停止する
- [x] 開発に必要な設定（tty, stdin_open等）が含まれている
- [x] 既存のcompose.ymlと競合しない

## 実行テスト
```bash
# 完全テスト
docker compose -f compose.dev.yaml config --quiet && echo "Config valid"

docker compose -f compose.dev.yaml up -d
sleep 5

# 基本動作確認
docker compose -f compose.dev.yaml exec devcontainer-dev /bin/bash -c "
  echo 'User:' \$(whoami) &&
  echo 'WorkDir:' \$(pwd) &&
  echo 'Environment check:' &&
  env | grep -E '(DEV_MODE|PYTHON|UV_)' | sort &&
  echo 'Tools check:' &&
  uv --version &&
  git --version
"

# ファイル同期テスト
echo "sync-test-$(date +%s)" > test-file.txt
CONTENT=\$(docker compose -f compose.dev.yaml exec devcontainer-dev cat test-file.txt)
echo "File sync result: \$CONTENT"
rm test-file.txt

# クリーンアップ
docker compose -f compose.dev.yaml down
```

## 注意事項
- Docker Compose v2の最新仕様（`name`フィールド等）を使用
- bind mountには`cached`オプションを使用してパフォーマンス向上
- 既存の`compose.yml`と競合しないサービス名を使用
- 環境変数の設定漏れがないよう注意
- コンテナの再起動ポリシーを適切に設定

## コミットメッセージ案
```
feat: create development environment Docker Compose configuration

- Add compose.dev.yaml with bind mount for real-time file sync
- Configure claude-code-config volume for persistent settings
- Set comprehensive environment variables for development
- Enable interactive development with tty and stdin_open
- Ensure compatibility with Docker Compose v2 specifications
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 5.1
- 推定時間: 30分
- 全体設計書: `_overview-tasks.md`