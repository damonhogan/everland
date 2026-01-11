@echo off
REM Launch PRG directly with autostart and try virtual FS, then check EVLOG.
REM Usage: vice_evlog_test.bat [path\to\x64sc.exe] [path\to\everland.prg]

SETLOCAL
SET "VICE="
SET "PRG="

IF NOT "%~1"=="" SET "VICE=%~1"
IF NOT "%~2"=="" SET "PRG=%~2"
IF "%VICE%"=="" IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe" SET "VICE=C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe"
IF "%PRG%"=="" SET "PRG=%~dp0..\bin\everland.prg"
IF NOT EXIST "%PRG%" (
  echo PRG not found: %PRG%
  ENDLOCAL & EXIT /B 1
)

REM Build key buffer: talk conductor, pick quest, open inventory
SET "KEYBUF=\n \n talk conductor\n 3\n i\n"

REM Try autostart in PRG mode 0 (virtual device traps); rely on default FS mapping to PRG directory
"%VICE%" -autostart "%PRG%" -autostartprgmode 0 -virtualdev 1 -driveTrueEmulation 0 -keybuf "%KEYBUF%"

REM After emulator exits, check for EVLOG next to PRG
SET "PRGDIR=%~dp0..\bin"
IF EXIST "%PRGDIR%\EVLOG" (
  echo EVLOG found: %PRGDIR%\EVLOG
  ENDLOCAL & EXIT /B 0
) ELSE (
  echo EVLOG not found in %PRGDIR%. Ensure virtual device traps are enabled.
  ENDLOCAL & EXIT /B 2
)
