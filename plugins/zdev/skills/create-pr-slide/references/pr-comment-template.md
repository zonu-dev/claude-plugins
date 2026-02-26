# PR コメントテンプレート

PR に投稿するコメントの Markdown テンプレート。
PDF リンクを含み、GitHub の PDF ビューアーでプレビューできる。

## テンプレート

```markdown
📊 **PR 解説スライド** — [スライドを見る（PDF）](<PDF_URL>)
```

## 変数の埋め込み

| 変数 | 説明 | 取得方法 |
|------|------|---------|
| `<PDF_URL>` | GitHub 上の PDF ファイル URL | `https://github.com/<owner>/<repo>/blob/<head-branch>/slides/dist/<filename>.pdf` |

## 使い方

1. テンプレートの `<PDF_URL>` を実際の URL で置換する
2. `gh pr comment <number> --body "<本文>"` で投稿する
