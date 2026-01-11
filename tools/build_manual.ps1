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

        # Optional cover: images/SpiderPrincess1Up.png
        $coverPng = Join-Path (Split-Path -Parent $PSCommandPath) "..\images\SpiderPrincess1Up.png"
        $coverHtml = "MANUAL.cover.html"
        $useCover = Test-Path $coverPng
        if ($useCover) {
                Write-Host "Found cover image: $coverPng" -ForegroundColor Cyan
                $coverDoc = @'
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <style>
        html,body{margin:0;padding:0;height:100%;}
        .full{position:fixed;inset:0;display:flex;align-items:center;justify-content:center;background:#000;}
        img{max-width:100%;max-height:100%;}
    </style>
    <title>Everland — Manual Cover</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="robots" content="noindex" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="color-scheme" content="light dark" />
    <meta name="supported-color-schemes" content="light dark" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="msapplication-tap-highlight" content="no" />
    <meta name="HandheldFriendly" content="true" />
    <meta http-equiv="cleartype" content="on" />
    <meta http-equiv="imagetoolbar" content="no" />
    <meta http-equiv="msthemecompatible" content="no" />
    <meta name="build" content="wkhtmltopdf cover" />
    <meta name="generator" content="Everland tools/build_manual.ps1" />
    <meta name="application-name" content="Everland Manual" />
    <meta name="description" content="Cover image for Everland Manual" />
    <meta name="theme-color" content="#000000" />
    <meta name="referrer" content="no-referrer" />
    <meta name="referrer" content="strict-origin-when-cross-origin" />
    <meta http-equiv="Content-Security-Policy" content="default-src 'self' data: 'unsafe-inline'; img-src 'self' data:;" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
    <base href="./" />
    <link rel="icon" href="data:," />
    <meta name="prefers-color-scheme" content="dark light" />
    <meta name="color-scheme" content="dark light" />
    <meta name="supported-color-schemes" content="dark light" />
</head>
<body>
    <div class="full">
        <img src="images/SpiderPrincess1Up.png" alt="Everland Manual Cover" />
    </div>
</body>
</html>
'@
                Set-Content -Path $coverHtml -Value $coverDoc -Encoding UTF8
        }

        # Allow wkhtmltopdf to access local image files when converting HTML -> PDF
        if ($useCover) {
                & $wkhtmltopdf --enable-local-file-access cover $coverHtml $OutHtml $OutPdf
        }
        else {
                & $wkhtmltopdf --enable-local-file-access $OutHtml $OutPdf
        }
        if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutPdf via wkhtmltopdf" -ForegroundColor Green; exit 0 }
        else { Write-Host "wkhtmltopdf failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
}

# Fallback: produce HTML and inform user
Write-Host "No PDF engine found (xelatex/pdflatex/wkhtmltopdf). Producing HTML fallback..." -ForegroundColor Yellow
& $pandoc $ManualMd -o $OutHtml --standalone --toc
if ($LASTEXITCODE -eq 0) { Write-Host "Created $OutHtml. Install a TeX engine or wkhtmltopdf to produce PDF." -ForegroundColor Yellow; exit 1 }
else { Write-Host "pandoc->HTML failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit $LASTEXITCODE }
