#!/usr/bin/env bash
# Instaluje polskie tlumaczenie The Mermaid Mask (Linux / SteamOS / Steam Deck).
# Uzycie: ./install-pl.sh ["/sciezka/do/gry"]
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

load_game_path "${1:-}"
require_patch_payload

BACKUP_DIR="$SCRIPT_DIR/backup"

echo "Gra:    $GAME_PATH"
echo "Pakiet: $PATCH_DIR"
mkdir -p "$BACKUP_DIR"

while IFS= read -r src; do
  rel="${src#"$PATCH_DIR"/}"
  target="$GAME_PATH/$rel"
  bak="$BACKUP_DIR/$rel"

  if [[ ! -f "$target" ]]; then
    echo "  BLAD: brak oryginalnego pliku $target" >&2
    echo "  (upewnij sie, ze wskazujesz na poprawny folder gry)" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$bak")"
  if [[ ! -f "$bak" ]]; then
    cp "$target" "$bak"
    echo "  kopia zapasowa: $rel"
  fi

  mkdir -p "$(dirname "$target")"
  cp "$src" "$target"
  echo "  zainstalowano:  $rel"
done < <(find "$PATCH_DIR" -type f ! -name '.gitkeep')

echo ""
echo "Gotowe! Polskie tlumaczenie $GAME_NAME zostalo zainstalowane."
echo "Oryginalne pliki zachowane w: $BACKUP_DIR"
echo ""
echo "W grze: Opcje -> Jezyk tekstu -> wybierz 'Polski'."
echo ""
echo "Uruchamiam weryfikacje instalacji..."
"$SCRIPT_DIR/verify-install.sh" "$GAME_PATH"
echo ""
echo "Aby przywrocic oryginal: ./restore-original.sh"
