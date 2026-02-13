param(
    [Parameter(Mandatory=$true, HelpMessage="Please provide a file path to the BG3 data directory.")]
    [string]$BG3DataPath
)

Write-Host $BG3DataPath

$ErrorActionPreference = "Stop"

Write-Host "`n=== BG3 Mod Junctio Setup ===" -ForegroundColor Cyan
Write-Host "This script will setup your Git repo to work with BG3 Toolkit `n" -ForegroundColor Gray

if(-not (Test-Path $BG3DataPath))
{
    Write-Host "ERROR: BG3 Data path not found: $BG3DataPath" - -ForegroundColor Red
    Write-Host "Please verify your BG3 install path and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "BG3 Data Path: $BG3DataPath" -ForegroundColor Green

$ModUUID = "ASongForTheAges_dd5252f6-ddae-5e37-0961-0bafb237afe5"

# Step 1 is to copy the files into BG3 Data folder
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
try {
    Write-Host "    - Removing Mods Folder..." -ForegroundColor Gray
    Remove-Item "Mods\$UUID" -Recurse -Force

    Write-Host "    - Removing Editor Folder..." -ForegroundColor Gray
    Remove-Item "Editor\Mods\$UUID" -Recurse -Force

    Write-Host "    - Removing Projects Folder..." -ForegroundColor Gray
    Remove-Item "Projects\$UUID" -Recurse -Force

    Write-Host "    Folders removed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to remove folders: $_" -ForgroundColor Red
    Write-Host "You may need to run PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}