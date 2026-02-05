// Modem I/O abstraction for custom BBS shell
// Use device 2 for all input/output

// KERNAL routine addresses
.label CHKIN = $FFC6
.label CHRIN = $FFCF
.label CHKOUT = $FFC9
.label CHROUT = $FFD2
.label CLRCHN = $FFCC

modem_in:
    LDX #2
    JSR CHKIN // Set input to device 2
    JSR CHRIN // Read char from modem
    JSR CLRCHN
    RTS

modem_out:
    LDX #2
    JSR CHKOUT // Set output to device 2
    JSR CHROUT // Output char to modem
    JSR CLRCHN
    RTS
