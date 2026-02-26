---
name: commit
description: セマンティックコミットメッセージ形式（Type: Emoji #Issue Title）でコミットを作成する
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git branch:*), AskUserQuestion
disable-model-invocation: true
---

# セマンティックコミットの作成

Semantic Commit Message形式でコミットを作成します。

## フォーマット

```
<Type>: <Emoji> #<Issue Number> <Title>
```

例: `feat: ✨ #123 ログイン機能の実装をする`

## Type一覧

| Type | Emoji | 説明 |
|------|-------|------|
| `feat` | ✨ | ユーザー向けの機能の追加や変更 |
| `fix` | 🐛 | ユーザー向けの不具合の修正 |
| `docs` | 📝 | ドキュメントの更新 |
| `style` | 🎨 | コードスタイルの修正（フォーマット等） |
| `refactor` | ♻️ | リファクタリング（機能変更なし） |
| `test` | ✅ | テストコードの追加や修正 |
| `chore` | 🔧 | ビルドやツール設定等の変更 |

## 処理手順

### 1. 変更内容の確認

```bash
# ステータスを確認
git status

# 変更差分を確認（ステージ済み + 未ステージ）
git diff HEAD
```

変更がない場合は終了します。

### 2. Issue番号の抽出（オプション）

```bash
# 現在のブランチ名を取得
git branch --show-current
```

ブランチ名からIssue番号を抽出します（例: `feature/42-xxx` → `#42`）。
抽出できない場合はIssue番号なしで続行します。

### 3. コミットタイプの選択

変更内容を分析し、Type一覧を参考に**最も適切なタイプを1つ推奨として選択肢の先頭に「(推奨)」付きで表示**します。

**AskUserQuestion** でTypeを確認：

```
質問: コミットタイプを選択してください

選択肢:
- <推奨タイプ>: <Emoji> (推奨) <説明>
- <他のタイプ1>: <Emoji> <説明>
- <他のタイプ2>: <Emoji> <説明>
- <他のタイプ3>: <Emoji> <説明>
```

選択肢に該当しない場合は「Other」でtest/style/choreを入力可能。

### 4. コミットメッセージの生成

変更内容を分析し、適切なコミットメッセージを生成します。

**ルール:**
- Titleは現在形で記述
- 20〜30文字程度を目安
- 変更の「何を」ではなく「なぜ」を意識

### 5. ステージングとコミット

```bash
# ステップ1で確認した変更ファイルを個別にステージング
# ※ git add -A は使用しない（.env等の意図しないファイルを含むリスクがあるため）
git add <file1> <file2> ...

# コミットを作成
git commit -m "<Type>: <Emoji> #<Issue> <Title>"
```

### 6. 完了メッセージ

コミット結果を表示します。

## 出力例

```
## コミットを作成しました

**コミットメッセージ:**
feat: ✨ #42 ユーザー認証機能を追加する

**変更ファイル:**
- src/auth/login.ts (new)
- src/auth/logout.ts (new)
- src/middleware/auth.ts (modified)

**次のステップ:**
- `git push` でリモートにプッシュ
- `/zdev:create-pr` でPRを作成
```

## 引数

- `$ARGUMENTS` から追加オプションを取得
- `--no-emoji`: 絵文字なしでコミット
- `--amend`: 直前のコミットを修正（注意して使用）

## 注意事項

- コミット前に必ず変更内容を確認してください
- `--amend` は未プッシュのコミットにのみ使用してください
