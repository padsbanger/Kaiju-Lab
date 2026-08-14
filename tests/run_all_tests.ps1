$ErrorActionPreference = "Stop"

$godot = (Get-Command godot.exe -ErrorAction Stop).Source
$tests = @(
    "res://tests/foundation_test.gd",
    "res://tests/biological_specimen_test.gd"
)

function Invoke-Godot([string[]] $Arguments) {
    $process = Start-Process -FilePath $godot -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
    return $process.ExitCode
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
