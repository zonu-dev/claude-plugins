---
name: create-pr-slide
description: "PR の変更内容を視覚的に解説するスライドを生成し、PDF を PR ブランチにコミットして PR コメントにリンクを投稿する。"
allowed-tools: Bash(gh:*), Bash(git:*), Bash(npx:*), Bash(mkdir:*), Read, AskUserQuestion, Skill
argument-hint: "[PR番号]"
disable-model-invocation: true
---

# PR 解説スライド生成

PR の変更内容（diff・コミット履歴・メタデータ）を収集し、`create-slide` の解説型ワークフローで視覚的なスライドを生成する。
完成した PDF を PR ブランチにコミットし、PR コメントにリンクを投稿する。

## 引数

```
/create-pr-slide [PR番号] [--base <branch>]
```

- `PR番号`: 省略時は現在ブランチの PR を自動検出する
- `--base <branch>`: create-slide 実行時のベースブランチ（省略時はデフォルトブランチ）

例:

```
/create-pr-slide 42
/create-pr-slide
/create-pr-slide 42 --base develop
```

## 前提条件

- `gh` CLI がインストール・認証済みであること
- `create-slide` スキルが利用可能であること
- Node.js がインストール済みであること（marp-cli の実行に必要）
- 対象の PR がオープン状態であること

## ワークフロー

### Phase 1: PR 情報を収集する

#### 1a. PR 番号を確定する

以下の優先順位で PR 番号を決定する:

1. 引数で指定された番号を使う
2. 引数がない場合、現在ブランチの PR を自動検出する:
   ```bash
   gh pr view --json number --jq '.number'
   ```
3. 自動検出できない場合、AskUserQuestion でユーザーに確認する

#### 1b. PR メタデータを取得する

```bash
gh pr view <number> --json number,title,body,labels,baseRefName,headRefName,additions,deletions,changedFiles,commits,files,url
```

以下の情報を抽出する:
- タイトルと説明
- ベースブランチ / ヘッドブランチ
- 追加行数 / 削除行数 / 変更ファイル数
- ラベル

#### 1c. コード diff を取得する

`slides/` 配下のファイル（スライド本体・テーマ CSS・生成画像等）は解説対象ではないため、diff から除外する。

```bash
gh pr diff <number> | grep -v '^diff --git a/slides/' | awk '/^diff --git/{show=1} /^diff --git a\/slides\//{show=0} show'
```

> 上記のフィルタが複雑な場合は、`gh pr diff <number>` の出力から `slides/` で始まるファイルの差分セクションを無視して読めばよい。

diff が非常に大きい場合（5000 行超）は、変更ファイル一覧と統計情報に要約する:

```bash
gh pr diff <number> --stat | grep -v ' slides/'
```

その上で、主要な変更ファイル（追加/削除行数が多い上位ファイル）の diff のみを個別に取得する。

#### 1d. コミット履歴を取得する

```bash
gh pr view <number> --json commits --jq '.commits[] | "\(.oid[0:7]) \(.messageHeadline)"'
```

#### 1e. 変更パッケージ・ディレクトリを特定する

変更ファイルのパスから、影響を受けるパッケージやディレクトリを特定する（`slides/` 配下は除外）:

```bash
gh pr view <number> --json files --jq '.files[].path | select(startswith("slides/") | not)'
```

パスのプレフィックス（例: `packages/core/`, `backend/api/`）でグルーピングし、変更の全体像を把握する。

### Phase 2: create-slide を呼び出す

#### 2a. ブリーフを構成する

[references/pr-brief-template.md](references/pr-brief-template.md) に従い、Phase 1 で収集した情報を構造化したブリーフを作成する。

ブリーフには以下を含める:
- PR の概要（タイトル・目的・背景）
- 変更の統計（ファイル数・追加/削除行数）
- 変更パッケージ/ディレクトリの一覧と各々の役割
- 主要な変更内容のサマリ（コミット履歴ベース）
- コード diff のハイライト（重要な変更箇所）

#### 2b. create-slide をプリフィル値付きで呼び出す

Skill ツールで `create-slide` を呼び出す。引数にブリーフ全文を渡す:

```
Skill: create-slide
Args: <ブリーフ全文>
```

以下のプリフィル値を指示に含める:
- **対象者**: PR レビュワー（エンジニア中級-上級）
- **ストーリー型**: 解説型
- **ゴール**: 理解（PR の変更内容を理解する）
- **ファイル名**: `pr-<number>-<sanitized-title>.md`
- **想定ページ数**: 10-20 ページ（diff の規模に応じて調整）
- **計画の承認をスキップ**: create-pr-slide から全パラメータが確定済みのため、create-slide のステップ 2 の計画提示・ユーザー承認を省略し、即座にステップ 3（スライド作成）に進む

> create-slide がスライド作成・品質チェック・レビューまで一貫して実行する。
> create-slide のワークフロー完了を待ってから Phase 3 に進む。

### Phase 3: PDF 変換とコミット

#### 3a. PDF を生成する

```bash
npx @marp-team/marp-cli --no-config-file --allow-local-files --pdf "slides/<ファイル名>.md" -o "slides/dist/<ファイル名>.pdf" < /dev/null
```

`slides/dist/` ディレクトリがない場合は作成する:

```bash
mkdir -p slides/dist
```

PDF ファイルが正常に生成されたことを確認する。marp-cli が失敗した場合はエラー内容をユーザーに報告し、処理を中断する。

#### 3b. PDF を PR ブランチにコミットする

```bash
git add "slides/<ファイル名>.md" "slides/dist/<ファイル名>.pdf"
git commit -m "docs: 📝 PR #<number> 解説スライドを追加"
```

スライド作成過程で追加されたファイル（テーマ CSS、スクリプト等）があれば含める（存在しないファイルは無視）:

```bash
git add slides/themes/ scripts/marp-export-png.sh .marprc.yml .vscode/settings.json 2>/dev/null
```

#### 3c. リモートにプッシュする

```bash
git push origin HEAD
```

### Phase 4: PR コメントを投稿する

#### 4a. PDF リンクを構築する

GitHub の PDF ビューアーで閲覧できるリンクを構築する:

```
https://github.com/<owner>/<repo>/blob/<head-branch>/slides/dist/<ファイル名>.pdf
```

owner/repo は以下で取得:

```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

#### 4b. PR コメントを投稿する

[references/pr-comment-template.md](references/pr-comment-template.md) のテンプレートに沿ってコメントを構成し、投稿する:

```bash
gh pr comment <number> --body "<コメント本文>"
```

### 完了報告

以下を出力する:

```
PR #<number> 解説スライド — <GitHub PDF URL>
```

## エラーハンドリング

- **PR が見つからない場合**: PR 番号を再確認するよう案内
- **gh CLI 未認証**: `gh auth login` の実行を案内
- **diff が極端に大きい場合**: 要約戦略に切り替え、主要ファイルのみ詳細化
- **PDF 生成が失敗した場合**: marp-cli のエラー内容をユーザーに報告し、処理を中断
- **create-slide が失敗した場合**: エラー内容をユーザーに報告し、手動対応を案内
- **プッシュが失敗した場合**: リモートブランチの状態を確認し、ユーザーに報告

## 注意事項

- PDF はバイナリファイルのため、リポジトリサイズが増加する。大量の PR スライドを生成する場合は `.gitignore` での管理を検討すること
- 非常に大きな diff（100 ファイル超）では、スライドの情報密度が高くなりすぎる可能性がある。重要な変更に焦点を絞ること
