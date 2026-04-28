# PowerPilot Startup Context

Last updated: 2026-04-28

## Verified build state

- Source file compiled successfully: PowerPilot_V1.0.pb
- Main build artifact verified: build\PowerPilot_V1.0.exe
- Installer assembly verified: build\PowerPilot_V1.0_Setup.exe

Latest verified artifact details:

- build\PowerPilot_V1.0.exe
  - Size: 773,632 bytes
  - Last write time: 2026-04-28 17:19:38
  - SHA-256: C85FDD675CCBF3BC26EA7EBA495780D41264242C562BA10F2AEF6E3DF4CCB083
- build\PowerPilot_V1.0_Setup.exe
  - Size: 2,419,064 bytes
  - Last write time: 2026-04-28 17:19:49
  - SHA-256: 735B6B1E00A647AFA735A1675C5A79C5CA5BDA0E581469D6A0757E1B48409933

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

- Snapshot was skipped for this run.

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
