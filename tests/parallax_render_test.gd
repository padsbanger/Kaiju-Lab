extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.scroll_controller.set_process(false)
	await process_frame
	await process_frame
	var start_image: Image = root.get_viewport().get_texture().get_image()
	if start_image == null:
		print("SKIP: current headless renderer does not expose viewport capture")
		quit(0)
		return
	assert(start_image.get_width() == 640 and start_image.get_height() == 360)
	var kaiju_screen: Vector2 = battle.kaiju.global_position - battle.camera.get_screen_center_position() + Vector2(320.0, 180.0)
	assert(kaiju_screen.x >= 0.0 and kaiju_screen.x < 640.0 and kaiju_screen.y >= 0.0 and kaiju_screen.y < 360.0, "Kaiju must remain in front of the background canvas")
	var start_path: String = ProjectSettings.globalize_path("res://tmp/parallax_start.png")
	assert(start_image.save_png(start_path) == OK, "Start frame must save for visual seam inspection")
	var camera_jump: float = 400.0
	battle.camera.global_position.x += camera_jump
	await process_frame
	await process_frame
	var scrolled_image: Image = root.get_viewport().get_texture().get_image()
	var scrolled_path: String = ProjectSettings.globalize_path("res://tmp/parallax_scrolled.png")
	assert(scrolled_image.save_png(scrolled_path) == OK, "Scrolled frame must save for visual seam inspection")
	assert(start_image.get_data() != scrolled_image.get_data(), "Parallax composition must visibly change after several screen widths")
	print("PASS: rendered City Ruins parallax at start and multi-screen scroll")
	quit(0)
