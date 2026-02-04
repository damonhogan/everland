# Everland BBS Shared Features

This document describes shared features for all BBS integrations: high scores, message boards, and asynchronous PvP.

## High Score Table
- Store player scores in a sequential file (e.g., "HISCORES").
- Update after each game session if the player's score qualifies.
- Display top scores from the file on request.

## Message Board
- Store messages in a sequential file (e.g., "BBSMSG").
- Allow players to post new messages and read existing ones.
- Limit message length and number for C64 memory constraints.

## Asynchronous PvP (Ghost Battles/Challenges)
- Save a "ghost" record of a player's stats, moves, or challenge in a file (e.g., "GHOSTS").
- Next player can choose to battle a ghost or accept a challenge.
- Record outcome and update ghost/challenge file.

## File Format Suggestions
- Use PRG or SEQ files for data storage.
- Each record: fixed-length or delimited fields (PETSCII encoding).
- Example high score record: USERNAME, SCORE, DATE
- Example message: USERNAME, DATE, MESSAGE
- Example ghost: USERNAME, STATS, MOVES, OUTCOME

## Implementation Notes
- All routines should use device 8 (disk) for file I/O.
- PETSCII encoding for all text.
- Keep routines modular for reuse across BBS platforms.
