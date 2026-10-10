#!/usr/bin/env bash
# wire-apps.sh [--report]
#
# hooks matugen up to the apps that need something of their own in place before
# it can theme them: a config directory, a browser profile. an app counts once
# it is really there - its command, or what it creates on first run.
#
# install.sh runs this once, but on a fresh machine the apps it installs in the
# same run have never been opened, so their directories do not exist yet and
# every one of them used to be skipped for good. render-templates.sh runs this
# before every render too, so an app installed or first opened later is picked
# up on the next theme or wallpaper change instead of never.
#
# an existing [templates.x] block is the user's and is always left alone.
# --report prints what was added, kept and skipped (install.sh); without it
# this is silent.

set -uo pipefail

REPORT=0
[[ "${1:-}" == "--report" ]] && REPORT=1

CFG="$HOME/.config/matugen/config.toml"
TPL='~/.config/matugen/templates'
STAMP="$(date +%Y%m%d-%H%M%S)"
[[ -f "$CFG" ]] || exit 0

ADDED=(); KEPT=(); SKIPPED=()

# a guard is one or more of dir:<path>, file:<path>, cmd:<name> split by |,
# and passes when any of them does
present() {
    local g
    local IFS='|'
    for g in $1; do
        case "$g" in
            always) return 0 ;;
            dir:*)  [[ -d "${g#dir:}" ]] && return 0 ;;
            file:*) [[ -f "${g#file:}" ]] && return 0 ;;
            cmd:*)  command -v "${g#cmd:}" &>/dev/null && return 0 ;;
        esac
    done
    return 1
}

has_block() {
    grep -q "^\[templates\.$1\]" "$CFG"
}

add() {
    local name=$1 input=$2 output=$3 guard=$4 hook=${5:-}
    if has_block "$name"; then
        KEPT+=("$name"); return 0
    fi
    present "$guard" || { SKIPPED+=("$name"); return 0; }
    mkdir -p "$(dirname "${output/#\~/$HOME}")"
    {
        printf '\n[templates.%s]\n' "$name"
        printf "input_path = '%s'\n" "$input"
        printf "output_path = '%s'\n" "$output"
        [[ -n "$hook" ]] && printf "post_hook = '%s'\n" "$hook" || true
    } >> "$CFG"
    ADDED+=("$name")
}

# the profile firefox-likes actually open: the [Install...] section names it.
# a bare glob is not enough - zen creates "Default (release)", the real one,
# next to an empty "Default Profile" that is never used
moz_profile() {
    local root=$1 ini="$1/profiles.ini" rel=""
    [[ -f "$ini" ]] || return 1
    rel=$(awk -F= '/^\[Install/ { inst = 1; next } /^\[/ { inst = 0 } inst && $1 == "Default" { print $2; exit }' "$ini")
    if [[ -z "$rel" ]]; then
        # no install section (an older profile layout): the one marked default
        rel=$(awk -F= '/^\[Profile/ { p = ""; d = 0 } $1 == "Path" { p = $2 } $1 == "Default" && $2 == "1" { d = 1 } d && p != "" { print p; exit }' "$ini")
    fi
    [[ -n "$rel" ]] || return 1
    if [[ "$rel" == /* ]]; then
        [[ -d "$rel" ]] && printf '%s\n' "$rel"
    else
        [[ -d "$root/$rel" ]] && printf '%s\n' "$root/$rel"
    fi
}

# firefox-likes ignore userChrome.css until this pref is on. user.js is read
# on every start and outranks prefs.js, which the browser rewrites itself
moz_allow_userchrome() {
    local prof=$1 pref='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
    grep -qF "$pref" "$prof/user.js" 2>/dev/null && return 0
    printf '%s\n' "// added by Lucid: lets the browser read chrome/userChrome.css" "$pref" >> "$prof/user.js"
}

STARSHIP_HOOK='for sh in fish bash zsh; do pkill -WINCH -x "$sh" 2>/dev/null; done; true'

add hyprland       "$TPL/hyprland-colors.lua"  '~/.config/hypr/colors.conf'                 "dir:$HOME/.config/hypr"
add kitty          "$TPL/kitty.conf"           '~/.config/kitty/matugen-colors.conf'        "cmd:kitty" 'killall -SIGUSR1 kitty 2>/dev/null || true'
add starship       "$TPL/starship-colors.toml" '~/.config/starship.toml'                    "cmd:starship" "$STARSHIP_HOOK"
add rofi           "$TPL/rofi-colors.rasi"     '~/.config/rofi/colors.rasi'                 "dir:$HOME/.config/rofi"
add waybar         "$TPL/colors.css"           '~/.config/waybar/colors.css'                "dir:$HOME/.config/waybar"
add swaync         "$TPL/colors.css"           '~/.config/swaync/colors.css'                "dir:$HOME/.config/swaync"
add wlogout        "$TPL/colors.css"           '~/.config/wlogout/colors.css'               "dir:$HOME/.config/wlogout"
add ags            "$TPL/ags-colors.scss"      '~/.config/ags/style/_colors.scss'           "dir:$HOME/.config/ags"
# vesktop reads every css in its themes folder, which add() creates, so the
# app being installed is enough; it need not have been opened yet
add vesktop        "$TPL/midnight-discord.css" '~/.config/vesktop/themes/midnight-discord.css' "cmd:vesktop|dir:$HOME/.config/vesktop"
add pywalfox       "$TPL/pywalfox-colors.json" '~/.cache/wal/colors.json'                   "cmd:pywalfox" 'pywalfox update'
add steam-material "$TPL/steam-material.css"   '~/.local/share/Steam/millennium/themes/Material-Theme/css/main/colors/matugen.css' \
                   "dir:$HOME/.local/share/Steam/millennium/themes/Material-Theme"

FF_PROFILE=$(moz_profile "$HOME/.mozilla/firefox" || true)
if [[ -n "$FF_PROFILE" ]]; then
    add firefox-website-colors "$TPL/firefox-colors.css" "$FF_PROFILE/chrome/colors.css" always
else
    has_block firefox-website-colors && KEPT+=(firefox-website-colors) || SKIPPED+=(firefox-website-colors)
fi

ZEN_PROFILE=$(moz_profile "$HOME/.config/zen" || moz_profile "$HOME/.zen" || true)
if [[ -n "$ZEN_PROFILE" ]]; then
    if ! has_block zen; then
        # the template writes the whole userChrome.css. one Lucid did not
        # write is somebody's own work, so it is kept aside, not overwritten
        uc="$ZEN_PROFILE/chrome/userChrome.css"
        if [[ -s "$uc" ]] && ! grep -q "zen-userchrome.css" "$uc"; then
            cp "$uc" "$uc.backup-$STAMP"
        fi
    fi
    add zen "$TPL/zen-userchrome.css" "$ZEN_PROFILE/chrome/userChrome.css" always
    moz_allow_userchrome "$ZEN_PROFILE"
else
    has_block zen && KEPT+=(zen) || SKIPPED+=(zen)
fi

if (( REPORT )); then
    dim=$'\e[2m'; r=$'\e[0m'
    (( ${#ADDED[@]} ))   && printf '  matugen added:   %s\n' "${ADDED[*]}"
    (( ${#KEPT[@]} ))    && printf '  %smatugen kept:    %s%s\n' "$dim" "${KEPT[*]}" "$r"
    (( ${#SKIPPED[@]} )) && printf '  %smatugen skipped: %s (not installed yet - wired on the next theme change once they are)%s\n' "$dim" "${SKIPPED[*]}" "$r"
fi
exit 0
