# Shared shell setup and helpers


# Generate truecolor ANSI escape sequence given a hex color code
#
# Parameters:
#   $1 Hex color code (#RRGGBB)
#   $2 Mode:
#       fg: foreground color (default)
#       bg: background color
#   $3 Bold:
#       0: disabled (default)
#       1: enabled
#
# Usage:
#   local NAME="$(color_hex2ansi "#88c0d0" fg 1)"
color_hex2ansi() {
    hex="${1#"#"}"
    mode="${2:-fg}"
    bold="${3:-0}"

    [ ${#hex} -eq 6 ] || return 1

    r=$((16#${hex%????}))

    tmp="${hex#??}"
    g=$((16#${tmp%??}))

    b=$((16#${hex##????}))

    case "$mode" in
        fg) code=38 ;;
        bg) code=48 ;;
        *) return 1 ;;
    esac

    if [ "$bold" -eq 1 ]; then
        printf '\\[\\e[1;%s;2;%d;%d;%dm\\]' \
            "$code" "$r" "$g" "$b"
    else
        printf '\\[\\e[%s;2;%d;%d;%dm\\]' \
            "$code" "$r" "$g" "$b"
    fi
}


# Safely prepend a directory to PATH only if it is not already present
#
# Usage:
#   path_prepend "$HOME/somedir/bin"
path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}


# Source *.sh files in a specified directory
#
# Note: does not recursively source *.sh files within sub-directories
#
# Usage:
#   load_rc_dir "$HOME/.shellrc"
load_rc_dir() {
    local dir="$1"
    local rc

    [ -d "$dir" ] || return

    for rc in "$dir"/*.sh; do
        [ -f "$rc" ] || continue

        . "$rc"
    done
}
