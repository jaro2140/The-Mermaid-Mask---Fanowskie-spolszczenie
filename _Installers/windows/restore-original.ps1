# Przywraca oryginalne (angielskie) pliki gry, zapisane przez install-pl.ps1.
# Uzycie: powershell -ExecutionPolicy Bypass -File restore-original.ps1 [-GamePath "C:\sciezka\do\gry"]
param(
    [string]$GamePath
)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "paths.ps1")

$BackupDir = Join-Path $ScriptDir "backup"
if (-not (Test-Path $BackupDir)) {
    Write-Host "Brak kopii zapasowej ($BackupDir) - nie ma czego przywracac."
    Write-Host "(instalator tworzy ja automatycznie przy pierwszym uruchomieniu install-pl.ps1)"
    exit 1
}

$GamePath = Get-GamePathOrExit -Explicit $GamePath

Write-Host "Gra: $GamePath"

Get-ChildItem -Path $BackupDir -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($BackupDir.Length + 1)
    $target = Join-Path $GamePath $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    Copy-Item $_.FullName $target -Force
    Write-Host "  przywrocono: $rel"
}

Write-Host ""
Write-Host "Gotowe - przywrocono oryginalne (angielskie) pliki $GameName."
