---
description: Analyze issue requirements and propose implementation approach based on codebase
argument-hint: "<issue_number>"
allowed-tools: Bash(gh issue view:*), Glob, Grep, Read, Task, TodoWrite
---

# Issue分析・実装方針提案

Issueの内容を分析し、コードベースを調査して実装方針を提案します。

## 引数

- `<issue_number>`: 分析するIssue番号（必須）

## 処理手順

### 1. Issue詳細の取得

```bash
gh issue view <number> --json number,title,body,labels,comments
```

Issue情報を取得し、内容を把握します。

### 2. Issue内容の分析

Issue本文から以下を抽出：
- 主要な要件・目標
- 技術的なキーワード
- 受け入れ基準（明示されている場合）

### 3. コードベースの調査

**Task**ツールで`issue-analyzer`エージェントを使用するか、直接以下を調査：

1. **関連ファイルの検索**
   - Grepでキーワードを検索
   - Globで関連するファイルパターンを検索

2. **既存実装の確認**
   - 類似機能がないか確認
   - 使用されているパターンを把握

3. **影響範囲の特定**
   - 変更が必要なファイルを列挙
   - 依存関係を確認

### 4. 分析結果の出力

以下の形式で出力してください：

```markdown
## Issue分析: #<number> <title>

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

### 関連コンポーネント
- ...

### 実装方針

#### 推奨アプローチ
1. ...
2. ...
3. ...

#### 参考になる既存実装
- `path/to/similar.ts:42` - 類似機能の実装例

### リスク・考慮事項
- ...

### 次のステップ
1. `/issue-start <number>` で開発を開始
2. ...
```

### 5. Todoリストの作成（オプション）

実装ステップをTodoリストとして保存したい場合は、**TodoWrite**を使用して作成。

## 出力例

```markdown
## Issue分析: #42 Add user authentication

### 要件サマリ
- 主要目標: JWTを使用したユーザー認証機能の追加
- 技術的制約: 既存のExpress.jsミドルウェアパターンに従う

### 受け入れ基準
- [ ] ログイン/ログアウトAPIが動作する
- [ ] JWTトークンが正しく発行・検証される
- [ ] 認証が必要なエンドポイントが保護される

### 影響範囲

| ファイル | 役割 | 変更種別 |
|---------|------|---------|
| src/middleware/auth.ts | 認証ミドルウェア | 新規 |
| src/routes/auth.ts | 認証ルート | 新規 |
| src/routes/index.ts | ルート登録 | 修正 |
| src/types/user.ts | ユーザー型定義 | 修正 |

### 関連コンポーネント
- Express.js ミドルウェア
- JWT (jsonwebtoken)
- bcrypt (パスワードハッシュ)

### 実装方針

#### 推奨アプローチ
1. ユーザーモデルにパスワードハッシュフィールドを追加
2. 認証ミドルウェアを作成
3. ログイン/ログアウトAPIを実装
4. 保護が必要なルートにミドルウェアを適用
5. テストを追加

#### 参考になる既存実装
- `src/middleware/logger.ts:15` - ミドルウェアパターンの例

### リスク・考慮事項
- パスワードは必ずハッシュ化して保存
- トークンの有効期限を適切に設定
- HTTPS必須（本番環境）

### 次のステップ
1. `/issue-start 42` で開発を開始
2. 認証ミドルウェアから実装
```

## 注意事項

- コードベースが大きい場合は重要な部分に絞って分析
- 推測ではなく、実際のコードを読んで分析する
- セキュリティに関わる変更は特に注意を促す
