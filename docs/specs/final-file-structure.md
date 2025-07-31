# 最終ファイル構成設計書

## 概要
Task 1.2で確定された、.devcontainerと同等のDockerコンテナ環境構築のための最終ファイル構成です。品質チェックで判明した必須ツール（GitHub CLI、Node.js、Claude Code CLI）の要件も含まれています。

## 最終ファイル構成

```
プロジェクトルート/
├── docker/
│   ├── Dockerfile.dev      # 開発用Dockerfile（必須ツール全て含む）
│   ├── Dockerfile.prod     # 本番用Dockerfile（最小限構成）
│   └── init.sh             # 初期化スクリプト（ツール動作確認含む）
│
├── compose.dev.yaml        # 開発環境Docker Compose設定（v2最新仕様）
├── compose.prod.yaml       # 本番環境Docker Compose設定（v2最新仕様）
├── .dockerignore           # 最適化されたビルドコンテキスト
│
└── docs/
    └── specs/
        ├── dockerignore-design.md  # .dockerignore設計書
        └── final-file-structure.md # この文書
```

## ファイル詳細仕様

### 1. docker/Dockerfile.dev
- **目的**: 開発環境用コンテナイメージ
- **ベースイメージ**: `mcr.microsoft.com/devcontainers/base:ubuntu`
- **必須ツール**:
  - GitHub CLI (gh) - バージョン管理・PR作成
  - Node.js 20.x LTS - Claude Code CLI依存
  - Claude Code CLI - コード生成・分析
  - uv - Python環境管理
  - システムパッケージ: curl, wget, git, jq, ca-certificates, build-essential, ripgrep
- **ユーザー**: vscode
- **作業ディレクトリ**: `/workspaces/claude-code-python-project-template`

### 2. docker/Dockerfile.prod  
- **目的**: 本番環境用コンテナイメージ
- **ベースイメージ**: `mcr.microsoft.com/devcontainers/base:ubuntu`
- **最小限ツール**: Python、uv、必要なシステムパッケージのみ
- **最適化**: マルチステージビルド、レイヤーキャッシュ活用

### 3. docker/init.sh
- **目的**: コンテナ起動時の初期化処理
- **機能**:
  - pre-commit hooksの自動インストール
  - Python仮想環境の設定確認
  - 必須ツールの動作確認
  - 設定ファイルの生成・検証
- **冪等性**: 複数回実行可能
- **エラーハンドリング**: 各ステップでの詳細ログ出力

### 4. compose.dev.yaml
- **目的**: 開発環境用Docker Compose設定
- **Docker Compose仕様**: v2最新形式
- **マウント戦略**: bind mount（リアルタイム同期）
- **ボリューム**: 
  - プロジェクトルート: `.:workspaces/claude-code-python-project-template:cached`
  - Claude設定: `claude-code-config:/home/vscode/.claude`
- **環境変数**: 開発モード最適化
- **サービス名**: `devcontainer`（既存との競合回避）

### 5. compose.prod.yaml
- **目的**: 本番環境用Docker Compose設定
- **Docker Compose仕様**: v2最新形式  
- **ファイル配置**: COPY命令（コンテナ内固定）
- **最適化**: メモリ制限、リソース制約
- **サービス名**: `app-prod`（既存との競合回避）

### 6. .dockerignore
- **目的**: ビルドコンテキスト最適化
- **除外対象**:
  - バージョン管理システム (.git等)
  - IDE設定 (.vscode等)
  - Python一時ファイル (__pycache__等)
  - Node.js関連 (node_modules等)
  - 開発環境固有ファイル (.env等)
  - ドキュメント・README
- **セキュリティ**: 機密ファイルの確実な除外

## 既存ファイルとの競合回避戦略

### 1. ファイル名分離
- 新規: `compose.dev.yaml`, `compose.prod.yaml`
- 既存: `compose.yml`（保持）
- 明確な用途分離で競合回避

### 2. サービス名分離  
- 新規サービス名: `devcontainer`, `app-prod`
- 既存サービス名: `app`（保持）
- 独立した名前空間で運用

### 3. ボリューム名分離
- 新規: `claude-code-config`, `uv-cache-dev`, `uv-cache-prod`
- 既存の匿名ボリュームと分離

## 品質チェック対応

### 必須ツールの追加根拠
1. **GitHub CLI (gh)**: バージョン管理、PR作成、Issues管理に必須
2. **Node.js**: Claude Code CLIの実行環境として必要
3. **Claude Code CLI**: AI支援開発の核となるツール

### インストール戦略
- バージョン固定による再現性確保
- エラーハンドリングと代替手段の提供
- 必須/オプショナルツールの明確な分離
- インストール順序の最適化（依存関係考慮）

## 次のステップ
Task 1.2完了により、以下が確定されました：
1. 作成すべき全ファイルのパスと仕様
2. 既存システムとの競合回避方法
3. 品質チェック対応の必須ツール要件
4. Docker Compose v2最新仕様への準拠

これにより、Phase 2（基盤実装）のタスク実行が可能になりました。