#!/bin/bash
# npm-codex env — @anthropic-ai/codex
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh npm-codex <command>

Commands:
  install     Install @anthropic-ai/codex globally via npm
              Requires npm to be installed first (main.sh npm install).

  -h, --help  Show this help message

Examples:
  main.sh npm-codex install
  main.sh npm-codex install -h (show install help)
EOF
}

COMMAND="${1:-install}"

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    show_help
    exit 0
fi

shift

case "$COMMAND" in
    install)
        exec bash "$ENV_DIR/install.sh" "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'main.sh npm-codex -h' for usage."
        exit 1
        ;;
esac
