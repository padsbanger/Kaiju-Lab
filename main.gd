class_name Main
extends Node

signal prototype_event(message: String)

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")

@onready var scene_root: Node = $SceneRoot
@onready var run_manager: RunManager = $RunManager
var lab_scene: LabController
var combat_scene: SideScrollBattle
var transition_in_progress: bool = false
var initialize_from_save: bool = true


func _ready() -> void:
	if initialize_from_save:
		run_manager.initialize_session()
	else:
		run_manager.begin_run()
	show_lab()


func show_lab() -> void:
	transition_in_progress = true
	_clear_scene_root()
	combat_scene = null
	lab_scene = LAB_SCENE.instantiate() as LabController
	scene_root.add_child(lab_scene)
	lab_scene.bind_specimen(run_manager.specimen, run_manager.latest_battle_result)
	lab_scene.deploy_requested.connect(deploy)
	lab_scene.map_selected.connect(run_manager.select_map)
	lab_scene.salvage_requested.connect(_on_salvage_requested)
	lab_scene.new_specimen_requested.connect(restart_specimen)
	transition_in_progress = false
	prototype_event.emit("GIANT KAIJU LAB // SPECIMEN READY")


func deploy() -> void:
	if transition_in_progress or run_manager.specimen.has_pending_salvage():
		return
	transition_in_progress = true
	_clear_scene_root()
	lab_scene = null
	var battle_scene: PackedScene = load(run_manager.selected_map.battle_scene_path) as PackedScene
	combat_scene = battle_scene.instantiate() as SideScrollBattle
	scene_root.add_child(combat_scene)
	combat_scene.configure_map(run_manager.selected_map, run_manager.specimen.threat_tier)
	combat_scene.bind_specimen(run_manager.specimen)
	combat_scene.battle_finished.connect(_on_battle_finished)
	transition_in_progress = false
	prototype_event.emit("DEPLOYMENT // %s // THREAT %d" % [run_manager.selected_map.display_name, run_manager.specimen.threat_tier])


func _on_battle_finished(result: BattleResult) -> void:
	run_manager.record_battle_result(result)
	show_lab()


func restart_specimen() -> void:
	run_manager.new_specimen()
	show_lab()


func _on_salvage_requested(index: int) -> void:
	if run_manager.claim_salvage(index) and lab_scene != null:
		lab_scene.refresh_after_salvage()


func _clear_scene_root() -> void:
	for child: Node in scene_root.get_children():
		child.queue_free()
	if scene_root.get_child_count() > 0:
		await get_tree().process_frame
