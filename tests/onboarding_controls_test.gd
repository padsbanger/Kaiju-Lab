extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")
const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var lab := LAB_SCENE.instantiate() as LabController
	root.add_child(lab)
	await process_frame
	assert(not lab.guide_panel.visible)
	lab._toggle_guide()
	assert(lab.guide_panel.visible)
	assert((lab.guide_panel.get_node("Body") as Label).text.contains("autonomous"))
	lab.queue_free()

	var battle := BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	var pause_event := InputEventAction.new()
	pause_event.action = &"pause"
	pause_event.pressed = true
	battle._unhandled_input(pause_event)
	assert(paused)
	battle._unhandled_input(pause_event)
	assert(not paused)
	var speed_event := InputEventAction.new()
	speed_event.action = &"speed_up"
	speed_event.pressed = true
	battle._unhandled_input(speed_event)
	assert(battle.battle_speed == 2.0 and Engine.time_scale == 2.0)
	battle._unhandled_input(speed_event)
	assert(battle.battle_speed == 1.0 and Engine.time_scale == 1.0)
	print("PASS: field guide, pause, and autonomous battle speed controls")
	quit(0)

