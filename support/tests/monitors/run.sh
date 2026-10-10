#!/bin/bash
# run.sh — the Displays map driven with a pointer, against the stand-ins in qs/
cd "$(dirname "$0")"
out=$(QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -import . -input tst_monitormap.qml 2>&1)
echo "$out" | grep -E "^(FAIL|Totals)|Actual|Expected|Loc:"
echo "$out" | grep -q " 0 failed"
