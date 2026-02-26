---
name: implement-issue
description: plan-issue で計画済みの GitHub Issue を受け取り、ブランチ作成・実装・検証・コミットまで一気通貫で実行する。
allowed-tools: Bash, Glob, Grep, Read, Edit, Write, Task, AskUserQuestion, TaskCreate, TaskUpdate, TaskList
disable-model-invocation: true
---

# Issue 実装

plan-issue で計画済みの GitHub Issue を受け取り、ブランチ作成から実装・検証・コミットまでを一気通貫で実行します。

## 引数

`$ARGUMENTS` を以下のルールで解析する：
- 数値部分 → Issue 番号
- `--base <branch>` → ベースブランチ（省略時はデフォルトブランチ）

例:
- `42` → Issue #42, ベースはデフォルトブランチ
- `42 --base develop` → Issue #42, ベースは develop

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

### 1. Issue 番号の確認

Issue 番号が指定されていない場合は、Issue 一覧を表示して選択を促す：

```bash
gh issue list --assignee "@me" --state open --json number,title,labels --limit 10
```

一覧を表示後、**AskUserQuestion** でユーザーに Issue 番号の入力を求める。

### 2. Issue 情報の取得と実装計画の抽出

```bash
gh issue view <number> --json number,title,body,labels,assignees,milestone
```

取得した Issue 本文から **"## 実装計画"** セクション（Implementation Plan）を探す。

以下のいずれかに該当する場合は、計画が存在するとみなす：
- `## 実装計画` セクションがある
- `### 実装ステップ` セクションがある

**計画が見つからない場合：**

> この Issue にはまだ実装計画がありません。
> 先に `/zdev:plan-issue <number>` を実行して計画を作成してください。

と案内して **処理を終了** する。

**計画が見つかった場合：**

以下の情報を抽出する：
- **要件サマリ**: 主要目標と技術的制約
- **受け入れ基準**: チェックリスト
- **影響範囲**: 変更対象のファイル一覧
- **実装ステップ**: 順序付きのステップ
- **リスク・考慮事項**: 注意点

### 3. ブランチの作成

#### 3a. ベースブランチの決定

`--base` が指定されていない場合、リポジトリのデフォルトブランチを取得：

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

#### 3b. ブランチ名の生成

feature ブランチ名を生成：
- パターン: `feature/<issue-number>-<sanitized-title>`
- タイトルは小文字化し、スペースをハイフンに置換、特殊文字を除去
- 最大50文字程度に切り詰め

例: `feature/42-add-user-authentication`

#### 3c. ブランチの作成とチェックアウト

```bash
# 最新のベースブランチを取得
git fetch origin

# ブランチを作成してチェックアウト
git checkout -b <branch-name> origin/<base-branch>
```

#### 3d. ブランチ作成の検証

```bash
git branch --show-current
```

期待するブランチ名と一致しない場合はエラーを表示して終了。

### 4. タスクリストの作成

**TaskCreate** を使用して、実装計画の「実装ステップ」からタスクを生成する。

タスク生成ルール：
- 実装ステップの各項目を1タスクにする
- 受け入れ基準の検証を最後のタスクに含める
- 各タスクには `activeForm`（進行形）を設定する
- タスクの description には関連ファイルや詳細を含める

例：
```
TaskCreate:
  subject: "JWTユーティリティを作成する"
  description: "トークン生成・検証関数を実装する。関連ファイル: src/utils/jwt.ts"
  activeForm: "JWTユーティリティを作成中"
```

### 5. 実装

タスクリストを **上から順番に** 実行する。各タスクで以下のサイクルを回す：

#### 5a. タスク開始

```
TaskUpdate: status → in_progress
```

#### 5b. コードベース調査

- **Glob** / **Grep** / **Read** を使用して関連コードを調査
- 既存のパターンや規約を把握する
- 必要に応じて **Task**（Explore エージェント）で深い調査を行う

#### 5c. 実装

- **Edit** / **Write** を使用してコードを変更
- 既存のコーディングスタイルと規約に従う
- 小さな単位で変更を積み重ねる

#### 5d. 動作確認

変更が期待通りに動くことを確認する：
- 関連するテストがあれば実行
- 型チェックが通ることを確認
- 明らかなエラーがないことを確認

#### 5e. 判断が必要な場合

実装中に計画にない判断が必要になった場合は、**AskUserQuestion** でユーザーに確認する。

#### 5f. タスク完了

```
TaskUpdate: status → completed
```

次のタスクに進む。

### 6. 検証

すべてのタスクが完了したら、プロジェクト全体の品質チェックを実行する。

#### 6a. チェックコマンドの特定

以下の順序でチェックコマンドを探す：

1. **CLAUDE.md** にチェックコマンドの記載があるか確認
2. **package.json** の scripts を確認（lint, typecheck, test, build）
3. **Makefile** / **Taskfile** / **justfile** などを確認

#### 6b. チェックの実行

見つかったチェックコマンドを順番に実行：

```bash
# 例（プロジェクトに応じて変わる）
npm run lint
npm run typecheck
npm run test
npm run build
```

#### 6c. 失敗時の修正

チェックが失敗した場合：
1. エラー内容を分析
2. 該当コードを修正
3. 再度チェックを実行
4. すべてパスするまでループ

### 7. コミット

すべてのチェックがパスしたら、変更をコミットする。

#### 7a. 変更の確認

```bash
git status
git diff --stat
```

#### 7b. セマンティックコミットの作成

コミットメッセージを生成する：

- フォーマット: `<Type>: <Emoji> #<Issue> <Title>`
- Type と Emoji のマッピング:
  - feat: ✨ / fix: 🐛 / refactor: ♻️ / test: ✅ / docs: 📝 / chore: 🔧
- 変更が大きい場合は論理的な単位で複数コミットに分割

```bash
git add <files>
git commit -m "<commit-message>"
```

### 8. 完了報告

以下を出力する：

```
## Issue #<number> の実装が完了しました

**ブランチ:** `feature/<number>-<title>`

**実装サマリ:**
- <実装した内容の箇条書き>

**検証結果:**
- lint: PASS
- typecheck: PASS
- test: PASS
- build: PASS

**コミット:**
- <commit-hash> <commit-message>

**次のステップ:**
- PRを作成: `/zdev:create-pr`
```

## エラーハンドリング

- **Issue が見つからない場合**: Issue 番号を再確認するよう案内
- **ブランチが既に存在する場合**: 既存ブランチにチェックアウトするか確認
- **実装計画がない場合**: `/zdev:plan-issue` の実行を案内して終了
- **チェックが繰り返し失敗する場合**: 3回修正しても解決しない場合はユーザーに相談
