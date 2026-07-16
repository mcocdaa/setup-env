#!/bin/bash
# =============================================================================
# main.sh — Installation router
# =============================================================================
# Usage:
#   ./main.sh <env> [command] [args...]
#
#   ./main.sh docker install      # Install Docker
#   ./main.sh docker mirror       # Configure Docker mirror
#   ./main.sh uv install          # Install uv
#   ./main.sh npm mirror          # Configure npm mirror
#   ./main.sh                     # List available environments
# =============================================================================

set -e

ROOT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

ENV_NAME="${1:-}"
COMMAND="${2:-install}"

# Shift away env name so env/main.sh sees only [command, args...]
shift 2>/dev/null || true

if [ -z "$ENV_NAME" ]; then
    echo "Usage: $0 <env> [command] [args...]"
    echo ""
    echo "Available environments:"
    for d in "$ROOT_DIR"/env/*/; do
        [ -d "$d" ] || continue
        name="$(basename "$d")"
        printf "  %-16s" "$name"
        # Print available commands in this env
        cmds=()
        for f in "$d"*.sh; do
            [ -f "$f" ] || continue
            fname="$(basename "$f" .sh)"
            [ "$fname" = "main" ] && continue
            # Skip downloaded helper scripts (e.g. install_docker.sh)
            case "$fname" in install_*) continue ;; esac
            cmds+=("$fname")
        done
        if [ ${#cmds[@]} -gt 0 ]; then
            printf " (%s)" "$(IFS=', '; echo "${cmds[*]}")"
        fi
        echo
    done
    exit 0
fi

ENV_MAIN="$ROOT_DIR/env/$ENV_NAME/main.sh"

if [ ! -f "$ENV_MAIN" ]; then
    echo "ERROR: Unknown environment '$ENV_NAME'"
    echo "       No main.sh found at env/$ENV_NAME/main.sh"
    echo ""
    echo "Available environments:"
    for d in "$ROOT_DIR"/env/*/; do
        [ -d "$d" ] || continue
        echo "  - $(basename "$d")"
    done
    exit 1
fi

# Route to the env's main.sh
exec bash "$ENV_MAIN" "$COMMAND" "$@"
