#!/bin/bash
# npm-claude env — main entry point
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
COMMAND="${1:-install}"
shift 2>/dev/null || true

case "$COMMAND" in
    install)
        exec bash "$ENV_DIR/install.sh" "$@"
        ;;
    *)
        echo "Usage: $0 {install}"
        echo "  install   Install @anthropic-ai/claude-code via npm"
        exit 1
        ;;
esac
