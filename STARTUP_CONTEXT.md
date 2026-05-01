# PowerPilot Startup Context

Last updated: 2026-05-02

## Verified build state

- Source file compiled successfully: PowerPilot_V1.0.pb
- Main build artifact verified: build\PowerPilot_V1.0.exe
- Installer assembly verified: build\PowerPilot_V1.0_Setup.exe

Latest verified artifact details:

- build\PowerPilot_V1.0.exe
  - Size: 795,648 bytes
  - Last write time: 2026-05-02 00:59:40
  - SHA-256: 7A33626AE9921C86BC54C90D2AE358A75EECC43C23006B4B66CC0BCC84A28280
- build\PowerPilot_V1.0_Setup.exe
  - Size: 2,553,337 bytes
  - Last write time: 2026-05-02 00:59:42
  - SHA-256: 90896D7B9D2541F3DD7635C30861DAEB8264B1DE5C5BDB11F4B566FB442D67AF

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

- Archive: SNAPSHOTS\powerpilot-prebuild-2026-05-02_00-59-38.zip
- Created: 2026-05-02 00:59:38
- Source files captured: 30

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
