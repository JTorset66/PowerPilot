# PowerPilot Startup Context

Last updated: 2026-04-23

## Verified build state

- Source file compiled successfully: PowerPilot_V1.0.pb
- Main build artifact verified: build\PowerPilot_V1.0.exe
- Installer assembly verified: build\PowerPilot_V1.0_Setup.exe

Latest verified artifact details:

- build\PowerPilot_V1.0.exe
  - Size: 772,096 bytes
  - Last write time: 2026-04-23 01:11:22
  - SHA-256: 35A87382642533A8FE236FB68CA63861858148B309CCC3053BE1B9285EF71736
- build\PowerPilot_V1.0_Setup.exe
  - Size: 2,418,922 bytes
  - Last write time: 2026-04-23 01:11:29
  - SHA-256: AFF81959FF229D58CDD06EEDCD8DC63326F36EBEC93C7BC2BCBF43BAA4F471C0

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

- Archive: SNAPSHOTS\powerpilot-prebuild-2026-04-23_01-11-04.zip
- Created: 2026-04-23 01:11:04
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
