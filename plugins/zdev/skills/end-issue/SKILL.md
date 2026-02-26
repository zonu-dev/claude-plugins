---
name: end-issue
description: 現在のIssue作業を終了し、PRのSquashマージとブランチのクリーンアップを行う
allowed-tools: Bash(git branch:*), Bash(git status:*), Bash(git fetch:*), Bash(git rebase:*), Bash(git push:*), Bash(git checkout:*), Bash(git pull:*), Bash(pwd:*), Bash(gh pr:*), AskUserQuestion
disable-model-invocation: true
---

# Issue作業終了

関連するPRのマージとブランチのクリーンアップを行います。
Issueは PRマージ時に自動的にクローズされます。

## 処理手順

### 0. 前提条件の確認

`gh` CLI がインストール・認証済みか確認する:

```bash
gh auth status
```

失敗した場合は以下を案内して終了:

> `gh` CLI のインストールと認証が必要です。
> - インストール: https://cli.github.com/
> - 認証: `gh auth login`

### 1. 現在の状態を確認

```bash
# 現在のディレクトリを確認
pwd

# 現在のブランチを取得
git branch --show-current
```

ブランチ名からIssue番号を抽出します（例: `feature/42-xxx` → 42）。

### 2. 関連PRの検索

```bash
# 関連PRを検索
gh pr list --head <branch-name> --json number,title,state,url,mergeable,mergeStateStatus
```

PRが存在しない場合はエラーを表示して終了します。

### 3. ベースブランチとの同期（必須）

**マージ前に必ずこのステップを実行すること。スキップ厳禁。**

現在のブランチがPRのブランチでない場合は、先にチェックアウトします：

```bash
gh pr checkout <pr-number>
```

ベースブランチの最新を取り込み、rebaseします：

```bash
# ベースブランチを取得
gh pr view <pr-number> --json baseRefName --jq '.baseRefName'

# 最新を取得
git fetch origin <base-branch>

# rebaseを実行（差分がなくても必ず実行する）
git rebase origin/<base-branch>

# コンフリクトが発生した場合は解決してから続行

# リモートにforce push（実行前にユーザー確認を取る）
```

**AskUserQuestion** で確認：
```
質問: rebase後にforce pushを実行します。よろしいですか？
選択肢:
- 実行する: force-with-leaseで安全にpush
- キャンセル: pushせずに終了
```

承認された場合のみ実行：
```bash
git push --force-with-lease
```

### 4. CIの通過を確認（必須）

rebase後にforce pushするとCIが再実行されます。**CIが全てパスするまでマージに進まないこと。**

```bash
gh pr checks <pr-number> --watch
```

CIが失敗した場合は修正してから再度pushします。

### 5. Squashマージの実行

PRのコミット一覧を取得し、Squashマージを実行します：

```bash
# コミット一覧を取得
gh pr view <pr-number> --json commits --jq '.commits[].messageHeadline'
```

PRタイトルをそのままコミットタイトルとして使用し、本文にコミット一覧を含めます。

```bash
gh pr merge <pr-number> --squash --subject "<PRタイトル>" --body "$(cat <<'EOF'
- <コミット1のメッセージ>
- <コミット2のメッセージ>
- <コミット3のメッセージ>
EOF
)"
```

**コミットメッセージの例:**
```
<PRタイトル>

- <コミット1のメッセージ>
- <コミット2のメッセージ>
- <コミット3のメッセージ>
```

プロジェクトのコミット規約に従ってフォーマットしてください。

### 6. ベースブランチへのチェックアウト

ステップ3で取得したベースブランチに戻ります：

```bash
# ベースブランチにチェックアウト
git checkout <base-branch>

# 最新を取得
git pull origin <base-branch>
```

### 7. ブランチの削除

```bash
# ローカルブランチを削除
git branch -d <branch-name>

# リモートブランチを削除
git push origin --delete <branch-name>
```

### 8. 完了メッセージ

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
