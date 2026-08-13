class_name Main
extends Node

signal prototype_event(message: String)

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")
const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")

@onready var scene_root: Node = $SceneRoot
@onready var run_manager: RunManager = $RunManager
var lab_scene: LabController
var combat_scene: SideScrollBattle


func _ready() -> void:
	run_manager.begin_run()
	show_lab()


func show_lab() -> void:
	_clear_scene_root()
	lab_scene = LAB_SCENE.instantiate() as LabController
	scene_root.add_child(lab_scene)
	lab_scene.bind_specimen(run_manager.specimen)
	lab_scene.deploy_requested.connect(deploy)
	prototype_event.emit("GIANT KAIJU LAB // SPECIMEN READY")


func deploy() -> void:
	_clear_scene_root()
	combat_scene = BATTLE_SCENE.instantiate() as SideScrollBattle
	scene_root.add_child(combat_scene)
	combat_scene.bind_specimen(run_manager.specimen)
	combat_scene.battle_finished.connect(_on_battle_finished)
	prototype_event.emit("DEPLOYMENT // CITY RUINS")


func _on_battle_finished(result: BattleResult) -> void:
	run_manager.record_battle_result(result)
	show_lab()


func _clear_scene_root() -> void:
	for child: Node in scene_root.get_children():
		child.queue_free()
	if scene_root.get_child_count() > 0:
		await get_tree().process_frame
