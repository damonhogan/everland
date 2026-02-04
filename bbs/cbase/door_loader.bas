10 REM Everland Door Loader for C*Base BBS
20 OPEN 2,2,0: REM Open modem device
30 SYS 49152: REM Start Everland at $C000 (replace with actual address if needed)
40 CLOSE 2
50 END
