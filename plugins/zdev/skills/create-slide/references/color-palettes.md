# カラーパレット一覧

Tech Scrapbook テーマで使える 10 種のカラーパレット。
フロントマターの `class:` でパレットを切り替える。

> **索引**: デフォルト(Charcoal) | `palette-midnight` | `palette-forest` | `palette-coral` | `palette-terracotta` | `palette-ocean` | `palette-teal` | `palette-berry` | `palette-cherry` | `palette-sage`

## 使い方

```markdown
---
marp: true
theme: tech-scrapbook
class: palette-ocean
---
```

個別スライドだけ変更する場合:

```markdown
<!-- _class: palette-coral -->
```

## パレット一覧と選び方

| CSS クラス | テーマ名 | 背景 | 向いているテーマ |
|-----------|---------|------|----------------|
| (なし/デフォルト) | Charcoal Minimal | ライト | コード主体の解説（汎用） |
| `palette-midnight` | Midnight Executive | ダーク | コードが映えるダーク背景 |
| `palette-forest` | Forest & Moss | ライト | 自然・成長・環境テーマ |
| `palette-coral` | Coral Energy | ライト | 比較・対照（コントラスト明確） |
| `palette-terracotta` | Warm Terracotta | ライト | デザイン・クラフト系 |
| `palette-ocean` | Ocean Gradient | ライト | テック・データ系 |
| `palette-teal` | Teal Trust | ライト | 信頼感・ヘルスケア |
| `palette-berry` | Berry & Cream | ライト | クリエイティブ・プレミアム |
| `palette-cherry` | Cherry Bold | ライト | インパクト重視 |
| `palette-sage` | Sage Calm | ライト | 教育・ウェルネス |

## 選択ガイド

1. **迷ったらデフォルト**（Charcoal Minimal）を使う
2. コード量が多い技術解説 → デフォルト or `palette-ocean`
3. ダーク背景でコードを目立たせたい → `palette-midnight`
4. 比較・対照が中心のスライド → `palette-coral`
5. チュートリアル・教育系 → `palette-sage` or `palette-teal`

## 配色の詳細

各パレットは以下の要素に色を定義している:

- **背景**: `section` の `background`
- **本文テキスト**: `section` の `color`
- **見出し**: `h1` / `h2` / `h3` の `color`
- **リンク**: `a` の `color`
- **インラインコード**: `code` の `background` と `color`
- **lead スライド**: `section.lead` の `background` と `color`（見出し色を反転）

## WCAG コントラスト

全パレットで本文テキストと背景のコントラスト比 4.5:1 以上を確保している。
`palette-midnight` のダーク背景ではライトテキスト (#e0e0e0) を使用。
