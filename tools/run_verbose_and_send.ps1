param(
    [string]$VicePath = 'C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe',
    [string]$PrgPath = "C:\commodore\everland\bin\everland.prg",
    [string]$OutScreenshot = "$PSScriptRoot\screens\conv_manual_send.png",
    [int]$TimeoutSec = 30
)

# ensure screens dir
if (-not (Test-Path (Join-Path $PSScriptRoot 'screens'))) { New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'screens') | Out-Null }

# kill any existing x64sc
Get-Process -Name x64sc -ErrorAction SilentlyContinue | ForEach-Object { try { $_.CloseMainWindow(); Start-Sleep -Milliseconds 200 } catch {}; if (-not $_.HasExited) { Stop-Process -Id $_.Id -Force } }

# start VICE with verbose logging to file
$log = Join-Path $PSScriptRoot 'vice_verbose_run.log'
Start-Process -FilePath $VicePath -ArgumentList "--verbose -autostart `"$PrgPath`" -warp" -NoNewWindow -PassThru | Out-Null

# wait for process window
$sw = 0
$found = $false
while ($sw -lt $TimeoutSec) {
    $proc = Get-Process -Name x64sc -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc -and $proc.MainWindowHandle -ne 0) { $found = $true; break }
    Start-Sleep -Seconds 1
    $sw += 1
}
if (-not $found) { Write-Host "VICE window not found after $TimeoutSec seconds" -ForegroundColor Yellow }

# bring to front using helper if present
$winapiPath = Join-Path $PSScriptRoot 'winapi.ps1'
if (Test-Path $winapiPath) { . $winapiPath } else { Write-Host "winapi.ps1 missing; window focusing may fail." -ForegroundColor Yellow }
if ($proc -and $proc.MainWindowHandle -ne 0) { Show-Window ([IntPtr]$proc.MainWindowHandle) 3; Start-Sleep -Milliseconds 200; Set-ForegroundWindow ([IntPtr]$proc.MainWindowHandle); Start-Sleep -Milliseconds 400 }

# send keys
Add-Type -AssemblyName System.Windows.Forms
function SendToVice([string]$keys,[int]$delay=700){ [System.Windows.Forms.SendKeys]::SendWait($keys); Start-Sleep -Milliseconds $delay }

SendToVice('TALK BARTENDER{ENTER}',1000)
SendToVice('2{ENTER}',800)
SendToVice('1{ENTER}',800)
Start-Sleep -Seconds 1

# capture screenshot (PowerShell fallback)
try {
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    $bounds = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
    $bmp = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen(0,0,0,0,$bmp.Size)
    $bmp.Save($OutScreenshot, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bmp.Dispose()
    Write-Host "Saved screenshot to $OutScreenshot"
} catch {
    Write-Host "Screenshot capture failed: $_" -ForegroundColor Yellow
}

# sleep a bit then tail last 80 lines of any vice verbose log in working dir
Start-Sleep -Seconds 1
$possible = Get-ChildItem (Split-Path $VicePath) -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($possible) { Write-Host "Tailing: $($possible.FullName)"; Get-Content $possible.FullName -Tail 80 }

Write-Host 'Done'
