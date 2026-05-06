# Verification Checklist

Use this checklist before releasing or installing a new PowerPilot build.

## Logic Checks

- Settings load defaults first, then overlay saved values.
- New settings are added to `AppSettings`, `LoadSettings()`, `SaveSettings()`, clamp logic, `ApplySettingsToGui()`, and event handling.
- New gadgets are added to the gadget enumeration before use.
- Tooltips are added and cleared for every new visible control.
- Battery Test modes do not overlap: manual, vendor detected, Lenovo reset, charge recovery, complete, and monitor.
- Lenovo reset does not complete until plugged-in discharge, charging, and final idle have all been observed.
- Auto drain stops on charging and does not stop only because load falls to zero.
- CPU load threads are stopped on manual end, app exit, update close, and charge recovery.
- Report files are created only in `%APPDATA%\PowerPilot\reports`.
- `Open report` handles missing reports gracefully.

## GUI Checks

- Text fits at normal Windows scaling.
- Button labels are short enough for their fixed widths.
- Dynamic values do not resize layout.
- Battery Test status and report areas do not overlap.
- The graph does not flicker when refreshed.
- Hidden tabs do not redraw heavy canvases unnecessarily.

## Build Checks

Run:

```powershell
.\build-purebasic.ps1
```

Expected result:

- Exit code 0.
- Versioned EXE exists in `build\`.

Run:

```powershell
.\build-installer.ps1
```

Expected result:

- Exit code 0.
- Versioned setup EXE exists in `build\`.
- `powerpilot.iss` version fields match `#AppVersion$`.
- Pre-build snapshot exists.

## Install Checks

Run:

```powershell
.\install-powerpilot.ps1
```

Expected result:

- Installer exit code 0.
- PowerPilot is running after install.
- No installer or cleanup process remains.
- Installed app folder contains EXE, icons, README, license, and notices.

## Battery Test Checks

Manual test:

- `Manual` starts a test.
- Guide prompts unplug.
- Charging changes mode to charge recovery.
- `End` freezes summary.
- `Copy report` copies text.

Lenovo reset:

- `Lenovo reset` starts mode.
- If unplugged, guide waits for charger.
- Plugged-in discharging starts auto drain.
- Charging stops auto drain.
- Plugged-in idle after charging completes the test.
- A `.txt` report is saved under `%APPDATA%\PowerPilot\reports`.
- `Open report` opens the latest report.

Drain helper test mode:

- `Test mode` writes controller tick rows during auto drain.
- Rows include load, watts, current minutes, target minutes, error, integral, and usable mWh.

## Release Checks

- Update release notes and GitHub release changelog.
- Keep framework docs aligned with changed behavior.
- Do not include unrelated local logs or user-specific report data in release commits.
