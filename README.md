# Claude Code Python Project Template

.devcontainerと同等のDockerコンテナ環境を、docker runまたはdocker composeコマンドで直接利用できるPythonプロジェクトテンプレートです。

## 🚀 クイックスタート

### 開発モード（.devcontainer相当）
```bash
# 開発環境の起動
docker compose -f compose.dev.yaml up -d

# コンテナに接続
docker compose -f compose.dev.yaml exec dev zsh
```

### 本番モード
```bash
# 本番環境の起動
docker compose -f compose.prod.yaml up -d

# アプリケーション実行
docker compose -f compose.prod.yaml exec app python main.py
```

### 直接実行
```bash
# 開発モード
docker run --rm -it \
  -v $(pwd):/workspaces/claude-code-python-project-template:cached \
  -v claude-code-config:/home/vscode/.claude \
  claude-code-python-dev

# 本番モード
docker run --rm -it claude-code-python-prod
```

## 🏗️ プロジェクト構成

### Docker関連ファイル
```
docker/
├── Dockerfile.dev      # 開発用Dockerfile
├── Dockerfile.prod     # 本番用Dockerfile  
└── init.sh             # 初期化スクリプト

compose.dev.yaml        # 開発環境Docker Compose設定
compose.prod.yaml       # 本番環境Docker Compose設定
.dockerignore           # ビルド最適化設定
```

### 仕様書・設計書
```
docs/specs/
├── requirements.md         # 要件定義書
├── design.md              # 詳細設計書
├── final-file-structure.md # ファイル構成設計書
└── dockerignore-design.md  # .dockerignore設計書
```

## ✨ 主な機能

### 🔧 開発ツール完備
- **GitHub CLI (gh)** - バージョン管理・PR作成
- **Node.js + npm** - モダンなJavaScript開発環境
- **Claude Code CLI** - AI支援コード生成・分析
- **uv** - 高速Python パッケージマネージャー
- **システムツール** - curl, wget, git, jq, ca-certificates, build-essential, ripgrep

### 🐍 Python開発環境
- Python 3.x + uv による高速パッケージ管理
- 自動仮想環境構築
- pre-commit hooks自動セットアップ
- ruff, mypy等の品質チェックツール対応

### 🛡️ セキュリティ・最適化
- 非rootユーザー（vscode）での実行
- リソース制限とセキュリティオプション設定
- .dockerignoreによるビルド最適化
- マルチステージビルドによるイメージサイズ削減

### 🔄 開発・本番モード切り替え
- **開発モード**: bind mountによるリアルタイムファイル同期
- **本番モード**: COPYによる独立したファイル配置
- 環境変数による動作モード制御

## 📋 環境変数

### 共通設定
```bash
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
UV_CACHE_DIR=/workspaces/claude-code-python-project-template/.cache/uv
UV_LINK_MODE=copy
UV_PROJECT_ENVIRONMENT=/home/vscode/.venv
UV_COMPILE_BYTECODE=1
```

### 開発モード固有
```bash
DEV_MODE=true
DISPLAY=${DISPLAY:-}
```

## 🎯 .devcontainerとの互換性

このプロジェクトは**.devcontainer設定と完全に互換性**があります：

- 同じベースイメージ（mcr.microsoft.com/devcontainers/base:ubuntu）
- 同じ環境変数設定
- 同じ開発ツールチェーン
- 同じユーザー権限（vscode）
- 同じワーキングディレクトリ

.devcontainerを使用しない開発者でも、同じ開発体験を得られます。

## 🚦 システム要件

- Docker 20.10+
- Docker Compose v2
- 2GB以上のメモリ（開発環境）
- 1GB以上のディスク容量

### オプション要件
- NVIDIA Docker（GPU対応時）
- X11 forwarding（GUI アプリケーション使用時）

## 📚 詳細ドキュメント

- [要件定義書](docs/specs/requirements.md) - プロジェクトの目的と要件
- [詳細設計書](docs/specs/design.md) - アーキテクチャと技術仕様
- [ファイル構成設計書](docs/specs/final-file-structure.md) - ファイル構成の詳細

## 🛠️ 開発者向け情報

### 初期化プロセス
コンテナ起動時に`docker/init.sh`が実行され、以下の処理を自動実行：

1. 必須ツールの動作確認
2. Python仮想環境の構築
3. pre-commit hooksのインストール
4. 設定ファイルの生成
5. 認証状態の確認

### カスタマイズ
- 環境変数で動作をカスタマイズ可能
- .env.localでローカル固有設定を追加
- Docker Compose overrideファイルでの設定拡張対応

### トラブルシューティング
```bash
# ヘルスチェック実行
/tmp/health-check.sh

# 初期化状態確認
ls -la /workspaces/claude-code-python-project-template/.init_complete

# ログ確認
docker compose -f compose.dev.yaml logs dev
```

## 📝 ライセンス

このプロジェクトテンプレートは自由に利用・改変してください。

## 🤝 コントリビューション

プロジェクトの改善提案やバグ報告を歓迎します。Issue作成やPull Requestをお気軽にどうぞ。

---

**Generated with Claude Code** 🤖