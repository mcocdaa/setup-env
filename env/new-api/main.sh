#!/bin/bash
# new-api env — deploy New API (LLM gateway) via Docker
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh new-api <command> [args...]

Commands:
  install     Pull Docker image and start New API container
              Defaults to calciumion/new-api:latest with SQLite.
              Use -t to specify a tag, --mysql for MySQL mode.

  -h, --help  Show this help message

Examples:
  main.sh new-api install
  main.sh new-api install -t v1.0.0-rc.20
  main.sh new-api install --mysql -t latest
  main.sh new-api install -h     (show install help)
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
        echo "Run 'main.sh new-api -h' for usage."
        exit 1
        ;;
esac
