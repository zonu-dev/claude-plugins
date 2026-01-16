# gh-issue-workflow

GitHub Issuesベースの開発ワークフローを支援するClaude Code Skillsプラグイン。

## 提供コマンド

| コマンド | 説明 |
|---------|------|
| `/issue-list` | Issue一覧・検索 |
| `/issue-start` | Issueからブランチ作成・開発開始 |
| `/issue-create` | 新規Issue作成 |
| `/issue-update` | Issueステータス・ラベル更新 |
| `/issue-analyze` | Issue分析・実装方針提案 |
| `/issue-pr` | Issue連携PR作成 |

## インストール

```bash
/plugin marketplace add zonu-dev/claude-plugins
/plugin install gh-issue-workflow@claude-plugins
```

## 使用例

### 開発フロー

```
# 1. Issue一覧を確認
/issue-list

# 2. Issueを分析して実装方針を立てる
/issue-analyze 123

# 3. 開発開始（ブランチ作成）
/issue-start 123

# 4. 実装作業...

# 5. PRを作成
/issue-pr
```

### 各コマンドの詳細

#### `/issue-list`
```bash
/issue-list              # 自分にアサインされたIssue
/issue-list --all        # すべてのopen Issue
/issue-list --label bug  # ラベルでフィルタ
```

#### `/issue-start <number>`
```bash
/issue-start 123         # Issue #123の開発を開始
```
- ブランチタイプ（feature/bugfix/hotfix/release）を選択
- Git-flow準拠のブランチ名を自動生成

#### `/issue-pr`
```bash
/issue-pr                # 現在のブランチからPR作成
/issue-pr --draft        # ドラフトPRとして作成
```

## 前提条件

- `gh` CLI がインストール済み
- `gh auth login` で認証済み
- GitHubリポジトリで作業中
