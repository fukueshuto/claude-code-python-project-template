---
allowed-tools: TodoWrite, TodoRead, Read, Write, MultiEdit, Bash
description: Start autonomous implementation using Sub agents
---

## Context
- Requirements: @.tmp/requirements.md
- Design: @.tmp/design.md
- Tasks: @.tmp/tasks.md

## Your task

### 1. Prepare for autonomous execution
```bash
# Create necessary directories
mkdir -p docs/specs docs/plans/tasks

# Move specifications to permanent location
cp .tmp/requirements.md docs/specs/
cp .tmp/design.md docs/specs/
cp .tmp/tasks.md docs/plans/
```

### 2. Invoke task decomposer
Use the task-decomposer Sub agent to:
- Convert task list into executable task files
- Create overview document
- Set up task dependencies

```
task-decomposerを使って docs/plans/tasks.md をタスクファイルに分解してください
```

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