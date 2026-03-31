#!/usr/bin/env bash
# screen_map.sh — Map interactive UI elements using accessibility tree (requires idb)
# Usage: ./screen_map.sh [--udid UDID] [--verbose]
# Output: human-readable list of buttons, text fields, and labels

source "$(dirname "$0")/_utils.sh"

UDID=""; VERBOSE=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --udid) UDID="$2"; shift 2 ;;
    --verbose) VERBOSE=true; shift ;;
    *) shift ;;
  esac
done

UDID=$(get_udid "$UDID") || die "No booted simulator found."

if ! command -v idb &>/dev/null; then
  die "idb not found. Install: brew install idb-companion && pip install fb-idb"
fi

idb --udid "$UDID" ui describe-all --json 2>/dev/null | python3 -c "
import json, sys

verbose = sys.argv[1] == 'true'
try:
    elements = json.load(sys.stdin)
except json.JSONDecodeError:
    print('{\"success\": false, \"error\": \"Could not parse accessibility tree\"}')
    sys.exit(1)

interactive_types = ('button', 'textfield', 'securetextfield', 'switch', 'slider', 'cell', 'link')
results = []
for el in elements:
    el_type = str(el.get('type', el.get('class', ''))).lower()
    label = str(el.get('label', el.get('AXLabel', ''))).strip()
    is_interactive = any(t in el_type for t in interactive_types)
    if not is_interactive and not label:
        continue
    item = {'type': el_type, 'label': label}
    if verbose:
        frame = el.get('frame', {})
        item['frame'] = frame
    results.append(item)

print(json.dumps({'success': True, 'elements': results, 'count': len(results)}, indent=2))
" "$VERBOSE"
