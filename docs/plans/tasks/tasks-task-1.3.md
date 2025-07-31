# タスク: ファイル構成計画

## 概要
Task 1.1と1.2の分析結果を基に、Docker Compose v2最新仕様に基づいた最終的なファイル構成を決定する。既存ファイルとの競合を回避し、.dockerignoreファイルの設計も含めて実装準備を完了する。

## 前提条件
- 依存タスク: Task 1.1, Task 1.2
- 必要な知識: Docker Compose v2仕様、ファイル命名規則

## 対象ファイル
- このタスクでは実際のファイル作成は行わず、構成の確定のみを行う

## 実装手順
1. [x] Docker Compose v2最新仕様の確認
   - compose.yamlファイル形式の仕様確認
   - 推奨されるファイル命名規則の適用
   - 既存compose.ymlとの明確な分離方法

2. [x] 最終ファイル構成の設計
   ```
   docker/
   ├── Dockerfile.dev      # 開発用Dockerfile
   ├── Dockerfile.prod     # 本番用Dockerfile
   └── init.sh             # 初期化スクリプト
   compose.dev.yaml        # 開発環境用Compose設定
   compose.prod.yaml       # 本番環境用Compose設定
   .dockerignore           # ビルド最適化
   ```

3. [x] 競合回避戦略の確定
   - サービス名: `devcontainer-dev`, `devcontainer-prod`
   - ボリューム名: `claude-code-config`, `project-cache`
   - ネットワーク名: デフォルトを使用

4. [x] .dockerignoreファイル設計
   - 除外すべきファイル・ディレクトリの特定
   - .git, node_modules, __pycache__, .vscode等
   - 機密ファイルの除外設定
   - ビルド効率最適化のための設定

5. [x] パス設計の確定
   - 絶対パスと相対パスの使い分け決定
   - マウントポイントの統一
   - 環境間での一貫性確保

## 完了条件
- [x] 作成すべきファイル一覧とパスが確定している
- [x] Docker Compose v2最新仕様に準拠している
- [x] 既存ファイルとの競合が完全に回避されている
- [x] .dockerignoreの詳細設計が完了している
- [x] 各ファイルの役割と依存関係が明確である
- [x] 次フェーズの実装に必要な仕様がすべて決定している

## 実行テスト
```bash
# 設計したファイル構成が実現可能であることを確認
# （実際のファイル作成は行わない）
echo "Planned file structure:"
echo "docker/Dockerfile.dev"
echo "docker/Dockerfile.prod" 
echo "docker/init.sh"
echo "compose.dev.yaml"
echo "compose.prod.yaml"
echo ".dockerignore"
```

## 注意事項
- Docker Compose v2では`compose.yaml`形式が推奨される
- 既存の`compose.yml`との競合を完全に避ける
- Windows、macOS、Linuxでの互換性を考慮
- セキュリティを考慮した.dockerignore設計
- 将来の拡張性も考慮したファイル構成

## コミットメッセージ案
```
docs: finalize Docker file structure design

- Define compose.dev.yaml and compose.prod.yaml structure
- Design .dockerignore for build optimization
- Ensure compatibility with existing Docker setup  
- Follow Docker Compose v2 latest specifications
```

## 最終設計仕様

### Docker Compose v2準拠の設計決定

#### 1. ファイル命名規則
Docker Compose v2では`.yaml`拡張子が推奨されるため：
- `compose.dev.yaml` - 開発環境用設定（.devcontainer相当）
- `compose.prod.yaml` - 本番環境用設定（既存compose.yml相当）

#### 2. 作成予定ファイル一覧とパス
```
プロジェクトルート/
├── docker/
│   ├── Dockerfile.dev       # 開発用Dockerfile（.devcontainer相当）
│   ├── Dockerfile.prod      # 本番用Dockerfile（既存Dockerfile相当）
│   └── init.sh              # 開発環境初期化スクリプト
├── compose.dev.yaml         # 開発環境Compose設定
├── compose.prod.yaml        # 本番環境Compose設定
└── .dockerignore            # ビルド最適化用除外設定
```

#### 3. 既存ファイルとの競合回避戦略

##### ファイル名の分離
- 既存: `compose.yml`, `docker/Dockerfile` → **変更なし**（保持）
- 新規: `compose.dev.yaml`, `compose.prod.yaml`, `docker/Dockerfile.dev`, `docker/Dockerfile.prod`

##### サービス名の分離
```yaml
# compose.dev.yaml
services:
  devcontainer:              # 開発環境サービス

# compose.prod.yaml  
services:
  app-prod:                  # 本番環境サービス（既存`app`と区別）
```

##### ボリューム名の分離
```yaml
volumes:
  claude-code-config:        # Claude設定用（開発環境固有）
  uv-cache-dev:             # 開発用UVキャッシュ
  uv-cache-prod:            # 本番用UVキャッシュ
  project-workspace:        # 開発環境ワークスペース
```

#### 4. .dockerignoreファイルの詳細設計

##### 基本除外設定
```dockerignore
# Version control
.git
.gitignore

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
.env
.venv/
env/
venv/
ENV/
env.bak/
venv.bak/
.cache/

# Testing
.tox/
.coverage
.pytest_cache/
htmlcov/

# Documentation
docs/_build/
.readthedocs.yml

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Node.js (if present)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Docker
.dockerignore
Dockerfile*
docker-compose*.yml
compose*.yaml

# Temporary files
.tmp/
tmp/
*.tmp
*.log

# Security sensitive
.env.local
.env.*.local
*.key
*.pem
secrets/
```

#### 5. パス設計の確定

##### 開発環境パス設計（.devcontainer準拠）
```yaml
# compose.dev.yaml設定
working_dir: /workspaces/claude-code-python-project-template
volumes:
  - .:/workspaces/claude-code-python-project-template
  - claude-code-config:/home/vscode/.claude
  - uv-cache-dev:/home/vscode/.cache/uv
environment:
  - UV_CACHE_DIR=/home/vscode/.cache/uv
  - UV_PROJECT_ENVIRONMENT=/home/vscode/.venv
```

##### 本番環境パス設計（既存構成維持）
```yaml
# compose.prod.yaml設定
working_dir: /app
volumes:
  - .:/app
  - uv-cache-prod:/opt/venv
environment:
  - UV_PYTHON_INSTALL_DIR=/opt/python
  - UV_PROJECT_ENVIRONMENT=/opt/venv
```

#### 6. 各ファイルの役割と依存関係

##### 依存関係マップ
```
compose.dev.yaml
├── depends on: docker/Dockerfile.dev
├── depends on: docker/init.sh
└── depends on: .dockerignore

compose.prod.yaml
├── depends on: docker/Dockerfile.prod
└── depends on: .dockerignore

docker/init.sh
└── used by: docker/Dockerfile.dev (COPY)
```

##### ファイル別責務
- **docker/Dockerfile.dev**: .devcontainer相当の開発環境構築
- **docker/Dockerfile.prod**: 本番環境用最適化イメージ構築
- **docker/init.sh**: 開発環境初期化処理（postCreateCommand相当）
- **compose.dev.yaml**: 開発環境オーケストレーション
- **compose.prod.yaml**: 本番環境オーケストレーション
- **.dockerignore**: 全環境共通のビルド最適化

#### 7. 環境変数統一戦略

##### 共通環境変数
```bash
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
```

##### 開発環境固有（.devcontainer準拠）
```bash
DISPLAY=${localEnv:DISPLAY}
UV_CACHE_DIR=/home/vscode/.cache/uv
UV_PROJECT_ENVIRONMENT=/home/vscode/.venv
UV_LINK_MODE=copy
UV_COMPILE_BYTECODE=1
```

##### 本番環境固有（既存構成維持）
```bash
UV_PYTHON_INSTALL_DIR=/opt/python
UV_PROJECT_ENVIRONMENT=/opt/venv
PATH=/opt/venv/bin:$PATH
```

#### 8. 将来の拡張性考慮

##### 追加予定の設定項目
- GPU支援設定（開発環境）
- セキュリティスキャン設定
- マルチアーキテクチャ対応
- CI/CD統合用設定

##### 拡張可能性
- `compose.test.yaml` - テスト環境用設定
- `compose.staging.yaml` - ステージング環境用設定
- `docker/Dockerfile.test` - テスト専用イメージ

### 次フェーズ実装における注意事項
1. 既存ファイル（compose.yml, docker/Dockerfile）は**絶対に変更しない**
2. 新規ファイル作成時は必ず.dockerignoreを最初に作成
3. Docker Compose v2の`yaml`拡張子を厳守
4. 環境変数設定は.devcontainer/devcontainer.jsonを基準とする
5. ボリューム設定は既存システムと完全分離を維持

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 1.3
- 推定時間: 10分
- 全体設計書: `_overview-tasks.md`