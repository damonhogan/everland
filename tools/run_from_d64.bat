@echo off
REM Launch VICE with EVERLAND.D64 on drive 8 and auto LOAD/RUN
REM Usage: run_from_d64.bat [path\to\x64sc.exe] [path\to\everland.d64] [post_keybuf]

SETLOCAL
SET "VICE="
SET "D64="
SET "POSTBUF="

REM Resolve VICE path
IF NOT "%~1"=="" SET "VICE=%~1"
IF "%VICE%"=="" IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe" SET "VICE=C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe"
IF "%VICE%"=="" IF EXIST "%ProgramFiles(x86)%\VICE\x64sc.exe" SET "VICE=%ProgramFiles(x86)%\VICE\x64sc.exe"
IF "%VICE%"=="" (
  ECHO x64sc.exe not found. Please pass path as first argument.
  ENDLOCAL & EXIT /B 1
)

REM Resolve D64 path
IF NOT "%~2"=="" SET "D64=%~2"
IF "%D64%"=="" SET "D64=%~dp0..\bin\everland.d64"

REM Optional appended key buffer after RUN (e.g., in-game commands)
IF NOT "%~3"=="" SET "POSTBUF=%~3"

REM Ensure D64 exists; if missing, try to (re)create from PRG
IF NOT EXIST "%D64%" (
  CALL "%~dp0make_d64.bat" "%~dp0..\bin\everland.prg" "%~dp0..\bin"
)
IF NOT EXIST "%D64%" (
  ECHO D64 not found: %D64%
  ENDLOCAL & EXIT /B 1
)

REM Build key buffer: clean prompt, LOAD and RUN, then optional post commands
REM Add extra newlines up front to ensure BASIC is ready
SET "KEYBUF=\n \n \n \n \n load\"*\",8,1\n \n run\n"
IF NOT "%POSTBUF%"=="" SET "KEYBUF=%KEYBUF%%POSTBUF%"

"%VICE%" -8 "%D64%" -keybuf "%KEYBUF%"

ENDLOCAL
EXIT /B 0
