#!/bin/bash
# docker env — install Docker Engine & configure mirror
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh docker <command> [args...]

Commands:
  install     Download and install Docker Engine
              Downloads the official get.docker.com script,
              patches out -qq flags, and runs the installer.

  mirror      Configure Docker registry mirrors via /etc/docker/daemon.json
              Backs up existing daemon.json before overwriting.

  -h, --help  Show this help message

Examples:
  main.sh docker install
  main.sh docker mirror
  main.sh docker install -h     (show install help)
EOF
}

COMMAND="${1:-install}"

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    show_help
    exit 0
fi

shift

case "$COMMAND" in
    install|mirror)
        exec bash "$ENV_DIR/$COMMAND.sh" "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'main.sh docker -h' for usage."
        exit 1
        ;;
esac
