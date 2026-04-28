# PowerPilot Startup Context

Last updated: 2026-04-28

## Verified build state

- Source file compiled successfully: PowerPilot_V1.0.pb
- Main build artifact verified: build\PowerPilot_V1.0.exe
- Installer assembly verified: build\PowerPilot_V1.0_Setup.exe

Latest verified artifact details:

- build\PowerPilot_V1.0.exe
  - Size: 776,192 bytes
  - Last write time: 2026-04-28 17:47:29
  - SHA-256: AE8D4D878E44932F12996E83D2A8370F7E62020082A6779F38E02DFA933B8CDF
- build\PowerPilot_V1.0_Setup.exe
  - Size: 2,419,590 bytes
  - Last write time: 2026-04-28 17:47:35
  - SHA-256: A34546179750CD538F31423C405A9A6735BB23EB21D87E082FE3B865EAA039DB

## Current feature notes

- Control now includes a saved Cool avg (sec) setting for the Auto Cool averaging window.
- Manual Override includes a Reset Display action that sends the Windows graphics reset hotkey.
- Automatic Cool plans now arm from sustained GPU load instead of game-specific wording.
- Power switching now returns to Battery Saver or Full Power when the GPU load trigger is inactive.

## Installer status

- Installer assembly was rebuilt successfully with build-installer.ps1.
- Latest install verification, when available, is tracked in CHAT_MEMORY\LATEST_INSTALL.md.
- This file confirms build and installer assembly status inside the project directory for quick startup reference.

## Retention defaults

- Snapshot archives kept: 8
- Chat-memory entries kept: 30

## Latest snapshot

- Archive: SNAPSHOTS\powerpilot-prebuild-2026-04-28_17-47-15.zip
- Created: 2026-04-28 17:47:15
- Source files captured: 728

## Where to look first on a new startup

1. README.md
2. STARTUP_CONTEXT.md
3. CHAT_MEMORY\CURRENT_CONTEXT.md
4. CHAT_MEMORY\LATEST_BUILD.md
5. CHAT_MEMORY\LATEST_INSTALL.md
6. CHAT_MEMORY\INDEX.md

## Working habit reminder

- Take regular snapshots or commits.
- Good times to snapshot:
  - before changing power-plan logic
  - before rebuilding the installer
  - before running elevated install or uninstall steps
  - before larger UI or telemetry refactors
