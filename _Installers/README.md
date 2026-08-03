# The Mermaid Mask — polskie tłumaczenie

Ten folder jest kompletnym, samodzielnym instalatorem. Rozpakuj ZIP w dowolnym
miejscu i uruchom skrypt dla swojego systemu:

- **Linux / SteamOS / Steam Deck:** `cd linux && ./install-pl.sh`
- **Windows:** przejdź do folderu `windows` i uruchom
  `powershell -ExecutionPolicy Bypass -File install-pl.ps1`

Instalator automatycznie wyszuka grę i przed podmianą plików utworzy ich kopię
zapasową. Jeśli nie znajdzie gry, podaj jej folder jako argument skryptu albo
ustaw `GAME_PATH` w pliku `game-path.env` utworzonym z
`game-path.env.example`.

Po instalacji wybierz w grze: **Opcje → Język tekstu → Polski**.

Oryginalne pliki można przywrócić skryptem `restore-original.sh` albo
`restore-original.ps1` z folderu właściwego dla systemu.
