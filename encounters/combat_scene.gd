class_name CombatScene
extends Node3D

signal combat_finished(result: StringName)

@onready var camera: Camera3D = %Camera3D
@onready var kaiju: Kaiju = %Kaiju
@onready var enemy: MeleeSoldier = %MeleeSoldier


func _ready() -> void:
	camera.look_at(Vector3(0.0, 1.0, 0.0))
	kaiju.health.health_changed.connect(_on_kaiju_health_changed)
	kaiju.died.connect(_on_kaiju_died)
	enemy.died.connect(_on_enemy_died)
	status_changed.emit("AUTONOMOUS COMBAT // TARGET ACQUISITION")


signal status_changed(message: String)
signal kaiju_health_changed(current: float, maximum: float)


func _on_kaiju_health_changed(current: float, maximum: float) -> void:
	kaiju_health_changed.emit(current, maximum)


func _on_enemy_died(_enemy: MeleeSoldier) -> void:
	status_changed.emit("ENCOUNTER CLEARED // HOSTILE ELIMINATED")
	combat_finished.emit(&"victory")


func _on_kaiju_died(_source: Node) -> void:
	status_changed.emit("SPECIMEN LOST // RUN TERMINATED")
	combat_finished.emit(&"defeat")
