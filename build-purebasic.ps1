param(
    [string]$Source = ".\PowerPilot_V1.0.pb",
    [string]$OutputDir = ".\build",
    [string]$CertificateThumbprint,
    [string]$TimestampUrl
)

$ErrorActionPreference = "Stop"

function Resolve-PureBasicCompiler {
    $candidates = @(
        "C:\Program Files\PureBasic\Compilers\pbcompiler.exe",
        "C:\Program Files (x86)\PureBasic\Compilers\pbcompiler.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $command = Get-Command pbcompiler -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "pbcompiler was not found. Install PureBasic or add pbcompiler to PATH."
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

function Update-PureBasicAppVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $now = Get-Date
    $monthStart = Get-Date -Year $now.Year -Month $now.Month -Day 1 -Hour 0 -Minute 0 -Second 0
    $minutesSinceMonthStart = [int][Math]::Floor(($now - $monthStart).TotalMinutes)
    $appVersion = "1.0.{0}.{1:D5}" -f $now.ToString("yyMM"), $minutesSinceMonthStart

    $content = Get-Content -LiteralPath $Path -Raw
    $versionPattern = '(?m)^#AppVersion\$\s*=\s*"[^"]*"'

    if ($content -notmatch $versionPattern) {
        throw "App version constant not found in $Path."
    }

    $updated = [regex]::Replace($content, $versionPattern, '#AppVersion$         = "' + $appVersion + '"', 1)
    Set-Content -LiteralPath $Path -Value $updated -NoNewline

    return $appVersion
}

$compiler = Resolve-PureBasicCompiler

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = Join-Path $repoRoot $Source

if (-not (Test-Path $sourcePath)) {
    throw "Source file not found: $sourcePath"
}

$resolvedSource = (Resolve-Path $sourcePath).Path
$appVersion = Update-PureBasicAppVersion -Path $resolvedSource
$outputRoot = Join-Path $repoRoot $OutputDir
$null = New-Item -ItemType Directory -Path $outputRoot -Force
$iconPath = Join-Path $repoRoot "powerpilot.ico"

$exeName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedSource) + ".exe"
$outputPath = Join-Path $outputRoot $exeName

$compileArgs = @($resolvedSource, "/THREAD", "/OPTIMIZER", "/OUTPUT", $outputPath)
if (Test-Path $iconPath) {
    $compileArgs += @("/ICON", $iconPath)
}

Write-Host "Using PureBasic compiler:" $compiler
Write-Host "App version:" $appVersion

$compilerDir = Split-Path -Parent $compiler
Push-Location $compilerDir
try {
    & $compiler @compileArgs
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "PureBasic compilation failed."
}

Write-Host "Built:" $outputPath

if ($CertificateThumbprint) {
    $certificate = Get-CodeSigningCertificate -Thumbprint $CertificateThumbprint

    $signingParams = @{
        FilePath = $outputPath
        Certificate = $certificate
        HashAlgorithm = "SHA256"
    }

    if ($TimestampUrl) {
        $signingParams.TimestampServer = $TimestampUrl
    }

    $signature = Set-AuthenticodeSignature @signingParams

    if ($signature.Status -ne "Valid") {
        throw "Signing failed: $($signature.Status) - $($signature.StatusMessage)"
    }

    Write-Host "Signed:" $outputPath
    Write-Host "Signer:" $certificate.Subject
}
