#!/usr/bin/env bash
# Restores the verified original files created by install-pl.sh.
# Usage: ./restore-original.sh ["/path/to/The Mermaid Mask"]
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

load_game_path "${1:-}"
BACKUP_DIR="$GAME_PATH/.the_mermaid_mask_pl_backup/windows"
BACKUP_MANIFEST="$BACKUP_DIR/source-sha256.txt"

if [[ ! -f "$BACKUP_MANIFEST" ]]; then
  echo "BLAD: brak zweryfikowanej kopii zapasowej w $BACKUP_DIR." >&2
  echo "Jesli backup zostal usuniety, przywroc pliki przez Steam lub GOG." >&2
  exit 1
fi

echo "=== The Mermaid Mask - przywracanie oryginalu ==="
echo "Gra:    $GAME_PATH"
echo "Backup: $BACKUP_DIR"
echo ""

file_count=0
while read -r expected rel; do
  [[ -n "${expected:-}" && "$expected" != \#* ]] || continue
  file_count=$((file_count + 1))
  backup="$BACKUP_DIR/$rel"
  [[ -f "$backup" ]] || { echo "BLAD: backup nie zawiera pliku: $rel" >&2; exit 1; }
  [[ "$(sha256_of "$backup")" == "$expected" ]] || {
    echo "BLAD: backup ma nieprawidlowa sume SHA-256: $rel" >&2
    exit 1
  }
done < "$BACKUP_MANIFEST"

if [[ "$file_count" -eq 0 ]]; then
  echo "BLAD: manifest backupu jest pusty." >&2
  exit 1
fi

while read -r expected rel; do
  [[ -n "${expected:-}" && "$expected" != \#* ]] || continue
  target="$GAME_PATH/$rel"
  mkdir -p "$(dirname -- "$target")"
  cp "$BACKUP_DIR/$rel" "$target"
  echo "  przywrocono: $rel"
done < "$BACKUP_MANIFEST"

echo ""
echo "Gotowe - przywrocono oryginalne pliki gry."
