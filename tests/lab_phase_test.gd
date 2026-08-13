extends SceneTree

const LAB_SCENE: PackedScene = preload("res://ui/mutation_selection/mutation_selection.tscn")
const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var lab: MutationSelection = LAB_SCENE.instantiate() as MutationSelection
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(lab)
	root.add_child(kaiju)
	await process_frame
	lab.set_anatomy_summary(kaiju)
	lab.present_choices()
	assert(lab.mutation_pool.size() >= 3)
	assert(not lab.get_node("Panel/Margin/Rows/Cards/LabInspector/Margin/Rows/AnatomyList").text.is_empty())
	assert(not lab.get_node("Panel/Margin/Rows/Cards/LabInspector/Margin/Rows/PreviewTitle").text.is_empty())
	assert(not lab.selection_locked)
	print("PASS: lab exposes anatomy, three choices, and focused mutation preview")
	quit(0)
