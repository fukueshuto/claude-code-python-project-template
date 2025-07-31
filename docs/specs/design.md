# 詳細設計書 - .devcontainerと同等のDockerコンテナ環境構築

## 1. アーキテクチャ概要
### 1.1 システム構成図
```
┌─────────────────────────────────────────────────────────────┐
│                        Host System                          │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │   Dev Mode      │  │   Prod Mode     │                  │
│  │   (Bind Mount)  │  │   (Copy Files)  │                  │
│  └─────────────────┘  └─────────────────┘                  │
│           │                     │                           │
│           ▼                     ▼                           │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Docker Container                           │ │
│  │  ┌─────────────────────────────────────────────────────┐│ │
│  │  │            Base Image                               ││ │
│  │  │     mcr.microsoft.com/devcontainers/base:ubuntu     ││ │
│  │  └─────────────────────────────────────────────────────┘│ │
│  │  ┌─────────────────────────────────────────────────────┐│ │
│  │  │            Tool Layer                               ││ │
│  │  │  • GitHub CLI  • uv  • Node.js  • Claude Code CLI  ││ │
│  │  │  • Python tools  • Git  • Build tools              ││ │
│  │  └─────────────────────────────────────────────────────┘│ │
│  │  ┌─────────────────────────────────────────────────────┐│ │
│  │  │          Application Layer                          ││ │
│  │  │        /workspaces/project                          ││ │
│  │  └─────────────────────────────────────────────────────┘│ │
│  └─────────────────────────────────────────────────────────┘ │
│           │                                                 │
│           ▼                                                 │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Volumes                                    │ │
│  │  • claude-code-config                                   │ │
│  │  • Project files (dev mode)                            │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 技術スタック
- **ベースイメージ**: mcr.microsoft.com/devcontainers/base:ubuntu
- **コンテナオーケストレーション**: Docker Compose v2（compose.yaml形式）
- **ファイルシステム**: bind mount (開発) / COPY (本番)
- **初期化**: shell script (init.sh)
- **パッケージマネージャー**: 
  - Python: uv
  - Node.js: npm/yarn
  - System: apt

## 2. コンポーネント設計
### 2.1 コンポーネント一覧
| コンポーネント名 | 責務 | 依存関係 |
|-----------------|------|----------|
| Base Container | ベースイメージの提供、共通設定 | mcr.microsoft.com/devcontainers/base:ubuntu |
| Environment Manager | 環境変数の管理と設定 | Base Container |
| Tool Installer | 開発ツールのインストール | Base Container, Environment Manager |
| Mount Manager | ファイルマウント戦略の実装 | Base Container |
| Init Script | 初期化処理の実行 | すべてのコンポーネント |
| Compose Orchestrator | 複数環境の管理 | すべてのコンポーネント |

### 2.2 各コンポーネントの詳細
#### Base Container
- **目的**: .devcontainerと同じベースイメージを使用した統一された実行環境の提供
- **設定項目**:
```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu
USER vscode
WORKDIR /workspaces/claude-code-python-project-template
```
- **内部実装方針**: 既存のDockerfileを拡張し、.devcontainerの設定を再現する

#### Environment Manager
- **目的**: .devcontainerで定義された環境変数の適切な設定
- **環境変数一覧**:
```bash
# Display関連
DISPLAY=""

# Python関連
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1

# UV関連
UV_CACHE_DIR=/tmp/uv-cache
UV_LINK_MODE=copy
UV_PROJECT_ENVIRONMENT=/workspaces/claude-code-python-project-template/.venv
UV_COMPILE_BYTECODE=1
```
- **内部実装方針**: docker-compose.ymlとDockerfileで環境変数を管理

#### Tool Installer
- **目的**: 開発に必要なツールの自動インストール
- **インストール対象**:
  - GitHub CLI
  - common-utils (zsh設定含む)
  - system packages: curl, wget, git, jq, ca-certificates, build-essential, ripgrep
  - uv (Python package manager)
  - Node.js
  - Claude Code CLI
- **内部実装方針**: Dockerfileの複数ステージビルドでキャッシュを活用

#### Mount Manager
- **目的**: 開発モードと本番モードでの適切なファイル配置戦略
- **開発モード**: 
```yaml
volumes:
  - .:/workspaces/claude-code-python-project-template:cached
  - claude-code-config:/home/vscode/.claude
```
- **本番モード**:
```dockerfile
COPY . /workspaces/claude-code-python-project-template/
```

#### Init Script
- **目的**: コンテナ起動時の初期化処理
- **処理内容**:
  - pre-commit hooksのインストール
  - Python仮想環境の設定
  - 必要な設定ファイルの生成
- **実装方針**: 冪等性を保った初期化スクリプト

## 3. データフロー
### 3.1 データフロー図
```
Host Files → Mount Strategy → Container Files → Init Script → Development Environment
    ↓              ↓              ↓               ↓                     ↓
[Project]    [Bind/Copy]    [/workspaces]    [Setup Tools]        [Ready to Use]
```

### 3.2 データ変換
- **入力データ形式**: ホストファイルシステム上のプロジェクトファイル
- **処理過程**: 
  1. モード判定（DEV_MODE環境変数）
  2. 適切なマウント戦略の選択
  3. 環境変数の設定
  4. 初期化スクリプトの実行
- **出力データ形式**: 完全に構成された開発環境

## 4. APIインターフェース
### 4.1 内部API
```bash
# 開発モード起動
docker compose -f compose.dev.yaml up -d

# 本番モード起動
docker compose -f compose.prod.yaml up -d

# 直接起動（開発モード）
docker run --rm -it \
  -v $(pwd):/workspaces/claude-code-python-project-template:cached \
  -v claude-code-config:/home/vscode/.claude \
  -e DEV_MODE=true \
  project-name:latest
```

### 4.2 外部API
```bash
# GPU対応の場合
docker run --gpus all [other-options] project-name:latest

# カスタムrunArgs対応
docker run --init --rm [other-options] project-name:latest
```

## 5. エラーハンドリング
### 5.1 エラー分類
- **環境変数設定エラー**: デフォルト値の設定とログ出力
- **マウントエラー**: パス存在確認とエラーメッセージ表示
- **ツールインストールエラー**: 必須/オプショナル分類とフォールバック処理
- **初期化エラー**: 段階的実行と中断ポイントの明示

### 5.2 エラー通知
- コンテナログへの構造化ログ出力
- 初期化スクリプトでのexit codeによる状態通知
- ヘルスチェック機能による状態監視

## 6. セキュリティ設計
### 6.1 認証・認可
- vscodeユーザーでの実行（非root）
- sudo権限の適切な制限
- ファイルパーミッションの継承

### 6.2 データ保護
- 機密ファイルの.dockerignore除外
- 環境変数による秘密情報の外部化
- ボリュームマウント時の適切な権限設定

## 7. テスト戦略
### 7.1 単体テスト
- **カバレッジ目標**: 80%以上
- **テスト対象**: 初期化スクリプト、環境設定
- **テストフレームワーク**: pytest + Docker test containers

### 7.2 統合テスト
- 各モード（dev/prod）での起動テスト
- ツール動作確認テスト
- ファイル同期テスト
- VSCode統合テスト

## 8. パフォーマンス最適化
### 8.1 想定される負荷
- コンテナ起動時間: < 30秒
- ファイル同期レイテンシ: < 100ms
- メモリ使用量: < 2GB (開発環境)

### 8.2 最適化方針
- マルチステージビルドによるレイヤー最適化
- .dockerignoreによる不要ファイル除外
- bind mountのcachedオプション使用
- ツールインストールの並列化

## 9. デプロイメント
### 9.1 デプロイ構成
```bash
# 構成ファイル
├── docker/
│   ├── Dockerfile.dev      # 開発用
│   ├── Dockerfile.prod     # 本番用
│   └── init.sh             # 初期化スクリプト
├── compose.dev.yaml        # 開発環境用（Docker Compose v2最新仕様）
├── compose.prod.yaml       # 本番環境用（Docker Compose v2最新仕様）
└── .dockerignore
```

### 9.2 設定管理
- 環境変数による設定切り替え
- .envファイルによるローカル設定
- Docker Compose override機能の活用（compose.override.yaml）
- Docker Compose v2の最新機能を活用した設定管理

## 10. 実装上の注意事項
- 既存のDockerfile/compose.ymlとの競合を避けるため、Docker Compose v2最新仕様のcompose.yaml形式でファイル名を明確に分離する
- .devcontainerとの設定同期を保つため、共通の設定ファイルを参照する仕組みを検討する
- uvの仮想環境パスを絶対パスで指定し、マウント戦略に依存しないようにする
- init.shスクリプトは冪等性を保ち、複数回実行可能にする
- GPU対応は環境変数による有効/無効切り替えを実装する
- Windows/macOS/Linuxでの動作差異を最小限に抑える設定にする
- ファイルパーミッション問題を避けるため、UID/GIDマッピングを適切に設定する