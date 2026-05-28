# Helper for initialiting and managing SSH port-forwarding tunnels
#
# Usage:
#   ssh-tunnel direct <remote_host> [local_port] [remote_port]
#   ssh-tunnel jump   <login_host> <node_host> [local_port] [remote_port]
#   ssh-tunnel list
#   ssh-tunnel stop <name|all>
ssh-tunnel() {
    local TUNNEL_DIR="${HOME}/.ssh/tunnels"
    mkdir -p "$TUNNEL_DIR"

    local cmd="${1:-help}"
    [ "$#" -gt 0 ] && shift

    case "$cmd" in
        direct)
            local REMOTE="$1"
            local L_PORT="${2:-8000}"
            local R_PORT="${3:-8000}"

            if [ -z "$REMOTE" ]; then
                echo "Usage: ssh-tunnel direct <remote_host> [local_port] [remote_port]"
                return 1
            fi

            local NAME="direct.${REMOTE}.${L_PORT}.${R_PORT}"
            local SOCK="${TUNNEL_DIR}/${NAME}.sock"

            echo "Forwarding localhost:${L_PORT} → ${REMOTE}:${R_PORT}"

            ssh -fN \
                -M -S "$SOCK" \
                -L "${L_PORT}:localhost:${R_PORT}" \
                "$REMOTE"

            ;;

        jump)
            local LOGIN="$1"
            local NODE="$2"
            local L_PORT="${3:-8000}"
            local R_PORT="${4:-8000}"

            if [ -z "$LOGIN" ] || [ -z "$NODE" ]; then
                echo "Usage: ssh-tunnel jump <login_host> <node_host> [local_port] [remote_port]"
                return 1
            fi

            local NAME="jump.${LOGIN}.${NODE}.${L_PORT}.${R_PORT}"
            local SOCK="${TUNNEL_DIR}/${NAME}.sock"

            echo "Forwarding localhost:${L_PORT} → ${NODE}:${R_PORT} via ${LOGIN}"

            ssh -fN \
                -M -S "$SOCK" \
                -L "${L_PORT}:${NODE}:${R_PORT}" \
                "$LOGIN"

            ;;

        list)
            echo "Active SSH tunnels:"
            local found=0

            # Enable local nullglob
            setopt local_options null_glob 2>/dev/null || true
            shopt -s nullglob 2>/dev/null || true

            for sock in "$TUNNEL_DIR"/*.sock; do
                [ -e "$sock" ] || continue

                if ssh -S "$sock" -O check dummy 2>/dev/null; then
                    found=1
                    echo "  $(basename "$sock" .sock)"
                else
                    rm -f "$sock"
                fi
            done

            [ "$found" -eq 0 ] && echo "  none"
            ;;

        stop)
            local TARGET="$1"

            if [ -z "$TARGET" ]; then
                echo "Usage: ssh-tunnel stop <name|all>"
                echo "Run: ssh-tunnel list"
                return 1
            fi

            if [ "$TARGET" = "all" ]; then
                for sock in "$TUNNEL_DIR"/*.sock; do
                    [ -e "$sock" ] || continue
                    ssh -S "$sock" -O exit dummy 2>/dev/null
                    rm -f "$sock"
                done
                echo "Stopped all tunnels."
                return 0
            fi

            local SOCK="${TUNNEL_DIR}/${TARGET}.sock"

            if [ ! -e "$SOCK" ]; then
                echo "No tunnel named: $TARGET"
                echo "Run: ssh-tunnel list"
                return 1
            fi

            ssh -S "$SOCK" -O exit dummy 2>/dev/null
            rm -f "$SOCK"
            echo "Stopped tunnel: $TARGET"
            ;;

        help|"")
            cat <<EOF
Usage:
  ssh-tunnel direct <remote_host> [local_port] [remote_port]
  ssh-tunnel jump   <login_host>  <node_host> [local_port] [remote_port]
  ssh-tunnel list
  ssh-tunnel stop   <name|all>
  ssh-tunnel help

Examples:
  ssh-tunnel direct host 8000 8000
  ssh-tunnel jump login nodexx 8000 8000
  ssh-tunnel list
  ssh-tunnel stop jump.login.nodexx.8000.8000
  ssh-tunnel stop all
EOF
            return 1
            ;;
    esac

    if [ $? -eq 0 ] && [ "$cmd" != "list" ] && [ "$cmd" != "stop" ]; then
        echo "Tunnel established: http://localhost:${L_PORT}"
        echo "Name: $NAME"
    fi
}
