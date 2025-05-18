#!/usr/bin/env bash
# -------------------------------------------------------------------
# cargo_workspace_graph.sh
#
# Print a Mermaid dependency graph (`graph TD`) for all crates
# **inside the current Cargo workspace** (or the workspace path
# provided as first argument). External crates.io dependencies
# are ignored; only edges between workspace members are kept.
#
# Usage:
#   ./cargo_workspace_graph.sh [path/to/workspace] > deps.mmd
#
# Example:
#   chmod +x scripts/cargo_workspace_graph.sh
#   cd research/Cap          # Cargo.toml がある階層
#   ../../scripts/cargo_workspace_graph.sh > deps.mmd
#
# Requires:
#   - cargo
#   - jq
# -------------------------------------------------------------------
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
  | ($pkgs[] | select(.id == $src_id) | .name) as $src_name
  | .deps[]
  | .pkg as $dst_id
  | select($ws | index($dst_id))
  | ($pkgs[] | select(.id == $dst_id) | .name) as $dst_name
  | "\($src_name) --> \($dst_name)"
' |
sort -u |
awk 'BEGIN {print "graph TD"} {print}'
