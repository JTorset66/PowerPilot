# PowerPilot Framework Documentation

This folder is the build-from-scratch framework for PowerPilot. It describes how the app is structured, how the GUI is laid out, how settings and algorithms behave, and how the installer is built.

Read in this order:

1. `DESIGN_FRAMEWORK.md` - intended clean design, target program flow, module boundaries, and rebuild strategy.
2. `APPLICATION_FRAMEWORK.md` - current source layout, runtime model, owned data, and core boundaries.
3. `DEFAULTS_AND_SETTINGS.md` - first-install defaults and how settings become user-owned after first run.
4. `GUI_AND_WORKFLOWS.md` - tab layout, Battery Test workflows, Lenovo calibration reset, reports, and user actions.
5. `ALGORITHMS_AND_LOGIC.md` - power-plan mapping, battery estimates, logging, graphing, drain helper, and completion rules.
6. `BUILD_INSTALLER_AND_ASSETS.md` - PureBasic build, installer build, icons, tray assets, bundled docs, and install behavior.
7. `VERIFICATION_CHECKLIST.md` - logic checks, GUI checks, build checks, installer checks, and release checks.

The implementation source is `PowerPilot_V1.2.pb`. The framework documents intentionally name the main procedures and files so a clean implementation can be rebuilt without relying on memory.
