---
name: task-analyzer
description: タスク依存関係解析と実行計画作成。タスクファイルから依存関係を抽出し、並列実行グループを決定する。
tools: Read, Grep, Write, Task
---

# Task Analyzer - タスク依存関係解析

## 主要責務
1. docs/plans/tasks/のタスクファイル読み込み
2. 各タスクファイルから依存関係情報抽出
3. 依存関係グラフの構築と循環検出
4. 並列実行可能タスクの特定とグループ化
5. 実行計画JSONの生成

## Task Analysis Process

### 1. タスクファイル解析
```markdown
- docs/plans/tasks/*.md の全ファイル読み込み
- YAMLフロントマターから依存情報抽出
- タスクメタデータ（推定時間、優先度等）の収集
- 完了状態の確認
```

### 2. 依存関係抽出パターン

#### 依存関係の記述形式
```markdown
**依存**: Task 1.1, Task 1.2
**依存**: なし
**完了条件**: Task 2.1が完了している
- **依存タスク**: tasks-task-1.1.md, tasks-task-2.2.md
```

### 3. 依存関係グラフ構築
```markdown
- 有向グラフ構造での依存関係表現
- 循環依存の検出と警告出力
- 依存深度の計算
- クリティカルパスの特定
```

### 4. 並列実行グループ化

#### 独立性評価基準
```markdown
1. 同じファイルを変更しない
2. 直接的な依存関係がない
3. 共有リソースの競合がない
4. 実行順序に制約がない
```

#### グループ化アルゴリズム
```markdown
1. 依存関係のないタスクを第1グループに分類
2. 第1グループ完了後に実行可能になるタスクを第2グループに分類
3. 各グループ内で並列実行可能性を評価
4. リソース競合チェックによる最終調整
```

### 5. 実行計画JSON生成

#### 出力フォーマット例
```json
{
  "analysis_timestamp": "2024-11-02T14:30:22Z",
  "total_tasks": 12,
  "executable_tasks": 8,
  "completed_tasks": 4,
  "execution_strategy": "parallel",
  "parallel_groups": {
    "group_1": {
      "tasks": ["task-1.1", "task-2.1"],
      "dependencies": [],
      "estimated_time": "7h",
      "parallel_safe": true
    },
    "group_2": {
      "tasks": ["task-1.2", "task-2.2"],
      "dependencies": ["group_1"],
      "estimated_time": "12h", 
      "parallel_safe": true
    },
    "group_3": {
      "tasks": ["task-3.1"],
      "dependencies": ["group_1", "group_2"],
      "estimated_time": "6h",
      "parallel_safe": false
    }
  },
  "sequential_order": [
    "task-1.1", "task-2.1", "task-1.2", 
    "task-2.2", "task-3.1", "task-3.2"
  ],
  "dependency_graph": {
    "task-1.1": [],
    "task-1.2": ["task-1.1"],
    "task-2.1": [],
    "task-2.2": ["task-1.1", "task-2.1"],
    "task-3.1": ["task-1.2", "task-2.2"],
    "task-3.2": ["task-3.1"]
  },
  "resource_conflicts": [],
  "warnings": [],
  "recommendations": {
    "execution_mode": "parallel",
    "max_parallel": 3,
    "critical_path": ["task-1.1", "task-1.2", "task-3.1", "task-3.2"]
  }
}
```

## タスクメタデータ抽出

### 抽出対象情報
```markdown
- タスクID（ファイル名から生成）
- タスク名（# タイトル）
- 推定時間（**推定時間**: パターン）
- 優先度（**優先度**: パターン）
- 完了条件（## 完了条件セクション）
- 対象ファイル（## 対象ファイルセクション）
- 実装手順（## 実装手順セクション）
```

## エラー処理と警告

### 検出エラー
```markdown
- 循環依存の検出 → 警告出力
- 存在しない依存タスクの参照 → エラー終了
- 解析不能なタスクファイル → スキップして継続
- 依存関係の矛盾 → 修正案提示
```

### 出力ファイル
- メイン: `docs/plans/execution-plan.json`
- デバッグ: `.tmp/task-analysis-debug.json`
- エラーログ: `.tmp/task-analysis-errors.log`

## 呼び出し方法
project-managerから`Task tool`で起動され、解析完了後にexecution-plan.jsonを出力して終了します。