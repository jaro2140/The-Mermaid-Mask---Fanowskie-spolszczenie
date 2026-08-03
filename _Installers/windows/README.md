# Windows Installers

Skrypty PowerShell instalujące polskie tłumaczenie The Mermaid Mask.

```powershell
cd windows
powershell -ExecutionPolicy Bypass -File install-pl.ps1
```

Jeśli automatyczne wykrycie gry nie zadziała, podaj ścieżkę:
`install-pl.ps1 -GamePath "C:\ścieżka\do\gry"`.

Przywrócenie oryginału: `restore-original.ps1`. Weryfikacja instalacji:
`verify-install.ps1`.
