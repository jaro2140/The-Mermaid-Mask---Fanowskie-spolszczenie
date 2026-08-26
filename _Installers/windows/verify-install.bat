@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
pushd "%~dp0.." >nul 2>&1
if errorlevel 1 (
  echo BLAD: nie mozna ustalic katalogu paczki instalacyjnej.
  exit /b 1
)
set "ROOT=!CD!"
popd

set "GAME_NAME=The Mermaid Mask"
set "DATA_DIR=The Mermaid Mask_Data"
set "PATCH_DIR=!ROOT!\payload"
set "PATCH_MANIFEST=!ROOT!\patch-sha256.txt"
set "SOURCE_MANIFEST=!ROOT!\source-sha256.txt"
set "PLATFORM_FILE=!ROOT!\platform.txt"
set "EXPLICIT_PATH=%~1"
goto :Verify

:Install
call :ValidatePackage || exit /b 1
call :FindGame || exit /b 1
call :SetGamePaths

if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!" || (
  echo BLAD: nie mozna utworzyc backupu: !BACKUP_DIR!
  exit /b 1
)

call :MigrateLegacyBackup

echo === The Mermaid Mask PL - instalacja Windows ===
echo Gra:    !GAME_PATH!
echo Patch:  !PATCH_DIR!
echo Backup: !BACKUP_DIR!
echo.

set "FILE_COUNT=0"
for /f "usebackq eol=# tokens=1,*" %%H in ("!SOURCE_MANIFEST!") do (
  call :PreflightFile "%%I" "%%H" || exit /b 1
  set /a FILE_COUNT+=1
)
if "!FILE_COUNT!"=="0" (
  echo BLAD: manifest oryginalnych plikow jest pusty.
  exit /b 1
)

for /f "usebackq eol=# tokens=1,*" %%H in ("!SOURCE_MANIFEST!") do (
  call :InstallFile "%%I" "%%H" || goto :InstallRollback
)

copy /y "!SOURCE_MANIFEST!" "!BACKUP_DIR!\source-sha256.txt" >nul || goto :InstallRollback
copy /y "!PLATFORM_FILE!" "!BACKUP_DIR!\platform.txt" >nul || goto :InstallRollback

echo.
echo Uruchamiam weryfikacje instalacji...
set "ALL_OK=1"
for /f "usebackq eol=# tokens=1,*" %%H in ("!PATCH_MANIFEST!") do call :VerifyFile "%%I" "%%H"
if "!ALL_OK!"=="0" goto :InstallRollback

echo.
echo Gotowe! Polskie tlumaczenie zostalo zainstalowane.
echo W grze wybierz: Opcje -^> Jezyk tekstu -^> Polski.
echo Oryginalne pliki sa bezpiecznie zapisane w: !BACKUP_DIR!
echo Przywracanie: %~dp0restore-original.bat
exit /b 0

:InstallRollback
echo.
echo BLAD: instalacja nie powiodla sie. Przywracam pliki z backupu...
call :RollbackFiles
exit /b 1

:Verify
call :ValidatePackage || exit /b 1
call :FindGame || exit /b 1
call :SetGamePaths

echo === The Mermaid Mask PL - weryfikacja Windows ===
echo Gra: !GAME_PATH!
echo.
set "ALL_OK=1"
set "FILE_COUNT=0"
for /f "usebackq eol=# tokens=1,*" %%H in ("!PATCH_MANIFEST!") do (
  call :VerifyFile "%%I" "%%H"
  set /a FILE_COUNT+=1
)
if "!FILE_COUNT!"=="0" (
  echo BLAD: manifest patcha jest pusty.
  exit /b 1
)
echo.
if "!ALL_OK!"=="1" (
  echo Wszystko zgodne - tlumaczenie jest zainstalowane poprawnie.
  exit /b 0
)
echo Znaleziono niezgodnosci - patrz szczegoly powyzej.
exit /b 1

:Restore
call :FindGame || exit /b 1
call :SetGamePaths
if not exist "!BACKUP_DIR!\source-sha256.txt" (
  echo BLAD: brak zweryfikowanej kopii zapasowej w !BACKUP_DIR!.
  echo Jesli backup zostal usuniety, przywroc pliki przez Steam lub GOG.
  exit /b 1
)
set "SOURCE_MANIFEST=!BACKUP_DIR!\source-sha256.txt"
where certutil.exe >nul 2>&1 || (
  echo BLAD: system nie zawiera certutil.exe potrzebnego do kontroli SHA-256.
  exit /b 1
)

echo === The Mermaid Mask - przywracanie oryginalu ===
echo Gra:    !GAME_PATH!
echo Backup: !BACKUP_DIR!
echo.

set "FILE_COUNT=0"
for /f "usebackq eol=# tokens=1,*" %%H in ("!SOURCE_MANIFEST!") do (
  call :PreflightRestore "%%I" "%%H" || exit /b 1
  set /a FILE_COUNT+=1
)
if "!FILE_COUNT!"=="0" (
  echo BLAD: manifest backupu jest pusty.
  exit /b 1
)
for /f "usebackq eol=# tokens=1,*" %%H in ("!SOURCE_MANIFEST!") do call :RestoreFile "%%I" || exit /b 1

echo.
echo Gotowe - przywrocono oryginalne pliki gry.
exit /b 0

:ValidatePackage
if not exist "!PATCH_DIR!" (
  echo BLAD: brak payloadu patcha: !PATCH_DIR!
  echo Pobierz paczke ponownie i nie przenos samych plikow BAT.
  exit /b 1
)
if not exist "!PATCH_MANIFEST!" (
  echo BLAD: brak manifestu patcha: !PATCH_MANIFEST!
  exit /b 1
)
if not exist "!SOURCE_MANIFEST!" (
  echo BLAD: brak manifestu oryginalnych plikow: !SOURCE_MANIFEST!
  exit /b 1
)
if not exist "!PLATFORM_FILE!" (
  echo BLAD: brak oznaczenia platformy: !PLATFORM_FILE!
  exit /b 1
)
set "PATCH_PLATFORM="
set /p "PATCH_PLATFORM="<"!PLATFORM_FILE!"
if /i not "!PATCH_PLATFORM!"=="windows" (
  echo BLAD: payload jest przeznaczony dla platformy !PATCH_PLATFORM!, nie Windows/Proton.
  exit /b 1
)
where certutil.exe >nul 2>&1 || (
  echo BLAD: system nie zawiera certutil.exe potrzebnego do kontroli SHA-256.
  exit /b 1
)
exit /b 0

:FindGame
set "GAME_PATH="
if defined EXPLICIT_PATH call :TryCandidate "!EXPLICIT_PATH!"
if defined GAME_PATH exit /b 0

if defined TMM_GAME_PATH call :TryCandidate "!TMM_GAME_PATH!"
if defined GAME_PATH exit /b 0

if exist "!ROOT!\game-path.env" (
  set "CONFIGURED="
  for /f "usebackq tokens=1,* delims==" %%A in ("!ROOT!\game-path.env") do if /i "%%A"=="GAME_PATH" set "CONFIGURED=%%B"
  if defined CONFIGURED (
    set "CONFIGURED=!CONFIGURED:"=!"
    call :TryCandidate "!CONFIGURED!"
  )
)
if defined GAME_PATH exit /b 0

for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do (
  set "STEAM_ROOT=%%B"
  call :TrySteamRoot
)
if defined GAME_PATH exit /b 0
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v InstallPath 2^>nul') do (
  set "STEAM_ROOT=%%B"
  call :TrySteamRoot
)
if defined GAME_PATH exit /b 0
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul') do (
  set "STEAM_ROOT=%%B"
  call :TrySteamRoot
)
if defined GAME_PATH exit /b 0

set "STEAM_ROOT=C:\Program Files (x86)\Steam"
call :TrySteamRoot
if defined GAME_PATH exit /b 0
set "STEAM_ROOT=C:\Program Files\Steam"
call :TrySteamRoot
if defined GAME_PATH exit /b 0

for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%D:\" (
  call :TryCandidate "%%D:\SteamLibrary\steamapps\common\!GAME_NAME!"
  if not defined GAME_PATH call :TryCandidate "%%D:\Steam\steamapps\common\!GAME_NAME!"
  if not defined GAME_PATH call :TryCandidate "%%D:\GOG Games\!GAME_NAME!"
)
if defined GAME_PATH exit /b 0

echo Nie znaleziono gry automatycznie.
set "MANUAL_PATH="
set /p "MANUAL_PATH=Wklej sciezke do folderu gry lub pliku EXE (Enter = anuluj): "
if defined MANUAL_PATH call :TryCandidate "!MANUAL_PATH!"
if not defined GAME_PATH (
  echo BLAD: nie znaleziono !DATA_DIR!\sharedassets1.assets.
  echo Mozesz tez ustawic GAME_PATH w pliku game-path.env obok folderu windows.
  exit /b 1
)
exit /b 0

:TrySteamRoot
if not defined STEAM_ROOT exit /b 0
set "STEAM_ROOT=!STEAM_ROOT:/=\!"
call :TryCandidate "!STEAM_ROOT!\steamapps\common\!GAME_NAME!"
if defined GAME_PATH exit /b 0
set "VDF=!STEAM_ROOT!\steamapps\libraryfolders.vdf"
if not exist "!VDF!" exit /b 0
for /f "usebackq tokens=*" %%L in ("!VDF!") do (
  set "VDF_LINE=%%L"
  for /f tokens^=2^,4^ delims^=^" %%A in ("!VDF_LINE!") do if not "%%B"=="" (
    set "LIBRARY=%%B"
    set "LIBRARY=!LIBRARY:\\=\!"
    call :TryCandidate "!LIBRARY!\steamapps\common\!GAME_NAME!"
  )
)
exit /b 0

:TryCandidate
if defined GAME_PATH exit /b 0
set "CANDIDATE=%~1"
set "CANDIDATE=!CANDIDATE:"=!"
if not defined CANDIDATE exit /b 0
set "CANDIDATE=!CANDIDATE:/=\!"
if exist "!CANDIDATE!" for %%I in ("!CANDIDATE!") do if /i "%%~xI"==".exe" set "CANDIDATE=%%~dpI"
if exist "!CANDIDATE!" for %%I in ("!CANDIDATE!") do set "CANDIDATE=%%~fI"
if exist "!CANDIDATE!\sharedassets1.assets" for %%I in ("!CANDIDATE!\..") do set "CANDIDATE=%%~fI"
if exist "!CANDIDATE!\!GAME_NAME!.exe" if exist "!CANDIDATE!\!DATA_DIR!\sharedassets1.assets" set "GAME_PATH=!CANDIDATE!"
exit /b 0

:SetGamePaths
set "BACKUP_DIR=!GAME_PATH!\.the_mermaid_mask_pl_backup\windows"
exit /b 0

:GetPatchHash
set "PATCH_HASH="
set "LOOKUP_REL=%~1"
set "LOOKUP_REL=!LOOKUP_REL:\=/!"
for /f "usebackq eol=# tokens=1,*" %%P in ("!PATCH_MANIFEST!") do if /i "%%Q"=="!LOOKUP_REL!" set "PATCH_HASH=%%P"
if not defined PATCH_HASH (
  echo BLAD: manifest patcha nie zawiera pliku !LOOKUP_REL!.
  exit /b 1
)
exit /b 0

:GetHash
set "FILE_HASH="
for /f "skip=1 tokens=*" %%H in ('certutil.exe -hashfile "!HASH_FILE!" SHA256 2^>nul') do if not defined FILE_HASH set "FILE_HASH=%%H"
set "FILE_HASH=!FILE_HASH: =!"
if not defined FILE_HASH (
  echo BLAD: nie mozna obliczyc SHA-256 pliku !HASH_FILE!.
  exit /b 1
)
exit /b 0

:PreflightFile
set "REL=%~1"
set "REL=!REL:/=\!"
set "SOURCE_HASH=%~2"
call :GetPatchHash "!REL!" || exit /b 1
set "PATCH_FILE=!PATCH_DIR!\!REL!"
set "TARGET_FILE=!GAME_PATH!\!REL!"
set "BACKUP_FILE=!BACKUP_DIR!\!REL!"
if not exist "!PATCH_FILE!" (
  echo BLAD: brak pliku patcha !REL!.
  exit /b 1
)
if not exist "!TARGET_FILE!" (
  echo BLAD: brak pliku gry !REL!.
  exit /b 1
)
set "HASH_FILE=!PATCH_FILE!"
call :GetHash || exit /b 1
if /i not "!FILE_HASH!"=="!PATCH_HASH!" (
  echo BLAD: plik patcha ma nieprawidlowa sume SHA-256: !REL!.
  echo Pobierz paczke ponownie.
  exit /b 1
)
set "HASH_FILE=!TARGET_FILE!"
call :GetHash || exit /b 1
set "TARGET_HASH=!FILE_HASH!"
if /i "!TARGET_HASH!"=="!SOURCE_HASH!" exit /b 0
if /i "!TARGET_HASH!"=="!PATCH_HASH!" (
  if not exist "!BACKUP_FILE!" (
    echo BLAD: !REL! jest juz spatchowany, ale brakuje bezpiecznego backupu.
    echo Przywroc pliki przez Steam lub GOG przed ponowna instalacja.
    exit /b 1
  )
  set "HASH_FILE=!BACKUP_FILE!"
  call :GetHash || exit /b 1
  if /i "!FILE_HASH!"=="!SOURCE_HASH!" exit /b 0
  echo BLAD: backup pliku !REL! jest uszkodzony lub pochodzi z innej wersji gry.
  exit /b 1
)
echo BLAD: nieobslugiwana wersja lub zmodyfikowany plik gry: !REL!.
echo Sprawdz spojnosc plikow w Steam/GOG i uruchom instalator ponownie.
exit /b 1

:InstallFile
set "REL=%~1"
set "REL=!REL:/=\!"
set "SOURCE_HASH=%~2"
set "PATCH_FILE=!PATCH_DIR!\!REL!"
set "TARGET_FILE=!GAME_PATH!\!REL!"
set "BACKUP_FILE=!BACKUP_DIR!\!REL!"
set "HASH_FILE=!TARGET_FILE!"
call :GetHash || exit /b 1
if /i "!FILE_HASH!"=="!SOURCE_HASH!" (
  for %%D in ("!BACKUP_FILE!") do if not exist "%%~dpD" mkdir "%%~dpD" || exit /b 1
  copy /y "!TARGET_FILE!" "!BACKUP_FILE!" >nul || exit /b 1
  echo   backup:       !REL!
)
copy /y "!PATCH_FILE!" "!TARGET_FILE!" >nul || exit /b 1
echo   zainstalowano: !REL!
exit /b 0

:VerifyFile
set "REL=%~1"
set "REL=!REL:/=\!"
set "EXPECTED_HASH=%~2"
set "TARGET_FILE=!GAME_PATH!\!REL!"
if not exist "!TARGET_FILE!" (
  echo   BRAK: !REL!
  set "ALL_OK=0"
  exit /b 0
)
set "HASH_FILE=!TARGET_FILE!"
call :GetHash || (
  set "ALL_OK=0"
  exit /b 0
)
if /i "!FILE_HASH!"=="!EXPECTED_HASH!" (
  echo   OK: !REL!
) else (
  echo   ROZNI SIE: !REL!
  set "ALL_OK=0"
)
exit /b 0

:MigrateLegacyBackup
set "LEGACY_BACKUP=!SCRIPT_DIR!backup"
if not exist "!LEGACY_BACKUP!" exit /b 0
for /f "usebackq eol=# tokens=1,*" %%H in ("!SOURCE_MANIFEST!") do call :MigrateLegacyFile "%%I" "%%H"
exit /b 0

:MigrateLegacyFile
set "REL=%~1"
set "REL=!REL:/=\!"
set "EXPECTED_HASH=%~2"
set "LEGACY_FILE=!LEGACY_BACKUP!\!REL!"
set "BACKUP_FILE=!BACKUP_DIR!\!REL!"
if not exist "!LEGACY_FILE!" exit /b 0
if exist "!BACKUP_FILE!" exit /b 0
set "HASH_FILE=!LEGACY_FILE!"
call :GetHash || exit /b 0
if /i not "!FILE_HASH!"=="!EXPECTED_HASH!" exit /b 0
for %%D in ("!BACKUP_FILE!") do if not exist "%%~dpD" mkdir "%%~dpD" >nul 2>&1
copy /y "!LEGACY_FILE!" "!BACKUP_FILE!" >nul
echo   przeniesiono stary backup: !REL!
exit /b 0

:RollbackFiles
if not exist "!BACKUP_DIR!" exit /b 0
for /f "usebackq eol=# tokens=1,*" %%H in ("!SOURCE_MANIFEST!") do call :RollbackFile "%%I" "%%H"
exit /b 0

:RollbackFile
set "REL=%~1"
set "REL=!REL:/=\!"
set "EXPECTED_HASH=%~2"
set "BACKUP_FILE=!BACKUP_DIR!\!REL!"
set "TARGET_FILE=!GAME_PATH!\!REL!"
if not exist "!BACKUP_FILE!" exit /b 0
set "HASH_FILE=!BACKUP_FILE!"
call :GetHash || exit /b 0
if /i not "!FILE_HASH!"=="!EXPECTED_HASH!" exit /b 0
copy /y "!BACKUP_FILE!" "!TARGET_FILE!" >nul
exit /b 0

:PreflightRestore
set "REL=%~1"
set "REL=!REL:/=\!"
set "EXPECTED_HASH=%~2"
set "BACKUP_FILE=!BACKUP_DIR!\!REL!"
if not exist "!BACKUP_FILE!" (
  echo BLAD: backup nie zawiera pliku !REL!.
  exit /b 1
)
set "HASH_FILE=!BACKUP_FILE!"
call :GetHash || exit /b 1
if /i not "!FILE_HASH!"=="!EXPECTED_HASH!" (
  echo BLAD: backup pliku !REL! ma nieprawidlowa sume SHA-256.
  exit /b 1
)
exit /b 0

:RestoreFile
set "REL=%~1"
set "REL=!REL:/=\!"
set "BACKUP_FILE=!BACKUP_DIR!\!REL!"
set "TARGET_FILE=!GAME_PATH!\!REL!"
for %%D in ("!TARGET_FILE!") do if not exist "%%~dpD" mkdir "%%~dpD" || exit /b 1
copy /y "!BACKUP_FILE!" "!TARGET_FILE!" >nul || exit /b 1
echo   przywrocono: !REL!
exit /b 0
