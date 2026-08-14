extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	# Accelerate simulated time while preserving ordinary physics and AI paths.
	Engine.time_scale = 8.0
	await create_timer(12.0, false, false, true).timeout
	Engine.time_scale = 1.0
	assert(battle.elapsed_seconds >= 80.0, "Soak must cover a meaningful deployment duration")
	assert(battle.battle_director.remaining_count() <= 12, "Living enemies must remain bounded")
	assert(get_nodes_in_group(&"projectiles").size() <= 32, "Projectile population must remain bounded")
	assert(battle.parallax.get_layers().size() == 5)
	assert(battle.kaiju.resource_controller.energy >= 0.0 and battle.kaiju.resource_controller.heat <= 100.0)
	print("PASS: accelerated multi-minute deployment keeps enemies, projectiles, metabolism, and parallax bounded")
	quit(0)
