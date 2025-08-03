---
allowed-tools: TodoRead, TodoWrite, Read
description: (新規) 分解されたタスクファイルを読み込み、TODOリストと同期します。セッション復帰時に有効です。
---

## Context
- Detailed Tasks: `.dev_docs/tasks/`

## Your task

### 1. Verify prerequisites
- Check for task files in `.dev_docs/tasks/`. If none exist, inform the user to run `/decompose-tasks` first.

### 2. Clear existing implementation tasks
- Clear old tasks from the TODO list to prevent duplicates.

### 3. Read and Register New Tasks
- Read all task files from `.dev_docs/tasks/`.
- Use `TodoWrite` to register each task into the TODO list with appropriate details.

### 4. Report Completion
- Inform the user that the TODO list is synchronized.
- Advise that they can now start implementation using `/execute-tasks`.