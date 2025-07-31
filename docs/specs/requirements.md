# 要件定義書 - .devcontainerと同等のDockerコンテナ環境構築

## 1. 目的
.devcontainer設定で定義された開発環境と同じ状態のDockerコンテナを、docker runまたはdocker composeコマンドで直接立ち上げられるようにする。プロジェクトルートが適切にマウントされ、開発者が.devcontainerを使用しない場合でも同じ開発体験を提供する。

## 2. 機能要件
### 2.1 必須機能
- [ ] .devcontainerと同じベースイメージ（mcr.microsoft.com/devcontainers/base:ubuntu）の利用
- [ ] プロジェクトルートディレクトリの柔軟な配置方式対応
  - **開発モード**: bind mount/volume mountによるリアルタイム同期（.devcontainer相当）
  - **本番モード**: COPYによるファイルのコンテナ内固定配置
- [ ] .devcontainerで定義された環境変数の再現
  - DISPLAY、PYTHONUNBUFFERED、PYTHONDONTWRITEBYTECODE
  - UV関連環境変数（UV_CACHE_DIR、UV_LINK_MODE、UV_PROJECT_ENVIRONMENT、UV_COMPILE_BYTECODE）
- [ ] 必要なパッケージとツールのインストール
  - GitHub CLI、common-utils（zsh設定含む）
  - apt-packages: curl, wget, git, jq, ca-certificates, build-essential, ripgrep
  - uv（Python package manager）
  - Node.js
  - Claude Code CLI
- [ ] VSCode設定の再現（Python interpreter path等）
- [ ] 必要なVSCode拡張機能の情報提供
- [ ] Docker volumes設定（claude-code-config volume）
- [ ] 初期化スクリプト（init.sh）の実行
- [ ] pre-commit hooksの自動インストール

### 2.2 オプション機能
- [ ] GPU対応の設定（--gpus all、NVIDIA関連設定）
- [ ] カスタムrunArgsの対応（--init、--rm等）
- [ ] ホスト要件の確認機能
- [ ] デプロイ用途向けの設定
  - 環境変数によるモード切り替え（DEV_MODE=true/false）
  - compose.dev.yaml と compose.prod.yaml の提供（Docker Compose v2最新仕様）
  - 本番環境用の最適化設定

## 3. 非機能要件
### 3.1 パフォーマンス
- コンテナ起動時間は.devcontainerと同等もしくはそれより高速
- ビルド時間の最適化（キャッシュ活用）

### 3.2 セキュリティ
- 適切なユーザー権限設定（vscodeユーザーまたは同等）
- sudo権限の適切な管理
- ファイアウォール設定の維持

### 3.3 保守性
- 設定の重複を避け、.devcontainerとの整合性を保つ
- 環境変数や設定の一元管理
- ドキュメント化された設定手順

### 3.4 互換性
- 既存のdocker/Dockerfileとの互換性
- 既存のcompose.ymlとの共存（最新のcompose.yamlファイル形式を使用）
- 異なるOS（Linux、macOS、Windows）での動作

## 4. 制約事項
### 4.1 技術的制約
- 既存のDockerfile構成を大幅に変更しない
- uvを使用したPython環境管理の維持
- 既存のcompose.ymlとの競合回避

### 4.2 ビジネス制約
- 開発効率の低下を避ける
- 既存の開発フローへの影響を最小限に抑える

## 5. 成功基準
### 5.1 完了の定義
- [ ] docker runコマンドで.devcontainerと同等の環境が起動する
- [ ] 開発モード: プロジェクトルートが適切にマウントされ、リアルタイム同期される
- [ ] 本番モード: プロジェクトファイルがコンテナ内に固定配置される
- [ ] Python開発環境（uv、venv）が正常に動作する
- [ ] 必要なツール（git、gh、ruff等）がすべて利用可能
- [ ] 初期化処理が正常に完了する
- [ ] 既存のmain.pyが実行可能

### 5.2 受け入れテスト
- **開発モード**: ホスト側でのファイル変更がコンテナ内に即座に反映される
- **本番モード**: コンテナ独立でファイルが配置され、外部依存なく動作する
- 新しいDockerコンテナ環境で既存のPythonコードが実行できる
- uvコマンドでパッケージ管理が可能
- git操作が正常に動作する
- pre-commit hooksが正常に動作する

## 6. 想定されるリスク
- 環境変数の設定漏れによる動作不良
- マウント設定の不備によるファイルアクセス問題
- ユーザー権限設定の不整合
- 既存のDocker設定との競合
- 初期化スクリプトの実行エラー

## 7. 今後の検討事項
- GPU対応が必要な場合の設定方法
- マルチプラットフォーム対応（ARM64等）
- CI/CD環境での利用方法
- 開発環境の自動テスト手順
- 設定の自動同期メカニズム