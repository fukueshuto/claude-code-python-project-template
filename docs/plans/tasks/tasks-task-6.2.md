# タスク: エラーハンドリングと品質向上

## 概要
詳細なエラーメッセージの実装、ログ出力の改善、設定の妥当性チェック機能、ヘルスチェック機能を実装し、エラー時の診断が容易で堅牢性の高いシステムを構築する。

## 前提条件
- 依存タスク: Task 6.1
- 必要な知識: エラーハンドリング設計、ログ管理、ヘルスチェック実装

## 対象ファイル
- [ ] `docker/init.sh` - エラーハンドリング強化
- [ ] `docker/Dockerfile.dev` - ヘルスチェック追加
- [ ] `docker/Dockerfile.prod` - 本番用エラーハンドリング
- [ ] `compose.dev.yaml` - ヘルスチェック設定
- [ ] `compose.prod.yaml` - 本番用ヘルスチェック

## 実装手順
1. [ ] init.shスクリプトのエラーハンドリング強化
   ```bash
   #!/bin/bash
   set -euo pipefail
   
   # ログ設定
   readonly LOG_FILE="/tmp/init.log"
   readonly ERROR_LOG="/tmp/init.error.log"
   
   # ログ出力関数の強化
   log() {
       local level="$1"
       local message="$2"
       local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
       
       case "$level" in
           INFO)  echo "[$timestamp] INFO: $message" | tee -a "$LOG_FILE" ;;
           WARN)  echo "[$timestamp] WARN: $message" | tee -a "$LOG_FILE" >&2 ;;
           ERROR) echo "[$timestamp] ERROR: $message" | tee -a "$LOG_FILE" | tee -a "$ERROR_LOG" >&2 ;;
           DEBUG) [ "${DEBUG:-false}" = "true" ] && echo "[$timestamp] DEBUG: $message" | tee -a "$LOG_FILE" ;;
       esac
   }
   
   # エラーハンドラーの改善
   error_handler() {
       local line_no=$1
       local error_code=$?
       local command="${BASH_COMMAND}"
       
       log ERROR "Script failed at line $line_no with exit code $error_code"
       log ERROR "Failed command: $command"
       log ERROR "Working directory: $(pwd)"
       log ERROR "User: $(whoami)"
       log ERROR "Environment variables:"
       env | grep -E "(PYTHON|UV_|DEV_MODE)" | while read line; do
           log ERROR "  $line"
       done
       
       # スタックトレースの出力
       log ERROR "Call stack:"
       local frame=0
       while caller $frame; do
           ((frame++))
       done | while read line; do
           log ERROR "  $line"
       done
       
       # 診断情報の収集
       collect_diagnostic_info
       
       exit $error_code
   }
   
   trap 'error_handler $LINENO' ERR
   ```
2. [ ] 診断情報収集機能の実装
   ```bash
   # 診断情報収集
   collect_diagnostic_info() {
       log INFO "Collecting diagnostic information..."
       
       {
           echo "=== System Information ==="
           uname -a
           echo ""
           
           echo "=== Docker Environment ==="
           env | grep -E "(DOCKER|CONTAINER)" || true
           echo ""
           
           echo "=== Python Environment ==="
           python --version 2>/dev/null || echo "Python not available"
           which python 2>/dev/null || echo "Python path not found"
           echo ""
           
           echo "=== UV Environment ==="
           uv --version 2>/dev/null || echo "UV not available"
           which uv 2>/dev/null || echo "UV path not found"
           echo ""
           
           echo "=== Disk Space ==="
           df -h /workspaces/claude-code-python-project-template 2>/dev/null || echo "Workspace not available"
           echo ""
           
           echo "=== Process List ==="
           ps aux | head -10
           echo ""
           
       } >> "$ERROR_LOG" 2>&1
       
       log INFO "Diagnostic information saved to $ERROR_LOG"
   }
   ```
3. [ ] 設定妥当性チェック機能の実装
   ```bash
   # 設定妥当性チェック
   validate_environment() {
       log INFO "Validating environment configuration..."
       
       local errors=0
       
       # 必須環境変数のチェック
       local required_vars=("PYTHONUNBUFFERED" "UV_PROJECT_ENVIRONMENT" "UV_CACHE_DIR")
       for var in "${required_vars[@]}"; do
           if [ -z "${!var:-}" ]; then
               log ERROR "Required environment variable $var is not set"
               ((errors++))
           else
               log DEBUG "$var=${!var}"
           fi
       done
       
       # ディレクトリ存在チェック
       local required_dirs=("/workspaces/claude-code-python-project-template")
       for dir in "${required_dirs[@]}"; do
           if [ ! -d "$dir" ]; then
               log ERROR "Required directory $dir does not exist"
               ((errors++))
           else
               log DEBUG "Directory $dir exists"
           fi
       done
       
       # コマンド利用可能性チェック
       local required_commands=("python" "uv" "git")
       for cmd in "${required_commands[@]}"; do
           if ! command -v "$cmd" >/dev/null 2>&1; then
               log ERROR "Required command $cmd is not available"
               ((errors++))
           else
               log DEBUG "Command $cmd is available at $(which $cmd)"
           fi
       done
       
       # ファイル権限チェック
       if [ ! -w "/workspaces/claude-code-python-project-template" ]; then
           log ERROR "Workspace directory is not writable"
           ((errors++))
       fi
       
       if [ $errors -gt 0 ]; then
           log ERROR "Environment validation failed with $errors errors"
           return 1
       fi
       
       log INFO "Environment validation completed successfully"
       return 0
   }
   ```
4. [ ] ヘルスチェック機能の実装
   ```bash
   # docker/healthcheck.sh の作成
   #!/bin/bash
   
   # ヘルスチェックスクリプト
   readonly HEALTH_LOG="/tmp/health.log"
   
   health_log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$HEALTH_LOG"
   }
   
   # 基本的なヘルスチェック
   check_basic_health() {
       health_log "Starting health check..."
       
       # Python環境チェック
       if ! python -c "import sys; sys.exit(0)" 2>/dev/null; then
           health_log "ERROR: Python environment is not healthy"
           return 1
       fi
       
       # UV環境チェック
       if ! uv --version >/dev/null 2>&1; then
           health_log "ERROR: UV is not accessible"
           return 1
       fi
       
       # プロジェクトファイルアクセスチェック
       if [ ! -f "/workspaces/claude-code-python-project-template/main.py" ]; then
           health_log "WARNING: main.py not found"
       fi
       
       # 仮想環境チェック
       if [ ! -d "$UV_PROJECT_ENVIRONMENT" ]; then
           health_log "WARNING: Virtual environment not found at $UV_PROJECT_ENVIRONMENT"
       fi
       
       health_log "Health check completed successfully"
       return 0
   }
   
   check_basic_health
   ```
5. [ ] Dockerfileでのヘルスチェック設定
   ```dockerfile
   # Development Dockerfile
   COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh
   RUN chmod +x /usr/local/bin/healthcheck.sh
   
   HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
       CMD /usr/local/bin/healthcheck.sh
   ```
6. [ ] Docker Composeでのヘルスチェック設定強化
   ```yaml
   # compose.dev.yaml
   services:
     dev-container:
       # ... other settings ...
       healthcheck:
         test: ["/usr/local/bin/healthcheck.sh"]
         interval: 30s
         timeout: 10s
         retries: 3
         start_period: 40s
       # ヘルスチェック失敗時の設定
       restart: unless-stopped
   ```
7. [ ] 詳細なログ出力の改善
   ```bash
   # ログレベル別の出力改善
   setup_logging() {
       # ログレベルの設定
       case "${LOG_LEVEL:-INFO}" in
           DEBUG) set -x ;;
           INFO)  ;;
           WARN)  ;;
           ERROR) ;;
           *) log WARN "Unknown log level: ${LOG_LEVEL:-INFO}, using INFO" ;;
       esac
       
       # ログローテーション設定
       if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt 1048576 ]; then
           mv "$LOG_FILE" "${LOG_FILE}.old"
           touch "$LOG_FILE"
           log INFO "Log file rotated"
       fi
   }
   ```
8. [ ] エラー回復機能の実装
   ```bash
   # エラー回復試行
   retry_with_backoff() {
       local max_attempts=$1
       local delay=$2
       local command="$3"
       local attempt=1
       
       while [ $attempt -le $max_attempts ]; do
           log INFO "Attempting: $command (attempt $attempt/$max_attempts)"
           
           if eval "$command"; then
               log INFO "Command succeeded on attempt $attempt"
               return 0
           else
               local exit_code=$?
               log WARN "Command failed on attempt $attempt with exit code $exit_code"
               
               if [ $attempt -lt $max_attempts ]; then
                   log INFO "Waiting ${delay}s before retry..."
                   sleep $delay
                   delay=$((delay * 2))  # Exponential backoff
               fi
           fi
           
           ((attempt++))
       done
       
       log ERROR "Command failed after $max_attempts attempts"
       return 1
   }
   ```

## 完了条件
- [ ] 詳細なエラーメッセージが実装される
- [ ] 構造化ログ出力が改善される
- [ ] 設定の妥当性チェック機能が動作する
- [ ] ヘルスチェック機能が実装される
- [ ] エラー時の診断情報が自動収集される
- [ ] エラー回復機能が実装される
- [ ] 冪等性が保たれる
- [ ] 堅牢性が大幅に向上する

## 注意事項
- エラーハンドリングがパフォーマンスに大きく影響しないようにする
- ログ出力が過度に詳細にならないよう調整する
- セキュリティ情報がログに含まれないよう注意する
- エラー回復機能が無限ループを引き起こさないようにする

## コミットメッセージ案
```
feat: implement comprehensive error handling and quality improvements

- Add detailed error messages with diagnostic information
- Implement structured logging with multiple levels
- Add environment validation and health check functionality
- Create error recovery mechanisms with exponential backoff
- Improve system robustness and debuggability
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 6.2
- 推定時間: 45分
- 全体設計書: `_overview-tasks.md`