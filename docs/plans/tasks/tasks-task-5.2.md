# タスク: 本番モード動作確認

## 概要
compose.prod.yamlでのコンテナ起動テストを実行し、本番モードの全機能が正常動作することを確認する。コンテナ独立動作、リソース制限、パフォーマンス最適化を包括的にテストする。

## 前提条件
- 依存タスク: Task 4.1
- 必要な知識: Docker Compose操作、本番環境テスト手法、リソース監視

## 対象ファイル
- [ ] `compose.prod.yaml` - 動作確認
- [ ] `main.py` - 実行テスト対象

## 実装手順
1. [ ] compose.prod.yamlでのコンテナ起動テスト
   ```bash
   # コンテナ起動
   docker compose -f compose.prod.yaml up -d
   
   # 起動ログの確認
   docker compose -f compose.prod.yaml logs
   
   # コンテナ状態の確認
   docker compose -f compose.prod.yaml ps
   
   # ヘルスチェック状態の確認
   docker compose -f compose.prod.yaml exec prod-container echo "Health check: OK"
   ```
2. [ ] コンテナ独立動作の確認
   ```bash
   # ファイルがコンテナ内に固定配置されていることを確認
   docker compose -f compose.prod.yaml exec prod-container ls -la /workspaces/claude-code-python-project-template/
   
   # ホストファイルの変更がコンテナに影響しないことを確認
   echo "# Host file change" > host_test.md
   docker compose -f compose.prod.yaml exec prod-container ls -la /workspaces/claude-code-python-project-template/host_test.md || echo "File not found in container (expected)"
   rm host_test.md
   
   # bind mountが設定されていないことを確認
   docker compose -f compose.prod.yaml exec prod-container mount | grep workspaces || echo "No bind mount found (expected)"
   ```
3. [ ] Python環境の動作確認
   ```bash
   # Python環境の確認
   docker compose -f compose.prod.yaml exec prod-container python --version
   docker compose -f compose.prod.yaml exec prod-container which python
   
   # UV環境の確認
   docker compose -f compose.prod.yaml exec prod-container uv --version
   
   # 依存関係の確認
   docker compose -f compose.prod.yaml exec prod-container uv pip list
   
   # 仮想環境の確認
   docker compose -f compose.prod.yaml exec prod-container ls -la /workspaces/claude-code-python-project-template/.venv
   ```
4. [ ] main.pyの実行テスト
   ```bash
   # main.pyの実行
   docker compose -f compose.prod.yaml exec prod-container python main.py
   
   # 実行ログの確認
   docker compose -f compose.prod.yaml logs prod-container
   
   # プロセス状態の確認
   docker compose -f compose.prod.yaml exec prod-container ps aux
   ```
5. [ ] 環境変数の確認
   ```bash
   # 本番用環境変数の確認
   docker compose -f compose.prod.yaml exec prod-container env | grep -E "(DEV_MODE|PYTHON|UV_)"
   
   # DEV_MODEがfalseに設定されていることを確認
   docker compose -f compose.prod.yaml exec prod-container echo $DEV_MODE
   
   # PYTHONOPTIMIZE設定の確認
   docker compose -f compose.prod.yaml exec prod-container python -c "import sys; print('Optimization level:', sys.flags.optimize)"
   ```
6. [ ] パフォーマンス確認（起動時間、メモリ使用量）
   ```bash
   # 起動時間の測定
   time docker compose -f compose.prod.yaml up -d
   
   # メモリ使用量の確認
   docker stats --no-stream $(docker compose -f compose.prod.yaml ps -q)
   
   # CPU使用率の確認
   docker compose -f compose.prod.yaml exec prod-container top -bn1 | head -n 20
   ```
7. [ ] リソース制限の確認
   ```bash
   # コンテナ設定の確認
   docker inspect $(docker compose -f compose.prod.yaml ps -q) | grep -A 10 "Memory\|Cpu"
   
   # 実際のリソース制限の動作確認
   docker stats --no-stream $(docker compose -f compose.prod.yaml ps -q)
   ```
8. [ ] 再起動ポリシーの確認
   ```bash
   # 再起動ポリシーの確認
   docker inspect $(docker compose -f compose.prod.yaml ps -q) | grep -A 5 "RestartPolicy"
   
   # 手動停止・自動再起動テスト
   CONTAINER_ID=$(docker compose -f compose.prod.yaml ps -q)
   docker stop $CONTAINER_ID
   sleep 5
   docker ps | grep $CONTAINER_ID || echo "Container restarted automatically"
   ```

## 完了条件
- [ ] compose.prod.yamlでコンテナが正常に起動する
- [ ] ファイルがコンテナ内に固定配置されている（bind mountなし）
- [ ] 外部依存なく独立して動作する
- [ ] Python環境が正常に動作する
- [ ] main.pyが正常に実行できる
- [ ] 本番用環境変数が正しく設定されている
- [ ] リソース制限が適用されている
- [ ] 起動時間とメモリ使用量が要件を満たす
- [ ] 再起動ポリシーが動作する

## 注意事項
- 本番モードではファイル同期は不要（COPYベース）
- リソース使用量を継続的に監視する
- セキュリティ面での設定を確認する
- エラー時の適切なログ出力を確認する

## コミットメッセージ案
```
test: verify production mode functionality

- Test container startup with compose.prod.yaml
- Verify container independence without bind mounts  
- Confirm Python environment in production mode
- Test resource limits and restart policies
- Validate performance metrics and health checks
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 5.2
- 推定時間: 30分
- 全体設計書: `_overview-tasks.md`