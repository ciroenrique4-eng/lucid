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
want 1 "Batería|es|es_MX"
has(){ local got; got=$(qs ipc --pid $PID call bench search "$2"); case ";$got;" in *";$3;"*) echo "ok   $1: '$2' finds $3";; *) echo "FAIL $1: '$2' -> $got (want $3)"; fail=1;; esac; }
has s1 idioma Idioma
has s2 language Idioma
has s3 diseno "Diseño de barra"
has s4 "bar style" "Diseño de barra"; qs ipc --pid $PID call bench set en; sleep 0.5; want 2 "Battery|en|en_US"
qs ipc --pid $PID call bench set es; sleep 0.5; want 3 "Batería|es|es_MX"
sed -i 's/Batería/Pila/' $H/i18n/es.json; sleep 1; want 4 "Pila|es|es_MX"
printf '{"Battery": ' > $H/i18n/es.json; sleep 1; want 5 "Pila|es|es_MX"
grep -aq "i18n: .*es.json" $H/log && echo "ok   5: broken file warned" || { echo "FAIL 5: no warning"; fail=1; }
fi
bash support/tests/i18n/harness/stop.sh $H; sleep 1
qs list --all | grep -q "$H/shell.qml" && { echo "FAIL harness still running"; fail=1; }
exit $fail
