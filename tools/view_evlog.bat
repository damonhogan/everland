@echo off
REM View EVLOG: prefer bin\EVLOG_extracted, else extract from D64 then print.
REM Usage: view_evlog.bat [path\to\everland.d64]

SETLOCAL
SET "D64=%~1"
SET "OUTDIR=%~dp0..\bin"
SET "EVHOST=%OUTDIR%\EVLOG_extracted"
IF "%D64%"=="" SET "D64=%OUTDIR%\everland.d64"

IF EXIST "%EVHOST%" (
  ECHO === EVLOG (host extracted) ===
  TYPE "%EVHOST%"
  ENDLOCAL & EXIT /B 0
)

REM Locate c1541.exe
SET "PF=%ProgramFiles%"
SET "PF86=%ProgramFiles(x86)%"
SET "C1541="
IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\c1541.exe" SET "C1541=C:\commodore\GTK3VICE-3.10-win64\bin\c1541.exe"
IF "%C1541%"=="" IF EXIST "%PF%\VICE\c1541.exe" SET "C1541=%PF%\VICE\c1541.exe"
IF "%C1541%"=="" IF EXIST "%PF86%\VICE\c1541.exe" SET "C1541=%PF86%\VICE\c1541.exe"
IF NOT "%VICE_BIN%"=="" IF EXIST "%VICE_BIN%\c1541.exe" SET "C1541=%VICE_BIN%\c1541.exe"

IF "%C1541%"=="" (
  ECHO c1541.exe not found. Set VICE_BIN or install VICE.
  ENDLOCAL & EXIT /B 2
)

IF NOT EXIST "%D64%" (
  ECHO D64 not found: %D64%
  ENDLOCAL & EXIT /B 3
)

REM Extract EVLOG from D64 then print
"%C1541%" -attach "%D64%" -read "EVLOG" "%EVHOST%"
IF EXIST "%EVHOST%" (
  ECHO === EVLOG (extracted from D64) ===
  TYPE "%EVHOST%"
  ENDLOCAL & EXIT /B 0
) ELSE (
  ECHO EVLOG not found in disk image.
  ENDLOCAL & EXIT /B 4
)
