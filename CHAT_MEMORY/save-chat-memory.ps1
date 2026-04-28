param(
    [string]$Title = "",
    [string]$Text = "",
    [switch]$FromClipboard,
    [int]$Retention = 30
)

$ErrorActionPreference = "Stop"

$memoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsDir = Join-Path $memoryRoot "logs"
$indexPath = Join-Path $memoryRoot "INDEX.md"

function New-Slug {
    param([string]$Value)

    $clean = $Value.Trim().ToLowerInvariant()
    $clean = [regex]::Replace($clean, "[^a-z0-9]+", "-")
    $clean = $clean.Trim("-")

    if ([string]::IsNullOrWhiteSpace($clean)) {
        return "chat-memory"
    }

    return $clean
}

function Get-ChatLogFiles {
    if (-not (Test-Path $logsDir)) {
        return @()
    }

    return Get-ChildItem -Path $logsDir -Filter "*.md" -File |
        Where-Object { $_.Name -ne "README.md" } |
        Sort-Object LastWriteTime -Descending
}

function Get-LogTitle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $firstHeading = Get-Content -LiteralPath $Path -TotalCount 1 -ErrorAction SilentlyContinue
    if ($firstHeading -and $firstHeading.StartsWith("# ")) {
        return $firstHeading.Substring(2).Trim()
    }

    return [System.IO.Path]::GetFileNameWithoutExtension($Path)
}

function Cleanup-OldChatLogs {
    param(
        [Parameter(Mandatory = $true)]
        [int]$KeepCount
    )

    if ($KeepCount -lt 1) {
        $KeepCount = 1
    }

    $files = @(Get-ChatLogFiles)
    $files | Select-Object -Skip $KeepCount | ForEach-Object {
        Remove-Item -LiteralPath $_.FullName -Force
    }
}

function Write-IndexFile {
    $entries = @(Get-ChatLogFiles)
    $savedLines = @()

    foreach ($entry in $entries) {
        $title = Get-LogTitle -Path $entry.FullName
        $savedLines += "- $($entry.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss zzz")) : [$title](logs/$($entry.Name))"
    }

    if ($savedLines.Count -eq 0) {
        $savedLines += "- No saved entries yet."
    }

    $savedBlock = $savedLines -join [Environment]::NewLine

    $content = @"
# Chat Memory Index

Use this folder to keep session summaries and pasted chat transcripts close to the codebase.

Important limit:

- Full automatic capture of IDE chat history is not available from this repo alone because the editor chat stream is not exposed to the local project files.
- The helper script here gives a fast local save path so the repo can still keep durable memory between sessions.

## Current pinned files

- CURRENT_CONTEXT.md for the latest working summary
- LATEST_BUILD.md for the latest auto-generated installer-build summary
- ..\STARTUP_CONTEXT.md for build and installer verification

## Retention defaults

- chat-memory entries kept: $Retention
- snapshot archives are trimmed by build-installer.ps1, default: 8

## Saving new chat memory

Example:

    powershell
    .\CHAT_MEMORY\save-chat-memory.ps1 -FromClipboard -Title "dGPU display recovery"

You can also pass text directly:

    powershell
    .\CHAT_MEMORY\save-chat-memory.ps1 -Title "session note" -Text "Summary goes here"

## Saved entries

$savedBlock
"@

    Set-Content -LiteralPath $indexPath -Value $content -Encoding UTF8
}

if ($Retention -lt 1) {
    $Retention = 1
}

if ([string]::IsNullOrWhiteSpace($Text) -and $FromClipboard) {
    Add-Type -AssemblyName System.Windows.Forms

    if ([System.Windows.Forms.Clipboard]::ContainsText()) {
        $Text = [System.Windows.Forms.Clipboard]::GetText()
    }
}

if ([string]::IsNullOrWhiteSpace($Text)) {
    throw "No chat text was provided. Use -Text or -FromClipboard."
}

$null = New-Item -ItemType Directory -Path $logsDir -Force

$stamp = Get-Date
$stampFile = $stamp.ToString("yyyy-MM-dd_HH-mm-ss")

if ([string]::IsNullOrWhiteSpace($Title)) {
    $Title = "Chat memory $stampFile"
}

$slug = New-Slug -Value $Title
$fileName = "$stampFile-$slug.md"
$filePath = Join-Path $logsDir $fileName

$content = @"
# $Title

Saved: $($stamp.ToString("yyyy-MM-dd HH:mm:ss zzz"))

$Text
"@

Set-Content -LiteralPath $filePath -Value $content -Encoding UTF8
Cleanup-OldChatLogs -KeepCount $Retention
Write-IndexFile

Write-Host "Saved chat memory:" $filePath
