# タスク: .dockerignore作成

## 概要
Dockerビルドの効率化とセキュリティ向上のため、適切な.dockerignoreファイルを作成する。不要ファイルの除外、機密情報の保護、ビルド時間の最適化を実現する。

## 前提条件
- 依存タスク: なし（他のタスクと並行実行可能）
- 必要な知識: .dockerignore記法、セキュリティベストプラクティス

## 対象ファイル
- [x] `.dockerignore` - ビルド最適化設定（新規作成）

## 実装手順
1. [x] `.dockerignore`の基本設定作成
   ```dockerignore
   # Git関連
   .git
   .gitignore
   .gitattributes
   
   # IDE/エディタ設定
   .vscode
   .idea
   *.swp
   *.swo
   *~
   
   # OS固有ファイル
   .DS_Store
   Thumbs.db
   
   # ログファイル
   *.log
   logs/
   
   # 一時ファイル
   tmp/
   temp/
   .tmp/
   ```

2. [x] Python固有の除外設定
   ```dockerignore
   # Python
   __pycache__/
   *.py[cod]
   *$py.class
   *.so
   .Python
   build/
   develop-eggs/
   dist/
   downloads/
   eggs/
   .eggs/
   lib/
   lib64/
   parts/
   sdist/
   var/
   wheels/
   *.egg-info/
   .installed.cfg
   *.egg
   
   # Virtual environments
   .env
   .venv
   env/
   venv/
   ENV/
   env.bak/
   venv.bak/
   
   # pytest
   .pytest_cache/
   .coverage
   htmlcov/
   
   # mypy
   .mypy_cache/
   .dmypy.json
   dmypy.json
   ```

3. [x] Node.js固有の除外設定
   ```dockerignore
   # Node.js
   node_modules/
   npm-debug.log*
   yarn-debug.log*
   yarn-error.log*
   .npm
   .yarn-integrity
   
   # Package files
   package-lock.json
   yarn.lock
   ```

4. [x] Docker/コンテナ関連の除外
   ```dockerignore
   # Docker
   Dockerfile*
   docker-compose*.yml
   docker-compose*.yaml
   compose*.yml
   compose*.yaml
   .dockerignore
   
   # CI/CD
   .github/
   .gitlab-ci.yml
   .travis.yml
   .circleci/
   ```

5. [x] ドキュメント・開発関連の除外
   ```dockerignore
   # Documentation
   README.md
   CHANGELOG.md
   LICENSE
   docs/
   
   # Development
   .pre-commit-config.yaml
   .editorconfig
   .flake8
   .isort.cfg
   pyproject.toml
   setup.cfg
   
   # Tests (本番ビルド時)
   tests/
   test_*/
   *_test.py
   ```

6. [x] ビルド効果の確認
   ```bash
   # ビルドコンテキストサイズの確認
   docker build -f docker/Dockerfile.dev -t test-dockerignore .
   
   # .dockerignore無しとの比較
   mv .dockerignore .dockerignore.bak
   docker build -f docker/Dockerfile.dev -t test-no-dockerignore .
   mv .dockerignore.bak .dockerignore
   
   # イメージサイズ比較
   docker images | grep test-
   ```

## 完了条件
- [x] .dockerignoreファイルが作成されている
- [x] Git関連ファイルが適切に除外されている
- [x] Python関連の不要ファイルが除外されている
- [x] IDE設定ファイルが除外されている
- [x] ログ・一時ファイルが除外されている
- [x] 機密情報が保護されている
- [x] ビルド時間が最適化されている
- [x] 必要なファイルが誤って除外されていない

## 実行テスト
```bash
# .dockerignoreの動作確認
echo "test" > .test-file
mkdir -p .test-dir
echo "test" > .test-dir/file

# ビルドして除外されることを確認
docker build -f docker/Dockerfile.dev -t test-dockerignore-check . 2>&1 | grep -E "(test-file|test-dir)" || echo "Files correctly ignored"

# テストファイル削除
rm -f .test-file
rm -rf .test-dir

# ビルド効率確認
time docker build -f docker/Dockerfile.dev -t test-build-time .

echo "Build completed. Check build time and context size."
```

## 注意事項
- 必要なファイルを誤って除外しないよう注意
- 開発環境と本番環境の両方を考慮
- セキュリティ上重要なファイルの除外を確実に行う
- ビルドコンテキストサイズの削減効果を測定
- プロジェクト固有のファイルパターンも考慮

## コミットメッセージ案
```
feat: create comprehensive .dockerignore for build optimization

- Exclude Git, IDE, and OS-specific files
- Add Python-specific patterns (__pycache__, .venv, etc.)
- Include Node.js patterns for npm/yarn files
- Exclude documentation and development configuration
- Protect sensitive files and optimize build context size
```

## メタ情報
- 計画書: `docs/plans/tasks.md`
- タスク番号: Task 6.2 (dockerignore)
- 推定時間: 15分
- 全体設計書: `_overview-tasks.md`