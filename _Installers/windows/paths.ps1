# Wspolne funkcje uzywane przez instalatory Windows.
# Kropkowane (dot-sourced) przez install-pl.ps1 / restore-original.ps1 / verify-install.ps1.
#
# Wszystkie sciezki sa liczone wzgledem folderu _Installers (jeden poziom nad
# windows/), NIE wzgledem checkoutu repo - dzieki temu caly folder _Installers
# (razem z payload/ i translation_manifest.json) mozna spakowac do ZIP-a i
# uruchomic po rozpakowaniu w DOWOLNYM miejscu, bez reszty repozytorium.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallerRoot = Split-Path -Parent $ScriptDir
$PatchDir = Join-Path $InstallerRoot "payload"
$Manifest = Join-Path $InstallerRoot "translation_manifest.json"

$GameName = "The Mermaid Mask"
$DataDirName = "The Mermaid Mask_Data"

$GamePathCandidates = @(
    "C:\Program Files (x86)\Steam\steamapps\common\$GameName"
    "C:\Program Files\Steam\steamapps\common\$GameName"
    "C:\GOG Games\$GameName"
)

function Resolve-GamePath {
    param([string]$Explicit)

    if ($Explicit) { return $Explicit }

    $envFile = Join-Path $InstallerRoot "game-path.env"
    if (Test-Path $envFile) {
        $line = Get-Content $envFile | Where-Object { $_ -match '^GAME_PATH=' } | Select-Object -First 1
        if ($line) {
            $val = ($line -replace '^GAME_PATH=', '').Trim().Trim('"')
            if ($val) { return $val }
        }
    }

    foreach ($c in $GamePathCandidates) {
        if (Test-Path (Join-Path $c $DataDirName)) { return $c }
    }

    foreach ($drive in Get-PSDrive -PSProvider FileSystem) {
        $root = $drive.Root
        $libraryCandidates = @(
            (Join-Path $root "SteamLibrary\steamapps\common\$GameName")
            (Join-Path $root "Steam\steamapps\common\$GameName")
            (Join-Path $root "GOG Games\$GameName")
        )
        foreach ($path in $libraryCandidates) {
            if (Test-Path (Join-Path $path $DataDirName)) { return $path }
        }
    }

    return $null
}

function Get-GamePathOrExit {
    param([string]$Explicit)

    $path = Resolve-GamePath -Explicit $Explicit
    if (-not $path) {
        Write-Host "Nie znaleziono folderu gry '$GameName'."
        Write-Host "Podaj sciezke parametrem -GamePath, np.:"
        Write-Host "  .\install-pl.ps1 -GamePath 'C:\sciezka\do\gry'"
        Write-Host "albo skopiuj game-path.env.example do game-path.env (obok folderu"
        Write-Host "_Installers) i ustaw tam GAME_PATH."
        exit 1
    }
    if (-not (Test-Path $path)) {
        Write-Host "Sciezka gry nie istnieje: $path"
        exit 1
    }
    if (-not (Test-Path (Join-Path $path $DataDirName))) {
        Write-Host "Blad: '$path' nie wyglada na folder gry '$GameName' (brak $DataDirName)."
        exit 1
    }
    return $path
}

function Assert-PatchPayload {
    if (-not (Test-Path $PatchDir)) {
        Write-Host "Brak payloadu patcha: $PatchDir"
        Write-Host "Ta paczka wyglada na niekompletna - pobierz ja ponownie."
        exit 1
    }
    $files = Get-ChildItem -Path $PatchDir -Recurse -File | Where-Object { $_.Name -ne ".gitkeep" }
    if (-not $files) {
        Write-Host "Folder payloadu jest pusty: $PatchDir"
        Write-Host "Ta paczka wyglada na niekompletna - pobierz ja ponownie."
        exit 1
    }
}
