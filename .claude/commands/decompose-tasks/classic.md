---
allowed-tools: Read, Bash
description: 確定された計画書を元に、task-decomposerエージェントを使って詳細な実行タスクファイル群に分解します。
---

## Context
- Finalized Plan: `.dev_docs/specs/plan.md`

## Your task

### 1. Verify prerequisites
- Check that `.dev_docs/specs/plan.md` exists. If not, inform the user to run `/finalize-spec` first.

### 2. Invoke task decomposer
- Use the `classic-task-decomposer` Sub agent to break down the plan into detailed, executable task files in `.dev_docs/tasks/`.
  ```
  classic-task-decomposer を使って `.dev_docs/specs/plan.md` を詳細なタスクファイルに分解してください。
  ```

### 3. Report Completion
- Inform the user that task decomposition is complete.
- Advise that the next step is `/sync-todos`.