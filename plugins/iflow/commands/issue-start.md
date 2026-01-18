---
description: Start working on a GitHub issue - creates branch and sets up context
allowed-tools: Bash(gh issue:*), Bash(git checkout:*), Bash(git branch:*), Bash(git pull:*), Bash(git fetch:*), AskUserQuestion, TodoWrite
---

# Issue開発開始

指定したIssueに基づいてブランチを作成し、開発コンテキストをセットアップします。

## 引数

- `$ARGUMENTS` から Issue番号を取得
- `--base <branch>`: ベースブランチ（デフォルト: develop）

## 処理手順

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

### 3. ブランチの作成とチェックアウト

```bash
# 最新のベースブランチを取得
git fetch origin

# ブランチを作成してチェックアウト
git checkout -b <branch-name> origin/<base-branch>
```

### 4. Todoリストの作成

**TodoWrite** を使用して、Issue本文からタスクを抽出し、Todoリストを作成してください：

- Issue本文のチェックリスト項目があれば、それをTodoに変換
- なければ、Issue内容から主要なタスクを推測して作成

### 5. 完了メッセージ

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

**Todoリスト:**
- [ ] JWTライブラリの追加
- [ ] 認証ミドルウェアの実装
- [ ] ログインエンドポイントの作成
- [ ] テストの追加

**次のステップ:**
- 実装を開始してください
- 完了後: `/issue-pr` でPRを作成
- 作業終了時: `/issue-end` でPRマージとIssueクローズ
```
