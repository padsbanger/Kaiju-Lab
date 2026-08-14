extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	specimen.dna = 8
	specimen.apply_damage(&"arm_left", 38.0, "field trauma")
	var lab: LabController = LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	lab.bind_specimen(specimen)
	lab.select_socket(&"arm_left")
	await process_frame
	await process_frame
	if DisplayServer.get_name() == "headless":
		print("SKIP: headless display has no GPU viewport")
		quit(0)
		return
	var viewport_texture := root.get_viewport().get_texture()
	if viewport_texture == null:
		print("SKIP: renderer does not expose viewport pixels")
		quit(0)
		return
	var image := viewport_texture.get_image()
	if image == null:
		print("SKIP: renderer does not expose viewport image")
		quit(0)
		return
	if image.get_width() != 640 or image.get_height() != 360:
		image.resize(640, 360, Image.INTERPOLATE_NEAREST)
	assert(image.save_png(ProjectSettings.globalize_path("res://tmp/lab.png")) == OK)
	print("PASS: captured functional laboratory at 640x360")
	quit(0)
