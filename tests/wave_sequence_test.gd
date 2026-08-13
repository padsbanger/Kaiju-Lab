extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	var director: BattleDirector = battle.battle_director
	director.set_process(false)
	assert(director.map_data.waves.size() == 4)
	await process_frame
	assert(director.remaining_count() == director.map_data.waves[0].enemy_scenes.size(), "A deployment must open with a visible first-contact wave")
	for enemy: Node2D in director.living_enemies:
		assert(enemy.global_position.x > battle.right_screen_x(), "Ahead-entry enemies must begin beyond the right screen edge")
		await physics_frame
		var visual: Sprite2D = enemy.get_node_or_null("Body") as Sprite2D
		assert(visual != null and visual.flip_h, "Right-edge enemies must flip their sprite toward the kaiju")
		assert(is_zero_approx(enemy.rotation), "2D enemies must not rotate away from the kaiju")
	for enemy: Node2D in director.living_enemies.duplicate():
		enemy.take_damage(9999.0, battle.kaiju)
	await process_frame
	await process_frame
	for index: int in director.map_data.waves.size():
		if index == 0:
			continue
		director.start_wave(index)
		await process_frame
		assert(director.current_wave_index == index)
		assert(director.remaining_count() == director.map_data.waves[index].enemy_scenes.size())
		for enemy: Node2D in director.living_enemies.duplicate():
			enemy.take_damage(9999.0, battle.kaiju)
		await process_frame
		await process_frame
		assert(director.remaining_count() == 0, "Defeated waves must not leave stale targets")
	assert(director.next_wave_index == 4)
	assert(director.enemies_defeated == 11)
	assert(director.map_data.target_duration_seconds >= 120.0 and director.map_data.target_duration_seconds <= 300.0)
	print("PASS: complete accelerated pre-boss wave sequence and spawn rules")
	quit(0)
