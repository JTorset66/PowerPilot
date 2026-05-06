# PowerPilot User Guide

PowerPilot is a small Windows tray app that manages three local Windows power plans and records local battery history.

The three plans are:

- `PowerPilot Maximum`
- `PowerPilot Balanced`
- `PowerPilot Battery`

PowerPilot follows the normal Windows power mode control. You use Windows to choose Best performance, Balanced, or Best power efficiency. PowerPilot then switches to the matching PowerPilot plan.

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
- `Latest action` shows the latest thing PowerPilot did.
- `Graphics` lists Windows display adapters, labels likely iGPU/dGPU rows, and keeps Windows `active` and `primary` flags. Generic AMD/Intel iGPU names are refined only when the local CPU name gives a safe match.
- `Startup and Idle` controls startup, reinstall settings, background throttling, deep idle behavior, and tooltips.

Most users can leave these defaults enabled:

- `Start with Windows`
- `Keep settings`
- `Throttle background`
- `Deep idle saver`
- `Show tips`

`Deep idle saver` reduces hidden-tray wakeups to about 5 minutes, marks PowerPilot itself as background/EcoQoS while hidden, and uses deeper idle-friendly Battery plan settings.

### Plans

Use Plans to tune the three PowerPilot plans.

Select `Maximum`, `Balanced`, or `Battery`, change the values, then click `Save plan`.

Plain meanings:

- `Energy pref`: lower is faster, higher is more efficient.
- `CPU boost`: Disabled saves power, Aggressive responds fastest.
- `Max CPU`: highest allowed CPU state as a percent.
- `CPU MHz cap`: maximum CPU frequency. `0` means uncapped.
- `Energy saver`: `Follow Windows` uses normal automatic Energy Saver behavior. `On for Battery plan` applies Energy Saver only to the PowerPilot Battery plan.
- `Cooling`: Passive favors lower fan use and lower clocks. Active favors cooling.

There is a plugged-in column and a battery column because Windows can use different behavior on AC power and on battery.

### Battery Graph

Use Battery Graph to see live battery information and a selectable percent graph.

The graph marks battery samples, Energy Saver state, and power events on a fixed 0% to 100% scale, with hour-only labels. Choose 6, 12, 18, 24, 36, 48, 60, or 72 hours. Windows up to 24 hours label every hour; longer windows label every fourth hour. Blue line segments mean normal battery samples. Green line segments mean Energy Saver was active at that point, either from Windows or PowerPilot's controlled Battery plan setting. Red segments and markers show event/offline gaps. Marker letters are shown in the graph: `Z` sleep/suspend, `H` hibernate, `W` wake, `S` shutdown, `P` startup, `!` improper shutdown, `O` offline or missing samples, `E` Energy Saver, and `N` normal. Thin vertical lines mark graph color changes. `E` and `N` labels are skipped when the view is crowded. It helps answer questions like:

- Did the battery drop while asleep?
- Did the laptop wake?
- Is active battery drain higher than expected?
- Is Windows reporting a useful runtime estimate?

Remaining-time fields:

- `Average`: based on recent logged battery drop.
- `Now`: based on current discharging rate. While charging, PowerPilot uses the average estimate.
- `Windows`: Windows or firmware estimate.
- `Full-to-min`: average estimate from your configured full point down to your configured empty point.
- `As new`: the same full-to-empty estimate scaled to the battery's original design capacity.

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
- `Log every`: how often a battery row is saved.
- `Read every`: how often live battery data is read while the window is open. The default is 5 seconds; tray mode backs off to about 5 minutes.
- `Empty at`: the percent used as the empty point for estimates. It can be 0%; Windows critical sleep is kept at least 1% when plans are written.
- `Full at`: the percent used as the full point for discharging estimates and the target for charging estimates.
- `Use charge limit`: use your laptop charging limit instead of 100%.
- `Average window`: how much recent battery history is averaged.
- `Startup estimate`: temporary drain estimate used right after app start.
- `Reset log`: clears retained log rows, graph history, and current estimate learning.

PowerPilot keeps a capped learned charging rate in user settings, up to 32 recent charging-learning updates, so future time-to-full estimates can start closer before fresh charging history builds.

Copy buttons:

- `Copy rows`: copies selected rows, or the newest visible row if nothing is selected.
- `Copy CSV`: copies the full retained CSV.

### Battery Stats

Use Battery Stats for summaries.

- `Latest Power Event`: last sleep, wake, shutdown, startup, hibernate, or improper shutdown event.
- `Sleep/Off Battery Loss`: battery lost across sleep, hibernate, shutdown, startup, or large missing-sample gaps.
- `Daily Battery Summary`: today's range, active battery time, active drain, wear, and cycles.
- `Shown Log Columns`: hides or shows optional log columns, including average time, now/rate, Windows time, plugged-in state, battery watts, screen event, laptop brightness, and event rows including Energy Saver changes.
- `Settings Backup`: manual export/import of PowerPilot settings.

During vendor battery calibration, Windows can report plugged in and discharging at the same time. PowerPilot treats that as active battery use while still showing that external power is present.

`Avg active drain` is the average battery drop per hour while awake and on battery. `Total battery used today` adds up each on-battery discharging period. Example: 80% to 60% counts as 20%; after charging back to 90%, 90% to 70% counts as another 20%. Recharging does not subtract from the total, so the value can go over 100% in one day.

Settings backup is optional. PowerPilot normally keeps settings during updates when `Keep settings` is enabled.

### Power Use

Use Power Use to see PowerPilot's own estimated cost.

PowerPilot watches its own process CPU time over a 60-second window and estimates how much of the current battery drain belongs to PowerPilot. This is useful for checking whether the app itself is unusually active.

When plugged in, PowerPilot keeps the estimate active by using the current full-charge capacity and learned average discharging rate as the battery discharging basis.

`PowerPilot CPU time in that 60s` is CPU time accumulated by the PowerPilot process during the last 60 seconds. It can be much lower than 60 seconds when PowerPilot is mostly idle.

`CPU load` is shown as a share of total logical CPU capacity, not as a share of one core. This matches the mW estimate below it.

`Full-to-empty battery cost` estimates how many seconds of battery runtime PowerPilot may consume across your configured `Full at` to `Empty at` range. `About 5 sec` is very small; it means PowerPilot itself is estimated to cost about five seconds across that whole usable battery window if the same app CPU share continued.

It is an estimate, not a hardware meter.

The lower half explains how to read the numbers and gives a short idle-investigation checklist. It is useful when comparing tray-hidden, visible-window, screen-on, and screen-off behavior.

### Battery Test

Use Battery Test to monitor a battery run or vendor calibration workflow.

- `Manual discharge test`: starts a report and prompts you to unplug.
- `Lenovo reset`: waits for the charger, starts the saved drain helper target during Lenovo plugged-in discharge, stops load when charging starts, and saves a `.txt` report when charging reaches idle.
- `Vendor calibration detected`: appears automatically when Windows reports plugged in and discharging.
- `Charge recovery`: tracks charging back to the configured full target.
- `Open report`: opens the latest saved Battery Test report. `Copy report` copies start/end percent, mWh moved, average watts, observed runtime, and capacity notes.
- `CPU Load`: automatically targets a chosen drain time with filtered PI-style load changes about every 10 seconds, starting at 25%, and stops when charging starts. `Test mode` adds detailed controller rows for normal unplug tuning runs.
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
- author information
- MIT license information and where to find the full installed `LICENSE.txt` file
- `Open README` and `Open LICENSE` buttons for opening the bundled guide and license text in the user's chosen `.txt` editor
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
- enables tray startup for the current user
- launches PowerPilot after install
- runs post-install commands and the tray app as the current user without UAC elevation
- keeps existing user settings when that preference is enabled
- installs newer stamped app versions side-by-side
- writes `PowerPilot update close` when replacing a running copy
- lets the newly installed app close older PowerPilot versions in the background
- removes stale old versioned app files
- repairs missing PowerPilot plans during normal updates
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
