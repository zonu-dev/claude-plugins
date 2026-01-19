---
description: List and search GitHub issues with filtering options
allowed-tools: Bash(gh issue list:*), Bash(gh issue view:*)
---

# Issue一覧・検索

GitHub Issueの一覧を表示し、フィルタリングや検索を行います。

## 引数の解析

引数 `$ARGUMENTS` を解析して、以下のオプションを判定してください：

- `--mine` または引数なし: 自分にアサインされたIssueのみ表示（デフォルト）
- `--all`: すべてのopen Issueを表示
- `--label <name>`: 指定したラベルでフィルタ
- `--search <query>`: フリーテキスト検索
- `--state <open|closed|all>`: 状態でフィルタ（デフォルト: open）

## 処理手順

1. **引数の解析**
   - 引数がない場合は `--assignee "@me" --state open` をデフォルトとする

2. **Issue一覧の取得**
   ```bash
   gh issue list --json number,title,state,labels,assignees,updatedAt --limit 30 [オプション]
   ```

3. **一覧の整形出力**
   以下の形式でテーブル表示：
   ```
   | # | Title | Labels | Assignees | Updated |
   |---|-------|--------|-----------|---------|
   ```

4. **次のアクション提案**
   一覧表示後、以下を案内：
   - 特定のIssueの詳細を見る: `gh issue view <number>`
   - Issueの開発を開始する: `/iflow:issue-start <number>`
   - Issueを分析する: `/iflow:issue-plan <number>`

## 出力例

```
## GitHub Issues

| # | Title | Labels | Assignees | Updated |
|---|-------|--------|-----------|---------|
| 42 | Add user authentication | enhancement | @user | 2024-01-15 |
| 38 | Fix login error | bug, urgent | @user | 2024-01-14 |

**次のステップ:**
- Issue詳細を確認: `gh issue view <number>`
- 開発を開始: `/iflow:issue-start <number>`
- Issueを分析: `/iflow:issue-plan <number>`
```
