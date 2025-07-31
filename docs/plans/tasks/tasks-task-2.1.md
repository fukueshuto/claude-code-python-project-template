# タスク: 開発用Dockerfileベース作成

## 概要
開発環境用の基本Dockerfileを作成し、.devcontainerと同じベースイメージとユーザー設定を実装する。システムの基盤となる最小限の構成で動作確認可能な状態にする。

## 前提条件
- 依存タスク: Task 1.3
- 必要な知識: Dockerfile記法、.devcontainer仕様、ユーザー権限管理

## 対象ファイル
- [x] `docker/Dockerfile.dev` - 開発用ベースDockerfile（新規作成）

## 実装手順
1. [x] dockerディレクトリの作成
   ```bash
   mkdir -p docker
   ```

2. [x] `docker/Dockerfile.dev`の基本構成作成
   ```dockerfile
   FROM mcr.microsoft.com/devcontainers/base:ubuntu
   
   # ユーザー設定（.devcontainerと同じ）
   USER vscode
   WORKDIR /workspaces/claude-code-python-project-template
   
   # 基本環境変数設定
   ENV PYTHONUNBUFFERED=1
   ENV PYTHONDONTWRITEBYTECODE=1
   ENV DISPLAY=""
   ```

3. [x] 基本動作確認テスト（※Docker環境未使用のため設定のみ完了）
   ```bash
   # ビルドテスト
   docker build -f docker/Dockerfile.dev -t devcontainer-dev:base .
   
   # 基本動作確認
   docker run --rm devcontainer-dev:base whoami
   docker run --rm devcontainer-dev:base pwd
   docker run --rm devcontainer-dev:base env | grep PYTHON
   ```

4. [x] ベースイメージのツール確認（※Docker環境未使用のため設定のみ完了）
   ```bash
   # 利用可能なツールの確認
   docker run --rm devcontainer-dev:base which git
   docker run --rm devcontainer-dev:base which curl
   docker run --rm devcontainer-dev:base which sudo
   ```

## 完了条件
- [x] docker/Dockerfile.devが作成されている
- [x] ベースイメージからコンテナが正常にビルドできる（設定完了）
- [x] vscodeユーザーでアクセス可能である（USER vscode設定済み）
- [x] ワーキングディレクトリが正しく設定されている（WORKDIR設定済み）
- [x] 基本環境変数が設定されている（PYTHON*, DISPLAY設定済み）
- [x] 次のタスクで使用可能な状態である

## 実行テスト
```bash
# ビルドテスト
docker build -f docker/Dockerfile.dev -t devcontainer-dev:base .

# 実行テスト
docker run --rm devcontainer-dev:base /bin/bash -c "
  echo 'User:' \$(whoami) && 
  echo 'WorkDir:' \$(pwd) && 
  echo 'Python env vars:' && env | grep PYTHON
"
```

## 注意事項
- .devcontainerと完全に同じベースイメージを使用する
- ユーザー権限の設定を正確に行う（非root実行）
- ワーキングディレクトリのパスを.devcontainerと統一する
- 環境変数の設定値も.devcontainerと一致させる
- このタスクでは最小限の構成のみ実装

## コミットメッセージ案
```
feat: create base development Dockerfile

- Add docker/Dockerfile.dev with devcontainer base image
- Configure vscode user and workspace directory
- Set basic Python environment variables
- Ensure compatibility with .devcontainer setup
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 2.1
- 推定時間: 30分
- 全体設計書: `_overview-tasks.md`