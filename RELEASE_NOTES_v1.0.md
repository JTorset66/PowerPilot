# PowerPilot v1.0

Initial public release of PowerPilot, a PureBasic x64 tray utility for managing local Windows power plans.

## Highlights

- Creates and manages three PowerPilot-owned plans: Maximum, Balanced, and Battery.
- Edits the three fixed PowerPilot plans directly from the Plans tab.
- Can follow Windows power mode and map it to the matching PowerPilot plan.
- Rebuilds PowerPilot-owned plans from the selected non-PowerPilot Windows plan.
- Runs from the notification area with startup-in-tray support.
- Shows local CPU identification through CPUID.
- Shows local GPU/display-adapter information through Windows display enumeration.
- Cleans up old helper files from earlier builds.
- Windows installer with desktop shortcut creation, startup setup, repair/uninstall support, and bundled README/license/notices viewer.

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

## Checksums

Use the published `.sha256` files to verify release artifacts after download.
