---
description: 現在のブランチからPull Requestを作成し、関連するIssueと連携する
allowed-tools: Bash(git:*), Bash(gh pr:*), Bash(gh issue:*), Bash(npm run:*), Bash(make:*), Bash(npx:*), Bash(pnpm:*), Bash(bun:*), Glob, Grep, Read, Edit, Write, Task
disable-model-invocation: true
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
git log origin/main..HEAD --oneline
git diff origin/main --stat
```

### 5. 品質チェックの実行

PR作成前にプロジェクトの品質チェックを実行します。

#### 5.1 チェックコマンドの特定

以下のファイルを確認してチェックコマンドを特定：

- `package.json`: npm scripts（lint, test, build, check, typecheck など）
- `Makefile`: make targets
- `CLAUDE.md`: プロジェクト固有の指示
- その他設定ファイル（`.github/workflows/*.yml` など）

#### 5.2 チェックの実行

特定したチェックコマンドを実行：

```bash
# 例: Node.jsプロジェクトの場合
npm run lint
npm run typecheck
npm run test
npm run build
```

#### 5.3 エラー修正（必要に応じて）

チェックでエラーが発生した場合：

1. エラー内容を分析
2. 該当ファイルを修正
3. `/zdev:commit` でコミット
4. 再度チェックを実行
5. すべてのチェックが通過するまで繰り返す

**注意:** チェックが通過するまでPR作成に進まないこと。

### 6. リモートへのプッシュ

未プッシュの場合：
```bash
git push -u origin <current-branch>
```

### 7. PR本文の生成

以下の形式でPR本文を生成：

```markdown
## 概要
<!-- 変更内容のサマリを1-3行で記述 -->

## 関連Issue
Closes #<issue-number>

## 変更内容
<!-- コミットログや差分から主要な変更点を箇条書き -->

## テスト計画
<!-- テスト方法を記述 -->
```

### 8. PRの作成

```bash
gh pr create --base main --title "<title>" --body "<body>" [--draft]
```

タイトル形式: `[#<issue-number>] <issue-title>` または変更内容に基づいて生成

### 9. 完了メッセージ

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
