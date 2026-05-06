# Algorithms And Logic

## Power Mode To Plan Mapping

PowerPilot maps Windows power mode overlays into the three fixed plans:

- Best performance maps to `PowerPilot Maximum`.
- Balanced maps to `PowerPilot Balanced`.
- Energy efficiency maps to `PowerPilot Battery`.

The app recreates missing managed plans when needed and never deletes arbitrary user plans.

## Plan Writing

`CreateManagedPlans()` and related helpers use `powercfg` to write processor settings. Values are clamped before writing:

- EPP: 0 to 100.
- Boost mode: valid combo index.
- Max processor state: 1 to 100.
- Max frequency: 0 to 6000 MHz.
- Cooling: valid combo index.

Energy Saver control can follow Windows or apply the PowerPilot Battery-plan setting.

## Battery Telemetry

Battery telemetry combines Windows battery sources and static capacity data:

- Percent.
- Plugged in state.
- Charging state.
- Disconnected battery state.
- Remaining mWh.
- Full-charge capacity.
- Design capacity.
- Wear percent.
- Charge/discharge rates.
- Voltage.
- Cycle count when available.
- Windows runtime/estimate when available.

Windows does not always report time to full while charging. PowerPilot therefore records charging behavior and learns a capped average for future time-to-full estimates.

## Battery Estimates

PowerPilot records:

- Average remaining time from smoothed discharge behavior.
- Current-rate time from instant discharge watts.
- Windows or firmware time if available.
- Learned charging rate for time to configured full target.

Battery Test uses current discharge watts for faster time-to-empty while discharging.

## Logging

`battery-log.csv` is the retained source of truth for:

- Battery sample rows.
- App rows.
- PC power event rows.
- Screen rows.
- Energy Saver rows.
- Battery Test rows.

Sleep, hibernate, shutdown, startup, wake, app close, and missing-sample gaps are treated as breaks for average-drain calculations.

## Graph Drawing

`DrawBatteryGraph()` draws to an offscreen image first, then blits once to the visible canvas. This reduces flicker and keeps the graph stable during refresh.

The graph uses marker priority and collision checks:

- Power/offline markers are higher priority than Energy Saver/normal transition markers.
- Event letters close together are combined when they would land on nearly the same x position.
- Sleep-to-hibernate can split into separate `Z` and `H` markers when the sleep/offline segment start and hibernate marker are far enough apart; otherwise it stays compact.
- Label placement reserves small occupied rectangles. A marker label is drawn only if it can fit without overlapping an earlier label in the same row.
- Low-priority `E` and `N` labels thin out more as the selected graph window grows; if their label cannot be drawn, their vertical marker is skipped.

## Battery Test Accumulation

Battery Test tracks:

- Start and end percent.
- Start and end remaining mWh.
- mWh used.
- mWh charged.
- Discharge seconds.
- Charge seconds.
- Average discharge watts.
- Average charge watts.

Movement is calculated from changes in remaining mWh. Watt averages prefer measured charge/discharge watts when available.

## Lenovo Calibration Reset Completion

Lenovo reset completes only when all required observations are true:

1. The user has started Lenovo reset.
2. PowerPilot has observed plugged in and discharging.
3. PowerPilot has observed charging.
4. The final state is plugged in, not discharging, and not charging.

This avoids marking the test complete if the charger was merely plugged in without a Lenovo discharge/charge cycle.

## Drain Helper Regulation

The auto drain helper:

- Starts at 25% CPU load when discharge is already active.
- Uses the saved drain target time.
- Estimates current minutes from usable mWh and filtered discharge watts.
- Uses PI-style correction with hysteresis.
- Limits load changes to avoid large jumps.
- Does not stop just because target load reaches zero.
- Stops on charge recovery.

Test mode writes controller tick rows with load, watts, current minutes, target minutes, error, integral, and usable mWh.

## Safety Boundaries

The CPU load helper is local process load only. It does not change CPU TDP, firmware limits, charger behavior, or Lenovo calibration state. The UI warns the user to watch temperature.
