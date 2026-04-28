# powerpilot ui gpu devices and helper architecture

Saved: 2026-04-22 02:17:49 +08:00

Session summary for resume:

- Updated PowerPilot live telemetry UI to remove the bottom standalone GPU Power section and repurpose the old fallback area into a GPU Devices summary.
- Kept Windows GPU power readings in the Windows Telemetry section.
- Improved readability of several UI labels and explanatory text.
- Added GPU device-name support to the telemetry display path so GPU load, memory, and power can show a GPU name when Windows exposes one.
- Extended WindowsPerfRefresherHelper to emit WINDOWSGPUDEVICE lines using Win32_VideoController names.
- Updated build-helpers.ps1 so the perf helper builds with System.Management.
- Rebuilt PowerPilot_V1.0.exe, rebuilt PowerPilot_V1.0_Setup.exe, and previously verified install-powerpilot.ps1 completed successfully.

Design discussion notes:

- Preferred long-term language for future expansion: C#, but PureBasic remains the best fit for small native standalone binaries in the current codebase.
- Helper executables can be implemented in PureBasic too.
- A single PureBasic source file is feasible for app plus helper modes, while still keeping separate helper processes at runtime.
- Helper processes could be replaced with threads, but separate processes are safer for isolation and restart behavior.
