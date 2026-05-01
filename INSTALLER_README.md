# PowerPilot User README

PowerPilot is a Windows x64 tray utility for managing three local Windows power plans:

- `PowerPilot Maximum`
- `PowerPilot Balanced`
- `PowerPilot Battery`

It creates or refreshes those plans from the currently selected Windows power plan, then applies PowerPilot's CPU behavior settings on top.

## Main Functions

- Start with Windows and run from the notification area.
- Edit the fixed Maximum, Balanced, and Battery plan settings from the Plans tab.
- Follow Windows power mode automatically:
  - Best performance -> PowerPilot Maximum
  - Balanced -> PowerPilot Balanced
  - Best power efficiency -> PowerPilot Battery
- Recreate PowerPilot-owned plans from the current non-PowerPilot Windows plan.
- Show local CPU identification from CPUID.
- Show local display-adapter names, vendor IDs, device IDs, and active/primary flags.
- Remove PowerPilot-owned plans during uninstall.

## Default Plan Behavior

- `PowerPilot Maximum` favors maximum possible plugged-in performance: AC energy preference `0`, aggressive AC boost, 100% max CPU, no frequency cap, active cooling, faster boost ramp-up, slower ramp-down, and CPU idle still enabled.
- `PowerPilot Balanced` stays close to Windows Balanced: AC/DC energy preference `33/50`, AC boost enabled, DC boost disabled, 100% max CPU on AC and battery, no frequency cap, active AC cooling, passive DC cooling, Windows-like boost policy and ramp thresholds, and CPU idle enabled.
- `PowerPilot Battery` favors battery life with disabled boost, lower max CPU, MHz caps, passive cooling, deeper core parking when deep idle saver is enabled, and CPU idle enabled.

## Basic Use

1. Install PowerPilot.
2. Let setup create or refresh the PowerPilot-owned plans.
3. Open PowerPilot from the tray icon or desktop shortcut.
4. Use the Plans tab to edit the fixed Maximum, Balanced, and Battery plan settings.
5. Click `Save` to apply the selected plan's edited settings to Windows.
6. Leave PowerPilot running in the tray if you want it to follow Windows power mode.

PowerPilot does not expose manual plan activation in the UI. Windows power mode chooses which of the three fixed plans should be active while PowerPilot is running.

## Installer Behavior

The installer:

- installs PowerPilot into `Program Files\PowerPilot`
- creates a desktop shortcut using the green shield `powerpilot_desktop.ico`
- enables startup for the current user using `/tray`
- closes a running PowerPilot process before install, repair, reinstall, or uninstall file operations
- removes old helper files from earlier builds
- removes and recreates only PowerPilot-owned plans during install
- offers repair and uninstall from Windows Apps/Programs maintenance

The uninstaller removes installed files, the startup entry, PowerPilot-owned plans, and legacy prototype `Codex *` plans.

## Privacy

PowerPilot does not transfer information to networked systems unless specifically requested by the user or the person installing or operating it.

Hardware information is read locally from CPUID and Windows display-adapter enumeration. PowerPilot changes only local Windows power plans and the Windows startup entry used for tray launch.

## Notes

- PowerPilot no longer uses helper executables, temperature telemetry, package-power telemetry, fan-speed telemetry, Auto Control, or live GPU telemetry.
- PowerPilot manages only the plans it owns.
- Windows power plan behavior can vary by device firmware, drivers, and Windows power settings.
