# GUI And Workflows

PowerPilot uses one fixed-size tabbed PureBasic window. Gadgets are declared in the main enumeration and created in `CreateMainWindow()`. Event dispatch is centralized in `HandleAction()`.

## Tab Order

1. Overview
2. Plans
3. Battery Saver
4. PowerPilot Log
5. Battery Graph
6. Battery Stats
7. Power Use
8. Battery Test
9. About

## Overview

Shows current active PowerPilot plan, Windows power mode, battery state, Energy Saver state, latest action, concise CPU/GPU identity, battery runtime/capacity summary, PowerPilot read/log cadence, and startup controls. The bottom controls include `Hide` and `Exit`.

## Plans

The user selects one of the three managed plans and edits AC/DC processor behavior. `Save plan` writes the plan to Windows, and `Defaults` restores the selected plan's default values. The plan list keeps Plan and Installed narrow and gives Purpose the remaining width so the descriptions are readable at normal window scale.

## Battery Saver

Centralizes Windows Energy Saver, low/reserve/critical battery thresholds, low/critical battery actions, background throttling, deep idle saver, and normal-plan restore-on-exit. Reserve is a Windows warning level only; actions happen at Low and Critical. These settings are written to PowerPilot-owned plans while the app runs; on app exit PowerPilot can switch back to the last normal Windows plan it saw.

## Battery Graph

Shows a retained battery history graph with selectable time windows from 6 to 72 hours. Drawing uses an offscreen image buffer and blits once to the canvas to avoid flicker.

Graph markers use compact letters: `Z` sleep/suspend, `H` hibernate, `W` wake, `S` shutdown, `P` startup, `!` improper shutdown, `0` offline, `1` online, `E` Energy Saver, and `N` normal. Power/offline markers have priority over Energy Saver/normal markers. Crowded marker letters stack above their vertical line as white letters with black shadows.

## PowerPilot Log

Shows retained CSV rows with configurable visible columns. Copy buttons export visible rows or full CSV data. Column widths are saved.

## Battery Stats

Shows latest event, today's battery summary, sleep/off loss summary, visible column controls, retained-log Battery Analysis with last-run/source/interval details and a local stats-helper note, a Refresh analysis button, and export/import settings controls.

## Power Use

Estimates app battery cost from process CPU time normalized to total logical CPU capacity over a 60-second window. It is an estimate, not a hardware power meter.

## Battery Test

Battery Test has four areas:

- Test Status: mode, phase, elapsed time, and workflow buttons.
- Live Stats: battery percent, remaining mWh, watts, and estimate.
- Report: saved/copyable report text and report buttons.
- Drain Load: drain-helper target time, auto control, test-mode telemetry, and live load state.

### Manual Discharge Test

1. User clicks `Manual`.
2. PowerPilot starts a test log and prompts through guide text.
3. User unplugs to discharge.
4. User plugs in again to track charge recovery.
5. User clicks `End` to freeze the summary.

### Vendor Calibration Detected

When Windows reports plugged in and discharging, PowerPilot identifies vendor calibration-like behavior. It starts monitoring automatically if no other test is active.

### Lenovo Calibration Reset

The `Lenovo reset` button starts a guided workflow built for Lenovo battery calibration reset.

Rules:

1. If the PC is unplugged, PowerPilot waits for the charger.
2. The drain target uses the saved `Target` setting.
3. When Windows reports plugged in and discharging, PowerPilot starts auto drain helper.
4. When charging starts, PowerPilot stops auto drain and CPU load.
5. When the PC is plugged in, not discharging, and not charging after charge recovery, the test completes.
6. PowerPilot writes a complete report to `%APPDATA%\PowerPilot\reports`.
7. `Open report` opens the latest saved `.txt` report through Windows' default file handler.

### Drain Load Panel

`Target` is saved as `BatteryCalibrationDrainMinutes`. `Auto` starts PI-style load control for the selected target time. `Test mode` writes detailed controller telemetry rows to the log for normal unplug tuning runs.

### Report Buttons

- `Open report` opens the newest saved Battery Test report.
- `Copy report` copies the current report text to the clipboard.

## About

About explains local data, privacy boundary, bundled license/readme docs, and what PowerPilot cannot measure directly.
