#!/bin/bash
# run.sh — every tst_*.qml in this folder through qmltestrunner (offscreen)
cd "$(dirname "$0")"
fail=0
for t in tst_*.qml; do
    out=$(QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -input "$t" 2>&1)
    echo "$out" | grep -E "^(FAIL|Totals)" | sed "s|^|$t: |"
    echo "$out" | grep -q "0 failed" || fail=1
done
exit $fail
