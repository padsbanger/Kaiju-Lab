extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")


func _initialize() -> void:
	var lab: LabController = LAB_SCENE.instantiate() as LabController
	root.add_child(lab)
	await process_frame
	var specimen := SpecimenState.new()
	lab.bind_specimen(specimen)
	assert(lab.component_list.item_count == lab.kaiju.anatomy_controller.components.size())
	assert(lab.deploy_button.visible and not lab.deploy_button.disabled)
	assert(lab.kaiju.pixel_animation.state == PixelAnimationController.State.IDLE)
	print("PASS: giant lab displays persistent specimen, organ inspection, resources, and deploy")
	quit(0)
