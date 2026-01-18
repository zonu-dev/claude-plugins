---
description: Plan implementation for a GitHub issue with structured clarification questions
allowed-tools: Bash(gh issue view:*), Bash(gh issue edit:*), Bash(gh label list:*), Glob, Grep, Read, Task, AskUserQuestion, Write, EnterPlanMode
---

# Issue計画・深掘り

Issueの内容を分析し、構造化された質問で曖昧さを解消しながら実装計画を立てます。
完了後、Issueに計画を反映します。

## 引数

- `<issue_number>`: 計画を立てるIssue番号（必須）

## 処理手順

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

Issueや実装方針で不明確な点を特定し、**AskUserQuestion**で構造化された質問を行います。

**質問のルール:**
- 2〜4個の質問を一度に提示
- 各質問には2〜4個の具体的な選択肢を用意
- 各選択肢にはメリット/デメリットを記載
- 「Other」は自動追加されるので含めない

**質問すべきカテゴリ:**
- **アーキテクチャ**: 設計パターン、コンポーネント構造
- **データ**: データモデル、状態管理
- **API**: エンドポイント設計、インターフェース
- **UI/UX**: ユーザーインターフェースの詳細
- **テスト**: テスト戦略、カバレッジ
- **スコープ**: 今回の実装範囲、将来の拡張

**質問例:**

```
質問: 認証方式はどれを採用しますか？

選択肢:
- JWT: ステートレス、スケーラブル。トークン失効が難しい
- Session: サーバー側で管理、即時失効可能。スケールに課題
- OAuth2: 外部認証連携可能。実装が複雑
```

### Phase 4: 計画の作成

回答を踏まえて、以下の形式で計画を作成：

```markdown
## 実装計画: #<number> <title>

### 決定事項

| 項目 | 選択 | 理由 | 備考 |
|------|------|------|------|
| 認証方式 | JWT | スケーラビリティ重視 | リフレッシュトークン実装 |

### 要件サマリ
- 主要目標: ...
- 技術的制約: ...

### 受け入れ基準
- [ ] ...
- [ ] ...

### 影響範囲

| ファイル | 役割 | 変更種別 |
|---------|------|---------|
| path/to/file | ... | 新規/修正 |

### 実装ステップ

1. **Step 1: タイトル**
   - 詳細説明
   - 関連ファイル: `path/to/file`

2. **Step 2: タイトル**
   - 詳細説明

### リスク・考慮事項
- ...

### 次のステップ
1. `/issue-start <number>` で開発を開始
```

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

または、Issueにコメントとして追加：

```bash
gh issue comment <number> --body "$(cat <<'EOF'
## Implementation Plan

<計画の内容>
EOF
)"
```

## 出力例

```markdown
## 実装計画: #42 Add user authentication

### 決定事項

| 項目 | 選択 | 理由 | 備考 |
|------|------|------|------|
| 認証方式 | JWT | スケーラビリティ重視 | リフレッシュトークン実装 |
| パスワード保存 | bcrypt | 業界標準、十分なセキュリティ | コスト12 |
| トークン有効期限 | 1時間 | セキュリティとUXのバランス | リフレッシュで延長 |

### 要件サマリ
- 主要目標: JWTを使用したユーザー認証機能の追加
- 技術的制約: 既存のExpress.jsミドルウェアパターンに従う

### 受け入れ基準
- [ ] ログイン/ログアウトAPIが動作する
- [ ] JWTトークンが正しく発行・検証される
- [ ] 認証が必要なエンドポイントが保護される
- [ ] リフレッシュトークンで期限延長できる

### 影響範囲

| ファイル | 役割 | 変更種別 |
|---------|------|---------|
| src/middleware/auth.ts | 認証ミドルウェア | 新規 |
| src/routes/auth.ts | 認証ルート | 新規 |
| src/routes/index.ts | ルート登録 | 修正 |
| src/types/user.ts | ユーザー型定義 | 修正 |
| src/utils/jwt.ts | JWTユーティリティ | 新規 |

### 実装ステップ

1. **Step 1: JWTユーティリティの作成**
   - トークン生成・検証関数を実装
   - 関連ファイル: `src/utils/jwt.ts`

2. **Step 2: 認証ミドルウェアの実装**
   - リクエストからトークンを抽出・検証
   - 関連ファイル: `src/middleware/auth.ts`

3. **Step 3: 認証APIの実装**
   - POST /auth/login, POST /auth/logout, POST /auth/refresh
   - 関連ファイル: `src/routes/auth.ts`

4. **Step 4: テストの追加**
   - 単体テスト、統合テスト
   - 関連ファイル: `src/__tests__/auth.test.ts`

### リスク・考慮事項
- パスワードは必ずハッシュ化して保存
- トークンの有効期限を適切に設定
- HTTPS必須（本番環境）

### 次のステップ
1. `/issue-start 42` で開発を開始
2. JWTユーティリティから実装

---
Issue #42 に計画を反映しました。
```

## 注意事項

- オープンエンドの質問は避け、具体的な選択肢を提示する
- プロジェクトの既存パターン（CLAUDE.mdなど）を確認してから質問を作成
- セキュリティに関わる決定は特に慎重に
- 曖昧さが解消されるまで深掘りを繰り返す
