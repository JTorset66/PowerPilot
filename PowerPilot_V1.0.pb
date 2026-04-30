EnableExplicit

; PowerPilot v1.0
; Windows tray utility for behavior profiles and target-based automatic cap control.

#AppName$            = "PowerPilot"
#AppVersion$         = "1.0"
#AppFullName$        = #AppName$ + " v" + #AppVersion$
#AppRunKey$          = "PowerPilot"
#SettingsFolderName$ = "PowerPilot"
#SettingsFileName$   = "settings.ini"
#TrayTooltip$        = #AppFullName$

#SlowGpuPerfHelperIntervalSeconds = 60
#AmdAdlxHelperPollSeconds = 5
#AmdAdlxAvailableProbeSeconds = 60
#AmdAdlxUnavailableProbeSeconds = 30
#AmdAdlxControlMinimumIntervalMs = 15000
#AmdAdlxRecoveryIntervalMs = 45000

#PowerSourceUnknown = 0
#PowerSourceBattery = 1
#PowerSourcePlugged = 2

#PlanPrefixNew$   = "PowerPilot "
#PlanPrefixOld$   = "Codex "
#PlanVisible$     = "PowerPilot"
#PlanBattery$     = "PowerPilot Battery"
#PlanPlugged$     = "PowerPilot Balanced"
#PlanQuiet$       = "PowerPilot Quiet"
#PlanFull$        = "PowerPilot Maximum"

#FILE_MAP_READ    = $0004
#HKEY_LOCAL_MACHINE = $80000002
#KEY_READ         = $20019
#REG_SZ           = 1
#REG_EXPAND_SZ    = 2
#NIM_ADD          = 0
#NIM_MODIFY       = 1
#NIM_DELETE       = 2
#NIF_MESSAGE      = $00000001
#NIF_ICON         = $00000002
#NIF_TIP          = $00000004
#WM_APP           = $8000
#WM_SETREDRAW     = $000B
#WM_SETICON       = $0080
#WM_CONTEXTMENU   = $007B
#WM_LBUTTONUP     = $0202
#WM_LBUTTONDBLCLK = $0203
#WM_RBUTTONUP     = $0205
#EM_LINESCROLL    = $00B6
#EM_GETFIRSTVISIBLELINE = $00CE
#TrayCallbackMsg  = #WM_APP + 77
#SW_SHOW          = 5
#SW_RESTORE       = 9
#HWND_TOPMOST     = -1
#HWND_NOTOPMOST   = -2
#SWP_NOMOVE       = $0002
#SWP_NOSIZE       = $0001
#SWP_NOACTIVATE   = $0010
#VK_CONTROL       = $11
#VK_SHIFT         = $10
#VK_LWIN          = $5B
#VK_B             = $42
#KEYEVENTF_KEYUP  = $0002

#WindowMain       = 1
#WindowTray       = 2
#WindowDependency = 3
#ImageTrayMain    = 1
#TrayIconMain     = 1
#PopupTray        = 1
#StateMutex       = 1

#TimerUiRefresh   = 1
#UiRefreshMs      = 500
#UiLogLineCount   = 8
#DefaultAutoControlAverageSeconds = 6 ; Dashboard smoothing. Auto Control uses a shorter bounded response window.
#AutoControlResponseAverageMaxMs = 2000
#AutoControlApplyIntervalMs = 1500
#MinimumDynamicCpuCapPercent = 5
#MinimumDynamicCpuMHz = 400
#TelemetryHistorySize = 24
#TelemetryLatchGracePolls = 3
#TelemetryLatchMinimumMs = 15000
#TelemetryLatchMaximumMs = 120000
#MinimumMeaningfulPowerW = 0.05
#PDH_MORE_DATA    = $800007D2
#PDH_CSTATUS_VALID_DATA = 0
#PDH_CSTATUS_NEW_DATA = 1
#PDH_FMT_DOUBLE   = $00000200
#WinCounterCpu    = 1
#WinCounterTempHp = 4
#WinCounterTemp   = 5

Enumeration 100
  #MenuOpen
  #MenuToggleAuto
  #MenuAutoOnce
  #MenuBattery
  #MenuPlugged
  #MenuFull
  #MenuDependencies
  #MenuCreatePlans
  #MenuCleanupPlans
  #MenuExit
EndEnumeration

Enumeration 200
  #GadgetMainPanel
  #GadgetOverviewSourceValue
  #GadgetOverviewTempSensorValue
  #GadgetOverviewTempValue
  #GadgetOverviewGpuMemoryValue
  #GadgetOverviewCpuPowerValue
  #GadgetOverviewPowerValue
  #GadgetOverviewPlanValue
  #GadgetOverviewControlStateValue
  #GadgetSourceValue
  #GadgetSensorValue
  #GadgetTempValue
  #GadgetCpuPowerValue
  #GadgetGpuMemoryValue
  #GadgetPowerValue
  #GadgetControlStateValue
  #GadgetPlanValue
  #GadgetLiveBlendSourceMix
  #GadgetLiveBlendTempSensor
  #GadgetLiveBlendTemp
  #GadgetLiveBlendCpu
  #GadgetLiveBlendGpuMemory
  #GadgetLiveBlendPowerSource
  #GadgetLiveBlendActivePlan
  #GadgetLiveBlendControlState
  #GadgetLiveFallbackStatus
  #GadgetActionValue
  #GadgetOverviewHardwareDetails
  #GadgetAutoEnabled
  #GadgetUseWindows
  #GadgetAmdAdlxEnabled
  #GadgetWindowsInfo
  #GadgetAutoStart
  #GadgetKeepSettings
  #GadgetAutoBatteryPlan
  #GadgetPollSpin
  #GadgetHysteresisSpin
  #GadgetControlDeadbandSpin
  #GadgetAutoControlAverage
  #GadgetPowerTargetEnabled
  #GadgetPowerTargetWatts
  #GadgetTempTargetEnabled
  #GadgetTempTargetC
  #GadgetMinCpuCap
  #GadgetMinCpuMHz
  #GadgetMaxCpuMHz
  #GadgetControllerStatus
  #GadgetPlanList
  #GadgetPlanEditorName
  #GadgetPlanEditorPreset
  #GadgetPlanEditorLoadPreset
  #GadgetPlanEditorSave
  #GadgetPlanEditorNew
  #GadgetPlanEditorDelete
  #GadgetPlanEditorSummary
  #GadgetPlanAcEpp
  #GadgetPlanAcBoost
  #GadgetPlanAcState
  #GadgetPlanAcFreq
  #GadgetPlanAcCooling
  #GadgetPlanDcEpp
  #GadgetPlanDcBoost
  #GadgetPlanDcState
  #GadgetPlanDcFreq
  #GadgetPlanDcCooling
  #GadgetPlanRefreshAll
  #GadgetPlanRemoveAll
  #GadgetAmdAdlxStatus
  #GadgetAmdAdlxGpuName
  #GadgetAmdAdlxFeatures
  #GadgetAmdAdlxMetrics
  #GadgetAmdAdlxRestore
  #GadgetPlanCombo
  #GadgetActivatePlan
  #GadgetAutoOnce
  #GadgetResetDisplay
  #GadgetSaveSettings
  #GadgetDependencies
  #GadgetHideToTray
  #GadgetExit
  #GadgetStatusLine
  #GadgetDependencyInfo
  #GadgetDependencySummary
  #GadgetDependencyRefresh
  #GadgetDependencyCopy
  #GadgetDependencyLaunch
  #GadgetDependencyClose
EndEnumeration

Structure TempReading
  valid.i
  source.s
  sensor.s
  celsius.d
  windowsTempValid.i
  windowsTempSensor.s
  windowsTempCelsius.d
  cpuPackageValid.i
  cpuPackageSensor.s
  cpuPackageWatts.d
  gpuMemoryValid.i
  gpuMemorySensor.s
  gpuMemoryMb.d
  gpuSharedMemoryValid.i
  gpuSharedMemorySensor.s
  gpuSharedMemoryMb.d
  gpuDeviceNames.s
EndStructure

Structure TelemetryLatchState
  Last.TempReading
  TempTick.q
  PreviousTempTick.q
  WindowsTempTick.q
  PreviousWindowsTempTick.q
  CpuPowerTick.q
  PreviousCpuPowerTick.q
  GpuMemoryTick.q
  PreviousGpuMemoryTick.q
EndStructure

Structure AppSettings
  AutoEnabled.i
  UseWindows.i
  AutoStartWithApp.i
  KeepSettingsOnReinstall.i
  AutoBatteryPlan.i
  AmdAdlxEnabled.i
  PowerTargetEnabled.i
  TemperatureTargetEnabled.i
  PowerTargetWatts.i
  TemperatureTargetC.i
  ControlDeadband.i
  MinCpuCapPercent.i
  MinCpuMHz.i
  MaxCpuMHz.i
  PollSeconds.i
  Hysteresis.i
  AutoControlAverageSeconds.i
  LastPluggedPlan.s
  CurrentManagedPlan.s
EndStructure

Structure AmdAdlxState
  Probed.i
  Available.i
  SdkCompiled.i
  AmdGpuPresent.i
  Enabled.i
  GpuName.s
  StatusText.s
  FeatureText.s
  MetricsText.s
  MetricsValid.i
  UsageValid.i
  UsagePercent.d
  ClockValid.i
  ClockMhz.i
  PowerValid.i
  PowerWatts.d
  TemperatureValid.i
  TemperatureC.d
  GfxMaxSupported.i
  PowerLimitSupported.i
  TdcLimitSupported.i
  LastProbeTick.q
  LastMetricsTick.q
  LastControlTick.q
  LastRecoverTick.q
  LastDiscreteGpuConnected.i
  LastGpuHardwareText.s
  ControlIntegral.d
  HasChangedSettings.i
EndStructure

Structure RuntimeState
  LastTemp.TempReading
  LastControl.TempReading
  LastWindows.TempReading
  LastFallback.TempReading
  ActivePlan.s
  LastAction.s
  PowerSource.i
  AutoEnabled.i
  StopWorker.i
  WorkerRunning.i
  ImmediateRefresh.i
EndStructure

Structure DynamicControlState
  Active.i
  CpuCapPercent.i
  CpuCapMhz.i
  Integral.d
  LastApplyTick.q
  StatusText.s
EndStructure

Structure DependencyStatus
  WindowsEnabled.i
  WindowsTelemetryReady.i
  WindowsTempReady.i
  WindowsPowerReady.i
  WindowsGpuReady.i
  FallbackAvailable.i
  ManagedPlansReady.i
  SensorReady.i
  SensorSource.s
  SensorName.s
EndStructure

Structure PlanDefinition
  Name.s
  BuiltIn.i
  DefaultInstalled.i
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

Structure PDH_FMT_COUNTERVALUE_DOUBLE
  CStatus.l
  Padding.l
  doubleValue.d
EndStructure

Structure DoubleHolder
  value.d
EndStructure

Structure WindowsCounterEntry
  kind.i
  path.s
  handle.i
EndStructure

Prototype.i PdhOpenQueryProto(szDataSource.i, dwUserData.i, *phQuery.Integer)
Prototype.i PdhAddEnglishCounterProto(hQuery.i, szFullCounterPath.p-unicode, dwUserData.i, *phCounter.Integer)
Prototype.i PdhCollectQueryDataProto(hQuery.i)
Prototype.i PdhGetFormattedCounterValueProto(hCounter.i, dwFormat.l, *lpdwType.Long, *pValue.PDH_FMT_COUNTERVALUE_DOUBLE)
Prototype.i PdhExpandWildCardPathProto(szDataSource.i, szWildCardPath.p-unicode, *mszExpandedPathList, *pcchPathListLength.Long, dwFlags.l)
Prototype.i PdhCloseQueryProto(hQuery.i)

Global gSettings.AppSettings
Global gState.RuntimeState
Global gAmdAdlx.AmdAdlxState
Global gDynamicControl.DynamicControlState
Global gWorkerThread.i
Global gStateMutex.i
Global gTrayStart.i
Global gTrayImage.i
Global gTrayReady.i
Global gTrayIconSmall.i
Global gTrayIconLarge.i
Global gTrayData.NOTIFYICONDATA
Global Dim gUiLogLines.s(#UiLogLineCount - 1)
Global gHelpAlertNeeded.i
Global gCachedDependency.DependencyStatus
Global gLastUiLogText$
Global gLastStatusText$
Global gLastOverviewHardwareText$
Global gLastDependencyInfoText$
Global gLastPlanListSignature$
Global gLastPlanComboSignature$
Global gManagedPlansCacheValid.i
Global gManagedPlansCacheValue.i
Global gManagedPlansExistCacheValid.i
Global gManagedPlansExistCacheValue.i
Global gManualOverrideUntil.i
Global gSelectedPlanName$
Global gCachedCpuName$
Global gInstalledMemoryBytes.q
Global NewList gPlanDefs.PlanDefinition()
Global gPdhLibrary.i
Global PdhOpenQueryW.PdhOpenQueryProto
Global PdhAddEnglishCounterW.PdhAddEnglishCounterProto
Global PdhCollectQueryData.PdhCollectQueryDataProto
Global PdhGetFormattedCounterValue.PdhGetFormattedCounterValueProto
Global PdhExpandWildCardPathW.PdhExpandWildCardPathProto
Global PdhCloseQuery.PdhCloseQueryProto
Global Dim gTempSampleTick.q(#TelemetryHistorySize - 1)
Global Dim gTempSampleValue.d(#TelemetryHistorySize - 1)
Global gTempSampleIndex.i
Global gTempLastSource$
Global gTempLastSensor$
Global Dim gCpuPowerSampleTick.q(#TelemetryHistorySize - 1)
Global Dim gCpuPowerSampleValue.d(#TelemetryHistorySize - 1)
Global gCpuPowerSampleIndex.i
Global gCpuPowerLastSensor$
Global Dim gGpuMemorySampleTick.q(#TelemetryHistorySize - 1)
Global Dim gGpuMemorySampleValue.d(#TelemetryHistorySize - 1)
Global gGpuMemorySampleIndex.i
Global gGpuMemoryLastSensor$
Global gBlendTelemetryLatch.TelemetryLatchState
Global gWindowsTelemetryLatch.TelemetryLatchState
Global gFallbackTelemetryLatch.TelemetryLatchState
Global gFontBold.i
Global gFontBoldSmall.i
Global gWindowsPerfHelperHandle.i
Global gWindowsPerfHelperIntervalMs.i
Global gWindowsPerfHelperInBlock.i
Global gWindowsPerfHelperCurrentBlock$
Global gWindowsPerfHelperLatestBlock$
Global gWindowsPerfHelperLatestTick.q
Global gWindowsPerfStartupSnapshotRead.i
Global gWindowsPerfStartupSnapshotBlock$
Global gWindowsPerfStartupSnapshotTick.q
Global gLastHelpAlertState.i = -1

Declare ReadDependencyStatus(*status.DependencyStatus)
Declare.s GetCurrentManagedPlan()
Declare.s EnsureScheme(planName$)
Declare.s GetSchemeGuidByName(planName$)
Declare.i ReadWindowsPmiTelemetry(*reading.TempReading)
Declare.i ReadWindowsEmiTelemetry(*reading.TempReading)
Declare RefreshDependencyWindow()
Declare RememberPluggedPlan(planName$, persist.i = #False)
Declare RememberCurrentManagedPlan(planName$, persist.i = #False)
Declare InitializePlanDefinitions()
Declare.i ManagedPlansPresent()
Declare.i CachedManagedPlansPresent()
Declare.i CachedManagedPlansExist()
Declare InvalidateManagedPlansCache()
Declare RefreshPlanEditor()
Declare RefreshPlanList()
Declare EnsureSettingsDirectory()
Declare SelectPlanComboByName(planName$)
Declare.s MergeLineLists(baseText$, extraText$)
Declare.s ExtractHardwareNameFromSensor(sensorText$)
Declare.s BuildTelemetrySourceDisplay(*reading.TempReading)
Declare.s CurrentGpuHardwareDisplay(*reading.TempReading)
Declare.s BuildGpuDeviceSummary(*reading.TempReading, *windows.TempReading)
Declare.i ActiveDiscreteGpuConnected(*reading.TempReading)
Declare.s CachedCpuName()
Declare.s FormatGpuTelemetryValue(valid.i, valueText$, sensorText$, deviceList$)
Declare.i IsStartupGpuHelperSnapshotSensor(sensorText$)
Declare.s SecondaryFallbackSummary(*reading.TempReading, *windows.TempReading, *fallback.TempReading, *settings.AppSettings)
Declare ResetTempReading(*reading.TempReading)
Declare.i HasUsableTelemetry(*reading.TempReading)
Declare.i HasVisibleTelemetry(*reading.TempReading)
Declare.i CaptureTelemetrySnapshot(*reading.TempReading, *windows.TempReading, *fallback.TempReading)
Declare.s FindBundledWindowsPerfHelper()
Declare.s FindBundledAmdAdlxHelper()
Declare.i ReadWindowsPerfStreamTelemetry(*reading.TempReading)
Declare ProbeAmdAdlx(announce.i = #False)
Declare MaintainAmdAdlxAutoProbe(*reading.TempReading, force.i = #False)
Declare ReadAmdAdlxMetrics(force.i = #False)
Declare ApplyAmdAdlxControl(*reading.TempReading, targetW.i, *settings.AppSettings)
Declare RestoreAmdAdlxSettings(announce.i = #True)
Declare.i ShouldUseWindowsPerfHelper()
Declare.s ResolveIdleRememberedPluggedPlan(*settings.AppSettings)
Declare StopWindowsPerfHelper()
Declare ResetTelemetrySmoothing()
Declare ApplyTelemetryAveraging(*reading.TempReading, averageWindowMs.i, recordSample.i = #True)
Procedure.s AppDataRoot()
  Protected path$ = GetEnvironmentVariable("APPDATA")
  If path$ = ""
    path$ = GetTemporaryDirectory()
  EndIf
  ProcedureReturn path$
EndProcedure

Procedure.s SettingsDirectory()
  ProcedureReturn AppDataRoot() + "\" + #SettingsFolderName$
EndProcedure

Procedure.s SettingsPath()
  ProcedureReturn SettingsDirectory() + "\" + #SettingsFileName$
EndProcedure

Procedure.s CleanPlanText(text$)
  text$ = ReplaceString(text$, #CR$, " ")
  text$ = ReplaceString(text$, #LF$, " ")
  text$ = ReplaceString(text$, #TAB$, " ")
  ProcedureReturn Trim(text$)
EndProcedure

Procedure ResetTelemetrySmoothing()
  FillMemory(@gTempSampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gTempSampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gTempSampleIndex = 0
  gTempLastSource$ = ""
  gTempLastSensor$ = ""

  FillMemory(@gCpuPowerSampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gCpuPowerSampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gCpuPowerSampleIndex = 0
  gCpuPowerLastSensor$ = ""

  FillMemory(@gGpuMemorySampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gGpuMemorySampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gGpuMemorySampleIndex = 0
  gGpuMemoryLastSensor$ = ""
EndProcedure

Procedure ApplyTelemetryAveraging(*reading.TempReading, averageWindowMs.i, recordSample.i = #True)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected averageTotal.d
  Protected averageCount.i
  Protected averageIndex.i

  If averageWindowMs < 1000
    averageWindowMs = 1000
  ElseIf averageWindowMs > 60000
    averageWindowMs = 60000
  EndIf

  If recordSample And *reading\valid
    gTempSampleTick(gTempSampleIndex) = nowTick
    gTempSampleValue(gTempSampleIndex) = *reading\celsius
    gTempLastSensor$ = *reading\sensor
    gTempSampleIndex = (gTempSampleIndex + 1) % #TelemetryHistorySize
  EndIf
  If recordSample And *reading\valid
    gTempLastSource$ = *reading\source
  EndIf

  If recordSample And *reading\cpuPackageValid
    gCpuPowerSampleTick(gCpuPowerSampleIndex) = nowTick
    gCpuPowerSampleValue(gCpuPowerSampleIndex) = *reading\cpuPackageWatts
    gCpuPowerLastSensor$ = *reading\cpuPackageSensor
    gCpuPowerSampleIndex = (gCpuPowerSampleIndex + 1) % #TelemetryHistorySize
  EndIf

  If recordSample And *reading\gpuMemoryValid And IsStartupGpuHelperSnapshotSensor(*reading\gpuMemorySensor) = #False
    gGpuMemorySampleTick(gGpuMemorySampleIndex) = nowTick
    gGpuMemorySampleValue(gGpuMemorySampleIndex) = *reading\gpuMemoryMb
    gGpuMemoryLastSensor$ = *reading\gpuMemorySensor
    gGpuMemorySampleIndex = (gGpuMemorySampleIndex + 1) % #TelemetryHistorySize
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gTempSampleTick(averageIndex) > 0 And nowTick - gTempSampleTick(averageIndex) <= averageWindowMs
      averageTotal + gTempSampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\valid = #True
    *reading\celsius = averageTotal / averageCount
    *reading\sensor = gTempLastSensor$
  Else
    *reading\valid = #False
    *reading\celsius = 0.0
    *reading\sensor = "No sensor data"
  EndIf
  If *reading\valid
    *reading\source = gTempLastSource$
  Else
    *reading\source = "Unavailable"
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gCpuPowerSampleTick(averageIndex) > 0 And nowTick - gCpuPowerSampleTick(averageIndex) <= averageWindowMs
      averageTotal + gCpuPowerSampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\cpuPackageValid = #True
    *reading\cpuPackageWatts = averageTotal / averageCount
    *reading\cpuPackageSensor = gCpuPowerLastSensor$
  Else
    *reading\cpuPackageValid = #False
    *reading\cpuPackageWatts = 0.0
    *reading\cpuPackageSensor = ""
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gGpuMemorySampleTick(averageIndex) > 0 And nowTick - gGpuMemorySampleTick(averageIndex) <= averageWindowMs
      averageTotal + gGpuMemorySampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\gpuMemoryValid = #True
    *reading\gpuMemoryMb = averageTotal / averageCount
    *reading\gpuMemorySensor = gGpuMemoryLastSensor$
  Else
    *reading\gpuMemoryValid = #False
    *reading\gpuMemoryMb = 0.0
    *reading\gpuMemorySensor = ""
  EndIf
EndProcedure

Procedure AddPlanDefinition(planName$, builtIn.i, defaultInstalled.i, description$, acEpp.i, acBoost.i, acState.i, acFreq.i, acCooling.i, dcEpp.i, dcBoost.i, dcState.i, dcFreq.i, dcCooling.i)
  AddElement(gPlanDefs())
  gPlanDefs()\Name = CleanPlanText(planName$)
  gPlanDefs()\BuiltIn = builtIn
  gPlanDefs()\DefaultInstalled = defaultInstalled
  gPlanDefs()\Description = CleanPlanText(description$)
  gPlanDefs()\AcEpp = acEpp
  gPlanDefs()\AcBoostMode = acBoost
  gPlanDefs()\AcMaxState = acState
  gPlanDefs()\AcFreqMHz = acFreq
  gPlanDefs()\AcCooling = acCooling
  gPlanDefs()\DcEpp = dcEpp
  gPlanDefs()\DcBoostMode = dcBoost
  gPlanDefs()\DcMaxState = dcState
  gPlanDefs()\DcFreqMHz = dcFreq
  gPlanDefs()\DcCooling = dcCooling
EndProcedure

Procedure ResetBuiltInPlanDefinitions()
  ClearList(gPlanDefs())
  AddPlanDefinition(#PlanFull$, #True, #True, "Maximum profile: full plugged-in performance behavior.", 5, 2, 100, 0, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanPlugged$, #True, #True, "Balanced profile: old 24W behavior, calmer plugged-in response.", 60, 0, 70, 2800, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanQuiet$, #True, #True, "Quiet profile: old 15W behavior, reduced boost and fan pressure.", 90, 0, 35, 1600, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanBattery$, #True, #True, "Battery profile: lowest drain on battery. Boost is off and CPU demand is capped.", 65, 0, 90, 2800, 0, 95, 0, 65, 1800, 0)
EndProcedure

Procedure.i FindPlanDefinition(planName$)
  ForEach gPlanDefs()
    If gPlanDefs()\Name = planName$
      ProcedureReturn #True
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

Procedure InitializePlanDefinitions()
  ResetBuiltInPlanDefinitions()
EndProcedure

Procedure.s InstalledIconPath()
  ProcedureReturn GetPathPart(ProgramFilename()) + "powerpilot.ico"
EndProcedure

Procedure.s InstalledTrayIconPath()
  ProcedureReturn GetPathPart(ProgramFilename()) + "powerpilot_tray.ico"
EndProcedure

Procedure.s SystemIconLibraryPath()
  Protected path$ = GetEnvironmentVariable("WINDIR")
  If path$ = ""
    path$ = "C:\Windows"
  EndIf
  ProcedureReturn path$ + "\System32\imageres.dll"
EndProcedure

Procedure.i InitializePdh()
  If gPdhLibrary = 0
    gPdhLibrary = OpenLibrary(#PB_Any, "pdh.dll")
    If gPdhLibrary
      PdhOpenQueryW = GetFunction(gPdhLibrary, "PdhOpenQueryW")
      PdhAddEnglishCounterW = GetFunction(gPdhLibrary, "PdhAddEnglishCounterW")
      PdhCollectQueryData = GetFunction(gPdhLibrary, "PdhCollectQueryData")
      PdhGetFormattedCounterValue = GetFunction(gPdhLibrary, "PdhGetFormattedCounterValue")
      PdhExpandWildCardPathW = GetFunction(gPdhLibrary, "PdhExpandWildCardPathW")
      PdhCloseQuery = GetFunction(gPdhLibrary, "PdhCloseQuery")
    EndIf
  EndIf

  If gPdhLibrary = 0 Or PdhOpenQueryW = 0 Or PdhAddEnglishCounterW = 0 Or PdhCollectQueryData = 0 Or PdhGetFormattedCounterValue = 0 Or PdhExpandWildCardPathW = 0 Or PdhCloseQuery = 0
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.s YesNoText(value.i)
  If value
    ProcedureReturn "Yes"
  EndIf
  ProcedureReturn "No"
EndProcedure

Procedure SetEditorText(gadget.i, text$)
  Protected normalized$ = ReplaceString(text$, #CR$, "")
  Protected lineCount.i
  Protected i.i

  ClearGadgetItems(gadget)
  lineCount = CountString(normalized$, #LF$) + 1
  For i = 1 To lineCount
    AddGadgetItem(gadget, -1, StringField(normalized$, i, #LF$))
  Next
EndProcedure

Procedure EnsureUiFonts()
  If IsFont(gFontBold) = 0
    gFontBold = LoadFont(#PB_Any, "Segoe UI", 11, #PB_Font_Bold)
  EndIf
  If IsFont(gFontBoldSmall) = 0
    gFontBoldSmall = LoadFont(#PB_Any, "Segoe UI", 9, #PB_Font_Bold)
  EndIf
EndProcedure

Procedure.i HandleBelongsToGadget(handle.i, gadget.i)
  Protected gadgetHandle.i = GadgetID(gadget)

  While handle
    If handle = gadgetHandle
      ProcedureReturn #True
    EndIf
    handle = GetParent_(handle)
  Wend

  ProcedureReturn #False
EndProcedure

Procedure.i TelemetryEditorInteractionActive()
  ProcedureReturn #False
EndProcedure

Procedure.s UpdateEditorTextIfNeeded(gadget.i, text$, cachedText$)
  Protected handle.i
  Protected firstVisibleLine.i

  If cachedText$ <> text$ And GetActiveGadget() <> gadget And TelemetryEditorInteractionActive() = #False
    handle = GadgetID(gadget)
    firstVisibleLine = SendMessage_(handle, #EM_GETFIRSTVISIBLELINE, 0, 0)
    SendMessage_(handle, #WM_SETREDRAW, 0, 0)
    SetEditorText(gadget, text$)
    If firstVisibleLine > 0
      SendMessage_(handle, #EM_LINESCROLL, 0, firstVisibleLine)
    EndIf
    SendMessage_(handle, #WM_SETREDRAW, 1, 0)
    InvalidateRect_(handle, 0, #True)
    UpdateWindow_(handle)
    ProcedureReturn text$
  EndIf

  ProcedureReturn cachedText$
EndProcedure

Procedure.i UpdateTextGadgetIfNeeded(gadget.i, text$)
  If IsGadget(gadget) = 0
    ProcedureReturn #False
  EndIf

  If GetGadgetText(gadget) <> text$
    SetGadgetText(gadget, text$)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i UpdateGadgetStateIfNeeded(gadget.i, state.i)
  If IsGadget(gadget) = 0
    ProcedureReturn #False
  EndIf

  If GetGadgetState(gadget) <> state
    SetGadgetState(gadget, state)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i UpdateGadgetDisabledIfNeeded(gadget.i, disabled.i)
  Protected handle.i
  Protected currentlyDisabled.i

  If IsGadget(gadget) = 0
    ProcedureReturn #False
  EndIf

  handle = GadgetID(gadget)
  currentlyDisabled = Bool(IsWindowEnabled_(handle) = 0)
  If currentlyDisabled <> Bool(disabled)
    DisableGadget(gadget, disabled)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure CopyTempReading(*target.TempReading, *source.TempReading)
  *target\valid = *source\valid
  *target\source = *source\source
  *target\sensor = *source\sensor
  *target\celsius = *source\celsius
  *target\windowsTempValid = *source\windowsTempValid
  *target\windowsTempSensor = *source\windowsTempSensor
  *target\windowsTempCelsius = *source\windowsTempCelsius
  *target\cpuPackageValid = *source\cpuPackageValid
  *target\cpuPackageSensor = *source\cpuPackageSensor
  *target\cpuPackageWatts = *source\cpuPackageWatts
  *target\gpuMemoryValid = *source\gpuMemoryValid
  *target\gpuMemorySensor = *source\gpuMemorySensor
  *target\gpuMemoryMb = *source\gpuMemoryMb
  *target\gpuSharedMemoryValid = *source\gpuSharedMemoryValid
  *target\gpuSharedMemorySensor = *source\gpuSharedMemorySensor
  *target\gpuSharedMemoryMb = *source\gpuSharedMemoryMb
  *target\gpuDeviceNames = *source\gpuDeviceNames
EndProcedure

Procedure.i HasMeaningfulPowerWatts(watts.d)
  ProcedureReturn Bool(watts > #MinimumMeaningfulPowerW)
EndProcedure

Procedure.i IsStartupGpuHelperSnapshotSensor(sensorText$)
  ProcedureReturn Bool(FindString(LCase(sensorText$), "startup snapshot", 1) > 0)
EndProcedure

Procedure ResetTempReading(*reading.TempReading)
  *reading\valid = #False
  *reading\source = "Unavailable"
  *reading\sensor = "No sensor data"
  *reading\celsius = 0.0
  *reading\windowsTempValid = #False
  *reading\windowsTempSensor = ""
  *reading\windowsTempCelsius = 0.0
  *reading\cpuPackageValid = #False
  *reading\cpuPackageSensor = ""
  *reading\cpuPackageWatts = 0.0
  *reading\gpuMemoryValid = #False
  *reading\gpuMemorySensor = ""
  *reading\gpuMemoryMb = 0.0
  *reading\gpuSharedMemoryValid = #False
  *reading\gpuSharedMemorySensor = ""
  *reading\gpuSharedMemoryMb = 0.0
  *reading\gpuDeviceNames = ""
EndProcedure

Procedure ResetTelemetryLatchState(*state.TelemetryLatchState)
  ResetTempReading(@*state\Last)
  *state\TempTick = 0
  *state\PreviousTempTick = 0
  *state\WindowsTempTick = 0
  *state\PreviousWindowsTempTick = 0
  *state\CpuPowerTick = 0
  *state\PreviousCpuPowerTick = 0
  *state\GpuMemoryTick = 0
  *state\PreviousGpuMemoryTick = 0
EndProcedure

Procedure.i TelemetryLatchTimeoutMs()
  Protected timeoutMs.i
  Protected windowVisible.i = #False

  LockMutex(gStateMutex)
  timeoutMs = gSettings\PollSeconds
  UnlockMutex(gStateMutex)

  If timeoutMs < 1
    timeoutMs = 1
  ElseIf timeoutMs > 60
    timeoutMs = 60
  EndIf
  timeoutMs * 1000

  If IsWindow(#WindowMain)
    windowVisible = IsWindowVisible_(WindowID(#WindowMain))
  EndIf
  If windowVisible
    timeoutMs = 1000
  EndIf

  timeoutMs * #TelemetryLatchGracePolls
  If timeoutMs < #TelemetryLatchMinimumMs
    timeoutMs = #TelemetryLatchMinimumMs
  EndIf
  If timeoutMs > #TelemetryLatchMaximumMs
    timeoutMs = #TelemetryLatchMaximumMs
  EndIf

  ProcedureReturn timeoutMs
EndProcedure

Procedure.i TelemetryLatchFresh(lastTick.q, nowTick.q, timeoutMs.i)
  If lastTick <= 0 Or nowTick < lastTick
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(nowTick - lastTick <= timeoutMs)
EndProcedure

Procedure.i TelemetryFieldTimeoutMs(lastTick.q, previousTick.q, baseTimeoutMs.i)
  Protected timeoutMs.i = baseTimeoutMs
  Protected intervalMs.q

  If previousTick > 0 And lastTick > previousTick
    intervalMs = lastTick - previousTick
    If intervalMs < 1000
      intervalMs = 1000
    EndIf
    If intervalMs * 4 > timeoutMs
      timeoutMs = intervalMs * 4
    EndIf
  EndIf

  If timeoutMs < #TelemetryLatchMinimumMs
    timeoutMs = #TelemetryLatchMinimumMs
  EndIf
  If timeoutMs > #TelemetryLatchMaximumMs
    timeoutMs = #TelemetryLatchMaximumMs
  EndIf

  ProcedureReturn timeoutMs
EndProcedure

Procedure ApplyTelemetryLatch(*reading.TempReading, *state.TelemetryLatchState)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected baseTimeoutMs.i = TelemetryLatchTimeoutMs()

  LockMutex(gStateMutex)

  If *reading\valid
    *state\Last\valid = #True
    *state\Last\source = *reading\source
    *state\Last\sensor = *reading\sensor
    *state\Last\celsius = *reading\celsius
    *state\PreviousTempTick = *state\TempTick
    *state\TempTick = nowTick
  ElseIf *state\Last\valid And TelemetryLatchFresh(*state\TempTick, nowTick, TelemetryFieldTimeoutMs(*state\TempTick, *state\PreviousTempTick, baseTimeoutMs))
    *reading\valid = #True
    *reading\source = *state\Last\source
    *reading\sensor = *state\Last\sensor
    *reading\celsius = *state\Last\celsius
  EndIf

  If *reading\windowsTempValid
    *state\Last\windowsTempValid = #True
    *state\Last\windowsTempSensor = *reading\windowsTempSensor
    *state\Last\windowsTempCelsius = *reading\windowsTempCelsius
    *state\PreviousWindowsTempTick = *state\WindowsTempTick
    *state\WindowsTempTick = nowTick
  ElseIf *state\Last\windowsTempValid And TelemetryLatchFresh(*state\WindowsTempTick, nowTick, TelemetryFieldTimeoutMs(*state\WindowsTempTick, *state\PreviousWindowsTempTick, baseTimeoutMs))
    *reading\windowsTempValid = #True
    *reading\windowsTempSensor = *state\Last\windowsTempSensor
    *reading\windowsTempCelsius = *state\Last\windowsTempCelsius
  EndIf

  If *reading\cpuPackageValid
    *state\Last\cpuPackageValid = #True
    *state\Last\cpuPackageSensor = *reading\cpuPackageSensor
    *state\Last\cpuPackageWatts = *reading\cpuPackageWatts
    *state\PreviousCpuPowerTick = *state\CpuPowerTick
    *state\CpuPowerTick = nowTick
  ElseIf *state\Last\cpuPackageValid And TelemetryLatchFresh(*state\CpuPowerTick, nowTick, TelemetryFieldTimeoutMs(*state\CpuPowerTick, *state\PreviousCpuPowerTick, baseTimeoutMs))
    *reading\cpuPackageValid = #True
    *reading\cpuPackageSensor = *state\Last\cpuPackageSensor
    *reading\cpuPackageWatts = *state\Last\cpuPackageWatts
  EndIf

  If *reading\gpuMemoryValid
    *state\Last\gpuMemoryValid = #True
    *state\Last\gpuMemorySensor = *reading\gpuMemorySensor
    *state\Last\gpuMemoryMb = *reading\gpuMemoryMb
    *state\Last\gpuSharedMemoryValid = *reading\gpuSharedMemoryValid
    *state\Last\gpuSharedMemorySensor = *reading\gpuSharedMemorySensor
    *state\Last\gpuSharedMemoryMb = *reading\gpuSharedMemoryMb
    *state\PreviousGpuMemoryTick = *state\GpuMemoryTick
    *state\GpuMemoryTick = nowTick
  ElseIf *state\Last\gpuMemoryValid And TelemetryLatchFresh(*state\GpuMemoryTick, nowTick, TelemetryFieldTimeoutMs(*state\GpuMemoryTick, *state\PreviousGpuMemoryTick, baseTimeoutMs))
    *reading\gpuMemoryValid = #True
    *reading\gpuMemorySensor = *state\Last\gpuMemorySensor
    *reading\gpuMemoryMb = *state\Last\gpuMemoryMb
    *reading\gpuSharedMemoryValid = *state\Last\gpuSharedMemoryValid
    *reading\gpuSharedMemorySensor = *state\Last\gpuSharedMemorySensor
    *reading\gpuSharedMemoryMb = *state\Last\gpuSharedMemoryMb
  EndIf

  If *reading\gpuDeviceNames <> ""
    *state\Last\gpuDeviceNames = *reading\gpuDeviceNames
  ElseIf *state\Last\gpuDeviceNames <> ""
    *reading\gpuDeviceNames = *state\Last\gpuDeviceNames
  EndIf

  UnlockMutex(gStateMutex)
EndProcedure

Procedure PushUiLogLine(line$)
  Protected i.i

  For i = 0 To #UiLogLineCount - 2
    gUiLogLines(i) = gUiLogLines(i + 1)
  Next
  gUiLogLines(#UiLogLineCount - 1) = line$
EndProcedure

Procedure.s BuildUiLogText()
  Protected text$
  Protected i.i

  For i = 0 To #UiLogLineCount - 1
    If gUiLogLines(i) <> ""
      If text$ <> ""
        text$ + #LF$
      EndIf
      text$ + gUiLogLines(i)
    EndIf
  Next

  If text$ = ""
    text$ = "Ready."
  EndIf

  ProcedureReturn text$
EndProcedure

Procedure CacheDependencyStatus(*status.DependencyStatus)

  LockMutex(gStateMutex)
  gCachedDependency\WindowsEnabled = *status\WindowsEnabled
  gCachedDependency\WindowsTelemetryReady = *status\WindowsTelemetryReady
  gCachedDependency\WindowsTempReady = *status\WindowsTempReady
  gCachedDependency\WindowsPowerReady = *status\WindowsPowerReady
  gCachedDependency\WindowsGpuReady = *status\WindowsGpuReady
  gCachedDependency\FallbackAvailable = *status\FallbackAvailable
  gCachedDependency\ManagedPlansReady = *status\ManagedPlansReady
  gCachedDependency\SensorReady = *status\SensorReady
  gCachedDependency\SensorSource = *status\SensorSource
  gCachedDependency\SensorName = *status\SensorName
  UnlockMutex(gStateMutex)
EndProcedure

Procedure CopyCachedDependencyStatus(*status.DependencyStatus)
  LockMutex(gStateMutex)
  *status\WindowsEnabled = gCachedDependency\WindowsEnabled
  *status\WindowsTelemetryReady = gCachedDependency\WindowsTelemetryReady
  *status\WindowsTempReady = gCachedDependency\WindowsTempReady
  *status\WindowsPowerReady = gCachedDependency\WindowsPowerReady
  *status\WindowsGpuReady = gCachedDependency\WindowsGpuReady
  *status\FallbackAvailable = gCachedDependency\FallbackAvailable
  *status\ManagedPlansReady = gCachedDependency\ManagedPlansReady
  *status\SensorReady = gCachedDependency\SensorReady
  *status\SensorSource = gCachedDependency\SensorSource
  *status\SensorName = gCachedDependency\SensorName
  UnlockMutex(gStateMutex)
EndProcedure

Procedure BuildDependencyStatusFromSnapshots(*status.DependencyStatus, *reading.TempReading, *windows.TempReading, *fallback.TempReading, *settings.AppSettings)
  *status\WindowsEnabled = *settings\UseWindows
  *status\WindowsTelemetryReady = HasUsableTelemetry(*windows)
  *status\WindowsTempReady = *windows\windowsTempValid
  *status\WindowsPowerReady = *windows\cpuPackageValid
  *status\WindowsGpuReady = Bool(*windows\gpuMemoryValid Or *windows\gpuSharedMemoryValid Or *windows\gpuDeviceNames <> "")
  *status\FallbackAvailable = Bool(*status\WindowsTempReady = #False And *fallback\valid)
  *status\ManagedPlansReady = CachedManagedPlansPresent()
  *status\SensorReady = #False
  *status\SensorSource = "Unavailable"
  *status\SensorName = "No sensor data"

  If *windows\valid Or *windows\cpuPackageValid Or *windows\gpuMemoryValid Or *windows\gpuSharedMemoryValid Or *windows\gpuDeviceNames <> ""
    *status\SensorReady = #True
    If *windows\valid
      *status\SensorSource = *windows\source
      *status\SensorName = *windows\sensor
    ElseIf *windows\cpuPackageValid
      *status\SensorSource = "Power telemetry"
      *status\SensorName = *windows\cpuPackageSensor
    ElseIf *windows\gpuMemoryValid
      *status\SensorSource = "VRAM telemetry"
      *status\SensorName = *windows\gpuMemorySensor
    ElseIf *windows\gpuSharedMemoryValid
      *status\SensorSource = "VRAM telemetry"
      *status\SensorName = *windows\gpuSharedMemorySensor
    ElseIf *windows\gpuDeviceNames <> ""
      *status\SensorSource = "GPU device telemetry"
      *status\SensorName = StringField(*windows\gpuDeviceNames, 1, #LF$)
    EndIf
  ElseIf *reading\valid Or *reading\cpuPackageValid Or *reading\gpuMemoryValid Or *reading\gpuSharedMemoryValid Or *reading\gpuDeviceNames <> ""
    *status\SensorReady = #True
    If *reading\valid
      *status\SensorSource = *reading\source
      *status\SensorName = *reading\sensor
    ElseIf *reading\cpuPackageValid
      *status\SensorSource = "Power telemetry"
      *status\SensorName = *reading\cpuPackageSensor
    ElseIf *reading\gpuMemoryValid
      *status\SensorSource = "VRAM telemetry"
      *status\SensorName = *reading\gpuMemorySensor
    ElseIf *reading\gpuSharedMemoryValid
      *status\SensorSource = "VRAM telemetry"
      *status\SensorName = *reading\gpuSharedMemorySensor
    ElseIf *reading\gpuDeviceNames <> ""
      *status\SensorSource = "GPU device telemetry"
      *status\SensorName = StringField(*reading\gpuDeviceNames, 1, #LF$)
    EndIf
  ElseIf *status\FallbackAvailable
    *status\SensorReady = #True
    *status\SensorSource = *fallback\source
    *status\SensorName = *fallback\sensor
  EndIf
EndProcedure

Procedure EnsureSettingsDirectory()
  If FileSize(SettingsDirectory()) <> -2
    CreateDirectory(SettingsDirectory())
  EndIf
EndProcedure

Procedure AppendRuntimeLog(text$)
  Protected file.i
  Protected path$ = SettingsDirectory() + "\runtime.log"

  EnsureSettingsDirectory()
  file = OpenFile(#PB_Any, path$)
  If file = 0
    file = CreateFile(#PB_Any, path$)
  Else
    FileSeek(file, Lof(file))
  EndIf

  If file
    WriteStringN(file, FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", Date()) + "  " + text$)
    CloseFile(file)
  EndIf
EndProcedure

Procedure.i ClampInt(value.i, minValue.i, maxValue.i)
  If value < minValue : ProcedureReturn minValue : EndIf
  If value > maxValue : ProcedureReturn maxValue : EndIf
  ProcedureReturn value
EndProcedure

Procedure.d ClampDouble(value.d, minValue.d, maxValue.d)
  If value < minValue : ProcedureReturn minValue : EndIf
  If value > maxValue : ProcedureReturn maxValue : EndIf
  ProcedureReturn value
EndProcedure

Procedure.i PlanDefinitionInstalled(planName$)
  If planName$ = #PlanVisible$
    ProcedureReturn Bool(GetSchemeGuidByName(#PlanVisible$) <> "")
  EndIf

  ProcedureReturn Bool(GetSchemeGuidByName(planName$) <> "")
EndProcedure

Procedure.i IsRememberedPluggedPlanName(planName$)
  Protected builtInAllowed.i

  Select planName$
    Case #PlanPlugged$, #PlanQuiet$, #PlanFull$
      builtInAllowed = #True
  EndSelect

  If builtInAllowed
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i IsSelectableManagedPlanName(planName$)
  If planName$ = #PlanBattery$
    ProcedureReturn #True
  EndIf

  If IsRememberedPluggedPlanName(planName$)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s NormalizeRememberedPluggedPlan(planName$)
  If IsRememberedPluggedPlanName(planName$)
    ProcedureReturn planName$
  EndIf

  ProcedureReturn #PlanPlugged$
EndProcedure

Procedure.s ResolveIdleRememberedPluggedPlan(*settings.AppSettings)
  ProcedureReturn NormalizeRememberedPluggedPlan(*settings\LastPluggedPlan)
EndProcedure

Procedure.s NormalizeManagedPlan(planName$)
  If IsSelectableManagedPlanName(planName$)
    ProcedureReturn planName$
  EndIf

  ProcedureReturn #PlanPlugged$
EndProcedure

Procedure.i HasPowerTelemetry(*reading.TempReading)
  If *reading\cpuPackageValid
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i HasUsableTelemetry(*reading.TempReading)
  If *reading\valid Or *reading\cpuPackageValid Or *reading\gpuMemoryValid Or *reading\gpuSharedMemoryValid Or *reading\gpuDeviceNames <> ""
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i HasVisibleTelemetry(*reading.TempReading)
  ProcedureReturn HasUsableTelemetry(*reading)
EndProcedure

Procedure.i NeedsMoreTelemetry(*reading.TempReading)
  If *reading\valid = #False
    ProcedureReturn #True
  EndIf

  If *reading\cpuPackageValid = #False Or *reading\gpuMemoryValid = #False
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i HasControlTelemetry(*reading.TempReading, *settings.AppSettings)
  If *settings\TemperatureTargetEnabled And *reading\valid
    ProcedureReturn #True
  EndIf

  If *settings\PowerTargetEnabled And HasPowerTelemetry(*reading)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s BuildControlStateText(*reading.TempReading, *settings.AppSettings)
  If *settings\AutoBatteryPlan
    If gState\PowerSource = #PowerSourceBattery
      ProcedureReturn "On battery: keeping Battery profile active."
    EndIf
  EndIf

  If *settings\AutoEnabled
    If *settings\PowerTargetEnabled Or *settings\TemperatureTargetEnabled
      ProcedureReturn "Auto Control uses enabled targets; profiles only set Windows behavior."
    EndIf
    ProcedureReturn "Auto Control is on, but no target is enabled."
  EndIf

  ProcedureReturn "Auto Control is off."
EndProcedure

Procedure.s BuildWindowsInfoText()
  Protected text$

  text$ + "Windows telemetry is the normal data source." + #LF$ + #LF$
  text$ + "PowerPilot reads temperature and CPU package power from Windows." + #LF$
  text$ + "If Windows temperature is missing, PowerPilot can use a basic ACPI fallback temperature sensor." + #LF$ + #LF$
  text$ + "How Auto Control decides:" + #LF$
  text$ + "- Profiles set Windows behavior only: Maximum, Balanced, Quiet, and Battery." + #LF$
  text$ + "- Auto Control applies temporary CPU caps from enabled power or temperature targets." + #LF$
  text$ + "- Selecting a profile does not change target settings." + #LF$ + #LF$
  text$ + "AMD ADLX GPU-side control is optional and used only when enabled and supported." + #LF$ + #LF$
  text$ + "Battery note: set Windows Power mode to Balanced or Best performance. Best power efficiency can cap the system before PowerPilot gets the full Auto Control range."

  ProcedureReturn text$
EndProcedure

Procedure ApplyMainWindowToolTips()
  GadgetToolTip(#GadgetAutoEnabled, "Turn target-based Auto Control on or off.")
  GadgetToolTip(#GadgetUseWindows, "Use Windows temperature, CPU package power, GPU names, and VRAM readings.")
  GadgetToolTip(#GadgetAmdAdlxEnabled, "Allow optional AMD ADLX GPU-side controls when package power looks GPU-driven.")
  GadgetToolTip(#GadgetWindowsInfo, "Show where readings come from and how Auto Control uses them.")
  GadgetToolTip(#GadgetAutoStart, "Start PowerPilot with Windows and keep it hidden in the tray.")
  GadgetToolTip(#GadgetKeepSettings, "Keep your saved settings when installing a newer version.")
  GadgetToolTip(#GadgetAutoBatteryPlan, "On battery, keep the Battery profile active. Plugged in, restore the selected behavior profile.")
  GadgetToolTip(#GadgetPollSpin, "How often PowerPilot refreshes temperature and CPU-power readings.")
  GadgetToolTip(#GadgetHysteresisSpin, "Reserved temperature tolerance used by status messages.")
  GadgetToolTip(#GadgetControlDeadbandSpin, "Package-power deadband before the PI controller changes caps.")
  GadgetToolTip(#GadgetAutoControlAverage, "Seconds of readings to smooth the dashboard. Auto Control uses a short bounded response window.")
  GadgetToolTip(#GadgetPowerTargetEnabled, "Enable package-power target control.")
  GadgetToolTip(#GadgetPowerTargetWatts, "Package-power target in watts.")
  GadgetToolTip(#GadgetTempTargetEnabled, "Enable single temperature target control.")
  GadgetToolTip(#GadgetTempTargetC, "Soft temperature target in degrees C.")
  GadgetToolTip(#GadgetMinCpuCap, "Lowest temporary CPU percentage cap Auto Control may apply. Low values can starve GPU-heavy package load.")
  GadgetToolTip(#GadgetMinCpuMHz, "Lowest temporary CPU MHz cap Auto Control may apply. Low values can starve GPU-heavy package load.")
  GadgetToolTip(#GadgetMaxCpuMHz, "Reference CPU MHz used when converting cap percentage to a frequency cap.")
  GadgetToolTip(#GadgetPlanList, "Checked plans stay installed in Windows. Select a row to edit it.")
  GadgetToolTip(#GadgetPlanEditorName, "Built-in profile name.")
  GadgetToolTip(#GadgetPlanEditorSummary, "Short purpose text shown in the Installed Plans table.")
  GadgetToolTip(#GadgetPlanEditorPreset, "Load a built-in plan as a starting point for this editor.")
  GadgetToolTip(#GadgetPlanEditorLoadPreset, "Copy the selected preset into the editor. This does not save yet.")
  GadgetToolTip(#GadgetPlanAcEpp, "Plugged-in CPU efficiency preference. Lower is faster; higher is cooler.")
  GadgetToolTip(#GadgetPlanDcEpp, "Battery CPU efficiency preference. Higher usually saves more battery.")
  GadgetToolTip(#GadgetPlanAcBoost, "Plugged-in CPU boost mode. Disabled is cooler; Aggressive is fastest.")
  GadgetToolTip(#GadgetPlanDcBoost, "Battery CPU boost mode. Disabled usually saves battery and heat.")
  GadgetToolTip(#GadgetPlanAcState, "Plugged-in maximum CPU percentage.")
  GadgetToolTip(#GadgetPlanDcState, "Battery maximum CPU percentage.")
  GadgetToolTip(#GadgetPlanAcFreq, "Plugged-in CPU MHz cap. Use 0 for no MHz cap.")
  GadgetToolTip(#GadgetPlanDcFreq, "Battery CPU MHz cap. Use 0 for no MHz cap.")
  GadgetToolTip(#GadgetPlanAcCooling, "Plugged-in cooling policy. Active favors fans; Passive limits CPU first.")
  GadgetToolTip(#GadgetPlanDcCooling, "Battery cooling policy. Passive is usually quieter and cooler.")
  GadgetToolTip(#GadgetPlanEditorSave, "Save this plan. If installed, its Windows plan is updated too.")
  GadgetToolTip(#GadgetPlanEditorNew, "Custom profiles are disabled; PowerPilot uses four profiles.")
  GadgetToolTip(#GadgetPlanEditorDelete, "Built-in profiles are kept; use Remove Managed to clean Windows profiles.")
  GadgetToolTip(#GadgetPlanRefreshAll, "Create or refresh the PowerPilot plans in Windows.")
  GadgetToolTip(#GadgetPlanRemoveAll, "Remove all PowerPilot-managed plans from Windows.")
  GadgetToolTip(#GadgetAmdAdlxRestore, "Restore only AMD driver settings changed by the ADLX helper.")
  GadgetToolTip(#GadgetPlanCombo, "Pick a plan to activate manually.")
  GadgetToolTip(#GadgetActivatePlan, "Activate the selected plan now.")
  GadgetToolTip(#GadgetAutoOnce, "Make one Auto Control decision now without changing settings.")
  GadgetToolTip(#GadgetResetDisplay, "Ask Windows to reset the display path using Win+Ctrl+Shift+B.")
  GadgetToolTip(#GadgetDependencies, "Open reading-source and plan-status help.")
  GadgetToolTip(#GadgetSaveSettings, "Save the current settings.")
  GadgetToolTip(#GadgetHideToTray, "Hide this window and keep PowerPilot running.")
  GadgetToolTip(#GadgetExit, "Close PowerPilot completely.")
  GadgetToolTip(#GadgetStatusLine, "Current PowerPilot status.")
EndProcedure

Procedure ApplyDefaultSettings()
  gSettings\AutoEnabled      = #True
  gSettings\UseWindows       = #True
  gSettings\AutoStartWithApp = #True
  gSettings\KeepSettingsOnReinstall = #False
  gSettings\AutoBatteryPlan  = #True
  gSettings\AmdAdlxEnabled   = #False
  gSettings\PowerTargetEnabled = #True
  gSettings\TemperatureTargetEnabled = #False
  gSettings\PowerTargetWatts = 24
  gSettings\TemperatureTargetC = 80
  gSettings\ControlDeadband = 2
  gSettings\MinCpuCapPercent = #MinimumDynamicCpuCapPercent
  gSettings\MinCpuMHz = #MinimumDynamicCpuMHz
  gSettings\MaxCpuMHz = 4200
  gSettings\PollSeconds      = 5
  gSettings\Hysteresis       = 5
  gSettings\AutoControlAverageSeconds = #DefaultAutoControlAverageSeconds
  gSettings\LastPluggedPlan  = #PlanPlugged$
  gSettings\CurrentManagedPlan = #PlanPlugged$
EndProcedure

Procedure NormalizeSettings()
  gSettings\PollSeconds      = ClampInt(gSettings\PollSeconds, 1, 60)
  gSettings\Hysteresis       = ClampInt(gSettings\Hysteresis, 1, 20)
  gSettings\AutoControlAverageSeconds = ClampInt(gSettings\AutoControlAverageSeconds, 1, 60)
  gSettings\AmdAdlxEnabled   = Bool(gSettings\AmdAdlxEnabled)
  gSettings\PowerTargetEnabled = Bool(gSettings\PowerTargetEnabled)
  gSettings\TemperatureTargetEnabled = Bool(gSettings\TemperatureTargetEnabled)
  gSettings\PowerTargetWatts = ClampInt(gSettings\PowerTargetWatts, 5, 80)
  gSettings\TemperatureTargetC = ClampInt(gSettings\TemperatureTargetC, 45, 100)
  gSettings\ControlDeadband = ClampInt(gSettings\ControlDeadband, 1, 15)
  gSettings\MinCpuCapPercent = ClampInt(gSettings\MinCpuCapPercent, #MinimumDynamicCpuCapPercent, 100)
  gSettings\MinCpuMHz = ClampInt(gSettings\MinCpuMHz, #MinimumDynamicCpuMHz, 5000)
  gSettings\MaxCpuMHz = ClampInt(gSettings\MaxCpuMHz, gSettings\MinCpuMHz, 6000)
  gSettings\LastPluggedPlan  = NormalizeRememberedPluggedPlan(gSettings\LastPluggedPlan)
  gSettings\CurrentManagedPlan = NormalizeManagedPlan(gSettings\CurrentManagedPlan)
EndProcedure

Procedure LoadSettings()
  ApplyDefaultSettings()
  EnsureSettingsDirectory()

  If OpenPreferences(SettingsPath())
    gSettings\AutoEnabled      = ReadPreferenceInteger("AutoEnabled", gSettings\AutoEnabled)
    gSettings\UseWindows       = ReadPreferenceInteger("UseWindows", gSettings\UseWindows)
    gSettings\AutoStartWithApp = ReadPreferenceInteger("AutoStartWithApp", gSettings\AutoStartWithApp)
    gSettings\KeepSettingsOnReinstall = ReadPreferenceInteger("KeepSettingsOnReinstall", gSettings\KeepSettingsOnReinstall)
    gSettings\AutoBatteryPlan  = ReadPreferenceInteger("AutoBatteryPlan", gSettings\AutoBatteryPlan)
    gSettings\AmdAdlxEnabled   = ReadPreferenceInteger("AmdAdlxEnabled", gSettings\AmdAdlxEnabled)
    gSettings\PowerTargetEnabled = ReadPreferenceInteger("PowerTargetEnabled", gSettings\PowerTargetEnabled)
    gSettings\TemperatureTargetEnabled = ReadPreferenceInteger("TemperatureTargetEnabled", gSettings\TemperatureTargetEnabled)
    gSettings\PowerTargetWatts = ReadPreferenceInteger("PowerTargetWatts", gSettings\PowerTargetWatts)
    gSettings\TemperatureTargetC = ReadPreferenceInteger("TemperatureTargetC", gSettings\TemperatureTargetC)
    gSettings\ControlDeadband = ReadPreferenceInteger("ControlDeadband", gSettings\ControlDeadband)
    gSettings\MinCpuCapPercent = ReadPreferenceInteger("MinCpuCapPercent", gSettings\MinCpuCapPercent)
    gSettings\MinCpuMHz = ReadPreferenceInteger("MinCpuMHz", gSettings\MinCpuMHz)
    gSettings\MaxCpuMHz = ReadPreferenceInteger("MaxCpuMHz", gSettings\MaxCpuMHz)
    gSettings\PollSeconds      = ReadPreferenceInteger("PollSeconds", gSettings\PollSeconds)
    gSettings\Hysteresis       = ReadPreferenceInteger("Hysteresis", gSettings\Hysteresis)
    gSettings\AutoControlAverageSeconds = ReadPreferenceInteger("AutoControlAverageSeconds", gSettings\AutoControlAverageSeconds)
    gSettings\LastPluggedPlan  = ReadPreferenceString("LastPluggedPlan", gSettings\LastPluggedPlan)
    gSettings\CurrentManagedPlan = ReadPreferenceString("CurrentManagedPlan", gSettings\CurrentManagedPlan)
    ClosePreferences()
  EndIf

  NormalizeSettings()
EndProcedure

Procedure SaveSettings()
  NormalizeSettings()
  EnsureSettingsDirectory()

  If CreatePreferences(SettingsPath())
    WritePreferenceInteger("AutoEnabled", gSettings\AutoEnabled)
    WritePreferenceInteger("UseWindows", gSettings\UseWindows)
    WritePreferenceInteger("AutoStartWithApp", gSettings\AutoStartWithApp)
    WritePreferenceInteger("KeepSettingsOnReinstall", gSettings\KeepSettingsOnReinstall)
    WritePreferenceInteger("AutoBatteryPlan", gSettings\AutoBatteryPlan)
    WritePreferenceInteger("AmdAdlxEnabled", gSettings\AmdAdlxEnabled)
    WritePreferenceInteger("PowerTargetEnabled", gSettings\PowerTargetEnabled)
    WritePreferenceInteger("TemperatureTargetEnabled", gSettings\TemperatureTargetEnabled)
    WritePreferenceInteger("PowerTargetWatts", gSettings\PowerTargetWatts)
    WritePreferenceInteger("TemperatureTargetC", gSettings\TemperatureTargetC)
    WritePreferenceInteger("ControlDeadband", gSettings\ControlDeadband)
    WritePreferenceInteger("MinCpuCapPercent", gSettings\MinCpuCapPercent)
    WritePreferenceInteger("MinCpuMHz", gSettings\MinCpuMHz)
    WritePreferenceInteger("MaxCpuMHz", gSettings\MaxCpuMHz)
    WritePreferenceInteger("PollSeconds", gSettings\PollSeconds)
    WritePreferenceInteger("Hysteresis", gSettings\Hysteresis)
    WritePreferenceInteger("AutoControlAverageSeconds", gSettings\AutoControlAverageSeconds)
    WritePreferenceString("LastPluggedPlan", gSettings\LastPluggedPlan)
    WritePreferenceString("CurrentManagedPlan", gSettings\CurrentManagedPlan)
    ClosePreferences()
  EndIf
EndProcedure

Procedure PullSettingsFromGui()
  If IsGadget(#GadgetAutoEnabled) : gSettings\AutoEnabled = GetGadgetState(#GadgetAutoEnabled) : EndIf
  If IsGadget(#GadgetUseWindows) : gSettings\UseWindows = GetGadgetState(#GadgetUseWindows) : EndIf
  If IsGadget(#GadgetAutoStart) : gSettings\AutoStartWithApp = GetGadgetState(#GadgetAutoStart) : EndIf
  If IsGadget(#GadgetKeepSettings) : gSettings\KeepSettingsOnReinstall = GetGadgetState(#GadgetKeepSettings) : EndIf
  If IsGadget(#GadgetAutoBatteryPlan) : gSettings\AutoBatteryPlan = GetGadgetState(#GadgetAutoBatteryPlan) : EndIf
  If IsGadget(#GadgetAmdAdlxEnabled) : gSettings\AmdAdlxEnabled = GetGadgetState(#GadgetAmdAdlxEnabled) : EndIf
  If IsGadget(#GadgetPowerTargetEnabled) : gSettings\PowerTargetEnabled = GetGadgetState(#GadgetPowerTargetEnabled) : EndIf
  If IsGadget(#GadgetTempTargetEnabled) : gSettings\TemperatureTargetEnabled = GetGadgetState(#GadgetTempTargetEnabled) : EndIf
  If IsGadget(#GadgetPowerTargetWatts) : gSettings\PowerTargetWatts = GetGadgetState(#GadgetPowerTargetWatts) : EndIf
  If IsGadget(#GadgetTempTargetC) : gSettings\TemperatureTargetC = GetGadgetState(#GadgetTempTargetC) : EndIf
  If IsGadget(#GadgetControlDeadbandSpin) : gSettings\ControlDeadband = GetGadgetState(#GadgetControlDeadbandSpin) : EndIf
  If IsGadget(#GadgetMinCpuCap) : gSettings\MinCpuCapPercent = GetGadgetState(#GadgetMinCpuCap) : EndIf
  If IsGadget(#GadgetMinCpuMHz) : gSettings\MinCpuMHz = GetGadgetState(#GadgetMinCpuMHz) : EndIf
  If IsGadget(#GadgetMaxCpuMHz) : gSettings\MaxCpuMHz = GetGadgetState(#GadgetMaxCpuMHz) : EndIf
  If IsGadget(#GadgetPollSpin) : gSettings\PollSeconds = GetGadgetState(#GadgetPollSpin) : EndIf
  If IsGadget(#GadgetHysteresisSpin) : gSettings\Hysteresis = GetGadgetState(#GadgetHysteresisSpin) : EndIf
  If IsGadget(#GadgetAutoControlAverage) : gSettings\AutoControlAverageSeconds = GetGadgetState(#GadgetAutoControlAverage) : EndIf
  NormalizeSettings()
EndProcedure

Procedure UpdateTelemetryControlState()
EndProcedure

Procedure PushSettingsToGui()
  UpdateGadgetStateIfNeeded(#GadgetAutoEnabled, gSettings\AutoEnabled)
  UpdateGadgetStateIfNeeded(#GadgetUseWindows, gSettings\UseWindows)
  UpdateGadgetStateIfNeeded(#GadgetAutoStart, gSettings\AutoStartWithApp)
  UpdateGadgetStateIfNeeded(#GadgetKeepSettings, gSettings\KeepSettingsOnReinstall)
  UpdateGadgetStateIfNeeded(#GadgetAutoBatteryPlan, gSettings\AutoBatteryPlan)
  UpdateGadgetStateIfNeeded(#GadgetAmdAdlxEnabled, gSettings\AmdAdlxEnabled)
  UpdateGadgetStateIfNeeded(#GadgetPowerTargetEnabled, gSettings\PowerTargetEnabled)
  UpdateGadgetStateIfNeeded(#GadgetTempTargetEnabled, gSettings\TemperatureTargetEnabled)
  UpdateGadgetStateIfNeeded(#GadgetPowerTargetWatts, gSettings\PowerTargetWatts)
  UpdateGadgetStateIfNeeded(#GadgetTempTargetC, gSettings\TemperatureTargetC)
  UpdateGadgetStateIfNeeded(#GadgetControlDeadbandSpin, gSettings\ControlDeadband)
  UpdateGadgetStateIfNeeded(#GadgetMinCpuCap, gSettings\MinCpuCapPercent)
  UpdateGadgetStateIfNeeded(#GadgetMinCpuMHz, gSettings\MinCpuMHz)
  UpdateGadgetStateIfNeeded(#GadgetMaxCpuMHz, gSettings\MaxCpuMHz)
  UpdateGadgetStateIfNeeded(#GadgetPollSpin, gSettings\PollSeconds)
  UpdateGadgetStateIfNeeded(#GadgetHysteresisSpin, gSettings\Hysteresis)
  UpdateGadgetStateIfNeeded(#GadgetAutoControlAverage, gSettings\AutoControlAverageSeconds)
  UpdateTelemetryControlState()
EndProcedure

Procedure LogAction(text$)
  Protected line$ = FormatDate("%hh:%ii:%ss", Date()) + "  " + text$

  LockMutex(gStateMutex)
  gState\LastAction = line$
  PushUiLogLine(line$)
  UnlockMutex(gStateMutex)

  AppendRuntimeLog("LOG " + text$)
EndProcedure

Procedure.s QuoteArgument(value$)
  ProcedureReturn Chr(34) + value$ + Chr(34)
EndProcedure

Procedure.s FirstLine(text$)
  ProcedureReturn Trim(StringField(ReplaceString(text$, #CR$, ""), 1, #LF$))
EndProcedure

Procedure.s RunCapture(program$, arguments$, workingDir$ = "")
  Protected handle.i
  Protected output$
  Protected line$

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle = 0
    ProcedureReturn ""
  EndIf

  While ProgramRunning(handle)
    While AvailableProgramOutput(handle)
      line$ = ReadProgramString(handle)
      output$ + line$ + #LF$
    Wend
    Delay(5)
  Wend

  While AvailableProgramOutput(handle)
    line$ = ReadProgramString(handle)
    output$ + line$ + #LF$
  Wend

  CloseProgram(handle)
  ProcedureReturn output$
EndProcedure

Procedure.i RunExitCode(program$, arguments$, workingDir$ = "")
  Protected handle.i
  Protected exitCode.i
  Protected line$

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle = 0
    ProcedureReturn -1
  EndIf

  While ProgramRunning(handle)
    While AvailableProgramOutput(handle)
      line$ = ReadProgramString(handle)
    Wend
    Delay(5)
  Wend

  While AvailableProgramOutput(handle)
    line$ = ReadProgramString(handle)
  Wend

  exitCode = ProgramExitCode(handle)
  CloseProgram(handle)
  ProcedureReturn exitCode
EndProcedure

Procedure.i RunPowerCfg(arguments$)
  ProcedureReturn RunExitCode("powercfg", arguments$)
EndProcedure

Procedure.s RunPowerCfgCapture(arguments$)
  ProcedureReturn RunCapture("powercfg", arguments$)
EndProcedure

Procedure.s FindBundledAmdAdlxHelper()
  Protected helper$

  helper$ = GetPathPart(ProgramFilename()) + "PowerPilotAmdAdlxHelper.exe"
  If FileSize(helper$) > 0
    ProcedureReturn helper$
  EndIf

  helper$ = GetCurrentDirectory() + "build\PowerPilotAmdAdlxHelper.exe"
  If FileSize(helper$) > 0
    ProcedureReturn helper$
  EndIf

  helper$ = GetCurrentDirectory() + "PowerPilotAmdAdlxHelper.exe"
  If FileSize(helper$) > 0
    ProcedureReturn helper$
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s JsonStringValue(json$, key$)
  Protected token$ = Chr(34) + key$ + Chr(34) + ":"
  Protected pos.i = FindString(json$, token$, 1)
  Protected start.i
  Protected i.i
  Protected c$
  Protected value$
  Protected escaped.i

  If pos = 0
    ProcedureReturn ""
  EndIf

  start = pos + Len(token$)
  While start <= Len(json$) And Mid(json$, start, 1) = " "
    start + 1
  Wend
  If Mid(json$, start, 1) <> Chr(34)
    ProcedureReturn ""
  EndIf
  start + 1

  For i = start To Len(json$)
    c$ = Mid(json$, i, 1)
    If escaped
      Select c$
        Case "n" : value$ + #LF$
        Case "r" : value$ + #CR$
        Case "t" : value$ + #TAB$
        Default : value$ + c$
      EndSelect
      escaped = #False
    ElseIf c$ = "\"
      escaped = #True
    ElseIf c$ = Chr(34)
      ProcedureReturn value$
    Else
      value$ + c$
    EndIf
  Next

  ProcedureReturn value$
EndProcedure

Procedure.i JsonBoolValue(json$, key$)
  Protected token$ = Chr(34) + key$ + Chr(34) + ":"
  Protected pos.i = FindString(json$, token$, 1)
  Protected value$

  If pos = 0
    ProcedureReturn #False
  EndIf

  value$ = LCase(Trim(Mid(json$, pos + Len(token$), 5)))
  ProcedureReturn Bool(Left(value$, 4) = "true")
EndProcedure

Procedure.d JsonNumberValue(json$, key$)
  Protected token$ = Chr(34) + key$ + Chr(34) + ":"
  Protected pos.i = FindString(json$, token$, 1)
  Protected start.i
  Protected i.i
  Protected c$
  Protected value$

  If pos = 0
    ProcedureReturn 0.0
  EndIf

  start = pos + Len(token$)
  For i = start To Len(json$)
    c$ = Mid(json$, i, 1)
    If FindString("0123456789.-", c$, 1)
      value$ + c$
    ElseIf value$ <> ""
      Break
    EndIf
  Next

  ProcedureReturn ValD(value$)
EndProcedure

Procedure.s RunAmdAdlxHelper(arguments$)
  Protected helper$ = FindBundledAmdAdlxHelper()
  Protected output$

  If helper$ = ""
    AppendRuntimeLog("AMD ADLX helper missing for command: " + arguments$)
    ProcedureReturn ""
  EndIf

  AppendRuntimeLog("AMD ADLX helper call: " + arguments$)
  output$ = RunCapture(helper$, arguments$, GetPathPart(helper$))
  If Trim(output$) = ""
    AppendRuntimeLog("AMD ADLX helper returned no output for: " + arguments$)
  ElseIf JsonBoolValue(output$, "ok") = #False
    AppendRuntimeLog("AMD ADLX helper error: " + FirstLine(output$))
  EndIf

  ProcedureReturn output$
EndProcedure

Procedure.s AmdAdlxSupportedFeatureText()
  Protected text$

  If gAmdAdlx\GfxMaxSupported : text$ = MergeLineLists(text$, "GPU max frequency") : EndIf
  If gAmdAdlx\PowerLimitSupported : text$ = MergeLineLists(text$, "GPU power limit") : EndIf
  If gAmdAdlx\TdcLimitSupported : text$ = MergeLineLists(text$, "GPU TDC limit") : EndIf

  If text$ = ""
    ProcedureReturn "Metrics only; no ADLX power/frequency controls exposed."
  EndIf

  ProcedureReturn ReplaceString(text$, #LF$, ", ")
EndProcedure

Procedure.i IsGenericAmdGpuDisplayName(name$)
  Protected lowered$ = LCase(Trim(name$))

  ProcedureReturn Bool(lowered$ = "amd radeon graphics" Or lowered$ = "radeon graphics" Or lowered$ = "amd radeon(tm) graphics" Or lowered$ = "radeon(tm) graphics")
EndProcedure

Procedure.s CleanGpuDisplayName(name$)
  Protected cleaned$ = Trim(name$)

  cleaned$ = ReplaceString(cleaned$, "[iGPU]", "")
  cleaned$ = ReplaceString(cleaned$, "[dGPU]", "")
  cleaned$ = ReplaceString(cleaned$, "[eGPU]", "")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  ProcedureReturn Trim(cleaned$)
EndProcedure

Procedure.s PreferResolvedAmdGpuName(adlxName$, detectedGpuText$)
  Protected candidate$
  Protected normalized$
  Protected lineCount.i
  Protected i.i

  If IsGenericAmdGpuDisplayName(adlxName$) = #False
    ProcedureReturn adlxName$
  EndIf

  normalized$ = ReplaceString(detectedGpuText$, ", ", #LF$)
  lineCount = CountString(normalized$, #LF$) + 1
  For i = 1 To lineCount
    candidate$ = CleanGpuDisplayName(StringField(normalized$, i, #LF$))
    If candidate$ <> "" And IsGenericAmdGpuDisplayName(candidate$) = #False
      If FindString(LCase(candidate$), "amd ", 1) Or FindString(LCase(candidate$), "radeon", 1)
        ProcedureReturn candidate$
      EndIf
    EndIf
  Next

  ProcedureReturn adlxName$
EndProcedure

Procedure UpdateAmdAdlxStatusFromJson(output$)
  gAmdAdlx\Probed = #True
  gAmdAdlx\Available = JsonBoolValue(output$, "available")
  gAmdAdlx\SdkCompiled = JsonBoolValue(output$, "sdk_compiled")
  gAmdAdlx\AmdGpuPresent = JsonBoolValue(output$, "amd_gpu_present")
  gAmdAdlx\GpuName = JsonStringValue(output$, "name")
  gAmdAdlx\GfxMaxSupported = JsonBoolValue(output$, "gfx_max")
  gAmdAdlx\PowerLimitSupported = JsonBoolValue(output$, "power_limit")
  gAmdAdlx\TdcLimitSupported = JsonBoolValue(output$, "tdc_limit")

  If gAmdAdlx\Available
    gAmdAdlx\StatusText = "Available"
  ElseIf FindBundledAmdAdlxHelper() = ""
    gAmdAdlx\StatusText = "Helper not installed"
  ElseIf gAmdAdlx\SdkCompiled = #False
    gAmdAdlx\StatusText = "Helper built without ADLX SDK"
  Else
    gAmdAdlx\StatusText = "Unavailable"
  EndIf

  gAmdAdlx\FeatureText = AmdAdlxSupportedFeatureText()
EndProcedure

Procedure ProbeAmdAdlx(announce.i = #False)
  Protected output$ = RunAmdAdlxHelper("probe")

  If output$ <> ""
    UpdateAmdAdlxStatusFromJson(output$)
  Else
    gAmdAdlx\Probed = #True
    gAmdAdlx\Available = #False
    gAmdAdlx\StatusText = "Helper unavailable"
    gAmdAdlx\FeatureText = "No ADLX helper response."
  EndIf

  gAmdAdlx\LastProbeTick = ElapsedMilliseconds()
  If announce
    If gAmdAdlx\Available
      LogAction("AMD ADLX probe: available. Features: " + gAmdAdlx\FeatureText)
    Else
      LogAction("AMD ADLX probe: " + gAmdAdlx\StatusText)
    EndIf
  EndIf
EndProcedure

Procedure ReadAmdAdlxMetrics(force.i = #False)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected output$

  If gAmdAdlx\Available = #False
    If gAmdAdlx\Probed = #False Or nowTick - gAmdAdlx\LastProbeTick > 60000
      ProbeAmdAdlx(#False)
    EndIf
    ProcedureReturn
  EndIf

  If force = #False And nowTick - gAmdAdlx\LastMetricsTick < #AmdAdlxHelperPollSeconds * 1000
    ProcedureReturn
  EndIf

  output$ = RunAmdAdlxHelper("metrics")
  gAmdAdlx\LastMetricsTick = nowTick
  If output$ = "" Or JsonBoolValue(output$, "ok") = #False
    gAmdAdlx\MetricsValid = #False
    gAmdAdlx\MetricsText = "Metrics unavailable"
    ProcedureReturn
  EndIf

  gAmdAdlx\MetricsValid = #True
  gAmdAdlx\UsageValid = JsonBoolValue(output$, "usage_valid")
  gAmdAdlx\UsagePercent = JsonNumberValue(output$, "usage_percent")
  gAmdAdlx\ClockValid = JsonBoolValue(output$, "clock_valid")
  gAmdAdlx\ClockMhz = Int(JsonNumberValue(output$, "clock_mhz"))
  gAmdAdlx\PowerValid = JsonBoolValue(output$, "power_valid")
  gAmdAdlx\PowerWatts = JsonNumberValue(output$, "power_w")
  gAmdAdlx\TemperatureValid = JsonBoolValue(output$, "temperature_valid")
  gAmdAdlx\TemperatureC = JsonNumberValue(output$, "temperature_c")

  gAmdAdlx\MetricsText = ""
  If gAmdAdlx\UsageValid : gAmdAdlx\MetricsText + "Usage " + StrD(gAmdAdlx\UsagePercent, 0) + "%" : EndIf
  If gAmdAdlx\ClockValid
    If gAmdAdlx\MetricsText <> "" : gAmdAdlx\MetricsText + ", " : EndIf
    gAmdAdlx\MetricsText + Str(gAmdAdlx\ClockMhz) + " MHz"
  EndIf
  If gAmdAdlx\PowerValid
    If gAmdAdlx\MetricsText <> "" : gAmdAdlx\MetricsText + ", " : EndIf
    gAmdAdlx\MetricsText + StrD(gAmdAdlx\PowerWatts, 1) + " W"
  EndIf
  If gAmdAdlx\TemperatureValid
    If gAmdAdlx\MetricsText <> "" : gAmdAdlx\MetricsText + ", " : EndIf
    gAmdAdlx\MetricsText + StrD(gAmdAdlx\TemperatureC, 1) + " C"
  EndIf
  If gAmdAdlx\MetricsText = "" : gAmdAdlx\MetricsText = "No supported metrics exposed" : EndIf
EndProcedure

Procedure MaintainAmdAdlxAutoProbe(*reading.TempReading, force.i = #False)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected intervalMs.q
  Protected discreteConnected.i
  Protected hardwareText$
  Protected previousAvailable.i
  Protected previousGpuName$
  Protected hardwareChanged.i

  hardwareText$ = CurrentGpuHardwareDisplay(*reading)
  discreteConnected = ActiveDiscreteGpuConnected(*reading)
  hardwareChanged = Bool(gAmdAdlx\LastGpuHardwareText <> hardwareText$ Or gAmdAdlx\LastDiscreteGpuConnected <> discreteConnected)

  If gAmdAdlx\Available
    intervalMs = #AmdAdlxAvailableProbeSeconds * 1000
  Else
    intervalMs = #AmdAdlxUnavailableProbeSeconds * 1000
  EndIf

  If force Or gAmdAdlx\Probed = #False Or hardwareChanged Or nowTick - gAmdAdlx\LastProbeTick >= intervalMs
    previousAvailable = gAmdAdlx\Available
    previousGpuName$ = gAmdAdlx\GpuName
    ProbeAmdAdlx(#False)
    If gAmdAdlx\GpuName <> ""
      gAmdAdlx\GpuName = PreferResolvedAmdGpuName(gAmdAdlx\GpuName, hardwareText$)
    EndIf

    If gAmdAdlx\Available
      If force Or previousAvailable = #False
        LogAction("AMD ADLX detected automatically. Features: " + gAmdAdlx\FeatureText)
      ElseIf previousGpuName$ <> gAmdAdlx\GpuName
        LogAction("AMD ADLX GPU changed: " + gAmdAdlx\GpuName)
      ElseIf hardwareChanged And discreteConnected
        LogAction("Discrete GPU detected by Windows. AMD ADLX support refreshed.")
      EndIf
    ElseIf force
      LogAction("AMD ADLX automatic probe: " + gAmdAdlx\StatusText)
    EndIf

    gAmdAdlx\LastGpuHardwareText = hardwareText$
    gAmdAdlx\LastDiscreteGpuConnected = discreteConnected
  EndIf

  If gAmdAdlx\Available
    ReadAmdAdlxMetrics(#False)
  EndIf
EndProcedure

Procedure.i ApplyAmdAdlxDriverPowerLimit(powerError.d, severeOvershoot.i)
  Protected output$
  Protected currentLimit.i
  Protected minLimit.i
  Protected maxLimit.i
  Protected desiredLimit.i
  Protected stepSize.i

  If gAmdAdlx\PowerLimitSupported = #False
    ProcedureReturn #False
  EndIf

  output$ = RunAmdAdlxHelper("power_get")
  If JsonBoolValue(output$, "ok") = #False
    ProcedureReturn #False
  EndIf

  currentLimit = Int(JsonNumberValue(output$, "power_limit"))
  minLimit = Int(JsonNumberValue(output$, "min"))
  maxLimit = Int(JsonNumberValue(output$, "max"))
  If maxLimit <= minLimit
    ProcedureReturn #False
  EndIf

  stepSize = ClampInt(Int(powerError), 1, 10)
  If severeOvershoot
    stepSize = ClampInt(stepSize * 2, 2, 20)
  EndIf
  desiredLimit = ClampInt(currentLimit - stepSize, minLimit, maxLimit)
  If desiredLimit >= currentLimit
    ProcedureReturn #False
  EndIf

  output$ = RunAmdAdlxHelper("power_set " + Str(desiredLimit))
  ProcedureReturn JsonBoolValue(output$, "ok")
EndProcedure

Procedure.i ApplyAmdAdlxGpuFrequencyLimit(powerError.d, severeOvershoot.i)
  Protected output$
  Protected currentMhz.i
  Protected minMhz.i
  Protected maxMhz.i
  Protected desiredMhz.i
  Protected stepMhz.i

  If gAmdAdlx\GfxMaxSupported = #False
    ProcedureReturn #False
  EndIf

  output$ = RunAmdAdlxHelper("gfx_get")
  If JsonBoolValue(output$, "ok") = #False
    ProcedureReturn #False
  EndIf

  currentMhz = Int(JsonNumberValue(output$, "max_mhz"))
  minMhz = Int(JsonNumberValue(output$, "min"))
  maxMhz = Int(JsonNumberValue(output$, "max"))
  If maxMhz <= minMhz Or currentMhz <= 0
    ProcedureReturn #False
  EndIf

  stepMhz = ClampInt(Int(powerError * 35.0), 75, 350)
  If severeOvershoot
    stepMhz = ClampInt(stepMhz * 2, 150, 700)
  EndIf
  desiredMhz = ClampInt(currentMhz - stepMhz, minMhz, maxMhz)
  If desiredMhz >= currentMhz
    ProcedureReturn #False
  EndIf

  output$ = RunAmdAdlxHelper("gfx_set_max " + Str(desiredMhz))
  ProcedureReturn JsonBoolValue(output$, "ok")
EndProcedure

Procedure.i ApplyAmdAdlxPackagePowerActuator(powerError.d, severeOvershoot.i)
  Protected ok.i

  If ApplyAmdAdlxDriverPowerLimit(powerError, severeOvershoot)
    ok = #True
  EndIf
  If (ok = #False Or severeOvershoot) And ApplyAmdAdlxGpuFrequencyLimit(powerError, severeOvershoot)
    ok = #True
  EndIf

  ProcedureReturn ok
EndProcedure

Procedure ApplyAmdAdlxControl(*reading.TempReading, targetW.i, *settings.AppSettings)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected powerError.d
  Protected severeOvershoot.i
  Static lastTraceTick.q

  If *settings\AmdAdlxEnabled = #False Or *reading\cpuPackageValid = #False
    If nowTick - lastTraceTick > 30000
      AppendRuntimeLog("AMD ADLX control skipped: enabled=" + Str(*settings\AmdAdlxEnabled) + ", package_valid=" + Str(*reading\cpuPackageValid) + ".")
      lastTraceTick = nowTick
    EndIf
    ProcedureReturn
  EndIf

  If gAmdAdlx\Available = #False
    If gAmdAdlx\Probed = #False
      ProbeAmdAdlx(#False)
    EndIf
    ProcedureReturn
  EndIf

  If gAmdAdlx\GfxMaxSupported = #False And gAmdAdlx\PowerLimitSupported = #False
    ProcedureReturn
  EndIf

  ReadAmdAdlxMetrics(#True)
  If targetW <= 0
    If nowTick - lastTraceTick > 30000
      AppendRuntimeLog("AMD ADLX control skipped: no watt target.")
      lastTraceTick = nowTick
    EndIf
    ProcedureReturn
  EndIf

  powerError = *reading\cpuPackageWatts - targetW
  If nowTick - lastTraceTick > 30000
    AppendRuntimeLog("AMD ADLX control eval: package=" + StrD(*reading\cpuPackageWatts, 1) + " W, target=" + Str(targetW) + " W, error=" + StrD(powerError, 1) + " W, features=" + gAmdAdlx\FeatureText)
    lastTraceTick = nowTick
  EndIf

  If powerError < *settings\ControlDeadband
    ProcedureReturn
  EndIf

  severeOvershoot = Bool(powerError >= *settings\ControlDeadband * 3.0)

  If powerError >= *settings\ControlDeadband
    If nowTick - gAmdAdlx\LastControlTick < #AmdAdlxControlMinimumIntervalMs
      ProcedureReturn
    EndIf
    gAmdAdlx\ControlIntegral = ClampDouble((gAmdAdlx\ControlIntegral * 0.80) + powerError, -30.0, 30.0)
    If ApplyAmdAdlxPackagePowerActuator(powerError + (gAmdAdlx\ControlIntegral * 0.25), severeOvershoot)
      gAmdAdlx\HasChangedSettings = #True
      gAmdAdlx\LastControlTick = nowTick
      If severeOvershoot
        LogAction("AMD ADLX GPU-side power/frequency limit reduced because package power remains above " + Str(targetW) + " W.")
      Else
        LogAction("AMD ADLX GPU-side power/frequency limit reduced by package-power controller.")
      EndIf
    EndIf
  ElseIf powerError <= -*settings\ControlDeadband And gAmdAdlx\HasChangedSettings
    If nowTick - gAmdAdlx\LastRecoverTick < #AmdAdlxRecoveryIntervalMs
      ProcedureReturn
    EndIf
    gAmdAdlx\ControlIntegral = ClampDouble((gAmdAdlx\ControlIntegral * 0.50) + powerError, -30.0, 30.0)
    RestoreAmdAdlxSettings(#False)
    gAmdAdlx\ControlIntegral = 0.0
    gAmdAdlx\HasChangedSettings = #False
    LogAction("AMD ADLX power/frequency settings restored after sustained lower package power.")
    gAmdAdlx\LastRecoverTick = nowTick
  Else
    gAmdAdlx\ControlIntegral * 0.90
  EndIf
EndProcedure

Procedure RestoreAmdAdlxSettings(announce.i = #True)
  Protected output$ = RunAmdAdlxHelper("restore")

  If JsonBoolValue(output$, "ok")
    gAmdAdlx\HasChangedSettings = #False
    gAmdAdlx\ControlIntegral = 0.0
    If announce
      LogAction("AMD ADLX helper restored settings it changed.")
    EndIf
  ElseIf announce
    LogAction("AMD ADLX restore failed or no ADLX runtime is available.")
  EndIf
EndProcedure

Procedure CleanupDetachedWindowsPerfHelpers()
  Protected script$

  script$ = "$currentPid = " + Str(GetCurrentProcessId_()) + "; " +
            "Get-CimInstance Win32_Process -Filter " + QuoteArgument("Name = 'PowerPilotWindowsPerfHelper.exe'") + " | ForEach-Object { " +
            "$parent = Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue; " +
            "if ($null -eq $parent -or ($parent.ProcessName -ne 'PowerPilot_V1.0' -and $_.ParentProcessId -ne $currentPid)) { " +
            "Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } }"

  RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(script$))
EndProcedure

Procedure.i RunPowerCfgElevated(arguments$)
  Protected psCommand$

  psCommand$ = "& { " +
               "$p = Start-Process -FilePath 'powercfg.exe' -ArgumentList " + QuoteArgument(arguments$) + " -Verb RunAs -WindowStyle Hidden -PassThru -Wait; " +
               "exit $p.ExitCode }"

  ProcedureReturn RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(psCommand$))
EndProcedure

Procedure TriggerDisplayReset()
  keybd_event_(#VK_LWIN, 0, 0, 0)
  keybd_event_(#VK_CONTROL, 0, 0, 0)
  keybd_event_(#VK_SHIFT, 0, 0, 0)
  keybd_event_(#VK_B, 0, 0, 0)
  Delay(60)
  keybd_event_(#VK_B, 0, #KEYEVENTF_KEYUP, 0)
  keybd_event_(#VK_SHIFT, 0, #KEYEVENTF_KEYUP, 0)
  keybd_event_(#VK_CONTROL, 0, #KEYEVENTF_KEYUP, 0)
  keybd_event_(#VK_LWIN, 0, #KEYEVENTF_KEYUP, 0)
EndProcedure

Procedure.i IsHexChar(char$)
  ProcedureReturn Bool(FindString("0123456789abcdefABCDEF", char$, 1) > 0)
EndProcedure

Procedure.i IsGuidText(text$)
  Protected i.i
  Protected char$

  If Len(text$) <> 36
    ProcedureReturn #False
  EndIf

  For i = 1 To 36
    char$ = Mid(text$, i, 1)
    Select i
      Case 9, 14, 19, 24
        If char$ <> "-"
          ProcedureReturn #False
        EndIf
      Default
        If IsHexChar(char$) = #False
          ProcedureReturn #False
        EndIf
    EndSelect
  Next

  ProcedureReturn #True
EndProcedure

Procedure.s FindGuidInText(text$)
  Protected cleaned$ = ReplaceString(ReplaceString(text$, "{", ""), "}", "")
  Protected i.i
  Protected candidate$

  For i = 1 To Len(cleaned$) - 35
    candidate$ = Mid(cleaned$, i, 36)
    If IsGuidText(candidate$)
      ProcedureReturn LCase(candidate$)
    EndIf
  Next

  ProcedureReturn ""
EndProcedure

Procedure.s GetActiveSchemeGuid()
  ProcedureReturn FindGuidInText(RunPowerCfgCapture("/GETACTIVESCHEME"))
EndProcedure

Procedure.s GetSchemeGuidByName(planName$)
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected lines.i = CountString(output$, #LF$) + 1
  Protected i.i
  Protected line$

  For i = 1 To lines
    line$ = Trim(StringField(output$, i, #LF$))
    If FindString(LCase(line$), "(" + LCase(planName$) + ")", 1)
      ProcedureReturn FindGuidInText(line$)
    EndIf
  Next

  ProcedureReturn ""
EndProcedure

Procedure.s GetSchemeNameByGuid(schemeGuid$)
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected lines.i = CountString(output$, #LF$) + 1
  Protected i.i
  Protected line$
  Protected planName$

  If schemeGuid$ = ""
    ProcedureReturn ""
  EndIf

  For i = 1 To lines
    line$ = Trim(StringField(output$, i, #LF$))
    If line$ = "" : Continue : EndIf
    If FindString(LCase(line$), LCase(schemeGuid$), 1)
      If FindString(line$, "(", 1) And FindString(line$, ")", 1)
        planName$ = StringField(StringField(line$, 2, "("), 1, ")")
        ProcedureReturn Trim(planName$)
      EndIf
    EndIf
  Next

  ProcedureReturn ""
EndProcedure

Procedure.s GetActiveSchemeName()
  ProcedureReturn GetSchemeNameByGuid(GetActiveSchemeGuid())
EndProcedure

Procedure.i ManagedPlansPresent()
  ProcedureReturn Bool(GetSchemeGuidByName(#PlanVisible$) <> "")
EndProcedure

Procedure InvalidateManagedPlansCache()
  LockMutex(gStateMutex)
  gManagedPlansCacheValid = #False
  gManagedPlansExistCacheValid = #False
  UnlockMutex(gStateMutex)
EndProcedure

Procedure.i CachedManagedPlansPresent()
  Protected valid.i
  Protected value.i

  LockMutex(gStateMutex)
  valid = gManagedPlansCacheValid
  value = gManagedPlansCacheValue
  UnlockMutex(gStateMutex)

  If valid
    ProcedureReturn value
  EndIf

  value = ManagedPlansPresent()
  LockMutex(gStateMutex)
  gManagedPlansCacheValue = value
  gManagedPlansCacheValid = #True
  UnlockMutex(gStateMutex)

  ProcedureReturn value
EndProcedure

Procedure.i SetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  Protected command$

  If acMode
    command$ = "/SETACVALUEINDEX " + schemeGuid$ + " " + subgroup$ + " " + setting$ + " " + Str(value)
  Else
    command$ = "/SETDCVALUEINDEX " + schemeGuid$ + " " + subgroup$ + " " + setting$ + " " + Str(value)
  EndIf

  ProcedureReturn RunPowerCfg(command$)
EndProcedure

Procedure.i TrySetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  SetSchemeValue(schemeGuid$, acMode, subgroup$, setting$, value)
  ProcedureReturn #True
EndProcedure

Procedure.i SetFrequencyCaps(schemeGuid$, acMode.i, mhz.i)
  If SetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX", mhz) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX1", mhz) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX2", mhz) <> 0 : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i DerivedPlanMinState(epp.i, boostMode.i, cooling.i, maxState.i, freqMHz.i)
  Protected minState.i

  If boostMode >= 2
    ProcedureReturn 15
  EndIf
  If boostMode = 1
    ProcedureReturn 8
  EndIf

  If epp >= 90 Or maxState <= 50 Or (freqMHz > 0 And freqMHz <= 1800)
    minState = 0
  ElseIf epp >= 80 Or maxState <= 60 Or (freqMHz > 0 And freqMHz <= 2200)
    minState = 1
  ElseIf epp >= 70 Or maxState <= 70 Or (freqMHz > 0 And freqMHz <= 2600)
    minState = 2
  ElseIf epp >= 60 Or maxState <= 80 Or (freqMHz > 0 And freqMHz <= 3000)
    minState = 3
  Else
    minState = 4
  EndIf

  If cooling = 0 And minState > 0
    minState - 1
  EndIf

  ProcedureReturn minState
EndProcedure

Procedure.i DerivedPlanCoreParkingMin(epp.i, boostMode.i, cooling.i, maxState.i, freqMHz.i)
  Protected parkingMin.i

  If boostMode >= 2
    parkingMin = 100
  ElseIf boostMode = 1
    parkingMin = 85
  ElseIf epp >= 90 Or maxState <= 50 Or (freqMHz > 0 And freqMHz <= 1800)
    parkingMin = 0
  ElseIf epp >= 80 Or maxState <= 60 Or (freqMHz > 0 And freqMHz <= 2200)
    parkingMin = 15
  ElseIf epp >= 70 Or maxState <= 70 Or (freqMHz > 0 And freqMHz <= 2600)
    parkingMin = 30
  ElseIf epp >= 60 Or maxState <= 80 Or (freqMHz > 0 And freqMHz <= 3000)
    parkingMin = 45
  Else
    parkingMin = 60
  EndIf

  If cooling = 0 And parkingMin >= 15
    parkingMin - 15
  EndIf

  ProcedureReturn parkingMin
EndProcedure

Procedure.i DerivedPlanPerfIncreaseThreshold(epp.i, boostMode.i, maxState.i, freqMHz.i)
  If boostMode >= 2
    ProcedureReturn 25
  EndIf
  If boostMode = 1
    ProcedureReturn 45
  EndIf

  If epp >= 95 Or maxState <= 65 Or (freqMHz > 0 And freqMHz <= 1800)
    ProcedureReturn 95
  ElseIf epp >= 90 Or maxState <= 75 Or (freqMHz > 0 And freqMHz <= 2200)
    ProcedureReturn 90
  ElseIf epp >= 80 Or maxState <= 85 Or (freqMHz > 0 And freqMHz <= 2600)
    ProcedureReturn 80
  ElseIf epp >= 65
    ProcedureReturn 65
  EndIf

  ProcedureReturn 45
EndProcedure

Procedure.i DerivedPlanPerfDecreaseThreshold(epp.i, boostMode.i, maxState.i, freqMHz.i)
  If boostMode >= 2
    ProcedureReturn 10
  EndIf
  If boostMode = 1
    ProcedureReturn 20
  EndIf

  If epp >= 95 Or maxState <= 65 Or (freqMHz > 0 And freqMHz <= 1800)
    ProcedureReturn 55
  ElseIf epp >= 90 Or maxState <= 75 Or (freqMHz > 0 And freqMHz <= 2200)
    ProcedureReturn 45
  ElseIf epp >= 80 Or maxState <= 85 Or (freqMHz > 0 And freqMHz <= 2600)
    ProcedureReturn 35
  ElseIf epp >= 65
    ProcedureReturn 25
  EndIf

  ProcedureReturn 15
EndProcedure

Procedure.i DerivedPlanBoostPolicy(epp.i, boostMode.i, maxState.i, freqMHz.i)
  If boostMode >= 2
    ProcedureReturn 70
  EndIf
  If boostMode = 1
    ProcedureReturn 45
  EndIf

  If epp >= 90 Or maxState <= 75 Or (freqMHz > 0 And freqMHz <= 2200)
    ProcedureReturn 0
  EndIf

  ProcedureReturn 20
EndProcedure

Procedure.i DerivedPlanPerfIncreasePolicy(epp.i, boostMode.i)
  If boostMode >= 2
    ProcedureReturn 2
  EndIf
  If boostMode = 1 Or epp < 40
    ProcedureReturn 1
  EndIf

  ProcedureReturn 0
EndProcedure

Procedure.i DerivedPlanPerfDecreasePolicy(epp.i, boostMode.i)
  If boostMode >= 2 Or epp < 40
    ProcedureReturn 1
  EndIf

  ProcedureReturn 0
EndProcedure

Procedure.i DerivedPlanLatencyHintPerf(epp.i, boostMode.i, maxState.i, freqMHz.i)
  If boostMode >= 2
    ProcedureReturn 99
  EndIf
  If boostMode = 1
    ProcedureReturn 70
  EndIf

  If epp >= 95 Or maxState <= 65 Or (freqMHz > 0 And freqMHz <= 1800)
    ProcedureReturn 30
  ElseIf epp >= 90 Or maxState <= 75 Or (freqMHz > 0 And freqMHz <= 2200)
    ProcedureReturn 40
  ElseIf epp >= 80 Or maxState <= 85 Or (freqMHz > 0 And freqMHz <= 2600)
    ProcedureReturn 50
  EndIf

  ProcedureReturn 60
EndProcedure

Procedure.i DerivedPlanSchedulingPolicy(epp.i, boostMode.i, maxState.i, freqMHz.i)
  If boostMode >= 2 Or epp < 80
    ProcedureReturn 5
  EndIf

  If epp >= 95 Or maxState <= 65 Or (freqMHz > 0 And freqMHz <= 1800)
    ProcedureReturn 4
  EndIf

  ProcedureReturn 5
EndProcedure

Procedure.i DerivedPlanAutonomousMode(epp.i, boostMode.i, maxState.i, freqMHz.i)
  If boostMode = 0 Or maxState < 95 Or freqMHz > 0 Or epp >= 50
    ProcedureReturn 0
  EndIf

  ProcedureReturn 1
EndProcedure

Procedure.i ApplyAdvancedProcessorTuning(*plan.PlanDefinition, schemeGuid$)
  Protected dcMinState.i
  Protected acMinState.i
  Protected dcCoreParkingMin.i
  Protected acCoreParkingMin.i
  Protected dcPerfIncreaseThreshold.i
  Protected acPerfIncreaseThreshold.i
  Protected dcPerfDecreaseThreshold.i
  Protected acPerfDecreaseThreshold.i
  Protected dcBoostPolicy.i
  Protected acBoostPolicy.i
  Protected dcPerfIncreasePolicy.i
  Protected acPerfIncreasePolicy.i
  Protected dcPerfDecreasePolicy.i
  Protected acPerfDecreasePolicy.i
  Protected dcLatencyHintPerf.i
  Protected acLatencyHintPerf.i
  Protected dcSchedulingPolicy.i
  Protected acSchedulingPolicy.i
  Protected dcAutonomousMode.i
  Protected acAutonomousMode.i

  If *plan = 0
    ProcedureReturn #False
  EndIf

  dcMinState = DerivedPlanMinState(*plan\DcEpp, *plan\DcBoostMode, *plan\DcCooling, *plan\DcMaxState, *plan\DcFreqMHz)
  acMinState = DerivedPlanMinState(*plan\AcEpp, *plan\AcBoostMode, *plan\AcCooling, *plan\AcMaxState, *plan\AcFreqMHz)
  dcCoreParkingMin = DerivedPlanCoreParkingMin(*plan\DcEpp, *plan\DcBoostMode, *plan\DcCooling, *plan\DcMaxState, *plan\DcFreqMHz)
  acCoreParkingMin = DerivedPlanCoreParkingMin(*plan\AcEpp, *plan\AcBoostMode, *plan\AcCooling, *plan\AcMaxState, *plan\AcFreqMHz)
  dcPerfIncreaseThreshold = DerivedPlanPerfIncreaseThreshold(*plan\DcEpp, *plan\DcBoostMode, *plan\DcMaxState, *plan\DcFreqMHz)
  acPerfIncreaseThreshold = DerivedPlanPerfIncreaseThreshold(*plan\AcEpp, *plan\AcBoostMode, *plan\AcMaxState, *plan\AcFreqMHz)
  dcPerfDecreaseThreshold = DerivedPlanPerfDecreaseThreshold(*plan\DcEpp, *plan\DcBoostMode, *plan\DcMaxState, *plan\DcFreqMHz)
  acPerfDecreaseThreshold = DerivedPlanPerfDecreaseThreshold(*plan\AcEpp, *plan\AcBoostMode, *plan\AcMaxState, *plan\AcFreqMHz)
  dcBoostPolicy = DerivedPlanBoostPolicy(*plan\DcEpp, *plan\DcBoostMode, *plan\DcMaxState, *plan\DcFreqMHz)
  acBoostPolicy = DerivedPlanBoostPolicy(*plan\AcEpp, *plan\AcBoostMode, *plan\AcMaxState, *plan\AcFreqMHz)
  dcPerfIncreasePolicy = DerivedPlanPerfIncreasePolicy(*plan\DcEpp, *plan\DcBoostMode)
  acPerfIncreasePolicy = DerivedPlanPerfIncreasePolicy(*plan\AcEpp, *plan\AcBoostMode)
  dcPerfDecreasePolicy = DerivedPlanPerfDecreasePolicy(*plan\DcEpp, *plan\DcBoostMode)
  acPerfDecreasePolicy = DerivedPlanPerfDecreasePolicy(*plan\AcEpp, *plan\AcBoostMode)
  dcLatencyHintPerf = DerivedPlanLatencyHintPerf(*plan\DcEpp, *plan\DcBoostMode, *plan\DcMaxState, *plan\DcFreqMHz)
  acLatencyHintPerf = DerivedPlanLatencyHintPerf(*plan\AcEpp, *plan\AcBoostMode, *plan\AcMaxState, *plan\AcFreqMHz)
  dcSchedulingPolicy = DerivedPlanSchedulingPolicy(*plan\DcEpp, *plan\DcBoostMode, *plan\DcMaxState, *plan\DcFreqMHz)
  acSchedulingPolicy = DerivedPlanSchedulingPolicy(*plan\AcEpp, *plan\AcBoostMode, *plan\AcMaxState, *plan\AcFreqMHz)
  dcAutonomousMode = DerivedPlanAutonomousMode(*plan\DcEpp, *plan\DcBoostMode, *plan\DcMaxState, *plan\DcFreqMHz)
  acAutonomousMode = DerivedPlanAutonomousMode(*plan\AcEpp, *plan\AcBoostMode, *plan\AcMaxState, *plan\AcFreqMHz)

  ; These processor knobs are optional so older systems can still accept the
  ; base plan even if a specific alias is absent. The existing EPP/boost/cooling
  ; values remain the source of truth, and the extra aliases follow them.
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP1", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP2", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN1", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN2", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES", acCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES1", acCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD", acPerfIncreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", acPerfIncreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD", acPerfDecreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", acPerfDecreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCPOL", acPerfIncreasePolicy)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCPOL1", acPerfIncreasePolicy)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECPOL", acPerfDecreasePolicy)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECPOL1", acPerfDecreasePolicy)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL", acBoostPolicy)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTEPP", 100)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTEPP1", 100)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTEPP2", 100)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTPERF", acLatencyHintPerf)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTPERF1", acLatencyHintPerf)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "LATENCYHINTPERF2", acLatencyHintPerf)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SCHEDPOLICY", acSchedulingPolicy)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SHORTSCHEDPOLICY", acSchedulingPolicy)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFAUTONOMOUS", acAutonomousMode)

  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP1", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP2", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN1", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN2", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES", dcCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES1", dcCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD", dcPerfIncreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", dcPerfIncreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD", dcPerfDecreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", dcPerfDecreaseThreshold)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCPOL", dcPerfIncreasePolicy)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCPOL1", dcPerfIncreasePolicy)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECPOL", dcPerfDecreasePolicy)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECPOL1", dcPerfDecreasePolicy)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL", dcBoostPolicy)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTEPP", 100)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTEPP1", 100)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTEPP2", 100)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTPERF", dcLatencyHintPerf)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTPERF1", dcLatencyHintPerf)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "LATENCYHINTPERF2", dcLatencyHintPerf)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SCHEDPOLICY", dcSchedulingPolicy)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SHORTSCHEDPOLICY", dcSchedulingPolicy)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFAUTONOMOUS", dcAutonomousMode)

  ProcedureReturn #True
EndProcedure

Procedure.i ApplyPlanDefinitionToScheme(*plan.PlanDefinition, schemeGuid$)
  If *plan = 0
    ProcedureReturn #False
  EndIf

  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP", *plan\DcEpp) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\DcBoostMode) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\DcMaxState) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #False, *plan\DcFreqMHz) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\DcCooling) <> 0 : ProcedureReturn #False : EndIf

  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", *plan\AcEpp) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\AcBoostMode) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\AcMaxState) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #True, *plan\AcFreqMHz) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\AcCooling) <> 0 : ProcedureReturn #False : EndIf
  If ApplyAdvancedProcessorTuning(*plan, schemeGuid$) = #False : ProcedureReturn #False : EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i ConfigureScheme(planName$, schemeGuid$)
  If planName$ = #PlanVisible$
    planName$ = GetCurrentManagedPlan()
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\Name = planName$
      ProcedureReturn ApplyPlanDefinitionToScheme(@gPlanDefs(), schemeGuid$)
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

Procedure.s EnsureVisibleScheme()
  ProcedureReturn EnsureScheme(#PlanVisible$)
EndProcedure

Procedure.i SyncVisibleScheme(planName$)
  Protected visibleGuid$ = EnsureVisibleScheme()

  If visibleGuid$ = ""
    LogAction("Failed to create " + #PlanVisible$)
    ProcedureReturn #False
  EndIf

  If ConfigureScheme(planName$, visibleGuid$) = #False
    LogAction("Failed to synchronize " + #PlanVisible$ + " with " + planName$)
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.s EnsureScheme(planName$)
  Protected guid$ = GetSchemeGuidByName(planName$)

  If guid$ <> ""
    ProcedureReturn guid$
  EndIf

  guid$ = FindGuidInText(RunPowerCfgCapture("/DUPLICATESCHEME SCHEME_BALANCED"))
  If guid$ = ""
    ProcedureReturn ""
  EndIf

  If RunPowerCfg("/CHANGENAME " + guid$ + " " + QuoteArgument(planName$)) <> 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn guid$
EndProcedure

Procedure.i EnsurePlanInstalled(planName$)
  Protected schemeGuid$

  schemeGuid$ = EnsureScheme(planName$)
  If schemeGuid$ = ""
    LogAction("Failed to create " + planName$)
    ProcedureReturn #False
  EndIf

  If ConfigureScheme(planName$, schemeGuid$) = #False
    LogAction("Failed to configure " + planName$)
    ProcedureReturn #False
  EndIf

  InvalidateManagedPlansCache()
  ProcedureReturn #True
EndProcedure

Procedure.i RemoveManagedPlanByName(planName$)
  Protected guid$
  Protected activePlan$

  If planName$ = "" Or planName$ = #PlanVisible$
    ProcedureReturn #False
  EndIf

  guid$ = GetSchemeGuidByName(planName$)
  If guid$ = ""
    ProcedureReturn #True
  EndIf

  activePlan$ = GetActiveSchemeName()
  If activePlan$ = planName$ Or (activePlan$ = #PlanVisible$ And GetCurrentManagedPlan() = planName$)
    RunPowerCfg("/SETACTIVE SCHEME_BALANCED")
  EndIf

  If gSettings\CurrentManagedPlan = planName$
    RememberCurrentManagedPlan(#PlanPlugged$, #True)
  EndIf
  If gSettings\LastPluggedPlan = planName$
    RememberPluggedPlan(#PlanPlugged$, #True)
  EndIf

  If RunPowerCfg("/DELETE " + guid$) <> 0
    LogAction("Failed to remove " + planName$)
    ProcedureReturn #False
  EndIf

  LogAction("Removed " + planName$)
  InvalidateManagedPlansCache()
  ProcedureReturn #True
EndProcedure

Procedure.s BuildPlanComboSignature()
  Protected signature$

  ForEach gPlanDefs()
    If PlanDefinitionInstalled(gPlanDefs()\Name)
      signature$ + gPlanDefs()\Name + #LF$
    EndIf
  Next

  ProcedureReturn signature$
EndProcedure

Procedure.s BuildPlanListSignature()
  Protected signature$

  ForEach gPlanDefs()
    signature$ + gPlanDefs()\Name + "|" +
                 Str(gPlanDefs()\BuiltIn) + "|" +
                 gPlanDefs()\Description + "|" +
                 Str(PlanDefinitionInstalled(gPlanDefs()\Name)) + #LF$
  Next

  ProcedureReturn signature$
EndProcedure

Procedure PopulatePlanCombo()
  Protected selectedName$
  Protected signature$

  If IsGadget(#GadgetPlanCombo) = 0
    ProcedureReturn
  EndIf

  selectedName$ = ""
  If GetGadgetState(#GadgetPlanCombo) >= 0
    selectedName$ = GetGadgetText(#GadgetPlanCombo)
  EndIf

  signature$ = BuildPlanComboSignature()
  If gLastPlanComboSignature$ <> signature$
    ClearGadgetItems(#GadgetPlanCombo)
    ForEach gPlanDefs()
      If PlanDefinitionInstalled(gPlanDefs()\Name)
        AddGadgetItem(#GadgetPlanCombo, -1, gPlanDefs()\Name)
      EndIf
    Next
    gLastPlanComboSignature$ = signature$
  EndIf

  If CountGadgetItems(#GadgetPlanCombo) > 0
    UpdateGadgetStateIfNeeded(#GadgetPlanCombo, 0)
    If selectedName$ <> ""
      SelectPlanComboByName(selectedName$)
    EndIf
  EndIf
EndProcedure

Procedure PopulatePlanPresetCombo()
  If IsGadget(#GadgetPlanEditorPreset) = 0
    ProcedureReturn
  EndIf

  ClearGadgetItems(#GadgetPlanEditorPreset)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanFull$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanPlugged$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanQuiet$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanBattery$)
  UpdateGadgetStateIfNeeded(#GadgetPlanEditorPreset, 0)
EndProcedure

Procedure RefreshPlanList()
  Protected row.i
  Protected selectedRow.i = -1
  Protected typeText$
  Protected signature$

  If IsGadget(#GadgetPlanList) = 0
    ProcedureReturn
  EndIf

  signature$ = BuildPlanListSignature()
  If gLastPlanListSignature$ <> signature$
    ClearGadgetItems(#GadgetPlanList)
    row = 0
    ForEach gPlanDefs()
      If gPlanDefs()\BuiltIn
        typeText$ = "Built-in"
      Else
        typeText$ = "Saved"
      EndIf
      AddGadgetItem(#GadgetPlanList, -1, gPlanDefs()\Name + #LF$ + typeText$ + #LF$ + gPlanDefs()\Description)
      If PlanDefinitionInstalled(gPlanDefs()\Name)
        SetGadgetItemState(#GadgetPlanList, row, #PB_ListIcon_Checked)
      EndIf
      row + 1
    Next
    gLastPlanListSignature$ = signature$
  EndIf

  row = 0
  ForEach gPlanDefs()
    If gSelectedPlanName$ = gPlanDefs()\Name
      selectedRow = row
      Break
    EndIf
    row + 1
  Next

  If selectedRow >= 0
    UpdateGadgetStateIfNeeded(#GadgetPlanList, selectedRow)
  ElseIf row > 0
    UpdateGadgetStateIfNeeded(#GadgetPlanList, 0)
    gSelectedPlanName$ = GetGadgetItemText(#GadgetPlanList, 0)
  EndIf
EndProcedure

Procedure RefreshPlanEditor()
  Protected selected$

  If IsGadget(#GadgetPlanEditorName) = 0
    ProcedureReturn
  EndIf

  selected$ = gSelectedPlanName$
  If selected$ = ""
    If FirstElement(gPlanDefs())
      selected$ = gPlanDefs()\Name
      gSelectedPlanName$ = selected$
    EndIf
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\Name = selected$
      UpdateTextGadgetIfNeeded(#GadgetPlanEditorName, gPlanDefs()\Name)
      UpdateTextGadgetIfNeeded(#GadgetPlanEditorSummary, gPlanDefs()\Description)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcEpp, gPlanDefs()\AcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcBoost, gPlanDefs()\AcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcState, gPlanDefs()\AcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcFreq, gPlanDefs()\AcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcCooling, gPlanDefs()\AcCooling)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcEpp, gPlanDefs()\DcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcBoost, gPlanDefs()\DcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcState, gPlanDefs()\DcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcFreq, gPlanDefs()\DcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcCooling, gPlanDefs()\DcCooling)
      UpdateGadgetDisabledIfNeeded(#GadgetPlanEditorDelete, Bool(gPlanDefs()\BuiltIn))
      UpdateGadgetDisabledIfNeeded(#GadgetPlanEditorName, Bool(gPlanDefs()\BuiltIn))
      Break
    EndIf
  Next
EndProcedure

Procedure LoadPlanEditorFromPreset(planName$)
  ForEach gPlanDefs()
    If gPlanDefs()\Name = planName$
      UpdateGadgetStateIfNeeded(#GadgetPlanAcEpp, gPlanDefs()\AcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcBoost, gPlanDefs()\AcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcState, gPlanDefs()\AcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcFreq, gPlanDefs()\AcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcCooling, gPlanDefs()\AcCooling)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcEpp, gPlanDefs()\DcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcBoost, gPlanDefs()\DcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcState, gPlanDefs()\DcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcFreq, gPlanDefs()\DcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcCooling, gPlanDefs()\DcCooling)
      UpdateTextGadgetIfNeeded(#GadgetPlanEditorSummary, gPlanDefs()\Description)
      Break
    EndIf
  Next
EndProcedure

Procedure SavePlanEditorDefinition()
  Protected targetName$
  Protected existingGuid$

  targetName$ = gSelectedPlanName$

  If targetName$ = ""
    LogAction("Select a profile before saving.")
    ProcedureReturn
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\Name = targetName$
      gPlanDefs()\Description = CleanPlanText(GetGadgetText(#GadgetPlanEditorSummary))
      gPlanDefs()\AcEpp = GetGadgetState(#GadgetPlanAcEpp)
      gPlanDefs()\AcBoostMode = GetGadgetState(#GadgetPlanAcBoost)
      gPlanDefs()\AcMaxState = GetGadgetState(#GadgetPlanAcState)
      gPlanDefs()\AcFreqMHz = GetGadgetState(#GadgetPlanAcFreq)
      gPlanDefs()\AcCooling = GetGadgetState(#GadgetPlanAcCooling)
      gPlanDefs()\DcEpp = GetGadgetState(#GadgetPlanDcEpp)
      gPlanDefs()\DcBoostMode = GetGadgetState(#GadgetPlanDcBoost)
      gPlanDefs()\DcMaxState = GetGadgetState(#GadgetPlanDcState)
      gPlanDefs()\DcFreqMHz = GetGadgetState(#GadgetPlanDcFreq)
      gPlanDefs()\DcCooling = GetGadgetState(#GadgetPlanDcCooling)
      existingGuid$ = GetSchemeGuidByName(targetName$)
      If existingGuid$ <> ""
        ConfigureScheme(targetName$, existingGuid$)
      EndIf
      gSelectedPlanName$ = targetName$
      RefreshPlanList()
      PopulatePlanCombo()
      RefreshPlanEditor()
      LogAction("Updated plan definition for " + targetName$)
      ProcedureReturn
    EndIf
  Next
EndProcedure

Procedure.i CreateManagedPlans()
  Protected visibleGuid$
  Protected schemeGuid$

  visibleGuid$ = EnsureVisibleScheme()
  If visibleGuid$ = "" : LogAction("Failed to create " + #PlanVisible$) : ProcedureReturn #False : EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\DefaultInstalled
      schemeGuid$ = EnsureScheme(gPlanDefs()\Name)
      If schemeGuid$ = "" : LogAction("Failed to create " + gPlanDefs()\Name) : ProcedureReturn #False : EndIf
      If ConfigureScheme(gPlanDefs()\Name, schemeGuid$) = #False : LogAction("Failed to configure " + gPlanDefs()\Name) : ProcedureReturn #False : EndIf
    EndIf
  Next

  If ConfigureScheme(GetCurrentManagedPlan(), visibleGuid$) = #False : LogAction("Failed to configure " + #PlanVisible$) : ProcedureReturn #False : EndIf
  InvalidateManagedPlansCache()
  LogAction("PowerPilot behavior profiles are present.")
  ProcedureReturn #True
EndProcedure

Procedure.i CleanupManagedPlans()
  Protected script$
  Protected result$

  script$ = "& { " +
            "$entries = @(); " +
            "powercfg /L | ForEach-Object { " +
            "  if($_ -match '([a-fA-F0-9-]{36}).*\\(([^\\)]+)\\)\\s*(\\*)?') { " +
            "    if($matches[2] -match '^(PowerPilot($| )|Codex )') { " +
            "      $entries += [pscustomobject]@{ Guid = $matches[1]; Active = ($_ -match '\\*') } " +
            "    } " +
            "  } " +
            "}; " +
            "if(($entries | Where-Object { $_.Active }).Count -gt 0) { powercfg /SETACTIVE SCHEME_BALANCED | Out-Null }; " +
            "$entries | ForEach-Object { powercfg /DELETE $_.Guid | Out-Null }; " +
            "Write-Output 'OK' }"

  result$ = RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(script$))
  If FindString(result$, "OK", 1)
    InvalidateManagedPlansCache()
    LogAction("Managed PowerPilot profiles removed.")
    ProcedureReturn #True
  EndIf

  LogAction("Failed to remove managed PowerPilot profiles.")
  ProcedureReturn #False
EndProcedure

Procedure.i ActivatePlanByName(planName$, allowElevation.i = #False)
  Protected guid$
  Protected activeTargetPlan$
  Protected result.i
  Protected oldPlan$
  Protected oldGuid$

  If IsSelectableManagedPlanName(planName$)
    RememberCurrentManagedPlan(planName$, #True)

    activeTargetPlan$ = planName$
  Else
    activeTargetPlan$ = planName$
  EndIf

  guid$ = GetSchemeGuidByName(activeTargetPlan$)

  If guid$ = ""
    LogAction("Plan not found: " + planName$)
    ProcedureReturn #False
  EndIf

  If gDynamicControl\Active
    oldPlan$ = GetActiveSchemeName()
    If oldPlan$ = #PlanVisible$
      oldPlan$ = GetCurrentManagedPlan()
    EndIf
    oldGuid$ = GetActiveSchemeGuid()
    If oldGuid$ <> "" And IsSelectableManagedPlanName(oldPlan$)
      ConfigureScheme(oldPlan$, oldGuid$)
    EndIf
  EndIf

  result = RunPowerCfg("/SETACTIVE " + guid$)
  If result <> 0 And allowElevation
    result = RunPowerCfgElevated("/SETACTIVE " + guid$)
  EndIf

  If result = 0
    gDynamicControl\Active = #False
    gDynamicControl\CpuCapPercent = 100
    gDynamicControl\CpuCapMhz = 0
    gDynamicControl\Integral = 0.0
    gDynamicControl\StatusText = "Selected profile active; no temporary cap applied."
    LockMutex(gStateMutex)
    If IsSelectableManagedPlanName(planName$)
      gState\ActivePlan = planName$
    Else
      gState\ActivePlan = activeTargetPlan$
    EndIf
    UnlockMutex(gStateMutex)
    LogAction("Activated " + planName$)
    ProcedureReturn #True
  EndIf

  LogAction("Failed to activate " + planName$ + " (exit " + Str(result) + ")")
  ProcedureReturn #False
EndProcedure

Procedure.i DetectPowerSource()
  Protected status.SYSTEM_POWER_STATUS
  If GetSystemPowerStatus_(@status) = 0
    ProcedureReturn #PowerSourceUnknown
  EndIf

  Select status\ACLineStatus
    Case 0 : ProcedureReturn #PowerSourceBattery
    Case 1 : ProcedureReturn #PowerSourcePlugged
  EndSelect

  ProcedureReturn #PowerSourceUnknown
EndProcedure

Procedure.s PowerSourceText(powerSource.i)
  Select powerSource
    Case #PowerSourceBattery : ProcedureReturn "Battery"
    Case #PowerSourcePlugged : ProcedureReturn "Plugged In"
  EndSelect
  ProcedureReturn "Unknown"
EndProcedure

Procedure.i ExpandWindowsCounterPaths(counterPath$, List expandedPaths.s())
  Protected needed.l = 0
  Protected result.i
  Protected *buffer
  Protected *cursor
  Protected onePath$

  ClearList(expandedPaths())
  result = PdhExpandWildCardPathW(0, counterPath$, 0, @needed, 0)
  If needed <= 0
    ProcedureReturn #False
  EndIf

  *buffer = AllocateMemory((needed + 2) * SizeOf(Character))
  If *buffer = 0
    ProcedureReturn #False
  EndIf

  result = PdhExpandWildCardPathW(0, counterPath$, *buffer, @needed, 0)
  If result <> 0
    FreeMemory(*buffer)
    ProcedureReturn #False
  EndIf

  *cursor = *buffer
  While PeekU(*cursor) <> 0
    onePath$ = PeekS(*cursor, -1, #PB_Unicode)
    If onePath$ <> ""
      AddElement(expandedPaths())
      expandedPaths() = onePath$
    EndIf
    *cursor + (Len(onePath$) + 1) * SizeOf(Character)
  Wend

  FreeMemory(*buffer)
  ProcedureReturn Bool(ListSize(expandedPaths()) > 0)
EndProcedure

Procedure.s WindowsCounterInstanceName(counterPath$)
  Protected startPos.i = FindString(counterPath$, "(", 1)
  Protected endPos.i

  If startPos > 0
    endPos = FindString(counterPath$, ")", startPos + 1)
    If endPos > startPos
      ProcedureReturn Mid(counterPath$, startPos + 1, endPos - startPos - 1)
    EndIf
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i WindowsCpuCounterScore(instanceName$)
  Protected inst$ = LCase(instanceName$)

  If inst$ = "rapl_package0_pkg" : ProcedureReturn 5000 : EndIf
  If inst$ = "current socket power" : ProcedureReturn 4500 : EndIf
  If inst$ = "apu power" : ProcedureReturn 4200 : EndIf
  If FindString(inst$, "cpu", 1) : ProcedureReturn 3900 : EndIf
  If FindString(inst$, "socket", 1) : ProcedureReturn 3800 : EndIf
  If FindString(inst$, "power", 1) And FindString(inst$, "gpu", 1) = 0 : ProcedureReturn 3400 : EndIf
  If FindString(inst$, "ppt", 1) : ProcedureReturn 3200 : EndIf
  If FindString(inst$, "stapm", 1) : ProcedureReturn 3100 : EndIf
  If FindString(inst$, "pkg", 1) : ProcedureReturn 2500 : EndIf

  ProcedureReturn -1
EndProcedure

Procedure.i ReadWindowsCounterDouble(counterHandle.i, *out.DoubleHolder)
  Protected fmt.PDH_FMT_COUNTERVALUE_DOUBLE
  Protected counterType.l
  Protected result.i

  result = PdhGetFormattedCounterValue(counterHandle, #PDH_FMT_DOUBLE, @counterType, @fmt)
  If result = 0 And (fmt\CStatus = #PDH_CSTATUS_VALID_DATA Or fmt\CStatus = #PDH_CSTATUS_NEW_DATA)
    *out\value = fmt\doubleValue
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i ReadWindowsTelemetry(*reading.TempReading)
  Protected queryHandle.i
  Protected counterHandle.i
  Protected result.i
  Protected cpuBestScore.i = -1
  Protected tempBestScore.i = -1
  Protected powerFallbackNeeded.i
  Protected value.DoubleHolder
  Protected instanceName$
  Protected tempC.d
  Protected watts.d
  Protected NewList counterPaths.s()
  Protected NewList counters.WindowsCounterEntry()

  ReadWindowsPmiTelemetry(*reading)
  If *reading\cpuPackageValid = #False
    ReadWindowsEmiTelemetry(*reading)
  EndIf
  ReadWindowsPerfStreamTelemetry(*reading)
  powerFallbackNeeded = Bool(*reading\cpuPackageValid = #False)

  If InitializePdh() = #False
    ProcedureReturn HasUsableTelemetry(*reading)
  EndIf

  result = PdhOpenQueryW(0, 0, @queryHandle)
  If result <> 0 Or queryHandle = 0
    ProcedureReturn HasUsableTelemetry(*reading)
  EndIf

  If powerFallbackNeeded And ExpandWindowsCounterPaths("\Energy Meter(*)\Power", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterCpu
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If ExpandWindowsCounterPaths("\Thermal Zone Information(*)\High Precision Temperature", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterTempHp
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If ExpandWindowsCounterPaths("\Thermal Zone Information(*)\Temperature", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterTemp
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If ListSize(counters()) = 0
    PdhCloseQuery(queryHandle)
    ProcedureReturn HasUsableTelemetry(*reading)
  EndIf

  PdhCollectQueryData(queryHandle)
  Delay(150)
  PdhCollectQueryData(queryHandle)

  ForEach counters()
    If ReadWindowsCounterDouble(counters()\handle, @value) = #False
      Continue
    EndIf

    instanceName$ = WindowsCounterInstanceName(counters()\path)

    Select counters()\kind
      Case #WinCounterCpu
        watts = value\value / 1000.0
        result = WindowsCpuCounterScore(instanceName$)
        If *reading\cpuPackageValid = #False And result >= 0 And HasMeaningfulPowerWatts(watts) And (result > cpuBestScore Or (result = cpuBestScore And value\value > (*reading\cpuPackageWatts * 1000.0)))
          cpuBestScore = result
          *reading\cpuPackageValid = #True
          *reading\cpuPackageSensor = "Windows power reading / " + instanceName$
          *reading\cpuPackageWatts = watts
        EndIf

      Case #WinCounterTempHp
        tempC = (value\value / 10.0) - 273.15
        If tempC > -50 And tempC < 150 And (tempBestScore < 2000 Or (tempBestScore = 2000 And tempC > *reading\windowsTempCelsius))
          tempBestScore = 2000
          *reading\windowsTempValid = #True
          *reading\windowsTempSensor = "Windows " + instanceName$
          *reading\windowsTempCelsius = tempC
        EndIf

      Case #WinCounterTemp
        tempC = value\value - 273.15
        If tempC > -50 And tempC < 150 And (tempBestScore < 1000 Or (tempBestScore = 1000 And tempC > *reading\windowsTempCelsius))
          tempBestScore = 1000
          *reading\windowsTempValid = #True
          *reading\windowsTempSensor = "Windows " + instanceName$
          *reading\windowsTempCelsius = tempC
        EndIf
    EndSelect
  Next

  PdhCloseQuery(queryHandle)

  If *reading\windowsTempValid
    *reading\valid = #True
    *reading\source = "Windows Performance Counters"
    *reading\sensor = *reading\windowsTempSensor
    *reading\celsius = *reading\windowsTempCelsius
  EndIf

  ProcedureReturn Bool(*reading\windowsTempValid Or *reading\cpuPackageValid Or *reading\gpuMemoryValid Or *reading\gpuSharedMemoryValid Or *reading\gpuDeviceNames <> "")
EndProcedure

Procedure.i ReadFallbackSensor(*reading.TempReading)
  Protected code$
  Protected line$

  code$ = "& { " +
          "$ErrorActionPreference='SilentlyContinue'; " +
          "try { " +
          "  $zones = Get-WmiObject -Namespace 'root\\WMI' -Class 'MSAcpi_ThermalZoneTemperature'; " +
          "  if($zones) { $hot = $zones | ForEach-Object { New-Object psobject -Property @{ Name = $_.InstanceName; Value = (([double]$_.CurrentTemperature / 10) - 273.15) } } | Sort-Object Value -Descending | Select-Object -First 1; if($hot) { Write-Output ('ACPI|' + $hot.Name + '|' + [string]([math]::Round([double]$hot.Value,1))); exit 0 } } " +
          "} catch {} " +
          "exit 1 }"

  line$ = FirstLine(RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(code$)))

  If Left(line$, 5) = "ACPI|"
    *reading\valid = #True
    *reading\source = "ACPI Thermal Zone"
    *reading\sensor = StringField(line$, 2, "|")
    *reading\celsius = ValD(StringField(line$, 3, "|"))
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure MergeTelemetryReading(*target.TempReading, *source.TempReading)
  If *target\valid = #False And *source\valid
    *target\valid = #True
    *target\source = *source\source
    *target\sensor = *source\sensor
    *target\celsius = *source\celsius
  EndIf

  If *target\windowsTempValid = #False And *source\windowsTempValid
    *target\windowsTempValid = #True
    *target\windowsTempSensor = *source\windowsTempSensor
    *target\windowsTempCelsius = *source\windowsTempCelsius
  EndIf

  If *target\cpuPackageValid = #False And *source\cpuPackageValid
    *target\cpuPackageValid = #True
    *target\cpuPackageSensor = *source\cpuPackageSensor
    *target\cpuPackageWatts = *source\cpuPackageWatts
  EndIf

  If *target\gpuMemoryValid = #False And *source\gpuMemoryValid
    *target\gpuMemoryValid = #True
    *target\gpuMemorySensor = *source\gpuMemorySensor
    *target\gpuMemoryMb = *source\gpuMemoryMb
  EndIf

  If *target\gpuSharedMemoryValid = #False And *source\gpuSharedMemoryValid
    *target\gpuSharedMemoryValid = #True
    *target\gpuSharedMemorySensor = *source\gpuSharedMemorySensor
    *target\gpuSharedMemoryMb = *source\gpuSharedMemoryMb
  EndIf

  If *source\gpuDeviceNames <> ""
    *target\gpuDeviceNames = MergeLineLists(*target\gpuDeviceNames, *source\gpuDeviceNames)
  EndIf
EndProcedure

Procedure.i CaptureTelemetrySnapshot(*reading.TempReading, *windows.TempReading, *fallback.TempReading)
  Protected useWindows.i
  Protected windowsReady.i
  Protected fallbackReady.i

  ResetTempReading(*reading)
  ResetTempReading(*windows)
  ResetTempReading(*fallback)

  LockMutex(gStateMutex)
  useWindows = gSettings\UseWindows
  UnlockMutex(gStateMutex)

  If useWindows
    windowsReady = ReadWindowsTelemetry(*windows)
    ApplyTelemetryLatch(*windows, @gWindowsTelemetryLatch)
    windowsReady = HasUsableTelemetry(*windows)
    If windowsReady
      MergeTelemetryReading(*reading, *windows)
    EndIf
  EndIf

  If *reading\valid = #False And *reading\windowsTempValid
    *reading\valid = #True
    *reading\source = "Windows Performance Counters"
    *reading\sensor = *reading\windowsTempSensor
    *reading\celsius = *reading\windowsTempCelsius
  EndIf

  If *reading\valid = #False And *reading\windowsTempValid = #False
    fallbackReady = ReadFallbackSensor(*fallback)
    ApplyTelemetryLatch(*fallback, @gFallbackTelemetryLatch)
    fallbackReady = *fallback\valid
    If fallbackReady
      CopyTempReading(*reading, *fallback)
    EndIf
  EndIf

  ApplyTelemetryLatch(*reading, @gBlendTelemetryLatch)

  ProcedureReturn HasVisibleTelemetry(*reading)
EndProcedure

Procedure.s FindBundledWindowsEmiHelper()
  Protected path$

  path$ = GetPathPart(ProgramFilename()) + "PowerPilotWindowsEmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetCurrentDirectory() + "PowerPilotWindowsEmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetPathPart(GetPathPart(ProgramFilename())) + "PowerPilotWindowsEmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s FindBundledWindowsPerfHelper()
  Protected path$

  path$ = GetPathPart(ProgramFilename()) + "PowerPilotWindowsPerfHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetCurrentDirectory() + "PowerPilotWindowsPerfHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetPathPart(GetPathPart(ProgramFilename())) + "PowerPilotWindowsPerfHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s FindBundledWindowsPmiHelper()
  Protected path$

  path$ = GetPathPart(ProgramFilename()) + "PowerPilotWindowsPmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetCurrentDirectory() + "PowerPilotWindowsPmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetPathPart(GetPathPart(ProgramFilename())) + "PowerPilotWindowsPmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure StopWindowsPerfHelper()
  If gWindowsPerfHelperHandle
    CloseProgram(gWindowsPerfHelperHandle)
    gWindowsPerfHelperHandle = 0
  EndIf

  gWindowsPerfHelperIntervalMs = 0
  gWindowsPerfHelperInBlock = #False
  gWindowsPerfHelperCurrentBlock$ = ""
  gWindowsPerfHelperLatestBlock$ = ""
  gWindowsPerfHelperLatestTick = 0
EndProcedure

Procedure.i ParseWindowsPerfBlockTelemetry(*reading.TempReading, blockText$, staleSuffix$ = "")
  Protected normalized$ = ReplaceString(blockText$, #CR$, "")
  Protected lineCount.i
  Protected i.i
  Protected line$
  Protected kind$
  Protected sensor$
  Protected value$

  lineCount = CountString(normalized$, #LF$) + 1

  For i = 1 To lineCount
    line$ = Trim(StringField(normalized$, i, #LF$))
    If line$ = "" Or line$ = "WINDOWSPERFBEGIN" Or line$ = "WINDOWSPERFEND"
      Continue
    EndIf

    kind$ = StringField(line$, 1, "|")
    sensor$ = StringField(line$, 2, "|")
    value$ = StringField(line$, 3, "|")
    If staleSuffix$ <> "" And sensor$ <> ""
      sensor$ + " / " + staleSuffix$
    EndIf

    Select kind$
      Case "WINDOWSGPUMEM"
        *reading\gpuMemoryValid = #True
        *reading\gpuMemorySensor = sensor$
        *reading\gpuMemoryMb = ValD(value$)

      Case "WINDOWSGPUMEMSHARED"
        *reading\gpuSharedMemoryValid = #True
        *reading\gpuSharedMemorySensor = sensor$
        *reading\gpuSharedMemoryMb = ValD(value$)

      Case "WINDOWSGPUDEVICE"
        *reading\gpuDeviceNames = MergeLineLists(*reading\gpuDeviceNames, sensor$)
    EndSelect
  Next

  ProcedureReturn Bool(*reading\gpuMemoryValid Or *reading\gpuSharedMemoryValid Or *reading\gpuDeviceNames <> "")
EndProcedure

Procedure.i ReadWindowsPerfStartupSnapshotTelemetry(*reading.TempReading)
  Protected helper$
  Protected output$

  If gWindowsPerfStartupSnapshotRead = #False
    gWindowsPerfStartupSnapshotRead = #True
    helper$ = FindBundledWindowsPerfHelper()
    If helper$ <> ""
      output$ = RunCapture(helper$, "")
      If output$ <> ""
        gWindowsPerfStartupSnapshotBlock$ = output$
        gWindowsPerfStartupSnapshotTick = ElapsedMilliseconds()
      EndIf
    EndIf
  EndIf

  If gWindowsPerfStartupSnapshotBlock$ = ""
    ProcedureReturn #False
  EndIf

  ProcedureReturn ParseWindowsPerfBlockTelemetry(*reading, gWindowsPerfStartupSnapshotBlock$, "startup snapshot - stale, helper off")
EndProcedure

Procedure.i WindowsPerfHelperIntervalMs()
  ProcedureReturn #SlowGpuPerfHelperIntervalSeconds * 1000
EndProcedure

Procedure.i ShouldUseWindowsPerfHelper()
  Protected useWindows.i

  LockMutex(gStateMutex)
  useWindows = gSettings\UseWindows
  UnlockMutex(gStateMutex)

  ProcedureReturn Bool(useWindows)
EndProcedure

Procedure DrainWindowsPerfHelperOutput()
  Protected line$

  If gWindowsPerfHelperHandle = 0
    ProcedureReturn
  EndIf

  While AvailableProgramOutput(gWindowsPerfHelperHandle)
    line$ = Trim(ReadProgramString(gWindowsPerfHelperHandle))

    Select line$
      Case "WINDOWSPERFBEGIN"
        gWindowsPerfHelperInBlock = #True
        gWindowsPerfHelperCurrentBlock$ = ""

      Case "WINDOWSPERFEND"
        If gWindowsPerfHelperInBlock
          gWindowsPerfHelperLatestBlock$ = gWindowsPerfHelperCurrentBlock$
          gWindowsPerfHelperLatestTick = ElapsedMilliseconds()
        EndIf
        gWindowsPerfHelperInBlock = #False
        gWindowsPerfHelperCurrentBlock$ = ""

      Default
        If gWindowsPerfHelperInBlock
          gWindowsPerfHelperCurrentBlock$ + line$ + #LF$
        EndIf
    EndSelect
  Wend

  If ProgramRunning(gWindowsPerfHelperHandle) = #False
    CloseProgram(gWindowsPerfHelperHandle)
    gWindowsPerfHelperHandle = 0
    gWindowsPerfHelperInBlock = #False
    gWindowsPerfHelperCurrentBlock$ = ""
  EndIf
EndProcedure

Procedure.i EnsureWindowsPerfHelper()
  Protected helper$
  Protected desiredIntervalMs.i = WindowsPerfHelperIntervalMs()

  If gWindowsPerfHelperHandle
    DrainWindowsPerfHelperOutput()
    If gWindowsPerfHelperHandle And gWindowsPerfHelperIntervalMs = desiredIntervalMs
      ProcedureReturn #True
    EndIf

    CloseProgram(gWindowsPerfHelperHandle)
    gWindowsPerfHelperHandle = 0
    gWindowsPerfHelperInBlock = #False
    gWindowsPerfHelperCurrentBlock$ = ""
  EndIf

  helper$ = FindBundledWindowsPerfHelper()
  If helper$ = ""
    ProcedureReturn #False
  EndIf

  gWindowsPerfHelperHandle = RunProgram(helper$, "--stream --interval-ms " + Str(desiredIntervalMs) + " --parent-pid " + Str(GetCurrentProcessId_()), GetPathPart(helper$), #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If gWindowsPerfHelperHandle = 0
    ProcedureReturn #False
  EndIf

  gWindowsPerfHelperIntervalMs = desiredIntervalMs
  ProcedureReturn #True
EndProcedure

Procedure.i ReadWindowsPerfStreamTelemetry(*reading.TempReading)
  Protected freshnessMs.i
  Protected nowTick.q

  If ShouldUseWindowsPerfHelper() = #False
    StopWindowsPerfHelper()
    ProcedureReturn ReadWindowsPerfStartupSnapshotTelemetry(*reading)
  EndIf

  freshnessMs = ClampInt(WindowsPerfHelperIntervalMs() * 2, 12000, 130000)

  If EnsureWindowsPerfHelper()
    DrainWindowsPerfHelperOutput()
  EndIf

  nowTick = ElapsedMilliseconds()
  If gWindowsPerfHelperLatestTick = 0 Or nowTick - gWindowsPerfHelperLatestTick > freshnessMs
    ProcedureReturn ReadWindowsPerfStartupSnapshotTelemetry(*reading)
  EndIf

  ProcedureReturn ParseWindowsPerfBlockTelemetry(*reading, gWindowsPerfHelperLatestBlock$)
EndProcedure

Procedure.s DependencyLaunchLabel()
  ProcedureReturn "Refresh Status"
EndProcedure

Procedure.i LaunchPreferredDependencyApp()
  RefreshDependencyWindow()
  LogAction("Dependency status refreshed.")
  ProcedureReturn #True
EndProcedure

Procedure.i ReadWindowsPmiTelemetry(*reading.TempReading)
  Protected helper$
  Protected output$
  Protected normalized$
  Protected lineCount.i
  Protected i.i
  Protected line$
  Protected kind$
  Protected sensor$
  Protected value$

  helper$ = FindBundledWindowsPmiHelper()
  If helper$ = ""
    ProcedureReturn #False
  EndIf

  output$ = RunCapture(helper$, "")
  If output$ = ""
    ProcedureReturn #False
  EndIf

  normalized$ = ReplaceString(output$, #CR$, "")
  lineCount = CountString(normalized$, #LF$) + 1

  For i = 1 To lineCount
    line$ = Trim(StringField(normalized$, i, #LF$))
    If line$ = ""
      Continue
    EndIf

    kind$ = StringField(line$, 1, "|")
    sensor$ = StringField(line$, 2, "|")
    value$ = StringField(line$, 3, "|")

    Select kind$
      Case "WINDOWSCPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\cpuPackageValid = #True
          *reading\cpuPackageSensor = sensor$
          *reading\cpuPackageWatts = ValD(value$)
        EndIf

    EndSelect
  Next

  ProcedureReturn *reading\cpuPackageValid
EndProcedure

Procedure.i ReadWindowsEmiTelemetry(*reading.TempReading)
  Protected helper$
  Protected output$
  Protected normalized$
  Protected lineCount.i
  Protected i.i
  Protected line$
  Protected kind$
  Protected sensor$
  Protected value$

  helper$ = FindBundledWindowsEmiHelper()
  If helper$ = ""
    ProcedureReturn #False
  EndIf

  output$ = RunCapture(helper$, "")
  If output$ = ""
    ProcedureReturn #False
  EndIf

  normalized$ = ReplaceString(output$, #CR$, "")
  lineCount = CountString(normalized$, #LF$) + 1

  For i = 1 To lineCount
    line$ = Trim(StringField(normalized$, i, #LF$))
    If line$ = ""
      Continue
    EndIf

    kind$ = StringField(line$, 1, "|")
    sensor$ = StringField(line$, 2, "|")
    value$ = StringField(line$, 3, "|")

    Select kind$
      Case "WINDOWSCPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\cpuPackageValid = #True
          *reading\cpuPackageSensor = sensor$
          *reading\cpuPackageWatts = ValD(value$)
        EndIf

    EndSelect
  Next

  ProcedureReturn *reading\cpuPackageValid
EndProcedure

Procedure ReadDependencyStatus(*status.DependencyStatus)
  Protected useWindows.i
  Protected reading.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected settings.AppSettings

  LockMutex(gStateMutex)
  useWindows = gSettings\UseWindows
  UnlockMutex(gStateMutex)

  settings\UseWindows = useWindows

  ReadWindowsTelemetry(@windows)
  ApplyTelemetryLatch(@windows, @gWindowsTelemetryLatch)
  If windows\valid = #False And windows\windowsTempValid = #False
    ReadFallbackSensor(@fallback)
    ApplyTelemetryLatch(@fallback, @gFallbackTelemetryLatch)
  EndIf
  BuildDependencyStatusFromSnapshots(*status, @reading, @windows, @fallback, @settings)
EndProcedure

Procedure.s BuildDependencySummary()
  Protected status.DependencyStatus

  CopyCachedDependencyStatus(@status)

  If status\ManagedPlansReady = #False
    ProcedureReturn "Profiles are missing. Create PowerPilot profiles once before using Auto Control."
  EndIf

  If status\WindowsTelemetryReady
    ProcedureReturn "Live telemetry is working."
  EndIf

  If status\FallbackAvailable
    ProcedureReturn "Only ACPI fallback temperature is working."
  EndIf

  If status\WindowsEnabled And status\WindowsTelemetryReady = #False
    ProcedureReturn "Windows telemetry is enabled, but no usable readings are available."
  EndIf

  ProcedureReturn "No usable temperature or CPU-power reading is available."
EndProcedure

Procedure.s BuildDependencyInstructions()
  Protected status.DependencyStatus
  Protected text$

  CopyCachedDependencyStatus(@status)

  text$ + "Current Status" + #LF$
  text$ + "Windows telemetry enabled: " + YesNoText(status\WindowsEnabled) + #LF$
  text$ + "Any Windows reading available: " + YesNoText(status\WindowsTelemetryReady) + #LF$
  text$ + "Windows temperature available: " + YesNoText(status\WindowsTempReady) + #LF$
  text$ + "Windows CPU package power available: " + YesNoText(status\WindowsPowerReady) + #LF$
  text$ + "GPU name or VRAM display available: " + YesNoText(status\WindowsGpuReady) + #LF$
  text$ + "ACPI fallback temperature available: " + YesNoText(status\FallbackAvailable) + #LF$
  text$ + "PowerPilot plans installed: " + YesNoText(status\ManagedPlansReady) + #LF$
  If status\SensorReady
    text$ + "Reading used now: " + status\SensorSource + " / " + status\SensorName + #LF$
  Else
    text$ + "Reading used now: none" + #LF$
  EndIf

  text$ + #LF$
  text$ + "How Auto Control Works" + #LF$
  text$ + "PowerPilot reads Windows telemetry first." + #LF$
  text$ + "Profiles set Windows behavior only: Maximum, Balanced, Quiet, and Battery." + #LF$
  text$ + "Enabled power and temperature targets apply temporary CPU caps through a bounded PI-style controller." + #LF$
  text$ + "ADLX GPU controls are used only when AMD exposes real power or frequency tuning." + #LF$
  text$ + "Dashboard values use the average window from the Auto Tuning tab." + #LF$
  text$ + "On battery, PowerPilot can hold the Battery profile instead of running Auto Control." + #LF$
  text$ + "Battery note: set Windows Power mode to Balanced or Best performance. Best power efficiency can cap the system before PowerPilot gets the full control range." + #LF$

  text$ + #LF$
  text$ + "Reading Priority" + #LF$
  text$ + "1. CPU package power from Windows PMI, EMI, or energy counters." + #LF$
  text$ + "2. Temperature from Windows thermal-zone counters." + #LF$
  text$ + "3. GPU names and VRAM from the helper, for display only." + #LF$
  text$ + "4. Basic ACPI fallback temperature only when Windows temperature is missing." + #LF$
  If status\WindowsPowerReady
    text$ + "CPU package power is working right now." + #LF$
  EndIf

  text$ + #LF$
  text$ + "What To Do Next" + #LF$
  If status\WindowsTelemetryReady
    text$ + "- Telemetry is working. Auto Control can run." + #LF$
  Else
    text$ + "- Windows telemetry is not working. Auto Control can only use ACPI fallback temperature if it exists." + #LF$
  EndIf

  If status\WindowsPowerReady = #False
    text$ + "- CPU package power is missing. Power target control will wait until CPU power appears." + #LF$
  EndIf

  If status\WindowsEnabled And status\WindowsGpuReady = #False
    text$ + "- GPU names or VRAM are missing. Auto Control does not need them." + #LF$
  EndIf

  If status\FallbackAvailable And status\WindowsTelemetryReady = #False
    text$ + "- ACPI fallback temperature is available. It is less specific than Windows telemetry." + #LF$
  ElseIf status\FallbackAvailable = #False And status\WindowsTelemetryReady = #False
    text$ + "- No usable reading is available, so Auto Control will stay paused." + #LF$
  EndIf

  If status\ManagedPlansReady = #False
    text$ + "- Open Profiles and click Create Defaults to install the PowerPilot profiles." + #LF$
  Else
    text$ + "- The PowerPilot profiles are installed." + #LF$
  EndIf

  text$ + #LF$
  text$ + "Short Version" + #LF$
  text$ + "Use Windows telemetry. Profiles choose behavior. Auto Control uses independent power and temperature targets." + #LF$

  ProcedureReturn text$
EndProcedure

Procedure.s BuildMainStatusText(*reading.TempReading, autoEnabled.i)
  Protected status.DependencyStatus

  CopyCachedDependencyStatus(@status)

  If autoEnabled And status\ManagedPlansReady = #False
    ProcedureReturn "PowerPilot profiles are missing. Open Profiles and click Create Defaults."
  EndIf

  If HasControlTelemetry(*reading, @gSettings)
    If status\WindowsTelemetryReady
      If autoEnabled
        If gSettings\PowerTargetEnabled Or gSettings\TemperatureTargetEnabled
          ProcedureReturn "Auto Control is active. " + gDynamicControl\StatusText
        EndIf
        ProcedureReturn "Auto Control is on, but no target is enabled."
      EndIf

      ProcedureReturn "Telemetry is working. Auto Control is off."
    EndIf
    If Left(*reading\source, 4) = "ACPI" Or FindString(UCase(*reading\source), "FALLBACK", 1)
      If autoEnabled
      ProcedureReturn "ACPI fallback temperature is active. Temperature target control can run."
      EndIf
      ProcedureReturn "ACPI fallback temperature is active. Auto Control is off."
    EndIf

    If autoEnabled
      ProcedureReturn "Auto Control is on and waiting for enabled target telemetry."
    EndIf

    ProcedureReturn "Auto Control is off."
  EndIf

  If status\WindowsEnabled And status\WindowsTelemetryReady = #False
    If status\FallbackAvailable
      ProcedureReturn "Windows telemetry is missing. PowerPilot will use ACPI fallback temperature."
    EndIf
    ProcedureReturn "No usable telemetry yet. PowerPilot is waiting for readings."
  EndIf

  If autoEnabled
    ProcedureReturn "Auto Control is on."
  EndIf

  ProcedureReturn "Auto Control is off."
EndProcedure

Procedure.i DependencyAlertNeeded()
  Protected status.DependencyStatus

  CopyCachedDependencyStatus(@status)

  If status\ManagedPlansReady = #False
    ProcedureReturn #True
  EndIf

  If status\WindowsTelemetryReady
    ProcedureReturn #False
  EndIf

  If status\WindowsEnabled And status\WindowsTelemetryReady = #False
    ProcedureReturn #True
  EndIf

  ProcedureReturn Bool(status\SensorReady = #False)
EndProcedure

Procedure DrawHelpButton()
  Protected width.i
  Protected height.i
  Protected fillColor.i
  Protected outerBorder.i
  Protected topBorder.i
  Protected bottomBorder.i
  Protected textColor.i
  Protected label$ = "Help"
  Protected textX.i
  Protected textY.i

  If gLastHelpAlertState = gHelpAlertNeeded
    ProcedureReturn
  EndIf

  If IsGadget(#GadgetDependencies) = 0
    ProcedureReturn
  EndIf

  width = GadgetWidth(#GadgetDependencies)
  height = GadgetHeight(#GadgetDependencies)

  If gHelpAlertNeeded
    fillColor = RGB(220, 35, 35)
    outerBorder = RGB(110, 0, 0)
    topBorder = RGB(255, 150, 150)
    bottomBorder = RGB(110, 0, 0)
    textColor = RGB(255, 255, 255)
  Else
    fillColor = RGB(240, 240, 240)
    outerBorder = RGB(140, 140, 140)
    topBorder = RGB(255, 255, 255)
    bottomBorder = RGB(150, 150, 150)
    textColor = RGB(35, 35, 35)
  EndIf

  If StartDrawing(CanvasOutput(#GadgetDependencies))
    Box(0, 0, width, height, fillColor)
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, width, 1, outerBorder)
    Box(0, 0, 1, height, outerBorder)
    Box(width - 1, 0, 1, height, outerBorder)
    Box(0, height - 1, width, 1, outerBorder)
    Box(1, 1, width - 2, 1, topBorder)
    Box(1, 1, 1, height - 2, topBorder)
    Box(1, height - 2, width - 2, 1, bottomBorder)
    Box(width - 2, 1, 1, height - 2, bottomBorder)
    DrawingMode(#PB_2DDrawing_Transparent)
    textX = (width - TextWidth(label$)) / 2
    textY = (height - TextHeight(label$)) / 2
    DrawText(textX, textY, label$, textColor)
    StopDrawing()
  EndIf

  gLastHelpAlertState = gHelpAlertNeeded
EndProcedure

Procedure CopySettings(*settings.AppSettings)
  LockMutex(gStateMutex)
  *settings\AutoEnabled = gSettings\AutoEnabled
  *settings\UseWindows = gSettings\UseWindows
  *settings\AutoStartWithApp = gSettings\AutoStartWithApp
  *settings\KeepSettingsOnReinstall = gSettings\KeepSettingsOnReinstall
  *settings\AutoBatteryPlan = gSettings\AutoBatteryPlan
  *settings\AmdAdlxEnabled = gSettings\AmdAdlxEnabled
  *settings\PowerTargetEnabled = gSettings\PowerTargetEnabled
  *settings\TemperatureTargetEnabled = gSettings\TemperatureTargetEnabled
  *settings\PowerTargetWatts = gSettings\PowerTargetWatts
  *settings\TemperatureTargetC = gSettings\TemperatureTargetC
  *settings\ControlDeadband = gSettings\ControlDeadband
  *settings\MinCpuCapPercent = gSettings\MinCpuCapPercent
  *settings\MinCpuMHz = gSettings\MinCpuMHz
  *settings\MaxCpuMHz = gSettings\MaxCpuMHz
  *settings\PollSeconds = gSettings\PollSeconds
  *settings\Hysteresis = gSettings\Hysteresis
  *settings\AutoControlAverageSeconds = gSettings\AutoControlAverageSeconds
  *settings\LastPluggedPlan = gSettings\LastPluggedPlan
  *settings\CurrentManagedPlan = gSettings\CurrentManagedPlan
  UnlockMutex(gStateMutex)
EndProcedure

Procedure RememberPluggedPlan(planName$, persist.i = #False)
  Protected normalized$
  Protected changed.i

  If IsRememberedPluggedPlanName(planName$) = #False
    ProcedureReturn
  EndIf

  normalized$ = NormalizeRememberedPluggedPlan(planName$)

  LockMutex(gStateMutex)
  If gSettings\LastPluggedPlan <> normalized$
    gSettings\LastPluggedPlan = normalized$
    changed = #True
  EndIf
  UnlockMutex(gStateMutex)

  If changed And persist
    SaveSettings()
  EndIf
EndProcedure

Procedure.s GetCurrentManagedPlan()
  Protected plan$

  LockMutex(gStateMutex)
  plan$ = gSettings\CurrentManagedPlan
  UnlockMutex(gStateMutex)

  ProcedureReturn NormalizeManagedPlan(plan$)
EndProcedure

Procedure RememberCurrentManagedPlan(planName$, persist.i = #False)
  Protected normalized$
  Protected changed.i

  If IsSelectableManagedPlanName(planName$) = #False
    ProcedureReturn
  EndIf

  normalized$ = NormalizeManagedPlan(planName$)

  LockMutex(gStateMutex)
  If gSettings\CurrentManagedPlan <> normalized$
    gSettings\CurrentManagedPlan = normalized$
    changed = #True
  EndIf
  UnlockMutex(gStateMutex)

  If changed And persist
    SaveSettings()
  EndIf
EndProcedure

Procedure EnsureVisiblePlanActive(allowElevation.i = #False)
  Protected activePlan$ = GetActiveSchemeName()

  If activePlan$ = #PlanVisible$
    ActivatePlanByName(GetCurrentManagedPlan(), allowElevation)
  ElseIf IsSelectableManagedPlanName(activePlan$)
    RememberCurrentManagedPlan(activePlan$, #True)
  EndIf
EndProcedure

Procedure.i ManagedPlansExist()
  If GetSchemeGuidByName(#PlanVisible$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanBattery$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanPlugged$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanQuiet$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanFull$) = "" : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i CachedManagedPlansExist()
  Protected valid.i
  Protected value.i

  LockMutex(gStateMutex)
  valid = gManagedPlansExistCacheValid
  value = gManagedPlansExistCacheValue
  UnlockMutex(gStateMutex)

  If valid
    ProcedureReturn value
  EndIf

  value = ManagedPlansExist()
  LockMutex(gStateMutex)
  gManagedPlansExistCacheValue = value
  gManagedPlansExistCacheValid = #True
  UnlockMutex(gStateMutex)

  ProcedureReturn value
EndProcedure

Procedure.i SetStartupRegistry(enabled.i)
  Protected key$ = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
  Protected Data$ = Chr(34) + ProgramFilename() + Chr(34) + " /tray"
  Protected code$

  If enabled
    code$ = "$key = '" + ReplaceString(key$, "'", "''") + "'; " +
            "$value = '" + ReplaceString(Data$, "'", "''") + "'; " +
            "New-Item -Path $key -Force | Out-Null; " +
            "New-ItemProperty -Path $key -Name '" + ReplaceString(#AppRunKey$, "'", "''") + "' -PropertyType String -Value $value -Force | Out-Null; " +
            "exit 0"
  Else
    code$ = "$key = '" + ReplaceString(key$, "'", "''") + "'; " +
            "Remove-ItemProperty -Path $key -Name '" + ReplaceString(#AppRunKey$, "'", "''") + "' -ErrorAction SilentlyContinue; " +
            "exit 0"
  EndIf

  ProcedureReturn Bool(RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(code$)) = 0)
EndProcedure

Procedure.i CleanupSettingsData()
  Protected settingsDir$ = SettingsDirectory()

  SetStartupRegistry(#False)

  If FileSize(settingsDir$) = -2
    ProcedureReturn DeleteDirectory(settingsDir$, "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i DynamicCpuMhzForCap(capPercent.i, *settings.AppSettings)
  Protected percentRange.i
  Protected scaledPercent.d

  If capPercent >= 99
    ProcedureReturn 0
  EndIf

  If capPercent <= *settings\MinCpuCapPercent
    ProcedureReturn *settings\MinCpuMHz
  EndIf

  percentRange = 100 - *settings\MinCpuCapPercent
  If percentRange <= 0
    ProcedureReturn *settings\MinCpuMHz
  EndIf

  scaledPercent = (capPercent - *settings\MinCpuCapPercent) * 1.0 / percentRange
  ProcedureReturn ClampInt(*settings\MinCpuMHz + Int((*settings\MaxCpuMHz - *settings\MinCpuMHz) * scaledPercent), *settings\MinCpuMHz, *settings\MaxCpuMHz)
EndProcedure

Procedure.i ApplyDynamicCpuCap(activePlan$, capPercent.i, *settings.AppSettings)
  Protected schemeGuid$ = GetActiveSchemeGuid()
  Protected capMhz.i

  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf

  capPercent = ClampInt(capPercent, *settings\MinCpuCapPercent, 100)
  capMhz = DynamicCpuMhzForCap(capPercent, *settings)

  If capPercent >= 99
    If IsSelectableManagedPlanName(activePlan$)
      If ConfigureScheme(activePlan$, schemeGuid$) = #False
        ProcedureReturn #False
      EndIf
    Else
      If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", 100) <> 0 : ProcedureReturn #False : EndIf
      If SetFrequencyCaps(schemeGuid$, #True, 0) = #False : ProcedureReturn #False : EndIf
    EndIf
  Else
    If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", capPercent) <> 0 : ProcedureReturn #False : EndIf
    If TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", capPercent) = #False : ProcedureReturn #False : EndIf
    If TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", capPercent) = #False : ProcedureReturn #False : EndIf
    If SetFrequencyCaps(schemeGuid$, #True, capMhz) = #False : ProcedureReturn #False : EndIf
  EndIf

  gDynamicControl\CpuCapPercent = capPercent
  gDynamicControl\CpuCapMhz = capMhz
  gDynamicControl\Active = Bool(capPercent < 99)
  gDynamicControl\LastApplyTick = ElapsedMilliseconds()
  ProcedureReturn #True
EndProcedure

Procedure RestoreDynamicCpuCap(activePlan$, *settings.AppSettings)
  If gDynamicControl\Active Or gDynamicControl\CpuCapPercent > 0
    If ApplyDynamicCpuCap(activePlan$, 100, *settings)
      gDynamicControl\Integral = 0.0
      gDynamicControl\StatusText = "Controller relaxed; profile settings restored."
      LogAction("Temporary CPU cap restored to selected profile.")
    EndIf
  EndIf
EndProcedure

Procedure ApplyTargetController(*reading.TempReading, currentPlan$, *settings.AppSettings, announceKeep.i = #False)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected powerError.d = 0.0
  Protected tempError.d = 0.0
  Protected controlError.d = 0.0
  Protected requestedReduction.d
  Protected targetCap.i
  Protected currentCap.i
  Protected maxStepDown.i = 14
  Protected maxStepUp.i = 4
  Protected forcedDrop.i
  Protected targetSummary$
  Protected amdTargetW.i

  If *settings\PowerTargetEnabled = #False And *settings\TemperatureTargetEnabled = #False
    RestoreDynamicCpuCap(currentPlan$, *settings)
    gDynamicControl\StatusText = "No automatic targets enabled; selected profile is active."
    ProcedureReturn
  EndIf

  If *settings\PowerTargetEnabled
    If *reading\cpuPackageValid
      powerError = *reading\cpuPackageWatts - *settings\PowerTargetWatts
      If Abs(powerError) < *settings\ControlDeadband
        powerError = 0.0
      EndIf
      targetSummary$ = "power " + Str(*settings\PowerTargetWatts) + " W"
    Else
      targetSummary$ = "power target waiting for telemetry"
    EndIf
  EndIf

  If *settings\TemperatureTargetEnabled
    If *reading\valid
      tempError = (*reading\celsius - *settings\TemperatureTargetC) * 2.0
      If Abs(tempError) < *settings\Hysteresis
        tempError = 0.0
      EndIf
      If targetSummary$ <> "" : targetSummary$ + ", " : EndIf
      targetSummary$ + "temp " + Str(*settings\TemperatureTargetC) + " C"
    Else
      If targetSummary$ <> "" : targetSummary$ + ", " : EndIf
      targetSummary$ + "temp target waiting for telemetry"
    EndIf
  EndIf

  controlError = powerError
  If tempError > controlError
    controlError = tempError
  EndIf

  If controlError >= *settings\ControlDeadband * 5.0
    maxStepDown = 45
  ElseIf controlError >= *settings\ControlDeadband * 3.0
    maxStepDown = 34
  ElseIf controlError >= *settings\ControlDeadband * 2.0
    maxStepDown = 24
  EndIf

  If controlError <= 0.0
    gDynamicControl\Integral = ClampDouble(gDynamicControl\Integral + (controlError * 0.25), -45.0, 45.0)
  Else
    gDynamicControl\Integral = ClampDouble(gDynamicControl\Integral + controlError, -45.0, 45.0)
  EndIf

  requestedReduction = (controlError * 3.0) + (gDynamicControl\Integral * 0.35)
  requestedReduction = ClampDouble(requestedReduction, 0.0, 100.0 - *settings\MinCpuCapPercent)
  targetCap = ClampInt(100 - Int(requestedReduction), *settings\MinCpuCapPercent, 100)

  currentCap = gDynamicControl\CpuCapPercent
  If currentCap <= 0
    currentCap = 100
  EndIf

  If *settings\PowerTargetEnabled And powerError > 0.0
    If targetCap > currentCap
      targetCap = currentCap
    EndIf
    If powerError >= *settings\ControlDeadband * 2.0
      forcedDrop = ClampInt(Int(powerError * 3.0), 5, maxStepDown)
      If targetCap > currentCap - forcedDrop
        targetCap = currentCap - forcedDrop
      EndIf
    EndIf
  EndIf

  If targetCap < currentCap - maxStepDown
    targetCap = currentCap - maxStepDown
  ElseIf targetCap > currentCap + maxStepUp
    targetCap = currentCap + maxStepUp
  EndIf
  targetCap = ClampInt(targetCap, *settings\MinCpuCapPercent, 100)

  If nowTick - gDynamicControl\LastApplyTick >= #AutoControlApplyIntervalMs And Abs(targetCap - currentCap) >= 2
    If ApplyDynamicCpuCap(currentPlan$, targetCap, *settings)
      If targetCap < 99
        gDynamicControl\StatusText = "Limiting to CPU " + Str(targetCap) + "% / " + Str(gDynamicControl\CpuCapMhz) + " MHz for " + targetSummary$ + "."
        LogAction("Auto Control applied CPU cap " + Str(targetCap) + "% (" + Str(gDynamicControl\CpuCapMhz) + " MHz).")
        If *settings\AmdAdlxEnabled
          If *settings\PowerTargetEnabled
            amdTargetW = *settings\PowerTargetWatts
          ElseIf *reading\cpuPackageValid And controlError > 0.0
            amdTargetW = ClampInt(Int(*reading\cpuPackageWatts - controlError), 5, 80)
          EndIf
          If amdTargetW > 0
            ApplyAmdAdlxControl(*reading, amdTargetW, *settings)
          EndIf
        EndIf
      Else
        gDynamicControl\StatusText = "Controller relaxed; selected profile is active."
      EndIf
    EndIf
  Else
    If gDynamicControl\Active
      gDynamicControl\StatusText = "Holding CPU " + Str(gDynamicControl\CpuCapPercent) + "% / " + Str(gDynamicControl\CpuCapMhz) + " MHz for " + targetSummary$ + "."
    Else
      gDynamicControl\StatusText = "Selected profile active; targets are within deadband."
    EndIf
  EndIf

  If announceKeep
    LogAction(gDynamicControl\StatusText)
  EndIf
EndProcedure

Procedure UpdateRuntimeState(*reading.TempReading, powerSource.i, activePlan$)
  LockMutex(gStateMutex)
  CopyTempReading(@gState\LastTemp, *reading)
  gState\PowerSource = powerSource
  If activePlan$ <> ""
    gState\ActivePlan = activePlan$
  EndIf
  UnlockMutex(gStateMutex)
EndProcedure

Procedure UpdateRuntimeControlState(*reading.TempReading)
  LockMutex(gStateMutex)
  CopyTempReading(@gState\LastControl, *reading)
  UnlockMutex(gStateMutex)
EndProcedure

Procedure UpdateRuntimeSourceSnapshots(*windows.TempReading, *fallback.TempReading)
  LockMutex(gStateMutex)
  CopyTempReading(@gState\LastWindows, *windows)
  CopyTempReading(@gState\LastFallback, *fallback)
  UnlockMutex(gStateMutex)
EndProcedure

Procedure.i AutoControlStep(announceKeep.i = #False)
  Protected settings.AppSettings
  Protected reading.TempReading
  Protected displayReading.TempReading
  Protected controlReading.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected dependency.DependencyStatus
  Protected powerSource.i
  Protected previousPowerSource.i
  Protected currentPlan$
  Protected targetPlan$
  Protected autoWanted.i
  Protected pollSeconds.i
  Protected controlAverageMs.i
  Static warnedMissing.i
  Static warnedSensor.i

  CopySettings(@settings)
  pollSeconds = settings\PollSeconds
  powerSource = DetectPowerSource()

  LockMutex(gStateMutex)
  previousPowerSource = gState\PowerSource
  gState\PowerSource = powerSource
  UnlockMutex(gStateMutex)

  CaptureTelemetrySnapshot(@reading, @windows, @fallback)
  CopyTempReading(@displayReading, @reading)
  CopyTempReading(@controlReading, @reading)
  ApplyTelemetryAveraging(@displayReading, settings\AutoControlAverageSeconds * 1000, #True)
  controlAverageMs = settings\AutoControlAverageSeconds * 1000
  If controlAverageMs > #AutoControlResponseAverageMaxMs
    controlAverageMs = #AutoControlResponseAverageMaxMs
  EndIf
  ApplyTelemetryAveraging(@controlReading, controlAverageMs, #False)
  BuildDependencyStatusFromSnapshots(@dependency, @reading, @windows, @fallback, @settings)
  CacheDependencyStatus(@dependency)
  currentPlan$ = GetActiveSchemeName()

  If currentPlan$ = #PlanVisible$
    currentPlan$ = GetCurrentManagedPlan()
  EndIf

  If currentPlan$ = ""
    LockMutex(gStateMutex)
    currentPlan$ = gState\ActivePlan
    UnlockMutex(gStateMutex)
  EndIf

  LockMutex(gStateMutex)
  gState\AutoEnabled = settings\AutoEnabled
  UnlockMutex(gStateMutex)

  UpdateRuntimeState(@reading, powerSource, currentPlan$)
  UpdateRuntimeControlState(@displayReading)
  UpdateRuntimeSourceSnapshots(@windows, @fallback)
  MaintainAmdAdlxAutoProbe(@reading, #False)

  If settings\AutoBatteryPlan And powerSource = #PowerSourceBattery
    RestoreDynamicCpuCap(currentPlan$, @settings)
    warnedSensor = #False
    If currentPlan$ <> #PlanBattery$
      LogAction("Battery power detected. Switching to " + #PlanBattery$)
      ProcedureReturn ActivatePlanByName(#PlanBattery$)
    ElseIf announceKeep
      LogAction("Battery power detected. Keeping " + #PlanBattery$)
    EndIf
    ProcedureReturn #False
  EndIf

  autoWanted = settings\AutoEnabled

  If autoWanted = #False
    RestoreDynamicCpuCap(currentPlan$, @settings)
    ProcedureReturn #False
  EndIf

  If CachedManagedPlansExist() = #False
    If warnedMissing = #False
      LogAction("PowerPilot profiles are missing. Open Profiles and click Create Defaults.")
      warnedMissing = #True
    EndIf
    ProcedureReturn #False
  EndIf

  warnedMissing = #False

  Select powerSource
    Case #PowerSourceBattery
      warnedSensor = #False
      If currentPlan$ <> #PlanBattery$
        ProcedureReturn ActivatePlanByName(#PlanBattery$)
      ElseIf announceKeep
        LogAction("Battery power detected. Keeping " + #PlanBattery$)
      EndIf

    Case #PowerSourcePlugged
      If Date() < gManualOverrideUntil
        If announceKeep
          LogAction("Manual plan override is active. Keeping " + currentPlan$)
        EndIf
      EndIf

      If previousPowerSource = #PowerSourceBattery Or currentPlan$ = #PlanBattery$
        targetPlan$ = ResolveIdleRememberedPluggedPlan(@settings)
        If targetPlan$ <> "" And currentPlan$ <> targetPlan$
          LogAction("Plugged in power detected. Restoring " + targetPlan$)
          ProcedureReturn ActivatePlanByName(targetPlan$)
        EndIf
      EndIf

      If HasControlTelemetry(@controlReading, @settings) = #False
        If warnedSensor = #False
          ReadDependencyStatus(@dependency)
          If dependency\WindowsTelemetryReady = #False And dependency\FallbackAvailable = #False
            LogAction("No usable Windows or fallback reading is available.")
          Else
            LogAction("No usable temperature or CPU-power reading is available.")
          EndIf
          warnedSensor = #True
        EndIf
        RestoreDynamicCpuCap(currentPlan$, @settings)
        ProcedureReturn #False
      EndIf

      warnedSensor = #False
      ApplyTargetController(@controlReading, currentPlan$, @settings, announceKeep)

    Default
      If announceKeep
        LogAction("Power source is unknown. No plan change was made.")
      EndIf
      RestoreDynamicCpuCap(currentPlan$, @settings)
  EndSelect
  ProcedureReturn #False
EndProcedure

Procedure WorkerThread(*unused)
  Protected pollSeconds.i
  Protected stopThread.i
  Protected waitSteps.i
  Protected immediateRefresh.i
  Protected windowVisible.i

  LockMutex(gStateMutex)
  gState\WorkerRunning = #True
  gState\StopWorker = #False
  UnlockMutex(gStateMutex)

  Repeat
    AutoControlStep()

    LockMutex(gStateMutex)
    pollSeconds = gSettings\PollSeconds
    stopThread = gState\StopWorker
    UnlockMutex(gStateMutex)

    windowVisible = #False
    If IsWindow(#WindowMain)
      windowVisible = IsWindowVisible_(WindowID(#WindowMain))
    EndIf

    If stopThread
      Break
    EndIf

    pollSeconds = ClampInt(pollSeconds, 1, 60)
    If windowVisible And pollSeconds > 1
      pollSeconds = 1
    EndIf
    waitSteps = pollSeconds * 10
    While waitSteps > 0
      Delay(100)
      LockMutex(gStateMutex)
      stopThread = gState\StopWorker
      immediateRefresh = gState\ImmediateRefresh
      If immediateRefresh
        gState\ImmediateRefresh = #False
      EndIf
      UnlockMutex(gStateMutex)
      If stopThread
        Break
      EndIf
      If immediateRefresh
        Break
      EndIf
      waitSteps - 1
    Wend

  ForEver

  LockMutex(gStateMutex)
  gState\WorkerRunning = #False
  gWorkerThread = 0
  UnlockMutex(gStateMutex)
EndProcedure

Procedure StartWorkerThread()
  Protected alreadyRunning.i

  LockMutex(gStateMutex)
  alreadyRunning = gState\WorkerRunning
  gState\StopWorker = #False
  UnlockMutex(gStateMutex)

  If alreadyRunning = #False
    gWorkerThread = CreateThread(@WorkerThread(), 0)
    If gWorkerThread = 0
      LogAction("Failed to start the background worker thread.")
    Else
      AppendRuntimeLog("Background worker thread created.")
      LogAction("Background worker started.")
    EndIf
  EndIf
EndProcedure

Procedure StopWorkerThread()
  Protected worker.i

  LockMutex(gStateMutex)
  gState\StopWorker = #True
  worker = gWorkerThread
  UnlockMutex(gStateMutex)

  If worker
    WaitThread(worker)
  EndIf

  LockMutex(gStateMutex)
  gState\WorkerRunning = #False
  gWorkerThread = 0
  UnlockMutex(gStateMutex)
EndProcedure

Procedure FreeNativeTrayIcons()
  If gTrayIconSmall
    DestroyIcon_(gTrayIconSmall)
    gTrayIconSmall = 0
  EndIf

  If gTrayIconLarge
    DestroyIcon_(gTrayIconLarge)
    gTrayIconLarge = 0
  EndIf
EndProcedure

Procedure.i LoadNativeTrayIcons()
  Protected largeIcon.i
  Protected smallIcon.i
  Protected iconSource$

  FreeNativeTrayIcons()

  iconSource$ = SystemIconLibraryPath()
  If FileSize(iconSource$) > 0
    ExtractIconEx_(iconSource$, 101, @largeIcon, @smallIcon, 1)
  EndIf

  If smallIcon = 0
    iconSource$ = InstalledTrayIconPath()
    If FileSize(iconSource$) > 0
      ExtractIconEx_(iconSource$, 0, @largeIcon, @smallIcon, 1)
    EndIf
  EndIf

  If smallIcon = 0
    iconSource$ = InstalledIconPath()
    If FileSize(iconSource$) > 0
      ExtractIconEx_(iconSource$, 0, @largeIcon, @smallIcon, 1)
    EndIf
  EndIf

  gTrayIconSmall = smallIcon
  gTrayIconLarge = largeIcon

  ProcedureReturn Bool(gTrayIconSmall <> 0)
EndProcedure

Procedure ApplyWindowIcons()
  Protected windowHandle.i

  If IsWindow(#WindowMain) = 0
    ProcedureReturn
  EndIf

  If gTrayIconSmall = 0
    If LoadNativeTrayIcons() = #False
      ProcedureReturn
    EndIf
  EndIf

  windowHandle = WindowID(#WindowMain)
  If gTrayIconSmall
    SendMessage_(windowHandle, #WM_SETICON, 0, gTrayIconSmall)
  EndIf
  If gTrayIconLarge
    SendMessage_(windowHandle, #WM_SETICON, 1, gTrayIconLarge)
  ElseIf gTrayIconSmall
    SendMessage_(windowHandle, #WM_SETICON, 1, gTrayIconSmall)
  EndIf
EndProcedure

Procedure PrepareNativeTrayData()
  If IsWindow(#WindowMain) = 0
    ProcedureReturn
  EndIf

  FillMemory(@gTrayData, SizeOf(NOTIFYICONDATA), 0)
  gTrayData\cbSize = SizeOf(NOTIFYICONDATA)
  gTrayData\hWnd = WindowID(#WindowMain)
  gTrayData\uID = #TrayIconMain
  gTrayData\uFlags = #NIF_MESSAGE | #NIF_ICON | #NIF_TIP
  gTrayData\uCallbackMessage = #TrayCallbackMsg
  gTrayData\hIcon = gTrayIconSmall
  PokeS(@gTrayData\szTip[0], #TrayTooltip$, -1, #PB_Unicode)
EndProcedure

Procedure.i AddNativeTrayIcon()
  If IsWindow(#WindowMain) = 0
    ProcedureReturn #False
  EndIf

  If gTrayIconSmall = 0
    If LoadNativeTrayIcons() = #False
      AppendRuntimeLog("LoadNativeTrayIcons failed")
      ProcedureReturn #False
    EndIf
  EndIf

  PrepareNativeTrayData()
  If Shell_NotifyIcon_(#NIM_ADD, @gTrayData)
    gTrayReady = #True
    AppendRuntimeLog("Shell_NotifyIcon add ok")
    ProcedureReturn #True
  EndIf

  AppendRuntimeLog("Shell_NotifyIcon add failed")
  ProcedureReturn #False
EndProcedure

Procedure.i AddNativeTrayIconWithRetry(attempts.i, delayMs.i)
  Protected attempt.i

  If attempts < 1
    attempts = 1
  EndIf

  For attempt = 1 To attempts
    If AddNativeTrayIcon()
      ProcedureReturn #True
    EndIf

    If attempt < attempts And delayMs > 0
      Delay(delayMs)
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

Procedure RemoveNativeTrayIcon()
  If gTrayReady
    PrepareNativeTrayData()
    Shell_NotifyIcon_(#NIM_DELETE, @gTrayData)
    gTrayReady = #False
  EndIf
EndProcedure

Procedure SelectPlanComboByName(planName$)
  Protected i.i
  Protected count.i

  count = CountGadgetItems(#GadgetPlanCombo)
  For i = 0 To count - 1
    If GetGadgetItemText(#GadgetPlanCombo, i) = planName$
      UpdateGadgetStateIfNeeded(#GadgetPlanCombo, i)
      Break
    EndIf
  Next
EndProcedure

Procedure.s ValueWithSourceTag(valueText$, sourceText$)
  ProcedureReturn valueText$
EndProcedure

Procedure.s MergeLineLists(baseText$, extraText$)
  Protected merged$ = baseText$
  Protected cleaned$
  Protected lineCount.i
  Protected i.i
  Protected existing$

  cleaned$ = Trim(extraText$)
  If cleaned$ = ""
    ProcedureReturn merged$
  EndIf

  lineCount = CountString(cleaned$, #LF$) + 1
  For i = 1 To lineCount
    existing$ = Trim(StringField(cleaned$, i, #LF$))
    If existing$ = ""
      Continue
    EndIf

    If FindString(#LF$ + LCase(merged$) + #LF$, #LF$ + LCase(existing$) + #LF$, 1) = 0
      If merged$ <> ""
        merged$ + #LF$
      EndIf
      merged$ + existing$
    EndIf
  Next

ProcedureReturn merged$
EndProcedure

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

Procedure.s ResolveAmdGraphicsCuName(cuCount.i)
  If cuCount <= 0
    ProcedureReturn "AMD Radeon Graphics"
  EndIf

  ProcedureReturn "AMD Radeon Graphics (" + Str(cuCount) + " CUs)"
EndProcedure

Procedure.i IsGenericAmdIntegratedGpuName(hardwareName$)
  Protected lowered$ = LCase(Trim(hardwareName$))

  ProcedureReturn Bool(lowered$ = "amd radeon graphics" Or lowered$ = "radeon graphics" Or lowered$ = "amd radeon(tm) graphics" Or lowered$ = "radeon(tm) graphics")
EndProcedure

Procedure.s ResolveAmdIntegratedGpuName(cpuName$)
  Protected cpuMatchText$ = BuildCpuMatchText(cpuName$)

  If cpuMatchText$ = ""
    ProcedureReturn ""
  EndIf
  If FindString(cpuMatchText$, " amd ", 1) = 0
    ProcedureReturn ""
  EndIf

  ; Prefer AMD's published graphics model where the CPU family exposes one.
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

  ; When AMD only publishes a generic "Radeon Graphics" name, add CU count from the CPU SKU.
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

Procedure.s CpuInferredIntegratedGpuName()
  Protected gpuName$ = ResolveAmdIntegratedGpuName(CachedCpuName())

  If gpuName$ <> ""
    ProcedureReturn gpuName$ + " [iGPU]"
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s NormalizeGpuHardwareName(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected lowered$
  Protected splitPos.i
  Protected resolvedAmdName$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, #CR$, " ")
  cleaned$ = ReplaceString(cleaned$, #LF$, " ")
  splitPos = FindString(cleaned$, " / ", 1)
  If splitPos > 0
    cleaned$ = Trim(Left(cleaned$, splitPos - 1))
  EndIf

  lowered$ = LCase(cleaned$)
  If lowered$ = ""
    ProcedureReturn ""
  EndIf

  If Left(lowered$, 5) = "luid_"
    ProcedureReturn ""
  EndIf
  If FindString(lowered$, "engtype_", 1)
    ProcedureReturn ""
  EndIf
  If lowered$ = "gpu adapter memory" Or lowered$ = "gpu engine" Or lowered$ = "emi meter" Or lowered$ = "pmi meter"
    ProcedureReturn ""
  EndIf
  If lowered$ = "vddgfx power" Or lowered$ = "vddcr_gfx power" Or lowered$ = "vddcr_soc power" Or lowered$ = "gpu power" Or lowered$ = "apu power" Or lowered$ = "current socket power" Or lowered$ = "rapl_package0_pkg" Or lowered$ = "gpu" Or lowered$ = "gfx" Or lowered$ = "soc"
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, "(TM)", "")
  cleaned$ = ReplaceString(cleaned$, "(R)", "")
  cleaned$ = ReplaceString(cleaned$, "Microsoft Corporation ", "")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  If IsGenericAmdIntegratedGpuName(cleaned$)
    resolvedAmdName$ = ResolveAmdIntegratedGpuName(CachedCpuName())
    If resolvedAmdName$ <> ""
      cleaned$ = resolvedAmdName$
    EndIf
  EndIf

  ProcedureReturn cleaned$
EndProcedure

Procedure.s StripGpuRoleTags(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)

  cleaned$ = ReplaceString(cleaned$, "[iGPU]", "")
  cleaned$ = ReplaceString(cleaned$, "[dGPU]", "")
  cleaned$ = ReplaceString(cleaned$, "[eGPU]", "")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  ProcedureReturn Trim(cleaned$)
EndProcedure

Procedure.s CompactGpuHardwareName(hardwareName$, stripVendor.i = #False)
  Protected cleaned$ = NormalizeGpuHardwareName(StripGpuRoleTags(hardwareName$))
  Protected lowered$

  If cleaned$ = ""
    cleaned$ = StripGpuRoleTags(hardwareName$)
  EndIf

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  If stripVendor
    lowered$ = LCase(cleaned$)
    If Left(lowered$, 4) = "amd "
      cleaned$ = Mid(cleaned$, 5)
    ElseIf Left(lowered$, 7) = "nvidia "
      cleaned$ = Mid(cleaned$, 8)
    ElseIf Left(lowered$, 6) = "intel "
      cleaned$ = Mid(cleaned$, 7)
    EndIf
  EndIf

  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  ProcedureReturn Trim(cleaned$)
EndProcedure

Procedure.s ExtractHardwareNameFromSensor(sensorText$)
  Protected cleaned$ = Trim(sensorText$)
  Protected trimmed$
  Protected prefix$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  prefix$ = "Preferred GPU: "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows WMI performance / "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows PMI power reading / "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows power reading / EMI "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows power reading / "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i IsExternalGpuHardwareHint(text$)
  Protected lowered$ = LCase(Trim(text$))

  If lowered$ = ""
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(FindString(lowered$, "external", 1) Or FindString(lowered$, "egpu", 1) Or FindString(lowered$, "usb4", 1) Or FindString(lowered$, "usb 4", 1) Or FindString(lowered$, "thunderbolt", 1) Or FindString(lowered$, "tapex creek", 1) Or FindString(lowered$, "goshen ridge", 1) Or FindString(lowered$, "maple ridge", 1) Or FindString(lowered$, "oculink", 1) Or FindString(lowered$, "ocu link", 1) Or FindString(lowered$, "external pcie", 1) Or FindString(lowered$, "external pci express", 1) Or FindString(lowered$, "egfx", 1))
EndProcedure

Procedure.s AnnotateGpuHardwareName(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected lowered$
  Protected tag$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  lowered$ = LCase(cleaned$)

  If IsExternalGpuHardwareHint(lowered$)
    tag$ = "[eGPU]"
  ElseIf FindString(lowered$, "geforce", 1) Or FindString(lowered$, "nvidia", 1) Or FindString(lowered$, "radeon rx", 1) Or FindString(lowered$, " rx ", 1) Or FindString(lowered$, "arc ", 1)
    tag$ = "[dGPU]"
  ElseIf FindString(lowered$, "radeon graphics", 1) Or FindString(lowered$, "uhd", 1) Or FindString(lowered$, "iris", 1) Or FindString(lowered$, "xe graphics", 1) Or FindString(lowered$, "vega", 1) Or FindString(lowered$, "890m", 1) Or FindString(lowered$, "880m", 1) Or FindString(lowered$, "860m", 1) Or FindString(lowered$, "840m", 1) Or FindString(lowered$, "780m", 1) Or FindString(lowered$, "760m", 1) Or FindString(lowered$, "740m", 1) Or FindString(lowered$, "680m", 1) Or FindString(lowered$, "660m", 1) Or FindString(lowered$, "610m", 1) Or FindString(lowered$, "8060s", 1) Or FindString(lowered$, "8050s", 1) Or FindString(lowered$, "8040s", 1) Or FindString(lowered$, "integrated", 1) Or (FindString(lowered$, "intel", 1) And FindString(lowered$, "graphics", 1))
    tag$ = "[iGPU]"
  EndIf

  If tag$ <> ""
    ProcedureReturn cleaned$ + " " + tag$
  EndIf

  ProcedureReturn cleaned$
EndProcedure

Procedure.s GpuHardwareNamesFromReading(*reading.TempReading)
  Protected names$
  Protected hardware$
  Protected lineCount.i
  Protected i.i

  If *reading\gpuDeviceNames <> ""
    lineCount = CountString(*reading\gpuDeviceNames, #LF$) + 1
    For i = 1 To lineCount
      hardware$ = NormalizeGpuHardwareName(StringField(*reading\gpuDeviceNames, i, #LF$))
      If hardware$ <> ""
        names$ = MergeLineLists(names$, AnnotateGpuHardwareName(hardware$))
      EndIf
    Next
  EndIf

  hardware$ = ExtractHardwareNameFromSensor(*reading\gpuMemorySensor)
  If hardware$ <> ""
    names$ = MergeLineLists(names$, AnnotateGpuHardwareName(hardware$))
  EndIf

  ProcedureReturn names$
EndProcedure

Procedure.s CombinedGpuDeviceList(*reading.TempReading, *windows.TempReading)
  Protected names$

  names$ = MergeLineLists(names$, GpuHardwareNamesFromReading(*windows))
  names$ = MergeLineLists(names$, GpuHardwareNamesFromReading(*reading))

  ProcedureReturn names$
EndProcedure

Procedure.s SingleGpuHardwareFromList(deviceList$)
  Protected cleaned$ = Trim(deviceList$)
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected single$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  lineCount = CountString(cleaned$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(cleaned$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    If single$ = ""
      single$ = value$
    Else
      ProcedureReturn ""
    EndIf
  Next

  ProcedureReturn single$
EndProcedure

Procedure.s GpuRoleLabel(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected lowered$ = LCase(cleaned$)

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  If FindString(cleaned$, "[eGPU]", 1) Or IsExternalGpuHardwareHint(lowered$)
    ProcedureReturn "eGPU"
  EndIf
  If FindString(cleaned$, "[dGPU]", 1)
    ProcedureReturn "dGPU"
  EndIf
  If FindString(cleaned$, "[iGPU]", 1)
    ProcedureReturn "iGPU"
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s CompactGpuSourceDisplay(*reading.TempReading)
  Protected names$ = GpuHardwareNamesFromReading(*reading)
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected role$
  Protected roles$
  Protected fallbackCount.i

  If names$ = ""
    ProcedureReturn ""
  EndIf

  lineCount = CountString(names$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(names$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    role$ = GpuRoleLabel(value$)
    If role$ <> ""
      roles$ = MergeLineLists(roles$, role$)
    Else
      fallbackCount + 1
    EndIf
  Next

  If roles$ <> ""
    roles$ = ReplaceString(roles$, #LF$, " + ")
    ProcedureReturn roles$
  EndIf

  If fallbackCount = 1
    ProcedureReturn "GPU"
  ElseIf fallbackCount > 1
    ProcedureReturn Str(fallbackCount) + " GPUs"
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s ShortGpuSuffix(sensorText$, deviceList$)
  Protected hardware$
  Protected role$

  hardware$ = ExtractHardwareNameFromSensor(sensorText$)
  If hardware$ <> ""
    role$ = GpuRoleLabel(AnnotateGpuHardwareName(hardware$))
    If role$ <> ""
      ProcedureReturn role$
    EndIf
  EndIf

  hardware$ = SingleGpuHardwareFromList(deviceList$)
  If hardware$ <> ""
    role$ = GpuRoleLabel(hardware$)
    If role$ <> ""
      ProcedureReturn role$
    EndIf
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i IsSharedGpuMemorySensor(sensorText$)
  ProcedureReturn Bool(FindString(UCase(sensorText$), "SHARED USAGE", 1) > 0)
EndProcedure

Procedure.i IsDedicatedGpuMemorySensor(sensorText$)
  ProcedureReturn Bool(FindString(UCase(sensorText$), "DEDICATED USAGE", 1) > 0)
EndProcedure

Procedure.i PreferSharedGpuMemoryDisplay(*reading.TempReading, deviceList$)
  Protected suffix$

  If *reading\gpuSharedMemoryValid = #False
    ProcedureReturn #False
  EndIf

  suffix$ = ShortGpuSuffix(*reading\gpuSharedMemorySensor, deviceList$)
  If suffix$ = ""
    suffix$ = ShortGpuSuffix(*reading\gpuMemorySensor, deviceList$)
  EndIf

  ProcedureReturn Bool(suffix$ = "iGPU")
EndProcedure

Procedure.s DisplayGpuMemoryValue(*reading.TempReading, deviceList$)
  Protected sharedSuffix$
  Protected primarySuffix$
  Protected sharedMb.d
  Protected dedicatedMb.d
  Protected totalMb.d
  Protected tagSensor$

  sharedSuffix$ = ShortGpuSuffix(*reading\gpuSharedMemorySensor, deviceList$)
  primarySuffix$ = ShortGpuSuffix(*reading\gpuMemorySensor, deviceList$)

  If *reading\gpuSharedMemoryValid And sharedSuffix$ = "iGPU"
    sharedMb = *reading\gpuSharedMemoryMb
    tagSensor$ = *reading\gpuSharedMemorySensor
  EndIf

  If *reading\gpuMemoryValid And primarySuffix$ = "iGPU"
    If IsSharedGpuMemorySensor(*reading\gpuMemorySensor)
      If sharedMb = 0.0
        sharedMb = *reading\gpuMemoryMb
        If tagSensor$ = ""
          tagSensor$ = *reading\gpuMemorySensor
        EndIf
      EndIf
    Else
      dedicatedMb = *reading\gpuMemoryMb
      If tagSensor$ = ""
        tagSensor$ = *reading\gpuMemorySensor
      EndIf
    EndIf
  EndIf

  totalMb = dedicatedMb + sharedMb
  If totalMb > 0.0
    If tagSensor$ <> ""
      ProcedureReturn ValueWithSourceTag(StrD(totalMb, 0) + " MB", tagSensor$)
    EndIf
    ProcedureReturn StrD(totalMb, 0) + " MB"
  EndIf

  If PreferSharedGpuMemoryDisplay(*reading, deviceList$)
    ProcedureReturn FormatGpuTelemetryValue(#True, StrD(*reading\gpuSharedMemoryMb, 0) + " MB", *reading\gpuSharedMemorySensor, deviceList$)
  EndIf

  If *reading\gpuMemoryValid
    ProcedureReturn FormatGpuTelemetryValue(#True, StrD(*reading\gpuMemoryMb, 0) + " MB", *reading\gpuMemorySensor, deviceList$)
  EndIf

  If *reading\gpuSharedMemoryValid
    ProcedureReturn FormatGpuTelemetryValue(#True, StrD(*reading\gpuSharedMemoryMb, 0) + " MB", *reading\gpuSharedMemorySensor, deviceList$)
  EndIf

  ProcedureReturn "Unavailable"
EndProcedure

Procedure.s BuildTelemetrySourceDisplay(*reading.TempReading)
  Protected display$ = *reading\source
  Protected gpuHardware$
  Protected primary$

  gpuHardware$ = CompactGpuSourceDisplay(*reading)

  primary$ = UCase(*reading\source)
  If FindString(primary$, "WINDOWS", 1)
    display$ = "Windows telemetry"
  ElseIf FindString(primary$, "ACPI", 1)
    display$ = "Fallback temperature"
  ElseIf FindString(primary$, "FALLBACK", 1)
    display$ = "Fallback temperature"
  ElseIf *reading\source = ""
    display$ = ""
  EndIf

  If gpuHardware$ <> ""
    If display$ = "Windows telemetry"
      display$ + ", " + gpuHardware$
    ElseIf display$ = ""
      display$ = gpuHardware$
    Else
      display$ + " / " + gpuHardware$
    EndIf
  EndIf

  If display$ = ""
    display$ = "Unavailable"
  EndIf

  ProcedureReturn display$
EndProcedure

Procedure.s FormatTelemetryValue(valid.i, valueText$, sensorText$, includeHardware.i = #False)
  Protected hardware$

  If valid = #False
    ProcedureReturn "Unavailable"
  EndIf

  If sensorText$ <> ""
    hardware$ = ExtractHardwareNameFromSensor(sensorText$)
    If includeHardware And hardware$ <> ""
      ProcedureReturn ValueWithSourceTag(valueText$, sensorText$) + " on " + AnnotateGpuHardwareName(hardware$)
    EndIf
    ProcedureReturn ValueWithSourceTag(valueText$, sensorText$)
  EndIf

  ProcedureReturn valueText$
EndProcedure

Procedure.s FormatGpuTelemetryValue(valid.i, valueText$, sensorText$, deviceList$)
  If valid = #False
    ProcedureReturn "Unavailable"
  EndIf

  ProcedureReturn valueText$
EndProcedure

Procedure.s CurrentGpuHardwareDisplay(*reading.TempReading)
  Protected names$ = GpuHardwareNamesFromReading(*reading)
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected display$

  If names$ = ""
    ProcedureReturn CpuInferredIntegratedGpuName()
  EndIf

  lineCount = CountString(names$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(names$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    If display$ <> ""
      display$ + ", "
    EndIf
    display$ + value$
  Next

  ProcedureReturn display$
EndProcedure

Procedure.s BuildGpuDeviceSummary(*reading.TempReading, *windows.TempReading)
  Protected names$
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected text$

  names$ = CombinedGpuDeviceList(*reading, *windows)

  If names$ = ""
    value$ = CpuInferredIntegratedGpuName()
    If value$ <> ""
      ProcedureReturn "iGPU: " + CompactGpuHardwareName(value$, #False)
    EndIf
    ProcedureReturn "GPU names appear here when Windows exposes them."
  EndIf

  lineCount = CountString(names$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(names$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    If text$ <> ""
      text$ + #LF$
    EndIf

    If FindString(value$, "[eGPU]", 1)
      text$ + "eGPU: " + CompactGpuHardwareName(value$, #False)
    ElseIf FindString(value$, "[iGPU]", 1)
      text$ + "iGPU: " + CompactGpuHardwareName(value$, #False)
    ElseIf FindString(value$, "[dGPU]", 1)
      text$ + "dGPU: " + CompactGpuHardwareName(value$, #False)
    Else
      text$ + "GPU: " + CompactGpuHardwareName(value$, #False)
    EndIf
  Next

  ProcedureReturn text$
EndProcedure

Procedure.s ReadRegistryString(rootKey.i, subKey$, valueName$)
  Protected keyHandle.i
  Protected result.i
  Protected valueType.l
  Protected dataSize.l
  Protected *buffer
  Protected value$

  result = RegOpenKeyEx_(rootKey, subKey$, 0, #KEY_READ, @keyHandle)
  If result <> 0
    ProcedureReturn ""
  EndIf

  result = RegQueryValueEx_(keyHandle, valueName$, 0, @valueType, 0, @dataSize)
  If result = 0 And dataSize > 1 And (valueType = #REG_SZ Or valueType = #REG_EXPAND_SZ)
    *buffer = AllocateMemory(dataSize + 2)
    If *buffer
      FillMemory(*buffer, dataSize + 2, 0)
      If RegQueryValueEx_(keyHandle, valueName$, 0, @valueType, *buffer, @dataSize) = 0
        value$ = PeekS(*buffer, -1, #PB_Unicode)
      EndIf
      FreeMemory(*buffer)
    EndIf
  EndIf

  RegCloseKey_(keyHandle)
  ProcedureReturn Trim(value$)
EndProcedure

Procedure.s NormalizeCpuName(cpuName$)
  Protected cleaned$ = Trim(cpuName$)
  Protected lowered$
  Protected splitPos.i

  cleaned$ = ReplaceString(cleaned$, "(TM)", "")
  cleaned$ = ReplaceString(cleaned$, "(R)", "")
  lowered$ = LCase(cleaned$)
  splitPos = FindString(lowered$, " with ", 1)
  If splitPos > 0 And FindString(lowered$, "graphics", splitPos + 6)
    cleaned$ = Trim(Left(cleaned$, splitPos - 1))
  EndIf

  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  ProcedureReturn Trim(cleaned$)
EndProcedure

Procedure.s CachedCpuName()
  If gCachedCpuName$ = ""
    gCachedCpuName$ = NormalizeCpuName(ReadRegistryString(#HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString"))
  EndIf

  ProcedureReturn gCachedCpuName$
EndProcedure

Procedure.i QueryMemoryStatus(*memory.MEMORYSTATUSEX)
  FillMemory(*memory, SizeOf(MEMORYSTATUSEX), 0)
  *memory\dwLength = SizeOf(MEMORYSTATUSEX)
  ProcedureReturn GlobalMemoryStatusEx_(*memory)
EndProcedure

Procedure.q InstalledSystemMemoryBytes()
  Protected output$
  Protected memory.MEMORYSTATUSEX

  If gInstalledMemoryBytes <= 0
    output$ = RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument("(Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum"))
    If Trim(output$) <> ""
      gInstalledMemoryBytes = Int(ValD(Trim(output$)))
    EndIf

    If gInstalledMemoryBytes <= 0 And QueryMemoryStatus(@memory)
      gInstalledMemoryBytes = memory\ullTotalPhys
    EndIf
  EndIf

  ProcedureReturn gInstalledMemoryBytes
EndProcedure

Procedure.s FormatBytesAsGb(bytes.q)
  If bytes <= 0
    ProcedureReturn "Unavailable"
  EndIf

  ProcedureReturn StrD(bytes / (1024.0 * 1024.0 * 1024.0), 1) + " GB"
EndProcedure

Procedure.s FormatMegabytesCompact(valueMb.d)
  If valueMb <= 0.0
    ProcedureReturn "0 MB"
  EndIf

  If valueMb >= 1024.0
    ProcedureReturn StrD(valueMb / 1024.0, 1) + " GB"
  EndIf

  ProcedureReturn StrD(valueMb, 0) + " MB"
EndProcedure

Procedure.s BuildOverviewHardwareDetails(*reading.TempReading, *windows.TempReading)
  Protected text$
  Protected cpu$
  Protected gpu$
  Protected installedBytes.q
  Protected memory.MEMORYSTATUSEX
  Protected visibleBytes.q
  Protected usedBytes.q
  Protected sharedMb.d
  Protected dedicatedMb.d
  Protected totalMb.d
  Protected sharedValid.i
  Protected dedicatedValid.i
  Protected sharedSensor$
  Protected dedicatedSensor$
  Protected sharedLabel$
  Protected memoryLabel$
  Protected deviceList$

  cpu$ = CachedCpuName()
  If cpu$ = ""
    cpu$ = "Unavailable"
  EndIf

  text$ = "CPU: " + cpu$

  gpu$ = BuildGpuDeviceSummary(*reading, *windows)
  If gpu$ = "GPU names appear here when Windows exposes them."
    text$ + #LF$ + "GPU: Waiting for Windows"
  Else
    text$ + #LF$ + gpu$
  EndIf

  If QueryMemoryStatus(@memory)
    visibleBytes = memory\ullTotalPhys
    usedBytes = memory\ullTotalPhys - memory\ullAvailPhys
    text$ + #LF$ + "RAM: " + FormatBytesAsGb(usedBytes) + " used / " + FormatBytesAsGb(visibleBytes)
  Else
    text$ + #LF$ + "RAM: Unavailable"
  EndIf

  installedBytes = InstalledSystemMemoryBytes()
  If installedBytes > 0
    text$ + #LF$ + "Installed RAM: " + FormatBytesAsGb(installedBytes)
  EndIf

  deviceList$ = CombinedGpuDeviceList(*reading, *windows)

  If *windows\gpuMemoryValid
    dedicatedValid = #True
    dedicatedMb = *windows\gpuMemoryMb
    dedicatedSensor$ = *windows\gpuMemorySensor
  ElseIf *reading\gpuMemoryValid
    dedicatedValid = #True
    dedicatedMb = *reading\gpuMemoryMb
    dedicatedSensor$ = *reading\gpuMemorySensor
  EndIf

  If *windows\gpuSharedMemoryValid
    sharedValid = #True
    sharedMb = *windows\gpuSharedMemoryMb
    sharedSensor$ = *windows\gpuSharedMemorySensor
  ElseIf *reading\gpuSharedMemoryValid
    sharedValid = #True
    sharedMb = *reading\gpuSharedMemoryMb
    sharedSensor$ = *reading\gpuSharedMemorySensor
  EndIf

  memoryLabel$ = ShortGpuSuffix(sharedSensor$, deviceList$)
  If memoryLabel$ = ""
    memoryLabel$ = ShortGpuSuffix(dedicatedSensor$, deviceList$)
  EndIf

  If memoryLabel$ = "iGPU"
    If dedicatedValid And IsSharedGpuMemorySensor(dedicatedSensor$) = #False
      totalMb + dedicatedMb
    EndIf
    If sharedValid
      totalMb + sharedMb
    EndIf

    If totalMb > 0.0
      text$ + #LF$ + "iGPU memory: " + FormatMegabytesCompact(totalMb) + " total"
      If dedicatedValid And IsDedicatedGpuMemorySensor(dedicatedSensor$)
        text$ + " (" + FormatMegabytesCompact(dedicatedMb) + " reserved"
        If sharedValid
          text$ + " + " + FormatMegabytesCompact(sharedMb) + " shared"
        EndIf
        text$ + ")"
      ElseIf sharedValid
        text$ + " (" + FormatMegabytesCompact(sharedMb) + " shared)"
      ElseIf dedicatedValid
        text$ + " (" + FormatMegabytesCompact(dedicatedMb) + " primary)"
      EndIf
    EndIf
  ElseIf sharedValid
    sharedLabel$ = ShortGpuSuffix(sharedSensor$, deviceList$)
    If sharedLabel$ <> ""
      text$ + #LF$ + sharedLabel$ + " shared RAM: " + FormatMegabytesCompact(sharedMb) + " in use"
    Else
      text$ + #LF$ + "GPU shared RAM: " + FormatMegabytesCompact(sharedMb) + " in use"
    EndIf
  Else
    text$ + #LF$ + "GPU shared RAM: Not exposed"
  EndIf

  ProcedureReturn text$
EndProcedure

Procedure.i ActiveDiscreteGpuConnected(*reading.TempReading)
  Protected hardware$ = CurrentGpuHardwareDisplay(*reading)

  If FindString(hardware$, "[eGPU]", 1) Or FindString(hardware$, "[dGPU]", 1)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s SecondaryFallbackSummary(*reading.TempReading, *windows.TempReading, *fallback.TempReading, *settings.AppSettings)
  If *fallback\valid
  ProcedureReturn "ACPI fallback temperature" + #LF$ + FormatTelemetryValue(#True, StrD(*fallback\celsius, 1) + " C", *fallback\sensor)
  EndIf

  If *windows\valid Or *windows\cpuPackageValid Or *windows\gpuMemoryValid Or *windows\gpuSharedMemoryValid Or *windows\gpuDeviceNames <> ""
    ProcedureReturn "No ACPI fallback temperature is active."
  EndIf

  ProcedureReturn "No ACPI fallback temperature is active."
EndProcedure

Procedure RefreshStatusDisplay()
  Protected reading.TempReading
  Protected averaged.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected powerSource.i
  Protected activePlan$
  Protected autoEnabled.i
  Protected averageSeconds.i
  Protected logText$
  Protected status.DependencyStatus
  Protected tempText$
  Protected cpuPowerText$
  Protected gpuMemoryText$
  Protected controlStateText$
  Protected telemetrySourceText$
  Protected blendGpuDevices$
  Protected liveGpuDevicesText$
  Protected overviewHardwareText$

  LockMutex(gStateMutex)
  CopyTempReading(@reading, @gState\LastTemp)
  CopyTempReading(@averaged, @gState\LastControl)
  CopyTempReading(@windows, @gState\LastWindows)
  CopyTempReading(@fallback, @gState\LastFallback)
  powerSource = gState\PowerSource
  activePlan$ = gState\ActivePlan
  autoEnabled = gState\AutoEnabled
  averageSeconds = gSettings\AutoControlAverageSeconds
  logText$ = BuildUiLogText()
  UnlockMutex(gStateMutex)
  CopyCachedDependencyStatus(@status)

  If HasUsableTelemetry(@averaged)
    CopyTempReading(@reading, @averaged)
  EndIf

  If reading\valid
    tempText$ = ValueWithSourceTag(StrD(reading\celsius, 1) + " C", reading\source)
  Else
    tempText$ = "Unavailable"
  EndIf

  If reading\cpuPackageValid
    cpuPowerText$ = ValueWithSourceTag(StrD(reading\cpuPackageWatts, 1) + " W", reading\cpuPackageSensor)
  ElseIf status\WindowsTelemetryReady And status\WindowsPowerReady = #False
    cpuPowerText$ = "Windows not exposed"
  Else
    cpuPowerText$ = "Unavailable"
  EndIf

  blendGpuDevices$ = CombinedGpuDeviceList(@reading, @windows)

  gpuMemoryText$ = DisplayGpuMemoryValue(@reading, blendGpuDevices$)

  controlStateText$ = BuildControlStateText(@reading, @gSettings)
  If activePlan$ = "" : activePlan$ = "Unknown" : EndIf
  telemetrySourceText$ = BuildTelemetrySourceDisplay(@reading)
  If averageSeconds > 0 And HasUsableTelemetry(@averaged)
    telemetrySourceText$ + ", " + Str(averageSeconds) + " sec average"
  EndIf

  UpdateTextGadgetIfNeeded(#GadgetOverviewSourceValue, telemetrySourceText$)
  If reading\sensor <> ""
    UpdateTextGadgetIfNeeded(#GadgetOverviewTempSensorValue, reading\sensor)
  Else
    UpdateTextGadgetIfNeeded(#GadgetOverviewTempSensorValue, "Unavailable")
  EndIf
  UpdateTextGadgetIfNeeded(#GadgetOverviewTempValue, tempText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewCpuPowerValue, cpuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewGpuMemoryValue, gpuMemoryText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewPowerValue, PowerSourceText(powerSource))
  UpdateTextGadgetIfNeeded(#GadgetOverviewPlanValue, activePlan$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewControlStateValue, controlStateText$)
  overviewHardwareText$ = BuildOverviewHardwareDetails(@reading, @windows)
  UpdateTextGadgetIfNeeded(#GadgetOverviewHardwareDetails, overviewHardwareText$)

  liveGpuDevicesText$ = BuildGpuDeviceSummary(@reading, @windows)

  UpdateTextGadgetIfNeeded(#GadgetLiveBlendSourceMix, telemetrySourceText$)
  If reading\sensor <> ""
    UpdateTextGadgetIfNeeded(#GadgetLiveBlendTempSensor, reading\sensor)
  Else
    UpdateTextGadgetIfNeeded(#GadgetLiveBlendTempSensor, "Unavailable")
  EndIf
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendTemp, tempText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendCpu, cpuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendGpuMemory, gpuMemoryText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendPowerSource, PowerSourceText(powerSource))
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendActivePlan, activePlan$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendControlState, controlStateText$)

  UpdateTextGadgetIfNeeded(#GadgetLiveFallbackStatus, liveGpuDevicesText$)

  If IsGadget(#GadgetAmdAdlxStatus)
    If gAmdAdlx\Probed = #False
      UpdateTextGadgetIfNeeded(#GadgetAmdAdlxStatus, "Checking...")
    Else
      UpdateTextGadgetIfNeeded(#GadgetAmdAdlxStatus, gAmdAdlx\StatusText)
    EndIf
  If gAmdAdlx\GpuName <> ""
      UpdateTextGadgetIfNeeded(#GadgetAmdAdlxGpuName, PreferResolvedAmdGpuName(gAmdAdlx\GpuName, blendGpuDevices$))
    Else
      UpdateTextGadgetIfNeeded(#GadgetAmdAdlxGpuName, "Unavailable")
    EndIf
    UpdateTextGadgetIfNeeded(#GadgetAmdAdlxFeatures, gAmdAdlx\FeatureText)
    If gAmdAdlx\MetricsText <> ""
      UpdateTextGadgetIfNeeded(#GadgetAmdAdlxMetrics, gAmdAdlx\MetricsText)
    Else
      UpdateTextGadgetIfNeeded(#GadgetAmdAdlxMetrics, "Unavailable")
    EndIf
  EndIf

  If IsGadget(#GadgetControllerStatus)
    If gDynamicControl\StatusText <> ""
      UpdateTextGadgetIfNeeded(#GadgetControllerStatus, gDynamicControl\StatusText)
    Else
      UpdateTextGadgetIfNeeded(#GadgetControllerStatus, "Waiting for telemetry.")
    EndIf
  EndIf

  If gLastUiLogText$ <> logText$
    SetEditorText(#GadgetActionValue, logText$)
    gLastUiLogText$ = logText$
  EndIf
  gHelpAlertNeeded = DependencyAlertNeeded()
  DrawHelpButton()
  logText$ = BuildMainStatusText(@reading, autoEnabled)
  If gLastStatusText$ <> logText$
    UpdateTextGadgetIfNeeded(#GadgetStatusLine, logText$)
    gLastStatusText$ = logText$
  EndIf
EndProcedure

Procedure RefreshRuntimeSnapshot()
  Protected reading.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected dependency.DependencyStatus
  Protected settings.AppSettings
  Protected powerSource.i
  Protected activePlan$

  CopySettings(@settings)
  CaptureTelemetrySnapshot(@reading, @windows, @fallback)
  powerSource = DetectPowerSource()
  activePlan$ = GetActiveSchemeName()
  BuildDependencyStatusFromSnapshots(@dependency, @reading, @windows, @fallback, @settings)
  CacheDependencyStatus(@dependency)

  If activePlan$ = #PlanVisible$
    activePlan$ = GetCurrentManagedPlan()
  EndIf

  If activePlan$ = ""
    LockMutex(gStateMutex)
    activePlan$ = gState\ActivePlan
    UnlockMutex(gStateMutex)
  EndIf

  UpdateRuntimeState(@reading, powerSource, activePlan$)
  UpdateRuntimeSourceSnapshots(@windows, @fallback)
  MaintainAmdAdlxAutoProbe(@reading, #False)

  LockMutex(gStateMutex)
  gState\AutoEnabled = gSettings\AutoEnabled
  UnlockMutex(gStateMutex)
EndProcedure

Procedure UpdateUiRefreshTimer()
  If IsWindow(#WindowMain)
    RemoveWindowTimer(#WindowMain, #TimerUiRefresh)
    AddWindowTimer(#WindowMain, #TimerUiRefresh, #UiRefreshMs)
  EndIf
EndProcedure

Procedure RequestImmediateTelemetryRefresh()
  LockMutex(gStateMutex)
  gState\LastTemp\valid = #False
  gState\LastTemp\source = "Refreshing..."
  gState\LastTemp\sensor = "Waiting for enabled data sources"
  gState\LastTemp\celsius = 0.0
  gState\LastTemp\windowsTempValid = #False
  gState\LastTemp\windowsTempSensor = ""
  gState\LastTemp\windowsTempCelsius = 0.0
  gState\LastTemp\cpuPackageValid = #False
  gState\LastTemp\cpuPackageSensor = ""
  gState\LastTemp\cpuPackageWatts = 0.0
  gState\LastTemp\gpuMemoryValid = #False
  gState\LastTemp\gpuMemorySensor = ""
  gState\LastTemp\gpuMemoryMb = 0.0
  gState\LastTemp\gpuSharedMemoryValid = #False
  gState\LastTemp\gpuSharedMemorySensor = ""
  gState\LastTemp\gpuSharedMemoryMb = 0.0
  ResetTempReading(@gState\LastControl)
  gState\LastWindows\valid = #False
  gState\LastWindows\source = ""
  gState\LastFallback\valid = #False
  gState\LastFallback\source = ""
  ResetTelemetryLatchState(@gBlendTelemetryLatch)
  ResetTelemetryLatchState(@gWindowsTelemetryLatch)
  ResetTelemetryLatchState(@gFallbackTelemetryLatch)
  gLastHelpAlertState = -1
  gState\ImmediateRefresh = #True
  UnlockMutex(gStateMutex)
EndProcedure

Procedure SaveSettingsFromGui()
  PullSettingsFromGui()
  SaveSettings()
  SetStartupRegistry(gSettings\AutoStartWithApp)
  UpdateUiRefreshTimer()

  LockMutex(gStateMutex)
  gState\AutoEnabled = gSettings\AutoEnabled
  UnlockMutex(gStateMutex)

  PushSettingsToGui()
  LogAction("Settings saved.")
  RefreshStatusDisplay()
EndProcedure

Procedure ApplyLiveCheckboxSettings(logText$ = "")
  Protected previousAutoStart.i

  LockMutex(gStateMutex)
  previousAutoStart = gSettings\AutoStartWithApp
  UnlockMutex(gStateMutex)

  PullSettingsFromGui()
  SaveSettings()
  ResetTelemetrySmoothing()
  If previousAutoStart <> gSettings\AutoStartWithApp
    SetStartupRegistry(gSettings\AutoStartWithApp)
  EndIf
  UpdateUiRefreshTimer()
  PushSettingsToGui()

  LockMutex(gStateMutex)
  gState\AutoEnabled = gSettings\AutoEnabled
  UnlockMutex(gStateMutex)

  RequestImmediateTelemetryRefresh()
  RefreshStatusDisplay()

  If logText$ <> ""
    LogAction(logText$)
    RefreshStatusDisplay()
  EndIf
EndProcedure

Procedure ApplyLiveTuningSettings()
  Protected activePlan$
  Protected currentCap.i

  PullSettingsFromGui()
  SaveSettings()
  ResetTelemetrySmoothing()
  UpdateUiRefreshTimer()
  PushSettingsToGui()

  LockMutex(gStateMutex)
  gState\AutoEnabled = gSettings\AutoEnabled
  UnlockMutex(gStateMutex)

  If gDynamicControl\Active
    currentCap = gDynamicControl\CpuCapPercent
    activePlan$ = GetActiveSchemeName()
    If activePlan$ = #PlanVisible$
      activePlan$ = GetCurrentManagedPlan()
    EndIf
    ApplyDynamicCpuCap(activePlan$, currentCap, @gSettings)
  EndIf

  RequestImmediateTelemetryRefresh()
  RefreshStatusDisplay()
EndProcedure

Procedure SelectPrimaryTelemetrySource(enabled.i)
  UpdateGadgetStateIfNeeded(#GadgetUseWindows, enabled)
EndProcedure

Procedure HideToTray()
  If gTrayReady
    HideWindow(#WindowMain, #True)
  Else
    HideWindow(#WindowMain, #False)
    SetForegroundWindow_(WindowID(#WindowMain))
    LogAction("Tray unavailable. Window stays visible.")
    RefreshStatusDisplay()
  EndIf
EndProcedure

Procedure ShowFromTray()
  Protected windowHandle.i

  If IsWindow(#WindowMain) = 0
    ProcedureReturn
  EndIf

  windowHandle = WindowID(#WindowMain)
  HideWindow(#WindowMain, #False)
  ShowWindow_(windowHandle, #SW_RESTORE)
  SetWindowPos_(windowHandle, #HWND_TOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE | #SWP_NOACTIVATE)
  SetWindowPos_(windowHandle, #HWND_NOTOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE | #SWP_NOACTIVATE)
  BringWindowToTop_(windowHandle)
  SetActiveWindow_(windowHandle)
  SetForegroundWindow_(windowHandle)
EndProcedure

Procedure.i MainWindowCallback(windowHandle.i, message.i, wParam.i, lParam.i)
  Select message
    Case #TrayCallbackMsg
      Select lParam
        Case #WM_LBUTTONUP, #WM_LBUTTONDBLCLK
          ShowFromTray()
          ProcedureReturn 0

        Case #WM_RBUTTONUP, #WM_CONTEXTMENU
          If IsWindow(#WindowMain)
            SetForegroundWindow_(WindowID(#WindowMain))
            DisplayPopupMenu(#PopupTray, WindowID(#WindowMain))
          EndIf
          ProcedureReturn 0
      EndSelect
  EndSelect

  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure ShutdownApp(exitCode.i = 0)
  StopWorkerThread()
  If gAmdAdlx\HasChangedSettings
    RestoreAmdAdlxSettings(#False)
  EndIf
  StopWindowsPerfHelper()
  RemoveNativeTrayIcon()
  If IsImage(gTrayImage)
    FreeImage(gTrayImage)
    gTrayImage = 0
  EndIf
  FreeNativeTrayIcons()
  End exitCode
EndProcedure

Procedure CreateTrayMenu()
  If CreatePopupImageMenu(#PopupTray)
    MenuItem(#MenuOpen, "Open PowerPilot")
    MenuBar()
    MenuItem(#MenuToggleAuto, "Toggle Auto Control")
    MenuItem(#MenuAutoOnce, "Run Auto Control Once")
    MenuBar()
    MenuItem(#MenuBattery, "Activate Battery")
    MenuItem(#MenuPlugged, "Activate Balanced")
    MenuItem(#MenuFull, "Activate Maximum")
    MenuBar()
    MenuItem(#MenuDependencies, "Help")
    MenuBar()
    MenuItem(#MenuCreatePlans, "Create Or Refresh Profiles")
    MenuItem(#MenuCleanupPlans, "Remove Managed Profiles")
    MenuBar()
    MenuItem(#MenuExit, "Exit")
  EndIf
EndProcedure

Procedure RefreshDependencyWindow()
  Protected summary$
  Protected info$
  Protected launch$

  If IsWindow(#WindowDependency) = 0
    ProcedureReturn
  EndIf

  summary$ = BuildDependencySummary()
  info$ = BuildDependencyInstructions()
  launch$ = DependencyLaunchLabel()

  UpdateTextGadgetIfNeeded(#GadgetDependencySummary, summary$)
  gLastDependencyInfoText$ = UpdateEditorTextIfNeeded(#GadgetDependencyInfo, info$, gLastDependencyInfoText$)
  UpdateTextGadgetIfNeeded(#GadgetDependencyLaunch, launch$)
  UpdateGadgetDisabledIfNeeded(#GadgetDependencyLaunch, #False)
EndProcedure

Procedure ShowDependencyWindow()
  If IsWindow(#WindowDependency) = 0
    If OpenWindow(#WindowDependency, 0, 0, 760, 600, #AppName$ + " Dependency Help", #PB_Window_SystemMenu | #PB_Window_ScreenCentered) = 0
      ProcedureReturn
    EndIf

    TextGadget(#GadgetDependencySummary, 20, 20, 720, 50, "", #PB_Text_Border)
    EditorGadget(#GadgetDependencyInfo, 20, 80, 720, 455, #PB_Editor_WordWrap | #PB_Editor_ReadOnly)
    ButtonGadget(#GadgetDependencyRefresh, 20, 550, 130, 30, "Refresh Status")
    ButtonGadget(#GadgetDependencyCopy, 160, 550, 140, 30, "Copy Instructions")
    ButtonGadget(#GadgetDependencyLaunch, 310, 550, 200, 30, "Refresh Status")
    ButtonGadget(#GadgetDependencyClose, 620, 550, 120, 30, "Close")
    gLastDependencyInfoText$ = ""
  EndIf

  RefreshDependencyWindow()
  HideWindow(#WindowDependency, #False)
  SetForegroundWindow_(WindowID(#WindowDependency))
EndProcedure

Procedure HandleDependencyAction(action.i)
  Select action
    Case #GadgetDependencyRefresh
      RefreshRuntimeSnapshot()
      RefreshStatusDisplay()
      RefreshDependencyWindow()
      LogAction("Dependency status refreshed.")

    Case #GadgetDependencyCopy
      SetClipboardText(BuildDependencyInstructions())
      LogAction("Dependency instructions copied.")
      RefreshStatusDisplay()

    Case #GadgetDependencyLaunch
      LaunchPreferredDependencyApp()
      RefreshRuntimeSnapshot()
      RefreshStatusDisplay()
      RefreshDependencyWindow()

    Case #GadgetDependencyClose
      If IsWindow(#WindowDependency)
        CloseWindow(#WindowDependency)
      EndIf
  EndSelect
EndProcedure

Procedure.i CreateMainWindow(showWindow.i)
  Protected windowFlags.i = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget
  Protected headingId.i

  If showWindow = #False
    windowFlags | #PB_Window_Invisible
  EndIf

  If OpenWindow(#WindowMain, 0, 0, 860, 660, #AppFullName$, windowFlags) = 0
    ProcedureReturn #False
  EndIf
  AppendRuntimeLog("CreateMainWindow: OpenWindow ok")

  SetWindowCallback(@MainWindowCallback())
  AppendRuntimeLog("CreateMainWindow: SetWindowCallback ok")
  ApplyWindowIcons()
  AppendRuntimeLog("CreateMainWindow: ApplyWindowIcons ok")
  EnsureUiFonts()
  AppendRuntimeLog("CreateMainWindow: EnsureUiFonts ok")

  PanelGadget(#GadgetMainPanel, 20, 16, 820, 520)
  AppendRuntimeLog("CreateMainWindow: PanelGadget ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Overview")
  TextGadget(#PB_Any, 18, 12, 780, 34, "Main dashboard. Shows the readings and plan state PowerPilot is using now." + #CRLF$ + "Values are averaged using the Auto Tuning tab setting.")
  FrameGadget(#PB_Any, 18, 54, 370, 150, "Averaged Snapshot")
  TextGadget(#PB_Any, 34, 84, 94, 20, "Temperature:")
  TextGadget(#GadgetOverviewTempValue, 136, 82, 220, 22, "Waiting...")
  SetGadgetFont(#GadgetOverviewTempValue, FontID(gFontBold))
  TextGadget(#PB_Any, 34, 112, 94, 20, "Telemetry:")
  TextGadget(#GadgetOverviewSourceValue, 136, 110, 220, 30, "Waiting...")
  SetGadgetFont(#GadgetOverviewSourceValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 148, 94, 20, "Temp Sensor:")
  TextGadget(#GadgetOverviewTempSensorValue, 136, 146, 220, 34, "Waiting...")
  SetGadgetFont(#GadgetOverviewTempSensorValue, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 18, 216, 370, 198, "Power and State")
  TextGadget(#PB_Any, 34, 246, 82, 20, "CPU Power:")
  TextGadget(#GadgetOverviewCpuPowerValue, 122, 246, 240, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewCpuPowerValue, FontID(gFontBold))
  TextGadget(#PB_Any, 34, 274, 82, 20, "GPU Memory:")
  TextGadget(#GadgetOverviewGpuMemoryValue, 122, 274, 240, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewGpuMemoryValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 326, 82, 20, "Power Source:")
  TextGadget(#GadgetOverviewPowerValue, 122, 326, 240, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewPowerValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 352, 82, 20, "Active Plan:")
  TextGadget(#GadgetOverviewPlanValue, 122, 350, 240, 28, "Waiting...")
  SetGadgetFont(#GadgetOverviewPlanValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 382, 82, 20, "Control:")
  TextGadget(#GadgetOverviewControlStateValue, 122, 380, 240, 28, "Waiting...")
  SetGadgetFont(#GadgetOverviewControlStateValue, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 408, 54, 390, 220, "Activity Log")
  TextGadget(#PB_Any, 424, 82, 350, 18, "Recent Auto Control and manual profile actions.")
  EditorGadget(#GadgetActionValue, 424, 106, 350, 144, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)

  FrameGadget(#PB_Any, 408, 286, 390, 150, "System Details")
  TextGadget(#GadgetOverviewHardwareDetails, 424, 312, 350, 112, "Waiting...")
  SetGadgetFont(#GadgetOverviewHardwareDetails, FontID(gFontBoldSmall))

  TextGadget(#PB_Any, 18, 448, 780, 34, "Profiles set Windows behavior. Auto Control applies temporary CPU caps from enabled targets." + #CRLF$ + "AMD ADLX is used only for metrics or real driver power/frequency controls when exposed.")
  AppendRuntimeLog("CreateMainWindow: Overview tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Live Telemetry")
  TextGadget(#PB_Any, 18, 12, 780, 34, "Live reading summary. Use this tab to see what PowerPilot can currently read." + #CRLF$ + "CPU package power remains primary. AMD ADLX adds optional GPU-side visibility and control.")

  FrameGadget(#PB_Any, 18, 54, 390, 180, "Control Readings")
  TextGadget(#PB_Any, 34, 86, 96, 20, "Temperature:")
  TextGadget(#GadgetLiveBlendTemp, 152, 84, 220, 22, "")
  SetGadgetFont(#GadgetLiveBlendTemp, FontID(gFontBold))
  TextGadget(#PB_Any, 34, 116, 96, 20, "Telemetry:")
  TextGadget(#GadgetLiveBlendSourceMix, 152, 114, 220, 36, "")
  SetGadgetFont(#GadgetLiveBlendSourceMix, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 158, 96, 20, "Temp Sensor:")
  TextGadget(#GadgetLiveBlendTempSensor, 152, 156, 220, 34, "")
  SetGadgetFont(#GadgetLiveBlendTempSensor, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 202, 96, 20, "CPU Power:")
  TextGadget(#GadgetLiveBlendCpu, 152, 200, 220, 24, "")
  SetGadgetFont(#GadgetLiveBlendCpu, FontID(gFontBold))

  FrameGadget(#PB_Any, 418, 54, 380, 180, "Hardware Info")
  TextGadget(#PB_Any, 434, 86, 110, 20, "Detected GPUs:")
  TextGadget(#GadgetLiveFallbackStatus, 434, 108, 340, 48, "")
  SetGadgetFont(#GadgetLiveFallbackStatus, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 434, 164, 100, 20, "GPU Memory:")
  TextGadget(#GadgetLiveBlendGpuMemory, 550, 164, 224, 20, "")
  SetGadgetFont(#GadgetLiveBlendGpuMemory, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 434, 194, 100, 20, "Power Source:")
  TextGadget(#GadgetLiveBlendPowerSource, 550, 194, 224, 20, "")
  SetGadgetFont(#GadgetLiveBlendPowerSource, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 18, 248, 390, 190, "AMD Driver Telemetry")
  TextGadget(#PB_Any, 34, 280, 82, 20, "Status:")
  TextGadget(#GadgetAmdAdlxStatus, 128, 278, 250, 22, "Checking...")
  SetGadgetFont(#GadgetAmdAdlxStatus, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 310, 82, 20, "AMD GPU:")
  TextGadget(#GadgetAmdAdlxGpuName, 128, 308, 250, 34, "Unavailable")
  SetGadgetFont(#GadgetAmdAdlxGpuName, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 356, 82, 20, "Metrics:")
  TextGadget(#GadgetAmdAdlxMetrics, 128, 354, 250, 42, "Unavailable")
  SetGadgetFont(#GadgetAmdAdlxMetrics, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 418, 248, 380, 190, "Profile and Control State")
  TextGadget(#PB_Any, 434, 280, 100, 20, "Active Profile:")
  TextGadget(#GadgetLiveBlendActivePlan, 550, 278, 224, 30, "")
  SetGadgetFont(#GadgetLiveBlendActivePlan, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 434, 314, 100, 20, "Control:")
  TextGadget(#GadgetLiveBlendControlState, 550, 312, 224, 32, "")
  SetGadgetFont(#GadgetLiveBlendControlState, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 434, 356, 100, 20, "AMD Features:")
  TextGadget(#GadgetAmdAdlxFeatures, 550, 354, 224, 54, "Checking support.")
  SetGadgetFont(#GadgetAmdAdlxFeatures, FontID(gFontBoldSmall))

  TextGadget(#PB_Any, 18, 456, 780, 24, "ADLX is probed automatically at startup and refreshed when Windows reports a GPU change.")
  AppendRuntimeLog("CreateMainWindow: Live Telemetry tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Automation")
  TextGadget(#PB_Any, 18, 12, 780, 36, "Choose whether PowerPilot may apply temporary caps from Auto Tuning targets." + #CRLF$ + "Profiles stay separate and are not changed by target control.")
  FrameGadget(#PB_Any, 18, 54, 360, 146, "Auto Control")
  CheckBoxGadget(#GadgetAutoEnabled, 34, 84, 280, 24, "Allow target-based temporary caps")
  CheckBoxGadget(#GadgetAutoBatteryPlan, 34, 114, 292, 24, "Use Battery profile when unplugged")

  FrameGadget(#PB_Any, 392, 54, 406, 146, "Startup")
  CheckBoxGadget(#GadgetAutoStart, 410, 84, 170, 24, "Start in tray")
  CheckBoxGadget(#GadgetKeepSettings, 410, 114, 220, 24, "Keep settings on reinstall")
  TextGadget(#PB_Any, 410, 150, 360, 36, "Start in tray keeps the window hidden after login." + #CRLF$ + "Keep settings preserves your config during reinstall.")

  FrameGadget(#PB_Any, 18, 220, 360, 206, "Readings")
  TextGadget(#PB_Any, 34, 248, 320, 46, "Windows telemetry provides temperature, CPU package power, GPU names, and VRAM readings.")
  CheckBoxGadget(#GadgetUseWindows, 34, 306, 190, 24, "Use Windows telemetry")
  ButtonGadget(#GadgetWindowsInfo, 244, 302, 24, 24, "i")
  TextGadget(#PB_Any, 34, 350, 320, 40, "Use Windows Balanced or Best performance mode; Best power efficiency may cap power below PowerPilot targets.")

  FrameGadget(#PB_Any, 392, 220, 406, 206, "AMD GPU-Side Assist")
  CheckBoxGadget(#GadgetAmdAdlxEnabled, 410, 250, 260, 24, "Enable AMD GPU-side control")
  ButtonGadget(#GadgetAmdAdlxRestore, 410, 286, 150, 28, "Restore AMD")
  TextGadget(#PB_Any, 410, 330, 360, 58, "When enabled, Auto Control may use AMD power or frequency tuning only when the driver exposes it. ADLX support remains optional and driver-dependent.")
  AppendRuntimeLog("CreateMainWindow: Automation tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Auto Tuning")
  TextGadget(#PB_Any, 18, 12, 780, 36, "Power and temperature targets are independent of behavior profiles." + #CRLF$ + "The bounded PI controller applies temporary CPU caps and optional real AMD GPU caps.")
  FrameGadget(#PB_Any, 18, 54, 360, 174, "Timing and Response")
  TextGadget(#PB_Any, 34, 86, 170, 20, "Refresh every (sec):")
  SpinGadget(#GadgetPollSpin, 248, 82, 72, 25, 1, 60, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 116, 170, 20, "Temp deadband (C):")
  SpinGadget(#GadgetHysteresisSpin, 248, 112, 72, 25, 1, 20, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 146, 170, 20, "Power deadband (W):")
  SpinGadget(#GadgetControlDeadbandSpin, 248, 142, 72, 25, 1, 15, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 176, 170, 20, "Dashboard average (sec):")
  SpinGadget(#GadgetAutoControlAverage, 248, 172, 72, 25, 1, 60, #PB_Spin_Numeric)

  FrameGadget(#PB_Any, 392, 54, 406, 174, "Targets")
  CheckBoxGadget(#GadgetPowerTargetEnabled, 410, 84, 190, 24, "Use power target")
  TextGadget(#PB_Any, 622, 88, 66, 20, "Watts:")
  SpinGadget(#GadgetPowerTargetWatts, 696, 84, 72, 25, 5, 80, #PB_Spin_Numeric)
  CheckBoxGadget(#GadgetTempTargetEnabled, 410, 124, 190, 24, "Use temperature target")
  TextGadget(#PB_Any, 622, 128, 66, 20, "Temp C:")
  SpinGadget(#GadgetTempTargetC, 696, 124, 72, 25, 45, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 410, 164, 360, 42, "Enable either target or both. Selecting a profile never changes these target values.")

  FrameGadget(#PB_Any, 18, 252, 380, 186, "CPU Cap Bounds")
  TextGadget(#PB_Any, 34, 286, 164, 20, "Minimum CPU cap (%):")
  SpinGadget(#GadgetMinCpuCap, 224, 282, 72, 25, #MinimumDynamicCpuCapPercent, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 322, 164, 20, "Minimum CPU MHz:")
  SpinGadget(#GadgetMinCpuMHz, 224, 318, 72, 25, #MinimumDynamicCpuMHz, 5000, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 358, 164, 20, "Reference max MHz:")
  SpinGadget(#GadgetMaxCpuMHz, 224, 354, 72, 25, 800, 6000, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 398, 330, 26, "Very low caps can starve GPU-heavy APU load; profile settings return when control relaxes.")

  FrameGadget(#PB_Any, 418, 252, 380, 186, "Current Controller State")
  TextGadget(#GadgetControllerStatus, 436, 286, 340, 92, "Waiting for telemetry.")
  SetGadgetFont(#GadgetControllerStatus, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 436, 392, 340, 30, "Fast attack, slow recovery, bounded integral, and a short response window.")
  AppendRuntimeLog("CreateMainWindow: Auto Tuning tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Profiles")
  TextGadget(#PB_Any, 18, 12, 780, 36, "Install, remove, and tune the four PowerPilot behavior profiles." + #CRLF$ + "Profiles do not set watt or temperature targets; Auto Tuning does.")
  FrameGadget(#PB_Any, 18, 54, 370, 442, "Installed Profiles")
  ListIconGadget(#GadgetPlanList, 34, 84, 338, 270, "Plan", 175, #PB_ListIcon_CheckBoxes | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  AddGadgetColumn(#GadgetPlanList, 1, "Type", 72)
  AddGadgetColumn(#GadgetPlanList, 2, "Purpose", 280)
  ButtonGadget(#GadgetPlanRefreshAll, 34, 372, 150, 30, "Create Defaults")
  ButtonGadget(#GadgetPlanRemoveAll, 198, 372, 174, 30, "Remove Managed")
  TextGadget(#PB_Any, 34, 420, 338, 54, "Tick to keep installed; untick to remove." + #CRLF$ + "Maximum, Balanced, Quiet, and Battery are the only default profiles.")

  FrameGadget(#PB_Any, 408, 54, 390, 442, "Profile Editor")
  TextGadget(#PB_Any, 426, 84, 78, 20, "Plan Name:")
  StringGadget(#GadgetPlanEditorName, 512, 80, 266, 24, "")
  TextGadget(#PB_Any, 426, 114, 78, 20, "Purpose:")
  StringGadget(#GadgetPlanEditorSummary, 512, 110, 266, 24, "")
  TextGadget(#PB_Any, 426, 144, 78, 20, "Preset:")
  ComboBoxGadget(#GadgetPlanEditorPreset, 512, 140, 178, 24)
  ButtonGadget(#GadgetPlanEditorLoadPreset, 704, 140, 74, 24, "Load")

  FrameGadget(#PB_Any, 426, 176, 352, 116, "CPU Behavior")
  TextGadget(#PB_Any, 444, 204, 76, 20, "Plug Eff:")
  SpinGadget(#GadgetPlanAcEpp, 524, 200, 60, 24, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 612, 204, 76, 20, "Batt Eff:")
  SpinGadget(#GadgetPlanDcEpp, 696, 200, 60, 24, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 444, 232, 76, 20, "Plug Boost:")
  ComboBoxGadget(#GadgetPlanAcBoost, 524, 228, 82, 24)
  TextGadget(#PB_Any, 612, 232, 76, 20, "Batt Boost:")
  ComboBoxGadget(#GadgetPlanDcBoost, 696, 228, 82, 24)
  TextGadget(#PB_Any, 444, 260, 76, 20, "Plug Cool:")
  ComboBoxGadget(#GadgetPlanAcCooling, 524, 256, 82, 24)
  TextGadget(#PB_Any, 612, 260, 76, 20, "Batt Cool:")
  ComboBoxGadget(#GadgetPlanDcCooling, 696, 256, 82, 24)

  FrameGadget(#PB_Any, 426, 304, 352, 92, "CPU Limits")
  TextGadget(#PB_Any, 444, 332, 76, 20, "Plug Max:")
  SpinGadget(#GadgetPlanAcState, 524, 328, 60, 24, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 612, 332, 76, 20, "Batt Max:")
  SpinGadget(#GadgetPlanDcState, 696, 328, 60, 24, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 444, 360, 76, 20, "Plug MHz:")
  SpinGadget(#GadgetPlanAcFreq, 524, 356, 72, 24, 0, 5000, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 612, 360, 76, 20, "Batt MHz:")
  SpinGadget(#GadgetPlanDcFreq, 696, 356, 72, 24, 0, 5000, #PB_Spin_Numeric)

  ButtonGadget(#GadgetPlanEditorSave, 426, 420, 96, 30, "Save")
  ButtonGadget(#GadgetPlanEditorNew, 536, 420, 108, 30, "New")
  ButtonGadget(#GadgetPlanEditorDelete, 654, 420, 124, 30, "Delete")
  DisableGadget(#GadgetPlanEditorNew, #True)
  DisableGadget(#GadgetPlanEditorDelete, #True)
  AppendRuntimeLog("CreateMainWindow: Profiles tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Manual Override")
  TextGadget(#PB_Any, 18, 12, 780, 36, "Use this tab when you want to choose the Windows behavior profile yourself." + #CRLF$ + "Profiles do not set watt or temperature targets; those stay on the Auto Tuning tab.")
  FrameGadget(#PB_Any, 18, 54, 780, 136, "Manual Profile")
  TextGadget(#PB_Any, 34, 90, 80, 20, "Profile:")
  ComboBoxGadget(#GadgetPlanCombo, 120, 86, 398, 28)
  PopulatePlanCombo()
  ButtonGadget(#GadgetActivatePlan, 542, 85, 110, 28, "Activate")
  ButtonGadget(#GadgetAutoOnce, 670, 85, 106, 28, "Auto Once")
  TextGadget(#PB_Any, 34, 126, 740, 42, "Activate switches to the selected profile now." + #CRLF$ + "Auto Once applies one target-control decision and leaves target settings unchanged.")

  FrameGadget(#PB_Any, 18, 210, 780, 96, "Display Recovery")
  ButtonGadget(#GadgetResetDisplay, 34, 246, 190, 30, "Reset Display")
  TextGadget(#PB_Any, 244, 244, 530, 34, "Sends Win+Ctrl+Shift+B. Use this if the display path needs a quick Windows reset.")

  FrameGadget(#PB_Any, 18, 326, 780, 132, "How Manual Profiles Behave")
  TextGadget(#PB_Any, 34, 352, 740, 72, "Only installed profiles appear in the list." + #CRLF$ + "Manual profile activation does not enable, disable, or change power/temperature targets." + #CRLF$ + "Auto Control overlays temporary caps only when enabled in Automation and Auto Tuning.")

  CloseGadgetList()
  AppendRuntimeLog("CreateMainWindow: Manual Override tab ok")

  CanvasGadget(#GadgetDependencies, 20, 548, 95, 30)
  ButtonGadget(#GadgetSaveSettings, 125, 548, 90, 30, "Save")
  ButtonGadget(#GadgetHideToTray, 225, 548, 95, 30, "Hide")
  ButtonGadget(#GadgetExit, 730, 548, 110, 30, "Exit")
  TextGadget(#GadgetStatusLine, 20, 590, 820, 36, "Ready.", #PB_Text_Border)

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
  PopulatePlanPresetCombo()
  RefreshPlanList()
  RefreshPlanEditor()
  PushSettingsToGui()
  ResetTelemetrySmoothing()
  PopulatePlanCombo()
  UpdateUiRefreshTimer()
  DrawHelpButton()
  ApplyMainWindowToolTips()
  AppendRuntimeLog("CreateMainWindow: final setup ok")

  ProcedureReturn #True
EndProcedure

Procedure HandleManualAction(action.i)
  Protected planName$
  Protected planIndex.i
  Protected itemState.i

  Select action
    Case #GadgetPlanRefreshAll
      If CreateManagedPlans()
        RefreshPlanList()
        PopulatePlanCombo()
        RefreshPlanEditor()
        LogAction("Default and saved plans created or refreshed.")
      EndIf

    Case #GadgetPlanRemoveAll
      If CleanupManagedPlans()
        RefreshPlanList()
        PopulatePlanCombo()
        RefreshPlanEditor()
      EndIf

    Case #GadgetPlanList
      planIndex = GetGadgetState(#GadgetPlanList)
      If planIndex >= 0
        planName$ = GetGadgetItemText(#GadgetPlanList, planIndex)
        gSelectedPlanName$ = planName$
        itemState = GetGadgetItemState(#GadgetPlanList, planIndex)
        If (itemState & #PB_ListIcon_Checked) And PlanDefinitionInstalled(planName$) = #False
          EnsurePlanInstalled(planName$)
          PopulatePlanCombo()
        ElseIf (itemState & #PB_ListIcon_Checked) = 0 And PlanDefinitionInstalled(planName$)
          RemoveManagedPlanByName(planName$)
          PopulatePlanCombo()
        EndIf
        RefreshPlanList()
        RefreshPlanEditor()
      EndIf

    Case #GadgetPlanEditorLoadPreset
      planIndex = GetGadgetState(#GadgetPlanEditorPreset)
      If planIndex >= 0
        LoadPlanEditorFromPreset(GetGadgetItemText(#GadgetPlanEditorPreset, planIndex))
      EndIf

    Case #GadgetPlanEditorSave
      SavePlanEditorDefinition()

    Case #GadgetPlanEditorNew
      LogAction("Custom profiles are disabled; PowerPilot uses four behavior profiles.")

    Case #GadgetPlanEditorDelete
      LogAction("Built-in behavior profiles are kept; use Remove Managed to clean Windows profiles.")

    Case #GadgetActivatePlan
      planIndex = GetGadgetState(#GadgetPlanCombo)
      If planIndex >= 0
        planName$ = GetGadgetItemText(#GadgetPlanCombo, planIndex)
      EndIf
      If planName$ <> ""
        If ActivatePlanByName(planName$, #True) And IsRememberedPluggedPlanName(planName$)
          RememberPluggedPlan(planName$, #True)
          gManualOverrideUntil = 0
          RestoreDynamicCpuCap(planName$, @gSettings)
          SaveSettings()
          PushSettingsToGui()
          LogAction(planName$ + " profile activated. Power and temperature targets are unchanged.")
        EndIf
      Else
        LogAction("No manual plan is selected.")
      EndIf

    Case #GadgetAutoOnce
      AutoControlStep(#True)

    Case #GadgetResetDisplay
      TriggerDisplayReset()
      LogAction("Requested Windows graphics/display reset hotkey.")

    Case #GadgetAutoEnabled
      ApplyLiveCheckboxSettings("Auto Control setting updated.")

    Case #GadgetUseWindows
      SelectPrimaryTelemetrySource(GetGadgetState(#GadgetUseWindows))
      ApplyLiveCheckboxSettings("Windows telemetry setting updated.")

    Case #GadgetAutoStart
      ApplyLiveCheckboxSettings("Start With Windows setting updated.")

    Case #GadgetKeepSettings
      ApplyLiveCheckboxSettings("Keep settings on reinstall setting updated.")

    Case #GadgetAutoBatteryPlan
      ApplyLiveCheckboxSettings("Battery/plugged auto setting updated.")

    Case #GadgetAmdAdlxEnabled
      ApplyLiveCheckboxSettings("AMD ADLX GPU-side control setting updated.")
      If GetGadgetState(#GadgetAmdAdlxEnabled)
        ProbeAmdAdlx(#True)
        ReadAmdAdlxMetrics(#True)
      Else
        RestoreAmdAdlxSettings(#True)
      EndIf
      RefreshStatusDisplay()

    Case #GadgetAmdAdlxRestore
      RestoreAmdAdlxSettings(#True)
      RefreshStatusDisplay()

    Case #GadgetPollSpin, #GadgetHysteresisSpin, #GadgetControlDeadbandSpin, #GadgetAutoControlAverage, #GadgetPowerTargetEnabled, #GadgetPowerTargetWatts, #GadgetTempTargetEnabled, #GadgetTempTargetC, #GadgetMinCpuCap, #GadgetMinCpuMHz, #GadgetMaxCpuMHz
      ApplyLiveTuningSettings()

    Case #GadgetSaveSettings
      SaveSettingsFromGui()

    Case #GadgetDependencies
      If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftButtonUp Or EventType() = 0
        ShowDependencyWindow()
      EndIf

    Case #GadgetWindowsInfo
      MessageRequester(#AppName$ + " Telemetry Info", BuildWindowsInfoText())

    Case #GadgetHideToTray
      HideToTray()

    Case #GadgetExit
      ShutdownApp()
  EndSelect
EndProcedure

Procedure HandleTrayMenu(menuID.i)
  Select menuID
    Case #MenuOpen
      ShowFromTray()

    Case #MenuToggleAuto
      LockMutex(gStateMutex)
      gSettings\AutoEnabled = Bool(gSettings\AutoEnabled = 0)
      gState\AutoEnabled = gSettings\AutoEnabled
      UnlockMutex(gStateMutex)
      SaveSettings()
      PushSettingsToGui()
      LogAction("Auto Control toggled to " + Str(gSettings\AutoEnabled))

    Case #MenuAutoOnce
      AutoControlStep(#True)

    Case #MenuBattery
      ActivatePlanByName(#PlanBattery$, #True)

    Case #MenuPlugged
      If ActivatePlanByName(#PlanPlugged$, #True)
        RememberPluggedPlan(#PlanPlugged$, #True)
      EndIf

    Case #MenuFull
      If ActivatePlanByName(#PlanFull$, #True)
        RememberPluggedPlan(#PlanFull$, #True)
      EndIf

    Case #MenuDependencies
      ShowDependencyWindow()

    Case #MenuCreatePlans
      CreateManagedPlans()

    Case #MenuCleanupPlans
      CleanupManagedPlans()

    Case #MenuExit
      ShutdownApp()
  EndSelect
EndProcedure

Procedure RunGui(showWindow.i)
  Protected event.i
  Protected eventWindow.i
  Protected workerRunning.i

  AppendRuntimeLog("RunGui start, showWindow=" + Str(showWindow))
  CreateTrayMenu()
  If CreateMainWindow(showWindow) = #False
    AppendRuntimeLog("CreateMainWindow failed")
    End 1
  EndIf
  AppendRuntimeLog("CreateMainWindow ok")
  gTrayImage = 0
  If showWindow = #False
    gTrayReady = AddNativeTrayIconWithRetry(12, 500)
  Else
    gTrayReady = AddNativeTrayIcon()
  EndIf
  AppendRuntimeLog("AddNativeTrayIcon=" + Str(gTrayReady))

  RefreshRuntimeSnapshot()
  AppendRuntimeLog("RefreshRuntimeSnapshot ok")
  SelectPlanComboByName(gState\ActivePlan)
  AppendRuntimeLog("SelectPlanComboByName ok")
  RefreshStatusDisplay()
  AppendRuntimeLog("RefreshStatusDisplay ok")
  StartWorkerThread()
  AppendRuntimeLog("StartWorkerThread ok")

  If showWindow = #False And gTrayReady
    HideWindow(#WindowMain, #True)
    AppendRuntimeLog("HideWindow(true)")
  Else
    HideWindow(#WindowMain, #False)
    SetForegroundWindow_(WindowID(#WindowMain))
    If showWindow = #False
      LogAction("Tray icon unavailable at startup. Showing the window.")
    EndIf
    AppendRuntimeLog("HideWindow(false)")
  EndIf
  AppendRuntimeLog("Event loop start")

  Repeat
    event = WaitWindowEvent()
    eventWindow = EventWindow()

    Select event
      Case #PB_Event_CloseWindow
        Select eventWindow
          Case #WindowMain
            HideToTray()
          Case #WindowDependency
            CloseWindow(#WindowDependency)
        EndSelect

      Case #PB_Event_Gadget
        Select eventWindow
          Case #WindowDependency
            HandleDependencyAction(EventGadget())
          Default
            HandleManualAction(EventGadget())
        EndSelect

      Case #PB_Event_Menu
        HandleTrayMenu(EventMenu())

      Case #PB_Event_SysTray
        Select EventType()
          Case #PB_EventType_LeftClick, #PB_EventType_LeftDoubleClick
            ShowFromTray()
        EndSelect

      Case #PB_Event_Timer
        Select EventTimer()
          Case #TimerUiRefresh
            LockMutex(gStateMutex)
            workerRunning = gState\WorkerRunning
            UnlockMutex(gStateMutex)
            If workerRunning = #False
              AutoControlStep()
              RefreshRuntimeSnapshot()
            EndIf
            RefreshStatusDisplay()
            If IsWindow(#WindowDependency)
              If workerRunning = #False
                RefreshDependencyWindow()
              EndIf
            EndIf
        EndSelect

      Case #PB_Event_MinimizeWindow
        If eventWindow = #WindowMain And gTrayReady
          HideToTray()
        EndIf
    EndSelect
  ForEver
EndProcedure

gStateMutex = CreateMutex()
CleanupDetachedWindowsPerfHelpers()
LoadSettings()
InitializePlanDefinitions()

LockMutex(gStateMutex)
gState\AutoEnabled = gSettings\AutoEnabled
gState\PowerSource = DetectPowerSource()
gState\ActivePlan = GetActiveSchemeName()
UnlockMutex(gStateMutex)

If gState\ActivePlan = #PlanVisible$
  LockMutex(gStateMutex)
  gState\ActivePlan = GetCurrentManagedPlan()
  UnlockMutex(gStateMutex)
EndIf

If gState\PowerSource = #PowerSourcePlugged And IsRememberedPluggedPlanName(gState\ActivePlan)
  RememberPluggedPlan(gState\ActivePlan, #True)
EndIf
If IsSelectableManagedPlanName(gState\ActivePlan)
  RememberCurrentManagedPlan(gState\ActivePlan, #True)
EndIf
EnsureVisiblePlanActive()

If CountProgramParameters() > 0
  Select LCase(ProgramParameter(0))
    Case "/create-plans"
      If CreateManagedPlans()
        End 0
      Else
        End 1
      EndIf

    Case "/cleanup-plans"
      If CleanupManagedPlans()
        End 0
      Else
        End 1
      EndIf

    Case "/auto-gamecool-once", "/auto-cool-once"
      AutoControlStep(#True)
      End 0

    Case "/startup-on"
      gSettings\AutoStartWithApp = #True
      SaveSettings()
      If SetStartupRegistry(#True)
        End 0
      Else
        End 1
      EndIf

    Case "/startup-off"
      gSettings\AutoStartWithApp = #False
      SaveSettings()
      If SetStartupRegistry(#False)
        End 0
      Else
        End 1
      EndIf

    Case "/cleanup-settings"
      If CleanupSettingsData()
        End 0
      Else
        End 1
      EndIf

    Case "/query-keep-settings"
      If gSettings\KeepSettingsOnReinstall
        End 1
      Else
        End 0
      EndIf

    Case "/tray"
      gTrayStart = #True

    Case "/show"
      gTrayStart = #False
  EndSelect
EndIf

RunGui(Bool(gTrayStart = #False))

; IDE Options = PureBasic 6.40 (Windows - x64)
; FirstLine = 198
; Folding = ------------
; Optimizer
; EnableAsm
; EnableThread
; EnableXP
; DPIAware
; DisableDebugger

