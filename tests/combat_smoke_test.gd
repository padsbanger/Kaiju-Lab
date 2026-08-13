extends SceneTree

const COMBAT_SCENE: PackedScene = preload("res://encounters/combat_scene.tscn")

var result: StringName = &""


func _initialize() -> void:
	print("TEST: autonomous combat smoke test started")
	var combat: CombatScene = COMBAT_SCENE.instantiate() as CombatScene
	root.add_child(combat)
	combat.combat_finished.connect(_on_combat_finished)
	_run_test.call_deferred(combat)


func _run_test(combat: CombatScene) -> void:
	var timeout_seconds: float = 35.0
	while result == &"" and timeout_seconds > 0.0:
		await create_timer(0.1).timeout
		timeout_seconds -= 0.1
	if result != &"victory":
		push_error("Expected autonomous combat victory, got '%s'" % result)
		quit(1)
		return
	if combat.kaiju.health.current_health >= combat.kaiju.health.max_health:
		push_error("Enemy never damaged the kaiju")
		quit(1)
		return
	print("PASS: autonomous combat ended in victory after mutual damage; kaiju HP %.1f/%.1f" % [combat.kaiju.health.current_health, combat.kaiju.health.max_health])
	quit(0)


func _on_combat_finished(combat_result: StringName) -> void:
	result = combat_result
