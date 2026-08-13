extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	var start_x: float = battle.kaiju.global_position.x
	var camera_start: float = battle.camera.global_position.x
	var far_start: float = battle.get_node("FarLayer").position.x
	await create_timer(1.0).timeout
	assert(battle.kaiju.global_position.x > start_x, "Kaiju must advance automatically")
	assert(battle.camera.global_position.x > camera_start, "Camera must follow progress")
	assert(battle.get_node("FarLayer").position.x > far_start, "Parallax layer must respond to scroll")
	var screen_width_world: float = battle.camera.size * (640.0 / 360.0)
	var left_edge: float = battle.camera.global_position.x - screen_width_world * 0.5
	var horizontal_fraction: float = (battle.kaiju.global_position.x - left_edge) / screen_width_world
	assert(horizontal_fraction < 0.4, "Kaiju must remain in the left third composition")
	assert(battle.get_node("LevelRoot/BossGate").position.x > battle.get_node("LevelRoot/StartMarker").position.x)
	print("PASS: side-scrolling advance, left-third camera, parallax, and boss progress axis")
	quit(0)
