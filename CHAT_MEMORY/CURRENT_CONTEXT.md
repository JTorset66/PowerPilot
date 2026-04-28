# Current Context

Last updated: 2026-04-19

## Active summary

- `PowerPilot_V1.0.pb` was rebuilt successfully into `build\PowerPilot_V1.0.exe`.
- The installer was rebuilt successfully into `build\PowerPilot_V1.0_Setup.exe`.
- The latest local installer run completed successfully on `2026-04-19` and relaunched PowerPilot in the tray.
- The recent PowerPilot changes now cover three areas:
  - dGPU-aware plan handling
  - manual display recovery
  - adjustable Auto GameCool averaging from the Control tab

## dGPU behavior summary

- PowerPilot now tracks a separate remembered plan for active `dGPU` or `eGPU` use.
- The dGPU rule now follows GPU detection itself, not only AC reconnect.
- That means a connected active dGPU on battery can still hold the remembered dGPU plan instead of always falling back to `Battery Saver`.

## Manual recovery summary

- Manual Override now has a `Reset Display` button.
- The button sends the standard Windows graphics reset hotkey `Win+Ctrl+Shift+B`.
- This gives a software recovery path for black-screen external-display problems without requiring a full power cycle.

## Control summary

- Control now includes a saved `GameCool avg (sec)` setting.
- Auto GameCool uses that saved averaging window instead of a fixed 10-second window.

## Important operational note

- Build verification is current.
- Completed installer assembly is current.
- A full local installer run was re-verified from `build\install-run.log`.
- The successful install log shows `Installation process succeeded.` at `2026-04-19 19:34:33 +08:00` and `Need to restart Windows? No` at `2026-04-19 19:34:49 +08:00`.

## Reminder

- Take regular snapshots or commits during active work.
- Snapshot before installer changes, major plan logic changes, or any risky power-management edits.
