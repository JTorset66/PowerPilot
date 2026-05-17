# PowerPilot User Guide

PowerPilot is a small Windows tray app that manages three local Windows power plans and records local battery history.

The three plans are:

- `PowerPilot Maximum`
- `PowerPilot Balanced`
- `PowerPilot Battery`

PowerPilot follows the normal Windows power mode control. You use Windows to choose Best performance, Balanced, or Best power efficiency. PowerPilot then switches to the matching PowerPilot plan.

Older Windows power-plan screens may also list the three PowerPilot-owned plans because they are real local Windows schemes. That is expected. The normal Settings power mode choices remain efficiency, balanced, and maximum performance, and PowerPilot maps those modes to the matching plan while it is running.

## First Use

1. Install PowerPilot.
2. Let setup finish creating or refreshing the PowerPilot plans.
3. Look for PowerPilot in the Windows notification area.
4. Open it from the tray icon or desktop shortcut when you want to inspect or tune it.
5. Leave it running in the tray if you want automatic power-mode following.

PowerPilot does not require a helper service. Setup needs administrator approval to install into Program Files, but the post-install commands, startup entry, and tray app run as the normal user.

## What Each Tab Does

### Overview

Use Overview to see the current state.

- `Active plan` shows the Windows power plan that is active right now.
- `Windows mode` shows the Windows power mode PowerPilot is following.
- `Battery` and `Energy Saver` show live battery/saver state.
- `Latest action` shows the latest thing PowerPilot did.
- `Hardware` summarizes CPU, memory, graphics, and display state.
- `Battery Runtime` summarizes watts, runtime estimates, capacity, and wear.
- `PowerPilot` shows read/log cadence, app-use sampling, Energy Saver policy, and startup controls.

Most users can leave these defaults enabled:

- `Start with Windows` starts PowerPilot hidden in the tray after sign-in, reapplies saved plan settings, follows Windows power mode, and stays hidden until you open it.
- `Keep settings`
- `Show tips`
- `Theme`: Windows, Light, or Dark.

### Plans

Use Plans to tune the three PowerPilot plans.

Select `Maximum`, `Balanced`, or `Battery`, change the values, then click `Save plan`.

Plain meanings:

- `Energy`: lower is faster, higher is more efficient.
- `CPU boost`: Disabled saves power, Aggressive responds fastest.
- `Max CPU`: highest allowed CPU state as a percent.
- `CPU MHz cap`: maximum CPU frequency. `0` means uncapped.
- `Cooling`: Passive favors lower fan use and lower clocks. Active favors cooling.

There is a plugged-in column and a battery column because Windows can use different behavior on AC power and on battery.

### Battery Saver

Use Battery Saver to control Windows battery-saving behavior from PowerPilot while the app is running.

- `Energy Saver`: `Automatic threshold` uses the configured battery percent. `Battery plan always` forces Energy Saver for the PowerPilot Battery plan.
- `Turn on at`: Energy Saver battery threshold. Active only in `Automatic threshold` mode.
- `Brightness`: controls whether PowerPilot writes the Windows Energy Saver brightness scale; unchecked leaves the Windows brightness value untouched.
- `Throttle background`: asks Windows to slow safe background maintenance work in efficiency mode.
- `Deep idle saver`: reduces hidden-tray wakeups to about 5 minutes, marks PowerPilot itself as background/EcoQoS while hidden, and uses deeper idle-friendly Battery plan settings.
- `Restore normal plan on exit`: switches back to the last non-PowerPilot Windows plan PowerPilot saw when the app exits.
- `Low warning`, `Reserve`, `Low action`, `Critical`, and `Critical action`: Windows battery thresholds and actions written to PowerPilot-owned plans. Reserve is a warning level only; Windows does not expose a separate reserve action.

### Battery Graph

Use Battery Graph to see live battery information and a selectable percent graph.

The graph marks battery samples, Energy Saver state, and power events on a fixed 0% to 100% scale, with hour-only labels. Choose 1, 3, 6, 12, 18, 24, 36, 48, 60, or 72 hours, or `Max` for the retained 168-hour log window. Windows up to 24 hours label every hour; longer windows label every fourth hour. Blue line segments mean normal battery samples. Green line segments mean Energy Saver was active at that point, either from Windows or PowerPilot's controlled Battery plan setting. Orange line segments mean offline/discontinued samples. Red vertical lines show PC power events. Marker letters are shown in the graph: `Z` sleep/suspend, `H` hibernate, `W` wake, `S` shutdown, `P` startup, `!` improper shutdown, `0` offline, `1` online, `E` Energy Saver, and `N` normal. Thin vertical lines mark graph color changes. Crowded marker letters stack as white letters with black shadows. Use `Markers` on the graph tab to show or hide marker letters and their legend. It helps answer questions like:

- Did the battery drop while asleep?
- Did the laptop wake?
- Is active battery drain higher than expected?
- Is Windows reporting a useful runtime estimate?

Remaining-time fields:

- `Average`: based on recent logged battery drop. If the laptop is on AC or the drain is too small to trust, PowerPilot says so instead of showing a huge runtime.
- `Now`: based on current discharging rate. While charging, PowerPilot uses the average estimate.
- `Windows`: Windows or firmware estimate.
- `Full run`: average estimate from the configured full point down to the configured empty point, only with believable on-battery drain data.
- `As-new run`: the same full-to-empty estimate scaled to the battery's original design capacity, using the same believable-data rule.

### PowerPilot Log

Use PowerPilot Log when you want details or a copyable CSV.

The log can include:

- battery samples
- screen on, screen dim, and screen off
- Energy Saver on/off rows when Windows toggles battery saver
- built-in laptop screen brightness percent when Windows exposes it
- sleep, wake, shutdown, startup, hibernate, and improper shutdown
- app events such as PowerPilot start, exit, update close, and short status rows

Main settings:

- `Log samples`: turn retained battery sample logging on or off.
- `Log every`: how often a battery row is saved. Active only when `Log samples` is checked.
- `Read every`: how often live battery data is read while the window is open. The default is 5 seconds; tray mode backs off to about 5 minutes.
- `Empty at`: the percent used as the empty point for PowerPilot estimates. It can be 0%; Windows low and critical battery behavior is on the Battery Saver tab.
- `Full at`: the percent used as the full point for discharging estimates and the target for charging estimates.
- `Use charge limit`: use the laptop charge limit instead of 100%.
- `Average window`: how much recent battery history is averaged.
- `Startup drain`: temporary drain estimate used right after app start.
- `Reset log`: clears retained log rows, graph history, and current estimate learning.

PowerPilot keeps a capped learned charging rate in user settings, up to 32 recent charging-learning updates, so future time-to-full estimates can start closer before fresh charging history builds.

Copy buttons:

- `Copy rows`: copies selected rows, or the newest visible row if nothing is selected.
- `Copy CSV`: copies the full retained CSV.

### Battery Stats

Use Battery Stats for summaries.

- `Latest Event`: last sleep, wake, shutdown, startup, hibernate, or improper shutdown event.
- `Sleep/Off Loss`: battery lost across sleep, hibernate, shutdown, startup, or large missing-sample gaps.
- `Today`: today's range, active battery time, active drain, wear, and cycles.
- `Visible Log Columns`: hides or shows optional log columns, including average time, now/rate, Windows time, plugged-in state, battery watts, screen event, laptop brightness, and event rows including Energy Saver changes.
- `Battery Analysis`: when analysis last ran, retained rows/spans pulled, covered time interval, stable capacity, normal power, runtime, calibration, charging, and a local stats-helper note. `Refresh analysis` forces a fresh battery read/log row before rebuilding it.
- `Export settings` and `Import settings`: manual settings backup and restore.

During vendor battery calibration, Windows can report plugged in and discharging at the same time. PowerPilot treats that as active battery use while still showing that external power is present.

`Avg active drain` is the average battery drop per hour while awake and on battery. `Total battery used today` adds up each on-battery discharging period. Example: 80% to 60% counts as 20%; after charging back to 90%, 90% to 70% counts as another 20%. Recharging does not subtract from the total, so the value can go over 100% in one day.

Settings backup is optional. PowerPilot normally keeps settings during updates when `Keep settings` is enabled.

### Power Use

Use Power Use to see the app's estimated battery cost.

PowerPilot watches its own process CPU time over a 60-second live window and a configurable average window. The Battery Graph `Avg use` row defaults to 10 minutes and lets you choose 1 to 60 minutes. This is useful for checking whether the app itself is unusually active.

When plugged in, PowerPilot keeps the estimate active by using the current full-charge capacity and learned average discharging rate as the battery discharging basis.

`CPU time` is normalized to total logical CPU capacity. It tops out at 60 seconds when PowerPilot uses all logical CPUs for the whole 60-second window.

`CPU load` is shown as a share of total logical CPU capacity, not as a share of one core. This matches the live mW estimate below it; the average mW uses the selected average length.

`Full-to-empty cost` estimates how many seconds of battery runtime this app may consume across the configured `Full at` to `Empty at` range. `About 5 sec` is very small; it means PowerPilot is estimated to cost about five seconds across that usable battery window if the same app CPU share continued.

It is an estimate, not a hardware meter.

The lower half explains how to read the numbers and gives a short idle-investigation checklist. It is useful when comparing tray-hidden, visible-window, screen-on, and screen-off behavior.

### Battery Test

Use Battery Test to monitor a battery run or vendor calibration workflow.

- `Manual test`: starts a report and prompts you to unplug.
- `Calibration`: waits for the charger, starts the saved drain helper target during plugged-in calibration discharge, stops load when charging starts, and saves a `.txt` report when charging reaches idle.
- `Vendor calibration detected`: appears automatically when Windows reports plugged in and discharging.
- `Charge recovery`: tracks charging back to the configured full target.
- `Report and Log`: shows a short screen summary. `Open report` opens the latest saved Battery Test report. `Copy report` copies start/end percent, mWh moved, average watts, observed runtime, and capacity notes.
- `Calibration Drain Helper`: automatically targets a chosen drain time with filtered PI-style load changes about every 10 seconds, starting gently during plugged-in calibration discharge, and stops when charging starts. `Test mode` adds detailed controller rows for tuning runs.
- Battery Test live stats refresh about once per second while that tab is selected. Other tabs keep the normal read interval.
- While discharging, Battery Test estimates time to empty from current discharge watts so it reacts faster than the normal smoothed graph estimate.

Battery Test writes clear `BATTERY TEST` rows into the retained PowerPilot Log. Saved reports live in `%APPDATA%\PowerPilot\reports`.

### About

Use About for an in-app summary of what PowerPilot does.

It shows:

- the installed PowerPilot version
- the short purpose of PowerPilot
- the automatic plan mapping from Windows power mode
- the battery fields, screen states, laptop brightness, and event rows PowerPilot can log
- what local Windows data PowerPilot reads
- what local settings, retained rows, and Windows plan values PowerPilot writes
- privacy notes, including that PowerPilot does not send data anywhere by itself
- Store developer identity and copyright information
- MIT license information and where to find the full installed `LICENSE.txt` file
- `USER MANUAL`, `README`, and `LICENSE` buttons for opening the bundled manual, guide, and license text
- update, settings, documentation, and uninstall notes
- boundaries for the Power Use estimate, including that it is not a hardware power meter

## Screen Brightness Logging

PowerPilot tries to log built-in laptop screen brightness percent on normal battery sample rows.

It uses this order:

1. Windows monitor WMI, matched to the internal laptop panel.
2. A conservative `Dxva2.dll` monitor-brightness fallback only when the display layout is unambiguous.
3. Blank value if Windows does not expose a trustworthy laptop-panel brightness value.

This avoids accidentally logging an external monitor as the laptop screen.

## Installer Behavior

The installer:

- installs PowerPilot into `Program Files\PowerPilot`
- creates a desktop shortcut
- uses one combined two-column front page with setup summary and read buttons for USER MANUAL, README, LICENSE, and THIRD-PARTY NOTICES
- shows final setup status after file copy while it refreshes plans, handles settings, registers startup, and starts the tray app
- enables tray startup for the current user
- launches PowerPilot hidden in the tray after install
- runs post-install commands and the tray app as the current user without UAC elevation
- keeps existing user settings when that preference is enabled
- installs newer stamped app versions side-by-side
- writes `PowerPilot update close` when replacing a running copy
- lets the newly installed app close older PowerPilot versions in the background
- removes stale old versioned app files
- creates missing PowerPilot plans and refreshes their CPU, battery, Energy Saver, and hidden platform policy during normal updates and hidden startup
- checks that installer and cleanup helper processes have exited
- supports repair and uninstall from Windows Apps/Programs

The uninstaller removes installed files, the startup entry, PowerPilot-owned plans, and old prototype `Codex *` plans.

## Privacy

PowerPilot reads local Windows hardware, battery, display, and power-plan information. It writes local settings and a local retained CSV log.

PowerPilot does not send data to networked systems unless you or the operator separately choose to share copied logs or files.

## Notes

- PowerPilot no longer uses helper executables.
- PowerPilot does not read live CPU temperature, fan speed, package watts, or live GPU telemetry.
- Laptop brightness is sampled on normal battery rows, but skipped while the logged screen state is off.
- PowerPilot manages only plans it owns.
- Windows power behavior can still vary by device firmware, drivers, and hidden Windows settings.
