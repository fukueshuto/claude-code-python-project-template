---
allowed-tools: TodoWrite, TodoRead, Read, Write, MultiEdit, Bash
description: Start autonomous implementation using Sub agents
---

## Context
- Requirements: @.dev_docs/specs/requirements.md
- Design: @.dev_docs/specs/design.md

## Your task

### 1. Verify prerequisites
- Check if the TODO list is synchronized with the task files. If not, advise the user to run `/sync-todos` first.
- Confirm with the user before starting the execution loop.

### 3. Explain execution loop
Inform user about the autonomous execution process:

```markdown
## 自律実行プロセス

各タスクに対して以下のループを実行します：

1. **task-executor** でタスクを実行
   - 仕様書に基づいた実装
   - 進捗のリアルタイム更新

2. **quality-checker** で品質確認
   - コード品質の自動チェック
   - 問題の即座修正

3. **進捗確認とコミット**
   - タスク完了の確認
   - すべてのファイルをコミット
   - 次タスクへの移行

必要に応じて **spec-manager** で全体の整合性を確認できます。
```

### 4. Start first task execution
Begin with the first task:

```
では最初のタスクから開始します：
- task-executor でタスク01を実行
- 完了後、quality-checker で品質チェック
```

### 5. Monitor and assist
- Watch for context overflow signs
- Provide guidance when Sub agents need help
- Ensure quality standards are maintained
- Use spec-manager for coherence checks

## Important Notes
- Let Sub agents work autonomously
- Intervene only when necessary
- Maintain specification alignment
- Each task should result in a working commit
- Update progress documentation continuously

think hard