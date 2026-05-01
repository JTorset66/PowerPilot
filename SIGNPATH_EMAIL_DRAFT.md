Subject: SignPath Foundation application for PowerPilot

Hello SignPath Foundation team,

I would like to apply for SignPath Foundation signing for PowerPilot.

PowerPilot is a Windows x64 PureBasic tray application for managing three fixed local Windows power plans: Maximum, Balanced, and Battery. The Plans tab lets users edit those fixed plans directly, and PowerPilot follows Windows power mode to choose which managed plan should be active.

Repository:
https://github.com/JTorset66/PowerPilot

License:
MIT

Maintainer:
John Torset

Expected release artifacts:
- PowerPilot_V1.0.exe
- PowerPilot_V1.0_Setup.exe
- SHA-256 checksum files for published executables

Why code signing is needed:
PowerPilot is distributed as a Windows desktop executable and installer. Trusted code signing would help users verify that published binaries come from the public repository and would reduce Windows trust friction for open-source releases.

Repository readiness:
- The repository is public.
- The project uses the MIT License.
- The repository includes a code signing policy.
- The repository includes a release checklist.
- The repository includes a user-focused installer README and third-party notices.
- The repository includes a self-hosted Windows GitHub Actions workflow for release builds.
- The build scripts support signing with a certificate installed in the Windows certificate store.
- The README includes build, installer, privacy, and release notes.
- The installer bundles the README, license, and third-party notices, and offers buttons to read them before installation.

Privacy and user safety:
PowerPilot does not transfer information to other networked systems unless specifically requested by the user or the person installing or operating it. It reads local CPU identification through CPUID and local GPU display-adapter names through Windows display enumeration. It changes only local Windows power plans and the Windows startup entry needed for tray launch.

Current status:
The first public release is still pending. Current local binaries may be unsigned because SignPath onboarding is not yet complete.

Thank you for your consideration.
