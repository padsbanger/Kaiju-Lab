extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")
const TOXIC_MAP: BattleMapData = preload("res://data/battles/toxic_swamp.tres")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	battle.configure_map(TOXIC_MAP)
	battle.scroll_controller.set_process(false)
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	if image == null:
		print("SKIP: current renderer does not expose viewport capture")
		quit(0)
		return
	assert(image.save_png(ProjectSettings.globalize_path("res://tmp/toxic_swamp.png")) == OK)
	assert(image.get_width() == 640 and image.get_height() == 360)
	print("PASS: rendered data-selected Toxic Swamp battle and Parallax2D")
	quit(0)
