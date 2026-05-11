# Algorithms And Logic

## Power Mode To Plan Mapping

PowerPilot maps Windows power mode overlays into the three fixed plans:

- Best performance maps to `PowerPilot Maximum`.
- Balanced maps to `PowerPilot Balanced`.
- Best power efficiency maps to `PowerPilot Battery`.

The app recreates missing managed plans when needed and never deletes arbitrary user plans. The managed plans are real Windows power schemes, so Windows can list them in older plan screens. PowerPilot still treats Windows power mode as the user-facing selector.

Plan activation prefers the native `PowerSetActiveScheme` API. `powercfg /SETACTIVE` remains a fallback because some Windows 11 normal-user sessions can activate through the API while the command-line tool returns access denied.

## Plan Writing

`CreateManagedPlans()` and related helpers use `powercfg` to write plan settings and powrprof APIs to read/activate schemes where available. Values are clamped before writing:

- EPP: 0 to 100.
- Boost mode: valid combo index.
- Max processor state: 1 to 100.
- Max frequency: 0 to 6000 MHz.
- Cooling: valid combo index.

Battery Saver settings write Windows Energy Saver policy/threshold/brightness and low/reserve/critical battery behavior to PowerPilot-owned plans. Energy Saver can follow the Windows threshold or force the Battery plan into Energy Saver while PowerPilot is running.

The Battery plan also writes hidden Windows saving policy that is not exposed in the plan editor: Balanced-derived personality for Modern Standby compatibility, DC device idle, low-power GPU preference, PCIe maximum link saving, disabled DC standby networking, aggressive DC disconnected standby, shorter DC display/disk/sleep timeouts, DC hibernate after 30 minutes, and disabled DC wake timers. Installer refresh reapplies the full current PowerPilot plan policy to existing schemes so new hidden settings reach old installations without deleting user plans.

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
- `0` marks offline/discontinued graph spans and `1` marks the return to online samples.
- Event letters close together stack above the same vertical line instead of overlapping each other.
- Marker letters draw as white text with black shadows so they stay readable over graph lines.
- The `Markers` checkbox hides both marker letters and the marker legend while keeping the graph line colors.

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
