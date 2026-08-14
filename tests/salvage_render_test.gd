extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	var result := BattleResult.new()
	result.victory = true
	result.map_id = &"city_ruins"
	result.biomass_reward = 30
	result.dna_reward = 5
	result.experience_reward = 80
	specimen.set_pending_salvage(SalvageSystem.generate_choices(result, 1))
	var lab: LabController = LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	lab.bind_specimen(specimen)
	await process_frame
	assert(lab.salvage_panel.visible and lab.deploy_button.disabled)
	if DisplayServer.get_name() == "headless":
		print("SKIP: headless display has no GPU viewport")
		quit(0)
		return
	var image := root.get_viewport().get_texture().get_image()
	if image.get_width() != 640 or image.get_height() != 360:
		image.resize(640, 360, Image.INTERPOLATE_NEAREST)
	assert(image.save_png(ProjectSettings.globalize_path("res://tmp/salvage.png")) == OK)
	print("PASS: captured mandatory salvage choice at 640x360")
	quit(0)

