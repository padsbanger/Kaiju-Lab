extends SceneTree


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	assert(MapCatalog.available_for(specimen).size() == 1)
	specimen.unlocked_maps.append("toxic_swamp")
	assert(MapCatalog.available_for(specimen).size() == 2)
	var swamp := MapCatalog.get_by_id(&"toxic_swamp")
	assert(swamp.waves.size() == 4)
	assert(swamp.waves[0].entry_rule == "air")
	assert(swamp.waves[-1].is_boss_wave)
	var battle := preload("res://battle/side_scroll_battle.tscn").instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	battle.bind_specimen(specimen)
	battle.configure_map(swamp)
	var enemies := battle.director.spawn_wave(0)
	assert(enemies.size() == 4 and enemies[0].ranged)
	assert(enemies[0].position.y < swamp.ground_y)
	print("PASS: data-selected second biome reuses battle systems with distinct waves")
	quit(0)

