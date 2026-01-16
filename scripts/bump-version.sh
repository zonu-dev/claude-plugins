#!/usr/bin/env bash
set -euo pipefail

BUMP_TYPE="${1:-}"

if [[ "$BUMP_TYPE" != "major" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "patch" ]]; then
  echo "Usage: $0 <major|minor|patch>" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_JSON="$REPO_ROOT/plugins/zdev/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"

CURRENT_VERSION="$(jq -r '.version' "$PLUGIN_JSON")"

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$BUMP_TYPE" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

jq --arg v "$NEW_VERSION" '.version = $v' "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp" && mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"
jq --arg v "$NEW_VERSION" '.plugins[0].version = $v' "$MARKETPLACE_JSON" > "$MARKETPLACE_JSON.tmp" && mv "$MARKETPLACE_JSON.tmp" "$MARKETPLACE_JSON"

echo "$NEW_VERSION"
