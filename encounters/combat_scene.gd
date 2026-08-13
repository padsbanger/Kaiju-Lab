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


func _on_kaiju_health_changed(current: float, maximum: float) -> void:
	kaiju_health_changed.emit(current, maximum)


func _on_encounter_cleared() -> void:
	status_changed.emit("ENCOUNTER CLEARED // HOSTILE ELIMINATED")
	combat_finished.emit(&"victory")


func _on_enemy_count_changed(remaining: int) -> void:
	status_changed.emit("AUTONOMOUS COMBAT // HOSTILES REMAINING: %d" % remaining)


func _on_kaiju_died(_source: Node) -> void:
	status_changed.emit("SPECIMEN LOST // RUN TERMINATED")
	combat_finished.emit(&"defeat")


func _on_component_destroyed(component: KaijuComponent) -> void:
	status_changed.emit("%s DESTROYED // %s OFFLINE" % [component.data.display_name.to_upper(), component.data.function_id.to_upper()])
