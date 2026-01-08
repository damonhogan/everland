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
    # Allow wkhtmltopdf to access local image files when converting HTML -> PDF
    & $wkhtmltopdf --enable-local-file-access $OutHtml $OutPdf
    if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutPdf via wkhtmltopdf" -ForegroundColor Green; exit 0 }
    else { Write-Host "wkhtmltopdf failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
}

# Fallback: produce HTML and inform user
Write-Host "No PDF engine found (xelatex/pdflatex/wkhtmltopdf). Producing HTML fallback..." -ForegroundColor Yellow
& $pandoc $ManualMd -o $OutHtml --standalone --toc
if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutHtml. Install a TeX engine or wkhtmltopdf to produce PDF." -ForegroundColor Yellow; exit 1 }
else { Write-Host "pandoc->HTML failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
