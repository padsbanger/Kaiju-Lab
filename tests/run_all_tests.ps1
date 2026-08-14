$ErrorActionPreference = "Stop"

$godot = if (Get-Command godot.exe -ErrorAction SilentlyContinue) {
    (Get-Command godot.exe).Source
} else {
    "C:\godot\godot.exe"
}

$tests = @(
    "res://tests/persistent_state_test.gd",
    "res://tests/save_system_test.gd",
    "res://tests/session_progression_test.gd",
    "res://tests/salvage_choice_test.gd",
    "res://tests/multi_socket_build_test.gd",
    "res://tests/campaign_circuit_test.gd",
	"res://tests/lab_salvage_render_test.gd",
    "res://tests/pixel_pipeline_test.gd",
    "res://tests/active_2d_architecture_test.gd",
    "res://tests/lab_entry_test.gd",
    "res://tests/side_scroll_test.gd",
    "res://tests/parallax_test.gd",
    "res://tests/biome_reuse_test.gd",
    "res://tests/toxic_swamp_render_test.gd",
    "res://tests/parallax_render_test.gd",
    "res://tests/autonomous_advance_test.gd",
    "res://tests/wave_sequence_test.gd",
    "res://tests/enemy_facing_test.gd",
    "res://tests/combat_readability_test.gd",
    "res://tests/boss_resolution_test.gd",
    "res://tests/regeneration_test.gd",
    "res://tests/progression_loadout_test.gd",
    "res://tests/vertical_slice_test.gd",
    "res://tests/deployment_soak_test.gd",
    "res://tests/polish_controls_test.gd",
    "res://tests/anatomy_test.gd",
    "res://tests/metabolism_test.gd",
    "res://tests/brain_test.gd",
    "res://tests/mutation_test.gd",
    "res://tests/prototype_loop_test.gd"
)

foreach ($test in $tests) {
    Write-Host "RUN $test"
    $arguments = @("--headless", "--path", ".", "--script", $test)
    if ($test -in @("res://tests/parallax_render_test.gd", "res://tests/toxic_swamp_render_test.gd", "res://tests/lab_salvage_render_test.gd")) {
        # The dummy headless renderer cannot expose viewport pixels; the test
        # still validates structure in CI and performs capture on a GPU run.
        $arguments = @("--path", ".", "--script", $test)
    }
	$process = Start-Process -FilePath $godot -ArgumentList $arguments -PassThru
	if (-not $process.WaitForExit(60000)) {
		$process.Kill()
		throw "Test timed out: $test"
	}
    if ($process.ExitCode -ne 0) {
        throw "Test failed: $test (exit $($process.ExitCode))"
    }
}

Write-Host "PASS: $($tests.Count) Kaiju Lab test scripts"
