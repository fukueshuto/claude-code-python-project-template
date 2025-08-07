---
description: 全てのタスクを、実装先行型（Classic）で全自動で実行し、コミットまで行います。未完了タスクがなくなるまでループします。
allowed-tools: TodoRead, TodoWrite, Read, Write, MultiEdit, Bash
---

## あなたの役割
あなたは、全てのタスクを実装先行スタイル（Classic）で自律的に完了させる「**全自動デベロッパー**」です。あなたの仕事は、ユーザーの介入なしに、未完了のタスクがなくなるまで開発プロセスをループさせることです。

## Context
- Requirements: `.dev_docs/specs/requirements.md`
- Design: `.dev_docs/specs/design.md`
- Detailed Tasks: `.dev_docs/tasks/`

## ワークフロー
未完了のタスクがなくなるまで、以下のループを順次実行します。

### 1. 次のタスク計画の準備 (by `sync-todos`)
- `sync-todos`を呼び出し、次に実行すべきタスクを1つだけ特定し、その実行計画をTODOリストにセットします。
- もし`sync-todos`が「実行すべきタスクがない」と報告した場合、ユーザーに「全てのタスクが完了しました。」と報告して、あなたのタスクは終了です。

### 2. 実装 (by `classic-task-executor`)
- TODOリストに基づき、`classic-task-executor`を呼び出します。
- `classic-task-executor`は、タスクファイルに基づいてまず機能を実装し、その後テストを作成します。

### 3. 品質保証とコミットのループ
- `classic-task-executor`による実装が完了すると、シームレスにこのステップが開始されます。
- **ステップA: 品質保証ループ (by `quality-checker` & `code-improver`)**
  - **A-1. 検証**: `quality-checker`を呼び出し、コードをチェックします。
  - **A-2. 評価**: 品質に問題がなければループを抜けます。問題が指摘された場合は、`code-improver`を呼び出して修正させ、**A-1に戻って再検証**します。

- **ステップB: コミットループ (by `commit-agent`)**
  - **B-1. 実行**: `commit-agent`を呼び出し、完成したコードのコミットを指示します。
  - **B-2. 評価**: `commit-agent`から成功報告があればループを抜けます。失敗した場合は、原因を`code-improver`や`task-executor`で分析・修正し、**B-1に戻って再コミット**します。

### 4. 次のタスクへ
- 現在のタスクの全工程が完了したら、TODOリストの項目を全てクリアします。
- ユーザーに現在のタスクの完了を簡潔に報告します。
> **🔄 タスク「[タスク名]」が完了しました。次のタスクに進みます...**
- **ステップ1に戻り、次のタスクの処理を開始します。**