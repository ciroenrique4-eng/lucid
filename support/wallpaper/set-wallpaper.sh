#!/usr/bin/env bash
# set-wallpaper.sh <path-to-image> [dark|light]
#
# sets the wallpaper, then regenerates colours if the active theme derives
# them from the image. ~/.cache/current_theme decides:
#   matugen  — matugen works out the scheme, render-templates.sh renders every
#              template in its config from it
#   pywal    — wal extracts, gen-pywal-palette.py maps it to material roles
#   anything else — a static theme owns its palette, so colours are left alone
#
# the mode argument is remembered in ~/.cache/current_mode, so a later wallpaper
# change keeps whichever of light/dark the desktop is currently in instead of
# silently dropping back to dark.
#
# the wallpaper is set first because it is the only step you actually see.
# ~/.config/lucid/wallpaper-outputs.conf, if it exists, overrides single outputs.

set -euo pipefail

WALLPAPER="${1:-}"
CACHE_DIR="$HOME/.cache"
CURRENT_WALL_FILE="$CACHE_DIR/current_wallpaper"
CURRENT_THEME_FILE="$CACHE_DIR/current_theme"
CURRENT_MODE_FILE="$CACHE_DIR/current_mode"
LUCID_DIR="$HOME/.config/lucid"
WALL_RULES_FILE="$LUCID_DIR/wallpaper-outputs.conf"

CURRENT_THEME="$(cat "$CURRENT_THEME_FILE" 2>/dev/null || echo matugen)"
MODE="${2:-$(cat "$CURRENT_MODE_FILE" 2>/dev/null || echo dark)}"

usage() {
    echo "usage: $(basename "$0") <path-to-image> [dark|light]"
    exit 1
}

[[ -z "$WALLPAPER" ]] && { echo "error: no wallpaper path given" >&2; usage; }

WALLPAPER="${WALLPAPER/#\~/$HOME}"

[[ -f "$WALLPAPER" ]] || { echo "error: file not found: $WALLPAPER" >&2; exit 1; }

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
    echo "error: mode must be dark or light (got: $MODE)" >&2
    usage
fi

# wallpaper daemon: awww, falling back to swww
if command -v awww &>/dev/null; then
    WP_CLI=awww; WP_DAEMON=awww-daemon
elif command -v swww &>/dev/null; then
    WP_CLI=swww; WP_DAEMON="swww-daemon"
else
    echo "error: neither awww nor swww is installed" >&2
    exit 1
fi

if ! "$WP_CLI" query &>/dev/null; then
    "$WP_DAEMON" &>/dev/null &
    sleep 0.5
fi

DEFAULT_TRANS=(--transition-type fade --transition-duration 1 --transition-fps 60)
TRANS_ARGS=("${DEFAULT_TRANS[@]}")

# the transition chosen in Settings -> Theme, written by the shell to
# transition.conf as KEY=value lines. read line by line, never sourced: only the
# keys below are looked at and every value must match its pattern, so a damaged
# or hostile file falls back to the plain fade. WALL_POS (x,y as fractions, y
# from the bottom) is the picker saying where the chosen card sits.
load_transition() {
    local conf="$LUCID_DIR/wallpaper-transition.conf" k v
    local type=fade duration=1 angle="" origin=center bezier="" wave=""
    if [[ -f "$conf" ]]; then
        while IFS='=' read -r k v || [[ -n "$k" ]]; do
            case "$k" in
            TYPE)
                [[ "$v" =~ ^(none|simple|fade|left|right|top|bottom|wipe|wave|grow|center|any|outer|random)$ ]] && type=$v ;;
            DURATION)
                [[ "$v" =~ ^[0-9]+([.][0-9]+)?$ ]] && awk -v d="$v" 'BEGIN{exit !(d > 0)}' && duration=$v ;;
            ANGLE) [[ "$v" =~ ^[0-9]{1,3}$ ]] && angle=$v ;;
            ORIGIN) [[ "$v" =~ ^(center|card|cursor)$ ]] && origin=$v ;;
            BEZIER) [[ "$v" =~ ^[0-9.]+(,[0-9.]+){3}$ ]] && bezier=$v ;;
            WAVE) [[ "$v" =~ ^[0-9]+,[0-9]+$ ]] && wave=$v ;;
            esac
        done < "$conf"
    fi
    TRANS_ARGS=(--transition-type "$type" --transition-duration "$duration" --transition-fps 60)
    [[ "$type" == wipe || "$type" == wave ]] && [[ -n "$angle" ]] && TRANS_ARGS+=(--transition-angle "$angle")
    [[ "$type" == wave && -n "$wave" ]] && TRANS_ARGS+=(--transition-wave "$wave")
    [[ "$type" != none && "$type" != simple && -n "$bezier" ]] && TRANS_ARGS+=(--transition-bezier "$bezier")
    if [[ "$type" == grow || "$type" == outer ]]; then
        local pos=center
        if [[ "$origin" == card && "${WALL_POS:-}" =~ ^[0-9]*[.]?[0-9]+,[0-9]*[.]?[0-9]+$ ]]; then
            pos=$WALL_POS
        elif [[ "$origin" == cursor ]] && command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
            local cur mon
            cur=$(hyprctl cursorpos 2>/dev/null | tr -d ' ')
            mon=$(hyprctl monitors -j 2>/dev/null | jq -r '(map(select(.focused))[0] // .[0]) | "\(.x) \(.y) \(.width / .scale) \(.height / .scale)"')
            if [[ "$cur" =~ ^[0-9]+,[0-9]+$ && -n "$mon" ]]; then
                pos=$(awk -v c="$cur" -v m="$mon" 'BEGIN{split(c,a,",");split(m,b," ");
                    x=(a[1]-b[1])/b[3]; y=1-(a[2]-b[2])/b[4];
                    if (x<0) x=0; if (x>1) x=1; if (y<0) y=0; if (y>1) y=1;
                    printf "%.3f,%.3f", x, y}')
            fi
        fi
        TRANS_ARGS+=(--transition-pos "$pos")
    fi
}
load_transition

set_output() {
    # $1 image, $2 output ("" for every one), rest passed to the daemon. if the
    # daemon refuses the chosen transition the plain fade still changes the picture
    local img="$1" out="$2"; shift 2
    local target=()
    [[ -n "$out" ]] && target=(-o "$out")
    "$WP_CLI" img "$img" ${target[@]+"${target[@]}"} "${TRANS_ARGS[@]}" "$@" \
        || "$WP_CLI" img "$img" ${target[@]+"${target[@]}"} "${DEFAULT_TRANS[@]}" "$@" \
        || { [[ -n "$out" ]] && echo "warning: could not set the wallpaper on $out" >&2; }
}

# WALL_DEMO=1 is Settings -> Theme -> Try transition. The picture is already on
# screen, so a transition to it would show nothing: put a flat colour taken from
# the picture up first, then run the real transition. Only the background moves;
# the colours and the saved wallpaper stay as they are.
if [[ -n "${WALL_DEMO:-}" ]]; then
    DEMO_HEX=""
    command -v magick &>/dev/null && DEMO_HEX=$(magick "$WALLPAPER" -resize '1x1!' -modulate 55 -format '%[hex:u.p{0,0}]' info: 2>/dev/null | tr -dc '0-9A-Fa-f' | head -c 6 | tr a-f A-F)
    [[ ${#DEMO_HEX} -eq 6 ]] || DEMO_HEX=101018
    "$WP_CLI" img "0x$DEMO_HEX" --transition-type none &>/dev/null || true
    sleep 0.3
fi

# per-output overrides, one rule a line:  <output>  <extra args for img>
# any argument that is a file becomes that output's image, the rest are passed
# through, so a portrait screen can letterbox instead of crop, or show its own
# picture. every other output gets $WALLPAPER, in the same pass, so nothing
# fades twice
declare -A WALL_RULES=()
if [[ -f "$WALL_RULES_FILE" ]]; then
    while read -r RULE_OUT RULE_ARGS; do
        [[ -z "${RULE_OUT:-}" || "$RULE_OUT" == \#* ]] && continue
        WALL_RULES["$RULE_OUT"]="$RULE_ARGS"
    done < "$WALL_RULES_FILE"
fi

OUTPUTS=()
if [[ ${#WALL_RULES[@]} -gt 0 ]] && command -v hyprctl &>/dev/null; then
    while read -r NAME; do
        [[ -n "$NAME" ]] && OUTPUTS+=("$NAME")
    done < <(hyprctl monitors | awk '/^Monitor /{print $2}')
fi

if [[ ${#OUTPUTS[@]} -eq 0 ]]; then
    set_output "$WALLPAPER" ""
else
    for OUT in "${OUTPUTS[@]}"; do
        OUT_IMG="$WALLPAPER"
        OUT_ARGS=()
        for ARG in ${WALL_RULES[$OUT]:-}; do
            ARG="${ARG/#\~/$HOME}"
            if [[ -f "$ARG" ]]; then
                OUT_IMG="$ARG"
            else
                OUT_ARGS+=("$ARG")
            fi
        done
        set_output "$OUT_IMG" "$OUT" ${OUT_ARGS[@]+"${OUT_ARGS[@]}"}
    done
fi

[[ -n "${WALL_DEMO:-}" ]] && exit 0

mkdir -p "$CACHE_DIR"
printf '%s' "$WALLPAPER" > "$CURRENT_WALL_FILE"
printf '%s' "$MODE" > "$CURRENT_MODE_FILE"

case "$CURRENT_THEME" in
matugen)
    if ! command -v matugen &>/dev/null; then
        echo "warning: matugen not installed, colours unchanged" >&2
        exit 0
    fi
    # --source-color-index keeps it non-interactive, so it can't hang on a
    # picker prompt it will never receive from a keybind
    if [[ -x "$LUCID_DIR/render-templates.sh" ]]; then
        # the scheme type, contrast and starting colour set in Settings -> Theme
        MATUGEN_SCHEME=scheme-tonal-spot
        MATUGEN_CONTRAST=0
        SOURCE_INDEX=0
        if [[ -f "$LUCID_DIR/matugen-options.sh" ]]; then
            # shellcheck source=../lucid/matugen-options.sh
            . "$LUCID_DIR/matugen-options.sh"
            SOURCE_INDEX=$(matugen_source_index "$WALLPAPER")
        fi
        # matugen only works out the scheme; render-templates.sh renders the
        # templates from it one at a time, and reloads hyprland if one of them
        # wrote its colours
        COLOURS=$(mktemp)
        scheme_from() {
            matugen image "$WALLPAPER" -m "$MODE" -t "$MATUGEN_SCHEME" --contrast "$MATUGEN_CONTRAST" \
                --source-color-index "$1" --dry-run --json hex --include-image-in-json true -q > "$COLOURS"
        }
        # an index past the colours this image has falls back to its most
        # dominant, quietly: matugen's complaint about it is expected
        if { [[ "$SOURCE_INDEX" != 0 ]] && scheme_from "$SOURCE_INDEX" 2>/dev/null; } || scheme_from 0; then
            "$LUCID_DIR/render-templates.sh" "$COLOURS" "$MODE" matugen || true
        else
            echo "warning: matugen could not read $WALLPAPER, colours unchanged" >&2
        fi
        rm -f "$COLOURS"
    else
        matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0
        hyprctl reload &>/dev/null || true
    fi
    # matugen writes the palette from its own templates and never reaches
    # apply-theme.sh, so this is the only place the login screen can follow it
    "$LUCID_DIR/sync-sddm.sh" 2>/dev/null || true
    ;;
pywal)
    if ! command -v wal &>/dev/null; then
        echo "warning: pywal not installed, colours unchanged" >&2
        exit 0
    fi
    # -n leaves the wallpaper alone, it is already set above; -l extracts a
    # light terminal palette, which is what the light branch of the generator
    # expects to be handed
    WAL_ARGS=(-i "$WALLPAPER" -n -s -t -e -q)
    [[ "$MODE" == "light" ]] && WAL_ARGS+=(-l)
    wal "${WAL_ARGS[@]}" || echo "warning: wal failed" >&2
    if "$LUCID_DIR/gen-pywal-palette.py" "$MODE"; then
        "$LUCID_DIR/apply-theme.sh" pywal "$MODE"
    else
        echo "warning: pywal palette generation failed" >&2
    fi
    hyprctl reload &>/dev/null || true
    ;;
*)
    echo "static theme ($CURRENT_THEME) — colours unchanged"
    # the palette stays put but the login screen still carries the wallpaper
    "$LUCID_DIR/sync-sddm.sh" 2>/dev/null || true
    ;;
esac

echo "done: $WALLPAPER ($MODE, theme: $CURRENT_THEME)"
