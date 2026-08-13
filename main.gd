class_name Main
extends Node

signal prototype_event(message: String)

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")
const LEGACY_BATTLE_SCENE: PackedScene = preload("res://encounters/combat_scene.tscn")

@onready var scene_root: Node = $SceneRoot
@onready var run_manager: RunManager = $RunManager
var lab_scene: LabController
var combat_scene: CombatScene


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
	combat_scene = LEGACY_BATTLE_SCENE.instantiate() as CombatScene
	scene_root.add_child(combat_scene)
	run_manager.specimen.apply_to_kaiju(combat_scene.kaiju)
	combat_scene.combat_finished.connect(_on_legacy_battle_finished)
	prototype_event.emit("DEPLOYMENT // LEGACY TEST RANGE")


func _on_legacy_battle_finished(result: StringName) -> void:
	var battle_result := BattleResult.new()
	battle_result.outcome = BattleResult.Outcome.VICTORY if result == &"victory" else BattleResult.Outcome.KAIJU_DEAD
	battle_result.capture_components(combat_scene.kaiju)
	battle_result.experience_reward = 50 if result == &"victory" else 10
	battle_result.biomass_reward = 20
	run_manager.record_battle_result(battle_result)
	show_lab()


func _clear_scene_root() -> void:
	for child: Node in scene_root.get_children():
		child.queue_free()
	if scene_root.get_child_count() > 0:
		await get_tree().process_frame
