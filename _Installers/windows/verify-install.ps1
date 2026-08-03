# Weryfikuje integralnosc zainstalowanego tlumaczenia PL (SHA-256 wzgledem manifestu).
# Uzycie: powershell -ExecutionPolicy Bypass -File verify-install.ps1 [-GamePath "C:\sciezka\do\gry"]
param(
    [string]$GamePath
)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "paths.ps1")

if (-not (Test-Path $Manifest)) {
    Write-Host "Brak $Manifest - nie mozna zweryfikowac instalacji."
    exit 1
}

$GamePath = Get-GamePathOrExit -Explicit $GamePath

Write-Host "Gra: $GamePath"
Write-Host ""

$manifestData = Get-Content $Manifest -Raw | ConvertFrom-Json
$allOk = $true

foreach ($prop in $manifestData.files.PSObject.Properties) {
    $rel = $prop.Name
    $expected = $prop.Value
    $target = Join-Path $GamePath $rel
    if (-not (Test-Path $target)) {
        Write-Host "  BRAK: $rel"
        $allOk = $false
        continue
    }
    $actual = (Get-FileHash -Path $target -Algorithm SHA256).Hash.ToLower()
    if ($actual -eq $expected) {
        Write-Host "  OK: $rel"
    } else {
        Write-Host "  ROZNI SIE: $rel (plik zmodyfikowany / niezainstalowany / inna wersja patcha)"
        $allOk = $false
    }
}

Write-Host ""
if ($allOk) {
    Write-Host "Wszystko zgodne - tlumaczenie $GameName (PL) zainstalowane poprawnie."
} else {
    Write-Host "Znaleziono niezgodnosci - patrz szczegoly powyzej."
    exit 1
}
