# A Song For The Ages for Baldurs Gate 3

# Features

- A bard NPC quest giver with full dialogue
- Multi-room cave dungeon with goblin encounters and a Bugbear boss
- Custom magic amulet reward

# Releases

- [Steam Workshop]()
- [Nexus]()

# Development Setup

To work on this mod with the BG3 Toolkit, you need to run a setup script that links your Git repository to BG3's Data folder using directory junctions. This only needs to be done once per repository clone/machine. It re-run safely if the repo is updated with new junctions.

## Prerequisites

- Baldur's Gate 3 installed via Steam
- BG3 Toolkit installed
- Git with LFS enabled — run `git lfs install` once per machine if you haven't already
- Administrator privileges (required for creating junctions via setup script)

## First-Time Setup

1. **Clone the repository:**

   ```powershell
   git clone https://github.com/CarterIrish/A-Song-For-The-Ages.git
   cd A-Song-For-The-Ages
   ```

2. **Open PowerShell as Administrator** — right-click PowerShell and select "Run as Administrator"

3. **Navigate to the repository folder:**

   ```powershell
   cd "D:\path\to\A-Song-For-The-Ages"
   ```

4. **Run the setup script:**

   ```powershell
   .\setup-junctions.ps1
   ```

   On first run you will be prompted to enter your BG3 Data folder path. This is the `Data` folder inside your BG3 Steam installation, for example:

   ```
   G:\SteamLibrary\steamapps\common\Baldurs Gate 3\Data
   ```

   You can also pass it directly as an argument:

   ```powershell
   .\setup-junctions.ps1 "G:\SteamLibrary\steamapps\common\Baldurs Gate 3\Data"
   ```

   Your path is saved to `bg3-setup.config.json` after a successful run, so future runs will not prompt you again. If you have changes to the path, you can change it here or re-provide directly in the script.

5. **Open BG3 Toolkit** — you should see `ASongForTheAges` in your mod list.

## Re-running the Script

The script is safe to re-run at any time, for example when the repo gains new junctions. It will skip any junctions that already exist and only create new ones. Always run as Administrator.

## What the Script Does

The script creates three directory junctions so that files written by the BG3 Toolkit flow directly into your Git working tree:

| Repo folder                        | Points to                                  |
| ---------------------------------- | ------------------------------------------ |
| `Mods/ASongForTheAges_.../`        | `BG3Data\Mods\ASongForTheAges_...\`        |
| `Editor/Mods/ASongForTheAges_.../` | `BG3Data\Editor\Mods\ASongForTheAges_...\` |
| `Public/ASongForTheAges_.../`      | `BG3Data\Public\ASongForTheAges_...\`      |

## Committing Toolkit Changes

After making changes in the BG3 Toolkit, **always save the level explicitly before closing the editor.** Unsaved changes exist only in memory and will be lost.

After saving, use `git status` or GitHub app to see what changed. When staging level work make sure to include everything the Toolkit wrote — not just the `SelectionGroups/` or `Terrains/` metadata, but the full level directory:

```bash
git add Mods/ASongForTheAges_dd5252f6-ddae-5e37-0961-0bafb237afe5/Levels/
git add Editor/Mods/ASongForTheAges_dd5252f6-ddae-5e37-0961-0bafb237afe5/Levels/
git commit -m "Your change description"
git push
```

git add also works here:
```bash
git add .
git commit -m "Your change description"
git push
```

## Git LFS

The following binary file types are tracked via Git LFS:

`.png` `.gr2` `.dds` `.tga` `.wem` `.bnk` `.bik` `.lsf`

If you add new binary asset types, track them before committing:

```bash
git lfs track "*.ext"
git add .gitattributes
```

# Attribution

- [Baldur's Gate 3](https://store.steampowered.com/app/1086940/Baldurs_Gate_3/), a game by [Larian Studios](https://larian.com/)
