#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

load_game_path
require_patch_payload

BACKUP_DIR="$GAME_PATH/backup_pl"
mkdir -p "$BACKUP_DIR"

echo "TODO: add backup and copy rules for this game."
echo "Game path: $GAME_PATH"
echo "Patch payload: $PATCH_DIR"
echo "Backup dir: $BACKUP_DIR"
