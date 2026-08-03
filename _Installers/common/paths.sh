#!/usr/bin/env bash
# Wspolne funkcje uzywane przez instalatory Linux/SteamOS.
# Zrodlowane (source) przez install-pl.sh / restore-original.sh / verify-install.sh.
#
# Wszystkie sciezki sa liczone wzgledem folderu _Installers (jeden poziom nad
# common/), NIE wzgledem checkoutu repo - dzieki temu caly folder _Installers
# (razem z payload/ i translation_manifest.json) mozna spakowac do ZIP-a i
# uruchomic po rozpakowaniu w DOWOLNYM miejscu, bez reszty repozytorium.
set -euo pipefail

_PATHS_SH_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_ROOT="$(cd -- "$_PATHS_SH_DIR/.." && pwd)"
PATCH_DIR="$INSTALLER_ROOT/payload"
MANIFEST="$INSTALLER_ROOT/translation_manifest.json"

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

# Ustawia zmienna GAME_PATH: argument skryptu > zmienna srodowiskowa GAME_PATH >
# plik game-path.env obok folderu _Installers > automatyczne wykrycie
# (Steam/GOG/Steam Deck).
load_game_path() {
  local explicit="${1:-}"

  if [[ -n "$explicit" ]]; then
    GAME_PATH="$explicit"
  fi

  if [[ -z "${GAME_PATH:-}" && -f "$INSTALLER_ROOT/game-path.env" ]]; then
    # shellcheck disable=SC1091
    source "$INSTALLER_ROOT/game-path.env"
  fi

  if [[ -z "${GAME_PATH:-}" ]]; then
    local candidate
    for candidate in "${GAME_PATH_CANDIDATES[@]}"; do
      if [[ -d "$candidate/$DATA_DIR_NAME" ]]; then
        GAME_PATH="$candidate"
        break
      fi
    done
  fi

  if [[ -z "${GAME_PATH:-}" ]]; then
    for candidate in /run/media/"${USER:-deck}"/*/steamapps/common/"$GAME_NAME" /run/media/*/*/steamapps/common/"$GAME_NAME"; do
      if [[ -d "$candidate/$DATA_DIR_NAME" ]]; then
        GAME_PATH="$candidate"
        break
      fi
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

  if [[ ! -d "$GAME_PATH" ]]; then
    echo "Sciezka gry nie istnieje: $GAME_PATH" >&2
    exit 1
  fi

  if [[ ! -d "$GAME_PATH/$DATA_DIR_NAME" ]]; then
    echo "Blad: '$GAME_PATH' nie wyglada na folder gry '$GAME_NAME' (brak $DATA_DIR_NAME)." >&2
    exit 1
  fi
}

require_patch_payload() {
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
}

sha256_of() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}
