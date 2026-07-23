# _Installers

Publiczne skrypty instalacji patcha.

Proponowany układ:

- `common/` - wspólne funkcje, wykrywanie ścieżek, logowanie.
- `linux/` - instalacja Linux / SteamOS.
- `windows/` - instalacja Windows.

Instalator powinien:

- wykryć lub przyjąć ścieżkę do gry,
- sprawdzić, czy wymagane pliki patcha istnieją,
- zrobić kopię zapasową oryginalnych plików,
- skopiować pliki patcha,
- umożliwić weryfikację i przywrócenie oryginału.
