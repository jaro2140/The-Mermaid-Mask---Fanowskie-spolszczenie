# Instalator Windows

Uruchom dwuklikiem `install-pl.bat`. PowerShell ani zmiana zasad wykonywania
skryptów nie są potrzebne.

Jeśli automatyczne wykrycie gry nie zadziała, instalator poprosi o wklejenie
pełnej ścieżki. Możesz też uruchomić go z argumentem:

```bat
install-pl.bat "D:\SteamLibrary\steamapps\common\The Mermaid Mask"
```

Pozostałe narzędzia:

- `verify-install.bat` — sprawdza wszystkie 14 plików tłumaczenia;
- `restore-original.bat` — przywraca zweryfikowaną kopię oryginału.

Nie przenoś samych BAT-ów. Folder `windows` musi pozostać obok `payload` i
plików manifestu tak jak w rozpakowanym ZIP-ie.
