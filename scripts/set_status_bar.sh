#!/usr/bin/env bash
# set_status_bar.sh — Override simulator status bar for clean screenshots
# Usage: ./set_status_bar.sh [--preset clean|testing|low_battery] [--clear] [--udid UDID]
# Preset "clean": 9:41, full battery, Wi-Fi — the classic Apple screenshot look

source "$(dirname "$0")/_utils.sh"

UDID=""; PRESET=""; CLEAR=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --udid)   UDID="$2"; shift 2 ;;
    --preset) PRESET="$2"; shift 2 ;;
    --clear)  CLEAR=true; shift ;;
    *) shift ;;
  esac
done

UDID=$(get_udid "$UDID") || die "No booted simulator found."

if $CLEAR; then
  xcrun simctl status_bar "$UDID" clear 2>&1
  echo "{\"success\": true, \"message\": \"Status bar restored to default\"}"
  exit 0
fi

case "$PRESET" in
  clean)
    xcrun simctl status_bar "$UDID" override \
      --time "9:41" \
      --batteryLevel 100 --batteryState charged \
      --dataNetwork wifi --wifiMode active --wifiBars 3 \
      --cellularMode notSupported 2>&1
    echo "{\"success\": true, \"preset\": \"clean\"}"
    ;;
  low_battery)
    xcrun simctl status_bar "$UDID" override \
      --batteryLevel 10 --batteryState discharging 2>&1
    echo "{\"success\": true, \"preset\": \"low_battery\"}"
    ;;
  testing)
    xcrun simctl status_bar "$UDID" override \
      --time "12:00" \
      --batteryLevel 80 --batteryState discharging \
      --dataNetwork 5g 2>&1
    echo "{\"success\": true, \"preset\": \"testing\"}"
    ;;
  *)
    die "Unknown preset: $PRESET. Use: clean, low_battery, testing, or --clear"
    ;;
esac
