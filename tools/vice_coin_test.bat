@echo off
REM Launch coin grant playtest: loads from D64, then talks to conductor and selects quest.
REM Usage: vice_coin_test.bat [path\to\x64sc.exe] [path\to\everland.d64]

SETLOCAL
SET "VICE="
SET "D64="

IF NOT "%~1"=="" SET "VICE=%~1"
IF NOT "%~2"=="" SET "D64=%~2"

REM Build post key buffer: ensure lowercase for PETSCII safety
REM Provide login answers: username, display, class, pin, month, week
SET "POST=\n \n eve\n \n eve\n \n knight\n \n 0\n \n 4\n \n 14\n \n talk conductor\n \n \n 3\n \n \n i\n \n \n"

CALL "%~dp0run_from_d64.bat" "%VICE%" "%D64%" "%POST%"

ENDLOCAL
EXIT /B %ERRORLEVEL%
