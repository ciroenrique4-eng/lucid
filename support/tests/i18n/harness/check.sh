#!/bin/bash
# check.sh [LANG] — the I18n checks against a live harness instance
cd "$(dirname "$0")/../../../.."
export SP_ROOT=${SP_ROOT:-/tmp}
read H < <(bash support/tests/i18n/harness/run.sh "${1:-es_MX.UTF-8}")
sleep 3
PID=$(qs list --all | awk -v cfg="$H/shell.qml" '/Process ID/{p=$3} /Config path/{if ($3==cfg) print p}')
fail=0
g(){ qs ipc --pid $PID call bench get; }
want(){ local got; got=$(g); if [ "$got" = "$2" ]; then echo "ok   $1: $got"; else echo "FAIL $1: $got (want $2)"; fail=1; fi; }
if [ "${1:-}" = "C.UTF-8" ]; then want 6 "Battery|en|en_US"; else
want 1 "Batería|es|es_MX"; qs ipc --pid $PID call bench set en; sleep 0.5; want 2 "Battery|en|en_US"
qs ipc --pid $PID call bench set es; sleep 0.5; want 3 "Batería|es|es_MX"
sed -i 's/Batería/Pila/' $H/i18n/es.json; sleep 1; want 4 "Pila|es|es_MX"
printf '{"Battery": ' > $H/i18n/es.json; sleep 1; want 5 "Pila|es|es_MX"
grep -aq "i18n: .*es.json" $H/log && echo "ok   5: broken file warned" || { echo "FAIL 5: no warning"; fail=1; }
fi
bash support/tests/i18n/harness/stop.sh $H; sleep 1
qs list --all | grep -q "$H/shell.qml" && { echo "FAIL harness still running"; fail=1; }
exit $fail
