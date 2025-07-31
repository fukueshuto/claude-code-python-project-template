# 全体設計書 - .devcontainerと同等のDockerコンテナ環境構築

## プロジェクト概要
.devcontainer設定で定義された開発環境と同じ状態のDockerコンテナを、docker runまたはdocker composeコマンドで直接立ち上げられるようにするプロジェクトです。

## 目的と価値
- .devcontainerを使用しない開発者に同じ開発体験を提供
- 開発モード（bind mount）と本番モード（COPY）の両方に対応
- 既存の設定を活用しつつ、Docker Compose v2最新仕様に準拠

## アーキテクチャ概要
```
┌─────────────────────────────────────────────────────┐
│                Host System                          │
│  ┌─────────────────┐  ┌─────────────────┐          │
│  │   Dev Mode      │  │   Prod Mode     │          │
│  │   (Bind Mount)  │  │   (Copy Files)  │          │
│  └─────────────────┘  └─────────────────┘          │
│           │                     │                   │
│           ▼                     ▼                   │
│  ┌─────────────────────────────────────────────────┐ │
│  │              Docker Container                   │ │
│  │  • Base: mcr.microsoft.com/devcontainers/base   │ │
│  │  • Tools: GitHub CLI, uv, Node.js, Claude CLI  │ │
│  │  • Mount: /workspaces/project                   │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## 改善されたタスク構成（1コミット粒度）

### Phase 1: 準備・調査（45分）
- **Task 1.1**: .devcontainer設定分析（20分）
- **Task 1.2**: 既存Docker構成確認（15分）
- **Task 1.3**: ファイル構成計画（10分）

### Phase 2: 基盤Dockerfile（120分）
- **Task 2.1**: 開発用Dockerfileベース作成（30分）
- **Task 2.2**: 本番用Dockerfileベース作成（30分）
- **Task 2.3**: システムパッケージインストール（30分）
- **Task 2.4**: Python環境（uv）セットアップ（30分）

### Phase 3: 開発ツール（90分）
- **Task 3.1**: GitHub CLI インストール（20分）
- **Task 3.2**: Node.js インストール（20分）
- **Task 3.3**: Claude Code CLI インストール（25分）
- **Task 3.4**: 開発支援ツール（zsh, ripgrep等）（25分）

注意: 品質チェックで判明した必須ツールを含む構成に更新

### Phase 4: 環境変数とマウント（60分）
- **Task 4.1**: 基本環境変数設定（20分）
- **Task 4.2**: UV環境変数設定（20分）
- **Task 4.3**: マウント戦略実装（20分）

### Phase 5: Compose設定（90分）
- **Task 5.1**: 開発環境Compose設定（30分）
- **Task 5.2**: 本番環境Compose設定（30分）
- **Task 5.3**: ボリューム設定（30分）

### Phase 6: 初期化とファイル（60分）
- **Task 6.1**: 初期化スクリプト作成（35分）
- **Task 6.2**: .dockerignore作成（15分）
- **Task 6.3**: pre-commit自動設定（10分）

### Phase 7: 検証とテスト（75分）
- **Task 7.1**: 開発モード基本テスト（25分）
- **Task 7.2**: 本番モード基本テスト（25分）
- **Task 7.3**: 統合テストと最適化（25分）

## ファイル構成
```
docker/
├── Dockerfile.dev      # 開発用
├── Dockerfile.prod     # 本番用
└── init.sh             # 初期化スクリプト
compose.dev.yaml        # 開発環境用（Docker Compose v2）
compose.prod.yaml       # 本番環境用（Docker Compose v2）
.dockerignore
```

## 共通実装指針

### 環境変数管理
すべてのタスクで一貫した環境変数を使用：
```bash
# Python関連
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1

# UV関連
UV_CACHE_DIR=/tmp/uv-cache
UV_LINK_MODE=copy
UV_PROJECT_ENVIRONMENT=/workspaces/claude-code-python-project-template/.venv
UV_COMPILE_BYTECODE=1

# Display
DISPLAY=""
```

### ベースイメージとユーザー設定
```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu
USER vscode
WORKDIR /workspaces/claude-code-python-project-template
```

### タスク間の依存関係
```
Task 1.1 → Task 1.2 → Task 1.3
Task 1.3 → Task 2.1, Task 2.2（並行実行可能）
Task 2.1, Task 2.2 → Task 2.3, Task 2.4（並行実行可能）
Task 2.3, Task 2.4 → Task 3.1, Task 3.2, Task 3.3, Task 3.4（すべて並行実行可能）
Task 3.* → Task 4.1, Task 4.2, Task 4.3（並行実行可能）
Task 4.* → Task 5.1, Task 5.2, Task 5.3（並行実行可能）
Task 5.* → Task 6.1, Task 6.2, Task 6.3（並行実行可能）
Task 6.* → Task 7.1, Task 7.2（並行実行可能）
Task 7.1, Task 7.2 → Task 7.3
```

## 重要な改善点

### 1コミット粒度の実現
- 各タスクは1-3ファイルの変更に限定
- 独立してテスト・検証可能
- ロールバック容易な単位

### 並行実行の最大化
- Phase 2以降で複数タスクの並行実行が可能
- 依存関係を最小限に抑えた設計
- CI/CDでの並列処理に適した構成

### 検証可能な完了条件
- 各タスクで具体的なテストコマンドを定義
- 動作確認手順を明確化
- 次のタスクに必要な条件を具体化

## 品質基準
- コンテナ起動時間：30秒以内
- 各ツールの動作確認コマンド実行成功
- 既存テストの非破壊性
- TypeScript/Python両方のビルド成功

## 最終的な成果物
1. **開発者向け**：`docker compose -f compose.dev.yaml up -d`で即座に開発環境構築
2. **本番向け**：`docker compose -f compose.prod.yaml up -d`で独立したコンテナ実行
3. **ドキュメント**：使用方法と設定説明
4. **テスト**：両モードでの動作確認済み

この再設計により、task-executorが自律的に実行可能な、1コミット粒度の実装可能なタスクを提供します。