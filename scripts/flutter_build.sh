#!/usr/bin/env bash
# flutter_build.sh — Build Flutter app for iOS Simulator
# Usage: ./flutter_build.sh <project_path> [--mode debug|release|profile]
# Output: build/ios/iphonesimulator/<AppName>.app

FLUTTER="${FLUTTER_PATH:-$HOME/development/flutter/bin/flutter}"
PROJECT="${1:-}"; shift 1 2>/dev/null || true
MODE="debug"

while [[ $# -gt 0 ]]; do
  case $1 in --mode) MODE="$2"; shift 2 ;; *) shift ;; esac
done

[[ -z "$PROJECT" ]] && { echo '{"success": false, "error": "Usage: flutter_build.sh <project_path>"}'; exit 1; }
[[ ! -d "$PROJECT" ]] && { echo "{\"success\": false, \"error\": \"Directory not found: $PROJECT\"}"; exit 1; }
[[ ! -x "$FLUTTER" ]] && { echo "{\"success\": false, \"error\": \"Flutter not found at $FLUTTER. Set FLUTTER_PATH env var.\"}"; exit 1; }

cd "$PROJECT" || exit 1
echo "Building Flutter app ($MODE) for iOS Simulator..."
"$FLUTTER" build ios --simulator "--$MODE" --no-codesign 2>&1

if [[ $? -eq 0 ]]; then
  APP=$(find "$PROJECT/build/ios/iphonesimulator" -name "*.app" -maxdepth 1 2>/dev/null | head -1)
  echo "{\"success\": true, \"mode\": \"$MODE\", \"app_path\": \"$APP\"}"
else
  echo '{"success": false, "error": "Build failed. See output above."}'
fi
