---
description: 対話的に新しいGitHub Issueを作成する
allowed-tools: Bash(gh issue create:*), Bash(gh label list:*), Bash(ls:*), AskUserQuestion
disable-model-invocation: true
---

# 新規Issue作成

対話的に新しいGitHub Issueを作成します。

## 引数

- `--title <title>`: Issueタイトル
- `--template <name>`: 使用するテンプレート名
- `--label <name>`: 付与するラベル（複数可）

## 処理手順

### 1. テンプレートの確認

```bash
ls .github/ISSUE_TEMPLATE/ 2>/dev/null || echo "テンプレートなし"
```

テンプレートが存在する場合は、使用するテンプレートを選択させます。

### 2. Issue種別の確認

**AskUserQuestion** を使用してIssue種別を確認：

```
質問: どの種類のIssueを作成しますか？

選択肢:
- Bug: バグ報告
- Feature: 新機能リクエスト
- Task: タスク・作業項目
- Documentation: ドキュメント関連
```

### 3. 利用可能なラベルの取得

```bash
gh label list --json name,description --limit 20
```

### 4. Issue内容の入力

**AskUserQuestion** を使用して以下を **1つずつ順番に** 質問：

1. **タイトル**（--titleで指定されていない場合）
2. **説明**
   - Bug: 再現手順、期待する動作、実際の動作
   - Feature: 背景、提案内容、受け入れ基準
   - Task: 詳細な作業内容
3. **ラベル**（選択式）
4. **アサイン先**（任意）

### 5. Issueの作成

```bash
gh issue create \
  --title "<title>" \
  --body "<body>" \
  --label "<labels>" \
  --assignee "<assignee>"
```

### 6. 完了メッセージ

以下を出力：
- 作成されたIssue URL
- Issue番号
- `/zdev:implement-issue` で開発開始を促すメッセージ

## Issue本文テンプレート

### Bug
```markdown
## 概要
<!-- バグの簡潔な説明 -->

## 再現手順
1.
2.
3.

## 期待する動作
<!-- 本来どう動くべきか -->

## 実際の動作
<!-- 現在どう動いているか -->

## 環境
- OS:
- バージョン:
```

### Feature
```markdown
## 背景
<!-- なぜこの機能が必要か -->

## 提案内容
<!-- 何を実装したいか -->

## 受け入れ基準
- [ ]
- [ ]

## 追加情報
<!-- 参考情報など -->
```

### Task
```markdown
## 概要
<!-- タスクの説明 -->

## 作業内容
- [ ]
- [ ]

## 完了条件
<!-- どうなったら完了か -->
```

## 出力例

```
## Issue を作成しました

**Issue:** #43 - Add password reset functionality
**URL:** https://github.com/owner/repo/issues/43
**ラベル:** enhancement, auth

**次のステップ:**
- 開発を開始: `/zdev:implement-issue 43`
- Issueを分析: `/zdev:plan-issue 43`
```
