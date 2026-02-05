

# Copilot Instructions for Everland

## Project Overview

**Everland** is a single-file Commodore 64 text adventure, written in Kick Assembler. All game logic, data, and engine code are in everland.asm (13k+ lines) for C64 memory constraints and simplicity. The project targets C64, built and run on Windows using helper scripts in tools/.

**Key outputs:**
- Main binary: bin/everland.prg
- Disk image: bin/everland.d64

## Key Files & Structure

- everland.asm: All game logic, data, engine, and content (single-file architecture)
- constants.inc: Shared constants/labels for KERNAL, SID, IRQ, memory, device I/O
- tools/: All build, run, and utility scripts (batch/PowerShell)
- bin/: Output directory for PRG, D64, logs, and symbol files
- MANUAL.md: Full game and developer manual (feature lists, walkthroughs, dev notes)
- bbs/: BBS door game ports and shared features

## Build & Run Workflow

**Always use scripts in tools/** (do not invoke KickAssembler or VICE directly):

- **Build PRG:**
  - tools/build_prg_simple.bat "C:/commodore/KickAssembler/KickAss.jar"
- **Update D64:**
  - tools/make_d64.bat
- **Run in VICE emulator:**
  - tools/run_from_d64.bat "C:/commodore/GTK3VICE-3.10-win64/bin/x64sc.exe" "bin/everland.d64"
- **Automated playtest:**
  - tools/vice_playtest.ps1 (scripted emulator flows, smoke tests)
- **Build PDF manual:**
  - tools/build_manual.ps1 (Pandoc/wkhtmltopdf/LaTeX)

## Project Conventions & Patterns

- **Single-file:** All code/data in everland.asm; no modularization
- **Constants:** constants.inc, always included at top of everland.asm
- **Labels:** .label for addresses, .const for values (KickAssembler/C64 style)
- **Game data:** Arrays/tables for locations, NPCs, items, quests, trinkets
- **Save/Load:** Custom EVx formats (EV1-EV4), all file I/O targets device 8
- **String encoding:** PETSCII for all string data and I/O
- **Game state:** Player/NPC data, inventory, quests, coins in arrays/tables
- **Input debounce:** Input handler ignores two identical chars in a row
- **Debugging:** Use VICE monitor, bin/everland.sym, bin/everland.vs; EVLOG for quest logging
- **Testing:** No unit tests; use VICE and playtest scripts for smoke tests
- **Manual is authoritative:** For features, dev notes, and walkthroughs, see MANUAL.md

## Integration & External Dependencies

- **KickAssembler** (Java JAR): Required for building
- **VICE** (x64sc.exe, c1541.exe): Required for running and disk image management
- **Pandoc/wkhtmltopdf/LaTeX:** For manual PDF generation (optional)

## Notable Patterns & Tips

- **Script-driven workflow:** Use tools/ scripts for all builds, runs, and playtests
- **Device 8:** All file I/O (save/load, EVLOG) targets device 8
- **NPCs/Quests:** NPCs have level, HP, trinkets; quests tracked in arrays (see quest* and npc* tables in everland.asm)
- **Coin system:** PlayerGold, PlayerSilver, PlayerCopper track balances; inventory/quest rewards update these
- **Playtest automation:** tools/vice_playtest.ps1 for scripted emulator flows and EVLOG extraction
- **PDF/manual build:** tools/build_manual.ps1 (supports xelatex, pdflatex, or wkhtmltopdf)

## Examples

- Build and run after editing everland.asm:
  - tools/build_prg_simple.bat "C:/commodore/KickAssembler/KickAss.jar"
  - tools/run_from_d64.bat "C:/commodore/GTK3VICE-3.10-win64/bin/x64sc.exe" "bin/everland.d64"
- Generate PDF manual:
  - powershell -ExecutionPolicy Bypass -File tools/build_manual.ps1
- Automated playtest:
  - powershell -ExecutionPolicy Bypass -File tools/vice_playtest.ps1

---
For more, see MANUAL.md and scripts in tools/.
