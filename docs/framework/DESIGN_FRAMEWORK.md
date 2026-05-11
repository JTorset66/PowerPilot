# PowerPilot Design Framework

This document describes the intended design of PowerPilot independently from the current source layout. The current program grew feature by feature, so the existing implementation is useful and working, but a future rebuild should organize the same behavior around clearer boundaries.

Use this as the design guide before changing large flows or rebuilding the app from scratch.

## Design Intent

PowerPilot should feel like a quiet Windows utility, not a large dashboard. It should stay local, understandable, and predictable:

- Follow Windows power mode with three PowerPilot-owned plans.
- Show the current power and battery state without hiding important uncertainty.
- Record enough local history to explain battery behavior later.
- Provide guided battery tests without pretending to control vendor firmware.
- Stay safe in the tray with low background activity.
- Keep settings per user and preserve user choices after first install.

The application should be designed around workflows, not around which API produced each value.

## Current Design Reality

The current implementation is mostly contained in one PureBasic source file:

```text
PowerPilot_V1.1.pb
```

That file currently owns:

- Constants, structures, globals, and declarations.
- Settings load/save and migration.
- Power-plan creation and application.
- Battery telemetry.
- CSV log retention.
- Battery graph drawing.
- Battery stats.
- Power-use estimate.
- Battery Test and Lenovo reset workflow.
- GUI construction.
- Tray behavior.
- Windows message callback.

This has been practical while the app was evolving quickly. The downside is that unrelated concepts now sit close together, and future changes can accidentally couple UI layout, battery logic, settings, and installer assumptions.

The current source should be treated as the reference behavior, not as the ideal architecture.

## Target Architecture

A clean rebuild should organize PowerPilot into these logical layers.

## Layer 1: Platform Adapters

Platform adapters talk to Windows and vendor-visible system surfaces. They should not own app decisions.

Responsibilities:

- Read Windows power mode overlay.
- Read active power plan.
- Run `powercfg`.
- Read battery telemetry.
- Read static battery capacity and cycle data.
- Read screen state and brightness when available.
- Register Windows power/session notifications.
- Create tray icon and tray menu.
- Open files through Windows shell.
- Read/write startup registry value.

Suggested module names:

- `platform_power.pb`
- `platform_battery.pb`
- `platform_display.pb`
- `platform_tray.pb`
- `platform_shell.pb`

Rule: platform adapters return facts or operation results. They do not decide which PowerPilot plan to use, when a test is complete, or what the UI should say.

## Layer 2: Domain Models

Domain models describe the app's own concepts.

Core models:

- `AppSettings`
- `ManagedPlan`
- `BatteryTelemetry`
- `BatteryLogRow`
- `BatteryGraphPoint`
- `BatteryTestSession`
- `DrainHelperState`
- `PowerUseSample`

These models should be plain data with clear units:

- Time: seconds or date timestamps.
- Energy: mWh.
- Power: mW for raw telemetry, W for user-facing summaries.
- Percent: 0 to 100.
- CPU load target: 0 to 100.

Rule: a field name should make its unit obvious. Avoid mixing mW and W in one field family.

## Layer 3: Services

Services own decisions and state transitions. They depend on platform adapters, but the UI should call services instead of directly calling Windows APIs.

Suggested services:

- `SettingsService`
- `PlanService`
- `BatteryTelemetryService`
- `BatteryLogService`
- `BatteryEstimateService`
- `BatteryGraphService`
- `BatteryStatsService`
- `PowerUseService`
- `BatteryTestService`
- `DrainHelperService`
- `ReportService`
- `TrayService`

Service responsibilities:

- Clamp settings.
- Migrate old settings.
- Map Windows power mode to PowerPilot plans.
- Decide whether a log row should be written.
- Calculate battery estimates.
- Manage Battery Test state.
- Manage Lenovo reset state.
- Produce reports.
- Decide timer cadence.

Rule: services may update models and write logs. UI code should only display service state and send user actions.

## Layer 4: UI

The UI should be a thin fixed-window shell:

- Create tabs and gadgets.
- Apply settings to controls.
- Read user actions.
- Call services.
- Refresh visible text and graphs.

The UI should not own algorithm state. For example, the Battery Test tab can show `Lenovo reset`, but `BatteryTestService` should decide whether Lenovo reset is waiting, discharging, charging, complete, or ended early.

## Recommended Program Flow

A cleaner PowerPilot should use this flow:

1. `AppStart`
2. Load settings defaults.
3. Overlay saved settings.
4. Migrate settings.
5. Initialize platform adapters.
6. Initialize services from settings.
7. Create GUI and tray.
8. Read initial platform state.
9. Refresh service state.
10. Render current UI.
11. Enter event loop.

The event loop should process four kinds of events:

- User action: button, checkbox, spin, tab change, tray menu.
- Timer tick: regular refresh cadence.
- Windows event: power, display, suspend, resume, shutdown.
- Installer/update event: app replacement close.

Every event should follow the same route:

```text
event -> service update -> log/report/settings side effect -> UI refresh
```

This makes it easier to test logic without running the GUI.

## Workflow State Machines

Battery workflows should be explicit state machines.

## Manual Battery Test

States:

- `Idle`
- `ManualStarted`
- `Discharging`
- `ChargeRecovery`
- `Complete`
- `EndedEarly`

Transitions:

- User starts manual test: `Idle -> ManualStarted`
- Windows reports unplugged discharging: `ManualStarted -> Discharging`
- Windows reports charging: `Discharging -> ChargeRecovery`
- User ends test: any active state -> `Complete` or `EndedEarly`

## Vendor Calibration Monitor

States:

- `Idle`
- `VendorPluggedDischarge`
- `ChargeRecovery`
- `IdleAfterCharge`

Transitions:

- Windows reports plugged in and discharging: `Idle -> VendorPluggedDischarge`
- Windows reports charging: `VendorPluggedDischarge -> ChargeRecovery`
- Windows reports plugged in, not charging, not discharging: `ChargeRecovery -> IdleAfterCharge`

This workflow can monitor automatically, but it should not generate a final vendor-specific report unless the user started a guided workflow.

## Lenovo Calibration Reset

States:

- `WaitingForCharger`
- `WaitingForPluggedDischarge`
- `PluggedDischarge`
- `ChargeRecovery`
- `Complete`
- `EndedEarly`

Transitions:

- User selects Lenovo reset while unplugged: `WaitingForCharger`
- Charger is plugged in but no discharge yet: `WaitingForPluggedDischarge`
- Windows reports plugged in and discharging: `PluggedDischarge`
- Auto drain starts from saved target.
- Windows reports charging: `ChargeRecovery`
- Auto drain stops.
- Windows reports plugged in, not charging, not discharging after charge recovery: `Complete`
- Report is saved.

Important design rule:

The Lenovo reset measurement baseline should start at `PluggedDischarge`, not at `WaitingForCharger`, so waiting time does not distort used mWh or average discharge watts.

## Drain Helper Control Design

The drain helper should be its own service with one job: apply bounded local CPU load to target a desired discharge duration.

Inputs:

- Current battery telemetry.
- Usable mWh above configured empty floor.
- Saved target minutes.
- Current CPU load target.
- Whether charging has started.

Outputs:

- New CPU load target.
- Status text.
- Optional controller telemetry row.

Rules:

- Start at 25% when already discharging.
- Use filtered discharge watts for control.
- Apply PI correction with hysteresis.
- Limit target changes per adjustment.
- Stop only on charging, explicit stop, app exit, or completed test.
- Do not stop simply because calculated load reaches zero.

Future improvement:

The controller should store a short rolling window of control ticks in memory so the UI can show why it changed load without forcing the user to inspect the CSV.

## Data Ownership

Settings:

- Owned by `SettingsService`.
- Saved under `%APPDATA%\PowerPilot\settings.ini`.
- Defaults are code-owned only until first user save.

Logs:

- Owned by `BatteryLogService`.
- Saved under `%APPDATA%\PowerPilot\battery-log.csv`.
- Used for graph reload, battery summaries, and debugging.

Reports:

- Owned by `ReportService`.
- Saved under `%APPDATA%\PowerPilot\reports`.
- Report text should be human-readable and shareable.

Managed plans:

- Owned by `PlanService`.
- Created and repaired through Windows `powercfg`, with native powrprof APIs preferred for active-scheme reads and activation.
- Kept Balanced-derived for Modern Standby visibility; performance and battery behavior should come from processor settings plus hidden platform policy, not from changing the scheme personality away from Balanced.
- Refreshed in place during installer updates so new hidden policy reaches existing GUIDs without a destructive rebase.
- Only PowerPilot-owned plans may be deleted by cleanup.

## UI Design Principles

PowerPilot is an operational utility. The UI should favor clear status, compact controls, and stable layout.

Design rules:

- Use tabs by workflow, not by implementation subsystem.
- Use frames for major groups.
- Keep dynamic values in predictable rows.
- Keep report/log/graph surfaces as contained data areas.
- Use short button labels.
- Avoid explanatory paragraphs inside cramped panels.
- Use tooltips for details that do not fit.
- Do not hide important uncertainty. Use text like `Windows not reported`, `Calculating`, or `Estimated`.

Recommended future tab model:

1. Overview
2. Plans
3. Battery Saver
4. Battery
5. Battery Log
6. Battery Test
7. Power Use
8. Settings
9. About

Reasoning:

- Battery Graph and Battery Stats could become one `Battery` tab with subviews or a split layout.
- Battery Saver should remain separate because it changes Windows plan policy rather than showing historical battery data.
- Settings backup and log visibility controls could move to a clear `Settings` tab.
- Battery Test should stay near Battery, because it is a workflow, not only a report.
- About should remain last.

This is not required for the current app, but it is a cleaner rebuild direction.

## Report Design

Battery reports should have a stable structure:

1. Title and generation time.
2. Workflow and phase.
3. Result sentence.
4. Timeline.
5. Battery movement.
6. Average power.
7. Workflow-specific phases.
8. Capacity notes.
9. Interpretation and limitations.

Reports should avoid raw implementation terms unless they are useful for debugging. The report should be understandable when pasted into a support discussion.

## Installer And Asset Design

The installer should be treated as part of the product, not an afterthought.

Installer responsibilities:

- Install one versioned EXE.
- Install app, desktop, and tray icons.
- Install README, license, and third-party notices as `.txt`.
- Create a desktop shortcut.
- Remove obsolete helper files from older prototypes.
- Start PowerPilot in tray mode after install.
- Avoid Restart Manager killing the app in a way that looks like PC shutdown.

Icon responsibilities:

- App/setup icon: `powerpilot.ico`.
- Desktop shortcut icon: `powerpilot_desktop.ico`.
- Tray icon: `powerpilot_tray.ico`.

Tray responsibilities:

- Always provide `Open`.
- Always provide `Exit`.
- If tray creation fails, keep the main window visible.

## Rebuild Strategy

A future rebuild should not start by copying the current source line for line. It should follow this order:

1. Define models and settings.
2. Implement settings load/save/migration.
3. Implement platform adapters.
4. Implement plan service.
5. Implement battery telemetry service.
6. Implement log service.
7. Implement estimate service.
8. Implement Battery Test state machines.
9. Implement drain helper.
10. Implement report service.
11. Build the UI shell.
12. Bind UI controls to services.
13. Add tray behavior.
14. Add installer.
15. Run verification checklist.

This order avoids the current problem where UI, service logic, and persistence grow together.

## Design Test Questions

Before adding a feature, ask:

- Which service owns this behavior?
- Which model stores its state?
- Is this a platform fact or an app decision?
- Does it need a setting?
- Does it need a log row?
- Does it need a report row?
- What happens in tray mode?
- What happens during install/update close?
- What happens if Windows does not report the expected value?
- Can the UI explain the state in one short sentence?

If those questions are hard to answer, the design boundary is probably not clean enough yet.
