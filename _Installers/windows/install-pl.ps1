# Instaluje polskie tlumaczenie The Mermaid Mask (Windows).
# Uzycie: powershell -ExecutionPolicy Bypass -File install-pl.ps1 [-GamePath "C:\sciezka\do\gry"]
param(
    [string]$GamePath
)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "paths.ps1")

Assert-PatchPayload
$GamePath = Get-GamePathOrExit -Explicit $GamePath

$BackupDir = Join-Path $ScriptDir "backup"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

Write-Host "Gra:    $GamePath"
Write-Host "Pakiet: $PatchDir"

Get-ChildItem -Path $PatchDir -Recurse -File | Where-Object { $_.Name -ne ".gitkeep" } | ForEach-Object {
    $rel = $_.FullName.Substring($PatchDir.Length + 1)
    $target = Join-Path $GamePath $rel
    $bak = Join-Path $BackupDir $rel

    if (-not (Test-Path $target)) {
        Write-Host "  BLAD: brak oryginalnego pliku $target"
        Write-Host "  (upewnij sie, ze wskazujesz na poprawny folder gry)"
        exit 1
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $bak) | Out-Null
    if (-not (Test-Path $bak)) {
        Copy-Item $target $bak
        Write-Host "  kopia zapasowa: $rel"
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    Copy-Item $_.FullName $target -Force
    Write-Host "  zainstalowano:  $rel"
}

Write-Host ""
Write-Host "Gotowe! Polskie tlumaczenie $GameName zostalo zainstalowane."
Write-Host "Oryginalne pliki zachowane w: $BackupDir"
Write-Host ""
Write-Host "W grze: Opcje -> Jezyk tekstu -> wybierz 'Polski'."
Write-Host ""
Write-Host "Uruchamiam weryfikacje instalacji..."
& (Join-Path $ScriptDir "verify-install.ps1") -GamePath $GamePath
Write-Host ""
Write-Host "Aby przywrocic oryginal: .\restore-original.ps1"
