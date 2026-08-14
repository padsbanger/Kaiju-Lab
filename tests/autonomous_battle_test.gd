extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	battle.bind_specimen(specimen)
	assert(battle.map_data.map_id == &"city_ruins")
	var parallax_count := 0
	for child: Node in battle.get_children():
		if child is Parallax2D:
			parallax_count += 1
			assert((child as Parallax2D).repeat_size.x == 640.0)
	assert(parallax_count == 5)

	var enemies := battle.director.spawn_wave(0)
	assert(enemies.size() == 3)
	var enemy := enemies[0]
	enemy.global_position = battle.kaiju.global_position + Vector2(40.0, 0.0)
	battle.kaiju.scan_for_target()
	var health_before := enemy.health
	battle.kaiju._physics_process(0.1)
	assert(battle.kaiju.battle_state == KaijuBattleActor.BattleState.ENGAGE)
	assert(enemy.health < health_before)

	specimen.apply_damage(&"heart", 999.0, "test disruption")
	battle.kaiju._physics_process(0.1)
	assert(battle.kaiju.battle_state == KaijuBattleActor.BattleState.STAGGERED)
	assert(specimen.movement_multiplier() < 0.2)
	print("PASS: autonomous state, staggered scans, attacks, anatomy failure, and Parallax2D")
	quit(0)
