@echo off
REM Minimal builder to avoid parser issues with parentheses
REM Usage: build_prg_simple.bat [KickAss.jar] [source.asm] [outdir]

SETLOCAL
IF NOT "%~1"=="" SET "KJAR=%~1"
IF "%KJAR%"=="" SET "KJAR=%~dp0KickAss.jar"
IF "%KJAR%"=="" IF NOT "%KICKASS_JAR%"=="" SET "KJAR=%KICKASS_JAR%"
REM Also accept KickAss installed at C:\commodore\KickAssembler\KickAss.jar
IF "%KJAR%"=="" IF EXIST "C:\commodore\KickAssembler\KickAss.jar" SET "KJAR=C:\commodore\KickAssembler\KickAss.jar"
IF "%~2"=="" SET "SRC=%~dp0..\everland.asm"
IF NOT "%~2"=="" SET "SRC=%~2"
IF "%~3"=="" SET "OUTDIR=%~dp0..\bin"
IF NOT "%~3"=="" SET "OUTDIR=%~3"
IF NOT EXIST "%KJAR%" (
	IF EXIST "C:\commodore\KickAssembler\KickAss.jar" (
		SET "KJAR=C:\commodore\KickAssembler\KickAss.jar"
	) ELSE (
		ECHO KickAssembler JAR not found: %KJAR%
		EXIT /B 1
	)
)
IF NOT EXIST "%OUTDIR%" MD "%OUTDIR%"
SET "OUTPRG=%OUTDIR%\everland.prg"
SET "OUTSYM=%OUTDIR%\everland.sym"
SET "OUTVS=%OUTDIR%\everland.vs"
SET "OUTLOG=%OUTDIR%\buildlog.txt"
java -version >NUL 2>&1 || EXIT /B 1
java -jar "%KJAR%" "%SRC%" -o "%OUTPRG%" -symbolfile "%OUTSYM%" -vicesymbols "%OUTVS%" -log "%OUTLOG%"
SET RET=%ERRORLEVEL%
IF "%RET%"=="0" CALL "%~dp0make_d64.bat" "%OUTPRG%" "%OUTDIR%"
ENDLOCAL
EXIT /B %RET%
