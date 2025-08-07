---
allowed-tools: Read, Write, MultiEdit
description: 対話形式で仕様書と設計書を比較・分析し、改善案を提示して品質を高めます。状況に応じて，タスク計画書とも比較・分析します．
---

## Context
- Requirements: `.tmp/requirements.md`
- Design: `.tmp/design.md`
- Plan (optional): `.tmp/plan.md`

## Your task

### 1. Verify prerequisites
- Check that `.tmp/requirements.md` and `.tmp/design.md`, `.tmp/plan.md` exist.

### 2. Analyze and Compare
- Read and analyze the contents of the requirements, design, and plan (if it exists).
- Compare them to identify inconsistencies, gaps, ambiguities, potential risks, and suggestions for improvement.

### 3. Initiate Dialogue
- Present a summary of your findings to the user.
- Ask specific questions to clarify ambiguities and propose concrete changes to the documents.
- Example: "要件定義書では「X」が求められていますが、設計書には関連する記述がありません。追加しますか？"

### 4. Apply Refinements
- Based on the user's feedback, apply the agreed-upon changes to the documents in the `.tmp/` directory.

### 5. Conclude
- Once the user is satisfied, confirm that the specifications are of higher quality and ready for finalization.

think hard