param(
    [string]$VicePath = 'C:\commodore\GTK3VICE-3.10-win64\bin\x64sc.exe',
    [string]$D64Path = "$PSScriptRoot\..\bin\everland.d64",
    [string]$OutVideo = "$PSScriptRoot\screens\coin_demo.mp4",
    [int]$DurationSec = 25
)

# Ensure screens dir
$ssDir = Join-Path $PSScriptRoot 'screens'
if (-not (Test-Path $ssDir)) { New-Item -ItemType Directory -Path $ssDir | Out-Null }

# Kill existing emulator
Get-Process -Name x64sc -ErrorAction SilentlyContinue | ForEach-Object { try { $_.CloseMainWindow(); Start-Sleep -Milliseconds 200 } catch {}; if (-not $_.HasExited) { Stop-Process -Id $_.Id -Force } }

# Compose initial key buffer: clean prompt, wildcard load+run, extra spacing
$KEYBUF = "\n \n \n load`"*`",8,1\n \n run\n \n \n"

# Start emulator with D64 mounted and initial keybuf
Start-Process -FilePath $VicePath -ArgumentList "-8 `"$D64Path`" -keybuf `"$KEYBUF`"" -PassThru | Out-Null

# Wait for window
$proc = $null
for ($i=0; $i -lt 20; $i++) {
  $proc = Get-Process -Name x64sc -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($proc -and $proc.MainWindowHandle -ne 0) { break }
  Start-Sleep -Milliseconds 500
}
if (-not $proc) { Write-Host "Emulator window not found" -ForegroundColor Yellow; exit 1 }

# Bring to front
$winapiPath = Join-Path $PSScriptRoot 'winapi.ps1'
if (Test-Path $winapiPath) { . $winapiPath }
if ($proc.MainWindowHandle -ne 0) { Show-Window ([IntPtr]$proc.MainWindowHandle) 3; Start-Sleep -Milliseconds 200; Set-ForegroundWindow ([IntPtr]$proc.MainWindowHandle) }

# Start ffmpeg recording if available
$ff = Get-Command ffmpeg -ErrorAction SilentlyContinue
$recJob = $null
if ($ff) {
  $title = $proc.MainWindowTitle
  $args = @('-y','-f','gdigrab','-framerate','30','-i',"title=$title",'-t',$DurationSec.ToString(),'-c:v','libx264','-pix_fmt','yuv420p',"$OutVideo")
  $recJob = Start-Process -FilePath $ff.Path -ArgumentList $args -PassThru
  Write-Host "Recording with ffmpeg to $OutVideo"
} else {
  Write-Host "ffmpeg not found; proceeding without video capture" -ForegroundColor Yellow
}

# Send inputs with conservative delays
Add-Type -AssemblyName System.Windows.Forms
function SendToVice([string]$keys,[int]$delay=900){ [System.Windows.Forms.SendKeys]::SendWait($keys); Start-Sleep -Milliseconds $delay }

# Login answers
SendToVice('eve{ENTER}',900)      # username
SendToVice('eve{ENTER}',900)      # display name
SendToVice('knight{ENTER}',900)   # class
SendToVice('0{ENTER}',700)        # PIN
SendToVice('4{ENTER}',700)        # month
SendToVice('14{ENTER}',700)       # week

# Talk to conductor and select quest, then open inventory
SendToVice('talk conductor{ENTER}',900)
SendToVice('3{ENTER}',900)
SendToVice('i{ENTER}',900)

# Wait for recording to finish
if ($recJob) { $recJob.WaitForExit() }

Write-Host "Done. Video: $OutVideo"
