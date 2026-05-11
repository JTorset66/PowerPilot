EnableExplicit

; PowerPilot v1.1
; PureBasic-only Windows power-plan manager with local CPU/GPU identification.
; Author: John Torset.
;
; Design contract:
; - PowerPilot owns only its three named Windows power plans. Normal Windows plans
;   are read as base templates or restored on exit, but they are not tuned.
; - Runtime settings are local to the signed-in Windows user. Installer helper
;   commands may run elevated, but the tray app should persist HKCU/AppData data.
; - Battery data comes from Windows battery/display APIs and local retained CSV
;   rows. PowerPilot does not send telemetry or depend on a background service.
; - The UI is one fixed tab window with DPI/View scaling. When adding gadgets,
;   keep labels short and let tooltips/README carry secondary explanation.
;
; Source layout:
; - Constants, structures, globals, and forward declarations.
; - Settings and fixed-plan model.
; - Battery telemetry, retained PowerPilot log, graph, and estimates.
; - Windows power APIs, powercfg integration, and managed plan install/apply.
; - Hardware summary helpers for CPU/GPU display text.
; - GUI construction, event dispatch, tray behavior, and command-line entry.

#AppName$            = "PowerPilot"
#AppVersion$         = "1.1.2605.14550"
#AppFullName$        = #AppName$ + " v" + #AppVersion$
#AppRunKey$          = "PowerPilot"
#SettingsFolderName$ = "PowerPilot"
#SettingsFileName$   = "settings.ini"
#SettingsVersion = 20
#TrayTooltip$        = #AppFullName$

; PowerPilot owns exactly three Windows plans. The old "Codex" prefix is kept
; only so cleanup code can remove prototype plans from earlier builds.
#PlanPrefixNew$ = "PowerPilot "
#PlanPrefixOld$ = "Codex "
#PlanFull$      = "PowerPilot Maximum"
#PlanBalanced$  = "PowerPilot Balanced"
#PlanBattery$   = "PowerPilot Battery"

; Windows power-mode overlay GUIDs. Balanced is the all-zero overlay GUID used
; by Windows when no explicit performance/efficiency overlay is selected.
; The overlay is observed, then mapped to one of the three managed plans. The
; program intentionally does not expose a manual "activate this plan" button,
; because Windows power mode is the user-facing selector.
#PowerModeEfficiency$ = "961cc777-2547-4f9d-8174-7d86181b8a7a"
#PowerModeBalanced$   = "00000000-0000-0000-0000-000000000000"
#PowerModePerformance$ = "ded574b5-45a0-4f42-8737-46345c09c238"

; Windows Energy Saver is controlled through hidden power settings on each
; managed plan. PowerPilot writes both the policy and the threshold so the
; Battery plan can force Energy Saver while Maximum/Balanced can still follow
; the regular Windows threshold.
#EnergySaverFollowWindows = 0
#EnergySaverPowerPilotControlled = 1
#EnergySaverWindowsThreshold = 20
#EnergySaverDefaultBrightness = 70
#EnergySaverSubgroup$ = "de830923-a562-41af-a086-e3a2c6bad2da"
#EnergySaverPolicySetting$ = "5c5bb349-ad29-4ee2-9d0b-2b25270f7a81"
#EnergySaverThresholdSetting$ = "e69653ca-cf7f-4f05-aa73-cb833fa90ad4"
#EnergySaverBrightnessSetting$ = "13d09884-f74e-474a-a852-b6bde8ad03a8"
#EnergySaverPolicyUser = 0
#EnergySaverPolicyAggressive = 1

; Hidden Windows power-policy settings that sit outside the visible CPU plan
; editor. These values let the three fixed PowerPilot schemes behave like real
; Windows power personalities instead of only changing processor sliders. Most
; are written with TrySetSchemeValue because OEM firmware can omit individual
; settings, and a missing hidden setting should never break plan creation.
#NoSubgroup$ = "SUB_NONE"
#PowerPlanPersonalitySetting$ = "PERSONALITY"
#DeviceIdleSetting$ = "DEVICEIDLE"
#DisconnectedStandbyModeSetting$ = "DISCONNECTEDSTANDBYMODE"
#ConnectivityStandbySetting$ = "CONNECTIVITYINSTANDBY"
#PowerPlanPersonalityBalanced = 2
#DeviceIdlePerformance = 0
#DeviceIdlePowerSavings = 1
#DisconnectedStandbyNormal = 0
#DisconnectedStandbyAggressive = 1
#StandbyNetworkingDisabled = 0
#StandbyNetworkingEnabled = 1
#StandbyNetworkingManaged = 2

#GraphicsSubgroup$ = "SUB_GRAPHICS"
#GpuPreferencePolicySetting$ = "GPUPREFERENCEPOLICY"
#GpuPreferenceDefault = 0
#GpuPreferenceLowPower = 1

#PciExpressSubgroup$ = "SUB_PCIEXPRESS"
#PciExpressLinkStateSetting$ = "ASPM"
#PciExpressLinkOff = 0
#PciExpressLinkModerate = 1
#PciExpressLinkMaximum = 2

#DiskSubgroup$ = "SUB_DISK"
#DiskIdleSetting$ = "DISKIDLE"
#DisplaySubgroup$ = "SUB_VIDEO"
#DisplayIdleSetting$ = "VIDEOIDLE"
#SleepSubgroup$ = "SUB_SLEEP"
#SleepIdleSetting$ = "STANDBYIDLE"
#HibernateIdleSetting$ = "HIBERNATEIDLE"
#WakeTimersSetting$ = "RTCWAKE"
#WakeTimersDisabled = 0
#WakeTimersEnabled = 1

#BatteryPlanDisplayAcSeconds = 900
#BatteryPlanDisplayDcSeconds = 300
#BatteryPlanDiskDcSeconds = 300
#BatteryPlanSleepDcSeconds = 900
#BatteryPlanHibernateDcSeconds = 1800
#BatteryLowWarningDefaultPercent = 10
#BatteryReserveDefaultPercent = 7
#BatteryCriticalDefaultPercent = 5
#BatteryReserveLevelSetting$ = "f3c5027d-cd16-4930-aa6b-90db844a8f00"
#BatteryActionDoNothing = 0
#BatteryActionSleep = 1
#BatteryActionHibernate = 2
#BatteryActionShutdown = 3

#ERROR_SUCCESS = 0
#ERROR_ALREADY_EXISTS = 183

; Display-device and setup/battery IO constants used by the native Windows
; battery path. If native reads fail, PowerPilot falls back to WMI battery data.
#EDD_GET_DEVICE_INTERFACE_NAME = 1

#WindowMain = 1
#MainWindowBaseWidth = 760
#MainWindowBaseHeight = 560
#MainWindowMinScale = 0.585
#MainWindowMaxScale = 2.0
#MainWindowMinWidth = 445
#MainWindowMinHeight = 328
#UiFontMinSize = 5
#UiFontBaseSize = 8
#UiFontMaxSize = 16
#TooltipWrapColumn = 72
#ImageTray = 1
#TrayIconMain = 1
#PopupTray = 1
#TimerRefresh = 1
#TimerBatterySettingsApply = 2
#RefreshVisibleMs = 5000
#RefreshBatteryTestTabMs = 1000
#RefreshHiddenMs = 30000
#RefreshHiddenDeepIdleMs = 300000
#BatterySettingsApplyDelayMs = 1500
#ProgramTimeoutMs = 10000
#ThrottleScanMs = 30000

; Battery graph/log sizing. The CSV retention cap is the source of truth for
; how much history the PowerPilot Log tab and startup graph reload can show.
#BatteryGraphMaxPoints = 60000
#BatteryGraphDefaultHours = 24
#BatteryGraphMaxWindowSeconds = 259200
#BatteryGraphLongAppGapSeconds = 3600
#BatteryLogRetentionSeconds = 604800
#BatteryStaticRefreshSeconds = 86400
#BatteryDefaultLogMinutes = 5
#BatteryDefaultRefreshSeconds = 5
#BatteryHiddenRefreshSeconds = 300
#BatteryAverageMinSeconds = 300
#BatteryDuplicateEventSeconds = 10
#BatteryShutdownRequestGraceSeconds = 120
#BatteryChargeLearningCap = 32
#BatteryWmiTimeoutMs = 15000
#BatteryTestSampleSeconds = 60
#BatteryAutoDrainAdjustSeconds = 10
#BatteryDrainHelperTraceSeconds = 10
#BatteryCalibrationDefaultDrainMinutes = 120
#BatteryStableCapacityMinSamples = 3
#BatteryCapacityRecalibrationThreshold = 0.02
#BatteryLowGaugePercent = 7
#BatteryRollingMaxSamples = 96
#BatteryAutoDrainMinHoldSeconds = 20
#BatteryAutoDrainMaxStep = 10
#PowerPilotUseWindowSeconds = 60
#PowerPilotUseMaxPoints = 64
#TabBatteryGraph = 4
#TabBatteryTest = 7

#BatteryPhaseUnknown = 0
#BatteryPhaseOnBatteryNormal = 1
#BatteryPhaseCharging = 2
#BatteryPhasePluggedDischargingCalibration = 3
#BatteryPhasePluggedIdleOrFull = 4

#BatteryUseScreenOff = 1
#BatteryUseLowBrightness = 2
#BatteryUseActive = 3
#BatteryUseHighLoad = 4

; Window and power-broadcast messages used to distinguish real PC power events
; from installer/restart-manager app closes. CLOSEAPP is intentionally ignored
; as a PC shutdown marker elsewhere in the code.
#WM_QUERYENDSESSION = $0011
#WM_ENDSESSION = $0016
#WM_SETREDRAW = $000B
#WM_SETFONT = $0030
#WM_POWERBROADCAST = $0218
#WM_APP = $8000
#WM_POWERPILOT_UPDATE_CLOSE = #WM_APP + $66
#ENDSESSION_CLOSEAPP = $00000001
#PBT_APMSUSPEND = $0004
#PBT_APMRESUMECRITICAL = $0006
#PBT_APMRESUMESUSPEND = $0007
#PBT_APMPOWERSTATUSCHANGE = $000A
#PBT_APMRESUMEAUTOMATIC = $0012
#PBT_POWERSETTINGCHANGE = $8013
#DEVICE_NOTIFY_WINDOW_HANDLE = 0
#SWP_NOZORDER = $0004
#SWP_NOACTIVATE = $0010
#DisplayStateOff = 0
#DisplayStateOn = 1
#DisplayStateDimmed = 2
#BatteryLogVisibleColumns = 10

#BatteryIoctlQueryTag = $294040
#BatteryIoctlQueryInformation = $294044
#BatteryIoctlQueryStatus = $29404C
#BatteryInfoLevelInformation = 0
#BatteryInfoLevelEstimatedTime = 3
#BatteryPowerOnline = $00000001
#BatteryPowerDischarging = $00000002
#BatteryPowerCharging = $00000004
#BatteryCapacityRelative = $40000000
#SetupDigcfPresent = $00000002
#SetupDigcfDeviceInterface = $00000010
#SetupErrorNoMoreItems = 259
#BatteryFileShareRead = $00000001
#BatteryFileShareWrite = $00000002
#BatteryOpenExisting = 3
#BatteryGenericRead = $80000000
#BatteryGenericWrite = $40000000

; Process and EcoQoS constants. These are deliberately minimal so PowerPilot
; can throttle only safe background maintenance processes without a helper exe.
#TH32CS_SNAPPROCESS = $00000002
#PROCESS_TERMINATE = $0001
#PROCESS_SET_INFORMATION = $0200
#PROCESS_QUERY_LIMITED_INFORMATION = $1000
#ProcessPowerThrottling = 4
#PROCESS_POWER_THROTTLING_CURRENT_VERSION = 1
#PROCESS_POWER_THROTTLING_EXECUTION_SPEED = $1
#INVALID_HANDLE_VALUE = -1

Prototype.i PowerGetActiveSchemeProto(userRoot.i, *activeScheme)
Prototype.i PowerSetActiveSchemeProto(userRoot.i, *schemeGuid)
Prototype.i PowerGetGuidValueProto(*guid)
Prototype.i PowerReadValueIndexProto(userRoot.i, *schemeGuid, *subGroupGuid, *powerSettingGuid, *valueIndex)
Prototype.i RegisterPowerSettingNotificationProto(hRecipient.i, *powerSettingGuid, flags.l)
Prototype.i UnregisterPowerSettingNotificationProto(handle.i)
Prototype.i SetProcessInformationProto(processHandle.i, informationClass.i, *processInformation, processInformationSize.i)
Prototype.i GetProcessInformationProto(processHandle.i, informationClass.i, *processInformation, processInformationSize.i)
Prototype.i SetupDiGetClassDevsProto(*classGuid, enumerator.i, hwndParent.i, flags.l)
Prototype.i SetupDiEnumDeviceInterfacesProto(deviceInfoSet.i, deviceInfoData.i, *interfaceClassGuid, memberIndex.l, *deviceInterfaceData)
Prototype.i SetupDiGetDeviceInterfaceDetailProto(deviceInfoSet.i, *deviceInterfaceData, *deviceInterfaceDetailData, deviceInterfaceDetailDataSize.l, *requiredSize, deviceInfoData.i)
Prototype.i SetupDiDestroyDeviceInfoListProto(deviceInfoSet.i)

; Tray menu ids.
Enumeration 100
  #MenuOpen
  #MenuExit
EndEnumeration

; Gadget ids are centralized because PureBasic uses integer ids for event
; dispatch. Keep this list aligned with CreateMainWindow and HandleAction.
Enumeration 200
  #GadgetPanel
  #GadgetCpuInfo
  #GadgetGpuInfo
  #GadgetActivePlan
  #GadgetPowerSource
  #GadgetLastAction
  #GadgetOverviewBatteryState
  #GadgetOverviewSaverState
  #GadgetOverviewRuntime
  #GadgetOverviewPowerPilot
  #GadgetPlanList
  #GadgetPlanSummary
  #GadgetPlanAcEpp
  #GadgetPlanDcEpp
  #GadgetPlanAcBoost
  #GadgetPlanDcBoost
  #GadgetPlanAcState
  #GadgetPlanDcState
  #GadgetPlanAcFreq
  #GadgetPlanDcFreq
  #GadgetPlanAcCooling
  #GadgetPlanDcCooling
  #GadgetPlanSave
  #GadgetPlanReset
  #GadgetAutoStart
  #GadgetKeepSettings
  #GadgetThrottleMaintenance
  #GadgetDeepIdleSaver
  #GadgetEnergySaverMode
  #GadgetEnergySaverThreshold
  #GadgetEnergySaverBrightness
  #GadgetBatteryLowWarningPercent
  #GadgetBatteryReservePercent
  #GadgetBatteryLowAction
  #GadgetBatteryCriticalPercent
  #GadgetBatteryCriticalAction
  #GadgetRestoreNormalPlanOnExit
  #GadgetBatterySaverSummary
  #GadgetShowToolTips
  #GadgetHideToTray
  #GadgetExit
  #GadgetBatteryPercent
  #GadgetBatteryConnection
  #GadgetBatteryCharging
  #GadgetBatteryCapacity
  #GadgetBatteryRates
  #GadgetBatteryVoltage
  #GadgetPowerPilotDraw
  #GadgetBatteryEstimate
  #GadgetBatteryInstantEstimate
  #GadgetBatteryRuntime
  #GadgetBatteryFullEstimate
  #GadgetBatteryWear
  #GadgetBatteryNominalEstimate
  #GadgetBatteryMaxCapacity
  #GadgetBatteryCycle
  #GadgetBatteryGraphHours
  #GadgetBatteryGraphShowMarkers
  #GadgetBatteryGraph
  #GadgetBatteryLogEnabled
  #GadgetBatteryLogMinutes
  #GadgetBatteryRefreshSeconds
  #GadgetBatteryMinPercent
  #GadgetBatteryMaxPercent
  #GadgetBatteryLimiterEnabled
  #GadgetBatteryLimiterMaxPercent
  #GadgetBatterySmoothingMinutes
  #GadgetBatteryStartupDrain
  #GadgetBatteryStatsReset
  #GadgetBatteryLogCopyRow
  #GadgetBatteryLogCopyAll
  #GadgetBatteryLogPreview
  #GadgetBatterySessionSummary
  #GadgetBatteryDailySummary
  #GadgetBatteryOffLossSummary
  #GadgetBatteryAnalysisSummary
  #GadgetBatteryAnalysisRefresh
  #GadgetSettingsExport
  #GadgetSettingsImport
  #GadgetLogShowAverage
  #GadgetLogShowInstant
  #GadgetLogShowWindows
  #GadgetLogShowConnected
  #GadgetLogShowPower
  #GadgetLogShowScreen
  #GadgetLogShowBrightness
  #GadgetLogShowEvents
  #GadgetBatteryTestPhase
  #GadgetBatteryTestPercent
  #GadgetBatteryTestRemaining
  #GadgetBatteryTestWatts
  #GadgetBatteryTestEstimate
  #GadgetBatteryTestElapsed
  #GadgetBatteryTestStart
  #GadgetBatteryTestLenovo
  #GadgetBatteryTestEnd
  #GadgetBatteryTestCopy
  #GadgetBatteryTestOpenReport
  #GadgetBatteryTestMode
  #GadgetBatteryTestGuide
  #GadgetBatteryTestSummary
  #GadgetBatteryLoadStatus
  #GadgetBatteryLoadStep
  #GadgetBatteryLoadStop
  #GadgetBatteryLoadMinutes
  #GadgetBatteryLoadAuto
  #GadgetBatteryLoadAutoStatus
  #GadgetBatteryLoadTestMode
  #GadgetBatteryLoadNote
  #GadgetPowerUseSummary
  #GadgetPowerUseStatus
  #GadgetPowerUseInterpretation
  #GadgetPowerUseIdleChecklist
  #GadgetAboutPurpose
  #GadgetAboutOperation
  #GadgetAboutData
  #GadgetAboutVersion
  #GadgetAboutLicense
  #GadgetAboutOpenReadme
  #GadgetAboutOpenLicense
  #GadgetAboutBoundaries
EndEnumeration

; CPUID returns four 32-bit registers; q is used here to make bit operations
; and string extraction straightforward in PureBasic.
Structure CpuidRegs
  Eax.q
  Ebx.q
  Ecx.q
  Edx.q
EndStructure

; A fixed plan definition stores only the settings PowerPilot owns. Additional
; hidden Windows plan settings are applied in ConfigureScheme.
Structure PlanDefinition
  Name.s
  Description.s
  AcEpp.i
  AcBoostMode.i
  AcMaxState.i
  AcFreqMHz.i
  AcCooling.i
  DcEpp.i
  DcBoostMode.i
  DcMaxState.i
  DcFreqMHz.i
  DcCooling.i
EndStructure

; User settings live in %APPDATA%\PowerPilot\settings.ini. SettingsVersion is
; used by UpgradeSettingsIfNeeded to safely adjust defaults between releases.
; The structure is intentionally flat because PureBasic preference files are
; flat key/value stores. Keep field names stable: older settings files can omit
; new keys, and LoadDefaultSettings supplies the current default before reading.
Structure AppSettings
  ; Startup, installer, and UI preferences.
  AutoStartWithApp.i
  KeepSettingsOnReinstall.i
  ThrottleMaintenance.i
  DeepIdleSaver.i
  ShowToolTips.i

  ; Battery Saver tab. These values are written to PowerPilot-owned Windows
  ; plans while the tray app is running, then normal-plan restore can switch the
  ; user back to the last non-PowerPilot plan on exit.
  EnergySaverMode.i
  EnergySaverThreshold.i
  EnergySaverBrightness.i
  BatteryLowWarningPercent.i
  BatteryReservePercent.i
  BatteryLowAction.i
  BatteryCriticalPercent.i
  BatteryCriticalAction.i
  RestoreNormalPlanOnExit.i

  ; PowerPilot Log and Battery Graph settings. Empty/Full are estimate bounds;
  ; Windows low/critical battery actions belong to the Battery Saver fields.
  BatteryLogEnabled.i
  BatteryLogIntervalMinutes.i
  BatteryRefreshSeconds.i
  BatteryMinPercent.i
  BatteryMaxPercent.i
  BatteryLimiterEnabled.i
  BatteryLimiterMaxPercent.i
  BatterySmoothingMinutes.i
  BatteryStartupDrainPctPerHour.d
  BatteryLastDrainPctPerHour.d
  BatteryLastChargePctPerHour.d
  BatteryChargeLearningCount.i
  BatteryLastStaticQuery.q

  ; Battery Test and graph presentation.
  BatteryCalibrationDrainMinutes.i
  BatteryGraphHours.i
  BatteryGraphShowMarkers.i

  ; Battery Stats column visibility and retained column widths. Widths are
  ; stored individually rather than in an array so settings remain readable.
  BatteryLogShowAverage.i
  BatteryLogShowInstant.i
  BatteryLogShowWindows.i
  BatteryLogShowConnected.i
  BatteryLogShowPower.i
  BatteryLogShowScreen.i
  BatteryLogShowBrightness.i
  BatteryLogShowEvents.i
  BatteryLogColumn0Width.i
  BatteryLogColumn1Width.i
  BatteryLogColumn2Width.i
  BatteryLogColumn3Width.i
  BatteryLogColumn4Width.i
  BatteryLogColumn5Width.i
  BatteryLogColumn6Width.i
  BatteryLogColumn7Width.i
  BatteryLogColumn8Width.i
  BatteryLogColumn9Width.i

  ; LastBootTime prevents duplicate startup/shutdown summaries. NormalPlan* is
  ; the last non-PowerPilot plan seen, used only when restore-on-exit is enabled.
  LastBootTime.q
  SettingsVersion.i
  NormalPlanGuid.s
  NormalPlanName.s
  LastPlan.s
EndStructure

; Live battery state combines the native battery driver, WMI fallback,
; Win32_Battery runtime fallback, static capacity data, and PowerPilot estimate
; calculations. Values are deliberately cached here so all tabs render from the
; same snapshot and do not trigger separate battery-provider reads.
Structure BatteryTelemetry
  Valid.i
  Timestamp.q
  Percent.d
  Connected.i
  Charging.i
  DisconnectedBattery.i
  RemainingMWh.d
  FullMWh.d
  DesignMWh.d
  WearPercent.d
  DischargeRateMW.d
  ChargeRateMW.d
  VoltageMV.d
  CycleCount.i
  RuntimeMinutes.i
  RuntimeValid.i
  EstimateMinutes.i
  EstimateValid.i
  InstantEstimateMinutes.i
  InstantEstimateValid.i
  InstantDrainPctPerHour.d
  SmoothedDrainPctPerHour.d
  SmoothedChargePctPerHour.d
  EnergySaverOn.i
  StableFullMWh.d
  StableWearPercent.d
  EstimateLowConfidence.i
  LowBatteryPlateau.i
  Phase.i
EndStructure

; The graph keeps the battery state needed to color each interval. Event/app
; break arrays are separate so they can affect averages and drawing differently.
Structure BatteryGraphPoint
  Timestamp.q
  Percent.d
  Connected.i
  Charging.i
  DisconnectedBattery.i
  RemainingMWh.d
  FullMWh.d
  DischargeRateMW.d
  ChargeRateMW.d
  EnergySaverOn.i
  Phase.i
  ScreenOnKnown.i
  ScreenOn.i
  BrightnessPercent.i
EndStructure

Structure BatteryLogRow
  Timestamp.q
  BatteryPercent.d
  Connected.i
  Charging.i
  DisconnectedBattery.i
  RemainingMWh.d
  FullMWh.d
  DesignMWh.d
  WearPercent.d
  DischargeRateMW.d
  ChargeRateMW.d
  RuntimeMinutes.i
  AverageEstimateMinutes.i
  InstantEstimateMinutes.i
  InstantDrainPctPerHour.d
  SmoothedDrainPctPerHour.d
  CycleCount.i
  RowType.s
  EventName.s
  ScreenEvent.s
  ScreenBrightnessPercent.i
  EnergySaverOn.i
  Phase.i
EndStructure

Structure BatteryPowerEstimate
  Watts.d
  Count.i
  Valid.i
EndStructure

Structure BatteryAnalysis
  AnalysisTimestamp.q
  FirstBatteryTimestamp.q
  LastBatteryTimestamp.q
  BatteryRows.i
  ScreenRows.i
  TestRows.i
  EventRows.i
  NormalSpans.i
  ScreenOffSpans.i
  ScreenOnSpans.i
  ChargingSpans.i
  LatestStableFullMWh.d
  DesignMWh.d
  WearPercent.d
  NormalWatts.d
  ScreenOffWatts.d
  ScreenOnWatts.d
  LowPowerRuntimeMinutes.i
  ActiveRuntimeMinutes.i
  CalibrationSessions.i
  RecalibrationCount.i
  ChargingWatts.d
  ChargingSamples.i
  LowBatteryPlateau.i
  Warnings.s
EndStructure

Structure PowerPilotUsePoint
  Timestamp.q
  CpuTime100Ns.q
EndStructure

; PC power events are graph markers. App lifecycle/status rows stay in the CSV
; and average-break list, but are not drawn as PC shutdown/sleep markers.
Structure BatteryEventPoint
  Timestamp.q
  Name.s
EndStructure

; Windows PROCESS_POWER_THROTTLING_STATE layout for SetProcessInformation.
Structure ProcessPowerThrottlingState
  Version.l
  ControlMask.l
  StateMask.l
EndStructure

Structure GuidValue
  Data1.l
  Data2.w
  Data3.w
  Data4.a[8]
EndStructure

Structure DeviceInterfaceData
  cbSize.l
  InterfaceClassGuid.GuidValue
  Flags.l
  Reserved.i
EndStructure

Structure DeviceInterfaceDetailData
  cbSize.l
  DevicePath.c[1024]
EndStructure

Structure BatteryQueryInformation
  BatteryTag.l
  InformationLevel.l
  AtRate.l
EndStructure

Structure BatteryInformation
  Capabilities.l
  Technology.a
  Reserved.a[3]
  Chemistry.a[4]
  DesignedCapacity.l
  FullChargedCapacity.l
  DefaultAlert1.l
  DefaultAlert2.l
  CriticalBias.l
  CycleCount.l
EndStructure

Structure BatteryWaitStatus
  BatteryTag.l
  Timeout.l
  PowerState.l
  LowCapacity.l
  HighCapacity.l
EndStructure

Structure BatteryStatus
  PowerState.l
  Capacity.l
  Voltage.l
  Rate.l
EndStructure

; PROCESSENTRY32 layout for Toolhelp snapshots. PowerPilot uses this to find
; older versioned app executables without relying on external taskkill behavior.
Structure PowerPilotProcessEntry32
  dwSize.l
  cntUsage.l
  th32ProcessID.l
  *th32DefaultHeapID
  th32ModuleID.l
  cntThreads.l
  th32ParentProcessID.l
  pcPriClassBase.l
  dwFlags.l
  szExeFile.c[#MAX_PATH]
EndStructure

Structure UiChildLayout
  Hwnd.i
  Parent.i
  X.i
  Y.i
  Width.i
  Height.i
EndStructure

; Fixed plans and application state.
Global Dim gPlans.PlanDefinition(2)
Global gSettings.AppSettings
Global gSelectedPlan.i
Global gTrayReady.i
Global gStartedInTrayMode.i
Global gLastAction$
Global gCachedCpuInfo$
Global gCachedGpuInfo$
Global gCachedActiveGuid$
Global gCachedActiveName$
Global gCachedPowerModeGuid$
Global gCachedPowerModeText$
Global gSchemeCacheValid.i

; Timer state is intentionally tiny. The desired cadence is recalculated each
; time the window is shown/hidden or Battery Test becomes active, so the app
; only needs to remember whether a window timer currently exists.
Global gRefreshTimerActive.i
Global gBatterySettingsApplyPending.i

; UI scaling uses the original gadget rectangles captured after construction.
; The base list is rebuilt only when the window is created; resizing then scales
; every child window from those stable coordinates to avoid cumulative drift.
Global gFontUi.i
Global gFontBold.i
Global gUiFontSize.i
Global gUiScale.d = 1.0
Global gUiBaseClientWidth.i
Global gUiBaseClientHeight.i
Global gPowrProfLibrary.i
Global gPowerApiTried.i
Global gPowerGetActiveScheme.PowerGetActiveSchemeProto
Global gPowerSetActiveScheme.PowerSetActiveSchemeProto
Global gPowerGetEffectiveOverlayScheme.PowerGetGuidValueProto
Global gPowerGetUserConfiguredACPowerMode.PowerGetGuidValueProto
Global gPowerGetUserConfiguredDCPowerMode.PowerGetGuidValueProto
Global gPowerReadACValueIndex.PowerReadValueIndexProto
Global gPowerReadDCValueIndex.PowerReadValueIndexProto
Global gKernelLibrary.i
Global gThrottleApiTried.i
Global gSetProcessInformation.SetProcessInformationProto
Global gGetProcessInformation.GetProcessInformationProto
Global gSetupApiLibrary.i
Global gSetupApiTried.i
Global gSetupDiGetClassDevs.SetupDiGetClassDevsProto
Global gSetupDiEnumDeviceInterfaces.SetupDiEnumDeviceInterfacesProto
Global gSetupDiGetDeviceInterfaceDetail.SetupDiGetDeviceInterfaceDetailProto
Global gSetupDiDestroyDeviceInfoList.SetupDiDestroyDeviceInfoListProto
Global gBatteryDevicePath$
Global gUser32PowerLibrary.i
Global gDisplayNotifyTried.i
Global gDisplayPowerNotifyHandle.i
Global gEnergySaverNotifyHandle.i
Global gRegisterPowerSettingNotification.RegisterPowerSettingNotificationProto
Global gUnregisterPowerSettingNotification.UnregisterPowerSettingNotificationProto
Global gLastScreenEvent$
Global gLastScreenBrightnessPercent.i = -1
Global gEnergySaverStateKnown.i
Global gEnergySaverStateOn.i

; Automatic plan following and optional maintenance throttling state.
Global gMonitorInitialized.i
Global gLastObservedActiveGuid$
Global gLastObservedPowerModeGuid$
Global gMaintenanceThrottleActive.i
Global gLastMaintenanceThrottleScan.q
Global gSelfEcoThrottleActive.i

; Battery samples, retained-log reload state, and break/event arrays. Sleep,
; hibernate, shutdown, startup, and app lifecycle rows are represented as
; separate break arrays so estimates can exclude non-active time. The graph
; arrays are fixed-size to keep the tray app predictable and allocation-free
; during normal periodic refresh.
Global gBattery.BatteryTelemetry
Global gLastBatteryRefresh.q
Global gLastBatteryLogTime.q
Global gBatteryLastSampleTime.q
Global gBatteryLastSamplePercent.d
Global gBatteryOnBatterySince.q
Global gBatteryPowerStateKnown.i
Global gBatteryPowerStateConnected.i
Global gBatteryPowerStateCharging.i
Global gBatteryNativeFallbackUsed.i
Global gPowerPilotCpuWindowSeconds.d
Global gPowerPilotCpuWindowTotalPercent.d
Global gPowerPilotCpuWindowMw.d
Global gPowerPilotCpuWindowSecondsCost.d
Global gPowerPilotCpuWindowDrainBasisMW.d
Global gPowerPilotCpuWindowDrainBasisEstimated.i
Global gPowerPilotCpuWindowDrainBasisPctPerHour.d
Global gLastSuspendTime.q
Global gShutdownLogged.i
Global gBatteryTestActive.i
Global gBatteryTestHasSummary.i
Global gBatteryTestStartTime.q
Global gBatteryTestEndTime.q
Global gBatteryTestLastTime.q
Global gBatteryTestLastLogTime.q
Global gBatteryTestStartPercent.d
Global gBatteryTestEndPercent.d
Global gBatteryTestStartRemainingMWh.d
Global gBatteryTestEndRemainingMWh.d
Global gBatteryTestLastRemainingMWh.d
Global gBatteryTestUsedMWh.d
Global gBatteryTestChargedMWh.d
Global gBatteryTestDischargeSeconds.q
Global gBatteryTestChargeSeconds.q
Global gBatteryTestDischargeWattSeconds.d
Global gBatteryTestChargeWattSeconds.d
Global gBatteryTestCalibrationActive.i
Global gBatteryTestCalibrationKnown.i
Global gBatteryTestVendorAuto.i
Global gBatteryTestLenovoReset.i
Global gBatteryTestLenovoSawPluggedDrain.i
Global gBatteryTestLenovoSawCharging.i
Global gBatteryTestWorkflow$
Global gBatteryTestReportPath$
Global gBatteryCpuLoadTarget.i
Global gBatteryCpuLoadStop.i
Global gBatteryCpuLoadThreadCount.i
Global gBatteryAutoDrainActive.i
Global gBatteryAutoDrainMinutes.i = 120
Global gBatteryAutoDrainEndTime.q
Global gBatteryAutoDrainLastAdjust.q
Global gBatteryAutoDrainIntegral.d
Global gBatteryAutoDrainFilteredW.d
Global gBatteryAutoDrainReason$
Global gBatteryDrainHelperTestMode.i
Global gBatteryDrainHelperTraceLastTime.q
Global gBatteryLastSampleRemainingMWh.d
Global gBatteryFlatSampleCount.i
Global gBatteryStableFullMWh.d
Global gBatteryStableDesignMWh.d
Global gBatteryStableWearPercent.d
Global gBatteryCapacityCandidateMWh.d
Global gBatteryCapacityCandidateStartTime.q
Global gBatteryCapacityCandidateCount.i
Global gBatteryCapacityRecalibrationDetected.i
Global gBatteryScreenOffEstimate.BatteryPowerEstimate
Global gBatteryLowBrightnessEstimate.BatteryPowerEstimate
Global gBatteryActiveEstimate.BatteryPowerEstimate
Global gBatteryHighLoadEstimate.BatteryPowerEstimate
Global gBatteryNormalEstimate.BatteryPowerEstimate
Global gSingleInstanceMutex.i
Global Dim gBatteryCpuLoadThreads.i(63)
Global Dim gBatteryGraph.BatteryGraphPoint(#BatteryGraphMaxPoints - 1)
Global gBatteryGraphCount.i
Global Dim gBatteryAverageBreakTime.q(#BatteryGraphMaxPoints - 1)
Global gBatteryAverageBreakCount.i
Global Dim gBatteryAppBreakTime.q(#BatteryGraphMaxPoints - 1)
Global gBatteryAppBreakCount.i
Global Dim gBatteryEvents.BatteryEventPoint(#BatteryGraphMaxPoints - 1)
Global gBatteryEventCount.i
Global Dim gPowerPilotUsePoints.PowerPilotUsePoint(#PowerPilotUseMaxPoints - 1)
Global gPowerPilotUsePointCount.i
Global gIntroOverview.i
Global gIntroPlans.i
Global gFrameProcessor.i
Global gFrameState.i
Global gFrameOverviewBattery.i
Global gFrameStartup.i
Global gFrameManagedPlans.i
Global gFramePlanSettings.i
Global gFrameBatteryStatus.i
Global gFrameBatteryEstimate.i
Global gFrameBatteryGraph.i
Global gFrameBatterySettings.i
Global gWindowPreparingForDisplay.i
Global NewList gUiLayout.UiChildLayout()
Global NewList gUiBoldHwnds.i()

; Windows scheme cache maps both directions because UI refreshes often need
; names while plan application paths usually need GUIDs.
Global NewMap gSchemeGuidByName.s()
Global NewMap gSchemeNameByGuid.s()

Declare RefreshDisplay(force.i = #False)
Declare RefreshPlanList(force.i = #False)
Declare RefreshPlanEditor()
Declare ApplySettingsToGui()
Declare SaveSettingsFromGui()
Declare SaveSettings()
Declare.i CaptureBatteryLogColumnWidths(saveIfChanged.i = #False)
Declare ApplyBatteryLogColumnWidths()
Declare RefreshBattery(force.i = #False, forceLog.i = #False)
Declare RefreshBatteryDisplay()
Declare DrawBatteryGraph()
Declare RefreshPowerPilotDrawDisplay()
Declare RefreshPowerUseDetails()
Declare RefreshBatteryLogPreview()
Declare RefreshBatteryTest()
Declare RefreshBatteryTestDisplay()
Declare StartBatteryTestLog()
Declare StartLenovoCalibrationReset()
Declare EndBatteryTestLog()
Declare CopyBatteryTestReport()
Declare OpenLatestBatteryTestReport()
Declare StepBatteryCpuLoad()
Declare StartAutoDrainTarget()
Declare ToggleAutoDrainTarget()
Declare UpdateAutoDrainTarget(force.i = #False)
Declare StopBatteryCpuLoad(logEvent.i = #True)
Declare SetBatteryDrainHelperTestMode(enabled.i)
Declare WriteBatteryDrainHelperTrace(reason$, targetMinutes.d, currentMinutes.d, errorMinutes.d, measuredW.d, usableMWh.d, selectedLoad.i, force.i = #False, targetW.d = 0.0, errorW.d = 0.0, phase$ = "")
Declare RefreshBatteryCpuLoadDisplay()
Declare SaveBatterySettingsFromGui()
Declare SaveBatteryGraphDisplaySettingsFromGui()
Declare RefreshBatterySaverSummary()
Declare.i NormalizeBatteryGraphHours(hours.i)
Declare.i BatteryGraphHoursIndex(hours.i)
Declare.i BatteryGraphHoursFromIndex(index.i)
Declare.q BatteryGraphWindowSeconds()
Declare.s BatteryGraphWindowTitle()
Declare ResetBatteryStats()
Declare CopyBatteryLogRow()
Declare CopyBatteryLogAll()
Declare ExportSettings()
Declare ImportSettings()
Declare WriteBatteryAppEvent(eventName$)
Declare WriteBatteryEvent(eventName$)
Declare.i BatteryEventIsSleepHibernate(eventName$)
Declare.s BatteryEventShortName(eventName$)
Declare.i BatteryEventDuplicateNear(timestamp.q, eventName$, windowSeconds.i = #BatteryDuplicateEventSeconds)
Declare WriteBatteryScreenEvent(eventName$)
Declare WriteBatteryEnergySaverEvent(energySaverOn.i)
Declare WriteBatteryTestRow(eventName$, includeBattery.i = #True)
Declare LogStartupPowerEvents()
Declare CleanupAppCloseShutdownEvents(bootTime.q)
Declare AutoSetInitialBatteryDrainFromLog()
Declare RefreshBatteryAnalysisNow()
Declare RefreshBatteryAnalysisSummary()
Declare DrawBatteryGraph()
Declare RefreshBatteryStatsSummary()
Declare PruneBatteryLog()
Declare ApplyToolTips()
Declare SetGadgetTextIfChanged(gadget.i, text$)
Declare RefreshActiveTimer()
Declare EnsurePowerApi()
Declare.i CurrentPowerSupplyIsBattery()
Declare.i BatteryGraphTabVisible()
Declare.i BatteryTestTabVisible()
Declare.i SetStartupRegistry(enabled.i)
Declare.i CreateManagedPlans()
Declare.i CreateManagedPlansFromBase(baseGuid$, forceRebase.i = #False)
Declare.i CleanupManagedPlans()
Declare.i ApplyBatterySleepFloorToManagedPlans()
Declare.i ApplyEnergySaverPolicyToManagedPlans()
Declare RememberNormalPowerPlan(schemeGuid$, schemeName$)
Declare.i RestoreNormalPowerPlanForExit()
Declare.i ActivatePlanByName(planName$)
Declare.i InstallRefresh()
Declare.i CleanupOldPowerPilotVersions(deleteFiles.i = #False, logEvent.i = #True)
Declare.i LogUpdateCloseIfSameExeRunning()
Declare.i LogUpdateCloseIfAnyPowerPilotRunning()
Declare.i MainWindowVisible()
Declare.i EnsureSingleInstance()

; Quotes command arguments for RunProgram calls. The app builds its own command
; strings for powercfg and PowerShell rather than invoking a shell pipeline.
Procedure.s QuoteArgument(value$)
  ProcedureReturn Chr(34) + value$ + Chr(34)
EndProcedure

; Settings are stored per user. This is important because the installer can be
; elevated, but the tray app should run and persist settings as the local user.
Procedure.s SettingsDirectory()
  Protected path$ = GetEnvironmentVariable("APPDATA")
  If path$ = ""
    path$ = GetCurrentDirectory()
  Else
    path$ + "\" + #SettingsFolderName$
  EndIf
  ProcedureReturn path$
EndProcedure

Procedure.s SettingsPath()
  ProcedureReturn SettingsDirectory() + "\" + #SettingsFileName$
EndProcedure

Procedure EnsureSettingsDirectory()
  If FileSize(SettingsDirectory()) <> -2
    CreateDirectory(SettingsDirectory())
  EndIf
EndProcedure

Procedure.s BatteryReportDirectory()
  ProcedureReturn SettingsDirectory() + "\reports"
EndProcedure

Procedure EnsureBatteryReportDirectory()
  EnsureSettingsDirectory()
  If FileSize(BatteryReportDirectory()) <> -2
    CreateDirectory(BatteryReportDirectory())
  EndIf
EndProcedure

Procedure.s BatteryReportFileName(prefix$)
  Protected name$ = prefix$ + "_" + FormatDate("%yyyy-%mm-%dd_%hh-%ii-%ss", Date()) + ".txt"
  name$ = ReplaceString(name$, " ", "_")
  name$ = ReplaceString(name$, ",", "")
  name$ = ReplaceString(name$, ":", "-")
  ProcedureReturn name$
EndProcedure

Procedure.s LatestBatteryReportPath()
  Protected dir$ = BatteryReportDirectory()
  Protected latestPath$
  Protected latestTime.q = -1
  Protected entry$
  Protected path$
  Protected modified.q
  If FileSize(dir$) <> -2
    ProcedureReturn gBatteryTestReportPath$
  EndIf
  If ExamineDirectory(0, dir$, "*.txt")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        entry$ = DirectoryEntryName(0)
        path$ = dir$ + "\" + entry$
        modified = GetFileDate(path$, #PB_Date_Modified)
        If modified > latestTime
          latestTime = modified
          latestPath$ = path$
        EndIf
      EndIf
    Wend
    FinishDirectory(0)
  EndIf
  If latestPath$ <> ""
    ProcedureReturn latestPath$
  EndIf
  ProcedureReturn gBatteryTestReportPath$
EndProcedure

; Keep plan names/descriptions single-line so powercfg output parsing and list
; rows remain predictable.
Procedure.s CleanPlanText(text$)
  text$ = ReplaceString(text$, #CR$, " ")
  text$ = ReplaceString(text$, #LF$, " ")
  text$ = ReplaceString(text$, #TAB$, " ")
  While FindString(text$, "  ", 1)
    text$ = ReplaceString(text$, "  ", " ")
  Wend
  ProcedureReturn Trim(text$)
EndProcedure

; Small helper used throughout UI and settings load/save to keep user-editable
; numeric values within the ranges the rest of the code expects.
Procedure.i ClampInt(value.i, minValue.i, maxValue.i)
  If value < minValue : ProcedureReturn minValue : EndIf
  If value > maxValue : ProcedureReturn maxValue : EndIf
  ProcedureReturn value
EndProcedure

Procedure.s BatteryActionName(action.i)
  Select ClampInt(action, #BatteryActionDoNothing, #BatteryActionShutdown)
    Case #BatteryActionSleep
      ProcedureReturn "Sleep"
    Case #BatteryActionHibernate
      ProcedureReturn "Hibernate"
    Case #BatteryActionShutdown
      ProcedureReturn "Shut down"
  EndSelect
  ProcedureReturn "Do nothing"
EndProcedure

Procedure.s EnergySaverModeName(mode.i)
  Select ClampInt(mode, #EnergySaverFollowWindows, #EnergySaverPowerPilotControlled)
    Case #EnergySaverPowerPilotControlled
      ProcedureReturn "Battery plan always"
  EndSelect
  ProcedureReturn "Automatic threshold"
EndProcedure

; Default PowerPilot Log column widths are deliberately below the full list
; width so the vertical scrollbar does not force a horizontal scrollbar.
Procedure.i BatteryLogDefaultColumnWidth(column.i)
  Select column
    Case 0 : ProcedureReturn 142
    Case 1 : ProcedureReturn 55
    Case 2 : ProcedureReturn 145
    Case 3 : ProcedureReturn 72
    Case 4 : ProcedureReturn 64
    Case 5 : ProcedureReturn 64
    Case 6 : ProcedureReturn 58
    Case 7 : ProcedureReturn 76
    Case 8 : ProcedureReturn 74
    Case 9 : ProcedureReturn 78
  EndSelect
  ProcedureReturn 60
EndProcedure

; Store user-resized log column widths in named fields instead of an array so
; settings.ini remains simple and PureBasic's structure layout stays explicit.
Procedure.i BatteryLogColumnWidth(column.i)
  Select column
    Case 0 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn0Width, 40, 240)
    Case 1 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn1Width, 35, 160)
    Case 2 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn2Width, 50, 260)
    Case 3 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn3Width, 45, 200)
    Case 4 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn4Width, 45, 180)
    Case 5 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn5Width, 45, 180)
    Case 6 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn6Width, 35, 160)
    Case 7 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn7Width, 50, 180)
    Case 8 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn8Width, 50, 180)
    Case 9 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn9Width, 55, 180)
  EndSelect
  ProcedureReturn BatteryLogDefaultColumnWidth(column)
EndProcedure

Procedure SetBatteryLogColumnWidthSetting(column.i, width.i)
  width = ClampInt(width, 35, 260)
  Select column
    Case 0 : gSettings\BatteryLogColumn0Width = width
    Case 1 : gSettings\BatteryLogColumn1Width = width
    Case 2 : gSettings\BatteryLogColumn2Width = width
    Case 3 : gSettings\BatteryLogColumn3Width = width
    Case 4 : gSettings\BatteryLogColumn4Width = width
    Case 5 : gSettings\BatteryLogColumn5Width = width
    Case 6 : gSettings\BatteryLogColumn6Width = width
    Case 7 : gSettings\BatteryLogColumn7Width = width
    Case 8 : gSettings\BatteryLogColumn8Width = width
    Case 9 : gSettings\BatteryLogColumn9Width = width
  EndSelect
EndProcedure

; Populate one of the three fixed in-memory plan definitions.
Procedure AddPlan(index.i, name$, description$, acEpp.i, acBoost.i, acState.i, acFreq.i, acCooling.i, dcEpp.i, dcBoost.i, dcState.i, dcFreq.i, dcCooling.i)
  gPlans(index)\Name = CleanPlanText(name$)
  gPlans(index)\Description = CleanPlanText(description$)
  gPlans(index)\AcEpp = acEpp
  gPlans(index)\AcBoostMode = acBoost
  gPlans(index)\AcMaxState = acState
  gPlans(index)\AcFreqMHz = acFreq
  gPlans(index)\AcCooling = acCooling
  gPlans(index)\DcEpp = dcEpp
  gPlans(index)\DcBoostMode = dcBoost
  gPlans(index)\DcMaxState = dcState
  gPlans(index)\DcFreqMHz = dcFreq
  gPlans(index)\DcCooling = dcCooling
EndProcedure

; Defaults are conservative: Maximum favors plugged-in performance, Balanced
; mirrors Windows Balanced, and Battery prioritizes lower power.
Procedure LoadDefaultPlan(index.i)
  Select index
    Case 0
      AddPlan(0, #PlanFull$, "Highest performance profile.", 0, 2, 100, 0, 1, 60, 1, 100, 0, 1)
    Case 1
      AddPlan(1, #PlanBalanced$, "Balanced daily profile.", 33, 1, 100, 0, 1, 50, 0, 100, 0, 0)
    Case 2
      AddPlan(2, #PlanBattery$, "Battery-saving profile.", 90, 0, 65, 2200, 0, 100, 0, 30, 1100, 0)
  EndSelect
EndProcedure

Procedure LoadDefaultPlans()
  LoadDefaultPlan(0)
  LoadDefaultPlan(1)
  LoadDefaultPlan(2)
EndProcedure

; Return -1 for unknown names so callers can fall back to Balanced.
Procedure.i PlanIndexByName(planName$)
  Protected i.i
  For i = 0 To 2
    If gPlans(i)\Name = planName$
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn -1
EndProcedure

; Persisted plan selection is normalized because old or hand-edited settings can
; refer to plans that no longer exist in the fixed three-plan model.
Procedure.s NormalizePlanName(planName$)
  If PlanIndexByName(planName$) >= 0
    ProcedureReturn planName$
  EndIf
  ProcedureReturn #PlanBalanced$
EndProcedure

; PowerPilot cleans both current and prototype-owned plans, but never arbitrary
; user-created Windows plans.
Procedure.i IsManagedPlanName(planName$)
  ProcedureReturn Bool(planName$ = #AppName$ Or Left(planName$, Len(#PlanPrefixNew$)) = #PlanPrefixNew$ Or Left(planName$, Len(#PlanPrefixOld$)) = #PlanPrefixOld$)
EndProcedure

; Convert Windows overlay GUIDs into the fixed PowerPilot plan target.
Procedure.i IsEfficiencyPowerMode(guid$)
  ProcedureReturn Bool(LCase(guid$) = #PowerModeEfficiency$)
EndProcedure

; Map the active Windows overlay to user-facing text for the Overview tab.
Procedure.s PowerModeTextFromGuid(guid$)
  Select LCase(guid$)
    Case #PowerModeEfficiency$
      ProcedureReturn "Best power efficiency"
    Case #PowerModePerformance$
      ProcedureReturn "Best performance"
    Case #PowerModeBalanced$
      ProcedureReturn "Balanced"
  EndSelect
  ProcedureReturn ""
EndProcedure

; Map the active Windows overlay directly to the fixed plan PowerPilot should
; activate while following Windows power mode.
Procedure.s TargetPlanForPowerModeGuid(guid$)
  Select LCase(guid$)
    Case #PowerModeEfficiency$
      ProcedureReturn #PlanBattery$
    Case #PowerModePerformance$
      ProcedureReturn #PlanFull$
    Case #PowerModeBalanced$
      ProcedureReturn #PlanBalanced$
  EndSelect
  ProcedureReturn ""
EndProcedure

; When creating plans from a user-selected base plan, use the base plan name as
; a hint for which PowerPilot plan should become active.
Procedure.s TargetPlanForWindowsPlan(planName$)
  Protected lower$ = LCase(planName$)
  If FindString(lower$, "power saver", 1) Or FindString(lower$, "powersaver", 1) Or FindString(lower$, "efficiency", 1) Or FindString(lower$, "efficient", 1) Or FindString(lower$, "energy saver", 1) Or FindString(lower$, "battery saver", 1) Or FindString(lower$, "eco", 1)
    ProcedureReturn #PlanBattery$
  EndIf
  If FindString(lower$, "balanced", 1)
    ProcedureReturn #PlanBalanced$
  EndIf
  If FindString(lower$, "ultimate", 1) Or FindString(lower$, "maximum", 1) Or FindString(lower$, "high performance", 1) Or FindString(lower$, "performance", 1)
    ProcedureReturn #PlanFull$
  EndIf
  ProcedureReturn #PlanBalanced$
EndProcedure

; Guard rails for every power-plan value that can be imported, edited, or read
; from older settings files.
Procedure ClampPlanValues(*plan.PlanDefinition)
  *plan\AcEpp = ClampInt(*plan\AcEpp, 0, 100)
  *plan\DcEpp = ClampInt(*plan\DcEpp, 0, 100)
  *plan\AcBoostMode = ClampInt(*plan\AcBoostMode, 0, 2)
  *plan\DcBoostMode = ClampInt(*plan\DcBoostMode, 0, 2)
  *plan\AcMaxState = ClampInt(*plan\AcMaxState, 1, 100)
  *plan\DcMaxState = ClampInt(*plan\DcMaxState, 1, 100)
  *plan\AcFreqMHz = ClampInt(*plan\AcFreqMHz, 0, 6000)
  *plan\DcFreqMHz = ClampInt(*plan\DcFreqMHz, 0, 6000)
  *plan\AcCooling = ClampInt(*plan\AcCooling, 0, 1)
  *plan\DcCooling = ClampInt(*plan\DcCooling, 0, 1)
EndProcedure

; Used by migrations to detect old default profiles. If the user has changed a
; profile, migration leaves that edited plan alone.
Procedure.i PlanMatchesValues(*plan.PlanDefinition, acEpp.i, acBoost.i, acState.i, acFreq.i, acCooling.i, dcEpp.i, dcBoost.i, dcState.i, dcFreq.i, dcCooling.i)
  If *plan\AcEpp <> acEpp : ProcedureReturn #False : EndIf
  If *plan\AcBoostMode <> acBoost : ProcedureReturn #False : EndIf
  If *plan\AcMaxState <> acState : ProcedureReturn #False : EndIf
  If *plan\AcFreqMHz <> acFreq : ProcedureReturn #False : EndIf
  If *plan\AcCooling <> acCooling : ProcedureReturn #False : EndIf
  If *plan\DcEpp <> dcEpp : ProcedureReturn #False : EndIf
  If *plan\DcBoostMode <> dcBoost : ProcedureReturn #False : EndIf
  If *plan\DcMaxState <> dcState : ProcedureReturn #False : EndIf
  If *plan\DcFreqMHz <> dcFreq : ProcedureReturn #False : EndIf
  If *plan\DcCooling <> dcCooling : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

; Settings upgrades are intentionally narrow. Only old unchanged defaults are
; refreshed, avoiding accidental overwrites of user tuning.
Procedure.i UpgradeSettingsIfNeeded(savedVersion.i)
  Protected upgraded.i
  If savedVersion < 2
    If PlanMatchesValues(@gPlans(2), 85, 0, 70, 2500, 0, 95, 0, 60, 1800, 0)
      LoadDefaultPlan(2)
      upgraded = #True
    EndIf
  EndIf
  If savedVersion < 5
    If PlanMatchesValues(@gPlans(0), 5, 2, 100, 0, 1, 60, 1, 100, 0, 1)
      LoadDefaultPlan(0)
      upgraded = #True
    EndIf
    If PlanMatchesValues(@gPlans(1), 55, 1, 85, 0, 1, 75, 1, 80, 0, 1)
      LoadDefaultPlan(1)
      upgraded = #True
    EndIf
  EndIf
  If savedVersion < 10
    If gSettings\BatteryLogColumn8Width <= 0
      gSettings\BatteryLogColumn8Width = BatteryLogDefaultColumnWidth(8)
      upgraded = #True
    EndIf
    If gSettings\BatteryLogColumn9Width <= 0
      gSettings\BatteryLogColumn9Width = BatteryLogDefaultColumnWidth(9)
      upgraded = #True
    EndIf
  EndIf
  If savedVersion < 11 And gSettings\BatteryRefreshSeconds = 120
    gSettings\BatteryRefreshSeconds = #BatteryDefaultRefreshSeconds
    upgraded = #True
  EndIf
  If savedVersion < 12 And gSettings\BatteryRefreshSeconds = 30
    gSettings\BatteryRefreshSeconds = #BatteryDefaultRefreshSeconds
    upgraded = #True
  EndIf
  If savedVersion < 15 And gSettings\BatteryMinPercent = 1
    gSettings\BatteryMinPercent = 0
    upgraded = #True
  EndIf
  If savedVersion < 17 And gSettings\BatteryCalibrationDrainMinutes <= 0
    gSettings\BatteryCalibrationDrainMinutes = #BatteryCalibrationDefaultDrainMinutes
    upgraded = #True
  EndIf
  If savedVersion > 0 And savedVersion < 19
    gSettings\BatteryCriticalPercent = ClampInt(gSettings\BatteryMinPercent, 1, 99)
    gSettings\BatteryLowWarningPercent = ClampInt(gSettings\BatteryCriticalPercent + 1, 1, 100)
    If gSettings\BatteryReservePercent < gSettings\BatteryCriticalPercent
      gSettings\BatteryReservePercent = ClampInt(gSettings\BatteryLowWarningPercent, gSettings\BatteryCriticalPercent, 100)
    EndIf
    upgraded = #True
  EndIf
  If savedVersion > 0 And savedVersion < 20
    ; Tighten only the old untouched Battery default. If the user already tuned
    ; the Battery profile, preserve it exactly and apply only the hidden plan
    ; policy from ConfigureScheme during the next refresh/install.
    If PlanMatchesValues(@gPlans(2), 90, 0, 65, 2200, 0, 98, 0, 55, 1600, 0)
      LoadDefaultPlan(2)
      upgraded = #True
    EndIf
  EndIf
  If gSettings\SettingsVersion <> #SettingsVersion
    gSettings\SettingsVersion = #SettingsVersion
    upgraded = #True
  EndIf
  ProcedureReturn upgraded
EndProcedure

; Load defaults first, then overlay settings.ini. That makes missing keys safe
; and keeps new settings backward compatible with older installed versions.
Procedure LoadSettings()
  Protected i.i
  Protected savedVersion.i = 0
  Protected upgraded.i
  LoadDefaultPlans()
  gSettings\AutoStartWithApp = #True
  gSettings\KeepSettingsOnReinstall = #False
  gSettings\ThrottleMaintenance = #True
  gSettings\DeepIdleSaver = #True
  gSettings\EnergySaverMode = #EnergySaverFollowWindows
  gSettings\EnergySaverThreshold = #EnergySaverWindowsThreshold
  gSettings\EnergySaverBrightness = #EnergySaverDefaultBrightness
  gSettings\BatteryLowWarningPercent = #BatteryLowWarningDefaultPercent
  gSettings\BatteryReservePercent = #BatteryReserveDefaultPercent
  gSettings\BatteryLowAction = #BatteryActionDoNothing
  gSettings\BatteryCriticalPercent = #BatteryCriticalDefaultPercent
  gSettings\BatteryCriticalAction = #BatteryActionSleep
  gSettings\RestoreNormalPlanOnExit = #True
  gSettings\ShowToolTips = #True
  gSettings\BatteryLogEnabled = #True
  gSettings\BatteryLogIntervalMinutes = #BatteryDefaultLogMinutes
  gSettings\BatteryRefreshSeconds = #BatteryDefaultRefreshSeconds
  gSettings\BatteryMinPercent = 0
  gSettings\BatteryMaxPercent = 100
  gSettings\BatteryLimiterEnabled = #False
  gSettings\BatteryLimiterMaxPercent = 80
  gSettings\BatterySmoothingMinutes = 60
  gSettings\BatteryStartupDrainPctPerHour = 12.0
  gSettings\BatteryLastDrainPctPerHour = 12.0
  gSettings\BatteryLastChargePctPerHour = 0.0
  gSettings\BatteryChargeLearningCount = 0
  gSettings\BatteryLastStaticQuery = 0
  gSettings\BatteryCalibrationDrainMinutes = #BatteryCalibrationDefaultDrainMinutes
  gSettings\BatteryGraphHours = #BatteryGraphDefaultHours
  gSettings\BatteryGraphShowMarkers = #True
  gSettings\BatteryLogShowAverage = #True
  gSettings\BatteryLogShowInstant = #True
  gSettings\BatteryLogShowWindows = #True
  gSettings\BatteryLogShowConnected = #True
  gSettings\BatteryLogShowPower = #True
  gSettings\BatteryLogShowScreen = #True
  gSettings\BatteryLogShowBrightness = #True
  gSettings\BatteryLogShowEvents = #True
  gSettings\BatteryLogColumn0Width = BatteryLogDefaultColumnWidth(0)
  gSettings\BatteryLogColumn1Width = BatteryLogDefaultColumnWidth(1)
  gSettings\BatteryLogColumn2Width = BatteryLogDefaultColumnWidth(2)
  gSettings\BatteryLogColumn3Width = BatteryLogDefaultColumnWidth(3)
  gSettings\BatteryLogColumn4Width = BatteryLogDefaultColumnWidth(4)
  gSettings\BatteryLogColumn5Width = BatteryLogDefaultColumnWidth(5)
  gSettings\BatteryLogColumn6Width = BatteryLogDefaultColumnWidth(6)
  gSettings\BatteryLogColumn7Width = BatteryLogDefaultColumnWidth(7)
  gSettings\BatteryLogColumn8Width = BatteryLogDefaultColumnWidth(8)
  gSettings\BatteryLogColumn9Width = BatteryLogDefaultColumnWidth(9)
  gSettings\SettingsVersion = #SettingsVersion
  gSettings\LastPlan = #PlanBalanced$

  If OpenPreferences(SettingsPath())
    savedVersion = ReadPreferenceInteger("SettingsVersion", 0)
    gSettings\SettingsVersion = savedVersion
    gSettings\AutoStartWithApp = ReadPreferenceInteger("AutoStartWithApp", gSettings\AutoStartWithApp)
    gSettings\KeepSettingsOnReinstall = ReadPreferenceInteger("KeepSettingsOnReinstall", gSettings\KeepSettingsOnReinstall)
    gSettings\ThrottleMaintenance = ReadPreferenceInteger("ThrottleMaintenance", gSettings\ThrottleMaintenance)
    gSettings\DeepIdleSaver = ReadPreferenceInteger("DeepIdleSaver", gSettings\DeepIdleSaver)
    gSettings\EnergySaverMode = ReadPreferenceInteger("EnergySaverMode", gSettings\EnergySaverMode)
    gSettings\EnergySaverThreshold = ReadPreferenceInteger("EnergySaverThreshold", gSettings\EnergySaverThreshold)
    gSettings\EnergySaverBrightness = ReadPreferenceInteger("EnergySaverBrightness", gSettings\EnergySaverBrightness)
    gSettings\BatteryLowWarningPercent = ReadPreferenceInteger("BatteryLowWarningPercent", gSettings\BatteryLowWarningPercent)
    gSettings\BatteryReservePercent = ReadPreferenceInteger("BatteryReservePercent", gSettings\BatteryReservePercent)
    gSettings\BatteryLowAction = ReadPreferenceInteger("BatteryLowAction", gSettings\BatteryLowAction)
    gSettings\BatteryCriticalPercent = ReadPreferenceInteger("BatteryCriticalPercent", gSettings\BatteryCriticalPercent)
    gSettings\BatteryCriticalAction = ReadPreferenceInteger("BatteryCriticalAction", gSettings\BatteryCriticalAction)
    gSettings\RestoreNormalPlanOnExit = ReadPreferenceInteger("RestoreNormalPlanOnExit", gSettings\RestoreNormalPlanOnExit)
    gSettings\ShowToolTips = ReadPreferenceInteger("ShowToolTips", gSettings\ShowToolTips)
    gSettings\BatteryLogEnabled = ReadPreferenceInteger("BatteryLogEnabled", gSettings\BatteryLogEnabled)
    gSettings\BatteryLogIntervalMinutes = ReadPreferenceInteger("BatteryLogIntervalMinutes", gSettings\BatteryLogIntervalMinutes)
    gSettings\BatteryRefreshSeconds = ReadPreferenceInteger("BatteryRefreshSeconds", gSettings\BatteryRefreshSeconds)
    gSettings\BatteryMinPercent = ReadPreferenceInteger("BatteryMinPercent", gSettings\BatteryMinPercent)
    gSettings\BatteryMaxPercent = ReadPreferenceInteger("BatteryMaxPercent", gSettings\BatteryMaxPercent)
    gSettings\BatteryLimiterEnabled = ReadPreferenceInteger("BatteryLimiterEnabled", gSettings\BatteryLimiterEnabled)
    gSettings\BatteryLimiterMaxPercent = ReadPreferenceInteger("BatteryLimiterMaxPercent", gSettings\BatteryLimiterMaxPercent)
    gSettings\BatterySmoothingMinutes = ReadPreferenceInteger("BatterySmoothingMinutes", gSettings\BatterySmoothingMinutes)
    gSettings\BatteryStartupDrainPctPerHour = ValD(ReadPreferenceString("BatteryStartupDrainPctPerHour", StrD(gSettings\BatteryStartupDrainPctPerHour, 2)))
    gSettings\BatteryLastDrainPctPerHour = ValD(ReadPreferenceString("BatteryLastDrainPctPerHour", StrD(gSettings\BatteryLastDrainPctPerHour, 2)))
    gSettings\BatteryLastChargePctPerHour = ValD(ReadPreferenceString("BatteryLastChargePctPerHour", StrD(gSettings\BatteryLastChargePctPerHour, 2)))
    gSettings\BatteryChargeLearningCount = ReadPreferenceInteger("BatteryChargeLearningCount", gSettings\BatteryChargeLearningCount)
    gSettings\BatteryLastStaticQuery = Val(ReadPreferenceString("BatteryLastStaticQuery", Str(gSettings\BatteryLastStaticQuery)))
    gSettings\BatteryCalibrationDrainMinutes = ReadPreferenceInteger("BatteryCalibrationDrainMinutes", gSettings\BatteryCalibrationDrainMinutes)
    gSettings\BatteryGraphHours = ReadPreferenceInteger("BatteryGraphHours", gSettings\BatteryGraphHours)
    gSettings\BatteryGraphShowMarkers = ReadPreferenceInteger("BatteryGraphShowMarkers", gSettings\BatteryGraphShowMarkers)
    gSettings\BatteryLogShowAverage = ReadPreferenceInteger("BatteryLogShowAverage", gSettings\BatteryLogShowAverage)
    gSettings\BatteryLogShowInstant = ReadPreferenceInteger("BatteryLogShowInstant", gSettings\BatteryLogShowInstant)
    gSettings\BatteryLogShowWindows = ReadPreferenceInteger("BatteryLogShowWindows", gSettings\BatteryLogShowWindows)
    gSettings\BatteryLogShowConnected = ReadPreferenceInteger("BatteryLogShowConnected", gSettings\BatteryLogShowConnected)
    gSettings\BatteryLogShowPower = ReadPreferenceInteger("BatteryLogShowPower", gSettings\BatteryLogShowPower)
    gSettings\BatteryLogShowScreen = ReadPreferenceInteger("BatteryLogShowScreen", gSettings\BatteryLogShowScreen)
    gSettings\BatteryLogShowBrightness = ReadPreferenceInteger("BatteryLogShowBrightness", gSettings\BatteryLogShowBrightness)
    gSettings\BatteryLogShowEvents = ReadPreferenceInteger("BatteryLogShowEvents", gSettings\BatteryLogShowEvents)
    gSettings\BatteryLogColumn0Width = ReadPreferenceInteger("BatteryLogColumn0Width", gSettings\BatteryLogColumn0Width)
    gSettings\BatteryLogColumn1Width = ReadPreferenceInteger("BatteryLogColumn1Width", gSettings\BatteryLogColumn1Width)
    gSettings\BatteryLogColumn2Width = ReadPreferenceInteger("BatteryLogColumn2Width", gSettings\BatteryLogColumn2Width)
    gSettings\BatteryLogColumn3Width = ReadPreferenceInteger("BatteryLogColumn3Width", gSettings\BatteryLogColumn3Width)
    gSettings\BatteryLogColumn4Width = ReadPreferenceInteger("BatteryLogColumn4Width", gSettings\BatteryLogColumn4Width)
    gSettings\BatteryLogColumn5Width = ReadPreferenceInteger("BatteryLogColumn5Width", gSettings\BatteryLogColumn5Width)
    gSettings\BatteryLogColumn6Width = ReadPreferenceInteger("BatteryLogColumn6Width", gSettings\BatteryLogColumn6Width)
    gSettings\BatteryLogColumn7Width = ReadPreferenceInteger("BatteryLogColumn7Width", gSettings\BatteryLogColumn7Width)
    gSettings\BatteryLogColumn8Width = ReadPreferenceInteger("BatteryLogColumn8Width", gSettings\BatteryLogColumn8Width)
    gSettings\BatteryLogColumn9Width = ReadPreferenceInteger("BatteryLogColumn9Width", gSettings\BatteryLogColumn9Width)
    gSettings\LastBootTime = Val(ReadPreferenceString("LastBootTime", Str(gSettings\LastBootTime)))
    gSettings\NormalPlanGuid = LCase(ReadPreferenceString("NormalPlanGuid", gSettings\NormalPlanGuid))
    gSettings\NormalPlanName = ReadPreferenceString("NormalPlanName", gSettings\NormalPlanName)
    gSettings\LastPlan = ReadPreferenceString("LastPlan", gSettings\LastPlan)
    ; Plan sections are stored under their visible plan names. This keeps the
    ; settings file readable and lets each plan migrate independently.
    For i = 0 To 2
      PreferenceGroup(gPlans(i)\Name)
      gPlans(i)\Description = ReadPreferenceString("Description", gPlans(i)\Description)
      gPlans(i)\AcEpp = ReadPreferenceInteger("AcEpp", gPlans(i)\AcEpp)
      gPlans(i)\AcBoostMode = ReadPreferenceInteger("AcBoostMode", gPlans(i)\AcBoostMode)
      gPlans(i)\AcMaxState = ReadPreferenceInteger("AcMaxState", gPlans(i)\AcMaxState)
      gPlans(i)\AcFreqMHz = ReadPreferenceInteger("AcFreqMHz", gPlans(i)\AcFreqMHz)
      gPlans(i)\AcCooling = ReadPreferenceInteger("AcCooling", gPlans(i)\AcCooling)
      gPlans(i)\DcEpp = ReadPreferenceInteger("DcEpp", gPlans(i)\DcEpp)
      gPlans(i)\DcBoostMode = ReadPreferenceInteger("DcBoostMode", gPlans(i)\DcBoostMode)
      gPlans(i)\DcMaxState = ReadPreferenceInteger("DcMaxState", gPlans(i)\DcMaxState)
      gPlans(i)\DcFreqMHz = ReadPreferenceInteger("DcFreqMHz", gPlans(i)\DcFreqMHz)
      gPlans(i)\DcCooling = ReadPreferenceInteger("DcCooling", gPlans(i)\DcCooling)
      PreferenceGroup("")
      ClampPlanValues(@gPlans(i))
    Next
    ClosePreferences()
  EndIf

  gSettings\LastPlan = NormalizePlanName(gSettings\LastPlan)
  gSettings\BatteryLogIntervalMinutes = ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440)
  gSettings\BatteryRefreshSeconds = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)
  gSettings\EnergySaverMode = ClampInt(gSettings\EnergySaverMode, #EnergySaverFollowWindows, #EnergySaverPowerPilotControlled)
  gSettings\EnergySaverThreshold = ClampInt(gSettings\EnergySaverThreshold, 0, 100)
  gSettings\EnergySaverBrightness = ClampInt(gSettings\EnergySaverBrightness, 0, 100)
  gSettings\BatteryCriticalPercent = ClampInt(gSettings\BatteryCriticalPercent, 1, 99)
  gSettings\BatteryLowWarningPercent = ClampInt(gSettings\BatteryLowWarningPercent, gSettings\BatteryCriticalPercent + 1, 100)
  gSettings\BatteryReservePercent = ClampInt(gSettings\BatteryReservePercent, gSettings\BatteryCriticalPercent, 100)
  gSettings\BatteryLowAction = ClampInt(gSettings\BatteryLowAction, #BatteryActionDoNothing, #BatteryActionShutdown)
  gSettings\BatteryCriticalAction = ClampInt(gSettings\BatteryCriticalAction, #BatteryActionDoNothing, #BatteryActionShutdown)
  gSettings\RestoreNormalPlanOnExit = Bool(gSettings\RestoreNormalPlanOnExit)
  gSettings\BatteryMinPercent = ClampInt(gSettings\BatteryMinPercent, 0, 99)
  gSettings\BatteryMaxPercent = ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatteryLimiterMaxPercent = ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatterySmoothingMinutes = ClampInt(gSettings\BatterySmoothingMinutes, 5, 240)
  gSettings\BatteryCalibrationDrainMinutes = ClampInt(gSettings\BatteryCalibrationDrainMinutes, 15, 720)
  gSettings\BatteryGraphHours = NormalizeBatteryGraphHours(gSettings\BatteryGraphHours)
  gSettings\BatteryGraphShowMarkers = Bool(gSettings\BatteryGraphShowMarkers)
  SetBatteryLogColumnWidthSetting(0, gSettings\BatteryLogColumn0Width)
  SetBatteryLogColumnWidthSetting(1, gSettings\BatteryLogColumn1Width)
  SetBatteryLogColumnWidthSetting(2, gSettings\BatteryLogColumn2Width)
  SetBatteryLogColumnWidthSetting(3, gSettings\BatteryLogColumn3Width)
  SetBatteryLogColumnWidthSetting(4, gSettings\BatteryLogColumn4Width)
  SetBatteryLogColumnWidthSetting(5, gSettings\BatteryLogColumn5Width)
  SetBatteryLogColumnWidthSetting(6, gSettings\BatteryLogColumn6Width)
  SetBatteryLogColumnWidthSetting(7, gSettings\BatteryLogColumn7Width)
  SetBatteryLogColumnWidthSetting(8, gSettings\BatteryLogColumn8Width)
  SetBatteryLogColumnWidthSetting(9, gSettings\BatteryLogColumn9Width)
  If gSettings\BatteryStartupDrainPctPerHour <= 0.0
    gSettings\BatteryStartupDrainPctPerHour = 12.0
  EndIf
  If gSettings\BatteryLastDrainPctPerHour <= 0.0
    gSettings\BatteryLastDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
  EndIf
  If gSettings\BatteryLastChargePctPerHour < 0.0 Or gSettings\BatteryLastChargePctPerHour > 200.0
    gSettings\BatteryLastChargePctPerHour = 0.0
  EndIf
  gSettings\BatteryChargeLearningCount = ClampInt(gSettings\BatteryChargeLearningCount, 0, #BatteryChargeLearningCap)
  ; Clamp and migrate after reading all values so old or hand-edited settings
  ; cannot leak invalid values into UI controls or powercfg calls.
  upgraded = UpgradeSettingsIfNeeded(savedVersion)
  If upgraded
    SaveSettings()
  EndIf
EndProcedure

; Save only PowerPilot-owned settings. Windows power-plan GUIDs are intentionally
; not persisted because plans can be deleted and recreated by Windows or setup.
Procedure SaveSettings()
  Protected i.i
  CaptureBatteryLogColumnWidths(#False)
  EnsureSettingsDirectory()
  If CreatePreferences(SettingsPath())
    WritePreferenceInteger("AutoStartWithApp", Bool(gSettings\AutoStartWithApp))
    WritePreferenceInteger("KeepSettingsOnReinstall", Bool(gSettings\KeepSettingsOnReinstall))
    WritePreferenceInteger("ThrottleMaintenance", Bool(gSettings\ThrottleMaintenance))
    WritePreferenceInteger("DeepIdleSaver", Bool(gSettings\DeepIdleSaver))
    WritePreferenceInteger("EnergySaverMode", ClampInt(gSettings\EnergySaverMode, #EnergySaverFollowWindows, #EnergySaverPowerPilotControlled))
    WritePreferenceInteger("EnergySaverThreshold", ClampInt(gSettings\EnergySaverThreshold, 0, 100))
    WritePreferenceInteger("EnergySaverBrightness", ClampInt(gSettings\EnergySaverBrightness, 0, 100))
    WritePreferenceInteger("BatteryLowWarningPercent", ClampInt(gSettings\BatteryLowWarningPercent, gSettings\BatteryCriticalPercent + 1, 100))
    WritePreferenceInteger("BatteryReservePercent", ClampInt(gSettings\BatteryReservePercent, gSettings\BatteryCriticalPercent, 100))
    WritePreferenceInteger("BatteryLowAction", ClampInt(gSettings\BatteryLowAction, #BatteryActionDoNothing, #BatteryActionShutdown))
    WritePreferenceInteger("BatteryCriticalPercent", ClampInt(gSettings\BatteryCriticalPercent, 1, 99))
    WritePreferenceInteger("BatteryCriticalAction", ClampInt(gSettings\BatteryCriticalAction, #BatteryActionDoNothing, #BatteryActionShutdown))
    WritePreferenceInteger("RestoreNormalPlanOnExit", Bool(gSettings\RestoreNormalPlanOnExit))
    WritePreferenceInteger("ShowToolTips", Bool(gSettings\ShowToolTips))
    WritePreferenceInteger("BatteryLogEnabled", Bool(gSettings\BatteryLogEnabled))
    WritePreferenceInteger("BatteryLogIntervalMinutes", ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440))
    WritePreferenceInteger("BatteryRefreshSeconds", ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600))
    WritePreferenceInteger("BatteryMinPercent", ClampInt(gSettings\BatteryMinPercent, 0, 99))
    WritePreferenceInteger("BatteryMaxPercent", ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100))
    WritePreferenceInteger("BatteryLimiterEnabled", Bool(gSettings\BatteryLimiterEnabled))
    WritePreferenceInteger("BatteryLimiterMaxPercent", ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100))
    WritePreferenceInteger("BatterySmoothingMinutes", ClampInt(gSettings\BatterySmoothingMinutes, 5, 240))
    WritePreferenceString("BatteryStartupDrainPctPerHour", StrD(gSettings\BatteryStartupDrainPctPerHour, 2))
    WritePreferenceString("BatteryLastDrainPctPerHour", StrD(gSettings\BatteryLastDrainPctPerHour, 2))
    WritePreferenceString("BatteryLastChargePctPerHour", StrD(gSettings\BatteryLastChargePctPerHour, 2))
    WritePreferenceInteger("BatteryChargeLearningCount", ClampInt(gSettings\BatteryChargeLearningCount, 0, #BatteryChargeLearningCap))
    WritePreferenceString("BatteryLastStaticQuery", Str(gSettings\BatteryLastStaticQuery))
    WritePreferenceInteger("BatteryCalibrationDrainMinutes", ClampInt(gSettings\BatteryCalibrationDrainMinutes, 15, 720))
    WritePreferenceInteger("BatteryGraphHours", NormalizeBatteryGraphHours(gSettings\BatteryGraphHours))
    WritePreferenceInteger("BatteryGraphShowMarkers", Bool(gSettings\BatteryGraphShowMarkers))
    WritePreferenceInteger("BatteryLogShowAverage", Bool(gSettings\BatteryLogShowAverage))
    WritePreferenceInteger("BatteryLogShowInstant", Bool(gSettings\BatteryLogShowInstant))
    WritePreferenceInteger("BatteryLogShowWindows", Bool(gSettings\BatteryLogShowWindows))
    WritePreferenceInteger("BatteryLogShowConnected", Bool(gSettings\BatteryLogShowConnected))
    WritePreferenceInteger("BatteryLogShowPower", Bool(gSettings\BatteryLogShowPower))
    WritePreferenceInteger("BatteryLogShowScreen", Bool(gSettings\BatteryLogShowScreen))
    WritePreferenceInteger("BatteryLogShowBrightness", Bool(gSettings\BatteryLogShowBrightness))
    WritePreferenceInteger("BatteryLogShowEvents", Bool(gSettings\BatteryLogShowEvents))
    WritePreferenceInteger("BatteryLogColumn0Width", BatteryLogColumnWidth(0))
    WritePreferenceInteger("BatteryLogColumn1Width", BatteryLogColumnWidth(1))
    WritePreferenceInteger("BatteryLogColumn2Width", BatteryLogColumnWidth(2))
    WritePreferenceInteger("BatteryLogColumn3Width", BatteryLogColumnWidth(3))
    WritePreferenceInteger("BatteryLogColumn4Width", BatteryLogColumnWidth(4))
    WritePreferenceInteger("BatteryLogColumn5Width", BatteryLogColumnWidth(5))
    WritePreferenceInteger("BatteryLogColumn6Width", BatteryLogColumnWidth(6))
    WritePreferenceInteger("BatteryLogColumn7Width", BatteryLogColumnWidth(7))
    WritePreferenceInteger("BatteryLogColumn8Width", BatteryLogColumnWidth(8))
    WritePreferenceInteger("BatteryLogColumn9Width", BatteryLogColumnWidth(9))
    WritePreferenceString("LastBootTime", Str(gSettings\LastBootTime))
    WritePreferenceString("NormalPlanGuid", LCase(gSettings\NormalPlanGuid))
    WritePreferenceString("NormalPlanName", CleanPlanText(gSettings\NormalPlanName))
    WritePreferenceInteger("SettingsVersion", #SettingsVersion)
    WritePreferenceString("LastPlan", NormalizePlanName(gSettings\LastPlan))
    ; Persist all three plan definitions, including user-edited description text
    ; and AC/DC processor behavior values.
    For i = 0 To 2
      ClampPlanValues(@gPlans(i))
      PreferenceGroup(gPlans(i)\Name)
      WritePreferenceString("Description", gPlans(i)\Description)
      WritePreferenceInteger("AcEpp", gPlans(i)\AcEpp)
      WritePreferenceInteger("AcBoostMode", gPlans(i)\AcBoostMode)
      WritePreferenceInteger("AcMaxState", gPlans(i)\AcMaxState)
      WritePreferenceInteger("AcFreqMHz", gPlans(i)\AcFreqMHz)
      WritePreferenceInteger("AcCooling", gPlans(i)\AcCooling)
      WritePreferenceInteger("DcEpp", gPlans(i)\DcEpp)
      WritePreferenceInteger("DcBoostMode", gPlans(i)\DcBoostMode)
      WritePreferenceInteger("DcMaxState", gPlans(i)\DcMaxState)
      WritePreferenceInteger("DcFreqMHz", gPlans(i)\DcFreqMHz)
      WritePreferenceInteger("DcCooling", gPlans(i)\DcCooling)
      PreferenceGroup("")
    Next
    ClosePreferences()
  EndIf
EndProcedure

; The visible bottom status field was removed. Shortened action text now becomes
; an app row in the PowerPilot Log, while the full text remains on Overview.
Procedure.s ShortStatusLogText(text$)
  Protected short$ = Trim(text$)
  short$ = ReplaceString(short$, "PowerPilot ", "")
  short$ = ReplaceString(short$, "Managed ", "")
  short$ = ReplaceString(short$, " and applied to Windows", "")
  short$ = ReplaceString(short$, " from the selected Windows plan", "")
  short$ = ReplaceString(short$, "PowerPilot log", "log", #PB_String_NoCase)
  short$ = ReplaceString(short$, "Battery log", "Log")
  short$ = ReplaceString(short$, "Settings ", "Settings ")
  short$ = ReplaceString(short$, "No PowerPilot log row to copy.", "No row to copy.")
  short$ = ReplaceString(short$, "PowerPilot log row copied.", "Row copied.")
  short$ = ReplaceString(short$, "PowerPilot CSV log copied.", "CSV copied.")
  short$ = ReplaceString(short$, "Settings export failed.", "Export failed.")
  short$ = ReplaceString(short$, "Settings import failed.", "Import failed.")
  short$ = ReplaceString(short$, "Settings exported.", "Settings exported.")
  short$ = ReplaceString(short$, "Settings imported.", "Settings imported.")
  short$ = ReplaceString(short$, "Battery stats reset.", "Stats reset.")
  short$ = ReplaceString(short$, "Tray icon unavailable. Window stays visible.", "Tray unavailable.")
  If Len(short$) > 42
    short$ = Left(short$, 39) + "..."
  EndIf
ProcedureReturn short$
EndProcedure

Procedure.s OldItemCountText(count.i, singular$)
  If count <= 0
    ProcedureReturn ""
  EndIf
  If count = 1
    ProcedureReturn "1 old " + singular$
  EndIf
  ProcedureReturn Str(count) + " old " + singular$ + "s"
EndProcedure

Procedure.s CleanupOldPowerPilotText(processes.i, files.i)
  Protected processText$ = OldItemCountText(processes, "app")
  Protected fileText$ = OldItemCountText(files, "file")
  If processText$ <> "" And fileText$ <> ""
    ProcedureReturn "Cleaned " + processText$ + ", " + fileText$
  EndIf
  If processText$ <> ""
    ProcedureReturn "Cleaned " + processText$
  EndIf
  If fileText$ <> ""
    ProcedureReturn "Cleaned " + fileText$
  EndIf
  ProcedureReturn ""
EndProcedure

; Central UI/app feedback path. This updates the Overview tab and records a
; compact app-status row in the retained CSV log when the GUI is available.
Procedure LogAction(text$)
  Protected logText$ = ShortStatusLogText(text$)
  gLastAction$ = FormatDate("%hh:%ii:%ss", Date()) + "  " + text$
  If IsGadget(#GadgetLastAction)
    SetGadgetText(#GadgetLastAction, gLastAction$)
  EndIf
  If logText$ <> ""
    WriteBatteryAppEvent(logText$)
  EndIf
EndProcedure

Procedure.i ProgramWaitTimedOut(startTick.q, timeoutMs.i)
  If timeoutMs <= 0
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(ElapsedMilliseconds() - startTick >= timeoutMs)
EndProcedure

; Run a child process and return its exit code while draining stdout. Draining
; prevents hidden powercfg/PowerShell calls from blocking on a full output pipe.
Procedure.i RunExitCode(program$, arguments$, workingDir$ = "", timeoutMs.i = #ProgramTimeoutMs)
  Protected handle.i
  Protected code.i = -1
  Protected startTick.q
  Protected timedOut.i

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle
    startTick = ElapsedMilliseconds()
    While ProgramRunning(handle)
      While AvailableProgramOutput(handle)
        ReadProgramString(handle)
      Wend
      If ProgramWaitTimedOut(startTick, timeoutMs)
        timedOut = #True
        KillProgram(handle)
        Break
      EndIf
      Delay(10)
    Wend
    While AvailableProgramOutput(handle)
      ReadProgramString(handle)
    Wend
    If timedOut
      code = -2
    Else
      code = ProgramExitCode(handle)
    EndIf
    CloseProgram(handle)
  EndIf
  ProcedureReturn code
EndProcedure

; Capture stdout from small helper commands. This is used for powercfg, WMI
; PowerShell calls, and system event queries where a structured Windows API is
; either unavailable from PureBasic or too verbose for this utility.
Procedure.s RunCapture(program$, arguments$, workingDir$ = "", timeoutMs.i = #ProgramTimeoutMs)
  Protected handle.i
  Protected output$
  Protected startTick.q

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle
    startTick = ElapsedMilliseconds()
    While ProgramRunning(handle)
      While AvailableProgramOutput(handle)
        output$ + ReadProgramString(handle) + #LF$
      Wend
      If ProgramWaitTimedOut(startTick, timeoutMs)
        KillProgram(handle)
        Break
      EndIf
      Delay(10)
    Wend
    While AvailableProgramOutput(handle)
      output$ + ReadProgramString(handle) + #LF$
    Wend
    CloseProgram(handle)
  EndIf
  ProcedureReturn output$
EndProcedure

; WMI and event-log reads are run through PowerShell because root\wmi battery
; provider classes are easier to query and parse from PowerShell than COM/WBEM
; bindings inside a compact PureBasic tray app.
Procedure.s PowerShellCapture(command$, timeoutMs.i = #BatteryWmiTimeoutMs)
  ProcedureReturn RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(command$), "", timeoutMs)
EndProcedure

; The retained CSV combines battery sample rows, PC power-event rows, and app
; status/lifecycle rows. It is deliberately under APPDATA for non-elevated use.
Procedure.s BatteryLogPath()
  ProcedureReturn SettingsDirectory() + "\battery-log.csv"
EndProcedure

; ISO-like timestamps sort lexically and are easy to parse from PowerShell,
; PureBasic, and spreadsheet tools.
Procedure.s IsoTimestamp(timestamp.q)
  ProcedureReturn FormatDate("%yyyy-%mm-%ddT%hh:%ii:%ss", timestamp)
EndProcedure

Procedure.s DisplayTimestamp(timestamp.q)
  ProcedureReturn FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", timestamp)
EndProcedure

Procedure.s DisplayShortTimestamp(timestamp.q)
  ProcedureReturn FormatDate("%mm-%dd %hh:%ii", timestamp)
EndProcedure

Procedure.s BatteryLogTimestampForDisplay(timestamp$)
  Protected parsed.q
  parsed = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", timestamp$)
  If parsed <= 0
    parsed = ParseDate("%yyyy-%mm-%dd %hh:%ii:%ss", timestamp$)
  EndIf
  If parsed > 0
    ProcedureReturn DisplayTimestamp(parsed)
  EndIf
  ProcedureReturn ReplaceString(timestamp$, "T", " ")
EndProcedure

; Keep the header stable. Older rows can have missing or legacy fields, so all
; CSV readers in this file check field counts before reading newer columns.
Procedure.s BatteryLogHeader()
  ProcedureReturn "timestamp,battery_percent,connected,charging,disconnected_battery,remaining_mwh,full_mwh,design_mwh,wear_percent,discharge_rate_mw,charge_rate_mw,runtime_minutes,average_estimate_minutes,instant_estimate_minutes,instant_drain_pct_hour,smoothed_drain_pct_hour,cycle_count,row_type,event_name,screen_event,screen_brightness_percent,energy_saver_on"
EndProcedure

Procedure EnsureBatteryLogHeaderCurrent()
  Protected path$ = BatteryLogPath()
  Protected firstLine$
  Protected text$
  If FileSize(path$) <= 0
    ProcedureReturn
  EndIf
  If ReadFile(0, path$)
    firstLine$ = ReadString(0)
    If firstLine$ = BatteryLogHeader() Or Left(firstLine$, 9) <> "timestamp"
      CloseFile(0)
      ProcedureReturn
    EndIf
    text$ = BatteryLogHeader() + #CRLF$
    While Eof(0) = 0
      text$ + ReadString(0) + #CRLF$
    Wend
    CloseFile(0)
    If CreateFile(0, path$)
      WriteString(0, text$)
      CloseFile(0)
    EndIf
  EndIf
EndProcedure

Procedure.s BatteryLogBrightnessText()
  If gLastScreenBrightnessPercent >= 0 And gLastScreenBrightnessPercent <= 100
    ProcedureReturn Str(gLastScreenBrightnessPercent)
  EndIf
  ProcedureReturn ""
EndProcedure

Procedure.i ShouldQueryScreenBrightness()
  ProcedureReturn Bool(LCase(gLastScreenEvent$) <> "screen off")
EndProcedure

; Laptop-panel brightness is sampled only when a normal retained CSV row is
; written. Match WmiMonitorBrightness to WmiMonitorConnectionParams so external
; displays do not replace the built-in panel value when they are active.
Procedure.i QueryScreenBrightnessPercent()
  Protected output$ = Trim(PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $b=@(Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBrightness); $c=@(Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams); $internal=@([uint32]2147483648,[uint32]6,[uint32]11,[uint32]13); $target=$null; foreach($cp in @($c | Where-Object { $internal -contains [uint32]$_.VideoOutputTechnology })) { $target=@($b | Where-Object { $_.InstanceName -eq $cp.InstanceName } | Select-Object -First 1); if($target) { break } }; if(-not $target -and $b.Count -eq 1) { $target=$b[0] }; if($target -and $null -ne $target.CurrentBrightness) { [int]$target.CurrentBrightness; exit }; $active=@($c | Where-Object { $_.Active -ne $false }); $internalActive=@($active | Where-Object { $internal -contains [uint32]$_.VideoOutputTechnology }); $externalActive=@($active | Where-Object { $internal -notcontains [uint32]$_.VideoOutputTechnology }); $allowDxva=(($c.Count -gt 0 -and $internalActive.Count -eq 1 -and $externalActive.Count -eq 0) -or ($c.Count -eq 0 -and @(Get-CimInstance -ClassName Win32_Battery).Count -gt 0)); if(-not $allowDxva) { exit }; $q=[char]34; $sig='using System; using System.Runtime.InteropServices; public static class PPMon { public delegate bool MonitorEnumProc(IntPtr hMonitor, IntPtr hdcMonitor, IntPtr lprcMonitor, IntPtr dwData); [DllImport('+$q+'user32.dll'+$q+')] public static extern bool EnumDisplayMonitors(IntPtr hdc, IntPtr lprcClip, MonitorEnumProc lpfnEnum, IntPtr dwData); [DllImport('+$q+'dxva2.dll'+$q+', SetLastError=true)] public static extern bool GetNumberOfPhysicalMonitorsFromHMONITOR(IntPtr hMonitor, out uint count); [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public struct PHYSICAL_MONITOR { public IntPtr hPhysicalMonitor; [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string szPhysicalMonitorDescription; } [DllImport('+$q+'dxva2.dll'+$q+', SetLastError=true)] public static extern bool GetPhysicalMonitorsFromHMONITOR(IntPtr hMonitor, uint count, [Out] PHYSICAL_MONITOR[] monitors); [DllImport('+$q+'dxva2.dll'+$q+', SetLastError=true)] public static extern bool DestroyPhysicalMonitors(uint count, PHYSICAL_MONITOR[] monitors); [DllImport('+$q+'dxva2.dll'+$q+', SetLastError=true)] public static extern bool GetMonitorBrightness(IntPtr hMonitor, out uint min, out uint cur, out uint max); }'; Add-Type $sig; $vals=New-Object System.Collections.Generic.List[int]; $cb=[PPMon+MonitorEnumProc]{ param([IntPtr]$h,[IntPtr]$hdc,[IntPtr]$r,[IntPtr]$d) $n=0; if([PPMon]::GetNumberOfPhysicalMonitorsFromHMONITOR($h,[ref]$n) -and $n -gt 0) { $m=New-Object PPMon+PHYSICAL_MONITOR[] $n; if([PPMon]::GetPhysicalMonitorsFromHMONITOR($h,$n,$m)) { foreach($p in $m) { $min=0; $cur=0; $max=0; if([PPMon]::GetMonitorBrightness($p.hPhysicalMonitor,[ref]$min,[ref]$cur,[ref]$max) -and $max -gt $min) { $pct=[int][Math]::Round((($cur-$min)*100.0)/($max-$min)); if($pct -ge 0 -and $pct -le 100) { $vals.Add($pct) } } }; [PPMon]::DestroyPhysicalMonitors($n,$m) | Out-Null } }; return $true }; [PPMon]::EnumDisplayMonitors([IntPtr]::Zero,[IntPtr]::Zero,$cb,[IntPtr]::Zero) | Out-Null; $u=@($vals | Select-Object -Unique); if($u.Count -eq 1) { [int]$u[0] }", 6000))
  Protected value.i
  If output$ = ""
    ProcedureReturn -1
  EndIf
  value = Val(StringField(output$, 1, #LF$))
  If value < 0 Or value > 100
    ProcedureReturn -1
  EndIf
  ProcedureReturn value
EndProcedure

Procedure.s BatteryLogListRow(c0$, c1$, c2$, c3$, c4$, c5$, c6$, c7$, c8$, c9$)
  ProcedureReturn c0$ + Chr(10) + c1$ + Chr(10) + c2$ + Chr(10) + c3$ + Chr(10) + c4$ + Chr(10) + c5$ + Chr(10) + c6$ + Chr(10) + c7$ + Chr(10) + c8$ + Chr(10) + c9$
EndProcedure

; Event names live in a CSV cell, so remove separators/control characters but
; preserve enough text for user-visible PowerPilot Log messages.
Procedure.s CleanBatteryEventName(eventName$)
  eventName$ = ReplaceString(eventName$, ",", " ")
  eventName$ = ReplaceString(eventName$, #CR$, " ")
  eventName$ = ReplaceString(eventName$, #LF$, " ")
  eventName$ = ReplaceString(eventName$, #TAB$, " ")
  While FindString(eventName$, "  ", 1)
    eventName$ = ReplaceString(eventName$, "  ", " ")
  Wend
  ProcedureReturn Trim(eventName$)
EndProcedure

; Escape a PowerShell single-quoted literal. This avoids interpreting user or
; filesystem text as script when passing paths to helper commands.
Procedure.s PowerShellLiteral(value$)
  ProcedureReturn "'" + ReplaceString(value$, "'", "''") + "'"
EndProcedure

; Parse key=value pairs from the compact pipe-separated PowerShell output used
; by battery WMI queries.
Procedure.s BatteryFieldValue(line$, key$)
  Protected token$ = key$ + "="
  Protected pos.i = FindString(line$, token$, 1)
  Protected endPos.i
  If pos = 0
    ProcedureReturn ""
  EndIf
  pos + Len(token$)
  endPos = FindString(line$, "|", pos)
  If endPos = 0
    endPos = Len(line$) + 1
  EndIf
  ProcedureReturn Mid(line$, pos, endPos - pos)
EndProcedure

; PowerShell Boolean string normalization.
Procedure.i BatteryBool(value$)
  value$ = LCase(Trim(value$))
  ProcedureReturn Bool(value$ = "true" Or value$ = "1" Or value$ = "yes")
EndProcedure

Procedure.q BatteryParseTimestamp(timestamp$)
  Protected parsed.q
  timestamp$ = Trim(timestamp$)
  parsed = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", timestamp$)
  If parsed <= 0
    parsed = ParseDate("%yyyy-%mm-%dd %hh:%ii:%ss", timestamp$)
  EndIf
  ProcedureReturn parsed
EndProcedure

Procedure.i BatteryOperatingPhase(connected.i, charging.i, disconnectedBattery.i)
  connected = Bool(connected)
  charging = Bool(charging)
  disconnectedBattery = Bool(disconnectedBattery)
  If connected = #False And disconnectedBattery
    ProcedureReturn #BatteryPhaseOnBatteryNormal
  EndIf
  If connected And charging
    ProcedureReturn #BatteryPhaseCharging
  EndIf
  If connected And charging = #False And disconnectedBattery
    ProcedureReturn #BatteryPhasePluggedDischargingCalibration
  EndIf
  If connected And charging = #False And disconnectedBattery = #False
    ProcedureReturn #BatteryPhasePluggedIdleOrFull
  EndIf
  ProcedureReturn #BatteryPhaseUnknown
EndProcedure

Procedure.s BatteryPhaseName(phase.i)
  Select phase
    Case #BatteryPhaseOnBatteryNormal
      ProcedureReturn "OnBatteryNormal"
    Case #BatteryPhaseCharging
      ProcedureReturn "Charging"
    Case #BatteryPhasePluggedDischargingCalibration
      ProcedureReturn "PluggedDischargingCalibration"
    Case #BatteryPhasePluggedIdleOrFull
      ProcedureReturn "PluggedIdleOrFull"
  EndSelect
  ProcedureReturn "Unknown"
EndProcedure

Procedure.i ParseBatteryLogRow(line$, *row.BatteryLogRow)
  Protected fieldCount.i
  Protected brightness$
  If *row = 0 Or Trim(line$) = "" Or Left(line$, 9) = "timestamp"
    ProcedureReturn #False
  EndIf
  fieldCount = CountString(line$, ",") + 1
  If fieldCount < 1
    ProcedureReturn #False
  EndIf
  InitializeStructure(*row, BatteryLogRow)
  *row\Timestamp = BatteryParseTimestamp(StringField(line$, 1, ","))
  *row\BatteryPercent = ValD(StringField(line$, 2, ","))
  *row\Connected = Val(StringField(line$, 3, ","))
  *row\Charging = Val(StringField(line$, 4, ","))
  *row\DisconnectedBattery = Val(StringField(line$, 5, ","))
  *row\RemainingMWh = ValD(StringField(line$, 6, ","))
  *row\FullMWh = ValD(StringField(line$, 7, ","))
  *row\DesignMWh = ValD(StringField(line$, 8, ","))
  *row\WearPercent = ValD(StringField(line$, 9, ","))
  *row\DischargeRateMW = ValD(StringField(line$, 10, ","))
  *row\ChargeRateMW = ValD(StringField(line$, 11, ","))
  *row\RuntimeMinutes = Val(StringField(line$, 12, ","))
  *row\AverageEstimateMinutes = Val(StringField(line$, 13, ","))
  *row\InstantEstimateMinutes = Val(StringField(line$, 14, ","))
  *row\InstantDrainPctPerHour = ValD(StringField(line$, 15, ","))
  *row\SmoothedDrainPctPerHour = ValD(StringField(line$, 16, ","))
  *row\CycleCount = Val(StringField(line$, 17, ","))
  If fieldCount >= 18
    *row\RowType = LCase(Trim(StringField(line$, 18, ",")))
  EndIf
  If *row\RowType = ""
    *row\RowType = "battery"
  EndIf
  If fieldCount >= 19 : *row\EventName = StringField(line$, 19, ",") : EndIf
  If fieldCount >= 20 : *row\ScreenEvent = StringField(line$, 20, ",") : EndIf
  *row\ScreenBrightnessPercent = -1
  If fieldCount >= 21
    brightness$ = Trim(StringField(line$, 21, ","))
    If brightness$ <> ""
      *row\ScreenBrightnessPercent = Val(brightness$)
    EndIf
  EndIf
  If fieldCount >= 22
    *row\EnergySaverOn = Val(StringField(line$, 22, ","))
  EndIf
  *row\Phase = BatteryOperatingPhase(*row\Connected, *row\Charging, *row\DisconnectedBattery)
  ProcedureReturn Bool(*row\Timestamp > 0)
EndProcedure

; Stable capacity is preferred over the latest instantaneous FullMWh because
; firmware can expose temporary gauge recalibration values. If no stable value
; has been learned yet, fall back through the live snapshot to raw FullMWh.
Procedure.d BatteryRuntimeFullMWh()
  If gBatteryStableFullMWh > 0.0
    ProcedureReturn gBatteryStableFullMWh
  EndIf
  If gBattery\StableFullMWh > 0.0
    ProcedureReturn gBattery\StableFullMWh
  EndIf
  ProcedureReturn gBattery\FullMWh
EndProcedure

Procedure.i BatteryCurrentScreenOnKnown()
  Protected screen$ = LCase(gLastScreenEvent$)
  ProcedureReturn Bool(screen$ = "screen off" Or screen$ = "screen on" Or screen$ = "screen dimmed")
EndProcedure

Procedure.i BatteryCurrentScreenOn()
  Protected screen$ = LCase(gLastScreenEvent$)
  ProcedureReturn Bool(screen$ = "screen on" Or screen$ = "screen dimmed")
EndProcedure

; Battery use buckets are a local heuristic used for analysis summaries. They
; deliberately avoid making hardware claims: the buckets only describe the
; context PowerPilot can observe, such as screen state, brightness, Energy
; Saver state, and total battery watts.
Procedure.i BatteryUseCategory(screenOnKnown.i, screenOn.i, brightness.i, watts.d, energySaverOn.i)
  If watts >= 15.0
    ProcedureReturn #BatteryUseHighLoad
  EndIf
  If screenOnKnown And screenOn = #False
    ProcedureReturn #BatteryUseScreenOff
  EndIf
  If screenOnKnown And screenOn
    If brightness >= 0 And brightness <= 35
      ProcedureReturn #BatteryUseLowBrightness
    EndIf
    ProcedureReturn #BatteryUseActive
  EndIf
  If energySaverOn And watts > 0.0 And watts < 8.0
    ProcedureReturn #BatteryUseLowBrightness
  EndIf
  ProcedureReturn #BatteryUseActive
EndProcedure

Procedure.d RobustAverageWatts(Array values.d(1), count.i)
  Protected i.i
  Protected j.i
  Protected trim.i
  Protected first.i
  Protected last.i
  Protected used.i
  Protected total.d
  Protected tempValue.d
  If count <= 0
    ProcedureReturn 0.0
  EndIf
  For i = 0 To count - 2
    For j = i + 1 To count - 1
      If values(j) < values(i)
        tempValue = values(i)
        values(i) = values(j)
        values(j) = tempValue
      EndIf
    Next
  Next
  trim = count / 10
  first = trim
  last = count - trim - 1
  If first > last
    first = 0
    last = count - 1
  EndIf
  For i = first To last
    total + values(i)
    used + 1
  Next
  If used <= 0
    ProcedureReturn 0.0
  EndIf
  ProcedureReturn total / used
EndProcedure

Procedure SetBatteryEstimate(*estimate.BatteryPowerEstimate, watts.d, count.i)
  If *estimate = 0
    ProcedureReturn
  EndIf
  *estimate\Watts = watts
  *estimate\Count = count
  *estimate\Valid = Bool(watts > 0.0 And count > 0)
EndProcedure

; Windows battery firmware can change FullChargedCapacity abruptly after a
; calibration run. Treat the first jump as a candidate instead of immediately
; rewriting the stable capacity used by estimates. After the same new capacity
; appears enough times, accept it as the new stable value. This keeps one-off
; firmware spikes from making the runtime and wear displays jump around.
Procedure UpdateBatteryCapacityHealth(timestamp.q, fullMWh.d, designMWh.d)
  Protected changeRatio.d
  If designMWh > 0.0
    gBatteryStableDesignMWh = designMWh
  EndIf
  If fullMWh <= 0.0
    ProcedureReturn
  EndIf
  If gBatteryStableFullMWh <= 0.0
    gBatteryStableFullMWh = fullMWh
    gBatteryCapacityCandidateMWh = fullMWh
    gBatteryCapacityCandidateStartTime = timestamp
    gBatteryCapacityCandidateCount = 1
  Else
    changeRatio = Abs(fullMWh - gBatteryStableFullMWh) / gBatteryStableFullMWh
    If changeRatio > #BatteryCapacityRecalibrationThreshold
      gBatteryCapacityRecalibrationDetected = #True
      If gBatteryCapacityCandidateMWh > 0.0 And Abs(fullMWh - gBatteryCapacityCandidateMWh) / gBatteryCapacityCandidateMWh <= #BatteryCapacityRecalibrationThreshold
        gBatteryCapacityCandidateCount + 1
      Else
        gBatteryCapacityCandidateMWh = fullMWh
        gBatteryCapacityCandidateStartTime = timestamp
        gBatteryCapacityCandidateCount = 1
      EndIf
      If gBatteryCapacityCandidateCount >= #BatteryStableCapacityMinSamples
        gBatteryStableFullMWh = gBatteryCapacityCandidateMWh
      EndIf
    Else
      gBatteryCapacityCandidateMWh = fullMWh
      gBatteryCapacityCandidateStartTime = timestamp
      gBatteryCapacityCandidateCount = #BatteryStableCapacityMinSamples
      gBatteryStableFullMWh = ((gBatteryStableFullMWh * 2.0) + fullMWh) / 3.0
    EndIf
  EndIf
  If gBatteryStableFullMWh > 0.0 And gBatteryStableDesignMWh > 0.0
    gBatteryStableWearPercent = 100.0 - ((gBatteryStableFullMWh / gBatteryStableDesignMWh) * 100.0)
    If gBatteryStableWearPercent < 0.0 : gBatteryStableWearPercent = 0.0 : EndIf
  EndIf
  gBattery\StableFullMWh = gBatteryStableFullMWh
  gBattery\StableWearPercent = gBatteryStableWearPercent
EndProcedure

; The graph/estimate "full" point can be a user maximum or a limiter-reported
; charge maximum. The minimum percent is handled separately as the empty floor.
Procedure.d BatteryEffectiveMaxPercent()
  Protected maxPercent.i = gSettings\BatteryMaxPercent
  If gSettings\BatteryLimiterEnabled
    maxPercent = gSettings\BatteryLimiterMaxPercent
  EndIf
  If maxPercent <= gSettings\BatteryMinPercent
    maxPercent = gSettings\BatteryMinPercent + 1
  EndIf
  ProcedureReturn maxPercent
EndProcedure

; Format minute estimates consistently across live display and PowerPilot Log.
Procedure.s FormatBatteryMinutes(minutes.i)
  Protected hours.i
  Protected mins.i
  If minutes < 0
    ProcedureReturn "Unknown"
  EndIf
  hours = minutes / 60
  mins = minutes % 60
  ProcedureReturn Str(hours) + "h " + RSet(Str(mins), 2, "0") + "m"
EndProcedure

Procedure.s FormatBatteryRuntimeMinutes(minutes.i, connected.i)
  If minutes <= 0 And connected
    ProcedureReturn "Plugged in"
  EndIf
  ProcedureReturn FormatBatteryMinutes(minutes)
EndProcedure

Procedure.d BatterySignedWatts(dischargeRateMW.d, chargeRateMW.d)
  If chargeRateMW > 0.0
    ProcedureReturn chargeRateMW / 1000.0
  EndIf
  If dischargeRateMW > 0.0
    ProcedureReturn -dischargeRateMW / 1000.0
  EndIf
  ProcedureReturn 0.0
EndProcedure

Procedure.s FormatSignedBatteryWatts(dischargeRateMW.d, chargeRateMW.d)
  Protected watts.d = BatterySignedWatts(dischargeRateMW, chargeRateMW)
  If watts > 0.0
    ProcedureReturn "Charging " + StrD(watts, 2) + " W"
  EndIf
  If watts < 0.0
    ProcedureReturn "Discharging " + StrD(Abs(watts), 2) + " W"
  EndIf
  ProcedureReturn "Idle 0.00 W"
EndProcedure

Procedure RememberBatteryPowerState(connected.i, charging.i)
  gBatteryPowerStateKnown = #True
  gBatteryPowerStateConnected = Bool(connected)
  gBatteryPowerStateCharging = Bool(charging)
EndProcedure

Procedure.i BatteryPowerStateChangedFromSystem()
  Protected status.SYSTEM_POWER_STATUS
  Protected connected.i
  Protected charging.i
  Protected changed.i
  If GetSystemPowerStatus_(@status) = #False
    ProcedureReturn #True
  EndIf
  connected = Bool(status\ACLineStatus <> 0)
  charging = Bool(status\BatteryFlag & 8)
  changed = Bool(gBatteryPowerStateKnown = #False Or connected <> gBatteryPowerStateConnected Or charging <> gBatteryPowerStateCharging)
  RememberBatteryPowerState(connected, charging)
  ProcedureReturn changed
EndProcedure

Procedure.i PowerPilotControlledEnergySaverActive()
  Protected activeName$ = NormalizePlanName(gCachedActiveName$)
  If activeName$ = ""
    activeName$ = NormalizePlanName(gSettings\LastPlan)
  EndIf
  ProcedureReturn Bool(gSettings\EnergySaverMode = #EnergySaverPowerPilotControlled And activeName$ = #PlanBattery$)
EndProcedure

Procedure SetEnergySaverSubgroupGuid(*guid.GuidValue)
  *guid\Data1 = $DE830923
  *guid\Data2 = $A562
  *guid\Data3 = $41AF
  *guid\Data4[0] = $A0
  *guid\Data4[1] = $86
  *guid\Data4[2] = $E3
  *guid\Data4[3] = $A2
  *guid\Data4[4] = $C6
  *guid\Data4[5] = $BA
  *guid\Data4[6] = $D2
  *guid\Data4[7] = $DA
EndProcedure

Procedure SetEnergySaverPolicyGuid(*guid.GuidValue)
  *guid\Data1 = $5C5BB349
  *guid\Data2 = $AD29
  *guid\Data3 = $4EE2
  *guid\Data4[0] = $9D
  *guid\Data4[1] = $0B
  *guid\Data4[2] = $2B
  *guid\Data4[3] = $25
  *guid\Data4[4] = $27
  *guid\Data4[5] = $0F
  *guid\Data4[6] = $7A
  *guid\Data4[7] = $81
EndProcedure

Procedure SetEnergySaverThresholdGuid(*guid.GuidValue)
  *guid\Data1 = $E69653CA
  *guid\Data2 = $CF7F
  *guid\Data3 = $4F05
  *guid\Data4[0] = $AA
  *guid\Data4[1] = $73
  *guid\Data4[2] = $CB
  *guid\Data4[3] = $83
  *guid\Data4[4] = $3F
  *guid\Data4[5] = $A9
  *guid\Data4[6] = $0A
  *guid\Data4[7] = $D4
EndProcedure

Procedure.i ReadActiveEnergySaverSetting(*settingGuid.GuidValue, *value.Long)
  Protected activeScheme.i
  Protected subGroup.GuidValue
  Protected result.i
  EnsurePowerApi()
  If gPowerGetActiveScheme = 0 Or gPowerReadACValueIndex = 0 Or gPowerReadDCValueIndex = 0
    ProcedureReturn #False
  EndIf
  If gPowerGetActiveScheme(0, @activeScheme) <> #ERROR_SUCCESS Or activeScheme = 0
    ProcedureReturn #False
  EndIf
  SetEnergySaverSubgroupGuid(@subGroup)
  If CurrentPowerSupplyIsBattery()
    result = gPowerReadDCValueIndex(0, activeScheme, @subGroup, *settingGuid, *value)
  Else
    result = gPowerReadACValueIndex(0, activeScheme, @subGroup, *settingGuid, *value)
  EndIf
  LocalFree_(activeScheme)
  ProcedureReturn Bool(result = #ERROR_SUCCESS)
EndProcedure

Procedure.i WindowsEnergySaverPolicyActive()
  Protected policyGuid.GuidValue
  Protected thresholdGuid.GuidValue
  Protected status.SYSTEM_POWER_STATUS
  Protected policy.l
  Protected threshold.l
  SetEnergySaverPolicyGuid(@policyGuid)
  If ReadActiveEnergySaverSetting(@policyGuid, @policy)
    If policy = #EnergySaverPolicyAggressive
      ProcedureReturn #True
    EndIf
  EndIf
  SetEnergySaverThresholdGuid(@thresholdGuid)
  If ReadActiveEnergySaverSetting(@thresholdGuid, @threshold)
    If GetSystemPowerStatus_(@status) And status\ACLineStatus = 0 And status\BatteryLifePercent <= 100 And threshold > 0 And status\BatteryLifePercent <= threshold
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.i WindowsEnergySaverActive()
  Protected status.SYSTEM_POWER_STATUS
  If GetSystemPowerStatus_(@status)
    If status\SystemStatusFlag & 1
      ProcedureReturn #True
    EndIf
  EndIf
  If WindowsEnergySaverPolicyActive()
    ProcedureReturn #True
  EndIf
  ProcedureReturn PowerPilotControlledEnergySaverActive()
EndProcedure

Procedure UpdateEnergySaverLogState(energySaverOn.i)
  energySaverOn = Bool(energySaverOn)
  If gEnergySaverStateKnown = #False
    gEnergySaverStateKnown = #True
    gEnergySaverStateOn = energySaverOn
    If energySaverOn
      WriteBatteryEnergySaverEvent(#True)
    EndIf
    ProcedureReturn
  EndIf
  If energySaverOn <> gEnergySaverStateOn
    gEnergySaverStateOn = energySaverOn
    WriteBatteryEnergySaverEvent(energySaverOn)
  EndIf
EndProcedure

Procedure TrackEnergySaverLogState()
  If gBattery\Valid = #False
    ProcedureReturn
  EndIf
  UpdateEnergySaverLogState(gBattery\EnergySaverOn)
EndProcedure

Procedure.q FileTimeValue100Ns(*time.FILETIME)
  ProcedureReturn ((*time\dwHighDateTime & $FFFFFFFF) << 32) | (*time\dwLowDateTime & $FFFFFFFF)
EndProcedure

Procedure.q CurrentProcessCpuTime100Ns()
  Protected created.FILETIME
  Protected exited.FILETIME
  Protected kernel.FILETIME
  Protected user.FILETIME
  If GetProcessTimes_(GetCurrentProcess_(), @created, @exited, @kernel, @user)
    ProcedureReturn FileTimeValue100Ns(@kernel) + FileTimeValue100Ns(@user)
  EndIf
  ProcedureReturn 0
EndProcedure

; Keep a short rolling CPU-time series for the Power Use tab. The app compares
; the first and last points in the recent window, normalizes by logical CPU
; capacity, then estimates how much of the observed/learned battery drain is
; attributable to this process. The raw points are tiny, so an array is simpler
; and more predictable than a list for a tray app.
Procedure AddPowerPilotUsePoint(timestamp.q, cpuTime100Ns.q)
  Protected i.i
  Protected cutoff.q = timestamp - (#PowerPilotUseWindowSeconds * 4)
  Protected removeCount.i
  If timestamp <= 0 Or cpuTime100Ns <= 0
    ProcedureReturn
  EndIf
  If gPowerPilotUsePointCount > 0 And gPowerPilotUsePoints(gPowerPilotUsePointCount - 1)\Timestamp = timestamp
    gPowerPilotUsePoints(gPowerPilotUsePointCount - 1)\CpuTime100Ns = cpuTime100Ns
  ElseIf gPowerPilotUsePointCount < #PowerPilotUseMaxPoints
    gPowerPilotUsePoints(gPowerPilotUsePointCount)\Timestamp = timestamp
    gPowerPilotUsePoints(gPowerPilotUsePointCount)\CpuTime100Ns = cpuTime100Ns
    gPowerPilotUsePointCount + 1
  Else
    For i = 1 To #PowerPilotUseMaxPoints - 1
      gPowerPilotUsePoints(i - 1) = gPowerPilotUsePoints(i)
    Next
    gPowerPilotUsePoints(#PowerPilotUseMaxPoints - 1)\Timestamp = timestamp
    gPowerPilotUsePoints(#PowerPilotUseMaxPoints - 1)\CpuTime100Ns = cpuTime100Ns
  EndIf
  While removeCount < gPowerPilotUsePointCount - 1 And gPowerPilotUsePoints(removeCount)\Timestamp < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gPowerPilotUsePointCount - 1
      gPowerPilotUsePoints(i - removeCount) = gPowerPilotUsePoints(i)
    Next
    gPowerPilotUsePointCount - removeCount
  EndIf
EndProcedure

; GUID_DEVCLASS_BATTERY is filled manually so the source stays PureBasic-only
; and does not depend on importing a Windows SDK header.
Procedure SetBatteryClassGuid(*guid.GuidValue)
  *guid\Data1 = $72631E54
  *guid\Data2 = $78A4
  *guid\Data3 = $11D0
  *guid\Data4[0] = $BC
  *guid\Data4[1] = $F7
  *guid\Data4[2] = $00
  *guid\Data4[3] = $AA
  *guid\Data4[4] = $00
  *guid\Data4[5] = $B7
  *guid\Data4[6] = $B3
  *guid\Data4[7] = $2A
EndProcedure

Procedure.i EnsureSetupApi()
  If gSetupApiTried
    ProcedureReturn Bool(gSetupDiGetClassDevs And gSetupDiEnumDeviceInterfaces And gSetupDiGetDeviceInterfaceDetail And gSetupDiDestroyDeviceInfoList)
  EndIf
  gSetupApiTried = #True
  gSetupApiLibrary = OpenLibrary(#PB_Any, "setupapi.dll")
  If gSetupApiLibrary
    gSetupDiGetClassDevs = GetFunction(gSetupApiLibrary, "SetupDiGetClassDevsW")
    gSetupDiEnumDeviceInterfaces = GetFunction(gSetupApiLibrary, "SetupDiEnumDeviceInterfaces")
    gSetupDiGetDeviceInterfaceDetail = GetFunction(gSetupApiLibrary, "SetupDiGetDeviceInterfaceDetailW")
    gSetupDiDestroyDeviceInfoList = GetFunction(gSetupApiLibrary, "SetupDiDestroyDeviceInfoList")
  EndIf
  ProcedureReturn Bool(gSetupDiGetClassDevs And gSetupDiEnumDeviceInterfaces And gSetupDiGetDeviceInterfaceDetail And gSetupDiDestroyDeviceInfoList)
EndProcedure

; Native battery reads need the device interface path for GUID_DEVCLASS_BATTERY.
; SetupAPI enumeration is cached after the first successful path because laptop
; battery devices rarely change while the app is running. If enumeration fails,
; the higher-level refresh path falls back to WMI rather than surfacing an error
; in the UI.
Procedure.s NativeBatteryDevicePath()
  Protected guid.GuidValue
  Protected hdev.i
  Protected index.i
  Protected ifaceData.DeviceInterfaceData
  Protected detail.DeviceInterfaceDetailData
  Protected requiredSize.l
  Protected path$
  If gBatteryDevicePath$ <> ""
    ProcedureReturn gBatteryDevicePath$
  EndIf
  If EnsureSetupApi() = #False
    ProcedureReturn ""
  EndIf
  SetBatteryClassGuid(@guid)
  hdev = gSetupDiGetClassDevs(@guid, 0, 0, #SetupDigcfPresent | #SetupDigcfDeviceInterface)
  If hdev = #INVALID_HANDLE_VALUE
    ProcedureReturn ""
  EndIf
  For index = 0 To 99
    FillMemory(@ifaceData, SizeOf(DeviceInterfaceData), 0)
    ifaceData\cbSize = SizeOf(DeviceInterfaceData)
    If gSetupDiEnumDeviceInterfaces(hdev, 0, @guid, index, @ifaceData) = #False
      If GetLastError_() = #SetupErrorNoMoreItems
        Break
      EndIf
      Continue
    EndIf
    requiredSize = 0
    gSetupDiGetDeviceInterfaceDetail(hdev, @ifaceData, 0, 0, @requiredSize, 0)
    If requiredSize > SizeOf(DeviceInterfaceDetailData)
      Continue
    EndIf
    FillMemory(@detail, SizeOf(DeviceInterfaceDetailData), 0)
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      detail\cbSize = 8
    CompilerElse
      detail\cbSize = 6
    CompilerEndIf
    If gSetupDiGetDeviceInterfaceDetail(hdev, @ifaceData, @detail, SizeOf(DeviceInterfaceDetailData), @requiredSize, 0)
      path$ = PeekS(@detail\DevicePath[0])
      If path$ <> ""
        gBatteryDevicePath$ = path$
        Break
      EndIf
    EndIf
  Next
  gSetupDiDestroyDeviceInfoList(hdev)
  ProcedureReturn gBatteryDevicePath$
EndProcedure

Procedure.i NativeBatteryHandle()
  Protected path$ = NativeBatteryDevicePath()
  Protected handle.i
  If path$ = ""
    ProcedureReturn 0
  EndIf
  handle = CreateFile_(path$, #BatteryGenericRead | #BatteryGenericWrite, #BatteryFileShareRead | #BatteryFileShareWrite, 0, #BatteryOpenExisting, 0, 0)
  If handle = #INVALID_HANDLE_VALUE
    gBatteryDevicePath$ = ""
    ProcedureReturn 0
  EndIf
  ProcedureReturn handle
EndProcedure

Procedure.i QueryNativeBatteryData()
  Protected handle.i
  Protected waitInput.l
  Protected tag.l
  Protected bytes.l
  Protected query.BatteryQueryInformation
  Protected info.BatteryInformation
  Protected wait.BatteryWaitStatus
  Protected status.BatteryStatus
  Protected estimatedSeconds.l
  Protected signedRate.l
  Protected relative.i
  Protected percent.d
  handle = NativeBatteryHandle()
  If handle = 0
    ProcedureReturn #False
  EndIf
  If DeviceIoControl_(handle, #BatteryIoctlQueryTag, @waitInput, SizeOf(Long), @tag, SizeOf(Long), @bytes, 0) = #False Or tag = 0
    CloseHandle_(handle)
    ProcedureReturn #False
  EndIf

  query\BatteryTag = tag
  query\InformationLevel = #BatteryInfoLevelInformation
  query\AtRate = 0
  If DeviceIoControl_(handle, #BatteryIoctlQueryInformation, @query, SizeOf(BatteryQueryInformation), @info, SizeOf(BatteryInformation), @bytes, 0)
    relative = Bool(info\Capabilities & #BatteryCapacityRelative)
    If relative = #False
      If info\FullChargedCapacity > 0 And info\FullChargedCapacity <> -1
        gBattery\FullMWh = info\FullChargedCapacity
      EndIf
      If info\DesignedCapacity > 0 And info\DesignedCapacity <> -1
        gBattery\DesignMWh = info\DesignedCapacity
      EndIf
      If gBattery\DesignMWh > 0.0 And gBattery\FullMWh > 0.0
        gBattery\WearPercent = 100.0 - ((gBattery\FullMWh / gBattery\DesignMWh) * 100.0)
        If gBattery\WearPercent < 0.0 : gBattery\WearPercent = 0.0 : EndIf
      EndIf
      UpdateBatteryCapacityHealth(Date(), gBattery\FullMWh, gBattery\DesignMWh)
    EndIf
    If info\CycleCount > 0 And info\CycleCount <> -1
      gBattery\CycleCount = info\CycleCount
    EndIf
  EndIf

  query\BatteryTag = tag
  query\InformationLevel = #BatteryInfoLevelEstimatedTime
  query\AtRate = 0
  If DeviceIoControl_(handle, #BatteryIoctlQueryInformation, @query, SizeOf(BatteryQueryInformation), @estimatedSeconds, SizeOf(Long), @bytes, 0)
    If estimatedSeconds > 0 And estimatedSeconds <> -1 And estimatedSeconds < 864000
      gBattery\RuntimeValid = #True
      gBattery\RuntimeMinutes = estimatedSeconds / 60
    Else
      gBattery\RuntimeValid = #False
      gBattery\RuntimeMinutes = -1
    EndIf
  Else
    gBattery\RuntimeValid = #False
    gBattery\RuntimeMinutes = -1
  EndIf

  wait\BatteryTag = tag
  wait\Timeout = 0
  wait\PowerState = 0
  wait\LowCapacity = 0
  wait\HighCapacity = 0
  If DeviceIoControl_(handle, #BatteryIoctlQueryStatus, @wait, SizeOf(BatteryWaitStatus), @status, SizeOf(BatteryStatus), @bytes, 0) = #False
    CloseHandle_(handle)
    ProcedureReturn #False
  EndIf
  CloseHandle_(handle)

  gBattery\Valid = #True
  gBattery\Timestamp = Date()
  gBattery\Connected = Bool(status\PowerState & #BatteryPowerOnline)
  gBattery\Charging = Bool(status\PowerState & #BatteryPowerCharging)
  gBattery\EnergySaverOn = WindowsEnergySaverActive()
  RememberBatteryPowerState(gBattery\Connected, gBattery\Charging)
  If relative = #False And status\Capacity > 0 And status\Capacity <> -1
    gBattery\RemainingMWh = status\Capacity
  EndIf
  If status\Voltage > 0 And status\Voltage <> -1
    gBattery\VoltageMV = status\Voltage
  EndIf
  signedRate = status\Rate
  If signedRate <> -1 And relative = #False
    If signedRate < 0
      gBattery\DischargeRateMW = -signedRate
      gBattery\ChargeRateMW = 0.0
    ElseIf signedRate > 0
      gBattery\ChargeRateMW = signedRate
      gBattery\DischargeRateMW = 0.0
    Else
      gBattery\ChargeRateMW = 0.0
      gBattery\DischargeRateMW = 0.0
    EndIf
  EndIf
  gBattery\DisconnectedBattery = Bool((status\PowerState & #BatteryPowerOnline) = 0 Or (status\PowerState & #BatteryPowerDischarging) Or gBattery\DischargeRateMW > 0.0)
  If gBattery\FullMWh > 0.0 And gBattery\RemainingMWh > 0.0
    percent = (gBattery\RemainingMWh / gBattery\FullMWh) * 100.0
    If percent > 100.0 : percent = 100.0 : EndIf
    gBattery\Percent = percent
  EndIf
  ProcedureReturn #True
EndProcedure

; Compact elapsed-duration display for session, off-time, and daily summaries.
Procedure.s FormatDurationSeconds(seconds.q)
  Protected hours.q
  Protected mins.q
  If seconds < 0
    seconds = 0
  EndIf
  hours = seconds / 3600
  mins = (seconds % 3600) / 60
  If hours >= 24
    ProcedureReturn Str(hours / 24) + "d " + Str(hours % 24) + "h"
  EndIf
  If hours > 0
    ProcedureReturn Str(hours) + "h " + RSet(Str(mins), 2, "0") + "m"
  EndIf
  ProcedureReturn Str(mins) + "m"
EndProcedure

Procedure.i NormalizeBatteryGraphHours(hours.i)
  Select hours
    Case 6, 12, 18, 24, 36, 48, 60, 72
      ProcedureReturn hours
    Case 35
      ProcedureReturn 36
  EndSelect
  ProcedureReturn #BatteryGraphDefaultHours
EndProcedure

Procedure.i BatteryGraphHoursIndex(hours.i)
  Select NormalizeBatteryGraphHours(hours)
    Case 6 : ProcedureReturn 0
    Case 12 : ProcedureReturn 1
    Case 18 : ProcedureReturn 2
    Case 24 : ProcedureReturn 3
    Case 36 : ProcedureReturn 4
    Case 48 : ProcedureReturn 5
    Case 60 : ProcedureReturn 6
    Case 72 : ProcedureReturn 7
  EndSelect
  ProcedureReturn 3
EndProcedure

Procedure.i BatteryGraphHoursFromIndex(index.i)
  Select index
    Case 0 : ProcedureReturn 6
    Case 1 : ProcedureReturn 12
    Case 2 : ProcedureReturn 18
    Case 3 : ProcedureReturn 24
    Case 4 : ProcedureReturn 36
    Case 5 : ProcedureReturn 48
    Case 6 : ProcedureReturn 60
    Case 7 : ProcedureReturn 72
  EndSelect
  ProcedureReturn #BatteryGraphDefaultHours
EndProcedure

Procedure.q BatteryGraphWindowSeconds()
  ProcedureReturn NormalizeBatteryGraphHours(gSettings\BatteryGraphHours) * 3600
EndProcedure

Procedure.s BatteryGraphWindowTitle()
  ProcedureReturn Str(NormalizeBatteryGraphHours(gSettings\BatteryGraphHours)) + "-Hour Battery Percent"
EndProcedure

; In-memory graph points are capped by both count and the largest selectable
; graph window. The CSV remains the durable source and is reloaded at startup.
Procedure PruneBatteryGraph(now.q)
  Protected cutoff.q = now - #BatteryGraphMaxWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryGraphCount - 1 And gBatteryGraph(removeCount)\Timestamp < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryGraphCount - 1
      gBatteryGraph(i - removeCount) = gBatteryGraph(i)
    Next
    gBatteryGraphCount - removeCount
  EndIf
EndProcedure

; Add one visible graph point. Duplicate timestamps are ignored because WMI
; refresh and forced logging can happen in the same second during startup.
Procedure AddBatteryGraphPoint(timestamp.q, percent.d, connected.i, charging.i, energySaverOn.i = #False, disconnectedBattery.i = -1, remainingMWh.d = 0.0, fullMWh.d = 0.0, dischargeRateMW.d = 0.0, chargeRateMW.d = 0.0, screenOnKnown.i = #False, screenOn.i = #False, brightnessPercent.i = -1)
  Protected i.i
  Protected phase.i
  If percent < 0.0
    ProcedureReturn
  EndIf
  If disconnectedBattery < 0
    disconnectedBattery = Bool(connected = #False)
  EndIf
  phase = BatteryOperatingPhase(connected, charging, disconnectedBattery)
  If gBatteryGraphCount > 0 And gBatteryGraph(gBatteryGraphCount - 1)\Timestamp = timestamp
    gBatteryGraph(gBatteryGraphCount - 1)\Percent = percent
    gBatteryGraph(gBatteryGraphCount - 1)\Connected = connected
    gBatteryGraph(gBatteryGraphCount - 1)\Charging = charging
    gBatteryGraph(gBatteryGraphCount - 1)\DisconnectedBattery = disconnectedBattery
    gBatteryGraph(gBatteryGraphCount - 1)\RemainingMWh = remainingMWh
    gBatteryGraph(gBatteryGraphCount - 1)\FullMWh = fullMWh
    gBatteryGraph(gBatteryGraphCount - 1)\DischargeRateMW = dischargeRateMW
    gBatteryGraph(gBatteryGraphCount - 1)\ChargeRateMW = chargeRateMW
    gBatteryGraph(gBatteryGraphCount - 1)\EnergySaverOn = Bool(energySaverOn)
    gBatteryGraph(gBatteryGraphCount - 1)\Phase = phase
    gBatteryGraph(gBatteryGraphCount - 1)\ScreenOnKnown = Bool(screenOnKnown)
    gBatteryGraph(gBatteryGraphCount - 1)\ScreenOn = Bool(screenOn)
    gBatteryGraph(gBatteryGraphCount - 1)\BrightnessPercent = brightnessPercent
    ProcedureReturn
  EndIf
  If gBatteryGraphCount < #BatteryGraphMaxPoints
    gBatteryGraph(gBatteryGraphCount)\Timestamp = timestamp
    gBatteryGraph(gBatteryGraphCount)\Percent = percent
    gBatteryGraph(gBatteryGraphCount)\Connected = connected
    gBatteryGraph(gBatteryGraphCount)\Charging = charging
    gBatteryGraph(gBatteryGraphCount)\DisconnectedBattery = disconnectedBattery
    gBatteryGraph(gBatteryGraphCount)\RemainingMWh = remainingMWh
    gBatteryGraph(gBatteryGraphCount)\FullMWh = fullMWh
    gBatteryGraph(gBatteryGraphCount)\DischargeRateMW = dischargeRateMW
    gBatteryGraph(gBatteryGraphCount)\ChargeRateMW = chargeRateMW
    gBatteryGraph(gBatteryGraphCount)\EnergySaverOn = Bool(energySaverOn)
    gBatteryGraph(gBatteryGraphCount)\Phase = phase
    gBatteryGraph(gBatteryGraphCount)\ScreenOnKnown = Bool(screenOnKnown)
    gBatteryGraph(gBatteryGraphCount)\ScreenOn = Bool(screenOn)
    gBatteryGraph(gBatteryGraphCount)\BrightnessPercent = brightnessPercent
    gBatteryGraphCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryGraph(i - 1) = gBatteryGraph(i)
    Next
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Timestamp = timestamp
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Percent = percent
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Connected = connected
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Charging = charging
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\DisconnectedBattery = disconnectedBattery
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\RemainingMWh = remainingMWh
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\FullMWh = fullMWh
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\DischargeRateMW = dischargeRateMW
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\ChargeRateMW = chargeRateMW
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\EnergySaverOn = Bool(energySaverOn)
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Phase = phase
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\ScreenOnKnown = Bool(screenOnKnown)
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\ScreenOn = Bool(screenOn)
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\BrightnessPercent = brightnessPercent
  EndIf
  PruneBatteryGraph(timestamp)
EndProcedure

; Average-breaks mark intervals that must not count as active battery drain:
; PC power events, app restarts, reinstall closes, or manual reset boundaries.
Procedure PruneBatteryAverageBreaks(now.q)
  Protected cutoff.q = now - #BatteryGraphMaxWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryAverageBreakCount And gBatteryAverageBreakTime(removeCount) < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryAverageBreakCount - 1
      gBatteryAverageBreakTime(i - removeCount) = gBatteryAverageBreakTime(i)
    Next
    gBatteryAverageBreakCount - removeCount
  EndIf
EndProcedure

; App breaks are tracked separately from power breaks. They reset averages but
; do not create PC-off loss summaries or graph event markers.
Procedure PruneBatteryAppBreaks(now.q)
  Protected cutoff.q = now - #BatteryGraphMaxWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryAppBreakCount And gBatteryAppBreakTime(removeCount) < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryAppBreakCount - 1
      gBatteryAppBreakTime(i - removeCount) = gBatteryAppBreakTime(i)
    Next
    gBatteryAppBreakCount - removeCount
  EndIf
EndProcedure

; Mark a timestamp where active-drain averaging should restart.
Procedure AddBatteryAverageBreak(timestamp.q)
  Protected i.i
  If timestamp <= 0
    ProcedureReturn
  EndIf
  If gBatteryAverageBreakCount > 0 And gBatteryAverageBreakTime(gBatteryAverageBreakCount - 1) = timestamp
    ProcedureReturn
  EndIf
  If gBatteryAverageBreakCount < #BatteryGraphMaxPoints
    gBatteryAverageBreakTime(gBatteryAverageBreakCount) = timestamp
    gBatteryAverageBreakCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryAverageBreakTime(i - 1) = gBatteryAverageBreakTime(i)
    Next
    gBatteryAverageBreakTime(#BatteryGraphMaxPoints - 1) = timestamp
  EndIf
  PruneBatteryAverageBreaks(timestamp)
EndProcedure

; Mark an app lifecycle/status boundary. These rows stay visible in the log.
Procedure AddBatteryAppBreak(timestamp.q)
  Protected i.i
  If timestamp <= 0
    ProcedureReturn
  EndIf
  If gBatteryAppBreakCount > 0 And gBatteryAppBreakTime(gBatteryAppBreakCount - 1) = timestamp
    ProcedureReturn
  EndIf
  If gBatteryAppBreakCount < #BatteryGraphMaxPoints
    gBatteryAppBreakTime(gBatteryAppBreakCount) = timestamp
    gBatteryAppBreakCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryAppBreakTime(i - 1) = gBatteryAppBreakTime(i)
    Next
    gBatteryAppBreakTime(#BatteryGraphMaxPoints - 1) = timestamp
  EndIf
  PruneBatteryAppBreaks(timestamp)
EndProcedure

; Power event markers are kept for graph labels and session summaries.
Procedure PruneBatteryEvents(now.q)
  Protected cutoff.q = now - #BatteryGraphMaxWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryEventCount And gBatteryEvents(removeCount)\Timestamp < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryEventCount - 1
      gBatteryEvents(i - removeCount) = gBatteryEvents(i)
    Next
    gBatteryEventCount - removeCount
  EndIf
EndProcedure

; Add a PC power-event marker to the in-memory graph/event list.
Procedure AddBatteryEventPoint(timestamp.q, eventName$)
  Protected i.i
  eventName$ = CleanBatteryEventName(eventName$)
  If timestamp <= 0 Or eventName$ = ""
    ProcedureReturn
  EndIf
  If gBatteryEventCount > 0 And gBatteryEvents(gBatteryEventCount - 1)\Timestamp = timestamp And gBatteryEvents(gBatteryEventCount - 1)\Name = eventName$
    ProcedureReturn
  EndIf
  If BatteryEventDuplicateNear(timestamp, eventName$)
    ProcedureReturn
  EndIf
  If gBatteryEventCount < #BatteryGraphMaxPoints
    gBatteryEvents(gBatteryEventCount)\Timestamp = timestamp
    gBatteryEvents(gBatteryEventCount)\Name = eventName$
    gBatteryEventCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryEvents(i - 1) = gBatteryEvents(i)
    Next
    gBatteryEvents(#BatteryGraphMaxPoints - 1)\Timestamp = timestamp
    gBatteryEvents(#BatteryGraphMaxPoints - 1)\Name = eventName$
  EndIf
  PruneBatteryEvents(timestamp)
EndProcedure

; These event rows represent time when the machine was not actively running, so
; active drain calculations must not bridge across them.
Procedure.i BatteryEventBreaksAverage(eventName$)
  Protected lower$ = LCase(eventName$)
  ProcedureReturn Bool(FindString(lower$, "sleep", 1) Or FindString(lower$, "hibernate", 1) Or FindString(lower$, "wake", 1) Or FindString(lower$, "shutdown", 1) Or FindString(lower$, "startup", 1) Or FindString(lower$, "improper", 1))
EndProcedure

; Test whether a time interval crosses a break. All interval helpers use sorted
; timestamp arrays and are intentionally inclusive to avoid edge leakage.
Procedure.i BatteryIntervalHasAverageBreak(startTime.q, endTime.q)
  Protected i.i
  If endTime < startTime
    ProcedureReturn #True
  EndIf
  For i = gBatteryAverageBreakCount - 1 To 0 Step -1
    If gBatteryAverageBreakTime(i) <= startTime
      ProcedureReturn #False
    EndIf
    If gBatteryAverageBreakTime(i) <= endTime
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; App breaks reset rolling average samples without counting as sleep/shutdown.
Procedure.i BatteryIntervalHasAppBreak(startTime.q, endTime.q)
  Protected i.i
  If endTime < startTime
    ProcedureReturn #True
  EndIf
  For i = gBatteryAppBreakCount - 1 To 0 Step -1
    If gBatteryAppBreakTime(i) <= startTime
      ProcedureReturn #False
    EndIf
    If gBatteryAppBreakTime(i) <= endTime
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; Power breaks are the subset used by graph off-time markers and off-loss stats.
Procedure.i BatteryIntervalHasPowerBreak(startTime.q, endTime.q)
  Protected i.i
  If endTime < startTime
    ProcedureReturn #True
  EndIf
  For i = gBatteryEventCount - 1 To 0 Step -1
    If gBatteryEvents(i)\Timestamp <= startTime
      ProcedureReturn #False
    EndIf
    If gBatteryEvents(i)\Timestamp <= endTime And BatteryEventBreaksAverage(gBatteryEvents(i)\Name)
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

Procedure.i BatteryIntervalHasSleepHibernateBreak(startTime.q, endTime.q)
  Protected i.i
  If endTime < startTime
    ProcedureReturn #False
  EndIf
  For i = gBatteryEventCount - 1 To 0 Step -1
    If gBatteryEvents(i)\Timestamp <= startTime
      ProcedureReturn #False
    EndIf
    If gBatteryEvents(i)\Timestamp <= endTime And BatteryEventIsSleepHibernate(gBatteryEvents(i)\Name)
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

Procedure.i BatteryIntervalHasSleepHibernateMarkerNearX(startTime.q, endTime.q, markerX.i, graphStartTime.q, graphLeft.i, graphXScale.d, markerThreshold.i)
  Protected i.i
  Protected eventX.i
  Protected shortLabel$
  If endTime < startTime
    ProcedureReturn #False
  EndIf
  For i = gBatteryEventCount - 1 To 0 Step -1
    If gBatteryEvents(i)\Timestamp < startTime
      ProcedureReturn #False
    EndIf
    If gBatteryEvents(i)\Timestamp <= endTime
      shortLabel$ = BatteryEventShortName(gBatteryEvents(i)\Name)
      If shortLabel$ = "Z" Or shortLabel$ = "H" Or BatteryEventIsSleepHibernate(gBatteryEvents(i)\Name)
        eventX = Round(graphLeft + ((gBatteryEvents(i)\Timestamp - graphStartTime) * graphXScale), #PB_Round_Nearest)
        If Abs(eventX - markerX) <= markerThreshold
          ProcedureReturn #True
        EndIf
      EndIf
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; Missing samples beyond this threshold are candidates for offline-looking gaps.
Procedure.i BatteryGraphFlatGapSeconds()
  Protected gap.i = (ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440) * 120) + 60
  Protected refreshGap.i = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600) * 4
  If refreshGap > gap
    gap = refreshGap
  EndIf
  If gap < 600
    gap = 600
  EndIf
  ProcedureReturn gap
EndProcedure

; Decide whether two visible battery samples should be joined as offline/event
; time. Short PowerPilot restarts are not red, but long app-closed gaps still
; mean the graph had no active samples and should not inherit blue/green state.
Procedure.i BatteryGraphOfflineGap(startTime.q, endTime.q)
  Protected elapsed.q
  If endTime < startTime
    ProcedureReturn #True
  EndIf
  If BatteryIntervalHasPowerBreak(startTime, endTime)
    ProcedureReturn #True
  EndIf
  elapsed = endTime - startTime
  If elapsed <= BatteryGraphFlatGapSeconds()
    ProcedureReturn #False
  EndIf
  If BatteryIntervalHasAppBreak(startTime, endTime)
    ProcedureReturn Bool(elapsed >= #BatteryGraphLongAppGapSeconds)
  EndIf
  ProcedureReturn #True
EndProcedure

; Reset the simple last-sample pair used by instant measured-percent drain.
Procedure ResetBatteryAverageSamples()
  gBatteryLastSampleTime = 0
  gBatteryLastSamplePercent = 0.0
  gBatteryLastSampleRemainingMWh = 0.0
  gBatteryFlatSampleCount = 0
  gBatteryOnBatterySince = 0
EndProcedure

; Versioned exe names let installers use side-by-side updates while the newly
; started app closes/removes older stamped builds in the background.
Procedure.i IsPowerPilotVersionedExeName(exeName$)
  exeName$ = LCase(exeName$)
  ProcedureReturn Bool(Left(exeName$, 12) = "powerpilot_v" And Right(exeName$, 4) = ".exe" And FindString(exeName$, "_setup", 1) = 0)
EndProcedure

; Extract only the stamped version part from PowerPilot_Vx.y...exe.
Procedure.s PowerPilotVersionFromExeName(exeName$)
  If IsPowerPilotVersionedExeName(exeName$) = #False
    ProcedureReturn ""
  EndIf
  ProcedureReturn Left(Mid(exeName$, 13), Len(exeName$) - 16)
EndProcedure

; Numeric dotted-version compare for stamped app filenames. Missing segments are
; treated as zero, which is enough for 1.1.YYMM.minute-of-month.
Procedure.i CompareVersionStrings(leftVersion$, rightVersion$)
  Protected i.i
  Protected leftPart.i
  Protected rightPart.i
  For i = 1 To 4
    leftPart = Val(StringField(leftVersion$, i, "."))
    rightPart = Val(StringField(rightVersion$, i, "."))
    If leftPart < rightPart
      ProcedureReturn -1
    ElseIf leftPart > rightPart
      ProcedureReturn 1
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

; Same-version reinstalls must overwrite the running exe, so setup still has to
; stop that exact process before copying files. This helper is called by setup
; first, as the original user, to leave a truthful lifecycle row in the log.
Procedure.i LogUpdateCloseIfSameExeRunning()
  Protected ownPid.i = GetCurrentProcessId_()
  Protected ownName$ = LCase(GetFilePart(ProgramFilename()))
  Protected command$
  Protected output$
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected foundRunningCopy.i
  command$ = "$ownPid=" + Str(ownPid) + "; $ownName=" + PowerShellLiteral(ownName$) + "; @((Get-Process PowerPilot_V* -ErrorAction SilentlyContinue) | Where-Object { $_.Id -ne $ownPid -and (($_.ProcessName + '.exe').ToLowerInvariant()) -eq $ownName }).Count"
  output$ = Trim(PowerShellCapture(command$, 5000))
  If Val(output$) > 0
    WriteBatteryAppEvent("PowerPilot update close")
    ProcedureReturn #True
  EndIf

  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot <> #INVALID_HANDLE_VALUE
    entry\dwSize = SizeOf(PowerPilotProcessEntry32)
    If Process32First_(snapshot, @entry)
      Repeat
        If entry\th32ProcessID <> ownPid And LCase(PeekS(@entry\szExeFile[0])) = ownName$
          foundRunningCopy = #True
          Break
        EndIf
      Until Process32Next_(snapshot, @entry) = #False
    EndIf
    CloseHandle_(snapshot)
  EndIf
  If foundRunningCopy
    WriteBatteryAppEvent("PowerPilot update close")
  EndIf
  ProcedureReturn foundRunningCopy
EndProcedure

; Normal version upgrades install the new exe side-by-side, then close the old
; tray app. Setup calls this helper before cleanup starts so the log gets the
; update-close row even if Windows later requires a force-stop to unlock files.
Procedure.i LogUpdateCloseIfAnyPowerPilotRunning()
  Protected ownPid.i = GetCurrentProcessId_()
  Protected command$
  Protected output$
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected exeName$
  Protected foundRunningCopy.i
  command$ = "$ownPid=" + Str(ownPid) + "; @((Get-Process PowerPilot_V* -ErrorAction SilentlyContinue) | Where-Object { $_.Id -ne $ownPid -and $_.ProcessName -notmatch '_Setup$' }).Count"
  output$ = Trim(PowerShellCapture(command$, 5000))
  If Val(output$) > 0
    WriteBatteryAppEvent("PowerPilot update close")
    ProcedureReturn #True
  EndIf

  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot <> #INVALID_HANDLE_VALUE
    entry\dwSize = SizeOf(PowerPilotProcessEntry32)
    If Process32First_(snapshot, @entry)
      Repeat
        exeName$ = LCase(PeekS(@entry\szExeFile[0]))
        If entry\th32ProcessID <> ownPid And PowerPilotVersionFromExeName(exeName$) <> ""
          foundRunningCopy = #True
          Break
        EndIf
      Until Process32Next_(snapshot, @entry) = #False
    EndIf
    CloseHandle_(snapshot)
  EndIf
  If foundRunningCopy
    WriteBatteryAppEvent("PowerPilot update close")
  EndIf
  ProcedureReturn foundRunningCopy
EndProcedure

; Close older running PowerPilot versions and optionally delete old app files.
; The current process and exact current exe name are excluded so an install
; refresh can launch the new app before cleanup completes.
Procedure.i CleanupOldPowerPilotVersions(deleteFiles.i = #False, logEvent.i = #True)
  Protected ownPid.i = GetCurrentProcessId_()
  Protected ownName$ = LCase(GetFilePart(ProgramFilename()))
  Protected ownVersion$ = #AppVersion$
  Protected dq$ = Chr(34)
  Protected command$
  Protected output$
  Protected line$
  Protected i.i
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected exeName$
  Protected exeVersion$
  Protected processHandle.i
  Protected closed.i
  Protected forced.i
  Protected removed.i
  Protected cleanupText$
  Protected directory.i
  Protected fileName$
  Protected fullPath$

  ; Prefer PowerShell for process cleanup because it handles version parsing and
  ; elevated Program Files deletion better than manual Toolhelp loops. Before
  ; force-stopping anything, send PowerPilot's private update-close message to
  ; older builds. Fixed builds can then write "PowerPilot update close" to the
  ; log, while older builds still get cleaned up by the fallback stop.
  command$ = "$ErrorActionPreference='SilentlyContinue'; $own=" + PowerShellLiteral(ownName$) + "; $ownVersion=[version]" + PowerShellLiteral(ownVersion$) + "; $app=" + PowerShellLiteral(GetPathPart(ProgramFilename())) + "; $closed=0; $forced=0; $removed=0; "
  command$ + "$targets=@(Get-Process PowerPilot_V* | Where-Object { try { $name=$_.ProcessName + '.exe'; if ($name -ne $own -and $_.ProcessName -notmatch '_Setup$') { $v=[version](($_.ProcessName -replace '^PowerPilot_V','')); $v -lt $ownVersion } else { $false } } catch { $false } }); "
  command$ + "if($targets.Count -gt 0) { $sig='using System; using System.Runtime.InteropServices; public static class PPWin { public delegate bool EnumWindowsProc(IntPtr h, IntPtr l); [DllImport(" + dq$ + "user32.dll" + dq$ + ")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr l); [DllImport(" + dq$ + "user32.dll" + dq$ + ")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint p); [DllImport(" + dq$ + "user32.dll" + dq$ + ")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l); }'; Add-Type $sig; foreach($p in $targets) { $script:targetPid=[uint32]$p.Id; $callback=[PPWin+EnumWindowsProc]{ param([IntPtr]$h,[IntPtr]$l) $pid=0; [PPWin]::GetWindowThreadProcessId($h,[ref]$pid) | Out-Null; if($pid -eq $script:targetPid) { [PPWin]::PostMessage($h," + Str(#WM_POWERPILOT_UPDATE_CLOSE) + ",[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null }; return $true }; [PPWin]::EnumWindows($callback,[IntPtr]::Zero) | Out-Null }; Start-Sleep -Milliseconds 1200; foreach($p in $targets) { try { $p.Refresh(); if($p.HasExited) { $closed++ } else { Stop-Process -Id $p.Id -Force; $closed++; $forced++ } } catch { $closed++ } } }; "
  If deleteFiles
    command$ + "Start-Sleep -Milliseconds 500; Get-ChildItem -LiteralPath $app -Filter 'PowerPilot_V*.exe' | ForEach-Object { try { if ($_.Name -ne $own -and $_.Name -notlike '*_Setup.exe') { $v=[version](($_.BaseName -replace '^PowerPilot_V','')); if ($v -lt $ownVersion) { Remove-Item -LiteralPath $_.FullName -Force; $removed++ } } } catch {} }; "
  EndIf
  command$ + "'cleanup|closed=' + $closed + '|forced=' + $forced + '|removed=' + $removed"
  output$ = PowerShellCapture(command$, 8000)
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 8) = "cleanup|"
      closed = Val(BatteryFieldValue(line$, "closed"))
      forced = Val(BatteryFieldValue(line$, "forced"))
      removed = Val(BatteryFieldValue(line$, "removed"))
      If logEvent And (closed > 0 Or removed > 0)
        If forced > 0
          WriteBatteryAppEvent("PowerPilot update close")
        EndIf
        cleanupText$ = CleanupOldPowerPilotText(closed, removed)
        If cleanupText$ <> ""
          WriteBatteryAppEvent(cleanupText$)
        EndIf
      EndIf
      ProcedureReturn #True
    EndIf
  Next

  ; If PowerShell is unavailable or blocked, fall back to native process
  ; enumeration. The fallback can close processes and delete files when rights
  ; allow, but does not rely on shell command availability.
  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot <> #INVALID_HANDLE_VALUE
    entry\dwSize = SizeOf(PowerPilotProcessEntry32)
    If Process32First_(snapshot, @entry)
      Repeat
        exeName$ = PeekS(@entry\szExeFile[0])
        exeVersion$ = PowerPilotVersionFromExeName(exeName$)
        If exeVersion$ <> "" And LCase(exeName$) <> ownName$ And entry\th32ProcessID <> ownPid And CompareVersionStrings(exeVersion$, ownVersion$) < 0
          processHandle = OpenProcess_(#PROCESS_TERMINATE | #PROCESS_QUERY_LIMITED_INFORMATION, #False, entry\th32ProcessID)
          If processHandle
            If TerminateProcess_(processHandle, 0)
              closed + 1
            EndIf
            CloseHandle_(processHandle)
          EndIf
        EndIf
      Until Process32Next_(snapshot, @entry) = #False
    EndIf
    CloseHandle_(snapshot)
  EndIf

  If deleteFiles
    Delay(500)
    directory = ExamineDirectory(#PB_Any, GetPathPart(ProgramFilename()), "PowerPilot_V*.exe")
    If directory
      While NextDirectoryEntry(directory)
        If DirectoryEntryType(directory) = #PB_DirectoryEntry_File
          fileName$ = DirectoryEntryName(directory)
          exeVersion$ = PowerPilotVersionFromExeName(fileName$)
          If exeVersion$ <> "" And LCase(fileName$) <> ownName$ And CompareVersionStrings(exeVersion$, ownVersion$) < 0
            fullPath$ = GetPathPart(ProgramFilename()) + fileName$
            If DeleteFile(fullPath$)
              removed + 1
            EndIf
          EndIf
        EndIf
      Wend
      FinishDirectory(directory)
    EndIf
  EndIf

  If logEvent And (closed > 0 Or removed > 0)
    cleanupText$ = CleanupOldPowerPilotText(closed, removed)
    If cleanupText$ <> ""
      WriteBatteryAppEvent(cleanupText$)
    EndIf
  EndIf
  ProcedureReturn #True
EndProcedure

; Locate the graph point at or before an event time for session summary text.
Procedure.i BatteryGraphIndexBefore(timestamp.q)
  Protected i.i
  For i = gBatteryGraphCount - 1 To 0 Step -1
    If gBatteryGraph(i)\Timestamp <= timestamp
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn -1
EndProcedure

; Locate the graph point at or after an event time for session summary text.
Procedure.i BatteryGraphIndexAfter(timestamp.q)
  Protected i.i
  For i = 0 To gBatteryGraphCount - 1
    If gBatteryGraph(i)\Timestamp >= timestamp
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn -1
EndProcedure

; Compact event labels for graph markers and summaries.
Procedure.i BatteryEventIsSleepHibernate(eventName$)
  Protected lower$ = LCase(eventName$)
  ProcedureReturn Bool((FindString(lower$, "sleep", 1) Or FindString(lower$, "suspend", 1)) And (FindString(lower$, "hibernate", 1) Or FindString(lower$, "hibernation", 1)))
EndProcedure

Procedure.s BatteryEventShortName(eventName$)
  Protected lower$ = LCase(eventName$)
  Protected label$
  Protected wakeLike.i = Bool(FindString(lower$, "wake", 1) Or FindString(lower$, "resume", 1) Or FindString(lower$, "return", 1))
  Protected sleepLike.i = Bool(FindString(lower$, "sleep", 1) Or FindString(lower$, "suspend", 1))
  Protected hibernateLike.i = Bool(FindString(lower$, "hibernate", 1) Or FindString(lower$, "hibernation", 1))
  If FindString(lower$, "improper", 1)
    label$ + "!"
  EndIf
  If wakeLike
    label$ + "W"
  ElseIf hibernateLike
    label$ + "H"
  ElseIf sleepLike
    label$ + "Z"
  EndIf
  If FindString(lower$, "shutdown", 1)
    label$ + "S"
  EndIf
  If FindString(lower$, "startup", 1)
    label$ + "P"
  EndIf
  If label$ <> ""
    ProcedureReturn label$
  EndIf
  ProcedureReturn "E"
EndProcedure

Procedure.s BatteryEventDuplicateKey(eventName$)
  Protected label$ = BatteryEventShortName(eventName$)
  If label$ = "W"
    ProcedureReturn "W"
  EndIf
  If BatteryEventIsSleepHibernate(eventName$) Or label$ = "Z" Or label$ = "H"
    ProcedureReturn "SLEEP"
  EndIf
  ProcedureReturn ""
EndProcedure

Procedure.i BatteryEventDuplicateNear(timestamp.q, eventName$, windowSeconds.i = #BatteryDuplicateEventSeconds)
  Protected duplicateKey$ = BatteryEventDuplicateKey(eventName$)
  Protected i.i
  If timestamp <= 0 Or duplicateKey$ = ""
    ProcedureReturn #False
  EndIf
  For i = gBatteryEventCount - 1 To 0 Step -1
    If timestamp - gBatteryEvents(i)\Timestamp > windowSeconds
      ProcedureReturn #False
    EndIf
    If Abs(timestamp - gBatteryEvents(i)\Timestamp) <= windowSeconds
      If BatteryEventDuplicateKey(gBatteryEvents(i)\Name) = duplicateKey$
        ProcedureReturn #True
      EndIf
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

Procedure.i BatteryLogEventDuplicateNear(timestamp.q, eventName$, windowSeconds.i = #BatteryDuplicateEventSeconds)
  Protected duplicateKey$ = BatteryEventDuplicateKey(eventName$)
  Protected path$ = BatteryLogPath()
  Protected line$
  Protected row.BatteryLogRow
  If timestamp <= 0 Or duplicateKey$ = "" Or FileSize(path$) <= 0
    ProcedureReturn #False
  EndIf
  If ReadFile(0, path$)
    While Eof(0) = 0
      line$ = ReadString(0)
      If ParseBatteryLogRow(line$, @row) And row\RowType = "event"
        If Abs(timestamp - row\Timestamp) <= windowSeconds And BatteryEventDuplicateKey(row\EventName) = duplicateKey$
          CloseFile(0)
          ProcedureReturn #True
        EndIf
      EndIf
    Wend
    CloseFile(0)
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.i BatteryGraphSegmentVisible(index.i, startTime.q, endTime.q)
  If index <= 0 Or index >= gBatteryGraphCount
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(gBatteryGraph(index - 1)\Timestamp <= endTime And gBatteryGraph(index)\Timestamp >= startTime)
EndProcedure

Procedure.d BatteryGraphSegmentPercentAt(index.i, timestamp.q)
  Protected startSample.q
  Protected endSample.q
  Protected fraction.d
  If index <= 0 Or index >= gBatteryGraphCount
    ProcedureReturn 0.0
  EndIf
  startSample = gBatteryGraph(index - 1)\Timestamp
  endSample = gBatteryGraph(index)\Timestamp
  If endSample <= startSample
    ProcedureReturn gBatteryGraph(index)\Percent
  EndIf
  If timestamp <= startSample
    ProcedureReturn gBatteryGraph(index - 1)\Percent
  EndIf
  If timestamp >= endSample
    ProcedureReturn gBatteryGraph(index)\Percent
  EndIf
  fraction = (timestamp - startSample) * 1.0 / (endSample - startSample)
  ProcedureReturn gBatteryGraph(index - 1)\Percent + ((gBatteryGraph(index)\Percent - gBatteryGraph(index - 1)\Percent) * fraction)
EndProcedure

; Build the Battery Stats tab text from in-memory graph/event data. Active drain
; excludes intervals broken by power events, app lifecycle rows, or large gaps.
Procedure RefreshBatteryStatsSummary()
  Protected now.q = Date()
  Protected dayStart.q = ParseDate("%yyyy-%mm-%dd %hh:%ii:%ss", FormatDate("%yyyy-%mm-%dd 00:00:00", now))
  Protected i.i
  Protected elapsed.q
  Protected activeElapsed.q
  Protected activeDrain.d
  Protected offLoss.d
  Protected offCount.i
  Protected minPct.d = 101.0
  Protected maxPct.d = -1.0
  Protected lastEvent$
  Protected lastEventTime.q
  Protected session$
  Protected daily$
  Protected off$
  Protected beforeIndex.i
  Protected afterIndex.i
  Protected lastGap$
  Protected change.d
  If IsGadget(#GadgetBatterySessionSummary) = #False
    ProcedureReturn
  EndIf
  PruneBatteryAppBreaks(now)
  For i = 0 To gBatteryEventCount - 1
    If gBatteryEvents(i)\Timestamp > 0
      lastEvent$ = gBatteryEvents(i)\Name
      lastEventTime = gBatteryEvents(i)\Timestamp
    EndIf
  Next
  If lastEvent$ <> ""
    session$ = "Latest event: " + lastEvent$ + " at " + DisplayTimestamp(lastEventTime) + " (" + FormatDurationSeconds(now - lastEventTime) + " ago)"
    beforeIndex = BatteryGraphIndexBefore(lastEventTime)
    afterIndex = BatteryGraphIndexAfter(lastEventTime)
    If beforeIndex >= 0 And afterIndex >= 0 And afterIndex <> beforeIndex
      change = gBatteryGraph(afterIndex)\Percent - gBatteryGraph(beforeIndex)\Percent
      session$ + #CRLF$ + "Battery around event: " + StrD(gBatteryGraph(beforeIndex)\Percent, 1) + "% -> " + StrD(gBatteryGraph(afterIndex)\Percent, 1) + "% (" + StrD(change, 1) + "%)"
    EndIf
  Else
    session$ = "No sleep, wake, shutdown, or startup event recorded yet."
  EndIf
  ; Daily min/max can include all graph points from today. Active drain below is
  ; more selective because it should reflect awake/on-battery runtime only.
  For i = 0 To gBatteryGraphCount - 1
    If gBatteryGraph(i)\Timestamp >= dayStart
      If gBatteryGraph(i)\Percent < minPct : minPct = gBatteryGraph(i)\Percent : EndIf
      If gBatteryGraph(i)\Percent > maxPct : maxPct = gBatteryGraph(i)\Percent : EndIf
    EndIf
    If i > 0 And gBatteryGraph(i)\Timestamp >= dayStart
      elapsed = gBatteryGraph(i)\Timestamp - gBatteryGraph(i - 1)\Timestamp
      If elapsed > 0
        If BatteryGraphOfflineGap(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp)
          If gBatteryGraph(i - 1)\Percent > gBatteryGraph(i)\Percent
            change = gBatteryGraph(i - 1)\Percent - gBatteryGraph(i)\Percent
            offLoss + change
            offCount + 1
            lastGap$ = FormatDurationSeconds(elapsed) + ": " + StrD(change, 1) + "% lost"
          EndIf
        ElseIf gBatteryGraph(i - 1)\Connected = #False And gBatteryGraph(i)\Connected = #False
          activeElapsed + elapsed
          If gBatteryGraph(i - 1)\Percent > gBatteryGraph(i)\Percent
            activeDrain + (gBatteryGraph(i - 1)\Percent - gBatteryGraph(i)\Percent)
          EndIf
        EndIf
      EndIf
    EndIf
  Next
  If minPct <= 100.0
    daily$ = "Today: " + StrD(minPct, 1) + "% min, " + StrD(maxPct, 1) + "% max, " + FormatDurationSeconds(activeElapsed) + " active battery time"
    If activeElapsed >= 60 And activeDrain > 0.0
      daily$ + #CRLF$ + "Avg active drain: " + StrD((activeDrain * 3600.0) / activeElapsed, 1) + "%/h while awake on battery"
      daily$ + #CRLF$ + "Total battery used today: " + StrD(activeDrain, 1) + "% (recharging can make this over 100%)"
    Else
      daily$ + #CRLF$ + "Active drain: waiting for more on-battery samples"
    EndIf
    If gBatteryStableFullMWh > 0.0 And gBatteryStableDesignMWh > 0.0
      daily$ + #CRLF$ + "Health: " + StrD(gBatteryStableWearPercent, 1) + "% wear stable, " + Str(gBattery\CycleCount) + " cycles"
    ElseIf gBattery\WearPercent >= 0.0
      daily$ + #CRLF$ + "Health: " + StrD(gBattery\WearPercent, 1) + "% wear, " + Str(gBattery\CycleCount) + " cycles"
    EndIf
  Else
    daily$ = "Today: waiting for battery samples."
  EndIf
  If offCount > 0
    off$ = "Sleep/off loss today: " + StrD(offLoss, 1) + "% across " + Str(offCount) + " gap(s)"
    If lastGap$ <> ""
      off$ + #CRLF$ + "Latest gap: " + lastGap$
    EndIf
  Else
    off$ = "Sleep/off loss today: none detected from retained samples."
  EndIf
  SetGadgetText(#GadgetBatterySessionSummary, session$)
  SetGadgetText(#GadgetBatteryDailySummary, daily$)
  SetGadgetText(#GadgetBatteryOffLossSummary, off$)
  RefreshBatteryAnalysisSummary()
EndProcedure

; Rehydrate the graph and break/event arrays from retained CSV rows at startup
; so the graph and summaries have useful history before the next scheduled log.
Procedure LoadBatteryGraphFromLog()
  Protected line$
  Protected row.BatteryLogRow
  Protected lastScreenEvent$
  Protected screenOnKnown.i
  Protected screenOn.i
  gBatteryGraphCount = 0
  gBatteryAverageBreakCount = 0
  gBatteryAppBreakCount = 0
  gBatteryEventCount = 0
  PruneBatteryLog()
  If ReadFile(0, BatteryLogPath())
    While Eof(0) = 0
      line$ = ReadString(0)
      If ParseBatteryLogRow(line$, @row)
        ; Event rows become graph/session markers. App rows only become break
        ; points, which prevents reinstall/app restarts from looking like PC
        ; shutdowns or sleep gaps.
        If row\RowType = "event"
          AddBatteryEventPoint(row\Timestamp, row\EventName)
          If BatteryEventBreaksAverage(row\EventName)
            AddBatteryAverageBreak(row\Timestamp)
          EndIf
        ElseIf row\RowType = "app"
          AddBatteryAverageBreak(row\Timestamp)
          AddBatteryAppBreak(row\Timestamp)
        ElseIf row\RowType = "screen"
          lastScreenEvent$ = LCase(row\ScreenEvent)
        ElseIf row\RowType = "energy" Or row\RowType = "test"
          Continue
        Else
          screenOnKnown = Bool(lastScreenEvent$ = "screen off" Or lastScreenEvent$ = "screen on" Or lastScreenEvent$ = "screen dimmed")
          screenOn = Bool(lastScreenEvent$ = "screen on" Or lastScreenEvent$ = "screen dimmed")
          UpdateBatteryCapacityHealth(row\Timestamp, row\FullMWh, row\DesignMWh)
          AddBatteryGraphPoint(row\Timestamp, row\BatteryPercent, row\Connected, row\Charging, row\EnergySaverOn, row\DisconnectedBattery, row\RemainingMWh, row\FullMWh, row\DischargeRateMW, row\ChargeRateMW, screenOnKnown, screenOn, row\ScreenBrightnessPercent)
        EndIf
      EndIf
    Wend
    CloseFile(0)
  EndIf
EndProcedure

; Keep the CSV bounded to the latest 168 hours. Rewriting the file is simple
; and safe here because the log is small and written by one tray process.
Procedure PruneBatteryLog()
  Protected path$ = BatteryLogPath()
  Protected tempPath$ = path$ + ".tmp"
  Protected cutoff.q = Date() - #BatteryLogRetentionSeconds
  Protected input.i
  Protected output.i
  Protected line$
  Protected timestamp.q
  Protected header$
  Protected wroteHeader.i
  Protected row.BatteryLogRow
  Protected eventDuplicateKey$
  Protected lastEventDuplicateKey$
  Protected lastEventTime.q
  Protected eventNameLower$
  Protected pendingShutdownRequest.i
  Protected pendingShutdownRequestLine$
  Protected pendingShutdownRequestTime.q
  Protected skipRow.i
  If FileSize(path$) <= 0
    ProcedureReturn
  EndIf
  input = ReadFile(#PB_Any, path$)
  If input = 0
    ProcedureReturn
  EndIf
  output = CreateFile(#PB_Any, tempPath$)
  If output = 0
    CloseFile(input)
    ProcedureReturn
  EndIf
  WriteStringN(output, BatteryLogHeader())
  wroteHeader = #True
  While Eof(input) = 0
    line$ = ReadString(input)
    If Left(line$, 9) = "timestamp"
      header$ = line$
      If wroteHeader = #False
        WriteStringN(output, header$)
        wroteHeader = #True
      EndIf
    ElseIf Trim(line$) <> ""
      timestamp = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", StringField(line$, 1, ","))
      If timestamp = 0 Or timestamp >= cutoff
        If wroteHeader = #False
          WriteStringN(output, BatteryLogHeader())
          wroteHeader = #True
        EndIf
        skipRow = #False
        If ParseBatteryLogRow(line$, @row) And row\RowType = "event"
          eventNameLower$ = LCase(row\EventName)
          If pendingShutdownRequest
            If eventNameLower$ = "shutdown" And row\Timestamp >= pendingShutdownRequestTime And row\Timestamp - pendingShutdownRequestTime <= #BatteryShutdownRequestGraceSeconds
              pendingShutdownRequest = #False
            Else
              WriteStringN(output, pendingShutdownRequestLine$)
              pendingShutdownRequest = #False
            EndIf
          EndIf
          If eventNameLower$ = "shutdown requested"
            pendingShutdownRequest = #True
            pendingShutdownRequestLine$ = line$
            pendingShutdownRequestTime = row\Timestamp
            skipRow = #True
          EndIf
          eventDuplicateKey$ = BatteryEventDuplicateKey(row\EventName)
          If eventDuplicateKey$ <> "" And eventDuplicateKey$ = lastEventDuplicateKey$ And Abs(row\Timestamp - lastEventTime) <= #BatteryDuplicateEventSeconds
            skipRow = #True
          ElseIf skipRow = #False
            lastEventDuplicateKey$ = eventDuplicateKey$
            lastEventTime = row\Timestamp
          EndIf
        ElseIf pendingShutdownRequest
          WriteStringN(output, pendingShutdownRequestLine$)
          pendingShutdownRequest = #False
        EndIf
        If skipRow = #False
          WriteStringN(output, line$)
        EndIf
      EndIf
    EndIf
  Wend
  If pendingShutdownRequest
    WriteStringN(output, pendingShutdownRequestLine$)
  EndIf
  CloseFile(input)
  CloseFile(output)
  If DeleteFile(path$)
    RenameFile(tempPath$, path$)
  Else
    DeleteFile(tempPath$)
  EndIf
EndProcedure

; Return the latest PC power-event row. App rows are ignored so a normal app
; restart does not mask whether the last terminal PC event was Shutdown.
Procedure.s LastBatteryEventName()
  Protected line$
  Protected eventName$
  Protected fieldCount.i
  If ReadFile(0, BatteryLogPath())
    While Eof(0) = 0
      line$ = ReadString(0)
      fieldCount = CountString(line$, ",") + 1
      If fieldCount >= 19 And LCase(StringField(line$, 18, ",")) = "event"
        eventName$ = StringField(line$, 19, ",")
      EndIf
    Wend
    CloseFile(0)
  EndIf
  ProcedureReturn eventName$
EndProcedure

; Windows boot time distinguishes a real PC startup from a PowerPilot restart or
; reinstall inside the same boot session.
Procedure.q CurrentBootTime()
  Protected output$
  Protected line$
  Protected i.i
  Protected boot.q
  output$ = PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $os=Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -First 1; if ($os) { 'boot|' + $os.LastBootUpTime.ToString('yyyy-MM-ddTHH:mm:ss') }", 5000)
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 5) = "boot|"
      boot = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", Mid(line$, 6))
      If boot > 0
        ProcedureReturn boot
      EndIf
    EndIf
  Next
  If gSettings\LastBootTime > 0
    ProcedureReturn gSettings\LastBootTime
  EndIf
  ProcedureReturn Date()
EndProcedure

; Resume broadcasts do not reliably label sleep versus hibernation. Recent
; System log text gives PowerPilot a better event name.
Procedure.s RecentResumeEventName()
  Protected output$
  Protected command$
  Protected line$
  Protected i.i
  command$ = "$ErrorActionPreference='SilentlyContinue'; $since=(Get-Date).AddHours(-12); "
  command$ + "$sleep=Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Kernel-Power'; StartTime=$since; Id=42} -MaxEvents 1; "
  command$ + "$text=if($sleep){$sleep.Message}else{''}; "
  command$ + "if ($text -match '(?i)hibernate|hibernation') {'resume|Return from hibernation'} elseif ($text -match '(?i)sleep|suspend|standby') {'resume|Wake'} else {'resume|'}"
  output$ = PowerShellCapture(command$, 4000)
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 7) = "resume|"
      ProcedureReturn Mid(line$, 8)
    EndIf
  Next
  ProcedureReturn ""
EndProcedure

; Older builds could log installer/app close as Shutdown. On startup, remove
; same-boot false shutdown rows before graph and stats are loaded.
Procedure CleanupAppCloseShutdownEvents(bootTime.q)
  Protected path$ = BatteryLogPath()
  Protected tempPath$ = path$ + ".tmp"
  Protected input.i
  Protected output.i
  Protected line$
  Protected timestamp.q
  Protected fieldCount.i
  Protected eventName$
  Protected previousPowerEvent$
  Protected removed.i
  If bootTime <= 0 Or FileSize(path$) <= 0
    ProcedureReturn
  EndIf
  input = ReadFile(#PB_Any, path$)
  If input = 0
    ProcedureReturn
  EndIf
  output = CreateFile(#PB_Any, tempPath$)
  If output = 0
    CloseFile(input)
    ProcedureReturn
  EndIf
  WriteStringN(output, BatteryLogHeader())
  While Eof(input) = 0
    line$ = ReadString(input)
    If Left(line$, 9) = "timestamp" Or Trim(line$) = ""
      Continue
    EndIf
    fieldCount = CountString(line$, ",") + 1
    timestamp = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", StringField(line$, 1, ","))
    eventName$ = ""
    If fieldCount >= 19 And LCase(StringField(line$, 18, ",")) = "event"
      eventName$ = LCase(StringField(line$, 19, ","))
    EndIf
    If timestamp >= bootTime And (eventName$ = "shutdown requested" Or eventName$ = "shutdown")
      removed + 1
    ElseIf timestamp >= bootTime And eventName$ = "pc startup" And previousPowerEvent$ <> "shutdown" And previousPowerEvent$ <> "improper shutdown"
      removed + 1
    Else
      WriteStringN(output, line$)
      If eventName$ <> ""
        previousPowerEvent$ = eventName$
      EndIf
    EndIf
  Wend
  CloseFile(input)
  CloseFile(output)
  If removed > 0
    If DeleteFile(path$)
      RenameFile(tempPath$, path$)
    Else
      DeleteFile(tempPath$)
    EndIf
  Else
    DeleteFile(tempPath$)
  EndIf
EndProcedure

Procedure RecalculateBatteryPowerEstimates(now.q)
  Protected i.i
  Protected elapsed.q
  Protected watts.d
  Protected deltaMWh.d
  Protected category.i
  Protected maxInterval.i = BatteryGraphFlatGapSeconds()
  Protected runtimeFullMWh.d = BatteryRuntimeFullMWh()
  Protected normalCount.i
  Protected offCount.i
  Protected lowCount.i
  Protected activeCount.i
  Protected highCount.i
  Dim normalWatts.d(#BatteryRollingMaxSamples - 1)
  Dim offWatts.d(#BatteryRollingMaxSamples - 1)
  Dim lowWatts.d(#BatteryRollingMaxSamples - 1)
  Dim activeWatts.d(#BatteryRollingMaxSamples - 1)
  Dim highWatts.d(#BatteryRollingMaxSamples - 1)
  If gBatteryGraphCount < 2
    ProcedureReturn
  EndIf
  For i = gBatteryGraphCount - 1 To 1 Step -1
    If gBatteryGraph(i)\Timestamp < now - (ClampInt(gSettings\BatterySmoothingMinutes, 5, 240) * 60)
      Break
    EndIf
    If gBatteryGraph(i - 1)\Phase <> #BatteryPhaseOnBatteryNormal Or gBatteryGraph(i)\Phase <> #BatteryPhaseOnBatteryNormal
      Continue
    EndIf
    elapsed = gBatteryGraph(i)\Timestamp - gBatteryGraph(i - 1)\Timestamp
    If elapsed < 10 Or elapsed > maxInterval
      Continue
    EndIf
    If BatteryIntervalHasAverageBreak(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp) Or BatteryIntervalHasAppBreak(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp)
      Continue
    EndIf
    deltaMWh = gBatteryGraph(i - 1)\RemainingMWh - gBatteryGraph(i)\RemainingMWh
    If deltaMWh <= 0.0 And runtimeFullMWh > 0.0 And gBatteryGraph(i - 1)\Percent > gBatteryGraph(i)\Percent
      deltaMWh = ((gBatteryGraph(i - 1)\Percent - gBatteryGraph(i)\Percent) / 100.0) * runtimeFullMWh
    EndIf
    If deltaMWh <= 0.0
      Continue
    EndIf
    watts = (deltaMWh / (elapsed / 3600.0)) / 1000.0
    If watts <= 0.0 Or watts > 60.0
      Continue
    EndIf
    category = BatteryUseCategory(gBatteryGraph(i)\ScreenOnKnown, gBatteryGraph(i)\ScreenOn, gBatteryGraph(i)\BrightnessPercent, watts, gBatteryGraph(i)\EnergySaverOn)
    If watts < 15.0 And normalCount < #BatteryRollingMaxSamples
      normalWatts(normalCount) = watts
      normalCount + 1
    EndIf
    Select category
      Case #BatteryUseScreenOff
        If offCount < #BatteryRollingMaxSamples
          offWatts(offCount) = watts
          offCount + 1
        EndIf
      Case #BatteryUseLowBrightness
        If lowCount < #BatteryRollingMaxSamples
          lowWatts(lowCount) = watts
          lowCount + 1
        EndIf
      Case #BatteryUseHighLoad
        If highCount < #BatteryRollingMaxSamples
          highWatts(highCount) = watts
          highCount + 1
        EndIf
      Default
        If activeCount < #BatteryRollingMaxSamples
          activeWatts(activeCount) = watts
          activeCount + 1
        EndIf
    EndSelect
  Next
  SetBatteryEstimate(@gBatteryNormalEstimate, RobustAverageWatts(normalWatts(), normalCount), normalCount)
  SetBatteryEstimate(@gBatteryScreenOffEstimate, RobustAverageWatts(offWatts(), offCount), offCount)
  SetBatteryEstimate(@gBatteryLowBrightnessEstimate, RobustAverageWatts(lowWatts(), lowCount), lowCount)
  SetBatteryEstimate(@gBatteryActiveEstimate, RobustAverageWatts(activeWatts(), activeCount), activeCount)
  SetBatteryEstimate(@gBatteryHighLoadEstimate, RobustAverageWatts(highWatts(), highCount), highCount)
EndProcedure

Procedure.d BatteryPreferredRuntimeWatts()
  Protected measuredW.d
  Protected category.i
  If gBattery\DischargeRateMW > 0.0
    measuredW = gBattery\DischargeRateMW / 1000.0
  EndIf
  category = BatteryUseCategory(BatteryCurrentScreenOnKnown(), BatteryCurrentScreenOn(), gLastScreenBrightnessPercent, measuredW, gBattery\EnergySaverOn)
  Select category
    Case #BatteryUseScreenOff
      If gBatteryScreenOffEstimate\Valid : ProcedureReturn gBatteryScreenOffEstimate\Watts : EndIf
    Case #BatteryUseLowBrightness
      If gBatteryLowBrightnessEstimate\Valid : ProcedureReturn gBatteryLowBrightnessEstimate\Watts : EndIf
    Case #BatteryUseHighLoad
      If gBatteryHighLoadEstimate\Valid : ProcedureReturn gBatteryHighLoadEstimate\Watts : EndIf
    Default
      If gBatteryActiveEstimate\Valid : ProcedureReturn gBatteryActiveEstimate\Watts : EndIf
  EndSelect
  If gBatteryNormalEstimate\Valid
    ProcedureReturn gBatteryNormalEstimate\Watts
  EndIf
  If gBatteryActiveEstimate\Valid
    ProcedureReturn gBatteryActiveEstimate\Watts
  EndIf
  If measuredW > 0.0 And measuredW < 15.0
    ProcedureReturn measuredW
  EndIf
  ProcedureReturn 0.0
EndProcedure

Procedure.i BuildBatteryAnalysisFromLog(*analysis.BatteryAnalysis)
  Protected line$
  Protected row.BatteryLogRow
  Protected previous.BatteryLogRow
  Protected hasPrevious.i
  Protected lastScreenEvent$
  Protected screenOnKnown.i
  Protected screenOn.i
  Protected elapsed.q
  Protected deltaMWh.d
  Protected watts.d
  Protected category.i
  Protected normalCount.i
  Protected offCount.i
  Protected onCount.i
  Protected chargeCount.i
  Protected fullClusterCount.i
  Protected stableFull.d
  Protected clusterFull.d
  Protected recalCount.i
  Protected calibrationActive.i
  Protected plateauCount.i
  Dim normalWatts.d(#BatteryRollingMaxSamples - 1)
  Dim offWatts.d(#BatteryRollingMaxSamples - 1)
  Dim onWatts.d(#BatteryRollingMaxSamples - 1)
  Dim chargeWatts.d(#BatteryRollingMaxSamples - 1)
  If *analysis = 0
    ProcedureReturn #False
  EndIf
  InitializeStructure(*analysis, BatteryAnalysis)
  *analysis\AnalysisTimestamp = Date()
  If ReadFile(0, BatteryLogPath()) = 0
    ProcedureReturn #False
  EndIf
  While Eof(0) = 0
    line$ = ReadString(0)
    If ParseBatteryLogRow(line$, @row) = #False
      Continue
    EndIf
    If row\DesignMWh > 0.0
      *analysis\DesignMWh = row\DesignMWh
    EndIf
    If row\RowType = "screen"
      *analysis\ScreenRows + 1
      lastScreenEvent$ = LCase(row\ScreenEvent)
      Continue
    EndIf
    If row\RowType = "test"
      *analysis\TestRows + 1
      hasPrevious = #False
      Continue
    EndIf
    If row\RowType = "app" Or row\RowType = "event"
      *analysis\EventRows + 1
      hasPrevious = #False
      Continue
    EndIf
    If row\RowType <> "battery"
      Continue
    EndIf
    *analysis\BatteryRows + 1
    If *analysis\FirstBatteryTimestamp <= 0
      *analysis\FirstBatteryTimestamp = row\Timestamp
    EndIf
    *analysis\LastBatteryTimestamp = row\Timestamp
    If row\FullMWh > 0.0
      If stableFull <= 0.0
        stableFull = row\FullMWh
        clusterFull = row\FullMWh
        fullClusterCount = 1
      ElseIf Abs(row\FullMWh - clusterFull) / clusterFull <= #BatteryCapacityRecalibrationThreshold
        clusterFull = ((clusterFull * fullClusterCount) + row\FullMWh) / (fullClusterCount + 1)
        fullClusterCount + 1
        If fullClusterCount >= #BatteryStableCapacityMinSamples
          stableFull = clusterFull
        EndIf
      Else
        recalCount + 1
        clusterFull = row\FullMWh
        fullClusterCount = 1
      EndIf
    EndIf
    If row\Phase = #BatteryPhasePluggedDischargingCalibration And calibrationActive = #False
      *analysis\CalibrationSessions + 1
      calibrationActive = #True
    ElseIf row\Phase <> #BatteryPhasePluggedDischargingCalibration
      calibrationActive = #False
    EndIf
    screenOnKnown = Bool(lastScreenEvent$ = "screen off" Or lastScreenEvent$ = "screen on" Or lastScreenEvent$ = "screen dimmed")
    screenOn = Bool(lastScreenEvent$ = "screen on" Or lastScreenEvent$ = "screen dimmed")
    If hasPrevious And previous\Phase = #BatteryPhaseOnBatteryNormal And row\Phase = #BatteryPhaseOnBatteryNormal
      elapsed = row\Timestamp - previous\Timestamp
      If elapsed >= 10 And elapsed <= BatteryGraphFlatGapSeconds()
        deltaMWh = previous\RemainingMWh - row\RemainingMWh
        If deltaMWh <= 0.0 And stableFull > 0.0 And previous\BatteryPercent > row\BatteryPercent
          deltaMWh = ((previous\BatteryPercent - row\BatteryPercent) / 100.0) * stableFull
        EndIf
        If deltaMWh > 0.0
          watts = (deltaMWh / (elapsed / 3600.0)) / 1000.0
          If watts > 0.0 And watts < 60.0
            category = BatteryUseCategory(screenOnKnown, screenOn, row\ScreenBrightnessPercent, watts, row\EnergySaverOn)
            If watts < 15.0 And normalCount < #BatteryRollingMaxSamples
              normalWatts(normalCount) = watts
              normalCount + 1
              *analysis\NormalSpans + 1
            EndIf
            If category = #BatteryUseScreenOff And offCount < #BatteryRollingMaxSamples
              offWatts(offCount) = watts
              offCount + 1
              *analysis\ScreenOffSpans + 1
            ElseIf category <> #BatteryUseScreenOff And category <> #BatteryUseHighLoad And onCount < #BatteryRollingMaxSamples
              onWatts(onCount) = watts
              onCount + 1
              *analysis\ScreenOnSpans + 1
            EndIf
          EndIf
        ElseIf row\BatteryPercent < #BatteryLowGaugePercent And previous\DischargeRateMW > 0.0 And Abs(previous\BatteryPercent - row\BatteryPercent) < 0.02 And Abs(previous\RemainingMWh - row\RemainingMWh) < 1.0
          plateauCount + 1
        Else
          plateauCount = 0
        EndIf
      EndIf
    ElseIf hasPrevious And previous\Phase = #BatteryPhaseCharging And row\Phase = #BatteryPhaseCharging
      elapsed = row\Timestamp - previous\Timestamp
      If elapsed >= 10 And elapsed <= BatteryGraphFlatGapSeconds()
        deltaMWh = row\RemainingMWh - previous\RemainingMWh
        If deltaMWh > 0.0
          watts = (deltaMWh / (elapsed / 3600.0)) / 1000.0
          If watts > 0.0 And watts < 120.0 And chargeCount < #BatteryRollingMaxSamples
            chargeWatts(chargeCount) = watts
            chargeCount + 1
            *analysis\ChargingSpans + 1
          EndIf
        EndIf
      EndIf
    EndIf
    If plateauCount >= 2
      *analysis\LowBatteryPlateau = #True
    EndIf
    previous = row
    hasPrevious = #True
  Wend
  CloseFile(0)
  *analysis\LatestStableFullMWh = stableFull
  *analysis\RecalibrationCount = recalCount
  *analysis\NormalWatts = RobustAverageWatts(normalWatts(), normalCount)
  *analysis\ScreenOffWatts = RobustAverageWatts(offWatts(), offCount)
  *analysis\ScreenOnWatts = RobustAverageWatts(onWatts(), onCount)
  *analysis\ChargingWatts = RobustAverageWatts(chargeWatts(), chargeCount)
  *analysis\ChargingSamples = chargeCount
  If *analysis\LatestStableFullMWh <= 0.0
    *analysis\LatestStableFullMWh = gBatteryStableFullMWh
  EndIf
  If *analysis\DesignMWh <= 0.0
    *analysis\DesignMWh = gBatteryStableDesignMWh
  EndIf
  If *analysis\LatestStableFullMWh > 0.0 And *analysis\DesignMWh > 0.0
    *analysis\WearPercent = 100.0 - ((*analysis\LatestStableFullMWh / *analysis\DesignMWh) * 100.0)
    If *analysis\WearPercent < 0.0 : *analysis\WearPercent = 0.0 : EndIf
  EndIf
  If *analysis\LatestStableFullMWh > 0.0 And *analysis\ScreenOffWatts > 0.0
    *analysis\LowPowerRuntimeMinutes = ((*analysis\LatestStableFullMWh / 1000.0) / *analysis\ScreenOffWatts) * 60.0
  EndIf
  If *analysis\LatestStableFullMWh > 0.0 And *analysis\ScreenOnWatts > 0.0
    *analysis\ActiveRuntimeMinutes = ((*analysis\LatestStableFullMWh / 1000.0) / *analysis\ScreenOnWatts) * 60.0
  EndIf
  If *analysis\LowBatteryPlateau
    *analysis\Warnings = "Low-battery gauge plateau detected; estimate may be unreliable."
  EndIf
  If recalCount > 0
    If *analysis\Warnings <> "" : *analysis\Warnings + " " : EndIf
    *analysis\Warnings + "Capacity gauge recalibration detected."
  EndIf
  If *analysis\LatestStableFullMWh > 0.0
    UpdateBatteryCapacityHealth(Date(), *analysis\LatestStableFullMWh, *analysis\DesignMWh)
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure.s FormatWh(mWh.d)
  If mWh <= 0.0
    ProcedureReturn "Unknown"
  EndIf
  ProcedureReturn StrD(mWh / 1000.0, 1) + " Wh"
EndProcedure

Procedure.s FormatWattsOrUnknown(watts.d)
  If watts <= 0.0
    ProcedureReturn "Unknown"
  EndIf
  ProcedureReturn StrD(watts, 1) + " W"
EndProcedure

Procedure.s BatteryAnalysisIntervalText(*analysis.BatteryAnalysis)
  Protected interval.q
  If *analysis = 0 Or *analysis\FirstBatteryTimestamp <= 0 Or *analysis\LastBatteryTimestamp <= 0
    ProcedureReturn "no retained battery interval"
  EndIf
  interval = *analysis\LastBatteryTimestamp - *analysis\FirstBatteryTimestamp
  If interval < 0
    interval = 0
  EndIf
  ProcedureReturn DisplayShortTimestamp(*analysis\FirstBatteryTimestamp) + " -> " + DisplayShortTimestamp(*analysis\LastBatteryTimestamp) + " (" + FormatDurationSeconds(interval) + ")"
EndProcedure

Procedure.s BatteryAnalysisPulledText(*analysis.BatteryAnalysis)
  Protected text$
  If *analysis = 0
    ProcedureReturn "Rows: no retained log data"
  EndIf
  text$ = "Rows: " + Str(*analysis\BatteryRows) + " batt"
  If *analysis\ScreenRows > 0
    text$ + ", " + Str(*analysis\ScreenRows) + " screen"
  EndIf
  text$ + "; " + Str(*analysis\NormalSpans) + " drain, " + Str(*analysis\ChargingSpans) + " charge"
  ProcedureReturn text$
EndProcedure

Procedure.s BatteryAnalysisHelperText(*analysis.BatteryAnalysis)
  Protected flags$
  If *analysis = 0
    ProcedureReturn "Status: waiting for retained battery data."
  EndIf
  If *analysis\Warnings <> ""
    If *analysis\LowBatteryPlateau
      flags$ = "low gauge"
    EndIf
    If *analysis\RecalibrationCount > 0
      If flags$ <> "" : flags$ + "; " : EndIf
      flags$ + "recalibration"
    EndIf
    If flags$ <> ""
      ProcedureReturn "Flags: " + flags$
    EndIf
    ProcedureReturn "Flags: review retained battery data"
  EndIf
  If *analysis\LatestStableFullMWh <= 0.0
    ProcedureReturn "Need: more capacity rows"
  EndIf
  If *analysis\NormalWatts <= 0.0
    ProcedureReturn "Need: longer battery session"
  EndIf
  If *analysis\ScreenOffWatts > 0.0 And *analysis\ScreenOnWatts > 0.0
    If *analysis\ScreenOffWatts >= *analysis\ScreenOnWatts * 0.85
      ProcedureReturn "Hint: screen-off drain near active"
    EndIf
    If *analysis\ScreenOnWatts >= *analysis\ScreenOffWatts * 1.6
      ProcedureReturn "Hint: active/display drain dominates"
    EndIf
  EndIf
  If *analysis\ChargingSamples < 2
    ProcedureReturn "Need: more charging spans"
  EndIf
  If *analysis\WearPercent >= 20.0
    ProcedureReturn "Flag: capacity wear notable"
  EndIf
  ProcedureReturn "Status: retained stats steady"
EndProcedure

Procedure RefreshBatteryAnalysisNow()
  RefreshBattery(#True, #True)
  RefreshBatteryAnalysisSummary()
  RefreshBatteryLogPreview()
EndProcedure

Procedure RefreshBatteryAnalysisSummary()
  Protected analysis.BatteryAnalysis
  Protected text$
  If IsGadget(#GadgetBatteryAnalysisSummary) = #False
    ProcedureReturn
  EndIf
  If BuildBatteryAnalysisFromLog(@analysis) = #False
    SetGadgetTextIfChanged(#GadgetBatteryAnalysisSummary, "Waiting for retained battery rows.")
    ProcedureReturn
  EndIf
  text$ = "Updated " + FormatDate("%hh:%ii", analysis\AnalysisTimestamp) + " | " + BatteryAnalysisIntervalText(@analysis)
  text$ + #CRLF$ + BatteryAnalysisPulledText(@analysis)
  text$ + #CRLF$ + "Capacity: " + FormatWh(analysis\LatestStableFullMWh) + " / design " + FormatWh(analysis\DesignMWh)
  If analysis\WearPercent > 0.0
    text$ + ", wear " + StrD(analysis\WearPercent, 1) + "%"
  EndIf
  text$ + #CRLF$ + "Power: normal " + FormatWattsOrUnknown(analysis\NormalWatts) + ", off " + FormatWattsOrUnknown(analysis\ScreenOffWatts) + ", on " + FormatWattsOrUnknown(analysis\ScreenOnWatts)
  text$ + #CRLF$ + "Runtime: low " + FormatBatteryMinutes(analysis\LowPowerRuntimeMinutes) + ", active " + FormatBatteryMinutes(analysis\ActiveRuntimeMinutes) + "; charge " + FormatWattsOrUnknown(analysis\ChargingWatts)
  If gBattery\EstimateLowConfidence And analysis\Warnings = ""
    analysis\Warnings = "Low-battery gauge plateau detected; estimate may be unreliable."
    analysis\LowBatteryPlateau = #True
  EndIf
  text$ + #CRLF$ + "Cal " + Str(analysis\CalibrationSessions) + ", recal " + Str(analysis\RecalibrationCount) + " | " + BatteryAnalysisHelperText(@analysis)
  SetGadgetTextIfChanged(#GadgetBatteryAnalysisSummary, text$)
EndProcedure

; Learn an initial drain rate from retained history. Only continuous on-battery
; sample spans count; power/app/event breaks and large gaps are skipped.
Procedure.d BatteryFullLogDrainPctPerHour()
  Protected file.i
  Protected line$
  Protected row.BatteryLogRow
  Protected previous.BatteryLogRow
  Protected previousTime.q
  Protected elapsed.q
  Protected hasPrevious.i
  Protected activeElapsed.q
  Protected drainMWhTotal.d
  Protected intervalMWh.d
  Protected runtimeFullMWh.d
  Protected drainPctPerHour.d
  Protected maxGap.i = BatteryGraphFlatGapSeconds()
  PruneBatteryLog()
  file = ReadFile(#PB_Any, BatteryLogPath())
  If file = 0
    ProcedureReturn 0.0
  EndIf
  While Eof(file) = 0
    line$ = ReadString(file)
    If ParseBatteryLogRow(line$, @row) = #False
      Continue
    EndIf
    If row\RowType = "event" Or row\RowType = "app"
      hasPrevious = #False
      Continue
    EndIf
    If row\RowType = "screen" Or row\RowType = "energy" Or row\RowType = "test"
      Continue
    EndIf
    If row\Timestamp <= 0 Or row\BatteryPercent <= 0.0
      hasPrevious = #False
      Continue
    EndIf
    If hasPrevious And previous\Phase = #BatteryPhaseOnBatteryNormal And row\Phase = #BatteryPhaseOnBatteryNormal
      elapsed = row\Timestamp - previousTime
      If elapsed >= 10 And elapsed <= maxGap
        intervalMWh = previous\RemainingMWh - row\RemainingMWh
        If intervalMWh <= 0.0 And previous\FullMWh > 0.0 And previous\BatteryPercent > row\BatteryPercent
          intervalMWh = ((previous\BatteryPercent - row\BatteryPercent) / 100.0) * previous\FullMWh
        EndIf
        If intervalMWh > 0.0 And intervalMWh < 12000.0
          drainMWhTotal + intervalMWh
          activeElapsed + elapsed
        EndIf
      EndIf
    EndIf
    previousTime = row\Timestamp
    previous = row
    hasPrevious = #True
  Wend
  CloseFile(file)
  runtimeFullMWh = BatteryRuntimeFullMWh()
  If runtimeFullMWh <= 0.0 And gBattery\FullMWh > 0.0
    runtimeFullMWh = gBattery\FullMWh
  EndIf
  If activeElapsed >= 300 And drainMWhTotal > 0.0 And runtimeFullMWh > 0.0
    drainPctPerHour = ((drainMWhTotal * 3600.0) / activeElapsed / runtimeFullMWh) * 100.0
    If drainPctPerHour > 0.0 And drainPctPerHour < 200.0
      ProcedureReturn drainPctPerHour
    EndIf
  EndIf
  ProcedureReturn 0.0
EndProcedure

; Apply the learned drain to both startup and last-known drain settings. The
; saved value makes early-session estimates useful before a full glide window.
Procedure AutoSetInitialBatteryDrainFromLog()
  Protected learnedDrain.d = BatteryFullLogDrainPctPerHour()
  If learnedDrain > 0.0 And learnedDrain < 200.0
    If Abs(gSettings\BatteryStartupDrainPctPerHour - learnedDrain) >= 0.05 Or Abs(gSettings\BatteryLastDrainPctPerHour - learnedDrain) >= 0.05
      gSettings\BatteryStartupDrainPctPerHour = learnedDrain
      gSettings\BatteryLastDrainPctPerHour = learnedDrain
      If gBattery\SmoothedDrainPctPerHour <= 0.0
        gBattery\SmoothedDrainPctPerHour = learnedDrain
      EndIf
      SaveSettings()
    EndIf
  EndIf
EndProcedure

Procedure.i BatteryAppEventDebounceSeconds(eventName$)
  Protected lower$ = LCase(eventName$)
  If lower$ = "powerpilot start" Or lower$ = "powerpilot update close" Or Left(lower$, 8) = "cleaned "
    ProcedureReturn 60
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure.i RecentBatteryAppEvent(eventName$, seconds.i)
  Protected line$
  Protected row.BatteryLogRow
  Protected latest.q
  If seconds <= 0 Or FileSize(BatteryLogPath()) <= 0
    ProcedureReturn #False
  EndIf
  If ReadFile(0, BatteryLogPath())
    While Eof(0) = 0
      line$ = ReadString(0)
      If ParseBatteryLogRow(line$, @row) And row\RowType = "app" And LCase(row\EventName) = LCase(eventName$)
        latest = row\Timestamp
      EndIf
    Wend
    CloseFile(0)
  EndIf
  ProcedureReturn Bool(latest > 0 And Date() - latest <= seconds)
EndProcedure

; App rows include lifecycle and short status messages. They reset averages and
; appear in the PowerPilot Log, but are not PC power events.
Procedure WriteBatteryAppEvent(eventName$)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected timestamp.q = Date()
  Protected i.i
  eventName$ = CleanBatteryEventName(eventName$)
  If eventName$ = ""
    ProcedureReturn
  EndIf
  If RecentBatteryAppEvent(eventName$, BatteryAppEventDebounceSeconds(eventName$))
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  EnsureBatteryLogHeaderCurrent()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    line$ = IsoTimestamp(timestamp)
    For i = 1 To 17
      line$ + ","
    Next
    line$ + "app," + eventName$ + ",,,"
    WriteStringN(file, line$)
    CloseFile(file)
    AddBatteryAverageBreak(timestamp)
    AddBatteryAppBreak(timestamp)
    ResetBatteryAverageSamples()
    PruneBatteryLog()
    RefreshBatteryLogPreview()
  EndIf
EndProcedure

; PC power-event rows are separate from battery samples. They are used for graph
; markers, session summaries, off-time loss, and average-drain breaks.
Procedure WriteBatteryEvent(eventName$)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected timestamp.q = Date()
  Protected i.i
  eventName$ = CleanBatteryEventName(eventName$)
  If eventName$ = ""
    ProcedureReturn
  EndIf
  If BatteryEventDuplicateNear(timestamp, eventName$) Or BatteryLogEventDuplicateNear(timestamp, eventName$)
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  EnsureBatteryLogHeaderCurrent()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    line$ = IsoTimestamp(timestamp)
    For i = 1 To 17
      line$ + ","
    Next
    line$ + "event," + eventName$ + ",,,"
    WriteStringN(file, line$)
    CloseFile(file)
    AddBatteryEventPoint(timestamp, eventName$)
    If BatteryEventBreaksAverage(eventName$)
      AddBatteryAverageBreak(timestamp)
      ResetBatteryAverageSamples()
    EndIf
    PruneBatteryLog()
    RefreshBatteryLogPreview()
    RefreshBatteryStatsSummary()
  EndIf
EndProcedure

; Screen rows capture display state transitions without treating them as PC
; sleep/shutdown events or app breaks. Brightness is the last scheduled sample.
Procedure WriteBatteryScreenEvent(eventName$)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected timestamp.q = Date()
  Protected i.i
  eventName$ = CleanBatteryEventName(eventName$)
  If eventName$ = "" Or eventName$ = gLastScreenEvent$
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  EnsureBatteryLogHeaderCurrent()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    line$ = IsoTimestamp(timestamp)
    For i = 1 To 17
      line$ + ","
    Next
    line$ + "screen,," + eventName$ + "," + BatteryLogBrightnessText() + ","
    WriteStringN(file, line$)
    CloseFile(file)
    gLastScreenEvent$ = eventName$
    PruneBatteryLog()
    RefreshBatteryLogPreview()
  EndIf
EndProcedure

; Energy Saver rows show when Windows Energy Saver turns on/off. They do not
; break battery averages because the laptop is still awake and measurable.
Procedure WriteBatteryEnergySaverEvent(energySaverOn.i)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected timestamp.q = Date()
  Protected i.i
  Protected eventName$
  energySaverOn = Bool(energySaverOn)
  If energySaverOn
    eventName$ = "Energy Saver on"
  Else
    eventName$ = "Energy Saver off"
  EndIf
  EnsureSettingsDirectory()
  EnsureBatteryLogHeaderCurrent()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    line$ = IsoTimestamp(timestamp)
    For i = 1 To 17
      line$ + ","
    Next
    line$ + "energy," + eventName$ + ",,," + Str(energySaverOn)
    WriteStringN(file, line$)
    CloseFile(file)
    PruneBatteryLog()
    RefreshBatteryLogPreview()
  EndIf
EndProcedure

Procedure ResetBatteryTestWorkflowState()
  gBatteryTestLenovoReset = #False
  gBatteryTestLenovoSawPluggedDrain = #False
  gBatteryTestLenovoSawCharging = #False
  gBatteryTestVendorAuto = #False
EndProcedure

Procedure BeginBatteryTestSession(workflow$)
  If gBattery\Valid = #False
    RefreshBattery(#True)
  EndIf
  gBatteryTestActive = #True
  gBatteryTestHasSummary = #False
  gBatteryTestWorkflow$ = workflow$
  gBatteryTestReportPath$ = ""
  gBatteryTestStartTime = Date()
  If gBattery\Valid
    gBatteryTestStartTime = gBattery\Timestamp
    gBatteryTestStartPercent = gBattery\Percent
    gBatteryTestStartRemainingMWh = gBattery\RemainingMWh
    gBatteryTestLastRemainingMWh = gBattery\RemainingMWh
  Else
    gBatteryTestStartPercent = 0.0
    gBatteryTestStartRemainingMWh = 0.0
    gBatteryTestLastRemainingMWh = 0.0
  EndIf
  gBatteryTestEndTime = 0
  gBatteryTestEndPercent = gBatteryTestStartPercent
  gBatteryTestEndRemainingMWh = gBatteryTestStartRemainingMWh
  gBatteryTestLastTime = gBatteryTestStartTime
  gBatteryTestLastLogTime = gBatteryTestStartTime
  gBatteryTestUsedMWh = 0.0
  gBatteryTestChargedMWh = 0.0
  gBatteryTestDischargeSeconds = 0
  gBatteryTestChargeSeconds = 0
  gBatteryTestDischargeWattSeconds = 0.0
  gBatteryTestChargeWattSeconds = 0.0
EndProcedure

Procedure.s BatteryTestPhase()
  If gBatteryTestActive = #False And gBatteryTestHasSummary
    ProcedureReturn "Complete"
  EndIf
  If gBattery\Valid = #False
    ProcedureReturn "Idle"
  EndIf
  If gBattery\Connected And gBattery\DisconnectedBattery And gBattery\Charging = #False
    ProcedureReturn "Plugged in, discharging"
  EndIf
  If gBattery\Charging
    ProcedureReturn "Charging"
  EndIf
  If gBattery\Connected = #False And gBattery\DisconnectedBattery
    ProcedureReturn "On battery"
  EndIf
  ProcedureReturn "Idle"
EndProcedure

Procedure.s BatteryTestMode()
  If gBatteryTestActive = #False And gBatteryTestHasSummary
    If gBatteryTestWorkflow$ = "Lenovo calibration reset"
      ProcedureReturn "Lenovo reset complete"
    EndIf
    ProcedureReturn "Complete"
  EndIf
  If gBatteryTestActive And gBatteryTestWorkflow$ <> ""
    ProcedureReturn gBatteryTestWorkflow$
  EndIf
  If gBattery\Valid = #False
    ProcedureReturn "Monitor"
  EndIf
  If gBattery\Connected And gBattery\DisconnectedBattery And gBattery\Charging = #False
    ProcedureReturn "Vendor calibration detected"
  EndIf
  If gBatteryTestActive And gBattery\Charging
    ProcedureReturn "Charge recovery"
  EndIf
  If gBatteryTestActive
    ProcedureReturn "Manual discharge test"
  EndIf
  ProcedureReturn "Monitor"
EndProcedure

Procedure.s BatteryTestGuide()
  Protected mode$ = BatteryTestMode()
  If mode$ = "Complete" Or mode$ = "Lenovo reset complete"
    If gBatteryTestReportPath$ <> ""
      ProcedureReturn "Review, copy, or open the saved report."
    EndIf
    ProcedureReturn "Review or copy the report."
  EndIf
  If mode$ = "Lenovo calibration reset"
    If gBattery\Valid = #False
      ProcedureReturn "Waiting for battery data."
    EndIf
    If gBattery\Connected = #False
      ProcedureReturn "Connect the charger. Keep Lenovo reset selected."
    EndIf
    If gBattery\Connected And gBattery\DisconnectedBattery And gBattery\Charging = #False
      ProcedureReturn "Plugged-in discharge is active; drain helper is running."
    EndIf
    If gBattery\Charging
      ProcedureReturn "Charging now; drain helper is off."
    EndIf
    If gBatteryTestLenovoSawCharging
      ProcedureReturn "Waiting for Lenovo to finish after charging."
    EndIf
    ProcedureReturn "Waiting for plugged-in discharge mode."
  EndIf
  If mode$ = "Vendor calibration detected"
    ProcedureReturn "Watching plugged-in discharge. Keep calibration running."
  EndIf
  If mode$ = "Charge recovery"
    ProcedureReturn "Tracking charge recovery to the full target."
  EndIf
  If mode$ = "Manual discharge test"
    If gBattery\Valid = #False
      ProcedureReturn "Waiting for battery data."
    EndIf
    If gBattery\Connected And gBattery\Charging = #False And gBattery\DisconnectedBattery = #False
      ProcedureReturn "Unplug to start discharge."
    EndIf
    If gBattery\DisconnectedBattery
      ProcedureReturn "Discharge, then plug in to track recovery."
    EndIf
    If gBattery\Charging
      ProcedureReturn "Tracking charge recovery to the full target."
    EndIf
  EndIf
  ProcedureReturn "Start a manual test or leave this open during vendor calibration."
EndProcedure

Procedure.s BatteryTestElapsedText(seconds.q)
  If seconds < 0
    seconds = 0
  EndIf
  ProcedureReturn FormatBatteryMinutes(seconds / 60)
EndProcedure

Procedure.d BatteryTestAverageDischargeWatts()
  If gBatteryTestDischargeSeconds <= 0
    ProcedureReturn 0.0
  EndIf
  If gBatteryTestDischargeWattSeconds > 0.0
    ProcedureReturn gBatteryTestDischargeWattSeconds / gBatteryTestDischargeSeconds
  EndIf
  ProcedureReturn (gBatteryTestUsedMWh * 3.6) / gBatteryTestDischargeSeconds
EndProcedure

Procedure.d BatteryTestAverageChargeWatts()
  If gBatteryTestChargeSeconds <= 0
    ProcedureReturn 0.0
  EndIf
  If gBatteryTestChargeWattSeconds > 0.0
    ProcedureReturn gBatteryTestChargeWattSeconds / gBatteryTestChargeSeconds
  EndIf
  ProcedureReturn (gBatteryTestChargedMWh * 3.6) / gBatteryTestChargeSeconds
EndProcedure

Procedure.d BatteryTestUsableMWh()
  Protected usableMWh.d
  Protected floorMWh.d
  Protected percent.d
  Protected runtimeFullMWh.d = BatteryRuntimeFullMWh()
  If gBattery\Valid = #False
    ProcedureReturn 0.0
  EndIf
  If runtimeFullMWh > 0.0
    usableMWh = ((gBattery\Percent - gSettings\BatteryMinPercent) / 100.0) * runtimeFullMWh
  Else
    percent = gBattery\Percent
    If percent < 1.0
      percent = 1.0
    EndIf
    floorMWh = gBattery\RemainingMWh * (gSettings\BatteryMinPercent / percent)
    usableMWh = gBattery\RemainingMWh - floorMWh
  EndIf
  If usableMWh < 0.0
    usableMWh = 0.0
  EndIf
  ProcedureReturn usableMWh
EndProcedure

Procedure.d BatteryTestCurrentDischargeWatts()
  If gBattery\Valid = #False Or gBattery\DisconnectedBattery = #False Or gBattery\Charging
    ProcedureReturn 0.0
  EndIf
  If gBattery\DischargeRateMW > 0.0
    ProcedureReturn gBattery\DischargeRateMW / 1000.0
  EndIf
  ProcedureReturn 0.0
EndProcedure

Procedure.i BatteryTestFastEstimateMinutes()
  Protected watts.d = BatteryTestCurrentDischargeWatts()
  Protected usableMWh.d = BatteryTestUsableMWh()
  If watts <= 0.0 Or usableMWh <= 0.0
    ProcedureReturn -1
  EndIf
  ProcedureReturn ((usableMWh / 1000.0) / watts) * 60.0
EndProcedure

Procedure.s BatteryTestCapacityNotes()
  Protected health.d
  Protected observed.d
  Protected notes$
  Protected runtimeFullMWh.d = BatteryRuntimeFullMWh()
  If runtimeFullMWh > 0.0 And gBatteryStableDesignMWh > 0.0
    health = (runtimeFullMWh / gBatteryStableDesignMWh) * 100.0
    notes$ = StrD(runtimeFullMWh, 0) + " / " + StrD(gBatteryStableDesignMWh, 0) + " mWh stable, " + StrD(health, 1) + "% of design"
    If gBatteryCapacityRecalibrationDetected
      notes$ + #CRLF$ + "Recent full-charge jumps are labeled as capacity gauge recalibration."
    EndIf
  ElseIf gBattery\FullMWh > 0.0 And gBattery\DesignMWh > 0.0
    health = (gBattery\FullMWh / gBattery\DesignMWh) * 100.0
    notes$ = StrD(gBattery\FullMWh, 0) + " / " + StrD(gBattery\DesignMWh, 0) + " mWh, " + StrD(health, 1) + "% of design"
  ElseIf gBattery\FullMWh > 0.0
    notes$ = "Full-charge capacity " + StrD(gBattery\FullMWh, 0) + " mWh. Design capacity unavailable."
  Else
    notes$ = "Full/design capacity unavailable from Windows."
  EndIf
  If runtimeFullMWh > 0.0 And (gBatteryTestUsedMWh > 0.0 Or gBatteryTestChargedMWh > 0.0)
    observed = ((gBatteryTestUsedMWh + gBatteryTestChargedMWh) / runtimeFullMWh) * 100.0
    notes$ + #CRLF$ + "Observed movement: about " + StrD(observed, 1) + "% of full capacity"
  EndIf
  ProcedureReturn notes$
EndProcedure

Procedure.s YesNo(value.i)
  If value
    ProcedureReturn "Yes"
  EndIf
  ProcedureReturn "No"
EndProcedure

Procedure.s BatteryTestReport()
  Protected now.q = Date()
  Protected endTime.q
  Protected endPercent.d
  Protected endRemaining.d
  Protected elapsed.q
  Protected report$
  Protected workflow$
  Protected result$
  If gBatteryTestActive = #False And gBatteryTestHasSummary = #False
    ProcedureReturn "No test running." + #CRLF$ + #CRLF$ + "Start Manual, Lenovo reset, or leave this tab open during vendor calibration."
  EndIf
  workflow$ = gBatteryTestWorkflow$
  If workflow$ = ""
    workflow$ = BatteryTestMode()
  EndIf
  If gBatteryTestActive
    endTime = now
    endPercent = gBattery\Percent
    endRemaining = gBattery\RemainingMWh
  Else
    endTime = gBatteryTestEndTime
    endPercent = gBatteryTestEndPercent
    endRemaining = gBatteryTestEndRemainingMWh
  EndIf
  elapsed = endTime - gBatteryTestStartTime
  If gBatteryTestHasSummary And workflow$ = "Lenovo calibration reset" And gBatteryTestLenovoSawPluggedDrain And gBatteryTestLenovoSawCharging
    result$ = "Lenovo battery calibration reset completed."
  ElseIf gBatteryTestHasSummary And workflow$ = "Lenovo calibration reset"
    result$ = "Lenovo battery calibration reset ended before all expected phases were observed."
  ElseIf gBatteryTestHasSummary
    result$ = "Battery test completed."
  Else
    result$ = "Battery test is still running."
  EndIf
  report$ = "PowerPilot Battery Test Report" + #CRLF$
  report$ + "Generated " + DisplayTimestamp(now) + #CRLF$
  report$ + "Workflow " + workflow$ + #CRLF$
  report$ + "Phase    " + BatteryTestPhase() + #CRLF$
  report$ + "Result   " + result$ + #CRLF$ + #CRLF$
  report$ + "Timeline" + #CRLF$
  report$ + "Start   " + DisplayTimestamp(gBatteryTestStartTime)
  If gBatteryTestActive = #False And gBatteryTestHasSummary
    report$ + #CRLF$ + "End     " + DisplayTimestamp(gBatteryTestEndTime) + #CRLF$
  Else
    report$ + #CRLF$ + "Now     " + DisplayTimestamp(now) + #CRLF$
  EndIf
  report$ + "Elapsed " + BatteryTestElapsedText(elapsed) + " total" + #CRLF$
  report$ + "Discharge time " + BatteryTestElapsedText(gBatteryTestDischargeSeconds) + #CRLF$
  report$ + "Charge time    " + BatteryTestElapsedText(gBatteryTestChargeSeconds) + #CRLF$ + #CRLF$
  report$ + "Battery movement" + #CRLF$
  report$ + "Percent " + StrD(gBatteryTestStartPercent, 1) + "% -> " + StrD(endPercent, 1) + "%" + #CRLF$
  report$ + "mWh     " + StrD(gBatteryTestStartRemainingMWh, 0) + " -> " + StrD(endRemaining, 0) + #CRLF$
  report$ + "Moved   " + StrD(gBatteryTestUsedMWh, 0) + " mWh used, " + StrD(gBatteryTestChargedMWh, 0) + " mWh charged" + #CRLF$
  report$ + "Power   " + StrD(BatteryTestAverageDischargeWatts(), 2) + " W average discharging, " + StrD(BatteryTestAverageChargeWatts(), 2) + " W average charging" + #CRLF$ + #CRLF$
  If workflow$ = "Lenovo calibration reset"
    report$ + "Lenovo reset phases" + #CRLF$
    report$ + "Plugged-in discharge observed: " + YesNo(gBatteryTestLenovoSawPluggedDrain) + #CRLF$
    report$ + "Charge recovery observed:       " + YesNo(gBatteryTestLenovoSawCharging) + #CRLF$
    report$ + "Configured drain target:        " + Str(gSettings\BatteryCalibrationDrainMinutes) + " min" + #CRLF$ + #CRLF$
  EndIf
  report$ + "Capacity notes" + #CRLF$
  report$ + BatteryTestCapacityNotes() + #CRLF$ + #CRLF$
  report$ + "Interpretation" + #CRLF$
  report$ + "PowerPilot records Windows battery telemetry and local CPU-load actions. It cannot command Lenovo firmware calibration directly; it verifies the reset workflow from the observed plugged-in discharge, charge recovery, and final idle states."
  ProcedureReturn report$
EndProcedure

Procedure.s BatteryTestShortSummary()
  ProcedureReturn "used " + StrD(gBatteryTestUsedMWh, 0) + " mWh charged " + StrD(gBatteryTestChargedMWh, 0) + " mWh avg discharging " + StrD(BatteryTestAverageDischargeWatts(), 2) + " W avg charging " + StrD(BatteryTestAverageChargeWatts(), 2) + " W"
EndProcedure

Procedure.s SaveBatteryTestReportFile(prefix$)
  Protected path$
  Protected file.i
  EnsureBatteryReportDirectory()
  path$ = BatteryReportDirectory() + "\" + BatteryReportFileName(prefix$)
  file = CreateFile(#PB_Any, path$)
  If file
    WriteStringN(file, BatteryTestReport())
    CloseFile(file)
    gBatteryTestReportPath$ = path$
    LogAction("Battery test report saved.")
    ProcedureReturn path$
  EndIf
  LogAction("Battery test report save failed.")
  ProcedureReturn ""
EndProcedure

Procedure OpenLatestBatteryTestReport()
  Protected path$ = LatestBatteryReportPath()
  If path$ <> "" And FileSize(path$) >= 0
    RunProgram("explorer.exe", QuoteArgument(path$), "")
    LogAction("Battery test report opened.")
  Else
    LogAction("No battery test report found.")
    MessageRequester(#AppName$, "No battery test report has been saved yet.", #PB_MessageRequester_Info)
  EndIf
EndProcedure

Procedure WriteBatteryTestRow(eventName$, includeBattery.i = #True)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected timestamp.q = Date()
  Protected i.i
  eventName$ = "BATTERY TEST " + CleanBatteryEventName(eventName$)
  EnsureSettingsDirectory()
  EnsureBatteryLogHeaderCurrent()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    line$ = IsoTimestamp(timestamp)
    If includeBattery And gBattery\Valid
      line$ + "," + StrD(gBattery\Percent, 2)
      line$ + "," + Str(gBattery\Connected)
      line$ + "," + Str(gBattery\Charging)
      line$ + "," + Str(gBattery\DisconnectedBattery)
      line$ + "," + StrD(gBattery\RemainingMWh, 0)
      line$ + "," + StrD(gBattery\FullMWh, 0)
      line$ + "," + StrD(gBattery\DesignMWh, 0)
      line$ + "," + StrD(gBattery\WearPercent, 1)
      line$ + "," + StrD(gBattery\DischargeRateMW, 0)
      line$ + "," + StrD(gBattery\ChargeRateMW, 0)
      line$ + "," + Str(gBattery\RuntimeMinutes)
      line$ + "," + Str(gBattery\EstimateMinutes)
      line$ + "," + Str(gBattery\InstantEstimateMinutes)
      line$ + "," + StrD(gBattery\InstantDrainPctPerHour, 2)
      If gBattery\Charging
        line$ + "," + StrD(gBattery\SmoothedChargePctPerHour, 2)
      Else
        line$ + "," + StrD(gBattery\SmoothedDrainPctPerHour, 2)
      EndIf
      line$ + "," + Str(gBattery\CycleCount)
    Else
      For i = 1 To 17
        line$ + ","
      Next
    EndIf
    line$ + ",test," + eventName$ + ",," + BatteryLogBrightnessText()
    If gBattery\Valid
      line$ + "," + Str(gBattery\EnergySaverOn)
    Else
      line$ + ","
    EndIf
    WriteStringN(file, line$)
    CloseFile(file)
    PruneBatteryLog()
    RefreshBatteryLogPreview()
  EndIf
EndProcedure

Procedure StartBatteryTestLog()
  If gBatteryTestActive
    MessageRequester(#AppName$, "End the current battery test before starting another one.", #PB_MessageRequester_Info)
    ProcedureReturn
  EndIf
  ResetBatteryTestWorkflowState()
  BeginBatteryTestSession("Manual discharge test")
  WriteBatteryTestRow("start manual discharge test - " + BatteryTestPhase(), #True)
  RefreshBatteryTestDisplay()
EndProcedure

Procedure StartLenovoCalibrationReset()
  If gBatteryTestActive
    MessageRequester(#AppName$, "End the current battery test before starting Lenovo reset.", #PB_MessageRequester_Info)
    ProcedureReturn
  EndIf
  If IsGadget(#GadgetBatteryLoadMinutes)
    gSettings\BatteryCalibrationDrainMinutes = ClampInt(GetGadgetState(#GadgetBatteryLoadMinutes), 15, 720)
    SaveSettings()
  EndIf
  ResetBatteryTestWorkflowState()
  BeginBatteryTestSession("Lenovo calibration reset")
  gBatteryTestLenovoReset = #True
  WriteBatteryTestRow("start Lenovo calibration reset - " + BatteryTestPhase(), #True)
  If gBattery\Valid And gBattery\Connected And gBattery\DisconnectedBattery And gBattery\Charging = #False
    gBatteryTestLenovoSawPluggedDrain = #True
    StartAutoDrainTarget()
    WriteBatteryTestRow("Lenovo reset drain helper auto started", #True)
  EndIf
  RefreshBatteryTestDisplay()
EndProcedure

Procedure EndBatteryTestLog()
  If gBatteryTestActive = #False
    ProcedureReturn
  EndIf
  RefreshBatteryTest()
  gBatteryTestActive = #False
  gBatteryTestHasSummary = #True
  gBatteryTestEndTime = Date()
  If gBattery\Valid
    gBatteryTestEndTime = gBattery\Timestamp
    gBatteryTestEndPercent = gBattery\Percent
    gBatteryTestEndRemainingMWh = gBattery\RemainingMWh
  Else
    gBatteryTestEndPercent = gBatteryTestStartPercent
    gBatteryTestEndRemainingMWh = gBatteryTestStartRemainingMWh
  EndIf
  gBatteryAutoDrainActive = #False
  StopBatteryCpuLoad(#False)
  WriteBatteryTestRow("end - " + BatteryTestShortSummary(), #True)
  If gBatteryTestLenovoReset
    SaveBatteryTestReportFile("lenovo_calibration_reset_manual_end")
  EndIf
  gBatteryTestLenovoReset = #False
  gBatteryTestVendorAuto = #False
  RefreshBatteryTestDisplay()
EndProcedure

Procedure CopyBatteryTestReport()
  SetClipboardText(BatteryTestReport())
EndProcedure

Procedure BatteryCpuLoadWorker(index.i)
  Protected busyMs.i
  Protected startMs.q
  Protected spin.q
  While gBatteryCpuLoadStop = #False
    busyMs = ClampInt(gBatteryCpuLoadTarget, 0, 100)
    If busyMs > 0
      startMs = ElapsedMilliseconds()
      While ElapsedMilliseconds() - startMs < busyMs And gBatteryCpuLoadStop = #False
        spin + 1
        If spin > 1000000000
          spin = index
        EndIf
      Wend
    EndIf
    If busyMs < 100
      Delay(100 - busyMs)
    Else
      Delay(1)
    EndIf
  Wend
EndProcedure

Procedure RefreshBatteryCpuLoadDisplay()
  Protected status$
  Protected autoStatus$
  Protected remaining.q
  If IsGadget(#GadgetBatteryLoadStatus) = #False
    ProcedureReturn
  EndIf
  If gBatteryCpuLoadTarget > 0 And gBatteryCpuLoadThreadCount > 0
    status$ = Str(gBatteryCpuLoadTarget) + "% across " + Str(gBatteryCpuLoadThreadCount) + " thread(s)"
  ElseIf gBatteryAutoDrainActive And gBatteryAutoDrainReason$ <> ""
    status$ = gBatteryAutoDrainReason$
  Else
    status$ = "Off"
  EndIf
  If gBatteryAutoDrainActive
    remaining = gBatteryAutoDrainEndTime - Date()
    If remaining < 0
      remaining = 0
    EndIf
    autoStatus$ = "Auto to " + FormatDate("%hh:%ii", gBatteryAutoDrainEndTime) + ", " + BatteryTestElapsedText(remaining) + " left"
    SetGadgetTextIfChanged(#GadgetBatteryLoadAuto, "Stop auto")
  Else
    autoStatus$ = "Auto off"
    SetGadgetTextIfChanged(#GadgetBatteryLoadAuto, "Auto")
  EndIf
  SetGadgetTextIfChanged(#GadgetBatteryLoadStatus, status$)
  SetGadgetTextIfChanged(#GadgetBatteryLoadAutoStatus, autoStatus$)
  If IsGadget(#GadgetBatteryLoadTestMode)
    SetGadgetState(#GadgetBatteryLoadTestMode, Bool(gBatteryDrainHelperTestMode))
  EndIf
  If IsGadget(#GadgetBatteryLoadStop)
    DisableGadget(#GadgetBatteryLoadStop, Bool(gBatteryCpuLoadTarget <= 0))
  EndIf
EndProcedure

Procedure SetBatteryDrainHelperTestMode(enabled.i)
  enabled = Bool(enabled)
  If gBatteryDrainHelperTestMode = enabled
    ProcedureReturn
  EndIf
  gBatteryDrainHelperTestMode = enabled
  gBatteryDrainHelperTraceLastTime = 0
  If gBatteryDrainHelperTestMode
    WriteBatteryTestRow("drain helper test mode on", #True)
  Else
    WriteBatteryTestRow("drain helper test mode off", #True)
  EndIf
  RefreshBatteryCpuLoadDisplay()
EndProcedure

Procedure WriteBatteryDrainHelperTrace(reason$, targetMinutes.d, currentMinutes.d, errorMinutes.d, measuredW.d, usableMWh.d, selectedLoad.i, force.i = #False, targetW.d = 0.0, errorW.d = 0.0, phase$ = "")
  Protected now.q = Date()
  Protected eventName$
  If gBatteryDrainHelperTestMode = #False And gBatteryAutoDrainActive = #False
    ProcedureReturn
  EndIf
  If force = #False And gBatteryDrainHelperTraceLastTime > 0 And now - gBatteryDrainHelperTraceLastTime < #BatteryDrainHelperTraceSeconds
    ProcedureReturn
  EndIf
  gBatteryDrainHelperTraceLastTime = now
  If phase$ = ""
    phase$ = BatteryPhaseName(gBattery\Phase)
  EndIf
  eventName$ = "drain helper tick " + reason$
  eventName$ + " target_watts " + StrD(targetW, 2)
  eventName$ + " measured_watts " + StrD(measuredW, 2)
  eventName$ + " error_watts " + StrD(errorW, 2)
  eventName$ + " cpu_load_target " + Str(selectedLoad)
  eventName$ + " integral " + StrD(gBatteryAutoDrainIntegral, 2)
  eventName$ + " phase " + phase$
  eventName$ + " estimated_minutes " + StrD(currentMinutes, 1)
  eventName$ + " target_minutes " + StrD(targetMinutes, 1)
  eventName$ + " usable_mwh " + StrD(usableMWh, 0)
  WriteBatteryTestRow(eventName$, #True)
EndProcedure

Procedure StartBatteryCpuLoad(target.i)
  Protected logical.i
  Protected i.i
  target = ClampInt(target, 0, 100)
  If target <= 0
    StopBatteryCpuLoad(Bool(gBatteryAutoDrainActive = #False))
    ProcedureReturn
  EndIf
  If gBatteryCpuLoadThreadCount <= 0
    logical = ClampInt(CountCPUs(), 1, 64)
    gBatteryCpuLoadStop = #False
    gBatteryCpuLoadThreadCount = logical
    For i = 0 To logical - 1
      gBatteryCpuLoadThreads(i) = CreateThread(@BatteryCpuLoadWorker(), i)
    Next
  EndIf
  gBatteryCpuLoadTarget = target
  WriteBatteryTestRow("CPU load target " + Str(target) + "%", #True)
  RefreshBatteryCpuLoadDisplay()
EndProcedure

Procedure StepBatteryCpuLoad()
  Protected target.i = gBatteryCpuLoadTarget + 25
  gBatteryAutoDrainActive = #False
  If target > 100
    target = 100
  EndIf
  StartBatteryCpuLoad(target)
EndProcedure

; Start automatic drain control. The target is a time-to-empty goal, not a fixed
; CPU percentage: the controller samples current battery watts and adjusts the
; local CPU load helper so the remaining usable mWh trends toward the selected
; target time. Lenovo calibration starts gently because plugged-in discharge can
; already have a vendor-controlled load.
Procedure StartAutoDrainTarget()
  If IsGadget(#GadgetBatteryLoadMinutes)
    gBatteryAutoDrainMinutes = ClampInt(GetGadgetState(#GadgetBatteryLoadMinutes), 15, 720)
  Else
    gBatteryAutoDrainMinutes = ClampInt(gSettings\BatteryCalibrationDrainMinutes, 15, 720)
  EndIf
  gSettings\BatteryCalibrationDrainMinutes = gBatteryAutoDrainMinutes
  SaveSettings()
  If gBatteryTestActive = #False
    StartBatteryTestLog()
  EndIf
  gBatteryAutoDrainActive = #True
  gBatteryAutoDrainEndTime = Date() + (gBatteryAutoDrainMinutes * 60)
  gBatteryAutoDrainLastAdjust = 0
  gBatteryAutoDrainIntegral = 0.0
  gBatteryAutoDrainFilteredW = 0.0
  gBatteryAutoDrainReason$ = "Starting"
  WriteBatteryTestRow("auto drain target " + Str(gBatteryAutoDrainMinutes) + " min, end " + FormatDate("%hh:%ii", gBatteryAutoDrainEndTime), #True)
  WriteBatteryDrainHelperTrace("start", gBatteryAutoDrainMinutes, -1.0, 0.0, 0.0, BatteryTestUsableMWh(), gBatteryCpuLoadTarget, #True)
  If gBattery\Valid And gBattery\DisconnectedBattery And gBattery\Charging = #False
    If BatteryOperatingPhase(gBattery\Connected, gBattery\Charging, gBattery\DisconnectedBattery) = #BatteryPhasePluggedDischargingCalibration
      gBatteryAutoDrainReason$ = "Starting at 10%"
      StartBatteryCpuLoad(10)
    Else
      gBatteryAutoDrainReason$ = "Starting at 25%"
      StartBatteryCpuLoad(25)
    EndIf
    gBatteryAutoDrainLastAdjust = Date()
  Else
    UpdateAutoDrainTarget(#True)
  EndIf
  RefreshBatteryCpuLoadDisplay()
EndProcedure

Procedure ToggleAutoDrainTarget()
  If gBatteryAutoDrainActive
    WriteBatteryDrainHelperTrace("manual stop", 0.0, -1.0, 0.0, BatteryTestCurrentDischargeWatts(), BatteryTestUsableMWh(), 0, #True)
    gBatteryAutoDrainActive = #False
    StopBatteryCpuLoad(#False)
    WriteBatteryTestRow("auto drain target stopped", #True)
  Else
    StartAutoDrainTarget()
  EndIf
  RefreshBatteryCpuLoadDisplay()
EndProcedure

; Automatic drain is a filtered proportional/integral controller with small load
; steps. It uses measured discharge watts when Windows exposes them, then falls
; back to PowerPilot's runtime estimates so it can still make progress on
; systems that hide instantaneous watts. Charging always stops the load.
Procedure UpdateAutoDrainTarget(force.i = #False)
  Protected now.q = Date()
  Protected elapsed.q
  Protected remainingSeconds.q
  Protected targetMinutes.d
  Protected currentMinutes.d
  Protected targetW.d
  Protected errorW.d
  Protected deadbandW.d
  Protected kp.d
  Protected ki.d
  Protected maxStep.d = #BatteryAutoDrainMaxStep
  Protected usableMWh.d
  Protected measuredW.d
  Protected controlW.d
  Protected errorMinutes.d
  Protected desiredLoad.d
  Protected delta.d
  Protected target.i
  Protected phase.i
  Protected runtimeFullMWh.d
  If gBatteryAutoDrainActive = #False
    ProcedureReturn
  EndIf
  If gBattery\Valid = #False
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  phase = BatteryOperatingPhase(gBattery\Connected, gBattery\Charging, gBattery\DisconnectedBattery)
  remainingSeconds = gBatteryAutoDrainEndTime - now
  If remainingSeconds <= 0
    gBatteryAutoDrainReason$ = "Behind target"
    WriteBatteryDrainHelperTrace("behind target", 0.0, -1.0, 0.0, 0.0, BatteryTestUsableMWh(), 100, #True, 0.0, 0.0, BatteryPhaseName(phase))
    StartBatteryCpuLoad(100)
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  If gBattery\Charging
    If gBatteryCpuLoadTarget > 0 Or gBatteryAutoDrainActive
      WriteBatteryDrainHelperTrace("charging stop", remainingSeconds / 60.0, -1.0, 0.0, 0.0, BatteryTestUsableMWh(), 0, #True, 0.0, 0.0, BatteryPhaseName(phase))
      gBatteryAutoDrainActive = #False
      StopBatteryCpuLoad(#False)
      WriteBatteryTestRow("auto drain stopped - charge recovery started", #True)
    EndIf
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  If gBattery\DisconnectedBattery = #False
    gBatteryAutoDrainReason$ = "Waiting for discharging"
    WriteBatteryDrainHelperTrace("wait discharging", remainingSeconds / 60.0, -1.0, 0.0, 0.0, 0.0, gBatteryCpuLoadTarget, #False, 0.0, 0.0, BatteryPhaseName(phase))
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  usableMWh = BatteryTestUsableMWh()
  runtimeFullMWh = BatteryRuntimeFullMWh()
  If usableMWh <= 0.0
    WriteBatteryDrainHelperTrace("empty target reached", remainingSeconds / 60.0, 0.0, 0.0, 0.0, usableMWh, 0, #True, 0.0, 0.0, BatteryPhaseName(phase))
    gBatteryAutoDrainActive = #False
    StopBatteryCpuLoad(#False)
    WriteBatteryTestRow("auto drain target reached", #True)
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  measuredW = BatteryTestCurrentDischargeWatts()
  If measuredW <= 0.0
    If runtimeFullMWh > 0.0 And gBattery\EstimateValid And gBattery\EstimateMinutes > 0
      measuredW = (usableMWh / 1000.0) / (gBattery\EstimateMinutes / 60.0)
    EndIf
  EndIf
  If measuredW <= 0.0 And runtimeFullMWh > 0.0 And gBattery\SmoothedDrainPctPerHour > 0.0
    measuredW = ((runtimeFullMWh * (gBattery\SmoothedDrainPctPerHour / 100.0)) / 1000.0)
  EndIf
  If measuredW <= 0.0
    gBatteryAutoDrainReason$ = "Starting load"
    If phase = #BatteryPhasePluggedDischargingCalibration
      target = 10
    Else
      target = 25
    EndIf
    WriteBatteryDrainHelperTrace("no watts start load", remainingSeconds / 60.0, -1.0, 0.0, measuredW, usableMWh, target, #True, 0.0, 0.0, BatteryPhaseName(phase))
    StartBatteryCpuLoad(target)
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  If force = #False And gBatteryAutoDrainLastAdjust > 0 And now - gBatteryAutoDrainLastAdjust < #BatteryAutoDrainMinHoldSeconds
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  If gBatteryAutoDrainFilteredW <= 0.0 Or force
    gBatteryAutoDrainFilteredW = measuredW
  Else
    gBatteryAutoDrainFilteredW = (gBatteryAutoDrainFilteredW * 0.65) + (measuredW * 0.35)
  EndIf
  controlW = gBatteryAutoDrainFilteredW
  If controlW <= 0.0
    controlW = measuredW
  EndIf
  targetMinutes = remainingSeconds / 60.0
  targetW = (usableMWh / targetMinutes / 1000.0) * 60.0
  currentMinutes = ((usableMWh / 1000.0) / controlW) * 60.0
  deadbandW = targetW * 0.08
  If deadbandW < 0.35 : deadbandW = 0.35 : EndIf
  If deadbandW > 1.25 : deadbandW = 1.25 : EndIf
  If phase = #BatteryPhasePluggedDischargingCalibration
    deadbandW + 0.25
    maxStep = 5.0
  EndIf
  errorMinutes = currentMinutes - targetMinutes
  errorW = targetW - controlW
  If Abs(errorW) <= deadbandW
    gBatteryAutoDrainReason$ = "On target"
    gBatteryAutoDrainLastAdjust = now
    If Abs(gBatteryAutoDrainIntegral) > 0.01
      gBatteryAutoDrainIntegral * 0.80
    EndIf
    WriteBatteryDrainHelperTrace("on target", targetMinutes, currentMinutes, errorMinutes, controlW, usableMWh, gBatteryCpuLoadTarget, #False, targetW, errorW, BatteryPhaseName(phase))
    RefreshBatteryCpuLoadDisplay()
    ProcedureReturn
  EndIf
  elapsed = #BatteryAutoDrainAdjustSeconds
  If gBatteryAutoDrainLastAdjust > 0 And now > gBatteryAutoDrainLastAdjust
    elapsed = now - gBatteryAutoDrainLastAdjust
  EndIf
  If gBatteryCpuLoadTarget <= 0 And errorW < 0.0
    gBatteryAutoDrainIntegral = 0.0
  ElseIf gBatteryCpuLoadTarget >= 100 And errorW > 0.0
    gBatteryAutoDrainIntegral = gBatteryAutoDrainIntegral
  Else
    gBatteryAutoDrainIntegral + (errorW * (elapsed / 60.0))
  EndIf
  If gBatteryAutoDrainIntegral > 30.0 : gBatteryAutoDrainIntegral = 30.0 : EndIf
  If gBatteryAutoDrainIntegral < -30.0 : gBatteryAutoDrainIntegral = -30.0 : EndIf
  If phase = #BatteryPhasePluggedDischargingCalibration
    kp = 5.0
    ki = 1.2
  Else
    kp = 7.0
    ki = 1.8
  EndIf
  desiredLoad = gBatteryCpuLoadTarget + (errorW * kp) + (gBatteryAutoDrainIntegral * ki)
  delta = desiredLoad - gBatteryCpuLoadTarget
  If delta > maxStep
    delta = maxStep
  ElseIf delta < -maxStep
    delta = -maxStep
  EndIf
  If delta > 0.0 And delta < 1.0
    delta = 1.0
  ElseIf delta < 0.0 And delta > -1.0
    delta = -1.0
  EndIf
  target = ClampInt(gBatteryCpuLoadTarget + Round(delta, #PB_Round_Nearest), 0, 100)
  If target = 0 And errorW > deadbandW
    target = 10
  EndIf
  If target > gBatteryCpuLoadTarget
    gBatteryAutoDrainReason$ = "Adding load"
  ElseIf target < gBatteryCpuLoadTarget
    gBatteryAutoDrainReason$ = "Reducing load"
  Else
    gBatteryAutoDrainReason$ = "Holding load"
  EndIf
  If target <> gBatteryCpuLoadTarget Or force
    StartBatteryCpuLoad(target)
  EndIf
  gBatteryAutoDrainLastAdjust = now
  WriteBatteryDrainHelperTrace(gBatteryAutoDrainReason$, targetMinutes, currentMinutes, errorMinutes, controlW, usableMWh, target, #False, targetW, errorW, BatteryPhaseName(phase))
  RefreshBatteryCpuLoadDisplay()
EndProcedure

Procedure StopBatteryCpuLoad(logEvent.i = #True)
  Protected i.i
  Protected hadLoad.i = Bool(gBatteryCpuLoadTarget > 0 Or gBatteryCpuLoadThreadCount > 0)
  If logEvent
    gBatteryAutoDrainActive = #False
  EndIf
  gBatteryCpuLoadTarget = 0
  If gBatteryAutoDrainActive = #False
    gBatteryAutoDrainReason$ = ""
    gBatteryAutoDrainFilteredW = 0.0
  EndIf
  If gBatteryCpuLoadThreadCount > 0
    gBatteryCpuLoadStop = #True
    For i = 0 To gBatteryCpuLoadThreadCount - 1
      If gBatteryCpuLoadThreads(i)
        WaitThread(gBatteryCpuLoadThreads(i), 500)
        gBatteryCpuLoadThreads(i) = 0
      EndIf
    Next
    gBatteryCpuLoadThreadCount = 0
  EndIf
  If logEvent And hadLoad
    WriteBatteryTestRow("CPU load stopped", #True)
  EndIf
  RefreshBatteryCpuLoadDisplay()
EndProcedure

Procedure CompleteLenovoCalibrationReset()
  If gBatteryTestActive = #False Or gBatteryTestLenovoReset = #False
    ProcedureReturn
  EndIf
  gBatteryTestActive = #False
  gBatteryTestHasSummary = #True
  gBatteryTestEndTime = Date()
  If gBattery\Valid
    gBatteryTestEndTime = gBattery\Timestamp
    gBatteryTestEndPercent = gBattery\Percent
    gBatteryTestEndRemainingMWh = gBattery\RemainingMWh
  Else
    gBatteryTestEndPercent = gBatteryTestStartPercent
    gBatteryTestEndRemainingMWh = gBatteryTestStartRemainingMWh
  EndIf
  gBatteryAutoDrainActive = #False
  StopBatteryCpuLoad(#False)
  WriteBatteryTestRow("Lenovo calibration reset completed - " + BatteryTestShortSummary(), #True)
  SaveBatteryTestReportFile("lenovo_calibration_reset_completed")
  gBatteryTestLenovoReset = #False
  gBatteryTestVendorAuto = #False
  RefreshBatteryTestDisplay()
EndProcedure

Procedure RefreshBatteryTest()
  Protected now.q
  Protected elapsed.q
  Protected watts.d
  Protected deltaMWh.d
  Protected phase$
  Protected calibrationNow.i
  If gBattery\Valid = #False
    RefreshBatteryTestDisplay()
    ProcedureReturn
  EndIf
  phase$ = BatteryTestPhase()
  calibrationNow = Bool(gBattery\Connected And gBattery\DisconnectedBattery And gBattery\Charging = #False)
  If calibrationNow And gBatteryTestActive = #False And gBatteryTestHasSummary = #False
    ResetBatteryTestWorkflowState()
    BeginBatteryTestSession("Vendor calibration detected")
    gBatteryTestVendorAuto = #True
    gBatteryTestCalibrationActive = #True
    gBatteryTestCalibrationKnown = #True
    WriteBatteryTestRow("start vendor calibration monitor - plugged in discharging", #True)
  EndIf
  If gBatteryTestCalibrationKnown = #False Or calibrationNow <> gBatteryTestCalibrationActive
    If calibrationNow
      WriteBatteryTestRow("vendor calibration detected - plugged in discharging", #True)
    ElseIf gBatteryTestCalibrationKnown
      WriteBatteryTestRow("vendor calibration ended - " + phase$, #True)
    EndIf
    gBatteryTestCalibrationActive = calibrationNow
    gBatteryTestCalibrationKnown = #True
  EndIf
  If gBatteryTestLenovoReset
    If calibrationNow And gBatteryTestLenovoSawPluggedDrain = #False
      BeginBatteryTestSession("Lenovo calibration reset")
      gBatteryTestLenovoReset = #True
      gBatteryTestLenovoSawPluggedDrain = #True
      gBatteryTestLenovoSawCharging = #False
      WriteBatteryTestRow("Lenovo reset plugged-in discharge started", #True)
      If gBatteryAutoDrainActive = #False
        StartAutoDrainTarget()
      EndIf
    EndIf
    If gBattery\Charging
      If gBatteryTestLenovoSawCharging = #False
        WriteBatteryTestRow("Lenovo reset charge recovery started", #True)
      EndIf
      gBatteryTestLenovoSawCharging = #True
      If gBatteryAutoDrainActive Or gBatteryCpuLoadTarget > 0
        gBatteryAutoDrainActive = #False
        StopBatteryCpuLoad(#False)
        WriteBatteryTestRow("Lenovo reset drain helper stopped for charging", #True)
      EndIf
    EndIf
  EndIf
  If gBatteryTestActive = #False
    RefreshBatteryTestDisplay()
    ProcedureReturn
  EndIf
  now = gBattery\Timestamp
  If gBatteryTestLastTime > 0 And now > gBatteryTestLastTime
    elapsed = now - gBatteryTestLastTime
    deltaMWh = gBatteryTestLastRemainingMWh - gBattery\RemainingMWh
    If deltaMWh > 0.0
      gBatteryTestUsedMWh + deltaMWh
    ElseIf deltaMWh < 0.0
      gBatteryTestChargedMWh + Abs(deltaMWh)
    EndIf
    If gBattery\DisconnectedBattery And gBattery\Charging = #False
      gBatteryTestDischargeSeconds + elapsed
      watts = gBattery\DischargeRateMW / 1000.0
      If watts > 0.0
        gBatteryTestDischargeWattSeconds + (watts * elapsed)
      EndIf
    ElseIf gBattery\Charging
      gBatteryTestChargeSeconds + elapsed
      watts = gBattery\ChargeRateMW / 1000.0
      If watts > 0.0
        gBatteryTestChargeWattSeconds + (watts * elapsed)
      EndIf
    EndIf
  EndIf
  gBatteryTestLastTime = now
  gBatteryTestLastRemainingMWh = gBattery\RemainingMWh
  If now - gBatteryTestLastLogTime >= #BatteryTestSampleSeconds
    WriteBatteryTestRow("sample - " + phase$ + " elapsed " + BatteryTestElapsedText(now - gBatteryTestStartTime), #True)
    gBatteryTestLastLogTime = now
  EndIf
  UpdateAutoDrainTarget()
  If gBatteryTestLenovoReset And gBatteryTestLenovoSawPluggedDrain And gBatteryTestLenovoSawCharging
    If gBattery\Connected And gBattery\DisconnectedBattery = #False And gBattery\Charging = #False
      CompleteLenovoCalibrationReset()
      ProcedureReturn
    EndIf
  EndIf
  RefreshBatteryTestDisplay()
EndProcedure

Procedure RefreshBatteryTestDisplay()
  Protected phase$
  Protected estimate$
  Protected fastEstimate.i
  Protected elapsed.q
  Protected summary$
  If MainWindowVisible() = #False
    ProcedureReturn
  EndIf
  If IsGadget(#GadgetBatteryTestPhase) = #False
    ProcedureReturn
  EndIf
  phase$ = BatteryTestPhase()
  If gBattery\Valid
    fastEstimate = BatteryTestFastEstimateMinutes()
    If gBattery\Charging And gBattery\EstimateValid
      estimate$ = FormatBatteryMinutes(gBattery\EstimateMinutes) + " to full target"
    ElseIf gBattery\DisconnectedBattery And fastEstimate >= 0
      estimate$ = FormatBatteryMinutes(fastEstimate) + " to empty target"
    ElseIf gBattery\DisconnectedBattery And gBattery\EstimateValid
      estimate$ = FormatBatteryMinutes(gBattery\EstimateMinutes) + " average"
    ElseIf gBattery\RuntimeValid
      estimate$ = FormatBatteryMinutes(gBattery\RuntimeMinutes) + " Windows"
    Else
      estimate$ = "Calculating"
    EndIf
    SetGadgetTextIfChanged(#GadgetBatteryTestPercent, StrD(gBattery\Percent, 1) + "%")
    SetGadgetTextIfChanged(#GadgetBatteryTestRemaining, StrD(gBattery\RemainingMWh, 0) + " mWh")
    SetGadgetTextIfChanged(#GadgetBatteryTestWatts, FormatSignedBatteryWatts(gBattery\DischargeRateMW, gBattery\ChargeRateMW))
    SetGadgetTextIfChanged(#GadgetBatteryTestEstimate, estimate$)
  Else
    SetGadgetTextIfChanged(#GadgetBatteryTestPercent, "Unknown")
    SetGadgetTextIfChanged(#GadgetBatteryTestRemaining, "Unknown")
    SetGadgetTextIfChanged(#GadgetBatteryTestWatts, "Unknown")
    SetGadgetTextIfChanged(#GadgetBatteryTestEstimate, "Unknown")
  EndIf
  If gBatteryTestActive
    elapsed = Date() - gBatteryTestStartTime
  ElseIf gBatteryTestHasSummary
    elapsed = gBatteryTestEndTime - gBatteryTestStartTime
  Else
    elapsed = 0
  EndIf
  SetGadgetTextIfChanged(#GadgetBatteryTestPhase, phase$)
  SetGadgetTextIfChanged(#GadgetBatteryTestMode, BatteryTestMode())
  SetGadgetTextIfChanged(#GadgetBatteryTestGuide, BatteryTestGuide())
  SetGadgetTextIfChanged(#GadgetBatteryTestElapsed, BatteryTestElapsedText(elapsed))
  summary$ = BatteryTestReport()
  SetGadgetTextIfChanged(#GadgetBatteryTestSummary, summary$)
  DisableGadget(#GadgetBatteryTestStart, Bool(gBatteryTestActive))
  DisableGadget(#GadgetBatteryTestLenovo, Bool(gBatteryTestActive))
  DisableGadget(#GadgetBatteryTestEnd, Bool(gBatteryTestActive = #False))
  DisableGadget(#GadgetBatteryTestOpenReport, Bool(LatestBatteryReportPath() = ""))
  RefreshBatteryCpuLoadDisplay()
EndProcedure

; At app startup, compare current boot time with the saved boot time. If the PC
; booted and the last terminal event was not Shutdown, log improper shutdown.
Procedure LogStartupPowerEvents()
  Protected bootTime.q = CurrentBootTime()
  Protected lastEvent$ = LastBatteryEventName()
  Protected newBoot.i = Bool(gSettings\LastBootTime = 0 Or Abs(bootTime - gSettings\LastBootTime) > 120)
  CleanupAppCloseShutdownEvents(bootTime)
  If newBoot
    If gSettings\LastBootTime <> 0
      If LCase(lastEvent$) <> "shutdown"
        WriteBatteryEvent("Improper shutdown")
      EndIf
      WriteBatteryEvent("PC startup")
    EndIf
    gSettings\LastBootTime = bootTime
    SaveSettings()
  EndIf
EndProcedure

; Static battery data changes slowly, so query it once a day or on forced
; startup refresh. Design capacity may require a batteryreport fallback.
Procedure QueryBatteryStatic(force.i = #False)
  Protected now.q = Date()
  Protected output$
  Protected line$
  Protected i.i
  Protected full.d
  Protected design.d
  Protected cycle.i
  If force = #False And gSettings\BatteryLastStaticQuery > 0 And now - gSettings\BatteryLastStaticQuery < #BatteryStaticRefreshSeconds
    ProcedureReturn
  EndIf
  If QueryNativeBatteryData()
    gSettings\BatteryLastStaticQuery = now
    SaveSettings()
    ProcedureReturn
  EndIf
  ; root\wmi normally provides full-charge capacity and cycle count. Design
  ; capacity is less consistent across devices, so the command falls back
  ; through BatteryStaticData, Win32_Battery, then powercfg /batteryreport.
  output$ = PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $full=Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity | Select-Object -First 1; $cycle=Get-CimInstance -Namespace root\wmi -ClassName BatteryCycleCount | Select-Object -First 1; $static=Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData | Select-Object -First 1; $win=Get-CimInstance -ClassName Win32_Battery | Select-Object -First 1; $design=0; if ($static -and $static.DesignedCapacity) {$design=$static.DesignedCapacity}; if (-not $design -and $static -and $static.DesignCapacity) {$design=$static.DesignCapacity}; if (-not $design -and $win -and $win.DesignCapacity) {$design=$win.DesignCapacity}; if (-not $design) {$path=Join-Path $env:TEMP 'PowerPilot_battery_report.html'; powercfg /batteryreport /output $path | Out-Null; if (Test-Path $path) {$html=Get-Content -LiteralPath $path -Raw; $m=[regex]::Match($html,'DESIGN CAPACITY</span></td><td>([\d,]+) mWh'); if ($m.Success) {$design=[int](($m.Groups[1].Value) -replace ',','')}}}; if ($full) { 'static|FullChargedCapacity=' + $full.FullChargedCapacity + '|DesignCapacity=' + $design + '|CycleCount=' + $(if ($cycle) {$cycle.CycleCount} else {-1}) }")
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 7) = "static|"
      full = ValD(BatteryFieldValue(line$, "FullChargedCapacity"))
      design = ValD(BatteryFieldValue(line$, "DesignCapacity"))
      cycle = Val(BatteryFieldValue(line$, "CycleCount"))
      If full > 0.0
        gBattery\FullMWh = full
      EndIf
      If design > 0.0
        gBattery\DesignMWh = design
        If gBattery\FullMWh > 0.0
          gBattery\WearPercent = 100.0 - ((gBattery\FullMWh / gBattery\DesignMWh) * 100.0)
          If gBattery\WearPercent < 0.0 : gBattery\WearPercent = 0.0 : EndIf
        EndIf
      EndIf
      UpdateBatteryCapacityHealth(now, gBattery\FullMWh, gBattery\DesignMWh)
      If cycle >= 0
        gBattery\CycleCount = cycle
      EndIf
      gSettings\BatteryLastStaticQuery = now
      SaveSettings()
      ProcedureReturn
    EndIf
  Next
EndProcedure

; Live WMI read. BatteryRuntime.EstimatedRuntime is seconds on this machine,
; while Win32_Battery.EstimatedRunTime is minutes, so both units are handled.
Procedure QueryBatteryStatus()
  Protected output$
  Protected line$
  Protected i.i
  Protected status.SYSTEM_POWER_STATUS
  Protected percent.d
  Protected runtimeSeconds.q
  Protected runtimeMinutes.q
  Protected discharging.i
  If QueryNativeBatteryData()
    gBatteryNativeFallbackUsed = #False
    ProcedureReturn
  EndIf
  gBatteryNativeFallbackUsed = #True
  output$ = PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $s=Get-CimInstance -Namespace root\wmi -ClassName BatteryStatus | Select-Object -First 1; $r=Get-CimInstance -Namespace root\wmi -ClassName BatteryRuntime | Select-Object -First 1; $w=Get-CimInstance -ClassName Win32_Battery | Select-Object -First 1; if ($s) { 'status|Active=' + $s.Active + '|PowerOnline=' + $s.PowerOnline + '|Charging=' + $s.Charging + '|Discharging=' + $s.Discharging + '|RemainingCapacity=' + $s.RemainingCapacity + '|ChargeRate=' + $s.ChargeRate + '|DischargeRate=' + $s.DischargeRate + '|Voltage=' + $s.Voltage + '|EstimatedRuntimeSeconds=' + $(if ($r) {$r.EstimatedRuntime} else {-1}) + '|Win32EstimatedMinutes=' + $(if ($w) {$w.EstimatedRunTime} else {-1}) }")
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 7) = "status|"
      gBattery\Valid = #True
      gBattery\Timestamp = Date()
      gBattery\Connected = BatteryBool(BatteryFieldValue(line$, "PowerOnline"))
      gBattery\Charging = BatteryBool(BatteryFieldValue(line$, "Charging"))
      discharging = BatteryBool(BatteryFieldValue(line$, "Discharging"))
      gBattery\EnergySaverOn = WindowsEnergySaverActive()
      RememberBatteryPowerState(gBattery\Connected, gBattery\Charging)
      gBattery\RemainingMWh = ValD(BatteryFieldValue(line$, "RemainingCapacity"))
      gBattery\ChargeRateMW = ValD(BatteryFieldValue(line$, "ChargeRate"))
      gBattery\DischargeRateMW = ValD(BatteryFieldValue(line$, "DischargeRate"))
      gBattery\DisconnectedBattery = Bool(gBattery\Connected = #False Or discharging Or gBattery\DischargeRateMW > 0.0)
      gBattery\VoltageMV = ValD(BatteryFieldValue(line$, "Voltage"))
      runtimeSeconds = Val(BatteryFieldValue(line$, "EstimatedRuntimeSeconds"))
      runtimeMinutes = Val(BatteryFieldValue(line$, "Win32EstimatedMinutes"))
      ; Prefer root\wmi runtime when it is usable, then fall back to Win32.
      gBattery\RuntimeValid = Bool(runtimeSeconds > 0 And runtimeSeconds < 864000)
      If gBattery\RuntimeValid
        gBattery\RuntimeMinutes = runtimeSeconds / 60
      ElseIf runtimeMinutes > 0 And runtimeMinutes < 14400
        gBattery\RuntimeValid = #True
        gBattery\RuntimeMinutes = runtimeMinutes
      Else
        gBattery\RuntimeMinutes = -1
      EndIf
      If gBattery\FullMWh > 0.0 And gBattery\RemainingMWh > 0.0
        percent = (gBattery\RemainingMWh / gBattery\FullMWh) * 100.0
        If percent > 100.0 : percent = 100.0 : EndIf
        gBattery\Percent = percent
      ElseIf GetSystemPowerStatus_(@status) And status\BatteryLifePercent <= 100
        gBattery\Percent = status\BatteryLifePercent
      EndIf
      ProcedureReturn
    EndIf
  Next

  If GetSystemPowerStatus_(@status)
    gBattery\Valid = #True
    gBattery\Timestamp = Date()
    gBattery\Connected = Bool(status\ACLineStatus <> 0)
    gBattery\Charging = Bool(status\BatteryFlag & 8)
    gBattery\EnergySaverOn = WindowsEnergySaverActive()
    RememberBatteryPowerState(gBattery\Connected, gBattery\Charging)
    If status\BatteryLifePercent <= 100
      gBattery\Percent = status\BatteryLifePercent
    EndIf
    gBattery\RuntimeValid = Bool(status\BatteryLifeTime > 0 And status\BatteryLifeTime < 864000)
    If gBattery\RuntimeValid
      gBattery\RuntimeMinutes = status\BatteryLifeTime / 60
    Else
      gBattery\RuntimeMinutes = -1
    EndIf
    gBattery\DisconnectedBattery = Bool(status\ACLineStatus = 0 Or (gBattery\Charging = #False And gBattery\RuntimeValid))
  EndIf
EndProcedure

; Calculate the rolling average drain from recent graph points. Until a full
; glide window exists, the elapsed available active-battery time is used.
Procedure.d BatteryAverageDrainPctPerHour(now.q)
  Protected windowStart.q = now - (ClampInt(gSettings\BatterySmoothingMinutes, 5, 240) * 60)
  Protected i.i
  Protected previousTime.q = now
  Protected previousPercent.d = gBattery\Percent
  Protected elapsed.q
  Protected drain.d
  Protected totalDrain.d
  Protected activeElapsed.q
  Protected maxInterval.i = (ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440) * 120) + 60
  Protected refreshInterval.i = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600) * 4
  If refreshInterval > maxInterval
    maxInterval = refreshInterval
  EndIf
  If maxInterval < 600
    maxInterval = 600
  EndIf
  PruneBatteryAverageBreaks(now)
  ; Walk backward from the current point and stop at charging/idle AC power, a
  ; break row, a large gap, or the configured glide-window boundary. Some
  ; vendor calibration modes stay plugged in while deliberately discharging.
  For i = gBatteryGraphCount - 1 To 0 Step -1
    If gBatteryGraph(i)\Timestamp <= 0 Or gBatteryGraph(i)\Timestamp > previousTime
      Continue
    EndIf
    If gBatteryGraph(i)\Connected And (gBatteryGraph(i)\Charging Or gBatteryGraph(i)\Percent <= previousPercent)
      Break
    EndIf
    If gBatteryGraph(i)\Timestamp < windowStart
      Break
    EndIf
    If BatteryIntervalHasAverageBreak(gBatteryGraph(i)\Timestamp, previousTime)
      Break
    EndIf
    elapsed = previousTime - gBatteryGraph(i)\Timestamp
    If elapsed > maxInterval
      Break
    EndIf
    If elapsed >= 10
      drain = gBatteryGraph(i)\Percent - previousPercent
      If drain > 0.0
        totalDrain + drain
      EndIf
      activeElapsed + elapsed
    EndIf
    previousTime = gBatteryGraph(i)\Timestamp
    previousPercent = gBatteryGraph(i)\Percent
  Next
  ; If the graph has not yet been updated, fall back to the last live sample so
  ; the estimate can start moving before the first scheduled log interval.
  If activeElapsed = 0 And gBatteryLastSampleTime > 0 And gBatteryLastSampleTime < now And BatteryIntervalHasAverageBreak(gBatteryLastSampleTime, now) = #False
    elapsed = now - gBatteryLastSampleTime
    If elapsed >= 10 And elapsed <= maxInterval And gBatteryLastSamplePercent > gBattery\Percent
      totalDrain = gBatteryLastSamplePercent - gBattery\Percent
      activeElapsed = elapsed
    EndIf
  EndIf
  If activeElapsed >= #BatteryAverageMinSeconds And totalDrain > 0.0
    drain = (totalDrain * 3600.0) / activeElapsed
    If drain > 0.0 And drain < 200.0
      ProcedureReturn drain
    EndIf
  EndIf
  ProcedureReturn 0.0
EndProcedure

Procedure.d BatteryAverageChargePctPerHour(now.q)
  Protected windowStart.q = now - (ClampInt(gSettings\BatterySmoothingMinutes, 5, 240) * 60)
  Protected i.i
  Protected previousTime.q = now
  Protected previousPercent.d = gBattery\Percent
  Protected elapsed.q
  Protected charge.d
  Protected totalCharge.d
  Protected activeElapsed.q
  Protected maxInterval.i = (ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440) * 120) + 60
  Protected refreshInterval.i = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600) * 4
  If refreshInterval > maxInterval
    maxInterval = refreshInterval
  EndIf
  If maxInterval < 600
    maxInterval = 600
  EndIf
  PruneBatteryAverageBreaks(now)
  For i = gBatteryGraphCount - 1 To 0 Step -1
    If gBatteryGraph(i)\Timestamp <= 0 Or gBatteryGraph(i)\Timestamp > previousTime
      Continue
    EndIf
    If gBatteryGraph(i)\Connected = #False Or gBatteryGraph(i)\Charging = #False
      Break
    EndIf
    If gBatteryGraph(i)\Timestamp < windowStart
      Break
    EndIf
    If BatteryIntervalHasAverageBreak(gBatteryGraph(i)\Timestamp, previousTime)
      Break
    EndIf
    elapsed = previousTime - gBatteryGraph(i)\Timestamp
    If elapsed > maxInterval
      Break
    EndIf
    If elapsed >= 10
      charge = previousPercent - gBatteryGraph(i)\Percent
      If charge > 0.0
        totalCharge + charge
      EndIf
      activeElapsed + elapsed
    EndIf
    previousTime = gBatteryGraph(i)\Timestamp
    previousPercent = gBatteryGraph(i)\Percent
  Next
  If activeElapsed = 0 And gBatteryLastSampleTime > 0 And gBatteryLastSampleTime < now And BatteryIntervalHasAverageBreak(gBatteryLastSampleTime, now) = #False
    elapsed = now - gBatteryLastSampleTime
    If elapsed >= 10 And elapsed <= maxInterval And gBatteryLastSamplePercent < gBattery\Percent
      totalCharge = gBattery\Percent - gBatteryLastSamplePercent
      activeElapsed = elapsed
    EndIf
  EndIf
  If activeElapsed >= 60 And totalCharge > 0.0
    charge = (totalCharge * 3600.0) / activeElapsed
    If charge > 0.0 And charge < 200.0
      ProcedureReturn charge
    EndIf
  EndIf
  ProcedureReturn 0.0
EndProcedure

Procedure.d BatteryChargingTaperFactor(percent.d, targetPercent.d)
  Protected ratio.d
  Protected factor.d
  If targetPercent <= 0.0
    ProcedureReturn 1.0
  EndIf
  ratio = percent / targetPercent
  If ratio < 0.0 : ratio = 0.0 : EndIf
  If ratio > 1.0 : ratio = 1.0 : EndIf
  factor = 1.0 - (0.72 * ratio * ratio * ratio)
  If factor < 0.18 : factor = 0.18 : EndIf
  ProcedureReturn factor
EndProcedure

Procedure.d BatteryChargingTaperAdjustedRatePctPerHour(ratePctPerHour.d, currentPercent.d, previousPercent.d, targetPercent.d)
  Protected currentFactor.d
  Protected targetFactor.d
  Protected previousFactor.d
  Protected futureAverageFactor.d
  Protected observedNextFactor.d
  Protected adjustedFactor.d
  If ratePctPerHour <= 0.0
    ProcedureReturn 0.0
  EndIf
  If targetPercent <= currentPercent
    ProcedureReturn ratePctPerHour
  EndIf
  currentFactor = BatteryChargingTaperFactor(currentPercent, targetPercent)
  targetFactor = BatteryChargingTaperFactor(targetPercent, targetPercent)
  futureAverageFactor = (currentFactor + targetFactor) / 2.0
  If previousPercent > 0.0 And previousPercent < currentPercent
    previousFactor = BatteryChargingTaperFactor(previousPercent, targetPercent)
    If previousFactor > 0.0
      observedNextFactor = currentFactor * (currentFactor / previousFactor)
      If observedNextFactor < targetFactor
        observedNextFactor = targetFactor
      EndIf
      futureAverageFactor = (futureAverageFactor + ((observedNextFactor + targetFactor) / 2.0)) / 2.0
    EndIf
  EndIf
  If currentFactor <= 0.0
    ProcedureReturn ratePctPerHour
  EndIf
  adjustedFactor = futureAverageFactor / currentFactor
  If adjustedFactor < 0.20 : adjustedFactor = 0.20 : EndIf
  If adjustedFactor > 1.00 : adjustedFactor = 1.00 : EndIf
  ProcedureReturn ratePctPerHour * adjustedFactor
EndProcedure

Procedure.i RememberLearnedChargingRate(ratePctPerHour.d)
  Protected count.i
  Protected weight.i
  Protected learned.d
  If ratePctPerHour <= 0.0 Or ratePctPerHour >= 200.0
    ProcedureReturn #False
  EndIf
  count = ClampInt(gSettings\BatteryChargeLearningCount, 0, #BatteryChargeLearningCap)
  If count <= 0 Or gSettings\BatteryLastChargePctPerHour <= 0.0
    learned = ratePctPerHour
    count = 1
  Else
    weight = count
    If weight >= #BatteryChargeLearningCap
      weight = #BatteryChargeLearningCap - 1
    EndIf
    learned = ((gSettings\BatteryLastChargePctPerHour * weight) + ratePctPerHour) / (weight + 1)
    If count < #BatteryChargeLearningCap
      count + 1
    EndIf
  EndIf
  If Abs(gSettings\BatteryLastChargePctPerHour - learned) >= 0.05 Or gSettings\BatteryChargeLearningCount <> count
    gSettings\BatteryLastChargePctPerHour = learned
    gSettings\BatteryChargeLearningCount = count
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; Combine firmware/WMI charge/discharge rates, measured percent movement, and
; retained-log learning into average and instant time estimates.
Procedure UpdateBatteryEstimate()
  Protected now.q = gBattery\Timestamp
  Protected elapsed.q
  Protected liveDrain.d
  Protected sampleDrain.d
  Protected instantDrain.d
  Protected averageDrain.d
  Protected liveCharge.d
  Protected sampleCharge.d
  Protected instantCharge.d
  Protected averageCharge.d
  Protected adjustedInstantCharge.d
  Protected adjustedAverageCharge.d
  Protected remainingPercent.d
  Protected targetPercent.d
  Protected chargeRemainingPercent.d
  Protected runtimeFullMWh.d
  Protected estimateWatts.d
  Protected usableMWh.d
  Protected phase.i
  If gBattery\Valid = #False
    ProcedureReturn
  EndIf
  phase = BatteryOperatingPhase(gBattery\Connected, gBattery\Charging, gBattery\DisconnectedBattery)
  gBattery\Phase = phase
  UpdateBatteryCapacityHealth(now, gBattery\FullMWh, gBattery\DesignMWh)
  runtimeFullMWh = BatteryRuntimeFullMWh()

  ; Seed discharge display from retained history or user setting so startup does
  ; not show "Calculating" until a full active-battery window has passed.
  If gBattery\SmoothedDrainPctPerHour <= 0.0
    If gSettings\BatteryLastDrainPctPerHour > 0.0
      gBattery\SmoothedDrainPctPerHour = gSettings\BatteryLastDrainPctPerHour
    Else
      gBattery\SmoothedDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
    EndIf
  EndIf

  ; Normal battery discharge and vendor calibration discharge both reduce the
  ; battery while Windows can expose a useful discharge rate. Treat both phases
  ; as time-to-empty situations; pure AC idle/full stays in the neutral branch
  ; below because there is no active charge or drain event to time.
  If phase = #BatteryPhaseOnBatteryNormal Or phase = #BatteryPhasePluggedDischargingCalibration
    If gBatteryOnBatterySince = 0
      gBatteryOnBatterySince = now
    EndIf
    RecalculateBatteryPowerEstimates(now)
    ; Instant drain prefers current WMI discharge rate because it reflects the
    ; present workload. Measured percent drop is used to stabilize/fill gaps.
    If runtimeFullMWh > 0.0 And gBattery\DischargeRateMW > 0.0
      liveDrain = (gBattery\DischargeRateMW / runtimeFullMWh) * 100.0
      instantDrain = liveDrain
    EndIf
    If gBatteryLastSampleTime > 0 And gBatteryLastSamplePercent > gBattery\Percent
      elapsed = now - gBatteryLastSampleTime
      If elapsed >= 10
        If gBatteryLastSampleRemainingMWh > 0.0 And gBattery\RemainingMWh > 0.0 And gBatteryLastSampleRemainingMWh > gBattery\RemainingMWh And runtimeFullMWh > 0.0
          sampleDrain = (((gBatteryLastSampleRemainingMWh - gBattery\RemainingMWh) / runtimeFullMWh) * 100.0 * 3600.0) / elapsed
        Else
          sampleDrain = ((gBatteryLastSamplePercent - gBattery\Percent) * 3600.0) / elapsed
        EndIf
        If sampleDrain > 0.0 And sampleDrain < 200.0
          If instantDrain <= 0.0
            instantDrain = sampleDrain
          EndIf
          If liveDrain > 0.0
            liveDrain = (liveDrain + sampleDrain) / 2.0
          Else
            liveDrain = sampleDrain
          EndIf
        EndIf
      EndIf
    EndIf
    estimateWatts = BatteryPreferredRuntimeWatts()
    If estimateWatts > 0.0 And estimateWatts < 60.0 And runtimeFullMWh > 0.0
      averageDrain = ((estimateWatts * 1000.0) / runtimeFullMWh) * 100.0
      gBattery\SmoothedDrainPctPerHour = averageDrain
    ElseIf liveDrain > 0.0 And liveDrain < 200.0
      averageDrain = BatteryAverageDrainPctPerHour(now)
      If averageDrain > 0.0
        gBattery\SmoothedDrainPctPerHour = averageDrain
      EndIf
    EndIf
    ; Remaining time is calculated to the configured empty floor, which is 0%
    ; by default but can be raised by the user.
    remainingPercent = gBattery\Percent - gSettings\BatteryMinPercent
    If remainingPercent > 0.0 And instantDrain > 0.0 And instantDrain < 200.0
      gBattery\InstantDrainPctPerHour = instantDrain
      gBattery\InstantEstimateMinutes = (remainingPercent / instantDrain) * 60.0
      gBattery\InstantEstimateValid = #True
    Else
      gBattery\InstantDrainPctPerHour = 0.0
      gBattery\InstantEstimateMinutes = -1
      gBattery\InstantEstimateValid = #False
    EndIf
    usableMWh = BatteryTestUsableMWh()
    If usableMWh > 0.0 And estimateWatts > 0.0
      gBattery\EstimateMinutes = ((usableMWh / 1000.0) / estimateWatts) * 60.0
      gBattery\EstimateValid = #True
    ElseIf remainingPercent > 0.0 And gBattery\SmoothedDrainPctPerHour > 0.0
      gBattery\EstimateMinutes = (remainingPercent / gBattery\SmoothedDrainPctPerHour) * 60.0
      gBattery\EstimateValid = #True
    Else
      gBattery\EstimateMinutes = -1
      gBattery\EstimateValid = #False
    EndIf
    gBattery\LowBatteryPlateau = #False
    If gBatteryLastSampleTime > 0 And gBattery\DischargeRateMW > 0.0
      If Abs(gBatteryLastSamplePercent - gBattery\Percent) < 0.02 And Abs(gBatteryLastSampleRemainingMWh - gBattery\RemainingMWh) < 1.0
        gBatteryFlatSampleCount + 1
      Else
        gBatteryFlatSampleCount = 0
      EndIf
      If gBatteryFlatSampleCount >= 2
        gBattery\LowBatteryPlateau = #True
      EndIf
    EndIf
    gBattery\EstimateLowConfidence = Bool(gBattery\Percent < #BatteryLowGaugePercent Or gBattery\LowBatteryPlateau)
  ElseIf gBattery\Charging
    gBatteryOnBatterySince = 0
    gBatteryFlatSampleCount = 0
    gBattery\EstimateLowConfidence = #False
    gBattery\LowBatteryPlateau = #False
    targetPercent = BatteryEffectiveMaxPercent()
    chargeRemainingPercent = targetPercent - gBattery\Percent
    If gBattery\SmoothedChargePctPerHour <= 0.0 And gSettings\BatteryLastChargePctPerHour > 0.0
      gBattery\SmoothedChargePctPerHour = gSettings\BatteryLastChargePctPerHour
    EndIf

    If runtimeFullMWh > 0.0 And gBattery\ChargeRateMW > 0.0
      liveCharge = (gBattery\ChargeRateMW / runtimeFullMWh) * 100.0
      instantCharge = liveCharge
    EndIf
    If gBatteryLastSampleTime > 0 And gBatteryLastSamplePercent < gBattery\Percent
      elapsed = now - gBatteryLastSampleTime
      If elapsed >= 10
        sampleCharge = ((gBattery\Percent - gBatteryLastSamplePercent) * 3600.0) / elapsed
        If sampleCharge > 0.0 And sampleCharge < 200.0
          If instantCharge <= 0.0
            instantCharge = sampleCharge
          EndIf
          If liveCharge > 0.0
            liveCharge = (liveCharge + sampleCharge) / 2.0
          Else
            liveCharge = sampleCharge
          EndIf
        EndIf
      EndIf
    EndIf

    averageCharge = BatteryAverageChargePctPerHour(now)
    If averageCharge <= 0.0
      averageCharge = liveCharge
    EndIf
    If averageCharge <= 0.0 And gSettings\BatteryLastChargePctPerHour > 0.0
      averageCharge = gSettings\BatteryLastChargePctPerHour
    EndIf
    If averageCharge > 0.0 And averageCharge < 200.0
      gBattery\SmoothedChargePctPerHour = averageCharge
    EndIf

    adjustedInstantCharge = BatteryChargingTaperAdjustedRatePctPerHour(instantCharge, gBattery\Percent, gBatteryLastSamplePercent, targetPercent)
    adjustedAverageCharge = BatteryChargingTaperAdjustedRatePctPerHour(gBattery\SmoothedChargePctPerHour, gBattery\Percent, gBatteryLastSamplePercent, targetPercent)
    If chargeRemainingPercent <= 0.0
      gBattery\InstantDrainPctPerHour = 0.0
      gBattery\InstantEstimateMinutes = 0
      gBattery\InstantEstimateValid = #True
      gBattery\EstimateMinutes = 0
      gBattery\EstimateValid = #True
    Else
      If adjustedInstantCharge > 0.0 And adjustedInstantCharge < 200.0
        gBattery\InstantDrainPctPerHour = adjustedInstantCharge
        gBattery\InstantEstimateMinutes = (chargeRemainingPercent / adjustedInstantCharge) * 60.0
        gBattery\InstantEstimateValid = #True
      Else
        gBattery\InstantDrainPctPerHour = 0.0
        gBattery\InstantEstimateMinutes = -1
        gBattery\InstantEstimateValid = #False
      EndIf
      If adjustedAverageCharge > 0.0 And adjustedAverageCharge < 200.0
        gBattery\EstimateMinutes = (chargeRemainingPercent / adjustedAverageCharge) * 60.0
        gBattery\EstimateValid = #True
      Else
        gBattery\EstimateMinutes = -1
        gBattery\EstimateValid = #False
      EndIf
    EndIf
  Else
    gBatteryOnBatterySince = 0
    gBatteryFlatSampleCount = 0
    gBattery\EstimateLowConfidence = #False
    gBattery\LowBatteryPlateau = #False
    gBattery\EstimateMinutes = -1
    gBattery\EstimateValid = #False
    gBattery\InstantDrainPctPerHour = 0.0
    gBattery\InstantEstimateMinutes = -1
    gBattery\InstantEstimateValid = #False
  EndIf

  gBatteryLastSampleTime = now
  gBatteryLastSamplePercent = gBattery\Percent
  gBatteryLastSampleRemainingMWh = gBattery\RemainingMWh
EndProcedure

; Write a battery sample row when the interval elapses, or immediately on
; forced startup/refresh. App and event rows are written by separate functions.
Procedure WriteBatteryLog(force.i = #False)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected smoothedRateForLog.d
  Protected intervalSeconds.i = ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440) * 60
  If gSettings\BatteryLogEnabled = #False Or gBattery\Valid = #False
    ProcedureReturn
  EndIf
  If force = #False And gLastBatteryLogTime > 0 And gBattery\Timestamp - gLastBatteryLogTime < intervalSeconds
    ProcedureReturn
  EndIf
  If ShouldQueryScreenBrightness()
    gLastScreenBrightnessPercent = QueryScreenBrightnessPercent()
  Else
    gLastScreenBrightnessPercent = -1
  EndIf
  EnsureSettingsDirectory()
  EnsureBatteryLogHeaderCurrent()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    If gBattery\Charging
      smoothedRateForLog = gBattery\SmoothedChargePctPerHour
    Else
      smoothedRateForLog = gBattery\SmoothedDrainPctPerHour
    EndIf
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    ; CSV order must match BatteryLogHeader. Runtime minutes is the direct
    ; Windows estimate; average/instant values are PowerPilot estimates.
    line$ = IsoTimestamp(gBattery\Timestamp)
    line$ + "," + StrD(gBattery\Percent, 2)
    line$ + "," + Str(gBattery\Connected)
    line$ + "," + Str(gBattery\Charging)
    line$ + "," + Str(gBattery\DisconnectedBattery)
    line$ + "," + StrD(gBattery\RemainingMWh, 0)
    line$ + "," + StrD(gBattery\FullMWh, 0)
    line$ + "," + StrD(gBattery\DesignMWh, 0)
    line$ + "," + StrD(gBattery\WearPercent, 1)
    line$ + "," + StrD(gBattery\DischargeRateMW, 0)
    line$ + "," + StrD(gBattery\ChargeRateMW, 0)
    line$ + "," + Str(gBattery\RuntimeMinutes)
    line$ + "," + Str(gBattery\EstimateMinutes)
    line$ + "," + Str(gBattery\InstantEstimateMinutes)
    line$ + "," + StrD(gBattery\InstantDrainPctPerHour, 2)
    line$ + "," + StrD(smoothedRateForLog, 2)
    line$ + "," + Str(gBattery\CycleCount)
    line$ + ",battery,,," + BatteryLogBrightnessText()
    line$ + "," + Str(gBattery\EnergySaverOn)
    WriteStringN(file, line$)
    CloseFile(file)
    PruneBatteryLog()
    gLastBatteryLogTime = gBattery\Timestamp
    If gBattery\Charging And smoothedRateForLog > 0.0
      If RememberLearnedChargingRate(smoothedRateForLog)
        SaveSettings()
      EndIf
    ElseIf gBattery\DisconnectedBattery And gBattery\SmoothedDrainPctPerHour > 0.0
      gSettings\BatteryLastDrainPctPerHour = gBattery\SmoothedDrainPctPerHour
      SaveSettings()
    EndIf
    AddBatteryGraphPoint(gBattery\Timestamp, gBattery\Percent, gBattery\Connected, gBattery\Charging, gBattery\EnergySaverOn, gBattery\DisconnectedBattery, gBattery\RemainingMWh, gBattery\FullMWh, gBattery\DischargeRateMW, gBattery\ChargeRateMW, BatteryCurrentScreenOnKnown(), BatteryCurrentScreenOn(), gLastScreenBrightnessPercent)
    RefreshBatteryLogPreview()
  EndIf
EndProcedure

; Use two cadences: the visible window follows the user setting, while tray mode
; backs off to a slower floor to reduce idle wakeups and battery-driver reads.
Procedure.i DesiredBatteryRefreshSeconds()
  Protected seconds.i = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)
  If BatteryTestTabVisible()
    ProcedureReturn 1
  EndIf
  If MainWindowVisible() = #False And seconds < #BatteryHiddenRefreshSeconds
    seconds = #BatteryHiddenRefreshSeconds
  EndIf
  ProcedureReturn seconds
EndProcedure

; Refresh live battery data on the configured cadence. Static capacity data is
; queried only when missing or once per day to keep startup/refresh light.
Procedure RefreshBattery(force.i = #False, forceLog.i = #False)
  Protected now.q = Date()
  If force = #False And gLastBatteryRefresh > 0 And now - gLastBatteryRefresh < DesiredBatteryRefreshSeconds()
    ProcedureReturn
  EndIf
  QueryBatteryStatic(Bool(gBattery\FullMWh <= 0.0))
  QueryBatteryStatus()
  If gBattery\Valid
    TrackEnergySaverLogState()
    UpdateBatteryEstimate()
    AddBatteryGraphPoint(gBattery\Timestamp, gBattery\Percent, gBattery\Connected, gBattery\Charging, gBattery\EnergySaverOn, gBattery\DisconnectedBattery, gBattery\RemainingMWh, gBattery\FullMWh, gBattery\DischargeRateMW, gBattery\ChargeRateMW, BatteryCurrentScreenOnKnown(), BatteryCurrentScreenOn(), gLastScreenBrightnessPercent)
    WriteBatteryLog(forceLog)
    RefreshBatteryTest()
  EndIf
  gLastBatteryRefresh = now
  RefreshBatteryDisplay()
EndProcedure

; powercfg wrappers keep all plan manipulation in one place.
Procedure.i RunPowerCfg(arguments$)
  ProcedureReturn RunExitCode("powercfg.exe", arguments$)
EndProcedure

Procedure.s RunPowerCfgCapture(arguments$)
  ProcedureReturn RunCapture("powercfg.exe", arguments$)
EndProcedure

; Extract the first GUID from powercfg output.
Procedure.s FindGuidInText(text$)
  Protected re.i
  Protected result$
  re = CreateRegularExpression(#PB_Any, "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
  If re
    If ExamineRegularExpression(re, text$)
      If NextRegularExpressionMatch(re)
        result$ = RegularExpressionMatchString(re)
      EndIf
    EndIf
    FreeRegularExpression(re)
  EndIf
  ProcedureReturn LCase(result$)
EndProcedure

; Helpers for converting GUID pointers returned by powrprof.dll into strings.
Procedure.s HexPart(value.q, width.i)
  ProcedureReturn RSet(LCase(Hex(value)), width, "0")
EndProcedure

Procedure.s GuidPointerText(*guid)
  Protected text$
  If *guid = 0
    ProcedureReturn ""
  EndIf

  text$ = HexPart(PeekL(*guid) & $FFFFFFFF, 8)
  text$ + "-" + HexPart(PeekW(*guid + 4) & $FFFF, 4)
  text$ + "-" + HexPart(PeekW(*guid + 6) & $FFFF, 4)
  text$ + "-" + HexPart(PeekA(*guid + 8) & $FF, 2) + HexPart(PeekA(*guid + 9) & $FF, 2)
  text$ + "-" + HexPart(PeekA(*guid + 10) & $FF, 2) + HexPart(PeekA(*guid + 11) & $FF, 2)
  text$ + HexPart(PeekA(*guid + 12) & $FF, 2) + HexPart(PeekA(*guid + 13) & $FF, 2)
  text$ + HexPart(PeekA(*guid + 14) & $FF, 2) + HexPart(PeekA(*guid + 15) & $FF, 2)
  ProcedureReturn text$
EndProcedure

Procedure.i SetGuidFromText(guidText$, *guid.GuidValue)
  Protected compact$ = RemoveString(LCase(guidText$), "-")
  Protected i.i
  If *guid = 0 Or Len(compact$) <> 32
    ProcedureReturn #False
  EndIf
  *guid\Data1 = Val("$" + Mid(compact$, 1, 8))
  *guid\Data2 = Val("$" + Mid(compact$, 9, 4))
  *guid\Data3 = Val("$" + Mid(compact$, 13, 4))
  For i = 0 To 7
    *guid\Data4[i] = Val("$" + Mid(compact$, 17 + (i * 2), 2))
  Next
  ProcedureReturn #True
EndProcedure

; Load powrprof lazily. Some Windows builds expose different overlay APIs, so
; GetWindowsPowerModeGuid falls back between them.
Procedure EnsurePowerApi()
  If gPowerApiTried
    ProcedureReturn
  EndIf
  gPowerApiTried = #True
  gPowrProfLibrary = OpenLibrary(#PB_Any, "powrprof.dll")
  If gPowrProfLibrary
    gPowerGetActiveScheme = GetFunction(gPowrProfLibrary, "PowerGetActiveScheme")
    gPowerSetActiveScheme = GetFunction(gPowrProfLibrary, "PowerSetActiveScheme")
    gPowerGetEffectiveOverlayScheme = GetFunction(gPowrProfLibrary, "PowerGetEffectiveOverlayScheme")
    gPowerGetUserConfiguredACPowerMode = GetFunction(gPowrProfLibrary, "PowerGetUserConfiguredACPowerMode")
    gPowerGetUserConfiguredDCPowerMode = GetFunction(gPowrProfLibrary, "PowerGetUserConfiguredDCPowerMode")
    gPowerReadACValueIndex = GetFunction(gPowrProfLibrary, "PowerReadACValueIndex")
    gPowerReadDCValueIndex = GetFunction(gPowrProfLibrary, "PowerReadDCValueIndex")
  EndIf
EndProcedure

Procedure.i SetActiveSchemeByGuid(schemeGuid$)
  Protected guid.GuidValue
  EnsurePowerApi()
  ; Prefer the native powrprof activation path. On some Windows 11 systems the
  ; same normal user can activate the scheme through PowerSetActiveScheme while
  ; `powercfg /SETACTIVE` returns "Access is denied"; keeping powercfg as a
  ; fallback still helps older or unusual builds where the API entry point is
  ; unavailable.
  If gPowerSetActiveScheme And SetGuidFromText(schemeGuid$, @guid)
    If gPowerSetActiveScheme(0, @guid) = #ERROR_SUCCESS
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn Bool(RunPowerCfg("/SETACTIVE " + schemeGuid$) = 0)
EndProcedure

; Read a GUID from one of the powrprof overlay callbacks.
Procedure.s ReadPowerGuidValue(callback.PowerGetGuidValueProto)
  Protected *guid
  Protected result$
  If callback = 0
    ProcedureReturn ""
  EndIf
  *guid = AllocateMemory(16)
  If *guid
    If callback(*guid) = #ERROR_SUCCESS
      result$ = GuidPointerText(*guid)
    EndIf
    FreeMemory(*guid)
  EndIf
  ProcedureReturn result$
EndProcedure

; API path for active plan GUID. powercfg text parsing is kept as fallback.
Procedure.s GetActiveSchemeGuidByApi()
  Protected activeScheme.i
  Protected guid$
  EnsurePowerApi()
  If gPowerGetActiveScheme And gPowerGetActiveScheme(0, @activeScheme) = #ERROR_SUCCESS And activeScheme
    guid$ = GuidPointerText(activeScheme)
    LocalFree_(activeScheme)
  EndIf
  ProcedureReturn guid$
EndProcedure

; Use GetSystemPowerStatus for a cheap AC/DC check when choosing AC/DC overlay.
Procedure.i CurrentPowerSupplyIsBattery()
  Protected status.SYSTEM_POWER_STATUS
  If GetSystemPowerStatus_(@status)
    ProcedureReturn Bool(status\ACLineStatus = 0)
  EndIf
  ProcedureReturn #False
EndProcedure

; Resolve Windows power mode overlay. Prefer the effective overlay; fall back to
; the user-configured AC/DC overlay when effective overlay is unavailable.
Procedure.s GetWindowsPowerModeGuid()
  Protected guid$
  EnsurePowerApi()

  guid$ = ReadPowerGuidValue(gPowerGetEffectiveOverlayScheme)
  If guid$ <> ""
    ProcedureReturn guid$
  EndIf

  If CurrentPowerSupplyIsBattery()
    guid$ = ReadPowerGuidValue(gPowerGetUserConfiguredDCPowerMode)
  Else
    guid$ = ReadPowerGuidValue(gPowerGetUserConfiguredACPowerMode)
  EndIf
  ProcedureReturn guid$
EndProcedure

; Load process-throttling APIs lazily. If unavailable, maintenance throttling is
; simply skipped.
Procedure EnsureProcessThrottleApi()
  If gThrottleApiTried
    ProcedureReturn
  EndIf
  gThrottleApiTried = #True
  gKernelLibrary = OpenLibrary(#PB_Any, "kernel32.dll")
  If gKernelLibrary
    gSetProcessInformation = GetFunction(gKernelLibrary, "SetProcessInformation")
    gGetProcessInformation = GetFunction(gKernelLibrary, "GetProcessInformation")
  EndIf
EndProcedure

; Avoid throttling the foreground process, even if its exe name matches a
; maintenance process pattern.
Procedure.i ForegroundProcessId()
  Protected hwnd.i = GetForegroundWindow_()
  Protected pid.i
  If hwnd
    GetWindowThreadProcessId_(hwnd, @pid)
  EndIf
  ProcedureReturn pid
EndProcedure

; Conservative allowlist of background maintenance processes that are safe to
; place in EcoQoS while Windows is in efficiency mode.
Procedure.i IsMaintenanceThrottleProcessName(exeName$)
  Select LCase(exeName$)
    Case "searchindexer.exe", "searchprotocolhost.exe", "searchfilterhost.exe"
      ProcedureReturn #True
    Case "sdxhelper.exe", "officec2rclient.exe", "officeclicktorun.exe"
      ProcedureReturn #True
    Case "microsoftedgeupdate.exe"
      ProcedureReturn #True
  EndSelect
  ProcedureReturn #False
EndProcedure

; Apply or clear EcoQoS execution-speed throttling on one process.
Procedure.i SetProcessEcoThrottle(pid.i, enable.i)
  Protected processHandle.i
  Protected state.ProcessPowerThrottlingState
  Protected stateSize.i = SizeOf(ProcessPowerThrottlingState)
  Protected queried.i
  Protected result.i

  If pid <= 0
    ProcedureReturn #False
  EndIf
  EnsureProcessThrottleApi()
  If gSetProcessInformation = 0
    ProcedureReturn #False
  EndIf

  processHandle = OpenProcess_(#PROCESS_SET_INFORMATION | #PROCESS_QUERY_LIMITED_INFORMATION, #False, pid)
  If processHandle = 0
    ProcedureReturn #False
  EndIf

  state\Version = #PROCESS_POWER_THROTTLING_CURRENT_VERSION
  If gGetProcessInformation
    queried = gGetProcessInformation(processHandle, #ProcessPowerThrottling, @state, stateSize)
  EndIf
  If queried = #False
    state\Version = #PROCESS_POWER_THROTTLING_CURRENT_VERSION
    state\ControlMask = 0
    state\StateMask = 0
  EndIf

  If enable
    state\ControlMask = state\ControlMask | #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
    state\StateMask = state\StateMask | #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
  Else
    If state\ControlMask & #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
      state\ControlMask = state\ControlMask ! #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
    EndIf
    If state\StateMask & #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
      state\StateMask = state\StateMask ! #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
    EndIf
  EndIf

  result = gSetProcessInformation(processHandle, #ProcessPowerThrottling, @state, stateSize)
  CloseHandle_(processHandle)
  ProcedureReturn Bool(result)
EndProcedure

; Scan processes at a modest cadence and apply EcoQoS only to the allowlist.
Procedure.i ApplyMaintenanceThrottling(enable.i, force.i = #False)
  Protected now.q = ElapsedMilliseconds()
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected foregroundPid.i = ForegroundProcessId()
  Protected exeName$
  Protected changed.i

  If gSettings\ThrottleMaintenance = #False
    enable = #False
  EndIf
  If force = #False And enable And gMaintenanceThrottleActive And now - gLastMaintenanceThrottleScan < #ThrottleScanMs
    ProcedureReturn 0
  EndIf
  If force = #False And enable = #False And gMaintenanceThrottleActive = #False
    ProcedureReturn 0
  EndIf

  EnsureProcessThrottleApi()
  If gSetProcessInformation = 0
    ProcedureReturn 0
  EndIf

  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot = #INVALID_HANDLE_VALUE
    ProcedureReturn 0
  EndIf

  entry\dwSize = SizeOf(PowerPilotProcessEntry32)
  If Process32First_(snapshot, @entry)
    Repeat
      exeName$ = PeekS(@entry\szExeFile[0])
      If IsMaintenanceThrottleProcessName(exeName$) And entry\th32ProcessID <> foregroundPid
        If SetProcessEcoThrottle(entry\th32ProcessID, enable)
          changed + 1
        EndIf
      EndIf
    Until Process32Next_(snapshot, @entry) = #False
  EndIf
  CloseHandle_(snapshot)

  gMaintenanceThrottleActive = Bool(enable)
  gLastMaintenanceThrottleScan = now
  ProcedureReturn changed
EndProcedure

; Deep idle saver also marks PowerPilot itself as background/EcoQoS while the
; window is hidden. Clear it when visible so the GUI stays responsive.
Procedure ApplySelfDeepIdleThrottle()
  Protected enable.i = Bool(gSettings\DeepIdleSaver And MainWindowVisible() = #False)
  If enable = gSelfEcoThrottleActive
    ProcedureReturn
  EndIf
  If SetProcessEcoThrottle(GetCurrentProcessId_(), enable)
    gSelfEcoThrottleActive = enable
  EndIf
EndProcedure

; powercfg /L prints plan names in parentheses; this extracts the display name.
Procedure.s SchemeNameFromPowerCfgLine(line$)
  Protected p1.i = FindString(line$, "(", 1)
  Protected p2.i
  If p1
    p2 = FindString(line$, ")", p1 + 1)
    If p2 > p1
      ProcedureReturn Mid(line$, p1 + 1, p2 - p1 - 1)
    EndIf
  EndIf
  ProcedureReturn ""
EndProcedure

; Any plan create/delete/rename can invalidate both name->GUID and GUID->name.
Procedure InvalidateSchemeCache()
  gSchemeCacheValid = #False
  gCachedActiveName$ = ""
  ClearMap(gSchemeGuidByName())
  ClearMap(gSchemeNameByGuid())
EndProcedure

; Rebuild the scheme maps from powercfg /L.
Procedure RefreshSchemeCache()
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected line$
  Protected guid$
  Protected name$
  Protected i.i

  ClearMap(gSchemeGuidByName())
  ClearMap(gSchemeNameByGuid())
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = StringField(output$, i, #LF$)
    guid$ = FindGuidInText(line$)
    name$ = SchemeNameFromPowerCfgLine(line$)
    If guid$ <> "" And name$ <> ""
      gSchemeNameByGuid(guid$) = name$
      gSchemeGuidByName(LCase(name$)) = guid$
    EndIf
  Next
  gSchemeCacheValid = #True
EndProcedure

; Active plan GUID is read from powrprof when possible, then from powercfg.
Procedure.s GetActiveSchemeGuid()
  Protected guid$ = GetActiveSchemeGuidByApi()
  If guid$ = ""
    guid$ = FindGuidInText(RunPowerCfgCapture("/GETACTIVESCHEME"))
  EndIf
  ProcedureReturn guid$
EndProcedure

; Resolve a Windows plan GUID from its display name, refreshing once on miss.
Procedure.s GetSchemeGuidByName(planName$, forceRefresh.i = #False)
  Protected key$ = LCase(planName$)
  If forceRefresh Or gSchemeCacheValid = #False
    RefreshSchemeCache()
  EndIf
  If FindMapElement(gSchemeGuidByName(), key$)
    ProcedureReturn gSchemeGuidByName()
  EndIf
  If forceRefresh = #False
    RefreshSchemeCache()
    If FindMapElement(gSchemeGuidByName(), key$)
      ProcedureReturn gSchemeGuidByName()
    EndIf
  EndIf
  ProcedureReturn ""
EndProcedure

; Resolve a Windows plan name from its GUID, refreshing once on miss.
Procedure.s GetSchemeNameByGuid(schemeGuid$, forceRefresh.i = #False)
  schemeGuid$ = LCase(schemeGuid$)
  If forceRefresh Or gSchemeCacheValid = #False
    RefreshSchemeCache()
  EndIf
  If FindMapElement(gSchemeNameByGuid(), schemeGuid$)
    ProcedureReturn gSchemeNameByGuid()
  EndIf
  If forceRefresh = #False
    RefreshSchemeCache()
    If FindMapElement(gSchemeNameByGuid(), schemeGuid$)
      ProcedureReturn gSchemeNameByGuid()
    EndIf
  EndIf
  ProcedureReturn ""
EndProcedure

; Set one AC or DC power setting value through powercfg.
Procedure.i SetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  Protected mode$ = "/SETDCVALUEINDEX "
  If acMode
    mode$ = "/SETACVALUEINDEX "
  EndIf
  ProcedureReturn RunPowerCfg(mode$ + schemeGuid$ + " " + subgroup$ + " " + setting$ + " " + Str(value))
EndProcedure

; Some processor settings are not available on every CPU/firmware combination.
; Optional writes intentionally ignore the result.
Procedure TrySetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  SetSchemeValue(schemeGuid$, acMode, subgroup$, setting$, value)
EndProcedure

; Windows exposes several generation-specific maximum-frequency aliases.
Procedure SetFrequencyCaps(schemeGuid$, acMode.i, mhz.i)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX", mhz)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX1", mhz)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX2", mhz)
EndProcedure

; Windows low/reserve/critical battery settings are controlled on PowerPilot's
; managed plans. They stay separate from PowerPilot's estimate-only Empty at.
; Only DC values are written because these thresholds matter while the device is
; on battery. The user can still choose "Do nothing" for low/critical actions,
; but the warning levels are kept ordered so Windows accepts the plan values.
; Reserve uses the raw Windows GUID because the short BATLEVELRESERVE alias is
; not available on every system. If Windows protects that write for the current
; user, the installer or an elevated refresh can apply it later.
Procedure.i ConfigureBatterySleepFloor(schemeGuid$)
  Protected floor.i = ClampInt(gSettings\BatteryCriticalPercent, 1, 99)
  Protected lowWarning.i = ClampInt(gSettings\BatteryLowWarningPercent, floor + 1, 100)
  Protected reserve.i = ClampInt(gSettings\BatteryReservePercent, floor, 100)
  Protected lowAction.i = ClampInt(gSettings\BatteryLowAction, #BatteryActionDoNothing, #BatteryActionShutdown)
  Protected criticalAction.i = ClampInt(gSettings\BatteryCriticalAction, #BatteryActionDoNothing, #BatteryActionShutdown)
  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATFLAGSLOW", 1)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATLEVELLOW", lowWarning)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATACTIONLOW", lowAction)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATFLAGSCRIT", 1)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATACTIONCRIT", criticalAction)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATLEVELCRIT", floor)
  If SetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", #BatteryReserveLevelSetting$, reserve) <> 0
    LogAction("Reserve battery level needs elevated Windows permission; installer can apply it.")
  EndIf
  ProcedureReturn #True
EndProcedure

; Windows Energy Saver is a hidden power setting. Threshold 100 alone can make
; Settings show "turns on at 100%" while the always-use policy stays off, so
; PowerPilot writes both the threshold and policy values for its plans.
; In controlled mode the Battery plan uses policy=aggressive and threshold=100;
; Maximum/Balanced use a zero DC threshold so they do not unexpectedly force
; Energy Saver. In automatic mode all plans use the configured threshold.
Procedure.i ConfigureEnergySaverPolicy(planName$, schemeGuid$)
  Protected acThreshold.i = 0
  Protected dcThreshold.i = ClampInt(gSettings\EnergySaverThreshold, 0, 100)
  Protected acPolicy.i = #EnergySaverPolicyUser
  Protected dcPolicy.i = #EnergySaverPolicyUser
  Protected brightness.i = ClampInt(gSettings\EnergySaverBrightness, 0, 100)
  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf
  If gSettings\EnergySaverMode = #EnergySaverPowerPilotControlled
    If planName$ = #PlanBattery$
      acThreshold = 100
      dcThreshold = 100
      acPolicy = #EnergySaverPolicyAggressive
      dcPolicy = #EnergySaverPolicyAggressive
    Else
      dcThreshold = 0
    EndIf
  EndIf
  TrySetSchemeValue(schemeGuid$, #True, #EnergySaverSubgroup$, #EnergySaverPolicySetting$, acPolicy)
  TrySetSchemeValue(schemeGuid$, #False, #EnergySaverSubgroup$, #EnergySaverPolicySetting$, dcPolicy)
  TrySetSchemeValue(schemeGuid$, #True, #EnergySaverSubgroup$, #EnergySaverThresholdSetting$, acThreshold)
  TrySetSchemeValue(schemeGuid$, #False, #EnergySaverSubgroup$, #EnergySaverThresholdSetting$, dcThreshold)
  TrySetSchemeValue(schemeGuid$, #True, #EnergySaverSubgroup$, #EnergySaverBrightnessSetting$, brightness)
  TrySetSchemeValue(schemeGuid$, #False, #EnergySaverSubgroup$, #EnergySaverBrightnessSetting$, brightness)
  ProcedureReturn #True
EndProcedure

; Apply the non-processor Windows platform-saving knobs.
; These are intentionally profile-level choices:
; - All plans keep the Balanced personality so they remain valid on Modern
;   Standby systems, where Windows allows only Balanced-derived schemes.
; - Maximum avoids device/GPU idle bias.
; - Balanced uses low-power GPU only on DC.
; - Battery adds device idle, GPU, PCIe, standby-network, display, disk, sleep,
;   hibernate, and wake-timer savings.
; The values complement the visible processor controls without adding more UI.
Procedure.i ConfigurePlatformPowerPolicy(planName$, schemeGuid$)
  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf

  Select planName$
    Case #PlanFull$
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #PowerPlanPersonalitySetting$, #PowerPlanPersonalityBalanced)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #PowerPlanPersonalitySetting$, #PowerPlanPersonalityBalanced)
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #DeviceIdleSetting$, #DeviceIdlePerformance)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #DeviceIdleSetting$, #DeviceIdlePerformance)
      TrySetSchemeValue(schemeGuid$, #True, #GraphicsSubgroup$, #GpuPreferencePolicySetting$, #GpuPreferenceDefault)
      TrySetSchemeValue(schemeGuid$, #False, #GraphicsSubgroup$, #GpuPreferencePolicySetting$, #GpuPreferenceDefault)
      TrySetSchemeValue(schemeGuid$, #True, #PciExpressSubgroup$, #PciExpressLinkStateSetting$, #PciExpressLinkOff)
      TrySetSchemeValue(schemeGuid$, #False, #PciExpressSubgroup$, #PciExpressLinkStateSetting$, #PciExpressLinkModerate)

    Case #PlanBalanced$
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #PowerPlanPersonalitySetting$, #PowerPlanPersonalityBalanced)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #PowerPlanPersonalitySetting$, #PowerPlanPersonalityBalanced)
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #DeviceIdleSetting$, #DeviceIdlePerformance)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #DeviceIdleSetting$, #DeviceIdlePowerSavings)
      TrySetSchemeValue(schemeGuid$, #True, #GraphicsSubgroup$, #GpuPreferencePolicySetting$, #GpuPreferenceDefault)
      TrySetSchemeValue(schemeGuid$, #False, #GraphicsSubgroup$, #GpuPreferencePolicySetting$, #GpuPreferenceLowPower)
      TrySetSchemeValue(schemeGuid$, #True, #PciExpressSubgroup$, #PciExpressLinkStateSetting$, #PciExpressLinkModerate)
      TrySetSchemeValue(schemeGuid$, #False, #PciExpressSubgroup$, #PciExpressLinkStateSetting$, #PciExpressLinkMaximum)

    Case #PlanBattery$
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #PowerPlanPersonalitySetting$, #PowerPlanPersonalityBalanced)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #PowerPlanPersonalitySetting$, #PowerPlanPersonalityBalanced)
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #DeviceIdleSetting$, #DeviceIdlePowerSavings)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #DeviceIdleSetting$, #DeviceIdlePowerSavings)
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #DisconnectedStandbyModeSetting$, #DisconnectedStandbyNormal)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #DisconnectedStandbyModeSetting$, #DisconnectedStandbyAggressive)
      TrySetSchemeValue(schemeGuid$, #True, #NoSubgroup$, #ConnectivityStandbySetting$, #StandbyNetworkingManaged)
      TrySetSchemeValue(schemeGuid$, #False, #NoSubgroup$, #ConnectivityStandbySetting$, #StandbyNetworkingDisabled)
      TrySetSchemeValue(schemeGuid$, #True, #GraphicsSubgroup$, #GpuPreferencePolicySetting$, #GpuPreferenceLowPower)
      TrySetSchemeValue(schemeGuid$, #False, #GraphicsSubgroup$, #GpuPreferencePolicySetting$, #GpuPreferenceLowPower)
      TrySetSchemeValue(schemeGuid$, #True, #PciExpressSubgroup$, #PciExpressLinkStateSetting$, #PciExpressLinkMaximum)
      TrySetSchemeValue(schemeGuid$, #False, #PciExpressSubgroup$, #PciExpressLinkStateSetting$, #PciExpressLinkMaximum)
      TrySetSchemeValue(schemeGuid$, #True, #DiskSubgroup$, #DiskIdleSetting$, 0)
      TrySetSchemeValue(schemeGuid$, #False, #DiskSubgroup$, #DiskIdleSetting$, #BatteryPlanDiskDcSeconds)
      TrySetSchemeValue(schemeGuid$, #True, #DisplaySubgroup$, #DisplayIdleSetting$, #BatteryPlanDisplayAcSeconds)
      TrySetSchemeValue(schemeGuid$, #False, #DisplaySubgroup$, #DisplayIdleSetting$, #BatteryPlanDisplayDcSeconds)
      TrySetSchemeValue(schemeGuid$, #True, #SleepSubgroup$, #SleepIdleSetting$, 0)
      TrySetSchemeValue(schemeGuid$, #False, #SleepSubgroup$, #SleepIdleSetting$, #BatteryPlanSleepDcSeconds)
      TrySetSchemeValue(schemeGuid$, #True, #SleepSubgroup$, #HibernateIdleSetting$, 0)
      TrySetSchemeValue(schemeGuid$, #False, #SleepSubgroup$, #HibernateIdleSetting$, #BatteryPlanHibernateDcSeconds)
      TrySetSchemeValue(schemeGuid$, #True, #SleepSubgroup$, #WakeTimersSetting$, #WakeTimersEnabled)
      TrySetSchemeValue(schemeGuid$, #False, #SleepSubgroup$, #WakeTimersSetting$, #WakeTimersDisabled)
  EndSelect

  ProcedureReturn #True
EndProcedure

; Apply all PowerPilot-owned processor settings to one Windows scheme. The
; visible plan editor controls the headline values; this routine also sets
; hidden ramp, boost-policy, cooling, and parking values for consistency.
Procedure.i ConfigureScheme(*plan.PlanDefinition, schemeGuid$)
  Protected acMinState.i = 5
  Protected dcMinState.i = 5
  Protected acCoreParkingMin.i = 100
  Protected dcCoreParkingMin.i = 25
  Protected acCoreParkingMin1.i = 100
  Protected dcCoreParkingMin1.i = 25
  Protected acCoreParkingMin2.i = 100
  Protected dcCoreParkingMin2.i = 25

  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf

  ; Core parking differs by profile. Battery can park aggressively when deep
  ; idle saver is enabled; Maximum keeps cores awake for responsiveness.
  If *plan\Name = #PlanBattery$
    If gSettings\DeepIdleSaver
      acCoreParkingMin = 0
      dcCoreParkingMin = 0
      acCoreParkingMin1 = 0
      dcCoreParkingMin1 = 0
      acCoreParkingMin2 = 0
      dcCoreParkingMin2 = 0
    Else
      acCoreParkingMin = 50
      dcCoreParkingMin = 10
      acCoreParkingMin1 = 50
      dcCoreParkingMin1 = 10
      acCoreParkingMin2 = 50
      dcCoreParkingMin2 = 10
    EndIf
  ElseIf *plan\Name = #PlanBalanced$
    acCoreParkingMin1 = 0
    dcCoreParkingMin1 = 0
    acCoreParkingMin2 = 0
    dcCoreParkingMin2 = 0
  ElseIf *plan\Name = #PlanFull$
    acMinState = 20
    dcMinState = 10
    dcCoreParkingMin = 100
    dcCoreParkingMin1 = 100
    dcCoreParkingMin2 = 100
  EndIf

  ; AC values.
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP1", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP2", *plan\AcEpp)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\AcBoostMode)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN1", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN2", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES", acCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES1", acCoreParkingMin1)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES2", acCoreParkingMin2)
  SetFrequencyCaps(schemeGuid$, #True, *plan\AcFreqMHz)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\AcCooling)

  ; DC values.
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP1", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP2", *plan\DcEpp)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\DcBoostMode)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN1", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN2", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES", dcCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES1", dcCoreParkingMin1)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES2", dcCoreParkingMin2)
  SetFrequencyCaps(schemeGuid$, #False, *plan\DcFreqMHz)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\DcCooling)
  ConfigureBatterySleepFloor(schemeGuid$)
  ConfigureEnergySaverPolicy(*plan\Name, schemeGuid$)
  ConfigurePlatformPowerPolicy(*plan\Name, schemeGuid$)

  ; Profile-specific hidden boost/ramp tuning. These calls are optional because
  ; many firmware packages hide or omit some aliases.
  If *plan\Name = #PlanBattery$
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 80)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 80)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 20)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 20)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME", 4)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME1", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME1", 4)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTEPP", 100)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTEPP", 100)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTEPP1", 100)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTEPP1", 100)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTEPP2", 100)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTEPP2", 100)
  ElseIf *plan\Name = #PlanBalanced$
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL", 60)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL", 40)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL1", 60)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL1", 40)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 30)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 30)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 30)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 30)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME1", 1)
  ElseIf *plan\Name = #PlanFull$
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL", 100)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL", 80)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL1", 100)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL1", 80)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 20)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 20)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 5)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 5)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME", 2)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME1", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME1", 2)
  EndIf

  ProcedureReturn #True
EndProcedure

; Duplicate the selected base Windows plan, then rename it into a PowerPilot
; fixed plan. This preserves OEM hidden defaults where possible.
Procedure.s DuplicateBaseScheme(baseGuid$, planName$, description$)
  Protected output$
  Protected newGuid$
  If baseGuid$ = ""
    baseGuid$ = "SCHEME_BALANCED"
  EndIf
  output$ = RunPowerCfgCapture("/DUPLICATESCHEME " + baseGuid$)
  newGuid$ = FindGuidInText(output$)
  If newGuid$ <> ""
    RunPowerCfg("/CHANGENAME " + newGuid$ + " " + QuoteArgument(planName$) + " " + QuoteArgument(description$))
    InvalidateSchemeCache()
  EndIf
  ProcedureReturn newGuid$
EndProcedure

; Create a missing plan or refresh an existing fixed plan in place.
Procedure.i EnsurePlanInstalled(index.i, baseGuid$)
  Protected guid$ = GetSchemeGuidByName(gPlans(index)\Name)
  If guid$ = ""
    guid$ = DuplicateBaseScheme(baseGuid$, gPlans(index)\Name, gPlans(index)\Description)
  EndIf
  If guid$ = ""
    ProcedureReturn #False
  EndIf
  ProcedureReturn ConfigureScheme(@gPlans(index), guid$)
EndProcedure

; Delete only PowerPilot-owned and old prototype-owned plans.
Procedure DeleteManagedPlanCopies()
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected line$
  Protected name$
  Protected guid$
  Protected i.i

  For i = 1 To CountString(output$, #LF$) + 1
    line$ = StringField(output$, i, #LF$)
    guid$ = FindGuidInText(line$)
    name$ = SchemeNameFromPowerCfgLine(line$)
    If guid$ <> "" And IsManagedPlanName(name$)
      RunPowerCfg("/DELETE " + guid$)
    EndIf
  Next
  InvalidateSchemeCache()
EndProcedure

; Create or refresh the three fixed plans from a chosen base. During force
; rebase, switch away from any managed plan before deleting old copies.
Procedure.i CreateManagedPlansFromBase(baseGuid$, forceRebase.i = #False)
  Protected baseName$ = GetSchemeNameByGuid(baseGuid$, #True)
  Protected activeGuid$
  Protected activeName$
  Protected i.i

  If baseGuid$ = "" Or IsManagedPlanName(baseName$)
    baseGuid$ = "SCHEME_BALANCED"
  EndIf

  If forceRebase
    activeGuid$ = GetActiveSchemeGuid()
    activeName$ = GetSchemeNameByGuid(activeGuid$, #True)
    If IsManagedPlanName(activeName$)
      SetActiveSchemeByGuid(baseGuid$)
      gCachedActiveGuid$ = ""
      gCachedActiveName$ = ""
      gLastObservedActiveGuid$ = ""
    EndIf
    DeleteManagedPlanCopies()
  EndIf

  For i = 0 To 2
    If EnsurePlanInstalled(i, baseGuid$) = #False
      LogAction("Failed to create or refresh " + gPlans(i)\Name + ".")
      ProcedureReturn #False
    EndIf
  Next
  RefreshSchemeCache()
  LogAction("PowerPilot plans refreshed from the selected Windows plan.")
  ProcedureReturn #True
EndProcedure

Procedure.i CreateManagedPlans()
  ProcedureReturn CreateManagedPlansFromBase(GetActiveSchemeGuid(), #True)
EndProcedure

; Fast installer/update check: if all three plans exist, avoid recreating them.
Procedure.i ManagedPlansInstalled()
  Protected i.i
  RefreshSchemeCache()
  For i = 0 To 2
    If GetSchemeGuidByName(gPlans(i)\Name) = ""
      ProcedureReturn #False
    EndIf
  Next
  ProcedureReturn #True
EndProcedure

; Re-select the active PowerPilot plan after bulk writes. Most powercfg values
; take effect immediately, but reactivating the current scheme nudges Windows to
; reload the whole policy set and clears PowerPilot's cached active-plan state.
Procedure ReactivateActiveManagedPlanIfNeeded()
  Protected activeGuid$ = GetActiveSchemeGuid()
  Protected activeName$ = GetSchemeNameByGuid(activeGuid$, #True)
  If IsManagedPlanName(activeName$)
    SetActiveSchemeByGuid(activeGuid$)
    gCachedActiveGuid$ = ""
    gCachedActiveName$ = ""
    gLastObservedActiveGuid$ = ""
  EndIf
EndProcedure

; Reapply the full current plan definition to all existing managed plans. This
; is used by installer/update repair so new hidden settings reach already
; installed plans without forcing a destructive rebase or changing GUIDs.
Procedure.i ApplyFullPlanSettingsToManagedPlans()
  Protected i.i
  Protected guid$
  Protected changed.i
  RefreshSchemeCache()
  For i = 0 To 2
    guid$ = GetSchemeGuidByName(gPlans(i)\Name)
    If guid$ = ""
      ProcedureReturn 0
    EndIf
    If ConfigureScheme(@gPlans(i), guid$)
      changed + 1
    EndIf
  Next
  If changed > 0
    ReactivateActiveManagedPlanIfNeeded()
  EndIf
  ProcedureReturn changed
EndProcedure

; Reapply only the Windows battery sleep floor to existing managed plans. This
; keeps Min percent changes quick while avoiding a full processor-plan rewrite.
Procedure.i ApplyBatterySleepFloorToManagedPlans()
  Protected i.i
  Protected guid$
  Protected changed.i
  For i = 0 To 2
    guid$ = GetSchemeGuidByName(gPlans(i)\Name)
    If guid$ <> ""
      If ConfigureBatterySleepFloor(guid$)
        changed + 1
      EndIf
    EndIf
  Next
  ProcedureReturn changed
EndProcedure

; Reapply only Windows Energy Saver settings to existing managed plans when the
; Plans tab Energy Saver mode changes.
Procedure.i ApplyEnergySaverPolicyToManagedPlans()
  Protected i.i
  Protected guid$
  Protected changed.i
  For i = 0 To 2
    guid$ = GetSchemeGuidByName(gPlans(i)\Name)
    If guid$ <> ""
      If ConfigureEnergySaverPolicy(gPlans(i)\Name, guid$)
        changed + 1
      EndIf
    EndIf
  Next
  If changed > 0
    ReactivateActiveManagedPlanIfNeeded()
  EndIf
  ProcedureReturn changed
EndProcedure

Procedure RememberNormalPowerPlan(schemeGuid$, schemeName$)
  If schemeGuid$ = ""
    ProcedureReturn
  EndIf
  If schemeName$ = ""
    schemeName$ = GetSchemeNameByGuid(schemeGuid$, #True)
  EndIf
  If schemeName$ = "" Or IsManagedPlanName(schemeName$)
    ProcedureReturn
  EndIf
  schemeGuid$ = LCase(schemeGuid$)
  If LCase(gSettings\NormalPlanGuid) <> schemeGuid$ Or gSettings\NormalPlanName <> schemeName$
    gSettings\NormalPlanGuid = schemeGuid$
    gSettings\NormalPlanName = schemeName$
    SaveSettings()
    RefreshBatterySaverSummary()
  EndIf
EndProcedure

Procedure.s PreferredNormalPowerPlanGuid()
  Protected guid$ = LCase(gSettings\NormalPlanGuid)
  Protected name$
  If guid$ <> ""
    name$ = GetSchemeNameByGuid(guid$, #True)
    If name$ <> "" And IsManagedPlanName(name$) = #False
      ProcedureReturn guid$
    EndIf
  EndIf
  If gSettings\NormalPlanName <> ""
    guid$ = GetSchemeGuidByName(gSettings\NormalPlanName, #True)
    If guid$ <> ""
      name$ = GetSchemeNameByGuid(guid$, #True)
      If name$ <> "" And IsManagedPlanName(name$) = #False
        ProcedureReturn guid$
      EndIf
    EndIf
  EndIf
  ProcedureReturn "SCHEME_BALANCED"
EndProcedure

Procedure.i RestoreNormalPowerPlanForExit()
  Protected activeGuid$ = GetActiveSchemeGuid()
  Protected activeName$ = GetSchemeNameByGuid(activeGuid$, #True)
  Protected normalGuid$
  If gSettings\RestoreNormalPlanOnExit = #False
    ProcedureReturn #False
  EndIf
  If IsManagedPlanName(activeName$) = #False
    ProcedureReturn #False
  EndIf
  normalGuid$ = PreferredNormalPowerPlanGuid()
  If normalGuid$ <> "" And SetActiveSchemeByGuid(normalGuid$)
    gCachedActiveGuid$ = ""
    gCachedActiveName$ = ""
    gLastObservedActiveGuid$ = ""
    LogAction("Normal Windows power plan restored.")
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; Installer entry point. Persist the user's startup preference, create missing
; managed plans, and refresh the full policy on existing managed plans. The
; installer owns the actual Windows startup registration.
Procedure.i InstallRefresh()
  gSettings\AutoStartWithApp = #True
  SaveSettings()
  If ManagedPlansInstalled() = #False
    ProcedureReturn CreateManagedPlansFromBase(GetActiveSchemeGuid(), #False)
  EndIf
  If ApplyFullPlanSettingsToManagedPlans() = 3
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; Uninstall/cleanup path. If a managed plan is active, switch to Balanced before
; deleting owned plans.
Procedure.i CleanupManagedPlans()
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected line$
  Protected name$
  Protected guid$
  Protected activeGuid$ = GetActiveSchemeGuid()
  Protected active$ = GetSchemeNameByGuid(activeGuid$, #True)
  Protected i.i

  If IsManagedPlanName(active$)
    SetActiveSchemeByGuid("381b4222-f694-41f0-9685-ff5bb260df2e")
    gCachedActiveGuid$ = ""
    gCachedActiveName$ = ""
  EndIf

  For i = 1 To CountString(output$, #LF$) + 1
    line$ = StringField(output$, i, #LF$)
    guid$ = FindGuidInText(line$)
    If guid$ <> ""
      name$ = SchemeNameFromPowerCfgLine(line$)
      If IsManagedPlanName(name$)
        RunPowerCfg("/DELETE " + guid$)
      EndIf
    EndIf
  Next

  InvalidateSchemeCache()
  LogAction("Managed PowerPilot and legacy Codex plans removed.")
  ProcedureReturn #True
EndProcedure

; Activate a fixed PowerPilot plan, recreating missing managed plans if needed.
Procedure.i ActivatePlanByName(planName$)
  Protected guid$ = GetSchemeGuidByName(planName$)
  If guid$ = ""
    CreateManagedPlans()
    guid$ = GetSchemeGuidByName(planName$)
  EndIf
  If guid$ = ""
    LogAction("Plan is not installed: " + planName$)
    ProcedureReturn #False
  EndIf
  If SetActiveSchemeByGuid(guid$)
    gSettings\LastPlan = NormalizePlanName(planName$)
    SaveSettings()
    gCachedActiveGuid$ = ""
    gCachedActiveName$ = ""
    LogAction(planName$ + " activated.")
    ProcedureReturn #True
  EndIf
  LogAction("Failed to activate " + planName$ + ".")
  ProcedureReturn #False
EndProcedure

; UI helpers. PureBasic gadgets are plain child windows, so View scaling is
; handled by remembering each gadget's base rectangle and applying one scale
; factor to the child HWNDs. That keeps the source layout readable in base
; coordinates while still allowing the user to resize the whole app.
Procedure.i MainWindowVisible()
  If IsWindow(#WindowMain) = #False
    ProcedureReturn #False
  EndIf
  If gWindowPreparingForDisplay
    ProcedureReturn #True
  EndIf
  ProcedureReturn Bool(IsWindowVisible_(WindowID(#WindowMain)) <> 0)
EndProcedure

Procedure.i EnsureSingleInstance()
  gSingleInstanceMutex = CreateMutex_(0, #True, "Local\PowerPilot.SingleInstance")
  If gSingleInstanceMutex And GetLastError_() = #ERROR_ALREADY_EXISTS
    CloseHandle_(gSingleInstanceMutex)
    gSingleInstanceMutex = 0
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i BatteryGraphTabVisible()
  If MainWindowVisible() = #False Or IsGadget(#GadgetPanel) = #False
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(GetGadgetState(#GadgetPanel) = #TabBatteryGraph)
EndProcedure

Procedure.i BatteryTestTabVisible()
  If MainWindowVisible() = #False Or IsGadget(#GadgetPanel) = #False
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(GetGadgetState(#GadgetPanel) = #TabBatteryTest)
EndProcedure

Procedure SetGadgetTextIfChanged(gadget.i, text$)
  If IsGadget(gadget) And GetGadgetText(gadget) <> text$
    SetGadgetText(gadget, text$)
  EndIf
EndProcedure

; Coordinate helpers keep three concerns separate:
; - logical UI scale from the user's window size
; - Windows DPI scale reported by PureBasic/DesktopScaled*
; - drawing stroke scale for canvas content such as the battery graph
Procedure.i UiScaledCoord(value.i, scale.d)
  ProcedureReturn Round(value * scale, #PB_Round_Nearest)
EndProcedure

Procedure.i UiScaleInt(value.i)
  ProcedureReturn UiScaledCoord(value, gUiScale)
EndProcedure

Procedure.i UiDpiScaleX(value.i)
  ProcedureReturn DesktopScaledX(UiScaleInt(value))
EndProcedure

Procedure.i UiDpiScaleY(value.i)
  ProcedureReturn DesktopScaledY(UiScaleInt(value))
EndProcedure

Procedure.d UiDpiStrokeScale()
  ProcedureReturn gUiScale * ((DesktopResolutionX() + DesktopResolutionY()) / 2.0)
EndProcedure

Procedure.d ClampUiScale(scale.d)
  If scale < #MainWindowMinScale : scale = #MainWindowMinScale : EndIf
  If scale > #MainWindowMaxScale : scale = #MainWindowMaxScale : EndIf
  ProcedureReturn scale
EndProcedure

Procedure EnsureUiFonts(fontSize.i = #UiFontBaseSize)
  Protected newUi.i
  Protected newBold.i
  Protected oldUi.i
  Protected oldBold.i
  fontSize = ClampInt(fontSize, #UiFontMinSize, #UiFontMaxSize)
  If gUiFontSize <> fontSize Or gFontUi = 0 Or gFontBold = 0
    newUi = LoadFont(#PB_Any, "Segoe UI", fontSize)
    newBold = LoadFont(#PB_Any, "Segoe UI", fontSize, #PB_Font_Bold)
    If newUi And newBold
      oldUi = gFontUi
      oldBold = gFontBold
      gFontUi = newUi
      gFontBold = newBold
      gUiFontSize = fontSize
      If oldUi : FreeFont(oldUi) : EndIf
      If oldBold : FreeFont(oldBold) : EndIf
    Else
      If newUi : FreeFont(newUi) : EndIf
      If newBold : FreeFont(newBold) : EndIf
    EndIf
  EndIf
  If gFontUi
    SetGadgetFont(#PB_Default, FontID(gFontUi))
  EndIf
EndProcedure

; Bold gadgets are tracked separately because changing the View scale reloads
; the shared Segoe UI fonts. PureBasic does not remember which gadgets were
; manually bolded after the default font changes, so this list reapplies them.
Procedure UseBoldFont(gadget.i)
  If IsGadget(gadget) And gFontBold
    SetGadgetFont(gadget, FontID(gFontBold))
    ForEach gUiBoldHwnds()
      If gUiBoldHwnds() = GadgetID(gadget)
        ProcedureReturn
      EndIf
    Next
    AddElement(gUiBoldHwnds())
    gUiBoldHwnds() = GadgetID(gadget)
  EndIf
EndProcedure

Procedure ApplyUiFontsToLayout()
  If gFontUi = 0
    ProcedureReturn
  EndIf
  ForEach gUiLayout()
    If IsWindow_(gUiLayout()\Hwnd)
      SendMessage_(gUiLayout()\Hwnd, #WM_SETFONT, FontID(gFontUi), #True)
    EndIf
  Next
  If gFontBold
    ForEach gUiBoldHwnds()
      If IsWindow_(gUiBoldHwnds())
        SendMessage_(gUiBoldHwnds(), #WM_SETFONT, FontID(gFontBold), #True)
      EndIf
    Next
  EndIf
EndProcedure

Procedure.i StoreUiChildLayoutCallback(hwnd.i, lParam.i)
  Protected rc.RECT
  Protected pt.POINT
  Protected parent.i = GetParent_(hwnd)
  If parent = 0
    ProcedureReturn #True
  EndIf
  If GetWindowRect_(hwnd, @rc)
    pt\x = rc\left
    pt\y = rc\top
    ScreenToClient_(parent, @pt)
    AddElement(gUiLayout())
    gUiLayout()\Hwnd = hwnd
    gUiLayout()\Parent = parent
    gUiLayout()\X = pt\x
    gUiLayout()\Y = pt\y
    gUiLayout()\Width = rc\right - rc\left
    gUiLayout()\Height = rc\bottom - rc\top
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure StoreUiBaseLayout()
  Protected rc.RECT
  ClearList(gUiLayout())
  If IsWindow(#WindowMain)
    If GetClientRect_(WindowID(#WindowMain), @rc)
      gUiBaseClientWidth = rc\right - rc\left
      gUiBaseClientHeight = rc\bottom - rc\top
    Else
      gUiBaseClientWidth = DesktopScaledX(#MainWindowBaseWidth)
      gUiBaseClientHeight = DesktopScaledY(#MainWindowBaseHeight)
    EndIf
    EnumChildWindows_(WindowID(#WindowMain), @StoreUiChildLayoutCallback(), 0)
  EndIf
EndProcedure

Procedure ApplyPlanListColumnWidths()
  Protected listWidth.i
  Protected planWidth.i
  Protected installedWidth.i
  Protected purposeWidth.i
  If IsGadget(#GadgetPlanList) = #False
    ProcedureReturn
  EndIf
  ; The Purpose text is the useful part of this list, so it receives all spare
  ; width after the fixed Plan and Installed columns are sized for their labels.
  listWidth = GadgetWidth(#GadgetPlanList)
  planWidth = UiScaledCoord(176, gUiScale)
  installedWidth = UiScaledCoord(78, gUiScale)
  purposeWidth = listWidth - planWidth - installedWidth - UiScaledCoord(12, gUiScale)
  If purposeWidth < UiScaledCoord(260, gUiScale)
    purposeWidth = UiScaledCoord(260, gUiScale)
  EndIf
  SetGadgetItemAttribute(#GadgetPlanList, #PB_Ignore, #PB_ListIcon_ColumnWidth, planWidth, 0)
  SetGadgetItemAttribute(#GadgetPlanList, #PB_Ignore, #PB_ListIcon_ColumnWidth, installedWidth, 1)
  SetGadgetItemAttribute(#GadgetPlanList, #PB_Ignore, #PB_ListIcon_ColumnWidth, purposeWidth, 2)
EndProcedure

Procedure ApplyMainWindowLayoutScale()
  Protected rc.RECT
  Protected width.i
  Protected height.i
  Protected scaleX.d
  Protected scaleY.d
  Protected fontScale.d
  Protected fontSize.i
  If IsWindow(#WindowMain) = #False Or ListSize(gUiLayout()) = 0
    ProcedureReturn
  EndIf
  If IsIconic_(WindowID(#WindowMain))
    ProcedureReturn
  EndIf
  If GetClientRect_(WindowID(#WindowMain), @rc)
    width = rc\right - rc\left
    height = rc\bottom - rc\top
  Else
    width = DesktopScaledX(WindowWidth(#WindowMain))
    height = DesktopScaledY(WindowHeight(#WindowMain))
  EndIf
  If width <= 0 Or height <= 0
    ProcedureReturn
  EndIf
  If gUiBaseClientWidth <= 0 : gUiBaseClientWidth = DesktopScaledX(#MainWindowBaseWidth) : EndIf
  If gUiBaseClientHeight <= 0 : gUiBaseClientHeight = DesktopScaledY(#MainWindowBaseHeight) : EndIf
  scaleX = ClampUiScale(width / gUiBaseClientWidth)
  scaleY = ClampUiScale(height / gUiBaseClientHeight)
  fontScale = scaleX
  If scaleY < fontScale : fontScale = scaleY : EndIf
  gUiScale = fontScale
  fontSize = ClampInt(Round(#UiFontBaseSize * fontScale, #PB_Round_Nearest), #UiFontMinSize, #UiFontMaxSize)
  EnsureUiFonts(fontSize)
  ForEach gUiLayout()
    If IsWindow_(gUiLayout()\Hwnd)
      SetWindowPos_(gUiLayout()\Hwnd, 0, UiScaledCoord(gUiLayout()\X, scaleX), UiScaledCoord(gUiLayout()\Y, scaleY), UiScaledCoord(gUiLayout()\Width, scaleX), UiScaledCoord(gUiLayout()\Height, scaleY), #SWP_NOZORDER | #SWP_NOACTIVATE)
    EndIf
  Next
  ApplyUiFontsToLayout()
  ApplyPlanListColumnWidths()
  If IsGadget(#GadgetBatteryGraph)
    DrawBatteryGraph()
  EndIf
EndProcedure

; Minimal x64 CPUID wrapper. RBX is preserved because it is nonvolatile on
; Windows x64 and PureBasic expects it to survive inline assembly blocks.
Procedure Cpuid(leaf.i, subleaf.i, *regs.CpuidRegs)
  Protected eax.q
  Protected ebx.q
  Protected ecx.q
  Protected edx.q
  Protected saveRbx.q

  !MOV [p.v_saveRbx], rbx
  !MOV eax, [p.v_leaf]
  !MOV ecx, [p.v_subleaf]
  !CPUID
  !MOV [p.v_eax], rax
  !MOV [p.v_ebx], rbx
  !MOV [p.v_ecx], rcx
  !MOV [p.v_edx], rdx
  !MOV rbx, [p.v_saveRbx]

  *regs\Eax = eax & $FFFFFFFF
  *regs\Ebx = ebx & $FFFFFFFF
  *regs\Ecx = ecx & $FFFFFFFF
  *regs\Edx = edx & $FFFFFFFF
EndProcedure

; XCR0 tells us whether the OS has enabled AVX/AVX-512 register state.
Procedure.q XGetBv0()
  Protected value.q
  !XOR rcx, rcx
  !XGETBV
  !MOV [p.v_value], rax
  ProcedureReturn value
EndProcedure

Procedure.i HasBit(value.q, bit.i)
  Protected mask.q = 1
  mask << bit
  ProcedureReturn Bool((value & mask) <> 0)
EndProcedure

; CPUID leaf 0 vendor string.
Procedure.s CpuVendor()
  Protected regs.CpuidRegs
  Protected *buf = AllocateMemory(13)
  Protected vendor$
  Cpuid(0, 0, @regs)
  If *buf
    PokeL(*buf + 0, regs\Ebx)
    PokeL(*buf + 4, regs\Edx)
    PokeL(*buf + 8, regs\Ecx)
    PokeB(*buf + 12, 0)
    vendor$ = PeekS(*buf, -1, #PB_Ascii)
    FreeMemory(*buf)
  EndIf
  ProcedureReturn vendor$
EndProcedure

; CPUID extended brand string.
Procedure.s CpuBrand()
  Protected maxExt.q
  Protected regs.CpuidRegs
  Protected *buf = AllocateMemory(49)
  Protected brand$
  Protected leaf.i
  Cpuid($80000000, 0, @regs)
  maxExt = regs\Eax
  If maxExt >= $80000004 And *buf
    For leaf = $80000002 To $80000004
      Cpuid(leaf, 0, @regs)
      PokeL(*buf + ((leaf - $80000002) * 16) + 0, regs\Eax)
      PokeL(*buf + ((leaf - $80000002) * 16) + 4, regs\Ebx)
      PokeL(*buf + ((leaf - $80000002) * 16) + 8, regs\Ecx)
      PokeL(*buf + ((leaf - $80000002) * 16) + 12, regs\Edx)
    Next
    PokeB(*buf + 48, 0)
    brand$ = Trim(PeekS(*buf, -1, #PB_Ascii))
    FreeMemory(*buf)
  EndIf
  If brand$ = ""
    brand$ = "Unknown CPU"
  EndIf
  ProcedureReturn brand$
EndProcedure

; Decode family/model/stepping using Intel/AMD CPUID rules.
Procedure.s CpuFamilyModelText()
  Protected regs.CpuidRegs
  Protected stepping.i
  Protected baseModel.i
  Protected baseFamily.i
  Protected extModel.i
  Protected extFamily.i
  Protected family.i
  Protected model.i
  Cpuid(1, 0, @regs)
  stepping = regs\Eax & $F
  baseModel = (regs\Eax >> 4) & $F
  baseFamily = (regs\Eax >> 8) & $F
  extModel = (regs\Eax >> 16) & $F
  extFamily = (regs\Eax >> 20) & $FF
  family = baseFamily
  If baseFamily = $F
    family + extFamily
  EndIf
  model = baseModel
  If baseFamily = $6 Or baseFamily = $F
    model + (extModel << 4)
  EndIf
  ProcedureReturn "Family " + Str(family) + ", model " + Str(model) + ", stepping " + Str(stepping)
EndProcedure

; Prefer modern topology leaves; fall back to AMD extended core count and then
; PureBasic's logical processor count.
Procedure.s CpuTopologyText()
  Protected regs.CpuidRegs
  Protected maxBasic.q
  Protected maxExt.q
  Protected leaf.i
  Protected level.i
  Protected domainType.i
  Protected smtLogical.i = 0
  Protected packageLogical.i = 0
  Protected cores.i = 0
  Protected logical.i = CountCPUs()

  Cpuid(0, 0, @regs)
  maxBasic = regs\Eax
  If maxBasic >= $1F
    leaf = $1F
  ElseIf maxBasic >= $0B
    leaf = $0B
  EndIf

  If leaf
    For level = 0 To 7
      Cpuid(leaf, level, @regs)
      If regs\Ebx = 0
        Break
      EndIf
      domainType = (regs\Ecx >> 8) & $FF
      If domainType = 1
        smtLogical = regs\Ebx & $FFFF
      ElseIf domainType = 2
        packageLogical = regs\Ebx & $FFFF
      EndIf
    Next
    If smtLogical > 0 And packageLogical >= smtLogical
      cores = packageLogical / smtLogical
    EndIf
  EndIf

  If cores = 0
    Cpuid($80000000, 0, @regs)
    maxExt = regs\Eax
    If maxExt >= $80000008
      Cpuid($80000008, 0, @regs)
      cores = (regs\Ecx & $FF) + 1
    EndIf
  EndIf

  If cores > 0
    ProcedureReturn Str(cores) + " cores / " + Str(logical) + " logical processors"
  EndIf
  ProcedureReturn Str(logical) + " logical processors"
EndProcedure

Procedure.s AddFeature(text$, label$)
  If text$ <> ""
    text$ + ", "
  EndIf
  ProcedureReturn text$ + label$
EndProcedure

; Build a compact feature summary. AVX/AVX-512 are reported only when both CPU
; support and OS xstate support are present.
Procedure.s CpuFeatureText()
  Protected r1.CpuidRegs
  Protected r7.CpuidRegs
  Protected re.CpuidRegs
  Protected maxBasic.q
  Protected maxExt.q
  Protected xcr0.q
  Protected features$
  Protected avxUsable.i
  Protected avx512Usable.i
  Protected bmi1.i
  Protected bmi2.i

  Cpuid(0, 0, @r7)
  maxBasic = r7\Eax
  Cpuid(1, 0, @r1)
  If HasBit(r1\Ecx, 27)
    xcr0 = XGetBv0()
    avxUsable = Bool((xcr0 & $6) = $6)
    avx512Usable = Bool((xcr0 & $E6) = $E6)
  EndIf

  If HasBit(r1\Ecx, 20)
    features$ = AddFeature(features$, "SSE-SSE4.2")
  Else
    If HasBit(r1\Edx, 25) : features$ = AddFeature(features$, "SSE") : EndIf
    If HasBit(r1\Edx, 26) : features$ = AddFeature(features$, "SSE2") : EndIf
    If HasBit(r1\Ecx, 0) : features$ = AddFeature(features$, "SSE3") : EndIf
    If HasBit(r1\Ecx, 9) : features$ = AddFeature(features$, "SSSE3") : EndIf
    If HasBit(r1\Ecx, 19) : features$ = AddFeature(features$, "SSE4.1") : EndIf
  EndIf
  If HasBit(r1\Ecx, 25) : features$ = AddFeature(features$, "AES") : EndIf
  If HasBit(r1\Ecx, 12) : features$ = AddFeature(features$, "FMA") : EndIf
  If HasBit(r1\Ecx, 23) : features$ = AddFeature(features$, "POPCNT") : EndIf
  If HasBit(r1\Ecx, 28) And avxUsable : features$ = AddFeature(features$, "AVX") : EndIf

  If maxBasic >= 7
    Cpuid(7, 0, @r7)
    bmi1 = HasBit(r7\Ebx, 3)
    bmi2 = HasBit(r7\Ebx, 8)
    If bmi1 And bmi2
      features$ = AddFeature(features$, "BMI1/2")
    ElseIf bmi1
      features$ = AddFeature(features$, "BMI1")
    ElseIf bmi2
      features$ = AddFeature(features$, "BMI2")
    EndIf
    If HasBit(r7\Ebx, 5) And avxUsable : features$ = AddFeature(features$, "AVX2") : EndIf
    If HasBit(r7\Ebx, 18) : features$ = AddFeature(features$, "RDSEED") : EndIf
    If HasBit(r7\Ebx, 29) : features$ = AddFeature(features$, "SHA") : EndIf
    If HasBit(r7\Ebx, 16) And avx512Usable : features$ = AddFeature(features$, "AVX-512F") : EndIf
    If HasBit(r7\Ecx, 5) : features$ = AddFeature(features$, "WAITPKG") : EndIf
  EndIf

  Cpuid($80000000, 0, @re)
  maxExt = re\Eax
  If maxExt >= $80000001
    Cpuid($80000001, 0, @re)
    If HasBit(re\Edx, 29) : features$ = AddFeature(features$, "x64") : EndIf
    If HasBit(re\Edx, 27) : features$ = AddFeature(features$, "RDTSCP") : EndIf
    If HasBit(re\Edx, 26) : features$ = AddFeature(features$, "1GB pg") : EndIf
    If HasBit(re\Ecx, 2) : features$ = AddFeature(features$, "SVM") : EndIf
  EndIf
  If HasBit(r1\Ecx, 5) : features$ = AddFeature(features$, "VMX") : EndIf
  If features$ = "" : features$ = "No CPUID feature summary available" : EndIf
  ProcedureReturn features$
EndProcedure

Procedure.s FormatBytes(bytes.q)
  Protected gb.d = bytes / 1073741824.0
  If gb >= 1.0
    ProcedureReturn StrD(gb, 1) + " GB"
  EndIf
  ProcedureReturn Str(bytes) + " bytes"
EndProcedure

Procedure.s SystemMemoryText()
  Protected memory.MEMORYSTATUSEX
  memory\dwLength = SizeOf(MEMORYSTATUSEX)
  If GlobalMemoryStatusEx_(@memory)
    ProcedureReturn FormatBytes(memory\ullTotalPhys) + " RAM"
  EndIf
  ProcedureReturn "RAM unavailable"
EndProcedure

Procedure.s FormatCacheSize(bytes.q)
  If bytes >= 1048576
    ProcedureReturn StrD(bytes / 1048576.0, 1) + " MB"
  EndIf
  ProcedureReturn Str(bytes / 1024) + " KB"
EndProcedure

; Deterministic cache parameters are available through leaf 4 on Intel and
; 8000001D on many AMD CPUs.
Procedure.s CpuCacheText()
  Protected regs.CpuidRegs
  Protected maxBasic.q
  Protected maxExt.q
  Protected vendor$ = CpuVendor()
  Protected leaf.i
  Protected sub.i
  Protected cacheType.i
  Protected level.i
  Protected lineSize.q
  Protected partitions.q
  Protected ways.q
  Protected sets.q
  Protected size.q
  Protected text$

  Cpuid(0, 0, @regs)
  maxBasic = regs\Eax
  Cpuid($80000000, 0, @regs)
  maxExt = regs\Eax

  If FindString(vendor$, "AuthenticAMD", 1) And maxExt >= $8000001D
    leaf = $8000001D
  ElseIf maxBasic >= 4
    leaf = 4
  EndIf
  If leaf = 0
    ProcedureReturn "Cache details unavailable"
  EndIf

  For sub = 0 To 15
    Cpuid(leaf, sub, @regs)
    cacheType = regs\Eax & $1F
    If cacheType = 0
      Break
    EndIf
    level = (regs\Eax >> 5) & $7
    lineSize = (regs\Ebx & $FFF) + 1
    partitions = ((regs\Ebx >> 12) & $3FF) + 1
    ways = ((regs\Ebx >> 22) & $3FF) + 1
    sets = regs\Ecx + 1
    size = lineSize * partitions * ways * sets
    If text$ <> "" : text$ + ", " : EndIf
    text$ + "L" + Str(level) + " " + FormatCacheSize(size)
  Next

  If text$ = "" : text$ = "Cache details unavailable" : EndIf
  ProcedureReturn text$
EndProcedure

; Compose the multi-line CPU/Memory text shown on the Overview tab.
Procedure.s BuildCpuInfo()
  Protected text$
  text$ = CpuBrand()
  text$ + #LF$ + CpuVendor() + " | " + CpuFamilyModelText()
  text$ + #LF$ + CpuTopologyText()
  text$ + #LF$ + "Cache: " + CpuCacheText() + " | " + SystemMemoryText()
  text$ + #LF$ + "Features: " + CpuFeatureText()
  ProcedureReturn text$
EndProcedure

; Normalize CPU names so GPU inference can match model families reliably.
Procedure.s BuildCpuMatchText(cpuName$)
  Protected cleaned$ = LCase(Trim(cpuName$))
  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, "-", " ")
  cleaned$ = ReplaceString(cleaned$, "/", " ")
  cleaned$ = ReplaceString(cleaned$, ",", " ")
  cleaned$ = ReplaceString(cleaned$, "(", " ")
  cleaned$ = ReplaceString(cleaned$, ")", " ")
  cleaned$ = ReplaceString(cleaned$, "[", " ")
  cleaned$ = ReplaceString(cleaned$, "]", " ")
  cleaned$ = ReplaceString(cleaned$, "+", " ")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend
  ProcedureReturn " " + Trim(cleaned$) + " "
EndProcedure

; Match a normalized CPU token string against a comma-separated pattern list.
Procedure.i CpuMatchAny(cpuMatchText$, patternList$)
  Protected itemCount.i = CountString(patternList$, ",") + 1
  Protected i.i
  Protected pattern$
  For i = 1 To itemCount
    pattern$ = Trim(StringField(patternList$, i, ","))
    If pattern$ <> "" And FindString(cpuMatchText$, " " + LCase(pattern$) + " ", 1)
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; Windows often reports AMD iGPUs generically. If so, infer a more useful CU
; count from the CPU family below.
Procedure.i IsGenericAmdIntegratedGpuName(hardwareName$)
  Protected lowered$ = LCase(Trim(hardwareName$))
  ProcedureReturn Bool(lowered$ = "amd radeon graphics" Or lowered$ = "radeon graphics" Or lowered$ = "amd radeon(tm) graphics" Or lowered$ = "radeon(tm) graphics")
EndProcedure

; Generic AMD Radeon Graphics plus CU count fallback.
Procedure.s ResolveAmdGraphicsCuName(cuCount.i)
  If cuCount <= 0
    ProcedureReturn "AMD Radeon Graphics"
  EndIf
  ProcedureReturn "AMD Radeon Graphics (" + Str(cuCount) + " CUs)"
EndProcedure

; CPU-family lookup table for AMD integrated GPU marketing names. This is only
; used when Windows reports a generic "AMD Radeon Graphics" display name.
Procedure.s ResolveAmdIntegratedGpuName(cpuName$)
  Protected cpuMatchText$ = BuildCpuMatchText(cpuName$)
  If cpuMatchText$ = "" Or FindString(cpuMatchText$, " amd ", 1) = 0
    ProcedureReturn ""
  EndIf

  If CpuMatchAny(cpuMatchText$, "ryzen ai 9 hx 370,ryzen ai 9 hx pro 370,ryzen ai 9 hx 375,ryzen ai 9 hx pro 375")
    ProcedureReturn "AMD Radeon 890M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai 9 365,ryzen ai 7 360,ryzen ai 7 pro 360")
    ProcedureReturn "AMD Radeon 880M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai 7 350,ryzen ai 7 pro 350")
    ProcedureReturn "AMD Radeon 860M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai 5 340,ryzen ai 5 pro 340")
    ProcedureReturn "AMD Radeon 840M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai max 395,ryzen ai max pro 395")
    ProcedureReturn "AMD Radeon 8060S Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai max 390,ryzen ai max 385,ryzen ai max pro 390,ryzen ai max pro 385")
    ProcedureReturn "AMD Radeon 8050S Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai max pro 380")
    ProcedureReturn "AMD Radeon 8040S Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen z1 extreme,7840u,7840hs,7940hs,8700g,8700ge,8945hs,8840u,8840hs,8845hs")
    ProcedureReturn "AMD Radeon 780M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "7640u,7640hs,8600g,8600ge,8540u,8540hs,8640u,8640hs")
    ProcedureReturn "AMD Radeon 760M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen z1,7440u,7440hs,7540u,7540hs,8300g,8305g,8440u,8440hs,8500g")
    ProcedureReturn "AMD Radeon 740M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "7120u,7220u,7320u,7520u")
    ProcedureReturn "AMD Radeon 610M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "6600u,6600h,6600hs,6650u,6650h,6650hs,7335u,7535u,7535hs")
    ProcedureReturn "AMD Radeon 660M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "6800u,6800h,6800hs,6850u,6850h,6850hs,6860z,6900hs,6900hx,6980hs,6980hx,7735u,7735hs,7736u")
    ProcedureReturn "AMD Radeon 680M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2200g,2500u,3200g,3500u,3550h")
    ProcedureReturn "AMD Radeon Vega 8 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2300u")
    ProcedureReturn "AMD Radeon Vega 6 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "3200u,3250u,300u")
    ProcedureReturn "AMD Radeon Vega 3 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2400g,3400g")
    ProcedureReturn "AMD Radeon RX Vega 11 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2700u,3700u,3750h")
    ProcedureReturn "AMD Radeon RX Vega 10 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "4300u,4450u")
    ProcedureReturn ResolveAmdGraphicsCuName(5)
  EndIf
  If CpuMatchAny(cpuMatchText$, "4350g,4350ge,4500u,4600u,4600h,4600hs,4650u,5300u,5355g,5355ge,5400u,7330u")
    ProcedureReturn ResolveAmdGraphicsCuName(6)
  EndIf
  If CpuMatchAny(cpuMatchText$, "4650g,4700u,4700h,4700hs,4750u,5500u,5500h,5600u,5600h,5600hs,5600g,5625u,5650u,7430u,7530u")
    ProcedureReturn ResolveAmdGraphicsCuName(7)
  EndIf
  If CpuMatchAny(cpuMatchText$, "4750g,4750ge,4800u,4800h,4800hs,4900h,4900hs,5700u,5700g,5800u,5800h,5800hs,5825u,5850u,5875u,5900hs,5900hx,5980hs,5980hx,7730u")
    ProcedureReturn ResolveAmdGraphicsCuName(8)
  EndIf
  ProcedureReturn ""
EndProcedure

; Intel Windows adapter names can be generic ("Intel Graphics" or
; "Intel Arc Graphics"). When the CPU brand gives a safe SKU hint, replace that
; generic text with the actual integrated GPU marketing name.
Procedure.i IsGenericIntelIntegratedGpuName(hardwareName$)
  Protected lowered$ = LCase(Trim(hardwareName$))
  ProcedureReturn Bool(lowered$ = "intel graphics" Or lowered$ = "intel arc graphics" Or lowered$ = "intel uhd graphics" Or lowered$ = "intel hd graphics")
EndProcedure

Procedure.s ResolveIntelIntegratedGpuName(cpuName$)
  Protected cpuMatchText$ = BuildCpuMatchText(cpuName$)
  If cpuMatchText$ = "" Or FindString(cpuMatchText$, " intel ", 1) = 0
    ProcedureReturn ""
  EndIf

  ; Core Ultra Series 2 "V" laptop processors, formerly Lunar Lake.
  If CpuMatchAny(cpuMatchText$, "ultra 9 288v,ultra 7 268v,ultra 7 266v,ultra 7 258v,ultra 7 256v")
    ProcedureReturn "Intel Arc 140V GPU"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ultra 5 238v,ultra 5 236v,ultra 5 228v,ultra 5 226v")
    ProcedureReturn "Intel Arc 130V GPU"
  EndIf

  ; Core Ultra Series 2 H laptop processors expose named 140T/130T iGPUs.
  If CpuMatchAny(cpuMatchText$, "ultra 9 285h,ultra 7 265h,ultra 7 255h")
    ProcedureReturn "Intel Arc 140T GPU"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ultra 5 235h,ultra 5 225h")
    ProcedureReturn "Intel Arc 130T GPU"
  EndIf

  ; Core Ultra Series 1 H laptop processors use built-in Intel Arc Graphics.
  If CpuMatchAny(cpuMatchText$, "ultra 9 185h,ultra 7 165h,ultra 7 155h,ultra 5 135h,ultra 5 125h")
    ProcedureReturn "Intel Arc Graphics"
  EndIf

  ; Recent mobile Core i5/i7/i9 parts often report generic graphics names. Use
  ; Intel's official "eligible" wording where the exact branding depends on SKU
  ; and memory configuration.
  If CpuMatchAny(cpuMatchText$, "13th gen intel core i9,13th gen intel core i7,13th gen intel core i5,12th gen intel core i9,12th gen intel core i7,12th gen intel core i5,11th gen intel core i7,11th gen intel core i5")
    ProcedureReturn "Intel Iris Xe Graphics eligible"
  EndIf
  If CpuMatchAny(cpuMatchText$, "14th gen intel core")
    ProcedureReturn "Intel UHD Graphics for 14th Gen Intel Processors"
  EndIf
  If CpuMatchAny(cpuMatchText$, "13th gen intel core i3,12th gen intel core i3")
    ProcedureReturn "Intel UHD Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "11th gen intel core i3")
    ProcedureReturn "Intel UHD Graphics for 11th Gen Intel Processors"
  EndIf
  ProcedureReturn ""
EndProcedure

Procedure.s CpuInferredIntegratedGpuName()
  Protected resolved$ = ResolveAmdIntegratedGpuName(CpuBrand())
  If resolved$ = ""
    resolved$ = ResolveIntelIntegratedGpuName(CpuBrand())
  EndIf
  ProcedureReturn resolved$
EndProcedure

; Clean Windows display adapter names and replace generic integrated GPU names
; when a CPU-family inference is available.
Procedure.s NormalizeGpuHardwareName(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected resolved$
  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, #CR$, " ")
  cleaned$ = ReplaceString(cleaned$, #LF$, " ")
  cleaned$ = ReplaceString(cleaned$, "(TM)", "")
  cleaned$ = ReplaceString(cleaned$, "(R)", "")
  cleaned$ = ReplaceString(cleaned$, "Microsoft Corporation ", "")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  If IsGenericAmdIntegratedGpuName(cleaned$)
    resolved$ = CpuInferredIntegratedGpuName()
    If resolved$ <> ""
      cleaned$ = resolved$
    EndIf
  ElseIf IsGenericIntelIntegratedGpuName(cleaned$)
    resolved$ = CpuInferredIntegratedGpuName()
    If resolved$ <> ""
      cleaned$ = resolved$
    EndIf
  EndIf
  ProcedureReturn Trim(cleaned$)
EndProcedure

; Used to annotate likely integrated GPUs in the Overview tab.
Procedure.i IsLikelyIntegratedGpuName(name$)
  Protected lower$ = LCase(name$)
  If FindString(lower$, "iris xe max", 1)
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(FindString(lower$, "radeon 680m", 1) Or FindString(lower$, "radeon 660m", 1) Or FindString(lower$, "radeon 610m", 1) Or FindString(lower$, "radeon 740m", 1) Or FindString(lower$, "radeon 760m", 1) Or FindString(lower$, "radeon 780m", 1) Or FindString(lower$, "radeon 840m", 1) Or FindString(lower$, "radeon 860m", 1) Or FindString(lower$, "radeon 880m", 1) Or FindString(lower$, "radeon 890m", 1) Or FindString(lower$, "vega", 1) Or FindString(lower$, "uhd", 1) Or FindString(lower$, "iris", 1) Or FindString(lower$, "xe graphics", 1) Or FindString(lower$, "intel graphics", 1) Or FindString(lower$, "intel arc graphics", 1) Or FindString(lower$, "arc 130v", 1) Or FindString(lower$, "arc 140v", 1) Or FindString(lower$, "arc 130t", 1) Or FindString(lower$, "arc 140t", 1) Or FindString(lower$, "arc b370", 1) Or FindString(lower$, "arc b390", 1))
EndProcedure

; Used to annotate common separate laptop/desktop GPUs without changing the
; Windows active/primary connection flags collected by BuildGpuInfo().
Procedure.i IsLikelyDiscreteGpuName(name$, vendor$ = "")
  Protected lower$ = LCase(name$)
  Protected lowerVendor$ = LCase(vendor$)

  If IsLikelyIntegratedGpuName(name$)
    ProcedureReturn #False
  EndIf
  If lowerVendor$ = "nvidia" Or FindString(lower$, "nvidia", 1) Or FindString(lower$, "geforce", 1) Or FindString(lower$, "quadro", 1)
    ProcedureReturn #True
  EndIf
  If FindString(lower$, "radeon rx", 1) Or FindString(lower$, "radeon pro", 1)
    ProcedureReturn #True
  EndIf
  If FindString(lower$, "intel arc a", 1) Or FindString(lower$, "intel arc pro", 1) Or FindString(lower$, "iris xe max", 1)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; Vendor decoding from PCI vendor id fragments exposed by DISPLAY_DEVICE.
Procedure.s VendorNameFromPciId(id$)
  Protected upper$ = UCase(id$)
  If FindString(upper$, "VEN_1002", 1) Or FindString(upper$, "VEN_1022", 1)
    ProcedureReturn "AMD"
  EndIf
  If FindString(upper$, "VEN_10DE", 1)
    ProcedureReturn "NVIDIA"
  EndIf
  If FindString(upper$, "VEN_8086", 1)
    ProcedureReturn "Intel"
  EndIf
  ProcedureReturn "Unknown vendor"
EndProcedure

; Keep only VEN_xxxx and DEV_xxxx so GPU rows stay compact.
Procedure.s PciSummary(id$)
  Protected upper$ = UCase(id$)
  Protected ven.i = FindString(upper$, "VEN_", 1)
  Protected dev.i = FindString(upper$, "DEV_", 1)
  Protected text$
  If ven
    text$ = Mid(upper$, ven, 8)
  EndIf
  If dev
    If text$ <> "" : text$ + " " : EndIf
    text$ + Mid(upper$, dev, 8)
  EndIf
  ProcedureReturn text$
EndProcedure

; Filter out virtual/basic display adapters that add noise for users.
Procedure.i IsUsefulGpuName(name$)
  Protected lower$ = LCase(name$)
  If Trim(name$) = "" : ProcedureReturn #False : EndIf
  If FindString(lower$, "mirage", 1) : ProcedureReturn #False : EndIf
  If FindString(lower$, "remote display", 1) : ProcedureReturn #False : EndIf
  If FindString(lower$, "basic render", 1) : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

; Enumerate Windows display adapters, normalize names, deduplicate, and include
; PCI/vendor/active/primary details where exposed.
Procedure.s BuildGpuInfo()
  Protected dd.DISPLAY_DEVICE
  Protected index.i
  Protected rawName$
  Protected name$
  Protected id$
  Protected pci$
  Protected vendor$
  Protected flags$
  Protected line$
  Protected key$
  Protected text$
  Protected isIntegrated.i
  Protected foundIntegrated.i
  Protected inferredName$
  NewMap seenGpu.i()

  Repeat
    FillMemory(@dd, SizeOf(DISPLAY_DEVICE), 0)
    dd\cb = SizeOf(DISPLAY_DEVICE)
    If EnumDisplayDevices_(0, index, @dd, #EDD_GET_DEVICE_INTERFACE_NAME) = 0
      Break
    EndIf
    rawName$ = Trim(PeekS(@dd\DeviceString[0]))
    name$ = NormalizeGpuHardwareName(rawName$)
    id$ = Trim(PeekS(@dd\DeviceID[0]))
    key$ = LCase(name$)
    If IsUsefulGpuName(name$) And FindMapElement(seenGpu(), key$) = #False
      seenGpu(key$) = #True
      vendor$ = VendorNameFromPciId(id$)
      pci$ = PciSummary(id$)
      flags$ = ""
      If dd\StateFlags & 1 : flags$ = "active" : EndIf
      If dd\StateFlags & 4
        If flags$ <> "" : flags$ + ", " : EndIf
        flags$ + "primary"
      EndIf
      line$ = name$
      isIntegrated = IsLikelyIntegratedGpuName(name$)
      If isIntegrated
        line$ + " [iGPU]"
        foundIntegrated = #True
      ElseIf IsLikelyDiscreteGpuName(name$, vendor$)
        line$ + " [dGPU]"
      EndIf
      If vendor$ <> "Unknown vendor" And FindString(LCase(line$), LCase(vendor$), 1) = 0
        line$ + " (" + vendor$ + ")"
      EndIf
      If pci$ <> ""
        line$ + " - " + pci$
      EndIf
      If flags$ <> ""
        line$ + " [" + flags$ + "]"
      EndIf
      If text$ <> "" : text$ + #LF$ : EndIf
      text$ + line$
    EndIf
    index + 1
  ForEver

  inferredName$ = CpuInferredIntegratedGpuName()
  If text$ <> "" And foundIntegrated = #False And inferredName$ <> "" And FindMapElement(seenGpu(), LCase(inferredName$)) = #False
    text$ + #LF$ + inferredName$ + " [iGPU, inferred]"
  EndIf

  If text$ = ""
    name$ = inferredName$
    If name$ <> ""
      text$ = name$ + " [iGPU, CPU inferred]"
    Else
      text$ = "No display adapter names exposed by Windows."
    EndIf
  EndIf
  ProcedureReturn text$
EndProcedure

; CPU/GPU strings are cached because they are static and relatively expensive.
Procedure.s CpuInfo()
  If gCachedCpuInfo$ = ""
    gCachedCpuInfo$ = BuildCpuInfo()
  EndIf
  ProcedureReturn gCachedCpuInfo$
EndProcedure

Procedure.s GpuInfo()
  If gCachedGpuInfo$ = ""
    gCachedGpuInfo$ = BuildGpuInfo()
  EndIf
  ProcedureReturn gCachedGpuInfo$
EndProcedure

; Per-user startup registration. The installer is elevated, but the app startup
; entry must be HKCU so PowerPilot runs non-elevated for the local user.
Procedure.i SetStartupRegistry(enabled.i)
  Protected ps$
  If enabled
    ps$ = "$q=[char]34; $cmd=$q + " + PowerShellLiteral(ProgramFilename()) + " + $q + ' /tray'; New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Force | Out-Null; Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name " + PowerShellLiteral(#AppRunKey$) + " -Value $cmd"
  Else
    ps$ = "Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name " + PowerShellLiteral(#AppRunKey$) + " -ErrorAction SilentlyContinue"
  EndIf
  ProcedureReturn Bool(RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(ps$), "", 10000) = 0)
EndProcedure

; Installer/uninstaller helper for removing user settings when requested.
Procedure.i CleanupSettingsData()
  SetStartupRegistry(#False)
  If FileSize(SettingsDirectory()) = -2
    ProcedureReturn DeleteDirectory(SettingsDirectory(), "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf
  ProcedureReturn #True
EndProcedure

; Copy plan editor gadget values into the selected in-memory plan.
Procedure ReadPlanEditor()
  If gSelectedPlan < 0 Or gSelectedPlan > 2
    ProcedureReturn
  EndIf
  If IsGadget(#GadgetPlanSummary) : gPlans(gSelectedPlan)\Description = CleanPlanText(GetGadgetText(#GadgetPlanSummary)) : EndIf
  If IsGadget(#GadgetPlanAcEpp) : gPlans(gSelectedPlan)\AcEpp = GetGadgetState(#GadgetPlanAcEpp) : EndIf
  If IsGadget(#GadgetPlanDcEpp) : gPlans(gSelectedPlan)\DcEpp = GetGadgetState(#GadgetPlanDcEpp) : EndIf
  If IsGadget(#GadgetPlanAcBoost) : gPlans(gSelectedPlan)\AcBoostMode = GetGadgetState(#GadgetPlanAcBoost) : EndIf
  If IsGadget(#GadgetPlanDcBoost) : gPlans(gSelectedPlan)\DcBoostMode = GetGadgetState(#GadgetPlanDcBoost) : EndIf
  If IsGadget(#GadgetPlanAcState) : gPlans(gSelectedPlan)\AcMaxState = GetGadgetState(#GadgetPlanAcState) : EndIf
  If IsGadget(#GadgetPlanDcState) : gPlans(gSelectedPlan)\DcMaxState = GetGadgetState(#GadgetPlanDcState) : EndIf
  If IsGadget(#GadgetPlanAcFreq) : gPlans(gSelectedPlan)\AcFreqMHz = GetGadgetState(#GadgetPlanAcFreq) : EndIf
  If IsGadget(#GadgetPlanDcFreq) : gPlans(gSelectedPlan)\DcFreqMHz = GetGadgetState(#GadgetPlanDcFreq) : EndIf
  If IsGadget(#GadgetPlanAcCooling) : gPlans(gSelectedPlan)\AcCooling = GetGadgetState(#GadgetPlanAcCooling) : EndIf
  If IsGadget(#GadgetPlanDcCooling) : gPlans(gSelectedPlan)\DcCooling = GetGadgetState(#GadgetPlanDcCooling) : EndIf
  ClampPlanValues(@gPlans(gSelectedPlan))
EndProcedure

; Copy selected in-memory plan values into the editor gadgets.
Procedure RefreshPlanEditor()
  If gSelectedPlan < 0 Or gSelectedPlan > 2
    gSelectedPlan = 1
  EndIf
  SetGadgetText(#GadgetPlanSummary, gPlans(gSelectedPlan)\Description)
  SetGadgetState(#GadgetPlanAcEpp, gPlans(gSelectedPlan)\AcEpp)
  SetGadgetState(#GadgetPlanDcEpp, gPlans(gSelectedPlan)\DcEpp)
  SetGadgetState(#GadgetPlanAcBoost, gPlans(gSelectedPlan)\AcBoostMode)
  SetGadgetState(#GadgetPlanDcBoost, gPlans(gSelectedPlan)\DcBoostMode)
  SetGadgetState(#GadgetPlanAcState, gPlans(gSelectedPlan)\AcMaxState)
  SetGadgetState(#GadgetPlanDcState, gPlans(gSelectedPlan)\DcMaxState)
  SetGadgetState(#GadgetPlanAcFreq, gPlans(gSelectedPlan)\AcFreqMHz)
  SetGadgetState(#GadgetPlanDcFreq, gPlans(gSelectedPlan)\DcFreqMHz)
  SetGadgetState(#GadgetPlanAcCooling, gPlans(gSelectedPlan)\AcCooling)
  SetGadgetState(#GadgetPlanDcCooling, gPlans(gSelectedPlan)\DcCooling)
EndProcedure

; Refresh the fixed-plan list and whether each plan exists in Windows.
Procedure RefreshPlanList(force.i = #False)
  Protected i.i
  Protected installed$
  If force Or gSchemeCacheValid = #False
    RefreshSchemeCache()
  EndIf
  ClearGadgetItems(#GadgetPlanList)
  For i = 0 To 2
    installed$ = "No"
    If GetSchemeGuidByName(gPlans(i)\Name) <> ""
      installed$ = "Yes"
    EndIf
    AddGadgetItem(#GadgetPlanList, -1, gPlans(i)\Name + Chr(10) + installed$ + Chr(10) + gPlans(i)\Description)
  Next
  If gSelectedPlan < 0 Or gSelectedPlan > 2
    gSelectedPlan = PlanIndexByName(gSettings\LastPlan)
    If gSelectedPlan < 0 : gSelectedPlan = 1 : EndIf
  EndIf
  SetGadgetState(#GadgetPlanList, gSelectedPlan)
EndProcedure

Procedure RefreshBatterySaverSummary()
  Protected text$
  Protected normalName$ = gSettings\NormalPlanName
  If IsGadget(#GadgetBatterySaverSummary) = #False
    ProcedureReturn
  EndIf
  If normalName$ = ""
    normalName$ = "Windows Balanced"
  EndIf
  text$ = "Energy Saver: " + EnergySaverModeName(gSettings\EnergySaverMode)
  text$ + ", " + Str(ClampInt(gSettings\EnergySaverThreshold, 0, 100)) + "%; brightness " + Str(ClampInt(gSettings\EnergySaverBrightness, 0, 100)) + "%." + #CRLF$
  text$ + "Guard: low " + Str(ClampInt(gSettings\BatteryLowWarningPercent, gSettings\BatteryCriticalPercent + 1, 100)) + "% -> " + BatteryActionName(gSettings\BatteryLowAction)
  text$ + "; reserve " + Str(ClampInt(gSettings\BatteryReservePercent, gSettings\BatteryCriticalPercent, 100)) + "% warning only." + #CRLF$
  text$ + "Critical " + Str(ClampInt(gSettings\BatteryCriticalPercent, 1, 99)) + "% -> " + BatteryActionName(gSettings\BatteryCriticalAction) + ". "
  If gSettings\RestoreNormalPlanOnExit
    text$ + "Exit restores " + normalName$ + "."
  Else
    text$ + "Exit leaves active plan."
  EndIf
  SetGadgetTextIfChanged(#GadgetBatterySaverSummary, text$)
EndProcedure

; Save edited plan settings, creating a missing Windows plan if necessary.
Procedure SavePlanEditor()
  Protected guid$
  Protected baseGuid$
  Protected baseName$
  ReadPlanEditor()
  SaveSettings()
  guid$ = GetSchemeGuidByName(gPlans(gSelectedPlan)\Name)
  If guid$ <> ""
    RunPowerCfg("/CHANGENAME " + guid$ + " " + QuoteArgument(gPlans(gSelectedPlan)\Name) + " " + QuoteArgument(gPlans(gSelectedPlan)\Description))
    ConfigureScheme(@gPlans(gSelectedPlan), guid$)
    LogAction(gPlans(gSelectedPlan)\Name + " saved and applied to Windows.")
  Else
    baseGuid$ = GetActiveSchemeGuid()
    baseName$ = GetSchemeNameByGuid(baseGuid$, #True)
    If baseGuid$ = "" Or IsManagedPlanName(baseName$)
      baseGuid$ = "SCHEME_BALANCED"
    EndIf
    If EnsurePlanInstalled(gSelectedPlan, baseGuid$)
      RefreshSchemeCache()
      LogAction(gPlans(gSelectedPlan)\Name + " created, saved, and applied to Windows.")
    Else
      LogAction("Failed to create " + gPlans(gSelectedPlan)\Name + ".")
    EndIf
  EndIf
  RefreshPlanList(#True)
EndProcedure

; Restore one fixed plan to the current defaults and apply it if installed.
Procedure ResetSelectedPlan()
  Protected name$ = gPlans(gSelectedPlan)\Name
  Protected guid$
  LoadDefaultPlan(gSelectedPlan)
  SaveSettings()
  RefreshPlanEditor()
  guid$ = GetSchemeGuidByName(name$)
  If guid$ <> ""
    RunPowerCfg("/CHANGENAME " + guid$ + " " + QuoteArgument(gPlans(gSelectedPlan)\Name) + " " + QuoteArgument(gPlans(gSelectedPlan)\Description))
    ConfigureScheme(@gPlans(gSelectedPlan), guid$)
    LogAction(name$ + " reset to defaults and applied to Windows.")
  Else
    LogAction(name$ + " reset to defaults.")
  EndIf
  RefreshPlanList(#True)
EndProcedure

; Push loaded settings into the tab controls. Most gadgets are created before
; this runs, but several checks stay defensive because installer command-line
; modes reuse settings code without ever opening the window.
Procedure ApplySettingsToGui()
  SetGadgetState(#GadgetAutoStart, Bool(gSettings\AutoStartWithApp))
  SetGadgetState(#GadgetKeepSettings, Bool(gSettings\KeepSettingsOnReinstall))
  SetGadgetState(#GadgetThrottleMaintenance, Bool(gSettings\ThrottleMaintenance))
  SetGadgetState(#GadgetDeepIdleSaver, Bool(gSettings\DeepIdleSaver))
  If IsGadget(#GadgetEnergySaverMode) : SetGadgetState(#GadgetEnergySaverMode, ClampInt(gSettings\EnergySaverMode, #EnergySaverFollowWindows, #EnergySaverPowerPilotControlled)) : EndIf
  If IsGadget(#GadgetEnergySaverThreshold) : SetGadgetState(#GadgetEnergySaverThreshold, ClampInt(gSettings\EnergySaverThreshold, 0, 100)) : EndIf
  If IsGadget(#GadgetEnergySaverBrightness) : SetGadgetState(#GadgetEnergySaverBrightness, ClampInt(gSettings\EnergySaverBrightness, 0, 100)) : EndIf
  If IsGadget(#GadgetBatteryLowWarningPercent) : SetGadgetState(#GadgetBatteryLowWarningPercent, ClampInt(gSettings\BatteryLowWarningPercent, gSettings\BatteryCriticalPercent + 1, 100)) : EndIf
  If IsGadget(#GadgetBatteryReservePercent) : SetGadgetState(#GadgetBatteryReservePercent, ClampInt(gSettings\BatteryReservePercent, gSettings\BatteryCriticalPercent, 100)) : EndIf
  If IsGadget(#GadgetBatteryLowAction) : SetGadgetState(#GadgetBatteryLowAction, ClampInt(gSettings\BatteryLowAction, #BatteryActionDoNothing, #BatteryActionShutdown)) : EndIf
  If IsGadget(#GadgetBatteryCriticalPercent) : SetGadgetState(#GadgetBatteryCriticalPercent, ClampInt(gSettings\BatteryCriticalPercent, 1, 99)) : EndIf
  If IsGadget(#GadgetBatteryCriticalAction) : SetGadgetState(#GadgetBatteryCriticalAction, ClampInt(gSettings\BatteryCriticalAction, #BatteryActionDoNothing, #BatteryActionShutdown)) : EndIf
  If IsGadget(#GadgetRestoreNormalPlanOnExit) : SetGadgetState(#GadgetRestoreNormalPlanOnExit, Bool(gSettings\RestoreNormalPlanOnExit)) : EndIf
  SetGadgetState(#GadgetShowToolTips, Bool(gSettings\ShowToolTips))
  If IsGadget(#GadgetBatteryLogEnabled) : SetGadgetState(#GadgetBatteryLogEnabled, Bool(gSettings\BatteryLogEnabled)) : EndIf
  If IsGadget(#GadgetBatteryLogMinutes) : SetGadgetState(#GadgetBatteryLogMinutes, ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440)) : EndIf
  If IsGadget(#GadgetBatteryRefreshSeconds) : SetGadgetState(#GadgetBatteryRefreshSeconds, ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)) : EndIf
  If IsGadget(#GadgetBatteryMinPercent) : SetGadgetState(#GadgetBatteryMinPercent, ClampInt(gSettings\BatteryMinPercent, 0, 99)) : EndIf
  If IsGadget(#GadgetBatteryMaxPercent) : SetGadgetState(#GadgetBatteryMaxPercent, ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100)) : EndIf
  If IsGadget(#GadgetBatteryLimiterEnabled) : SetGadgetState(#GadgetBatteryLimiterEnabled, Bool(gSettings\BatteryLimiterEnabled)) : EndIf
  If IsGadget(#GadgetBatteryLimiterMaxPercent) : SetGadgetState(#GadgetBatteryLimiterMaxPercent, ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100)) : EndIf
  If IsGadget(#GadgetBatterySmoothingMinutes) : SetGadgetState(#GadgetBatterySmoothingMinutes, ClampInt(gSettings\BatterySmoothingMinutes, 5, 240)) : EndIf
  If IsGadget(#GadgetBatteryStartupDrain) : SetGadgetState(#GadgetBatteryStartupDrain, ClampInt(gSettings\BatteryStartupDrainPctPerHour, 1, 100)) : EndIf
  If IsGadget(#GadgetBatteryLoadMinutes) : SetGadgetState(#GadgetBatteryLoadMinutes, ClampInt(gSettings\BatteryCalibrationDrainMinutes, 15, 720)) : EndIf
  If IsGadget(#GadgetBatteryGraphHours) : SetGadgetState(#GadgetBatteryGraphHours, BatteryGraphHoursIndex(gSettings\BatteryGraphHours)) : EndIf
  If IsGadget(#GadgetBatteryGraphShowMarkers) : SetGadgetState(#GadgetBatteryGraphShowMarkers, Bool(gSettings\BatteryGraphShowMarkers)) : EndIf
  If IsGadget(gFrameBatteryGraph) : SetGadgetTextIfChanged(gFrameBatteryGraph, BatteryGraphWindowTitle()) : EndIf
  If IsGadget(#GadgetLogShowAverage) : SetGadgetState(#GadgetLogShowAverage, Bool(gSettings\BatteryLogShowAverage)) : EndIf
  If IsGadget(#GadgetLogShowInstant) : SetGadgetState(#GadgetLogShowInstant, Bool(gSettings\BatteryLogShowInstant)) : EndIf
  If IsGadget(#GadgetLogShowWindows) : SetGadgetState(#GadgetLogShowWindows, Bool(gSettings\BatteryLogShowWindows)) : EndIf
  If IsGadget(#GadgetLogShowConnected) : SetGadgetState(#GadgetLogShowConnected, Bool(gSettings\BatteryLogShowConnected)) : EndIf
  If IsGadget(#GadgetLogShowPower) : SetGadgetState(#GadgetLogShowPower, Bool(gSettings\BatteryLogShowPower)) : EndIf
  If IsGadget(#GadgetLogShowScreen) : SetGadgetState(#GadgetLogShowScreen, Bool(gSettings\BatteryLogShowScreen)) : EndIf
  If IsGadget(#GadgetLogShowBrightness) : SetGadgetState(#GadgetLogShowBrightness, Bool(gSettings\BatteryLogShowBrightness)) : EndIf
  If IsGadget(#GadgetLogShowEvents) : SetGadgetState(#GadgetLogShowEvents, Bool(gSettings\BatteryLogShowEvents)) : EndIf
  RefreshBatterySaverSummary()
  ApplyToolTips()
EndProcedure

; Read and persist Battery Saver, PowerPilot Log, graph, and Battery Stats
; display settings from the GUI. Windows plan writes are delayed until after all
; values are clamped so related fields stay ordered (critical < low, etc.).
Procedure SaveBatterySettingsFromGui()
  Protected oldEnergySaverMode.i = gSettings\EnergySaverMode
  Protected oldEnergySaverThreshold.i = gSettings\EnergySaverThreshold
  Protected oldEnergySaverBrightness.i = gSettings\EnergySaverBrightness
  Protected oldBatteryLowWarningPercent.i = gSettings\BatteryLowWarningPercent
  Protected oldBatteryReservePercent.i = gSettings\BatteryReservePercent
  Protected oldBatteryLowAction.i = gSettings\BatteryLowAction
  Protected oldBatteryCriticalPercent.i = gSettings\BatteryCriticalPercent
  Protected oldBatteryCriticalAction.i = gSettings\BatteryCriticalAction
  If gBatterySettingsApplyPending And IsWindow(#WindowMain)
    RemoveWindowTimer(#WindowMain, #TimerBatterySettingsApply)
  EndIf
  gBatterySettingsApplyPending = #False
  CaptureBatteryLogColumnWidths(#False)
  If IsGadget(#GadgetEnergySaverMode) : gSettings\EnergySaverMode = GetGadgetState(#GadgetEnergySaverMode) : EndIf
  If IsGadget(#GadgetEnergySaverThreshold) : gSettings\EnergySaverThreshold = GetGadgetState(#GadgetEnergySaverThreshold) : EndIf
  If IsGadget(#GadgetEnergySaverBrightness) : gSettings\EnergySaverBrightness = GetGadgetState(#GadgetEnergySaverBrightness) : EndIf
  If IsGadget(#GadgetBatteryLowWarningPercent) : gSettings\BatteryLowWarningPercent = GetGadgetState(#GadgetBatteryLowWarningPercent) : EndIf
  If IsGadget(#GadgetBatteryReservePercent) : gSettings\BatteryReservePercent = GetGadgetState(#GadgetBatteryReservePercent) : EndIf
  If IsGadget(#GadgetBatteryLowAction) : gSettings\BatteryLowAction = GetGadgetState(#GadgetBatteryLowAction) : EndIf
  If IsGadget(#GadgetBatteryCriticalPercent) : gSettings\BatteryCriticalPercent = GetGadgetState(#GadgetBatteryCriticalPercent) : EndIf
  If IsGadget(#GadgetBatteryCriticalAction) : gSettings\BatteryCriticalAction = GetGadgetState(#GadgetBatteryCriticalAction) : EndIf
  If IsGadget(#GadgetRestoreNormalPlanOnExit) : gSettings\RestoreNormalPlanOnExit = GetGadgetState(#GadgetRestoreNormalPlanOnExit) : EndIf
  If IsGadget(#GadgetBatteryLogEnabled) : gSettings\BatteryLogEnabled = GetGadgetState(#GadgetBatteryLogEnabled) : EndIf
  If IsGadget(#GadgetBatteryLogMinutes) : gSettings\BatteryLogIntervalMinutes = GetGadgetState(#GadgetBatteryLogMinutes) : EndIf
  If IsGadget(#GadgetBatteryRefreshSeconds) : gSettings\BatteryRefreshSeconds = GetGadgetState(#GadgetBatteryRefreshSeconds) : EndIf
  If IsGadget(#GadgetBatteryMinPercent) : gSettings\BatteryMinPercent = GetGadgetState(#GadgetBatteryMinPercent) : EndIf
  If IsGadget(#GadgetBatteryMaxPercent) : gSettings\BatteryMaxPercent = GetGadgetState(#GadgetBatteryMaxPercent) : EndIf
  If IsGadget(#GadgetBatteryLimiterEnabled) : gSettings\BatteryLimiterEnabled = GetGadgetState(#GadgetBatteryLimiterEnabled) : EndIf
  If IsGadget(#GadgetBatteryLimiterMaxPercent) : gSettings\BatteryLimiterMaxPercent = GetGadgetState(#GadgetBatteryLimiterMaxPercent) : EndIf
  If IsGadget(#GadgetBatterySmoothingMinutes) : gSettings\BatterySmoothingMinutes = GetGadgetState(#GadgetBatterySmoothingMinutes) : EndIf
  If IsGadget(#GadgetBatteryStartupDrain) : gSettings\BatteryStartupDrainPctPerHour = GetGadgetState(#GadgetBatteryStartupDrain) : EndIf
  If IsGadget(#GadgetBatteryLoadMinutes) : gSettings\BatteryCalibrationDrainMinutes = GetGadgetState(#GadgetBatteryLoadMinutes) : EndIf
  If IsGadget(#GadgetBatteryGraphHours) : gSettings\BatteryGraphHours = BatteryGraphHoursFromIndex(GetGadgetState(#GadgetBatteryGraphHours)) : EndIf
  If IsGadget(#GadgetBatteryGraphShowMarkers) : gSettings\BatteryGraphShowMarkers = GetGadgetState(#GadgetBatteryGraphShowMarkers) : EndIf
  If IsGadget(#GadgetLogShowAverage) : gSettings\BatteryLogShowAverage = GetGadgetState(#GadgetLogShowAverage) : EndIf
  If IsGadget(#GadgetLogShowInstant) : gSettings\BatteryLogShowInstant = GetGadgetState(#GadgetLogShowInstant) : EndIf
  If IsGadget(#GadgetLogShowWindows) : gSettings\BatteryLogShowWindows = GetGadgetState(#GadgetLogShowWindows) : EndIf
  If IsGadget(#GadgetLogShowConnected) : gSettings\BatteryLogShowConnected = GetGadgetState(#GadgetLogShowConnected) : EndIf
  If IsGadget(#GadgetLogShowPower) : gSettings\BatteryLogShowPower = GetGadgetState(#GadgetLogShowPower) : EndIf
  If IsGadget(#GadgetLogShowScreen) : gSettings\BatteryLogShowScreen = GetGadgetState(#GadgetLogShowScreen) : EndIf
  If IsGadget(#GadgetLogShowBrightness) : gSettings\BatteryLogShowBrightness = GetGadgetState(#GadgetLogShowBrightness) : EndIf
  If IsGadget(#GadgetLogShowEvents) : gSettings\BatteryLogShowEvents = GetGadgetState(#GadgetLogShowEvents) : EndIf
  gSettings\EnergySaverMode = ClampInt(gSettings\EnergySaverMode, #EnergySaverFollowWindows, #EnergySaverPowerPilotControlled)
  gSettings\EnergySaverThreshold = ClampInt(gSettings\EnergySaverThreshold, 0, 100)
  gSettings\EnergySaverBrightness = ClampInt(gSettings\EnergySaverBrightness, 0, 100)
  gSettings\BatteryCriticalPercent = ClampInt(gSettings\BatteryCriticalPercent, 1, 99)
  gSettings\BatteryLowWarningPercent = ClampInt(gSettings\BatteryLowWarningPercent, gSettings\BatteryCriticalPercent + 1, 100)
  gSettings\BatteryReservePercent = ClampInt(gSettings\BatteryReservePercent, gSettings\BatteryCriticalPercent, 100)
  gSettings\BatteryLowAction = ClampInt(gSettings\BatteryLowAction, #BatteryActionDoNothing, #BatteryActionShutdown)
  gSettings\BatteryCriticalAction = ClampInt(gSettings\BatteryCriticalAction, #BatteryActionDoNothing, #BatteryActionShutdown)
  gSettings\RestoreNormalPlanOnExit = Bool(gSettings\RestoreNormalPlanOnExit)
  gSettings\BatteryLogIntervalMinutes = ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440)
  gSettings\BatteryRefreshSeconds = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)
  gSettings\BatteryMinPercent = ClampInt(gSettings\BatteryMinPercent, 0, 99)
  gSettings\BatteryMaxPercent = ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatteryLimiterMaxPercent = ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatterySmoothingMinutes = ClampInt(gSettings\BatterySmoothingMinutes, 5, 240)
  gSettings\BatteryCalibrationDrainMinutes = ClampInt(gSettings\BatteryCalibrationDrainMinutes, 15, 720)
  gSettings\BatteryGraphHours = NormalizeBatteryGraphHours(gSettings\BatteryGraphHours)
  gSettings\BatteryGraphShowMarkers = Bool(gSettings\BatteryGraphShowMarkers)
  If gSettings\BatteryStartupDrainPctPerHour <= 0.0
    gSettings\BatteryStartupDrainPctPerHour = 12.0
  EndIf
  SaveSettings()
  If oldBatteryLowWarningPercent <> gSettings\BatteryLowWarningPercent Or oldBatteryReservePercent <> gSettings\BatteryReservePercent Or oldBatteryLowAction <> gSettings\BatteryLowAction Or oldBatteryCriticalPercent <> gSettings\BatteryCriticalPercent Or oldBatteryCriticalAction <> gSettings\BatteryCriticalAction
    ApplyBatterySleepFloorToManagedPlans()
  EndIf
  If oldEnergySaverMode <> gSettings\EnergySaverMode Or oldEnergySaverThreshold <> gSettings\EnergySaverThreshold Or oldEnergySaverBrightness <> gSettings\EnergySaverBrightness
    ApplyEnergySaverPolicyToManagedPlans()
  EndIf
  ApplySettingsToGui()
  RefreshBattery(#True)
  RefreshBatteryLogPreview()
EndProcedure

; Graph display controls are visual only, so keep their click path immediate.
Procedure SaveBatteryGraphDisplaySettingsFromGui()
  If IsGadget(#GadgetBatteryGraphHours) : gSettings\BatteryGraphHours = BatteryGraphHoursFromIndex(GetGadgetState(#GadgetBatteryGraphHours)) : EndIf
  If IsGadget(#GadgetBatteryGraphShowMarkers) : gSettings\BatteryGraphShowMarkers = GetGadgetState(#GadgetBatteryGraphShowMarkers) : EndIf
  gSettings\BatteryGraphHours = NormalizeBatteryGraphHours(gSettings\BatteryGraphHours)
  gSettings\BatteryGraphShowMarkers = Bool(gSettings\BatteryGraphShowMarkers)
  If IsGadget(gFrameBatteryGraph) : SetGadgetTextIfChanged(gFrameBatteryGraph, BatteryGraphWindowTitle()) : EndIf
  SaveSettings()
EndProcedure

; Spinner/checkbox changes can fire repeatedly while the user is still editing.
; Debounce them so Windows powercfg battery writes happen once after the edit.
Procedure ScheduleBatterySettingsApply()
  If IsWindow(#WindowMain) = #False
    ProcedureReturn
  EndIf
  If gBatterySettingsApplyPending
    RemoveWindowTimer(#WindowMain, #TimerBatterySettingsApply)
  EndIf
  AddWindowTimer(#WindowMain, #TimerBatterySettingsApply, #BatterySettingsApplyDelayMs)
  gBatterySettingsApplyPending = #True
EndProcedure

Procedure ApplyPendingBatterySettings()
  If IsWindow(#WindowMain)
    RemoveWindowTimer(#WindowMain, #TimerBatterySettingsApply)
  EndIf
  If gBatterySettingsApplyPending
    SaveBatterySettingsFromGui()
  EndIf
  gBatterySettingsApplyPending = #False
EndProcedure

; Read current user-resized PowerPilot Log column widths from the live ListIcon.
; Hidden optional columns report width zero; keep their previous saved width so
; showing the column later restores the user's last useful size.
Procedure.i CaptureBatteryLogColumnWidths(saveIfChanged.i = #False)
  Protected column.i
  Protected width.i
  Protected changed.i
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn #False
  EndIf
  For column = 0 To #BatteryLogVisibleColumns - 1
    width = GetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, column)
    If width > 0 And width <> BatteryLogColumnWidth(column)
      SetBatteryLogColumnWidthSetting(column, width)
      changed = #True
    EndIf
  Next
  If changed And saveIfChanged
    SaveSettings()
  EndIf
  ProcedureReturn changed
EndProcedure

; Apply saved log column widths. The checkbox settings still control whether
; optional columns are shown, but their nonzero widths are retained separately.
Procedure ApplyBatteryLogColumnWidths()
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn
  EndIf
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, BatteryLogColumnWidth(0), 0)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, BatteryLogColumnWidth(1), 1)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowAverage) * BatteryLogColumnWidth(2), 2)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowInstant) * BatteryLogColumnWidth(3), 3)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowWindows) * BatteryLogColumnWidth(4), 4)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowInstant) * BatteryLogColumnWidth(5), 5)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowConnected) * BatteryLogColumnWidth(6), 6)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowPower) * BatteryLogColumnWidth(7), 7)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowScreen) * BatteryLogColumnWidth(8), 8)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowBrightness) * BatteryLogColumnWidth(9), 9)
EndProcedure

; Clear retained history and live estimate state, then immediately sample again
; so the graph/log are not left blank longer than necessary.
Procedure ResetBatteryStats()
  If FileSize(BatteryLogPath()) >= 0
    DeleteFile(BatteryLogPath())
  EndIf
  gBatteryGraphCount = 0
  gBatteryAverageBreakCount = 0
  gBatteryAppBreakCount = 0
  gBatteryEventCount = 0
  gLastBatteryLogTime = 0
  gBatteryLastSampleTime = 0
  gBatteryLastSamplePercent = 0.0
  gBatteryOnBatterySince = 0
  gBattery\EstimateMinutes = -1
  gBattery\EstimateValid = #False
  gBattery\InstantEstimateMinutes = -1
  gBattery\InstantEstimateValid = #False
  gBattery\InstantDrainPctPerHour = 0.0
  gBattery\SmoothedDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
  gBattery\SmoothedChargePctPerHour = 0.0
  gSettings\BatteryLastDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
  gSettings\BatteryLastChargePctPerHour = 0.0
  gSettings\BatteryChargeLearningCount = 0
  SaveSettings()
  If IsGadget(#GadgetBatteryLogPreview)
    ClearGadgetItems(#GadgetBatteryLogPreview)
  EndIf
  DrawBatteryGraph()
  RefreshBattery(#True)
  RefreshBatteryLogPreview()
  RefreshBatteryStatsSummary()
  LogAction("Battery stats reset.")
EndProcedure

; Format one visible log row for tab-separated clipboard copy.
Procedure.s BatteryLogPreviewRowText(row.i)
  Protected columns.i = #BatteryLogVisibleColumns
  Protected i.i
  Protected text$
  For i = 0 To columns - 1
    If i > 0 : text$ + #TAB$ : EndIf
    text$ + GetGadgetItemText(#GadgetBatteryLogPreview, row, i)
  Next
  ProcedureReturn text$
EndProcedure

; Copy all selected rows. If nothing is selected, copy the newest visible row.
Procedure CopyBatteryLogRow()
  Protected row.i
  Protected copied.i
  Protected text$
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn
  EndIf
  For row = 0 To CountGadgetItems(#GadgetBatteryLogPreview) - 1
    If GetGadgetItemState(#GadgetBatteryLogPreview, row) & #PB_ListIcon_Selected
      If copied > 0 : text$ + #CRLF$ : EndIf
      text$ + BatteryLogPreviewRowText(row)
      copied + 1
    EndIf
  Next
  If copied = 0
    row = CountGadgetItems(#GadgetBatteryLogPreview) - 1
    If row >= 0
      text$ = BatteryLogPreviewRowText(row)
      copied = 1
    EndIf
  EndIf
  If copied = 0
    LogAction("No PowerPilot log row to copy.")
    ProcedureReturn
  EndIf
  SetClipboardText(text$)
  If copied = 1
    LogAction("PowerPilot log row copied.")
  Else
    LogAction(Str(copied) + " PowerPilot log rows copied.")
  EndIf
EndProcedure

; Copy the full retained CSV, not just visible columns.
Procedure CopyBatteryLogAll()
  Protected file.i
  Protected text$
  PruneBatteryLog()
  If FileSize(BatteryLogPath()) < 0
    LogAction("No PowerPilot log to copy.")
    ProcedureReturn
  EndIf
  file = ReadFile(#PB_Any, BatteryLogPath())
  If file
    While Eof(file) = 0
      text$ + ReadString(file) + #CRLF$
    Wend
    CloseFile(file)
  EndIf
  If text$ <> ""
    SetClipboardText(text$)
    LogAction("PowerPilot CSV log copied.")
  Else
    LogAction("No PowerPilot log to copy.")
  EndIf
EndProcedure

; Simple settings backup/restore helpers for the Battery Stats tab.
Procedure ExportSettings()
  Protected target$
  SaveSettings()
  target$ = SaveFileRequester("Export PowerPilot settings", GetHomeDirectory() + "PowerPilot-settings.ini", "INI files (*.ini)|*.ini|All files (*.*)|*.*", 0)
  If target$ = ""
    ProcedureReturn
  EndIf
  If LCase(GetExtensionPart(target$)) = ""
    target$ + ".ini"
  EndIf
  If CopyFile(SettingsPath(), target$)
    LogAction("Settings exported.")
  Else
    LogAction("Settings export failed.")
  EndIf
EndProcedure

Procedure ImportSettings()
  Protected source$
  source$ = OpenFileRequester("Import PowerPilot settings", GetHomeDirectory(), "INI files (*.ini)|*.ini|All files (*.*)|*.*", 0)
  If source$ = ""
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  If CopyFile(source$, SettingsPath())
    LoadSettings()
    gSelectedPlan = PlanIndexByName(gSettings\LastPlan)
    If gSelectedPlan < 0 : gSelectedPlan = 1 : EndIf
    ApplySettingsToGui()
    RefreshPlanList(#True)
    RefreshPlanEditor()
    RefreshBatteryLogPreview()
    RefreshBatteryStatsSummary()
    RefreshActiveTimer()
    LogAction("Settings imported.")
  Else
    LogAction("Settings import failed.")
  EndIf
EndProcedure

Procedure OpenReadmeDocument()
  Protected path$ = GetPathPart(ProgramFilename()) + "README.txt"
  If FileSize(path$) < 0
    path$ = GetCurrentDirectory() + "README.txt"
  EndIf
  If FileSize(path$) < 0
    path$ = GetPathPart(ProgramFilename()) + "README.md"
  EndIf
  If FileSize(path$) < 0
    path$ = GetCurrentDirectory() + "README.md"
  EndIf
  If FileSize(path$) >= 0
    RunProgram("explorer.exe", QuoteArgument(path$), "")
    LogAction("README opened.")
  Else
    LogAction("README was not found beside PowerPilot.")
    MessageRequester(#AppName$, "README was not found beside PowerPilot.", #PB_MessageRequester_Warning)
  EndIf
EndProcedure

Procedure OpenLicenseDocument()
  Protected path$ = GetPathPart(ProgramFilename()) + "LICENSE.txt"
  If FileSize(path$) < 0
    path$ = GetCurrentDirectory() + "LICENSE.txt"
  EndIf
  If FileSize(path$) < 0
    path$ = GetPathPart(ProgramFilename()) + "LICENSE"
  EndIf
  If FileSize(path$) < 0
    path$ = GetCurrentDirectory() + "LICENSE"
  EndIf
  If FileSize(path$) >= 0
    RunProgram("explorer.exe", QuoteArgument(path$), "")
    LogAction("LICENSE opened.")
  Else
    LogAction("LICENSE was not found beside PowerPilot.")
    MessageRequester(#AppName$, "LICENSE was not found beside PowerPilot.", #PB_MessageRequester_Warning)
  EndIf
EndProcedure

; Save startup, idle, tooltip, and managed-plan Energy Saver settings.
Procedure SaveSettingsFromGui()
  Protected batteryGuid$
  Protected oldEnergySaverMode.i = gSettings\EnergySaverMode
  gSettings\AutoStartWithApp = GetGadgetState(#GadgetAutoStart)
  gSettings\KeepSettingsOnReinstall = GetGadgetState(#GadgetKeepSettings)
  gSettings\ThrottleMaintenance = GetGadgetState(#GadgetThrottleMaintenance)
  gSettings\DeepIdleSaver = GetGadgetState(#GadgetDeepIdleSaver)
  If IsGadget(#GadgetEnergySaverMode)
    gSettings\EnergySaverMode = GetGadgetState(#GadgetEnergySaverMode)
  EndIf
  gSettings\EnergySaverMode = ClampInt(gSettings\EnergySaverMode, #EnergySaverFollowWindows, #EnergySaverPowerPilotControlled)
  gSettings\ShowToolTips = GetGadgetState(#GadgetShowToolTips)
  SaveSettings()
  SetStartupRegistry(gSettings\AutoStartWithApp)
  batteryGuid$ = GetSchemeGuidByName(#PlanBattery$)
  If batteryGuid$ <> ""
    ConfigureScheme(@gPlans(2), batteryGuid$)
  EndIf
  If oldEnergySaverMode <> gSettings\EnergySaverMode
    ApplyEnergySaverPolicyToManagedPlans()
  EndIf
  ApplyMaintenanceThrottling(IsEfficiencyPowerMode(GetWindowsPowerModeGuid()), #True)
  RefreshActiveTimer()
  ApplyToolTips()
  LogAction("Settings saved.")
EndProcedure

; Fill the PowerPilot Log tab from the retained CSV. The list intentionally
; shows the full retained window, not just the last few rows.
Procedure RefreshBatteryLogPreview()
  Protected file.i
  Protected line$
  Protected added.i
  Protected fieldCount.i
  Protected averageField.i
  Protected instantField.i
  Protected instantValueField.i
  Protected instantValue$
  Protected instantTime$
  Protected instantDrain$
  Protected runtimeField.i
  Protected runtimeValue$
  Protected powerValue$
  Protected connected.i
  Protected dischargeField.i
  Protected chargeField.i
  Protected screenEvent$
  Protected brightness$
  Protected isEvent.i
  Protected rowType$
  Protected displayTimestamp$
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn
  EndIf
  If MainWindowVisible() = #False
    ProcedureReturn
  EndIf
  CaptureBatteryLogColumnWidths(#False)
  ClearGadgetItems(#GadgetBatteryLogPreview)
  ApplyBatteryLogColumnWidths()
  PruneBatteryLog()
  If ReadFile(0, BatteryLogPath())
    While Eof(0) = 0
      line$ = ReadString(0)
      If Left(line$, 9) <> "timestamp" And Trim(line$) <> ""
        fieldCount = CountString(line$, ",") + 1
        displayTimestamp$ = BatteryLogTimestampForDisplay(StringField(line$, 1, ","))
        rowType$ = ""
        If fieldCount >= 19
          rowType$ = LCase(StringField(line$, 18, ","))
        EndIf
        screenEvent$ = ""
        brightness$ = ""
        If fieldCount >= 20
          screenEvent$ = StringField(line$, 20, ",")
        EndIf
        If fieldCount >= 21
          brightness$ = StringField(line$, 21, ",")
        EndIf
        If brightness$ <> ""
          brightness$ + "%"
        EndIf
        isEvent = Bool(rowType$ = "event" Or rowType$ = "app" Or rowType$ = "screen" Or rowType$ = "energy" Or rowType$ = "test")
        If isEvent
          If gSettings\BatteryLogShowEvents = #False
            Continue
          EndIf
          If rowType$ = "screen"
            AddGadgetItem(#GadgetBatteryLogPreview, -1, BatteryLogListRow(displayTimestamp$, "SCREEN", "", "", "", "", "", "", screenEvent$, brightness$))
          ElseIf rowType$ = "energy"
            AddGadgetItem(#GadgetBatteryLogPreview, -1, BatteryLogListRow(displayTimestamp$, "ENERGY", StringField(line$, 19, ","), "", "", "", "", "", "", ""))
          ElseIf rowType$ = "app"
            AddGadgetItem(#GadgetBatteryLogPreview, -1, BatteryLogListRow(displayTimestamp$, "APP", StringField(line$, 19, ","), "", "", "", "", "", screenEvent$, brightness$))
          ElseIf rowType$ = "test"
            AddGadgetItem(#GadgetBatteryLogPreview, -1, BatteryLogListRow(displayTimestamp$, "TEST", StringField(line$, 19, ","), "", "", "", StringField(line$, 3, ","), FormatSignedBatteryWatts(ValD(StringField(line$, 10, ",")), ValD(StringField(line$, 11, ","))), screenEvent$, brightness$))
          Else
            AddGadgetItem(#GadgetBatteryLogPreview, -1, BatteryLogListRow(displayTimestamp$, "EVENT", StringField(line$, 19, ","), "", "", "", "", "", screenEvent$, brightness$))
          EndIf
        Else
          ; Legacy rows from earlier builds have fewer columns, so field indexes
          ; are chosen from the detected CSV shape.
          averageField = 11
          runtimeField = 12
          instantField = 0
          instantValueField = 0
          dischargeField = 0
          chargeField = 0
          If fieldCount >= 17
            averageField = 13
            runtimeField = 12
            instantField = 14
            instantValueField = 15
            dischargeField = 10
            chargeField = 11
          ElseIf fieldCount >= 16
            averageField = 13
            runtimeField = 12
            instantField = 14
          EndIf
          connected = Val(StringField(line$, 3, ","))
          runtimeValue$ = FormatBatteryRuntimeMinutes(Val(StringField(line$, runtimeField, ",")), connected)
          If instantField > 0
            instantTime$ = FormatBatteryMinutes(Val(StringField(line$, instantField, ",")))
          Else
            instantTime$ = "Unknown"
          EndIf
          If instantValueField > 0
            instantDrain$ = StrD(ValD(StringField(line$, instantValueField, ",")), 1) + "%/h"
          Else
            instantDrain$ = ""
          EndIf
          If dischargeField > 0 And chargeField > 0
            powerValue$ = FormatSignedBatteryWatts(ValD(StringField(line$, dischargeField, ",")), ValD(StringField(line$, chargeField, ",")))
          Else
            powerValue$ = ""
          EndIf
          AddGadgetItem(#GadgetBatteryLogPreview, -1, BatteryLogListRow(displayTimestamp$, StringField(line$, 2, ",") + "%", FormatBatteryMinutes(Val(StringField(line$, averageField, ","))), instantTime$, runtimeValue$, instantDrain$, StringField(line$, 3, ","), powerValue$, screenEvent$, brightness$))
        EndIf
        added + 1
      EndIf
    Wend
    CloseFile(0)
  EndIf
  If added > 0
    ; Keep the newest row visible after refresh.
    SetGadgetState(#GadgetBatteryLogPreview, added - 1)
  EndIf
EndProcedure

Procedure.s OverviewShortModeName()
  If gSettings\EnergySaverMode = #EnergySaverPowerPilotControlled
    ProcedureReturn "Battery plan always"
  EndIf
  ProcedureReturn "auto " + Str(ClampInt(gSettings\EnergySaverThreshold, 0, 100)) + "%"
EndProcedure

Procedure.s OverviewBatteryStateText()
  Protected text$
  If gBattery\Valid = #False
    ProcedureReturn "Waiting for battery"
  EndIf
  text$ = StrD(gBattery\Percent, 1) + "%"
  If gBattery\Connected
    text$ + ", plugged in"
  Else
    text$ + ", on battery"
  EndIf
  If gBattery\Charging
    text$ + ", charging"
  ElseIf gBattery\Connected And gBattery\DisconnectedBattery
    text$ + ", calibration discharge"
  ElseIf gBattery\DisconnectedBattery
    text$ + ", discharging"
  Else
    text$ + ", idle"
  EndIf
  ProcedureReturn text$
EndProcedure

Procedure.s OverviewEnergySaverText()
  Protected state$ = "Unknown"
  If gBattery\Valid
    If gBattery\EnergySaverOn
      state$ = "On"
    Else
      state$ = "Off"
    EndIf
  EndIf
  ProcedureReturn state$ + ", " + OverviewShortModeName()
EndProcedure

Procedure.s OverviewCpuText()
  Protected cpu$ = ReplaceString(CpuInfo(), #CRLF$, #LF$)
  Protected line1$ = Trim(StringField(cpu$, 1, #LF$))
  Protected line3$ = Trim(StringField(cpu$, 3, #LF$))
  Protected line4$ = Trim(StringField(cpu$, 4, #LF$))
  Protected ram$
  If line1$ = ""
    ProcedureReturn "CPU: unknown"
  EndIf
  If FindString(line4$, "|")
    ram$ = Trim(StringField(line4$, 2, "|"))
  EndIf
  If ram$ <> ""
    ProcedureReturn line1$ + #CRLF$ + line3$ + #CRLF$ + ram$
  EndIf
  ProcedureReturn line1$ + #CRLF$ + line3$
EndProcedure

Procedure.s OverviewGpuText()
  Protected gpu$ = ReplaceString(GpuInfo(), #CRLF$, #LF$)
  Protected line1$ = Trim(StringField(gpu$, 1, #LF$))
  Protected line2$ = Trim(StringField(gpu$, 2, #LF$))
  If line1$ = ""
    ProcedureReturn "Graphics: unknown"
  EndIf
  If line2$ <> ""
    ProcedureReturn line1$ + #CRLF$ + line2$
  EndIf
  ProcedureReturn line1$
EndProcedure

Procedure.s OverviewRuntimeText()
  Protected text$
  Protected fullRuntime$
  Protected timeText$
  Protected capacity$
  If gBattery\Valid = #False
    ProcedureReturn "Waiting for battery data."
  EndIf
  text$ = "State: " + OverviewBatteryStateText()
  text$ + #CRLF$ + "Watts: " + FormatSignedBatteryWatts(gBattery\DischargeRateMW, gBattery\ChargeRateMW)
  If gBattery\Charging And gBattery\EstimateValid
    timeText$ = FormatBatteryMinutes(gBattery\EstimateMinutes) + " to target"
  ElseIf gBattery\DisconnectedBattery And gBattery\InstantEstimateValid
    timeText$ = FormatBatteryMinutes(gBattery\InstantEstimateMinutes) + " now"
  ElseIf gBattery\EstimateValid
    timeText$ = FormatBatteryMinutes(gBattery\EstimateMinutes) + " average"
  ElseIf gBattery\RuntimeValid
    timeText$ = FormatBatteryMinutes(gBattery\RuntimeMinutes) + " Windows"
  ElseIf gBattery\Connected And gBattery\Charging = #False And gBattery\DisconnectedBattery = #False
    timeText$ = "not discharging"
  Else
    timeText$ = "calculating"
  EndIf
  If gBattery\SmoothedDrainPctPerHour > 0.0 And BatteryEffectiveMaxPercent() > gSettings\BatteryMinPercent
    fullRuntime$ = FormatBatteryMinutes(((BatteryEffectiveMaxPercent() - gSettings\BatteryMinPercent) / gBattery\SmoothedDrainPctPerHour) * 60.0)
  Else
    fullRuntime$ = "calculating"
  EndIf
  text$ + #CRLF$ + "Time: " + timeText$ + "; full-min " + fullRuntime$
  If gBatteryStableFullMWh > 0.0 And gBatteryStableDesignMWh > 0.0
    capacity$ = FormatWh(gBatteryStableFullMWh) + " / " + FormatWh(gBatteryStableDesignMWh)
    If gBatteryStableWearPercent > 0.0
      capacity$ + ", wear " + StrD(gBatteryStableWearPercent, 1) + "%"
    EndIf
  ElseIf gBattery\FullMWh > 0.0 And gBattery\DesignMWh > 0.0
    capacity$ = FormatWh(gBattery\FullMWh) + " / " + FormatWh(gBattery\DesignMWh)
    If gBattery\WearPercent > 0.0
      capacity$ + ", wear " + StrD(gBattery\WearPercent, 1) + "%"
    EndIf
  Else
    capacity$ = "Unknown"
  EndIf
  text$ + #CRLF$ + "Capacity: " + capacity$
  ProcedureReturn text$
EndProcedure

Procedure.s OverviewPowerPilotText()
  Protected text$
  Protected appUse$
  If gPowerPilotCpuWindowSeconds > 0.0 Or gPowerPilotCpuWindowTotalPercent > 0.0
    appUse$ = StrD(gPowerPilotCpuWindowMw, 2) + " mW, " + Str(gPowerPilotCpuWindowSecondsCost) + " sec"
  Else
    appUse$ = "sampling"
  EndIf
  text$ = "Read " + Str(ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)) + "s, log " + Str(ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440)) + "m; app " + appUse$
  text$ + #CRLF$ + "Energy Saver: " + OverviewShortModeName() + ", dim " + Str(ClampInt(gSettings\EnergySaverBrightness, 0, 100)) + "%"
  ProcedureReturn text$
EndProcedure

Procedure RefreshOverviewPanels()
  If MainWindowVisible() = #False
    ProcedureReturn
  EndIf
  If IsGadget(#GadgetOverviewBatteryState)
    SetGadgetTextIfChanged(#GadgetOverviewBatteryState, OverviewBatteryStateText())
  EndIf
  If IsGadget(#GadgetOverviewSaverState)
    SetGadgetTextIfChanged(#GadgetOverviewSaverState, OverviewEnergySaverText())
  EndIf
  If IsGadget(#GadgetOverviewRuntime)
    SetGadgetTextIfChanged(#GadgetOverviewRuntime, OverviewRuntimeText())
  EndIf
  If IsGadget(#GadgetOverviewPowerPilot)
    SetGadgetTextIfChanged(#GadgetOverviewPowerPilot, OverviewPowerPilotText())
  EndIf
EndProcedure

; Update the Battery Graph tab and redraw graph/stats after every battery
; refresh. Unknown text is only shown when no valid battery provider responded.
Procedure RefreshPowerPilotDrawDisplay()
  Protected now.q = Date()
  Protected nowCpu.q = CurrentProcessCpuTime100Ns()
  Protected cpuSeconds.d
  Protected cpuStart.d
  Protected normalizedCpuSeconds.d
  Protected elapsedSeconds.d
  Protected totalLogicalCpuSeconds.d
  Protected totalCpuPercent.d
  Protected processCpuShare.d
  Protected estimatedMw.d
  Protected drainBasisMW.d
  Protected drainBasisEstimated.i
  Protected drainBasisPctPerHour.d
  Protected windowMinutes.d
  Protected ppSeconds.q
  Protected windowStart.q
  Protected runtimeFullMWh.d = BatteryRuntimeFullMWh()
  Protected startIndex.i = -1
  Protected endIndex.i = -1
  Protected spanSeconds.d
  Protected interpolation.d
  Protected i.i
  Protected suffix$
  If gBatteryNativeFallbackUsed
    suffix$ = " fallback"
  EndIf
  If IsGadget(#GadgetPowerPilotDraw) = #False
    ProcedureReturn
  EndIf
  If nowCpu <= 0
    SetGadgetTextIfChanged(#GadgetPowerPilotDraw, "Unavailable" + suffix$)
    ProcedureReturn
  EndIf
  AddPowerPilotUsePoint(now, nowCpu)
  If gPowerPilotUsePointCount < 2
    SetGadgetTextIfChanged(#GadgetPowerPilotDraw, "Sampling 60s" + suffix$)
    ProcedureReturn
  EndIf
  windowStart = now - #PowerPilotUseWindowSeconds
  For i = gPowerPilotUsePointCount - 1 To 0 Step -1
    If gPowerPilotUsePoints(i)\Timestamp <= windowStart
      startIndex = i
      Break
    EndIf
  Next
  If startIndex < 0
    startIndex = 0
  EndIf
  If gPowerPilotUsePoints(startIndex)\Timestamp < windowStart And startIndex + 1 < gPowerPilotUsePointCount
    endIndex = startIndex + 1
    spanSeconds = gPowerPilotUsePoints(endIndex)\Timestamp - gPowerPilotUsePoints(startIndex)\Timestamp
    If spanSeconds > 0.0
      interpolation = (windowStart - gPowerPilotUsePoints(startIndex)\Timestamp) / spanSeconds
      If interpolation < 0.0 : interpolation = 0.0 : EndIf
      If interpolation > 1.0 : interpolation = 1.0 : EndIf
      cpuStart = gPowerPilotUsePoints(startIndex)\CpuTime100Ns + ((gPowerPilotUsePoints(endIndex)\CpuTime100Ns - gPowerPilotUsePoints(startIndex)\CpuTime100Ns) * interpolation)
      elapsedSeconds = now - windowStart
    EndIf
  EndIf
  If elapsedSeconds <= 0.0
    cpuStart = gPowerPilotUsePoints(startIndex)\CpuTime100Ns
    elapsedSeconds = now - gPowerPilotUsePoints(startIndex)\Timestamp
  EndIf
  cpuSeconds = (nowCpu - cpuStart) / 10000000.0
  If cpuSeconds < 0.0
    cpuSeconds = 0.0
  EndIf
  drainBasisMW = gBattery\DischargeRateMW
  If drainBasisMW <= 0.0 And runtimeFullMWh > 0.0
    drainBasisPctPerHour = gBattery\SmoothedDrainPctPerHour
    If drainBasisPctPerHour <= 0.0
      drainBasisPctPerHour = gSettings\BatteryLastDrainPctPerHour
    EndIf
    If drainBasisPctPerHour <= 0.0
      drainBasisPctPerHour = gSettings\BatteryStartupDrainPctPerHour
    EndIf
    If drainBasisPctPerHour > 0.0
      drainBasisMW = runtimeFullMWh * (drainBasisPctPerHour / 100.0)
      drainBasisEstimated = #True
    EndIf
  EndIf
  totalLogicalCpuSeconds = elapsedSeconds * CountCPUs()
  If totalLogicalCpuSeconds > 0.0
    processCpuShare = cpuSeconds / totalLogicalCpuSeconds
    If processCpuShare < 0.0 : processCpuShare = 0.0 : EndIf
    If processCpuShare > 1.0 : processCpuShare = 1.0 : EndIf
    totalCpuPercent = processCpuShare * 100.0
    normalizedCpuSeconds = elapsedSeconds * processCpuShare
    If normalizedCpuSeconds > #PowerPilotUseWindowSeconds
      normalizedCpuSeconds = #PowerPilotUseWindowSeconds
    EndIf
  EndIf
  If drainBasisMW > 0.0
    estimatedMw = drainBasisMW * processCpuShare
  EndIf
  gPowerPilotCpuWindowSeconds = normalizedCpuSeconds
  gPowerPilotCpuWindowTotalPercent = totalCpuPercent
  gPowerPilotCpuWindowMw = estimatedMw
  gPowerPilotCpuWindowDrainBasisMW = drainBasisMW
  gPowerPilotCpuWindowDrainBasisEstimated = drainBasisEstimated
  gPowerPilotCpuWindowDrainBasisPctPerHour = drainBasisPctPerHour
  If gPowerPilotCpuWindowSeconds > 0.0 Or gPowerPilotCpuWindowTotalPercent > 0.0
    If drainBasisMW > 0.0 And gPowerPilotCpuWindowMw > 0.0 And runtimeFullMWh > 0.0
      windowMinutes = (((BatteryEffectiveMaxPercent() - gSettings\BatteryMinPercent) / 100.0) * runtimeFullMWh / drainBasisMW) * 60.0
      ppSeconds = Round(windowMinutes * 60.0 * (gPowerPilotCpuWindowMw / drainBasisMW), #PB_Round_Nearest)
    EndIf
    gPowerPilotCpuWindowSecondsCost = ppSeconds
    SetGadgetTextIfChanged(#GadgetPowerPilotDraw, StrD(gPowerPilotCpuWindowMw, 2) + " mW, " + Str(ppSeconds) + " sec" + suffix$)
  Else
    SetGadgetTextIfChanged(#GadgetPowerPilotDraw, "Sampling 60s" + suffix$)
  EndIf
  RefreshOverviewPanels()
  RefreshPowerUseDetails()
EndProcedure

Procedure RefreshPowerUseDetails()
  Protected summary$
  Protected status$
  If IsGadget(#GadgetPowerUseSummary) = #False
    ProcedureReturn
  EndIf
  If gPowerPilotCpuWindowSeconds > 0.0 Or gPowerPilotCpuWindowTotalPercent > 0.0
    summary$ = "CPU time: " + StrD(gPowerPilotCpuWindowSeconds, 2) + " sec / 60 sec" + #CRLF$
    summary$ + "CPU load: " + StrD(gPowerPilotCpuWindowTotalPercent, 3) + "% total CPU" + #CRLF$
    summary$ + "App power draw: " + StrD(gPowerPilotCpuWindowMw, 2) + " mW" + #CRLF$
    summary$ + "Full-to-empty cost: about " + Str(gPowerPilotCpuWindowSecondsCost) + " sec"
  Else
    summary$ = "Waiting for 60 seconds of app CPU samples."
  EndIf
  If gBatteryNativeFallbackUsed
    status$ = "Source: WMI fallback."
  Else
    status$ = "Source: native Windows battery driver."
  EndIf
  If gBattery\DischargeRateMW > 0.0
    status$ + #CRLF$ + "Battery draw now: " + StrD(gBattery\DischargeRateMW / 1000.0, 2) + " W"
  ElseIf gPowerPilotCpuWindowDrainBasisEstimated And gPowerPilotCpuWindowDrainBasisMW > 0.0
    status$ + #CRLF$ + "Drain basis: about " + StrD(gPowerPilotCpuWindowDrainBasisMW / 1000.0, 2) + " W from " + StrD(gPowerPilotCpuWindowDrainBasisPctPerHour, 1) + "%/h."
  ElseIf gPowerPilotCpuWindowDrainBasisMW > 0.0
    status$ + #CRLF$ + "Drain basis: about " + StrD(gPowerPilotCpuWindowDrainBasisMW / 1000.0, 2) + " W."
  Else
    status$ + #CRLF$ + "Drain basis: unavailable."
  EndIf
  SetGadgetTextIfChanged(#GadgetPowerUseSummary, summary$)
  SetGadgetTextIfChanged(#GadgetPowerUseStatus, status$)
EndProcedure

Procedure RefreshBatteryDisplay()
  Protected connection$
  Protected charging$
  Protected state$
  Protected estimate$
  Protected instantEstimate$
  Protected runtime$
  Protected fullEstimate$
  Protected nominalEstimate$
  Protected wear$
  Protected maxCapacity$
  Protected pluggedIdleText$
  Protected floorText$ = " to " + Str(gSettings\BatteryMinPercent) + "%"
  Protected targetText$
  Protected ceilingPercent.d
  Protected estimateRate.d
  If MainWindowVisible() = #False
    ProcedureReturn
  EndIf
  If IsGadget(#GadgetBatteryPercent) = #False
    ProcedureReturn
  EndIf
  If gBattery\Valid = #False
    SetGadgetTextIfChanged(gFrameBatteryEstimate, "Time Estimates")
    SetGadgetText(#GadgetBatteryPercent, "Unknown")
    SetGadgetText(#GadgetBatteryConnection, "Unknown")
    SetGadgetText(#GadgetBatteryCharging, "Unknown")
    SetGadgetText(#GadgetBatteryCapacity, "Unknown")
    SetGadgetText(#GadgetBatteryRates, "Unknown")
    SetGadgetText(#GadgetBatteryVoltage, "Unknown")
    RefreshPowerPilotDrawDisplay()
    SetGadgetText(#GadgetBatteryEstimate, "Unknown")
    SetGadgetText(#GadgetBatteryInstantEstimate, "Unknown")
    SetGadgetText(#GadgetBatteryRuntime, "Unknown")
    SetGadgetText(#GadgetBatteryFullEstimate, "Unknown")
    SetGadgetText(#GadgetBatteryWear, "Unknown")
    SetGadgetText(#GadgetBatteryNominalEstimate, "Unknown")
    SetGadgetText(#GadgetBatteryMaxCapacity, "Unknown")
    SetGadgetText(#GadgetBatteryCycle, "Unknown")
    If BatteryGraphTabVisible()
      DrawBatteryGraph()
    EndIf
    RefreshBatteryTestDisplay()
    RefreshOverviewPanels()
    ProcedureReturn
  EndIf
  SetGadgetTextIfChanged(gFrameBatteryEstimate, "Time Estimates - read " + FormatDate("%hh:%ii:%ss", gBattery\Timestamp))
  ceilingPercent = BatteryEffectiveMaxPercent()
  If gBattery\Connected
    connection$ = "Plugged in"
  Else
    connection$ = "On battery"
  EndIf
  If gBattery\Charging
    charging$ = "Charging"
  ElseIf gBattery\DisconnectedBattery
    charging$ = "Discharging"
  Else
    charging$ = "Not charging"
  EndIf
  If gBattery\Connected
    state$ = "Plugged in"
  Else
    state$ = "On battery"
  EndIf
  If gBattery\Charging
    state$ + ", charging"
  ElseIf gBattery\Connected And gBattery\DisconnectedBattery
    state$ + ", calibration discharge"
  ElseIf gBattery\DisconnectedBattery
    state$ + ", discharging"
  Else
    state$ + ", idle"
  EndIf
  If gBattery\Charging
    targetText$ = " to " + StrD(ceilingPercent, 0) + "%"
    estimateRate = gBattery\SmoothedChargePctPerHour
  Else
    targetText$ = floorText$
    estimateRate = gBattery\SmoothedDrainPctPerHour
  EndIf
  If gBattery\Connected And gBattery\Charging = #False And gBattery\DisconnectedBattery = #False
    If gBattery\Percent >= ceilingPercent - 0.5
      pluggedIdleText$ = "At " + StrD(ceilingPercent, 0) + "% target"
    Else
      pluggedIdleText$ = "Plugged in, idle"
    EndIf
  Else
    pluggedIdleText$ = "Plugged in"
  EndIf
  If gBattery\EstimateValid
    If gBattery\Charging And gBattery\EstimateMinutes <= 0
      estimate$ = "At " + StrD(ceilingPercent, 0) + "% target"
    Else
      estimate$ = FormatBatteryMinutes(gBattery\EstimateMinutes) + targetText$ + " at " + StrD(estimateRate, 1) + "%/h"
      If gBattery\EstimateLowConfidence
        estimate$ + " low confidence"
      EndIf
    EndIf
  ElseIf gBattery\Connected
    If gBattery\Phase = #BatteryPhasePluggedDischargingCalibration
      estimate$ = "Waiting for drain data"
    Else
      estimate$ = pluggedIdleText$
    EndIf
  Else
    estimate$ = "Calculating"
  EndIf
  If gBattery\Charging
    If gBattery\EstimateValid And gBattery\EstimateMinutes <= 0
      instantEstimate$ = "At " + StrD(ceilingPercent, 0) + "% target"
    ElseIf gBattery\EstimateValid
      instantEstimate$ = "Using average"
    Else
      instantEstimate$ = "Calculating"
    EndIf
  ElseIf gBattery\InstantEstimateValid
    instantEstimate$ = FormatBatteryMinutes(gBattery\InstantEstimateMinutes) + targetText$
    If gBattery\EstimateLowConfidence
      instantEstimate$ + " low confidence"
    EndIf
  ElseIf gBattery\Connected
    If gBattery\Phase = #BatteryPhasePluggedDischargingCalibration
      instantEstimate$ = "Waiting for drain data"
    ElseIf gBattery\DisconnectedBattery = #False
      instantEstimate$ = "Not discharging"
    Else
      instantEstimate$ = "Plugged in"
    EndIf
  Else
    instantEstimate$ = "Calculating"
  EndIf
  If gBattery\Charging
    runtime$ = "Not reported"
  ElseIf gBattery\RuntimeValid
    runtime$ = FormatBatteryMinutes(gBattery\RuntimeMinutes)
  ElseIf gBattery\Connected
    runtime$ = "Not reported"
  Else
    runtime$ = "Unknown"
  EndIf
  If gBattery\SmoothedDrainPctPerHour > 0.0 And ceilingPercent > gSettings\BatteryMinPercent
    fullEstimate$ = FormatBatteryMinutes(((ceilingPercent - gSettings\BatteryMinPercent) / gBattery\SmoothedDrainPctPerHour) * 60.0) + " (" + StrD(ceilingPercent, 0) + "->" + Str(gSettings\BatteryMinPercent) + "%)"
  Else
    fullEstimate$ = "Calculating"
  EndIf
  nominalEstimate$ = "Unknown"
  If gBatteryStableDesignMWh > 0.0 And BatteryRuntimeFullMWh() > 0.0 And gBattery\SmoothedDrainPctPerHour > 0.0 And ceilingPercent > gSettings\BatteryMinPercent
    nominalEstimate$ = FormatBatteryMinutes((((ceilingPercent - gSettings\BatteryMinPercent) / gBattery\SmoothedDrainPctPerHour) * 60.0) * (gBatteryStableDesignMWh / BatteryRuntimeFullMWh()))
  ElseIf gBattery\DesignMWh > 0.0 And gBattery\FullMWh > 0.0 And gBattery\SmoothedDrainPctPerHour > 0.0 And ceilingPercent > gSettings\BatteryMinPercent
    nominalEstimate$ = FormatBatteryMinutes((((ceilingPercent - gSettings\BatteryMinPercent) / gBattery\SmoothedDrainPctPerHour) * 60.0) * (gBattery\DesignMWh / gBattery\FullMWh))
  ElseIf gBattery\Connected
    nominalEstimate$ = "Plugged in"
  ElseIf gBattery\SmoothedDrainPctPerHour <= 0.0
    nominalEstimate$ = "Calculating"
  EndIf
  If gBatteryStableDesignMWh > 0.0 And gBatteryStableFullMWh > 0.0
    wear$ = StrD(gBatteryStableWearPercent, 1) + "%"
    maxCapacity$ = StrD(gBatteryStableFullMWh, 0) + " / " + StrD(gBatteryStableDesignMWh, 0) + " mWh stable"
  ElseIf gBattery\DesignMWh > 0.0 And gBattery\FullMWh > 0.0
    wear$ = StrD(gBattery\WearPercent, 1) + "%"
    maxCapacity$ = StrD(gBattery\FullMWh, 0) + " / " + StrD(gBattery\DesignMWh, 0) + " mWh"
  ElseIf gBattery\FullMWh > 0.0
    wear$ = "Unknown"
    maxCapacity$ = StrD(gBattery\FullMWh, 0) + " mWh"
  Else
    wear$ = "Unknown"
    maxCapacity$ = "Unknown"
  EndIf
  SetGadgetTextIfChanged(#GadgetBatteryPercent, StrD(gBattery\Percent, 1) + "%")
  SetGadgetTextIfChanged(#GadgetBatteryConnection, state$)
  SetGadgetTextIfChanged(#GadgetBatteryCharging, "")
  SetGadgetTextIfChanged(#GadgetBatteryCapacity, StrD(gBattery\RemainingMWh, 0) + " mWh")
  SetGadgetTextIfChanged(#GadgetBatteryRates, FormatSignedBatteryWatts(gBattery\DischargeRateMW, gBattery\ChargeRateMW))
  If gBattery\VoltageMV > 0.0
    SetGadgetTextIfChanged(#GadgetBatteryVoltage, StrD(gBattery\VoltageMV / 1000.0, 2) + " V")
  Else
    SetGadgetTextIfChanged(#GadgetBatteryVoltage, "Unknown")
  EndIf
  RefreshPowerPilotDrawDisplay()
  RefreshOverviewPanels()
  SetGadgetTextIfChanged(#GadgetBatteryEstimate, estimate$)
  SetGadgetTextIfChanged(#GadgetBatteryInstantEstimate, instantEstimate$)
  SetGadgetTextIfChanged(#GadgetBatteryRuntime, runtime$)
  SetGadgetTextIfChanged(#GadgetBatteryFullEstimate, fullEstimate$)
  SetGadgetTextIfChanged(#GadgetBatteryWear, wear$)
  SetGadgetTextIfChanged(#GadgetBatteryNominalEstimate, nominalEstimate$)
  SetGadgetTextIfChanged(#GadgetBatteryMaxCapacity, maxCapacity$)
  SetGadgetTextIfChanged(#GadgetBatteryCycle, Str(gBattery\CycleCount))
  If BatteryGraphTabVisible()
    DrawBatteryGraph()
  EndIf
  RefreshBatteryStatsSummary()
  RefreshBatteryTestDisplay()
EndProcedure

Macro DrawBatteryMarkerGlyph(markerDrawX, markerDrawY, markerText)
  shortLabel$ = markerText
  If shortLabel$ <> ""
    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(0, 0, 0))
    For labelOffsetY = -UiDpiScaleY(2) To UiDpiScaleY(2)
      For labelOffsetX = -UiDpiScaleX(2) To UiDpiScaleX(2)
        If labelOffsetX <> 0 Or labelOffsetY <> 0
          DrawText(markerDrawX + labelOffsetX, markerDrawY + labelOffsetY, shortLabel$)
        EndIf
      Next
    Next
    FrontColor(RGB(255, 255, 255))
    DrawText(markerDrawX, markerDrawY, shortLabel$)
  EndIf
EndMacro

Macro DrawStackedBatteryMarkerLabel(markerX, markerText)
  shortLabel$ = markerText
  If shortLabel$ <> ""
    x = markerX
    labelWidth = TextWidth(shortLabel$)
    labelColumnIndex = -1
    For occupiedIndex = 0 To labelColumnCount - 1
      If Abs(x - labelColumnX(occupiedIndex)) < UiDpiScaleX(10)
        labelColumnIndex = occupiedIndex
        Break
      EndIf
    Next
    If labelColumnIndex < 0
      If labelColumnCount <= 127
        labelColumnIndex = labelColumnCount
        labelColumnX(labelColumnIndex) = x
        labelColumnNextSlot(labelColumnIndex) = 0
        labelColumnCount + 1
      Else
        labelColumnIndex = 127
      EndIf
    EndIf
    labelSlot = labelColumnNextSlot(labelColumnIndex)
    labelColumnNextSlot(labelColumnIndex) + 1
    If labelSlot > labelMaxSlots : labelSlot = labelMaxSlots : EndIf
    eventLabelY = top + UiDpiScaleY(3) + (labelSlot * labelStackStep)
    labelDrawLeft = x - (labelWidth / 2)
    If labelDrawLeft < left + UiDpiScaleX(2) : labelDrawLeft = left + UiDpiScaleX(2) : EndIf
    If labelDrawLeft + labelWidth > right : labelDrawLeft = right - labelWidth : EndIf
    If labelDrawLeft < left + UiDpiScaleX(2) : labelDrawLeft = left + UiDpiScaleX(2) : EndIf
    DrawBatteryMarkerGlyph(labelDrawLeft, eventLabelY, shortLabel$)
  EndIf
EndMacro

; Draw the selectable gliding battery graph. The graph always uses a 0%-100%
; vertical scale so different windows are visually comparable. Line color is
; contextual: blue for continuous normal samples, green when Energy Saver was
; active, and orange when the app has a break/offline gap and must draw a flat
; discontinued span instead of pretending it measured a real battery slope.
; Drawing goes to an offscreen image first, then blits once to the canvas to
; avoid flicker during 1-second Battery Test refreshes.
Procedure DrawBatteryGraph()
  Protected buffer.i
  Protected width.i
  Protected height.i
  Protected logicalWidth.i
  Protected logicalHeight.i
  Protected left.i = UiDpiScaleX(54)
  Protected top.i = UiDpiScaleY(64)
  Protected right.i
  Protected bottom.i
  Protected i.i
  Protected tick.q
  Protected startTime.q
  Protected endTime.q
  Protected graphWindowSeconds.q
  Protected firstHour.q
  Protected visibleCount.i
  Protected x1.i
  Protected y1.i
  Protected x2.i
  Protected y2.i
  Protected pathX1.d
  Protected pathY1.d
  Protected pathX2.d
  Protected pathY2.d
  Protected pathYJump.d
  Protected plotTop.d
  Protected plotBottom.d
  Protected plotHeight.d
  Protected plotLineInset.d = 1.5 * UiDpiStrokeScale()
  Protected x.i
  Protected labelHeight.i
  Protected legendY.i
  Protected legendLineY.i
  Protected legendTextY.i
  Protected legendX.i
  Protected minPercent.d = 0.0
  Protected maxPercent.d = 100.0
  Protected span.d
  Protected percent.d
  Protected xScale.d
  Protected flatSegment.i
  Protected segmentKind.i
  Protected previousSegmentKind.i = -1
  Protected markerColor.i
  Protected lastMarkerX.i = -99999
  Protected lastMarkerColor.i = -1
  Protected segmentStart.q
  Protected segmentEnd.q
  Protected drawStart.q
  Protected drawEnd.q
  Protected transitionTime.q
  Protected visiblePointCount.i
  Protected eventLabelY.i
  Protected label$
  Protected shortLabel$
  Protected eventX.i
  Protected labelWidth.i
  Protected labelDrawLeft.i
  Protected labelDrawRight.i
  Protected occupiedIndex.i
  Protected labelColumnCount.i
  Protected labelColumnIndex.i
  Protected labelSlot.i
  Protected labelMaxSlots.i = 7
  Protected labelStackStep.i
  Protected labelOffsetX.i
  Protected labelOffsetY.i
  Dim labelColumnX.i(127)
  Dim labelColumnNextSlot.i(127)
  If IsGadget(#GadgetBatteryGraph) = #False
    ProcedureReturn
  EndIf
  logicalWidth = GadgetWidth(#GadgetBatteryGraph)
  logicalHeight = GadgetHeight(#GadgetBatteryGraph)
  width = DesktopScaledX(logicalWidth)
  height = DesktopScaledY(logicalHeight)
  If width <= 0 Or height <= 0
    ProcedureReturn
  EndIf
  buffer = CreateImage(#PB_Any, width, height, 32, RGB(250, 250, 248))
  If buffer = 0
    ProcedureReturn
  EndIf
  right = width - UiDpiScaleX(14)
  bottom = height - UiDpiScaleY(36)
  If gSettings\BatteryGraphShowMarkers = #False
    top = UiDpiScaleY(42)
  EndIf
  plotTop = top + plotLineInset
  plotBottom = bottom - plotLineInset
  plotHeight = plotBottom - plotTop
  endTime = Date()
  If gBatteryGraphCount > 0 And gBatteryGraph(gBatteryGraphCount - 1)\Timestamp > endTime
    endTime = gBatteryGraph(gBatteryGraphCount - 1)\Timestamp
  EndIf
  graphWindowSeconds = BatteryGraphWindowSeconds()
  startTime = endTime - graphWindowSeconds
  xScale = (right - left) / graphWindowSeconds
  span = maxPercent - minPercent
  If span <= 0.0 : span = 1.0 : EndIf
  If StartDrawing(ImageOutput(buffer))
    If gFontUi : DrawingFont(FontID(gFontUi)) : EndIf
    Box(0, 0, width, height, RGB(250, 250, 248))
    labelHeight = TextHeight("100%")
    labelStackStep = labelHeight + UiDpiScaleY(6)
    legendY = UiDpiScaleY(8)
    legendLineY = legendY + (labelHeight / 2)
    DrawingMode(#PB_2DDrawing_Default)
    ; Hour marks are computed from wall-clock hours so date labels stay stable
    ; as the gliding window moves.
    firstHour = ParseDate("%yyyy-%mm-%dd %hh:%ii:%ss", FormatDate("%yyyy-%mm-%dd %hh:00:00", startTime))
    If firstHour < startTime
      firstHour = AddDate(firstHour, #PB_Date_Hour, 1)
    EndIf
    tick = firstHour
    While tick <= endTime
      x = left + ((tick - startTime) * xScale)
      If x >= left And x <= right
        If FormatDate("%hh", tick) = "00"
          FrontColor(RGB(154, 154, 148))
        Else
          FrontColor(RGB(218, 218, 214))
        EndIf
        LineXY(x, top, x, bottom)
      EndIf
      tick = AddDate(tick, #PB_Date_Hour, 1)
    Wend
    FrontColor(RGB(188, 188, 184))
    For i = 0 To 4
      y1 = top + ((bottom - top) * i / 4)
      LineXY(left, y1, right, y1)
    Next
    Box(0, 0, width, 1, RGB(214, 214, 210))
    Box(0, height - 1, width, 1, RGB(142, 142, 138))
    Box(0, 0, 1, height, RGB(214, 214, 210))
    Box(width - 1, 0, 1, height, RGB(214, 214, 210))
    FrontColor(RGB(48, 48, 48))
    Box(left, top, right - left + 1, 1, RGB(48, 48, 48))
    Box(left, top, 1, bottom - top + 1, RGB(48, 48, 48))
    Box(right, top, 1, bottom - top + 1, RGB(48, 48, 48))
    Box(left, bottom, right - left + 1, 1, RGB(48, 48, 48))
    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(24, 24, 24))
    DrawText(UiDpiScaleX(6), top - (labelHeight / 2), StrD(maxPercent, 0) + "%")
    DrawText(UiDpiScaleX(8), bottom - (labelHeight / 2), StrD(minPercent, 0) + "%")
    FrontColor(RGB(0, 96, 190))
    LineXY(left + UiDpiScaleX(78), legendLineY, left + UiDpiScaleX(108), legendLineY)
    LineXY(left + UiDpiScaleX(78), legendLineY + UiDpiScaleY(1), left + UiDpiScaleX(108), legendLineY + UiDpiScaleY(1))
    DrawText(left + UiDpiScaleX(114), legendY, "normal")
    FrontColor(RGB(0, 140, 72))
    LineXY(left + UiDpiScaleX(218), legendLineY, left + UiDpiScaleX(248), legendLineY)
    LineXY(left + UiDpiScaleX(218), legendLineY + UiDpiScaleY(1), left + UiDpiScaleX(248), legendLineY + UiDpiScaleY(1))
    DrawText(left + UiDpiScaleX(254), legendY, "Energy Saver")
    FrontColor(RGB(245, 132, 0))
    LineXY(left + UiDpiScaleX(398), legendLineY, left + UiDpiScaleX(428), legendLineY)
    LineXY(left + UiDpiScaleX(398), legendLineY + UiDpiScaleY(1), left + UiDpiScaleX(428), legendLineY + UiDpiScaleY(1))
    DrawText(left + UiDpiScaleX(434), legendY, "offline/discontinued")
    If gSettings\BatteryGraphShowMarkers
      FrontColor(RGB(112, 42, 42))
      legendTextY = legendY + labelHeight + UiDpiScaleY(4)
      legendX = left
      DrawText(legendX, legendTextY, "Marks:")
      legendX + TextWidth("Marks:") + UiDpiScaleX(8)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "Z")
      legendX + TextWidth("Z") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "sleep")
      legendX + TextWidth("sleep") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "H")
      legendX + TextWidth("H") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "hib")
      legendX + TextWidth("hib") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "W")
      legendX + TextWidth("W") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "wake")
      legendX + TextWidth("wake") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "S")
      legendX + TextWidth("S") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "shut")
      legendX + TextWidth("shut") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "P")
      legendX + TextWidth("P") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "start")
      legendX + TextWidth("start") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "!")
      legendX + TextWidth("!") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "bad")
      legendX + TextWidth("bad") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "0")
      legendX + TextWidth("0") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "offline")
      legendX + TextWidth("offline") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "1")
      legendX + TextWidth("1") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "online")
      legendX + TextWidth("online") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "E")
      legendX + TextWidth("E") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "saver")
      legendX + TextWidth("saver") + UiDpiScaleX(12)
      DrawBatteryMarkerGlyph(legendX, legendTextY, "N")
      legendX + TextWidth("N") + UiDpiScaleX(5)
      FrontColor(RGB(112, 42, 42))
      DrawText(legendX, legendTextY, "normal")
    EndIf
    FrontColor(RGB(0, 0, 0))
    tick = firstHour
    While tick <= endTime
      x = left + ((tick - startTime) * xScale)
      If x >= left And x <= right
        If graphWindowSeconds <= 86400 Or Val(FormatDate("%hh", tick)) % 4 = 0
          label$ = FormatDate("%hh", tick)
          If FormatDate("%hh", tick) = "00"
            FrontColor(RGB(32, 32, 32))
          Else
            FrontColor(RGB(74, 74, 70))
          EndIf
          DrawText(x - (TextWidth(label$) / 2), bottom + UiDpiScaleY(6), label$)
        EndIf
      EndIf
      tick = AddDate(tick, #PB_Date_Hour, 1)
    Wend
    DrawingMode(#PB_2DDrawing_Default)
    ; Draw PC power-event markers before the battery line so the line remains
    ; visible over the marker.
    i = 0
    While i < gBatteryEventCount
      If gBatteryEvents(i)\Timestamp >= startTime And gBatteryEvents(i)\Timestamp <= endTime
        eventX = left + ((gBatteryEvents(i)\Timestamp - startTime) * xScale)
        FrontColor(RGB(190, 35, 35))
        LineXY(eventX, top, eventX, bottom)
        i + 1
      Else
        i + 1
      EndIf
    Wend
    ; Draw color-change markers as one-pixel raster lines behind the battery
    ; stroke. This keeps them visible without making the graph line look fat.
    If gBatteryGraphCount > 1
      previousSegmentKind = -1
      lastMarkerX = -99999
      lastMarkerColor = -1
      For i = 1 To gBatteryGraphCount - 1
        If BatteryGraphSegmentVisible(i, startTime, endTime) = #False
          Continue
        EndIf
        segmentStart = gBatteryGraph(i - 1)\Timestamp
        segmentEnd = gBatteryGraph(i)\Timestamp
        flatSegment = BatteryGraphOfflineGap(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp)
        If flatSegment
          segmentKind = 2
          markerColor = RGB(245, 132, 0)
        ElseIf gBatteryGraph(i - 1)\EnergySaverOn Or gBatteryGraph(i)\EnergySaverOn
          segmentKind = 1
          markerColor = RGB(0, 140, 72)
        Else
          segmentKind = 0
          markerColor = RGB(0, 96, 190)
        EndIf
        If previousSegmentKind >= 0 And segmentKind <> previousSegmentKind
          transitionTime = segmentStart
          If transitionTime < startTime : transitionTime = startTime : EndIf
          If transitionTime > endTime : transitionTime = endTime : EndIf
          x = Round(left + ((transitionTime - startTime) * xScale), #PB_Round_Nearest)
          If x >= left And x <= right And (markerColor <> lastMarkerColor Or Abs(x - lastMarkerX) > UiDpiScaleX(6))
            FrontColor(markerColor)
            LineXY(x, top + UiDpiScaleY(1), x, bottom - UiDpiScaleY(1))
            lastMarkerX = x
            lastMarkerColor = markerColor
          EndIf
        EndIf
        If flatSegment = #False And gBatteryGraph(i - 1)\EnergySaverOn <> gBatteryGraph(i)\EnergySaverOn And segmentEnd >= startTime And segmentEnd <= endTime And (i + 1 >= gBatteryGraphCount Or BatteryGraphOfflineGap(gBatteryGraph(i)\Timestamp, gBatteryGraph(i + 1)\Timestamp) = #False)
          x = Round(left + ((segmentEnd - startTime) * xScale), #PB_Round_Nearest)
          If gBatteryGraph(i)\EnergySaverOn
            markerColor = RGB(0, 140, 72)
            shortLabel$ = "E"
          Else
            markerColor = RGB(0, 96, 190)
            shortLabel$ = "N"
          EndIf
          If x >= left And x <= right And (markerColor <> lastMarkerColor Or Abs(x - lastMarkerX) > UiDpiScaleX(6))
            FrontColor(markerColor)
            LineXY(x, top + UiDpiScaleY(1), x, bottom - UiDpiScaleY(1))
            lastMarkerX = x
            lastMarkerColor = markerColor
          EndIf
        EndIf
        previousSegmentKind = segmentKind
      Next
    EndIf
    StopDrawing()
  EndIf
  If gBatteryGraphCount > 1
    If StartVectorDrawing(ImageVectorOutput(buffer))
      For i = 1 To gBatteryGraphCount - 1
        If BatteryGraphSegmentVisible(i, startTime, endTime) = #False
          Continue
        EndIf
        segmentStart = gBatteryGraph(i - 1)\Timestamp
        segmentEnd = gBatteryGraph(i)\Timestamp
        drawStart = segmentStart
        If drawStart < startTime : drawStart = startTime : EndIf
        drawEnd = segmentEnd
        If drawEnd > endTime : drawEnd = endTime : EndIf
        If drawEnd < drawStart
          Continue
        EndIf
        pathX1 = left + ((drawStart - startTime) * xScale)
        pathX2 = left + ((drawEnd - startTime) * xScale)
        ; Orange means the app had no continuous measurements. Hold the last
        ; known percent flat, then jump at the next observed sample instead of
        ; inventing a charge/discharge slope while the PC was off.
        flatSegment = BatteryGraphOfflineGap(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp)
        If flatSegment
          percent = gBatteryGraph(i - 1)\Percent
          If percent < minPercent : percent = minPercent : EndIf
          If percent > maxPercent : percent = maxPercent : EndIf
          pathY1 = plotBottom - (plotHeight * (percent - minPercent) / span)
          pathY2 = pathY1
          segmentKind = 2
          VectorSourceColor(RGBA(245, 132, 0, 255))
        Else
          percent = BatteryGraphSegmentPercentAt(i, drawStart)
          If percent < minPercent : percent = minPercent : EndIf
          If percent > maxPercent : percent = maxPercent : EndIf
          pathY1 = plotBottom - (plotHeight * (percent - minPercent) / span)
          percent = BatteryGraphSegmentPercentAt(i, drawEnd)
          If percent < minPercent : percent = minPercent : EndIf
          If percent > maxPercent : percent = maxPercent : EndIf
          pathY2 = plotBottom - (plotHeight * (percent - minPercent) / span)
          If gBatteryGraph(i - 1)\EnergySaverOn Or gBatteryGraph(i)\EnergySaverOn
            segmentKind = 1
            VectorSourceColor(RGBA(0, 140, 72, 255))
          Else
            segmentKind = 0
            VectorSourceColor(RGBA(0, 96, 190, 255))
          EndIf
        EndIf
        MovePathCursor(pathX1, pathY1)
        AddPathLine(pathX2, pathY2)
        If flatSegment And segmentEnd >= startTime And segmentEnd <= endTime
          percent = gBatteryGraph(i)\Percent
          If percent < minPercent : percent = minPercent : EndIf
          If percent > maxPercent : percent = maxPercent : EndIf
          pathYJump = plotBottom - (plotHeight * (percent - minPercent) / span)
          AddPathLine(pathX2, pathYJump)
        EndIf
        StrokePath(2.4 * UiDpiStrokeScale(), #PB_Path_RoundEnd | #PB_Path_RoundCorner)
        previousSegmentKind = segmentKind
        visibleCount + 1
      Next
      StopVectorDrawing()
    EndIf
  EndIf
  If visibleCount = 0 And gBatteryGraphCount > 0
    If StartDrawing(ImageOutput(buffer))
      DrawingMode(#PB_2DDrawing_Default)
      For i = 0 To gBatteryGraphCount - 1
        If gBatteryGraph(i)\Timestamp >= startTime And gBatteryGraph(i)\Timestamp <= endTime
          x = Round(left + ((gBatteryGraph(i)\Timestamp - startTime) * xScale), #PB_Round_Nearest)
          percent = gBatteryGraph(i)\Percent
          If percent < minPercent : percent = minPercent : EndIf
          If percent > maxPercent : percent = maxPercent : EndIf
          y1 = Round(plotBottom - (plotHeight * (percent - minPercent) / span), #PB_Round_Nearest)
          If gBatteryGraph(i)\EnergySaverOn
            Circle(x, y1, UiDpiScaleX(2), RGB(0, 140, 72))
          Else
            Circle(x, y1, UiDpiScaleX(2), RGB(0, 96, 190))
          EndIf
          visiblePointCount + 1
        EndIf
      Next
      StopDrawing()
    EndIf
  EndIf
  If visibleCount > 0
    If StartDrawing(ImageOutput(buffer))
      FrontColor(RGB(48, 48, 48))
      Box(left, top, right - left + 1, 1, RGB(48, 48, 48))
      Box(left, top, 1, bottom - top + 1, RGB(48, 48, 48))
      Box(right, top, 1, bottom - top + 1, RGB(48, 48, 48))
      Box(left, bottom, right - left + 1, 1, RGB(48, 48, 48))
      StopDrawing()
    EndIf
  EndIf
  If gSettings\BatteryGraphShowMarkers
    If StartDrawing(ImageOutput(buffer))
    If gFontUi : DrawingFont(FontID(gFontUi)) : EndIf
    ; Marker letters are drawn last as white text over a black offset shadow so
    ; the battery line, grid, and marker strokes never cut through identifiers.
    labelColumnCount = 0
    For occupiedIndex = 0 To 127
      labelColumnX(occupiedIndex) = 0
      labelColumnNextSlot(occupiedIndex) = 0
    Next
    DrawingMode(#PB_2DDrawing_Transparent)
    If gBatteryGraphCount > 1
      previousSegmentKind = -1
      lastMarkerX = -99999
      lastMarkerColor = -1
      For i = 1 To gBatteryGraphCount - 1
        If BatteryGraphSegmentVisible(i, startTime, endTime) = #False
          Continue
        EndIf
        segmentStart = gBatteryGraph(i - 1)\Timestamp
        segmentEnd = gBatteryGraph(i)\Timestamp
        flatSegment = BatteryGraphOfflineGap(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp)
        If flatSegment
          segmentKind = 2
          markerColor = RGB(176, 78, 0)
        ElseIf gBatteryGraph(i - 1)\EnergySaverOn Or gBatteryGraph(i)\EnergySaverOn
          segmentKind = 1
          markerColor = RGB(0, 78, 42)
        Else
          segmentKind = 0
          markerColor = RGB(0, 55, 125)
        EndIf
        If previousSegmentKind >= 0 And segmentKind = 2 And segmentKind <> previousSegmentKind
          transitionTime = segmentStart
          If transitionTime < startTime : transitionTime = startTime : EndIf
          If transitionTime > endTime : transitionTime = endTime : EndIf
          x = Round(left + ((transitionTime - startTime) * xScale), #PB_Round_Nearest)
          If x >= left And x <= right And (markerColor <> lastMarkerColor Or Abs(x - lastMarkerX) > UiDpiScaleX(6))
            FrontColor(markerColor)
            DrawStackedBatteryMarkerLabel(x, "0")
            If BatteryIntervalHasSleepHibernateBreak(segmentStart, segmentEnd) And BatteryIntervalHasSleepHibernateMarkerNearX(segmentStart, segmentEnd, x, startTime, left, xScale, UiDpiScaleX(10)) = #False
              FrontColor(RGB(82, 12, 12))
              DrawStackedBatteryMarkerLabel(x, "Z")
            EndIf
            lastMarkerX = x
            lastMarkerColor = markerColor
          EndIf
        EndIf
        previousSegmentKind = segmentKind
      Next
    EndIf
    i = 0
    While i < gBatteryEventCount
      If gBatteryEvents(i)\Timestamp >= startTime And gBatteryEvents(i)\Timestamp <= endTime
        eventX = left + ((gBatteryEvents(i)\Timestamp - startTime) * xScale)
        shortLabel$ = BatteryEventShortName(gBatteryEvents(i)\Name)
        If BatteryEventIsSleepHibernate(gBatteryEvents(i)\Name)
          shortLabel$ = "H"
        EndIf
        FrontColor(RGB(82, 12, 12))
        DrawStackedBatteryMarkerLabel(eventX, shortLabel$)
      EndIf
      i + 1
    Wend
    If gBatteryGraphCount > 1
      previousSegmentKind = -1
      lastMarkerX = -99999
      lastMarkerColor = -1
      For i = 1 To gBatteryGraphCount - 1
        If BatteryGraphSegmentVisible(i, startTime, endTime) = #False
          Continue
        EndIf
        segmentStart = gBatteryGraph(i - 1)\Timestamp
        segmentEnd = gBatteryGraph(i)\Timestamp
        flatSegment = BatteryGraphOfflineGap(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp)
        If flatSegment
          segmentKind = 2
          markerColor = RGB(176, 78, 0)
        ElseIf gBatteryGraph(i - 1)\EnergySaverOn Or gBatteryGraph(i)\EnergySaverOn
          segmentKind = 1
          markerColor = RGB(0, 78, 42)
        Else
          segmentKind = 0
          markerColor = RGB(0, 55, 125)
        EndIf
        If previousSegmentKind >= 0 And segmentKind <> previousSegmentKind
          transitionTime = segmentStart
          If transitionTime < startTime : transitionTime = startTime : EndIf
          If transitionTime > endTime : transitionTime = endTime : EndIf
          x = Round(left + ((transitionTime - startTime) * xScale), #PB_Round_Nearest)
          If x >= left And x <= right And (markerColor <> lastMarkerColor Or Abs(x - lastMarkerX) > UiDpiScaleX(6))
            If segmentKind = 2
              ; Offline-start markers are drawn in an earlier pass so real
              ; events on the same line stack under the 0 marker.
            Else
              If previousSegmentKind = 2
                FrontColor(RGB(176, 78, 0))
                DrawStackedBatteryMarkerLabel(x, "1")
              EndIf
              If segmentKind = 1
                shortLabel$ = "E"
              Else
                shortLabel$ = "N"
              EndIf
              FrontColor(markerColor)
              DrawStackedBatteryMarkerLabel(x, shortLabel$)
            EndIf
            lastMarkerX = x
            lastMarkerColor = markerColor
          EndIf
        EndIf
        If flatSegment = #False And gBatteryGraph(i - 1)\EnergySaverOn <> gBatteryGraph(i)\EnergySaverOn And segmentEnd >= startTime And segmentEnd <= endTime And (i + 1 >= gBatteryGraphCount Or BatteryGraphOfflineGap(gBatteryGraph(i)\Timestamp, gBatteryGraph(i + 1)\Timestamp) = #False)
          x = Round(left + ((segmentEnd - startTime) * xScale), #PB_Round_Nearest)
          If gBatteryGraph(i)\EnergySaverOn
            markerColor = RGB(0, 78, 42)
            shortLabel$ = "E"
          Else
            markerColor = RGB(0, 55, 125)
            shortLabel$ = "N"
          EndIf
          If x >= left And x <= right And (markerColor <> lastMarkerColor Or Abs(x - lastMarkerX) > UiDpiScaleX(6))
            FrontColor(markerColor)
            DrawStackedBatteryMarkerLabel(x, shortLabel$)
            lastMarkerX = x
            lastMarkerColor = markerColor
          EndIf
        EndIf
        previousSegmentKind = segmentKind
      Next
    EndIf
      StopDrawing()
    EndIf
  EndIf
  If gBatteryGraphCount = 0 Or (visibleCount = 0 And visiblePointCount = 0)
    If StartDrawing(ImageOutput(buffer))
      If gFontUi : DrawingFont(FontID(gFontUi)) : EndIf
      DrawingMode(#PB_2DDrawing_Transparent)
      FrontColor(RGB(70, 70, 70))
      DrawText(left + UiDpiScaleX(12), top + UiDpiScaleY(46), "Waiting for battery samples")
      StopDrawing()
    EndIf
  EndIf
  If StartDrawing(CanvasOutput(#GadgetBatteryGraph))
    DrawImage(ImageID(buffer), 0, 0)
    StopDrawing()
  EndIf
  FreeImage(buffer)
EndProcedure

Procedure.s WrapTooltipLine(line$, maxColumn.i)
  Protected result$
  Protected current$
  Protected word$
  Protected wordIndex.i
  Protected wordCount.i
  line$ = Trim(line$)
  If Len(line$) <= maxColumn
    ProcedureReturn line$
  EndIf
  wordCount = CountString(line$, " ") + 1
  For wordIndex = 1 To wordCount
    word$ = StringField(line$, wordIndex, " ")
    If word$ = ""
      Continue
    EndIf
    If current$ = ""
      current$ = word$
    ElseIf Len(current$) + 1 + Len(word$) <= maxColumn
      current$ + " " + word$
    Else
      If result$ <> "" : result$ + #CRLF$ : EndIf
      result$ + current$
      current$ = word$
    EndIf
  Next
  If current$ <> ""
    If result$ <> "" : result$ + #CRLF$ : EndIf
    result$ + current$
  EndIf
  ProcedureReturn result$
EndProcedure

Procedure.s WrapTooltipText(text$)
  Protected normalized$
  Protected result$
  Protected line$
  Protected lineIndex.i
  Protected lineCount.i
  If text$ = ""
    ProcedureReturn ""
  EndIf
  normalized$ = ReplaceString(text$, #CRLF$, #LF$)
  normalized$ = ReplaceString(normalized$, #CR$, #LF$)
  lineCount = CountString(normalized$, #LF$) + 1
  For lineIndex = 1 To lineCount
    line$ = WrapTooltipLine(StringField(normalized$, lineIndex, #LF$), #TooltipWrapColumn)
    If lineIndex > 1 : result$ + #CRLF$ : EndIf
    result$ + line$
  Next
  ProcedureReturn result$
EndProcedure

; Tooltip wrapper guards against gadgets that are not available in all states.
Procedure SetTip(gadget.i, text$)
  If IsGadget(gadget)
    GadgetToolTip(gadget, WrapTooltipText(text$))
  EndIf
EndProcedure

; Tooltips can be turned off by the user without rebuilding the UI.
Procedure ApplyToolTips()
  Protected enabled.i = Bool(gSettings\ShowToolTips)
  Protected text$

  If enabled
    SetTip(#GadgetPanel, "Overview shows status. Plans edits CPU behavior. Battery tabs show history, estimates, and logs.")
    SetTip(gIntroOverview, "Use the Windows power mode slider. PowerPilot follows it with Maximum, Balanced, or Battery.")
    SetTip(gFrameProcessor, "Concise CPU and graphics summary.")
    SetTip(#GadgetCpuInfo, "Local CPU identity, core count, and memory.")
    SetTip(gFrameState, "Current plan follow, battery state, Energy Saver state, and latest action.")
    SetTip(#GadgetActivePlan, "The Windows power plan currently active.")
    SetTip(#GadgetPowerSource, "Windows power mode: Best performance, Balanced, or Best power efficiency.")
    SetTip(#GadgetOverviewBatteryState, "Current battery percent and live charge/discharge state.")
    SetTip(#GadgetOverviewSaverState, "Current Windows Energy Saver state and PowerPilot policy.")
    SetTip(#GadgetLastAction, "Most recent automatic or manual action.")
    SetTip(gFrameOverviewBattery, "Battery runtime, draw, and capacity summary.")
    SetTip(#GadgetOverviewRuntime, "Compact live battery estimate summary from Windows and PowerPilot.")
    SetTip(#GadgetGpuInfo, "Detected GPU names. Generic iGPU names may be refined from local CPU data.")
    SetTip(gFrameStartup, "PowerPilot cadence, Energy Saver policy, app use, and startup settings.")
    SetTip(#GadgetOverviewPowerPilot, "Read/log cadence, estimated app use, and Energy Saver policy.")
    SetTip(#GadgetAutoStart, "Start PowerPilot with Windows in the tray.")
    SetTip(#GadgetKeepSettings, "Keep PowerPilot settings and edited plans during reinstall or update.")
    SetTip(#GadgetThrottleMaintenance, "In efficiency mode, ask Windows to slow safe background maintenance.")
    SetTip(#GadgetDeepIdleSaver, "In tray mode, reduce hidden refresh work and tune the Battery plan for deeper idle.")
    SetTip(#GadgetEnergySaverMode, "How Energy Saver is set on PowerPilot plans.")
    SetTip(#GadgetEnergySaverThreshold, "Battery percent where Windows Energy Saver turns on in automatic mode.")
    SetTip(#GadgetEnergySaverBrightness, "Brightness scale Windows applies while Energy Saver is active.")
    SetTip(#GadgetBatteryLowWarningPercent, "Windows low-battery warning level for PowerPilot plans.")
    SetTip(#GadgetBatteryReservePercent, "Windows reserve-battery warning level for PowerPilot plans. Windows does not expose a separate reserve action.")
    SetTip(#GadgetBatteryLowAction, "Windows action at the low-battery level for PowerPilot plans.")
    SetTip(#GadgetBatteryCriticalPercent, "Windows critical-battery level for PowerPilot plans.")
    SetTip(#GadgetBatteryCriticalAction, "Windows action at the critical-battery level for PowerPilot plans.")
    SetTip(#GadgetRestoreNormalPlanOnExit, "On exit, restore the last normal Windows plan when a PowerPilot plan is active.")
    SetTip(#GadgetBatterySaverSummary, "Current Battery Saver control summary.")
    SetTip(#GadgetShowToolTips, "Show or hide these hover explanations.")

    SetTip(gIntroPlans, "Edit plan behavior. Windows power mode still chooses the active plan.")
    SetTip(gFrameManagedPlans, "The plans PowerPilot owns: Maximum, Balanced, and Battery.")
    SetTip(#GadgetPlanList, "Select a plan to edit its processor settings.")
    SetTip(gFramePlanSettings, "CPU behavior for the selected plan.")
    SetTip(#GadgetPlanSummary, "Short note for the selected plan.")
    SetTip(#GadgetPlanAcEpp, "Plugged-in energy preference. 0 means fastest response; 100 means strongest efficiency preference.")
    SetTip(#GadgetPlanDcEpp, "Battery energy preference. Higher numbers usually save more power with slower boost response.")
    SetTip(#GadgetPlanAcBoost, "Plugged-in CPU boost. Disabled saves power; Aggressive responds fastest.")
    SetTip(#GadgetPlanDcBoost, "Battery CPU boost. Disabled is usually best for battery life.")
    SetTip(#GadgetPlanAcState, "Plugged-in maximum CPU state. 100 allows full CPU speed.")
    SetTip(#GadgetPlanDcState, "Battery maximum CPU state. Lower values can reduce heat and battery drain.")
    SetTip(#GadgetPlanAcFreq, "Plugged-in CPU MHz cap. 0 means no explicit cap.")
    SetTip(#GadgetPlanDcFreq, "Battery CPU MHz cap. 0 means no explicit cap.")
    SetTip(#GadgetPlanAcCooling, "Plugged-in cooling policy. Passive favors less fan and lower clocks; Active favors cooling.")
    SetTip(#GadgetPlanDcCooling, "Battery cooling policy. Passive favors less fan and lower clocks; Active favors cooling.")
    SetTip(#GadgetPlanSave, "Save this selected plan and apply it to Windows.")
    SetTip(#GadgetPlanReset, "Restore this selected plan to PowerPilot's default values.")
    SetTip(gFrameBatteryStatus, "Current battery readings from Windows.")
    SetTip(gFrameBatteryEstimate, "Average, current-rate, and Windows firmware time estimates.")
    SetTip(#GadgetBatteryPercent, "Current battery percent.")
    SetTip(#GadgetBatteryConnection, "Live power state: plugged in or on battery, plus charging, discharging, or idle.")
    SetTip(#GadgetBatteryCharging, "")
    SetTip(#GadgetBatteryCapacity, "Remaining battery capacity in mWh.")
    SetTip(#GadgetBatteryRates, "Live battery draw from Windows battery status, shown as charging, discharging, or idle.")
    SetTip(#GadgetBatteryVoltage, "Live battery voltage in volts when the Windows battery driver exposes it.")
    SetTip(#GadgetPowerPilotDraw, "PowerPilot's estimated battery cost from recent CPU time.")
    SetTip(#GadgetBatteryEstimate, "Average time based on recent battery movement: down to Empty at, or up to Full at while charging.")
    SetTip(#GadgetBatteryInstantEstimate, "Now-based time while discharging. Charging uses the average estimate because charge rate tapers near the target.")
    SetTip(#GadgetBatteryRuntime, "Windows' own remaining-time estimate. Windows usually reports it only while discharging.")
    SetTip(#GadgetBatteryFullEstimate, "Learned on-battery runtime from Full at down to Empty at. It can remain visible while plugged in.")
    SetTip(#GadgetBatteryWear, "Battery wear calculated from full-charge capacity versus design capacity.")
    SetTip(#GadgetBatteryNominalEstimate, "Estimated Full at to Empty at runtime if this battery still had its original design capacity.")
    SetTip(#GadgetBatteryMaxCapacity, "Current full-charge capacity and design capacity in mWh when Windows exposes both.")
    SetTip(#GadgetBatteryCycle, "Battery cycle count from root\\wmi:BatteryCycleCount.")
    SetTip(#GadgetBatteryGraphHours, "Choose how many hours of retained battery history the graph shows.")
    SetTip(#GadgetBatteryGraphShowMarkers, "Show or hide marker letters and the marker-letter legend on the battery graph.")
    SetTip(#GadgetBatteryGraph, "Battery history. Blue is normal, green Energy Saver, orange offline, red power events.")
    SetTip(gFrameBatterySettings, "Battery read cadence, log cadence, and estimate settings.")
    SetTip(#GadgetBatteryLogEnabled, "Turn retained battery sample logging on or off.")
    SetTip(#GadgetBatteryLogMinutes, "Minutes between saved log rows. Shorter intervals give more detail and more disk writes.")
    SetTip(#GadgetBatteryRefreshSeconds, "Seconds between live battery reads while the window is open. Tray mode slows down to reduce background wakeups.")
    SetTip(#GadgetBatteryMinPercent, "Percent treated as empty for PowerPilot time estimates.")
    SetTip(#GadgetBatteryMaxPercent, "Percent treated as full for graph range, charging target, and full-to-min runtime estimates.")
    SetTip(#GadgetBatteryLimiterEnabled, "Use the laptop charge limit as the full point.")
    SetTip(#GadgetBatteryLimiterMaxPercent, "Your laptop's charge-limit target, for example 80 if charging normally stops near 80%.")
    SetTip(#GadgetBatterySmoothingMinutes, "How much recent battery history is averaged. Longer is calmer; shorter reacts faster.")
    SetTip(#GadgetBatteryStartupDrain, "Temporary percent-per-hour estimate used right after startup until fresh samples are available.")
    SetTip(#GadgetBatteryStatsReset, "Clear retained battery log rows, graph history, and current estimate learning.")
    SetTip(#GadgetBatteryLogPreview, "Retained battery, screen, power event, and app rows.")
    SetTip(#GadgetBatteryLogCopyRow, "Copy selected log rows to the clipboard. If none are selected, copy the newest visible row.")
    SetTip(#GadgetBatteryLogCopyAll, "Copy the full retained battery CSV log to the clipboard.")
    SetTip(#GadgetBatterySessionSummary, "Latest PC power event PowerPilot saw, such as sleep, wake, startup, or shutdown.")
    SetTip(#GadgetBatteryDailySummary, "Today only: battery range, active on-battery time, active drain, wear, and cycles.")
    SetTip(#GadgetBatteryOffLossSummary, "Battery percent lost while asleep, hibernated, shut down, or missing samples.")
    SetTip(#GadgetBatteryAnalysisSummary, "Retained-log analysis for capacity, power, charging, and warnings.")
    SetTip(#GadgetBatteryAnalysisRefresh, "Read battery data now and rebuild the analysis.")
    SetTip(#GadgetPowerUseSummary, "Estimated app battery cost from recent CPU time.")
    SetTip(#GadgetPowerUseStatus, "Shows which Windows battery data path is being used.")
    SetTip(#GadgetPowerUseInterpretation, "How to read estimated mW and full-to-empty seconds.")
    SetTip(#GadgetPowerUseIdleChecklist, "Checks for unexpected idle battery use.")
    SetTip(#GadgetBatteryTestMode, "Current workflow mode: manual discharge test, vendor calibration detected, charge recovery, monitor, or complete.")
    SetTip(#GadgetBatteryTestPhase, "Current live phase from Windows battery state.")
    SetTip(#GadgetBatteryTestElapsed, "Elapsed time since the current test log started.")
    SetTip(#GadgetBatteryTestStart, "Start a manual discharge test, then track charge recovery.")
    SetTip(#GadgetBatteryTestLenovo, "Start Lenovo reset monitoring with automatic drain load.")
    SetTip(#GadgetBatteryTestEnd, "End the current battery test log and freeze the summary.")
    SetTip(#GadgetBatteryTestCopy, "Copy the current battery test report to the clipboard.")
    SetTip(#GadgetBatteryTestOpenReport, "Open the latest saved battery test report in the default Windows text editor.")
    SetTip(#GadgetBatteryTestPercent, "Current battery percent during the test.")
    SetTip(#GadgetBatteryTestRemaining, "Remaining battery capacity in mWh during the test.")
    SetTip(#GadgetBatteryTestWatts, "Live charging or discharging watts from Windows battery status.")
    SetTip(#GadgetBatteryTestEstimate, "Current estimated time to empty or configured full target.")
    SetTip(#GadgetBatteryTestGuide, "Short next step for manual testing or vendor calibration monitoring.")
    SetTip(#GadgetBatteryTestSummary, "Copyable summary with start/end percent, mWh moved, average watts, runtime, and capacity notes.")
    SetTip(#GadgetBatteryLoadStatus, "Current CPU load target used to drain the battery faster during a test.")
    SetTip(#GadgetBatteryLoadStep, "Increase PowerPilot's CPU load target by 25%, up to 100%.")
    SetTip(#GadgetBatteryLoadStop, "Stop the CPU load helper immediately.")
    SetTip(#GadgetBatteryLoadMinutes, "Target time from now to Empty at.")
    SetTip(#GadgetBatteryLoadAuto, "Start or stop automatic CPU load control for the chosen drain time.")
    SetTip(#GadgetBatteryLoadAutoStatus, "Auto drain end time and remaining target time.")
    SetTip(#GadgetBatteryLoadTestMode, "Log detailed drain-helper control ticks while testing normal unplug discharge.")
    SetTip(#GadgetBatteryLoadNote, "CPU load is local and automatic. Stop when done.")
    SetTip(#GadgetAboutPurpose, "Short description of what PowerPilot is for.")
    SetTip(#GadgetAboutOperation, "Shows the automatic mapping from Windows power mode to PowerPilot plans.")
    SetTip(#GadgetAboutData, "Lists the events and battery fields PowerPilot can log.")
    SetTip(#GadgetAboutVersion, "Summarizes the local data PowerPilot reads and writes.")
    SetTip(#GadgetAboutLicense, "License, bundled documents, and uninstall reference.")
    SetTip(#GadgetAboutOpenReadme, "Open the bundled README.txt.")
    SetTip(#GadgetAboutOpenLicense, "Open the bundled MIT license text.")
    SetTip(#GadgetAboutBoundaries, "What PowerPilot cannot measure directly and how to read the Power Use estimate.")
    SetTip(#GadgetLogShowAverage, "Show or hide the average remaining-time column.")
    SetTip(#GadgetLogShowInstant, "Show or hide the current-rate and now-based time columns.")
    SetTip(#GadgetLogShowWindows, "Show or hide the Windows or firmware remaining-time column.")
    SetTip(#GadgetLogShowConnected, "Show or hide whether each row was plugged in.")
    SetTip(#GadgetLogShowPower, "Show or hide the battery watts column.")
    SetTip(#GadgetLogShowScreen, "Show or hide the screen on, dim, or off event column.")
    SetTip(#GadgetLogShowBrightness, "Show or hide the laptop brightness percent column.")
    SetTip(#GadgetLogShowEvents, "Show or hide event rows such as screen, sleep, wake, startup, and app status.")
    SetTip(#GadgetSettingsExport, "Save PowerPilot settings to an INI file.")
    SetTip(#GadgetSettingsImport, "Restore PowerPilot settings from an exported INI file.")
    SetTip(#GadgetHideToTray, "Hide PowerPilot to the tray while it continues following Windows power mode.")
    SetTip(#GadgetExit, "Exit PowerPilot and remove the tray icon.")
  Else
    SetTip(#GadgetPanel, "")
    SetTip(gIntroOverview, "")
    SetTip(gFrameProcessor, "")
    SetTip(#GadgetCpuInfo, "")
    SetTip(gFrameState, "")
    SetTip(#GadgetActivePlan, "")
    SetTip(#GadgetPowerSource, "")
    SetTip(#GadgetOverviewBatteryState, "")
    SetTip(#GadgetOverviewSaverState, "")
    SetTip(#GadgetLastAction, "")
    SetTip(gFrameOverviewBattery, "")
    SetTip(#GadgetOverviewRuntime, "")
    SetTip(#GadgetGpuInfo, "")
    SetTip(gFrameStartup, "")
    SetTip(#GadgetOverviewPowerPilot, "")
    SetTip(#GadgetAutoStart, "")
    SetTip(#GadgetKeepSettings, "")
    SetTip(#GadgetThrottleMaintenance, "")
    SetTip(#GadgetDeepIdleSaver, "")
    SetTip(#GadgetEnergySaverMode, "")
    SetTip(#GadgetEnergySaverThreshold, "")
    SetTip(#GadgetEnergySaverBrightness, "")
    SetTip(#GadgetBatteryLowWarningPercent, "")
    SetTip(#GadgetBatteryReservePercent, "")
    SetTip(#GadgetBatteryLowAction, "")
    SetTip(#GadgetBatteryCriticalPercent, "")
    SetTip(#GadgetBatteryCriticalAction, "")
    SetTip(#GadgetRestoreNormalPlanOnExit, "")
    SetTip(#GadgetBatterySaverSummary, "")
    SetTip(gIntroPlans, "")
    SetTip(gFrameManagedPlans, "")
    SetTip(#GadgetPlanList, "")
    SetTip(gFramePlanSettings, "")
    SetTip(#GadgetPlanSummary, "")
    SetTip(#GadgetPlanAcEpp, "")
    SetTip(#GadgetPlanDcEpp, "")
    SetTip(#GadgetPlanAcBoost, "")
    SetTip(#GadgetPlanDcBoost, "")
    SetTip(#GadgetPlanAcState, "")
    SetTip(#GadgetPlanDcState, "")
    SetTip(#GadgetPlanAcFreq, "")
    SetTip(#GadgetPlanDcFreq, "")
    SetTip(#GadgetPlanAcCooling, "")
    SetTip(#GadgetPlanDcCooling, "")
    SetTip(#GadgetPlanSave, "")
    SetTip(#GadgetPlanReset, "")
    SetTip(gFrameBatteryStatus, "")
    SetTip(gFrameBatteryEstimate, "")
    SetTip(#GadgetBatteryPercent, "")
    SetTip(#GadgetBatteryConnection, "")
    SetTip(#GadgetBatteryCharging, "")
    SetTip(#GadgetBatteryCapacity, "")
    SetTip(#GadgetBatteryRates, "")
    SetTip(#GadgetBatteryVoltage, "")
    SetTip(#GadgetPowerPilotDraw, "")
    SetTip(#GadgetBatteryEstimate, "")
    SetTip(#GadgetBatteryInstantEstimate, "")
    SetTip(#GadgetBatteryRuntime, "")
    SetTip(#GadgetBatteryFullEstimate, "")
    SetTip(#GadgetBatteryWear, "")
    SetTip(#GadgetBatteryNominalEstimate, "")
    SetTip(#GadgetBatteryMaxCapacity, "")
    SetTip(#GadgetBatteryCycle, "")
    SetTip(#GadgetBatteryGraphHours, "")
    SetTip(#GadgetBatteryGraphShowMarkers, "")
    SetTip(#GadgetBatteryGraph, "")
    SetTip(gFrameBatterySettings, "")
    SetTip(#GadgetBatteryLogEnabled, "")
    SetTip(#GadgetBatteryLogMinutes, "")
    SetTip(#GadgetBatteryRefreshSeconds, "")
    SetTip(#GadgetBatteryMinPercent, "")
    SetTip(#GadgetBatteryMaxPercent, "")
    SetTip(#GadgetBatteryLimiterEnabled, "")
    SetTip(#GadgetBatteryLimiterMaxPercent, "")
    SetTip(#GadgetBatterySmoothingMinutes, "")
    SetTip(#GadgetBatteryStartupDrain, "")
    SetTip(#GadgetBatteryStatsReset, "")
    SetTip(#GadgetBatteryLogPreview, "")
    SetTip(#GadgetBatteryLogCopyRow, "")
    SetTip(#GadgetBatteryLogCopyAll, "")
    SetTip(#GadgetBatterySessionSummary, "")
    SetTip(#GadgetBatteryDailySummary, "")
    SetTip(#GadgetBatteryOffLossSummary, "")
    SetTip(#GadgetBatteryAnalysisSummary, "")
    SetTip(#GadgetBatteryAnalysisRefresh, "")
    SetTip(#GadgetPowerUseSummary, "")
    SetTip(#GadgetPowerUseStatus, "")
    SetTip(#GadgetPowerUseInterpretation, "")
    SetTip(#GadgetPowerUseIdleChecklist, "")
    SetTip(#GadgetBatteryTestMode, "")
    SetTip(#GadgetBatteryTestPhase, "")
    SetTip(#GadgetBatteryTestElapsed, "")
    SetTip(#GadgetBatteryTestStart, "")
    SetTip(#GadgetBatteryTestLenovo, "")
    SetTip(#GadgetBatteryTestEnd, "")
    SetTip(#GadgetBatteryTestCopy, "")
    SetTip(#GadgetBatteryTestOpenReport, "")
    SetTip(#GadgetBatteryTestPercent, "")
    SetTip(#GadgetBatteryTestRemaining, "")
    SetTip(#GadgetBatteryTestWatts, "")
    SetTip(#GadgetBatteryTestEstimate, "")
    SetTip(#GadgetBatteryTestGuide, "")
    SetTip(#GadgetBatteryTestSummary, "")
    SetTip(#GadgetBatteryLoadStatus, "")
    SetTip(#GadgetBatteryLoadStep, "")
    SetTip(#GadgetBatteryLoadStop, "")
    SetTip(#GadgetBatteryLoadMinutes, "")
    SetTip(#GadgetBatteryLoadAuto, "")
    SetTip(#GadgetBatteryLoadAutoStatus, "")
    SetTip(#GadgetBatteryLoadTestMode, "")
    SetTip(#GadgetBatteryLoadNote, "")
    SetTip(#GadgetAboutPurpose, "")
    SetTip(#GadgetAboutOperation, "")
    SetTip(#GadgetAboutData, "")
    SetTip(#GadgetAboutVersion, "")
    SetTip(#GadgetAboutLicense, "")
    SetTip(#GadgetAboutOpenReadme, "")
    SetTip(#GadgetAboutOpenLicense, "")
    SetTip(#GadgetAboutBoundaries, "")
    SetTip(#GadgetLogShowAverage, "")
    SetTip(#GadgetLogShowInstant, "")
    SetTip(#GadgetLogShowWindows, "")
    SetTip(#GadgetLogShowConnected, "")
    SetTip(#GadgetLogShowPower, "")
    SetTip(#GadgetLogShowScreen, "")
    SetTip(#GadgetLogShowBrightness, "")
    SetTip(#GadgetLogShowEvents, "")
    SetTip(#GadgetSettingsExport, "")
    SetTip(#GadgetSettingsImport, "")
    SetTip(#GadgetHideToTray, "")
    SetTip(#GadgetExit, "")
    SetTip(#GadgetShowToolTips, "Show or hide hover explanations.")
    ProcedureReturn
  EndIf
EndProcedure

; Refresh Overview text. Hidden/tray mode skips expensive static UI updates
; unless forced by ShowFromTray/startup.
Procedure RefreshDisplay(force.i = #False)
  Protected activeGuid$
  Protected active$
  Protected powerModeGuid$
  Protected powerModeText$
  If force = #False And MainWindowVisible() = #False
    ProcedureReturn
  EndIf

  activeGuid$ = GetActiveSchemeGuid()
  If force Or activeGuid$ <> gCachedActiveGuid$ Or gCachedActiveName$ = ""
    gCachedActiveGuid$ = activeGuid$
    gCachedActiveName$ = GetSchemeNameByGuid(activeGuid$)
  EndIf

  powerModeGuid$ = GetWindowsPowerModeGuid()
  If force Or powerModeGuid$ <> gCachedPowerModeGuid$ Or gCachedPowerModeText$ = ""
    gCachedPowerModeGuid$ = powerModeGuid$
    powerModeText$ = PowerModeTextFromGuid(powerModeGuid$)
    If powerModeText$ = ""
      powerModeText$ = "Classic power plan"
    EndIf
    gCachedPowerModeText$ = powerModeText$
  EndIf

  active$ = gCachedActiveName$
  SetGadgetTextIfChanged(#GadgetCpuInfo, OverviewCpuText())
  SetGadgetTextIfChanged(#GadgetGpuInfo, OverviewGpuText())
  If active$ = "" : active$ = "Unknown" : EndIf
  SetGadgetTextIfChanged(#GadgetActivePlan, active$)
  SetGadgetTextIfChanged(#GadgetPowerSource, gCachedPowerModeText$)
  If gLastAction$ <> ""
    SetGadgetTextIfChanged(#GadgetLastAction, gLastAction$)
  EndIf
  RefreshOverviewPanels()
EndProcedure

; Follow Windows power mode. External active plans become the new base for
; PowerPilot's three managed plans; managed plans switch according to overlay.
Procedure.i ApplyWindowsPowerFollow(force.i = #False)
  Protected activeGuid$ = GetActiveSchemeGuid()
  Protected activeName$
  Protected powerModeGuid$ = GetWindowsPowerModeGuid()
  Protected targetPlan$
  Protected shouldApply.i
  Protected usedExternalBase.i
  Protected applied.i

  If activeGuid$ <> ""
    activeName$ = GetSchemeNameByGuid(activeGuid$)
    If IsManagedPlanName(activeName$) = #False
      RememberNormalPowerPlan(activeGuid$, activeName$)
    EndIf
  EndIf
  targetPlan$ = TargetPlanForPowerModeGuid(powerModeGuid$)
  If targetPlan$ = ""
    targetPlan$ = TargetPlanForWindowsPlan(activeName$)
  EndIf
  If targetPlan$ = ""
    targetPlan$ = #PlanBalanced$
  EndIf

  ; First run initializes observation state. Later runs react to either an
  ; external plan change or a Windows power-mode overlay change.
  If force
    shouldApply = Bool(activeName$ <> targetPlan$ Or activeGuid$ = "")
  ElseIf gMonitorInitialized = #False
    gMonitorInitialized = #True
    shouldApply = Bool(IsManagedPlanName(activeName$) = #False Or activeName$ <> targetPlan$ Or activeGuid$ = "")
  Else
    If activeGuid$ <> "" And IsManagedPlanName(activeName$) = #False And activeGuid$ <> gLastObservedActiveGuid$
      shouldApply = #True
    ElseIf activeGuid$ <> "" And IsManagedPlanName(activeName$) And activeName$ <> targetPlan$
      shouldApply = #True
    ElseIf powerModeGuid$ <> "" And powerModeGuid$ <> gLastObservedPowerModeGuid$ And activeName$ <> targetPlan$
      shouldApply = #True
    EndIf
  EndIf

  If shouldApply
    ; If the user selected a non-PowerPilot plan, rebuild the fixed plans from
    ; that plan so OEM/vendor hidden defaults are preserved.
    If activeGuid$ <> "" And IsManagedPlanName(activeName$) = #False
      If CreateManagedPlansFromBase(activeGuid$, #True)
        usedExternalBase = #True
      EndIf
    ElseIf GetSchemeGuidByName(targetPlan$) = ""
      CreateManagedPlansFromBase("SCHEME_BALANCED", #True)
    EndIf

    If ActivatePlanByName(targetPlan$)
      If usedExternalBase
        LogAction(activeName$ + " followed as " + targetPlan$ + ".")
      Else
        LogAction(targetPlan$ + " activated to follow Windows power mode.")
      EndIf
      applied = #True
    EndIf
    activeGuid$ = GetActiveSchemeGuid()
  EndIf

  gLastObservedActiveGuid$ = activeGuid$
  gLastObservedPowerModeGuid$ = powerModeGuid$
  ProcedureReturn applied
EndProcedure

; Timer task for power-mode following plus optional EcoQoS maintenance throttle.
Procedure MonitorAutomaticPlans()
  Protected powerModeGuid$ = GetWindowsPowerModeGuid()
  Protected throttleEnabled.i = IsEfficiencyPowerMode(powerModeGuid$)
  If ApplyWindowsPowerFollow(#False)
    RefreshPlanList(#True)
  EndIf
  ApplyMaintenanceThrottling(throttleEnabled)
EndProcedure

; Tray menu is intentionally tiny: open or exit.
Procedure CreateTrayMenu()
  If CreatePopupMenu(#PopupTray)
    MenuItem(#MenuOpen, "Open PowerPilot")
    MenuBar()
    MenuItem(#MenuExit, "Exit")
  EndIf
EndProcedure

; Add the tray icon if possible. Failure is tolerated because the window can
; remain visible and continue refreshing.
Procedure SetupTray()
  Protected iconPath$ = GetPathPart(ProgramFilename()) + "powerpilot_tray.ico"
  If gTrayReady
    ProcedureReturn
  EndIf
  If FileSize(iconPath$) <= 0
    iconPath$ = GetCurrentDirectory() + "powerpilot_tray.ico"
  EndIf
  If IsImage(#ImageTray) Or LoadImage(#ImageTray, iconPath$)
    gTrayReady = AddSysTrayIcon(#TrayIconMain, WindowID(#WindowMain), ImageID(#ImageTray))
    If gTrayReady
      SysTrayIconToolTip(#TrayIconMain, #TrayTooltip$)
    EndIf
  EndIf
EndProcedure

; Hidden mode can refresh less often when deep idle saver is enabled.
Procedure.i DesiredRefreshInterval()
  If MainWindowVisible()
    If BatteryTestTabVisible()
      ProcedureReturn #RefreshBatteryTestTabMs
    EndIf
    ProcedureReturn #RefreshVisibleMs
  EndIf
  If gSettings\DeepIdleSaver
    ProcedureReturn #RefreshHiddenDeepIdleMs
  EndIf
  ProcedureReturn #RefreshHiddenMs
EndProcedure

; Replace the existing timer when the visible/hidden cadence changes. The main
; event loop stays blocking so the tab window paints normally.
Procedure StartRefreshTimer(intervalMs.i = 0)
  If intervalMs <= 0
    intervalMs = DesiredRefreshInterval()
  EndIf
  ApplySelfDeepIdleThrottle()
  If gRefreshTimerActive
    RemoveWindowTimer(#WindowMain, #TimerRefresh)
  EndIf
  AddWindowTimer(#WindowMain, #TimerRefresh, intervalMs)
  gRefreshTimerActive = #True
EndProcedure

Procedure RefreshActiveTimer()
  If gRefreshTimerActive
    StartRefreshTimer(DesiredRefreshInterval())
  EndIf
EndProcedure

Procedure SetSessionDisplayStatusGuid(*guid.GuidValue)
  *guid\Data1 = $2B84C20E
  *guid\Data2 = $AD23
  *guid\Data3 = $4DDF
  *guid\Data4[0] = $93
  *guid\Data4[1] = $DB
  *guid\Data4[2] = $05
  *guid\Data4[3] = $FF
  *guid\Data4[4] = $BD
  *guid\Data4[5] = $7E
  *guid\Data4[6] = $FC
  *guid\Data4[7] = $A5
EndProcedure

Procedure SetPowerSavingStatusGuid(*guid.GuidValue)
  *guid\Data1 = $E00958C0
  *guid\Data2 = $C213
  *guid\Data3 = $4ACE
  *guid\Data4[0] = $AC
  *guid\Data4[1] = $77
  *guid\Data4[2] = $FE
  *guid\Data4[3] = $CC
  *guid\Data4[4] = $ED
  *guid\Data4[5] = $2E
  *guid\Data4[6] = $EE
  *guid\Data4[7] = $A5
EndProcedure

Procedure.i EnsureDisplayPowerApi()
  If gDisplayNotifyTried
    ProcedureReturn Bool(gRegisterPowerSettingNotification And gUnregisterPowerSettingNotification)
  EndIf
  gDisplayNotifyTried = #True
  gUser32PowerLibrary = OpenLibrary(#PB_Any, "user32.dll")
  If gUser32PowerLibrary
    gRegisterPowerSettingNotification = GetFunction(gUser32PowerLibrary, "RegisterPowerSettingNotification")
    If gRegisterPowerSettingNotification = 0
      gRegisterPowerSettingNotification = GetFunction(gUser32PowerLibrary, "RegisterPowerSettingNotificationW")
    EndIf
    gUnregisterPowerSettingNotification = GetFunction(gUser32PowerLibrary, "UnregisterPowerSettingNotification")
  EndIf
  ProcedureReturn Bool(gRegisterPowerSettingNotification And gUnregisterPowerSettingNotification)
EndProcedure

Procedure RegisterDisplayPowerNotification(hwnd.i)
  Protected guid.GuidValue
  If EnsureDisplayPowerApi() = #False
    ProcedureReturn
  EndIf
  If gDisplayPowerNotifyHandle = 0
    SetSessionDisplayStatusGuid(@guid)
    gDisplayPowerNotifyHandle = gRegisterPowerSettingNotification(hwnd, @guid, #DEVICE_NOTIFY_WINDOW_HANDLE)
  EndIf
  If gEnergySaverNotifyHandle = 0
    SetPowerSavingStatusGuid(@guid)
    gEnergySaverNotifyHandle = gRegisterPowerSettingNotification(hwnd, @guid, #DEVICE_NOTIFY_WINDOW_HANDLE)
  EndIf
EndProcedure

Procedure UnregisterDisplayPowerNotification()
  If gDisplayPowerNotifyHandle And gUnregisterPowerSettingNotification
    gUnregisterPowerSettingNotification(gDisplayPowerNotifyHandle)
    gDisplayPowerNotifyHandle = 0
  EndIf
  If gEnergySaverNotifyHandle And gUnregisterPowerSettingNotification
    gUnregisterPowerSettingNotification(gEnergySaverNotifyHandle)
    gEnergySaverNotifyHandle = 0
  EndIf
EndProcedure

Procedure.s ScreenEventFromPowerSetting(lParam.i)
  Protected guid.GuidValue
  Protected dataLength.i
  Protected state.i
  If lParam = 0
    ProcedureReturn ""
  EndIf
  SetSessionDisplayStatusGuid(@guid)
  If CompareMemory(lParam, @guid, SizeOf(GuidValue)) = #False
    ProcedureReturn ""
  EndIf
  dataLength = PeekL(lParam + SizeOf(GuidValue))
  If dataLength < 4
    ProcedureReturn ""
  EndIf
  state = PeekL(lParam + SizeOf(GuidValue) + 4)
  Select state
    Case #DisplayStateOff
      ProcedureReturn "Screen off"
    Case #DisplayStateOn
      ProcedureReturn "Screen on"
    Case #DisplayStateDimmed
      ProcedureReturn "Screen dim"
  EndSelect
  ProcedureReturn ""
EndProcedure

Procedure.i EnergySaverStateFromPowerSetting(lParam.i)
  Protected guid.GuidValue
  Protected dataLength.i
  If lParam = 0
    ProcedureReturn -1
  EndIf
  SetPowerSavingStatusGuid(@guid)
  If CompareMemory(lParam, @guid, SizeOf(GuidValue)) = #False
    ProcedureReturn -1
  EndIf
  dataLength = PeekL(lParam + SizeOf(GuidValue))
  If dataLength < 4
    ProcedureReturn -1
  EndIf
  ProcedureReturn Bool(PeekL(lParam + SizeOf(GuidValue) + 4) <> 0)
EndProcedure

; Hide to tray when the tray icon exists. If the tray icon could not be created,
; keep the window visible so the user is not left with an invisible app.
Procedure HideToTray()
  ApplyPendingBatterySettings()
  CaptureBatteryLogColumnWidths(#True)
  If gTrayReady Or gStartedInTrayMode
    HideWindow(#WindowMain, #True)
    StartRefreshTimer()
  Else
    HideWindow(#WindowMain, #False)
    StartRefreshTimer(#RefreshVisibleMs)
    LogAction("Tray icon unavailable. Window stays visible.")
  EndIf
EndProcedure

Procedure PrepareWindowForDisplay()
  Protected hwnd.i
  Protected previousPreparing.i
  If IsWindow(#WindowMain) = #False
    ProcedureReturn
  EndIf
  hwnd = WindowID(#WindowMain)
  previousPreparing = gWindowPreparingForDisplay
  gWindowPreparingForDisplay = #True
  SendMessage_(hwnd, #WM_SETREDRAW, #False, 0)
  ApplyMainWindowLayoutScale()
  ApplySettingsToGui()
  RefreshPlanList(#True)
  RefreshPlanEditor()
  RefreshBattery(#True)
  RefreshBatteryLogPreview()
  RefreshBatteryStatsSummary()
  RefreshBatteryAnalysisSummary()
  RefreshBatterySaverSummary()
  RefreshPowerUseDetails()
  RefreshDisplay(#True)
  RefreshPowerPilotDrawDisplay()
  If BatteryGraphTabVisible()
    DrawBatteryGraph()
  EndIf
  SendMessage_(hwnd, #WM_SETREDRAW, #True, 0)
  InvalidateRect_(hwnd, 0, #True)
  UpdateWindow_(hwnd)
  gWindowPreparingForDisplay = previousPreparing
EndProcedure

; Showing the window performs all layout and data refreshes while hidden, then
; reveals the already-populated window in one paint.
Procedure ShowFromTray()
  PrepareWindowForDisplay()
  HideWindow(#WindowMain, #False)
  StartRefreshTimer(#RefreshVisibleMs)
  SetForegroundWindow_(WindowID(#WindowMain))
EndProcedure

; Normal explicit app exit writes an app row, not a PC shutdown event.
Procedure ShutdownApp()
  ApplyPendingBatterySettings()
  CaptureBatteryLogColumnWidths(#False)
  StopBatteryCpuLoad(#False)
  SaveSettings()
  RestoreNormalPowerPlanForExit()
  WriteBatteryAppEvent("PowerPilot exit")
  If gTrayReady
    RemoveSysTrayIcon(#TrayIconMain)
  EndIf
  UnregisterDisplayPowerNotification()
  If gSingleInstanceMutex
    CloseHandle_(gSingleInstanceMutex)
  EndIf
  End
EndProcedure

; Installer-driven replacement exits use a separate app row so the log and
; graph do not look like the user pressed Exit or the PC shut down.
Procedure ShutdownForUpdate()
  ApplyPendingBatterySettings()
  CaptureBatteryLogColumnWidths(#False)
  StopBatteryCpuLoad(#False)
  SaveSettings()
  RestoreNormalPowerPlanForExit()
  WriteBatteryAppEvent("PowerPilot update close")
  If gTrayReady
    RemoveSysTrayIcon(#TrayIconMain)
  EndIf
  UnregisterDisplayPowerNotification()
  If gSingleInstanceMutex
    CloseHandle_(gSingleInstanceMutex)
  EndIf
  End
EndProcedure

; Central gadget event dispatcher.
Procedure HandleAction(gadget.i)
  Protected row.i
  Select gadget
    Case #GadgetPanel
      RefreshActiveTimer()
      If BatteryTestTabVisible()
        RefreshBattery(#True)
      ElseIf BatteryGraphTabVisible()
        DrawBatteryGraph()
      EndIf

    Case #GadgetPlanList
      row = GetGadgetState(#GadgetPlanList)
      If row >= 0 And row <= 2
        gSelectedPlan = row
        RefreshPlanEditor()
      EndIf

    Case #GadgetPlanSave
      SavePlanEditor()

    Case #GadgetPlanReset
      ResetSelectedPlan()

    Case #GadgetAutoStart, #GadgetKeepSettings, #GadgetThrottleMaintenance, #GadgetDeepIdleSaver, #GadgetShowToolTips
      SaveSettingsFromGui()

    Case #GadgetEnergySaverMode, #GadgetEnergySaverThreshold, #GadgetEnergySaverBrightness, #GadgetBatteryLowWarningPercent, #GadgetBatteryReservePercent, #GadgetBatteryLowAction, #GadgetBatteryCriticalPercent, #GadgetBatteryCriticalAction, #GadgetRestoreNormalPlanOnExit
      ScheduleBatterySettingsApply()

    Case #GadgetBatteryLogEnabled, #GadgetBatteryLogMinutes, #GadgetBatteryRefreshSeconds, #GadgetBatteryMinPercent, #GadgetBatteryMaxPercent, #GadgetBatteryLimiterEnabled, #GadgetBatteryLimiterMaxPercent, #GadgetBatterySmoothingMinutes, #GadgetBatteryStartupDrain
      ScheduleBatterySettingsApply()

    Case #GadgetBatteryGraphHours, #GadgetBatteryGraphShowMarkers
      SaveBatteryGraphDisplaySettingsFromGui()
      DrawBatteryGraph()

    Case #GadgetBatteryStatsReset
      ResetBatteryStats()

    Case #GadgetBatteryAnalysisRefresh
      RefreshBatteryAnalysisNow()

    Case #GadgetLogShowAverage, #GadgetLogShowInstant, #GadgetLogShowWindows, #GadgetLogShowConnected, #GadgetLogShowPower, #GadgetLogShowScreen, #GadgetLogShowBrightness, #GadgetLogShowEvents
      SaveBatterySettingsFromGui()

    Case #GadgetSettingsExport
      ExportSettings()

    Case #GadgetSettingsImport
      ImportSettings()

    Case #GadgetAboutOpenReadme
      OpenReadmeDocument()

    Case #GadgetAboutOpenLicense
      OpenLicenseDocument()

    Case #GadgetBatteryLogCopyRow
      CopyBatteryLogRow()

    Case #GadgetBatteryLogCopyAll
      CopyBatteryLogAll()

    Case #GadgetBatteryTestStart
      StartBatteryTestLog()

    Case #GadgetBatteryTestLenovo
      StartLenovoCalibrationReset()

    Case #GadgetBatteryTestEnd
      EndBatteryTestLog()

    Case #GadgetBatteryTestCopy
      CopyBatteryTestReport()

    Case #GadgetBatteryTestOpenReport
      OpenLatestBatteryTestReport()

    Case #GadgetBatteryLoadMinutes
      SaveBatterySettingsFromGui()

    Case #GadgetBatteryLoadStep
      StepBatteryCpuLoad()

    Case #GadgetBatteryLoadAuto
      ToggleAutoDrainTarget()

    Case #GadgetBatteryLoadTestMode
      SetBatteryDrainHelperTestMode(GetGadgetState(#GadgetBatteryLoadTestMode))

    Case #GadgetBatteryLoadStop
      StopBatteryCpuLoad()

    Case #GadgetHideToTray
      HideToTray()

    Case #GadgetExit
      ShutdownApp()
  EndSelect
EndProcedure

; Tray menu dispatcher.
Procedure HandleMenu(menu.i)
  Select menu
    Case #MenuOpen
      ShowFromTray()
    Case #MenuExit
      ShutdownApp()
  EndSelect
  RefreshPlanList()
  RefreshDisplay()
EndProcedure

; Native window callback catches power/session messages that PureBasic's normal
; event loop does not expose with enough detail for shutdown/sleep logging.
Procedure.i MainWindowCallback(hwnd.i, message.i, wParam.i, lParam.i)
  Protected resumeEvent$
  Protected screenEvent$
  Protected energySaverState.i
  Protected closeForAppRestart.i
  Select message
    Case #WM_POWERPILOT_UPDATE_CLOSE
      ShutdownForUpdate()
      ProcedureReturn #True

    Case #WM_POWERBROADCAST
      Select wParam
        Case #PBT_APMSUSPEND
          gLastSuspendTime = Date()
          WriteBatteryEvent("Sleep/Hibernate")

        Case #PBT_APMRESUMEAUTOMATIC, #PBT_APMRESUMESUSPEND, #PBT_APMRESUMECRITICAL
          resumeEvent$ = RecentResumeEventName()
          If resumeEvent$ <> ""
            WriteBatteryEvent(resumeEvent$)
          ElseIf gLastSuspendTime > 0 And Date() - gLastSuspendTime >= 7200
            WriteBatteryEvent("Return from hibernation")
          Else
            WriteBatteryEvent("Wake")
          EndIf
          gLastSuspendTime = 0
          RefreshBattery(#True)

        Case #PBT_APMPOWERSTATUSCHANGE
          If BatteryPowerStateChangedFromSystem()
            RefreshBattery(#True, #True)
          EndIf

        Case #PBT_POWERSETTINGCHANGE
          screenEvent$ = ScreenEventFromPowerSetting(lParam)
          If screenEvent$ <> ""
            WriteBatteryScreenEvent(screenEvent$)
          EndIf
          energySaverState = EnergySaverStateFromPowerSetting(lParam)
          If energySaverState >= 0
            gBattery\EnergySaverOn = Bool(energySaverState Or WindowsEnergySaverPolicyActive() Or PowerPilotControlledEnergySaverActive())
            UpdateEnergySaverLogState(gBattery\EnergySaverOn)
            If gBattery\Valid
              AddBatteryGraphPoint(Date(), gBattery\Percent, gBattery\Connected, gBattery\Charging, gBattery\EnergySaverOn, gBattery\DisconnectedBattery, gBattery\RemainingMWh, gBattery\FullMWh, gBattery\DischargeRateMW, gBattery\ChargeRateMW, BatteryCurrentScreenOnKnown(), BatteryCurrentScreenOn(), gLastScreenBrightnessPercent)
              If MainWindowVisible()
                DrawBatteryGraph()
              EndIf
            EndIf
          EndIf
      EndSelect
      ProcedureReturn #True

    Case #WM_QUERYENDSESSION
      ; Restart Manager sends ENDSESSION_CLOSEAPP when setup/restart flows close
      ; the app. Those are app lifecycle rows, not PC shutdown rows.
      closeForAppRestart = Bool(lParam & #ENDSESSION_CLOSEAPP)
      If closeForAppRestart = #False
        WriteBatteryEvent("Shutdown requested")
      EndIf

    Case #WM_ENDSESSION
      closeForAppRestart = Bool(lParam & #ENDSESSION_CLOSEAPP)
      If wParam <> 0 And gShutdownLogged = #False
        If closeForAppRestart
          WriteBatteryAppEvent("PowerPilot update close")
        Else
          WriteBatteryEvent("Shutdown")
        EndIf
        gShutdownLogged = #True
      EndIf
  EndSelect
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

; Shared periodic refresh body. The WindowTimer is the only periodic trigger;
; the cadence changes when the window is shown, hidden, or Battery Test is the
; selected tab. Keep slow work out of this routine unless it is gated, because
; this path runs for the lifetime of the tray app.
Procedure RunPeriodicRefresh()
  If gTrayReady = #False
    SetupTray()
  EndIf
  CaptureBatteryLogColumnWidths(#True)
  MonitorAutomaticPlans()
  RefreshBattery()
  RefreshPowerPilotDrawDisplay()
  RefreshDisplay()
EndProcedure

; Build all tabs in one place. The base size is dense on purpose; maximize
; scales the same tab layout for easier graph reading.
Procedure CreateMainWindow(showWindow.i)
  Protected flags.i = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered | #PB_Window_Invisible
  Protected activeLabel.i
  Protected modeLabel.i
  Protected lastActionLabel.i
  Protected acHeader.i
  Protected dcHeader.i
  Protected acCoolingHeader.i
  Protected dcCoolingHeader.i
  Protected batteryLabel.i
  Protected batterySettingsLabel.i
  Protected powerUseText$
  Protected idleText$
  Protected sectionHeader.i
  Protected aboutPurpose$
  Protected aboutOperation$
  Protected aboutData$
  Protected aboutVersion$
  Protected aboutBoundaries$
  Protected aboutTitle.i
  Protected aboutSubtitle.i
  ClearList(gUiBoldHwnds())
  gUiScale = 1.0
  OpenWindow(#WindowMain, 0, 0, #MainWindowBaseWidth, #MainWindowBaseHeight, #AppFullName$, flags)
  WindowBounds(#WindowMain, #MainWindowMinWidth, #MainWindowMinHeight, #PB_Ignore, #PB_Ignore)
  SetWindowCallback(@MainWindowCallback(), #WindowMain)
  RegisterDisplayPowerNotification(WindowID(#WindowMain))
  EnsureUiFonts()
  CreateTrayMenu()
  SetupTray()

  PanelGadget(#GadgetPanel, 12, 12, 736, 486)

  ; Overview tab: compact dashboard for the current plan, battery, hardware,
  ; PowerPilot cadence, and the latest full action message. Short action
  ; messages also go to the PowerPilot Log.
  AddGadgetItem(#GadgetPanel, -1, "Overview")
  gIntroOverview = TextGadget(#PB_Any, 18, 14, 700, 22, "PowerPilot follows Windows power mode, keeps battery policy aligned, and logs what changes.")
  UseBoldFont(gIntroOverview)
  gFrameState = FrameGadget(#PB_Any, 18, 42, 700, 112, "Live State")
  activeLabel = TextGadget(#PB_Any, 34, 66, 92, 20, "Active plan:")
  TextGadget(#GadgetActivePlan, 132, 66, 210, 20, "")
  modeLabel = TextGadget(#PB_Any, 370, 66, 108, 20, "Windows mode:")
  TextGadget(#GadgetPowerSource, 486, 66, 216, 20, "")
  TextGadget(#PB_Any, 34, 94, 92, 20, "Battery:")
  TextGadget(#GadgetOverviewBatteryState, 132, 94, 210, 20, "Waiting...")
  TextGadget(#PB_Any, 370, 94, 108, 20, "Energy Saver:")
  TextGadget(#GadgetOverviewSaverState, 486, 94, 216, 20, "Waiting...")
  lastActionLabel = TextGadget(#PB_Any, 34, 122, 92, 20, "Latest action:")
  TextGadget(#GadgetLastAction, 132, 122, 570, 20, "")
  UseBoldFont(activeLabel)
  UseBoldFont(#GadgetActivePlan)
  UseBoldFont(modeLabel)
  UseBoldFont(#GadgetPowerSource)
  UseBoldFont(#GadgetOverviewBatteryState)
  UseBoldFont(#GadgetOverviewSaverState)
  UseBoldFont(lastActionLabel)
  gFrameProcessor = FrameGadget(#PB_Any, 18, 166, 700, 104, "Hardware")
  TextGadget(#GadgetCpuInfo, 34, 190, 328, 62, "Reading CPU...")
  TextGadget(#GadgetGpuInfo, 386, 190, 316, 62, "Reading GPU...")
  gFrameOverviewBattery = FrameGadget(#PB_Any, 18, 282, 342, 126, "Battery Runtime")
  TextGadget(#GadgetOverviewRuntime, 34, 306, 310, 86, "Waiting for battery data.")
  gFrameStartup = FrameGadget(#PB_Any, 376, 282, 342, 126, "PowerPilot")
  TextGadget(#GadgetOverviewPowerPilot, 394, 306, 308, 42, "Waiting for app data.")
  CheckBoxGadget(#GadgetAutoStart, 394, 356, 150, 20, "Start with Windows")
  CheckBoxGadget(#GadgetKeepSettings, 552, 356, 140, 20, "Keep settings")
  CheckBoxGadget(#GadgetShowToolTips, 394, 384, 130, 20, "Show tips")

  ; Plans tab: fixed three-plan editor. Manual plan activation is intentionally
  ; not exposed; Windows power mode decides which plan is active.
  AddGadgetItem(#GadgetPanel, -1, "Plans")
  gIntroPlans = TextGadget(#PB_Any, 18, 14, 700, 22, "Edit plan behavior. Windows power mode still chooses the active plan.")
  UseBoldFont(gIntroPlans)
  gFrameManagedPlans = FrameGadget(#PB_Any, 18, 40, 700, 134, "PowerPilot Plans")
  ListIconGadget(#GadgetPlanList, 34, 62, 668, 96, "Plan", 176, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  AddGadgetColumn(#GadgetPlanList, 1, "Installed", 70)
  AddGadgetColumn(#GadgetPlanList, 2, "Purpose", 395)

  gFramePlanSettings = FrameGadget(#PB_Any, 18, 190, 700, 216, "Plan Tuning")
  TextGadget(#PB_Any, 34, 212, 64, 20, "Note:")
  StringGadget(#GadgetPlanSummary, 104, 208, 598, 22, "")
  acHeader = TextGadget(#PB_Any, 154, 238, 110, 20, "Plugged in")
  dcHeader = TextGadget(#PB_Any, 318, 238, 110, 20, "Battery")
  UseBoldFont(acHeader)
  UseBoldFont(dcHeader)
  TextGadget(#PB_Any, 34, 262, 86, 20, "Energy:")
  SpinGadget(#GadgetPlanAcEpp, 154, 258, 72, 22, 0, 100, #PB_Spin_Numeric)
  SpinGadget(#GadgetPlanDcEpp, 318, 258, 72, 22, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 286, 86, 20, "CPU boost:")
  ComboBoxGadget(#GadgetPlanAcBoost, 154, 282, 112, 22)
  ComboBoxGadget(#GadgetPlanDcBoost, 318, 282, 112, 22)
  TextGadget(#PB_Any, 34, 310, 86, 20, "Max CPU:")
  SpinGadget(#GadgetPlanAcState, 154, 306, 72, 22, 1, 100, #PB_Spin_Numeric)
  SpinGadget(#GadgetPlanDcState, 318, 306, 72, 22, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 334, 86, 20, "CPU MHz cap:")
  SpinGadget(#GadgetPlanAcFreq, 154, 330, 72, 22, 0, 6000, #PB_Spin_Numeric)
  SpinGadget(#GadgetPlanDcFreq, 318, 330, 72, 22, 0, 6000, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 458, 262, 64, 20, "Cooling:")
  acCoolingHeader = TextGadget(#PB_Any, 528, 238, 80, 20, "Plugged in")
  dcCoolingHeader = TextGadget(#PB_Any, 618, 238, 80, 20, "Battery")
  UseBoldFont(acCoolingHeader)
  UseBoldFont(dcCoolingHeader)
  ComboBoxGadget(#GadgetPlanAcCooling, 528, 258, 80, 22)
  ComboBoxGadget(#GadgetPlanDcCooling, 618, 258, 80, 22)
  ButtonGadget(#GadgetPlanSave, 528, 358, 80, 26, "Save plan")
  ButtonGadget(#GadgetPlanReset, 618, 358, 80, 26, "Defaults")

  ; Battery Saver tab: Windows battery/energy-saver policy plus PowerPilot's
  ; runtime saver behavior. Values are written to PowerPilot-owned plans.
  AddGadgetItem(#GadgetPanel, -1, "Battery Saver")
  FrameGadget(#PB_Any, 18, 18, 340, 142, "Energy Saver")
  sectionHeader = TextGadget(#PB_Any, 34, 42, 308, 20, "Windows policy")
  UseBoldFont(sectionHeader)
  TextGadget(#PB_Any, 34, 70, 108, 20, "Mode:")
  ComboBoxGadget(#GadgetEnergySaverMode, 154, 66, 174, 22)
  TextGadget(#PB_Any, 34, 102, 108, 20, "Turn on at:")
  SpinGadget(#GadgetEnergySaverThreshold, 154, 98, 70, 22, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 230, 102, 24, 20, "%")
  TextGadget(#PB_Any, 34, 134, 108, 20, "Brightness:")
  SpinGadget(#GadgetEnergySaverBrightness, 154, 130, 70, 22, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 230, 134, 24, 20, "%")

  FrameGadget(#PB_Any, 378, 18, 340, 142, "Runtime Saver")
  sectionHeader = TextGadget(#PB_Any, 394, 42, 308, 20, "While running")
  UseBoldFont(sectionHeader)
  CheckBoxGadget(#GadgetThrottleMaintenance, 394, 70, 150, 20, "Throttle background")
  CheckBoxGadget(#GadgetDeepIdleSaver, 552, 70, 140, 20, "Deep idle saver")
  CheckBoxGadget(#GadgetRestoreNormalPlanOnExit, 394, 102, 260, 20, "Restore normal plan on exit")

  FrameGadget(#PB_Any, 18, 180, 700, 158, "Low Battery Guard")
  sectionHeader = TextGadget(#PB_Any, 34, 204, 668, 20, "Windows thresholds")
  UseBoldFont(sectionHeader)
  TextGadget(#PB_Any, 34, 236, 92, 20, "Low warning:")
  SpinGadget(#GadgetBatteryLowWarningPercent, 132, 232, 64, 22, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 202, 236, 24, 20, "%")
  TextGadget(#PB_Any, 264, 236, 86, 20, "Critical:")
  SpinGadget(#GadgetBatteryCriticalPercent, 352, 232, 64, 22, 1, 99, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 422, 236, 24, 20, "%")
  TextGadget(#PB_Any, 494, 236, 70, 20, "Reserve:")
  SpinGadget(#GadgetBatteryReservePercent, 574, 232, 64, 22, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 644, 236, 24, 20, "%")
  TextGadget(#PB_Any, 34, 270, 190, 20, "Low action:")
  ComboBoxGadget(#GadgetBatteryLowAction, 34, 292, 190, 22)
  TextGadget(#PB_Any, 264, 270, 190, 20, "Critical action:")
  ComboBoxGadget(#GadgetBatteryCriticalAction, 264, 292, 190, 22)
  TextGadget(#PB_Any, 494, 292, 190, 22, "Warning only")
  TextGadget(#PB_Any, 34, 322, 668, 20, "Reserve has no separate action; Low and Critical handle Windows actions.")

  FrameGadget(#PB_Any, 18, 356, 700, 92, "Summary")
  TextGadget(#GadgetBatterySaverSummary, 34, 380, 668, 54, "Battery Saver summary appears here.")

  ; PowerPilot Log tab: settings plus retained CSV rows. The visible list shows
  ; the full retained 168-hour log window and supports multi-row copy.
  AddGadgetItem(#GadgetPanel, -1, "PowerPilot Log")
  gFrameBatterySettings = FrameGadget(#PB_Any, 18, 18, 700, 130, "Sampling and Estimates")
  CheckBoxGadget(#GadgetBatteryLogEnabled, 34, 44, 128, 20, "Log samples")
  TextGadget(#PB_Any, 184, 46, 82, 20, "Log every:")
  SpinGadget(#GadgetBatteryLogMinutes, 272, 42, 70, 22, 1, 1440, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 348, 46, 48, 20, "min")
  TextGadget(#PB_Any, 420, 46, 82, 20, "Read every:")
  SpinGadget(#GadgetBatteryRefreshSeconds, 508, 42, 70, 22, 5, 3600, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 584, 46, 48, 20, "sec")

  TextGadget(#PB_Any, 34, 80, 92, 20, "Empty at:")
  SpinGadget(#GadgetBatteryMinPercent, 132, 76, 70, 22, 0, 99, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 224, 80, 92, 20, "Full at:")
  SpinGadget(#GadgetBatteryMaxPercent, 322, 76, 70, 22, 2, 100, #PB_Spin_Numeric)
  CheckBoxGadget(#GadgetBatteryLimiterEnabled, 420, 78, 124, 20, "Use charge limit")
  SpinGadget(#GadgetBatteryLimiterMaxPercent, 568, 76, 70, 22, 2, 100, #PB_Spin_Numeric)

  TextGadget(#PB_Any, 34, 116, 92, 20, "Average window:")
  SpinGadget(#GadgetBatterySmoothingMinutes, 132, 112, 70, 22, 5, 240, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 208, 116, 42, 20, "min")
  TextGadget(#PB_Any, 272, 116, 126, 20, "Startup drain:")
  SpinGadget(#GadgetBatteryStartupDrain, 404, 112, 70, 22, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 480, 116, 48, 20, "%/h")
  ButtonGadget(#GadgetBatteryStatsReset, 584, 110, 104, 26, "Reset log")

  FrameGadget(#PB_Any, 18, 160, 700, 292, "Retained Log")
  ListIconGadget(#GadgetBatteryLogPreview, 34, 184, 668, 226, "Timestamp", BatteryLogColumnWidth(0), #PB_ListIcon_FullRowSelect | #PB_ListIcon_MultiSelect)
  AddGadgetColumn(#GadgetBatteryLogPreview, 1, "Battery %", BatteryLogColumnWidth(1))
  AddGadgetColumn(#GadgetBatteryLogPreview, 2, "Avg time", BatteryLogColumnWidth(2))
  AddGadgetColumn(#GadgetBatteryLogPreview, 3, "Instant time", BatteryLogColumnWidth(3))
  AddGadgetColumn(#GadgetBatteryLogPreview, 4, "Win time", BatteryLogColumnWidth(4))
  AddGadgetColumn(#GadgetBatteryLogPreview, 5, "Now rate", BatteryLogColumnWidth(5))
  AddGadgetColumn(#GadgetBatteryLogPreview, 6, "Plugged in", BatteryLogColumnWidth(6))
  AddGadgetColumn(#GadgetBatteryLogPreview, 7, "Batt W", BatteryLogColumnWidth(7))
  AddGadgetColumn(#GadgetBatteryLogPreview, 8, "Screen", BatteryLogColumnWidth(8))
  AddGadgetColumn(#GadgetBatteryLogPreview, 9, "Laptop %", BatteryLogColumnWidth(9))
  ButtonGadget(#GadgetBatteryLogCopyRow, 514, 420, 86, 24, "Copy rows")
  ButtonGadget(#GadgetBatteryLogCopyAll, 608, 420, 94, 24, "Copy CSV")

  ; Battery Graph tab: live telemetry and the large gliding percent graph.
  AddGadgetItem(#GadgetPanel, -1, "Battery Graph")
  gFrameBatteryStatus = FrameGadget(#PB_Any, 18, 18, 328, 180, "Live Status")
  batteryLabel = TextGadget(#PB_Any, 34, 40, 140, 17, "Battery:")
  TextGadget(#GadgetBatteryPercent, 178, 40, 138, 17, "Reading...")
  TextGadget(#PB_Any, 34, 59, 140, 17, "State:")
  TextGadget(#GadgetBatteryConnection, 178, 59, 154, 17, "")
  TextGadget(#GadgetBatteryCharging, 0, 0, 1, 1, "")
  HideGadget(#GadgetBatteryCharging, #True)
  TextGadget(#PB_Any, 34, 78, 140, 17, "Remaining:")
  TextGadget(#GadgetBatteryCapacity, 178, 78, 154, 17, "")
  TextGadget(#PB_Any, 34, 97, 140, 17, "Battery draw:")
  TextGadget(#GadgetBatteryRates, 178, 97, 154, 17, "")
  TextGadget(#PB_Any, 34, 116, 140, 17, "Voltage:")
  TextGadget(#GadgetBatteryVoltage, 178, 116, 154, 17, "")
  TextGadget(#PB_Any, 34, 143, 140, 17, "App use:")
  TextGadget(#GadgetPowerPilotDraw, 178, 143, 154, 17, "Sampling 60s")
  UseBoldFont(batteryLabel)
  UseBoldFont(#GadgetBatteryPercent)

  gFrameBatteryEstimate = FrameGadget(#PB_Any, 368, 18, 350, 180, "Time Estimates")
  TextGadget(#PB_Any, 384, 40, 112, 17, "Average:")
  TextGadget(#GadgetBatteryEstimate, 502, 40, 186, 17, "")
  TextGadget(#PB_Any, 384, 59, 112, 17, "Now:")
  TextGadget(#GadgetBatteryInstantEstimate, 502, 59, 186, 17, "")
  TextGadget(#PB_Any, 384, 78, 112, 17, "Windows:")
  TextGadget(#GadgetBatteryRuntime, 502, 78, 186, 17, "")
  TextGadget(#PB_Any, 384, 97, 112, 17, "Full-to-min:")
  TextGadget(#GadgetBatteryFullEstimate, 502, 97, 186, 17, "")
  TextGadget(#PB_Any, 384, 116, 112, 17, "Wear:")
  TextGadget(#GadgetBatteryWear, 502, 116, 186, 17, "")
  TextGadget(#PB_Any, 384, 135, 112, 17, "As new:")
  TextGadget(#GadgetBatteryNominalEstimate, 502, 135, 186, 17, "")
  TextGadget(#PB_Any, 384, 154, 112, 17, "Capacity:")
  TextGadget(#GadgetBatteryMaxCapacity, 502, 154, 186, 17, "")
  TextGadget(#PB_Any, 384, 173, 112, 17, "Cycle count:")
  TextGadget(#GadgetBatteryCycle, 502, 173, 186, 17, "")

  gFrameBatteryGraph = FrameGadget(#PB_Any, 18, 204, 700, 255, BatteryGraphWindowTitle())
  CheckBoxGadget(#GadgetBatteryGraphShowMarkers, 34, 430, 150, 20, "Markers")
  TextGadget(#PB_Any, 478, 430, 112, 20, "History:", #PB_Text_Right)
  ComboBoxGadget(#GadgetBatteryGraphHours, 598, 426, 88, 24)
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "6 h")
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "12 h")
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "18 h")
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "24 h")
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "36 h")
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "48 h")
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "60 h")
  AddGadgetItem(#GadgetBatteryGraphHours, -1, "72 h")
  CanvasGadget(#GadgetBatteryGraph, 34, 226, 668, 196)

  ; Battery Stats tab: derived summaries and display/export controls.
  AddGadgetItem(#GadgetPanel, -1, "Battery Stats")
  FrameGadget(#PB_Any, 18, 18, 340, 92, "Latest Event")
  TextGadget(#GadgetBatterySessionSummary, 34, 42, 308, 54, "No sleep, wake, shutdown, or startup event yet.")
  FrameGadget(#PB_Any, 378, 18, 340, 92, "Sleep/Off Loss")
  TextGadget(#GadgetBatteryOffLossSummary, 394, 42, 308, 54, "No sleep, hibernate, shutdown, or missing-sample battery loss yet.")
  FrameGadget(#PB_Any, 18, 124, 700, 112, "Today")
  TextGadget(#GadgetBatteryDailySummary, 34, 148, 668, 74, "Waiting for battery samples.")
  FrameGadget(#PB_Any, 18, 254, 340, 194, "Visible Log Columns")
  CheckBoxGadget(#GadgetLogShowAverage, 40, 286, 84, 20, "Avg time")
  CheckBoxGadget(#GadgetLogShowInstant, 154, 286, 96, 20, "Now/rate")
  CheckBoxGadget(#GadgetLogShowWindows, 268, 286, 84, 20, "Win time")
  CheckBoxGadget(#GadgetLogShowConnected, 40, 314, 100, 20, "Plugged in")
  CheckBoxGadget(#GadgetLogShowPower, 154, 314, 84, 20, "Batt W")
  CheckBoxGadget(#GadgetLogShowBrightness, 268, 314, 84, 20, "Laptop %")
  CheckBoxGadget(#GadgetLogShowScreen, 40, 342, 84, 20, "Screen")
  CheckBoxGadget(#GadgetLogShowEvents, 154, 342, 84, 20, "Events")
  sectionHeader = TextGadget(#PB_Any, 34, 372, 308, 18, "Display only")
  UseBoldFont(sectionHeader)
  TextGadget(#PB_Any, 34, 396, 308, 16, "Copy CSV includes all columns.")
  ButtonGadget(#GadgetSettingsExport, 40, 418, 126, 24, "Export settings")
  ButtonGadget(#GadgetSettingsImport, 190, 418, 126, 24, "Import settings")
  FrameGadget(#PB_Any, 378, 254, 340, 194, "Battery Analysis")
  TextGadget(#GadgetBatteryAnalysisSummary, 394, 278, 308, 132, "Waiting for retained battery rows.")
  ButtonGadget(#GadgetBatteryAnalysisRefresh, 476, 418, 144, 24, "Refresh analysis")

  ; Power Use tab: show the compact PP Power Use row without crowding the live
  ; battery panel. Method details live in README/FUNCTION_MAP.
  AddGadgetItem(#GadgetPanel, -1, "Power Use")
  FrameGadget(#PB_Any, 18, 18, 340, 174, "App Battery Cost")
  sectionHeader = TextGadget(#PB_Any, 34, 42, 308, 20, "Last 60 seconds")
  UseBoldFont(sectionHeader)
  TextGadget(#GadgetPowerUseSummary, 34, 68, 308, 96, "Waiting for 60 seconds of app CPU samples.")
  FrameGadget(#PB_Any, 378, 18, 340, 174, "Battery Source")
  sectionHeader = TextGadget(#PB_Any, 394, 42, 308, 20, "Current read path")
  UseBoldFont(sectionHeader)
  TextGadget(#GadgetPowerUseStatus, 394, 68, 308, 96, "Battery source appears after the first read.")
  powerUseText$ = "- App power draw estimates this app's battery use." + #CRLF$
  powerUseText$ + "- Full-to-empty cost converts that draw into runtime seconds." + #CRLF$
  powerUseText$ + "- 0.00 mW is normal when plugged in, idle, or missing watts." + #CRLF$
  powerUseText$ + "- This is not a hardware power meter."
  idleText$ = "- Compare visible window with tray-hidden mode." + #CRLF$
  idleText$ + "- Check the log for screen, wake, and update rows." + #CRLF$
  idleText$ + "- Keep Read every and Log every modest." + #CRLF$
  idleText$ + "- Use Task Manager or Energy report for other causes."
  FrameGadget(#PB_Any, 18, 210, 340, 238, "Reading the Estimate")
  sectionHeader = TextGadget(#PB_Any, 34, 234, 308, 20, "Meaning")
  UseBoldFont(sectionHeader)
  TextGadget(#GadgetPowerUseInterpretation, 34, 262, 308, 154, powerUseText$)
  FrameGadget(#PB_Any, 378, 210, 340, 238, "Idle Checks")
  sectionHeader = TextGadget(#PB_Any, 394, 234, 308, 20, "What to compare")
  UseBoldFont(sectionHeader)
  TextGadget(#GadgetPowerUseIdleChecklist, 394, 262, 308, 154, idleText$)

  ; Battery Test tab: live calibration/test observer. It records what Windows
  ; reports, including plugged-in discharging states used by vendor calibration.
  AddGadgetItem(#GadgetPanel, -1, "Battery Test")
  FrameGadget(#PB_Any, 18, 18, 340, 174, "Test Status")
  sectionHeader = TextGadget(#PB_Any, 34, 42, 308, 20, "Guided test")
  UseBoldFont(sectionHeader)
  TextGadget(#PB_Any, 34, 66, 92, 18, "Mode:")
  TextGadget(#GadgetBatteryTestMode, 132, 66, 196, 18, "Monitor")
  TextGadget(#PB_Any, 34, 90, 92, 18, "Phase:")
  TextGadget(#GadgetBatteryTestPhase, 132, 90, 196, 18, "Idle")
  TextGadget(#PB_Any, 34, 114, 92, 18, "Elapsed:")
  TextGadget(#GadgetBatteryTestElapsed, 132, 114, 196, 18, "0h 00m")
  ButtonGadget(#GadgetBatteryTestStart, 34, 146, 92, 26, "Manual")
  ButtonGadget(#GadgetBatteryTestLenovo, 136, 146, 112, 26, "Lenovo reset")
  ButtonGadget(#GadgetBatteryTestEnd, 258, 146, 70, 26, "End")

  FrameGadget(#PB_Any, 378, 18, 340, 174, "Live Stats")
  TextGadget(#PB_Any, 394, 42, 128, 18, "Battery:")
  TextGadget(#GadgetBatteryTestPercent, 528, 42, 174, 18, "Unknown")
  TextGadget(#PB_Any, 394, 68, 128, 18, "Remaining:")
  TextGadget(#GadgetBatteryTestRemaining, 528, 68, 174, 18, "Unknown")
  TextGadget(#PB_Any, 394, 94, 128, 18, "Watts:")
  TextGadget(#GadgetBatteryTestWatts, 528, 94, 174, 18, "Unknown")
  TextGadget(#PB_Any, 394, 120, 128, 18, "Estimate:")
  TextGadget(#GadgetBatteryTestEstimate, 528, 120, 174, 18, "Unknown")
  TextGadget(#GadgetBatteryTestGuide, 394, 146, 308, 34, "Start a manual test or leave this open during vendor calibration.")

  FrameGadget(#PB_Any, 18, 210, 340, 238, "Report")
  ButtonGadget(#GadgetBatteryTestOpenReport, 102, 228, 104, 24, "Open report")
  ButtonGadget(#GadgetBatteryTestCopy, 224, 228, 104, 24, "Copy report")
  TextGadget(#GadgetBatteryTestSummary, 34, 260, 308, 170, "No test log has been started yet.")

  FrameGadget(#PB_Any, 378, 210, 340, 238, "Drain Load")
  sectionHeader = TextGadget(#PB_Any, 394, 234, 308, 20, "Automatic drain")
  UseBoldFont(sectionHeader)
  TextGadget(#PB_Any, 394, 264, 78, 18, "Target:")
  SpinGadget(#GadgetBatteryLoadMinutes, 482, 260, 72, 22, 15, 720, #PB_Spin_Numeric)
  SetGadgetState(#GadgetBatteryLoadMinutes, ClampInt(gSettings\BatteryCalibrationDrainMinutes, 15, 720))
  TextGadget(#PB_Any, 560, 264, 34, 18, "min")
  ButtonGadget(#GadgetBatteryLoadAuto, 602, 258, 100, 26, "Auto")
  TextGadget(#GadgetBatteryLoadAutoStatus, 394, 294, 308, 18, "Auto off")
  TextGadget(#PB_Any, 394, 322, 78, 18, "Load:")
  TextGadget(#GadgetBatteryLoadStatus, 482, 322, 220, 18, "Off")
  CheckBoxGadget(#GadgetBatteryLoadTestMode, 394, 350, 140, 22, "Test mode")
  TextGadget(#GadgetBatteryLoadNote, 394, 382, 308, 42, "Auto drain stops when charging starts.")

  ; About tab: concise in-app identity, license, privacy, and operating model.
  AddGadgetItem(#GadgetPanel, -1, "About")
  aboutPurpose$ = "Local tray app for power plans, battery history, screen events, and CSV export."
  FrameGadget(#PB_Any, 18, 18, 700, 84, "PowerPilot")
  aboutTitle = TextGadget(#PB_Any, 34, 42, 668, 20, #AppFullName$, #PB_Text_Center)
  aboutSubtitle = TextGadget(#GadgetAboutPurpose, 34, 66, 668, 28, aboutPurpose$, #PB_Text_Center)
  UseBoldFont(aboutTitle)

  aboutOperation$ = "Windows power mode chooses the plan:" + #CRLF$
  aboutOperation$ + "- Best performance -> PowerPilot Maximum" + #CRLF$
  aboutOperation$ + "- Balanced -> PowerPilot Balanced" + #CRLF$
  aboutOperation$ + "- Best power efficiency -> PowerPilot Battery" + #CRLF$
  aboutOperation$ + "- Edit values on Plans; choose mode in Windows."
  FrameGadget(#PB_Any, 18, 118, 340, 120, "Plan Follow")
  TextGadget(#GadgetAboutOperation, 34, 142, 308, 78, aboutOperation$)

  aboutData$ = "- Battery percent, time, watts, and plug state." + #CRLF$
  aboutData$ + "- Screen state, brightness, Energy Saver, power events, and app rows."
  FrameGadget(#PB_Any, 378, 118, 340, 120, "Logged Data")
  TextGadget(#GadgetAboutData, 394, 142, 308, 78, aboutData$)

  aboutVersion$ = "- Reads local Windows power, battery, display, CPU, and brightness data." + #CRLF$
  aboutVersion$ + "- Writes local settings, retained log rows, and owned plan values." + #CRLF$
  aboutVersion$ + "- Sends nothing by itself."
  FrameGadget(#PB_Any, 18, 252, 340, 120, "Local Data")
  TextGadget(#GadgetAboutVersion, 34, 276, 308, 78, aboutVersion$)

  aboutBoundaries$ = "- Author: John Torset." + #CRLF$
  aboutBoundaries$ + "- MIT License in LICENSE.txt." + #CRLF$
  aboutBoundaries$ + "- Guide and uninstall notes in README.txt."
  FrameGadget(#PB_Any, 378, 252, 340, 120, "Files")
  TextGadget(#GadgetAboutLicense, 394, 276, 308, 50, aboutBoundaries$)
  ButtonGadget(#GadgetAboutOpenReadme, 452, 334, 120, 26, "Open README")
  ButtonGadget(#GadgetAboutOpenLicense, 582, 334, 120, 26, "Open LICENSE")

  aboutBoundaries$ = "PowerPilot does not measure CPU package watts, display watts, fan power, temperature, Wi-Fi, storage, GPU load, or other apps." + #CRLF$
  aboutBoundaries$ + "Power Use estimates only this app's battery cost; it is not a hardware meter."
  FrameGadget(#PB_Any, 18, 386, 700, 62, "Important Boundaries")
  TextGadget(#GadgetAboutBoundaries, 34, 410, 668, 28, aboutBoundaries$, #PB_Text_Center)
  CloseGadgetList()

  ButtonGadget(#GadgetHideToTray, 14, 512, 96, 28, "Hide")
  ButtonGadget(#GadgetExit, 650, 512, 96, 28, "Exit")
  StoreUiBaseLayout()
  ApplyMainWindowLayoutScale()

  AddGadgetItem(#GadgetPlanAcBoost, -1, "Disabled")
  AddGadgetItem(#GadgetPlanAcBoost, -1, "Efficient")
  AddGadgetItem(#GadgetPlanAcBoost, -1, "Aggressive")
  AddGadgetItem(#GadgetPlanDcBoost, -1, "Disabled")
  AddGadgetItem(#GadgetPlanDcBoost, -1, "Efficient")
  AddGadgetItem(#GadgetPlanDcBoost, -1, "Aggressive")
  AddGadgetItem(#GadgetPlanAcCooling, -1, "Passive")
  AddGadgetItem(#GadgetPlanAcCooling, -1, "Active")
  AddGadgetItem(#GadgetPlanDcCooling, -1, "Passive")
  AddGadgetItem(#GadgetPlanDcCooling, -1, "Active")
  AddGadgetItem(#GadgetEnergySaverMode, -1, "Automatic threshold")
  AddGadgetItem(#GadgetEnergySaverMode, -1, "Battery plan always")
  AddGadgetItem(#GadgetBatteryLowAction, -1, "Do nothing")
  AddGadgetItem(#GadgetBatteryLowAction, -1, "Sleep")
  AddGadgetItem(#GadgetBatteryLowAction, -1, "Hibernate")
  AddGadgetItem(#GadgetBatteryLowAction, -1, "Shut down")
  AddGadgetItem(#GadgetBatteryCriticalAction, -1, "Do nothing")
  AddGadgetItem(#GadgetBatteryCriticalAction, -1, "Sleep")
  AddGadgetItem(#GadgetBatteryCriticalAction, -1, "Hibernate")
  AddGadgetItem(#GadgetBatteryCriticalAction, -1, "Shut down")

  ; Startup order matters: settings first, then power-event cleanup/logging,
  ; learned drain, retained graph reload, live battery refresh, and plan follow.
  ApplySettingsToGui()
  LogStartupPowerEvents()
  AutoSetInitialBatteryDrainFromLog()
  ApplySettingsToGui()
  WriteBatteryAppEvent("PowerPilot start")
  CleanupOldPowerPilotVersions(#False, #True)
  LoadBatteryGraphFromLog()
  MonitorAutomaticPlans()

  If showWindow
    PrepareWindowForDisplay()
    HideWindow(#WindowMain, #False)
    SetForegroundWindow_(WindowID(#WindowMain))
    StartRefreshTimer()
  Else
    HideToTray()
  EndIf
EndProcedure

; Main GUI event loop. Closing/minimizing hides to tray; explicit Exit ends.
Procedure RunGui(showWindow.i)
  Protected event.i
  gStartedInTrayMode = Bool(showWindow = #False)
  CreateMainWindow(showWindow)
  Repeat
    event = WaitWindowEvent()
    Select event
      Case #PB_Event_CloseWindow
        HideToTray()
      Case #PB_Event_Gadget
        HandleAction(EventGadget())
      Case #PB_Event_Menu
        HandleMenu(EventMenu())
      Case #PB_Event_SysTray
        If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick
          ShowFromTray()
        ElseIf EventType() = #PB_EventType_RightClick
          DisplayPopupMenu(#PopupTray, WindowID(#WindowMain))
        EndIf
      Case #PB_Event_Timer
        Select EventTimer()
          Case #TimerRefresh
            RunPeriodicRefresh()

          Case #TimerBatterySettingsApply
            ApplyPendingBatterySettings()
        EndSelect
      Case #PB_Event_SizeWindow
        ApplyMainWindowLayoutScale()
      Case #PB_Event_MinimizeWindow
        HideToTray()
    EndSelect
  ForEver
EndProcedure

; Program entry point. Maintenance commands are used by the installer and should
; exit with conventional success/failure codes. No command opens the GUI.
LoadSettings()
gSelectedPlan = PlanIndexByName(gSettings\LastPlan)
If gSelectedPlan < 0 : gSelectedPlan = 1 : EndIf

If CountProgramParameters() > 0
  Select LCase(ProgramParameter(0))
    Case "/create-plans"
      If CreateManagedPlans() : End 0 : Else : End 1 : EndIf
    Case "/cleanup-plans"
      If CleanupManagedPlans() : End 0 : Else : End 1 : EndIf
    Case "/install-refresh"
      If InstallRefresh() : End 0 : Else : End 1 : EndIf
    Case "/cleanup-old-versions"
      If CleanupOldPowerPilotVersions(#True, #False) : End 0 : Else : End 1 : EndIf
    Case "/log-update-close-if-running"
      If LogUpdateCloseIfSameExeRunning() : End 0 : Else : End 1 : EndIf
    Case "/log-update-close-if-powerpilot-running"
      If LogUpdateCloseIfAnyPowerPilotRunning() : End 0 : Else : End 1 : EndIf
    Case "/startup-on"
      gSettings\AutoStartWithApp = #True
      SaveSettings()
      If SetStartupRegistry(#True) : End 0 : Else : End 1 : EndIf
    Case "/startup-off"
      gSettings\AutoStartWithApp = #False
      SaveSettings()
      If SetStartupRegistry(#False) : End 0 : Else : End 1 : EndIf
    Case "/cleanup-settings"
      If CleanupSettingsData() : End 0 : Else : End 1 : EndIf
    Case "/query-keep-settings"
      If gSettings\KeepSettingsOnReinstall : End 1 : Else : End 0 : EndIf
    Case "/follow-once"
      If ApplyWindowsPowerFollow(#True) : End 0 : Else : End 1 : EndIf
    Case "/tray"
      If EnsureSingleInstance() = #False : End 0 : EndIf
      RunGui(#False)
    Case "/show"
      If EnsureSingleInstance() = #False : End 0 : EndIf
      RunGui(#True)
  EndSelect
EndIf

If EnsureSingleInstance() = #False : End 0 : EndIf
RunGui(#True)

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 1
; EnableThread
; DPIAware
