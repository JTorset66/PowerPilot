# PowerPilot v1.1

PowerPilot v1.1 adds local battery history, graphing, and remaining-time estimation while keeping the tray app on the normal user side of the installer boundary.

Current stamped release: `v1.1.2605.14550`.

## Added

- Battery Graph tab with live battery percent, plugged-in state, charging/discharging state, capacity, charging/discharging rate, Windows runtime, wear, maximum capacity, cycle count, and a taller gliding graph.
- Battery Graph tab surfaces wear as the simple headline health number, backed by full-charge capacity versus design capacity.
- PowerPilot Log tab with configurable logging interval, battery refresh interval, minimum percent floor, maximum percent ceiling, charge-limiter maximum, smoothing window, and startup drain.
- PowerPilot CSV log saved under the user's PowerPilot settings folder.
- PowerPilot CSV log is capped to the latest 168 hours.
- PowerPilot Log tab includes a Reset log button to clear the CSV log, graph samples, and current estimate calculations.
- PowerPilot Log tab includes multi-row selection and copy buttons for selected retained rows and the full retained CSV log.
- PowerPilot Log tab shows average, instant, Windows runtime, now rate, plugged-in state, signed battery watts, screen event, brightness, power-event rows, and short app status messages.
- Charging estimates now show average time to the configured Full at or charge-limit target, using current charging watts plus recent percent movement with a taper adjustment near the target. The live `Now` field uses the average while charging to avoid a redundant second ETA.
- Charging estimate learning is persisted with a 32-update cap so future time-to-full estimates can start from earlier charging behavior.
- Vendor battery calibration states that are plugged in but discharging are now treated as active battery use for estimates and logs.
- Battery Test tab added between Power Use and About with guided manual discharge, Lenovo calibration reset mode, automatic vendor calibration detection, charge recovery tracking, target-time CPU load for watched drain tests, drain-helper test-mode telemetry, `BATTERY TEST` log rows, saved `.txt` reports, and copyable reports.
- PowerPilot Log column widths are saved as user settings, so manual column sizing survives refreshes, restarts, and reinstalls that keep settings.
- Battery Stats tab with session summary, daily battery summary, off-time battery-loss summary, configurable PowerPilot Log columns, and settings export/import.
- Battery Saver tab centralizes Windows Energy Saver threshold/brightness, low/reserve/critical battery thresholds, low/critical battery actions, background throttling, deep idle saver, and normal-plan restore-on-exit.
- PowerPilot CSV log records separate event rows for PC startup, shutdown, shutdown requested, sleep/hibernate, wake, return from hibernation, and Improper shutdown after a missing prior shutdown.
- PowerPilot CSV log records separate `screen` rows for screen on, screen dim, and screen off using Windows console display-state power notifications.
- PowerPilot CSV battery sample rows include the built-in laptop screen brightness percent when `root\wmi:WmiMonitorBrightness` and `root\wmi:WmiMonitorConnectionParams` expose it, with a conservative `Dxva2.dll` fallback when Windows monitor WMI is unavailable.
- PowerPilot CSV log records separate `app` rows for PowerPilot start, normal PowerPilot exit, installer/update close, and shortened app status messages; app rows reset sample averaging without being treated as PC shutdowns or graph power-event markers.
- Average battery-time calculation treats sleep, hibernate, shutdown, startup, wake, and improper-shutdown event rows as hard breaks so offline time is not counted as drain time.
- Battery percent graph based on recent logged/sampled values.
- Battery graph uses selectable 6-, 12-, 18-, 24-, 36-, 48-, 60-, and 72-hour windows with hour-only labels.
- Battery graph includes normal, Energy Saver, and offline/discontinued line colors, event markers, and orange flat spans across missing/offline periods while keeping those periods out of average drain calculations.
- Battery graph marker letters distinguish sleep/suspend, hibernate, wake, shutdown, startup, improper shutdown, offline (`0`), online (`1`), Energy Saver, and normal-state transitions. Crowded marker letters stack above their vertical line as white letters with black shadows.
- Resume classification checks recent Windows System event log text to better distinguish wake from return from hibernation.
- Gliding remaining-time estimate based on percent-per-hour reduction, with a saved startup estimate used immediately after app start until fresh data takes over.
- Initial startup `%/h` drain is now learned automatically from the full retained PowerPilot log, using continuous on-battery samples and skipping app/power-event breaks.
- Battery Graph tab displays both average remaining time and instant remaining time, and the PowerPilot log records average time, instant time, Windows time, and instant drain value.
- Battery Graph Time Estimates box includes `Full-to-min`, showing average estimated life from the configured full point down to the empty point.
- Average remaining time now uses actual elapsed on-battery history until the configured glide window is full, then rolls over that window.
- Battery estimate settings now auto-apply after a short edit delay; the old Save button was removed because the controls persist themselves.
- PowerPilot-managed Windows plans now take their low/reserve/critical battery levels and low/critical battery actions from the Battery Saver tab instead of tying Windows critical sleep to the estimate-only `Empty at` value.
- PowerPilot-managed plans now keep a Balanced-derived personality so Maximum, Balanced, and Battery remain visible and usable on Modern Standby systems while still following the normal Windows power mode choices.
- The Battery plan now applies additional Windows battery-saving policy: low-power GPU preference, PCIe maximum link saving, DC device idle, disabled DC standby networking, aggressive DC disconnected standby, shorter DC display/disk/sleep timeouts, DC hibernate after 30 minutes, and disabled DC wake timers.
- Daily/startup refresh for `root\wmi:BatteryFullChargedCapacity` and `root\wmi:BatteryCycleCount`.
- Live estimate refresh from `root\wmi:BatteryStatus` and runtime probing from `root\wmi:BatteryRuntime`.
- `root\wmi:BatteryRuntime.EstimatedRuntime` is treated as seconds, with `Win32_Battery.EstimatedRunTime` as a minutes fallback.

## Changed

- Build stamping now uses the `1.1.YYMM.minute-of-month` version line and `PowerPilot_V1.1...` artifact names.
- The installer still requires administrator approval for setup, but all installed app commands after file copy run as the original ordinary user, and post-install tray launch does not start PowerPilot elevated.
- The installer owns per-user Windows startup registration for the original user. The app install-refresh path persists the preference and repairs plans, but does not write the startup entry during setup.
- Installer cleanup now targets running and stale versioned app executables with the `PowerPilot_V*.exe` pattern so updates replace prior stamped builds cleanly.
- Installer normal-update path is faster: setup now closes PowerPilot directly instead of waiting on Inno Restart Manager, skips repeated legacy helper kills unless those files exist, and uses one `/install-refresh` command that repairs plans only when missing.
- Installer normal-update refresh now reapplies the current full PowerPilot plan policy to existing managed plans, including hidden Battery plan savings, without deleting their GUIDs.
- Installer now uses side-by-side versioned app updates: newer-version installs do not wait for the old tray app to close, while same-version reinstalls close only the exact same exe name before overwrite.
- Installed PowerPilot now version-checks running `PowerPilot_V*.exe` processes and closes older versions in the background while excluding its own process/name; setup also starts a background cleanup command to remove old versioned files after install.
- Setup asks the newly installed app to write `PowerPilot update close` before background cleanup starts when an existing PowerPilot tray copy is running, so reinstall/update rows no longer look like normal user exits or PC shutdowns.
- Older-version process/file cleanup uses a PowerShell-backed version check for reliable background termination and stale-file removal.
- Installer status text now explains whether it is closing the exact same version before overwrite or installing side-by-side and letting the new app close older versions in the background.
- Install helper now performs an automatic post-install process check and fails if setup, cleanup, or installer-related PowerShell processes remain after the run.
- Battery power-event logging ignores Windows Restart Manager `CLOSEAPP` session messages so installer/update closes are not recorded as PC shutdowns.
- Battery log startup cleanup removes same-boot `Shutdown requested` / `Shutdown` rows caused by app exit, app restart, or reinstall closure before the graph and stats are loaded.
- Battery stats now separates app lifecycle breaks from PC power breaks, so app exit/restart/reinstall rows reset averages without appearing as off/sleep loss or graph offline markers.
- First-run boot baseline no longer writes a misleading `PC startup` power event, and same-boot baseline startup rows without a prior shutdown/improper marker are cleaned from the retained log.
- The old bottom status field was removed; action feedback now appears as short `APP` rows in the PowerPilot Log while the Overview tab keeps the full latest action text.
- Added `FUNCTION_MAP.md` to document the current PureBasic source layout and make future stale-code checks easier.
- Release tooling now accepts an explicit app version so tagged builds such as `v1.1.2605.14550` produce matching executable and setup artifact names.

## Artifacts

- `PowerPilot_V1.1.YYMM.minute-of-month.exe`
- `PowerPilot_V1.1.YYMM.minute-of-month.exe.sha256`
- `PowerPilot_V1.1.YYMM.minute-of-month_Setup.exe`
- `PowerPilot_V1.1.YYMM.minute-of-month_Setup.exe.sha256`
