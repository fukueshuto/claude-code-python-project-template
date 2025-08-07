---
allowed-tools: Read, Write, Bash
description: 仕様策定フェーズの成果物 (.tmp/*.md) を .dev_docs/specs/ に移動し、仕様を確定します。
---

## Context
- Draft specifications: `.tmp/requirements.md`, `.tmp/design.md`, `.tmp/plan.md`

## Your task

### 1. Verify prerequisites
- Check for specification files in the `.tmp/` directory. If none exist, inform the user.

### 2. Confirm with User
- Ask for final confirmation to lock in the current specifications.
- "現在の仕様書（要件、設計、計画）を確定します。よろしいですか？"

### 3. Execute Finalization
- Upon confirmation, perform the following:
  ```bash
  mkdir -p .dev_docs/specs
  mv .tmp/requirements.md .dev_docs/specs/
  mv .tmp/design.md .dev_docs/specs/
  mv .tmp/plan.md .dev_docs/specs/
  ```

### 4. Report Completion
- Inform the user that specifications are finalized in `.dev_docs/specs/`.
- Advise that the next step is `/decompose-tasks`.
