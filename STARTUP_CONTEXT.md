# PowerPilot Startup Context

Last updated: 2026-04-29

## Verified build state

- Source file compiled successfully: PowerPilot_V1.0.pb
- Main build artifact verified: build\PowerPilot_V1.0.exe
- Installer assembly verified: build\PowerPilot_V1.0_Setup.exe

Latest verified artifact details:

- build\PowerPilot_V1.0.exe
  - Size: 753,152 bytes
  - Last write time: 2026-04-29 00:00:02
  - SHA-256: DBAB635EA89FC44E1821B11CE7A66D38142442E00502760400AE5A4191234A1E
- build\PowerPilot_V1.0_Setup.exe
  - Size: 2,416,467 bytes
  - Last write time: 2026-04-29 00:00:11
  - SHA-256: 3A55E4BAB3E8B1D2F5240CE5DA4131F70AFA66026CB0BEC94FB253A949B14982

## Current feature notes

- Control documents Auto Cool as CPU-package-power control for active Cool plans and temperature-only entry from Full Power.
- Battery guidance now reminds users to set Windows Power mode to Balanced or Best performance so Auto Cool is not capped by Best power efficiency.
- Manual Override includes a Reset Display action that sends the Windows graphics reset hotkey.
- Graphics power and graphics workload readings are no longer used for Auto Cool decisions.
- The GPU helper is retained only for GPU names and VRAM display.

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
