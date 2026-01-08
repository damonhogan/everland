# VICE playtest script for Everland
# VICE playtest script for Everland
# Usage: .\vice_playtest.ps1 [-VicePath <path_to_x64sc.exe>] [-PrgPath <path_to_prg>] [-Headless]
# This script attempts to find x64sc, launches it with -autostart <prg>, brings the window to front
# and sends a small sequence of keys to exercise TALK BARTENDER → Quest. Adjust timings as needed.
param(
    [string]$VicePath = '',
    [string]$PrgPath = "$PWD\\bin\\everland.prg",
    [switch]$Headless,
    [switch]$NoPause,
    [string[]]$Sequence = @("TALK BARTENDER{ENTER}", "3{ENTER}")
)

# Helper: find x64sc in common locations
$common = @("C:\\Program Files (x86)\\VICE\\x64sc.exe", "C:\\Program Files\\VICE\\x64sc.exe", "C:\\Program Files\\x64sc\\x64sc.exe")
if (-not $VicePath -or $VicePath -eq '') {
    foreach ($p in $common) { if (Test-Path $p) { $VicePath = $p; break } }
}
if (-not (Test-Path $VicePath)) {
    Write-Host "x64sc not found. Please install VICE or pass -VicePath to the script." -ForegroundColor Yellow
    return
}
if (-not (Test-Path $PrgPath)) { Write-Host "PRG not found: $PrgPath" -ForegroundColor Red; return }

# Launch VICE with autostart and warp for fast boot
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $VicePath
$startInfo.Arguments = "-autostart `"$PrgPath`" -warp"
$startInfo.UseShellExecute = $true
$proc = [System.Diagnostics.Process]::Start($startInfo)

# Wait for main window to appear
Start-Sleep -Seconds 2
$timeout = 40
$sw = 0
while ($sw -lt $timeout) {
    $proc.Refresh()
    if ($proc.MainWindowHandle -ne 0) { break }
    Start-Sleep -Milliseconds 250
    $sw += 1
}
if ($proc.MainWindowHandle -eq 0) { Write-Host "Couldn't find VICE window; continuing but SendKeys may fail." -ForegroundColor Yellow }

# Bring window to foreground
$winapiPath = Join-Path $PSScriptRoot 'winapi.ps1'
if (Test-Path $winapiPath) {
    . $winapiPath
} else {
    Write-Host "WinAPI helper not found; window focusing may fail." -ForegroundColor Yellow
}
if ($proc.MainWindowHandle -ne 0) {
    Show-Window ([IntPtr]$proc.MainWindowHandle) 3
    Start-Sleep -Milliseconds 200
    Set-ForegroundWindow ([IntPtr]$proc.MainWindowHandle)
        Start-Sleep -Milliseconds 400
        # Give the emulator a little extra time to finish autostart and show the READY prompt
        Start-Sleep -Seconds 4
}

# Prepare SendKeys (send characters one-by-one to avoid timing/brace issues)
Add-Type -AssemblyName System.Windows.Forms

function Send-ToVice([string]$keys, [int]$charDelayMs=75) {
    $i = 0
    while ($i -lt $keys.Length) {
        if ($keys.Substring($i) -like '{ENTER}*') {
            [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
            $i += 7
        } else {
            $ch = $keys[$i]
            [System.Windows.Forms.SendKeys]::SendWait($ch)
            Start-Sleep -Milliseconds $charDelayMs
            $i += 1
        }
    }
    Start-Sleep -Milliseconds ($charDelayMs * 4)
}

# Playtest sequence (tweak as needed): send each entry from -Sequence
# Note: Commodore keys: Send normal text then {ENTER}
foreach ($s in $Sequence) {
    Send-ToVice($s, 1000)
    Start-Sleep -Milliseconds 600
}

if (-not $NoPause) {
    Write-Host "Playtest sequence sent. Emulator running. Press Enter to terminate the emulator (script will not kill it)."
    Read-Host | Out-Null
    Write-Host "Playtest complete. Emulator left running." -ForegroundColor Green
} else {
    Write-Host "Playtest sequence sent (no-pause mode)." -ForegroundColor Cyan
}
# If a prompt appears for slot or choices, send defaults (this is just a simple smoke test)
# Optionally capture a screenshot (requires external tool). We'll pause so tester can see results.
Write-Host "Playtest sequence sent. Emulator running. Press Enter to terminate the emulator (script will not kill it)."
Read-Host | Out-Null

# Optional: leave emulator running for manual inspection
Write-Host "Playtest complete. Emulator left running." -ForegroundColor Green
