# CLAUDE.md

このファイルは、Claude Code がこのリポジトリで作業する際のガイダンスを提供する。

## リポジトリ概要

Claude Code プラグインマーケットプレイスリポジトリ。`/plugin` コマンドでインストール可能なカスタムプラグインをホストする。

## ディレクトリ構成

- `.claude-plugin/marketplace.json` - マーケットプレイス設定とプラグインレジストリ
- `plugins/` - プラグイン実装（`pluginRoot`）
- `hooks/` - Git hooks（post-commit による自動バージョンバンプ）
- `scripts/` - ユーティリティスクリプト（`bump-version.sh`）

## Git Workflow

- コミットメッセージは Conventional Commits 形式を使用する
  - `feat:` → minor バージョンバンプ
  - `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:` → patch バージョンバンプ
- post-commit hook がコミットタイプに応じてバージョンを自動バンプする
- バージョンの手動変更は不要（`scripts/bump-version.sh` が自動実行される）

## プラグインの追加

1. `plugins/` 配下に新しいディレクトリを作成する
2. `.claude-plugin/marketplace.json` の `plugins` 配列にプラグインを登録する
