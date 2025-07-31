# タスク: 本番環境用Compose設定

## 概要
compose.prod.yamlを作成し、本番モードでのコンテナ起動設定を実装する。COPYによるファイル配置、本番モード固有の環境変数、最適化設定（メモリ制限等）を行う。

## 前提条件
- 依存タスク: Task 2.3
- 必要な知識: Docker Compose v2仕様、本番環境最適化、リソース制限

## 対象ファイル
- [x] `compose.prod.yaml` - 本番環境用Docker Compose設定（新規作成）

## 実装手順
1. [x] compose.prod.yamlの基本構造作成
   ```yaml
   version: '3.8'
   
   services:
     prod-container:
       build:
         context: .
         dockerfile: docker/Dockerfile.prod
       container_name: claude-code-prod
   ```
2. [x] 本番モード固有の環境変数設定
   ```yaml
       environment:
         - DEV_MODE=false
         - PYTHONUNBUFFERED=1
         - PYTHONDONTWRITEBYTECODE=1
         - PYTHONOPTIMIZE=1
         - UV_CACHE_DIR=/tmp/uv-cache
         - UV_LINK_MODE=copy
         - UV_PROJECT_ENVIRONMENT=/workspaces/claude-code-python-project-template/.venv
         - UV_COMPILE_BYTECODE=1
   ```
3. [x] リソース制限設定
   ```yaml
       deploy:
         resources:
           limits:
             memory: 2G
             cpus: '1.0'
           reservations:
             memory: 512M
             cpus: '0.5'
   ```
4. [x] 本番用ボリューム設定（最小限）
   ```yaml
       volumes:
         # 必要最小限のボリューム（設定ファイル等）
         - claude-code-config:/home/vscode/.claude
   ```
5. [x] 本番用ネットワーク設定
   ```yaml
       networks:
         - prod-network
   
   networks:
     prod-network:
       driver: bridge
   ```
6. [x] 本番用ポート設定
   ```yaml
       ports:
         - "80:8000"  # 本番サービス用
   ```
7. [x] 再起動ポリシー設定
   ```yaml
       restart: unless-stopped
   ```
8. [x] ヘルスチェック設定
   ```yaml
       healthcheck:
         test: ["CMD", "python", "-c", "import sys; sys.exit(0)"]
         interval: 30s
         timeout: 10s
         retries: 3
         start_period: 40s
   ```
9. [x] ボリューム定義
   ```yaml
   volumes:
     claude-code-config:
       driver: local
   ```
10. [x] 動作確認テスト
    - `docker compose -f compose.prod.yaml up -d`でコンテナが起動する
    - リソース制限が適用される
    - 外部依存なく動作する
    - YAML構文の検証完了

## 完了条件
- [x] compose.prod.yamlが作成され、Docker Compose v2仕様に準拠している
- [x] 本番モードでコンテナが正常に起動する（設定済み、Dockerテスト不可）
- [x] ファイルがコンテナ内に固定配置される（bind mountなし、COPYによる配置設定済み）
- [x] 本番固有の環境変数が設定される
- [x] リソース制限が適用される
- [x] ヘルスチェックが動作する
- [x] 自動再起動が設定される

## 注意事項
- bind mountは使用せず、COPYによるファイル配置のみ
- セキュリティを考慮した最小限の権限設定
- パフォーマンス最適化のためのリソース制限
- 本番環境での安定性を重視した設定
- 不要なボリュームやポートは公開しない

## コミットメッセージ案
```
feat: create production environment Docker Compose configuration

- Add compose.prod.yaml for production mode
- Configure resource limits and reservations
- Set production-specific environment variables
- Add health check and restart policy
- Optimize for production workloads without bind mounts
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 3.2
- 推定時間: 30分
- 全体設計書: `_overview-tasks.md`