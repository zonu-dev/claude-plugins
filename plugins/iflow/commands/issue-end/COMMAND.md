---
description: End working on current issue - merge PR, close issue, and remove worktree
allowed-tools: Bash(git worktree:*), Bash(git branch:*), Bash(git status:*), Bash(git fetch:*), Bash(git rebase:*), Bash(git push:*), Bash(cd:*), Bash(pwd:*), Bash(gh pr:*), Bash(gh issue:*), AskUserQuestion
---

# Issue作業終了

issue-startで作成したworktreeを削除し、関連するPRのマージとIssueのクローズを行います。

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

### 3. Issueのクローズ

```bash
# Issue状態を確認
gh issue view <issue-number> --json state,title
```

**AskUserQuestion** でクローズするか確認：
```
質問: Issue #<number> をクローズしますか？

選択肢:
- close: Issueをクローズする
- skip: クローズしない（手動で対応）
```

クローズする場合：
```bash
gh issue close <issue-number>
```

### 4. メインリポジトリに移動

```bash
# worktree一覧からメインリポジトリのパスを特定
git worktree list
```

メインリポジトリ（bare: no または (bare) でないもの）のパスを特定し、移動します。

```bash
cd <main-repo-path>
```

### 5. worktreeの削除

```bash
# 未コミットの変更を確認
git -C <worktree-path> status --porcelain
```

未コミットの変更がある場合は警告を表示し、**AskUserQuestion** で続行するか確認します。

```bash
# worktreeを削除
git worktree remove <worktree-path>
```

### 6. ブランチ削除の確認

**AskUserQuestion** でローカルブランチも削除するか確認：
```
質問: ローカルブランチ '<branch-name>' も削除しますか？

選択肢:
- delete: ブランチを削除する
- keep: ブランチを残す
```

削除する場合：
```bash
git branch -d <branch-name>
```

マージされていない場合は警告を表示し、強制削除するか確認します。

### 7. 完了メッセージ

以下の情報を出力：
- マージしたPR（ある場合）
- クローズしたIssue（ある場合）
- 削除したworktreeのパス
- 削除したブランチ（ある場合）
- 現在のディレクトリ

## 出力例

```
## Issue #42 の作業を終了しました

**マージしたPR:** #45 - Add user authentication
**クローズしたIssue:** #42 - Add user authentication using JWT
**削除したWorktree:** ../feature/42-add-user-authentication
**削除したブランチ:** feature/42-add-user-authentication

**現在のディレクトリ:** /path/to/main-repo

お疲れ様でした！
```

## 注意事項

- worktree内で実行する必要があります
- PRがマージできない状態（CIが失敗、コンフリクトなど）の場合は、先に問題を解決してください
- 未コミットの変更がある場合は、先にコミットまたはスタッシュすることを推奨します
