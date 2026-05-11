# PowerPilot Startup Context

Last updated: 2026-05-11

## Verified build state

- Source file compiled successfully: PowerPilot_V1.1.pb
- Main build artifact verified: .\build\PowerPilot_V1.1.2605.14550.exe
- Installer assembly verified: .\build\PowerPilot_V1.1.2605.14550_Setup.exe

Latest verified artifact details:

- .\build\PowerPilot_V1.1.2605.14550.exe
  - Size: 1,158,144 bytes
  - Last write time: 2026-05-11 02:30:29
  - SHA-256: 1E78EB87576BA2F6970CBF75614C2ECD7222087F4D43AA18F776DFE3FD5E762F
- .\build\PowerPilot_V1.1.2605.14550_Setup.exe
  - Size: 2,647,020 bytes
  - Last write time: 2026-05-11 02:30:31
  - SHA-256: E516FDDE09FC1F1288083D06DCA798A2BA15BB22C8B567A330F7F6984E1D5921

## Current feature notes

- Control keeps only the Maximum, Balanced, and Battery plans.
- The tray app follows Windows power mode: Best performance, Balanced, or Best power efficiency.
- Plan creation refreshes PowerPilot plans from the current non-PowerPilot Windows plan when one is selected.
- CPU information comes from CPUID inline assembly.
- GPU names come from Windows display adapter enumeration plus CPU-based iGPU resolution, without helpers.

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
  - before larger UI or power-plan refactors
