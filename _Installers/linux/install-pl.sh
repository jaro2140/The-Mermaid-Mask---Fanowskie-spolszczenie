#!/usr/bin/env bash
# Installs the Polish translation on the Windows build run natively or via Proton.
# Usage: ./install-pl.sh ["/path/to/The Mermaid Mask"]
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

load_game_path "${1:-}"
validate_package

BACKUP_DIR="$GAME_PATH/.the_mermaid_mask_pl_backup/windows"
LEGACY_BACKUP_DIR="$SCRIPT_DIR/backup"
mkdir -p "$BACKUP_DIR"

echo "=== The Mermaid Mask PL - instalacja Linux/SteamOS (Proton) ==="
echo "Gra:    $GAME_PATH"
echo "Patch:  $PATCH_DIR"
echo "Backup: $BACKUP_DIR"
echo ""

file_count=0
while read -r source_hash rel; do
  [[ -n "${source_hash:-}" && "$source_hash" != \#* ]] || continue
  file_count=$((file_count + 1))
  patch_hash="$(patch_hash_for "$rel")" || {
    echo "BLAD: manifest patcha nie zawiera pliku: $rel" >&2
    exit 1
  }
  patch_file="$PATCH_DIR/$rel"
  target="$GAME_PATH/$rel"
  backup="$BACKUP_DIR/$rel"

  [[ -f "$patch_file" ]] || { echo "BLAD: brak pliku patcha: $rel" >&2; exit 1; }
  [[ -f "$target" ]] || { echo "BLAD: brak pliku gry: $rel" >&2; exit 1; }
  [[ "$(sha256_of "$patch_file")" == "$patch_hash" ]] || {
    echo "BLAD: nieprawidlowa suma SHA-256 pliku patcha: $rel" >&2
    exit 1
  }

  target_hash="$(sha256_of "$target")"
  if [[ "$target_hash" == "$source_hash" ]]; then
    continue
  fi
  if [[ "$target_hash" == "$patch_hash" ]]; then
    if [[ ! -f "$backup" && -f "$LEGACY_BACKUP_DIR/$rel" && "$(sha256_of "$LEGACY_BACKUP_DIR/$rel")" == "$source_hash" ]]; then
      mkdir -p "$(dirname -- "$backup")"
      cp "$LEGACY_BACKUP_DIR/$rel" "$backup"
      echo "  przeniesiono stary backup: $rel"
    fi
    [[ -f "$backup" && "$(sha256_of "$backup")" == "$source_hash" ]] || {
      echo "BLAD: $rel jest juz spatchowany, ale brakuje bezpiecznego backupu." >&2
      echo "Przywroc pliki przez Steam/GOG przed ponowna instalacja." >&2
      exit 1
    }
    continue
  fi
  echo "BLAD: nieobslugiwana wersja lub zmodyfikowany plik gry: $rel" >&2
  echo "Sprawdz spojnosc plikow w Steam/GOG i uruchom instalator ponownie." >&2
  exit 1
done < "$SOURCE_MANIFEST"

if [[ "$file_count" -eq 0 ]]; then
  echo "BLAD: manifest oryginalnych plikow jest pusty." >&2
  exit 1
fi

rollback() {
  local expected rel backup target
  while read -r expected rel; do
    [[ -n "${expected:-}" && "$expected" != \#* ]] || continue
    backup="$BACKUP_DIR/$rel"
    target="$GAME_PATH/$rel"
    if [[ -f "$backup" && "$(sha256_of "$backup")" == "$expected" ]]; then
      cp "$backup" "$target" || true
    fi
  done < "$SOURCE_MANIFEST"
}
trap 'echo "BLAD: instalacja nie powiodla sie. Przywracam backup." >&2; rollback' ERR

while read -r source_hash rel; do
  [[ -n "${source_hash:-}" && "$source_hash" != \#* ]] || continue
  target="$GAME_PATH/$rel"
  backup="$BACKUP_DIR/$rel"
  if [[ "$(sha256_of "$target")" == "$source_hash" ]]; then
    mkdir -p "$(dirname -- "$backup")"
    cp "$target" "$backup"
    echo "  backup:       $rel"
  fi
  cp "$PATCH_DIR/$rel" "$target"
  echo "  zainstalowano: $rel"
done < "$SOURCE_MANIFEST"

cp "$SOURCE_MANIFEST" "$BACKUP_DIR/source-sha256.txt"
cp "$PLATFORM_FILE" "$BACKUP_DIR/platform.txt"
trap - ERR

echo ""
echo "Uruchamiam weryfikacje instalacji..."
"$SCRIPT_DIR/verify-install.sh" "$GAME_PATH"
echo ""
echo "Gotowe! W grze wybierz: Opcje -> Jezyk tekstu -> Polski."
echo "Oryginalne pliki sa zapisane w: $BACKUP_DIR"
echo "Przywracanie: $SCRIPT_DIR/restore-original.sh"
