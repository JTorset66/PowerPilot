# PowerPilot Startup Context

Last updated: 2026-05-03

## Verified build state

- Source file compiled successfully: PowerPilot_V1.1.pb
- Main build artifact verified: .\build\PowerPilot_V1.1.2605.03093.exe
- Installer assembly verified: .\build\PowerPilot_V1.1.2605.03093_Setup.exe

Latest verified artifact details:

- .\build\PowerPilot_V1.1.2605.03093.exe
  - Size: 957,952 bytes
  - Last write time: 2026-05-03 03:33:14
  - SHA-256: 1F89A54C362B12A7B1DCC31F9065B06407DCBBFFE7D4D7B7FF56E70B5168257D
- .\build\PowerPilot_V1.1.2605.03093_Setup.exe
  - Size: 2,602,469 bytes
  - Last write time: 2026-05-03 03:33:18
  - SHA-256: DBB461948AE63526D2C6C44CA111773D850D70F92ECF9DB20C18D1884D468EF1

## Current feature notes

- Control keeps only the Maximum, Balanced, and Battery plans.
- The tray app follows Windows power mode: Best performance, Balanced, or Best power efficiency.
- Plan creation refreshes PowerPilot plans from the current non-PowerPilot Windows plan when one is selected.
- Battery Graph shows average, instant, Windows, wear, max capacity, cycle count, and Max avg estimates.
- PowerPilot Log records retained battery samples, app lifecycle rows, and PC power-event rows.
- Battery Stats summarizes the session, daily drain, off-time battery loss, and configurable log-column widths.
- Estimate math uses the configured minimum battery floor and effective maximum ceiling.
- PowerPilot-managed DC critical battery level follows the configured minimum percent and sleeps at that floor.

## Installer status

- Installer assembly was rebuilt successfully with build-installer.ps1.
- PowerPilot v1.1 was released from commit 33968a2 and tag v1.1.
- GitHub release: https://github.com/JTorset66/PowerPilot/releases/tag/v1.1
- Latest install verification, when available, is tracked in CHAT_MEMORY\LATEST_INSTALL.md.
- This file confirms build and installer assembly status inside the project directory for quick startup reference.

## Retention defaults

- Snapshot archives kept: 8
- Chat-memory entries kept: 30

## Latest snapshot

- Archive: SNAPSHOTS\powerpilot-release-v1.1-2026-05-03_03-43-06.zip
- Created: 2026-05-03 03:43:06
- Captured from tag: v1.1
- Tracked files captured: 67
- SHA-256: FB75C367E197B92FC3A89BF228D8E1737CDCDCFF32B57ABDE34138D14D0BE59C

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
