# Everland BBS Project

This directory contains all resources for running Everland as a BBS door game on Commodore 64 platforms.

## Subfolders
- color64/: Full door game for Color 64 BBS
- cbase/: Full door game for C*Base BBS
- custom/: Minimal custom BBS shell and integration

## Shared Features
- SHARED_FEATURES.md: Design for high scores, message board, async PvP
- SHARED_FEATURES.asm: Assembly routines for shared features
- SHARED_FEATURES_BASIC.bas: BASIC routines for shared features

## Build & Integration
- Each BBS folder contains loader, modem I/O abstraction, and main game source
- See each folder's README and PORTING_NOTES for details

## Next Steps
- Port/adapt everland.asm logic to each BBS version using modem I/O
- Implement shared features for persistent community play
