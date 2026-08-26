#!/usr/bin/env bash
# Verifies all translated files against the release manifest.
# Usage: ./verify-install.sh ["/path/to/The Mermaid Mask"]
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

load_game_path "${1:-}"
validate_package

echo "=== The Mermaid Mask PL - weryfikacja ==="
echo "Gra: $GAME_PATH"
echo ""

all_ok=1
file_count=0
while read -r expected rel; do
  [[ -n "${expected:-}" && "$expected" != \#* ]] || continue
  file_count=$((file_count + 1))
  target="$GAME_PATH/$rel"
  if [[ ! -f "$target" ]]; then
    echo "  BRAK: $rel"
    all_ok=0
  elif [[ "$(sha256_of "$target")" == "$expected" ]]; then
    echo "  OK: $rel"
  else
    echo "  ROZNI SIE: $rel"
    all_ok=0
  fi
done < "$PATCH_MANIFEST"

echo ""
if [[ "$file_count" -eq 0 ]]; then
  echo "BLAD: manifest patcha jest pusty." >&2
  exit 1
fi
if [[ "$all_ok" -eq 1 ]]; then
  echo "Wszystko zgodne - tlumaczenie jest zainstalowane poprawnie."
else
  echo "Znaleziono niezgodnosci - patrz szczegoly powyzej." >&2
  exit 1
fi
