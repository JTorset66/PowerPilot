# Code Signing Policy

This document describes how release binaries for PowerPilot are built, reviewed, and signed.

Free code signing provided by [SignPath.io](https://about.signpath.io), certificate by [SignPath Foundation](https://signpath.org).

Current status:

- This repository is preparing for a SignPath Foundation application.
- Until that application is approved and integrated, published binaries may be unsigned or signed through a separate trusted Windows code-signing setup controlled by the project maintainer.

## Project roles

- Committer and reviewer: John Torset
- Approver for release signing: John Torset

## Source of truth

- Primary repository: <https://github.com/JTorset66/PowerPilot>
- Default branch: `main`

Only binaries built from this repository and maintained by this project may be signed under this policy.

## Release build policy

- Release artifacts must be built from source in this repository.
- Builds should be produced by an automated workflow on a controlled Windows runner with PureBasic and Inno Setup installed.
- Release tags should use the format `v*`.
- Build scripts, installer scripts, and workflow definitions are part of the trusted source and must be reviewed with the same care as application code.

## Signing policy

- Only project-owned binaries may be signed.
- Third-party upstream executables and DLLs must not be re-signed as if they were project binaries.
- If signing is enabled for a release build, the signed artifact must come from the automated release workflow or an equivalent controlled maintainer-run process.

## User safety

- The project must not include malware, potentially unwanted software, or features intended to bypass platform security controls.
- System changes must be transparent to the user.
- The installer must provide a clear uninstall mechanism.
- Custom Windows power plans created by the project must be removable by the project.
