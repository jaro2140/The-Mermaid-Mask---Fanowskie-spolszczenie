#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

load_game_path

BACKUP_DIR="$GAME_PATH/backup_pl"

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "Backup directory not found: $BACKUP_DIR" >&2
  exit 1
fi

echo "TODO: add restore rules for this game."
echo "Game path: $GAME_PATH"
echo "Backup dir: $BACKUP_DIR"
