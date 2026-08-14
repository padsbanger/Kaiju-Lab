class_name ComponentState
extends Resource

@export var definition: ComponentData
@export var health: float = 0.0
@export var damage_cause: String = ""
@export var offline_reason: String = ""


static func create(component_data: ComponentData) -> ComponentState:
	var state := ComponentState.new()
	state.definition = component_data
	state.health = component_data.max_health
	return state


func health_ratio() -> float:
	if definition == null or definition.max_health <= 0.0:
		return 0.0
	return clampf(health / definition.max_health, 0.0, 1.0)


func is_destroyed() -> bool:
	return definition == null or health <= 0.0


func to_dictionary() -> Dictionary:
	return {
		"component_id": String(definition.component_id) if definition != null else "",
		"health": health,
		"damage_cause": damage_cause,
	}

