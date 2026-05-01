# PowerPilot Startup Context

Last updated: 2026-05-02

## Verified build state

- Source file compiled successfully: PowerPilot_V1.0.pb
- Main build artifact verified: build\PowerPilot_V1.0.exe
- Installer assembly verified: build\PowerPilot_V1.0_Setup.exe

Latest verified artifact details:

- build\PowerPilot_V1.0.exe
  - Size: 795,648 bytes
  - Last write time: 2026-05-02 00:50:17
  - SHA-256: B859BDA53811E39E864547836AB9A8768FD72F79992686C3C1F35626CAD657AC
- build\PowerPilot_V1.0_Setup.exe
  - Size: 2,552,965 bytes
  - Last write time: 2026-05-02 00:50:19
  - SHA-256: 0D5ECFE3F084BBF9E11970C73B2142F3E7703BA107C3FAF26D13D30820054161

## Current feature notes

- Control keeps only the Maximum, Balanced, and Battery plans.
- The tray app follows Windows power mode: Best performance, Balanced, or Best power efficiency.
- Plan creation refreshes PowerPilot plans from the current non-PowerPilot Windows plan when one is selected.
- PowerPilot Balanced is tuned close to Windows Balanced: 100% max CPU, AC boost enabled, DC boost disabled, Windows-like boost response, no frequency cap, and CPU idle enabled.
- PowerPilot Maximum favors maximum performance: AC EPP 0, aggressive AC boost, 100% max CPU, no frequency cap, faster boost ramp-up, slower ramp-down, and CPU idle enabled.
- CPU information comes from CPUID inline assembly.
- GPU names come from Windows display adapter enumeration plus CPU-based iGPU resolution, without helpers.
- The executable, tray, and desktop shortcut use matching green shield icon assets; the desktop shortcut points to powerpilot_desktop.ico.

## Installer status

- Installer assembly was rebuilt successfully with build-installer.ps1.
- Latest install verification, when available, is tracked in CHAT_MEMORY\LATEST_INSTALL.md.
- This file confirms build and installer assembly status inside the project directory for quick startup reference.

## Retention defaults

- Snapshot archives kept: 8
- Chat-memory entries kept: 30

## Latest snapshot

- Archive: SNAPSHOTS\powerpilot-prebuild-2026-05-02_00-50-15.zip
- Created: 2026-05-02 00:50:15
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
