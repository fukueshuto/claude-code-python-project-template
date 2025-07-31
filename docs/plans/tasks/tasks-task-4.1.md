# タスク: 初期化スクリプトの実装

## 概要
docker/init.shスクリプトを作成し、コンテナ起動時の自動初期化処理を実装する。pre-commit hooksの自動インストール、Python仮想環境の設定、設定ファイルの自動生成を冪等性を保って実行する。

## 前提条件
- 依存タスク: Task 3.1, Task 3.2
- 必要な知識: Bash scripting、Python環境管理、pre-commit設定

## 対象ファイル
- [x] `docker/init.sh` - 初期化スクリプト（新規作成）
- [x] `docker/Dockerfile.dev` - init.sh実行設定追加
- [x] `docker/Dockerfile.prod` - init.sh実行設定追加

## 実装手順
1. [x] `docker/init.sh`の基本構造作成
   ```bash
   #!/bin/bash
   set -euo pipefail
   
   # ログ出力関数
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&2
   }
   
   log "Starting initialization script..."
   ```
2. [x] Python仮想環境の自動設定
   ```bash
   # Python仮想環境の設定
   setup_python_env() {
       log "Setting up Python virtual environment..."
       
       if [ ! -d "/workspaces/claude-code-python-project-template/.venv" ]; then
           cd /workspaces/claude-code-python-project-template
           uv venv .venv
           log "Created Python virtual environment"
       else
           log "Python virtual environment already exists"
       fi
       
       # 依存関係のインストール
       if [ -f "pyproject.toml" ]; then
           uv pip install -e .
           log "Installed project dependencies"
       fi
   }
   ```
3. [x] pre-commit hooksの自動インストール
   ```bash
   # pre-commit hooksの設定
   setup_precommit() {
       log "Setting up pre-commit hooks..."
       
       cd /workspaces/claude-code-python-project-template
       
       if [ -f ".pre-commit-config.yaml" ]; then
           if ! command -v pre-commit &> /dev/null; then
               uv pip install pre-commit
           fi
           
           pre-commit install
           log "Pre-commit hooks installed"
       else
           log "No .pre-commit-config.yaml found, skipping pre-commit setup"
       fi
   }
   ```
4. [x] 設定ファイルの自動生成
   ```bash
   # 設定ファイルの生成
   setup_config_files() {
       log "Setting up configuration files..."
       
       # .env.localの生成（存在しない場合のみ）
       if [ ! -f "/workspaces/claude-code-python-project-template/.env.local" ]; then
           cat > /workspaces/claude-code-python-project-template/.env.local << EOF
   # Local development environment variables
   DEV_MODE=true
   PYTHONPATH=/workspaces/claude-code-python-project-template
   EOF
           log "Created .env.local file"
       fi
   }
   ```
5. [x] エラーハンドリングとログ出力
   ```bash
   # エラーハンドリング
   error_handler() {
       local line_no=$1
       log "ERROR: Script failed at line $line_no"
       exit 1
   }
   
   trap 'error_handler $LINENO' ERR
   ```
6. [x] 冪等性の保証
   ```bash
   # 冪等性チェック関数
   is_initialized() {
       [ -f "/workspaces/claude-code-python-project-template/.init_complete" ]
   }
   
   mark_initialized() {
       touch "/workspaces/claude-code-python-project-template/.init_complete"
       log "Marked initialization as complete"
   }
   ```
7. [x] メイン実行フロー
   ```bash
   # メイン処理
   main() {
       if is_initialized; then
           log "Environment already initialized, skipping..."
           return 0
       fi
       
       setup_python_env
       setup_precommit
       setup_config_files
       
       mark_initialized
       log "Initialization completed successfully"
   }
   
   main "$@"
   ```
8. [x] Dockerfileでの実行設定
   ```dockerfile
   # init.shの追加
   COPY docker/init.sh /usr/local/bin/init.sh
   RUN chmod +x /usr/local/bin/init.sh
   
   # エントリーポイントの設定
   ENTRYPOINT ["/usr/local/bin/init.sh"]
   CMD ["bash"]
   ```

## 完了条件
- [x] docker/init.shが作成され、実行可能である
- [x] Python仮想環境が自動で作成される
- [x] pre-commit hooksが正常にインストールされる
- [x] 設定ファイルが適切に生成される
- [x] エラーハンドリングが適切に動作する
- [x] 冪等性が保証され、複数回実行しても安全である
- [x] ログ出力が適切に行われる

## 注意事項
- 冪等性を保って、複数回実行しても安全にする
- 適切なエラーハンドリングと終了コードの設定
- ファイルパーミッションの問題を避ける
- 必須処理とオプション処理を分けて設計
- 実行時間を最適化（不要な処理の回避）

## コミットメッセージ案
```
feat: implement comprehensive initialization script

- Add docker/init.sh with automated environment setup
- Configure Python virtual environment creation
- Implement pre-commit hooks auto-installation
- Add configuration file generation
- Ensure idempotent execution with proper error handling
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 4.1
- 推定時間: 90分
- 全体設計書: `_overview-tasks.md`