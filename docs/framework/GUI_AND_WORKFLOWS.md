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

The visible tab captions stay descriptive. On Windows the panel keeps native
tab behavior and only adds caption padding, avoiding style overrides that can
disturb child-control rendering.

The tab content container must stay inside PureBasic's reported panel item
area (`#PB_Panel_ItemWidth` / `#PB_Panel_ItemHeight`). Oversizing it can cover
the outer tab frame. Section frames are drawn with thin line gadgets and a
title label instead of native `FrameGadget()` or full overlay canvases. This is
intentional: native frames repaint inconsistently inside the themed tab
container, and full overlay canvases can block controls.

## Overview

Shows current active PowerPilot plan, Windows power mode, battery state, Energy Saver state, latest action, concise CPU/GPU identity, display state/brightness, battery runtime/capacity summary, PowerPilot read/log cadence, startup controls, and the Windows/Light/Dark theme selector. The bottom controls include `Hide` and `Exit`.

## Plans

The user selects one of the three managed plans and edits AC/DC processor behavior. `Save plan` writes the plan to Windows, and `Defaults` restores the selected plan's default values. The plan list keeps Plan and Installed narrow and gives Purpose the remaining width so the descriptions are readable at normal window scale.

## Battery Saver

Centralizes Windows Energy Saver, low/reserve/critical battery thresholds, low/critical battery actions, background throttling, deep idle saver, and normal-plan restore-on-exit. Reserve is a Windows warning level only; actions happen at Low and Critical. These settings are written to PowerPilot-owned plans while the app runs; on app exit PowerPilot can switch back to the last normal Windows plan it saw.

## Battery Graph

Shows a retained battery history graph with selectable 1-, 3-, 6-, 12-, 18-, 24-, 36-, 48-, 60-, and 72-hour time windows, plus Max for the retained 168-hour log window. Drawing uses an offscreen image buffer and blits once to the canvas to avoid flicker.

Graph markers use compact letters: `Z` sleep/suspend, `H` hibernate, `W` wake, `S` shutdown, `P` startup, `!` improper shutdown, `0` offline, `1` online, `E` Energy Saver, and `N` normal. Power/offline markers have priority over Energy Saver/normal markers. Crowded marker letters stack above their vertical line as white letters with black shadows.

## PowerPilot Log

Shows retained CSV rows with configurable visible columns. Copy buttons export visible rows or full CSV data. Column widths are saved.

## Battery Stats

Shows latest event, today's battery summary, sleep/off loss summary, visible column controls, retained-log Battery Analysis with last-run/source/interval details and a local stats-helper note, a Refresh analysis button, and export/import settings controls.

## Power Use

Estimates app battery cost from process CPU time normalized to total logical CPU capacity over a 60-second live window plus a user-selected average window. It is an estimate, not a hardware power meter.

## Battery Test

Battery Test has four areas:

- Workflow: explains the three choices, shows mode/phase/elapsed time, and holds the workflow buttons.
- Live Windows Readings: battery percent, remaining mWh, watts, estimate, and the next expected user action.
- Report and Log: explains that BATTERY TEST log rows are written, exposes report buttons, and shows a short on-screen summary.
- Calibration Drain Helper: explains that Auto uses local CPU load during calibration/test workflows, shows the target time, auto control, telemetry mode, and live load state.

### Manual Discharge Test

1. User clicks `Manual test`.
2. PowerPilot starts a test log and prompts through guide text.
3. User unplugs to discharge.
4. User plugs in again to track charge recovery.
5. User clicks `End` to freeze the summary.

### Vendor Calibration Detected

When Windows reports plugged in and discharging, PowerPilot identifies vendor calibration-like behavior. It starts monitoring automatically if no other test is active.

### Battery Calibration

The `Calibration` button starts a guided workflow for laptop battery calibration runs where firmware exposes plugged-in discharge through Windows.

Rules:

1. If the PC is unplugged, PowerPilot waits for the charger.
2. The drain target uses the saved `Target min` setting.
3. When Windows reports plugged in and discharging, PowerPilot starts auto drain helper.
4. When charging starts, PowerPilot stops auto drain and CPU load.
5. When the PC is plugged in, not discharging, and not charging after charge recovery, the test completes.
6. PowerPilot writes a complete report to `%APPDATA%\PowerPilot\reports`.
7. `Open report` opens the latest saved `.txt` report through Windows' default file handler.

### Calibration Drain Helper

`Target min` is saved as `BatteryCalibrationDrainMinutes`. Typed values are read from the spin text before Auto starts. If Auto is already active and the target changes, the helper resets its end time and controller state to the new target. `Auto` starts PI-style load control for the selected target time. `Test mode` writes detailed controller telemetry rows to the log for tuning runs.

### Report Buttons

- `Open report` opens the newest saved Battery Test report.
- `Copy report` copies the full report text to the clipboard. The visible report panel shows a shorter screen summary to avoid clipped report text.

## About

About explains local data, privacy boundary, bundled manual/readme/license docs, and what PowerPilot cannot measure directly.
