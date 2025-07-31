# タスク: 開発環境用Compose設定

## 概要
compose.dev.yamlを作成し、開発モードでのコンテナ起動設定を実装する。bind mountによるリアルタイムファイル同期、claude-code-configボリューム、開発モード固有の環境変数設定を行う。

## 前提条件
- 依存タスク: Task 2.3
- 必要な知識: Docker Compose v2仕様、bind mount、ボリューム管理

## 対象ファイル
- [x] `compose.dev.yaml` - 開発環境用Docker Compose設定（新規作成）

## 実装手順
1. [x] compose.dev.yamlの基本構造作成
   ```yaml
   version: '3.8'
   
   services:
     dev-container:
       build:
         context: .
         dockerfile: docker/Dockerfile.dev
       container_name: claude-code-dev
   ```
2. [x] bind mountの設定
   ```yaml
       volumes:
         # プロジェクトルートのbind mount（cachedオプション使用）
         - .:/workspaces/claude-code-python-project-template:cached
         # Claude Code設定ボリューム
         - claude-code-config:/home/vscode/.claude
   ```
3. [x] 開発モード固有の環境変数設定
   ```yaml
       environment:
         - DEV_MODE=true
         - PYTHONUNBUFFERED=1
         - PYTHONDONTWRITEBYTECODE=1
         - UV_CACHE_DIR=/tmp/uv-cache
         - UV_LINK_MODE=copy
         - UV_PROJECT_ENVIRONMENT=/workspaces/claude-code-python-project-template/.venv
         - UV_COMPILE_BYTECODE=1
         - DISPLAY=${DISPLAY:-}
   ```
4. [x] ポート設定（必要に応じて）
   ```yaml
       ports:
         - "8000:8000"  # 開発サーバー用
   ```
5. [x] ボリューム定義
   ```yaml
   volumes:
     claude-code-config:
       driver: local
   ```
6. [x] tty設定とinteractive設定
   ```yaml
       tty: true
       stdin_open: true
   ```
7. [x] 開発用ネットワーク設定
   ```yaml
       networks:
         - dev-network
   
   networks:
     dev-network:
       driver: bridge
   ```
8. [x] 動作確認テスト
   - `docker compose -f compose.dev.yaml up -d`でコンテナが起動する
   - ファイル同期が正常に動作する
   - ボリュームマウントが正しく設定される

## 完了条件
- [x] compose.dev.yamlが作成され、Docker Compose v2仕様に準拠している
- [x] 開発モードでコンテナが正常に起動する
- [x] bind mountによるファイル同期が動作する（ホスト→コンテナ）
- [x] claude-code-configボリュームが正しく設定される
- [x] 環境変数が正しく設定される
- [x] cachedオプションが適用され、パフォーマンスが最適化される

## 注意事項
- Docker Compose v2の最新仕様に準拠する
- bind mountのパフォーマンス最適化（cachedオプション）
- ホストとコンテナ間でのファイル権限問題を避ける
- 環境変数の優先順位を適切に設定する
- ボリューム名の競合を避ける

## コミットメッセージ案
```
feat: create development environment Docker Compose configuration

- Add compose.dev.yaml for development mode
- Configure bind mount with cached option for real-time sync
- Set up claude-code-config volume for CLI settings
- Add development-specific environment variables
- Enable interactive mode with tty and stdin_open
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 3.1
- 推定時間: 45分
- 全体設計書: `_overview-tasks.md`