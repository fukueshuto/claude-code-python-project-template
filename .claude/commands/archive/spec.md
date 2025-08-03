---
allowed-tools: Read, Bash
description: (新規) 新しく仕様策定を行う前に.tmp 内の.tmp/archive/*以外のファイルを .tmp/archive/<requirement-name>に退避させ、作業場をクリーンにします。<requirement-name>がかぶる場合は両フォルダ名を被らないように修正します．
---

## Your task

### 1. Check for files to archive
- Check for any files in `.tmp/` (excluding `.tmp/archive/`).

### 2. Determine archive name
- Create a descriptive archive folder name from `.tmp/requirements.md` or a timestamp.
- Handle name conflicts by appending a suffix.

### 3. Execute Archive
- Move all relevant files from `.tmp/` into the new archive directory within `.tmp/archive/`.

### 4. Report Completion
- Inform the user that the temporary files have been archived and the workspace is clean.
