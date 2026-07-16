#!/bin/bash
# npm env — main entry point
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
COMMAND="${1:-install}"
shift 2>/dev/null || true

case "$COMMAND" in
    install)
        exec bash "$ENV_DIR/install.sh" "$@"
        ;;
    mirror)
        exec bash "$ENV_DIR/mirror.sh" "$@"
        ;;
    *)
        echo "Usage: $0 {install|mirror}"
        echo "  install   Install Node.js + npm (via apt with mirror)"
        echo "  mirror    Configure npm registry mirror"
        exit 1
        ;;
esac
