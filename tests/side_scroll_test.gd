extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	assert(battle is Node2D and battle.camera is Camera2D, "Battle and camera must be native 2D")
	var start_x: float = battle.kaiju.global_position.x
	var camera_start: float = battle.camera.global_position.x
	var near_layer: Parallax2D = battle.parallax.get_layers()[3]
	var near_start: float = near_layer.get_screen_transform().origin.x
	await create_timer(1.0).timeout
	assert(battle.kaiju.global_position.x > start_x, "Kaiju must advance automatically")
	assert(battle.camera.global_position.x > camera_start, "Camera must follow progress")
	var near_end: float = near_layer.get_screen_transform().origin.x
	assert(not is_equal_approx(near_end, near_start), "Near parallax must react to Camera2D movement")
	var screen_width_world: float = 640.0 / battle.camera.zoom.x
	var left_edge: float = battle.camera.get_screen_center_position().x - screen_width_world * 0.5
	var horizontal_fraction: float = (battle.kaiju.global_position.x - left_edge) / screen_width_world
	assert(horizontal_fraction < 0.4, "Kaiju must remain in the left third composition")
	assert(battle.get_node("LevelRoot/BossGate").position.x > battle.get_node("LevelRoot/StartMarker").position.x)
	print("PASS: side-scrolling advance, left-third camera, parallax, and boss progress axis")
	quit(0)
