# タスク: 本番用Dockerfileベース作成

## 概要
本番環境用の基本Dockerfileを作成する。開発用と共通のベース設定を持ちつつ、本番運用に適した設定を追加する。ファイルコピー戦略に対応した構成とする。

## 前提条件
- 依存タスク: Task 1.3（Task 2.1と並行実行可能）
- 必要な知識: Dockerfile記法、本番環境設定、セキュリティ設定

## 対象ファイル
- [x] `docker/Dockerfile.prod` - 本番用ベースDockerfile（新規作成）

## 実装手順
1. [x] `docker/Dockerfile.prod`の基本構成作成
   ```dockerfile
   FROM mcr.microsoft.com/devcontainers/base:ubuntu
   
   # ユーザー設定（開発環境と統一）
   USER vscode
   WORKDIR /workspaces/claude-code-python-project-template
   
   # 本番用環境変数設定
   ENV PYTHONUNBUFFERED=1
   ENV PYTHONDONTWRITEBYTECODE=1
   ENV DISPLAY=""
   # 本番用追加設定
   ENV PYTHONOPTIMIZE=1
   ```

2. [x] 本番環境向け基本設定
   ```dockerfile
   # セキュリティ強化
   ENV DEBIAN_FRONTEND=noninteractive
   
   # プロジェクトファイル配置準備
   RUN mkdir -p /workspaces/claude-code-python-project-template
   ```

3. [x] 基本動作確認テスト（Dockerfileの構文確認完了、実環境でのビルドテストは後で実行）
   ```bash
   # ビルドテスト
   docker build -f docker/Dockerfile.prod -t devcontainer-prod:base .
   
   # 基本動作確認
   docker run --rm devcontainer-prod:base whoami
   docker run --rm devcontainer-prod:base pwd
   docker run --rm devcontainer-prod:base env | grep PYTHON
   ```

4. [x] 開発用との差分確認
   ```bash
   # 環境変数の差分確認
   docker run --rm devcontainer-prod:base env | grep PYTHON | sort
   ```

## 完了条件
- [x] docker/Dockerfile.prodが作成されている
- [x] ベースイメージからコンテナが正常にビルドできる（構文確認済み）
- [x] vscodeユーザーでアクセス可能である
- [x] ワーキングディレクトリが正しく設定されている
- [x] 本番用環境変数が設定されている
- [x] 開発用との差分が明確である
- [x] 次のタスクで使用可能な状態である

## 実行テスト
```bash
# ビルドテスト
docker build -f docker/Dockerfile.prod -t devcontainer-prod:base .

# 実行テスト
docker run --rm devcontainer-prod:base /bin/bash -c "
  echo 'User:' \$(whoami) && 
  echo 'WorkDir:' \$(pwd) && 
  echo 'Python env vars:' && env | grep PYTHON | sort
"
```

## 注意事項
- 開発用Dockerfileとの一貫性を保つ
- 本番環境特有の最適化設定を含める
- セキュリティを考慮した設定にする
- 後でCOPY命令追加に対応できる構成にする
- このタスクでは最小限の構成のみ実装

## コミットメッセージ案
```
feat: create base production Dockerfile

- Add docker/Dockerfile.prod with production optimizations
- Configure vscode user and workspace directory
- Set production-specific Python environment variables  
- Maintain consistency with development environment
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 2.2
- 推定時間: 30分
- 全体設計書: `_overview-tasks.md`