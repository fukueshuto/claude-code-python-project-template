---
allowed-tools: Read, Bash
description: (新規) 新しく実装作業を行う前に，.dev_docs 内の.dev_docs/archive/*以外のファイルを.dev_docs/archive/<requirement-name>/ に移動します。<requirement-name>がかぶる場合は両フォルダ名を被らないように修正します．
---

## Your task

### 1. Check for files to archive
- Check for any files in `.dev_docs/` (excluding `.dev_docs/archive/`).

### 2. Determine archive name
- Create a descriptive archive folder name from `.dev_docs/specs/requirements.md` or a timestamp.
- Handle name conflicts.

### 3. Execute Archive
- Move all relevant files/directories from `.dev_docs/` into the new archive directory within `.dev_docs/archive/`.

### 4. Report Completion
- Inform the user that the implementation-related documents have been archived.