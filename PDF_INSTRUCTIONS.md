Converting MANUAL.md to a searchable PDF
========================================

Recommended: use `pandoc` (searchable PDF) or `wkhtmltopdf` if you prefer HTML rendering.

1) Install pandoc and a PDF engine (wkhtmltopdf or LaTeX/MikTeX):
   - Windows: install Pandoc from https://pandoc.org/installing.html
   - Install MikTeX or TinyTeX if you want high-quality PDF via LaTeX, or install `wkhtmltopdf` for HTML -> PDF conversion.

2) Place screenshots in `images/` directory next to `MANUAL.md` and ensure filenames match (screenshot1.png, screenshot2.png).

3) Convert with pandoc + wkhtmltopdf (recommended if LaTeX is not available):

```powershell
# Convert Markdown -> HTML
pandoc MANUAL.md -o MANUAL.html --standalone --toc
# Convert HTML -> searchable PDF with wkhtmltopdf (enable local file access for images)
wkhtmltopdf --enable-local-file-access MANUAL.html MANUAL.pdf
```

4) Or convert directly with pandoc + LaTeX (produces high-quality PDF):

```powershell
pandoc MANUAL.md -o MANUAL.pdf --pdf-engine=xelatex --toc
```

Notes:
- The resulting PDF is searchable because text comes from Markdown/HTML.
- If images are missing, they will be shown as broken links; add images to `images/` then re-run conversion.
- `tools/build_manual.ps1` provides a wrapper that detects available engines and will build PDF (or HTML fallback). Run with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build_manual.ps1
```
- If you want me to produce the PDF for you, upload the screenshots here and I will insert them and generate the Markdown; you'll still need to run the conversion locally or I can provide a downloadable PDF if you allow upload of images.

Troubleshooting:
- If `pandoc` cannot find images, ensure path is `images/screenshot1.png` relative to `MANUAL.md`.
- For Windows line endings issues, use `--wrap=preserve` if needed.
 - If `wkhtmltopdf` fails to load local images, include `--enable-local-file-access`.

Operational tips (C64 runtime)
-------------------------------
- Wildcard LOAD and lowercase: When launching from a D64, prefer lowercase commands and wildcard load if needed to avoid PETSCII filename mismatches:

```basic
load"*",8,1
run
```
