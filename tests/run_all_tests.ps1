$ErrorActionPreference = "Stop"

$godot = (Get-Command godot.exe -ErrorAction Stop).Source
$tests = @(
    "res://tests/foundation_test.gd",
    "res://tests/biological_specimen_test.gd",
    "res://tests/lab_flow_test.gd",
    "res://tests/lab_render_test.gd",
    "res://tests/autonomous_battle_test.gd",
    "res://tests/wave_boss_test.gd",
    "res://tests/battle_render_test.gd",
    "res://tests/battle_result_test.gd",
    "res://tests/persistent_campaign_test.gd",
    "res://tests/corrupt_save_test.gd",
    "res://tests/second_map_test.gd",
    "res://tests/salvage_render_test.gd"
)

function Invoke-Godot([string[]] $Arguments) {
    $process = Start-Process -FilePath $godot -ArgumentList $Arguments -NoNewWindow -PassThru
    if (-not $process.WaitForExit(30000)) {
        $process.Kill()
        throw "Godot process timed out: $($Arguments -join ' ')"
    }
    $process.WaitForExit()
    return [int]$process.ExitCode
}

$importExitCode = Invoke-Godot @("--headless", "--editor", "--path", ".", "--quit")
if ($importExitCode -ne 0) {
    throw "Godot import/parser validation failed"
}

foreach ($test in $tests) {
    Write-Host "RUN $test"
    $testExitCode = Invoke-Godot @("--headless", "--path", ".", "--script", $test)
    if ($testExitCode -ne 0) {
        throw "Test failed: $test"
    }
}

Write-Host "PASS: $($tests.Count) Kaiju Lab test scripts"
