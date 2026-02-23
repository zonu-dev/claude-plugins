---
description: 指定したGitHub Issueに基づいてfeatureブランチを作成し、開発コンテキストをセットアップする
allowed-tools: Bash(gh issue:*), Bash(gh repo view:*), Bash(git checkout:*), Bash(git branch:*), Bash(git pull:*), Bash(git fetch:*), AskUserQuestion, TaskCreate, TaskUpdate
disable-model-invocation: true
---

# Issue開発開始

指定したIssueに基づいてブランチを作成し、開発コンテキストをセットアップします。

## 引数

- `$ARGUMENTS` から Issue番号を取得
- `--base <branch>`: ベースブランチ（省略時はリポジトリのデフォルトブランチを使用）

## 処理手順

### 0. Issue番号の確認

Issue番号が指定されていない場合は、Issue一覧を表示して選択を促す：

```bash
gh issue list --assignee "@me" --state open --json number,title,labels --limit 10
```

一覧を表示後、ユーザーにIssue番号の入力を求める。

### 1. Issue情報の取得

```bash
gh issue view <number> --json number,title,body,labels,assignees,milestone
```

Issue情報を表示して、ユーザーに内容を確認させます。

### 2. ブランチ名の生成

featureブランチ名を生成：
- パターン: `feature/<issue-number>-<sanitized-title>`
- タイトルは小文字化し、スペースをハイフンに置換、特殊文字を除去
- 最大50文字程度に切り詰め

例: `feature/42-add-user-authentication`

### 3. ベースブランチの決定

`--base` が指定されていない場合、リポジトリのデフォルトブランチを取得：

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

### 4. ブランチの作成とチェックアウト

```bash
# 最新のベースブランチを取得
git fetch origin

# ブランチを作成してチェックアウト
git checkout -b <branch-name> origin/<base-branch>
```

### 5. ブランチ作成の検証

ブランチが正しく作成されたことを確認：

```bash
git branch --show-current
```

期待するブランチ名と一致しない場合はエラーを表示して終了。

### 6. タスクリストの作成

**TaskCreate** を使用して、Issue本文からタスクを抽出し、タスクリストを作成してください：

- Issue本文のチェックリスト項目があれば、それをタスクに変換
- なければ、Issue内容から主要なタスクを推測して作成
- 各タスクには `activeForm`（進行形）を設定する

### 7. 完了メッセージ

以下を出力：
- 作成したブランチ名
- Issue概要
- 作成したTodoリスト
- 次のステップの案内

## 出力例

```
## Issue #42 の開発を開始しました

**ブランチ:** `feature/42-add-user-authentication`

**Issue概要:**
Add user authentication using JWT tokens

**タスクリスト:**
- [ ] JWTライブラリの追加
- [ ] 認証ミドルウェアの実装
- [ ] ログインエンドポイントの作成
- [ ] テストの追加

**次のステップ:**
- 実装を開始してください
- 完了後: `/zdev:create-pr` でPRを作成
- 作業終了時: `/zdev:end-issue` でPRマージとIssueクローズ
```
