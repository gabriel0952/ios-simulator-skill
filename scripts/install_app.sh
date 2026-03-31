#!/usr/bin/env bash
# install_app.sh — Install a .app bundle into the simulator
# Usage: ./install_app.sh <app_path> [--udid UDID]

source "$(dirname "$0")/_utils.sh"

APP="${1:-}"; shift 1 2>/dev/null || true
UDID=""

while [[ $# -gt 0 ]]; do
  case $1 in --udid) UDID="$2"; shift 2 ;; *) shift ;; esac
done

[[ -z "$APP" ]] && die "Usage: install_app.sh <app_path> [--udid UDID]"
[[ ! -d "$APP" ]] && die "App not found: $APP"

UDID=$(get_udid "$UDID") || die "No booted simulator found."

OUT=$(xcrun simctl install "$UDID" "$APP" 2>&1)
if [[ $? -eq 0 ]]; then
  echo "{\"success\": true, \"message\": \"Installed\", \"app_path\": \"$APP\"}"
else
  die "$OUT"
fi
