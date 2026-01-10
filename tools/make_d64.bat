@echo off
REM Generate/refresh EVERLAND.D64 with the latest PRG
REM Usage: make_d64.bat [path\to\everland.prg] [outdir]

SETLOCAL
IF NOT "%~1"=="" SET "PRG=%~1"
IF "%PRG%"=="" SET "PRG=%~dp0..\bin\everland.prg"
IF NOT "%~2"=="" SET "OUTDIR=%~2"
IF "%OUTDIR%"=="" SET "OUTDIR=%~dp0..\bin"
SET "D64=%OUTDIR%\everland.d64"

REM Locate c1541.exe (GTK3VICE, Program Files, Program Files (x86), or VICE_BIN env)
SET "C1541="
SET "PF=%ProgramFiles%"
SET "PF86=%ProgramFiles(x86)%"
IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\c1541.exe" SET "C1541=C:\commodore\GTK3VICE-3.10-win64\bin\c1541.exe"
IF "%C1541%"=="" IF EXIST "%PF%\VICE\c1541.exe" SET "C1541=%PF%\VICE\c1541.exe"
IF "%C1541%"=="" IF EXIST "%PF86%\VICE\c1541.exe" SET "C1541=%PF86%\VICE\c1541.exe"
IF NOT "%VICE_BIN%"=="" IF EXIST "%VICE_BIN%\c1541.exe" SET "C1541=%VICE_BIN%\c1541.exe"

IF "%C1541%"=="" ECHO c1541.exe not found. Set VICE_BIN or install VICE. & ENDLOCAL & EXIT /B 0
IF NOT EXIST "%PRG%" ECHO PRG not found: %PRG% & ENDLOCAL & EXIT /B 1

ECHO Creating D64: %D64%
"%C1541%" -format "EVERLAND,00" d64 "%D64%"
"%C1541%" -attach "%D64%" -write "%PRG%" "EVERLAND"

ENDLOCAL
EXIT /B %ERRORLEVEL%
