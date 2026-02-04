; Shared features for Everland BBS: high scores, message board, async PvP
; All routines use device 8 for file I/O and PETSCII encoding

; High Score Table
; Save: Write username, score, date to "HISCORES" (SEQ file)
; Load: Read and display top scores

; Message Board
; Save: Write username, date, message to "BBSMSG" (SEQ file)
; Load: Read and display messages

; Async PvP (Ghost Battles)
; Save: Write username, stats, moves, outcome to "GHOSTS" (SEQ file)
; Load: Read and offer ghost battles/challenges

; All routines should be modular for reuse across BBS platforms
; See SHARED_FEATURES.md for file format details
