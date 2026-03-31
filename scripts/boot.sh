#!/usr/bin/env bash
# boot.sh — Boot a simulator and open Simulator.app
# Usage: ./boot.sh <udid_or_name>
# Example: ./boot.sh "iPhone 16 Pro"
#          ./boot.sh "A1B2C3D4-..."

source "$(dirname "$0")/_utils.sh"

UDID=$(get_udid "${1:-}") || die "No matching simulator found for: ${1:-}. Run list_simulators.sh to see available devices."

STATE=$(xcrun simctl list devices -j | python3 -c "
import json,sys
udid = sys.argv[1]
data=json.load(sys.stdin)
for _,devs in data['devices'].items():
    for d in devs:
        if d['udid']==udid:
            print(d['state']); sys.exit(0)
" "$UDID")

if [[ "$STATE" == "Booted" ]]; then
  echo "{\"success\": true, \"message\": \"Already booted\", \"udid\": \"$UDID\"}"
  open -a Simulator 2>/dev/null
  exit 0
fi

xcrun simctl boot "$UDID" 2>&1
open -a Simulator 2>/dev/null
echo "{\"success\": true, \"message\": \"Booted\", \"udid\": \"$UDID\"}"
