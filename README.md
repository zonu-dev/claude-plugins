# Claude Plugins

My personal Claude Code plugins.

## Installation

```bash
/plugin marketplace add zonu-dev/claude-plugins
```

## Available Plugins

### zdev

Personal dev toolkit for Claude Code。

```bash
/plugin install zdev@zonu-plugins
```

#### Commands

| Command | Description |
|---------|-------------|
| `/issue-list` | Issue一覧・検索 |
| `/issue-start <number>` | Issueからブランチ作成・開発開始（Git-flow準拠） |
| `/issue-create` | 新規Issue作成（対話式） |
| `/issue-update <number>` | Issueステータス・ラベル更新 |
| `/issue-analyze <number>` | Issue分析・実装方針提案 |
| `/issue-pr` | Issue連携PR作成 |

#### Workflow

```
/issue-list → /issue-analyze → /issue-start → (実装) → /issue-pr
```

#### Requirements

- `gh` CLI installed
- `gh auth login` authenticated
- Working in a GitHub repository
