# PowerPilot v1.1

PowerPilot v1.1 adds local battery history, graphing, and remaining-time estimation while keeping the tray app on the normal user side of the installer boundary.

## Added

- Battery Graph tab with live battery percent, connected state, charging/discharging state, capacity, charge/discharge rate, Windows runtime, wear, maximum capacity, cycle count, and a taller gliding graph.
- Battery Graph tab surfaces wear as the simple headline health number, backed by full-charge capacity versus design capacity.
- PowerPilot Log tab with configurable logging interval, battery refresh interval, minimum percent floor, maximum percent ceiling, charge-limiter maximum, smoothing window, and startup drain estimate.
- PowerPilot CSV log saved under the user's PowerPilot settings folder.
- PowerPilot CSV log is capped to the latest 168 hours.
- PowerPilot Log tab includes a Reset stats button to clear the CSV log, graph samples, and current estimate calculations.
- PowerPilot Log tab includes multi-row selection and copy buttons for selected retained rows and the full retained CSV log.
- PowerPilot Log tab shows average, instant, Windows runtime, instant drain, connected state, power-event rows, and short app status messages.
- PowerPilot Log column widths are saved as user settings, so manual column sizing survives refreshes, restarts, and reinstalls that keep settings.
- Battery Stats tab with session summary, daily battery summary, off-time battery-loss summary, configurable PowerPilot Log columns, and settings export/import.
- PowerPilot CSV log records separate event rows for PC startup, shutdown, shutdown requested, sleep/hibernate, wake, return from hibernation, and Improper shutdown after a missing prior shutdown.
- PowerPilot CSV log records separate `app` rows for PowerPilot start, normal PowerPilot exit, installer/update close, and shortened app status messages; app rows reset sample averaging without being treated as PC shutdowns or graph power-event markers.
- Average battery-time calculation treats sleep, hibernate, shutdown, startup, wake, and improper-shutdown event rows as hard breaks so offline time is not counted as drain time.
- Battery percent graph based on recent logged/sampled values.
- Battery graph now uses a gliding 24-hour time window with hourly grid marks and date/time labels.
- Battery graph includes an active/offline legend, event markers, and grey endpoint-to-endpoint segments across sleep, hibernate, shutdown, startup, and large missing-sample periods while keeping those periods out of average drain calculations.
- Resume classification checks recent Windows System event log text to better distinguish wake from return from hibernation.
- Gliding remaining-time estimate based on percent-per-hour reduction, with a saved startup estimate used immediately after app start until fresh data takes over.
- Initial startup `%/h` drain is now learned automatically from the full retained PowerPilot log, using continuous on-battery samples and skipping app/power-event breaks.
- Battery Graph tab displays both average remaining time and instant remaining time, and the PowerPilot log records average time, instant time, Windows time, and instant drain value.
- Battery Graph Estimate box now includes a `Max avg` reference showing average estimated life from the configured maximum ceiling down to the minimum-percent floor.
- Average remaining time now uses actual elapsed on-battery history until the configured glide window is full, then rolls over that window.
- Battery estimate settings, including the minimum-percent sleep floor, now auto-apply after a short edit delay; the old Save button was removed because the controls persist themselves.
- PowerPilot-managed Windows plans now use the same minimum percent as the DC critical battery level, set DC critical battery action to Sleep, and set the low-battery warning one percent above that floor.
- Daily/startup refresh for `root\wmi:BatteryFullChargedCapacity` and `root\wmi:BatteryCycleCount`.
- Live estimate refresh from `root\wmi:BatteryStatus` and runtime probing from `root\wmi:BatteryRuntime`.
- `root\wmi:BatteryRuntime.EstimatedRuntime` is treated as seconds, with `Win32_Battery.EstimatedRunTime` as a minutes fallback.

## Changed

- Build stamping now uses the `1.1.YYMM.minute-of-month` version line and `PowerPilot_V1.1...` artifact names.
- The installer still runs elevated, but post-install tray launch no longer falls back to starting PowerPilot elevated if original-user launch fails.
- Installer cleanup now targets running and stale versioned app executables with the `PowerPilot_V*.exe` pattern so updates replace prior stamped builds cleanly.
- Installer normal-update path is faster: setup now closes PowerPilot directly instead of waiting on Inno Restart Manager, skips repeated legacy helper kills unless those files exist, and uses one `/install-refresh` command that repairs plans only when missing.
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

## Artifacts

- `PowerPilot_V1.1.YYMM.minute-of-month.exe`
- `PowerPilot_V1.1.YYMM.minute-of-month.exe.sha256`
- `PowerPilot_V1.1.YYMM.minute-of-month_Setup.exe`
- `PowerPilot_V1.1.YYMM.minute-of-month_Setup.exe.sha256`
