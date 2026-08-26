# The Mermaid Mask — polskie tłumaczenie

Ten folder jest kompletnym, samodzielnym instalatorem. Rozpakuj ZIP w dowolnym
miejscu i uruchom skrypt dla swojego systemu:

- **Linux / SteamOS / Steam Deck (Proton):** `cd linux && ./install-pl.sh`
- **Windows:** uruchom dwuklikiem `windows\install-pl.bat`.

Instalator automatycznie wyszuka grę i przed podmianą plików zweryfikuje wersję
gry oraz integralność patcha. Oryginały zapisuje w ukrytym folderze backupu
wewnątrz katalogu gry, dlatego kopia nie zginie po usunięciu ZIP-a. Jeśli gra
nie zostanie znaleziona, podaj jej folder jako argument lub ustaw `GAME_PATH`
w pliku `game-path.env` utworzonym z `game-path.env.example`.

Po instalacji wybierz w grze: **Opcje → Język tekstu → Polski**.

Oryginalne pliki można przywrócić skryptem `restore-original.sh` albo
`restore-original.bat` z folderu właściwego dla systemu. Windows nie wymaga
PowerShella ani zmiany zasad wykonywania skryptów.

Paczka zawiera jeden payload `StandaloneWindows64`. Jest on właściwy zarówno
dla natywnego Windows, jak i dla SteamOS/Steam Deck uruchamiającego grę przez
Proton. Nie jest to payload natywnej wersji linuksowej.
