@echo off
REM Launch VICE with drive 8 mapped to a host folder, then auto LOAD/RUN and test EVLOG.
REM Usage: run_from_fs_dev8.bat [path\to\x64sc.exe] [hostFolderForDrive8]

SETLOCAL
SET "VICE="
SET "FS8DIR="

IF NOT "%~1"=="" SET "VICE=%~1"
IF NOT "%~2"=="" SET "FS8DIR=%~2"
IF "%VICE%"=="" IF EXIST "C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe" SET "VICE=C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe"
IF "%FS8DIR%"=="" SET "FS8DIR=%~dp0..\bin"
IF NOT EXIST "%FS8DIR%" (
  echo Folder for FS device 8 not found: %FS8DIR%
  ENDLOCAL & EXIT /B 1
)

REM Key buffer: wildcard load from FS device 8 and run; then talk conductor + 3
SET "KEYBUF=\n \n \n load"*",8,1\n \n run\n\n \n talk conductor\n 3\n"

"%VICE%" -8 "%FS8DIR%" -keybuf "%KEYBUF%"

REM After emulator exits, check for EVLOG in the mapped folder
IF EXIST "%FS8DIR%\EVLOG" (
  echo EVLOG found: %FS8DIR%\EVLOG
  ENDLOCAL & EXIT /B 0
) ELSE (
  echo EVLOG not found in %FS8DIR%. Ensure virtual device traps are enabled.
  ENDLOCAL & EXIT /B 2
)
