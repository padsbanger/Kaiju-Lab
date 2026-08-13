extends SceneTree

const ACID: MutationData = preload("res://data/mutations/acid_gland.tres")


func _initialize() -> void:
	var run := RunManager.new()
	root.add_child(run)
	run.begin_run()
	assert(run.encounter_index == 1)
	assert(run.phase == RunManager.RunPhase.COMBAT)
	run.begin_mutation_phase()
	assert(run.phase == RunManager.RunPhase.MUTATION)
	run.record_mutation(ACID)
	run.record_mutation(ACID)
	assert(run.selected_mutation_ids == [&"acid_gland"], "Mutation state must be unique")
	run.advance_encounter()
	assert(run.encounter_index == 2 and run.phase == RunManager.RunPhase.COMBAT)
	run.finish_run(true)
	assert(run.phase == RunManager.RunPhase.COMPLETE)
	run.begin_run()
	assert(run.encounter_index == 1 and run.selected_mutation_ids.is_empty(), "Restart must clear run state")
	print("PASS: two-encounter run state, mutation persistence, completion, and clean restart")
	quit(0)
