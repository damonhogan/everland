
# Copilot Instructions for Everland

## Project Overview
- **Everland** is a single-file Commodore 64 text adventure, written in Kick Assembler (see everland.asm).
- All game logic, data, and engine code are in everland.asm (13k+ lines) for C64 memory constraints and simplicity.
- The project targets C64, built and run on Windows using helper scripts in tools/.
- Main binary: bin/everland.prg, distributed on a D64 disk image (bin/everland.d64).

## Key Files & Structure
- everland.asm: Main source (all logic, data, engine, tables, and game content).
- constants.inc: Shared constants and labels for KERNAL, SID, IRQ, memory, and device I/O.
- tools/: All build, run, and utility scripts (batch and PowerShell).
- bin/: Output directory for PRG, D64, logs, and symbol files.
- MANUAL.md: Full game and developer manual, including feature lists, developer notes, and walkthroughs.

## Build & Run Workflow
- **Build PRG:** Use tools/build_prg_simple.bat (preferred) or tools/build_prg.bat to assemble everland.asm with KickAssembler. Example:
  powershell
  tools/build_prg_simple.bat "C:/commodore/KickAssembler/KickAss.jar"
- **Create/Update D64:** tools/make_d64.bat adds the PRG to a disk image.
- **Run in Emulator:** tools/run_from_d64.bat launches VICE with the D64 and auto-loads the game. Example:
  powershell
  tools/run_from_d64.bat "C:/commodore/GTK3VICE-3.10-win64/bin/x64sc.exe" "bin/everland.d64"
- **Automated Playtest:** tools/vice_playtest.ps1 and tools/vice_playtest.bat launch VICE and send scripted key sequences for smoke tests.
- **Manual & PDF:** tools/build_manual.ps1 builds a PDF manual from MANUAL.md using Pandoc/wkhtmltopdf or LaTeX.

## Project Conventions & Patterns
- **Single-file architecture:** All code and data in everland.asm. No modularization; arrays/tables for locations, NPCs, items, quests, and state.
- **Constants:** Shared in constants.inc, always included at the top of everland.asm.
- **Labels:** Use .label for addresses, .const for values; follow C64/KickAssembler conventions.
- **Game Data:** Tables for locations, NPCs, items, quests, and trinkets are arrays in everland.asm.
- **Save/Load:** Custom EVx formats (EV1-EV4), backward compatible. All file I/O targets device 8 (C64 disk drive convention).
- **String encoding:** All string data and I/O use PETSCII.
- **Game state:** Player/NPC data, inventory, quests, coins managed in arrays/tables. See MANUAL.md for variable names and flows.
- **Testing:** No automated tests; test by running in VICE and using in-game features/quests. Use playtest scripts for smoke tests.
- **Debugging:** Use VICE monitor and symbol files (bin/everland.sym, bin/everland.vs). Use EVLOG for quest logging (see tools/vice_evlog_from_d64.bat).
- **Manual is authoritative:** For feature details, developer notes, and walkthroughs, always consult MANUAL.md.

## External Dependencies
- **KickAssembler** (Java JAR): Required for building.
- **VICE** (x64sc.exe, c1541.exe): Required for running and disk image management.
- **Pandoc/wkhtmltopdf/LaTeX:** For manual PDF generation (optional).

## Notable Patterns & Tips
- **Script-driven workflow:** Always use provided scripts in tools/ for building, running, and playtesting. Do not invoke KickAssembler or VICE directly unless you replicate script logic.
- **Device 8:** All file I/O (save/load, EVLOG) targets device 8.
- **Input debounce:** Input handler does not accept two identical characters in a row (affects PINs, names, free-text prompts).
- **NPCs and Quests:** NPCs have level, HP, and trinkets; quests are tracked in arrays. See quest* and npc* tables in everland.asm.
- **Coin system:** PlayerGold, PlayerSilver, PlayerCopper store balances; inventory and quest rewards update these.
- **Playtest automation:** Use tools/vice_playtest.ps1 for scripted emulator flows and EVLOG extraction.
- **PDF/manual build:** Use tools/build_manual.ps1; supports xelatex, pdflatex, or wkhtmltopdf (with --enable-local-file-access for images).

## Examples
- Build and run after editing everland.asm:
  powershell
  tools/build_prg_simple.bat "C:/commodore/KickAssembler/KickAss.jar"
  tools/run_from_d64.bat "C:/commodore/GTK3VICE-3.10-win64/bin/x64sc.exe" "bin/everland.d64"
- Generate PDF manual:
  powershell
  powershell -ExecutionPolicy Bypass -File tools/build_manual.ps1
- Automated playtest:
  powershell
  powershell -ExecutionPolicy Bypass -File tools/vice_playtest.ps1

---
For more, see MANUAL.md and scripts in tools/.
