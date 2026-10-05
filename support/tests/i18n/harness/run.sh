#!/bin/bash
# run.sh [LANG] — copies the worktree to a scratch dir with this harness as its
# shell.qml, a test es.json and a fake HOME, starts it and prints its dir.
# stop.sh <dir> kills that instance (by its config path only)
set -eu
here=$(cd "$(dirname "$0")" && pwd)
wt=$(cd "$here/../../../.." && pwd)
h=$(mktemp -d "${SP_ROOT:-/tmp}/i18n.XXXX")
tar -C "$wt" --exclude=.git --exclude=.superpowers --exclude=wallpapers --exclude=assets --exclude=support --exclude=docs -cf - . | tar -C "$h" -xf -
cp "$here/shell.qml" "$h/shell.qml"
mkdir -p "$h/i18n"
printf '{\n  "_meta": { "name": "Español", "locale": "es" },\n  "Battery": "Batería"\n}\n' > "$h/i18n/es.json"
mkdir -p "$h/home/.config/quickshell/lucidprefs"
env -u LC_ALL -u LC_MESSAGES HOME="$h/home" LANG="${1:-es_MX.UTF-8}" qs -p "$h/shell.qml" > "$h/log" 2>&1 &
echo "$h"
