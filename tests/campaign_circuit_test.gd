extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")
const MAP_CATALOG: Script = preload("res://battle/map_catalog.gd")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	var city: BattleMapData = MAP_CATALOG.by_id(&"city_ruins")
	var toxic: BattleMapData = MAP_CATALOG.by_id(&"toxic_swamp")
	assert(city != null and toxic != null)
	assert(city.is_unlocked_for(specimen) and not toxic.is_unlocked_for(specimen))
	var campaign_ids: Array[StringName] = [&"city_ruins", &"toxic_swamp"]
	assert(not specimen.record_map_victory(&"city_ruins", campaign_ids))
	assert(toxic.is_unlocked_for(specimen))
	assert(specimen.map_clear_count(&"city_ruins") == 1 and specimen.circuit_level == 1)
	var biomass_before_cache: int = specimen.biomass
	assert(specimen.record_map_victory(&"toxic_swamp", campaign_ids))
	assert(specimen.circuit_level == 2 and specimen.threat_tier == 2)
	assert(specimen.circuit_cleared_map_ids.is_empty() and specimen.biomass > biomass_before_cache)
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	battle.configure_map(city, 3)
	battle.battle_director.set_process(false)
	var wave: WaveData = battle.battle_director.map_data.waves[0]
	var base_scene: PackedScene = wave.enemy_scenes[0]
	var baseline: Node2D = base_scene.instantiate() as Node2D
	root.add_child(baseline)
	await process_frame
	var base_health: float = (baseline.get_node("Health") as Health).max_health
	baseline.queue_free()
	battle.battle_director.living_enemies.clear()
	battle.battle_director.next_wave_index = 0
	battle.battle_director.start_wave(0)
	await process_frame
	var scaled: Node2D = battle.battle_director.living_enemies[0]
	assert((scaled.get_node("Health") as Health).max_health > base_health)
	var result: BattleResult = battle.build_result(BattleResult.Outcome.BOSS_DEFEATED)
	assert(result.threat_tier == 3 and result.experience_reward > 300)
	print("PASS: map prerequisites, circuit completion, threat scaling, and reward scaling form a replayable campaign")
	quit(0)
