#!/usr/bin/env bash
# flutter_test.sh — Run Flutter tests
# Usage: ./flutter_test.sh <project_path> [test_file_or_dir]

FLUTTER="${FLUTTER_PATH:-$HOME/development/flutter/bin/flutter}"
PROJECT="${1:-}"; TEST_PATH="${2:-}"

[[ -z "$PROJECT" ]] && { echo '{"success": false, "error": "Usage: flutter_test.sh <project_path> [test_path]"}'; exit 1; }
[[ ! -d "$PROJECT" ]] && { echo "{\"success\": false, \"error\": \"Directory not found: $PROJECT\"}"; exit 1; }
[[ ! -x "$FLUTTER" ]] && { echo "{\"success\": false, \"error\": \"Flutter not found: $FLUTTER\"}"; exit 1; }

cd "$PROJECT" || exit 1

if [[ -n "$TEST_PATH" ]]; then
  "$FLUTTER" test "$TEST_PATH" 2>&1
else
  "$FLUTTER" test 2>&1
fi
