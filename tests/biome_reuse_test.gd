extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")
const TOXIC_MAP: BattleMapData = preload("res://data/battles/toxic_swamp.tres")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	battle.configure_map(TOXIC_MAP)
	await process_frame
	assert(battle.battle_director.map_data.map_id == &"toxic_swamp")
	assert(battle.get_node("HazardRoot").get_child_count() == 3, "Toxic Swamp must install biome hazards through map data")
	assert(TOXIC_MAP.boss_scene_path.ends_with("bog_titan.tscn"))
	assert(battle.parallax.name == "ToxicSwampParallax")
	var layers: Array[Parallax2D] = battle.parallax.get_layers()
	assert(layers.size() == 5, "Second biome must reuse the five-layer parallax controller")
	assert(is_equal_approx(layers[0].scroll_scale.x, 0.04))
	assert(is_equal_approx(layers[4].scroll_scale.x, 1.18))
	for layer: Parallax2D in layers:
		assert(layer.repeat_size.x == 1672.0, "Mirrored A/B tile width must drive seamless repetition")
		assert(layer.get_child_count() >= 2)
	assert(TOXIC_MAP.waves.size() == 4 and TOXIC_MAP.target_duration_seconds >= 120.0)
	print("PASS: data-selected Toxic Swamp reuses battle, camera, waves, and five-layer Parallax2D")
	quit(0)
