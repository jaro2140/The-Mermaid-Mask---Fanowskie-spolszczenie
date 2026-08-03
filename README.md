# 🇵🇱 The Mermaid Mask - Fanowskie spolszczenie

Nieoficjalne polskie tłumaczenie gry **The Mermaid Mask** (SFB Games).
Potrzebujesz **legalnie posiadanej kopii** gry (Steam/GOG).

Projekt wymaga legalnie posiadanej kopii gry.


## ☕ Podoba Ci się to co robie?
Postaw mi kawe ☕! - https://buymeacoffee.com/jaro2140

---


## Status (2026-08-03)

| Obszar | Status |
| --- | --- |
| Teksty (menu, opcje, UI) | **Gotowe (100%)** |
| Teksty (dialogi, śledztwo, zagadki, dowody) | **Gotowe (100%)** |
| Opisy dowodów w bazie danych gry (`devTexts`) | **Gotowe (100%)** |
| Czcionki (polskie znaki) | **Gotowe — poprawka v44** |
| Patch/instalator | **Gotowy** |
| Testy w grze | **W trakcie** |


## Co jeszcze wymaga testu / znane niepewności

- **[KRYTYCZNE] Modyfikacja paczek Addressables (`.bundle`)** - część opisów
  dowodów jest przechowywana w 11 paczkach `StreamingAssets/aa/
  StandaloneWindows64/*.bundle`. Modyfikacja tych plików jest nowym
  mechanizmem. Jeśli tak, mogłoby to spowodować, że opisy
  (ale nie nazwy) niektórych dowodów wyświetlają się dalej po angielsku
  mimo poprawnej instalacji. Zgłoś to jako issue, jeśli zauważysz taki
  przypadek.
- Kilka drobnych niejednoznaczności fabularnych/tłumaczeniowych oznaczonych
  w trakcie pracy.


## Instalacja

Wymagana legalnie posiadana kopia gry (Steam/GOG, SteamOS/Steam Deck lub Windows).
1. Pobierz najnowszą paczkę z [Releases](../../releases) — **jeden ZIP, gotowy do użycia** (zawiera instalator i spatchowane pliki razem).
2. Rozpakuj ZIP **w dowolnym miejscu** (pulpit, pobrane, gdziekolwiek).
3. Uruchom instalator z rozpakowanego folderu:
   - **Linux / SteamOS / Steam Deck**: `cd linux && ./install-pl.sh`
   - **Windows**: `cd windows`, a następnie
     `powershell -ExecutionPolicy Bypass -File install-pl.ps1`
4. Instalator sam wykrywa folder gry (Steam/GOG/Steam Deck). Jeśli się nie uda, podaj ścieżkę jako argument (`./install-pl.sh "/ścieżka/do/gry"`) albo skopiuj `game-path.env.example` do `game-path.env` (obok folderu `linux`/`windows`) i ustaw tam `GAME_PATH`.
5. W grze: Opcje → Język tekstu → wybierz **Polski**.

Instalator sam robi kopię zapasową oryginalnych plików przed podmianą (folder `backup/` obok skryptu) - przywrócenie oryginału: `./restore-original.sh` (Linux) lub `restore-original.ps1` (Windows). Weryfikacja poprawności instalacji: `verify-install.sh` / `verify-install.ps1`.


## Screenshots

![image](https://github.com/jaro2140/The-Mermaid-Mask---Fanowskie-spolszczenie/blob/main/menugl.png)
![image](https://github.com/jaro2140/The-Mermaid-Mask---Fanowskie-spolszczenie/blob/main/menuopcje.png)


## Disclaimer

Fanowski projekt niezwiązany z twórcami ani wydawcą gry.
Gra musi być legalnie zakupiona. Patch nie zawiera oryginalnych plików gry.
