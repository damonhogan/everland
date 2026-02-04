# Porting Everland to Minimal Custom BBS

## Key Steps
- Replace all direct keyboard/screen I/O with modem I/O routines (device 2)
- Use modem_io.inc for all input/output
- Remove SID/music routines (not needed for BBS)
- Ensure all file I/O (save/load, high scores, messages) uses device 8
- Test all prompts and menus for remote usability (no direct screen control)

## Tips
- Use PETSCII for all text
- Keep memory usage low for BBS compatibility
- On exit, close device 2 and return to BASIC shell
