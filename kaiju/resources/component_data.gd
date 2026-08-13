class_name ComponentData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var max_health: float = 50.0
@export var mass: float = 10.0
@export var tags: Array[StringName] = []
@export var attachment_type: StringName
@export var function_id: StringName
@export var critical: bool = false
@export var energy_generation: float = 0.0
@export var energy_consumption: float = 0.0
