---
description: GitHub Issueの内容を分析し、構造化された質問で曖昧さを解消しながら実装計画を立てる
allowed-tools: Bash(gh issue view:*), Bash(gh issue edit:*), Bash(gh issue list:*), Bash(gh label list:*), Glob, Grep, Read, Task, AskUserQuestion, Write, EnterPlanMode
disable-model-invocation: true
---

# Issue計画・深掘り

Issueの内容を分析し、構造化された質問で曖昧さを解消しながら実装計画を立てます。
完了後、Issueに計画を反映します。

## 引数

- `<issue_number>`: 計画を立てるIssue番号

## 処理手順

### Phase 0: Issue番号の確認

Issue番号が指定されていない場合は、Issue一覧を表示して選択を促す：

```bash
gh issue list --assignee "@me" --state open --json number,title,labels --limit 10
```

一覧を表示後、ユーザーにIssue番号の入力を求める。

### Phase 1: Issue情報の収集

```bash
gh issue view <number> --json number,title,body,labels,comments
```

リポジトリで利用可能なラベル一覧も取得：

```bash
gh label list --json name,description,color
```

Issue情報を取得し、以下を抽出：
- 主要な要件・目標
- 技術的なキーワード
- 受け入れ基準（明示されている場合）
- 既存のコメントや議論
- 現在設定されているラベル

### Phase 2: コードベースの調査

**Task**ツールで`Explore`エージェントを使用するか、直接以下を調査：

1. **関連ファイルの検索**
   - Grepでキーワードを検索
   - Globで関連するファイルパターンを検索

2. **既存実装の確認**
   - 類似機能がないか確認
   - 使用されているパターンを把握
   - プロジェクトの規約（CLAUDE.mdなど）を確認

3. **影響範囲の特定**
   - 変更が必要なファイルを列挙
   - 依存関係を確認

### Phase 3: 曖昧さの特定と深掘り

AskUserQuestionツールを使って詳細にインタビューを行います。
- プロダクト仕様
- 技術的詳細
- UI/UX
- その他すべて

**禁止事項（重要）:**
- ❌「どの項目を深掘りしたいですか？」
- ❌「どの部分を調整したいですか？」
- ❌「何について詳しく聞きたいですか？」
- ❌ 深掘り対象をユーザーに選ばせるメタ質問

**正しいアプローチ:**
- ✅ こちらが曖昧な点を特定し、具体的な実装選択肢を提示する
- ✅ 例：「認証方式はどれを採用しますか？」→ JWT / Session / OAuth2
- ✅ 例：「データの保存形式は？」→ JSON / SQLite / PostgreSQL

以下のサイクルを繰り返します：

1. 不明確な点を特定
2. ユーザーに質問して決定
3. 決定事項を反映
4. 再度分析して不明確な点があればPhase 3.1に戻る

すべての曖昧な点が解消されるまで深掘りを続けます。

#### 質問のルール

- 質問数: **2〜4個**（曖昧さのレベルに応じて調整）
- 各質問に**2〜4個の具体的な選択肢**
- 各選択肢に**pros/cons**を簡潔に記載
- オープンエンドな質問は避ける
- 「Other」は自動追加されるので含めない
- CLAUDE.mdがあれば事前に読んでプロジェクトパターンに合わせる
- multiSelectは慎重に使用（デフォルト: false）
- **AskUserQuestionツール必須**（会話的な質問ではない）

#### 回答処理

回答を受け取ったら以下の形式で出力：

```markdown
## 決定事項

| 項目 | 選択 | 理由 | 備考 |
|------|------|------|------|
| データ保存 | Database | スケーラビリティ | 移行戦略を検討 |

## 次のステップ

1. **最初のタスク**
   - 詳細...
2. **次のタスク**
   - 詳細...
```

### Phase 4: 計画の作成

回答を踏まえて、[計画テンプレート](references/plan-template.md)の形式で計画を作成する。

### Phase 5: 追加の深掘り（必要に応じて）

計画作成後も曖昧な点が残っている場合は、Phase 3に戻って追加の質問を行います。

**AskUserQuestion**で確認：
```
質問: この計画で進めてよいですか？

選択肢:
- approve: この計画で開始する
- clarify: さらに詳細を詰めたい
```

### Phase 6: タイトルとラベルの最適化

計画が承認されたら、計画内容に基づいてより適切なIssueタイトルとラベルを提案します。

#### 6.1 タイトルの提案

**タイトル提案のルール:**
- 現在のタイトルと計画内容を比較
- より具体的で明確なタイトルを2〜3個提案
- 各提案には選択理由を記載
- 現在のタイトルも選択肢として含める

**AskUserQuestion**で確認：
```
質問: Issueタイトルを更新しますか？

選択肢:
- 現在のまま: 「<現在のタイトル>」を維持
- 提案1: 「<具体的なタイトル>」- より具体的な実装内容を反映
- 提案2: 「<別のタイトル案>」- 機能の目的を明確化
```

**タイトル提案の観点:**
- **具体性**: 何を実装するか明確か
- **スコープ**: 範囲が適切に表現されているか
- **アクション**: 動詞で始まっているか（Add, Fix, Update, Implement等）
- **一貫性**: プロジェクトの既存Issueタイトルパターンに合っているか

ユーザーが新しいタイトルを選択した場合：

```bash
gh issue edit <number> --title "<新しいタイトル>"
```

#### 6.2 ラベルの提案

まず、リポジトリで利用可能なラベルを確認：

```bash
gh label list --json name,description,color
```

**ラベル提案のルール:**
- 計画内容から適切なラベルを判断
- 既存のラベルから選択（新規作成は提案しない）
- 複数のラベルを提案可能（multiSelect: true）
- 現在設定されているラベルも表示

**AskUserQuestion**で確認（multiSelect: true）：
```
質問: Issueに設定するラベルを選択してください

選択肢:
- enhancement: 新機能の追加
- bug: バグ修正
- documentation: ドキュメントの更新
- refactor: リファクタリング
```

**ラベル提案の観点:**
- **タイプ**: 作業の種類（feature, bug, docs, refactor, test等）
- **優先度**: 緊急度や重要度（priority: high/medium/low等）
- **領域**: 影響する領域（frontend, backend, api, database等）
- **サイズ**: 作業規模（size: S/M/L/XL等）
- **ステータス**: 現在の状態（needs-review, in-progress等）

ユーザーがラベルを選択した場合：

```bash
# 既存ラベルをクリアして新しいラベルを設定
gh issue edit <number> --remove-label "<古いラベル>" --add-label "<新しいラベル1>,<新しいラベル2>"
```

または追加のみ：

```bash
gh issue edit <number> --add-label "<ラベル1>,<ラベル2>"
```

### Phase 7: Issueへの反映

計画とタイトル更新が完了したら、Issue本文に計画を追記：

```bash
gh issue edit <number> --body "$(cat <<'EOF'
<元のIssue本文>

---

## Implementation Plan

<計画の内容>

EOF
)"
```

## 注意事項

- オープンエンドの質問は避け、具体的な選択肢を提示する
- プロジェクトの既存パターン（CLAUDE.mdなど）を確認してから質問を作成
- セキュリティに関わる決定は特に慎重に
- 曖昧さが解消されるまで深掘りを繰り返す
