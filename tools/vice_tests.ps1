<#
Simple test harness for VICE playtest scenarios.
Usage: .\vice_tests.ps1 [-VicePath <path>] [-PrgPath <path>] [-Scenario smoke|quest|save]
This script reuses tools/vice_playtest.ps1 and runs a few named scenarios.
#>
param(
    [string]$VicePath = '',
    [string]$PrgPath = "$PWD\\bin\\everland.prg",
    [string]$Scenario = 'smoke',
    [switch]$CaptureScreenshots
)

function RunScenario($name, $sequence) {
    Write-Host "Running scenario: $name"
    # Build argument list for the spawned PowerShell so we only include -VicePath when it's set
    $exeArgs = @('-ExecutionPolicy','Bypass','-File', (Join-Path $PSScriptRoot 'vice_playtest.ps1'))
    if ($VicePath -and $VicePath.Trim() -ne '') {
        $exeArgs += '-VicePath'
        $exeArgs += $VicePath
    }
    $exeArgs += '-PrgPath'
    $exeArgs += $PrgPath
    $exeArgs += '-Sequence'
    $exeArgs += $sequence
    $exeArgs += '-NoPause'
    & powershell @exeArgs
    if ($CaptureScreenshots) {
        $screensDir = Join-Path $PSScriptRoot 'screens'
        if (-not (Test-Path $screensDir)) { New-Item -ItemType Directory -Path $screensDir | Out-Null }
        $out = Join-Path $screensDir "$name.png"
        # prefer nircmd if available
        $nircmd = (Get-Command nircmd.exe -ErrorAction SilentlyContinue)
        if ($nircmd) {
            & $nircmd.Source "savescreenshot" $out
            Write-Host "Saved screenshot to $out"
        } else {
            # try ImageMagick (magick.exe) next
            $magick = (Get-Command magick.exe -ErrorAction SilentlyContinue)
            $captured = $false
            if ($magick) {
                try {
                    & $magick.Source 'screenshot:' $out
                    Write-Host "Saved screenshot to $out (ImageMagick)"
                    $captured = $true
                } catch {
                    Write-Host "ImageMagick screenshot failed: $_" -ForegroundColor Yellow
                    Write-Host "Falling back to PowerShell capture..." -ForegroundColor Yellow
                }
            } else {
                Write-Host "nircmd/magick not found; attempting PowerShell screenshot capture..." -ForegroundColor Yellow
            }
            if (-not $captured) {
                try {
                    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
                    $bounds = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
                    $bmp = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
                    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
                    $graphics.CopyFromScreen(0,0,0,0,$bmp.Size)
                    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
                    $graphics.Dispose()
                    $bmp.Dispose()
                    Write-Host "Saved screenshot to $out (PowerShell capture)"
                } catch {
                    Write-Host "PowerShell screenshot capture failed: $_" -ForegroundColor Yellow
                    Write-Host "Skipping screenshot capture." -ForegroundColor Yellow
                }
            }
        }
    }
}

switch ($Scenario.ToLower()) {
    'smoke' {
        RunScenario 'smoke' @('TALK BARTENDER{ENTER}','3{ENTER}')
        break
    }
    'quest' {
        RunScenario 'quest' @('TALK BARTENDER{ENTER}','3{ENTER}','GIVE COIN TO BARTENDER{ENTER}')
        break
    }
    'save' {
        RunScenario 'save' @('TALK BARTENDER{ENTER}','3{ENTER}','S{ENTER}','1{ENTER}')
        break
    }
    'conv' {
        # conversation numeric-choice smoke test: perform login (username+displayname),
        # then TALK BARTENDER -> choose 2 (QUEST) -> leave
        RunScenario 'conv' @('PLAYER{ENTER}','PLAYER{ENTER}','TALK BARTENDER{ENTER}','2{ENTER}','1{ENTER}')
        break
    }
    default {
        Write-Host "Unknown scenario: $Scenario. Available: smoke, quest, save" -ForegroundColor Yellow
        break
    }
}
