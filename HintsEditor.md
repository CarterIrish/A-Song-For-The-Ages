# Editor Hints

Compiled from `HintsEditor.lsx`. Hints marked *(Internal)* were flagged as internal-only in the source.

## Hover Shortcuts

- **CTRL+Shift+K** — when hovering over an entity, kills/destroys it.
- **CTRL+Shift+L** — when hovering over a character, levels it up.
- **CTRL+Shift+S** — when hovering over a character in dialog, force-stops the dialog (only use when stuck; report blocked dialogs). *(Internal)*
- **CTRL+Shift+Click** — on anything (except offstage entities), shows debug info. *(Internal)*
- **CTRL+T** / **CTRL+Shift+T** — teleport your character / party to hovered area.
- **CTRL+Shift+R** — when hovering over a character, resurrects it.

## Editor Keyboard Shortcuts

- **CTRL+Enter** (or NumPad Enter) — toggle game mode.
- **F11** — open ReCon (the console). *(Internal)*
- **CTRL+Delete** — ignore an assert. *(Internal)*
- **CTRL+Shift+O** — open the Project menu.
- **CTRL+O** — open the Level menu.
- **CTRL+Shift+F4** — force close the editor (immediate shutdown).
- **CTRL+Shift+F7** — Graphics Debug panel (hide characters/items/scenery; warning: invisible items can still be clicked). *(Internal)*
- **CTRL+R** — reload the level (not the Story).
- **CTRL+Shift+A** — display the AI Grid. *(Internal)*
- **CTRL+Shift+E** — display world physics. *(Internal)*
- **CTRL+Alt+W** — Model Preview panel. *(Internal)*
- **CTRL+L** — hide/show all gizmos (Triggers, WallConstructions, etc.) — may need to hit twice.
- **CTRL+Shift+F8** — Sound panel. *(Internal)*
- **CTRL+Shift+F9** — Pathfinding panel. *(Internal)*
- **CTRL+Shift+G** / **CTRL+G** — switch to Editor Camera / Game Camera.
- **CTRL+B** — toggle the Sidebar (properties of selected entity).
- **CTRL+Shift+P** — Party Editor (save/load party presets). *(Internal)*
- **CTRL+Shift+End** — end the current turn.
- **CTRL+Shift+Y** — open selected character's inventory. *(Internal)*
- **CTRL+Shift+M** — unlock all waypoints.
- **CTRL+Alt+Shift+V** — enable video capture mode (consecutive screenshotting). *(Internal)*
- **CTRL+C** — copy text in a message box, even when text is not selectable. *(Internal)*

## Gizmos & Movement

- **1** — Select gizmo. *(Internal)*
- **2** — Move gizmo. *(Internal)*
- **3** — Rotate gizmo. *(Internal)*
- **CTRL+Right-click** (Move gizmo active) — place a character/item at mouse pointer. *(Internal)*
- **CTRL+7 / 8 / 9** (Rotate mode) — instant 90° rotation (NumPad works too). *(Internal)*
- **[** and **]** — decrease/increase paintbrush size.
- **CTRL** / **Shift** while moving — move slower / faster in the editor.
- Right-click the **Select / Translate / Rotate / Place Item** buttons to change their settings. *(Internal)*

## Terrain Editing *(Internal)*

- **Left-click** — create elevation.
- **Right-click** — create depression.
- **Hold Enter** — create slopes.
- **Hold CTRL** — flatten.
- **Hold Shift** — smooth.

## Game Mode Surfaces *(Internal)*

- **CTRL + NumPad 1–9** — create a surface.
- **CTRL + NumPad 0** — clear all surfaces / remove surface.
- **CTRL + NumPad − / +** — decrease/increase brush size.

## ReCon — Combat & Character

- `killcombat` — kills all enemies in current combat.
- `peace on/off` — toggle peace mode.
- `god` — toggle god mode.
- `resurrect` — resurrects currently selected character. *(Internal)*
- `nocooldowns` — removes cooldowns. *(Internal)*
- `infiniteAp` — infinite AP (actions cost 0 AP). *(Internal)*
- `infiniteMemory` — gives over 9000 memory. *(Internal)*
- `think on/off` — enables/disables AI scripts for all except player. *(Internal)*
- `think <on/off>` — disables AI for all NPCs. *(Internal)*
- `setHPPercentage <percentage>` — sets selected character's HP %. *(Internal)*
- `nearlyKill` — sets selected character HP to 1. *(Internal)*
- `killArmor` — sets magic & physical armor to 0. *(Internal)*
- `charm <character/item name>` — charms selected character by the given character/item. *(Internal)*
- `setCanFight <true/false>` — toggles CanFight for selected entity (still joins combat, just no turn). *(Internal)*
- `setCanJoinCombat <true/false>` — toggles CanJoinCombat for selected entity. *(Internal)*
- `setAlignment <alignmentID>` — changes alignment of selected entity. *(Internal)*
- `statusapply <status> <duration>` — applies status for 5 turns by default; `-1` is permanent.
- `statusremove <status>` — removes a given status.

## ReCon — Progression & Inventory

- `levelup <amount>` — levels up the entire party by `<amount>`.
- `addExp <amount>` — gives selected character XP. *(Internal)*
- `maxout` — level 27, maxes out stats. *(Internal)*
- `unlockall` — unlocks all skills. *(Internal)*
- `oe 3sp` — unlocks 3 source point slots. *(Internal)*
- `oe 10u` — +10 attitude for all companions toward their avatars, all players. *(Internal)*
- `magemana` — adds max source points for this character. *(Internal)*
- `gold <amount>` — gives both players half of `<amount>` in gold. *(Internal)*
- `givetreasure <table_name>` — gives treasure from a table.
- `givetreasure CheatBooks <element>` — all skillbooks of element (e.g. CheatBooksAir, CheatBooksEarth, CheatBooksNecromancy…). *(Internal)*
- `give <objectname>` — moves an existing item (local/quest/global) into your inventory. *(Internal)*
- `create <statname>` — creates an instance of a stats object in your inventory.
- `spawnitem GLO_QA_Debug_Item` — spawns the Debug book to start in Act 2 with a party. *(Internal)*
- `autoidentify <on/off>` — identifies all magic items. *(Internal)*

## ReCon — World, Crimes & Tension

- `raiseTension` — increases in-game tension. *(Internal)*
- `ResetCrimes` — clears all crimes & records (lowers tension). *(Internal)*
- `shroud <on/off>` — fog of war on/off. *(Internal)*
- `setOffstage <name|UUID>` — removes specified character/item (raises OFFSTAGE flag). *(Internal)*

## ReCon — Navigation & Teleport

- `loadlevel <levelname>` — loads the given level. *(Internal)*
- `teleport <target>` — teleports you to a character/object/trigger in current level (e.g. `teleport CYS_Arhu`). *(Internal)*
- `teleportToMe <name>` — teleports a character to the selected character. *(Internal)*
- `goto <x> <y>` — teleports you to x y coordinates (e.g. `goto 123 567`). *(Internal)*
- `setWalkSpeedMultiplier <multiplier>` — multiplies walk/run speed (4 is nice). *(Internal)*

## ReCon — Scripting & Osiris

- `oe <command>` — sends an Osiris TextEventSet event with `<command>` as parameter. *(Internal)*
- `oe skillwin` / `oe skilllose` — force next skill check win/lose (dialog or Osiris). *(Internal)*
- `reloadScripts` — reloads Behaviour Scripts. *(Internal)*
- `reloadStory` — reloads Story. *(Internal)*
- `reloadDialogs` — reloads Scriptflags, DialogVariables, SpeakerGroups and dialog files. *(Internal)*

## ReCon — Camera, Capture & Display

- `charAmbientLight <on|off>` — ambient light for selected player's character. *(Internal)*
- `freeCamera <on|off>` — enable/disable free camera. *(Internal)*
- `usecontroller` / `usekeyboard` — switch input device. *(Internal)*
- `SetCaptureScale <amount>` — scale for screenshot/video capture (game resolution × amount). *(Internal)*
- `SetVideoCaptureFPS <amount>` — target FPS for video capture mode. *(Internal)*
- `fps <amount>` — sets client frames per second. *(Internal)*
- `show projectiles [client|server|<time>]` — debug info for projectiles. *(Internal)*
- `hide projectiles` — hides projectile debug info. *(Internal)*
- `show crimes [<index>]` — debug info for crimes (optional index for details). *(Internal)*
- `hide crimes` — hides crime debug info. *(Internal)*

## ReCon — Console Usage

- **PageUp / PageDown** — navigate previously used commands. *(Internal)*
- **Autoexecute**: create `ae.txt` in your data folder with ReCon commands, then run `ae` to execute them. *(Internal)*

## Dialog Editor *(Internal)*

- Diffing tool lets you compare two versions of a dialogue.
- **ALT + left-click** a node — select the node and all its children.
- **CTRL + left-click** — add/remove nodes from selection.
- **Home** — center view on selected node.
- **Shift + click** (diffing tool) — also selects the matching node in the other window.

## Root Templates & Template Panels

- Right-click a Root Templates icon to quickly deselect all other item types (e.g. right-click the item icon to show only items).
- **Shift / CTRL** — select multiple Root Templates to change properties in bulk. *(Internal)*
- Search panels: prefix a term with `!` to exclude results (e.g. `sword !human !dwarves`).

