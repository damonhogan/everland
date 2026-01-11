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
    [switch]$PrepCleanup,
    [switch]$Minimal,
    [string]$ScreenshotPath = "$PWD\\playtest.png",
    # Send lowercase to avoid PETSCII/graphics issues in some keymap modes
    [string[]]$Sequence = @("north{ENTER}", "talk conductor{ENTER}", "3{ENTER}", "{ENTER}", "i{ENTER}")
)

# Helper: find x64sc in common locations
$common = @("C:\\Program Files (x86)\\VICE\\x64sc.exe", "C:\\Program Files\\VICE\\x64sc.exe", "C:\\Program Files\\x64sc\\x64sc.exe")
if (-not $VicePath -or $VicePath -eq '') {
    foreach ($p in $common) { if (Test-Path $p) { $VicePath = $p; break } }
}
if ([string]::IsNullOrEmpty($VicePath) -or -not (Test-Path $VicePath)) {
    Write-Host "x64sc not found. Please install VICE or pass -VicePath to the script." -ForegroundColor Yellow
    return
}
if (-not (Test-Path $PrgPath)) { Write-Host "PRG not found: $PrgPath" -ForegroundColor Red; return }

# Ensure we run from the PRG directory so FS device 8 maps there
$prgDir = Split-Path -Path $PrgPath -Parent
Push-Location $prgDir
try {
    # Drop EVAUTO marker to trigger dev auto-login in-game
    try { Set-Content -Path "EVAUTO" -Value "1" -NoNewline -ErrorAction SilentlyContinue } catch {}

    # Launch VICE with autostart and warp for fast boot
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $VicePath
$startInfo.Arguments = "-autostart `"$PrgPath`" -warp"
    $startInfo.WorkingDirectory = $prgDir
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
    # Give the emulator extra time to finish autostart and reach game init
    Start-Sleep -Seconds 20
        # Toggle warp mode off (Alt+W) to stabilize input timing
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.SendKeys]::SendWait('%w')
        Start-Sleep -Milliseconds 500
        # Prepare login defaults (lowercase to avoid PETSCII glyphs)
        $loginDefaults = @("{ENTER}{ENTER}{ENTER}", "autotest{ENTER}", "auto{ENTER}", "knight{ENTER}", "0000{ENTER}", "1{ENTER}", "1{ENTER}")
}

# Prepare SendKeys (send characters one-by-one to avoid timing/brace issues)
Add-Type -AssemblyName System.Windows.Forms

function Send-ToVice([string]$keys, [int]$charDelayMs=75) {
    $i = 0
    while ($i -lt $keys.Length) {
        if ($keys[$i] -eq '{') {
            $end = $keys.IndexOf('}', $i)
            if ($end -gt $i) {
                $token = $keys.Substring($i+1, $end-$i-1).ToUpper()
                switch ($token) {
                    'ENTER'     { [System.Windows.Forms.SendKeys]::SendWait('{ENTER}'); break }
                    'BACKSPACE' { [System.Windows.Forms.SendKeys]::SendWait('{BACKSPACE}'); break }
                    'TAB'       { [System.Windows.Forms.SendKeys]::SendWait('{TAB}'); break }
                    default     { [System.Windows.Forms.SendKeys]::SendWait("{$token}"); break }
                }
                Start-Sleep -Milliseconds ($charDelayMs)
                $i = $end + 1
                continue
            }
        }
        $ch = $keys[$i]
        [System.Windows.Forms.SendKeys]::SendWait($ch)
        Start-Sleep -Milliseconds $charDelayMs
        $i += 1
    }
    Start-Sleep -Milliseconds ($charDelayMs * 4)
}

# After defining Send-ToVice, optionally send login defaults
# Default to NOT sending to avoid prompt interference; caller can add them to -Sequence if needed

# Minimal mode: no pre-typing ENTER/BACKSPACE cleanup, just longer settle
if (-not $Minimal) {
    # Give extra settle time before issuing the first command
    Start-Sleep -Seconds 6
} else {
    Start-Sleep -Seconds 10
}

# Optional one-shot line cleanup right before first command
if ($PrepCleanup -and $proc.MainWindowHandle -ne 0) {
    Send-ToVice("{ENTER}", 200)
    Start-Sleep -Milliseconds 500
    $bs = ('{BACKSPACE}' * 20)
    Send-ToVice($bs, 80)
    Start-Sleep -Milliseconds 500
}

# Playtest sequence (tweak as needed): send each entry from -Sequence
# Note: Commodore keys: Send normal text then {ENTER}
$idx = 0
foreach ($s in $Sequence) {
    $charDelay = if ($idx -eq 0) { 600 } else { 300 }
    Send-ToVice($s, $charDelay)
    Start-Sleep -Milliseconds 1200
    $idx += 1
}

if (-not $NoPause) {
    Write-Host "Playtest sequence sent. Emulator running. Press Enter to continue." -ForegroundColor Cyan
    Read-Host | Out-Null
} else {
    Write-Host "Playtest sequence sent (no-pause)." -ForegroundColor Cyan
}

# Optional screenshot capture of the emulator window
try {
    if ($proc.MainWindowHandle -ne 0 -and -not [string]::IsNullOrEmpty($ScreenshotPath)) {
        # Add GetWindowRect
        $src = @'
using System;
using System.Runtime.InteropServices;
public static class WinCap {
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
'@
        Add-Type -TypeDefinition $src -Language CSharp -ErrorAction SilentlyContinue | Out-Null
        $rect = New-Object WinCap+RECT
        [WinCap]::GetWindowRect([IntPtr]$proc.MainWindowHandle, [ref]$rect) | Out-Null
        $width = $rect.Right - $rect.Left
        $height = $rect.Bottom - $rect.Top
        if ($width -gt 0 -and $height -gt 0) {
            Add-Type -AssemblyName System.Drawing
            $bmp = New-Object System.Drawing.Bitmap($width, $height)
            $gfx = [System.Drawing.Graphics]::FromImage($bmp)
            $gfx.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bmp.Size)
            $dir = Split-Path -Path $ScreenshotPath -Parent
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            $bmp.Save($ScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $gfx.Dispose()
            $bmp.Dispose()
            Write-Host "Saved screenshot: $ScreenshotPath" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Screenshot capture failed: $_" -ForegroundColor Yellow
}

# Attempt to read EVLOG from the PRG directory (FS device 8 maps here)
# Poll for up to ~30 seconds to allow the game to write after the giveItem event
$pollSeconds = 30
$printed = $false
for ($i = 0; $i -lt $pollSeconds; $i++) {
    if (Test-Path "EVLOG") {
        $info = Get-Item -Path "EVLOG" -ErrorAction SilentlyContinue
        if ($info -and $info.Length -gt 0) {
            Write-Host "EVLOG found. Recent entries:" -ForegroundColor Green
            Get-Content -Path "EVLOG" -ErrorAction SilentlyContinue | Select-Object -Last 25 | ForEach-Object { Write-Host $_ }
            $printed = $true
            break
        }
    }
    Start-Sleep -Seconds 1
}
if (-not $printed) {
    Write-Host "EVLOG not found or empty; it may be created later in-game." -ForegroundColor Yellow
}
}
finally {
    Pop-Location
}
