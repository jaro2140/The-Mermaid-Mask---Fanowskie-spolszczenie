#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
PATCH_DIR="$REPO_DIR/_Patches/payload"

load_game_path() {
  if [[ -f "$REPO_DIR/game-path.env" ]]; then
    # shellcheck disable=SC1091
    source "$REPO_DIR/game-path.env"
  fi

  if [[ -z "${GAME_PATH:-}" ]]; then
    echo "GAME_PATH is not set. Copy game-path.env.example to game-path.env and set the path." >&2
    exit 1
  fi

  if [[ ! -d "$GAME_PATH" ]]; then
    echo "Game path does not exist: $GAME_PATH" >&2
    exit 1
  fi
}

require_patch_payload() {
  if [[ ! -d "$PATCH_DIR" ]]; then
    echo "Patch payload is missing: $PATCH_DIR" >&2
    exit 1
  fi
}
