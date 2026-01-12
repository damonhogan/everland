@echo off
REM Simple VICE launcher for Everland
REM Usage: vice_playtest.bat [C:\path\to\x64sc.exe] [C:\path\to\everland.prg] [keybuf]

SETLOCAL
REM Resolve x64sc path: arg > env > common defaults
SET DEFAULT_VICE_X86="C:\Program Files (x86)\VICE\x64sc.exe"
SET DEFAULT_VICE_X64="C:\Program Files\VICE\x64sc.exe"
IF NOT "%~1"=="" (
  SET VICE=%~1
) ELSE IF NOT "%VICE_X64SC%"=="" (
  SET VICE=%VICE_X64SC%
) ELSE IF EXIST %DEFAULT_VICE_X64% (
  SET VICE=%DEFAULT_VICE_X64%
) ELSE (
  SET VICE=%DEFAULT_VICE_X86%
)
IF "%~2"=="" (
  SET PRG=%~dp0\..\bin\everland.prg
) ELSE (
  SET PRG=%~2
)

REM Default key buffer: move to TRAIN, talk conductor, pick quest, confirm, inventory
REM Allow KEYBUF to be provided via environment variable; else use arg3; else default
IF NOT "%KEYBUF%"=="" (
  SET KEYBUF=%KEYBUF%
) ELSE IF "%~3"=="" (
  REM Add initial newlines to ensure clean prompt, then run sequence
  SET KEYBUF=\n \n north\n talk conductor\n 3\n \n i\n i\n
) ELSE (
  SET KEYBUF=%~3
)

IF NOT EXIST %VICE% (
  ECHO x64sc not found at %VICE%
  ECHO Pass the path to x64sc.exe as first argument, or set env var VICE_X64SC.
  ECHO Example:
  ECHO   %~nx0 "C:\Program Files\VICE\x64sc.exe"
  ECHO   set VICE_X64SC="C:\Program Files\VICE\x64sc.exe" ^&^& %~nx0
  PAUSE
  EXIT /B 1
)
IF NOT EXIST "%PRG%" (
  ECHO PRG not found: %PRG%
  PAUSE
  EXIT /B 1
)

REM Launch VICE with autostart and warp for fast boot
REM Drop EVAUTO marker to trigger dev auto-login
echo 1>"%~dp0\..\bin\EVAUTO"
REM Launch VICE with autostart and key buffer (no warp to stabilize timing)
"%VICE%" -autostart "%PRG%" -autostartprgmode 0 -drive8truedrive 0 -virtualdevice8 1 -keybuf "%KEYBUF%"
ENDLOCAL
