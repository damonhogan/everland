Tools README

This folder contains helper scripts for building and running the game normally.

- `build_prg.bat` and `build_prg_simple.bat`: Assemble `everland.asm` with KickAssembler and write `bin/everland.prg`.
- `make_d64.bat`: Create or refresh `bin/everland.d64` and add the PRG.
- `run_from_d64.bat`: Launch VICE with the disk image and perform a simple `LOAD/RUN` to start the game.

Typical workflow on Windows:

```powershell
C:\commodore\everland\tools\build_prg_simple.bat "C:\commodore\KickAssembler\KickAss.jar"
C:\commodore\everland\tools\run_from_d64.bat "C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe" "C:\commodore\everland\bin\everland.d64"
```
