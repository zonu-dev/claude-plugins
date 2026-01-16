# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace repository. It hosts custom plugins that can be installed via the `/plugin` command.

## Structure

- `.claude-plugin/marketplace.json` - Marketplace configuration and plugin registry
- `./plugins/` - Directory for plugin implementations (defined in `pluginRoot`)

## Plugin Management

Install this marketplace:
```bash
/plugin marketplace add zonu-dev/claude-plugins
```

Install a plugin from this marketplace:
```bash
/plugin install <plugin-name>@zonu-plugins
```

## Setup

Clone 後に以下を実行して Git hooks を有効化する:
```bash
git config core.hooksPath hooks
```

## Adding New Plugins

1. Create a new directory under `./plugins/`
2. Register the plugin in `.claude-plugin/marketplace.json` by adding it to the `plugins` array
