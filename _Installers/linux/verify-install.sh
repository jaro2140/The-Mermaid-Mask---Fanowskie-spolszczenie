#!/usr/bin/env bash
# Weryfikuje integralnosc zainstalowanego tlumaczenia PL (SHA-256 wzgledem manifestu).
# Uzycie: ./verify-install.sh ["/sciezka/do/gry"]
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/paths.sh
source "$SCRIPT_DIR/../common/paths.sh"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Brak $MANIFEST - nie mozna zweryfikowac instalacji." >&2
  exit 1
fi

load_game_path "${1:-}"

echo "Gra: $GAME_PATH"
echo ""

ALL_OK=1
while IFS= read -r line; do
  rel="$(sed -E 's/^"(.*)": "[0-9a-f]{64}"$/\1/' <<<"$line")"
  expected="$(sed -E 's/^"(.*)": "([0-9a-f]{64})"$/\2/' <<<"$line")"
  target="$GAME_PATH/$rel"
  if [[ ! -f "$target" ]]; then
    echo "  BRAK: $rel"
    ALL_OK=0
    continue
  fi
  actual="$(sha256_of "$target")"
  if [[ "$actual" == "$expected" ]]; then
    echo "  OK: $rel"
  else
    echo "  ROZNI SIE: $rel (plik zmodyfikowany / niezainstalowany / inna wersja patcha)"
    ALL_OK=0
  fi
done < <(grep -oE '"[^"]+": "[0-9a-f]{64}"' "$MANIFEST")

echo ""
if [[ "$ALL_OK" -eq 1 ]]; then
  echo "Wszystko zgodne - tlumaczenie $GAME_NAME (PL) zainstalowane poprawnie."
else
  echo "Znaleziono niezgodnosci - patrz szczegoly powyzej." >&2
  exit 1
fi
