; Modem I/O abstraction for Color 64 BBS door
; Use device 2 for all input/output
; Replace all CHRIN/CHROUT with these routines

.modem_in
    LDX #2
    JSR CHKIN ; Set input to device 2
    JSR CHRIN ; Read char from modem
    JSR CLRCHN
    RTS

.modem_out
    LDX #2
    JSR CHKOUT ; Set output to device 2
    JSR CHROUT ; Output char to modem
    JSR CLRCHN
    RTS
