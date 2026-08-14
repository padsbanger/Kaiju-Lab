extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	var result := BattleResult.new()
	result.map_progress = 0.78
	result.enemies_defeated = 11
	result.waves_survived = 3
	result.biomass_reward = 33
	result.dna_reward = 12
	result.experience_reward = 132
	specimen.set_pending_salvage(SalvageSystem.generate_choices(result, &"city_ruins", 2))
	var lab: LabController = LAB_SCENE.instantiate() as LabController
	root.add_child(lab)
	await process_frame
	lab.bind_specimen(specimen, result)
	await process_frame
	await process_frame
	assert(lab.salvage_panel.visible and lab.deploy_button.disabled)
	var image: Image = root.get_viewport().get_texture().get_image()
	if image == null:
		print("SKIP: current renderer does not expose lab viewport capture")
		quit(0)
		return
	assert(image.save_png(ProjectSettings.globalize_path("res://tmp/lab_salvage.png")) == OK)
	assert(image.get_width() == 640 and image.get_height() == 360)
	print("PASS: rendered post-battle salvage decision panel at the logical viewport")
	quit(0)
