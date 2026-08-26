#!/usr/bin/env bash
# Shared functions used by the Linux/SteamOS installers.
#
# Wszystkie sciezki sa liczone wzgledem folderu _Installers (jeden poziom nad
# common/), NIE wzgledem checkoutu repo - dzieki temu caly folder _Installers
# (razem z payload/ i translation_manifest.json) mozna spakowac do ZIP-a i
# uruchomic po rozpakowaniu w DOWOLNYM miejscu, bez reszty repozytorium.
set -euo pipefail

_PATHS_SH_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_ROOT="$(cd -- "$_PATHS_SH_DIR/.." && pwd)"
PATCH_DIR="$INSTALLER_ROOT/payload"
PATCH_MANIFEST="$INSTALLER_ROOT/patch-sha256.txt"
SOURCE_MANIFEST="$INSTALLER_ROOT/source-sha256.txt"
PLATFORM_FILE="$INSTALLER_ROOT/platform.txt"

GAME_NAME="The Mermaid Mask"
DATA_DIR_NAME="The Mermaid Mask_Data"

GAME_PATH_CANDIDATES=(
  "$HOME/.steam/steam/steamapps/common/$GAME_NAME"
  "$HOME/.local/share/Steam/steamapps/common/$GAME_NAME"
  "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/$GAME_NAME"
  "/home/deck/.local/share/Steam/steamapps/common/$GAME_NAME"
  "/run/media/mmcblk0p1/steamapps/common/$GAME_NAME"
  "/run/media/deck/mmcblk0p1/steamapps/common/$GAME_NAME"
  "$HOME/GOG Games/$GAME_NAME"
)

resolve_candidate() {
  local candidate="${1:-}"
  [[ -n "$candidate" ]] || return 1
  candidate="${candidate%\"}"
  candidate="${candidate#\"}"

  if [[ -f "$candidate" && "$candidate" == *.exe ]]; then
    candidate="$(dirname -- "$candidate")"
  fi
  if [[ -f "$candidate/sharedassets1.assets" ]]; then
    candidate="$(dirname -- "$candidate")"
  fi
  if [[ -f "$candidate/$DATA_DIR_NAME/sharedassets1.assets" && -f "$candidate/$GAME_NAME.exe" ]]; then
    GAME_PATH="$(cd -- "$candidate" && pwd)"
    return 0
  fi
  return 1
}

try_steam_root() {
  local steam_root="$1"
  resolve_candidate "$steam_root/steamapps/common/$GAME_NAME" && return 0

  local vdf="$steam_root/steamapps/libraryfolders.vdf"
  [[ -f "$vdf" ]] || return 1
  local library
  while IFS= read -r library; do
    library="${library//\\\\/\\}"
    resolve_candidate "$library/steamapps/common/$GAME_NAME" && return 0
  done < <(sed -nE 's/.*"path"[[:space:]]+"([^"]+)".*/\1/p' "$vdf")
  return 1
}

# Sets GAME_PATH using: argument, environment, config file, then auto-detection.
load_game_path() {
  local explicit="${1:-}"
  local configured="${GAME_PATH:-}"
  GAME_PATH=""

  resolve_candidate "$explicit" || true
  [[ -n "$GAME_PATH" ]] || resolve_candidate "$configured" || true

  if [[ -z "${GAME_PATH:-}" && -f "$INSTALLER_ROOT/game-path.env" ]]; then
    local line value
    while IFS= read -r line; do
      if [[ "$line" == GAME_PATH=* ]]; then
        value="${line#GAME_PATH=}"
        resolve_candidate "$value" || true
        break
      fi
    done < "$INSTALLER_ROOT/game-path.env"
  fi

  if [[ -z "${GAME_PATH:-}" ]]; then
    local candidate
    for candidate in "${GAME_PATH_CANDIDATES[@]}"; do
      resolve_candidate "$candidate" && break
    done
  fi

  if [[ -z "${GAME_PATH:-}" ]]; then
    try_steam_root "$HOME/.steam/steam" || true
  fi
  if [[ -z "${GAME_PATH:-}" ]]; then
    try_steam_root "$HOME/.local/share/Steam" || true
  fi
  if [[ -z "${GAME_PATH:-}" ]]; then
    try_steam_root "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam" || true
  fi

  if [[ -z "${GAME_PATH:-}" ]]; then
    for candidate in /run/media/"${USER:-deck}"/*/steamapps/common/"$GAME_NAME" /run/media/*/*/steamapps/common/"$GAME_NAME"; do
      resolve_candidate "$candidate" && break
    done
  fi

  if [[ -z "${GAME_PATH:-}" ]]; then
    echo "Nie znaleziono folderu gry '$GAME_NAME'." >&2
    echo "Podaj sciezke jako argument skryptu, np.:" >&2
    echo "  ./install-pl.sh \"/sciezka/do/gry\"" >&2
    echo "albo skopiuj game-path.env.example do game-path.env (obok folderu" >&2
    echo "_Installers) i ustaw tam GAME_PATH." >&2
    exit 1
  fi

  resolve_candidate "$GAME_PATH" || {
    echo "Blad: '$GAME_PATH' nie wyglada na folder gry '$GAME_NAME'." >&2
    exit 1
  }
}

validate_package() {
  if [[ ! -d "$PATCH_DIR" ]]; then
    echo "Brak payloadu patcha: $PATCH_DIR" >&2
    echo "Ta paczka wyglada na niekompletna - pobierz ja ponownie." >&2
    exit 1
  fi
  if [[ -z "$(find "$PATCH_DIR" -type f ! -name '.gitkeep' -print -quit)" ]]; then
    echo "Folder payloadu jest pusty: $PATCH_DIR" >&2
    echo "Ta paczka wyglada na niekompletna - pobierz ja ponownie." >&2
    exit 1
  fi
  for required in "$PATCH_MANIFEST" "$SOURCE_MANIFEST" "$PLATFORM_FILE"; do
    if [[ ! -f "$required" ]]; then
      echo "Brak wymaganego pliku paczki: $required" >&2
      exit 1
    fi
  done
  local platform
  IFS= read -r platform < "$PLATFORM_FILE"
  if [[ "$platform" != "windows" ]]; then
    echo "Blad: payload '$platform' nie jest zgodny z buildem Windows/Proton." >&2
    exit 1
  fi
}

sha256_of() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

patch_hash_for() {
  local wanted="$1" expected rel
  while read -r expected rel; do
    [[ -n "${expected:-}" && "$expected" != \#* ]] || continue
    if [[ "$rel" == "$wanted" ]]; then
      printf '%s\n' "$expected"
      return 0
    fi
  done < "$PATCH_MANIFEST"
  return 1
}
