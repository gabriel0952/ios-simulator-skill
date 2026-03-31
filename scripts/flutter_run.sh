#!/usr/bin/env bash
# flutter_run.sh — Build and run Flutter app on iOS Simulator
# Usage: ./flutter_run.sh <project_path> [--udid UDID]
# Note: Runs in foreground; Ctrl+C to stop. For background, use: ./flutter_run.sh ... &

FLUTTER="${FLUTTER_PATH:-$HOME/development/flutter/bin/flutter}"

source "$(dirname "$0")/_utils.sh"

PROJECT="${1:-}"; shift 1 2>/dev/null || true
UDID=""

while [[ $# -gt 0 ]]; do
  case $1 in --udid) UDID="$2"; shift 2 ;; *) shift ;; esac
done

[[ -z "$PROJECT" ]] && die "Usage: flutter_run.sh <project_path> [--udid UDID]"
[[ ! -d "$PROJECT" ]] && die "Directory not found: $PROJECT"
[[ ! -x "$FLUTTER" ]] && die "Flutter not found: $FLUTTER. Set FLUTTER_PATH env var."

UDID=$(get_udid "$UDID") || die "No booted simulator found."

cd "$PROJECT" || exit 1
echo "Running Flutter app on simulator $UDID..."
exec "$FLUTTER" run -d "$UDID"
