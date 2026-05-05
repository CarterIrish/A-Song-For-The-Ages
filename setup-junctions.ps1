param(
    [Parameter(Mandatory = $false)]
    [string]$BG3DataPath
)

$configPath = "bg3-setup.config.json"

# Load path from config if not provided
if (-not $BG3DataPath) {
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        $BG3DataPath = $config.BG3DataPath
        Write-Host "Loaded BG3DataPath from config: $BG3DataPath" -ForegroundColor Cyan
    }
    else {
        $BG3DataPath = Read-Host "Enter your BG3 Data path (e.g. G:\SteamLibrary\...\Baldurs Gate 3\Data)"
    }
}

$ErrorActionPreference = "Stop"

# Check for Administrator privileges (required for junctions)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges to create junctions." -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== BG3 Mod Junction Setup ===" -ForegroundColor Cyan
Write-Host "This script will setup your Git repo to work with BG3 Toolkit `n" -ForegroundColor Gray

if (-not (Test-Path $BG3DataPath)) {
    Write-Host "ERROR: BG3 Data path not found: $BG3DataPath" -ForegroundColor Red
    Write-Host "Please verify your BG3 install path and try again." -ForegroundColor Yellow
    exit 1
}

# Save path to config only after confirming it is valid
$config = @{ BG3DataPath = $BG3DataPath }
$config | ConvertTo-Json | Set-Content $configPath
Write-Host "Saved BG3DataPath to $configPath" -ForegroundColor Gray

Write-Host "BG3 Data Path: $BG3DataPath" -ForegroundColor Green

Write-Host "`nAuto-detecting mod UUID..." -ForegroundColor Yellow
$modFolders = Get-ChildItem -Path "Mods" -Directory | Where-Object {
    $_.Name -match ".*_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
}

if ($modFolders.Count -eq 0) {
    Write-Host "ERROR: No mod Folder found in Mods/ Directory" -ForegroundColor Red
    Write-Host "Expected format: ModName_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -ForegroundColor Yellow
    exit 1
}

if ($modFolders.count -gt 1) {
    Write-Host "ERROR: Multiple mod folders found. Please Specify which mod:" -ForegroundColor Red
    $modFolders | ForEach-Object { Write-Host "  -$($_.Name)" -ForegroundColor Yellow }
    exit 1
}

$ModUUID = $modFolders[0].Name
Write-Host "    Detected: $ModUUID" -ForegroundColor Green

# Step 1: Copy mod files into BG3 Data folder (skip if junction already exists)
Write-Host "`n[Step 1/4] Copying Mod Files to BG3 data folder..." -ForegroundColor Yellow
try {
    # Make new file dirs if they arent there
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Mods"
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Editor\Mods"
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Public"
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Projects"

    $sources = [ordered]@{
        "Mods\$ModUUID"        = "$BG3DataPath\Mods\"
        "Editor\Mods\$ModUUID" = "$BG3DataPath\Editor\Mods\"
        "Public\$ModUUID"      = "$BG3DataPath\Public\"
        "Projects\$ModUUID"    = "$BG3DataPath\Projects\"
    }

    foreach ($source in $sources.Keys) {
        $dest = $sources[$source]
        $destFull = Join-Path $dest (Split-Path $source -Leaf)
        $existing = Get-Item $source -ErrorAction SilentlyContinue

        if ($existing -and $existing.LinkType -eq "Junction") {
            Write-Host "    - Skipping copy for $source (junction already exists)" -ForegroundColor Gray
            continue
        }
        if (-not (Test-Path $source)) {
            Write-Host "    - Skipping $source (folder not found in repo)" -ForegroundColor Yellow
            continue
        }

        # Warn and prompt before clobbering an existing non-empty destination
        if (Test-Path $destFull) {
            $existingFiles = @(Get-ChildItem $destFull -Recurse -Force -File -ErrorAction SilentlyContinue)
            if ($existingFiles.Count -gt 0) {
                Write-Host "    ! Destination already contains $($existingFiles.Count) file(s):" -ForegroundColor Yellow
                Write-Host "        $destFull" -ForegroundColor Yellow
                Write-Host "      Overwriting will replace matching files. Files only present at the destination will NOT be deleted." -ForegroundColor Yellow
                $answer = Read-Host "      Overwrite? [y/N]"
                if ($answer -notmatch '^(y|yes)$') {
                    Write-Host "ERROR: Aborted by user. No files were copied for $source." -ForegroundColor Red
                    Write-Host "       To re-run: either delete or back up '$destFull' first, or approve the overwrite." -ForegroundColor Yellow
                    exit 1
                }
            }
        }

        Write-Host "    - Copying $source -> $destFull..." -ForegroundColor Gray
        Copy-Item $source -Destination $dest -Recurse -Force
    }

    Write-Host "    Files copied successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to copy files: $_" -ForegroundColor Red
    Write-Host "       The source or destination may be locked by another process (e.g., BG3 Toolkit, Explorer)." -ForegroundColor Yellow
    Write-Host "       Close any program using these folders and re-run this script." -ForegroundColor Yellow
    exit 1
}

# Step 2: Remove real folders from Git clone (replace with junctions)
Write-Host "`n[Step 2/4] Removing real files from Git Clone..." -ForegroundColor Yellow
try {
    $foldersToRemove = [ordered]@{
        "Mods\$ModUUID"        = "$BG3DataPath\Mods\$ModUUID"
        "Editor\Mods\$ModUUID" = "$BG3DataPath\Editor\Mods\$ModUUID"
        "Public\$ModUUID"      = "$BG3DataPath\Public\$ModUUID"
        "Projects\$ModUUID"    = "$BG3DataPath\Projects\$ModUUID"
    }

    foreach ($folder in $foldersToRemove.Keys) {
        $target = $foldersToRemove[$folder]
        $existing = Get-Item $folder -ErrorAction SilentlyContinue

        if (-not $existing) {
            Write-Host "    - Skipping $folder (not present in repo)" -ForegroundColor Gray
            continue
        }
        if ($existing.LinkType -eq "Junction") {
            Write-Host "    - Skipping removal of $folder (already a junction)" -ForegroundColor Gray
            continue
        }
        if (-not (Test-Path $target)) {
            Write-Host "ERROR: Refusing to remove $folder — junction target does not exist:" -ForegroundColor Red
            Write-Host "       $target" -ForegroundColor Red
            Write-Host "       Step 1 should have copied files there. Check the Step 1 output above for clues." -ForegroundColor Yellow
            exit 1
        }

        Write-Host "    - Removing $folder..." -ForegroundColor Gray
        try {
            Remove-Item $folder -Recurse -Force
        }
        catch {
            Write-Host "ERROR: Failed to remove '$folder': $_" -ForegroundColor Red
            Write-Host "       The folder is likely locked. Common culprits:" -ForegroundColor Yellow
            Write-Host "         - BG3 Toolkit has the mod open" -ForegroundColor Yellow
            Write-Host "         - An IDE / editor has a file from the folder open" -ForegroundColor Yellow
            Write-Host "         - Windows Explorer is browsing inside the folder" -ForegroundColor Yellow
            Write-Host "       Close those programs and re-run this script." -ForegroundColor Yellow
            exit 1
        }

        if (Test-Path $folder) {
            Write-Host "ERROR: '$folder' still exists after removal — some files could not be deleted." -ForegroundColor Red
            Write-Host "       Close any program holding files in this folder and re-run." -ForegroundColor Yellow
            exit 1
        }
    }

    Write-Host "    Folders removed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to remove folders: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Create junctions (skip if already exists)
Write-Host "`n[Step 3/4] Creating Junctions..." -ForegroundColor Yellow
try {
    $junctions = [ordered]@{
        "Mods\$ModUUID"        = "$BG3DataPath\Mods\$ModUUID"
        "Editor\Mods\$ModUUID" = "$BG3DataPath\Editor\Mods\$ModUUID"
        "Public\$ModUUID"      = "$BG3DataPath\Public\$ModUUID"
        "Projects\$ModUUID"    = "$BG3DataPath\Projects\$ModUUID"
    }

    foreach ($link in $junctions.Keys) {
        $target = $junctions[$link]
        $existing = Get-Item $link -ErrorAction SilentlyContinue

        if ($existing -and $existing.LinkType -eq "Junction") {
            Write-Host "    - Junction already exists, skipping: $link" -ForegroundColor Gray
            continue
        }
        if ($existing) {
            Write-Host "ERROR: Cannot create junction at '$link' — a real folder still exists there." -ForegroundColor Red
            Write-Host "       Step 2 should have removed it. Check the Step 2 output above." -ForegroundColor Yellow
            exit 1
        }
        if (-not (Test-Path $target)) {
            Write-Host "    - Skipping junction for $link (target $target not found)" -ForegroundColor Yellow
            continue
        }

        Write-Host "    - Creating junction: $link -> $target" -ForegroundColor Gray
        $Result = cmd /c mklink /J "$link" "$target" 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "mklink failed for '$link' -> '$target': $Result"
        }
    }
    Write-Host "    Junctions created successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to create junctions: $_" -ForegroundColor Red
    Write-Host "       Make sure this script is running as Administrator (mklink /J needs it)." -ForegroundColor Yellow
    exit 1
}

# Step 4: Verify all junctions (only the folders that actually exist in this repo)
Write-Host "`n[Step 4/4] Verifying Setup..." -ForegroundColor Cyan
$expectedJunctions = [ordered]@{
    "Mods"     = "Mods\$ModUUID"
    "Editor"   = "Editor\Mods\$ModUUID"
    "Public"   = "Public\$ModUUID"
    "Projects" = "Projects\$ModUUID"
}

$verified = @()
$failed = @()
foreach ($label in $expectedJunctions.Keys) {
    $path = $expectedJunctions[$label]
    $item = Get-Item $path -ErrorAction SilentlyContinue
    if (-not $item) { continue }
    if ($item.LinkType -eq "Junction") {
        $verified += [pscustomobject]@{ Label = $label; Path = $path; Target = $item.Target }
    }
    else {
        $failed += $path
    }
}

if ($failed.Count -eq 0 -and $verified.Count -gt 0) {
    Write-Host "`nSuccess! All junctions were created properly" -ForegroundColor Green
    Write-Host "`nJunction Details:" -ForegroundColor Gray
    foreach ($j in $verified) {
        Write-Host ("  {0,-8} -> {1}" -f $j.Label, $j.Target) -ForegroundColor Gray
    }

    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Open BG3 Toolkit - you should see '$ModUUID' in your mod list" -ForegroundColor White
    Write-Host "  2. Make changes in the Toolkit" -ForegroundColor White
    Write-Host "  3. Use 'git status' to see your changes" -ForegroundColor White
    Write-Host "  4. Commit and push as normal!" -ForegroundColor White
}
else {
    Write-Host "`nWARNING: One or more junctions may not be setup correctly." -ForegroundColor Red
    foreach ($f in $failed) {
        Write-Host "  - $f is not a junction" -ForegroundColor Yellow
    }
    Write-Host "Please verify manually with: Get-Item 'Mods\$ModUUID' | Select-Object LinkType, Target" -ForegroundColor Yellow
}

Write-Host ""