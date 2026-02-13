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

if($modFolders.Count -eq 0)
{
    Write-Host "ERROR: No mod Folder found in Mods/ Directory" -ForegroundColor Red
    Write-Host "Expected format: ModName_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -ForegroundColor Yellow
}

if($modFolders.count -gt 1)
{
    Write-Host "ERROR: Multiple mod folders found. Please Specify which mod:" -ForegroundColor Red
    $modFolders | ForEach-Object {Write-Host "  -$($_.Name)" -ForegroundColor Yellow}
    exit 1
}

$ModUUID = $modFolders[0].Name
Write-Host "    Detected: $ModUUID" -ForegroundColor Green

# Step 1 is to copy the files into BG3 Data folder
Write-Host "`n[Step 1/3] Copying Mod Files to BG3 data folder..." -ForegroundColor Yellow
try {
    # Make new file dirs if they arent there
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Mods"
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Editor\Mods"
    $null = New-Item -ItemType Directory -Force -Path "$BG3DataPath\Projects"

    # Copy mods folder
    Write-Host "    - Copying Mods..." -ForegroundColor Gray
    Copy-Item "Mods\$ModUUID" -Destination "$BG3DataPath\Mods\" -Recurse -Force

    # Copy Editor Folder
    Write-Host "    - Copying Editor..." -ForegroundColor Gray
    Copy-Item "Editor\Mods\$ModUUID" -Destination "$BG3DataPath\Editor\Mods\" -Recurse -Force

    # Copy Projects Folder
    Write-Host "    - Copying Projects..." -ForegroundColor Gray
    Copy-Item "Projects\$ModUUID" -Destination "$BG3DataPath\Projects\" -Recurse -Force

    Write-Host "    Files copied successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to copy files: $_" -ForegroundColor Red
}

# Step 2 is to remove the real files from git clone
Write-Host "`n[Step 2/3] Removing real files from Git Clone..." -ForegroundColor Yellow
try {
    Write-Host "    - Removing Mods Folder..." -ForegroundColor Gray
    Remove-Item "Mods\$ModUUID" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "    - Removing Editor Folder..." -ForegroundColor Gray
    Remove-Item "Editor\Mods\$ModUUID" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "    - Removing Projects Folder..." -ForegroundColor Gray
    Remove-Item "Projects\$ModUUID" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "    Folders removed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to remove folders: $_" -ForegroundColor Red
    Write-Host "You may need to run PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}

# Step 3 Create the new junctions

Write-Host "`n[Step 3/3] Creating Junctions..." -ForegroundColor Yellow
try {
    Write-Host "    - Creating Mods junction..." -ForegroundColor Gray
    $Result = cmd /c mklink /J "Mods\$ModUUID" "$BG3DataPath\Mods\$ModUUID" 2>&1
    if ($LASTEXITCODE -ne 0) { throw $Result }

    Write-Host "    - Creating Editor junction..." -ForegroundColor Gray
    $Result = cmd /c mklink /J "Editor\Mods\$ModUUID" "$BG3DataPath\Editor\Mods\$ModUUID" 2>&1
    if ($LASTEXITCODE -ne 0) { throw $Result }

    Write-Host "    - Creating Projects junction..." -ForegroundColor Gray
    $Result = cmd /c mklink /J "Projects\$ModUUID" "$BG3DataPath\Projects\$ModUUID" 2>&1
    if ($LASTEXITCODE -ne 0) { throw $Result }

    Write-Host "    Junctions created successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to create junctions: $_" -ForegroundColor Red
    Write-Host "You MUST run PowerShell as Administrator to create junctions." -ForegroundColor Yellow
    exit 1
}

# Cleanup: Run verification to ensure all steps were successful
Write-Host "`n=== Verifying Setup ===" -ForegroundColor Cyan
$modsJunction = Get-Item "Mods\$ModUUID"
$editorJunction = Get-Item "Editor\Mods\$ModUUID"
$projectsJunction = Get-Item "Projects\$ModUUID"

if ($modsJunction.LinkType -eq "Junction" -and $editorJunction.LinkType -eq "Junction" -and $projectsJunction.LinkType -eq "Junction") {
    Write-Host "`nSuccess! All junctions were created properly" -ForegroundColor Green
    Write-Host "`nJunction Details:" -ForegroundColor Gray
    Write-Host "  Mods     -> $($modsJunction.Target)" -ForegroundColor Gray
    Write-Host "  Editor   -> $($editorJunction.Target)" -ForegroundColor Gray
    Write-Host "  Projects -> $($projectsJunction.Target)" -ForegroundColor Gray

    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Open BG3 Toolkit - you should see 'ASongForTheAges' in your mod list" -ForegroundColor White
    Write-Host "  2. Make changes in the Toolkit" -ForegroundColor White
    Write-Host "  3. Use 'git status' to see your changes" -ForegroundColor White
    Write-Host "  4. Commit and push as normal!" -ForegroundColor White
}
else {
    Write-Host "`nWARNING: Junctions may not be setup correctly." -ForegroundColor Red
    Write-Host "Please verify manually with: Get-Item 'Mods\$ModUUID' | Select-Object LinkType, Target" -ForegroundColor Yellow
}

Write-Host ""