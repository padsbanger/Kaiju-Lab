class_name ComponentState
extends Resource

@export var component_id: StringName
@export var current_health: float
@export var max_health: float
@export var installed_resource_path: String
@export var last_damage_cause: String = "No recorded damage"


func is_destroyed() -> bool:
	return current_health <= 0.0


func health_ratio() -> float:
	return current_health / max_health if max_health > 0.0 else 0.0
