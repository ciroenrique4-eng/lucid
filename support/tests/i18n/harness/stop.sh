#!/bin/bash
# stop.sh <dir> — kills only the harness instance whose config is <dir>/shell.qml
cfg="$1/shell.qml"
for p in $(qs list --all 2>/dev/null | awk -v cfg="$cfg" '/Process ID/{p=$3} /Config path/{if ($3==cfg) print p}'); do kill -TERM "$p"; done
