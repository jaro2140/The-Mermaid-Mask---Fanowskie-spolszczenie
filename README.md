# 🇵🇱 The Mermaid Mask - Fanowskie spolszczenie
Nieoficjalne polskie tłumaczenie gry **The Mermaid Mask** (SFB Games).
Potrzebujesz **legalnie posiadanej kopii** gry (Steam/GOG).

Projekt wymaga legalnie posiadanej kopii gry.

> [!CAUTION]
> **Spolszczenie stworzone we współpracy z AI**

## ☕ Podoba Ci się to co robie?
Postaw mi kawe ☕! - https://buymeacoffee.com/jaro2140

---


## Status — wersja 1.3

| Obszar | Status |
| --- | --- |
| Teksty (menu, opcje, UI) | **Gotowe (100%)** |
| Teksty (dialogi, śledztwo, zagadki, dowody) | **Gotowe (100%)** |
| Opisy dowodów w bazie danych gry | **Gotowe (100%)** |
| Czcionki (polskie znaki) | **Gotowe** |
| Patch/instalator | **Gotowy** |
| Testy w grze | **Zakończone** |


### Zmiany w v1.3

- Windows używa trzech zwykłych plików BAT — PowerShell nie jest wymagany.
- Poprawiono wykrywanie bibliotek Steam/GOG i ścieżek ze spacjami lub nawiasami.
- Dodano kontrolę SHA-256 wszystkich 14 plików przed instalacją.
- Backup jest przechowywany wewnątrz folderu gry i nie ginie po usunięciu ZIP-a.
- Payload tłumaczenia jest identyczny z v1.2; zmiany dotyczą instalatorów.

Jeśli v1.2 jest już zainstalowane i działa, ponowna instalacja nie jest
potrzebna. Nowa paczka jest przeznaczona przede wszystkim do kolejnych instalacji.


## Znane niepewności

- Kilka drobnych niejednoznaczności fabularnych/tłumaczeniowych oznaczonych
  w trakcie pracy — nie wpływają na rozgrywkę ani zrozumiałość tekstu.
- Jeśli mimo to zauważysz błąd w tłumaczeniu, zgłoś to jako issue.


## Instalacja

Wymagana legalnie posiadana kopia gry (Steam/GOG na Windows albo wersja Windows
uruchamiana przez Proton na SteamOS/Steam Deck).
1. Pobierz najnowszą paczkę z [Releases](../../releases) — **jeden ZIP, gotowy do użycia** (zawiera instalator i spatchowane pliki razem).
2. Rozpakuj ZIP **w dowolnym miejscu** (pulpit, pobrane, gdziekolwiek).
3. Uruchom instalator z rozpakowanego folderu:
   - **Linux / SteamOS / Steam Deck (Proton)**: `cd linux && ./install-pl.sh`
   - **Windows**: uruchom dwuklikiem `windows\install-pl.bat`.
4. Instalator sam wykrywa folder gry (Steam/GOG/Steam Deck). Jeśli się nie uda, podaj ścieżkę jako argument (`./install-pl.sh "/ścieżka/do/gry"`) albo skopiuj `game-path.env.example` do `game-path.env` (obok folderu `linux`/`windows`) i ustaw tam `GAME_PATH`.
5. W grze: Opcje → Język tekstu → wybierz **Polski**.

Instalator weryfikuje wersję gry i integralność wszystkich 14 plików, a potem
tworzy kopię zapasową w `.the_mermaid_mask_pl_backup/windows` wewnątrz folderu
gry. Przywrócenie oryginału: `./restore-original.sh` (Linux) lub
`restore-original.bat` (Windows). Weryfikacja: `verify-install.sh` /
`verify-install.bat`.


## Screenshots

![image](https://github.com/jaro2140/The-Mermaid-Mask---Fanowskie-spolszczenie/blob/main/menugl.png)
![image](https://github.com/jaro2140/The-Mermaid-Mask---Fanowskie-spolszczenie/blob/main/menuopcje.png)


## Disclaimer

Fanowski projekt niezwiązany z twórcami ani wydawcą gry.
Gra musi być legalnie zakupiona. Patch nie zawiera oryginalnych plików gry.
