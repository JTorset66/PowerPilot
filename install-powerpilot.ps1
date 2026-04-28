param(
    [string]$SetupPath = ".\build\PowerPilot_V1.0_Setup.exe",
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

function Test-PowerPilotRunningStable {
    param(
        [int]$ProbeCount = 4,
        [int]$DelayMs = 700
    )

    $probe = 0
    $running = $null

    for ($probe = 0; $probe -lt $ProbeCount; $probe++) {
        $running = Get-Process PowerPilot_V1.0 -ErrorAction SilentlyContinue
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
    $installedExe = Join-Path $env:ProgramFiles "PowerPilot\\PowerPilot_V1.0.exe"
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

$resolvedSetup = Resolve-UnderRepo -Path $SetupPath
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

$startParams = @{
    FilePath = $resolvedSetup
    ArgumentList = $arguments
    PassThru = $true
}

if (-not (Test-IsAdministrator)) {
    $startParams.Verb = "RunAs"
}

Write-Host "Setup:" $resolvedSetup
Write-Host "Log:" $resolvedLog
if (-not (Test-IsAdministrator)) {
    Write-Host "Requesting elevation for the installer..."
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
    Start-InstalledPowerPilotIfNeeded
}

Write-Host "Install result:" $resultText
Write-Host "Installer exit code:" $process.ExitCode
