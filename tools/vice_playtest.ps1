# VICE playtest script for Everland
# Usage: .\vice_playtest.ps1 [-VicePath <path_to_x64sc.exe>] [-PrgPath <path_to_prg>] [-Headless]
# This script attempts to find x64sc, launches it with -autostart <prg>, brings the window to front
# and sends a small sequence of keys to exercise TALK BARTENDER → Quest. Adjust timings as needed.
param(
    [string]$VicePath = '',
    [string]$PrgPath = "$PWD\\bin\\everland.prg",
    [switch]$Headless
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
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
if ($proc.MainWindowHandle -ne 0) {
    [WinAPI]::ShowWindow($proc.MainWindowHandle, 3) | Out-Null # SW_MAXIMIZE(3)
    Start-Sleep -Milliseconds 200
    [WinAPI]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 400
}

# Prepare SendKeys
Add-Type -AssemblyName System.Windows.Forms

function Send-ToVice([string]$keys, [int]$delayMs=300) {
    [System.Windows.Forms.SendKeys]::SendWait($keys)
    Start-Sleep -Milliseconds $delayMs
}

# Playtest sequence (tweak as needed): TALK BARTENDER <enter>, then choose 3 (quest)
# Note: Commodore keys: Send normal text then {ENTER}
Send-ToVice("TALK BARTENDER{ENTER}", 1000)
Start-Sleep -Milliseconds 800
Send-ToVice("3{ENTER}", 800)
Start-Sleep -Milliseconds 800
# If a prompt appears for slot or choices, send defaults (this is just a simple smoke test)
# Optionally capture a screenshot (requires external tool). We'll pause so tester can see results.
Write-Host "Playtest sequence sent. Emulator running. Press Enter to terminate the emulator (script will not kill it)."
Read-Host | Out-Null

# Optional: leave emulator running for manual inspection
Write-Host "Playtest complete. Emulator left running." -ForegroundColor Green
