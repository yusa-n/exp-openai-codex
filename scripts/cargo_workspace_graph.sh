#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-.}"

if [[ ! -f "${WORKSPACE_DIR}/Cargo.toml" ]]; then
  echo "error: '${WORKSPACE_DIR}' does not contain a Cargo.toml" >&2
  exit 1
fi

# Generate cargo metadata (JSON) and extract edges between workspace crates
cargo metadata \
  --manifest-path "${WORKSPACE_DIR}/Cargo.toml" \
  --format-version 1 \
  --all-features |
jq -r '
  .workspace_members as $ws
  | .packages as $pkgs
  | .resolve.nodes[]
  | .id as $src_id
  | select($ws | index($src_id))
  | ($pkgs[] | select(.id == $src_id) | .name) as $src
  | .deps[]
  | .pkg as $dst_id
  | select($ws | index($dst_id))
  | ($pkgs[] | select(.id == $dst_id) | .name) as $dst
  | "\($src) --> \($dst)"
' |
sort -u |
awk 'BEGIN {print "graph TD"} {print}'
