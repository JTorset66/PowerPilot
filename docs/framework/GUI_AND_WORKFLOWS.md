# GUI And Workflows

PowerPilot uses one fixed-size tabbed PureBasic window. Gadgets are declared in the main enumeration and created in `CreateMainWindow()`. Event dispatch is centralized in `HandleAction()`.

## Tab Order

1. Overview
2. Plans
3. Battery Graph
4. PowerPilot Log
5. Battery Stats
6. Power Use
7. Battery Test
8. About

## Overview

Shows current active PowerPilot plan, Windows power mode, CPU/GPU identity, and current actions. The bottom controls include `Hide` and `Exit`.

## Plans

The user selects one of the three managed plans and edits AC/DC processor behavior. `Save plan` writes the plan to Windows, and `Defaults` restores the selected plan's default values.

## Battery Graph

Shows a retained battery history graph with selectable time windows from 6 to 72 hours. Drawing uses an offscreen image buffer and blits once to the canvas to avoid flicker.

Graph markers use compact letters: `Z` sleep/suspend, `H` hibernate, `W` wake, `S` shutdown, `P` startup, `!` improper shutdown, `O` offline or missing samples, `E` Energy Saver, and `N` normal. Power/offline markers have priority over Energy Saver/normal markers. Labels reserve occupied rectangles before drawing; if a low-priority `E`/`N` label cannot fit, its transition marker is skipped too. Wider windows use stricter density rules so 36- to 72-hour views remain readable.

## PowerPilot Log

Shows retained CSV rows with configurable visible columns. Copy buttons export visible rows or full CSV data. Column widths are saved.

## Battery Stats

Shows session summary, daily battery summary, off-time loss summary, visible column controls, and settings backup controls.

## Power Use

Estimates PowerPilot's own battery cost from process CPU time over a 60-second window. It is an estimate, not a hardware power meter.

## Battery Test

Battery Test has four areas:

- Test Log: mode, phase, elapsed time, and workflow buttons.
- Live Test Stats: battery percent, remaining mWh, watts, and estimate.
- Test Report: saved/copyable report text and report buttons.
- CPU Load: drain-helper target time, auto control, test-mode telemetry, and live load state.

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
2. The drain target uses the saved `Drain in` setting.
3. When Windows reports plugged in and discharging, PowerPilot starts auto drain helper.
4. When charging starts, PowerPilot stops auto drain and CPU load.
5. When the PC is plugged in, not discharging, and not charging after charge recovery, the test completes.
6. PowerPilot writes a complete report to `%APPDATA%\PowerPilot\reports`.
7. `Open report` opens the latest saved `.txt` report through Windows' default file handler.

### CPU Load Panel

`Drain in` is saved as `BatteryCalibrationDrainMinutes`. `Auto target` starts PI-style load control for the selected target time. `Test mode` writes detailed controller telemetry rows to the log for normal unplug tuning runs.

### Report Buttons

- `Open report` opens the newest saved Battery Test report.
- `Copy report` copies the current report text to the clipboard.

## About

About explains local data, privacy boundary, bundled license/readme docs, and what PowerPilot cannot measure directly.
