#!/usr/bin/env bash
# Przywraca oryginalne (angielskie) pliki gry, zapisane przez install-pl.sh.
# Uzycie: ./restore-original.sh ["/sciezka/do/gry"]
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

BACKUP_DIR="$SCRIPT_DIR/backup"

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "Brak kopii zapasowej ($BACKUP_DIR) - nie ma czego przywracac." >&2
  echo "(instalator tworzy ja automatycznie przy pierwszym uruchomieniu install-pl.sh)" >&2
  exit 1
fi

load_game_path "${1:-}"

echo "Gra: $GAME_PATH"

while IFS= read -r src; do
  rel="${src#"$BACKUP_DIR"/}"
  target="$GAME_PATH/$rel"
  mkdir -p "$(dirname "$target")"
  cp "$src" "$target"
  echo "  przywrocono: $rel"
done < <(find "$BACKUP_DIR" -type f)

echo ""
echo "Gotowe - przywrocono oryginalne (angielskie) pliki $GAME_NAME."
