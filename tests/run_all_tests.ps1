$ErrorActionPreference = "Stop"

$godot = if (Get-Command godot.exe -ErrorAction SilentlyContinue) {
    (Get-Command godot.exe).Source
} else {
    "C:\godot\godot.exe"
}

$tests = @(
    "res://tests/persistent_state_test.gd",
    "res://tests/pixel_pipeline_test.gd",
    "res://tests/lab_entry_test.gd",
    "res://tests/side_scroll_test.gd",
    "res://tests/anatomy_test.gd",
    "res://tests/brain_test.gd",
    "res://tests/performance_budget_test.gd",
    "res://tests/mutation_test.gd",
    "res://tests/lab_phase_test.gd",
    "res://tests/run_flow_test.gd",
    "res://tests/combat_smoke_test.gd",
    "res://tests/prototype_loop_test.gd"
)

foreach ($test in $tests) {
    Write-Host "RUN $test"
    $process = Start-Process -FilePath $godot -ArgumentList "--headless", "--path", ".", "--script", $test -PassThru -Wait
    if ($process.ExitCode -ne 0) {
        throw "Test failed: $test (exit $($process.ExitCode))"
    }
}

Write-Host "PASS: $($tests.Count) Kaiju Lab test scripts"
