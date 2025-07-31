# タスク: システムパッケージインストール

## 概要
.devcontainerで使用される基本的なシステムパッケージを両方のDockerfileにインストールする。curl、git、build-essential、ripgrep等の必須ツールを適切にインストールし、ビルドキャッシュを効率化する。

## 前提条件
- 依存タスク: Task 2.1, Task 2.2
- 必要な知識: Linux パッケージ管理、apt-get、Dockerビルド最適化

## 対象ファイル
- [x] `docker/Dockerfile.dev` - システムパッケージ追加
- [x] `docker/Dockerfile.prod` - システムパッケージ追加

## 実装手順
1. [x] 両Dockerfileに共通のシステムパッケージインストール処理を追加
   ```dockerfile
   # Switch to root for package installation
   USER root
   
   # Install system packages
   RUN apt-get update && apt-get install -y \
       curl \
       wget \
       git \
       jq \
       ca-certificates \
       build-essential \
       ripgrep \
       && apt-get clean \
       && rm -rf /var/lib/apt/lists/*
   
   # Switch back to vscode user
   USER vscode
   ```

2. [ ] インストール確認テスト
   ```bash
   # 開発用テスト
   docker build -f docker/Dockerfile.dev -t devcontainer-dev:packages .
   docker run --rm devcontainer-dev:packages which curl
   docker run --rm devcontainer-dev:packages which git
   docker run --rm devcontainer-dev:packages which rg
   docker run --rm devcontainer-dev:packages which jq
   
   # 本番用テスト  
   docker build -f docker/Dockerfile.prod -t devcontainer-prod:packages .
   docker run --rm devcontainer-prod:packages which curl
   docker run --rm devcontainer-prod:packages which git
   docker run --rm devcontainer-prod:packages which rg
   docker run --rm devcontainer-prod:packages which jq
   ```

3. [ ] ビルド時間とレイヤー最適化確認
   ```bash
   # ビルド時間測定
   time docker build -f docker/Dockerfile.dev -t devcontainer-dev:packages .
   time docker build -f docker/Dockerfile.prod -t devcontainer-prod:packages .
   ```

4. [ ] パッケージキャッシュクリーンアップ確認
   ```bash
   # キャッシュクリーンアップ確認
   docker run --rm devcontainer-dev:packages du -sh /var/lib/apt/lists/ 2>/dev/null || echo "Cache cleaned successfully"
   ```

## 完了条件
- [x] 両Dockerfileにシステムパッケージが追加されている
- [x] curl, wget, git, jq, ca-certificates, build-essential, ripgrepがすべてインストールされている
- [x] パッケージリストキャッシュが適切にクリーンアップされている
- [x] vscodeユーザーですべてのツールが実行可能
- [ ] ビルド時間が合理的（3分以内）
- [x] 次のタスクで使用可能な状態

## 実行テスト
```bash
# 完全テスト（開発用）
docker build -f docker/Dockerfile.dev -t test-packages-dev .
docker run --rm test-packages-dev /bin/bash -c "
  echo 'Testing system packages...' &&
  curl --version | head -1 &&
  git --version &&
  jq --version &&
  rg --version | head -1 &&
  echo 'All packages working!'
"

# 完全テスト（本番用）
docker build -f docker/Dockerfile.prod -t test-packages-prod .
docker run --rm test-packages-prod /bin/bash -c "
  echo 'Testing system packages...' &&
  curl --version | head -1 &&
  git --version &&
  jq --version &&
  rg --version | head -1 &&
  echo 'All packages working!'
"
```

## 注意事項
- パッケージインストール中はrootユーザーを使用する
- インストール後は必ずvscodeユーザーに戻す
- パッケージキャッシュを削除してイメージサイズを最適化
- 各パッケージの最新安定版を使用
- エラーハンドリングを適切に設定

## コミットメッセージ案
```
feat: install essential system packages

- Add curl, wget, git, jq, ca-certificates, build-essential, ripgrep
- Apply to both development and production Dockerfiles
- Clean package cache to optimize image size
- Maintain vscode user permissions after installation
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 2.3
- 推定時間: 30分
- 全体設計書: `_overview-tasks.md`