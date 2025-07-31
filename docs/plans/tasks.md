# タスクリスト - .devcontainerと同等のDockerコンテナ環境構築

## 概要
- 総タスク数: 14
- 推定作業時間: 8-12時間
- 優先度: 高

## タスク一覧

### Phase 1: 準備・調査
#### Task 1.1: 既存環境の調査と.devcontainer設定確認
- [ ] .devcontainer/devcontainer.jsonの内容を確認
- [ ] .devcontainer/Dockerfileの内容を確認  
- [ ] 現在のdocker/Dockerfileとcompose.ymlの内容を確認
- [ ] 必要な環境変数とツール一覧を抽出
- **完了条件**: .devcontainerの全設定項目が文書化され、既存構成との差分が明確になる
- **依存**: なし
- **推定時間**: 30分

#### Task 1.2: ファイル構成設計の最終化
- [ ] 最新のDocker Compose仕様に基づくファイル名決定（compose.dev.yaml, compose.prod.yaml）
- [ ] 既存ファイルとの競合回避確認
- [ ] .dockerignoreファイルの設計
- **完了条件**: 作成すべきファイル一覧とパスが確定する
- **依存**: Task 1.1
- **推定時間**: 15分

### Phase 2: 基盤実装
#### Task 2.1: 基本Dockerfileの作成
- [ ] docker/Dockerfile.devの作成（開発用ベース）
- [ ] docker/Dockerfile.prodの作成（本番用ベース）
- [ ] mcr.microsoft.com/devcontainers/base:ubuntuベースイメージの設定
- [ ] vscodeユーザー設定とworkdir設定
- **完了条件**: 基本的なコンテナが起動し、vscodeユーザーでアクセス可能
- **依存**: Task 1.2
- **推定時間**: 45分

#### Task 2.2: 開発ツールインストール機能の実装
- [ ] システムパッケージのインストール（curl, wget, git, jq, ca-certificates, build-essential, ripgrep）
- [ ] GitHub CLIのインストール
- [ ] common-utilsの設定（zsh設定含む）
- [ ] uvのインストールと設定
- [ ] Node.jsのインストール
- [ ] Claude Code CLIのインストール
- **完了条件**: 全ての必要ツールがコンテナ内で利用可能
- **依存**: Task 2.1
- **推定時間**: 90分

#### Task 2.3: 環境変数管理の実装
- [ ] Docker Composeでの環境変数定義
- [ ] Python関連環境変数の設定（PYTHONUNBUFFERED, PYTHONDONTWRITEBYTECODE）
- [ ] UV関連環境変数の設定（UV_CACHE_DIR, UV_LINK_MODE, UV_PROJECT_ENVIRONMENT, UV_COMPILE_BYTECODE）
- [ ] DISPLAY環境変数の設定
- **完了条件**: .devcontainerと同等の環境変数がすべて設定される
- **依存**: Task 2.1
- **推定時間**: 30分

### Phase 3: Compose設定実装
#### Task 3.1: 開発環境用Compose設定
- [ ] compose.dev.yamlの作成
- [ ] bind mountの設定（プロジェクトルート）
- [ ] claude-code-configボリュームの設定
- [ ] 開発モード固有の環境変数設定
- [ ] cachedオプションの設定
- **完了条件**: 開発モードでコンテナが起動し、ファイル同期が動作する
- **依存**: Task 2.3
- **推定時間**: 45分

#### Task 3.2: 本番環境用Compose設定
- [ ] compose.prod.yamlの作成
- [ ] COPYによるファイル配置設定
- [ ] 本番モード固有の環境変数設定
- [ ] 最適化設定（メモリ制限等）
- **完了条件**: 本番モードでコンテナが起動し、外部依存なく動作する
- **依存**: Task 2.3
- **推定時間**: 30分

### Phase 4: 初期化・設定自動化
#### Task 4.1: 初期化スクリプトの実装
- [ ] docker/init.shスクリプトの作成
- [ ] pre-commit hooksの自動インストール機能
- [ ] Python仮想環境の自動設定
- [ ] 設定ファイルの自動生成
- [ ] エラーハンドリングとログ出力
- [ ] 冪等性の保証
- **完了条件**: init.shが正常に実行され、開発環境が完全に構築される
- **依存**: Task 3.1, Task 3.2
- **推定時間**: 90分

#### Task 4.2: .dockerignoreファイルの作成
- [ ] 不要ファイルの除外設定
- [ ] .git, .vscode, node_modules等の除外
- [ ] 機密ファイルの除外
- [ ] ビルド効率最適化
- **完了条件**: Dockerビルド時に不要ファイルが除外される
- **依存**: なし
- **推定時間**: 15分

### Phase 5: 検証・テスト
#### Task 5.1: 開発モード動作確認
- [ ] compose.dev.yamlでのコンテナ起動テスト
- [ ] ファイル同期の動作確認（ホスト→コンテナ）
- [ ] Python環境（uv, venv）の動作確認
- [ ] 各種ツール（git, gh, ruff等）の動作確認
- [ ] main.pyの実行テスト
- **完了条件**: 開発モードでの全機能が正常動作する
- **依存**: Task 4.1
- **推定時間**: 45分

#### Task 5.2: 本番モード動作確認
- [ ] compose.prod.yamlでのコンテナ起動テスト
- [ ] コンテナ独立動作の確認
- [ ] Python環境の動作確認
- [ ] main.pyの実行テスト
- [ ] パフォーマンス確認（起動時間、メモリ使用量）
- **完了条件**: 本番モードでの全機能が正常動作する
- **依存**: Task 4.1
- **推定時間**: 30分

#### Task 5.3: 統合テストとドキュメント確認
- [ ] docker runコマンドでの直接起動テスト
- [ ] GPU対応オプションの確認（環境に応じて）
- [ ] 既存compose.ymlとの共存確認
- [ ] 使用方法ドキュメントの作成
- **完了条件**: 全ての起動方法が動作し、使用方法が文書化される
- **依存**: Task 5.1, Task 5.2
- **推定時間**: 60分

### Phase 6: 仕上げ・最適化
#### Task 6.1: パフォーマンス最適化
- [ ] マルチステージビルドの実装
- [ ] Docker layerキャッシュの最適化
- [ ] 不要な依存関係の除去
- [ ] ビルド時間の測定と改善
- **完了条件**: コンテナ起動時間が30秒以内、ビルド時間が最適化される
- **依存**: Task 5.3
- **推定時間**: 45分

#### Task 6.2: エラーハンドリングと品質向上
- [ ] 詳細なエラーメッセージの実装
- [ ] ログ出力の改善
- [ ] 設定の妥当性チェック機能
- [ ] ヘルスチェック機能の実装
- **完了条件**: エラー時の診断が容易になり、堅牢性が向上する
- **依存**: Task 6.1
- **推定時間**: 45分

## 実装順序
1. Phase 1から順次実行（調査は並行可能）
2. Phase 2のTask 2.2とTask 2.3は並行実行可能
3. Phase 3のTask 3.1とTask 3.2は並行実行可能  
4. Phase 5のTask 5.1とTask 5.2は並行実行可能
5. 依存関係を考慮した実装順序を厳守

## リスクと対策
- **UID/GIDマッピング問題**: ホストとコンテナでのファイル権限不整合 → docker-compose.yamlでuser設定を追加
- **環境変数設定漏れ**: .devcontainerとの差異 → チェックリストによる検証
- **既存設定との競合**: compose.ymlとの競合 → ファイル名の明確な分離
- **マウント設定エラー**: bind mountの権限問題 → cachedオプションと適切な権限設定
- **ツールインストール失敗**: ネットワークやパッケージの問題 → リトライ機能とフォールバック処理

## 注意事項
- 各タスクはコミット単位で完結させる
- タスク完了時は必要に応じて品質チェックを実行
- Docker Compose最新仕様（compose.yaml）を使用
- 既存のcompose.ymlとの競合を避ける
- ファイルパーミッション問題に注意深く対応
- 不明点は実装前に確認する

## 実装開始ガイド
1. このタスクリストに従って順次実装を進めてください
2. 各タスクの開始時にTodoWriteでin_progressに更新
3. 完了時はcompletedに更新
4. 問題発生時は速やかに報告してください

## Sub Agent活用方法
- `/implement` コマンドで自律実装を開始
- `task-decomposer` でタスクファイルを生成
- `task-executor` で個別タスクを実行  
- `quality-checker` で品質保証

## 最新Docker Compose仕様対応
- ファイル名: `compose.dev.yaml`, `compose.prod.yaml`（最新の推奨形式）
- 既存の`compose.yml`との明確な分離
- Compose v2の機能を活用した最適化