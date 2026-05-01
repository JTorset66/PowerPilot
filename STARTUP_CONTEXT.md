# PowerPilot Startup Context

Last updated: 2026-05-01

## Verified build state

- Source file compiled successfully: PowerPilot_V1.0.pb
- Main build artifact verified: build\PowerPilot_V1.0.exe
- Installer assembly verified: build\PowerPilot_V1.0_Setup.exe

Latest verified artifact details:

- build\PowerPilot_V1.0.exe
  - Size: 793,088 bytes
  - Last write time: 2026-05-01 17:16:14
  - SHA-256: 97747E50A4CC561836AF333F3CD53576085A935DA9F118F47CAB97DEEAF288CB
- build\PowerPilot_V1.0_Setup.exe
  - Size: 2,558,579 bytes
  - Last write time: 2026-05-01 17:16:18
  - SHA-256: 92C4BBBC034DA212E755E2FFBCB7179A1A8B049DCFDC64C1A1CF31C5E962C96D

## Current feature notes

- Project language is PureBasic, not PowerBasic.
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
