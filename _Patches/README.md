# _Patches

Miejsce na gotowe pliki patcha używane przez instalator.

Duże pliki binarne, archiwa i payloady najlepiej publikować w GitHub Releases.
W repo trzymaj tylko ten README oraz ewentualnie małe manifesty opisujące zawartość
wydania.

Przykładowy układ po rozpakowaniu release:

```text
_Patches/
  payload/
    game-specific-file.dat
    StreamingAssets/
      ...
```

Nie commituj oryginalnych plików gry, jeśli ich redystrybucja nie jest dozwolona.
