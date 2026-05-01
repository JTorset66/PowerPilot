# PowerPilot v1.0

Initial public release of PowerPilot, a PureBasic x64 tray utility for managing local Windows power plans.

## Highlights

- Creates and manages three PowerPilot-owned plans: Maximum, Balanced, and Battery.
- Edits the three fixed PowerPilot plans directly from the Plans tab.
- Can follow Windows power mode and map it to the matching PowerPilot plan.
- Rebuilds PowerPilot-owned plans from the selected non-PowerPilot Windows plan.
- Uses a Windows-Balanced-like `PowerPilot Balanced` profile with 100% CPU max state, Windows-style boost response, and CPU idle enabled.
- Uses a more aggressive `PowerPilot Maximum` profile with AC energy preference `0`, aggressive boost, faster boost ramp-up, slower ramp-down, no CPU cap, and CPU idle enabled.
- Runs from the notification area with startup-in-tray support.
- Shows local CPU identification through CPUID.
- Shows local GPU/display-adapter information through Windows display enumeration.
- Cleans up old helper files from earlier builds.
- Windows installer with green desktop/tray icon assets, desktop shortcut creation, startup setup, repair/uninstall support, and bundled README/license/notices viewer.

## Build and platform

- Platform: Windows x64
- Source: PureBasic project
- Build helper included: `build-purebasic.ps1`
- Installer helper included: `build-installer.ps1`

## Notes

- This is the first public release of the project.
- Release binaries may be unsigned until trusted code-signing onboarding is complete.
- PowerPilot does not include helper executables, live temperature telemetry, package-power telemetry, fan-speed telemetry, Auto Control, or live GPU telemetry.

## Included assets

- `PowerPilot_V1.0.exe`
- `PowerPilot_V1.0.exe.sha256`
- `PowerPilot_V1.0_Setup.exe`
- `PowerPilot_V1.0_Setup.exe.sha256`
- green shield icon assets for the executable, desktop shortcut, and tray icon

## Checksums

Use the published `.sha256` files to verify release artifacts after download.
