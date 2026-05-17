# PowerPilot Startup Context

Last updated: 2026-05-17

## Verified build state

- Source file compiled successfully: PowerPilot_V1.2.pb
- Main build artifact verified: .\build\PowerPilot_V1.2.2605.23851.exe
- Installer assembly verified: .\build\PowerPilot_V1.2.2605.23851_Setup.exe

Latest verified artifact details:

- .\build\PowerPilot_V1.2.2605.23851.exe
  - Size: 1,197,568 bytes
  - Last write time: 2026-05-17 13:34:49
  - SHA-256: 95F771747271BE961F7BD345E3F4B950BA9A4F8DAE21991235ABB8BED6FAFE8A
- .\build\PowerPilot_V1.2.2605.23851_Setup.exe
  - Size: 2,464,272 bytes
  - Last write time: 2026-05-17 13:34:51
  - SHA-256: 3C9D01920D4EF256985A1BE7DD61EE08AF519D4120577CA5A3CDB32C1E4F115E

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

- Archive: SNAPSHOTS\powerpilot-prebuild-2026-05-17_13-34-46.zip
- Created: 2026-05-17 13:34:46
- Source files captured: 47

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
