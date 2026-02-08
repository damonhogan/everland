<#
Generate bbs/MANUAL.html and bbs/MANUAL.pdf from bbs/MANUAL.md
#>

param()

$md = Join-Path $PSScriptRoot 'MANUAL.md'
$html = Join-Path $PSScriptRoot 'MANUAL.html'
$pdf = Join-Path $PSScriptRoot 'MANUAL.pdf'

# Find pandoc
$pandocCmd = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandocCmd) {
    Write-Error "pandoc not found in PATH. Install pandoc or adjust PATH."
    exit 1
}

Write-Output "Generating HTML: $html"
& $pandocCmd.Source $md -s -o $html

# Convert HTML -> PDF if wkhtmltopdf is available
$wk = Get-Command wkhtmltopdf -ErrorAction SilentlyContinue
if (-not $wk) {
    Write-Warning "wkhtmltopdf not found; HTML generated only."
    exit 0
}

Write-Output "Converting HTML to PDF: $pdf"
& $wk.Source $html $pdf
Write-Output "Created $pdf"
