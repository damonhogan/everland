@echo off
REM Run from D64, then extract EVLOG from the disk image using c1541.
REM Usage: vice_evlog_from_d64.bat [path\to\x64sc.exe] [path\to\everland.d64]

SETLOCAL
SET "VICE="
SET "D64="
SET "PF=%ProgramFiles%"
SET "PF86=%ProgramFiles(x86)%"
SET "C1541="

IF NOT "%~1"=="" SET "VICE=%~1"
IF NOT "%~2"=="" SET "D64=%~2"
IF "%VICE%"=="" IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe" SET "VICE=C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe"
IF "%D64%"=="" SET "D64=%~dp0..\bin\everland.d64"
IF NOT EXIST "%D64%" (
  echo D64 not found: %D64%
  ENDLOCAL & EXIT /B 1
)

REM Run the game from D64 with login answers, TALK CONDUCTOR + 3, then inventory
SET "POST=\n \n eve\n \n eve\n \n knight\n \n 0\n \n 4\n \n 14\n \n talk conductor\n \n 3\n \n i\n \n"
CALL "%~dp0run_from_d64.bat" "%VICE%" "%D64%" "%POST%"

REM Give the game a moment to write EVLOG before extraction
TIMEOUT /T 3 /NOBREAK >NUL

REM Locate c1541.exe
IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\c1541.exe" SET "C1541=C:\commodore\GTK3VICE-3.10-win64\bin\c1541.exe"
IF "%C1541%"=="" IF EXIST "%PF%\VICE\c1541.exe" SET "C1541=%PF%\VICE\c1541.exe"
IF "%C1541%"=="" IF EXIST "%PF86%\VICE\c1541.exe" SET "C1541=%PF86%\VICE\c1541.exe"
IF NOT "%VICE_BIN%"=="" IF EXIST "%VICE_BIN%\c1541.exe" SET "C1541=%VICE_BIN%\c1541.exe"

IF "%C1541%"=="" (
  echo c1541.exe not found. Set VICE_BIN or install VICE.
  ENDLOCAL & EXIT /B 2
)

REM Try to extract EVLOG file from the D64 into bin folder
SET "OUTDIR=%~dp0..\bin"
SET "OUTLOG=%OUTDIR%\EVLOG_extracted"
"%C1541%" -attach "%D64%" -read "EVLOG" "%OUTLOG%"
IF EXIST "%OUTLOG%" (
  echo EVLOG extracted: %OUTLOG%
  ENDLOCAL & EXIT /B 0
) ELSE (
  echo EVLOG not found in disk image. It may not have been written.
  ENDLOCAL & EXIT /B 3
)
