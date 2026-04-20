param(
    [Parameter(Mandatory = $true, HelpMessage = "Please provide a file path to the BG3 data directory.")]
    [string]$BG3DataPath
)

Write-Host $BG3DataPath

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
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Projects"
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Public"

    $sources = @{
        "Mods\$ModUUID"        = "$BG3DataPath\Mods\"
        "Editor\Mods\$ModUUID" = "$BG3DataPath\Editor\Mods\"
        "Projects\$ModUUID"    = "$BG3DataPath\Projects\"
        "Public\$ModUUID"      = "$BG3DataPath\Public\"
    }

    foreach ($source in $sources.Keys) {
        $dest = $sources[$source]
        $existing = Get-Item $source -ErrorAction SilentlyContinue

        if ($existing -and $existing.LinkType -eq "Junction") {
            Write-Host "    - Skipping copy for $source (junction already exists)" -ForegroundColor Gray
        }
        elseif (Test-Path $source) {
            Write-Host "    - Copying $source..." -ForegroundColor Gray
            Copy-Item $source -Destination $dest -Recurse -Force
        }
        else {
            Write-Host "    - Skipping $source (folder not found in repo)" -ForegroundColor Yellow
        }
    }

    Write-Host "    Files copied successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to copy files: $_" -ForegroundColor Red
}

# Step 2: Remove real folders from Git clone (replace with junctions)
Write-Host "`n[Step 2/4] Removing real files from Git Clone..." -ForegroundColor Yellow
try {
    $foldersToRemove = @(
        "Mods\$ModUUID",
        "Editor\Mods\$ModUUID",
        "Projects\$ModUUID",
        "Public\$ModUUID"
    )

    foreach ($folder in $foldersToRemove) {
        $existing = Get-Item $folder -ErrorAction SilentlyContinue
        if ($existing -and $existing.LinkType -eq "Junction") {
            Write-Host "    - Skipping removal of $folder (already a junction)" -ForegroundColor Gray
        }
        else {
            Write-Host "    - Removing $folder..." -ForegroundColor Gray
            Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "    Folders removed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to remove folders: $_" -ForegroundColor Red
    Write-Host "You may need to run PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}

# Step 3: Create junctions (skip if already exists)
Write-Host "`n[Step 3/4] Creating Junctions..." -ForegroundColor Yellow
try {
    $junctions = @{
        "Mods\$ModUUID"        = "$BG3DataPath\Mods\$ModUUID"
        "Editor\Mods\$ModUUID" = "$BG3DataPath\Editor\Mods\$ModUUID"
        "Projects\$ModUUID"    = "$BG3DataPath\Projects\$ModUUID"
        "Public\$ModUUID"      = "$BG3DataPath\Public\$ModUUID"
    }

    foreach ($link in $junctions.Keys) {
        $target = $junctions[$link]
        $existing = Get-Item $link -ErrorAction SilentlyContinue

        if ($existing -and $existing.LinkType -eq "Junction") {
            Write-Host "    - Junction already exists, skipping: $link" -ForegroundColor Gray
        }
        else {
            Write-Host "    - Creating junction: $link -> $target" -ForegroundColor Gray
            $Result = cmd /c mklink /J "$link" "$target" 2>&1
            if ($LASTEXITCODE -ne 0) { throw $Result }
        }
    }
    Write-Host "    Junctions created successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to create junctions: $_" -ForegroundColor Red
    Write-Host "You MUST run PowerShell as Administrator to create junctions." -ForegroundColor Yellow
    exit 1
}

# Step 4: Verify all junctions
Write-Host "`n[Step 4/4] Verifying Setup..." -ForegroundColor Cyan
$modsJunction = Get-Item "Mods\$ModUUID"
$editorJunction = Get-Item "Editor\Mods\$ModUUID"
$projectsJunction = Get-Item "Projects\$ModUUID"
$publicJunction = Get-Item "Public\$ModUUID"

if ($modsJunction.LinkType -eq "Junction" -and
    $editorJunction.LinkType -eq "Junction" -and
    $projectsJunction.LinkType -eq "Junction" -and
    $publicJunction.LinkType -eq "Junction") {

    Write-Host "`nSuccess! All junctions were created properly" -ForegroundColor Green
    Write-Host "`nJunction Details:" -ForegroundColor Gray
    Write-Host "  Mods     -> $($modsJunction.Target)" -ForegroundColor Gray
    Write-Host "  Editor   -> $($editorJunction.Target)" -ForegroundColor Gray
    Write-Host "  Projects -> $($projectsJunction.Target)" -ForegroundColor Gray
    Write-Host "  Public   -> $($publicJunction.Target)" -ForegroundColor Gray

    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Open BG3 Toolkit - you should see 'ASongForTheAges' in your mod list" -ForegroundColor White
    Write-Host "  2. Make changes in the Toolkit" -ForegroundColor White
    Write-Host "  3. Use 'git status' to see your changes" -ForegroundColor White
    Write-Host "  4. Commit and push as normal!" -ForegroundColor White
}
else {
    Write-Host "`nWARNING: One or more junctions may not be setup correctly." -ForegroundColor Red
    Write-Host "Please verify manually with: Get-Item 'Mods\$ModUUID' | Select-Object LinkType, Target" -ForegroundColor Yellow
}

Write-Host ""