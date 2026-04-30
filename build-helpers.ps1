param(
    [string]$OutputDir = ".\build",
    [string]$CertificateThumbprint,
    [string]$TimestampUrl
)

$ErrorActionPreference = "Stop"

function Resolve-CSharpCompiler {
    $candidates = @(
        "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
        "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $command = Get-Command csc.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "csc.exe was not found."
}

function Resolve-VcVars64 {
    $candidates = @(
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "vcvars64.bat was not found. Install Visual Studio Build Tools with the C++ workload."
}

function Resolve-ClCompiler {
    $candidates = @(
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\cl.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $command = Get-Command cl.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "cl.exe was not found."
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

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputRoot = Join-Path $repoRoot $OutputDir
$null = New-Item -ItemType Directory -Path $outputRoot -Force

$windowsPmiHelperSourcePath = Join-Path $repoRoot "WindowsPmiHelper.cs"
$windowsPmiHelperOutputPath = Join-Path $outputRoot "PowerPilotWindowsPmiHelper.exe"
$windowsPmiHelperTempOutputPath = Join-Path $outputRoot "PowerPilotWindowsPmiHelper.build.exe"
$windowsPerfHelperSourcePath = Join-Path $repoRoot "WindowsPerfRefresherHelper.cs"
$windowsPerfHelperOutputPath = Join-Path $outputRoot "PowerPilotWindowsPerfHelper.exe"
$windowsPerfHelperTempOutputPath = Join-Path $outputRoot "PowerPilotWindowsPerfHelper.build.exe"
$windowsEmiHelperSourcePath = Join-Path $repoRoot "WindowsEmiHelper.c"
$windowsEmiHelperOutputPath = Join-Path $outputRoot "PowerPilotWindowsEmiHelper.exe"
$windowsEmiHelperTempOutputPath = Join-Path $outputRoot "PowerPilotWindowsEmiHelper.build.exe"
$amdAdlxHelperSourcePath = Join-Path $repoRoot "AmdAdlxHelper.cpp"
$amdAdlxHelperOutputPath = Join-Path $outputRoot "PowerPilotAmdAdlxHelper.exe"
$amdAdlxHelperTempOutputPath = Join-Path $outputRoot "PowerPilotAmdAdlxHelper.build.exe"
$amdAdlHelperSourcePath = Join-Path $repoRoot "AmdAdlHelper.cpp"
$amdAdlHelperOutputPath = Join-Path $outputRoot "PowerPilotAmdAdlHelper.exe"
$amdAdlHelperTempOutputPath = Join-Path $outputRoot "PowerPilotAmdAdlHelper.build.exe"

foreach ($requiredPath in @(
    $windowsPmiHelperSourcePath,
    $windowsPerfHelperSourcePath,
    $windowsEmiHelperSourcePath,
    $amdAdlxHelperSourcePath,
    $amdAdlHelperSourcePath
)) {
    if (-not (Test-Path $requiredPath)) {
        throw "Required helper source not found: $requiredPath"
    }
}

foreach ($tempPath in @(
    $windowsPmiHelperTempOutputPath,
    $windowsPerfHelperTempOutputPath,
    $windowsEmiHelperTempOutputPath,
    $amdAdlxHelperTempOutputPath,
    $amdAdlHelperTempOutputPath
)) {
    if (Test-Path $tempPath) {
        Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
    }
}

foreach ($legacyObjectPath in @(
    (Join-Path $repoRoot "AmdAdlxHelper.obj"),
    (Join-Path $repoRoot "AmdAdlHelper.obj"),
    (Join-Path $repoRoot "ADLXHelper.obj"),
    (Join-Path $repoRoot "WinAPIs.obj")
)) {
    if (Test-Path $legacyObjectPath) {
        Remove-Item -LiteralPath $legacyObjectPath -Force -ErrorAction SilentlyContinue
    }
}

$compiler = Resolve-CSharpCompiler

$args = @(
    "/nologo",
    "/target:exe",
    "/optimize+",
    "/platform:anycpu",
    "/reference:System.Management.dll",
    "/out:$windowsPmiHelperTempOutputPath",
    $windowsPmiHelperSourcePath
)

& $compiler @args
if ($LASTEXITCODE -ne 0) {
    throw "Windows PMI helper compilation failed."
}
Move-Item -LiteralPath $windowsPmiHelperTempOutputPath -Destination $windowsPmiHelperOutputPath -Force
Write-Host "Built Windows PMI helper:" $windowsPmiHelperOutputPath

$args = @(
    "/nologo",
    "/target:exe",
    "/optimize+",
    "/platform:anycpu",
    "/reference:Microsoft.CSharp.dll",
    "/reference:System.Management.dll",
    "/out:$windowsPerfHelperTempOutputPath",
    $windowsPerfHelperSourcePath
)

& $compiler @args
if ($LASTEXITCODE -ne 0) {
    throw "Windows perf helper compilation failed."
}
Move-Item -LiteralPath $windowsPerfHelperTempOutputPath -Destination $windowsPerfHelperOutputPath -Force
Write-Host "Built Windows perf helper:" $windowsPerfHelperOutputPath

$cl = Resolve-ClCompiler
$vcvars = Resolve-VcVars64

$cmdLine =
    "`"$vcvars`" >nul && " +
    "`"$cl`" /nologo /O2 /TC /DUNICODE /D_UNICODE /Fe:`"$windowsEmiHelperTempOutputPath`" `"$windowsEmiHelperSourcePath`" /link setupapi.lib"

Push-Location $repoRoot
try {
    cmd.exe /c $cmdLine
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "Windows EMI helper compilation failed."
}
Move-Item -LiteralPath $windowsEmiHelperTempOutputPath -Destination $windowsEmiHelperOutputPath -Force
Write-Host "Built Windows EMI helper:" $windowsEmiHelperOutputPath

$adlxSdkDir = $env:ADLX_SDK_DIR
$adlxEnabled = $false
$adlxCompileSources = @($amdAdlxHelperSourcePath)
$adlxIncludeArgs = @()
$adlxDefineArgs = @()

if ($adlxSdkDir) {
    $adlxHelperCpp = Join-Path $adlxSdkDir "SDK\ADLXHelper\Windows\Cpp\ADLXHelper.cpp"
    $adlxWinApisCpp = Join-Path $adlxSdkDir "SDK\Platform\Windows\WinAPIs.cpp"
    $adlxHeader = Join-Path $adlxSdkDir "SDK\ADLXHelper\Windows\Cpp\ADLXHelper.h"

    if ((Test-Path $adlxHelperCpp) -and (Test-Path $adlxWinApisCpp) -and (Test-Path $adlxHeader)) {
        $adlxEnabled = $true
        $adlxCompileSources += @($adlxHelperCpp, $adlxWinApisCpp)
        $adlxIncludeArgs += @("/I`"$adlxSdkDir`"")
        $adlxDefineArgs += @("/DPOWERPILOT_ENABLE_ADLX_SDK=1")
    }
    else {
        Write-Warning "ADLX_SDK_DIR is set but the expected ADLX SDK helper files were not found. Building the safe unavailable helper."
    }
}

$cmdParts = @(
    "`"$vcvars`" >nul &&",
    "`"$cl`"",
    "/nologo",
    "/O2",
    "/EHsc",
    "/std:c++17",
    "/DUNICODE",
    "/D_UNICODE"
) + $adlxDefineArgs + $adlxIncludeArgs + @(
    "/Fe:`"$amdAdlxHelperTempOutputPath`""
)

foreach ($sourcePath in $adlxCompileSources) {
    $cmdParts += "`"$sourcePath`""
}

$cmdParts += @("/link", "ole32.lib")
$cmdLine = $cmdParts -join " "

Push-Location $repoRoot
try {
    cmd.exe /c $cmdLine
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "AMD ADLX helper compilation failed."
}
Move-Item -LiteralPath $amdAdlxHelperTempOutputPath -Destination $amdAdlxHelperOutputPath -Force
if ($adlxEnabled) {
    Write-Host "Built AMD ADLX helper with ADLX SDK:" $amdAdlxHelperOutputPath
}
else {
    Write-Host "Built AMD ADLX helper without ADLX SDK support:" $amdAdlxHelperOutputPath
}

$cmdLine =
    "`"$vcvars`" >nul && " +
    "`"$cl`" /nologo /O2 /EHsc /std:c++17 /DUNICODE /D_UNICODE /Fe:`"$amdAdlHelperTempOutputPath`" `"$amdAdlHelperSourcePath`""

Push-Location $repoRoot
try {
    cmd.exe /c $cmdLine
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "AMD ADL helper compilation failed."
}
Move-Item -LiteralPath $amdAdlHelperTempOutputPath -Destination $amdAdlHelperOutputPath -Force
Write-Host "Built AMD ADL probe helper:" $amdAdlHelperOutputPath

if ($CertificateThumbprint) {
    $certificate = Get-CodeSigningCertificate -Thumbprint $CertificateThumbprint

    foreach ($helperPath in @(
        $windowsPmiHelperOutputPath,
        $windowsPerfHelperOutputPath,
        $windowsEmiHelperOutputPath,
        $amdAdlxHelperOutputPath,
        $amdAdlHelperOutputPath
    )) {
        Sign-ProjectArtifact -Path $helperPath -Certificate $certificate -TimestampServer $TimestampUrl
    }

    Write-Host "Helper signer:" $certificate.Subject
}
