# Application Framework

## Purpose

PowerPilot is a local Windows tray application written in PureBasic. It manages three PowerPilot-owned Windows power plans, follows Windows power mode, records battery and power events, displays battery graphs and stats, estimates PowerPilot's own battery cost, and guides battery tests including Lenovo calibration reset monitoring.

PowerPilot is not a firmware controller. It observes Windows battery telemetry and can create local CPU load for test assistance, but it does not command Lenovo firmware calibration directly.

## Source Layout

Primary source file:

- `PowerPilot_V1.1.pb`

Support files:

- `build-purebasic.ps1` builds the versioned executable.
- `build-installer.ps1` builds the installer, creates a pre-build snapshot, updates Inno Setup version fields, and refreshes build context files.
- `install-powerpilot.ps1` runs the latest setup executable and verifies the installed app.
- `powerpilot.iss` is the Inno Setup script.
- `powerpilot.ico`, `powerpilot_desktop.ico`, and `powerpilot_tray.ico` are runtime and installer icon assets.
- `INSTALLER_README.md`, `THIRD_PARTY_NOTICES.md`, and `LICENSE` are bundled into the installer as text files.

## Runtime Data

Per-user data lives below:

```text
%APPDATA%\PowerPilot
```

Important files and folders:

- `settings.ini` - user settings and edited plan values.
- `battery-log.csv` - retained battery, event, app, screen, energy saver, and battery-test rows.
- `reports\*.txt` - saved Battery Test reports, including Lenovo calibration reset reports.

The installer requires administrator approval for installation into Program Files. Every installed EXE invocation after files are copied, including post-install refresh, cleanup, startup registration, and tray launch, is designed to run as the original ordinary user. Settings and reports are intentionally per-user.

## Main Runtime Model

Startup sequence:

1. Load settings with defaults, then overlay `settings.ini`.
2. Load or create the fixed PowerPilot plans.
3. Register power notifications.
4. Create the main tabbed window and tray icon.
5. Refresh Windows power mode, active plan, battery telemetry, battery graph, log preview, and summaries.
6. Hide to tray when started in tray mode.

Main loops:

- A visible window refreshes more often than tray mode.
- Battery Test tab uses a faster one-second battery read cadence only while selected.
- Hidden or tray mode slows refresh to reduce background wakeups.
- Windows power broadcast messages force immediate battery and event refreshes.

## Ownership Boundaries

PowerPilot owns:

- Three managed plans: `PowerPilot Maximum`, `PowerPilot Balanced`, and `PowerPilot Battery`.
- Its settings file.
- Its retained CSV log.
- Its battery test report folder.
- Its tray icon, desktop shortcut, and bundled docs.

PowerPilot does not own:

- Arbitrary user-created Windows power plans.
- Lenovo firmware calibration state.
- Windows or firmware time-to-full estimates when they are not reported.
- System-wide TDP or vendor-specific power limits.
