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
	var claw_index: int = -1
	for index: int in lab.kaiju.anatomy_controller.components.size():
		if lab.kaiju.anatomy_controller.components[index].data.id == &"claw_left":
			claw_index = index
			break
	assert(claw_index >= 0)
	lab.component_list.select(claw_index)
	lab._on_component_selected(claw_index)
	assert(lab.organ_selector.item_count >= 4, "The selected arm must present all compatible organ choices")
	assert(lab.organ_preview.text.contains("HEALTH") and lab.organ_preview.text.contains("MASS"), "Lab must preview organ tradeoffs")
	print("PASS: giant lab displays persistent specimen, organ inspection, resources, and deploy")
	quit(0)
