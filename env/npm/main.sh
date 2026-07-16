#!/bin/bash
# npm env — Node.js + npm
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh npm <command> [args...]

Commands:
  install     Install Node.js + npm via apt
              Optionally configure apt mirror first: APT_MIRROR=<url> main.sh npm install

  mirror      Configure npm registry mirror
              Default: https://registry.npmmirror.com
              Usage: main.sh npm mirror [registry_url]

  -h, --help  Show this help message

Examples:
  main.sh npm install
  APT_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/ubuntu main.sh npm install
  main.sh npm mirror
  main.sh npm mirror https://registry.npmjs.org
  main.sh npm install -h       (show install help)
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
        echo "Run 'main.sh npm -h' for usage."
        exit 1
        ;;
esac
