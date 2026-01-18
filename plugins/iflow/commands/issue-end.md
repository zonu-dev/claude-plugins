---
description: End working on current issue - merge PR and cleanup
allowed-tools: Bash(git branch:*), Bash(git status:*), Bash(git fetch:*), Bash(git rebase:*), Bash(git push:*), Bash(git checkout:*), Bash(git pull:*), Bash(pwd:*), Bash(gh pr:*), AskUserQuestion
---

# Issue作業終了

関連するPRのマージとブランチのクリーンアップを行います。
Issueは PRマージ時に自動的にクローズされます。

## 処理手順

### 1. 現在の状態を確認

```bash
# 現在のディレクトリを確認
pwd

# 現在のブランチを取得
git branch --show-current
```

ブランチ名からIssue番号を抽出します（例: `feature/42-xxx` → 42）。

### 2. 関連PRの確認とマージ

```bash
# 関連PRを検索
gh pr list --head <branch-name> --json number,title,state,url,mergeable,mergeStateStatus
```

PRが存在する場合：

1. PRのステータスを表示（マージ可能か、CIの状態など）

2. ベースブランチの最新を取得して同期：
   ```bash
   # ベースブランチを取得
   gh pr view <pr-number> --json baseRefName --jq '.baseRefName'

   # 最新を取得
   git fetch origin <base-branch>

   # 最新が取り込まれていない場合、rebaseを実行
   git rebase origin/<base-branch>

   # リモートにforce push
   git push --force-with-lease
   ```

3. **AskUserQuestion** でマージ方法を確認：
   ```
   質問: PRをマージしますか？

   選択肢:
   - merge: 通常のマージコミット
   - squash: すべてのコミットを1つにまとめる
   - rebase: リベースマージ
   - skip: マージしない（手動で対応）
   ```

4. マージを実行：
   ```bash
   gh pr merge <pr-number> --merge  # または --squash / --rebase
   ```

### 3. mainブランチへのチェックアウト

```bash
# mainブランチにチェックアウト
git checkout main

# 最新を取得
git pull origin main
```

### 4. ブランチの削除

```bash
# ローカルブランチを削除
git branch -d <branch-name>

# リモートブランチを削除
git push origin --delete <branch-name>
```

### 5. 完了メッセージ

以下の情報を出力：
- マージしたPR
- 削除したブランチ

## 出力例

```
## Issue #42 の作業を終了しました

**マージしたPR:** #45 - Add user authentication
**削除したブランチ:** feature/42-add-user-authentication

お疲れ様でした！
```

## 注意事項

- PRがマージできない状態（CIが失敗、コンフリクトなど）の場合は、先に問題を解決してください
- 未コミットの変更がある場合は、先にコミットまたはスタッシュすることを推奨します
