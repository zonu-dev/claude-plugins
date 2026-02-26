---
name: update-issue
description: GitHub Issueのステータス、ラベル、アサインなどを更新する
allowed-tools: Bash(gh issue edit:*), Bash(gh issue close:*), Bash(gh issue reopen:*), Bash(gh issue comment:*), Bash(gh issue view:*), AskUserQuestion
disable-model-invocation: true
---

# Issue更新

Issueのステータス、ラベル、アサインなどを更新します。

## 引数

- `<issue_number>`: 更新するIssue番号（必須）
- `--status <open|closed>`: ステータス変更
- `--add-label <name>`: ラベル追加
- `--remove-label <name>`: ラベル削除
- `--assign <login>`: アサイン追加
- `--unassign <login>`: アサイン削除
- `--comment <text>`: コメント追加
- `--title <title>`: タイトル変更
- `--milestone <name>`: マイルストーン設定

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

### 1. 現在のIssue状態を取得

```bash
gh issue view <number> --json number,title,state,labels,assignees,milestone
```

現在の状態を表示して確認。

### 2. 引数の解析と実行

指定された操作を順番に実行：

#### ステータス変更

**クローズ・再オープンは実行前に AskUserQuestion で確認する：**

```
質問: Issue #<number> を <close/reopen> します。よろしいですか？
選択肢:
- 実行する: ステータスを変更
- キャンセル: 変更せずに終了
```

承認された場合のみ実行：
```bash
# クローズ
gh issue close <number>

# 再オープン
gh issue reopen <number>
```

#### ラベル操作
```bash
# ラベル追加
gh issue edit <number> --add-label "<label>"

# ラベル削除
gh issue edit <number> --remove-label "<label>"
```

#### アサイン操作
```bash
# アサイン追加
gh issue edit <number> --add-assignee "<login>"

# アサイン削除
gh issue edit <number> --remove-assignee "<login>"
```

#### その他の編集
```bash
# タイトル変更
gh issue edit <number> --title "<title>"

# マイルストーン設定
gh issue edit <number> --milestone "<milestone>"
```

#### コメント追加
```bash
gh issue comment <number> --body "<text>"
```

### 3. 更新後の状態を確認

```bash
gh issue view <number> --json number,title,state,labels,assignees,milestone
```

### 4. 完了メッセージ

変更前後の差分を表示：

```
## Issue #42 を更新しました

**変更内容:**
- ステータス: open → closed
- ラベル追加: done
- コメント追加: "実装完了しました"

**現在の状態:**
- ステータス: closed
- ラベル: enhancement, done
- アサイン: @user
```

## 使用例

```bash
# Issueをクローズ
/zdev:update-issue 42 --status closed

# ラベルを追加
/zdev:update-issue 42 --add-label "in-progress"

# コメントを追加
/zdev:update-issue 42 --comment "作業開始しました"

# 複合操作
/zdev:update-issue 42 --status closed --add-label "done" --comment "完了"
```
