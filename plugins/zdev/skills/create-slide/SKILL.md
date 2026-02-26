---
name: create-slide
description: "指定テーマで Marp スライドを作成し、聴衆・発表時間・学習ゴールに合わせて構成/表現/レイアウトを改善しながら完成させる。「〜のスライドを作って」「発表資料を作成して」「この内容をわかりやすくスライド化して」などの依頼で使用する。"
---

# スライド作成

指定されたテーマを、聴衆に伝わる構成と視覚設計で Marp スライドにする。
内容品質チェックとレイアウト品質チェックの両方を実施する。

## 引数

```
/create-slide <テーマ/内容の説明>
```

例:

```
/create-slide TypeScript の品質担保ツール 9 種を解説するスライド
/create-slide React hooks の基本パターンまとめ
/create-slide Git rebase vs merge の比較
```

## ワークフロー

### 0. 目的と聴衆を確定する

作成前に以下を確定する。ユーザーが明示した項目はそのまま採用し、未指定の項目はテーマから推定する。推定結果はステップ 2 の計画提示に含め、承認時に修正できるようにする。

- **対象者**: 初級 / 中級 / 上級、職種、前提知識
- **発表時間**: 分数（目安: 1 分 = 1 枚）
- **持ち帰り**: 発表後に覚えてほしい 3 点
- **ゴール**: 理解 / 意思決定 / 手順実行 のどれか
- **禁止事項**: 触れない範囲、使わない技術、避ける表現

### 1. ストーリー構造を選定する

ユーザーの説明から以下を決定する。

- **ストーリー型**: [references/story-structures.md](references/story-structures.md) の 6 型から選択する
- **構造テンプレート**: [references/story-structures.md](references/story-structures.md) から選択する
- **章立て**: 章ごとの目的と想定ページ数を決める
- **学習ゴール対応表**: 3 つの持ち帰りがどの章でカバーされるか対応付ける

### 2. スライド構成とデザイン方針を計画する

- **ファイル名**: テーマに基づいた kebab-case（例: `quality-tools.md`, `react-hooks.md`）
- **カラーパレット**: 内容に合うパレットを選択する。迷ったらデフォルト（Charcoal Minimal）。参照: [references/color-palettes.md](references/color-palettes.md)
- **構成原則**:
  - **結論先行**: タイトル直後に「このスライドで学べること」を 1 枚置く
  - **1 スライド = 1 メッセージ**: [references/design-patterns.md](references/design-patterns.md) のメッセージ設計規約に従う
  - **説明的見出し**: 「概要」「詳細」を使わず、見出しだけで主張が伝わる文にする
- **スライド構成**: タイトル → 学べること → 各章 → まとめ
- **想定ページ数**: 内容に応じて 10-30 ページ程度
- **図が必要か**: フローチャートや依存関係図がある場合は Mermaid 図を計画する
- **レイアウト計画**: スライド種別ごとのレイアウトパターンを計画する。参照: [references/design-patterns.md](references/design-patterns.md)

計画をユーザーに提示し、承認を得てからステップ 3 に進む。
（対象者・発表時間・ストーリー型・章立て・パレットを箇条書きで示す）

#### 複数ファイルシリーズの場合

同一テーマを複数ファイルに分割する場合（例: プロジェクト解説を 8 本に分ける）、追加で以下を計画する。

| 項目 | ガイドライン |
|------|-----------|
| ディレクトリ | `slides/<シリーズ名>/` に `01-xxx.md` 〜 `NN-xxx.md` で配置 |
| パレット配分 | 全ファイルで異なるパレットを割り当てる（10 種あるため最大 10 本まで重複なし） |
| ストーリー型 | 全て同じ型にせず、内容に応じて混在させる（例: 解説型 6 + 比較型 1 + 振り返り型 1） |
| header | 各ファイルのスライドタイトルを設定する（例: `header: "モノレポアーキテクチャ"`）。タイトルスライドでは `<!-- _class: lead _header: "" -->` で非表示にする |
| 一括作成順序 | 全ファイルの計画を先に提示し、承認後にまとめて作成する |

### 3. Marp スライドを作成する

`slides/<ファイル名>.md` に書き出す。既存シリーズがある場合は同じディレクトリ（例: `slides/etymo-learn/`）に配置する。

#### 環境セットアップ

スライド作成前に、プロジェクトの環境を確認し、不足があればセットアップする。

**1. Marp CLI の導入**（`package.json` に `@marp-team/marp-cli` がない場合）

```bash
npm install --save-dev @marp-team/marp-cli
```

`package.json` の `scripts` に以下を追加する（既存のものがあればスキップ）:

```json
{
  "scripts": {
    "marp:preview": "marp --no-config-file -s slides/",
    "marp:pdf": "marp --no-config-file --allow-local-files --pdf"
  }
}
```

> プロジェクトでスライドのlintやMermaid図の自動生成が必要な場合は、`marp:lint` / `marp:diagrams` スクリプトを別途追加する。

**2. テーマの導入**（`slides/themes/tech-scrapbook.css` がない場合）

1. このスキルの [references/tech-scrapbook.css](references/tech-scrapbook.css) を Read ツールで読み込む
2. `slides/themes/tech-scrapbook.css` に Write ツールで書き出す（ディレクトリがなければ `mkdir -p slides/themes` で作成）
3. `.marprc.yml`（なければ作成）に以下を設定する
   ```yaml
   theme: slides/themes/tech-scrapbook.css
   themeSet: ./slides/themes/
   html: true
   allowLocalFiles: true
   ```
4. VS Code / Cursor を使う場合は `.vscode/settings.json` に追加する
   ```json
   { "markdown.marp.themes": ["./slides/themes/tech-scrapbook.css"] }
   ```

テーマ CSS の原本: [references/tech-scrapbook.css](references/tech-scrapbook.css)

**3. PNG エクスポートスクリプトの導入**（`scripts/marp-export-png.sh` がない場合）

1. このスキルの [references/marp-export-png.sh](references/marp-export-png.sh) を Read ツールで読み込む
2. `scripts/marp-export-png.sh` に Write ツールで書き出す

スクリプト原本: [references/marp-export-png.sh](references/marp-export-png.sh)

#### 必須フォーマット（tech-scrapbook テーマ）

```markdown
---
marp: true
theme: tech-scrapbook
class: palette-ocean
paginate: true
header: "スライドタイトル"
---
```

- `header:` にはスライドのタイトル（`# 見出し` と同じ文言）を設定する
- タイトルスライド（1 ページ目）ではヘッダーを非表示にする（複数行ディレクティブで `_header: ""` を指定）

カスタムテーマに共通スタイルが含まれているため、原則として `style:` ブロックは不要。
例外として、フットノート位置などの局所調整が必要な場合のみ最小限の `<style>` を追加してよい（`palette-*` の色やタイポグラフィ全体は上書きしない）。
パレットの `class:` は [references/color-palettes.md](references/color-palettes.md) から選ぶ。

#### フォールバック（テーマが使えない環境向け）

`theme: tech-scrapbook` が使えない場合は [references/fallback-theme.md](references/fallback-theme.md) を参照。

#### コンテンツ量の制約（1 枚あたり）

作成時点からはみ出しを防ぐため、[references/content-limits.md](references/content-limits.md) の**作成時上限**列を守る。
同時に [references/design-patterns.md](references/design-patterns.md) の見出し品質・1 スライド 1 メッセージ規約を守る。
**見出し（`##`）は全角 28 文字、▶ 行は全角 38 文字を目安に収め、折り返し孤立文字を防ぐ。** 詳細は [references/content-limits.md](references/content-limits.md) の「折り返し孤立文字の防止」を参照。
**コード + テーブルを同一スライドに配置する場合、コード 7 行 + テーブル 4 行（ヘッダー含む）+ ▶ 1 行が上限。** 超過時はコードを圧縮（コメント削除・引数を 1 行化）するか、2 枚に分割する。

**⚠ `header:` 使用時は上限をさらに 1-2 行差し引く。** コンテンツが多いとヘッダーと `##` 見出しが近接する。詳細は [references/content-limits.md](references/content-limits.md) の「ヘッダー使用時の補正」を参照。

#### スライド種別ごとの書き方

- **タイトルスライド**: 複数行ディレクティブ + `# タイトル` + サブタイトル（ヘッダー非表示）
  ```markdown
  <!--
  _class: lead
  _header: ""
  -->
  ```
- **学べることスライド**: `## このスライドで学べること` + 箇条書き（3-5 項目）
- **コンテンツスライド**: `## 見出し` + 本文（コード / テーブル / 箇条書き / 図）
- **まとめスライド**: `<!-- _class: lead -->` + `# まとめ` + 箇条書き

#### フットノート（用語補足・OSS リンク）の書き方

専門用語の補足や OSS ツールのリンクにフットノートを使う。テーマの `.footnotes` スタイルでスライド下部に絶対配置される。

```markdown
テキスト中に<sup>※1</sup>マーカーを置き、スライド末尾に:

<div class="footnotes">
※1 SRS: Spaced Repetition System。最適間隔で復習を提示する学習手法<br>
※2 用語: 説明文
</div>
```

- **最大 3 件 / スライド**。4 件以上は括弧でのインライン化かスライド分割で対応
- 複数件は `<br>` で区切る
- フットノートは絶対配置のためメインコンテンツと **重なる** — 詳細は [references/content-limits.md](references/content-limits.md) を参照
- レイアウトパターンは [references/design-patterns.md](references/design-patterns.md) の「コンテンツ + フットノート」を参照

#### OSS ツールリンク

スライドで言及する **OSS ツール・ライブラリ・GitHub Action** には、**初出ページ**でフットノートにリンクを付ける。

```html
<!-- 見出しやテーブルセル内にマーカー -->
## dorny/paths-filter<sup>※1</sup> が 6 カテゴリでジョブ実行を制御する

<!-- スライド末尾にフットノート -->
<div class="footnotes">
※1 <a href="https://github.com/dorny/paths-filter">github.com/dorny/paths-filter</a> — パス変更検出 Action
</div>
```

| ルール | 説明 |
|-------|------|
| 初出ページのみ | 同じツールが複数ページに登場しても 2 回目以降はリンク不要 |
| 公式サイト優先 | 公式サイトがあればそちら（例: `eslint.org`）、なければ GitHub URL |
| 説明は短く | リンクの後に `—` で 1 フレーズの説明（例: `— JS/TS 静的解析ツール`） |
| コードブロック内 | マーカーを付けられないため、フットノートのみで対応 |

対象: ESLint, Prettier, Jest, Commitlint, lint-staged, Knip, dependency-cruiser, Dependabot, サードパーティ GitHub Action（dorny/*, marocchino/* 等）など、スライドに名前が登場するすべての OSS ツール。

### 4. 図が必要な場合: Mermaid 図を作成する

アスキーアートではなく、Mermaid で SVG 図を生成してスライドに埋め込む。
詳細な手順は [references/mermaid-guide.md](references/mermaid-guide.md) を参照。

- `package.json` の `scripts` に `marp:diagrams` が定義されている場合のみ、`npm run marp:diagrams` で `slides/images/<図名>.svg` と `slides/images/<図名>-midnight.svg` をセットで生成する。定義されていない場合はこのステップをスキップする
- SVG は Markdown 記法 `![](...)` で直接貼らず、必ず以下のテーマ切替コンテナを使う

```html
<div class="diagram-theme-switch" style="--diagram-width: 900px;">
  <img class="diagram-default" src="<images-relative>/<図名>.svg" alt="">
  <img class="diagram-midnight" src="<images-relative>/<図名>-midnight.svg" alt="">
</div>
```

- `images-relative` は Markdown ファイル位置に合わせる（例: `slides/foo.md` は `images`、`slides/etymo-learn/foo.md` は `../images`）

### 5. ソースコードとの事実検証を実施する

スライドに含まれる**事実的主張**を、対象プロジェクトの実ファイルと照合する。既存スライドの作り直しでは特に重要 — 以前存在した機能が削除・変更されている可能性がある。

#### 検証対象

| カテゴリ | 検証内容 | 確認方法 |
|---------|---------|---------|
| **コード例** | スライドに掲載するコードスニペットの正確性 | 実コードから該当クラス・メソッドを Read で開き、API 呼び出しパターン（クラス名・メソッド名・引数・戻り値型）がスライドの例示と一致するか照合 |
| **コンポーネント一覧** | テーブルや箇条書きで列挙するクラス・ファイル | 各エントリが実在するか Glob/Grep で確認し、記載された役割・説明が実装と一致するか Read で確認 |
| **依存・参照関係** | スライドに図やテキストで示すコンポーネント間の依存方向・参照関係 | 「A が B を参照する」「A が B に指示を出す」と書く場合、A のクラス定義を Read で開き B 型のフィールド・引数・メソッド呼び出しが実在するか確認。直接参照がなければ仲介層（Actor 等）を経由しているか調べ、図の矢印・テキストの記述を実装に合わせる |
| ドメインロジック | 機能の仕組み・使用制限・ライフサイクルの記述 | 該当 Model / Logic / Utility クラスを Read で確認。さらにその機能のメソッド・プロパティが実際に呼び出されているか Grep で参照元を確認 |
| CI/CD | ワークフローファイルの存在・ジョブ構成・**トリガー条件・成果物の種類と配布先・Job 実行順序** | `.github/workflows/` を Glob + Read。ジョブ名・ステップ概要だけで済ませず、トリガー（`on:` セクション）からアップロード・配布の最終ステップまで通読する。**`needs:` を確認し Job 間の依存関係（直列/並列）を正確に把握する** |
| npm スクリプト | スライドに登場するコマンドの実在 | `package.json` の `scripts` を確認 |
| 設定ファイル | 参照する設定（Jest, ESLint 等）の実在 | 実ファイルを Read で確認 |
| 数値 | ルール数・ジョブ数・閾値等 | ソースを数えて照合 |
| 自動化の頻度 | 「週次」「毎回」「手動」等の記述 | CI cron / Dependabot / scripts を確認 |
| ツールの有無 | 「〜を導入」「〜で検出」と書いたツール | dependencies / devDependencies を確認 |

#### 特に注意すべきパターン

- **コード例の API 不一致**: スライドの例示コードが実装と異なる API パターンを示している（例: `Services.Set<IFoo>(x)` と書いたが実装は `Services.Instance.Set(x)`）。コード例は必ず実コードを Read してから書き、メソッド名・型引数・呼び出し規約を正確に再現する。**推測でコード例を書かない**
- **テーブル内容の不正確**: コンポーネント一覧テーブルに実在しないクラスや誤った役割を記載している（例: 子 CompositionRoot を親と同列に並べる、実在しないインタフェース名で例示する）。テーブルの各行は Glob/Grep で実在と役割を確認する
- **ドメイン挙動の推測記述**: 「N 回だけ」「1 回限り」「無制限」等の使用制限・回数・条件は必ずソースで裏取りする。推測で書かない
- **依存方向の誤り**: 「A が B に指示を出す」「A → B」と書いたが、実装では A と B に直接の参照がなく、仲介層 C が両者を繋いでいた（例: Behaviour → BodyController と書いたが、実際は Actor が両者を仲介し直接参照はない）。コンポーネント間の関係を図やテキストで示す場合、双方のクラス定義をRead で開き、フィールド・メソッド引数に相手の型が存在するかを必ず確認する。**参照の存在を推測で書かない**
- **デッドコード（定義はあるが未使用の機能）**: モデルにプロパティやメソッドが定義されていても、ゲームロジックやステートマシンから一度も呼び出されていなければ「使われている」とは言えない。定義の存在確認だけでなく、Grep で呼び出し元が実在するかまで確認する
- **CI/CD フローの途中読み**: ワークフローのジョブ名・概要だけで成果物や配布先を推測し、実際のステップと異なる内容を書いてしまう。トリガー条件（`on:` セクション）、成果物の形式、アップロード・配布先は最終ステップまで Read で通読して確認する。**推測で書かない**
- **Job 実行順序の誤記**: 「並列」「同時実行」と書いたが、実際は `needs:` で直列に依存していた、またはその逆。見出しや本文に「並列制御」「並列実行」「同時実行」「直列」等の実行順序を示す語を使う場合、各 Job の `needs:` キーと `strategy.matrix` の値を Read で確認し、実際の依存グラフと一致するか検証する。**`needs:` がある Job 間は直列、`needs:` がない独立 Job 間のみ並列と記述できる**
- **削除済み機能の残留**: 以前あった CI ジョブ・設定ファイル・自動化がスライドに残っていないか
- **自動 vs 手動の混同**: 「自動実行」と書いたが実際は手動トリガーのみ、またはその逆。トリガー条件を必ず確認する
- **数値のズレ**: 「N 個のルール」と書いたが実際は増減していないか

#### ワークフロー

```
1. スライドから事実的主張（数値・ツール名・頻度・ファイル名）を抽出する
2. コード例のクラス名・メソッド名・引数を実コードと Read で照合する
3. テーブルに列挙したクラス・コンポーネントの実在と役割を Glob/Grep + Read で確認する
4. その他の主張に対応するソースファイルを Read で確認する
5. 不一致があればスライドを修正する
```

### 6. 明瞭性リライトを実施する

[references/clarity-checklist.md](references/clarity-checklist.md) で全スライドを確認する。

```
繰り返し (最大 2 回):
  1. 用語初出の定義不足、長文、抽象語を検出する
  2. 見出しを「主張が伝わる文」に書き換える
  3. 各スライド末尾に `▶ <要点>` を 1 行で補う
     例: `▶ ESLint は静的解析、Prettier はフォーマットに特化`
```

### 7. 自己採点（ルーブリック）

スライド全体を [references/quality-rubric.md](references/quality-rubric.md) の 9 次元で自己採点する。

```
繰り返し (最大 2 回):
  1. 9 次元 x 10 点 = 90 点満点で採点
  2. 68 点以上 → 次工程へ
  3. 68 点未満 → 下位 2 項目を修正
```

### 8. 自動 lint で内容の崩れを検出する

`package.json` の `scripts` に `marp:lint` が定義されている場合のみ、以下を実行し、警告を確認して修正する。定義されていない場合はこのステップをスキップする。

```bash
npm run marp:lint -- --warn-only "slides/<ファイル名>.md"
```

優先して修正する警告:

- 汎用見出し（例: 概要 / 詳細）
- テキストのみのスライド（タイトル・まとめ除く）
- 図だけスライド（図 + `▶` のみでテーブル・箇条書きがないコンテンツスライド）
- 箇条書きや番号付きリストの過多
- SVG の直接埋め込み（`diagram-theme-switch` への置換が必要）
- `diagram-default` / `diagram-midnight` の片方欠落、参照切れ

### 9. レビュー→修正ループ（最大 3 回）

スライド作成後、以下のループを回す。

> **重要: `/review-slide` を Skill ツールで呼び出さない。** 以下のレビュー手順を create-slide ワークフローの一部として直接実行する。Skill ツールで呼び出すとレビュー完了時点でワークフローが中断し、修正ループに戻れなくなる。

```
繰り返し (最大 3 回):
  1. 下記のレビュー手順を直接実行する
  2. 問題なし → ループ終了
  3. 問題あり → 修正方針に従って Markdown を修正し、次の繰り返しへ
```

#### レビュー手順（インライン実行）

1. PNG を生成する
   ```bash
   bash scripts/marp-export-png.sh "/tmp/marp-review-<base>" "slides/<ファイル名>"
   ```
2. `package.json` の `scripts` に `marp:lint` が定義されている場合のみ lint を実行する（未定義ならスキップ）
   ```bash
   npm run marp:lint -- --warn-only "slides/<ファイル名>.md"
   ```
3. Markdown ソースを Read で読み、[source-check-rules.md](references/source-check-rules.md) の全 6 ルールでチェックする
4. 全ページの PNG を Read ツールで **8 枚ずつ並列** 読み取りし、[review-checklist.md](references/review-checklist.md) の 17 観点で判定する
5. 問題を報告する。問題があれば修正方針に従って修正し、次の繰り返しへ進む

#### 修正の方針

| はみ出し原因 | 修正方法 |
|------------|---------|
| コードブロックが長い | 行数を削減（コメント削除、1行にまとめる、省略記法） |
| テーブルの行数が多い | 行数を減らす or 別スライドに分割 |
| テキスト + コード + テーブルの複合 | 2 枚のスライドに分割 |
| 1 行が長くて右端切れ | 改行を入れる or 表現を短縮 |
| フッターとの重なり | コンテンツ量削減 or `footer: ""` で無効化 |
| SVG 画像がはみ出す | `![w:XXX]` の幅を縮小する |
| SVG 画像が表示されない | `--allow-local-files` を確認、パスの相対指定を確認 |
| Mermaid 図が縦に長い | `flowchart LR` に変更、ノードをまとめて数を減らす |
| Mermaid 図の並列ノードが横並び | subgraph 一括接続を個別接続（fan-out/fan-in `&` 記法）に変更して縦配置にする |
| Mermaid 図の文字が小さい | 横一列のノードを最大 5 個にグループ化、fan-out/fan-in で縦配置、`--diagram-width` を拡大 |
| Mermaid 図の番号がガタガタ | ノード内テキストを `<div style='text-align:left'>` で左寄せにする |
| グリッド内のリスト/テーブルが長い | 項目をグループ化して行数削減（例: 8項目→4行×2項目）、または番号付きリストをテーブルに変換 |
| 見出し・▶行の末尾が数文字で折り返し | 表現を短縮して 1 行に収める。短縮困難なら語順を調整して自然な折り返し位置にする |
| ヘッダーと見出しが近接 | コンテンツ量を 1-2 行削減する（コード圧縮、テーブル行統合）。詳細は [content-limits.md](references/content-limits.md) の「ヘッダー使用時の補正」を参照 |

**情報を削除するのではなく、圧縮・分割で対応する。**

### 10. 最終チェックを実行する

完了報告の前に、`package.json` の `scripts` に各スクリプトが定義されている場合のみ以下を実行する（未定義のものはスキップ）。

```bash
npm run marp:diagrams
npm run marp:lint -- --warn-only "slides/<ファイル名>.md"
```

上記に加え、ステップ 9 と同じレビュー手順（PNG 生成→画像チェック）を 1 回実行する。
**Skill ツールで `/review-slide` を呼び出さず、直接実行すること。**

### 11. 完了報告

通常は**短縮版**で報告する。詳細版は問題が残る場合のみ使う。

#### 短縮版（標準）

```markdown
## スライド作成完了

- ファイル: slides/quality-tools.md (20 ページ)
- パレット: palette-ocean
- 対象者 / 発表時間 / ストーリー型: Web エンジニア中級 / 20分 / 比較型
- 自己採点: 74 / 90
- lint: 警告 0 件
- レビュー: 全ページ問題なし
- プレビュー: npm run marp:preview
```

#### 詳細版（未解決事項がある場合のみ）

```markdown
## スライド作成完了（要確認）

- ファイル: slides/quality-tools.md (20 ページ)
- 自己採点: 62 / 90
- lint: 警告 2 件（p6 見出し, p11 箇条書き過多）
- レビュー: 2 ページ未解決（p11 下部余白不足, p17 テーブル切れ）
- 提案: p11 を 2 枚に分割、p17 は表を 5 行以内に圧縮
```

## 注意事項

- macOS/Linux 環境を前提とする。Windows 環境では WSL 上での使用を推奨する
- `--no-config-file` は `.marprc.yml` との競合回避のため**必須**
- stdin 待ちでハングするのを防ぐため、Marp CLI 実行時は `< /dev/null` を使う（`--no-stdin` は v4.x では使えない）
- `--allow-local-files` は SVG 画像をスライドに埋め込む場合に**必須**
- レイアウト検証用 PNG は `review-slide` の規約に合わせて `--image-scale 1` を使う
- VS Code / Cursor の `markdown.marp.themes` はワークスペース相対パス（例: `./slides/themes/tech-scrapbook.css`）で設定する
- 内容品質の確認（構成・見出し・明瞭性）を済ませてから `review-slide` のレイアウトチェックに進む
- 既存ファイルと同名の場合はユーザーに確認してから上書きする
- PNG は `/tmp/` に生成するため、セッション終了後に自動削除される
- レビューループが 3 回で収束しない場合は、残存問題を報告してユーザーに確認する
