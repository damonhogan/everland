# Everland Color 64 BBS Door

This folder contains the full door game version of Everland for Color 64 BBS.

## Files
- door_loader.bas: BASIC loader to launch the game as a door
- modem_io.inc: Assembly include for modem I/O abstraction (device 2)
- everland_bbs.asm: Main game source (to be ported from everland.asm)
- PORTING_NOTES.md: Porting checklist and tips

## Integration
- Place the PRG and loader in the Color 64 doors directory
- Configure the BBS to launch the loader as a door
- All game I/O is via the modem (device 2)

## Build
- Assemble everland_bbs.asm with KickAssembler or compatible assembler
- Use the loader to launch at $C000 (or adjust as needed)

## Porting Notes
- All CHROUT/CHRIN calls must use modem_io.inc routines
- File I/O (save/load) should use device 8 as in the original
- Remove or stub out SID/music code for BBS version
- Adapt main loop for single-user, BBS-driven play
