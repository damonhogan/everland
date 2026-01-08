<#
Fix comment markers in everland.asm: convert semicolon comments to //
This script replaces ';' with '//' only outside of quoted strings to avoid altering string literals.
Backup created as everland.asm.fixbak
Usage: .\tools\fix_comments.ps1
#>

$File = Join-Path $PSScriptRoot '..\everland.asm'
$Bak = "$File.fixbak"
Write-Host "Reading $File"
Copy-Item -Path $File -Destination $Bak -Force

$sb = New-Object System.Text.StringBuilder
Get-Content -Path $File -Encoding UTF8 | ForEach-Object {
    $line = $_
    $inQ = $false
    $chars = $line.ToCharArray()
    $lineBuilder = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $chars.Length; $i++) {
        $c = $chars[$i]
        if ($c -eq '"') {
            $inQ = -not $inQ
            [void]$lineBuilder.Append($c)
            continue
        }
        if (-not $inQ -and $c -eq ';') {
            [void]$lineBuilder.Append('/')
            [void]$lineBuilder.Append('/')
        } else {
            [void]$lineBuilder.Append($c)
        }
    }
    [void]$sb.AppendLine($lineBuilder.ToString())
}

# Write back without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($File, $sb.ToString(), $utf8NoBom)
Write-Host "Wrote fixed file to $File (backup at $Bak)"