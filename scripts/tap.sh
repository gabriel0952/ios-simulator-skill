#!/usr/bin/env bash
# tap.sh — Tap at logical coordinates on the simulator
# Usage: ./tap.sh <x> <y> [--udid UDID]
# Requires: idb  (brew install idb-companion && pip install fb-idb)
# Example: ./tap.sh 196 400

source "$(dirname "$0")/_utils.sh"

X="${1:-}"; Y="${2:-}"; shift 2 2>/dev/null || true
UDID=""

while [[ $# -gt 0 ]]; do
  case $1 in --udid) UDID="$2"; shift 2 ;; *) shift ;; esac
done

[[ -z "$X" || -z "$Y" ]] && die "Usage: tap.sh <x> <y> [--udid UDID]"

UDID=$(get_udid "$UDID") || die "No booted simulator found."

if command -v idb &>/dev/null; then
  idb --udid "$UDID" ui tap "$X" "$Y" 2>&1
  echo "{\"success\": true, \"action\": \"tap\", \"x\": $X, \"y\": $Y}"
else
  die "idb not found. Install: brew install idb-companion && pip install fb-idb"
fi
