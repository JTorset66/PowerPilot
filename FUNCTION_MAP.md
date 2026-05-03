# PowerPilot Function Map

This map describes the current `PowerPilot_V1.1.pb` source layout so stale code and documentation drift are easier to spot during release work.

## Startup Flow

1. Load settings with `LoadSettings`.
2. Resolve the selected plan with `PlanIndexByName`.
3. Handle command-line maintenance commands such as `/install-refresh`, `/cleanup-old-versions`, `/log-update-close-if-powerpilot-running`, `/startup-on`, and `/cleanup-settings`.
4. Start the GUI with `RunGui`, which creates the window, tray icon, timers, startup log rows, graph history, and first battery refresh.
5. The timer loop calls `MonitorAutomaticPlans`, `RefreshBattery`, and `RefreshDisplay`.

## Core Settings And Utility

- Path and text helpers: `QuoteArgument`, `SettingsDirectory`, `SettingsPath`, `EnsureSettingsDirectory`, `CleanPlanText`, `ClampInt`, `PowerShellLiteral`.
- Settings lifecycle: `LoadSettings`, `SaveSettings`, `UpgradeSettingsIfNeeded`, `CleanupSettingsData`, `ExportSettings`, `ImportSettings`; PowerPilot Log column width helpers persist user-resized columns.
- UI feedback: `LogAction` updates the Overview `Last action` text and writes a shortened `app` row to the PowerPilot Log through `ShortStatusLogText`.
- Process helpers: `ProgramWaitTimedOut`, `RunExitCode`, `RunCapture`, `PowerShellCapture`.

## Fixed Plan Model

- Plan defaults and validation: `AddPlan`, `LoadDefaultPlan`, `LoadDefaultPlans`, `ClampPlanValues`, `PlanMatchesValues`.
- Plan lookup and naming: `PlanIndexByName`, `NormalizePlanName`, `IsManagedPlanName`.
- Power-mode mapping: `IsEfficiencyPowerMode`, `PowerModeTextFromGuid`, `TargetPlanForPowerModeGuid`, `TargetPlanForWindowsPlan`.
- Windows plan commands and cache: `RunPowerCfg`, `RunPowerCfgCapture`, `FindGuidInText`, `RefreshSchemeCache`, `InvalidateSchemeCache`, `GetActiveSchemeGuid`, `GetSchemeGuidByName`, `GetSchemeNameByGuid`.
- Power API fallback: `EnsurePowerApi`, `ReadPowerGuidValue`, `GetActiveSchemeGuidByApi`, `GetWindowsPowerModeGuid`, `CurrentPowerSupplyIsBattery`.
- Plan creation and cleanup: `DuplicateBaseScheme`, `EnsurePlanInstalled`, `DeleteManagedPlanCopies`, `CreateManagedPlansFromBase`, `CreateManagedPlans`, `ManagedPlansInstalled`, `InstallRefresh`, `CleanupManagedPlans`.
- Plan application: `SetSchemeValue`, `TrySetSchemeValue`, `SetFrequencyCaps`, `ConfigureBatterySleepFloor`, `ApplyBatterySleepFloorToManagedPlans`, `ConfigureScheme`, `ActivatePlanByName`, `ApplyWindowsPowerFollow`, `MonitorAutomaticPlans`.

## Battery Telemetry And Estimates

- Battery formatting and parsing: `BatteryLogPath`, `IsoTimestamp`, `BatteryLogHeader`, `CleanBatteryEventName`, `BatteryFieldValue`, `BatteryBool`, `BatteryEffectiveMaxPercent`, `FormatBatteryMinutes`, `FormatDurationSeconds`.
- Live reads: `QueryBatteryStatic` reads full-charge capacity, design capacity, wear, and cycle count; `QueryBatteryStatus` reads `root\wmi:BatteryStatus`, converts `root\wmi:BatteryRuntime.EstimatedRuntime` seconds to minutes, and falls back to `Win32_Battery.EstimatedRunTime`.
- Refresh pipeline: `RefreshBattery`, `UpdateBatteryEstimate`, `WriteBatteryLog`, `RefreshBatteryDisplay`.
- Average drain logic: `BatteryAverageDrainPctPerHour`, `ResetBatteryAverageSamples`, `BatteryFullLogDrainPctPerHour`, `AutoSetInitialBatteryDrainFromLog`.
- Break handling: `AddBatteryAverageBreak`, `AddBatteryAppBreak`, `BatteryEventBreaksAverage`, `BatteryIntervalHasAverageBreak`, `BatteryIntervalHasAppBreak`, `BatteryIntervalHasPowerBreak`, `BatteryGraphFlatGapSeconds`.

## PowerPilot Log And Events

- Retention: `PruneBatteryLog` keeps the CSV to the configured 168-hour retention cap.
- Graph load: `LoadBatteryGraphFromLog` rebuilds the in-memory graph from retained CSV rows at startup.
- Power event detection: `CurrentBootTime`, `LastBatteryEventName`, `RecentResumeEventName`, `CleanupAppCloseShutdownEvents`, `LogStartupPowerEvents`.
- Log writers: `WriteBatteryLog` writes battery sample rows, `WriteBatteryEvent` writes PC power-event rows, and `WriteBatteryAppEvent` writes app lifecycle/status rows.
- Log UI: `RefreshBatteryLogPreview` fills the PowerPilot Log tab from the full retained CSV, `CaptureBatteryLogColumnWidths` / `ApplyBatteryLogColumnWidths` keep user column sizing, `BatteryLogPreviewRowText` formats selected rows, `CopyBatteryLogRow` supports multi-row copy, and `CopyBatteryLogAll` copies the full retained CSV.

## Battery Graph And Stats

- In-memory graph: `AddBatteryGraphPoint`, `PruneBatteryGraph`, `BatteryGraphIndexBefore`, `BatteryGraphIndexAfter`.
- Event markers: `AddBatteryEventPoint`, `PruneBatteryEvents`, `BatteryEventShortName`.
- Summaries: `RefreshBatteryStatsSummary` updates session, off-time battery loss, and daily battery summary text.
- Drawing: `DrawBatteryGraph` renders the gliding 24-hour graph, hour/date marks, endpoint-to-endpoint gap segments, and event markers.

## Hardware Information

- CPU primitives: `Cpuid`, `XGetBv0`, `HasBit`.
- CPU display text: `CpuVendor`, `CpuBrand`, `CpuFamilyModelText`, `CpuTopologyText`, `CpuFeatureText`, `CpuCacheText`, `BuildCpuInfo`, `CpuInfo`.
- Memory formatting: `FormatBytes`, `SystemMemoryText`, `FormatCacheSize`.
- GPU display text: `BuildCpuMatchText`, `CpuMatchAny`, `IsGenericAmdIntegratedGpuName`, `ResolveAmdGraphicsCuName`, `ResolveAmdIntegratedGpuName`, `CpuInferredIntegratedGpuName`, `NormalizeGpuHardwareName`, `IsLikelyIntegratedGpuName`, `VendorNameFromPciId`, `PciSummary`, `IsUsefulGpuName`, `BuildGpuInfo`, `GpuInfo`.

## Process And Installer Support

- Startup registry: `SetStartupRegistry`.
- Versioned app cleanup: `IsPowerPilotVersionedExeName`, `PowerPilotVersionFromExeName`, `CompareVersionStrings`, `CleanupOldPowerPilotVersions`, `LogUpdateCloseIfSameExeRunning`, `LogUpdateCloseIfAnyPowerPilotRunning`.
- Maintenance throttling: `EnsureProcessThrottleApi`, `ForegroundProcessId`, `IsMaintenanceThrottleProcessName`, `SetProcessEcoThrottle`, `ApplyMaintenanceThrottling`.
- Shutdown lifecycle: `ShutdownApp`, `MainWindowCallback`.

## UI Construction And Event Handling

- Window and tray: `CreateMainWindow`, `CreateTrayMenu`, `SetupTray`, `HideToTray`, `ShowFromTray`, `MainWindowVisible`.
- Timer handling: `DesiredRefreshInterval`, `StartRefreshTimer`, `RefreshActiveTimer`.
- UI helpers: `SetGadgetTextIfChanged`, `EnsureUiFonts`, `UseBoldFont`, `SetTip`, `ApplyToolTips`.
- Plan UI: `ReadPlanEditor`, `RefreshPlanEditor`, `RefreshPlanList`, `SavePlanEditor`, `ResetSelectedPlan`.
- Battery/settings UI: `ApplySettingsToGui`, `ScheduleBatterySettingsApply`, `ApplyPendingBatterySettings`, `SaveBatterySettingsFromGui`, `ResetBatteryStats`, `SaveSettingsFromGui`.
- Dispatch: `HandleAction`, `HandleMenu`, `RunGui`.

## Current Cleanup Notes

- The old visible bottom status field has been removed. Status feedback is now retained as shortened `app` rows in the PowerPilot Log.
- Unused wrapper procedures from older UI/timer flows were removed during the v1.1 cleanup pass.
- `PowerPilot_V1.0.pb` is obsolete for v1.1 and should stay out of release packages.
- The repository `pb_*test*.pb` files are local PureBasic experiments and are not included by the installer.
