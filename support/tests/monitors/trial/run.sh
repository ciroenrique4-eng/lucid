#!/bin/bash
# run.sh — the real Monitors.qml (trial, place) against stand-ins for Quickshell
cd "$(dirname "$0")"
cp ../../../../Monitors.qml stubs/qs/Monitors.qml
out=$(QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -import stubs -input tst_trial.qml 2>&1)
rm -f stubs/qs/Monitors.qml
echo "$out" | grep -E "^(FAIL|Totals)|Actual|Expected|Loc:|QWARN"
echo "$out" | grep -q " 0 failed"
