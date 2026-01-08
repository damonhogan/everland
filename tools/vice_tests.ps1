<#
Simple test harness for VICE playtest scenarios.
Usage: .\vice_tests.ps1 [-VicePath <path>] [-PrgPath <path>] [-Scenario smoke|quest|save]
This script reuses tools/vice_playtest.ps1 and runs a few named scenarios.
#>
param(
    [string]$VicePath = '',
    [string]$PrgPath = "$PWD\\bin\\everland.prg",
    [string]$Scenario = 'smoke'
)

function RunScenario($name, $sequence) {
    Write-Host "Running scenario: $name"
    & powershell -ExecutionPolicy Bypass -File .\tools\vice_playtest.ps1 -VicePath $VicePath -PrgPath $PrgPath -Sequence $sequence
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
        # conversation numeric-choice smoke test: TALK BARTENDER -> choose 2 (QUEST) -> leave
        RunScenario 'conv' @('TALK BARTENDER{ENTER}','2{ENTER}','1{ENTER}')
        break
    }
    default {
        Write-Host "Unknown scenario: $Scenario. Available: smoke, quest, save" -ForegroundColor Yellow
        break
    }
}
