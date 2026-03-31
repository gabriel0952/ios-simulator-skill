#!/usr/bin/env bash
# _utils.sh — shared helper functions; source this from other scripts
# Usage: source "$(dirname "$0")/_utils.sh"

# Return UDID of the first booted iOS simulator, or $1 if provided
get_udid() {
  local arg="${1:-}"
  if [[ -n "$arg" && "$arg" != "booted" ]]; then
    # If it looks like a full UUID, use directly
    if [[ "$arg" =~ ^[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}$ ]]; then
      echo "$arg"
      return 0
    fi
    # Otherwise treat as device name (partial, case-insensitive)
    xcrun simctl list devices -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
name = sys.argv[1].lower()
booted = []
others = []
for rt, devs in data['devices'].items():
    if 'iOS' not in rt:
        continue
    for d in devs:
        if name in d['name'].lower():
            if d['state'] == 'Booted':
                booted.append(d['udid'])
            else:
                others.append(d['udid'])
result = booted[0] if booted else (others[0] if others else '')
print(result)
sys.exit(0 if result else 1)
" "$arg"
    return $?
  fi

  # Auto-detect first booted iOS simulator
  xcrun simctl list devices -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for rt, devs in data['devices'].items():
    if 'iOS' not in rt:
        continue
    for d in devs:
        if d['state'] == 'Booted':
            print(d['udid'])
            sys.exit(0)
sys.exit(1)
"
}

# Print JSON error and exit
die() {
  echo "{\"success\": false, \"error\": \"$*\"}"
  exit 1
}
