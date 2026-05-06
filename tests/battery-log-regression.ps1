param(
    [string]$Path = (Join-Path $PSScriptRoot "battery-log-sample.csv")
)

$ErrorActionPreference = "Stop"
$rows = Import-Csv -LiteralPath $Path

function Phase($row) {
    $connected = [int]($row.connected -as [int])
    $charging = [int]($row.charging -as [int])
    $disconnected = [int]($row.disconnected_battery -as [int])
    if ($connected -eq 0 -and $disconnected -eq 1) { return "OnBatteryNormal" }
    if ($connected -eq 1 -and $charging -eq 1) { return "Charging" }
    if ($connected -eq 1 -and $charging -eq 0 -and $disconnected -eq 1) { return "PluggedDischargingCalibration" }
    if ($connected -eq 1 -and $charging -eq 0 -and $disconnected -eq 0) { return "PluggedIdleOrFull" }
    return "Unknown"
}

$batteryRows = $rows | Where-Object { $_.row_type -eq "battery" }
$phases = $batteryRows | ForEach-Object { Phase $_ }
if ($phases -notcontains "OnBatteryNormal") { throw "Expected OnBatteryNormal rows." }
if ($phases -notcontains "Charging") { throw "Expected Charging rows." }
if ($phases -notcontains "PluggedDischargingCalibration") { throw "Expected calibration discharge rows." }

$stableFull = ($batteryRows |
    Where-Object { [double]$_.full_mwh -ge 46500 -and [double]$_.full_mwh -le 47500 } |
    Select-Object -Last 1).full_mwh -as [double]
if ([Math]::Abs($stableFull - 46990) -gt 100) {
    throw "Stable capacity should stay near 47 Wh, got $stableFull mWh."
}

$normal = $batteryRows | Where-Object { (Phase $_) -eq "OnBatteryNormal" }
$calibration = $batteryRows | Where-Object { (Phase $_) -eq "PluggedDischargingCalibration" }
if (($calibration | Where-Object { [double]$_.discharge_rate_mw -gt 15000 }).Count -eq 0) {
    throw "Fixture should include heavy calibration discharge."
}

$plateau = 0
for ($i = 1; $i -lt $normal.Count; $i++) {
    $prev = $normal[$i - 1]
    $cur = $normal[$i]
    if ([double]$cur.battery_percent -lt 7 -and
        [Math]::Abs(([double]$prev.battery_percent) - ([double]$cur.battery_percent)) -lt 0.02 -and
        [Math]::Abs(([double]$prev.remaining_mwh) - ([double]$cur.remaining_mwh)) -lt 1 -and
        [double]$cur.discharge_rate_mw -gt 0) {
        $plateau++
    }
}
if ($plateau -lt 2) { throw "Expected low-battery plateau detection." }

"battery-log regression passed"
