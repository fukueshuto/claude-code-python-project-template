# タスク: 既存Docker構成確認

## 概要
現在のdocker/Dockerfileとcompose.ymlの内容を確認し、新しい設定との競合可能性を特定する。既存構成を理解して適切な共存戦略を策定する。

## 前提条件
- 依存タスク: Task 1.1
- 必要な知識: Docker、Docker Compose、ファイル競合回避

## 対象ファイル
- [x] `docker/Dockerfile` - 既存Dockerfile構成の確認
- [x] `compose.yml` - 既存Compose設定の確認

## 実装手順
1. [x] 既存docker/Dockerfileの分析
   ```bash
   # 確認すべき項目
   - ベースイメージの種類
   - ユーザー設定の有無
   - インストール済みツール
   - 環境変数設定
   - ポート設定
   - ボリューム設定
   ```

2. [x] 既存compose.ymlの分析
   ```bash
   # 確認すべき項目
   - サービス名の一覧
   - 使用中のボリューム名
   - ネットワーク設定
   - 環境変数設定
   - ポートマッピング
   ```

3. [x] 競合可能性の特定
   - サービス名の重複チェック
   - ボリューム名の重複チェック
   - ポートの競合チェック
   - ファイル名の競合チェック

4. [x] 共存戦略の策定
   - 新ファイル名の決定（compose.dev.yaml, compose.prod.yaml）
   - 新しいサービス名の決定
   - 新しいボリューム名の決定

## 完了条件
- [x] 既存docker/Dockerfileの構成が把握されている
- [x] 既存compose.ymlの設定が把握されている
- [x] 潜在的な競合箇所が特定されている
- [x] 競合回避の具体的な方法が決定されている
- [x] 新ファイルの命名規則が確定している

## 実行テスト
```bash
# 既存ファイルの存在確認
ls -la docker/
ls -la compose.*
# 内容確認
cat docker/Dockerfile 2>/dev/null || echo "docker/Dockerfile not found"
cat compose.yml 2>/dev/null || echo "compose.yml not found"
```

## 注意事項
- 既存システムの動作を壊さないよう注意深く分析する
- Docker Compose v1とv2の仕様差異を考慮する
- ファイル名の大文字・小文字も含めて確認する
- 隠しファイル（.docker*）も確認する

## コミットメッセージ案
```
docs: analyze existing Docker configuration for conflict avoidance

- Review current docker/Dockerfile setup
- Check existing compose.yml configuration
- Identify potential naming conflicts
- Plan coexistence strategy for new files
```

## 分析結果

### 既存docker/Dockerfileの構成分析

#### 基本構成
- **ベースイメージ**: `ubuntu:24.04`（builder/production両方）
- **マルチステージビルド**: builder → production
- **ユーザー設定**: entrypoint.shでdynamic user作成（デフォルト: user:group）
- **ワーキングディレクトリ**: `/app`

#### 環境変数
```bash
# Builder段階
UV_PYTHON_INSTALL_DIR="/opt/python"
UV_PROJECT_ENVIRONMENT="/opt/venv"
UV_COMPILE_BYTECODE=1
UV_LINK_MODE=copy

# Production段階
PATH="/opt/venv/bin:$PATH"
UV_PYTHON_INSTALL_DIR="/opt/python"
UV_PROJECT_ENVIRONMENT="/opt/venv"
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
```

#### インストールツール
- git, curl, ca-certificates, build-essential, sudo, gosu
- UV（Python パッケージマネージャー）

#### 重要な特徴
- entrypoint.shでdynamic user作成（UID/GID指定可能）
- sudoパスワードなし設定
- Pythonとvenvの最適化（/opt以下に配置）

### 既存compose.ymlの構成分析

#### サービス設定
- **サービス名**: `app`
- **ビルドコンテキスト**: `.`（プロジェクトルート）
- **Dockerfile**: `docker/Dockerfile`
- **ワーキングディレクトリ**: `/app`
- **再起動設定**: `unless-stopped`

#### ボリューム設定
- **プロジェクトマウント**: `.:/app`（bind mount）
- **匿名ボリューム**: `/app/.venv`（ホストの.venvを隠蔽）

#### 実行設定
- **コマンド**: `python main.py`
- **ポート**: 設定なし

### 競合可能性の特定

#### 1. ファイル名競合
- **高リスク**: `compose.yml` - 既存ファイルと完全重複
- **中リスク**: `docker/Dockerfile` - 既存ファイルと完全重複

#### 2. サービス名競合
- **既存サービス名**: `app`
- **競合リスク**: 中（一般的な名前のため）

#### 3. ボリューム名競合
- **既存**: 匿名ボリューム `/app/.venv`
- **競合リスク**: 低（匿名ボリュームのため）

#### 4. ポート競合
- **既存**: ポート設定なし
- **競合リスク**: なし

#### 5. 環境変数競合
- **UV関連変数**: 設定値が異なる（.devcontainerとの差異）
- **Python関連**: 同一設定

### 共存戦略の策定

#### 1. ファイル命名戦略
```
# 新規作成ファイル
compose.dev.yaml     # 開発環境用（.devcontainer相当）
compose.prod.yaml    # 本番環境用（既存compose.yml相当）
docker/Dockerfile.dev   # 開発用Dockerfile
docker/Dockerfile.prod  # 本番用Dockerfile

# 既存ファイル保持
compose.yml         # 既存設定維持
docker/Dockerfile   # 既存設定維持
```

#### 2. サービス命名戦略
```yaml
# compose.dev.yaml
services:
  devcontainer:     # .devcontainer相当サービス

# compose.prod.yaml  
services:
  app-prod:         # 本番用サービス（既存と区別）
```

#### 3. ボリューム命名戦略
```yaml
volumes:
  claude-code-config:    # .devcontainer用Claude設定
  uv-cache-dev:         # 開発用UVキャッシュ
  uv-cache-prod:        # 本番用UVキャッシュ（既存との分離）
```

#### 4. 環境変数統一戦略
.devcontainerの設定を基準として：
```bash
# 共通環境変数
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1

# 開発環境固有（.devcontainer準拠）
UV_CACHE_DIR="/workspaces/claude-code-python-project-template/.cache/uv"
UV_PROJECT_ENVIRONMENT="/home/vscode/.venv"
UV_LINK_MODE=copy
UV_COMPILE_BYTECODE=1

# 本番環境（既存構成維持）
UV_PYTHON_INSTALL_DIR="/opt/python"
UV_PROJECT_ENVIRONMENT="/opt/venv"
```

### 競合回避の具体的な方法

1. **既存ファイルを一切変更しない**
   - `compose.yml`と`docker/Dockerfile`は現状維持
   - 新規ファイルのみ作成

2. **明確な命名規則**
   - `.dev`/`.prod`サフィックスで用途明確化
   - サービス名にも用途を含める

3. **独立したボリューム空間**
   - 開発用と本番用でボリューム名分離
   - 相互に影響しない設計

4. **段階的導入可能**
   - 既存システム稼働維持
   - 新システムの並行テスト可能

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 1.2
- 推定時間: 15分
- 全体設計書: `_overview-tasks.md`