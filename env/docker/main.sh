#!/bin/bash
# Docker env — main entry point
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
        echo "  install   Download and install Docker Engine"
        echo "  mirror    Configure Docker registry mirrors (daemon.json)"
        exit 1
        ;;
esac
