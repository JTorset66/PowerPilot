param(
    [string]$OutputDir = ".\build"
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

foreach ($requiredPath in @(
    $windowsPmiHelperSourcePath,
    $windowsPerfHelperSourcePath,
    $windowsEmiHelperSourcePath
)) {
    if (-not (Test-Path $requiredPath)) {
        throw "Required helper source not found: $requiredPath"
    }
}

foreach ($tempPath in @(
    $windowsPmiHelperTempOutputPath,
    $windowsPerfHelperTempOutputPath,
    $windowsEmiHelperTempOutputPath
)) {
    if (Test-Path $tempPath) {
        Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
    }
}

$legacyAmdHelperOutputPath = Join-Path $outputRoot "PowerPilotAmdAdlxHelper.exe"
if (Test-Path $legacyAmdHelperOutputPath) {
    Remove-Item -LiteralPath $legacyAmdHelperOutputPath -Force -ErrorAction SilentlyContinue
}

foreach ($legacyObjectPath in @(
    (Join-Path $repoRoot "AmdAdlxHelper.obj"),
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
