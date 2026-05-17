param(
    [string]$ChatTitle = "",
    [string]$ChatText = "",
    [switch]$SaveChatFromClipboard,
    [switch]$SkipSnapshot,
    [string]$AppVersion = "",
    [string]$CertificateThumbprint,
    [string]$TimestampUrl,
    [int]$SnapshotRetention = 8,
    [int]$ChatRetention = 30
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedRepoRoot = (Resolve-Path $repoRoot).Path

function Get-ProjectRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = (Resolve-Path $Path).Path
    $rootUri = New-Object System.Uri(($resolvedRepoRoot.TrimEnd("\") + "\"))
    $pathUri = New-Object System.Uri($resolvedPath)

    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("/", "\")
}

function Get-SnapshotSourceFiles {
    $allowedExtensions = @(
        ".pb",
        ".ps1",
        ".iss",
        ".cs",
        ".c",
        ".h",
        ".md",
        ".txt",
        ".json",
        ".yml",
        ".yaml",
        ".ico",
        ".png"
    )

    return Get-ChildItem -Path $repoRoot -Recurse -File | Where-Object {
        $relative = Get-ProjectRelativePath -Path $_.FullName

        if ($relative.StartsWith("build\")) { return $false }
        if ($relative.StartsWith("SNAPSHOTS\")) { return $false }
        if ($relative.StartsWith("CHAT_MEMORY\logs\")) { return $false }

        if ($_.Name -eq ".gitignore") { return $true }

        return $allowedExtensions -contains $_.Extension.ToLowerInvariant()
    } | Sort-Object FullName
}

function Get-GitSnapshotStatus {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        return "Git status unavailable: git was not found."
    }

    if (-not (Test-Path (Join-Path $repoRoot ".git"))) {
        return "Git status unavailable: this folder is not in a git work tree."
    }

    $probe = & $git.Source -C $repoRoot rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or ($probe | Select-Object -First 1) -ne "true") {
        return "Git status unavailable: this folder is not in a git work tree."
    }

    $branch = (& $git.Source -C $repoRoot branch --show-current 2>$null | Out-String).Trim()
    $statusLines = @(& $git.Source -C $repoRoot status --short 2>$null)
    $lines = @()

    if (-not [string]::IsNullOrWhiteSpace($branch)) {
        $lines += "Branch: $branch"
    }

    if ($statusLines.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace(($statusLines | Out-String).Trim())) {
        $lines += "Working tree:"
        $lines += $statusLines
    }
    else {
        $lines += "Working tree: clean"
    }

    return ($lines -join [Environment]::NewLine)
}

function Cleanup-OldSnapshots {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SnapshotRoot,
        [Parameter(Mandatory = $true)]
        [int]$Retention
    )

    if ($Retention -lt 1) {
        $Retention = 1
    }

    $archives = Get-ChildItem -Path $SnapshotRoot -Filter "powerpilot-prebuild-*.zip" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending

    $archives | Select-Object -Skip $Retention | ForEach-Object {
        Remove-Item -LiteralPath $_.FullName -Force
    }
}

function Create-PreBuildSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Retention
    )

    $snapshotRoot = Join-Path $repoRoot "SNAPSHOTS"
    $null = New-Item -ItemType Directory -Path $snapshotRoot -Force

    $stamp = Get-Date
    $stampFile = $stamp.ToString("yyyy-MM-dd_HH-mm-ss")
    $baseName = "powerpilot-prebuild-$stampFile"
    $snapshotPath = Join-Path $snapshotRoot "$baseName.zip"
    $stageDir = Join-Path $snapshotRoot "$baseName.tmp"

    if (Test-Path $stageDir) {
        Remove-Item -LiteralPath $stageDir -Recurse -Force
    }

    $null = New-Item -ItemType Directory -Path $stageDir -Force

    try {
        $files = @(Get-SnapshotSourceFiles)
        if ($files.Count -eq 0) {
            throw "No snapshot source files were found."
        }

        foreach ($file in $files) {
            $relative = Get-ProjectRelativePath -Path $file.FullName
            $target = Join-Path $stageDir $relative
            $targetDir = Split-Path -Parent $target

            if (-not (Test-Path $targetDir)) {
                $null = New-Item -ItemType Directory -Path $targetDir -Force
            }

            Copy-Item -LiteralPath $file.FullName -Destination $target -Force
        }

        $manifestPath = Join-Path $stageDir "SNAPSHOT_INFO.txt"
        $gitStatus = Get-GitSnapshotStatus
        $manifest = @"
PowerPilot pre-build snapshot

Created: $($stamp.ToString("yyyy-MM-dd HH:mm:ss zzz"))
Archive: $snapshotPath
Included files: $($files.Count)

Git status:
$gitStatus
"@
        Set-Content -LiteralPath $manifestPath -Value $manifest -Encoding UTF8

        if (Test-Path $snapshotPath) {
            Remove-Item -LiteralPath $snapshotPath -Force
        }

        Compress-Archive -Path (Join-Path $stageDir "*") -DestinationPath $snapshotPath -CompressionLevel Optimal
    }
    finally {
        if (Test-Path $stageDir) {
            Remove-Item -LiteralPath $stageDir -Recurse -Force
        }
    }

    Cleanup-OldSnapshots -SnapshotRoot $snapshotRoot -Retention $Retention

    return [PSCustomObject]@{
        FullName = $snapshotPath
        RelativePath = Get-ProjectRelativePath -Path $snapshotPath
        Name = Split-Path -Leaf $snapshotPath
        Created = $stamp
        FileCount = $files.Count
    }
}

function Resolve-IsccPath {
    $iscc = Get-Command iscc -ErrorAction SilentlyContinue
    if (-not $iscc) {
        $fallbacks = @(
            "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
            "C:\Program Files\Inno Setup 6\ISCC.exe",
            "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
        )

        foreach ($fallback in $fallbacks) {
            if (Test-Path $fallback) {
                $iscc = Get-Item $fallback
                break
            }
        }
    }

    if (-not $iscc) {
        throw "ISCC.exe was not found. Install Inno Setup 6 and try again."
    }

    if ($iscc.Source) {
        return $iscc.Source
    }
    if ($iscc.Path) {
        return $iscc.Path
    }

    return $iscc.FullName
}

function Get-ClipboardChatText {
    try {
        Add-Type -AssemblyName System.Windows.Forms

        if ([System.Windows.Forms.Clipboard]::ContainsText()) {
            return [System.Windows.Forms.Clipboard]::GetText()
        }
    }
    catch {
        Write-Warning "Clipboard chat capture was requested, but clipboard text could not be read."
    }

    return ""
}

function Get-ArtifactInfo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "Artifact not found: $Path"
    }

    $item = Get-Item $Path
    $hash = (Get-FileHash $Path -Algorithm SHA256).Hash

    return [PSCustomObject]@{
        Name = $item.Name
        RelativePath = Resolve-Path -Relative $item.FullName
        FullName = $item.FullName
        Length = $item.Length
        LastWriteTime = $item.LastWriteTime
        Sha256 = $hash
    }
}

function Get-CodeSigningCertificate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Thumbprint
    )

    $normalizedThumbprint = ($Thumbprint -replace "\s", "").ToUpperInvariant()
    $stores = @("Cert:\CurrentUser\My", "Cert:\LocalMachine\My")

    foreach ($store in $stores) {
        $match = Get-ChildItem -Path $store -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Thumbprint -eq $normalizedThumbprint -and
                $_.HasPrivateKey -and
                (
                    $_.EnhancedKeyUsageList.ObjectId -contains "1.3.6.1.5.5.7.3.3" -or
                    $_.EnhancedKeyUsageList.FriendlyName -contains "Code Signing"
                )
            } |
            Select-Object -First 1

        if ($match) {
            return $match
        }
    }

    throw "Code-signing certificate not found for thumbprint $normalizedThumbprint in Cert:\CurrentUser\My or Cert:\LocalMachine\My."
}

function Sign-ProjectArtifact {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [object]$Certificate,
        [string]$TimestampServer
    )

    $signingParams = @{
        FilePath = $Path
        Certificate = $Certificate
        HashAlgorithm = "SHA256"
    }

    if ($TimestampServer) {
        $signingParams.TimestampServer = $TimestampServer
    }

    $signature = Set-AuthenticodeSignature @signingParams

    if ($signature.Status -ne "Valid") {
        throw "Signing failed for $Path`: $($signature.Status) - $($signature.StatusMessage)"
    }

    Write-Host "Signed:" $Path
}

function Remove-StaleInstallerArtifacts {
    param(
        [Parameter(Mandatory = $true)]
        [object]$ArtifactNames
    )

    $buildDir = Join-Path $repoRoot "build"
    $staleArtifacts = @()
    $staleArtifacts += Get-ChildItem -Path $buildDir -Filter "PowerPilot_V*_Setup.exe" -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne $ArtifactNames.SetupName }
    $staleArtifacts += Get-ChildItem -Path $buildDir -Filter "PowerPilot_V*_Setup.exe.sha256" -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "$($ArtifactNames.SetupName).sha256" }

    $staleArtifacts | Remove-Item -Force
}

function Write-StartupContext {
    param(
        [Parameter(Mandatory = $true)]
        [object]$ExeInfo,
        [Parameter(Mandatory = $true)]
        [object]$SetupInfo,
        [object]$SnapshotInfo,
        [Parameter(Mandatory = $true)]
        [int]$SnapshotRetention,
        [Parameter(Mandatory = $true)]
        [int]$ChatRetention
    )

    $path = Join-Path $repoRoot "STARTUP_CONTEXT.md"
    $today = Get-Date -Format "yyyy-MM-dd"
    $exeSize = "{0:N0}" -f $ExeInfo.Length
    $setupSize = "{0:N0}" -f $SetupInfo.Length
    $exeTime = $ExeInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    $setupTime = $SetupInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    $snapshotSection = if ($SnapshotInfo) {
@"

## Latest snapshot

- Archive: $($SnapshotInfo.RelativePath)
- Created: $($SnapshotInfo.Created.ToString("yyyy-MM-dd HH:mm:ss"))
- Source files captured: $($SnapshotInfo.FileCount)
"@
    }
    else {
@"

## Latest snapshot

- Snapshot was skipped for this run.
"@
    }

    $content = @"
# PowerPilot Startup Context

Last updated: $today

## Verified build state

- Source file compiled successfully: PowerPilot_V1.2.pb
- Main build artifact verified: $($ExeInfo.RelativePath)
- Installer assembly verified: $($SetupInfo.RelativePath)

Latest verified artifact details:

- $($ExeInfo.RelativePath)
  - Size: $exeSize bytes
  - Last write time: $exeTime
  - SHA-256: $($ExeInfo.Sha256)
- $($SetupInfo.RelativePath)
  - Size: $setupSize bytes
  - Last write time: $setupTime
  - SHA-256: $($SetupInfo.Sha256)

## Current feature notes

- Control keeps only the Maximum, Balanced, and Battery plans.
- The tray app follows Windows power mode: Best performance, Balanced, or Best power efficiency.
- Plan creation refreshes PowerPilot plans from the current non-PowerPilot Windows plan when one is selected.
- CPU information comes from CPUID inline assembly.
- GPU names come from Windows display adapter enumeration plus CPU-based iGPU resolution, without helpers.

## Installer status

- Installer assembly was rebuilt successfully with build-installer.ps1.
- Latest install verification, when available, is tracked in `CHAT_MEMORY\LATEST_INSTALL.md`.
- This file confirms build and installer assembly status inside the project directory for quick startup reference.

## Retention defaults

- Snapshot archives kept: $SnapshotRetention
- Chat-memory entries kept: $ChatRetention
$snapshotSection

## Where to look first on a new startup

1. README.md
2. STARTUP_CONTEXT.md
3. CHAT_MEMORY\CURRENT_CONTEXT.md
4. CHAT_MEMORY\LATEST_BUILD.md
5. CHAT_MEMORY\LATEST_INSTALL.md
6. CHAT_MEMORY\INDEX.md

## Working habit reminder

- Take regular snapshots or commits.
- Good times to snapshot:
  - before changing power-plan logic
  - before rebuilding the installer
  - before running elevated install or uninstall steps
  - before larger UI or power-plan refactors
"@

    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
}

function Write-LatestBuildContext {
    param(
        [Parameter(Mandatory = $true)]
        [object]$ExeInfo,
        [Parameter(Mandatory = $true)]
        [object]$SetupInfo,
        [object]$SnapshotInfo,
        [Parameter(Mandatory = $true)]
        [int]$SnapshotRetention,
        [Parameter(Mandatory = $true)]
        [int]$ChatRetention
    )

    $path = Join-Path $repoRoot "CHAT_MEMORY\LATEST_BUILD.md"
    $stamp = Get-Date
    $exeSize = "{0:N0}" -f $ExeInfo.Length
    $setupSize = "{0:N0}" -f $SetupInfo.Length
    $exeTime = $ExeInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    $setupTime = $SetupInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    $snapshotSummary = if ($SnapshotInfo) {
@"

## Snapshot

- Archive: $($SnapshotInfo.RelativePath)
- Created: $($SnapshotInfo.Created.ToString("yyyy-MM-dd HH:mm:ss"))
- Source files captured: $($SnapshotInfo.FileCount)
"@
    }
    else {
@"

## Snapshot

- Snapshot was skipped for this run.
"@
    }

    $content = @"
# Latest Build

Generated: $($stamp.ToString("yyyy-MM-dd HH:mm:ss zzz"))

## Result

- PureBasic build: success
- Installer assembly: success

## Artifacts

- $($ExeInfo.RelativePath)
  - Size: $exeSize bytes
  - Last write time: $exeTime
  - SHA-256: $($ExeInfo.Sha256)
- $($SetupInfo.RelativePath)
  - Size: $setupSize bytes
  - Last write time: $setupTime
  - SHA-256: $($SetupInfo.Sha256)
$snapshotSummary

## Retention defaults

- Snapshot archives kept: $SnapshotRetention
- Chat-memory entries kept: $ChatRetention

## Reminder

- Save important chat notes into CHAT_MEMORY\logs
- Take regular snapshots before risky changes or install steps

## Feature reminders

- PowerPilot keeps only the Maximum, Balanced, and Battery plans.
- PowerPilot follows Windows power mode and maps it to Maximum, Balanced, or Battery.
- PowerPilot no longer uses temperature, package-power telemetry, or helper executables.
- GPU names come from Windows display adapter enumeration plus CPU-based iGPU resolution.
"@

    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
}

function Save-BuildMemory {
    param(
        [Parameter(Mandatory = $true)]
        [object]$ExeInfo,
        [Parameter(Mandatory = $true)]
        [object]$SetupInfo,
        [object]$SnapshotInfo,
        [Parameter(Mandatory = $true)]
        [int]$ChatRetention
    )

    $saveScript = Join-Path $repoRoot "CHAT_MEMORY\save-chat-memory.ps1"
    if (-not (Test-Path $saveScript)) {
        Write-Warning "Chat memory helper not found: $saveScript"
        return
    }

    $capturedChat = $ChatText
    if ([string]::IsNullOrWhiteSpace($capturedChat) -and $SaveChatFromClipboard) {
        $capturedChat = Get-ClipboardChatText
    }

    $stamp = Get-Date
    $title = $ChatTitle
    if ([string]::IsNullOrWhiteSpace($title)) {
        $title = "installer build " + $stamp.ToString("yyyy-MM-dd HH-mm-ss")
    }

    $text = @"
Installer build completed successfully on $($stamp.ToString("yyyy-MM-dd HH:mm:ss zzz")).

Artifacts:

- $($ExeInfo.RelativePath)
  - Size: $("{0:N0}" -f $ExeInfo.Length) bytes
  - SHA-256: $($ExeInfo.Sha256)
- $($SetupInfo.RelativePath)
  - Size: $("{0:N0}" -f $SetupInfo.Length) bytes
  - SHA-256: $($SetupInfo.Sha256)

Project memory refreshed:

- STARTUP_CONTEXT.md
- CHAT_MEMORY\LATEST_BUILD.md
"@

    if ($SnapshotInfo) {
        $text += @"
- $($SnapshotInfo.RelativePath)
"@
    }

    $text += @"

Retention:

- chat-memory entries kept: $ChatRetention
- snapshot archives kept: $SnapshotRetention

Reminder:

- take regular snapshots or commits before installer changes, elevated install steps, and risky logic edits
"@

    if (-not [string]::IsNullOrWhiteSpace($capturedChat)) {
        $text += @"

## Captured Chat Notes

$capturedChat
"@
    }

    & $saveScript -Title $title -Text $text -Retention $ChatRetention
}

function Sync-InnoAppVersion {
    $sourcePath = Join-Path $repoRoot "PowerPilot_V1.2.pb"
    $installerPath = Join-Path $repoRoot "powerpilot.iss"
    $sourceText = Get-Content -LiteralPath $sourcePath -Raw

    if ($sourceText -notmatch '(?m)^#AppVersion\$\s*=\s*"([^"]+)"') {
        throw "Could not read #AppVersion$ from $sourcePath."
    }

    $appVersion = $Matches[1]
    $exeName = "PowerPilot_V{0}.exe" -f $appVersion
    $setupName = "PowerPilot_V{0}_Setup.exe" -f $appVersion
    $setupBaseName = [System.IO.Path]::GetFileNameWithoutExtension($setupName)
    $installerText = Get-Content -LiteralPath $installerPath -Raw
    $updatedInstallerText = $installerText
    $updatedInstallerText = [regex]::Replace($updatedInstallerText, '(?m)^#define AppVersion "[^"]+"', '#define AppVersion "' + $appVersion + '"', 1)
    $updatedInstallerText = [regex]::Replace($updatedInstallerText, '(?m)^#define AppExeName "[^"]+"', '#define AppExeName "' + $exeName + '"', 1)
    $updatedInstallerText = [regex]::Replace($updatedInstallerText, '(?m)^#define AppSetupName "[^"]+"', '#define AppSetupName "' + $setupName + '"', 1)
    $updatedInstallerText = [regex]::Replace($updatedInstallerText, '(?m)^OutputBaseFilename=.+$', 'OutputBaseFilename=' + $setupBaseName, 1)

    Set-Content -LiteralPath $installerPath -Value $updatedInstallerText -NoNewline
    Write-Host "Installer AppVersion:" $appVersion
    Write-Host "Installer AppExeName:" $exeName
    Write-Host "Installer AppSetupName:" $setupName

    return [PSCustomObject]@{
        AppVersion = $appVersion
        ExeName = $exeName
        SetupName = $setupName
    }
}

Push-Location $repoRoot

try {
    $snapshotInfo = $null
    if ($SkipSnapshot) {
        Write-Host "Pre-build snapshot skipped."
    }
    else {
        $snapshotInfo = Create-PreBuildSnapshot -Retention $SnapshotRetention
        Write-Host "Pre-build snapshot created:" $snapshotInfo.RelativePath
    }

    $buildArgs = @{}
    if (-not [string]::IsNullOrWhiteSpace($AppVersion)) {
        $buildArgs.AppVersion = $AppVersion.Trim()
    }
    if (-not [string]::IsNullOrWhiteSpace($CertificateThumbprint)) {
        $buildArgs.CertificateThumbprint = $CertificateThumbprint
    }
    if (-not [string]::IsNullOrWhiteSpace($TimestampUrl)) {
        $buildArgs.TimestampUrl = $TimestampUrl
    }
    .\build-purebasic.ps1 @buildArgs
    $artifactNames = Sync-InnoAppVersion
    Remove-StaleInstallerArtifacts -ArtifactNames $artifactNames

    $isccPath = Resolve-IsccPath
    & $isccPath ".\powerpilot.iss"

    if ($LASTEXITCODE -ne 0) {
        throw "Inno Setup compilation failed."
    }

    $exePath = Join-Path $repoRoot ("build\{0}" -f $artifactNames.ExeName)
    $setupPath = Join-Path $repoRoot ("build\{0}" -f $artifactNames.SetupName)

    if ($CertificateThumbprint) {
        $certificate = Get-CodeSigningCertificate -Thumbprint $CertificateThumbprint
        Sign-ProjectArtifact -Path $setupPath -Certificate $certificate -TimestampServer $TimestampUrl
        Write-Host "Installer signer:" $certificate.Subject
    }

    $exeInfo = Get-ArtifactInfo -Path $exePath
    $setupInfo = Get-ArtifactInfo -Path $setupPath

    Write-StartupContext -ExeInfo $exeInfo -SetupInfo $setupInfo -SnapshotInfo $snapshotInfo -SnapshotRetention $SnapshotRetention -ChatRetention $ChatRetention
    Write-LatestBuildContext -ExeInfo $exeInfo -SetupInfo $setupInfo -SnapshotInfo $snapshotInfo -SnapshotRetention $SnapshotRetention -ChatRetention $ChatRetention
    try {
        Save-BuildMemory -ExeInfo $exeInfo -SetupInfo $setupInfo -SnapshotInfo $snapshotInfo -ChatRetention $ChatRetention
    }
    catch {
        Write-Warning "Chat memory update failed: $($_.Exception.Message)"
    }

    Write-Host "Installer built in build\"
    Write-Host "Startup context updated: STARTUP_CONTEXT.md"
    Write-Host "Latest build context updated: CHAT_MEMORY\\LATEST_BUILD.md"
    if ($snapshotInfo) {
        Write-Host "Snapshot saved:" $snapshotInfo.RelativePath
    }
}
finally {
    Pop-Location
}
