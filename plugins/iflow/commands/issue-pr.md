---
description: Create a pull request linked to the current issue
argument-hint: "[--issue <number>] [--draft]"
allowed-tools: Bash(gh pr create:*), Bash(gh issue view:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(git status:*), Bash(git branch:*)
---

# Issue連携PR作成

現在のブランチからPull Requestを作成し、関連するIssueと連携します。

## 引数

- `--issue <number>`: 連携するIssue番号（省略時はブランチ名から推測）
- `--draft`: ドラフトPRとして作成

## 処理手順

### 1. 現在のブランチ状態を確認

```bash
git status
git branch --show-current
```

### 2. Issue番号の特定

以下の順序でIssue番号を特定：
1. `--issue` 引数が指定されていればそれを使用
2. ブランチ名から抽出（例: `feature/42-add-auth` → 42）

### 3. Issue情報の取得

```bash
gh issue view <number> --json number,title,body,labels
```

### 4. 変更内容の確認

```bash
git log origin/develop..HEAD --oneline
git diff origin/develop --stat
```

### 5. リモートへのプッシュ

未プッシュの場合：
```bash
git push -u origin <current-branch>
```

### 6. PR本文の生成

以下の形式でPR本文を生成：

```markdown
## Summary
<!-- 変更内容のサマリを1-3行で記述 -->

## Related Issue
Closes #<issue-number>

## Changes
<!-- コミットログや差分から主要な変更点を箇条書き -->

## Test Plan
<!-- テスト方法を記述 -->
```

### 7. PRの作成

```bash
gh pr create --title "<title>" --body "<body>" [--draft]
```

タイトル形式: `[#<issue-number>] <issue-title>` または変更内容に基づいて生成

### 8. 完了メッセージ

以下を出力：
- PR URL
- 連携したIssue番号
- レビュー依頼の案内

## 出力例

```
## Pull Request を作成しました

**PR:** https://github.com/owner/repo/pull/123
**連携Issue:** #42 - Add user authentication

**次のステップ:**
- レビュアーをアサインしてください
- CIが通ることを確認してください
- Issueは PR マージ時に自動的にクローズされます
```

## 注意事項

- コミットがない場合はエラーを表示
- ベースブランチとの差分がない場合は警告
- 既存のPRがある場合はその旨を表示
