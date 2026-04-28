# SignPath Foundation Application Draft

This document collects the information needed to apply for a free SignPath.io subscription through SignPath Foundation.

## Project summary

- Project name: PowerPilot
- Project handle: powerpilot
- Repository: <https://github.com/JTorset66/PowerPilot>
- Latest public release: not published yet
- License: GPL-3.0
- Maintainer: John Torset
- Primary platform: Windows x64
- Project description: PureBasic tray application for managing custom Windows power plans, CPU-package-power Auto Cool levels, temperature protection, startup behavior, and clean install/uninstall handling

## Why this project fits the program

- The repository is public.
- The project uses an OSI-approved open-source license.
- Release artifacts are built from the repository source.
- The repository includes a public code signing policy and privacy statement.
- The application does not include network telemetry or data transfer unless explicitly requested by the user or operator.
- The project is a user-facing Windows desktop utility where trusted code signing materially improves install and run experience.

## Current public links

- Repository home: <https://github.com/JTorset66/PowerPilot>
- Code signing policy: <https://github.com/JTorset66/PowerPilot/blob/main/CODE_SIGNING_POLICY.md>
- Release checklist: <https://github.com/JTorset66/PowerPilot/blob/main/RELEASE_CHECKLIST.md>
- Release workflow: <https://github.com/JTorset66/PowerPilot/blob/main/.github/workflows/release-self-hosted.yml>

## Expected release artifacts

- `PowerPilot_V1.0.exe`
- `PowerPilotWindowsPmiHelper.exe`
- `PowerPilotWindowsPerfHelper.exe`
- `PowerPilotWindowsEmiHelper.exe`
- `PowerPilot_V1.0_Setup.exe`
- SHA-256 checksum files for published executables

## Compliance notes against SignPath Foundation terms

### License and source availability

- All repository content intended for release is open source under GPL-3.0.
- There is no commercial dual-licensing statement in the repository.
- The project does not intentionally bundle proprietary maintainer-owned components.

### Released and documented

- The repository README describes the software, build requirements, runtime notes, installer behavior, and usage.
- The repository includes a release checklist and a self-hosted Windows GitHub Actions workflow.
- The first public release is still pending, so current binaries may be unsigned until signing onboarding is complete.

### Privacy and user safety

- The project states: "This program does not transfer information to other networked systems unless specifically requested by the user or the person installing or operating it."
- PowerPilot reads local Windows telemetry for temperature, CPU package power, GPU names, and VRAM display.
- PowerPilot changes only local Windows power plans and the Windows startup entry needed for tray launch.
- The project is not a hacking tool and does not include features intended to bypass platform security controls.

### Roles and approvals

- Committer and reviewer: John Torset
- Release signing approver: John Torset

### Build and signing readiness

- The repository includes a self-hosted Windows GitHub Actions workflow for release builds.
- The build scripts support signing with a certificate installed in the Windows certificate store.
- The release process is documented in `RELEASE_CHECKLIST.md`.
- The repository includes a code signing policy that uses the required SignPath Foundation wording.

## Honest caveats to mention if asked

- The project is newly public and currently has limited external reputation.
- The first public release has not been published yet.
- Current local binaries may be unsigned because SignPath onboarding is not yet complete.
- The self-hosted Windows build workflow is present in the repository, but actual SignPath integration still depends on onboarding and runner setup.

## Suggested form/email answers

### Short project description

PowerPilot is a Windows x64 PureBasic tray application for managing custom Windows power plans. It can switch between battery, plugged-in, Full Power, and Auto Cool plans using CPU package power and temperature readings from Windows.

### Why code signing is needed

PowerPilot is distributed as a Windows desktop executable and installer. Trusted code signing would help users verify that published binaries come from the public repository and would reduce Windows trust friction for open-source releases.

### Why SignPath should consider it

The project is fully open source, documented, and already includes a public code signing policy, privacy statement, release checklist, and source-controlled release workflow. PowerPilot distributes Windows executables directly to end users, making repository-to-binary verification especially valuable.
