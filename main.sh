#!/bin/bash
# =============================================================================
# main.sh — Installation router
# =============================================================================
# Usage:
#   ./main.sh                          # List available environments
#   ./main.sh -h                       # Show this help
#   ./main.sh <env> [command] [args...]
#
# Examples:
#   ./main.sh docker install           # Install Docker
#   ./main.sh docker mirror            # Configure Docker mirror
#   ./main.sh docker -h                # Show docker env help
#   ./main.sh uv install               # Install uv
#   ./main.sh npm mirror               # Configure npm mirror
# =============================================================================

set -e

ROOT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: $0 [env] [command] [args...]

A modular environment installation router.
Each environment lives under env/<name>/ with its own main.sh.

Without arguments, lists all available environments and their commands.

Options:
  -h, --help    Show this help message

Examples:
  $0                        List all environments
  $0 docker install         Install Docker Engine
  $0 docker mirror          Configure Docker registry mirrors
  $0 docker -h              Show docker sub-commands
  $0 uv install             Install uv (Python package manager)
  $0 uv mirror              Configure PyPI mirror for uv
  $0 npm install            Install Node.js + npm
  $0 npm mirror             Configure npm registry mirror

Each env/<name>/main.sh also supports -h for its own help.
EOF
}

ENV_NAME="${1:-}"

# -h / --help at root level
if [ "$ENV_NAME" = "-h" ] || [ "$ENV_NAME" = "--help" ]; then
    show_help
    exit 0
fi

COMMAND="${2:-install}"

# Shift away env name and command so env/main.sh sees only [args...]
shift 2 2>/dev/null || true

if [ -z "$ENV_NAME" ]; then
    echo "Usage: $0 <env> [command] [args...]"
    echo "       $0 -h  for detailed help"
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
