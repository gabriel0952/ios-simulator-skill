#!/usr/bin/env bash
# health_check.sh — Check that all required tools are installed
# Usage: ./health_check.sh

FLUTTER="${FLUTTER_PATH:-$HOME/development/flutter/bin/flutter}"

echo "=== iOS Simulator Skill — Health Check ==="
echo ""

check() {
  local name="$1"; local cmd="$2"; local hint="$3"
  if eval "$cmd" &>/dev/null; then
    echo "  ✅ $name"
  else
    echo "  ❌ $name — $hint"
  fi
}

echo "Required:"
check "Xcode CLI tools"   "xcode-select -p"                        "Install Xcode from App Store"
check "xcrun simctl"      "xcrun simctl help"                      "Install Xcode"
check "Python 3"          "python3 --version"                      "Install: brew install python"

echo ""
echo "Optional (UI interaction):"
check "idb"               "idb help"                               "brew install idb-companion && pip install fb-idb"

echo ""
echo "Optional (Flutter):"
check "Flutter"           "\"$FLUTTER\" --version"                 "Install Flutter from https://flutter.dev"

echo ""
echo "Optional (visual_diff):"
check "Pillow"            "python3 -c 'import PIL'"                "pip install Pillow"

echo ""
echo "Booted simulator:"
UDID=$(xcrun simctl list devices -j 2>/dev/null | python3 -c "
import json,sys
data=json.load(sys.stdin)
for _,devs in data['devices'].items():
    for d in devs:
        if d['state']=='Booted' and d.get('isAvailable'):
            print(f\"  ✅ {d['name']} ({d['udid']})\")
            sys.exit(0)
print('  ⚠️  No simulator booted. Run: ./boot.sh \"iPhone 16 Pro\"')
" 2>/dev/null)
echo "$UDID"
