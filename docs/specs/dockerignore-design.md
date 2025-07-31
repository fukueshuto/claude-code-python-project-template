# .dockerignore設計書

## 目的
Dockerビルドコンテキストを最適化し、不要なファイルを除外することでビルド効率を向上させる。

## 除外対象ファイル・ディレクトリ

### 1. バージョン管理システム
```
.git
.gitignore
.gitattributes
.gitmodules
```

### 2. IDE・エディタ設定
```
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db
```

### 3. Python関連の一時ファイル
```
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
MANIFEST
.coverage
.pytest_cache/
.tox/
.nox/
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
```

### 4. Node.js関連
```
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*
.npm
.eslintcache
.node_repl_history
*.tgz
.yarn-integrity
.env.local
.env.development.local
.env.test.local
.env.production.local
```

### 5. 開発環境固有
```
.env
.env.*
!.env.example
.venv/
venv/
ENV/
env/
.cache/
*.log
logs/
.tmp/
temp/
tmp/
```

### 6. Docker関連
```
docker-compose.override.yml
.dockerignore
Dockerfile.*
!Dockerfile.dev
!Dockerfile.prod
```

### 7. CI/CD・テスト関連
```
.github/
.gitlab-ci.yml
.travis.yml
.circleci/
coverage/
.nyc_output/
junit.xml
test-results/
```

### 8. ドキュメント・README（開発用）
```
README.md
docs/
*.md
!docs/required-config.md
```

### 9. 設定ファイル（開発環境用）
```
.editorconfig
.pre-commit-config.yaml
pyproject.toml
package.json
package-lock.json
yarn.lock
requirements*.txt
```

### 10. その他の一時・キャッシュファイル
```
*.tmp
*.temp
*.bak
*.backup
.sass-cache/
connect.lock
typings/
.history/
```

## 特別な考慮事項

### 1. 必要なファイルの明示的な追加
- プロジェクト実行に必要な設定ファイルは除外対象から除外
- 本番環境で必要な設定ファイルは保持

### 2. セキュリティ考慮
- 機密情報を含むファイルは確実に除外
- .envファイルは除外（.env.exampleは保持）

### 3. ビルド効率最適化
- 大きなディレクトリ（node_modules、.git等）を優先的に除外
- 頻繁に変更されるファイルを適切に除外

## 最終的な.dockerignoreファイル構成

```
# Version Control
.git
.gitignore
.gitattributes

# IDE & Editor
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db

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
MANIFEST
.coverage
.pytest_cache/
.tox/
.nox/
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*
.npm
.eslintcache
.node_repl_history
*.tgz
.yarn-integrity

# Environment & Config
.env
.env.*
!.env.example
.venv/
venv/
ENV/
env/
.cache/

# Logs & Temp
*.log
logs/
.tmp/
temp/
tmp/
*.tmp
*.temp
*.bak
*.backup

# Docker
docker-compose.override.yml

# CI/CD
.github/
.gitlab-ci.yml
.travis.yml
.circleci/
coverage/
.nyc_output/
junit.xml
test-results/

# Documentation (development)
README.md
docs/
*.md

# Development Config
.editorconfig
.pre-commit-config.yaml
.history/
.sass-cache/
connect.lock
typings/
```

このファイル構成により、Dockerビルドの効率が向上し、セキュリティも確保されます。