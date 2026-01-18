# iflow

GitHub Issuesベースの開発ワークフローを支援するClaude Codeプラグイン。

## 提供スキル

| スキル | 説明 |
|--------|------|
| `issue-list` | Issue一覧・検索 |
| `issue-create` | 新規Issue作成 |
| `issue-plan` | Issue計画・深掘り（曖昧さ解消→計画→Issue反映） |
| `issue-start` | Issueからブランチ作成・開発開始 |
| `issue-update` | Issueステータス・ラベル更新 |
| `issue-pr` | Issue連携PR作成 |
| `issue-end` | 作業終了（PRマージ・Issueクローズ・worktree削除） |
| `commit` | セマンティックコミット作成 |

## インストール

```bash
/plugin marketplace add zonu-dev/claude-plugins
/plugin install iflow@zonu-plugins
```

## 使用方法

### 明示的な呼び出し

```bash
/issue-list
/issue-plan 123
/issue-start 123
/commit
/issue-pr
```

### 自然言語での呼び出し

Claudeが自動的に適切なスキルを判断して実行します：

```
「自分にアサインされたIssueを見せて」
「Issue 123の計画を立てて」
「Issue 123の開発を始めたい」
「PRを作成して」
```

## 開発フロー

```
# 1. Issue一覧を確認
/issue-list

# 2. Issueの計画を立てる（曖昧さを深掘り）
/issue-plan 123

# 3. 開発開始（worktree + ブランチ作成）
/issue-start 123

# 4. 実装作業...

# 5. コミット作成
/commit

# 6. PRを作成
/issue-pr

# 7. 作業終了（worktree削除）
/issue-end
```

## 各スキルの詳細

### `issue-list`
```bash
/issue-list              # 自分にアサインされたIssue
/issue-list --all        # すべてのopen Issue
/issue-list --label bug  # ラベルでフィルタ
```

### `issue-plan <number>`
```bash
/issue-plan 123          # Issue #123の計画を立てる
```
- コードベースを調査して影響範囲を特定
- 曖昧な点を構造化された質問で深掘り
- 決定事項を含む実装計画を作成
- 計画をIssue本文またはコメントに反映

### `issue-start <number>`
```bash
/issue-start 123         # Issue #123の開発を開始
```
- ブランチタイプ（feature/bugfix/hotfix/release）を選択
- Git-flow準拠のブランチ名を自動生成
- git worktreeを使用して親ディレクトリにworktreeを作成
- 作成したworktreeディレクトリに自動でcd

### `issue-pr`
```bash
/issue-pr                # 現在のブランチからPR作成
/issue-pr --draft        # ドラフトPRとして作成
```

### `commit`
```bash
/commit                  # セマンティックコミットを作成
/commit --no-emoji       # 絵文字なしでコミット
```
- フォーマット: `<Type>: <Emoji> #<Issue> <Title>`
- Type: feat/fix/docs/style/refactor/test/chore
- ブランチ名からIssue番号を自動抽出
- 変更内容を分析してメッセージを生成

### `issue-end`
```bash
/issue-end               # 現在のworktreeでの作業を終了
```
- 関連PRをマージ（merge/squash/rebase選択可能）
- 関連Issueをクローズ
- worktreeを削除
- メインリポジトリに自動でcd
- ローカルブランチの削除（オプション）

## 前提条件

- `gh` CLI がインストール済み
- `gh auth login` で認証済み
- GitHubリポジトリで作業中
