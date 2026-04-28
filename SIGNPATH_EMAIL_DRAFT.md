Subject: SignPath Foundation application for PowerPilot

Hello SignPath Foundation team,

I would like to apply for SignPath Foundation signing for PowerPilot.

PowerPilot is a Windows x64 PureBasic tray application for managing custom Windows power plans. It can switch between battery, plugged-in, Full Power, and Auto Cool plans using CPU package power and temperature readings from Windows.

Repository:
https://github.com/JTorset66/PowerPilot

License:
GPL-3.0

Maintainer:
John Torset

Expected release artifacts:
- PowerPilot_V1.0.exe
- PowerPilotWindowsPmiHelper.exe
- PowerPilotWindowsPerfHelper.exe
- PowerPilotWindowsEmiHelper.exe
- PowerPilot_V1.0_Setup.exe
- SHA-256 checksum files for published executables

Why code signing is needed:
PowerPilot is distributed as a Windows desktop executable and installer. Trusted code signing would help users verify that published binaries come from the public repository and would reduce Windows trust friction for open-source releases.

Repository readiness:
- The repository is public.
- The project uses GPL-3.0.
- The repository includes a code signing policy.
- The repository includes a release checklist.
- The repository includes a self-hosted Windows GitHub Actions workflow for release builds.
- The build scripts support signing with a certificate installed in the Windows certificate store.
- The README includes build, installer, privacy, and release notes.

Privacy and user safety:
PowerPilot does not transfer information to other networked systems unless specifically requested by the user or the person installing or operating it. It reads local Windows telemetry for temperature, CPU package power, GPU names, and VRAM display. It changes only local Windows power plans and the Windows startup entry needed for tray launch.

Current status:
The first public release is still pending. Current local binaries may be unsigned because SignPath onboarding is not yet complete.

Thank you for your consideration.
