extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")
const MAP_CATALOG: Script = preload("res://battle/map_catalog.gd")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	var lab: LabController = LAB_SCENE.instantiate() as LabController
	root.add_child(lab)
	await process_frame
	lab.bind_specimen(specimen)
	assert(lab.mutation_selector.item_count >= 3)
	var mutation: MutationData = lab.mutation_selector.get_item_metadata(0) as MutationData
	var before_dna: int = specimen.dna
	lab.mutation_selector.select(0)
	lab._install_selected_mutation()
	assert(mutation.id in specimen.mutation_ids and specimen.dna < before_dna, "Lab mutation choice must spend DNA and persist")
	var result := BattleResult.new()
	result.boss_defeated = true
	var run := RunManager.new()
	run.save_path = "user://kaiju_lab_session_test.json"
	root.add_child(run)
	run.specimen = specimen
	run.selected_map = MAP_CATALOG.by_id(&"city_ruins")
	run.record_battle_result(result)
	assert(&"toxic_swamp" in specimen.unlocked_map_ids, "First boss victory must unlock the second biome")
	if FileAccess.file_exists(run.save_path):
		DirAccess.remove_absolute(run.save_path)
	print("PASS: lab mutation purchase and boss-driven biome unlock progression")
	quit(0)
