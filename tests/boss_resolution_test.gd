extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await physics_frame
	await physics_frame
	battle.battle_director.next_wave_index = battle.battle_director.map_data.waves.size()
	battle.battle_director._begin_boss()
	await process_frame
	assert(battle.boss != null and battle.boss.is_in_group(&"boss"))
	assert(battle.battle_controller.forced_target == battle.boss)
	var pressures: Array[StringName] = []
	battle.boss.pressure_used.connect(func(p: StringName) -> void: pressures.append(p))
	battle.boss.global_position = battle.kaiju.global_position + Vector2(120.0, 0.0)
	battle.boss.cannon_remaining = 0.0
	battle.boss.stomp_remaining = 0.0
	await process_frame
	assert(pressures.size() == 2, "Boss must pressure vitality and anatomy through two attacks")
	var results: Array[BattleResult] = []
	battle.battle_finished.connect(func(result: BattleResult) -> void: results.append(result))
	battle.boss.take_damage(9999.0, battle.kaiju)
	await create_timer(0.5).timeout
	assert(results.size() == 1, "Boss resolution must emit exactly once")
	assert(results[0].boss_defeated and results[0].outcome == BattleResult.Outcome.BOSS_DEFEATED)
	assert(not results[0].component_health.is_empty())
	battle.resolve_battle(BattleResult.Outcome.ENCOUNTER_FAILED)
	await process_frame
	assert(results.size() == 1)
	print("PASS: final boss pressures anatomy and resolves an authoritative result once")
	quit(0)
