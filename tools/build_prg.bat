@echo off
REM Build Everland PRG via KickAssembler (no PowerShell)
REM Usage:
REM   build_prg.bat [path\to\KickAss.jar] [source.asm] [outdir]
REM Examples:
REM   build_prg.bat "C:\tools\KickAss.jar"
REM   build_prg.bat "C:\Program Files\KickAssembler\KickAss.jar" ..\everland.asm ..\bin

SETLOCAL

REM Resolve KickAssembler JAR
REM Resolve KickAssembler JAR
IF NOT "%~1"=="" SET "KJAR=%~1"
IF "%~1"=="" SET "KJAR=%~dp0KickAss.jar"
REM Cache Program Files paths to avoid parser confusion with (x86)
SET "PF=%ProgramFiles%"
SET "PF86=%ProgramFiles(x86)%"
IF NOT EXIST "%KJAR%" SET "KJAR=%PF%\KickAssembler\KickAss.jar"
IF NOT EXIST "%KJAR%" SET "KJAR=%PF86%\KickAssembler\KickAss.jar"
IF NOT EXIST "%KJAR%" (
  ECHO KickAssembler JAR not found. Please provide path as first argument.
  ECHO Tried: %~dp0KickAss.jar ^| %PF%\KickAssembler\KickAss.jar ^| %PF86%\KickAssembler\KickAss.jar
  EXIT /B 1
)

REM Resolve source and output dir
IF NOT "%~2"=="" (
  SET "SRC=%~2"
) ELSE (
  SET "SRC=%~dp0..\everland.asm"
)
IF NOT "%~3"=="" (
  SET "OUTDIR=%~3"
) ELSE (
  SET "OUTDIR=%~dp0..\bin"
)

REM Ensure output directory exists
IF NOT EXIST "%OUTDIR%" (
  MKDIR "%OUTDIR%" || (
    ECHO Failed to create output directory: %OUTDIR%
    EXIT /B 1
  )
)

REM Build command
SET "OUTPRG=%OUTDIR%\everland.prg"
SET "OUTSYM=%OUTDIR%\everland.sym"
SET "OUTVS=%OUTDIR%\everland.vs"
SET "OUTLOG=%OUTDIR%\buildlog.txt"

ECHO Assembling %SRC% -> %OUTPRG%
java -version >NUL 2>&1 || (
  ECHO Java not found on PATH. Please install Java JRE/JDK.
  EXIT /B 1
)

REM Run KickAssembler
java -jar "%KJAR%" "%SRC%" -o "%OUTPRG%" -symbolfile "%OUTSYM%" -vicesymbols "%OUTVS%" -log "%OUTLOG%"
SET RET=%ERRORLEVEL%
IF NOT "%RET%"=="0" (
  ECHO Build failed with exit code %RET%. See log: %OUTLOG%
  EXIT /B %RET%
)

ECHO Build succeeded.
ECHO Output: %OUTPRG%
ECHO Symbols: %OUTSYM% ^| VICE: %OUTVS%
ECHO Log: %OUTLOG%

ENDLOCAL
EXIT /B 0
