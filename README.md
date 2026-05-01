# PowerPilot

PowerPilot is a PureBasic x64 Windows tray application for managing three local Windows power plans:

- `PowerPilot Maximum`
- `PowerPilot Balanced`
- `PowerPilot Battery`

The app creates or refreshes those plans from the currently selected Windows power plan, then applies PowerPilot's tuned CPU behavior settings on top. It watches Windows power mode while open or hidden in the tray and follows Best performance, Balanced, or Best power efficiency. It no longer uses temperature, package-power telemetry, Auto Control, or helper executables.

## Main Features

- PureBasic x64 tray application
- three-plan maker/editor based on the selected Windows plan
- manual activation of Maximum, Balanced, or Battery
- automatic Maximum, Balanced, or Battery activation based on Windows power mode
- automatic refresh from a newly selected non-PowerPilot Windows plan
- CPU information from inline CPUID assembly
- GPU names and PCI IDs from Windows display adapter enumeration
- startup-in-tray support
- standard Inno Setup installer with uninstall support

## Hardware Information

PowerPilot shows static local hardware information only:

- CPU brand, vendor, family/model/stepping
- core/thread topology when CPUID exposes it
- cache summary
- CPU feature summary such as AVX2, AVX-512, AES, SHA, BMI, and virtualization
- installed system memory
- GPU display adapter names, vendor IDs, device IDs, and active/primary flags

PowerPilot does not read live CPU temperature, live package watts, fan speed, or live GPU telemetry.

## Build Requirements

- PureBasic x64
- Windows target
- Thread Safe runtime enabled
- Inno Setup 6 for installer builds

## Command-Line Build

Build the application:

```powershell
.\build-purebasic.ps1
```

Build the installer:

```powershell
.\build-installer.ps1
```

The installer build produces:

- `build\PowerPilot_V1.0.exe`
- `build\PowerPilot_V1.0_Setup.exe`

To sign the project-owned executables with a certificate already installed in the Windows certificate store:

```powershell
.\build-installer.ps1 -CertificateThumbprint "<YOUR_CERT_THUMBPRINT>"
```

## Installer Behavior

The installer:

- installs into `Program Files\PowerPilot`
- registers the app to start with Windows using `/tray`
- launches the app into the notification area after installation
- removes old PowerPilot helper files from earlier builds if present
- calls the app to remove and recreate only the PowerPilot plans it owns

The uninstall path removes:

- the installed files
- the Windows startup entry
- the PowerPilot plans
- any legacy `Codex *` plans from the prototype

## Command-Line Options

```text
/tray
/show
/create-plans
/cleanup-plans
/startup-on
/startup-off
/query-keep-settings
/cleanup-settings
```

## Privacy

PowerPilot does not transfer information to networked systems unless explicitly requested by the user or operator. Hardware information is read locally from CPUID and Windows display adapter enumeration.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

## Author

John Torset
