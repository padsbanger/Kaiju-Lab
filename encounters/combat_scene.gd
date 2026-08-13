class_name CombatScene
extends Node3D

signal combat_finished(result: StringName)

@onready var camera: Camera3D = %Camera3D
@onready var kaiju: Kaiju = %Kaiju
@onready var encounter_manager: EncounterManager = $EncounterManager


func _ready() -> void:
	camera.look_at(Vector3(0.0, 1.0, 0.0))
	kaiju.health.health_changed.connect(_on_kaiju_health_changed)
	kaiju.died.connect(_on_kaiju_died)
	kaiju.anatomy_controller.component_destroyed.connect(_on_component_destroyed)
	encounter_manager.encounter_cleared.connect(_on_encounter_cleared)
	encounter_manager.enemy_count_changed.connect(_on_enemy_count_changed)
	encounter_manager.register_existing_enemies.call_deferred()
	status_changed.emit("AUTONOMOUS COMBAT // TARGET ACQUISITION")


signal status_changed(message: String)
signal kaiju_health_changed(current: float, maximum: float)

const MELEE_SCENE: PackedScene = preload("res://enemies/melee_soldier.tscn")
const RANGED_SCENE: PackedScene = preload("res://enemies/ranged_soldier.tscn")
const TANK_SCENE: PackedScene = preload("res://enemies/tank.tscn")

var combat_active: bool = true


func _on_kaiju_health_changed(current: float, maximum: float) -> void:
	kaiju_health_changed.emit(current, maximum)


func _on_encounter_cleared() -> void:
	if not combat_active:
		return
	combat_active = false
	status_changed.emit("ENCOUNTER CLEARED // HOSTILE ELIMINATED")
	combat_finished.emit(&"victory")


func _on_enemy_count_changed(remaining: int) -> void:
	status_changed.emit("AUTONOMOUS COMBAT // HOSTILES REMAINING: %d" % remaining)


func _on_kaiju_died(_source: Node) -> void:
	if not combat_active:
		return
	combat_active = false
	status_changed.emit("SPECIMEN LOST // RUN TERMINATED")
	combat_finished.emit(&"defeat")


func _on_component_destroyed(component: KaijuComponent) -> void:
	status_changed.emit("%s DESTROYED // %s OFFLINE" % [component.data.display_name.to_upper(), component.data.function_id.to_upper()])


func start_encounter(encounter_index: int) -> void:
	for enemy: Node in get_tree().get_nodes_in_group(&"enemies"):
		enemy.queue_free()
	for projectile: Node in get_tree().get_nodes_in_group(&"projectiles"):
		projectile.queue_free()
	await get_tree().process_frame
	encounter_manager.reset()
	kaiju.reset_for_encounter(Vector3(-4.5, 0.0, 0.0))
	var formation: Array[Dictionary] = _formation_for(encounter_index)
	for entry: Dictionary in formation:
		var scene: PackedScene = entry["scene"] as PackedScene
		var enemy: Node3D = scene.instantiate() as Node3D
		enemy.position = entry["position"] as Vector3
		add_child(enemy)
		encounter_manager.register_enemy(enemy)
	combat_active = true
	encounter_manager.enemy_count_changed.emit(encounter_manager.active_enemies.size())


func _formation_for(encounter_index: int) -> Array[Dictionary]:
	if encounter_index <= 1:
		return [
			{"scene": MELEE_SCENE, "position": Vector3(5.5, 0.0, 0.0)},
			{"scene": RANGED_SCENE, "position": Vector3(7.5, 0.0, -4.5)},
			{"scene": TANK_SCENE, "position": Vector3(9.5, 0.0, 4.5)},
		]
	return [
		{"scene": MELEE_SCENE, "position": Vector3(4.5, 0.0, -2.2)},
		{"scene": MELEE_SCENE, "position": Vector3(5.5, 0.0, 2.8)},
		{"scene": RANGED_SCENE, "position": Vector3(8.0, 0.0, -5.0)},
		{"scene": RANGED_SCENE, "position": Vector3(9.0, 0.0, 1.0)},
		{"scene": TANK_SCENE, "position": Vector3(10.0, 0.0, 5.0)},
	]
