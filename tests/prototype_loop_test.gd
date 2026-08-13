extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	var main: Main = MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	current_scene = main
	_run.call_deferred(main)


func _run(main: Main) -> void:
	await process_frame
	assert(main.lab_scene != null, "Project must open in the giant lab")
	assert(main.run_manager.specimen.component_states.size() >= 6)
	main.deploy()
	await process_frame
	assert(main.combat_scene != null, "Deploy must transition to a battle")
	assert(main.combat_scene.kaiju != null)
	print("PASS: project opens in persistent lab and deploys the same specimen")
	quit(0)
