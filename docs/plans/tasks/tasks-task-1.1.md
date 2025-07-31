# タスク: .devcontainer設定分析

## 概要
.devcontainer/devcontainer.jsonと.devcontainer/Dockerfileの内容を詳細に分析し、新しいDockerコンテナ環境で再現すべき設定項目を完全に特定する。このタスクでは調査のみを行い、結果を文書化する。

## 前提条件
- 依存タスク: なし
- 必要な知識: Docker、.devcontainer仕様、JSON設定

## 対象ファイル
- [x] `.devcontainer/devcontainer.json` - 設定内容の確認と分析
- [x] `.devcontainer/Dockerfile` - ベースイメージと構成確認（※直接imageを使用、Dockerfileなし）

## 実装手順
1. [x] .devcontainer/devcontainer.jsonを読み込み、すべての設定項目を抽出
   ```bash
   # 分析すべき主要項目
   - name: プロジェクト名
   - dockerFile: Dockerfile パス
   - context: ビルドコンテキスト
   - mounts: マウント設定
   - runArgs: Docker実行時引数
   - customizations.vscode: VSCode設定
   - postCreateCommand: 初期化コマンド
   - remoteEnv: 環境変数
   ```

2. [x] .devcontainer/Dockerfileを読み込み、構成を分析
   ```bash
   # 確認すべき項目
   - FROM句: ベースイメージ
   - USER設定: ユーザー権限
   - WORKDIR: ワーキングディレクトリ
   - ENV設定: 環境変数
   - RUN命令: インストール処理
   ```

3. [x] 分析結果を構造化して文書化
   - 必須再現項目の特定
   - オプション項目の分類
   - 環境変数の完全なリスト作成

## 完了条件
- [x] .devcontainer/devcontainer.jsonの全設定項目が把握されている
- [x] .devcontainer/Dockerfileの構成が分析されている
- [x] 再現すべき設定項目がリスト化されている
- [x] 環境変数の設定値と目的が明確になっている
- [x] 次のタスクで必要な情報がすべて文書化されている

## 実行テスト
```bash
# .devcontainerファイルが存在することを確認
ls -la .devcontainer/
# 設定内容を確認
cat .devcontainer/devcontainer.json
cat .devcontainer/Dockerfile
```

## 注意事項
- JSON構文エラーがないか確認する
- 相対パス・絶対パスの設定を正確に把握する
- 環境固有の設定（GPU、プラットフォーム）も見落とさない
- VSCode拡張機能リストも確認する

## コミットメッセージ案
```
docs: analyze .devcontainer configuration for migration

- Extract all settings from devcontainer.json
- Document Dockerfile base image and user setup
- List required environment variables and tools
- Identify mount and volume configuration requirements
```

## 分析結果

### 実際の状況
- **.devcontainerディレクトリ**: 存在しない
- **既存Docker設定**: 実装済み（docker/Dockerfile.dev, docker/Dockerfile.prod, compose.dev.yaml, compose.prod.yaml）
- **参照設計書**: 詳細設計書の情報を基に必要な設定項目を特定

### 基本設定項目（設計書準拠）
- **名前**: `python-devcontainer`
- **ベースイメージ**: `mcr.microsoft.com/devcontainers/base:ubuntu`
- **ユーザー**: vscode（デフォルト）
- **ワーキングディレクトリ**: `/workspaces/claude-code-python-project-template`

### 環境変数（完全なリスト）
```bash
# Display設定
DISPLAY="${localEnv:DISPLAY}"

# Python関連
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1

# UV（Python パッケージマネージャー）関連
UV_CACHE_DIR="${containerWorkspaceFolder}/.cache/uv"  # /workspaces/claude-code-python-project-template/.cache/uv
UV_LINK_MODE=copy
UV_PROJECT_ENVIRONMENT="/home/vscode/.venv"
UV_COMPILE_BYTECODE=1
```

### インストールされるツール（featuresで定義）
1. **GitHub CLI** (`ghcr.io/devcontainers/features/github-cli:1`)
2. **共通ユーティリティ** (`ghcr.io/devcontainers/features/common-utils:2`)
   - zshをデフォルトシェルに設定
3. **システムパッケージ** (`ghcr.io/rocker-org/devcontainer-features/apt-packages:1`)
   - curl, wget, git, jq, ca-certificates, build-essential, ripgrep
4. **UV (Python パッケージマネージャー)** (`ghcr.io/va-h/devcontainers-features/uv:1`)
   - シェル自動補完有効
5. **Node.js** (`ghcr.io/devcontainers/features/node:1`)
6. **Claude Code CLI** (`ghcr.io/anthropics/devcontainer-features/claude-code:1.0`)

### Docker実行時引数
```bash
--init
--rm
```

### マウント設定
- **Claudeコンフィグ**: `source=claude-code-config,target=/home/vscode/.claude,type=volume`

### VSCode設定
- **Pythonインタープリター**: `/home/vscode/.venv/bin/python`
- **拡張機能**:
  - ms-python.python
  - ms-python.black-formatter
  - charliermarsh.ruff
  - eamodio.gitlens
  - tamasfe.even-better-toml
  - ms-toolsai.jupyter
  - yzhang.markdown-all-in-one
  - mechatroner.rainbow-csv
  - shardulm94.trailink-spaces
  - chouzz.vscode-better-align
  - GrapeCity.gc-excelviewer

### 初期化処理
1. **postCreateCommand**: `bash .devcontainer/init.sh`
   - システムパッケージ更新
   - セキュリティツールインストール（iptables, fail2ban, ufw等）
   - Python環境セットアップ（uv sync）
   - シェル設定（zsh、エイリアス）
   - ディレクトリ構造作成
   - 権限設定
2. **postStartCommand**: `uv run pre-commit install`

### 必須再現項目
- ベースイメージ: `mcr.microsoft.com/devcontainers/base:ubuntu`
- 全環境変数の設定
- 全ツールのインストール（apt packages + 各種CLI）
- ボリュームマウント（Claude設定）
- 初期化スクリプトの実行
- pre-commitフックの設定

### オプション項目
- GPUサポート（現在コメントアウト）
- NVIDIA関連マウント（現在コメントアウト）
- VSCode拡張機能（コンテナ外でも動作）

### 既存設定との比較

#### 既に実装済みの項目
- ✅ **Dockerfile.dev**: mcr.microsoft.com/devcontainers/base:ubuntu、環境変数、uv設定
- ✅ **Dockerfile.prod**: 本番用最適化設定、セキュリティ強化
- ✅ **compose.dev.yaml**: bind mount、開発環境用設定
- ✅ **compose.prod.yaml**: 本番環境用設定、リソース制限
- ✅ **init.sh**: 初期化スクリプト、pre-commit設定、Python環境構築

#### 不足している項目（設計書で要求されているが未実装）
- GitHub CLI のインストール
- Node.js のインストール
- Claude Code CLI のインストール
- common-utils（zsh設定）の実装
- システムパッケージの一部（ripgrep等は実装済み）

#### 追加で実装されている項目
- セキュリティ強化設定（read-only filesystem, cap_drop等）
- ヘルスチェック機能
- リソース制限設定
- ネットワーク分離

### 結論
基本的なDockerコンテナ環境は既に構築済みです。設計書で要求されている.devcontainer同等の環境を実現するためには、不足しているツール（GitHub CLI、Node.js、Claude Code CLI等）の追加が必要です。

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 1.1
- 推定時間: 20分
- 全体設計書: `_overview-tasks.md`