extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const ACID: MutationData = preload("res://data/mutations/acid_gland.tres")


func _initialize() -> void:
	var main: Main = MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	current_scene = main
	_run.call_deferred(main)


func _run(main: Main) -> void:
	await process_frame
	_defeat_active_enemies()
	await process_frame
	assert(main.run_manager.phase == RunManager.RunPhase.MUTATION)
	assert(main.mutation_selection.visible)
	main.mutation_selection._on_mutation_chosen(ACID)
	await process_frame
	assert(main.run_manager.encounter_index == 2)
	assert(&"acid_gland" in main.run_manager.selected_mutation_ids)
	assert(main.combat_scene.kaiju.get_node("ComponentRoot/MutationSocket").get_child_count() == 1)
	_defeat_active_enemies()
	await process_frame
	assert(main.run_manager.phase == RunManager.RunPhase.COMPLETE)
	assert(main.run_end_screen.visible)
	print("PASS: full UI loop reaches mutation, preserves visible change, and completes encounter two")
	quit(0)


func _defeat_active_enemies() -> void:
	for enemy: Node in get_nodes_in_group(&"enemies"):
		var health: Health = enemy.get_node("Health") as Health
		health.take_damage(health.max_health * 10.0)
