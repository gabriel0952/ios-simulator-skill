#!/usr/bin/env bash
# list_simulators.sh — List all available iOS simulators
# Usage: ./list_simulators.sh
# Output: JSON array of simulators with name, udid, state, runtime

xcrun simctl list devices -j 2>/dev/null | python3 -c "
import json, sys

data = json.load(sys.stdin)
results = []
for runtime, devices in data['devices'].items():
    if 'iOS' not in runtime:
        continue
    # human-readable runtime: com.apple.CoreSimulator.SimRuntime.iOS-18-2 -> iOS 18.2
    rt_label = runtime.replace('com.apple.CoreSimulator.SimRuntime.', '').replace('-', ' ', 1).replace('-', '.')
    for d in devices:
        if d.get('isAvailable', False):
            results.append({
                'name': d['name'],
                'udid': d['udid'],
                'state': d['state'],
                'runtime': rt_label,
            })
print(json.dumps({'success': True, 'simulators': results}, indent=2))
"
