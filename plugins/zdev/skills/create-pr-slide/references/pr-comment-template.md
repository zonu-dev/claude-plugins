# PR コメントテンプレート

PR に投稿するコメントの Markdown テンプレート。
PDF リンクを含み、GitHub の PDF ビューアーでプレビューできる。

## テンプレート

```markdown
## 📊 PR 解説スライド

この PR の変更内容を解説するスライドを生成しました。

**[📄 スライドを見る（PDF）](<PDF_URL>)**

| 項目 | 値 |
|------|-----|
| ページ数 | <N> ページ |
| 変更ファイル数 | <N> ファイル |
| 追加/削除 | +<N> / -<N> 行 |

### スライド構成

1. <章タイトル 1>
2. <章タイトル 2>
3. ...

---
<sub>🤖 Generated with create-pr-slide</sub>
```

## 変数の埋め込み

| 変数 | 説明 | 取得方法 |
|------|------|---------|
| `<PDF_URL>` | GitHub 上の PDF ファイル URL | `https://github.com/<owner>/<repo>/blob/<head-branch>/slides/dist/<filename>.pdf` |
| `<N> ページ` | スライドのページ数 | Markdown ファイルの `---` 区切り数をカウント |
| `<N> ファイル` | PR の変更ファイル数 | Phase 1 で取得済み |
| `+<N> / -<N>` | 追加/削除行数 | Phase 1 で取得済み |
| `<章タイトル>` | スライドの章構成 | 生成されたスライドの `## 見出し` を抽出 |

## 使い方

1. テンプレートの変数を実際の値で置換する
2. `gh pr comment <number> --body "<本文>"` で投稿する
3. 本文が長い場合は HEREDOC を使う:
   ```bash
   gh pr comment <number> --body "$(cat <<'EOF'
   <テンプレート展開後の本文>
   EOF
   )"
   ```
