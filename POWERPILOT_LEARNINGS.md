# PowerPilot Learnings

This file records design principles and debugging lessons agreed during PowerPilot work.
Read it before changing `PowerPilot_V1.1.pb`, especially graph, logging, installer, DPI, or UI event behavior.

## Maintenance Rule

- When a change establishes or corrects a general principle, update this file in the same work session.
- Prefer principles that prevent repeat mistakes over long descriptions of one bug.
- Keep entries short, practical, and tied to PowerPilot behavior.
- If a visible behavior changes, update the user docs and installer docs when relevant.

## UI Responsiveness

- Display-only controls must not use heavy settings handlers.
- A graph-only checkbox or combo should save only its own display state, update the relevant title/control if needed, and redraw the graph.
- Do not force `RefreshBattery(#True)`, `ApplySettingsToGui()`, or log-preview refreshes for visual-only graph changes.
- Use broader battery settings handlers only for controls that change battery polling, estimates, plan writes, or retained data.

## UI Text And Tooltips

- Long tooltips should wrap centrally through the tooltip helper, not by hand in each call.
- Tooltips should be readable boxes, not screen-wide single lines.
- Keep tooltip text direct; if it needs many clauses, prefer several wrapped sentences.

## Battery Graph Markers

- Every vertical line that represents a meaningful event/state should have an identifier when marker letters are enabled.
- Marker letters are never suppressed just because space is tight; stack them vertically on the line instead.
- Debounce duplicated log events before drawing when the underlying event is a duplicate.
- Draw marker letters last, above graph lines and vertical lines.
- Marker glyphs use high contrast: white foreground with black offset/shadow/border.
- The marker legend must use the same contrast glyph style as the graph.
- If marker letters are disabled, hide both graph marker letters and the marker-letter legend.
- If marker letters are disabled, let the plot expand vertically into the space formerly used by the marker-letter legend.

## Marker Meaning And Order

- `Z` means sleep/suspend.
- `H` means hibernate.
- `W` means wake/resume.
- `S` means shutdown.
- `P` means startup.
- `!` means improper shutdown or bad power event.
- `0` means offline/discontinued start.
- `1` means online/continued again.
- `E` means Energy Saver.
- `N` means normal.
- Stacked letters on the same vertical line should represent the actual sequence consistently, not a left/right special case.

## Offline And Discontinued Graph Sections

- Offline/discontinued spans are orange.
- Do not invent a charge/discharge slope while the PC was off or samples are missing.
- Hold the last known percent flat during the offline/discontinued span, then jump vertically at the next observed sample.
- Use `0` for the start of the offline/discontinued span and `1` for the return to continuous/online samples.

## Logger Cleanup

- Logger cleanup may normalize old or noisy rows when new event logic makes a previous row misleading.
- Sleep/hibernate duplicates close together should debounce to one useful event marker.
- Wake duplicates close together should debounce to one useful event marker.
- Prefer fixing noisy logging at the source, then use cleanup for retained legacy rows when needed.

## Window Size And DPI

- Keep the normal opening window size at the established base size unless the user explicitly asks to change the opening size.
- Minimum window size may be reduced independently from opening size for snapping and small layouts.
- Preserve DPI awareness and draw graph images at DPI-scaled backing resolution so fonts and lines stay sharp at Windows scale settings.
- Scaling up should enlarge fonts and controls together; scaling down should keep controls usable and avoid clipping where practical.

## Build And Install

- After PureBasic source changes, run `.\build-purebasic.ps1`.
- After user-facing app changes, build the installer with `.\build-installer.ps1 -SkipSnapshot`.
- Install only when requested or when the user clearly expects the running tray app updated.
- After install, verify the running process path/version with `Get-Process PowerPilot*`.

## Power Plans

- Keep all PowerPilot-owned plans Balanced-derived so they remain visible on Modern Standby systems.
- Use hidden plan settings to create the performance/battery differences instead of changing the plan personality away from Balanced.
- Prefer `PowerSetActiveScheme` for activation and keep `powercfg /SETACTIVE` only as fallback.
- Installer refresh should reapply the full current plan policy to existing PowerPilot plans without deleting their GUIDs.
