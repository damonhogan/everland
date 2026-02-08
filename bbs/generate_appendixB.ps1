# Generate Appendix B from recipes.inc and item_names.json
$recipesPath = Join-Path $PSScriptRoot 'recipes.inc'
$itemsPath = Join-Path $PSScriptRoot 'item_names.json'
$recipes = Get-Content -Path $recipesPath -Raw -ErrorAction Stop
$items = Get-Content -Path $itemsPath -Raw | ConvertFrom-Json
$itemMap = @{}
foreach ($it in $items) { $itemMap[([int]$it.id)] = $it.name }
$stationMap = @{1='Forge';2='Saw';3='Tannery';4='Apothecary';5='Mystic Tent'}

# Extract .byte lines
$lines = $recipes -split "\r?\n" | Where-Object { $_ -match '^\s*\.byte' }
$out = @()
$out += "## Appendix B: Crafting & Cooking Recipes"
$out += ""
foreach ($l in $lines) {
    # remove inline comments after a ';' to avoid parsing issues
    $clean = ($l -split ';')[0]
    $nums = ($clean -replace '^\s*\.byte\s+','') -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    if ($nums.Count -lt 15) { continue }
    $r = [int]$nums[0]
    $station = [int]$nums[1]
    $outId = [int]$nums[2]
    $outQty = [int]$nums[3]
    $outDur = [int]$nums[4]
    $in1 = [int]$nums[5]; $in1q = [int]$nums[6]
    $in2 = [int]$nums[7]; $in2q = [int]$nums[8]
    $in3 = [int]$nums[9]; $in3q = [int]$nums[10]
    $time = [int]$nums[11]
    $succ = [int]$nums[12]
    $skill = [int]$nums[13]
    $disc = [int]$nums[14]
    $stationName = $stationMap[$station]
    $outName = $itemMap[$outId]
    $inputs = @()
    if ($in1 -ne 255 -and $in1q -gt 0) { $inputs += "$($in1q) × $($itemMap[$in1]) (id $in1)" }
    if ($in2 -ne 255 -and $in2q -gt 0) { $inputs += "$($in2q) × $($itemMap[$in2]) (id $in2)" }
    if ($in3 -ne 255 -and $in3q -gt 0) { $inputs += "$($in3q) × $($itemMap[$in3]) (id $in3)" }
    $inputsStr = if ($inputs.Count -gt 0) { $inputs -join ' + ' } else { 'None' }
    $line = "- [$r] $stationName -> $outName (x$outQty, dur=$outDur): $inputsStr; time=$time ticks; success=$succ%; skill_req=$skill; discover_flag=$disc"
    $out += $line
}

# Replace the existing Appendix B block in MANUAL.md
$manualPath = Join-Path $PSScriptRoot 'MANUAL.md'
$manual = Get-Content -Path $manualPath -Raw
$start = $manual.IndexOf('## Appendix B: Crafting & Cooking Recipes')
if ($start -ge 0) {
    $before = $manual.Substring(0,$start)
    # find next top-level header after this section (## Appendix C or EOF)
    $afterIndex = $manual.IndexOf("## Appendix C", $start)
    if ($afterIndex -lt 0) { $after = "" } else { $after = $manual.Substring($afterIndex) }
    $newManual = $before + ($out -join "`r`n") + "`r`n" + $after
    $newManual | Out-File -FilePath $manualPath -Encoding UTF8
    Write-Host "MANUAL.md updated with generated Appendix B"
} else {
    Write-Host "Appendix B header not found in MANUAL.md"
}
