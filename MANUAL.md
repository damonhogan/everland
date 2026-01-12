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
- Save/Load (EV3): Per-username profile saved to device 8. EV3 stores username, display, class, race, pin, score, level, current HP, class/race indices, max HP (for reference), calendar, location, object locations, and quest state. Backward-compatible loader accepts EV1/EV2.
- Login/Profile: Username, display name, class, and race are selected at first login.
- Class & Level System: Class base HP and HP-per-level; new profiles start at Level 1.
- HP System: Character sheet shows current and max HP; max HP is based on class, level, and session bonuses. Current HP is saved; max HP is recomputed and also persisted in EV3.
- Idle Regeneration: While idle at prompts (i.e., not in a fight), HP regenerates at 1 HP per real-time minute (uses KERNAL jiffy clock; handles midnight wrap).
- Inventory: Full-screen Inventory with `I`.
- Characters & Sheets: `C` opens character menu; view player or NPC sheets with stats and HP.
- Talk/NPC Selection: `T` opens talk screen; select any present NPC.
- Direct TALK: `TALK <NPCNAME>` jumps straight to that NPC if present.
- Conversation Menu: Options like speak/ask/comment/quests/end; many branches apply effects (heals, score, quests).
- Movement: Cardinal plus diagonal movement (`NE/NW/SE/SW` and full words) with diagonals shown in the exits line when reachable.
- Rendering & I/O: PETSCII message-buffer rendering; KERNAL file and console I/O; music IRQ scaffolding.

Recent Additions (confirmed working)
- Direct TALK: `TALK <NPCNAME>` parsing and dispatch.
- Diagonal movement: `NE/NW/SE/SW` (and full words) plus exits display updates.
- New NPC content:
	- Saint Apollonia (Inn): Multi-step stories; offering quest that heals to max and grants +score; leaving without offering may penalize score.
	- Dragon Trainer Alyster (Dragon Haven): Basics, care, practice; Advanced training grants a session-only +2 Max HP bonus, heals to the new max, and +2 score.
	- Pirate Swordplay (Clockwork Alley): Stance/footwork guidance; practice parry/lunge grants +1 HP (capped) and +1 score.
	- Knight Arena Training (Gate): Guard stance/footwork; practice parry/lunge grants +1 HP (capped) and +1 score.
	- Mermaid (Clockwork Alley): Trade a land-based item (pinecone) for a sea-based item (sparkly shell); starts a themed trade quest and grants the shell upon completion.
- Character Sheet: Displays “HP: current / max” and shows “+N MAX HP (SESSION)” when a temporary bonus is active.
- Save Format EV3: Saves current HP and the computed max HP; compatible with older EV1/EV2 saves.
- Idle HP regen: 1 HP per minute at prompts; persists when HP changes.
- Manual build helpers: PDF via pandoc/TeX or pandoc+wkhtmltopdf; Dockerfile available.

What's New In This Release
---------------------------
- TALK improvements: Case-insensitive parsing and direct `TALK <NPCNAME>`.
- Character sheet HP line: Labeled “HP: current / max”; session HP bonus note.
- HP regeneration: 1 HP/min while idle, auto-saves on change.
- EV3 saves: Persist current HP and max HP; EV1/EV2 remain readable.
- New/updated NPC content: Saint Apollonia, Alyster, Pirate Captain/First Mate, Knight (training).
 - New/updated NPC content: Saint Apollonia, Alyster, Pirate Captain/First Mate, Knight (training), Mermaid (trade quest).
- Diagonal movement and exits display.

This Update — New Features
--------------------------
- NPC cap increased to 32: the NPC tables and presence masks were expanded so more characters can be present at once.
- New NPCs and quests:
	- Knight Kendrick (Plaza): a jovial, Scottish knight who keeps a bottle of scotch. Kendrick offers a fetch quest — bring him a bottle of scotch (from the Tiptsey Maiden tavern) to complete the quest and receive a small reward.
	- Warlock (Plaza): gives the player a protective ward and requests it be placed at the Portal fracture (the location formerly called the Gate; the game now uses "Portal").
	- Candy Witch (Alley): an opposing quest to the Warlock — she can disable a ward; returning a disabled ward to the Warlock is a separate flow and ties into a shared backstory.
	- Kora (Plaza): offers a playful jape quest — she asks the player to SAY a phrase to Knight Kendrick. Use the new `SAY` command to deliver the phrase and complete the quest.
	- Alyster oath (Order of the Emerald Sky): Alyster now offers an oath quest with an explicit Y/N acceptance flow; accepting sets a guild-membership flag in your profile.

- New command: `SAY <phrase> TO <NPC>` — a text-say parser was added to validate phrases for specific NPC quests (example: the Kora jape requires the phrase "SCOTCH ON THE KNIGHT" said to Kendrick).
- Portal rename: all references to the old "Gate" location were renamed to "Portal" in the game and manual.
- EVLOG quest logging: quest completions are recorded to an `EVLOG` file (device 8 / PRG directory when virtual device traps are enabled). Use the helper scripts in `tools/` to extract/view `EVLOG` from the D64 or PRG directory.
- Input improvements: username and other prompts now accept multi-character input until Enter and echo typed characters (previous single-char prompt behavior fixed).
- UI fixes: the Characters/Talk lists no longer show a stray "(UNKNOWN)" entry and the Conductor menu option text was restored.

- NPC Hitpoints & Levels: NPCs now have level and current/max HP like players. NPC level is used with the same class base/level HP formula to compute an NPC's max HP; current HP is stored in saves (EV3). NPCs heal passively at the same rate as players (1 HP per real minute while idle) and their current HP is auto-saved when it changes. The Characters/Talk lists now display each NPC as "LV <n> HP <cur>/<max>" where applicable.


 Latest Operational Updates
---------------------------
- Build helper: `tools/build_prg_simple.bat` compiles `everland.asm` with your KickAssembler JAR, then refreshes a D64 via `tools/make_d64.bat`.
- Disk runner: `tools/run_from_d64.bat` mounts `bin/everland.d64` on drive 8 and performs a simple `load"*",8,1` then `run`.
- TALK flow: Case-insensitive; `TALK <NPCNAME>` opens that NPC if present. Menu indices start at 0 on the list.
- HELP: Type `HELP` (or `?`) anytime to show controls.
- Conductor quest: Train Station option “3. Any quests?” starts the coin quest and grants a coin.
- Apollonia: “Leave an offering” — heals to max and grants +score; leaving without offering may reduce score.
- Alyster: “Advanced training” (after basics) — session-only +2 Max HP, full heal, +2 score.
- Diagonals: `NE/NW/SE/SW` movement and exits display.
- Pirate/Knight practice: Each practice grants +1 HP (capped) and +1 score.

Coin / Bartender Quest (player walkthrough)
-------------------------------------------
This release includes a small fetch quest where the Conductor asks you to bring a coin to the Bartender.

1) Accept the quest from the Conductor
	- `TALK CONDUCTOR` then select the "Any quests?" menu option (`3`) at the Train Station to accept `QUEST_COIN_BARTENDER`. When accepted, you will also receive a starter coin and see "YOU RECEIVE A COIN.".

2) Get a coin
	- The `COIN` object spawns in the Market by default. Travel to the Market and run:

```
TAKE COIN
```

	- Verify with `I` (Inventory) that `COIN` is now in your inventory.

3) Give the coin to the Bartender
	- Go to the Tavern and either:
	  - `GIVE COIN TO BARTENDER` (explicit target), or
	  - `GIVE COIN` while standing in the Tavern (auto-targets default NPC at location), or
	  - `TALK BARTENDER` and choose `BUY ALE (1 COIN)` or `GIVE TIP` — both consume a coin.

	- If `QUEST_COIN_BARTENDER` is active, giving the coin to the Bartender triggers `questComplete` and marks the quest done.

4) Verify
	- `I` should show the coin removed from inventory and the last message will indicate quest completion or reward.

Developer pointers (where to look in the source)
- `objLoc` (initial item locations) contains the coin spawn location.
- `cmdTake` and `cmdGive` implement TAKE/GIVE parsing and behavior.
- `questCheckGive` looks up (object,npc) pairs for active quests and calls `questComplete` when matched.
 - NPC HP/level and regen:
	 - `npcLevel`, `npcCurHp`, and `npcClassIdx` tables define NPC level, current HP and class.
	 - `computeNpcMaxHp` computes NPC max HP from class & level (same formula as players).
	 - `applyRegenIfDue` now heals NPCs the same way as players; look for the NPC-healing loop.


Partially Working / Needs Attention
----------------------------------
- Assembler Branch/Label Issues: Trampolines added where needed; recommend a full assemble and focused review for remaining long-branch patterns.
- Conversation tree expansion: Per-npc/quest tables are in place but branching trees and larger dialogue flows need more content and testing.
- SID Music: IRQ handler and new Celtic patterns added; full soundtrack integration and voice balancing still in progress.
- Quest edge-cases: Multi-stage quests persist, but complex state transitions need playtesting.
- UI polish: PETSCII art, pacing and transitions need refinement for better immersion.
- Automated emulator tests: Playtest scripts exist but comprehensive deterministic harness (screenshots, long flows) is TODO.

Beginner Player Manual
----------------------
Startup / Compile / Run

- Assemble with KickAssembler on Windows (example):

```powershell
java -cp C:\commodore\KickAssembler\KickAss.jar kickass.KickAssembler -odir bin -log c:\commodore\everland\bin\buildlog.txt -showmem -vicesymbols c:\commodore\everland\everland.asm
```

- Run in VICE: open `bin\everland.prg` or drag into x64.

Quickstart (Windows)
--------------------
- Build + refresh disk image:

```powershell
C:\commodore\everland\tools\build_prg_simple.bat "C:\commodore\KickAssembler\KickAss.jar"
```

- Run from D64 with auto LOAD/RUN (lowercase, wildcard):

```powershell
C:\commodore\everland\tools\run_from_d64.bat "C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe" "C:\commodore\everland\bin\everland.d64"
```

First Run / Profiles

- On first run you'll be prompted for a username/display and to pick a player class. The chosen class affects HP and is saved.

Core Controls

- Movement: N, S, E, W and NE, NW, SE, SW. Full words `NORTHEAST`, `NORTHWEST`, `SOUTHEAST`, `SOUTHWEST` also work. Diagonal exits appear in the exits line when reachable.
- `C`: Characters menu — view player or NPC sheets.
- `I`: Inventory (full screen).
- `T`: Talk — select NPC and start conversation.
 - Direct talk: `TALK <NPCNAME>` (e.g., `TALK CONDUCTOR`).
 - Help: `HELP` or `?`.
 - `ATTACK` / `FIGHT`: Melee attack an NPC at your current location. Use `ATTACK <npc>` or `FIGHT <npc>` to target someone.
- Conversation: Type menu number and press Enter; choose "End" to exit.

Gameplay Loop

- Explore, talk to NPCs (`T`/`TALK <NPC>`), check `C`haracter sheet and `I`nventory, accept quests, gain score/levels. Progress and HP updates are auto-saved on key events. HP passively regenerates while idle.

HP & Regeneration
-----------------
- Max HP: Determined by your class and level, plus any session-only bonus.
	- Formula: MaxHP = BaseHP(class) + PerLevel(class) × Level + SessionBonus.
	- New profiles start at Level 1, so initial MaxHP includes one per-level step.
- Session bonus: Some training (e.g., Alyster’s Advanced Training) grants a temporary +Max HP for the current session only. The character sheet shows “+N MAX HP (SESSION)” beneath your HP line when active.
- Viewing HP: Press `C` to open the character sheet and see “HP: current / max”.
- Regeneration: While idle at prompts (not actively performing actions), you recover 1 HP per real-time minute. Regeneration is capped at Max HP and is saved automatically when HP changes.
  
	- NPCs: Non-player characters now use the same regeneration rules. NPCs have `LV` and `HP` values; they recover 1 HP per real minute (capped at their computed max) and their current HP is persisted in EV3 saves.

Saving & Loading

- Per-username save file (device 8). On startup the game loads your profile; it auto-saves on key changes (e.g., HP regen, quests, training).
- Save format: EV3. The loader remains compatible with EV1/EV2 saves created by earlier builds; EV3 adds race indices and max HP reference.

Troubleshooting

- If KickAssembler reports branch/label errors, re-run and paste the build log; I can patch `everland.asm` to fix trampolines.
- If VICE hangs, try restarting the emulator or ensure the IRQ safe stub is enabled in code.
- If LOAD reports `?FILE NOT FOUND` in BASIC, use wildcard and lowercase:

```basic
load"*",8,1
run
```

 

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

Appendix B: Running the Automated VICE Playtest Script
-----------------------------------------------------

This appendix describes how to run the provided playtest helpers (`tools/vice_playtest.ps1` and `tools/vice_playtest.bat`) to automatically launch VICE and run a short smoke-test sequence against `bin/everland.prg`.

1) Quick launcher (recommended)

- Use the batch file if you just want to start the emulator with the PRG. From a Command Prompt or PowerShell in the project root run:

```powershell
tools\vice_playtest.bat "C:\Program Files (x86)\VICE\x64sc.exe" "c:\commodore\everland\bin\everland.prg"
```

If VICE is installed in the default path the arguments are optional:

```powershell
tools\vice_playtest.bat
```

2) Full scripted playtest (PowerShell)

- The PowerShell script `tools/vice_playtest.ps1` launches x64sc, waits for the emulator window, brings it to the foreground and sends a small keystroke sequence to exercise a conversation flow (example: `TALK BARTENDER` → choose menu option `3`). To run it once without changing policy:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\vice_playtest.ps1 -VicePath "C:\Program Files (x86)\VICE\x64sc.exe" -PrgPath ".\bin\everland.prg"
```

- If the script is blocked by Windows Defender / SmartScreen or another AV, unblock it and re-run:

```powershell
Unblock-File .\tools\vice_playtest.ps1
powershell -ExecutionPolicy Bypass -File .\tools\vice_playtest.ps1
```

Security and AV notes

- The PowerShell script sends keystrokes to the emulator window — some endpoint protection tools flag or block this behavior. If your AV blocks the script, prefer the batch launcher or add an exclusion for `tools\vice_playtest.ps1` in your AV settings.
- `-ExecutionPolicy Bypass` runs the script just for the process and does not permanently change system policy.

Script behavior and customization

- What the script does by default:
	- Launches x64sc with `-autostart <prg>` and `-warp` (fast boot).
	- Waits for the main emulator window and brings it to front.
	- Sends the keystrokes: `TALK BARTENDER{ENTER}` then `3{ENTER}` (selects the conversation menu's quest option).
	- Pauses and lets you inspect the emulator before exiting.
- You can modify the script to send other sequences (e.g., `TAKE COIN{ENTER}`, `GIVE COIN TO BARTENDER{ENTER}`) or longer test flows. Timings are configurable (delays in milliseconds between SendKeys).

Automating screenshot capture (optional)

- The script does not capture screenshots by default. To capture screens you can:
	- Use a command-line screenshot tool (e.g., `nircmd.exe` or `magick` from ImageMagick) and call it after the SendKeys sequence.
	- Or use VICE's built-in screenshot feature (keyboard binding) and send that key sequence from the script (timing-sensitive).

Troubleshooting

- If VICE fails to start: verify the `-VicePath` you provided points at `x64sc.exe` (or `x64.exe`/`x64sc.exe` depending on your build).
- If the PRG doesn't autostart: ensure `bin\everland.prg` exists and is the output from the latest assembly.
- If SendKeys appear to be ignored: ensure the emulator window has keyboard focus and increase the script's delay values.

Extending the playtest harness

- I can add additional scripted flows (save/load, give item flows, combat sequence) and optional screenshot collection. Tell me which flows you'd like automated and I will add them to `tools/vice_playtest.ps1` as named scenarios.

Appendix C: Build environment & scripts (PDF automation)
------------------------------------------------------

This appendix documents the environment and scripts used to build the manual, and includes a text copy of the build wrapper for reproducibility.

1) Dependencies (for PDF creation)

- `pandoc` — the primary tool to convert Markdown to HTML/PDF. Install from https://pandoc.org/
- A TeX engine (one of):
  - `xelatex` (recommended) — part of TeX Live or MiKTeX; provides good Unicode and font handling.
  - `pdflatex` — alternative TeX engine (also part of TeX Live / MiKTeX).
- `wkhtmltopdf` (optional) — alternative path: convert Markdown -> HTML via `pandoc`, then HTML -> PDF via `wkhtmltopdf`.
 - `wkhtmltopdf` (optional) — alternative path: convert Markdown -> HTML via `pandoc`, then HTML -> PDF via `wkhtmltopdf`.
 
wkhtmltopdf installation (Windows)
---------------------------------
If you prefer converting via HTML -> PDF, install `wkhtmltopdf`. On Windows you can install it in several ways:

- Using Chocolatey (recommended if you have Chocolatey installed):

```powershell
choco install wkhtmltopdf -y
```

- Using Scoop (if you use Scoop):

```powershell
iwr -useb get.scoop.sh | iex
scoop install wkhtmltopdf
```

- Manual download (no package manager):

1. Download the Windows 64-bit `wkhtmltopdf` binary ZIP from the official releases page: https://github.com/wkhtmltopdf/wkhtmltopdf/releases
2. Extract `wkhtmltopdf.exe` from the ZIP and place it in a folder such as `C:\Program Files\wkhtmltopdf`.
3. Add that folder to your user PATH (or system PATH) and restart your shell.

Note about PowerShell execution policy
-------------------------------------
If `tools\build_manual.ps1` is blocked on your system, run it with `-ExecutionPolicy Bypass` so the wrapper can run without changing system policy permanently:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build_manual.ps1
```

After installing `wkhtmltopdf` and ensuring it's on your PATH, re-run the wrapper above — it will detect `wkhtmltopdf` and use it to convert the generated `MANUAL.html` to `MANUAL.pdf`.
- Docker (optional) — we provide a Dockerfile below to build the manual inside a container without installing TeX locally. See the `tools/Dockerfile` file.
- Optional screenshot / helper tools (only for extended playtests): `nircmd.exe`, `ImageMagick (magick)`, or any command-line screenshot tool.

What we did locally (full summary)
----------------------------------
This project attempted multiple routes to produce `MANUAL.pdf` on a Windows dev machine; the following documents exactly what we ran and what succeeded.

- Step: Run `tools/build_manual.ps1` initially. Result: `pandoc` found, no TeX engines detected, no `wkhtmltopdf` present — script produced `MANUAL.html` fallback.

- Step: Attempted to install `wkhtmltopdf` via Chocolatey (non-elevated). Result: `choco` was not found.

- Step: Attempted Chocolatey bootstrap as an elevated process (UAC). The installer was launched but the elevated session did not leave a usable `choco` binary in the non-elevated shell (install requires admin and interactive UAC acceptance). Because automated elevation in this environment is unreliable, we fell back to a user-level installer.

- Step: Installed `wkhtmltopdf` via Scoop (user-level). Commands used:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb get.scoop.sh | iex
scoop update
scoop bucket add extras
scoop install wkhtmltopdf
```

- Step: Re-ran `tools/build_manual.ps1`. `pandoc` and `wkhtmltopdf` were detected, but `wkhtmltopdf` initially failed with network/ProtocolUnknownError when converting because local images were not accessible by default.

- Fix: Regenerated HTML with `pandoc` then converted with `wkhtmltopdf --enable-local-file-access` to allow embedded `images/` files to load. Command used:

```powershell
pandoc MANUAL.md -o MANUAL.html --standalone --toc
wkhtmltopdf --enable-local-file-access MANUAL.html MANUAL.pdf
```

- Result: `MANUAL.pdf` was successfully created and placed in the repository root.

Files modified during this process:
- `tools/build_manual.ps1` — updated to pass `--enable-local-file-access` to `wkhtmltopdf` to avoid the ProtocolUnknown/blocked local file access error.
- `MANUAL.md` — Appendix C updated with these notes and step-by-step install instructions for `wkhtmltopdf`.
- `MANUAL.pdf` — generated and added to the repo.

Notes and recommendations
- When converting Markdown -> HTML -> PDF with `wkhtmltopdf`, use `--enable-local-file-access` so local images referenced with relative paths load correctly.
- If you prefer a system-wide package manager, Chocolatey works but requires admin privileges and UAC acceptance; Scoop provides a user-friendly, non-admin alternative on Windows.
- Docker provides a fully reproducible environment if you cannot or do not wish to install TeX or `wkhtmltopdf` locally.

2) Build wrapper (text copy)

The repository includes `tools/build_manual.ps1`, a PowerShell wrapper that detects available engines and builds `MANUAL.pdf` if possible (falling back to `MANUAL.html` otherwise). The full script is below:

---- begin `build_manual.ps1` ----

<inserted-script>

---- end `build_manual.ps1` ----

Replace `<inserted-script>` with the following exact contents (copy-paste into a file):

```powershell
<#
Build wrapper for MANUAL.md -> MANUAL.pdf
Detects available PDF engines (xelatex, pdflatex, wkhtmltopdf) and runs pandoc accordingly.
Usage: powershell -ExecutionPolicy Bypass -File .\tools\build_manual.ps1
#>
param(
	[string]$ManualMd = "MANUAL.md",
	[string]$OutPdf = "MANUAL.pdf",
	[string]$OutHtml = "MANUAL.html"
)

function Which($name) { 
	$c = Get-Command $name -ErrorAction SilentlyContinue
	if ($c) { return $c.Source } 
	return $null
}

$pandoc = Which "pandoc"
if (-not $pandoc) {
	Write-Host "pandoc not found in PATH. Please install pandoc." -ForegroundColor Red
	exit 2
}

$xelatex = Which "xelatex"
$pdflatex = Which "pdflatex"
$wkhtmltopdf = Which "wkhtmltopdf"

Write-Host "Found: pandoc=$pandoc" -ForegroundColor Cyan
if ($xelatex) { Write-Host "Found xelatex: $xelatex" -ForegroundColor Cyan }
if ($pdflatex) { Write-Host "Found pdflatex: $pdflatex" -ForegroundColor Cyan }
if ($wkhtmltopdf) { Write-Host "Found wkhtmltopdf: $wkhtmltopdf" -ForegroundColor Cyan }

if ($xelatex) {
	Write-Host "Building PDF via xelatex..." -ForegroundColor Green
	& $pandoc $ManualMd -o $OutPdf --pdf-engine=xelatex --toc
	if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutPdf" -ForegroundColor Green; exit 0 }
	else { Write-Host "pandoc/xelatex failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
}

if ($pdflatex) {
	Write-Host "Building PDF via pdflatex..." -ForegroundColor Green
	& $pandoc $ManualMd -o $OutPdf --pdf-engine=pdflatex --toc
	if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutPdf" -ForegroundColor Green; exit 0 }
	else { Write-Host "pandoc/pdflatex failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
}

if ($wkhtmltopdf) {
	Write-Host "Building HTML then converting via wkhtmltopdf..." -ForegroundColor Green
	& $pandoc $ManualMd -o $OutHtml --standalone --toc
	if ($LASTEXITCODE -ne 0) { Write-Host "pandoc->HTML failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
	& $wkhtmltopdf $OutHtml $OutPdf
	if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutPdf via wkhtmltopdf" -ForegroundColor Green; exit 0 }
	else { Write-Host "wkhtmltopdf failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
}

# Fallback: produce HTML and inform user
Write-Host "No PDF engine found (xelatex/pdflatex/wkhtmltopdf). Producing HTML fallback..." -ForegroundColor Yellow
& $pandoc $ManualMd -o $OutHtml --standalone --toc
if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutHtml. Install a TeX engine or wkhtmltopdf to produce PDF." -ForegroundColor Yellow; exit 1 }
else { Write-Host "pandoc->HTML failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
```

3) Docker build (one-step reproducible PDF)

Use the provided `tools/Dockerfile` to build the manual inside a container that already includes pandoc + TeX. Example:

```powershell
docker build -t everland-manual -f tools/Dockerfile .
docker create --name tmp everland-manual
docker cp tmp:/work/MANUAL.pdf .
docker rm tmp
```

The Dockerfile uses the `pandoc/latex` base image and runs `pandoc MANUAL.md -o MANUAL.pdf --pdf-engine=xelatex --toc` during build; the generated PDF will be present at `/work/MANUAL.pdf` inside the image.

4) Rebuilding the manual using the wrapper

To rebuild locally (non-Docker):

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build_manual.ps1
```

If the script reports missing `xelatex`/`pdflatex`/`wkhtmltopdf`, either install one of those or use the Docker method above.

Appendix D: Artwork
-------------------

This appendix catalogs curated artwork used in Everland. These are included in the repository under `images/` and can be embedded in the manual or used as cover art.

- Spider Princess (cover candidate)

![Spider Princess](images/SpiderPrincess1Up.png)

- Mermaid at Medieval Theme Park (NPC quest ambiance)

![Mermaid Sitting in Wicker Chair](images/mermaid_sitting_in_a_wicker_chair_at_a_medieval_theme_park_she_will_tend_to_quests_with_patrons_blo_arttzoc89ruq0s6vmraj_2.png)

- Bridge the Troll & Kevin (Market NPC ambience)

![Bridge and Kevin](images/BridgeAndKevin1.png)

- Damian (portrait / cover variant)

![Damian 1Up](images/Damian1Up.png)

- Lezule the Fairy (Fairy Gardens ambiance)

![Lezule Fairy](images/fairy_named_lezule_lezule_colored_in_the_fairy_gardens_sweet_and_tender_shy_mouth_open_waiting_to_m_mthcye2lh1va3w5b8vtv_2.png)

- Mage Damon (portrait / mage variant)

![Mage Damon 3Up](images/MageDamon3Up.png)



Mermaid Trade Quest (player walkthrough)
----------------------------------------
This release adds a themed trade quest offered by the Mermaid in Clockwork Alley. Exchange a land-based item (pinecone) for a sea-based item (sparkly shell).

1) Accept the quest from the Mermaid
	- `TALK MERMAID` at Clockwork Alley and choose the conversation option to ask about a trade. This starts `QUEST_MERMAID_TRADE` (shown in the quest list as “TRADE LAND FOR SEA”).

2) Get a pinecone (land coral)
	- Travel to the Grove and run:

```
TAKE PINECONE
```

	- Verify with `I` (Inventory) that `PINECONE` is now in your inventory. You can also run `INSPECT PINECONE` for flavor text.

3) Offer the pinecone to the Mermaid
	- Return to Clockwork Alley and either:
	  - `GIVE PINECONE TO MERMAID`, or
	  - `TALK MERMAID` and choose the conversation option to offer land coral.

	- If `QUEST_MERMAID_TRADE` is active and you have the pinecone, the Mermaid will take the pinecone, give you a sparkly shell, and complete the quest.

4) Verify
	- `I` should show the pinecone removed and `SHELL` added. You can `INSPECT SHELL` to view its description.

Developer pointers (where to look in the source)
- See [everland.asm](everland.asm) for:
	- Objects: `OBJ_PINECONE` and `OBJ_SHELL` enumerations; `objLoc` sets initial pinecone spawn in the Grove and the shell is granted by the Mermaid.
	- Quest: `QUEST_MERMAID_TRADE` enumeration and completion flow; current reward handler uses the default completion path.
	- Conversation: `mermaidConversation` and its dispatch via `@conv_mermaid` in `convSpeakHandler`.
	- Parser: `kwMermaid`, `kwPinecone`, `kwShell` keywords mapped in `parseNpcNoun` and `parseObjectNoun`.
	- Location/NPC mask: `npcMaskByLocHi` updates include the Mermaid’s presence at Clockwork Alley.

