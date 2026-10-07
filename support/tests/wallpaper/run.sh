#!/bin/bash
# run.sh — set-wallpaper.sh against a fake awww and a throwaway HOME:
# what arguments does the daemon get for each transition.conf / WALL_POS
here=$(cd "$(dirname "$0")" && pwd)
script=$here/../../wallpaper/set-wallpaper.sh
fail=0
pass=0

run() {
    # run <conf-body|-> <WALL_POS|-> [fake awww exit rule]; echoes the last "img" argv
    local conf=$1 pos=$2 rule=${3:-}
    local h; h=$(mktemp -d)
    mkdir -p "$h/bin" "$h/.config/lucid" "$h/.cache"
    printf 'static' > "$h/.cache/current_theme"
    : > "$h/pic.jpg"
    cat > "$h/bin/awww" <<FAKE
#!/bin/bash
[ "\$1" = query ] && exit 0
echo "\$*" >> "$h/awww.log"
case "\$*" in *$rule*) [ -n "$rule" ] && exit 1;; esac
exit 0
FAKE
    chmod +x "$h/bin/awww"
    [ "$conf" != "-" ] && printf '%b' "$conf" > "$h/.config/lucid/wallpaper-transition.conf"
    local env=(HOME="$h" PATH="$h/bin:$PATH")
    [ "$pos" != "-" ] && env+=(WALL_POS="$pos")
    env "${env[@]}" bash "$script" "$h/pic.jpg" dark >/dev/null 2>&1
    LAST=$(grep '^img' "$h/awww.log" | tail -1)
    ALL=$(cat "$h/awww.log" 2>/dev/null)
    HOMEDIR=$h
}

check() { # check <name> <condition>
    if eval "$2"; then pass=$((pass+1)); else fail=1; echo "FAIL: $1"; echo "   last: $LAST"; fi
}

run - -
check "no conf -> today's fade" '[[ $LAST == *"--transition-type fade --transition-duration 1 --transition-fps 60"* ]]'

run 'TYPE=grow\nDURATION=2\nORIGIN=card\n' 0.4,0.6
check "grow + card origin passes pos" '[[ $LAST == *"--transition-type grow"* && $LAST == *"--transition-duration 2"* && $LAST == *"--transition-pos 0.4,0.6"* ]]'

run 'TYPE=wipe\nANGLE=90\n' -
check "wipe passes angle" '[[ $LAST == *"--transition-angle 90"* ]]'

run 'TYPE=fade\nORIGIN=card\n' 0.4,0.6
check "fade ignores WALL_POS" '[[ $LAST != *"--transition-pos"* ]]'

run 'TYPE=grow\nORIGIN=card\n' -
check "card origin without WALL_POS -> center" '[[ $LAST == *"--transition-pos center"* ]]'

run 'TYPE=fade; touch $HOME/pwned\n' -
check "metacharacters -> default type" '[[ $LAST == *"--transition-type fade"* && ! -e $HOMEDIR/pwned ]]'

run 'DURATION=-3\n' -
check "negative duration -> 1" '[[ $LAST == *"--transition-duration 1 "* ]]'
run 'DURATION=abc\n' -
check "non-numeric duration -> 1" '[[ $LAST == *"--transition-duration 1 "* ]]'
run 'DURATION=0\n' -
check "zero duration -> 1" '[[ $LAST == *"--transition-duration 1 "* ]]'

run 'TYPE=none\nBEZIER=0,0,1,1\n' -
check "none carries no bezier" '[[ $LAST != *"--transition-bezier"* ]]'

run 'TYPE=wave\nWAVE=30,40\n' -
check "wave passes wave size" '[[ $LAST == *"--transition-wave 30,40"* ]]'

run 'TYPE=fade\nBEZIER=0.1,0.2,0.3,0.4\n' - '--transition-bezier'
check "awww rejecting bezier -> retried without it" '[[ $(grep -c "^img" <<<"$ALL") == 2 && $LAST != *"--transition-bezier"* ]]'

run 'TYPE=grow\nORIGIN=cursor\n' -
check "cursor origin -> fractions from hyprctl" '[[ $LAST =~ --transition-pos\ [01](\.[0-9]+)?,[01](\.[0-9]+)?$ ]]'

echo "wallpaper tests: $pass passed"
exit $fail
