extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	assert(battle.map_data.waves.size() == 4)
	assert(battle.map_data.waves[-1].is_boss_wave)
	var boss_defeated: Array[bool] = [false]
	battle.director.boss_defeated.connect(func() -> void: boss_defeated[0] = true)
	var boss_wave := battle.director.spawn_wave(3)
	assert(boss_wave.size() == 1 and boss_wave[0].is_boss)
	boss_wave[0].take_damage(9999.0)
	assert(boss_defeated[0])
	assert(battle.director.defeated_count == 1)
	print("PASS: data-driven wave sequence and boss resolution")
	quit(0)

