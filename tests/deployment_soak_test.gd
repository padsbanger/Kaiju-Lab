extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	for tick: int in range(3000):
		specimen.simulate(0.1, tick % 20 < 14)
		if tick % 18 == 0 and specimen.heat < 70.0:
			specimen.try_activate(&"arm_left")
		assert(is_finite(specimen.energy) and specimen.energy >= 0.0 and specimen.energy <= SpecimenState.MAX_ENERGY)
		assert(is_finite(specimen.blood) and specimen.blood >= 0.0 and specimen.blood <= SpecimenState.MAX_BLOOD)
		assert(is_finite(specimen.oxygen) and specimen.oxygen >= 0.0 and specimen.oxygen <= SpecimenState.MAX_OXYGEN)
		assert(is_finite(specimen.heat) and specimen.heat >= 0.0 and specimen.heat <= SpecimenState.MAX_HEAT)

	var battle := BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	var max_active := 0
	for wave_index: int in range(battle.map_data.waves.size()):
		var enemies := battle.director.spawn_wave(wave_index)
		max_active = maxi(max_active, battle.director.active_enemy_count)
		for enemy: BattleEnemy in enemies:
			enemy.take_damage(99999.0)
	assert(max_active <= 4)
	assert(battle.director.active_enemy_count == 0)
	var travel_minutes := battle.map_data.length / (KaijuBattleActor.BASE_ADVANCE_SPEED * 0.5) / 60.0
	assert(travel_minutes >= 2.0 and travel_minutes <= 5.0)
	print("PASS: five-minute metabolism soak and bounded authored wave population")
	quit(0)

