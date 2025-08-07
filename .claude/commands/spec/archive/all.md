---
allowed-tools: Read, Bash
description: /archive-spec と /archive-impl を順に実行し、プロジェクトを初期状態にします。
---

## Your task

### 1. Explain and Confirm
- Inform the user that this will archive all project documents and reset the state.
- Ask for confirmation: "プロジェクト全体をアーカイブし、初期状態に戻します。よろしいですか？"

### 2. Execute Archive Commands
- Upon confirmation, execute the logic of `/archive:docs` and then `/archive:tmp`.

### 3. Report Final Completion
- Inform the user that the project has been fully archived and is ready for a new development cycle.i