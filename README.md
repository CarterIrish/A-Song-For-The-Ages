A Song For The Ages for Baldurs Gate 3
=======

# Features:

# Releases
* [Steam Workshop]() 
* [Nexus]()

# Development Setup

To work on this mod with the BG3 Toolkit, you need to create junctions that link your git repository to BG3's Data folder.

## Prerequisites
- Baldur's Gate 3 installed
- BG3 Toolkit
- Administrator privileges (required for creating junctions)

## Running the Setup Script

1. **Open PowerShell as Administrator** - Right-click PowerShell and select "Run as Administrator"

2. **Navigate to the repository folder:**
   ```powershell
   cd "D:\path\to\A-Song-For-The-Ages"
   ```

3. **Run the setup script** with your BG3 Data folder path:
   ```powershell
   .\setup-junctions.ps1 -BG3DataPath "C:\path\to\Baldurs Gate 3\Data"
   ```
   
   Example with a typical Steam installation:
   ```powershell
   .\setup-junctions.ps1 "G:\SteamLibrary\steamapps\common\Baldurs Gate 3\Data"
   ```

4. **Open BG3 Toolkit** - You should see "ASongForTheAges" in your mod list

## What the Script Does

The script creates directory junctions so that:
- Changes made in BG3 Toolkit are reflected in your git repo
- You can commit and push changes as normal
- Multiple developers can collaborate on the mod

# Attribution
- [Baldurs Gate 3](https://store.steampowered.com/app/1086940/Baldurs_Gate_3/), a game by [Larian Studios](https://larian.com/)

