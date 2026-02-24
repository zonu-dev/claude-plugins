# zdev

Personal dev toolkit for Claude Code。

## 提供スキル

| スキル | 説明 |
|--------|------|
| `list-issues` | Issue一覧・検索 |
| `create-issue` | 新規Issue作成 |
| `plan-issue` | Issue計画・深掘り（曖昧さ解消→計画→Issue反映） |
| `start-issue` | Issueからブランチ作成・開発開始 |
| `update-issue` | Issueステータス・ラベル更新 |
| `create-pr` | Issue連携PR作成 |
| `review-pr` | PRコードレビュー（差分分析・指摘・アクション実行） |
| `end-issue` | 作業終了（PRマージ・Issueクローズ・worktree削除） |
| `commit` | セマンティックコミット作成 |
| `create-skill` | スキル作成・レビュー・自動修正 |
| `review-skill` | スキルを公式ベストプラクティスに基づいてレビュー |
| `review-rule` | ルールファイルをベストプラクティスに基づいてレビュー |
| `review-agent` | エージェント定義ファイルをベストプラクティスに基づいてレビュー |
| `review-instructions` | CLAUDE.mdをベストプラクティスに基づいてレビュー |
| `create-agent` | エージェント作成・レビュー・自動修正 |

## インストール

```bash
/plugin marketplace add zonu-dev/claude-plugins
/plugin install zdev@zonu-plugins
```

## 使用方法

### 明示的な呼び出し

```bash
/list-issues
/plan-issue 123
/start-issue 123
/commit
/create-pr
```

## 開発フロー

```
# 1. Issue一覧を確認
/list-issues

# 2. Issueの計画を立てる（曖昧さを深掘り）
/plan-issue 123

# 3. 開発開始（worktree + ブランチ作成）
/start-issue 123

# 4. 実装作業...

# 5. コミット作成
/commit

# 6. PRを作成
/create-pr

# 7. PRレビュー
/review-pr 123

# 8. 作業終了（worktree削除）
/end-issue
```

## 各スキルの詳細

### `list-issues`
```bash
/list-issues              # 自分にアサインされたIssue
/list-issues --all        # すべてのopen Issue
/list-issues --label bug  # ラベルでフィルタ
```

### `plan-issue <number>`
```bash
/plan-issue 123          # Issue #123の計画を立てる
```
- コードベースを調査して影響範囲を特定
- 曖昧な点を構造化された質問で深掘り
- 決定事項を含む実装計画を作成
- 計画をIssue本文またはコメントに反映

### `start-issue <number>`
```bash
/start-issue 123         # Issue #123の開発を開始
```
- ブランチタイプ（feature/bugfix/hotfix/release）を選択
- Git-flow準拠のブランチ名を自動生成
- git worktreeを使用して親ディレクトリにworktreeを作成
- 作成したworktreeディレクトリに自動でcd

### `create-pr`
```bash
/create-pr                # 現在のブランチからPR作成
/create-pr --draft        # ドラフトPRとして作成
```

### `review-pr <number|URL>`
```bash
/review-pr 123            # PR #123をレビュー
/review-pr https://github.com/owner/repo/pull/123
```
- コード品質・セキュリティ・パフォーマンス・テスト・設計の観点で分析
- CI/CDステータスを確認
- 構造化されたレビューレポートを生成
- Approve / Request Changes / Comment アクションを実行

### `commit`
```bash
/commit                  # セマンティックコミットを作成
/commit --no-emoji       # 絵文字なしでコミット
```
- フォーマット: `<Type>: <Emoji> #<Issue> <Title>`
- Type: feat/fix/docs/style/refactor/test/chore
- ブランチ名からIssue番号を自動抽出
- 変更内容を分析してメッセージを生成

### `end-issue`
```bash
/end-issue               # 現在のworktreeでの作業を終了
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
