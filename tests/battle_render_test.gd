extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	var enemies := battle.director.spawn_wave(0)
	for index: int in range(enemies.size()):
		enemies[index].position = battle.kaiju.position + Vector2(100.0 + index * 48.0, 0.0)
	battle.kaiju.scan_for_target()
	await process_frame
	await process_frame
	if DisplayServer.get_name() == "headless":
		print("SKIP: headless display has no GPU viewport")
		quit(0)
		return
	var image := root.get_viewport().get_texture().get_image()
	if image.get_width() != 640 or image.get_height() != 360:
		image.resize(640, 360, Image.INTERPOLATE_NEAREST)
	assert(image.save_png(ProjectSettings.globalize_path("res://tmp/battle.png")) == OK)
	print("PASS: captured autonomous battle at 640x360")
	quit(0)

