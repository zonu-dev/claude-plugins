#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: bash $0 <out_dir> <slide_file>" >&2
  exit 1
fi

out_dir="$1"
slide_file="$2"

mkdir -p "$out_dir"

npx @marp-team/marp-cli --no-config-file --html --images png \
  --image-scale 1 --allow-local-files \
  --theme-set ./slides/themes/ \
  -o "$out_dir/slide" \
  -- "$slide_file" < /dev/null 2>&1

shopt -s nullglob
for f in "$out_dir"/slide.[0-9][0-9][0-9]; do cp "$f" "${f}.png"; done
