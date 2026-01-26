# Copilot Instructions for Everland

## Project Overview
- **Everland** is a single-file Commodore 64 text adventure, written in Kick Assembler (see `everland.asm`).
- The project targets the C64 and is built/run on Windows using helper scripts in `tools/`.
- The main binary is `bin/everland.prg`, distributed on a D64 disk image (`bin/everland.d64`).

## Key Files & Structure
- `everland.asm`: Main source (over 13,000 lines), includes all game logic, data, and engine code.
- `constants.inc`: Shared constants and labels for KERNAL, SID, IRQ, and memory.
- `tools/`: Contains all build, run, and utility scripts (see below).
- `bin/`: Output directory for PRG, D64, and build logs.
- `MANUAL.md`: Full game and developer manual, including feature lists and developer notes.

## Build & Run Workflow
- **Build PRG:**
  - Use `tools/build_prg_simple.bat` (preferred) or `tools/build_prg.bat` to assemble `everland.asm` with KickAssembler.
  - Example: 
    ```powershell
    tools/build_prg_simple.bat "C:/commodore/KickAssembler/KickAss.jar"
    ```
- **Create/Update D64:**
  - `tools/make_d64.bat` adds the PRG to a disk image.
- **Run in Emulator:**
  - `tools/run_from_d64.bat` launches VICE with the D64 and auto-loads the game.
  - Example:
    ```powershell
    tools/run_from_d64.bat "C:/commodore/GTK3VICE-3.10-win64/bin/x64sc.exe" "bin/everland.d64"
    ```
- **Manual & PDF:**
  - `tools/build_manual.ps1` builds a PDF manual from `MANUAL.md` using Pandoc/wkhtmltopdf or LaTeX.

## Project Conventions & Patterns
- **Single-file architecture:** All game logic, data, and engine code are in `everland.asm` for simplicity and C64 memory constraints.
- **Constants:** Shared in `constants.inc`, always included at the top of `everland.asm`.
- **Labels:** Use `.label` for addresses and `.const` for values; follow C64/KickAssembler conventions.
- **Game Data:** Tables for locations, NPCs, items, and quests are defined as arrays in the main ASM file.
- **Save/Load:** Custom EVx formats, backward compatible; see `MANUAL.md` for details.
- **Testing:** No automated tests; test by running in VICE and using in-game features/quests.
- **Debugging:** Use VICE monitor and symbol files (`bin/everland.sym`, `bin/everland.vs`).

## External Dependencies
- **KickAssembler** (Java JAR): Required for building.
- **VICE** (x64sc.exe, c1541.exe): Required for running and disk image management.
- **Pandoc/wkhtmltopdf/LaTeX:** For manual PDF generation (optional).

## Notable Patterns & Tips
- **Workflow is script-driven:** Always use the provided batch/PS scripts for building and running; do not invoke KickAssembler or VICE directly unless you replicate script logic.
- **Device 8:** All file I/O (save/load, EVLOG) targets device 8 (C64 disk drive convention).
- **PETSCII:** All string data and I/O use PETSCII encoding.
- **Game state:** Player/NPC data, inventory, quests, and coins are managed in arrays/tables; see `MANUAL.md` for variable names and flows.
- **Manual is authoritative:** For feature details, developer notes, and walkthroughs, always consult `MANUAL.md`.

## Examples
- To build and run after editing `everland.asm`:
  ```powershell
  tools/build_prg_simple.bat "C:/commodore/KickAssembler/KickAss.jar"
  tools/run_from_d64.bat "C:/commodore/GTK3VICE-3.10-win64/bin/x64sc.exe" "bin/everland.d64"
  ```
- To generate a PDF manual:
  ```powershell
  powershell -ExecutionPolicy Bypass -File tools/build_manual.ps1
  ```

---
For more, see `MANUAL.md` and scripts in `tools/`.
