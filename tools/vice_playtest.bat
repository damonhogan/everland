@echo off
REM Simple VICE launcher for Everland
REM Usage: vice_playtest.bat [C:\path\to\x64sc.exe] [C:\path\to\everland.prg] [keybuf]

SETLOCAL
SET DEFAULT_VICE="C:\Program Files (x86)\VICE\x64sc.exe"
IF "%~1"=="" (
  SET VICE=%DEFAULT_VICE%
) ELSE (
  SET VICE=%~1
)
IF "%~2"=="" (
  SET PRG=%~dp0\..\bin\everland.prg
) ELSE (
  SET PRG=%~2
)

REM Default key buffer: move to TRAIN, talk conductor, pick quest, confirm, inventory
IF "%~3"=="" (
  REM Add initial newlines to ensure clean prompt, then run sequence
  SET KEYBUF=\n \n north\n talk conductor\n 3\n \n i\n i\n
) ELSE (
  SET KEYBUF=%~3
)

IF NOT EXIST %VICE% (
  ECHO x64sc not found at %VICE%
  ECHO Please pass the path to x64sc.exe as first argument.
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
