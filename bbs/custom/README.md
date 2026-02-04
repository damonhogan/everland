# Everland Minimal Custom BBS

This folder contains a minimal BBS shell in Commodore 64 BASIC/assembly for testing and integrating Everland as a door game.

## Files
- bbs_shell.bas: BASIC shell with menu and door launch
- modem_io.inc: Assembly include for modem I/O abstraction (device 2)
- everland_bbs.asm: Main game source (to be ported from everland.asm)

## Usage
- Load and run bbs_shell.bas in BASIC
- Select "Play Everland" to launch the door game
- All game I/O is via the modem (device 2)

## Build
- Assemble everland_bbs.asm with KickAssembler or compatible assembler
- Use the shell to launch at $C000 (or adjust as needed)

## Porting Notes
- All CHROUT/CHRIN calls must use modem_io.inc routines
- File I/O (save/load) should use device 8 as in the original
- Remove or stub out SID/music code for BBS version
- Adapt main loop for single-user, BBS-driven play

## Features
- Simple login prompt
- Main menu with option to launch Everland
- Handles modem/serial I/O (device 2)
- Returns to menu after game exit

## Example BASIC Shell
```basic
10 REM Minimal BBS Shell
20 PRINT "WELCOME TO EVERLAND BBS!"
30 INPUT "USERNAME: ",U$
40 PRINT "1. PLAY EVERLAND"
50 PRINT "2. HIGH SCORES"
60 PRINT "3. MESSAGE BOARD"
70 INPUT "OPTION: ",O
80 IF O=1 THEN GOSUB 200
90 IF O=2 THEN GOSUB 300
100 IF O=3 THEN GOSUB 400
110 GOTO 40
200 REM LAUNCH EVERLAND DOOR
210 OPEN 2,2,0: REM Open modem
220 SYS <EVERLAND_START_ADDR>: REM Start Everland (replace with actual address)
230 CLOSE 2
240 RETURN
300 REM HIGH SCORES
310 REM (Display high scores here)
320 RETURN
400 REM MESSAGE BOARD
410 REM (Display messages here)
420 RETURN
```

## Notes
- Replace <EVERLAND_START_ADDR> with the actual SYS address for Everland.
- Expand routines for high scores, message board, and async PvP as needed.
