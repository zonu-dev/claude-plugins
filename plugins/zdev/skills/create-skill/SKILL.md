---
description: "スキルを作成し、レビュー・自動修正まで行う。「スキルを作成」「新しいスキルを作って」「スキル作成して」などのリクエストで起動します。"
argument-hint: "[スキル名] [スキルの説明]"
disable-model-invocation: true
---

# /create-skill - スキル作成コマンド

このコマンドは、skill-creatorスキルを使って新しいスキルを作成し、review-skillスキルでレビュー・自動修正を行います。

## 前提条件
- `example-skills` プラグインがインストールされていること
  1. `/plugin marketplace add anthropics/skills`
  2. `/plugin install example-skills@anthropic-agent-skills`

## 使い方

### 引数付き起動
```
/create-skill pdf-converter PDFファイルを画像に変換するスキル
```

### 引数なし起動(対話的)
```
/create-skill
```

---

## [1/4] スキル情報の取得

### 引数の解析

引数からスキル情報を取得します:
- `$1`: スキル名
- `$2`以降: スキルの説明

```
スキル名: $1
スキルの説明: $ARGUMENTS から $1 を除いた部分
```

$1が空の場合、AskUserQuestionツールでスキル名を質問:
- 質問: 「作成するスキルの名前を入力してください」
- 例として `pdf-converter`, `code-review`, `data-analyzer` を提示
- 選択肢: 「名前を入力」（Otherで直接入力）

スキル名取得後、説明が空の場合もAskUserQuestionツールで質問:
- 質問: 「スキルの説明を入力してください。何を行うスキルですか？」
- 例として「PDFファイルを画像に変換し、OCR処理を行う」等を提示
- 選択肢: 「説明を入力」（Otherで直接入力）

### 起動方法の確認

AskUserQuestionツールでスキルの起動方法を確認:
- 質問: 「このスキルの起動方法を選択してください」
- 選択肢:
  - **ユーザー専用起動（推奨）**: `/スキル名` でのみ起動。副作用のあるコマンド的な用途向け（commit, deploy, issue操作など）。`disable-model-invocation: true` を設定。
  - **AI自動起動も許可**: ユーザーの発言に応じてAIが自動的に起動可能。分析・レビュー・情報提供などの用途向け。`disable-model-invocation` はデフォルト（false）。

---

## [2/4] スキルの作成

### TaskCreateでタスク管理

TaskCreateツールで以下の3つのタスクを作成:
1. 「skill-creatorでスキルを作成」（activeForm: スキルを作成している）
2. 「review-skillでスキルをレビュー」（activeForm: スキルをレビューしている）
3. 「レビュー結果に基づいて自動修正」（activeForm: スキルを自動修正している）

タスク#1をin_progressに更新してから次へ進む。

### skill-creatorの実行

Skillツールを使用してskill-creatorスキルを実行します:

```javascript
Skill({
  skill: "example-skills:skill-creator",
  args: "[スキル名] [スキルの説明]"
})
```

**重要事項**:
1. skill-creatorが対話的に質問してくる場合は、ユーザーから取得した情報を元に回答してください。
2. **SKILL.mdのボディとdescriptionは必ず日本語で生成してください。** 英語で生成された場合は、後のレビューステップで日本語に翻訳する必要があります。

### フロントマターの設定

スキル作成後、ユーザーが選択した起動方法に応じてフロントマターを設定:
- ユーザー専用起動を選択した場合: `disable-model-invocation: true` をフロントマターに追加
- AI自動起動を選択した場合: `disable-model-invocation` は設定しない（デフォルトのfalse）

### 作成完了の確認

スキルが正常に作成されたことを確認してください:
- SKILL.mdファイルが生成されたか
- 必要なディレクトリ構造が作成されたか

---

## [3/4] レビューと自動修正

### TaskUpdate更新

タスク#1をcompletedに、タスク#2をin_progressに更新する。

### review-skillの実行

Skillツールを使用してreview-skillスキルを実行します:

```javascript
Skill({
  skill: "review-skill"
})
```

### レビュー結果の処理

**問題がない場合**:
1. タスク#2, #3をcompletedに更新
2. 完了サマリーを表示して終了

**問題がある場合**:
1. タスク#2をcompleted、タスク#3をin_progressに更新
2. 指摘された問題を自動的に修正
3. 再度review-skillを実行して確認
4. 問題がなくなるまで繰り返す（最大3回）

### 自動修正のルール

review-skillから指摘された問題を自動修正する際:

1. **言語の問題**: SKILL.mdが英語で生成された場合は、フロントマター（description）とボディの全てを日本語に翻訳する
2. **構造的な問題**: ディレクトリ構造やファイル配置を修正
3. **内容の問題**: SKILL.mdの内容を修正・改善
4. **ベストプラクティス違反**: 推奨されるパターンに修正

**修正後は必ず再レビュー**を実行して、問題が解決されたことを確認してください。

---

## [4/4] README更新

レビュー・自動修正が完了したら、`/update-skill-readme` を実行してREADMEを更新する:

```
/update-skill-readme skills
```

---

## 完了サマリー

### サマリー表示

以下の情報を表示してください:

```
✓ スキルの作成が完了しました

スキル名: [スキル名]
説明: [スキルの説明]
起動方法: [ユーザー専用起動 / AI自動起動も許可]

作成されたファイル:
- [ファイルパスのリスト]

レビュー結果:
- [問題なし / N件の問題を自動修正]
```

---

## 重要な注意事項

### 自動修正の制限

- 最大3回まで自動修正を試行
- 3回試行しても問題が解決しない場合は、ユーザーに手動対応を依頼

### エラーハンドリング

- skill-creatorの実行エラー時は明確なエラーメッセージを表示
- review-skillの実行エラー時はリトライオプションを提供
- 修正不可能な問題はユーザーに報告
