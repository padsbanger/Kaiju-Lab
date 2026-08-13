extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	var director: BattleDirector = battle.battle_director
	director.set_process(false)
	assert(director.map_data.waves.size() == 4)
	for index: int in director.map_data.waves.size():
		director.start_wave(index)
		await process_frame
		assert(director.current_wave_index == index)
		assert(director.remaining_count() == director.map_data.waves[index].enemy_scenes.size())
		for enemy: Node3D in director.living_enemies.duplicate():
			enemy.take_damage(9999.0, battle.kaiju)
		await process_frame
		await process_frame
		assert(director.remaining_count() == 0, "Defeated waves must not leave stale targets")
	assert(director.next_wave_index == 4)
	assert(director.enemies_defeated == 11)
	assert(director.map_data.target_duration_seconds >= 120.0 and director.map_data.target_duration_seconds <= 300.0)
	print("PASS: complete accelerated pre-boss wave sequence and spawn rules")
	quit(0)
