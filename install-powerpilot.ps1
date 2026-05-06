param(
    [string]$SetupPath = "",
    [string]$LogPath = ".\build\install-run.log"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Get-ProjectRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedRoot = (Resolve-Path $repoRoot).Path
    $resolvedPath = (Resolve-Path $Path).Path
    $rootUri = New-Object System.Uri(($resolvedRoot.TrimEnd("\") + "\"))
    $pathUri = New-Object System.Uri($resolvedPath)

    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("/", "\")
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-LatestInstallContext {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedSetup,
        [Parameter(Mandatory = $true)]
        [string]$ResolvedLog,
        [Parameter(Mandatory = $true)]
        [int]$ExitCode,
        [Parameter(Mandatory = $true)]
        [string]$ResultText
    )

    $chatRoot = Join-Path $repoRoot "CHAT_MEMORY"
    $null = New-Item -ItemType Directory -Path $chatRoot -Force
    $path = Join-Path $chatRoot "LATEST_INSTALL.md"
    $stamp = Get-Date
    $setupRelative = Get-ProjectRelativePath -Path $ResolvedSetup
    $logRelative = if (Test-Path $ResolvedLog) { Get-ProjectRelativePath -Path $ResolvedLog } else { $ResolvedLog }

    $logSummary = "Installer log was not found."
    if (Test-Path $ResolvedLog) {
        $logTail = Get-Content -LiteralPath $ResolvedLog -Tail 6 -ErrorAction SilentlyContinue
        if ($logTail) {
            $logSummary = ($logTail -join [Environment]::NewLine)
        }
    }

    $content = @"
# Latest Install

Generated: $($stamp.ToString("yyyy-MM-dd HH:mm:ss zzz"))

## Result

- Silent installer run: $ResultText
- Exit code: $ExitCode

## Inputs

- Setup: $setupRelative
- Log: $logRelative

## Notes

- The install script now waits for the installer to finish so this record reflects the completed run.
- Use the installer log above for detailed file-by-file installation output.

## Log tail

$logSummary
"@

    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
}

function Get-InnoLogDuration {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedLog
    )

    if (-not (Test-Path $ResolvedLog)) {
        return $null
    }

    $timestampPattern = '^(?<stamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})'
    $first = $null
    $last = $null

    foreach ($line in Get-Content -LiteralPath $ResolvedLog -ErrorAction SilentlyContinue) {
        if ($line -match $timestampPattern) {
            $parsed = [datetime]::ParseExact($matches.stamp, 'yyyy-MM-dd HH:mm:ss.fff', [Globalization.CultureInfo]::InvariantCulture)
            if (-not $first) {
                $first = $parsed
            }
            $last = $parsed
        }
    }

    if ($first -and $last) {
        return [pscustomobject]@{
            Start = $first
            End = $last
            Seconds = [math]::Round(($last - $first).TotalSeconds, 3)
        }
    }

    return $null
}

function Get-PowerPilotBatteryLogDuration {
    $path = Join-Path $env:APPDATA "PowerPilot\battery-log.csv"
    if (-not (Test-Path $path)) {
        return $null
    }

    $rows = Import-Csv -LiteralPath $path -ErrorAction SilentlyContinue
    $items = foreach ($row in $rows) {
        if (-not [string]::IsNullOrWhiteSpace($row.timestamp)) {
            [pscustomobject]@{
                Time = [datetime]::ParseExact($row.timestamp, 'yyyy-MM-ddTHH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
                Type = [string]$row.row_type
            }
        }
    }

    if (-not $items) {
        return $null
    }

    $ordered = @($items | Sort-Object Time)
    $counts = $items | Group-Object Type | Sort-Object Name | ForEach-Object {
        $name = if ([string]::IsNullOrWhiteSpace($_.Name)) { "legacy" } else { $_.Name }
        "$name=$($_.Count)"
    }

    return [pscustomobject]@{
        Path = $path
        Start = $ordered[0].Time
        End = $ordered[-1].Time
        Seconds = [math]::Round(($ordered[-1].Time - $ordered[0].Time).TotalSeconds, 3)
        Rows = $ordered.Count
        Counts = ($counts -join ", ")
    }
}

function Resolve-UnderRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $repoRoot $Path)
}

function Resolve-PowerPilotSetupPath {
    param(
        [string]$Path
    )

    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        return Resolve-UnderRepo -Path $Path
    }

    $buildDir = Join-Path $repoRoot "build"
    $latestSetup = Get-ChildItem -Path $buildDir -Filter "PowerPilot_V*_Setup.exe" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latestSetup) {
        throw "No PowerPilot installer found in $buildDir. Build the installer first or pass -SetupPath."
    }

    return $latestSetup.FullName
}

function Resolve-InstalledPowerPilotExe {
    $installDir = Join-Path $env:ProgramFiles "PowerPilot"
    $latestExe = Get-ChildItem -Path $installDir -Filter "PowerPilot_V*.exe" -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike "*_Setup.exe" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($latestExe) {
        return $latestExe.FullName
    }

    return (Join-Path $installDir "PowerPilot_V1.1.exe")
}

function Test-PowerPilotRunningStable {
    param(
        [int]$ProbeCount = 4,
        [int]$DelayMs = 700
    )

    $probe = 0
    $running = $null

    for ($probe = 0; $probe -lt $ProbeCount; $probe++) {
        $running = Get-Process PowerPilot_V* -ErrorAction SilentlyContinue
        if (-not $running) {
            return $false
        }

        if ($probe + 1 -lt $ProbeCount) {
            Start-Sleep -Milliseconds $DelayMs
        }
    }

    return $true
}

function Start-PowerPilotTrayProcess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExePath
    )

    Start-Process -FilePath $ExePath -ArgumentList "/tray" -WindowStyle Hidden | Out-Null
}

function Start-InstalledPowerPilotIfNeeded {
    $installedExe = Resolve-InstalledPowerPilotExe
    $attempt = 0
    $observe = 0

    if (-not (Test-Path $installedExe)) {
        Write-Host "Installed app not found for tray launch:" $installedExe
        return
    }

    for ($observe = 0; $observe -lt 10; $observe++) {
        if (Test-PowerPilotRunningStable -ProbeCount 3 -DelayMs 700) {
            Start-Sleep -Seconds 3
            if (Test-PowerPilotRunningStable -ProbeCount 3 -DelayMs 700) {
                Write-Host "PowerPilot is already running after install."
                return
            }
        }

        Start-Sleep -Seconds 1
    }

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        Start-PowerPilotTrayProcess -ExePath $installedExe
        Start-Sleep -Seconds 1

        if (Test-PowerPilotRunningStable -ProbeCount 6 -DelayMs 900) {
            Start-Sleep -Seconds 3
            if (Test-PowerPilotRunningStable -ProbeCount 3 -DelayMs 700) {
            Write-Host "Started PowerPilot in tray:" $installedExe
            return
            }
        }
    }

    Write-Host "PowerPilot did not stay running after install launch attempts."
}

function Get-InstallerRelatedProcesses {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedSetup
    )

    $setupName = Split-Path -Leaf $ResolvedSetup
    $repoFragment = $repoRoot.Replace('\', '\\')

    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object {
            if ($_.ProcessId -eq $PID) {
                return $false
            }

            $name = [string]$_.Name
            $commandLine = [string]$_.CommandLine
            $executablePath = [string]$_.ExecutablePath

            if ($name -like "PowerPilot_V*_Setup.exe") {
                return $true
            }

            if ($name -like "PowerPilot_V*.exe" -and $commandLine -like "*/cleanup-old-versions*") {
                return $true
            }

            if ($name -in @("powershell.exe", "pwsh.exe")) {
                if ($commandLine -like "*install-powerpilot.ps1*" -or
                    $commandLine -like "*$setupName*" -or
                    $commandLine -like "*$repoRoot*") {
                    return $true
                }
            }

            if ($executablePath -eq $ResolvedSetup) {
                return $true
            }

            return $false
        } |
        Select-Object ProcessId, Name, CommandLine, ExecutablePath
}

function Wait-InstallerRelatedProcessesClosed {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedSetup,
        [int]$TimeoutSeconds = 15
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $remaining = @()

    do {
        Start-Sleep -Milliseconds 500
        $remaining = @(Get-InstallerRelatedProcesses -ResolvedSetup $ResolvedSetup)
        if ($remaining.Count -eq 0) {
            Write-Host "Post-install installer process check: clear."
            return
        }
    } while ((Get-Date) -lt $deadline)

    Write-Host "Post-install installer process check: processes still running:"
    foreach ($item in $remaining) {
        Write-Host (" - {0} PID {1}" -f $item.Name, $item.ProcessId)
    }
    throw "Installer-related processes remained after install."
}

$resolvedSetup = Resolve-PowerPilotSetupPath -Path $SetupPath
$resolvedLog = Resolve-UnderRepo -Path $LogPath

if (-not (Test-Path $resolvedSetup)) {
    throw "Installer not found: $resolvedSetup"
}

$logDir = Split-Path -Parent $resolvedLog
if (-not (Test-Path $logDir)) {
    $null = New-Item -ItemType Directory -Path $logDir -Force
}

if (Test-Path $resolvedLog) {
    Remove-Item -LiteralPath $resolvedLog -Force
}

$runStarted = Get-Date
$quotedLogPath = '"' + $resolvedLog + '"'
$arguments = @(
    "/VERYSILENT",
    "/SUPPRESSMSGBOXES",
    "/NORESTART",
    "/CLOSEAPPLICATIONS",
    "/FORCECLOSEAPPLICATIONS",
    "/LOG=$quotedLogPath"
)

Write-Host "Setup:" $resolvedSetup
Write-Host "Log:" $resolvedLog
$startParams = @{
    FilePath = $resolvedSetup
    ArgumentList = $arguments
    PassThru = $true
}
if (-not (Test-IsAdministrator)) {
    $startParams.Verb = "RunAs"
    Write-Host "Requesting elevation for the installer only..."
}
else {
    Write-Host "Installer helper is already elevated; it will not launch the installed app as admin."
}

$process = Start-Process @startParams
$lastStatus = Get-Date
$lastLogLine = ""

Write-Host "Started installer PID:" $process.Id
Write-Host "Waiting for installer to finish..."

while (-not $process.HasExited) {
    Start-Sleep -Seconds 2
    $process.Refresh()

    if ((Get-Date) -ge $lastStatus.AddSeconds(6)) {
        $elapsed = [int]((Get-Date) - $runStarted).TotalSeconds
        Write-Host "Installer still running (${elapsed}s elapsed)..."

        if (Test-Path $resolvedLog) {
            $tailLine = Get-Content -LiteralPath $resolvedLog -Tail 1 -ErrorAction SilentlyContinue
            if (-not [string]::IsNullOrWhiteSpace($tailLine) -and $tailLine -ne $lastLogLine) {
                Write-Host "Latest log:" $tailLine
                $lastLogLine = $tailLine
            }
        }

        $lastStatus = Get-Date
    }
}

$process.WaitForExit()
$installerProcessEnded = Get-Date

$resultText = "failed"
if (Test-Path $resolvedLog) {
    $logItem = Get-Item -LiteralPath $resolvedLog
    if ($logItem.LastWriteTime -ge $runStarted.AddSeconds(-1)) {
        $logText = Get-Content -LiteralPath $resolvedLog -Raw -ErrorAction SilentlyContinue
        if ($logText -match "Installation process succeeded\." -or $logText -match "Need to restart Windows\? No") {
            $resultText = "success"
        }
        elseif ($process.ExitCode -eq 0) {
            $resultText = "completed with log"
        }
    }
}
elseif ($process.ExitCode -eq 0) {
    $resultText = "completed without log"
}

Write-LatestInstallContext -ResolvedSetup $resolvedSetup -ResolvedLog $resolvedLog -ExitCode $process.ExitCode -ResultText $resultText

if ($process.ExitCode -eq 0) {
    Start-Sleep -Seconds 2
    if (Test-IsAdministrator) {
        Write-Host "Skipping non-installer tray fallback because this helper is elevated."
    }
    else {
        Start-InstalledPowerPilotIfNeeded
    }
    Wait-InstallerRelatedProcessesClosed -ResolvedSetup $resolvedSetup
}

$scriptEnded = Get-Date
$innoDuration = Get-InnoLogDuration -ResolvedLog $resolvedLog
if ($innoDuration) {
    Write-Host ("Installer log duration: {0:n3}s ({1} to {2})" -f $innoDuration.Seconds, $innoDuration.Start.ToString("HH:mm:ss.fff"), $innoDuration.End.ToString("HH:mm:ss.fff"))
}
$powerPilotLogDuration = Get-PowerPilotBatteryLogDuration
if ($powerPilotLogDuration) {
    Write-Host ("PowerPilot battery log duration: {0:n3}s ({1} to {2}, rows {3}, {4})" -f $powerPilotLogDuration.Seconds, $powerPilotLogDuration.Start.ToString("HH:mm:ss"), $powerPilotLogDuration.End.ToString("HH:mm:ss"), $powerPilotLogDuration.Rows, $powerPilotLogDuration.Counts)
}
Write-Host ("Installer process wait: {0:n3}s" -f (($installerProcessEnded - $runStarted).TotalSeconds))
Write-Host ("Install helper total time: {0:n3}s" -f (($scriptEnded - $runStarted).TotalSeconds))

Write-Host "Install result:" $resultText
Write-Host "Installer exit code:" $process.ExitCode
