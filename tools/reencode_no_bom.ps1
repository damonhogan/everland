$p = Join-Path $PSScriptRoot '..\everland.asm'
$s = Get-Content -Raw -Path $p
$enc = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($p,$s,$enc)
Write-Host "RE-WRITTEN $p"
