Everland — Manual
=================

Overview
--------
Everland is a single-file Commodore 64 text-adventure written in Kick Assembler. Build with KickAssembler and run in the VICE C64 emulator on Windows.

Screenshots
-----------
The following screenshots are included from the `images/` folder.

![Screenshot 1](images/screenshot1.png)
![Screenshot 2](images/screenshot2.png)

Fully Working Features
----------------------
- Save/Load (Disk I/O): Persistent profile save/load using a custom binary format.
- Login/Profile: Username/display and class selection at first login.
- Class & Level System: Player class, level, and score; class base HP and HP-per-level.
- HP Tracking & Persistence: Player and NPC current HP tracked and saved.
- Inventory Screen: Full-screen Inventory accessible with `I`.
- Characters Menu & Sheets: `C` opens character menu; view player or NPC sheet.
- Talk/NPC Selection: `T` opens talk screen; select NPCs and begin conversations.
- Conversation Menu: Options implemented (speak, ask weather, comment temp, request quest, quest info, end).
- NPC Data & Stats: Arrays for NPC name, class, level, score, current HP.
- PETSCII Helpers & Rendering: Message buffer rendering and PETSCII helpers.
- KERNAL Routines: File handling and console I/O routines used.
- IRQ / Music Hook: Music IRQ handler and safe IRQ stub scaffold present.

Partially Working / Needs Attention
----------------------------------
- Assembler Branch/Label Issues: Recent trampoline edits required fixes; re-verify with a full assemble.
- Conversation/Trampoline Robustness: Conversation menu logic works but needs final branch/label cleanup.
- SID Music Content: IRQ handler exists but SID tracks are not fully integrated.
- Quest Persistency Edge Cases: Basic quest assignment and save/load implemented; complex flows need expansion/testing.
- UI Polish: Dialog strings and message layout may need trimming.
- Multiplayer/Net: Not functional.

Beginner Player Manual
----------------------
Startup / Compile / Run

- Assemble with KickAssembler on Windows (example):

```powershell
java -cp C:\commodore\KickAssembler\KickAss.jar kickass.KickAssembler -odir bin -log c:\commodore\everland\bin\buildlog.txt -showmem -vicesymbols c:\commodore\everland\everland.asm
```

- Run in VICE: open `bin\everland.prg` or drag into x64.

First Run / Profiles

- On first run you'll be prompted for a username/display and to pick a player class. The chosen class affects HP and is saved.

Core Controls

- Movement: N, S, E, W (note: `S` is South only).
- `C`: Characters menu — view player or NPC sheets.
- `I`: Inventory (full screen).
- `T`: Talk — select NPC and start conversation.
 - `ATTACK` / `FIGHT`: Melee attack an NPC at your current location. Use `ATTACK <npc>` or `FIGHT <npc>` to target someone.
- Conversation: Type menu number and press Enter; choose "End" to exit.

Gameplay Loop

- Explore map, talk to NPCs (`T`), check `C`haracter sheet and `I`nventory, accept quests, gain score/levels. Progress and HP changes are auto-saved on key events.
 - Combat: Use `ATTACK <NPC>` to perform a simple melee attack. NPC and player HP are tracked and persisted to your profile; defeats remove NPCs from the location and update save state.
 - Combat: Use `ATTACK <NPC>` to perform a simple melee attack. NPC and player HP are tracked and persisted to your profile; defeats remove NPCs from the location and update save state. Defeating foes now grants small XP rewards (every 10 XP increases your level) and increments your score.

Saving & Loading

- Saves use KERNAL file routines; the game auto-loads profile on startup and auto-saves on key changes.

Troubleshooting

- If KickAssembler reports branch/label errors, re-run and paste the build log; I can patch `everland.asm` to fix trampolines.
- If VICE hangs, try restarting the emulator or ensure the IRQ safe stub is enabled in code.

Upcoming / Recommended Features
-------------------------------
- Full SID soundtrack and sound effects.
- Expanded quest system and quest log UI.
- Turn-based combat, skills, and status effects.
- Improved inventory with equip/unequip and item stacking.
- Enhanced PETSCII map, mini-map, and animations.
- Multiple save slots and in-game save manager.
- Joystick/controller support.
- Reorganize code to avoid long-branch patterns and improve assembler stability.

Build & Environment Notes
-------------------------
- Assembler: Kick Assembler (v5.25 in logs).
- Editor: Visual Studio Code.
- Emulator: VICE C64 Emulator on Windows.
- Source: `everland.asm` in the project root. Build output in `bin/`.

Credits
-------
- Producer: Damon Hogan
- Inspired by: Perry Fraptic (RetroRecipies YouTube)
- Hardware inspiration: Commodore 64 Ultimate, commodore.net
- Tooling: Kick Assembler, Visual Studio Code, VICE

Contact / Next Steps
--------------------
- To include screenshots: upload them into `images/` then re-run the PDF conversion instructions below.
- If you'd like, I can patch remaining assembler errors — paste the latest build log.

Appendix: Commands Used To Create The PDF
----------------------------------------
The PDF for this manual was produced using `pandoc` to convert Markdown to PDF. Below are the exact commands you can run locally to reproduce the same searchable PDF.

1) Convert Markdown directly to PDF via LaTeX (recommended if you have a TeX engine installed):

```powershell
pandoc MANUAL.md -o MANUAL.pdf --pdf-engine=xelatex --toc
```

2) Alternative: Generate HTML then convert to PDF with `wkhtmltopdf` (if you prefer HTML rendering):

```powershell
# Convert Markdown -> HTML
pandoc MANUAL.md -o MANUAL.html --standalone --toc
# Convert HTML -> searchable PDF with wkhtmltopdf
wkhtmltopdf MANUAL.html MANUAL.pdf
```

3) If you need only HTML output (searchable in browsers):

```powershell
pandoc MANUAL.md -o MANUAL.html --standalone --toc
```

Notes:
- `--toc` generates a table of contents.
- If images are large, consider resizing before embedding to reduce PDF size.

PDF Location
------------
If I successfully generate `MANUAL.pdf` in the repository root, it will be placed at `c:/commodore/everland/MANUAL.pdf` and offered for download here.
