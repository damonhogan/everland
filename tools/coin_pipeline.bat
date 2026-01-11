@echo off
REM One-click pipeline: build, D64, coin test, EVLOG extract
REM Usage: coin_pipeline.bat [KickAss.jar] [x64sc.exe] [everland.d64]

SETLOCAL
SET "KJAR=%~1"
SET "VICE=%~2"
SET "D64=%~3"
IF "%KJAR%"=="" SET "KJAR=C:\commodore\KickAssembler\KickAss.jar"
IF "%VICE%"=="" IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe" SET "VICE=C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe"
IF "%D64%"=="" SET "D64=%~dp0..\bin\everland.d64"

ECHO === Build PRG and D64 ===
CALL "%~dp0build_prg_simple.bat" "%KJAR%"
IF ERRORLEVEL 1 GOTO :build_fail

ECHO === Coin quest playtest ===
CALL "%~dp0vice_coin_test.bat" "%VICE%" "%D64%"

ECHO === Extract EVLOG from D64 ===
CALL "%~dp0vice_evlog_from_d64.bat" "%VICE%" "%D64%"
ECHO === View EVLOG ===
CALL "%~dp0view_evlog.bat" "%D64%"

ENDLOCAL
EXIT /B 0

:build_fail
ECHO Build failed (%ERRORLEVEL%).
ENDLOCAL
EXIT /B %ERRORLEVEL%
