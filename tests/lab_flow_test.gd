extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	specimen.dna = 10
	var lab: LabController = LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	lab.bind_specimen(specimen)
	lab.select_socket(&"heart")
	assert(lab.detail_title.text.contains("SIEGE HEART"))
	assert(lab.comparison_label.text.contains("CANDIDATE"))

	specimen.apply_damage(&"heart", 20.0, "test trauma")
	var biomass_before := specimen.biomass
	assert(lab.repair_selected())
	assert(specimen.biomass < biomass_before)
	assert(specimen.components[&"heart"].damage_cause.is_empty())

	assert(lab.install_component_by_id(&"heart_overclocked"))
	assert(specimen.components[&"heart"].definition.component_id == &"heart_overclocked")
	assert(not lab.install_component_by_id(&"acid_left"))

	assert(lab.apply_mutation_by_id(&"bone_plating"))
	assert(specimen.mutations.has("bone_plating"))
	assert(not lab.apply_mutation_by_id(&"bone_plating"))

	var deployment_emitted: Array[bool] = [false]
	lab.deployment_requested.connect(func(_value: SpecimenState) -> void: deployment_emitted[0] = true)
	lab.request_deployment()
	assert(deployment_emitted[0])
	print("PASS: lab inspection, comparison, repair, install, mutation, and deploy preparation")
	quit(0)
